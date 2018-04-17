;"*****************************************************************************

  This file defines library update routines for use with either network
  libraries or resident libraries.

  LUP-USER.MUD: EDIT HISTORY                                Machine Independent

  COMPILATION: Spliced in at compile time.

    JUN84 [Shane] - Created.
  31OCT84 [Shane] - Commented, cleaned up.
  10NOV84 [Shane] - LUP-ADD-FILE, LUP-DEL-FILE
  ****************************************************************************"

;"ACTLIB -- The active library represented as a channel. If the library is
  resident, we never write to this channel, since LUPI-KEY in LUP-BASE
  contains the actual shadow library (ACTLIB is the channel that the write
  lock is placed on.)"

<OR <GASSIGNED? ACTLIB> <SETG ACTLIB %<> '<OR CHANNEL FALSE>>>

;"LUP-CREATE --
  Effect:   Create library named NAME with associated log file. Second name
	    defaults to LIBMIM (LOG for log file). NBKTS is the number of
            buckets to use.
  Returns:  The full name of the library file."

<DEFINE LUP-CREATE ("OPT" (NAME:STRING "LIBMIM") (NBKTS:FIX ,INITIAL-BUCKETS))
   <LUPI-CREATE .NAME .NBKTS>>

;"LUP-ABORT --
  Effect:   If there is an update in progress, abort all changes after the
	    last install or lock."

<DEFINE LUP-ABORT ("AUX" (LIBC:<OR CHANNEL FALSE> ,ACTLIB)
			 (OUTCHAN:CHANNEL .OUTCHAN))
   <SETG ACTLIB %<>>
   <COND (.LIBC
	  <IFSYS ("VAX"
		  <COND (<REMOTE? .LIBC>
			 <COND (<CHANNEL-OPEN? .LIBC>
				<CHANNEL-OP .LIBC:NET WRITE-BUFFER
					     ![%,UPDATE-ABORT]>)>)
			(T
			 <LUPI-ABORT>)>)
		 ("TOPS20"
		  <LUPI-ABORT>)>
	  <COND (<CHANNEL-OPEN? .LIBC> <CLOSE .LIBC>)>
	  <PRINTSTRING "Pending requests aborted.">
	  <CRLF>)>>

;"LUP-ACT --
  Effect:   Lock the library named LIBS if there is no pre-existing lock.
  Returns:  T if successful, otherwise FALSE."

