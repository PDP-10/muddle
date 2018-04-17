<PACKAGE "COMFIL">

<ENTRY FILE-COMPILE STATUS REDO PRECOMPILED DISOWN MACRO-COMPILE
       REHASH-ALL MACRO-FLUSH NO-TEMP-FILE INS-LIST INS-FIX ACCESS-LIST
       ERRORS-OCCURED>

<USE "FILE-INDEX" "HASH" "CDRIVE" "COMPDEC" "ITIME" "MIMC-GRDUMP" "TTY">

<NEWTYPE ACCESS-LIST LIST '<<PRIMTYPE LIST> ANY FIX FIX>>

<NEWTYPE INS-LIST LIST>

<GDECL (ALL-OUT) LIST>

<SETG STATUS-LINE <>>

<SETG PACKAGE-OBLIST <MOBLIST PACKAGE>>

<SET NO-TEMP-FILE <>>

<SET PACKAGE-MODE <>>

<SET REDO ()>

<SET CAREFUL T>

<SET REASONABLE T>

<SET DEBUG-COMPILE T>

<SET HAIRY-ANALYSIS T>

<SETG FF <ASCII 12>>

<SETG GC-COUNT 0>

<SET MACRO-FLUSH <>>

<SET MACRO-COMPILE T>

<SETG REHASH-ALL <>>

"Stuff for status line"

<SETG STATE-TITLE "State ">

<MSETG H-STATE <LENGTH ,STATE-TITLE>>

<MSETG H-STATE-LN 5>

<SETG STATE-FCN " Fcn ">

<MSETG H-FCN <+ <LENGTH ,STATE-FCN> ,H-STATE-LN ,H-STATE>>

<MSETG H-FCN-LN 10>

<SETG STATE-PHASE " Phase ">

<MSETG H-PHASE <+ ,H-FCN ,H-FCN-LN <LENGTH ,STATE-PHASE>>>

<MSETG H-PHASE-LN 4>

<SETG STATE-CPU " Cpu ">

<MSETG H-CPU <+ ,H-PHASE ,H-PHASE-LN <LENGTH ,STATE-CPU>>>

<MSETG H-CPU-LN 6>

<SETG STATE-REAL " Real ">

<MSETG H-REAL <+ ,H-CPU ,H-CPU-LN <LENGTH ,STATE-REAL>>>

<MSETG H-REAL-LN 5>

<MSETG H-RATIO <+ ,H-REAL ,H-REAL-LN 1>>

<MSETG H-RATIO-LN 7>

<MSETG H-RE-ANA <+ ,H-RATIO ,H-RATIO-LN 1>>

<BLOCK (<ROOT>)>
IMPORT-PM!-
DEFINITION-MODULE!-
PROGRAM-MODULE!-
END-MODULE!-
INCLUDE-DEFINITIONS!-
PMEXPORT!-
INCLUDE-WHEN!-
IMPORT-WHEN!-
ZSECTION!-
ZZSECTION!-
ZPACKAGE!-
ZZPACKAGE!-
ZENDPACKAGE!-
ZENDSECTION!-
ENDSECTION!-
<ENDBLOCK>

