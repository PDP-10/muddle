<PACKAGE "L-QUERY">

;"****************************************************************************

  This file defines a query facility for the LIBRARY system: listing names of
  packages, entries, counts of same, findatom, etc. Both network and local
  libraries can be queried. See definition of library records (long, short)
  in LIBRARY.FORMAT.

  L-QUERY.MUD: EDIT HISTORY                                Machine Independent

  COMPILATION: XMIMC L-QUERY /NC <SET EXPFLOAD T>

  JUN84   [Shane] - Created.
  11OCT84 [Shane] - Commented, cleaned up.
  21OCT84 [Shane] - New protocols.
  29OCT84 [Shane] - L-DOC optionally (default) prints documentation files. Flush
		    some internal functions. Create some shareable internal
		    functions. Rewrite some kludges.
  ***************************************************************************"

<ENTRY L-LISTPE L-DOC L-FILES L-LISTE L-LISTP L-COUNTE L-COUNTP L-LISTU
       L-FINDATOM>

<USE "LIBRARY">

<INCLUDE-WHEN <COMPILING? "L-QUERY">
              "L-DEFS" !<IFSYS ("VAX" '("L-NETDEFS" "NETDEFS")) ("TOPS20" ())>>

<IFSYS ("VAX" <USE "NETBASE">)>

%%<PRINC "+L-QUERY-BASE "> <L-FLOAD "L-QUERY-BASE">	;"Splice into code."

%%<CRLF>

;"L-DOC --
  Effect:   If PKG is documented in library denoted LIBS, the documentation
	    is printed on OUTCHAN. If the documentation is a file, the name of
	    the file is printed in standard format (and if PRINT-FILE? is non-
	    false, the contents of the file is printed as well). If PKG is in
	    library denoted by LIBS but not documented, a message to the effect
	    is printed.
  Modifies: OUTCHAN.
  Returns:  T if PKG is found, FALSE otherwise."

<DEFINE L-DOC (PKG:STRING
	       "OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
		     (PRINT-FILE?:<OR ATOM FALSE> T)
		     (OUTCHAN:CHANNEL .OUTCHAN)
	       "AUX" (LIBC:<OR CHANNEL FALSE> %<>)
		     (DOC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>) DEV:<SPECIAL STRING>
	   PREFIX:<OR VECTOR STRING> RINFO:FIX DOCLEN:FIX DOCSTR:STRING
	   SNM:<SPECIAL STRING> FN:<CHANNEL 'PARSE>)
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <LQ-GET-RECORD .PKG .LIBC .RECORD %<>>>    ;"Short record"
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <SET PREFIX <MAKE-PREFIX .LIBC>>     ;"Path specification."
       <CLOSE .LIBC>
       <SET RINFO <1 .RECORD>>              ;"Record information."
       <SET DOCLEN <NTH .RECORD <+ <BYTE0 .RINFO> 2>>>	;"File name sizes."
       <SET RECORD                          ;"Move to start of documentation."
	    <REST .RECORD <+ <BYTE0 .RINFO> <BYTE0 .DOCLEN> <BYTE1 .DOCLEN>
			     <BYTE2 .DOCLEN> 2>>>
       <COND (<0? <SET DOCLEN <BYTE3 .DOCLEN>>>	;"Doc length is high byte."
	      <PRINTSTRING "No documentation provided." .OUTCHAN>
	      <CRLF .OUTCHAN>
	      <RETURN>)>
       <COND (<TESTBIT .RINFO ,RINFO-DFN? %<>>	;"Documentation string, no file."
	      <SET DOCSTR <UV2S .RECORD .DOCLEN>>)
	     (<TYPE? .PREFIX STRING>        ;"Network library path spec."
	      <SET DOCSTR <STRING .PREFIX <UV2S .RECORD .DOCLEN>>>)
	     (T                             ;"Local library file spec."
	      <SET DEV <1 .PREFIX>>
	      <SET SNM <2 .PREFIX>>
	      <SET FN <CHANNEL-OPEN 'PARSE <UV2S .RECORD .DOCLEN>>>
	      <SET DOCSTR <CHANNEL-OP .FN NAME ,NO-GENERATION>>
	      <CLOSE .FN>)>
       <PRINTSTRING .DOCSTR .OUTCHAN>
       <COND (<AND .PRINT-FILE? <TESTBIT .RINFO ,RINFO-DFN?>>
	      ;"Get the documentation file from LIBS and print it."
	      <COND (<SET DOC <FILE-FIND <UV2S .RECORD .DOCLEN> .LIBS>>
		     <CRLF .OUTCHAN>
		     <FILECOPY .DOC .OUTCHAN>
		     <CLOSE .DOC>)
		    (T
		     <PRINTSTRING "Cant open documentation file." .OUTCHAN>)>)>
       <CRLF .OUTCHAN>>
    <BIND () <AND .LIBC <CHANNEL-OPEN? .LIBC> <CLOSE .LIBC>>
	     <AND .DOC <CHANNEL-OPEN? .DOC> <CLOSE .DOC>>>>>

;"L-FILES --
  Effect:   If PKG is found in library denoted by LIBS, the names of the files
	    associated with the PKG are printed on OUTCHAN in standard format.
  Modifies: OUTCHAN.
  Returns:  T if PKG is found, otherwise FALSE."

<DEFINE L-FILES (PKG:STRING
		 "OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
		       (OUTCHAN:CHANNEL .OUTCHAN)
		 "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>) DEV:<SPECIAL STRING>
	   PREFIX:<OR VECTOR STRING> FNSIZES:FIX RINFO:FIX
	   SNM:<SPECIAL STRING>)
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <LQ-GET-RECORD .PKG .LIBC .RECORD %<>>>
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <SET PREFIX <MAKE-PREFIX .LIBC>>     ;"Path specification."
       <CLOSE .LIBC>
       <SET RINFO <1 .RECORD>>              ;"Record information."
       <SET FNSIZES <NTH .RECORD <+ <BYTE0 .RINFO> 2>>>	;"File name sizes."
       <SET RECORD <REST .RECORD <+ <BYTE0 .RINFO> 2>>>	;"Move to names."
       <COND (<TESTBIT .RINFO ,RINFO-DFN? %<>>	;"If no doc file, mask doc size."
	      <SET FNSIZES <GETBITS .FNSIZES <BITS 24 0>>>)>
       <REPEAT (FNSIZE:FIX FN:<CHANNEL 'PARSE>)
	  <COND (<G? <SET FNSIZE <BYTE0 .FNSIZES>> 0>
		 <COND (<TYPE? .PREFIX STRING>	;"Network file."
			<PRINTSTRING .PREFIX .OUTCHAN>
			<PRINTSTRING <UV2S .RECORD .FNSIZE> .OUTCHAN>)
		       (T                   ;"Local file."
			<SET DEV <1 .PREFIX>>
			<SET SNM <2 .PREFIX>>
			<SET FN <CHANNEL-OPEN PARSE <UV2S .RECORD .FNSIZE>>>
			<PRINTSTRING <CHANNEL-OP .FN NAME ,NO-GENERATION> .OUTCHAN>
			<CHANNEL-CLOSE .FN>)>
		 <CRLF .OUTCHAN>
		 <SET RECORD <REST .RECORD .FNSIZE>>)>
	  <COND (<0? <SET FNSIZES <LSH .FNSIZES -8>>> <RETURN>)>>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"MAKE-PREFIX --
  Effect:   Construct specification of library directory: a string specifying
	    host directory if LIBC is NETWORK channel, otherwise a vector
	    containing DEV, SNM if LIBC is local channel.
  Returns:  Path specification for LIBC.
  Requires: LIBC is not closed."

<DEFINE MAKE-PREFIX (LIBC:CHANNEL)
   <PROG ()
      <IFSYS ("VAX"
	      ;"Network => UNIX: host:hostdir/"
	      <COND (<REMOTE? .LIBC>
		     <RETURN <STRING ,SERVER-NAME ":" ,SERVER-DIR "/">>)>)>
      ;"Local: [DEV SNM]"
      <RETURN [<CHANNEL-OP .LIBC:DSK DEV> <CHANNEL-OP .LIBC:DSK SNM>]>>>

;"L-LISTPE --
  Effect:   If PKG is found in LIBRARY denoted by LIBS, the names of all the
	    entrys and rentrys of PKG are printed together with type information
	    on OUTCHAN.
  Returns:  T if PKG is found, otherwise FALSE.
  Modifies: OUTCHAN."

<DEFINE L-LISTPE (PKG:STRING
		  "OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
			(OUTCHAN:CHANNEL .OUTCHAN)
		  "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>)
	   (S:STRING <STACK <ISTRING ,MAXSTRS>>) (PRINTED:FIX 0)
	   ERCNT:FIX DELTAE:FIX RINFO:FIX)
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <LQ-GET-RECORD .PKG .LIBC .RECORD>>
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <CLOSE .LIBC>
       <SET RINFO <1 .RECORD>>              ;"Record information."
       <COND (<TESTBIT .RINFO ,RINFO-PKG?>  ;"PACKAGE or DEFINITIONS?"
	      <PRINTSTRING "Package:" .OUTCHAN>)
	     (T
	      <PRINTSTRING "Definitions:" .OUTCHAN>)>
       <INDENT-TO 14 .OUTCHAN>              ;"Print module name."
       <PRINTSTRING .S .OUTCHAN <UV2SS <REST .RECORD> .S <BYTE0 .RINFO>>>
       <CRLF .OUTCHAN>
       <SET DELTAE <NTH .RECORD <+ <BYTE0 .RINFO> 3>>>
       <SET ERCNT <RHALF .DELTAE>>          ;"R/ENTRY count."
       <SET DELTAE <LHALF .DELTAE>>         ;"Distance to entry list."
       <PRINTSTRING "Entries:" .OUTCHAN>    ;"Print entries."
       <INDENT-TO 14 .OUTCHAN>
       <REPEAT ((COUNT:FIX .ERCNT) (DELTA:FIX .DELTAE) ERTYPE:FIX)
	  <COND (<0? .COUNT>
		 <COND (<0? .PRINTED>
			<PRINTSTRING "None." .OUTCHAN>
			<CRLF .OUTCHAN>)>
		 <RETURN>)>
	  <SET ERTYPE <NTH .RECORD <+ .DELTA 1>>>
	  <COND (<TESTBIT .ERTYPE ,ERTYP-ENTRY?>	;"Entry?"
		 <SET PRINTED <+ .PRINTED 1>>
		 <INDENT-TO 14 .OUTCHAN>
		 <PRINT-ENTRY <REST .RECORD .DELTA> .S .OUTCHAN T>
		 <CRLF .OUTCHAN>)>
	  <SET COUNT <- .COUNT 1>>
	  <SET DELTA <+ .DELTA <BYTE0 .ERTYPE> 1>>>
       <PRINTSTRING "Rentries:" .OUTCHAN>
       <COND (<==? .PRINTED .ERCNT>         ;"Print rentries if any."
	      <INDENT-TO 14 .OUTCHAN>
	      <PRINTSTRING "None." .OUTCHAN>
	      <CRLF .OUTCHAN>
	      <RETURN>)>
       <REPEAT ((COUNT:FIX <- .ERCNT .PRINTED>) (DELTA:FIX .DELTAE) ERTYPE:FIX)
	  <SET ERTYPE <NTH .RECORD <+ .DELTA 1>>>
	  <COND (<TESTBIT .ERTYPE ,ERTYP-ENTRY? %<>>	;"Rentry?"
		 <INDENT-TO 14 .OUTCHAN>
		 <PRINT-ENTRY <REST .RECORD .DELTA> .S .OUTCHAN T>
		 <CRLF .OUTCHAN>
		 <COND (<0? <SET COUNT <- .COUNT 1>>>
			<RETURN>)>)>
	  <SET DELTA <+ .DELTA <BYTE0 .ERTYPE> 1>>>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"PRINT-ENTRY --
  Effect:   Prints descriptive information about entry descriptor at head of
	    U (should be record rested to entry descriptor). The name of the
	    entry followed by a space is printed to OUTCHAN. If VERBOSE? is
	    non-false, then type information is also printed. S is buffer.
  Modifies: S, OUTCHAN
  Requires: U is library record rested to entry descriptor word.
	    size(S) >= MAXSTRS."

<DEFINE PRINT-ENTRY (U:UVECTOR S:STRING OUTCHAN:CHANNEL VERBOSE?:<OR ATOM FALSE>
		     "AUX" (ERTYPE:FIX <1 .U>) FIELD:FIX)
   <PRINTSTRING .S .OUTCHAN <UV2SS <REST .U> .S <BYTE0 .ERTYPE>>>
   <PRINTSTRING " " .OUTCHAN>
   <COND (.VERBOSE?
	  <COND (<N==? <SET FIELD <GETBITS .ERTYPE <BITS 4 8>>> 0>
		 <PRINTSTRING "Gassigned " .OUTCHAN>)>
	  <COND (<TESTBIT .ERTYPE ,ERTYP-MANIFEST?>
		 <PRINTSTRING "Manifest " .OUTCHAN>)>
	  <COND (<AND <G? .FIELD 0> <L=? .FIELD 7>>
		 <PRINC <NTH ,L-ERTYPES:VECTOR .FIELD> .OUTCHAN>
		 <PRINTSTRING " " .OUTCHAN>)
		(<TESTBIT .ERTYPE ,ERTYP-APPLICABLE?>
		 <PRINTSTRING "Applicable " .OUTCHAN>)>
	  <COND (<TESTBIT .ERTYPE ,ERTYP-TYPE?>
		 <PRINTSTRING "Type " .OUTCHAN>)>)>
   T>

;"L-COUNTP --
  Effect:   Fetch count of number of packages or definitions contained in
	    library denoted by LIBS.
  Returns:  Package count if successful, otherwise FALSE."

<DEFINE L-COUNTP ("OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
		  "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((STATS:<OR FALSE <UVECTOR [2 FIX]>> <STACK <IUVECTOR 2>>))
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)>
       <SET STATS <GET-LIBRARY-STATISTICS .LIBC .STATS>>
       <CLOSE .LIBC>
       <COND (.STATS <2 .STATS>)>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"L-COUNTE --
  Effect:   Fetch count of number of entries or rentries contained in
	    library denoted by LIBS.
  Returns:  Entry count if successful, otherwise FALSE."

<DEFINE L-COUNTE ("OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
		  "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((STATS:<OR FALSE <UVECTOR [2 FIX]>> <STACK <IUVECTOR 2>>))
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)>
       <SET STATS <GET-LIBRARY-STATISTICS .LIBC .STATS>>
       <CLOSE .LIBC>
       <COND (.STATS <1 .STATS>)>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"GET-LIBRARY-STATISTICS --
  Effect:   Fetch library counts from LIBC into STATS.
  Modifies: LIBC, STATS
  Returns:  STATS = ![packages entries!] if successful, otherwise FALSE.
  Requires: Server is waiting for request if LIBC is NETWORK channel."

<DEFINE GET-LIBRARY-STATISTICS (LIBC:CHANNEL STATS:<UVECTOR [2 FIX]>)
   <PROG ()
      <IFSYS ("VAX"
	      ;"Network - send request and read."
	      <COND (<REMOTE? .LIBC>
		     <1 .STATS ,COUNT-REQUEST>
		     <CHANNEL-OP .LIBC:NET WRITE-BUFFER .STATS 1>
		     <COND (<NET-UVECTOR-IN .LIBC .STATS 2> <RETURN .STATS>)
			   (T <RETURN %<>>)>)>)>
      ;"Local, access to counts and read."
      <CHANNEL-OP .LIBC:DSK ACCESS ,DIR-LERCNT>
      <COND (<CHANNEL-OP .LIBC:DSK READ-BUFFER .STATS 2> .STATS)>>>


;"L-LISTE --
  Effect:   Print the names of every entry or rentry in every package or
	    definitions in library denoted by LIBS to outchan.
  Modifies: OUTCHAN."

<DEFINE L-LISTE ("OPT" (LIBS:STRING ,PUBLIC-LIBRARY) (OUTCHAN:CHANNEL .OUTCHAN)
		 "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((STATE:<OR UVECTOR FALSE> <STACK <IUVECTOR 3>>))
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <SET STATE <LQ-MAP-RECORDS .LIBC .STATE>>>
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <REPEAT ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>)
		(S:STRING <STACK <ISTRING ,MAXSTRS>>))
	  <COND (<LQ-NEXT-RECORD .LIBC .STATE .RECORD>
		 <CRLF .OUTCHAN>
		 <LISTE .RECORD .S .OUTCHAN>)
		(T
		 <CLOSE .LIBC>
		 <CRLF .OUTCHAN>
		 <RETURN>)>>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"LISTE --
  Effect:   Print the name of RECORD and whether it represents a package or
	    definitions. The print all the entries followed by all the
	    rentries to OUTCHAN.
  Modifies: S, OUTCHAN.
  Requires: RECORD is properly formatted record as defined in LIBRARY.FORMAT,
	    size(S) >= MAXSTRS."

<DEFINE LISTE (RECORD:UVECTOR S:STRING OUTCHAN:CHANNEL "NAME" LISTE
	       "AUX" (RINFO:FIX <1 .RECORD>) (PRINTED:FIX 0) DELTAE:FIX ERCNT:FIX)
   <COND (<TESTBIT .RINFO ,RINFO-PKG?>      ;"PACKAGE or DEFINITIONS?"
	  <PRINTSTRING "Package:" .OUTCHAN>)
	 (T
	  <PRINTSTRING "Definitions:" .OUTCHAN>)>
   <INDENT-TO 14 .OUTCHAN>                  ;"Print module name."
   <PRINTSTRING .S .OUTCHAN <UV2SS <REST .RECORD> .S <BYTE0 .RINFO>>>
   <CRLF .OUTCHAN>
   <SET DELTAE <NTH .RECORD <+ <BYTE0 .RINFO> 3>>>
   <SET ERCNT <RHALF .DELTAE>>              ;"R/ENTRY count."
   <SET DELTAE <LHALF .DELTAE>>             ;"Distance to entry list."
   <PRINTSTRING "Entries:" .OUTCHAN>        ;"Print entries."
   <INDENT-TO 14 .OUTCHAN>
   <REPEAT ((COUNT:FIX .ERCNT) (DELTA:FIX .DELTAE)
	    ERTYPE:FIX NAMLEN:FIX)
      <COND (<0? .COUNT>
	     <COND (<0? .PRINTED>
		    <PRINTSTRING "None." .OUTCHAN>)>
	     <CRLF .OUTCHAN>
	     <RETURN>)>
      <SET ERTYPE <NTH .RECORD <+ .DELTA 1>>>
      <COND (<TESTBIT .ERTYPE ,ERTYP-ENTRY?>	;"Entry?"
	     <SET PRINTED <+ .PRINTED 1>>
	     <SET NAMLEN <UV2SS <REST .RECORD <+ .DELTA 1>> .S <BYTE0 .ERTYPE>>>
	     ;"Dont overflow right margin."
	     <COND (<G? <+ <M-HPOS .OUTCHAN> .NAMLEN 1> 79>
		    <CRLF .OUTCHAN>
		    <INDENT-TO 14 .OUTCHAN>)>
	     <PRINTSTRING .S .OUTCHAN .NAMLEN>
	     <PRINTSTRING " " .OUTCHAN>)>
      <SET COUNT <- .COUNT 1>>
      <SET DELTA <+ .DELTA <BYTE0 .ERTYPE> 1>>>
   <PRINTSTRING "Rentries:" .OUTCHAN>
   <INDENT-TO 14 .OUTCHAN>
   <COND (<==? .PRINTED .ERCNT>             ;"Print rentries if any."
	  <INDENT-TO 14 .OUTCHAN>
	  <PRINTSTRING "None." .OUTCHAN>
	  <CRLF .OUTCHAN>
	  <RETURN T .LISTE>)>
   <REPEAT ((COUNT:FIX <- .ERCNT .PRINTED>) (DELTA:FIX .DELTAE)
	    ERTYPE:FIX NAMLEN:FIX)
      <SET ERTYPE <NTH .RECORD <+ .DELTA 1>>>
      <COND (<TESTBIT .ERTYPE ,ERTYP-ENTRY? %<>>	;"Rentry?"
	     <SET NAMLEN <UV2SS <REST .RECORD <+ .DELTA 1>> .S <BYTE0 .ERTYPE>>>
	     ;"Dont overflow right margin."
	     <COND (<G? <+ <M-HPOS .OUTCHAN> .NAMLEN 1> 79>
		    <CRLF .OUTCHAN>
		    <INDENT-TO 14 .OUTCHAN>)>
	     <PRINTSTRING .S .OUTCHAN .NAMLEN>
	     <PRINTSTRING " " .OUTCHAN>
	     <COND (<0? <SET COUNT <- .COUNT 1>>>
		    <CRLF .OUTCHAN>
		    <RETURN>)>)>
      <SET DELTA <+ .DELTA <BYTE0 .ERTYPE> 1>>>
   T>

;"L-LISTP --
  Effect:   Print the names of all the packages and definitions in library
	    denoted by LIBS to OUTCHAN.
  Modifies: OUTCHAN."

<DEFINE L-LISTP ("OPT" (LIBS:STRING ,PUBLIC-LIBRARY) (OUTCHAN:CHANNEL .OUTCHAN)
		 "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((STATE:<OR UVECTOR FALSE> <STACK <IUVECTOR 3>>))
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <SET STATE <LQ-MAP-RECORDS .LIBC .STATE %<>>>>
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <CRLF .OUTCHAN>
       <REPEAT ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>)
		(NAME:STRING <STACK <ISTRING ,MAXSTRS>>) NAMLEN:FIX)
	  <COND (<LQ-NEXT-RECORD .LIBC .STATE .RECORD %<>>
		 <SET NAMLEN <UV2SS <REST .RECORD> .NAME <BYTE0 <1 .RECORD>>>>
		 <COND (<G? <+ <M-HPOS .OUTCHAN> .NAMLEN 1> 79>
			<CRLF .OUTCHAN>)>
		 <PRINTSTRING .NAME .OUTCHAN .NAMLEN>
		 <PRINTSTRING " " .OUTCHAN>)
		(T
		 <CLOSE .LIBC>
		 <CRLF .OUTCHAN>
		 <RETURN>)>>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"L-FINDATOM --
  Effect:   Every entry or rentry in library denoted by LIBS whose pname matches
	    SPECSTR is printed to OUTCHAN with associated type information.
	    * in SPECSTR denotes zero or more characters, all other characters
	    represent themselves. There is no quote for * (tough shit).
  Modifies: OUTCHAN."

<DEFINE L-FINDATOM (SPECSTR:STRING
		    "OPT" (LIBS:STRING ,PUBLIC-LIBRARY)
			  (OUTCHAN:CHANNEL .OUTCHAN)
		    "AUX" (LIBC:<OR CHANNEL FALSE> %<>))
   <UNWIND
    <PROG ((STATE:<OR UVECTOR FALSE> <STACK <IUVECTOR 3>>))
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <SET STATE <LQ-MAP-RECORDS .LIBC .STATE>>>
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <CRLF .OUTCHAN>
       <REPEAT ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>)
		(S:STRING <STACK <ISTRING ,MAXSTRS>>))
	  <COND (<LQ-NEXT-RECORD .LIBC .STATE .RECORD>
		 <MATCH-AND-PRINT .RECORD .SPECSTR .S .OUTCHAN>)
		(T
		 <CRLF .OUTCHAN>
		 <CLOSE .LIBC>
		 <RETURN>)>>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"MATCH-AND-PRINT --
  Effect:   Prints the names of any entrys or rentrys in RECORD which match
	    SPECSTR along with type information. The name of the package or
	    definitions is printed if there is at least one match.
  Modifies: S, OUTCHAN
  Requires: RECORD is properly formatted library record as defined in
	    LIBRARY.FORMAT, size(S) >= MAXSTRS."