<DEFINE LUP-ACT ("OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
		 "AUX" (OUTCHAN:CHANNEL .OUTCHAN)
		       (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG (LOCK:<OR CHANNEL FALSE>)
       <COND (,ACTLIB <RETURN #FALSE ("LIBRARY ALREADY ACTIVATED")>)
	     (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>> <RETURN .LIBC>)>
       <IFSYS ("VAX"
	       <COND (<REMOTE? .LIBC>
		      <CHANNEL-OP .LIBC:NET TIMEOUT ,UPDATE-TIMEOUT>
		      <BIND ((MSG:UVECTOR <STACK <UVECTOR ,UPDATE-REQUEST>>))
			 <CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
			 <COND (<NOT <GET-REMOTE-RESPONSE .LIBC .MSG>>
				<CLOSE .LIBC>
				<RETURN #FALSE ("NETWORK ERROR")>)
			       (<N==? <1 .MSG> ,ACK>
				<CLOSE .LIBC>
				<RETURN #FALSE ("LOCKED")>)>
			 <SETG ACTLIB .LIBC>
			 <PRINTSTRING ,SERVER-NAME>
			 <PRINTSTRING " locked. ">
			 <CRLF>
			 <RETURN>>)>)>
       <COND (<SET LOCK <LUPI-LOCK .LIBC>>
	      <SETG ACTLIB <SET LIBC .LOCK>>
	      <PRINTSTRING <CHANNEL-OP .LIBC:DSK NAME>>
	      <PRINTSTRING " locked. ">
	      <CRLF>)
	     (T
	      <CLOSE .LIBC>
	      .LOCK)>>
    <BIND ()
       <LUP-ABORT>
       <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>>

;"LUP-DCT --
  Effect:   Unlock the active library and install all changes since the
	    last lock or install.
  Returns:  T if successful, otherwise FALSE."

<DEFINE LUP-DCT ("AUX" (LIBC:<OR CHANNEL FALSE> ,ACTLIB))
   <UNWIND
    <PROG ((OUTCHAN:CHANNEL .OUTCHAN))
       <COND (<NOT .LIBC> <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)>
       <IFSYS ("VAX"
	       <COND (<REMOTE? .LIBC>
		      <BIND ((MSG:UVECTOR <STACK <UVECTOR ,UPDATE-UNLOCK>>))
			 <CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
			 <PRINTSTRING ,SERVER-NAME>
			 <COND (<AND <GET-REMOTE-RESPONSE .LIBC .MSG>
				     <==? <1 .MSG> ,ACK>>
				<PRINTSTRING " unlocked. ">
				<CRLF>
				<CLOSE .LIBC>
				<SETG ACTLIB %<>>
				<RETURN T>)
			       (T
				<PRINTSTRING " update error.">
				<CRLF>
				<LUP-ABORT>
				<RETURN #FALSE ("UPDATE FAILED")>)>>)>)>
       <PRINTSTRING <CHANNEL-OP .LIBC:DSK NAME>>
       <COND (<LUPI-COMMIT>
	      <CLOSE .LIBC>
	      <SETG ACTLIB %<>>
	      <PRINTSTRING " unlocked.">
	      <CRLF>
	      <RETURN T>)
	     (T
	      <PRINTSTRING " update error.">
	      <CRLF>
	      <LUP-ABORT>
	      <RETURN #FALSE ("UPDATE FAILED")>)>>
    <LUP-ABORT>>>

;"LUP-INSTALL --
  Effect:   Install changes made since last lock or install without releasing
	    lock.
  Returns:  T if successful, FALSE otherwise."

<DEFINE LUP-INSTALL ("AUX" (LIBC:<OR CHANNEL FALSE> ,ACTLIB))
   <UNWIND
    <PROG ((OUTCHAN:CHANNEL .OUTCHAN) LOCK:<OR CHANNEL FALSE>)
       <COND (<NOT .LIBC> <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)>
       <IFSYS ("VAX"
	       <COND (<REMOTE? .LIBC>
		      <BIND ((MSG:UVECTOR <STACK <UVECTOR ,UPDATE-INSTALL>>))
			 <CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
			 <PRINTSTRING ,SERVER-NAME>
			 <COND (<AND <GET-REMOTE-RESPONSE .LIBC .MSG>
				     <==? <1 .MSG> ,ACK>>
				<PRINTSTRING " installed and locked.">
				<CRLF>
				<RETURN T>)
			       (T
				<PRINTSTRING " update error.">
				<CRLF>
				<LUP-ABORT>
				<RETURN #FALSE ("UPDATE FAILED")>)>>)>)>
       <PRINTSTRING <CHANNEL-OP .LIBC:DSK NAME>>
       <COND (<SET LOCK <LUPI-INSTALL>>
	      <COND (<CHANNEL-OPEN? .LIBC> <CLOSE .LIBC>)>
	      <SETG ACTLIB .LOCK>
	      <PRINTSTRING " installed and locked.">
	      <CRLF>
	      <RETURN T>)
	     (T
	      <PRINTSTRING " update error.">
	      <CRLF>
	      <LUP-ABORT>
	      <RETURN #FALSE ("UPDATE FAILED")>)>>
    <LUP-ABORT>>>

;"LUP-ADD-PACK --
  Effect:   Add module named PKG to library. The files for PKG are found in
	    L-SEARCH-PATH. An optional documentation file may be specified:
	    %<> means none. STRING means documentation is string rather than
	    file. [] = [NM1 NM2] specifies file in search path. [NAME] means
	    full file name. And finally [NM1 NM2 DEV SNM]. ABSTRACT? means
	    generate and ABSTR file if non-false. COPY?, if FALSE, causes
	    the library to point at the files where they are found rather than
	    copying them to library directory (meaningful only for local
	    libraries).
   Returns: T if successful, otherwise FALSE."

<DEFINE LUP-ADD-PACK (PKG:STRING
		      "OPT" (DOC:<OR STRING <VECTOR [REST STRING]> FALSE> %<>)
			    (ABSTRACT?:<OR ATOM FALSE> T)
			    (COPY?:<OR ATOM FALSE> T)
		      "AUX" (LIBC:<OR CHANNEL FALSE> ,ACTLIB))
   <UNWIND
    <PROG (PKGI:<OR FALSE PKGINFO> ABSTR:<OR VECTOR FALSE>
	   (OUTCHAN:CHANNEL .OUTCHAN)
	   (RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>))
       <COND (<NOT .LIBC>
	      <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)
	     (<NOT <SET PKGI <DESCRIBE-PACKAGE .PKG .ABSTRACT?>>>
	      <RETURN .PKGI>)
	     (<LIBRARY-RECORD-EXISTS? <PKG-NAME .PKGI> .LIBC>
	      <COND (<ERROR LIBRARY-CONTAINS-MODULE!-ERRORS <PKG-NAME .PKGI>
			    ERRET-T-TO-UPDATE-FALSE-TO-EXIT!-ERRORS
			    LUP-ADD-PACK>
		     <COND (<NOT <LUP-DEL-PACK <PKG-NAME .PKGI>>>
			    <LUP-ABORT>
			    <RETURN #FALSE ("UPDATE FAILED")>)>)
		    (T
		     <RETURN %<>>)>)>
       <COND				    ;"Figure out where documentation is."
	(<TYPE? .DOC VECTOR>
	 <COND (<EMPTY? .DOC> <SET DOC [<PKG-NAME .PKGI> "DOC"]>)>
	 <COND (<==? <LENGTH .DOC> 2>
		<SET DOC <OR <SEARCH <1 .DOC> VECTOR ,L-SEARCH-PATH <REST .DOC>>
			     <CHTYPE (!.DOC) FALSE>>>)
	       (<OR <==? <LENGTH .DOC> 1> <==? <LENGTH .DOC> 4>>
		<PROG (NM1:<SPECIAL STRING> NM2:<SPECIAL STRING>
		       DEV:<SPECIAL STRING> SNM:<SPECIAL STRING>
		       NAME:STRING FN:<CHANNEL 'PARSE>)
		   <COND (<==? <LENGTH .DOC> 4>
			  <SET DEV <3 .DOC>>
			  <SET SNM <4 .DOC>>
			  <SET NM1 <1 .DOC>>
			  <SET NM2 <2 .DOC>>
			  <SET FN <CHANNEL-OPEN PARSE .NM1>>
			  <SET NAME <CHANNEL-OP .FN NAME>>
			  <CLOSE .FN>)
			 (T
			  <SET FN <CHANNEL-OPEN PARSE <1 .DOC>>>
			  <SET NM1 <CHANNEL-OP .FN NM1>>
			  <SET NM2 <CHANNEL-OP .FN NM2>>
			  <SET DEV <CHANNEL-OP .FN DEV>>
			  <SET SNM <CHANNEL-OP .FN SNM>>
			  <SET NAME <CHANNEL-OP .FN NAME>>
			  <CLOSE .FN>)>
		   <COND (<FILE-EXISTS? .NAME>
			  <SET DOC [.NAME .NM1 .NM2 .DEV .SNM]>)
			 (T
			  <SET DOC <CHTYPE (!.DOC) FALSE>>)>>)
	       (T
		<SET DOC <CHTYPE (!.DOC) FALSE>>)>

	 <COND (<NOT .DOC>
		<COND (<ERROR FILE-NOT-FOUND!-ERRORS .DOC
			      ERRET-T-TO-EXIT-FALSE-TO-IGNORE!-ERRORS
			      LUP-ADD-PACK>
		       <RETURN %<>>)>)>)
	(<AND <TYPE? .DOC STRING> <G? <LENGTH .DOC> ,MAXSTRS>>
	 <COND (<ERROR DOCUMENTATION-EXCEEDS-MAXIMUM-LENGTH!-ERRORS
		       ,MAXSTRS <LENGTH .DOC>
		       ERRET-T-TO-EXIT-FALSE-TO-IGNORE!-ERRORS
		       LUP-ADD-PACK>
		<RETURN %<>>)
	       (T
		<SET DOC %<>>)>)>
       <IFSYS ("VAX" <COND (<REMOTE? .LIBC> <SET COPY? T>)>)>
       <COND (<PKG-ABSTRACT .PKGI>	    ;"Write abstract to file."
	      <BIND ((OBLIST:<SPECIAL LIST> <2 <PKG-ABSTRACT .PKGI>>)
		     (ABSTRACT:LIST <1 <PKG-ABSTRACT .PKGI>>)
		     (NM1:<SPECIAL STRING> <PKG-NAME .PKGI>)
		     (NM2:<SPECIAL STRING> "ABSTR")
		     (FN:<CHANNEL 'PARSE> <CHANNEL-OPEN PARSE .NM1>)
		     (NAME:STRING <CHANNEL-OP .FN NAME>)
		     (CH:CHANNEL <CHANNEL-OPEN DISK .NAME "CREATE" "ASCII">))
		 <CLOSE .FN>
		 <MAPF %<> <FUNCTION (F:FORM) <PRIN1 .F .CH>> .ABSTRACT>
		 <SET ABSTR [.NAME .NM1 .NM2
			     <CHANNEL-OP .CH DEV> <CHANNEL-OP .CH SNM>]>
		 <CLOSE .CH>>)
	     (T
	      <SET ABSTR %<>>)>
       <PRINTSTRING <PKG-NAME .PKGI>>
       <PRINTSTRING ": module addition request.">
       <CRLF>
       <BUILD-RECORD <PKG-NAME .PKGI> <==? <PKG-TYPE .PKGI> PACKAGE> .COPY?
		     <PKG-CODE .PKGI> <PKG-SOURCE .PKGI> .ABSTR .DOC
		     <PKG-ENTRYS .PKGI> <PKG-RENTRYS .PKGI> <PKG-USES .PKGI>
		     <PKG-EXPORTS .PKGI> <PKG-INCLUDES .PKGI> .RECORD>
       <IFSYS ("VAX"
	       <COND (<REMOTE? .LIBC>
		      <COND
		       (<REMOTE-UPDATE .RECORD .LIBC
				       <PKG-CODE .PKGI> <PKG-SOURCE .PKGI>
				       .ABSTR <AND <TYPE? .DOC VECTOR> .DOC>>
			<RETURN T>)
		       (T
			<LUP-ABORT>
			<RETURN #FALSE ("UPDATE FAILED")>)>)>)>
       <COND (<LOCAL-UPDATE .RECORD .COPY? .LIBC
			    <PKG-CODE .PKGI> <PKG-SOURCE .PKGI> .ABSTR
			    <AND <TYPE? .DOC VECTOR> .DOC>>
	      <RETURN T>)
	     (T
	      <LUP-ABORT>
	      <RETURN #FALSE ("UPDATE FAILED")>)>>
    <LUP-ABORT>>>

;"LUP-DEL-PACK --
  Effect:   Remove module named PKG from active library.
  Returns:  T if successful, otherwise FALSE."

<DEFINE LUP-DEL-PACK (PKG:STRING "AUX" (LIBC:<OR FALSE CHANNEL> ,ACTLIB))
   <UNWIND
    <PROG ((OUTCHAN:CHANNEL .OUTCHAN))
       <COND (<NOT .LIBC>
	      <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)
	     (<NOT <LIBRARY-RECORD-EXISTS? .PKG .LIBC>>
	      <RETURN #FALSE ("NO SUCH MODULE")>)>
       <PRINTSTRING .PKG>
       <PRINTSTRING ": module deletion request.">
       <CRLF>
       <IFSYS
	("VAX"
	 <COND (<REMOTE? .LIBC>
		<BIND ((MSG:UVECTOR
			<STACK <UVECTOR <ORB ,UPDATE-DEL
					     <LSH <LENGTH .PKG> 8>>>>))
		   <CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
		   <CHANNEL-OP .LIBC:NET WRITE-BUFFER .PKG>
		   <COND (<AND <GET-REMOTE-RESPONSE .LIBC .MSG>
			       <==? <1 .MSG> ,ACK>>
			  <RETURN T>)
			 (T
			  <LUP-ABORT>
			  <RETURN #FALSE ("UPDATE FAILED")>)>>)>)>
       <COND (<LUPI-DEL-PACK .PKG>
	      <RETURN T>)
	     (T
	      <LUP-ABORT>
	      <RETURN #FALSE ("UPDATE FAILED")>)>>
    <LUP-ABORT>>>

;"LUP-GC --
  Effect:   Garbage collect the active library. NBKTS is the number of
            buckets to use.
  Returns:  T if successful, otherwise FALSE."

<DEFINE LUP-GC ("OPT" (NBKTS:FIX ,INITIAL-BUCKETS)
                "AUX" (LIBC:<OR CHANNEL FALSE> ,ACTLIB))
   <UNWIND
    <PROG ((OUTCHAN:CHANNEL .OUTCHAN))
       <COND (<NOT .LIBC> <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)>
       <PRINTSTRING "Library GC...">
       <IFSYS
	("VAX"
	 <COND (<REMOTE? .LIBC>
		<BIND ((MSG:UVECTOR <STACK <UVECTOR ,UPDATE-GC>>))
		   <CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
		   <CHANNEL-OP .LIBC:NET TIMEOUT %<* 2 ,UPDATE-TIMEOUT>>
		   <COND (<AND <GET-REMOTE-RESPONSE .LIBC .MSG>
			       <==? <1 .MSG> ,ACK>>
			  <CHANNEL-OP .LIBC:NET TIMEOUT ,UPDATE-TIMEOUT>
			  <PRINTSTRING "Done.">
			  <CRLF>
			  <RETURN T>)
			 (T
			  <PRINTSTRING "Failed.">
			  <CRLF>
			  <LUP-ABORT>
			  <RETURN %<>>)>>)>)>
       <COND (<LUPI-GC .NBKTS>
	      <PRINTSTRING "Done.">
	      <CRLF>
	      <RETURN T>)
	     (T
	      <PRINTSTRING "Failed.">
	      <CRLF>
	      <LUP-ABORT>
	      <RETURN %<>>)>>
    <LUP-ABORT>>>

;"LUP-ADD-FILE --
  Effect:   Copies the file named NAME to the directory of the active library.
  Returns:  T if successful, FALSE otherwise."

<DEFINE LUP-ADD-FILE (NAME:STRING "AUX" (LIB:<OR CHANNEL FALSE> ,ACTLIB)
                                        (FIL:<OR CHANNEL FALSE> %<>)
                                        (CPY:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((OUTCHAN:CHANNEL .OUTCHAN))
       <COND (<NOT .LIB> <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)
	     (<NOT <SET FIL <SEARCH .NAME CHANNEL>>> <RETURN #FALSE ("NOT FOUND")>)>
       <SET NAME <STRING <CHANNEL-OP .FIL:DSK NM1> !\. <CHANNEL-OP .FIL:DSK NM2>>>
       <COND (<LIBRARY-FILE-EXISTS? .NAME .LIB>
	      <COND (<ERROR LIBRARY-FILE-EXISTS!-ERRORS .NAME
			    ERRET-T-TO-UPDATE-FALSE-TO-EXIT!-ERRORS LUP-ADD-FILE>
		     <COND (<NOT <LUP-DEL-FILE .NAME>>
			    <LUP-ABORT>
			    <CLOSE .FIL>
			    <RETURN #FALSE ("UPDATE FAILED")>)>)
		    (T
		     <CLOSE .FIL>
		     <RETURN %<>>)>)>
       <PRINTSTRING .NAME>
       <PRINTSTRING ": file addition request.">
       <CRLF>
       <PRINTSTRING "Copying ">
       <PRINTSTRING <CHANNEL-OP .FIL:DSK NAME>>
       <CRLF>
       <IFSYS
	("VAX"
	 <COND (<REMOTE? .LIB>
		<BIND ((R:UVECTOR <IUVECTOR 4>))
		   <1 .R <ORB ,UPDATE-ADD ,UPDATE-FILE <LSH <LENGTH .NAME> 8>>>
		   <CHANNEL-OP .LIB:NET WRITE-BUFFER .R 1>
		   <CHANNEL-OP .LIB:NET WRITE-BUFFER .NAME>
		   <CHANNEL-OP .LIB:NET LISTEN-ON-DATA>
		   <CHANNEL-OP .LIB:NET GET-DATA-ADDRESS <CHTYPE .R NET-ADDRESS>>
		   <CHANNEL-OP .LIB:NET WRITE-BUFFER .R>
		   <COND (<NOT <SET CPY <CHANNEL-OP .LIB:NET CONNECT-DATA-CHANNEL>>>
			  <ERROR CANT-OPEN-DATA-CONNECTION!-ERRORS
				 <SYS-ERR "" .CPY %<>> .CPY LUP-ADD-FILE>)
			 (<AND <NET-FILE-COPY .FIL .CPY .LIB>
			       <GET-REMOTE-RESPONSE .LIB .R>
			       <==? <1 .R> ,ACK>>
			  <CLOSE .FIL>
			  <CHANNEL-OP .LIB:NET CLOSE-DATA-CHANNEL>
			  <RETURN T>)>
		   <CHANNEL-OP .LIB:NET CLOSE-DATA-CHANNEL>
		   <LUP-ABORT>
		   <CLOSE .FIL>
		   <RETURN #FALSE ("UPDATE FAILED")>>)>)>
       <SET CPY <CHANNEL-OPEN DISK <LUPI-GENTEMP> "CREATE" "ASCII">>
       <DSK-FILE-COPY .FIL .CPY>
       <SET NAME <CHANNEL-OP .FIL:DSK NM1>>
       <PROG ((DEV:<SPECIAL STRING> <CHANNEL-OP .LIB:DSK DEV>)
	      (SNM:<SPECIAL STRING> <CHANNEL-OP .LIB:DSK SNM>)
	      (NM2:<SPECIAL STRING> <CHANNEL-OP .FIL:DSK NM2>)
	      (FN:<CHANNEL 'PARSE> <CHANNEL-OPEN PARSE .NAME>))
	  <LUPI-ADD-FILE <CHANNEL-OP .CPY:DSK NAME> <CHANNEL-OP .FN NAME>>
	  <CLOSE .FN>
	  <CLOSE .CPY>
	  <CLOSE .FIL>>
       <RETURN T>>
    <BIND ()
       <LUP-ABORT>
       <COND (<AND .CPY <CHANNEL-OPEN? .CPY>> <CLOSE .CPY>)>
       <COND (<AND .FIL <CHANNEL-OPEN? .FIL>> <CLOSE .FIL>)>>>>

;"LUP-DEL-FILE
  Effect:   Remove file named NAME from active library directory.
  Returns:  T if successful, FALSE otherwise."

<DEFINE LUP-DEL-FILE (NAME:STRING "AUX" (LIBC:<OR FALSE CHANNEL> ,ACTLIB))
   <PROG ((OUTCHAN:CHANNEL .OUTCHAN))
      <COND (<NOT .LIBC>
	     <RETURN #FALSE ("NO LIBRARY ACTIVATED")>)
	    (<NOT <LIBRARY-FILE-EXISTS? .NAME .LIBC>>
	     <RETURN #FALSE ("NO SUCH FILE")>)>
      <PRINTSTRING .NAME>
      <PRINTSTRING ": file deletion request.">
      <CRLF>
      <IFSYS ("VAX"
	      <COND (<REMOTE? .LIBC>
		     <BIND ((R:UVECTOR
			     <STACK <UVECTOR <ORB ,UPDATE-DEL ,UPDATE-FILE
						  <LSH <LENGTH .NAME> 8>>>>))
			<CHANNEL-OP .LIBC:NET WRITE-BUFFER .R>
			<CHANNEL-OP .LIBC:NET WRITE-BUFFER .NAME>
			<COND (<AND <GET-REMOTE-RESPONSE .LIBC .R>
				    <==? <1 .R> ,ACK>>
			       <RETURN T>)
			      (T
			       <LUP-ABORT>
			       <RETURN #FALSE ("UPDATE FAILED")>)>>)>)>
      <RETURN <LUPI-DEL-FILE .NAME>>>>

;"LIBRARY-RECORD-EXISTS? --
  Effect:   Determine if active library contains module named PKG.
  Returns:  T if it exists, otherwise FALSE."

<DEFINE LIBRARY-RECORD-EXISTS? (PKG:STRING LIBC:CHANNEL)
   <PROG ()
      <IFSYS ("VAX"
	      <COND (<REMOTE? .LIBC>
		     <BIND ((MSG:UVECTOR
			     <STACK <UVECTOR <ORB ,UPDATE-EXISTS?
						  <LSH <LENGTH .PKG> 8>>>>))
			<CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
			<CHANNEL-OP .LIBC:NET WRITE-BUFFER .PKG>
			<RETURN <AND <GET-REMOTE-RESPONSE .LIBC .MSG>
				     <==? <1 .MSG> ,ACK>>>>)>)>
      <RETURN <LUPI-RECORD-EXISTS? .PKG>>>>

;"LIBRARY-FILE-EXISTS? --
  Effect:   Determine if active library directory contains file named NAME.
  Returns:  T if it exists, otherwise FALSE."

<DEFINE LIBRARY-FILE-EXISTS? (NAME:STRING LIBC:CHANNEL)
   <PROG ()
      <IFSYS ("VAX"
	      <COND (<REMOTE? .LIBC>
		     <BIND ((MSG:UVECTOR
			     <STACK <UVECTOR <ORB ,UPDATE-EXISTS? ,UPDATE-FILE
						  <LSH <LENGTH .NAME> 8>>>>))
			<CHANNEL-OP .LIBC:NET WRITE-BUFFER .MSG>
			<CHANNEL-OP .LIBC:NET WRITE-BUFFER .NAME>
			<RETURN <AND <GET-REMOTE-RESPONSE .LIBC .MSG>
				     <==? <1 .MSG> ,ACK>>>>)>)>
      <RETURN <LUPI-FILE-EXISTS? .NAME>>>>

;"DSK-FILE-COPY --
  Effect:   Copy FROM to TO.
  Modifies: FROM, TO."

<DEFINE DSK-FILE-COPY (FROM:<CHANNEL 'DISK> TO:<CHANNEL 'DISK>)
   <REPEAT ((BUFFER:STRING <STACK <ISTRING 1024>>) AMOUNT:FIX)
      <SET AMOUNT <OR <CHANNEL-OP .FROM READ-BUFFER .BUFFER> 0>>
      <CHANNEL-OP .TO WRITE-BUFFER .BUFFER .AMOUNT>
      <COND (<==? .AMOUNT 0> <RETURN>)>>>

;"LOCAL-UPDATE --
  Effect:   Add a module to a local library. The module is represented
	    by RECORD. COPY? specifies whether or not files are to be
	    copied. FILES is (in order, some missing possibly) the file
	    spec vectors for MSUBR, MUD, ABSTR, DOC. A file spec vector
	    is [NAME NM1 NM2 DEV SNM].
  Returns:  T if successful, FALSE otherwise.
  Requires: RECORD is properly formatted library record as defined in
	    LIBRARY.FORMAT."

<DEFINE LOCAL-UPDATE (RECORD:UVECTOR COPY?:<OR ATOM FALSE>
		      LIBC:<CHANNEL 'DISK> "TUPLE" FILES:<PRIMTYPE VECTOR>)
   <PROG ((ADD:LIST ()) (TMP:LIST ()) (OUTCHAN:CHANNEL .OUTCHAN)
	  (DEV:<SPECIAL STRING> <CHANNEL-OP .LIBC DEV>)
	  (SNM:<SPECIAL STRING> <CHANNEL-OP .LIBC SNM>)
	  NM2:<SPECIAL STRING> FROM:<CHANNEL 'DISK> TO:<CHANNEL 'DISK>
	  NAME:STRING FN:<CHANNEL 'PARSE>)
      <MAPF %<>				    ;"Copy files."
	    <FUNCTION (FV:<OR <VECTOR [5 STRING]> FALSE>)
	       <COND (.FV
		      <COND (<OR .COPY?
				 <AND <=? .DEV <4 .FV>> <=? .SNM <5 .FV>>>>
			     ;"We have to copy files in library directory
			       regardless of COPY? since user may have moved
			       files there without updating library. Thus, if
			       he deleted a record, we would delete new files."
			     <COND (.COPY?
				    <PRINTSTRING "Copying ">
				    <PRINTSTRING <1 .FV>>
				    <CRLF>)>
			     <SET FROM <CHANNEL-OPEN DISK <1 .FV> "READ">>
			     <SET NAME <LUPI-GENTEMP>>
			     <SET TO <CHANNEL-OPEN DISK .NAME "CREATE">>
			     <DSK-FILE-COPY .FROM .TO>
			     <CLOSE .FROM>
			     <CLOSE .TO>
			     <SET NM2 <3 .FV>>
			     <SET FN <CHANNEL-OPEN PARSE <2 .FV>>>
			     <SET ADD (<CHANNEL-OP .FN NAME> !.ADD)>
			     <CLOSE .FN>
			     <SET TMP (.NAME !.TMP)>)>)>>
	    .FILES>
      <LUPI-ADD-PACK .RECORD .ADD .TMP>>>

;"BUILD-RECORD --
  Effect:   Create a library record.
  Returns:  The actual length of the record.
  Modifies: Record.
  Note:     CFN, SFN, AFN, DOC are file specs (except DOC can be string).
	    USES, EXPORTS, INCLUDES are lists of modules referenced by
	    the module. ENTRYS, RENTRYS are the obvious."

<DEFINE BUILD-RECORD (NAME:STRING PACKAGE?:<OR ATOM FALSE>
		      COPY?:<OR ATOM FALSE> CFN:<OR VECTOR STRING FALSE>
		      SFN:<OR VECTOR STRING FALSE> AFN:<OR VECTOR STRING FALSE>
		      DOC:<OR VECTOR STRING FALSE> ENTRYS:VECTOR RENTRYS:VECTOR
		      USES:VECTOR EXPORTS:VECTOR INCLUDES:VECTOR RECORD:UVECTOR
		      "AUX"
		      (RECLEN:FIX <LENGTH .RECORD>) (SFNLEN:FIX 0)
		      (PDNLEN:FIX <LENGTHW .NAME>) (CFNLEN:FIX 0)
		      (AFNLEN:FIX 0) (DOCLEN:FIX 0) DELTAE:FIX DELTAU:FIX)
   <1 .RECORD				    ;"File bits for record info word."
      <ORB <COND (.CFN ,RINFO-CFN?) (T 0)>
	   <COND (.AFN ,RINFO-AFN?) (T 0)>
	   <COND (.SFN ,RINFO-SFN?) (T 0)>
	   <COND (.PACKAGE? ,RINFO-PKG?) (T 0)>
	   <COND (<TYPE? .DOC STRING> ,RINFO-DOC?) (.DOC ,RINFO-DFN?) (T 0)>
	   .PDNLEN>>			    ;"And length of name in words."
   <S2UV .NAME <SET RECORD <REST .RECORD>>> ;"Module name."
   <SET RECORD <REST .RECORD <+ .PDNLEN 3>>>
   <COND				    ;"Encode file names."
    (.COPY?				    ;"COPY? -> NM1.NM2."
     <COND (<TYPE? .CFN VECTOR>             ;"Implies default SNM, DEV."
	    <SET CFNLEN <LENGTHW <SET CFN <STRING <2 .CFN> !\. <3 .CFN>>>>>
	    <S2UV .CFN .RECORD>
	    <SET RECORD <REST .RECORD .CFNLEN>>)>
     <COND (<TYPE? .SFN VECTOR>
	    <SET SFNLEN <LENGTHW <SET SFN <STRING <2 .SFN> !\. <3 .SFN>>>>>
	    <S2UV .SFN .RECORD>
	    <SET RECORD <REST .RECORD .SFNLEN>>)>
     <COND (<TYPE? .AFN VECTOR>
	    <SET AFNLEN <LENGTHW <SET AFN <STRING <2 .AFN> !\. <3 .AFN>>>>>
	    <S2UV .AFN .RECORD>
	    <SET RECORD <REST .RECORD .AFNLEN>>)>
     <COND (.DOC
	    <COND (<TYPE? .DOC VECTOR>
		   <SET DOC <STRING <2 .DOC> !\. <3 .DOC>>>)>
	    <SET DOCLEN <LENGTHW .DOC>>
	    <S2UV .DOC .RECORD>
	    <SET RECORD <REST .RECORD .DOCLEN>>)>)
    (T					    ;"Otherwise full name."
     <COND (<TYPE? .CFN VECTOR>
	    <SET CFNLEN <LENGTHW <SET CFN <1 .CFN>>:STRING>>
	    <S2UV .CFN .RECORD>
	    <SET RECORD <REST .RECORD .CFNLEN>>)>
     <COND (<TYPE? .SFN VECTOR>
	    <SET SFNLEN <LENGTHW <SET SFN <1 .SFN>>:STRING>>
	    <S2UV .SFN .RECORD>
	    <SET RECORD <REST .RECORD .SFNLEN>>)>
     <COND (<TYPE? .AFN VECTOR>
	    <SET AFNLEN <LENGTHW <SET AFN <1 .AFN>>:STRING>>
	    <S2UV .AFN .RECORD>
	    <SET RECORD <REST .RECORD .AFNLEN>>)>
     <COND (.DOC
	    <COND (<TYPE? .DOC VECTOR> <SET DOC <1 .DOC>>)>
	    <SET DOCLEN <LENGTHW .DOC:STRING>>
	    <S2UV .DOC .RECORD>
	    <SET RECORD <REST .RECORD .DOCLEN>>)>)>

   <SET DELTAE <- .RECLEN <LENGTH .RECORD>>>	;"Start of r/entry list."
   <REPEAT (ERNAME:ATOM ERLEN:FIX (TYPES:VECTOR ,L-ERTYPES))
      ;"The ENTRY and RENTRY vectors are sorted. Now we merge sort them
	into the record."
      <COND (<AND <EMPTY? .ENTRYS> <EMPTY? .RENTRYS>>
	     <SET ENTRYS <TOP .ENTRYS>>
	     <SET RENTRYS <TOP .RENTRYS>>
	     <RETURN>)
	    (<EMPTY? .RENTRYS>
	     <SET ERNAME <1 .ENTRYS>>
	     <SET ENTRYS <REST .ENTRYS>>)
	    (<OR <EMPTY? .ENTRYS>
		 <G? <STRCOMP <SPNAME <1 .ENTRYS>> <SPNAME <1 .RENTRYS>>> 0>>
	     <SET ERNAME <1 .RENTRYS>>
	     <SET RENTRYS <REST .RENTRYS>>)
	    (T
	     <SET ERNAME <1 .ENTRYS>>
	     <SET ENTRYS <REST .ENTRYS>>)>
      ;"Construct r/entry descriptor. Name length, type info, name."
      <1 .RECORD
	 <ORB <SET ERLEN <LENGTHW <SPNAME .ERNAME>>>
	      <COND (<GASSIGNED? .ERNAME>
		     <ORB <LSH <- 8 <LENGTH <MEMQ <TYPE ,.ERNAME> .TYPES>>> 8>
			  <COND (<APPLICABLE? ,.ERNAME> ,ERTYP-APPLICABLE)
				(T 0)>>)
		    (T 0)>
	      <COND (<N==? <OBLIST? .ERNAME> %<ROOT>> ,ERTYP-ENTRY?) (T 0)>
	      <COND (<MANIFEST? .ERNAME> ,ERTYP-MANIFEST?) (T 0)>
	      <COND (<TYPE-NAME? .ERNAME> ,ERTYP-TYPE?) (T 0)>
	      <LSH <- .RECLEN <LENGTH .RECORD>> 16>>>
      <S2UV <SPNAME .ERNAME> <SET RECORD <REST .RECORD>>>
      <SET RECORD <REST .RECORD .ERLEN>>>
   <SET DELTAU <- .RECLEN <LENGTH .RECORD>>>	;"Start of U/X/I list."
   <REPEAT (UXINAME:<OR STRING FALSE> UXITYPE:FIX UXILEN:FIX)
      ;"Again, the vectors are sorted and we merge sort them into record."
      <COND (<EMPTY? .USES>
	     <SET UXINAME %<>>)
	    (T
	     <SET UXINAME <1 .USES>>
	     <SET UXITYPE ,UXI-USED?>)>
      <COND (<AND <NOT <EMPTY? .INCLUDES>>
		  <OR <NOT .UXINAME> <G? <STRCOMP .UXINAME <1 .INCLUDES>> 0>>>
	     <SET UXINAME <1 .INCLUDES>>
	     <SET UXITYPE ,UXI-INCLUDED?>)>
      <COND (<AND <NOT <EMPTY? .EXPORTS>>
		  <OR <NOT .UXINAME> <G? <STRCOMP .UXINAME <1 .EXPORTS>> 0>>>
	     <SET UXINAME <1 .EXPORTS>>
	     <SET UXITYPE ,UXI-EXPORTED?>)>
      <COND (<NOT .UXINAME>
	     <SET USES <TOP .USES>>
	     <SET EXPORTS <TOP .EXPORTS>>
	     <SET INCLUDES <TOP .INCLUDES>>
	     <RETURN>)
	    (<==? .UXITYPE ,UXI-USED?>
	     <SET USES <REST .USES>>)
	    (<==? .UXITYPE ,UXI-INCLUDED?>
	     <SET INCLUDES <REST .INCLUDES>>)
	    (T
	     <SET EXPORTS <REST .EXPORTS>>)>
      ;"Construct descriptor. Bit indicating reference type, name length, name."
      <1 .RECORD <ORB .UXITYPE <SET UXILEN <LENGTHW .UXINAME>>>>
      <S2UV .UXINAME <SET RECORD <REST .RECORD>>>
      <SET RECORD <REST .RECORD .UXILEN>>>

   ;"Compute length of record and shove into record info word. Fix up
     r/entry count - displacement word. Fixup U/X/I count - displacement
     word."
   <SET RECLEN <- .RECLEN <LENGTH .RECORD>>>
   <1 <SET RECORD <TOP .RECORD>>
      <ORB <1 .RECORD> <LSH .RECLEN 16>>>
   <1 <SET RECORD <REST .RECORD <+ 1 .PDNLEN>>>
      <ORB <LSH .DOCLEN 24> <LSH .AFNLEN 16> <LSH .SFNLEN 8> .CFNLEN>>
   <1 <SET RECORD <REST .RECORD>>
      <ORB <LSH .DELTAE 16> <+ <LENGTH .ENTRYS> <LENGTH .RENTRYS>>>>
   <1 <REST .RECORD>
      <ORB <LSH .DELTAU 16>
	   <+ <LENGTH .USES> <LENGTH .INCLUDES> <LENGTH .EXPORTS>>>>
   .RECLEN>