<DEFINE FILE-COMPILE FCEX (INFILE
			   "OPTIONAL" (OUTFILE "") (NM2 "MUD")
			   "AUX" (STARCPU <FIX <+ <TIME> 0.5>>)
				 (STARR <RTIME>)
				 INCH OUTCH (TEMPCH <>) TEM (NEW-INDEX ())
				 X (PRE-INDEX ())
				 (SRC-CHAN #FALSE ())
				 (NO-TEMP-FILE .NO-TEMP-FILE)
				 ATOM-LIST OC FILE-DATA GC-HANDLER
				 (OBLIST .OBLIST) TMP ATL PRECH
				 (OUTCHAN .OUTCHAN) (NO-BQ <>)
				 (REDO .REDO) NM1 SNM DEV (GCTIME 0.0)
				 (I/O-TIME 0.0) (ANY-MIMAS? <>)
				 (REAL-NM2 .NM2))
	#DECL ((FCEX) <SPECIAL FRAME> (INFILE OUTFILE) STRING (REDO) LIST
	       (OUTCHAN) <SPECIAL CHANNEL> (INCH OC) <OR FALSE CHANNEL>
	       (TIXCH TEMPCH SRC-CHAN) <SPECIAL <OR CHANNEL FALSE>>
	       (OUTCH) <OR FALSE CHANNEL> (STARCPU STARR ATNUM) <SPECIAL FIX>
	       (ATOM-LIST ATL) <SPECIAL <LIST [REST <OR LIST ATOM>]>>
	       (FILE-DATA) <LIST <LIST [REST ATOM]> ATOM> (X) FLOAT
	       (REDONE) <LIST [REST LIST]> (GCTIME I/O-TIME) <SPECIAL FLOAT>
	       (NO-BQ) <SPECIAL ANY> (NM1 NM2 DEV SNM) <SPECIAL STRING>
	       (PRE-INDEX NEW-INDEX) <LIST [REST ACCESS-LIST]>
	       (OBLIST) <SPECIAL ANY>)
	<SETG ERRORS-OCCURED <>>
	<SETG ALL-OUT ()>
	<COND (<NOT <SET TEM <FILE-EXISTS? .INFILE>>>
	       <RETURN .TEM .FCEX>)>
	<SET INCH <CHANNEL-OPEN PARSE .INFILE>>
	<PRINSPEC "Input from " .INCH>
	<SET NM1 <CHANNEL-OP .INCH NM1>>
	;<SET SNM <CHANNEL-OP .INCH SNM>>
	;<SET DEV <CHANNEL-OP .INCH DEV>>
	<CLOSE .INCH>
	<SET NM2 "MIMA">
	<SET OUTCH <CHANNEL-OPEN PARSE .OUTFILE>>
	<PRINSPEC "Output to " .OUTCH>
	<COND (<NOT .NO-TEMP-FILE>
	       <REPEAT ((NM2 "TEMP")) #DECL ((NM2) <SPECIAL STRING>)
		<COND (<SET TEMPCH <OPEN "PRINT" "">>
		       <RETURN>)>
		<ERROR .TEMPCH "ERRET ANYTHING TO RETRY">>
	       <PRINSPEC "Temporary output to " .TEMPCH>)>
	<COND (<AND <ASSIGNED? PRECOMPILED>
		    .PRECOMPILED>
	       <REPEAT (X)
		       <COND (<OR <AND <ASSIGNED? PRECH> .PRECH>
				  <AND <SET PRECH <OPEN "READ" .PRECOMPILED>>
				       <PRINSPEC "Will load precompile from "
						 .PRECH>>>
			      <RETURN>)
			     (<=? <UNAME> "OPERATOR">
			      ; "Don't call error if running in batch mode"
			      <PRINCTHEM "Can't load precompilation from "
					 <2 .PRECH> ":  "
					 <1 .PRECH>
					 ,CRET>
			      <RETURN>)
			     (<SET X <ERROR "Cant load precompilation"
				            .PRECH
		"ERRET non-false to retry, false to ignore precompilation">>
			      <COND (<TYPE? .X STRING>
				     <SET PRECOMPILED .X>)>)
			     (ELSE <RETURN>)>>)>
	<COND (<NOT .CAREFUL> <PRINCTHEM "Bounds checking disabled." ,CRET>)>
	<COND
	 (<SET OC
	       <DO-AND-CHECK
		"Writing record "
		"RECORD"
		DISOWN
		.INCH
		.OUTCH
		.SRC-CHAN>>
	  <PRINCTHEM "Toodle-oo!" ,CRET>
	  <SETG COMPCHAN <SET OUTCHAN .OC>>
	  <PRINSPEC "Compilation record for: " .INCH>
	  <PRINSPEC "Output file:  " .OUTCH>)>
	<CLOSE .OUTCH>
	<SETG GC-COUNT 0>
	<SET GC-HANDLER <ON <HANDLER "GC" ,COUNT-GCS 10>>>
	<SET X <TIME>>
	<COND (,STATUS-LINE <UPDATE-STATUS "Load" <> <> <>>)>
	<SET FILE-DATA <FIND-DEFINE-LOAD .INFILE .REAL-NM2>>
	<SET I/O-TIME <- <TIME> .X>>
	<COND (,STATUS-LINE <UPDATE-STATUS "Ordr" <> <> <>>)>
	<PRINCTHEM "File loaded." ,CRET>
	<SET ATOM-LIST
	     <MAPF ,LIST
		   <FUNCTION (ATM) 
			   <COND (<OR <TYPE? ,.ATM FUNCTION>
				      <AND <TYPE? ,.ATM MACRO>
					   <NOT <EMPTY? ,.ATM>>
					   <TYPE? <1 ,.ATM> FUNCTION>>>
				  .ATM)
				 (ELSE <MAPRET>)>>
		   <1 .FILE-DATA>>>
	<COND (<NOT <EMPTY? <CHTYPE .REDO LIST>>>
	       <COND (.PACKAGE-MODE
		      <MAPR <>
			    <FUNCTION (L)
				 #DECL ((L) <LIST [REST ATOM]>)
				 <PUT .L 1 <PACK-FIX .PACKAGE-MODE <1 .L>>>>
			    <CHTYPE .REDO LIST>>)>
	       <PRINCTHEM "Explicitly Recompiling " .REDO ,CRET>)>
	<COND
	 (<AND <ASSIGNED? PRECOMPILED> .PRECOMPILED .PRECH>
	  <SET X <TIME>>
	  <SET PRE-INDEX ()>
	  <COND (,STATUS-LINE <UPDATE-STATUS "PCld" <> <> <>>)>
	  <REPEAT (THING OP ACC NM (HASH-CODE <>))
		  <SET ACC <ACCESS .PRECH>>
		  <SET THING <READ .PRECH '<RETURN>>>
		  <COND
		   (<AND <TYPE? .THING FORM>
			 <NOT <EMPTY? .THING>>
			 <TYPE? <SET OP <1 .THING>> ATOM>
			 <OR <=? <SPNAME .OP> "FCN"> <=? <SPNAME .OP> "GFCN">>>
		    <SKIP-MIMA .PRECH <SET NM <2 .THING>>>
		    <COND (<AND <NOT <GASSIGNED? .NM>>
				<NOT <MEMBER "ANONF" <SPNAME .NM>>>>
			   <AGAIN>)>
		    <COND (<AND <NOT <EMPTY? .ATOM-LIST>>
				<NOT <MEMQ .NM .REDO>>
				<NOT <AND <GASSIGNED? .NM>
					  .HASH-CODE
					  <N==? .HASH-CODE <HASH ,.NM>>>>>
			   <SET PRE-INDEX
				(<CHTYPE (.NM .ACC <ACCESS .PRECH>
					  <COND (.HASH-CODE)
						(<GASSIGNED? .NM>
						 <HASH ,.NM>)>)
					  ACCESS-LIST>
				 !.PRE-INDEX)>
			   <PUTPROP .NM RSUB-DEC <3 .THING>>
			   <COND (<==? .NM <1 .ATOM-LIST>>
				  <SET ATOM-LIST <REST .ATOM-LIST>>
				  <SET ANY-MIMAS? T>)
				 (ELSE
				  <REPEAT ((X .ATOM-LIST))
					  #DECL ((X) LIST)
					  <COND (<EMPTY? <REST .X>> <RETURN>)>
					  <COND (<==? <2 .X> .NM>
						 <PUTREST .X <REST .X 2>>
						 <SET ANY-MIMAS? T>
						 <RETURN>)>
					  <SET X <REST .X>>>)>)>
		    <COND (<AND .HASH-CODE <NOT <GASSIGNED? .NM>>>
			   <AGAIN>)>)
		   (<AND <TYPE? .THING WORD> <NOT ,REHASH-ALL>>
		    <SET HASH-CODE <CHTYPE .THING FIX>>
		    <AGAIN>)
		   (<NOT <AND <TYPE? .THING FORM>
			      <NOT <EMPTY? .THING>>
			      <NOT <MEMQ <1 .THING>
					 '[PACKAGE RPACKAGE ENDPACKAGE ENTRY
					   USE-WHEN USE-DEBUG INCLUDE
					   DEFINITIONS END-DEFINITIONS
					   DROP L-UNUSE
					   RENTRY USE USE-DEFER USE-TOTAL
					   IMPORT-PM!- DEFINITION-MODULE!-
					   PROGRAM-MODULE!- END-MODULE!-
					   INCLUDE-DEFINITIONS!- PMEXPORT!-
					   INCLUDE-WHEN!- IMPORT-WHEN!-
					   BLOCK ENDBLOCK
					   ZSECTION!-  ZZSECTION!-  ZPACKAGE!-
					   ZZPACKAGE!-  ZENDPACKAGE!-
					   ZENDSECTION!- ENDSECTION!- ]>>>>
		    ; "Don't eval most things in precompiled, since
		       they only screw things up."
		    <EVAL .THING>)>
		  <SET HASH-CODE <>>>
	  <PRINCTHEM "Precompilation loaded" ,CRET>
	  <COND (<NOT .ANY-MIMAS?>
		 <PRINCTHEM
		  "No compiled functions from PRECOMPILATION used?" ,CRET>)>
	  <RESET .PRECH>
	  <SET I/O-TIME <+ .I/O-TIME <- <TIME> .X>>>)>
	<COND (<EMPTY? .ATOM-LIST>
	       <PRINCTHEM "No DEFINEd functions in this file." ,CRET>
	       <SET ATOM-LIST ()>)
	      (ELSE <SET ATOM-LIST <GETORDER !<SET ATL .ATOM-LIST>>>)>
	<PRINCTHEM "Functions ordered." ,CRET>
	<SET ATOM-LIST <LINEARIZE .ATOM-LIST>>
	<COND (.REASONABLE
	       <SET ATOM-LIST
		    <MAPF ,LIST
			  <FUNCTION (A)
			       <COND (<MEMQ .A .ATL> .A)
				     (ELSE <MAPRET>)>>
			  .ATOM-LIST>>)>
	<MAPF <>
	      <FUNCTION (AL "AUX" OUTL ACC) 
		      #DECL ((AL) <SPECIAL ATOM> (OUTL) <OR FALSE LIST>)
		      <SET OBLIST <FIND-OBL .AL <2 .FILE-DATA>>>
		      <COND (<SET OUTL
				  <COMPILE
					 .AL
					 .CAREFUL
					 .REASONABLE
					 .HAIRY-ANALYSIS
					 .DEBUG-COMPILE>>
			     <BUFOUT .OUTCHAN>
			     <COND (<NOT .NO-TEMP-FILE>
				    <SET X <TIME>>
				    <SET ACC <ACCESS .TEMPCH>>
				    <DUMP-CODE .OUTL .TEMPCH .OBLIST>
				    <SET NEW-INDEX
					 (<CHTYPE (.AL .ACC <ACCESS .TEMPCH>
						   <HASH ,.AL>)
						  ACCESS-LIST> !.NEW-INDEX)>
				    <SET I/O-TIME <+ .I/O-TIME <- <TIME> .X>>>)
				   (ELSE
				    <SETG ALL-OUT ((.AL .OUTL <HASH ,.AL>)
						   !,ALL-OUT)>)>)
			    (ELSE
			     <SETG ERRORS-OCCURED T>
			     <BUFOUT .OUTCHAN>)>>
	      .ATOM-LIST>
	<COND (,STATUS-LINE <UPDATE-STATUS "Writ" "None" <> <>>)>
	<COND (<NOT .NO-TEMP-FILE>
	       <SET TMP <CHANNEL-OP .TEMPCH NAME>>
	       <CLOSE .TEMPCH>
	       <SET TEMPCH <OPEN "READ" .TMP>>
	       <MAPF <>
		     <FUNCTION (L)
			  <SETG <1 .L> .L> <PUT .L 1 .TEMPCH>> .NEW-INDEX>)
	      
	      (ELSE
	       <MAPF <> <FUNCTION (A) #DECL ((A) LIST)
			     <SETG <1 .A>
				   <CHTYPE (<3 .A> !<CHTYPE <2 .A> LIST>)
					   INS-LIST>>> ,ALL-OUT>)>
	<COND (<AND <ASSIGNED? PRECOMPILED>
		    .PRECOMPILED>
	       <PROG ((PREV <>) PN) #DECL ((PREV) <OR FALSE ACCESS-LIST>)
		     <MAPF <>
			   <FUNCTION (L "AUX" (ATM <1 .L>))
				#DECL ((L) ACCESS-LIST)
				<COND (<AND <NOT <GASSIGNED? .ATM>>
					    <MEMBER <SPNAME .PN>
						    <SPNAME .ATM>>>
				       <PUTREST <REST .L 3> (.PREV)>
				       <COND (<AND <NOT <4 .L>> <4 .PREV>>
					      <PUT .L 4 <4 .PREV>>
					      <PUT .PREV 4 <>>)>
				       <SETG .PN .L>)>
				<SETG .ATM .L>
				<SET PN .ATM>
				<PUT .L 1 .PRECH>
				<SET PREV .L>>
			   .PRE-INDEX>>)>
	<SET NO-BQ T>
	<SET X <TIME>>
	<MIMC-GROUP-DUMP .OUTFILE <2 .FILE-DATA> .TEMPCH>
	<SET I/O-TIME <+ .I/O-TIME <- <TIME> .X>>>
	<SET NO-BQ <>>
	<PRINTSTATS>
	<OFF .GC-HANDLER>
	<SETG COMPCHAN ,OUTCHAN>
	<COND (<AND <ASSIGNED? TEMPCH> <TYPE? .TEMPCH CHANNEL>>
	       <CLOSE .TEMPCH>
	       <DELFILE .TMP>)>
	<COND (<AND <ASSIGNED? DISOWN> .DISOWN>
	       "Compilation completed. Your patience is godlike.")
	      (ELSE "Compilation completed. Your patience is godlike.")>>