<DEFINE MATCH-AND-PRINT (RECORD:UVECTOR SPECSTR:STRING S:STRING OUTCHAN:CHANNEL)
   <REPEAT ((DELTA:FIX <+ <LHALF <NTH .RECORD <+ <BYTE0 <1 .RECORD>> 3>>> 1>)
	    (ERCNT:FIX <RHALF <NTH .RECORD <+ <BYTE0 <1 .RECORD>> 3>>>)
	    (BLURB?:<OR ATOM FALSE> %<>) MATCH?:<OR ATOM FALSE> ERLEN:FIX)
      <COND (<==? .ERCNT 0> <RETURN>)>      ;"Until every name considered."
      <SET ERLEN <BYTE0 <NTH .RECORD .DELTA>>>	;"Pname length in words."
      <SET MATCH? %<>>                      ;"Non-false => found match."
      <REPEAT ((SHIFT:FIX 0) (WPTR:FIX 0) (WILD?:<OR STRING FALSE> %<>)
	       W:FIX B:CHARACTER)
	 <REPEAT ()                         ;"Find next non-wild (not *)."
	    <COND (<OR <EMPTY? .SPECSTR> <N==? <1 .SPECSTR> !\*>>
		   <RETURN>)
		  (T
		   <SET WILD? .SPECSTR>     ;"WILD? = SPECSTR rested to wild."
		   <SET SPECSTR <REST .SPECSTR>>)>>
	 <COND (<G? <SET SHIFT <+ .SHIFT 8>> 0>	;"All bytes in this word done?"
		<SET SHIFT -24>             ;"If all words done, set W to nulls."
		<COND (<G? <SET WPTR <+ .WPTR 1>> .ERLEN> <SET W 0>)
		      (T <SET W <NTH .RECORD <+ .DELTA .WPTR>>>)>)>
	 <SET B <CHAR <BYTE0 <LSH .W .SHIFT>>>>	;"Next char in pname."
	 <COND (<==? .B <CHAR 0>>           ;"Null => end of pname."
		<SET MATCH? <EMPTY? .SPECSTR>>	;"Must match every character."
		<RETURN>)
	       (<EMPTY? .SPECSTR>           ;"If SPECSTR is empty."
		<COND (.WILD?               ;"And last character is wild."
		       <COND (<==? <NTH .WILD? <LENGTH .WILD?>> !\*>
			      <SET MATCH? T>	;"Then we have a match."
			      <RETURN>)
			     (T
			      <SET SPECSTR .WILD?>	;"Otherwise we back up."
			      <SET SHIFT <- .SHIFT 8>>)>)	;"And reconsider."
		      (T                    ;"If there is no wild, then no match."
		       <RETURN>)>)
	       (<==? .B <1 .SPECSTR>>       ;"Does it match current character?"
		<SET SPECSTR <REST .SPECSTR>>)
	       (.WILD?                      ;"If not, back up if wild."
		<SET SPECSTR .WILD?>)
	       (T                           ;"Else there is no match."
		<RETURN>)>>
      <COND (.MATCH?                        ;"Did we find a match?"
	     <COND (<NOT .BLURB?>           ;"If this is the first."
		    <SET BLURB? T>          ;"Say what module this is."
		    <CRLF .OUTCHAN>
		    <PRINTSTRING "In " .OUTCHAN>
		    <COND (<TESTBIT <1 .RECORD> ,RINFO-PKG?>
			   <PRINTSTRING "package " .OUTCHAN>)
			  (T
			   <PRINTSTRING "definitions " .OUTCHAN>)>
		    <PRINTSTRING .S .OUTCHAN
				 <UV2SS <REST .RECORD> .S <BYTE0 <1 .RECORD>>>>
		    <PRINC !\: .OUTCHAN>
		    <CRLF .OUTCHAN>)>
	     <INDENT-TO 3 .OUTCHAN>
	     <PRINT-ENTRY <REST .RECORD <- .DELTA 1>> .S .OUTCHAN T>
	     <CRLF .OUTCHAN>)>
      <SET ERCNT <- .ERCNT 1>>
      <SET SPECSTR <TOP .SPECSTR>>
      <SET DELTA <+ .DELTA .ERLEN 1>>>>

