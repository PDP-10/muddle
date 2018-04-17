;"*****************************************************************************
  This file defines library update primitives for use with a resident library
  file. Both the server and LUP use these procedures (spliced in at compile
  time). See LIBRARY.FORMAT for definition of binary formats of record and
  library.

  LUP-BASE.MUD: EDIT HISTORY				    Machine Independent

  COMPILATION: Spliced in at compile time.

    JUN84 [Shane] - Created.
  18OCT84 [Shane] - Commented, cleaned up.
  28OCT84 [Shane] - Add LUPI-INSTALL.
   9OCT84 [Shane] - Add LUPI-ADD-FILE, LUPI-FILE-EXISTS?, LUPI-DEL-FILE
  ****************************************************************************"

<COND (<NOT <VALID-TYPE? LIBLOCK>> <NEWTYPE LIBLOCK VECTOR>)>	;"See L-DEFS."

;"LUPI-KEY -- Is the LIBLOCK when an update is in progress."

<OR <GASSIGNED? LUPI-KEY> <SETG LUPI-KEY %<> '<OR FALSE LIBLOCK>>>

;"LUPI-ABORT --
  Effect:   Aborts an update in progress. Deletes all temporary files
	    generated, writes message to log file, and unlocks library.
  Modifies: K."

<DEFINE LUPI-ABORT ("AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY)
			  NAME:STRING CH:<CHANNEL 'DISK>)
   <COND (.K
	  <MAPF %<> ,DELFILE <LL-TMP-FILES .K>>
	  <COND (<CHANNEL-OPEN? <SET CH <LL-LOG .K>>>
		 <PRINTSTRING "*** Update aborted." .CH>
		 <CRLF .CH>
		 <CLOSE .CH>)>
	  <COND (<CHANNEL-OPEN? <SET CH <LL-NEW .K>>>
		 <SET NAME <CHANNEL-OP .CH:DSK NAME>>
		 <CLOSE .CH>)
		(T
		 <SET NAME <CHANNEL-NAME .CH>>)>
	  <DELFILE .NAME>
	  <IFSYS ("VAX"			    ;"Undo the soft lock under UNIX."
		  <COND (<CHANNEL-OPEN? <SET CH <LL-OLD .K>>>
			 <CALL SYSCALL FLOCK <CHANNEL-OP .CH:DSK FILE-HANDLE>
			       ,UNLOCK-FILE>)>)>
	  <SETG LUPI-KEY %<>>
	  T)>>

;"LUPI-GENTEMP --
  Effect:   Generate a unique file name for the library directory:
	    LIBTMPnnn.TEMP if the library is locked.
  Returns:  Filename.
  Modifies: K."

<DEFINE LUPI-GENTEMP ("AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND (.K
	  <PROG ((DEV:<SPECIAL STRING> <CHANNEL-OP <LL-OLD .K>:DSK DEV>)
		 (SNM:<SPECIAL STRING> <CHANNEL-OP <LL-OLD .K>:DSK SNM>)
		 (NM2:<SPECIAL STRING> "TEMP") (SUFFIX:FIX <LL-SUFFIX .K>)
		 (NAME:STRING <STACK <ISTRING 32>>)
		 FN:<CHANNEL 'PARSE>)
	     ;"Increment the suffix. I2S returns NAME rested to digits."
	     <LL-SUFFIX .K <+ .SUFFIX 1>>
	     <SUBSTRUC "LIBTMP" 0 6 <SET NAME <BACK <I2S .SUFFIX .NAME> 6>>>
	     <SET FN <CHANNEL-OPEN PARSE .NAME>>
	     <SET NAME <CHANNEL-OP .FN NAME>>
	     <CLOSE .FN>
	     <RETURN .NAME>>)>>

;"LUPI-LOCK --
  Effect:   Locks library corresponding to LIB. Creates the LIBLOCK and
	    writes message to LOG. The contents of the library is copied
	    and all update actions affect the copy.
  Returns:  The locked active library.
  Modifies: LOG.
  Note:     The default for the log file is NM1.LOG where NM1 is first name
	    of library file in library directory."

<DEFINE LUPI-LOCK (LIB:<CHANNEL 'DISK>
		   "OPT" (LOG:<OR <CHANNEL 'DISK> FALSE> %<>)
		   "AUX" (NEW:<OR <CHANNEL 'DISK> FALSE> %<>))
   <PROG ((DEV:<SPECIAL STRING> <CHANNEL-OP .LIB DEV>)
	  (SNM:<SPECIAL STRING> <CHANNEL-OP .LIB SNM>)
	  (NM1:<SPECIAL STRING> <CHANNEL-OP .LIB NM1>)
	  (NM2:<SPECIAL STRING> <CHANNEL-OP .LIB NM2>)
	  (NAME:STRING <CHANNEL-OP .LIB NAME>)
	  FN:<CHANNEL 'PARSE>)
      ;"Check to see if user already has library locked."
      <COND (<AND <GASSIGNED? LUPI-KEY> ,LUPI-KEY>
	     <RETURN #FALSE ("LOCKED")>)>
      <IFSYS ("VAX"
	      ;"Soft lock under UNIX."
	      <COND (<NOT <CALL SYSCALL FLOCK <CHANNEL-OP .LIB FILE-HANDLE>
				,LOCK-FILE>>
		     <RETURN #FALSE ("LOCKED")>)>)
	     ("TOPS20"
	      ;"Thawed under TOPS20."
	      <COND (<SET NEW <CHANNEL-OPEN DISK .NAME "MODIFY" "BINARY">>
		     <CLOSE .LIB>
		     <SET LIB .NEW>)
		    (T
		     <RETURN #FALSE ("LOCKED")>)>)>
      ;"Open the log file if we were not given one. Recreate if needed."
      <COND (<NOT .LOG>
	     <SET NM2 "LOG">
	     <SET FN <CHANNEL-OPEN PARSE .NM1>>
	     <SET NAME <CHANNEL-OP .FN NAME>>
	     <CLOSE .FN>
	     <COND (<SET LOG <CHANNEL-OPEN DISK .NAME "MODIFY" "ASCII">>
		    <CHANNEL-OP .LOG ACCESS <FILE-LENGTH .LOG>>)
		   (<SET LOG <CHANNEL-OPEN DISK .NAME "CREATE" "ASCII">>
		    <CLOSE .LOG>
		    <SET LOG <CHANNEL-OPEN DISK .NAME "MODIFY" "ASCII">>
		    <PRINTSTRING "*** " .LOG>
		    <PRINTSTRING <DTIME> .LOG>
		    <PRINTSTRING " Log file recreated." .LOG>
		    <CRLF .LOG>)>)>
      ;"Copy the library to temporary file."
      <SET NM2 "TEMP">
      <SET FN <CHANNEL-OPEN PARSE "LIBTMP0">>
      <SET NAME <CHANNEL-OP .FN NAME>>
      <CLOSE .FN>
      <COND (<SET NEW <CHANNEL-OPEN DISK .NAME "CREATE" "BINARY">>
	     <CHANNEL-OP .LIB:DSK ACCESS 0>
	     <REPEAT ((B:<UVECTOR [REST FIX]> <STACK <IUVECTOR 512>>) N:FIX)
		<SET N <OR <CHANNEL-OP .LIB:DSK READ-BUFFER .B> 0>>
		<CHANNEL-OP .NEW:DSK WRITE-BUFFER .B .N>
		<COND (<L? .N <LENGTH .B>> <RETURN>)>>
	     ;"Make the key and say library is locked."
	     <SETG LUPI-KEY <CHTYPE [.LIB .NEW .LOG () () () 1] LIBLOCK>>
	     <PRINTSTRING "*** " .LOG>
	     <PRINTSTRING <DTIME> .LOG>
	     <PRINTSTRING " Library locked." .LOG>
	     <CRLF .LOG>
	     .LIB)>>>

;"LUPI-COMMIT --
  Effect:   Deletes files that have been deleted from library. Renames
	    temporary files to destinations for files that have been
	    added to library. Renames temporary library to library and
	    releases lock. All accompanied by messages to log file.
  Modifies: K, LOG."

<DEFINE LUPI-COMMIT ("AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY) LOG:<CHANNEL 'DISK>)
   <COND (.K
	  <SET LOG <LL-LOG .K>>
	  ;"Delete files."
	  <MAPF %<>
		<FUNCTION (NAME:STRING)
		   <PRINTSTRING "    Deleting file " .LOG>
                   <PRINTSTRING .NAME .LOG>
		   <CRLF .LOG>
		   <DELFILE .NAME>>
		<LL-DEL-FILES .K>>
	  ;"Rename temporary files."
	  <MAPF %<>
		<FUNCTION (FROM:STRING TO:STRING)
		   <PRINTSTRING "    Adding file " .LOG>
		   <PRINTSTRING .TO .LOG>
		   <CRLF .LOG>
		   <RENAME .FROM .TO>>
		<LL-TMP-FILES .K>
		<LL-ADD-FILES .K>>
	  ;"Rename temporary library, flushing old library."
	  <BIND ((OLD:STRING <CHANNEL-OP <LL-OLD .K>:DSK NAME>)
		 (NEW:STRING <CHANNEL-OP <LL-NEW .K>:DSK NAME>))
	     <CLOSE <LL-NEW .K>>
	     <CLOSE <LL-OLD .K>>
	     <IFSYS ("TOPS20" <DELFILE .OLD>)>
	     <RENAME .NEW .OLD>
	     <PRINTSTRING "*** Update completed." .LOG>
	     <CRLF .LOG>
	     <CLOSE .LOG>
	     <SETG LUPI-KEY %<>>
	     T>)>>

;"LUPI-INSTALL --
  Effect:   Deletes files that have been deleted from library. Renames
	    temporary files to destinations for files that have been
	    added to library. Renames temporary library to library but
	    retains lock. All accompanied by messages to log file.
  Modifies: K, LOG."

<DEFINE LUPI-INSTALL ("AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY) LOG:<CHANNEL 'DISK>)
   <COND (.K
	  <SET LOG <LL-LOG .K>>
	  ;"Delete files."
	  <MAPF %<>
		<FUNCTION (NAME:STRING)
		   <PRINTSTRING "    Deleting file " .LOG>
		   <PRINTSTRING .NAME .LOG>
		   <CRLF .LOG>
		   <DELFILE .NAME>>
		<LL-DEL-FILES .K>>
	  ;"Rename temporary files."
	  <MAPF %<>
		<FUNCTION (FROM:STRING TO:STRING)
		   <PRINTSTRING "    Adding file " .LOG>
		   <PRINTSTRING .TO .LOG>
		   <CRLF .LOG>
		   <RENAME .FROM .TO>>
		<LL-TMP-FILES .K>
		<LL-ADD-FILES .K>>
	  ;"Rename temporary library, flushing old library, locking new."
	  <BIND ((OLD:STRING <CHANNEL-OP <LL-OLD .K>:DSK NAME>)
		 (NEW:STRING <CHANNEL-OP <LL-NEW .K>:DSK NAME>)
		 CH:<OR <CHANNEL 'DISK> FALSE>)
	     <CLOSE <LL-NEW .K>>
	     <CLOSE <LL-OLD .K>>
	     <IFSYS ("TOPS20" <DELFILE .OLD>)>
	     <RENAME .NEW .OLD>
	     <PRINTSTRING "*** Installed." .LOG>
	     <CRLF .LOG>
	     <SETG LUPI-KEY %<>>
	     ;"Small window here where someone else could grab library."
	     <COND (<AND <SET CH <CHANNEL-OPEN DISK .OLD "READ" "BINARY">>
			 <LUPI-LOCK .CH .LOG>>)
		   (T
		    <AND .CH <CLOSE .CH>>
		    <CLOSE .LOG>
		    %<>)>>)>>

;"LUPI-CREATE --
  Effect:  Create a library named NAME with default second name LIBMIM.
	   Creates associated log file. 
  Returns: Full library name."

<DEFINE LUPI-CREATE ("OPT" (NAME:STRING "LIBMIM") (NBKTS:FIX ,INITIAL-BUCKETS)
		     "AUX" (LIB:<OR <CHANNEL 'DISK> FALSE> %<>)
			   (LOG:<OR <CHANNEL 'DISK> FALSE> %<>))
   <SET NBKTS <NEXT-PRIME .NBKTS>>
   <PROG ((DIR:<UVECTOR [REST FIX]> <STACK <IUVECTOR <+ .NBKTS ,DIR-HDRLEN> 0>>)
	  (NM2:<SPECIAL STRING> "LBIN")
	  (FN:<CHANNEL 'PARSE> <CHANNEL-OPEN PARSE .NAME>))
      <SET NAME <CHANNEL-OP .FN NAME>>
      <CLOSE .FN>
      ;"If it exists, ask user what to do."
      <COND (<SET LIB <CHANNEL-OPEN DISK .NAME "READ" "BINARY">>
	     <COND (<ERROR LIBRARY-FILE-EXISTS!-ERRORS
			   ERRET-T-TO-CLOBBER-EXISTING-LIBRARY!-ERRORS
			   <SET NAME <CHNNEL-OP .LIB NAME>>
			   LUPI-CREATE>
		    <CLOSE .LIB>
		    <DELFILE .NAME>)
		   (T
		    <RETURN %<>>)>)>
      ;"Create library directory and log file."
      <COND (<SET LIB <CHANNEL-OPEN DISK .NAME "CREATE" "BINARY">>
	     <PROG ((SNM:<SPECIAL STRING> <CHANNEL-OP .LIB SNM>)
		    (DEV:<SPECIAL STRING> <CHANNEL-OP .LIB DEV>))
		<SET NM2 "LOG">
		<SET FN <CHANNEL-OPEN PARSE <CHANNEL-OP .LIB NM1>>>
		<SET NAME <CHANNEL-OP .FN NAME>>
		<CLOSE .FN>
		<SET LOG <CHANNEL-OPEN DISK .NAME "CREATE" "ASCII">>>
	     ;"Hash table size and end of file pointer."
	     <PUT .DIR <+ ,DIR-TABSIZ 1> .NBKTS>
	     <PUT .DIR <+ ,DIR-EOFPTR 1> <LENGTH .DIR>>
	     <CHANNEL-OP .LIB WRITE-BUFFER .DIR>
	     <SET NAME <CHANNEL-OP .LIB NAME>>
	     <CLOSE .LIB>
	     <PRINTSTRING "*** " .LOG>
	     <PRINTSTRING <DTIME> .LOG>
	     <PRINTSTRING " Library created" .LOG>
	     <CRLF .LOG>
	     <CLOSE .LOG>
	     .NAME)
	    (T
	     <ERROR CANT-OPEN-LIBRARY-FILE!-ERRORS .NAME .LIB LUPI-CREATE>
	     .LIB)>>>

;"LUPI-ADD-PACK --
  Effect:   Adds RECORD to shadow library. The names in TMP are the names
	    of the temporary files involved in the transaction. The names
	    in ADD are the destination file names. The order MUST be the
	    same. Writes message to log file.
  Modifies: K."

<DEFINE LUPI-ADD-PACK (RECORD:<UVECTOR [REST FIX]> ADD:LIST TMP:LIST
		       "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND (<AND .K
	       <==? <LENGTH .ADD> <LENGTH .TMP>>	;"Just in case."
	       <ADD-RECORD .RECORD <LL-NEW .K>>>
	  <BIND ((LLADD:LIST <LL-ADD-FILES .K>)
		 (LLTMP:LIST <LL-TMP-FILES .K>)
		 (LLSIZE:FIX <LENGTH .LLTMP>)
		 (LOG:<CHANNEL 'DISK> <LL-LOG .K>)
		 (NAME:STRING <STACK <ISTRING ,MAXSTRS>>))
	     ;"Splice file names onto existing lists."
	     <COND (<==? .LLSIZE 0>
		    <LL-TMP-FILES .K .TMP>
		    <LL-ADD-FILES .K .ADD>)
		   (<NOT <EMPTY? .TMP>>
		    <PUTREST <REST .LLTMP <- .LLSIZE 1>> .TMP>
		    <PUTREST <REST .LLADD <- .LLSIZE 1>> .ADD>)>
	     <PRINTSTRING "    Adding record " .LOG>
	     <PRINTSTRING .NAME .LOG
			  <UV2SS <REST .RECORD> .NAME <BYTE0 <1 .RECORD>>>>
	     <CRLF .LOG>>)>>

;"LUPI-ADD-FILE --
  Effect:   Adds an auxiliary file to the library directory (such as a runtime
	    help file). TMP is the name of the temporary file obtained from
	    LUPI-GENTEMP and ADD is the name the file should be renamed to when
	    the library is installed.
  Modifies: K."

<DEFINE LUPI-ADD-FILE (TMP:STRING ADD:STRING
		       "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND (.K
	  <LL-TMP-FILES .K (.TMP !<LL-TMP-FILES .K>)>
	  <LL-ADD-FILES .K (.ADD !<LL-ADD-FILES .K>)>
	  T)>>

;"LUPI-DEL-FILE --
  Effect:   Adds the name of an auxiliary file (in the library directory) to
	    the list of files to be deleted when the modified library is
	    installed.
  Modifies: K."

<DEFINE LUPI-DEL-FILE (DEL:STRING "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND (.K
	  <PROG ((OLD:<CHANNEL 'DISK> <LL-OLD .K>)
		 (DEV:<SPECIAL STRING> <CHANNEL-OP .OLD DEV>)
		 (SNM:<SPECIAL STRING> <CHANNEL-OP .OLD SNM>)
		 (FN:<CHANNEL 'PARSE> <CHANNEL-OPEN PARSE .DEL>)
		 (NM2:<SPECIAL STRING> <CHANNEL-OP .FN NM2>))
	     <SET DEL <CHANNEL-OP .FN NM1>>
	     <CLOSE .FN>
	     <CHANNEL-OPEN PARSE .DEL>
	     <SET DEL <CHANNEL-OP .FN NAME>>
	     <CLOSE .FN>
	     <LL-DEL-FILES .K (.DEL !<LL-DEL-FILES .K>)>
	     T>)>>

;"LUPI-DEL-PACK --
  Effect:   Deletes record named PACKAGE from shadow library and adds the
	    file names in record to delete list (if they correspond to files
	    in the library directory.
  Modifies: K."

<DEFINE LUPI-DEL-PACK (PACKAGE:STRING "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND
    (.K
     <PROG ((FILES:VECTOR <STACK <IVECTOR 4 %<>>>)
	    (LLDEL:LIST <LL-DEL-FILES .K>)
	    (LOG:<CHANNEL 'DISK> <LL-LOG .K>)
	    (NEW:<CHANNEL 'DISK> <LL-NEW .K>)
	    (DEV:<SPECIAL STRING> <CHANNEL-OP .NEW DEV>)
	    (SNM:<SPECIAL STRING> <CHANNEL-OP .NEW SNM>)
	    FN:<CHANNEL 'PARSE>)
	<COND
	 (<REMOVE-RECORD .PACKAGE .NEW .FILES>
	  ;"Map over the files REMOVE-RECORD found, adding them to
	    delete list if they are in the library directory. This
	    will always happen unless the library contains explicit
	    path name (those without paths must be in the library
	    directory and will be parsed as such)."
	  <MAPF
	   %<>
	   <FUNCTION (NAME:<OR STRING FALSE>)
	      <COND (.NAME
		     <SET FN <CHANNEL-OPEN PARSE .NAME>>
		     <COND (<AND <=? <CHANNEL-OP .FN DEV>:STRING .DEV>
				 <=? <CHANNEL-OP .FN SNM>:STRING .SNM>>
			    <SET LLDEL
				 (<CHANNEL-OP .FN NAME ,NO-GENERATION> !.LLDEL)>)>
		     <CLOSE .FN>)>>
	   .FILES>
	  <LL-DEL-FILES .K .LLDEL>
	  <PRINTSTRING "    Removing record " .LOG>
	  <PRINTSTRING .PACKAGE .LOG>
	  <CRLF .LOG>
	  T)>>)>>

;"LUPI-GC --
  Effect:   Compact shadow library, reclaiming any holes in the file. The
	    old shadow library is closed and the garbage collected shadow
	    library becomes the shadow library. Writes message to log file.
            NBKTS suggests the number of buckets to use.
  Modifies: K."

<DEFINE LUPI-GC ("OPT" (NBKTS:FIX ,INITIAL-BUCKETS)
                 "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND (.K
	  <BIND ((NEW:<CHANNEL 'DISK> <LL-NEW .K>)
		 (NAME:STRING <LUPI-GENTEMP>)
		 (LOG:<CHANNEL 'DISK> <LL-LOG .K>)
		 NNEW:<OR FALSE <CHANNEL 'DISK>>)
	     <COND (<AND <SET NNEW <CHANNEL-OPEN DISK .NAME "CREATE" "BINARY">>
			 <GC-LIB .NEW .NNEW .NBKTS>>
		    <SET NAME <CHANNEL-OP .NEW NAME>>
		    <FLUSH .NEW>
		    <DELFILE .NAME>
		    <LL-NEW .K .NNEW>
		    <PRINTSTRING "*** Library GC" .LOG>
		    <CRLF .LOG>
		    T)
		   (.NNEW
		    <FLUSH .NNEW>
		    <DELFILE .NAME>
		    %<>)>>)>>

;"NPRIME? -- Returns T iff N is not prime."

<DEFINE NPRIME? (N:FIX)
   #DECL ((N) FIX)
   <REPEAT ((D:FIX 2) (SQ:FIX <FIX <+ <SQRT <FLOAT .N>>:FLOAT 1.0>>))
      <COND (<G? .D .SQ> <RETURN %<>>)
	    (<==? <MOD .N .D> 0> <RETURN .D>)>
      <SET D <+ .D 1>>>>

;"NEXT-PRIME -- Returns next prime larger than X."

<DEFINE NEXT-PRIME (X:FIX)
   <REPEAT () <COND (<NOT <NPRIME? <SET X <+ .X 1>>>> <RETURN .X>)>>>

;"ALLOCATE --
  Effect:   Allocates AMT storage in LIB. The storage is taken from the free
	    list if possible otherwise storage is allocated at the end of
	    the file.
  Modifies: LIB
  Returns:  Address of allocated storage block."

<DEFINE ALLOCATE (LIB:<CHANNEL 'DISK> AMT:FIX
		  "AUX" BSIZE:FIX BADDR:FIX BPRED:FIX BSUCC:FIX SIZE:FIX
			ADDR:FIX SUCC:FIX PRED:FIX)
   <SETADR .LIB <SET PRED ,DIR-FRELST>>     ;"Move to free list."
   <SET ADDR <RDWRD .LIB>>		    ;"Address of first block."
   <SET BADDR <RDWRD .LIB>>		    ;"Best address initially EOF."
   <SET BSIZE *77777777*>		    ;"Best size initially max."
   <SET BPRED 0>			    ;"No predecessor."
   <SET BSUCC 0>			    ;"No successor."
   <COND (<N==? .ADDR 0>		    ;"Not end of list?"
	  <SETADR .LIB .ADDR>		    ;"Go to block descriptor."
	  <SET SIZE <RDWRD .LIB>>	    ;"Its size."
	  <SET SUCC <RDWRD .LIB>>	    ;"Its cdr."
	  <REPEAT ()			    ;"Cruise the list."
	     <COND (<OR <==? .SIZE .AMT>    ;"Better tnan best so far?"
			;"Must be at least 2 words bigger."
			<AND <G=? .SIZE <+ .AMT 2>> <L? .SIZE .BSIZE>>>
		    <SET BSIZE .SIZE>	    ;"Yep, set best variables."
		    <SET BPRED .PRED>
		    <SET BSUCC .SUCC>
		    <SET BADDR .ADDR>)>
	     ;"If end of list or exact, we can do no better."
	     <COND (<OR <0? .SUCC> <==? .BSIZE .AMT>>
		    <RETURN>)
		   (T
		    <SET PRED <+ .ADDR 1>>  ;"Move to next block."
		    <SETADR .LIB <SET ADDR .SUCC>>
		    <SET SIZE <RDWRD .LIB>>
		    <SET SUCC <RDWRD .LIB>>)>>)>
   <COND (<==? .BPRED 0>		    ;"0 -- eof, bump eof pointer."
	  <SETADR .LIB ,DIR-EOFPTR>
	  <WRWRD .LIB <+ .BADDR .AMT>>)
	 (T
	  <SETADR .LIB .BPRED>		    ;"Got a block from list."
	  <COND (<==? .BSIZE .AMT>	    ;"Exact, just splice out."
		 <WRWRD .LIB .BSUCC>)
		(T			    ;"Carve out a piece."
		 <WRWRD .LIB <SET ADDR <+ .BADDR .AMT>>>
		 <SETADR .LIB .ADDR>	    ;"Splice in reduced block."
		 <WRWRD .LIB <- .BSIZE .AMT>>
		 <WRWRD .LIB .BSUCC>)>)>
   <COND (<G? <+ .BADDR .AMT> *77777777*>   ;"File address < 24 bits."
	  <ERROR LIBRARY-SPACE-EXHAUSTED!-ERRORS .BADDR ALLOCATE>
	  %<>)
	 (T
	  .BADDR)>>

;"FREE --
  Effect:   Deallocate AMT storage beginning at address START. The block
	    is spliced into the FREE list in storage order.
  Modifies: LIB."

<DEFINE FREE (LIB:<CHANNEL 'DISK> START:FIX AMT:FIX
	      "AUX" (END:FIX <+ .START .AMT>) (PAIR <STACK <UVECTOR .AMT 0>>)
		    PRED:FIX SUCC:FIX)
   <SETADR .LIB <SET PRED ,DIR-FRELST>>     ;"Move to free list."
   <COND (<==? <SET SUCC <RDWRD .LIB>> 0>   ;"If none, its easy."
	  <SETADR .LIB ,DIR-FRELST>
	  <WRWRD .LIB .START>
	  <SETADR .LIB .START>
	  <WRBUF .LIB .PAIR>)
	 (T				    ;"Find where block belongs."
	  <REPEAT (SIZE:FIX)
	     <SETADR .LIB .SUCC>	    ;"Move to successor."
	     <RDBUF .LIB .PAIR>		    ;"Get descriptor."
	     <COND (<==? .START <+ .SUCC <SET SIZE <1 .PAIR>>>>
		    ;"Block is adjacent to end of SUCC, compact."
		    <COND (<==? .END <2 .PAIR>>
			   ;"Block exactly fills hole between SUCC and
			     and its successor, compact all three."
			   <SET AMT <+ .SIZE .AMT>>	;"Add block to SUCC."
			   <SETADR .LIB <2 .PAIR>>	;"Move to SUCC's cdr."
			   <RDBUF .LIB .PAIR>		;"Get its size."
			   <SET SIZE <1 .PAIR>>)>	;"and its successor."
		    <1 .PAIR <+ .SIZE .AMT>> ;"Add the words we are freeing."
		    <SETADR .LIB .SUCC>      ;"Move to SUCC."
		    <WRBUF .LIB .PAIR>	     ;"And mung in the new descriptor."
		    <RETURN>)
		   (<==? .END .SUCC>
		    ;"SUCC is adjacent to end of block, compact."
		    <SETADR .LIB .START>
		    ;"SUCC's successor becomes block's successor,
		      add SUCC's size to block's size, mung in new descriptor
		      and mung SUCC's predecessor.."
		    <WRBUF .LIB <1 .PAIR <+ .SIZE .AMT>>>
		    <SETADR .LIB .PRED>
		    <WRWRD .LIB .START>
		    <RETURN>)
		   (<L? .START .SUCC>
		    ;"Block belongs before SUCC, mung SUCC's predecessor and
		      point block at SUCC."
		    <SETADR .LIB .START>
		    <WRBUF .LIB <1 <2 .PAIR .SUCC> .AMT>>
		    <SETADR .LIB .PRED>
		    <WRWRD .LIB .START>
		    <RETURN>)
		   (<==? <2 .PAIR> 0>
		    ;"Block belongs after SUCC, point SUCC at block."
		    <SETADR .LIB <+ .SUCC 1>>
		    <WRWRD .LIB .START>
		    <SETADR .LIB .START>
		    <WRBUF .LIB <1 <2 .PAIR 0> .AMT>>
		    <RETURN>)
		   (T			     ;"Keep looking."
		    <SET PRED <+ .SUCC 1>>
		    <SET SUCC <2 .PAIR>>)>>)>
   T>

;"ADD-RECORD --
  Effect:   Adds RECORD to LIB. The directory is pointed at RECORD and all of its
	    entrys.
  Modifies: LIB
  Requires: RECORD is a properly formatted library record as defined in
	    LIBRARY.FORMAT."

<DEFINE ADD-RECORD (RECORD:<UVECTOR [REST FIX]> LIB:<CHANNEL 'DISK> "NAME" ADD-RECORD
		    "AUX" TMP:FIX RECADDR:FIX ADDR:FIX ERCNT:FIX DELTA:FIX
			  NBKTS:FIX 
			  (STATS:<UVECTOR [REST FIX]> <STACK <IUVECTOR 2>>))
   <COND (<G? <SET TMP <LHALF <1 .RECORD>>> <LENGTH .RECORD>>
	  <ERROR BAD-RECORD!-ERRORS "Incorrect RECLEN" .TMP <LENGTH .RECORD>
		 ADD-RECORD>
	  <RETURN %<> .ADD-RECORD>)>
   <SET RECADDR <ALLOCATE .LIB .TMP>>	     ;"Get some space."
   <SETADR .LIB .RECADDR>		     ;"Move to allocated address."
   <WRBUF .LIB .RECORD .TMP>		     ;"Write the record."
   <SETADR .LIB ,DIR-TABSIZ>		     ;"Get size of hash table."
   <SET NBKTS <RDWRD .LIB>>
   <SETADR .LIB ,DIR-LERCNT>		     ;"Get entry, package counts."
   <RDBUF .LIB .STATS>
   <SET TMP <BYTE0 <1 .RECORD>>>	     ;"Length of record name."
   <SET ADDR <HASH-UV <REST .RECORD> .NBKTS .TMP>>
   <ADD-POINTER .LIB .ADDR .RECADDR ,BKT-P>  ;"Point bucket at RECORD."
   <SET TMP <NTH .RECORD <+ .TMP 3>>>	     ;"Entry count, distance to list."
   <SET ERCNT <RHALF .TMP>>
   <SET DELTA <LHALF .TMP>>
   <2 <1 .STATS <+ <1 .STATS> .ERCNT>> <+ <2 .STATS> 1>>
   <SETADR .LIB ,DIR-LERCNT>		     ;"Update statistics."
   <WRBUF .LIB .STATS>
   <REPEAT ()				     ;"Hash entrys, add pointers."
      <COND (<0? .ERCNT> <RETURN>)>
      <SET TMP <BYTE0 <NTH .RECORD <+ .DELTA 1>>>>
      <SET ADDR <HASH-UV <REST .RECORD <+ .DELTA 1>> .NBKTS .TMP>>
      <ADD-POINTER .LIB .ADDR <+ .RECADDR .DELTA> ,BKT-E>
      <SET ERCNT <- .ERCNT 1>>
      <COND (<G? <SET DELTA <+ .DELTA .TMP 1>> <LENGTH .RECORD>>
	     <ERROR BAD-RECORD!-ERRORS "Incorrect DELTAP" .DELTA
		    <LENGTH .RECORD> ADD-RECORD>
	     <RETURN %<>>)>>>

;"ADD-POINTER --
  Effect:   Points the bucket FROM at address TO with MASK bits set in
	    bucket pointer (either BKT-P or BKT-E).
  Modifies: LIB
  Requires: FROM is address of BUCKET that was obtained from hasher, TO
	    is the address of a package or entry record, MASK is a legal
	    bucket mask."

<DEFINE ADD-POINTER (LIB:<CHANNEL 'DISK> FROM:FIX TO:FIX MASK:FIX "AUX" TMP:FIX)
   <SETADR .LIB .FROM>
   <COND (<0? <SET TMP <RDWRD .LIB>>>	     ;"Empty bucket."
	  <SETADR .LIB .FROM>
	  <WRWRD .LIB <ORB .TO .MASK>>)
	 (T				     ;"Single or list."
	  <BIND ((PAIR:<UVECTOR [REST FIX]> <STACK <IUVECTOR 2>>) ADDR:FIX)
	     <SET ADDR <ALLOCATE .LIB 2>>    ;"Get cons cell."
	     <COND (<TESTBIT .TMP ,BKT-M %<>>
		    ;"It was single item. We have to get a cons cell for
		      existing pointer and link FROM to the list of two
		      items."
		    <2 <1 .PAIR .TMP> <SET TMP <ALLOCATE .LIB 2>>>
		    <SETADR .LIB .FROM>      ;"Point to list."
		    <WRWRD .LIB <ORB ,BKT-M .ADDR>>
		    <SETADR .LIB .ADDR>      ;"Old pointer."
		    <WRBUF .LIB .PAIR>
		    <2 <1 .PAIR <ORB .TO .MASK>> 0>
		    <SETADR .LIB .TMP>	     ;"New pointer."
		    <WRBUF .LIB .PAIR>)
		   (T			     ;"Cons onto existing list."
		    <SETADR .LIB .FROM>
		    <WRWRD .LIB <ORB ,BKT-M .ADDR>>
		    <2 <1 .PAIR <ORB .MASK .TO>> <ADDRESS .TMP>>
		    <SETADR .LIB .ADDR>
		    <WRBUF .LIB .PAIR>)>>)>>

;"REMOVE-RECORD --
  Effect:   Removes record named PACKAGE from LIB. Removes all pointers to
	    record from directory, freeing the space. Gets names of files
	    associated with record.
  Modifies: LIB, FILES
  Returns:  Vector of file names associated with record."

<DEFINE REMOVE-RECORD (PACKAGE:STRING LIB:<CHANNEL 'DISK>
		       "OPT" (FILES:VECTOR <IVECTOR 4 %<>>)
		       "AUX" (BUFFER:<UVECTOR [REST FIX]> <STACK <IUVECTOR ,MAXREC>>)
			     (PDNLEN:FIX <LENGTHW .PACKAGE>)
			     (STATS:<UVECTOR [REST FIX]> <STACK <IUVECTOR 2>>)
			     RECADDR:FIX NBKTS:FIX RINFO:FIX
		       "NAME" REMOVE-RECORD)
   <SET BUFFER <REST .BUFFER <- <LENGTH .BUFFER> .PDNLEN>>>
   <SETADR .LIB ,DIR-TABSIZ>		     ;"Get size of hash table."
   <SET NBKTS <RDWRD .LIB>>
   <SETADR .LIB ,DIR-LERCNT>		     ;"Get package, entry count."
   <RDBUF .LIB .STATS>
   <BIND ((COMPARE:<UVECTOR [REST FIX]> <STACK <IUVECTOR .PDNLEN>>)
	  (BKT:FIX <HASH-SUV .PACKAGE .NBKTS .BUFFER>))
      <SETADR .LIB .BKT>		     ;"Look for pointer to record."
      <SET RECADDR <RDWRD .LIB>>
      <COND (<TESTBIT .RECADDR ,BKT-P>
	     ;"Single package pointer. Move to record and compare names."
	     <SETADR .LIB <SET RECADDR <ADDRESS .RECADDR>>>
	     <SET RINFO <RDWRD .LIB>>	     ;"Contains name length."
	     <COND (<==? <BYTE0 .RINFO> .PDNLEN>
		    ;"Same length, is it the name?"
		    <RDBUF .LIB .COMPARE>
		    <COND (<N=? .COMPARE .BUFFER>
			   <RETURN %<> .REMOVE-RECORD>)>)
		   (T
		    <RETURN %<> .REMOVE-RECORD>)>)
	    (<TESTBIT .RECADDR ,BKT-M>
	     ;"List, move through list examining package records."
	     <SETADR .LIB <ADDRESS .RECADDR>>
	     <REPEAT ((PAIR:<UVECTOR [REST FIX]> <STACK <IUVECTOR 2>>) CDR:FIX)
		<RDBUF .LIB .PAIR>
		<SET RECADDR <1 .PAIR>>
		<COND (<TESTBIT .RECADDR ,BKT-P>	   ;"Package?"
		       <SETADR .LIB <SET RECADDR <ADDRESS .RECADDR>>>
		       <SET RINFO <RDWRD .LIB>>
		       <COND (<==? <BYTE0 .RINFO> .PDNLEN> ;"Same name?"
			      <RDBUF .LIB .COMPARE>
			      <COND (<=? .COMPARE .BUFFER>
				     <RETURN>)>)>)>
		<COND (<==? <SET CDR <2 .PAIR>> 0>	   ;"Empty list?"
		       <RETURN %<> .REMOVE-RECORD>)
		      (T
		       <SETADR .LIB .CDR>)>>)
	    (T
	     <RETURN %<> .REMOVE-RECORD>)>
      <SET BUFFER <TOP .BUFFER>>	     ;"Get the record."
      <SETADR .LIB .RECADDR>
      <RDBUF .LIB .BUFFER <LHALF .RINFO>>    ;"We got record info above."
      <REMOVE-POINTER .LIB .BKT .RECADDR>    ;"Flush package pointer."
      <FREE .LIB .RECADDR <LHALF .RINFO>>>   ;"Free the record space."

   <BIND (ERCNT:FIX FSIZES:FIX DELTA:FIX)
      <SET BUFFER <REST .BUFFER <+ .PDNLEN 1>>>
      ;"Get sizes of file names."
      <COND (<TESTBIT .RINFO ,RINFO-DFN?>    ;"Is there a doc file?"
	     <SET FSIZES <1 .BUFFER>>)
	    (T				     ;"No, mask out doc length."
	     <SET FSIZES <ANDB *77777777* <1 .BUFFER>>>)>
      <SET ERCNT <RHALF <2 .BUFFER>>>	     ;"Count of entries."
      <SET DELTA <LHALF <2 .BUFFER>>>	     ;"Distance to entries."
      <SET BUFFER <REST .BUFFER 3>>
      <MAPR %<>				     ;"Get the file names."
	    <FUNCTION (FV:VECTOR "AUX" (FSIZE:FIX <BYTE0 .FSIZES>))
	       <SET FSIZES <LSH .FSIZES -8>>
	       <COND (<N==? .FSIZE 0>
		      <1 .FV <UV2S .BUFFER .FSIZE>>
		      <SET BUFFER <REST .BUFFER .FSIZE>>)
		     (T
		      <1 .FV %<>>)>>
	    .FILES>
      ;"Update library package, entry counts."
      <2 <1 .STATS <- <1 .STATS> .ERCNT>> <- <2 .STATS> 1>>
      <SETADR .LIB ,DIR-LERCNT>
      <WRBUF .LIB .STATS 2>
      <SET BUFFER <REST <TOP .BUFFER> .DELTA>>
      <REPEAT (ERLEN:FIX ADDR:FIX BKT:FIX)   ;"Remove pointers to entries."
	 <COND (<0? .ERCNT> <RETURN .FILES>)>
	 <SET ADDR <+ .RECADDR <- <LENGTH <TOP .BUFFER>> <LENGTH .BUFFER>>>>
	 <SET ERLEN <BYTE0 <1 .BUFFER>>>
	 <SET BKT <HASH-UV <REST .BUFFER> .NBKTS .ERLEN>>
	 <REMOVE-POINTER .LIB .BKT .ADDR>
	 <SET ERCNT <- .ERCNT 1>>
	 <SET BUFFER <REST .BUFFER <+ .ERLEN 1>>>>>>

;"REMOVE-POINTER --
  Effect:   Deletes pointer to ADDR found in BKT. If the pointer is in cons,
	    its storage is freed.
  Modifies: LIB
  Requires: BKT is the address of a bucket in the hash table, ADDR is present
	    in BKT."

<DEFINE REMOVE-POINTER (LIB:<CHANNEL 'DISK> BKT:FIX ADDR:FIX "AUX" LAST:FIX)
   <SETADR .LIB .BKT>
   <COND (<==? <ADDRESS <SET LAST <RDWRD .LIB>>> .ADDR>
	  <SETADR .LIB .BKT>		     ;"ADDR was only thing in bucket"
	  <WRWRD .LIB 0>)
	 (<TESTBIT .LAST ,BKT-M>	     ;"List?"
	  <SET LAST <ADDRESS .LAST>>	     ;"Cruise the list."
	  <REPEAT ((PAIR:<UVECTOR [REST FIX]> <STACK <UVECTOR 0 0>>) (PRED:FIX .BKT))
	     <SETADR .LIB .LAST>	     ;"Get a cons."
	     <RDBUF .LIB .PAIR>		     ;"And check its car for ADDR."
	     <COND (<==? <ADDRESS <1 .PAIR>> .ADDR>
		    <FREE .LIB .LAST 2>      ;"Give away the cons."
		    <SET LAST <2 .PAIR>>     ;"Check out the cdr."
		    <COND (<==? .LAST 0>     ;"Nil?"
			   <SETADR .LIB .PRED>
			   <WRWRD .LIB 0>    ;"Predecessor gets nil."
			   <COND (<N==? .PRED .BKT>
				  ;"If this was last in list of two items, move
				    car of remaining cons to bucket."
				  <SETADR .LIB .BKT>
				  <SET LAST <ADDRESS <RDWRD .LIB>>>
				  <COND (<==? .LAST <SET PRED <- .PRED 1>>>
					 ;"Yep, bucket points to this cons."
					 <SETADR .LIB .PRED>
					 <SET LAST <RDWRD .LIB>>
					 <FREE .LIB .PRED 2>
					 <SETADR .LIB .BKT>
					 <WRWRD .LIB .LAST>)>)>)
			  (<==? .PRED .BKT>
			   ;"If this was first in list of two items, move
			     car of remaining cons to bucket."
			   <SETADR .LIB .LAST>
			   <RDBUF .LIB .PAIR>
			   <SETADR .LIB .BKT>
			   <COND (<==? <2 .PAIR> 0>
				  ;"Yep, ADDR's successor is last in list."
				  <WRWRD .LIB <1 .PAIR>>
				  <FREE .LIB .LAST 2>)
				 (T
				  <WRWRD .LIB <ORB .LAST ,BKT-M>>)>)
			  (T		     ;"Just splice the cons out."
			   <SETADR .LIB .PRED>
			   <WRWRD .LIB .LAST>)>
		    <RETURN>)
		   (T
		    <SET PRED <+ .LAST 1>>   ;"Cdr is second word."
		    <SETADR .LIB <SET LAST <2 .PAIR>>>)>>)
	 (T
	  <ERROR BAD-POINTER!-ERRORS .LAST .ADDR REMOVE-POINTER>)>>

;"GC-LIB --
  Effect:   Copies contents of LIB to NEW in bucket order, rehashing if need.
            NNBKTS suggests the number of buckets to use.
  Modifies: NEW
  Requires: LIB is properly formatted library as defined in LIBRARY.FORMAT"

<DEFINE GC-LIB (LIB:<CHANNEL 'DISK> NEW:<CHANNEL 'DISK>
                "OPT" (NNBKTS:FIX ,INITIAL-BUCKETS)
                "NAME" GC-LIB 
		"AUX" NBKTS:FIX TMP:FIX (PAIR:<UVECTOR [REST FIX]> <STACK <IUVECTOR 2>>))
   <SET NNBKTS <NEXT-PRIME .NNBKTS>>
   <SETADR .LIB ,DIR-TABSIZ>		     ;"Get table size."
   <SET NBKTS <RDWRD .LIB>>
   <SETADR .LIB ,DIR-LERCNT>		     ;"Get package, entry counts."
   <RDBUF .LIB .PAIR>
   <COND (<G? </ <FLOAT <+ <1 .PAIR> <2 .PAIR>>> <FLOAT .NBKTS>> 1.5>
	  <SET NNBKTS			     ;"Rehash."
               <MAX .NNBKTS
                    <NEXT-PRIME <FIX <* 1.5 <FLOAT <+ <1 .PAIR> <2 .PAIR>>>>>>>>)>
   ;"Construct and write new directory."
   <BIND ((DIR:<UVECTOR [REST FIX]> <STACK <IUVECTOR <+ .NNBKTS ,DIR-HDRLEN> 0>>))
      ;"Initialize table size, end of file pointer for new directory."
      <PUT .DIR <+ ,DIR-TABSIZ 1> .NNBKTS>
      <PUT .DIR <+ ,DIR-EOFPTR 1> <LENGTH .DIR>>
      <SETADR .NEW ,DIR-TABSIZ>
      <OR <WRBUF .NEW .DIR> <RETURN %<> .GC-LIB>>>
   <SET NBKTS <+ .NBKTS ,DIR-HDRLEN>>
   ;"Find all the records and copy them to NEW."
   <REPEAT ((RECORD:<UVECTOR [REST FIX]> <STACK <IUVECTOR ,MAXREC>>) (NPKGS:FIX <2 .PAIR>)
	    (BKT:FIX ,DIR-HDRLEN))
      <COND (<OR <==? .NPKGS 0> <G? .BKT .NBKTS>>
	     <RETURN .NEW>)>
      <SETADR .LIB .BKT>		     ;"Get current bucket."
      <SET TMP <RDWRD .LIB>>
      <COND (<TESTBIT .TMP ,BKT-P>	     ;"Package?"
	     <SETADR .LIB <ADDRESS .TMP>>
	     <RDBUF .LIB .RECORD 1>	     ;"Record info."
	     <RDBUF .LIB <REST .RECORD> <- <LHALF <1 .RECORD>> 1>>
	     <OR <ADD-RECORD .RECORD .NEW> <RETURN %<> .GC-LIB>>
	     <SET NPKGS <- .NPKGS 1>>)
	    (<TESTBIT .TMP ,BKT-M>	     ;"List?"
	     <REPEAT ()			     ;"Cruise the list."
		<SETADR .LIB <ADDRESS .TMP>>
		<RDBUF .LIB .PAIR>	     ;"Get cons."
		<COND (<TESTBIT <1 .PAIR> ,BKT-P>	;"Package?"
		       <SETADR .LIB <ADDRESS <1 .PAIR>>>
		       <RDBUF .LIB .RECORD 1>	;"Record info."
		       <RDBUF .LIB
			      <REST .RECORD>
			      <- <LHALF <1 .RECORD>> 1>>
		       <OR <ADD-RECORD .RECORD .NEW> <RETURN %<> .GC-LIB>>
		       <SET NPKGS <- .NPKGS 1>>)>
		<COND (<==? <SET TMP <2 .PAIR>> 0> <RETURN>)>>)>
      <SET BKT <+ .BKT 1>>>>

;"LUPI-RECORD-EXISTS? --
  Effect:   Returns T if record named NAME exists in shadow library."

<DEFINE LUPI-RECORD-EXISTS? (NAME:STRING
		      "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY)
			    (JUNK:<UVECTOR [REST FIX]> <STACK <IUVECTOR 2>>))
   <AND .K <PACKAGE-POINTER .NAME <LL-NEW .K> .JUNK>>>

;"LUPI-FILE-EXISTS? --
  Effect:  Returns T if file named NAME is found in the library directory."

<DEFINE LUPI-FILE-EXISTS? (NAME:STRING "AUX" (K:<OR FALSE LIBLOCK> ,LUPI-KEY))
   <COND
    (.K
     <PROG ((FN:<CHANNEL 'PARSE> <CHANNEL-OPEN PARSE .NAME>)
	    (DEV:<SPECIAL STRING> <CHANNEL-OP <LL-OLD .K>:<CHANNEL 'DISK> DEV>)
	    (SNM:<SPECIAL STRING> <CHANNEL-OP <LL-OLD .K>:<CHANNEL 'DISK> SNM>)
	    (NM2:<SPECIAL STRING> <CHANNEL-OP .FN NM2>))
	<SET NAME <CHANNEL-OP .FN NM1>>
	<CLOSE .FN>
	<RETURN <FILE-EXISTS? .NAME>>>)>>

;"I2S --
  Effect:   Convert I to string representation.
  Modifies: S
  Returns:  S rested to the first digit.
  Requires: S is large enough to hold the representation of I."

<DEFINE I2S (I:FIX "OPT" (S:STRING <ISTRING 13>)
                   "AUX" (NEG:<OR ATOM FALSE> <L? .I 0>))
   <COND (.NEG <SET I <- .I>>)>
   <REPEAT ((P:FIX <LENGTH .S>) D:FIX)
      <SET D <MOD .I 10>>
      <PUT .S .P <CHTYPE <+ .D %<CHTYPE !\0 FIX>> CHARACTER>>
      <SET P <- .P 1>>
      <COND (<==? <SET I </ .I 10>> 0>
             <COND (.NEG 
                    <PUT .S .P !\->
                    <SET P <- .P 1>>)>
             <RETURN <REST .S .P>>)>>>

   