<DEFINE PACK-FIX (PCK ATM
		  "AUX" (S <PNAME .ATM>) (WIN <>)
			(PO <LOOKUP .PCK ,PACKAGE-OBLIST>))
	<AND .PO <SET PO ,.PO>>
	<MAPF <>
	      <FUNCTION (O) 
		      #DECL ((O) OBLIST)
		      <AND <SET WIN <LOOKUP .S .O>> <MAPLEAVE>>>
	      <CHTYPE .PO LIST>>
	<COND (.WIN) (.PO <INSERT .S <1 .PO>>) (ELSE .ATM)>>

<DEFINE LINEARIZE (ATOM-LIST) #DECL ((ATOM-LIST) LIST)
     <REPEAT ((L <SET ATOM-LIST (START !.ATOM-LIST)>) (LL <REST .L>))
	     #DECL ((L LL) LIST)
	     <COND (<EMPTY? .LL> <RETURN <REST .ATOM-LIST>>)
		   (<TYPE? <1 .LL> LIST>
		    <PUTREST .L <1 .LL>>
		    <PUTREST <SET L <REST .L <- <LENGTH .L> 1>>>
			     <SET LL <REST .LL>>>)
		   (ELSE <SET LL <REST <SET L .LL>>>)>>>


<DEFINE PRINTSTATS ("AUX" (TSTARCPU <- <FIX <+ 0.5 <TIME>>>
				       <CHTYPE .STARCPU FIX>>)
			  (TSTARR <- <RTIME> <CHTYPE .STARR FIX>>))
	#DECL ((STARCPU STARR TSTARCPU TSTARR) FIX)
	<COND (<GASSIGNED? REFERENCED>
	       <PRINCTHEM ,CRET "Called unknown atoms:" ,CRET>
	       <REPEAT ((L:LIST ,REFERENCED))
	         <COND (<EMPTY? .L> <RETURN>)>
		 <PRINCTHEM <1 .L> ": "
			    <COND (<==? <2 .L> 1> "once")
				  (T <2 .L>)>
			    <COND (<==? <2 .L> 1> "")
				  (T " times")>
			    ,CRET>
		 <SET L <REST .L 2>>>)>
	<COND (<L? .TSTARR 0>		;"Went over midnight."
		<SET TSTARR <+ .TSTARR %<* 24 60 60>>>)>
	<PRINCTHEM ,CRET ,CRET "Total time used is" ,CRET ,TAB>
	<PRINTIME .TSTARCPU "CPU time,">
	<PRINCTHEM ,CRET ,TAB>
	<PRINTIME <FIX .GCTIME> "garbage collector CPU time,">
	<PRINCTHEM ,CRET ,TAB>
	<PRINTIME <FIX .I/O-TIME> "I/O time.">
	<PRINCTHEM ,CRET ,TAB>
	<PRINTIME .TSTARR "real time.">
	<PRINCTHEM ,CRET
		"CPU utilization is " <* 100.0 </ .TSTARCPU <FLOAT .TSTARR>>>
		"%." ,CRET
		"Number of garbage collects = " ,GC-COUNT ,CRET>>