;"L-LISTU --
  Effect:   Print the names of all the modules in library denoted by LIBS which
	    reference module named TARGETS.
  Modifies: OUTCHAN."

<DEFINE L-LISTU (TARGETS:STRING
		 "OPT" (LIBS:STRING ,PUBLIC-LIBRARY) (OUTCHAN:CHANNEL .OUTCHAN)
		 "AUX" (LIBC:<OR CHANNEL FALSE> %<>)
		       (TARGETU:UVECTOR <STACK <IUVECTOR <LENGTHW .TARGETS>>>))
   <UNWIND
    <PROG ((STATE:<OR UVECTOR FALSE> <STACK <IUVECTOR 3>>))
       <S2UV .TARGETS .TARGETU>             ;"TARGETS as binary string."
       <COND (<NOT <SET LIBC <LIBRARY-OPEN .LIBS>>>
	      <RETURN %<>>)
	     (<NOT <SET STATE <LQ-MAP-RECORDS .LIBC .STATE>>>
	      <CLOSE .LIBC>
	      <RETURN %<>>)>
       <REPEAT ((RECORD:UVECTOR <STACK <IUVECTOR ,MAXREC>>)
		(S:STRING <STACK <ISTRING ,MAXSTRS>>) UXICNT:FIX DELTA:FIX)
	  <COND (<LQ-NEXT-RECORD .LIBC .STATE .RECORD>
		 <SET UXICNT <NTH .RECORD <+ <BYTE0 <1 .RECORD>> 4>>>
		 <SET DELTA <+ <LHALF .UXICNT> 1>>	;"Distance to UXI list."
		 <SET UXICNT <RHALF .UXICNT>>	;"Length of UXI list."
		 <REPEAT (UXI:FIX COMP:FIX UXILEN:FIX)
		    <COND (<0? .UXICNT> <RETURN>)>
		    <SET UXILEN <BYTE0 <SET UXI <NTH .RECORD .DELTA>>>>
		    <SET COMP <UVCOMP .TARGETU <REST .RECORD .DELTA>
				      <LENGTH .TARGETU> .UXILEN>>
		    <COND (<==? .COMP 0>    ;"Match?"
			   <COND (<TESTBIT <1 .RECORD> ,RINFO-PKG?>
				  <PRINTSTRING "Package " .OUTCHAN>)
				 (T
				  <PRINTSTRING "Definitions " .OUTCHAN>)>
			   <PRINTSTRING .S .OUTCHAN	;"Module name."
					<UV2SS <REST .RECORD> .S
					       <BYTE0 <1 .RECORD>>>>
			   <COND (<TESTBIT .UXI ,UXI-USED?>
				  <PRINTSTRING " uses " .OUTCHAN>)
				 (<TESTBIT .UXI ,UXI-INCLUDED?>
				  <PRINTSTRING " includes " .OUTCHAN>)
				 (T
				  <PRINTSTRING " exports " .OUTCHAN>)>
			   <PRINTSTRING .TARGETS .OUTCHAN>
			   <CRLF .OUTCHAN>
			   <RETURN>)
			  (<==? .COMP 1>    ;"Less than?"
			   <SET UXICNT <- .UXICNT 1>>
			   <SET DELTA <+ .DELTA .UXILEN 1>>)
			  (T                ;"Greater, we can stop looking."
			   <RETURN>)>>)
		(T
		 <CLOSE .LIBC>
		 <RETURN>)>>>
    <COND (<AND .LIBC <CHANNEL-OPEN? .LIBC>> <CLOSE .LIBC>)>>>