<DEFINE PRINTIME (AMT STR) #DECL((AMT) FIX)
	<COND (<G? .AMT %<* 60 60>>
		<PRINCTHEM </ .AMT %<* 60 60>> " hours ">
		<SET AMT <MOD .AMT %<* 60 60>>>)>
	<COND (<G? .AMT 60>
		<PRINCTHEM </ .AMT 60> " min. ">
		<SET AMT <MOD .AMT 60>>)>
	<PRINCTHEM .AMT " sec. " .STR>>

<DEFINE RTIME () <QTIME <ITIME>>> 

<DEFINE STATUS ("AUX" FL PL ATOM-LIST-L AL-L (OUTCHAN .OUTCHAN))
	#DECL ((ATOM-LIST-L) LIST (FL PL) FIX (OUTCHAN) <SPECIAL CHANNEL>)
	<COND  (<AND <ASSIGNED? ATOM-LIST> <ASSIGNED? AL>>
		<SET FL <LENGTH <SET ATOM-LIST-L <CHTYPE .ATOM-LIST LIST>>>>
		<SET PL <- .FL <LENGTH <MEMQ <SET AL-L .AL> .ATOM-LIST>>>>
		<PRINCTHEM ,CRET "Running: " .PL " finished, working on ">
		<PRIN1 .AL-L>
		<PRINCTHEM ", and " <- .FL .PL 1> " to go.">
		<PRINTSTATS>)
	      (<AND <ASSIGNED? STARCPU> <ASSIGNED? STARR>>
		<COND (<NOT <ASSIGNED? FILE-DATA>>
			<PRINC "
Files not yet loaded.">
			<PRINTSTATS>)
		      (<NOT <ASSIGNED? ATOM-LIST>>
			<PRINC"
Files loaded, but functions not yet ordered for compilation.">
			<PRINTSTATS>)
		      (ELSE <PRINC "
Almost done, just cleaning up and writing out final file.">
			<PRINTSTATS>)>)
	      (ELSE <PRINCTHEM ,CRET "I'm not running." ,CRET>)>>

<DEFINE COUNT-GCS (IGN TI WHICH)
	<SETG GC-COUNT <+ <CHTYPE ,GC-COUNT FIX> 1>>
	<AND <ASSIGNED? GCTIME>
	     <SET GCTIME <+ <CHTYPE .GCTIME FLOAT> <CHTYPE .TI FLOAT>>>>>

<GDECL (GC-COUNT) FIX>



<SETG CRET "
">

<MANIFEST NOT-COMPILE-TIME>


<SETG TAB <ASCII 9>>

<MANIFEST TAB>

<DEFMAC PRINCTHEM ("ARGS" A) #DECL ((A) LIST)
	<FORM PROG ()
	      !<MAPF ,LIST <FUNCTION (X)
				     <FORM PRINC .X>>
		     .A>>>

<DEFINE FIND-DEFINE-LOAD (FNM NM2 "AUX" GRP (OLD-FLOAD ,FLOAD))
	#DECL ((NM2) <SPECIAL STRING>)
	<SET GRP <GROUP-LOAD .FNM>>
	(<1 <GET-ATOMS ..GRP>> .GRP)>

<DEFINE GET-ATOMS (L "AUX" (L1 .L) (AL ()) (LL ()) TEM TT MCR ATM VAL) 
	#DECL ((L AL L1 LL) LIST (TT) FORM)
	<REPEAT ()
		<SET MCR <>>
		<COND (<EMPTY? .L1> <RETURN (.AL .L)>)
		      (<AND <TYPE? <1 .L1> FORM>
			    <NOT <EMPTY? <SET TT <1 .L1>>>>>
		       <COND (<OR <==? <1 .TT> DEFINE>
				  <SET MCR <==? <1 .TT> DEFMAC>>>
			      <COND (<AND .MCR .MACRO-FLUSH>
				     <PUT .L1 1 <FORM DEFINE <ATOM "A"> ()>>)
				    (ELSE
				     <PUT .L1 1 <FORM <1 .TT> <2 .TT> <>>>)>
			      <SET ATM <GETPROP <2 .TT> VALUE '<2 .TT>>>
			      <OR <AND .MCR <NOT .MACRO-COMPILE>>
				  <SET AL (.ATM !.AL)>>)>)>
		<SET L1 <REST .L1>>>>

<DEFINE NEW-ERROR (IGN FRM "TUPLE" TUP "EXTRA" (OUTCHAN ,COMPCHAN))
	#DECL ((TUP) TUPLE (OUTCHAN) <SPECIAL ANY>)
	<COND (<AND <NOT <EMPTY? .TUP>> <==? <1 .TUP> CONTROL-G!-ERRORS>>
		<INT-LEVEL 0>
		<OFF ,ERROR-HANDLER>
		;"HAVE TO NEST TO TURN HANDLER ON AND OFF"
		<ERROR !.TUP>
		<ON ,ERROR-HANDLER>
		<ERRET T .FRM>)
	      (ELSE <PRINC"
***********************************************************
*        ERROR ERROR ERROR ERROR ERROR ERROR ERROR        *
***********************************************************

to wit,">
		<MAPF <> ,PRINT .TUP>
		<PRINC "
Compilation totally aborted.
Status at death was:

">
		<STATUS>)>>

<SETG COMPCHAN ,OUTCHAN>

<COND (<GASSIGNED? NEW-ERROR>
       <SETG ERROR-HANDLER <HANDLER "ERROR" ,NEW-ERROR 100>>)>

<DEFINE PRINSPEC (STR CHAN) #DECL((STR) STRING (CHAN) CHANNEL)
	<PRINCTHEM .STR <CHANNEL-OP .CHAN NAME> ,CRET>>
	

<DEFINE DO-AND-CHECK (STR1 STR2 ATM INCH OUTCH FOOCH "AUX" NEW-CHAN TSTR)
	<COND (<AND <ASSIGNED? .ATM> ..ATM>			;"Do it?"
	       <PRINC .STR1>
	       <COND				;"Yes. Get the channel."
		(<TYPE? ..ATM CHANNEL>		;"Output channel already open."
		 <SET NEW-CHAN ..ATM>)
		(<TYPE? ..ATM STRING>		;"Name of output file given."
		 <COND (<FILE-EXISTS? ..ATM> <DELFILE ..ATM>)>
		 <COND (<SET NEW-CHAN <OPEN "PRINT" ..ATM>>)
		       ;"So try opening it."
		       (ELSE				;"Bad name."
			<CLOSE .INCH>
			<CLOSE .OUTCH>
			<AND .FOOCH <CLOSE .FOOCH>>
			<RETURN .NEW-CHAN .FCEX>)>)
		(ELSE
		 <PROG ((NM1 <CHANNEL-OP .INCH NM1>) (NM2 .STR2))
		       #DECL ((NM1 NM2) <SPECIAL STRING>)
		       <COND (<FILE-EXISTS? ""> <DELFILE "">)>
		       <COND (<SET NEW-CHAN <OPEN "PRINT" "">>)
			     (ELSE
			      <CLOSE .INCH>
			      <CLOSE .OUTCH>
			      <AND .FOOCH <CLOSE .FOOCH>>
			      <RETURN .NEW-CHAN .FCEX>)>>
		 <PRINSPEC "on " .NEW-CHAN>
		 .NEW-CHAN)>)>>

<DEFINE FLUSH-COMMENTS ("AUX" (A <ASSOCIATIONS>) B)
	<REPEAT ()
		<SET B <NEXT .A>>
		<COND (<==? <INDICATOR .A> COMMENT>
		       <PUTPROP <ITEM .A> COMMENT>)>
		<COND (<NOT <SET A .B>> <RETURN>)>>>


"GETORDER FUNCTIONS"

<DEFINE CHECK (ATM)
	#DECL ((ATM) <UNSPECIAL ATOM>)
	<AND <TYPE? .ATM ATOM>
	     <GASSIGNED? .ATM>
	     <OR <TYPE? ,.ATM FUNCTION>
		 <TYPE? ,.ATM MACRO>>>>

<DEFINE PREV (LS SUBLS)
	#DECL ((LS SUBLS) <UNSPECIAL LIST> (VALUE) LIST)
	<REST .LS <- <LENGTH .LS> <LENGTH .SUBLS> 1>>>