;"LQ-MAP-RECORDS --
  Effect:   Sets up STATE for mapping over every record in LIBC.
  Returns:  STATE if successful, FALSE otherwise.
  Modifies: STATE, LIBC
  Note:     If LIBC is NETWORK, the MAP-RECORDS request is made followed
	    by a request for the next record (with short bit determined
	    by value of LONG?. The request word is placed into STATE for
	    following requests."

<DEFINE LQ-MAP-RECORDS (LIBC:CHANNEL STATE:UVECTOR
			"OPT" (LONG?:<OR ATOM FALSE> T))
   <PROG ()
      <IFSYS ("VAX"
	      ;"Network => MAP-RECORDS. If that succeeds then NEXT-RECORD."
	      <COND (<REMOTE? .LIBC>
		     <1 <SET STATE <REST .STATE>> ,MAP-RECORDS-REQUEST>
		     <CHANNEL-OP .LIBC:NET WRITE-BUFFER .STATE 1>
		     <SET STATE <REST .STATE>>
		     <COND (<AND <GET-REMOTE-RESPONSE .LIBC .STATE>
				 <==? <1 .STATE> ,ACK>>
			    ;"Request next and set up for following call."
			    <1 .STATE
			       <COND (.LONG? ,MAP-NEXT-RECORD)
				     (T <ORB ,MAP-NEXT-RECORD
					     ,MAP-SHORT-RECORD>)>>
			    <CHANNEL-OP .LIBC:NET WRITE-BUFFER .STATE 1>
			    <RETURN .STATE>)
			   (T <RETURN %<>>)>)>)>
      ;"Local library."
      <RETURN <MAP-RECORDS .LIBC .STATE>>>>

;"LQ-NEXT-RECORD --
  Effect:   Fetches the next record from LIBC in map sequence if there is one.
  Modifies: LIBC, STATE, RECORD
  Returns:  T if record was read into RECORD, else FALSE.
  Requires: size(RECORD) >= size(record), STATE is descriptor created by
	    LQ-MAP-RECORDS and modified only by LQ-NEXT-RECORD.
  Note:     LONG? has no effect if library is network because that has
	    already been taken into account in STATE. The next record
	    is requested as soon as a record is received."

<DEFINE LQ-NEXT-RECORD (LIBC:CHANNEL STATE:UVECTOR RECORD:UVECTOR
			"OPT" (LONG?:<OR ATOM FALSE> T))
   <PROG ()
      <IFSYS ("VAX"
	      ;"Network => record waiting. Request next after reception."
	      <COND (<REMOTE? .LIBC>
		     <COND (<GET-REMOTE-RECORD .LIBC .RECORD>
			    ;"Request next record."
			    <CHANNEL-OP .LIBC:NET WRITE-BUFFER .STATE>
			    <RETURN>)
			   (T <RETURN %<>>)>)>)>
      ;"Local."
      <BIND ((NEXT:<OR FALSE FIX> <NEXT-RECORD .LIBC .STATE>))
	 <RETURN <AND .NEXT <GET-ADDRESSED-RECORD .NEXT .LIBC .RECORD .LONG?>>>>>>

;"LQ-GET-RECORD --
  Effect:   Fetch record named NAME into RECORD from LIBC.
  Modifies: RECORD, LIBC
  Returns:  T if record was fetched, otherwise FALSE.
  Requires: If LIBC is network channel, no request has been made yet
	    (the server will hang up when this request is processed)."

<DEFINE LQ-GET-RECORD (NAME:STRING LIBC:CHANNEL RECORD:UVECTOR
		       "OPT" (LONG?:<OR ATOM FALSE> T))
   <PROG ()
      <IFSYS ("VAX"
	      ;"Network => send record request with name."
	      <COND (<REMOTE? .LIBC>
		     <1 .RECORD
			<ORB <LSH <LENGTH .NAME> 8> ,RECORD-REQUEST
			     <COND (.LONG? 0) (T ,RECORD-SHORT)>>>
		     <CHANNEL-OP .LIBC:NET WRITE-BUFFER .RECORD 1>
		     <CHANNEL-OP .LIBC:NET WRITE-BUFFER .NAME>
		     <COND (<GET-REMOTE-RECORD .LIBC .RECORD> <RETURN>)
			   (T <RETURN %<>>)>)>)>
      ;"Local."
      <RETURN <GET-NAMED-RECORD .NAME .LIBC .RECORD .LONG?>>>>

;"UVCOMP --
  Effect:  Compare two binary strings (8-BIT ASCII UVECTORS). L1, L2 is
	   number of valid words in UV1, UV2 respectively.
  Returns: 1 if UV1 sorts before UV2. 0 if UV1 matches UV2. -1 if
	   UV1 sorts after UV2.
  Note:   NULL byte is interpreted as end of string."

<DEFINE UVCOMP (UV1:UVECTOR UV2:UVECTOR
		"OPT" (L1:FIX <LENGTH .UV1>) (L2:FIX <LENGTH .UV2>))
   <REPEAT (W1:FIX W2:FIX)
      <COND (<==? <SET W1 <1 .UV1>> <SET W2 <1 .UV2>>>
	     <SET L1 <- .L1 1>>
	     <SET L2 <- .L2 1>>
	     <COND (<OR <==? .L1 0> <==? .L2 0>>
		    <COND (<==? .L1 0>
			   <COND (<==? .L2 0> <RETURN 0>) (T <RETURN -1>)>)
			  (T <RETURN 1>)>)
		   (T
		    <SET UV1 <REST .UV1>>
		    <SET UV2 <REST .UV2>>)>)
	    (T
	     <BIND (B1:FIX B2:FIX)
		<COND (<N==? <SET B1 <BYTE3 .W1>> <SET B2 <BYTE3 .W2>>>)
		      (<N==? <SET B1 <BYTE2 .W1>> <SET B2 <BYTE2 .W2>>>)
		      (<N==? <SET B1 <BYTE1 .W1>> <SET B2 <BYTE1 .W2>>>)
		      (T
		       <SET B1 <BYTE0 .W1>>
		       <SET B2 <BYTE0 .W2>>)>
		<COND (<L? .B1 .B2> <RETURN -1>) (T <RETURN 1>)>>)>>>

<ENDPACKAGE>