<DEFINE SPLOUTEM (FL OU)
	#DECL ((FL) <UNSPECIAL LIST> (OU) <UNSPECIAL ATOM>)
	<REPEAT (TEM)
		#DECL ((TEM) <UNSPECIAL <PRIMTYPE LIST>>)
		<COND (<EMPTY? .FL> <RETURN T>)
		      (<SET TEM <MEMQ .OU <1 .FL>>>
		       <COND (<==? <1 .FL> .TEM> <PUT .FL 1 <REST .TEM>>)
			     (ELSE <PUTREST <PREV <1 .FL> .TEM> <REST .TEM>>)>)>
		<SET FL <REST .FL 2>>>>

<DEFINE REVERSE (LS)
	#DECL ((LS) <UNSPECIAL LIST>)
	<REPEAT ((RES ()) (TEM ()))
		#DECL ((RES TEM) LIST)
		<COND (<EMPTY? .LS> <RETURN .RES>)>
		<SET TEM <REST .LS>>
		<SET RES <PUTREST .LS .RES>>
		<SET LS .TEM>>>

<DEFINE ORDEREM (FLIST)
   #DECL ((FLIST) <UNSPECIAL LIST>)
   <REPEAT (TEM (RES ()))
     #DECL ((RES) <UNSPECIAL <LIST [REST <OR ATOM LIST>]>>
	    (VALUE) <LIST [REST <OR ATOM LIST>]>
	    (TEM) <UNSPECIAL <PRIMTYPE LIST>>)
     <COND
      (<EMPTY? .FLIST> <RETURN <REVERSE .RES>>)
      (<SET TEM <MEMQ () .FLIST>>
       <SET RES (<2 .TEM> !.RES)>
       <COND (<==? .TEM .FLIST> <SET FLIST <REST .FLIST 2>>)
	     (ELSE <PUTREST <PREV .FLIST .TEM> <REST .TEM 2>>)>
       <SPLOUTEM .FLIST <1 .RES>>)
      (ELSE
       <PROG ((RES2 ()) GOTONE)
	     #DECL ((RES2) LIST)
	     <SET GOTONE <>>
	     <REPEAT ((RES1 .FLIST))
		     #DECL ((RES1) LIST)
		     <COND (<NOT <CALLME <2 .RES1> .FLIST>>
			    <SET GOTONE T>
			    <SET RES2 (<2 .RES1> !.RES2)>
			    <COND (<==? .FLIST .RES1>
				   <SET FLIST <REST .FLIST 2>>)
				  (ELSE
				   <PUTREST <PREV .FLIST .RES1>
					    <REST .RES1 2>>)>)>
		     <AND <EMPTY? <SET RES1 <REST .RES1 2>>> <RETURN>>>
	     <COND (.GOTONE <AGAIN>)
		   (<NOT <EMPTY? .FLIST>> <SET FLIST <CORDER .FLIST>>)>
	     <SET TEM <REVERSE .RES>>
	     <COND (<NOT <EMPTY? .FLIST>>
		    <COND (<EMPTY? .RES>
			   <SET TEM .FLIST>
			   <SET RES <REST .FLIST <- <LENGTH .FLIST> 1>>>)
			  (ELSE
			   <SET RES
				<REST <PUTREST .RES .FLIST>
				      <LENGTH .FLIST>>>)>)>
	     <COND (<EMPTY? .RES> <SET RES .RES2>)
		   (ELSE <PUTREST .RES .RES2> <SET RES .TEM>)>>
       <RETURN .RES>)>>>

<DEFINE CALLME (ATM LST)
	#DECL ((ATM) ATOM (LST) <LIST [REST <LIST [REST ATOM]> ATOM]>)
	<REPEAT ()
		<AND <EMPTY? .LST> <RETURN <>>>
		<AND <MEMQ .ATM <1 .LST>> <RETURN>>
		<SET LST <REST .LST 2>>>>

<DEFINE CORDER (LST "AUX" (RES ()))
	#DECL ((LST) <LIST [REST <LIST [REST ATOM]> ATOM]> (RES) LIST)
	<REPEAT ((LS .LST))
		#DECL ((LS) <LIST [REST LIST ATOM]>)
		<AND <EMPTY? .LS> <RETURN>>
		<PUT .LS 1 <ALLREACH (<2 .LS>) <1 .LS> .LST>>
		<SET LS <REST .LS 2>>>
	<REPEAT ((PNT ()))
		#DECL ((PNT) <LIST [REST LIST ATOM]>)
		<REPEAT ((SHORT <CHTYPE <MIN> FIX>) (TL 0) (LST .LST))
			#DECL ((SHORT TL) FIX (LST) <LIST [REST LIST ATOM]>)
			<AND <EMPTY? .LST> <RETURN>>
			<COND (<L? <SET TL <LENGTH <1 .LST>>> .SHORT>
			       <SET SHORT .TL>
			       <SET PNT .LST>)>
			<SET LST <REST .LST 2>>>
		<SET RES
		     (<COND (<1? <LENGTH <1 .PNT>>> <1 <1 .PNT>>)
			    (ELSE <1 .PNT>)>
		      !.RES)>
		<MAPF <> <FUNCTION (ATM) <SPLOUTEM .LST .ATM>> <1 .PNT>>
		<REPEAT (TEM)
			<COND (<SET TEM <MEMQ () .LST>>
			       <COND (<==? .TEM .LST> <SET LST <REST .TEM 2>>)
				     (ELSE
				      <PUTREST <PREV .LST .TEM>
					       <REST .TEM 2>>)>)
			      (ELSE <RETURN>)>>
		<AND <EMPTY? .LST> <RETURN>>>
	<REVERSE .RES>>

<DEFINE ALLREACH (LATM LST MLST)
   #DECL ((LATM LST) <LIST [REST ATOM]>
	  (MLST) <LIST [REST <LIST [REST ATOM]> ATOM]>)
   <MAPF <>
    <FUNCTION (ATM)
	    #DECL ((ATM) ATOM)
	    <COND (<MEMQ .ATM .LATM>)
		  (ELSE
		   <SET LATM
			<ALLREACH (.ATM !.LATM)
				  <REPEAT ((L .MLST))
					  #DECL ((L) <LIST [REST LIST ATOM]>)
					  <AND <==? <2 .L> .ATM>
					       <RETURN <1 .L>>>
					  <SET L <REST .L 2>>>
				  .MLST>>)>>
    .LST>
   .LATM>

<DEFINE REMEMIT (ATM)
	#DECL ((ATM) ATOM (FUNC) <SPECIAL ATOM>
	       (FUNCL) <SPECIAL <LIST [REST ATOM]>>)
	<OR <==? .ATM .FUNC>
	    <MEMQ .ATM .FUNCL>
	    <SET FUNCL (.ATM !.FUNCL)>>>

<DEFINE FINDREC (OBJ "AUX" (FM '<>))
	#DECL ((FM) FORM)
	<COND (<MONAD? .OBJ>)
	      (<AND <TYPE? .OBJ FORM SEGMENT>
		    <NOT <EMPTY? <SET FM <CHTYPE .OBJ FORM>>>>>
	       <COND (<AND <TYPE? <1 .FM> ATOM> <GASSIGNED? <1 .FM>>>
		      <AND <TYPE? ,<1 .FM> FUNCTION> <REMEMIT <1 .FM>>>
		      <AND <TYPE? ,<1 .FM> MACRO>
			<NOT <EMPTY? ,<1 .FM>>>
				<FINDREC <EMACRO .FM>>>
				;"Analyze expansion of MACRO call"
		      <AND <OR <==? ,<1 .FM> ,MAPF> <==? ,<1 .FM> ,MAPR>>
			   <NOT <LENGTH? .FM 3>>
			   <PROG ()
				 <AND <TYPE? <2 .FM> FORM> <CHK-GVAL <2 .FM>>>
				 T>
			   <PROG ()
				 <AND <TYPE? <3 .FM> FORM>
				      <CHK-GVAL <3 .FM>>>>>)
		     (<STRUCTURED? <1 .OBJ>> <MAPF <> ,FINDREC <1 .OBJ>>)>
	       <COND (<EMPTY? <REST .OBJ>>)
		     (ELSE <MAPF <> ,FINDREC <REST .OBJ>>)>)
	      (ELSE <MAPF <> ,FINDREC .OBJ>)>>

<DEFINE EMACRO (OBJ "AUX" EH  TEM) 
	<ON <SET EH
		 <HANDLER "ERROR"
			  <FUNCTION (OBJ FRM "TUPLE" T)
			       <COND (<AND <GASSIGNED? MACACT>
					   <LEGAL? ,MACACT>>
				      <DISMISS [.OBJ !.T] ,MACACT>)
				     (ELSE <LISTEN !.T>)>>
			  100
			  .OBJ>>>
	<COND (<TYPE? <SET TEM
			   <PROG MACACT () #DECL ((MACACT) <SPECIAL ANY>)
				 <SETG MACACT .MACACT>
				 (<EXPAND .OBJ>)>>
		      VECTOR>
	       <OFF .EH>
	       <ERROR MACRO-EXPANSION-LOSSAGE!-ERRORS !.TEM>)
	      (ELSE <OFF .EH> <1 .TEM>)>>

<DEFINE CHK-GVAL (FM) #DECL ((FM) FORM)
	<AND	<==? <LENGTH .FM> 2>
		<TYPE? <1 .FM> ATOM>
		<==? ,<1 .FM> ,GVAL>
		<TYPE? <2 .FM> ATOM>
		<GASSIGNED? <2 .FM>>
		<OR <TYPE? ,<2 .FM> FUNCTION>
			<AND <TYPE? ,<2 .FM> MACRO>
				<NOT <EMPTY? ,<2 .FM>>>
				<TYPE? <1 ,<2 .FM>> FUNCTION>>>
		<REMEMIT <2 .FM>>>>

<DEFINE FINDEM (FUNC "AUX" (FUNCL ()))
	#DECL ((FUNC) <SPECIAL ATOM> (FUNCL) <SPECIAL <LIST [REST ATOM]>>
	       (VALUE) <LIST [REST ATOM]>)
	<FINDREC ,.FUNC>
	.FUNCL>

<DEFINE FINDEMALL (ATM
		   "AUX" (TOPDO
			  <REPEAT ((TD ()))
				  #DECL ((TD) LIST
					 (VALUE)
					 <LIST <LIST [REST ATOM]> ATOM>)
				  <AND <EMPTY? .ATM> <RETURN .TD>>
				  <SET TD (<FINDEM <1 .ATM>> <1 .ATM> !.TD)>
				  <SET ATM <REST .ATM>>>))
	#DECL ((ATM) <UNSPECIAL <<PRIMTYPE VECTOR> [REST ATOM]>>
	       (TOPDO) <UNSPECIAL <LIST <LIST [REST ATOM]> ATOM>>)
	<REPEAT ((TODO .TOPDO) (CURDO <1 .TOPDO>))
		#DECL ((TODO) <UNSPECIAL LIST>
		       (CURDO) <UNSPECIAL <LIST [REST ATOM]>>)
		<COND (<EMPTY? .CURDO>
		       <COND (<EMPTY? <SET TODO <REST .TODO 2>>>
			      <RETURN .TOPDO>)
			     (ELSE <SET CURDO <1 .TODO>> <AGAIN>)>)
		      (<MEMQ <1 .CURDO> .TOPDO>)
		      (ELSE
		       <PUTREST <REST .TODO <- <LENGTH .TODO> 1>>
				(<FINDEM <1 .CURDO>> <1 .CURDO>)>)>
		<SET CURDO <REST .CURDO>>>>

<DEFINE GETORDER ("TUPLE" ATMS)
	#DECL ((ATMS) <UNSPECIAL <<PRIMTYPE VECTOR> [REST ATOM]>>)
	<COND (<NOT <MEMQ #FALSE () <MAPF ,LIST ,CHECK .ATMS>>>
	       <ORDEREM <FINDEMALL .ATMS>>)
	      (ELSE <ERROR BAD-ARG GETORDER>)>>


<DEFINE FIND-OBL (NM GRP "AUX" (RGRP ..GRP) (OB .OBLIST)) 
	#DECL ((NM) ATOM (RGRP) LIST)
	<MAPR <>
	      <FUNCTION (PTR "AUX" (IT <1 .PTR>) TMP) 
		      <SET OB <GETPROP .PTR BLOCK '.OB>>
		      <COND (<AND <TYPE? .IT FORM>
				  <NOT <EMPTY? .IT>>
				  <OR <==? <SET TMP <1 .IT>> DEFINE>
				      <==? .TMP DEFMAC>>
				  <TYPE? <SET TMP
					      <GETPROP <2 .IT> VALUE '<2
								       .IT>>>
					 ATOM>
				  <==? .TMP .NM>>
			     <MAPLEAVE>)>>
	      .RGRP>
	.OB>

<DEFINE UPDATE-STATUS (STATE FCN PHASE REANA
		       "OPT" (CPU <FIX <+ <TIME> 0.5>>) (REAL <RTIME>)
		       "AUX" (OUTCHAN ,OUTCHAN))
	<COND (<NOT ,GC-USER-MON> <GC-MON ,GC-STATUS>)>
	<COND (<NOT <GASSIGNED? STATUS-CPU>> <SETG STATUS-CPU .CPU>)>
	<COND (<NOT <GASSIGNED? STATUS-REAL>> <SETG STATUS-REAL .REAL>)>
	<COND (.FCN <SETG STATUS-FCN .FCN>) (ELSE <SET FCN ,STATUS-FCN>)>
	<CHANNEL-OP .OUTCHAN HOR-POS-CURSOR 0>
	<PRINT-MANY .OUTCHAN PRINC
		    ,STATE-TITLE
		    !<STRING-FIT .STATE ,H-STATE-LN>
		    ,STATE-FCN
		    !<STRING-FIT .FCN ,H-FCN-LN>
		    ,STATE-PHASE
		    !<STRING-FIT <OR .PHASE ""> ,H-PHASE-LN>
		    ,STATE-CPU
		    !<CPU-STRING <- .CPU ,STATUS-CPU>>
		    ,STATE-REAL
		    !<REAL-STRING <- .REAL ,STATUS-REAL>>
		    " "
		    !<FUNCTION-RATIO>
		    " "
		    <COND (.REANA .REANA) (ELSE "  ")>
		    <COND (,ERRORS-OCCURED "E ") (ELSE "  ")>>>

<DEFINE GC-STATUS ("OPT" (OUT <>))
	<COND (.OUT <CHANNEL-OP ,OUTCHAN ERASE-CHAR>)
	      (ELSE <PRINC "G" ,OUTCHAN>)>>

<MSETG LENGTH-BLANK 100>

<SETG STR-BLANK <ISTRING ,LENGTH-BLANK !\ >>

<DEFINE STRING-FIT SF (STR:STRING FIELD:FIX "AUX" (LN <LENGTH .STR>))
	<COND (<==? .LN .FIELD> <MULTI-RETURN .SF .STR>)
	      (<G? .LN .FIELD>
	       <MULTI-RETURN .SF <SUBSTRUC .STR 0 .FIELD>>)
	      (ELSE
	       <MULTI-RETURN .SF .STR <REST ,STR-BLANK <- ,LENGTH-BLANK
							  <- .FIELD .LN>>>>)>>

<DEFINE CPU-STRING CS (CPU:FIX
		       "AUX" (COLON <>) (H:FIX </ .CPU 3600>)
			     (R:FIX <MOD .CPU 3600>) (M:FIX </ .R 60>)
			     (S:FIX <MOD .R 60>))
	<MULTI-RETURN .CS
		      <COND (<G? .H 10> "*:")
			    (<G? .H 0> <SET COLON T> .H)
			    (ELSE "")>
		      <COND (.COLON ":")(ELSE "")>
		      .M
		      ":"
		      <COND (<L? .S 10> "0") (ELSE "")>
		      .S
		      <COND (<==? .H 0> "  ") (ELSE "")>
		      <COND (<L? .M 10> " ") (ELSE "")>>>

<DEFINE REAL-STRING RS (REAL:FIX
		        "AUX" (COLON T) (H:FIX </ .REAL 3600>)
			      (R:FIX <MOD .REAL 3600>) (M:FIX </ .R 60>)
			      (S:FIX <MOD .R 60>))
	<MULTI-RETURN .RS
		      <COND (<G? .H 100> "**")
			    (<G? .H 0> "")
			    (ELSE <SET COLON <>> "")>
		      <COND (<AND <L? .H 100> <G? .H 0>> .H) (ELSE "")>
		      <COND (.COLON ":")(ELSE "")>
		      .M
		      ":"
		      <COND (<L? .S 10> "0") (ELSE "")>
		      .S
		      <COND (<G? .H 10> "")
			    (<G? .H 0> " ")
			    (ELSE "   ")>
		      <COND (<L? .M 10> " ") (ELSE "")>>>

<DEFINE FUNCTION-RATIO FR ("AUX" ATL:LIST LN1:FIX LN2:FIX)
	<COND (<OR <NOT <ASSIGNED? ATOM-LIST>> <NOT <ASSIGNED? AL>>>
	       <MULTI-RETURN .FR <REST ,STR-BLANK <- ,LENGTH-BLANK
						     ,H-RATIO-LN>>>)
	      (ELSE
	       <SET LN1 <LENGTH <SET ATL .ATOM-LIST>>>
	       <SET LN2 <- .LN1 <LENGTH <MEMQ .AL .ATL>> -1>>
	       <MULTI-RETURN .FR
			     <COND (<G=? .LN2 100> "")
				   (<G=? .LN2 10> " ")
				   (ELSE "  ")>
			     .LN2
			     "/"
			     <COND (<G=? .LN1 100> "")
				   (<G=? .LN1 10> " ")
				   (ELSE "  ")> 
			     .LN1>)>>
		      
<ENDPACKAGE>
