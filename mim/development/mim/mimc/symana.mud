
<PACKAGE "SYMANA">

<ENTRY ANA
       EANA
       SET-CURRENT-TYPE
       TYPE-NTH-REST
       WHO
       TMPS
       GET-TMP
       TRUTH
       UNTRUTH
       SEGFLUSH
       KILL-REM
       BUILD-TYPE-LIST
       GET-CURRENT-TYPE
       ADD-TYPE-LIST
       PUT-FLUSH
       WHON
       SAVE-SURVIVORS
       SEQ-AN
       ARGCHK
       ASSUM-OK?
       FREST-L-D-STATE
       HTMPS
       ORUPC
       APPLTYP
       MSAVE-L-D-STATE
       SHTMPS
       RESET-VARS
       STMPS
       ASSERT-TYPES
       SAVE-L-D-STATE
       MUNG-L-D-STATE
       NORM-BAN
       SUBR-C-AN
       ENTROPY
       NAUX-BAN
       TUP-BAN
       ARGS-BAN
       LIFE
       MANIFESTQ
       SPEC-FLUSH
       UPDATE-SIDE-EFFECTS>

<USE "CHKDCL"
     "COMPDEC"
     "STRANA"
     "CARANA"
     "NOTANA"
     "ADVMESS"
     "MAPANA"
     "SUBRTY"
     "BITSANA"
     "CDRIVE">

"	This is the main file associated with the type analysis phase of
the compilation.  It is called by calling FUNC-ANA with the main data structure
pointer.   ANA is the FUNCTION that dispatches to the various special handlers
and the SUBR call analyzer further dispatches for specific functions."

"	Many analyzers for specific SUBRs appear in their own files
(CARITH, STRUCT etc.).  Currently no special hacks are done for TYPE?, EMPTY?
etc. in COND, ANDS and ORS."

"	All analysis functions are called with 2 args, a NODE and a desired
type specification.  These args are usually called NOD and RTYP or
N and R."

" ANA is the main analysis dispatcher (see ANALYZERS at the end of
  this file for its dispatch table."

<GDECL (TEMPLATES SUBRS) VECTOR>

<DEFINE ANA (NOD RTYP "AUX" (P <PARENT .NOD>)) 
	#DECL ((NOD) NODE (P) ANY (TEM TT) <OR FALSE LIST>)
	<COND (<G=? <LENGTH .NOD> <INDEX ,SIDE-EFFECTS>>
	       <PUT .NOD ,SIDE-EFFECTS <>>)>
	<PUT .NOD ,RESULT-TYPE <ANALYSIS-DISPATCHER .NOD .RTYP>>
	<UPDATE-SIDE-EFFECTS .NOD .P>
	<RESULT-TYPE .NOD>>

<DEFINE UPDATE-SIDE-EFFECTS (NOD P "AUX" TEM TT) 
   #DECL ((NOD) NODE (TEM TT) <OR FALSE LIST>)
   <COND
    (<AND <N==? <NODE-TYPE .NOD> ,QUOTE-CODE>
	  <SET TEM <SIDE-EFFECTS .NOD>>
	  <REPEAT ()
		  <COND (<NOT <TYPE? .P NODE>> <RETURN <>>)>
		  <COND (<G=? <LENGTH .P> <CHTYPE <INDEX ,SIDE-EFFECTS> FIX>>
			 <RETURN T>)>
		  <SET P <PARENT .P>>>>
     <PUT
      .P
      ,SIDE-EFFECTS
      <COND (<EMPTY? .TEM> <SIDE-EFFECTS .P>)
	    (<EMPTY? <SET TT <SIDE-EFFECTS .P>>> .TEM)
	    (<AND <MEMQ ALL .TEM> <MEMQ ALL .TT>>
	     <COND (<G? <LENGTH .TEM> <LENGTH .TT>>
		    <SET TT
			 <MAPF ,LIST
			       <FUNCTION (IT) 
				       <COND (<AND <N==? .IT ALL>
						   <NOT <MEMQ .IT .TEM>>> .IT)
					     (ELSE <MAPRET>)>>
			       .TT>>
		    <COND (<EMPTY? .TT> .TEM)
			  (ELSE
			   <PUTREST <REST .TT <- <LENGTH .TT> 1>> .TEM>
			   .TT)>)
		   (ELSE
		    <SET TT
			 <MAPF ,LIST
			       <FUNCTION (IT) 
				       <COND (<AND <N==? .IT ALL>
						   <NOT <MEMQ .IT .TT>>> .IT)
					     (ELSE <MAPRET>)>>
			       .TEM>>
		    <COND (<EMPTY? .TEM> .TT)
			  (ELSE
			   <PUTREST <REST .TEM <- <LENGTH .TEM> 1>> .TT>
			   .TEM)>)>)
	    (<G? <LENGTH .TT> <LENGTH .TEM>> (!.TEM !.TT))
	    (ELSE (!.TT !.TEM))>>)>>

<DEFINE ARGCHK (GIV REQ NAME NOD "AUX" (HI .REQ) (LO .REQ)) 
	#DECL ((GIV) FIX (REQ HI LO) <OR <LIST FIX FIX> FIX> (NOD) NODE)
	<COND (<TYPE? .REQ LIST> <SET HI <2 .REQ>> <SET LO <1 .REQ>>)>
	<COND (<L? .GIV .LO>
	       <COMPILE-ERROR "Too many arguments to:  " .NAME .NOD>)
	      (<G? .GIV .HI>
	       <COMPILE-ERROR "Too many arguments to:  " .NAME .NOD>)>
	T>

<DEFINE EANA (NOD RTYP NAME) 
	#DECL ((NOD) NODE)
	<COND (<ANA .NOD .RTYP>)
	      (ELSE <COMPILE-ERROR "Argument wrong type to: " .NAME .NOD>)>>

" FUNC-ANA main entry to analysis phase.  Analyzes bindings then body."

<DEFINE FUNC-ANA ANA-ACT (N R
			  "AUX" (ANALY-OK
				 <COND (<ASSIGNED? ANALY-OK> .ANALY-OK)
				       (ELSE T)>) (OV .VERBOSE))
	#DECL ((ANA-ACT) <SPECIAL ANY> (ANALY-OK) <SPECIAL ANY>)
	<COND (.VERBOSE <PUTREST <SET VERBOSE .OV> ()>)>
	<FUNC-AN1 .N .R>>

<DEFINE FUNC-AN1 (FCN RTYP
		  "AUX" (VARTBL <SYMTAB .FCN>) (TMPS 0) (HTMPS 0) (TRUTH ())
			(UNTRUTH ()) (WHO ()) (WHON <>) (PRED <>) TEM (LIFE ())
			(USE-COUNT 0) (BACKTRACK 0) NRTYP)
   #DECL ((FCN) <SPECIAL NODE> (VARTBL) <SPECIAL SYMTAB>
	  (TMPS BACKTRACK USE-COUNT HTMPS) <SPECIAL FIX>
	  (LIFE TRUTH UNTRUTH) <SPECIAL LIST> (WHO PRED WHON) <SPECIAL ANY>)
   <RESET-VARS .VARTBL>
   <BIND-AN <BINDING-STRUCTURE .FCN>>
   <COND (<NOT <SET NRTYP <TYPE-OK? .RTYP <INIT-DECL-TYPE .FCN>>>>
	  <COMPILE-ERROR "Function returns wrong type: "
			 <NODE-NAME .FCN>
			 ".  Declared type is "
			 <INIT-DECL-TYPE .FCN>
			 ", required type is "
			 .RTYP>)>
   <PROG ((ACT? <ACTIV? <BINDING-STRUCTURE .FCN> T>) (OV .VERBOSE))
	 <COND (.VERBOSE <PUTREST <SET VERBOSE .OV> ()>)>
	 <PUT .FCN ,AGND <>>
	 <PUT .FCN ,LIVE-VARS ()>
	 <SET LIFE ()>
	 <PUT .FCN ,ASSUM <BUILD-TYPE-LIST .VARTBL>>
	 <PUT .FCN ,ACCUM-TYPE <COND (.ACT? .RTYP) (ELSE NO-RETURN)>>
	 <SET TEM <SEQ-AN <KIDS .FCN> <INIT-DECL-TYPE .FCN>>>
	 <COND (.ACT? <SPEC-FLUSH> <PUT-FLUSH ALL>)>
	 <COND
	  (<OR <AND <OR <AGND .FCN> .ACT?>
		    <NOT <ASSUM-OK? <ASSUM .FCN>
				    <OR <AGND .FCN>
					<BUILD-TYPE-LIST .VARTBL>>>>>
	       <AND <NOT .ACT?>
		    <SET ACT? <ACTIV? <BINDING-STRUCTURE .FCN> T>>
		    <ASSERT-TYPES <ASSUM .FCN>>>>
	   <AGAIN>)>>
   <PUT .FCN ,ASSUM ()>
   <PUT .FCN ,DEAD-VARS ()>
   <COND (<NOT .TEM>
	  <COMPILE-ERROR "Returned value violates decl of: " .NRTYP>)>
   <PUT .FCN ,RESULT-TYPE <TYPE-MERGE <ACCUM-TYPE .FCN> .TEM>>
   <PUT <RSUBR-DECLS .FCN> 2 <TASTEFUL-DECL <RESULT-TYPE .FCN>>>
   <RESULT-TYPE .FCN>>

" BIND-AN analyze binding structure for PROGs, FUNCTIONs etc."

<DEFINE BIND-AN (BNDS "AUX" COD) 
	#DECL ((BNDS) <LIST [REST SYMTAB]> (COD) FIX)
	<REPEAT (SYM)
		#DECL ((SYM) SYMTAB)
		<COND (<EMPTY? .BNDS> <RETURN>)>
		<PUT <SET SYM <1 .BNDS>> ,COMPOSIT-TYPE ANY>
		<PUT .SYM ,CURRENT-TYPE <>>
		<BIND-DISPATCH .SYM>
		<SET BNDS <REST .BNDS>>>>

" ENTROPY ignore call and return."

<DEFINE ENTROPY (SYM) T>

<DEFINE TUP-BAN (SYM) 
	#DECL ((SYM) SYMTAB)
	<COND (<NOT .ANALY-OK>
	       <PUT .SYM ,COMPOSIT-TYPE <DECL-SYM .SYM>>
	       <PUT .SYM ,CURRENT-TYPE ANY>)
	      (<N==? <ISTYPE? <DECL-SYM .SYM>> TUPLE>
	       <PUT .SYM ,COMPOSIT-TYPE TUPLE>
	       <PUT .SYM ,CURRENT-TYPE TUPLE>)
	      (ELSE
	       <PUT .SYM ,CURRENT-TYPE <DECL-SYM .SYM>>
	       <PUT .SYM ,COMPOSIT-TYPE <DECL-SYM .SYM>>)>>

" Analyze AUX and OPTIONAL intializations."

<DEFINE NORM-BAN (SYM
		  "AUX" (VARTBL <NEXT-SYM .SYM>) TEM COD (N <INIT-SYM .SYM>))
	#DECL ((VARTBL) <SPECIAL SYMTAB> (SYM) SYMTAB (COD) FIX (N) NODE)
	<COND (<NOT <SET TEM <ANA .N <DECL-SYM .SYM>>>>
	       <COMPILE-ERROR "AUX/OPT init for:  "
			      <NAME-SYM .SYM>
			      ".  Init value of: "
			      .N
			      " whose type is "
			      <RESULT-TYPE .N>
			      " violates decl of "
			      <DECL-SYM .SYM>>)>
	<COND (<AND .ANALY-OK
		    <OR <G? <SET COD <CODE-SYM .SYM>> ,ARGL-OPT>
			<L? .COD ,ARGL-QIOPT>>>
	       <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE>
		      <COND (<==? <NODE-NAME .N> <>> <SET TEM BOOL-FALSE>)
			    (<==? <NODE-NAME .N> T> <SET TEM BOOL-TRUE>)>)>
	       <PUT .SYM ,CURRENT-TYPE .TEM>
	       <PUT .SYM ,COMPOSIT-TYPE .TEM>)
	      (ELSE
	       <PUT .SYM ,COMPOSIT-TYPE <DECL-SYM .SYM>>
	       <PUT .SYM ,CURRENT-TYPE <DECL-SYM .SYM>>)>>

" ARGS-BAN analyze ARGS decl (change to OPTIONAL in some cases)."

<DEFINE ARGS-BAN (SYM) 
	#DECL ((SYM) SYMTAB)
	<PUT .SYM ,INIT-SYM <NODE1 ,QUOTE-CODE () LIST () ()>>
	<PUT .SYM ,CODE-SYM ,ARGL-IOPT>
	<COND (.ANALY-OK <PUT .SYM ,COMPOSIT-TYPE LIST>)
	      (ELSE <PUT .SYM ,COMPOSIT-TYPE <DECL-SYM .SYM>>)>
	<COND (.ANALY-OK
	       <PUT .SYM ,CURRENT-TYPE <TYPE-AND LIST <DECL-SYM .SYM>>>)
	      (<NOT .ANALY-OK> <PUT .SYM ,CURRENT-TYPE ANY>)>>

<DEFINE NAUX-BAN (SYM) 
	#DECL ((SYM) SYMTAB)
	<PUT .SYM
	     ,COMPOSIT-TYPE
	     <COND (.ANALY-OK NO-RETURN) (ELSE <DECL-SYM .SYM>)>>
	<PUT .SYM ,CURRENT-TYPE <COND (.ANALY-OK NO-RETURN) (ELSE ANY)>>>

"BIND-DISPATCH go to various binding analyzers analyzers."

<DEFINE BIND-DISPATCH (SYM "AUX" (COD <CODE-SYM .SYM>)) 
	<CASE ,==?
	      .COD
	      (,ARGL-ACT <ENTROPY .SYM>)
	      (,ARGL-IAUX <NORM-BAN .SYM>)
	      (,ARGL-AUX <NAUX-BAN .SYM>)
	      (,ARGL-TUPLE <TUP-BAN .SYM>)
	      (,ARGL-ARGS <ARGS-BAN .SYM>)
	      (,ARGL-QIOPT <NORM-BAN .SYM>)
	      (,ARGL-IOPT <NORM-BAN .SYM>)
	      (,ARGL-QOPT <ENTROPY .SYM>)
	      (,ARGL-OPT <ENTROPY .SYM>)
	      (,ARGL-CALL <ENTROPY .SYM>)
	      (,ARGL-BIND <ENTROPY .SYM>)
	      (,ARGL-QUOTE <ENTROPY .SYM>)
	      (,ARGL-ARG <ENTROPY .SYM>)>>

" SEQ-AN analyze a sequence of NODES discarding values until the last."

<DEFINE SEQ-AN (L FTYP "OPTIONAL" (DO-PRED <>) "AUX" (SOA <>) VAL) 
   #DECL ((L) <LIST [REST NODE]>)
   <COND
    (<EMPTY? .L> <COMPILE-LOSSAGE "Empty KIDS list in SEQ-AN">)
    (ELSE
     <SET VAL
      <REPEAT (TT N X Y TMP (RES NO-RETURN) (SPCD <>) ENDIF-FLAG
	       (RET-OR-AGAIN <>))
	#DECL ((X) NODE (Y) <LIST [REST NODE]> (RET-OR-AGAIN) <SPECIAL ANY>)
	<SET N <1 .L>>
	<SET ENDIF-FLAG <>>
	<COND
	 (<OR <AND <EMPTY? <SET L <REST .L>>> <NOT <IFSYS-ENDIF? .N "ENDIF">>>
	      <AND <NOT <EMPTY? .L>>
		   <IFSYS-ENDIF? <1 .L> "ENDIF">
		   <SET ENDIF-FLAG T>>>
	  <COND (<AND .DO-PRED <EMPTY? .L>>
		 <PROG ((PRED <PARENT .N>)) #DECL ((PRED) <SPECIAL ANY>)
		       <SET TT <ANA .N .FTYP>>>)
		(ELSE
		 <SET TT <ANA .N .FTYP>>)>
	  <COND (<AND .ENDIF-FLAG .SPCD>
		 <ASSERT-TYPES <ORUPC .VARTBL .SPCD>>
		 <SET SPCD <>>)>
	  <SET RES <TYPE-MERGE .TT .RES>>)
	 (<IFSYS-ENDIF? .N "IFSYS">
	  <SET TT <ANA .N ANY>>
	  <SET SPCD <BUILD-TYPE-LIST .VARTBL>>)
	 (ELSE
	  <SET TT <ANA .N ANY>>
	  <COND
	   (<OR <L? <LENGTH .N> <CHTYPE <INDEX ,SIDE-EFFECTS> FIX>>
		<NOT <SIDE-EFFECTS .N>>>
	    <COND
	     (<NOT .RET-OR-AGAIN>
	      <COND
	       (<AND .VERBOSE <NOT <EMPTY? .L>>>
		<ADDVMESS
		 <PARENT .N>
		 ("This object has no side-effects and its value is ignored"
		  .N)>)>)
	     (ELSE <PUTPROP .N DONT-FLUSH-ME T>)>)>)>
	<COND (<NOT .TT> <SET SOA .RET-OR-AGAIN> <RETURN <>>)>
	<COND
	 (<==? .TT NO-RETURN>
	  <COND (<AND .VERBOSE <NOT <EMPTY? .L>>>
		 <ADDVMESS <PARENT .N>
			   ("This object ends a sequence of forms"
			    .N
			    " because it never returns")>)>
	  <SET SOA .RET-OR-AGAIN>
	  <RETURN NO-RETURN>)>
	<COND (<EMPTY? .L> <SET SOA .RET-OR-AGAIN> <RETURN .RES>)>>>
     <COND (.SOA <SET RET-OR-AGAIN T>)>
     .VAL)>>

<DEFINE IFSYS-ENDIF? (N STR "AUX" Y NM) 
	#DECL ((N) NODE (Y) <LIST [REST NODE]>)
	<AND <==? <NODE-TYPE .N> ,CALL-CODE>
	     <G? <LENGTH <SET Y <KIDS .N>>> 1>
	     <TYPE? <SET NM <NODE-NAME <1 .Y>>> ATOM>
	     <=? <SPNAME .NM> .STR>>>

" ANALYZE ASSIGNED? usage."

<DEFINE ASSIGNED?-ANA (NOD RTYP
		       "AUX" (TEM <KIDS .NOD>) TT T1 T2 (TY '<OR ATOM
								 FALSE>))
   #DECL ((TT NOD) NODE (T1) SYMTAB (TEM) <LIST [REST NODE]>)
   <COND
    (<EMPTY? .TEM> <COMPILE-ERROR "No arguments ASSIGNED?: " .NOD>)
    (<SEGFLUSH .NOD .RTYP>)
    (ELSE
     <EANA <SET TT <1 .TEM>> ATOM ASSIGNED?>
     <COND (<AND <EMPTY? <REST .TEM>>
		 <==? <NODE-TYPE .TT> ,QUOTE-CODE>
		 <SET T2 <SRCH-SYM <NODE-NAME .TT>>>
		 <NOT <==? <CODE-SYM <SET T1 .T2>> -1>>>
	    <PUT .NOD ,NODE-TYPE ,ASSIGNED?-CODE>
	    <PUT .NOD ,NODE-NAME .T1>
	    <PUT .T1 ,ASS? T>
	    <PUT .T1 ,USED-AT-ALL T>
	    <PUT .T1 ,USAGE-SYM <+ <USAGE-SYM .T1> 1>>
	    <REVIVE .NOD .T1>
	    <SET TY
		 <COND (<==? <GET-CURRENT-TYPE .T1> NO-RETURN> BOOL-FALSE)
		       (ELSE BOOLEAN)>>)
	   (<==? <LENGTH .TEM> 2>
	    <EANA <2 .TEM> '<OR <PRIMTYPE FRAME> PROCESS> ASSIGNED?>)
	   (<EMPTY? <REST .TEM>>
	    <COND (<AND .VERBOSE <==? <NODE-TYPE .TT> ,QUOTE-CODE>>
		   <ADDVMESS .NOD
			     ("External reference to LVAL:  "
			      <NODE-NAME .TT>)>)>
	    <PUT .NOD ,NODE-TYPE ,ASSIGNED?-CODE>
	    <SET TY BOOLEAN>)
	   (ELSE <COMPILE-ERROR "Too many args to ASSIGNED?: " .NOD>)>)>
   <TYPE-OK? .TY .RTYP>>

<COND (<GASSIGNED? ASSIGNED?-ANA>
       <PUTPROP ,ASSIGNED? ANALYSIS ,ASSIGNED?-ANA>)>

" ANALYZE LVAL usage.  Become either direct reference or PUSHJ"

<DEFINE LVAL-ANA (NOD RTYP
		  "AUX" TEM ITYP (TT <>) T1 T2 T3 (P <PARENT .NOD>) NT)
   #DECL ((NOD) NODE (TEM) <LIST [REST NODE]> (T1) SYMTAB (WHO) LIST)
   <COND (<EMPTY? <SET TEM <KIDS .NOD>>>
	  <COMPILE-ERROR "No arguments LVAL: " .NOD>)
	 (<SEGFLUSH .NOD .RTYP>)
	 (<AND <OR <AND <TYPE? <NODE-NAME .NOD> SYMTAB>
			<SET TT <NODE-NAME .NOD>>>
		   <AND <EANA <1 .TEM> ATOM LVAL>
			<EMPTY? <REST .TEM>>
			<==? <NODE-TYPE <1 .TEM>> ,QUOTE-CODE>
			<==? <RESULT-TYPE <1 .TEM>> ATOM>
			<SET TT <SRCH-SYM <NODE-NAME <1 .TEM>>>>>>
	       <COND (<==? .WHON .P> <SET WHO ((<> .TT) !.WHO)>) (ELSE T)>
	       <PROG ()
		     <SET ITYP <GET-CURRENT-TYPE .TT>>
		     T>
	       <COND (<AND <==? .PRED .P>
			   <SET T2 <TYPE-OK? .ITYP FALSE>>
			   <SET T3 <TYPE-OK? .ITYP '<NOT FALSE>>>>
		      <SET TRUTH <ADD-TYPE-LIST .TT .T3 .TRUTH <>>>
		      <SET UNTRUTH <ADD-TYPE-LIST .TT .T2 .UNTRUTH <>>>)
		     (<AND <N==? .PRED .P>
			   <OR <NOT <TYPE? .P NODE>>
			       <AND <N==? <SET NT <NODE-TYPE .P>> ,SET-CODE>
				    <N==? .NT ,NOT-CODE>
				    <OR <N==? .NT ,SUBR-CODE>
					<AND <N==? <NODE-SUBR .P> ,SET>
					     <N==? <NODE-SUBR .P> ,NOT>>>>>
			   <MEMQ .ITYP '[BOOL-TRUE BOOL-FALSE BOOLEAN]>>
		      <SET-CURRENT-TYPE .TT <SET ITYP <GET-DECL .ITYP>>>
		      T)
		     (ELSE T)>
	       <NOT <==? <CODE-SYM <SET T1 .TT>> -1>>>
	  <PUT .NOD ,NODE-TYPE ,LVAL-CODE>
	  <REVIVE .NOD .T1>
	  <PUT .T1 ,RET-AGAIN-ONLY <>>
	  <PUT .T1 ,USED-AT-ALL T>
	  <PUT .T1 ,USAGE-SYM <+ <USAGE-SYM .T1> 1>>
	  <PUT .NOD ,NODE-NAME .T1>
	  <SET ITYP <TYPE-OK? .ITYP .RTYP>>
	  <COND (.ITYP <SET-CURRENT-TYPE .T1 .ITYP>)>
	  .ITYP)
	 (<EMPTY? <REST .TEM>>
	  <COND (<AND .VERBOSE <==? <NODE-TYPE <1 .TEM>> ,QUOTE-CODE>>
		 <ADDVMESS .NOD
			   ("External variable being referenced: "
			    <NODE-NAME <1 .TEM>>)>)>
	  <PUT .NOD ,NODE-TYPE ,FLVAL-CODE>
	  <AND .TT <PUT .NOD ,NODE-NAME <SET T1 .TT>>>
	  <COND (.TT <TYPE-OK? <DECL-SYM .T1> .RTYP>) (ELSE .RTYP)>)
	 (<AND <==? <LENGTH .TEM> 2>
	       <EANA <2 .TEM> '<OR <PRIMTYPE FRAME> PROCESS> LVAL>>
	  ANY)
	 (ELSE <COMPILE-ERROR "Too many args to LVAL: " .NOD>)>>

<COND (<GASSIGNED? LVAL-ANA> <PUTPROP ,LVAL ANALYSIS ,LVAL-ANA>)>

" SET-ANA analyze uses of SET."

<DEFINE SET-ANA (NOD RTYP
		 "AUX" (TEM <KIDS .NOD>) (LN <LENGTH .TEM>) T1 (T2 ATOM) T11 
		       (NM <2 <CHTYPE <NODE-SUBR .NOD> MSUBR>>) (WHON .WHON)
		       (PRED .PRED) OTYP T3 XX N)
   #DECL ((N NOD) NODE (TEM) <LIST [REST NODE]> (LN) FIX (T1) SYMTAB
	  (WHON PRED) <SPECIAL ANY> (WHO) LIST)
   <PUT .NOD ,SIDE-EFFECTS (.NOD !<SIDE-EFFECTS .NOD>)>
   <COND
    (<SEGFLUSH .NOD .RTYP>)
    (<OR <AND <==? .NM SET> <L? .LN 2>>
	 <AND <==? .NM UNASSIGN> <==? .LN 0>>>
     <COMPILE-ERROR "Too few arguments to:  " .NOD>)
    (<AND <OR <AND <TYPE? <NODE-NAME .NOD> SYMTAB> <SET T11 <NODE-NAME .NOD>>>
	      <AND <EANA <1 .TEM> ATOM .NM>
		   <OR <AND <==? .NM SET> <==? .LN 2>>
		       <AND <==? .NM UNASSIGN> <==? .LN 1>>>
		   <==? <NODE-TYPE <1 .TEM>> ,QUOTE-CODE>
		   <SET T11 <SRCH-SYM <NODE-NAME <1 .TEM>>>>>>
	  <COND (<==? .WHON <PARENT .NOD>>
		 <SET WHON .NOD>
		 <SET WHO ((T .T11) !.WHO)>)
		(ELSE T)>
	  <COND (<==? .PRED <PARENT .NOD>> <SET PRED .NOD>) (ELSE T)>
	  <SET T1 .T11>
	  <COND (<AND <==? .NM SET>
		      <NOT <SET T2 <ANA <SET N <2 .TEM>>
					<DECL-SYM .T1>>>>>
		 <COMPILE-ERROR "Decl violation:  " <NAME-SYM .T1> .NOD>)
		(ELSE T)>>
     <PUT .T1 ,PURE-SYM <>>
     <SET XX <DECL-SYM .T1>>
     <PUT .T1 ,USAGE-SYM <+ <USAGE-SYM .T1> 1>>
     <SET OTYP <OR <CURRENT-TYPE .T1> ANY>>
     <COND (<AND <==? <CODE-SYM .T1> -1> .VERBOSE>
	    <ADDVMESS .NOD ("External variable being SET (or UNASSIGNed):  "
			    <NAME-SYM .T1>)>)>
     <COND (<==? .NM SET> <SET T2 <OR <TYPE-AND .T2 .RTYP> .T2>>)>
     <COND (<N==? .NM SET>
	    <TYPE-INFO .NOD (<> <>)>)
	   (<SET OTYP <TYPESAME .OTYP .T2>> <PUT .NOD ,TYPE-INFO (.OTYP <>)>)
	   (ELSE <PUT .NOD ,TYPE-INFO (<> <>)>)>
     <PUT .NOD
	  ,NODE-TYPE
	  <COND (<==? <CODE-SYM .T1> -1> ,FSET-CODE) (ELSE ,SET-CODE)>>
     <PUT .NOD ,NODE-NAME .T1>
     <MAKE-DEAD .NOD .T1>
     <COND (<AND <==? .NM SET> <==? <NODE-TYPE .N> ,QUOTE-CODE>>
	    <COND (<==? <NODE-NAME .N> <>> <SET T2 BOOL-FALSE>)
		  (<==? <NODE-NAME .N> T> <SET T2 BOOL-TRUE>)>)>
     <SET-CURRENT-TYPE .T1 <COND (<==? .NM SET> .T2)(ELSE NO-RETURN)>>
     <PUT .T1 ,USED-AT-ALL T>
     <COND (<==? .NM SET>
	    <COND (<AND <==? .PRED .NOD>
			<SET OTYP <TYPE-OK? .T2 '<NOT FALSE>>>
			<SET T3 <TYPE-OK? .T2 FALSE>>>
		   <SET TRUTH <ADD-TYPE-LIST .T1 .OTYP .TRUTH T>>
		   <SET UNTRUTH <ADD-TYPE-LIST .T1 .T3 .UNTRUTH T>>)>
	    <TYPE-OK? .T2 .RTYP>)
	   (ELSE
	    <TYPE-OK? .T2 .RTYP>)>)
    (<AND <==? .NM SET> <L? .LN 4>>
     <SET T11 <ANA <2 .TEM> ANY>>
     <COND (<==? .LN 2>
	    <COND (<AND .VERBOSE <==? <NODE-TYPE <1 .TEM>> ,QUOTE-CODE>>
		   <ADDVMESS .NOD
			     ("External variable being SET: "
			      <NODE-NAME <1 .TEM>>)>)>
	    <PUT .NOD ,NODE-TYPE ,FSET-CODE>)
	   (ELSE <EANA <3 .TEM> '<OR <PRIMTYPE FRAME> PROCESS> SET>)>
     <TYPE-OK? .T11 .RTYP>)
    (<AND <==? .NM UNASSIGN> <L? .LN 3>>
     <COND (<==? .LN 1>
	    <COND (<AND .VERBOSE <==? <NODE-TYPE <1 .TEM>> ,QUOTE-CODE>>
		   <ADDVMESS .NOD
			     ("External variable being UNASSIGNed: "
			      <NODE-NAME <1 .TEM>>)>)>
	    <PUT .NOD ,NODE-TYPE ,FSET-CODE>)
	   (ELSE <EANA <2 .TEM> '<OR <PRIMTYPE FRAME> PROCESS> SET>)>)
    (ELSE <COMPILE-ERROR "Too many args to SET: " .NOD>)>>

<DEFINE MULTI-SET-ANA (NOD RTYP
		       "AUX" (K <KIDS .NOD>) (LN 0) (WHON .WHON) (PRED .PRED)
			     (SEG? <>) (N <1 .K>) (L-OF-A <NODE-NAME .N>)
			     L-OF-SY TY TY1 TTY FTY)
   #DECL ((N NOD) NODE (TEM) <LIST [REST NODE]> (LN) FIX (T1) SYMTAB
	  (WHON PRED) <SPECIAL ANY> (WHO) LIST (L-OF-A L-OF-SY) LIST)
   <PUT .NOD ,SIDE-EFFECTS (.NOD !<SIDE-EFFECTS .NOD>)>
   <SET L-OF-SY
    <MAPR ,LIST
     <FUNCTION (AL NL
		"AUX" (ATM:<OR ADECL ATOM LIST SYMTAB> <1 .AL>) (N:NODE <1 .NL>)
		      (NT:FIX <NODE-TYPE .N>) SY)
	     <COND
	      (<OR <==? .NT ,SEGMENT-CODE> <==? .NT ,SEG-CODE>>
	       <MAPSTOP !<MULTI-SET-SEG .NOD .AL .NL>>)
	      (ELSE
	       <COND (<AND <EMPTY? <REST .AL>> <NOT <EMPTY? <REST .NL>>>>
		      <COMPILE-ERROR "Too many values for vars:  " .NOD>)
		     (<AND <NOT <EMPTY? <REST .AL>>> <EMPTY? <REST .NL>>>
		      <COMPILE-ERROR "Too few values for vars:  " .NOD>)>
	       <SET TY1 ANY>
	       <COND (<TYPE? .ATM ATOM>
		      <COND (<SET SY <SRCH-SYM .ATM>> <SET ATM .SY>)>)
		     (<TYPE? .ATM ADECL>
		      <COND (<SET SY <SRCH-SYM <1 .ATM>>>
			     <SET TY1 <2 .ATM>>
			     <SET ATM .SY>)
			    (ELSE
			     <SET TY1 <2 .ATM>>
			     <SET ATM <1 .ATM>>)>)
		     (<TYPE? .ATM LIST>
		      <SET TY1 <1 .ATM>>
		      <SET ATM <2 .ATM>>)>
	       <COND (<TYPE? .ATM SYMTAB>
		      <COND (<AND <==? .WHON <PARENT .NOD>>
				  <EMPTY? <REST .AL>>>
			     <SET WHON .NOD>
			     <SET WHO ((T .ATM) !.WHO)>)>
		      <COND (<AND <==? .PRED <PARENT .NOD>>
				  <EMPTY? <REST .AL>>>
			     <SET PRED .NOD>)>
		      <COND (<OR <NOT <SET TY <TYPE-OK? .TY1 <DECL-SYM .ATM>>>>
				 <NOT <SET TY <ANA .N .TY>>>>
			     <COMPILE-ERROR "Decl violation: "
					    <NAME-SYM .N>
					    .NOD>)>
		      <PUT .ATM ,PURE-SYM <>>
		      <PUT .ATM ,USAGE-SYM <+ <USAGE-SYM .ATM> 1>>
		      <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE>
			     <COND (<==? <NODE-NAME .N> <>>
				    <SET TY BOOL-FALSE>)
				   (<==? <NODE-NAME .N> T>
				    <SET TY BOOL-TRUE>)>)>
		      <SET-CURRENT-TYPE .ATM .TY>
		      <PUT .ATM ,USED-AT-ALL T>
		      <COND (<AND <==? .PRED .NOD>
				  <SET TTY <TYPE-OK? .TY '<NOT FALSE>>>
				  <SET FTY <TYPE-OK? .TY FALSE>>>
			     <SET TRUTH <ADD-TYPE-LIST .ATM .TTY .TRUTH T>>
			     <SET UNTRUTH
				  <ADD-TYPE-LIST .ATM .FTY .UNTRUTH T>>)>)
		     (ELSE <SET TY <ANA .N .TY1>>)>
	       <COND (<AND .VERBOSE
			   <OR <AND <TYPE? .ATM SYMTAB>
				    <==? <CODE-SYM .ATM> -1>
				    <SET ATM <NAME-SYM .ATM>>>
			       <TYPE? .ATM ATOM>>>
		      <ADDVMESS .NOD ("External variable being SET: " .ATM)>)>
	       (.ATM .TY1))>>
     .L-OF-A
     <REST .K>>>
   <PUT .NOD ,NODE-NAME .L-OF-SY>
   <PUT .NOD ,NODE-TYPE ,MULTI-SET-CODE>
   <TYPE-OK? <2 <NTH .L-OF-SY <LENGTH .L-OF-SY>>> .RTYP>>

<DEFINE MULTI-SET-SEG (NOD:NODE AL:LIST NL:<LIST [REST NODE]>
		       "AUX" (MIN-LN:FIX 0) (MAX-LN:FIX 0)
			     (LN:FIX <LENGTH .AL>) (COMPOSIT-DECL NO-RETURN)
			     (COMPOSIT-TYPE NO-RETURN) L-OF-SY:LIST)
   <SET L-OF-SY
	<MAPF ,LIST
	      <FUNCTION (ATM:<OR ADECL ATOM LIST SYMTAB> "AUX" SY (TY ANY)) 
		      <COND (<TYPE? .ATM ATOM>
			     <COND (<SET SY <SRCH-SYM .ATM>> <SET ATM .SY>)>)
			    (<TYPE? .ATM ADECL>
			     <COND (<SET SY <SRCH-SYM <1 .ATM>>>
				    <SET TY <2 .ATM>>
				    <SET ATM .SY>)
				   (ELSE
				    <SET TY <2 .ATM>>
				    <SET ATM <1 .ATM>>)>)
			    (<TYPE? .ATM LIST>
			     <SET TY <1 .ATM>>
			     <SET ATM <2 .ATM>>)>
		      <COND (<TYPE? .ATM SYMTAB>
			     <COND (<NOT <SET TY <TYPE-AND <DECL-SYM .ATM> .TY>>>
				    <COMPILE-ERROR "ADECL and DECL mismatch:  "
						   <NAME-SYM .ATM>
						   .NOD>)>
			     <SET COMPOSIT-DECL
				  <TYPE-MERGE .COMPOSIT-DECL .TY>>
			     <PUT .ATM ,PURE-SYM <>>
			     <PUT .ATM ,USAGE-SYM <+ <USAGE-SYM .ATM> 1>>
			     <PUT .ATM ,USED-AT-ALL T>)>
		      (.ATM .TY)>
	      .AL>>
   <MAPF <>
    <FUNCTION (N:NODE "AUX" (NT:FIX <NODE-TYPE .N>) TY ET) 
       <COND
	(<OR <==? .NT ,SEG-CODE> <==? .NT ,SEGMENT-CODE>>
	 <SET TY <EANA <SET N <1 <KIDS .N>>> '<OR MULTI STRUCTURED> MULTI-SET>>
	 <COND (<N==? .COMPOSIT-DECL ANY>
		<COND (<NOT <SET ET
				 <TYPE-OK? <GET-ELE-TYPE .TY ALL>
					   .COMPOSIT-DECL>>>
		       <COMPILE-ERROR "Decl violation: " .NOD>)>)
	       (ELSE <SET ET <GET-ELE-TYPE .TY ALL>>)>
	 <SET COMPOSIT-TYPE <TYPE-MERGE .ET .COMPOSIT-TYPE>>
	 <SET MAX-LN <MAX <+ .MAX-LN <MAXL .TY>> ,MAX-LENGTH>>
	 <SET MIN-LN <+ .MIN-LN <MINL .TY>>>)
	(ELSE
	 <SET COMPOSIT-TYPE
	      <TYPE-MERGE <EANA .N .COMPOSIT-DECL MULTI-SET> .COMPOSIT-TYPE>>
	 <SET MAX-LN <MAX <+ .MAX-LN 1> ,MAX-LENGTH>>
	 <SET MIN-LN <+ .MIN-LN 1>>)>>
    .NL>
   <MAPF <>
    <FUNCTION (SY) 
	    <COND (<TYPE? <SET SY <1 .SY>> SYMTAB>
		   <SET-CURRENT-TYPE
		    .SY <TYPE-AND .COMPOSIT-TYPE <DECL-SYM .SY>>>)>>
    .L-OF-SY>
   <COND (<G? .MIN-LN .LN> <COMPILE-ERROR "Too many values:  " .NOD>)
	 (<L? .MAX-LN .LN> <COMPILE-ERROR "Too few values:  " .NOD>)>
   .L-OF-SY>

<COND (<GASSIGNED? SET-ANA>
       <PUTPROP ,SET ANALYSIS ,SET-ANA>
       <PUTPROP ,UNASSIGN ANALYSIS ,SET-ANA>)>

<DEFINE MUNG-L-D-STATE (V) 
	#DECL ((V) <OR VECTOR SYMTAB>)
	<REPEAT ()
		<COND (<TYPE? .V VECTOR> <RETURN>)>
		<PUT .V ,DEATH-LIST ()>
		<SET V <NEXT-SYM .V>>>>

<DEFINE MRESTORE-L-D-STATE (L1 L2 V) 
	<RESTORE-L-D-STATE .L1 .V>
	<RESTORE-L-D-STATE .L2 .V T>>

<DEFINE FREST-L-D-STATE (L) 
	#DECL ((L) LIST)
	<MAPF <>
	      <FUNCTION (LL) 
		      #DECL ((LL) <LIST SYMTAB <LIST [REST NODE]>>)
		      <COND (<NOT <2 <TYPE-INFO <1 <2 .LL>>>>>
			     <PUT <1 .LL> ,DEATH-LIST <2 .LL>>)>>
	      .L>>

<DEFINE RESTORE-L-D-STATE (L V "OPTIONAL" (FLG <>)) 
   #DECL ((L) <LIST [REST <LIST SYMTAB LIST>]> (V) <OR SYMTAB VECTOR>)
   <COND (<NOT .FLG>
	  <REPEAT (DL)
		  #DECL ((DL) <LIST [REST NODE]>)
		  <COND (<TYPE? .V VECTOR> <RETURN>)>
		  <COND (<AND <NOT <EMPTY? <SET DL <DEATH-LIST .V>>>>
			      <NOT <2 <TYPE-INFO <1 .DL>>>>>
			 <PUT .V ,DEATH-LIST ()>)>
		  <SET V <NEXT-SYM .V>>>)>
   <REPEAT (S DL)
     #DECL ((DL) <LIST NODE> (S) SYMTAB)
     <COND (<EMPTY? .L> <RETURN>)>
     <SET S <1 <1 .L>>>
     <AND .FLG
	  <REPEAT ()
		  <COND (<==? .S .V> <RETURN>) (<TYPE? .V VECTOR> <RETURN>)>
		  <PUT .V
		       ,DEATH-LIST
		       <MAPF ,LIST
			     <FUNCTION (N) 
				     #DECL ((N) NODE)
				     <COND (<==? <NODE-TYPE .N> ,SET-CODE>
					    <MAPRET>)
					   (ELSE .N)>>
			     <DEATH-LIST .V>>>
		  <SET V <NEXT-SYM .V>>>>
     <COND (<NOT <2 <TYPE-INFO <1 <SET DL <2 <1 .L>>>>>>>
	    <PUT .S
		 ,DEATH-LIST
		 <COND (.FLG <LMERGE <DEATH-LIST .S> .DL>) (ELSE .DL)>>)>
     <SET L <REST .L>>>>

<DEFINE SAVE-L-D-STATE (V) 
	#DECL ((V) <OR VECTOR SYMTAB>)
	<REPEAT ((L (())) (LP .L) DL)
		#DECL ((L LP) LIST (DL) <LIST [REST NODE]>)
		<COND (<TYPE? .V VECTOR> <RETURN <REST .L>>)>
		<COND (<AND <NOT <EMPTY? <SET DL <DEATH-LIST .V>>>>
			    <NOT <2 <CHTYPE <TYPE-INFO <1 .DL>> LIST>>>>
		       <SET LP <REST <PUTREST .LP ((.V .DL))>>>)>
		<SET V <NEXT-SYM .V>>>>

<DEFINE MSAVE-L-D-STATE (L V) 
	#DECL ((V) <OR VECTOR SYMTAB> (L) LIST)
	<REPEAT ((L (() !.L)) (LR .L) (LP <REST .L>) DL S TEM)
		#DECL ((L LP LR TEM) LIST (S) SYMTAB (DL) <LIST [REST NODE]>)
		<COND (<EMPTY? .LP>
		       <PUTREST .L <SAVE-L-D-STATE .V>>
		       <RETURN <REST .LR>>)
		      (<TYPE? .V VECTOR> <RETURN <REST .LR>>)
		      (<AND <NOT <EMPTY? <SET DL <DEATH-LIST .V>>>>
			    <NOT <2 <TYPE-INFO <1 .DL>>>>>
		       <COND (<==? <SET S <1 <1 .LP>>> .V>
			      <SET TEM <LMERGE <2 <1 .LP>> .DL>>
			      <COND (<EMPTY? .TEM>
				     <PUTREST .L <SET LP <REST .LP>>>)
				    (ELSE
				     <PUT <1 .LP> 2 .TEM>
				     <SET LP <REST <SET L .LP>>>)>)
			     (ELSE
			      <PUTREST .L <SET L ((.V .DL))>>
			      <PUTREST .L .LP>)>)
		      (<==? .V <1 <1 .LP>>> <SET LP <REST <SET L .LP>>>)>
		<SET V <NEXT-SYM .V>>>>

<DEFINE LMERGE (L1 L2) 
	#DECL ((L1 L2) <LIST [REST NODE]>)
	<SET L1
	     <MAPF ,LIST
		   <FUNCTION (N) 
			   <COND (<OR <2 <TYPE-INFO .N>>
				      <AND <==? <NODE-TYPE .N> ,SET-CODE>
					   <NOT <MEMQ .N .L2>>>>
				  <MAPRET>)>
			   .N>
		   .L1>>
	<SET L2
	     <MAPF ,LIST
		   <FUNCTION (N) 
			   <COND (<OR <2 <TYPE-INFO .N>>
				      <==? <NODE-TYPE .N> ,SET-CODE>
				      <MEMQ .N .L1>>
				  <MAPRET>)>
			   .N>
		   .L2>>
	<COND (<EMPTY? .L1> .L2)
	      (ELSE <PUTREST <REST .L1 <- <LENGTH .L1> 1>> .L2> .L1)>>

<DEFINE MAKE-DEAD (N SYM) 
	#DECL ((N) NODE (SYM) SYMTAB)
	<PUT .SYM ,DEATH-LIST (.N)>>

<DEFINE KILL-REM (L V) 
	#DECL ((L) <LIST [REST SYMTAB]> (V) <OR SYMTAB VECTOR>)
	<REPEAT ((L1 ()))
		#DECL ((L1) LIST)
		<COND (<TYPE? .V VECTOR> <RETURN .L1>)>
		<COND (<AND <NOT <SPEC-SYM .V>>
			    <N==? <CODE-SYM .V> -1>
			    <MEMQ .V .L>>
		       <SET L1 (.V !.L1)>)>
		<SET V <NEXT-SYM .V>>>>

<DEFINE SAVE-SURVIVORS (LS LI "OPTIONAL" (FLG <>)) 
	#DECL ((LS) <LIST [REST <LIST SYMTAB LIST>]> (LI) <LIST [REST
								 SYMTAB]>)
	<MAPF <>
	 <FUNCTION (LL) 
		 <COND (<MEMQ <1 .LL> .LI>
			<MAPF <>
			      <FUNCTION (N) 
				      #DECL ((N) NODE)
				      <PUT <TYPE-INFO .N> 2 T>>
			      <2 .LL>>)
		       (.FLG <PUT <1 .LL> ,DEATH-LIST <2 .LL>>)>>
	 .LS>>

<DEFINE REVIVE (NOD SYM "AUX" (L <DEATH-LIST .SYM>)) 
	#DECL ((L) <LIST [REST NODE]> (SYM) SYMTAB (NOD) NODE)
	<COND (<AND <NOT <SPEC-SYM .SYM>> <N==? <CODE-SYM .SYM> -1>>
	       <COND (<EMPTY? .L> <SET LIFE (.SYM !.LIFE)>)
		     (ELSE
		      <MAPF <>
			    <FUNCTION (N) 
				    #DECL ((N) NODE)
				    <PUT <TYPE-INFO .N> 2 T>>
			    .L>)>
	       <PUT .SYM ,DEATH-LIST (.NOD)>
	       <PUT .NOD ,TYPE-INFO (<> <>)>)>>

" Ananlyze a FORM that could really be an NTH."

<DEFINE FORM-F-ANA (NOD RTYP "AUX" (K <KIDS .NOD>) (OBJ <NODE-NAME .NOD>) TYP) 
	#DECL ((NOD) NODE (K) <LIST [REST NODE]>)
	<COND (<==? <ISTYPE? <SET TYP <ANA <1 .K> APPLICABLE>>> FIX>
	       <PUT .NOD ,KIDS (<2 .K> <1 .K> !<REST .K 2>)>
	       <COND (<==? <LENGTH .K> 2>
		      <SET RTYP <NTH-REST-ANA .NOD .RTYP ,NTH-CODE .TYP>>)
		     (ELSE <SET RTYP <PUT-ANA .NOD .RTYP ,PUT-CODE>>)>
	       <PUT .NOD ,NODE-SUBR <NODE-TYPE .NOD>>
	       <PUT .NOD ,KIDS .K>
	       <PUT .NOD ,NODE-NAME .OBJ>
	       <PUT .NOD ,NODE-TYPE ,FORM-F-CODE>
	       .RTYP)
	      (ELSE
	       <SPECIALIZE <NODE-NAME .NOD>>
	       <SPEC-FLUSH>
	       <PUT-FLUSH ALL>
	       <PUT .NOD ,SIDE-EFFECTS (ALL)>
	       <TYPE-OK? <RESULT-TYPE .NOD> .RTYP>)>>

" Further analyze a FORM."

<DEFINE FORM-AN (NOD RTYP) 
	#DECL ((NOD) NODE)
	<APPLY <OR <GETPROP <NODE-SUBR .NOD> ANALYSIS>
		   <GETPROP <TYPE <NODE-SUBR .NOD>> TANALYSIS>
		   <FUNCTION (N R) 
			   #DECL ((N) NODE)
			   <SPEC-FLUSH>
			   <PUT-FLUSH ALL>
			   <PUT .N ,SIDE-EFFECTS (ALL)>
			   <TYPE-OK? <RESULT-TYPE .N> .R>>>
	       .NOD
	       .RTYP>>

"Determine if an ATOM is mainfest."

<DEFINE MANIFESTQ (ATM) 
	#DECL ((ATM) ATOM)
	<AND <MANIFEST? .ATM> <GASSIGNED? .ATM> <NOT <TYPE? ,.ATM MSUBR>>>>

" Search for a decl associated with a local value."

<DEFINE SRCH-SYM (ATM "AUX" (TB .VARTBL)) 
	#DECL ((ATM) ATOM (TB) <PRIMTYPE VECTOR>)
	<REPEAT ()
		<COND (<EMPTY? .TB> <RETURN <>>)>
		<COND (<==? .ATM <NAME-SYM .TB>> <RETURN .TB>)>
		<SET TB <NEXT-SYM .TB>>>>

" Here to flush decls of specials for an external function call."

<DEFINE SPEC-FLUSH () <FLUSHER <>>>

" Here to flush decls when a PUT, PUTREST or external call happens."

<DEFINE PUT-FLUSH (TYP) <FLUSHER .TYP>>

<DEFINE FLUSHER (FLSFLG "AUX" (V .VARTBL)) 
   #DECL ((SYM) SYMTAB (V) <OR SYMTAB VECTOR>)
   <COND
    (.ANALY-OK
     <REPEAT (SYM TEM CT)
       #DECL ((SYM) SYMTAB)
       <COND
	(<AND <SET CT <CURRENT-TYPE <SET SYM .V>>>
	      <OR <AND <SPEC-SYM .SYM> <NOT .FLSFLG>>
		  <AND .FLSFLG
		       <N==? .CT NO-RETURN>
		       <N==? .CT BOOL-FALSE>
		       <N==? .CT BOOLEAN>
		       <N==? .CT BOOL-TRUE>
		       <TYPE-OK? <CURRENT-TYPE .V> '<STRUCTURED ANY>>
		       <OR <==? .FLSFLG ALL>
			   <NOT <SET TEM <STRUCTYP <CURRENT-TYPE .V>>>>
			   <==? .TEM .FLSFLG>>>>>
	 <SET-CURRENT-TYPE
	  .SYM <FLUSH-FIX-TYPE .SYM <CURRENT-TYPE .SYM> .FLSFLG>>)>
       <COND (<EMPTY? <SET V <NEXT-SYM .V>>> <RETURN>)>>)
    (ELSE
     <REPEAT (SYM)
	     #DECL ((SYM) SYMTAB)
	     <COND (<EMPTY? <SET V <NEXT-SYM .V>>> <RETURN>)>>)>>

<DEFINE FLUSH-FIX-TYPE (SYM TY FLG "AUX" TEM) 
	#DECL ((SYM) SYMTAB)
	<OR <AND .FLG
		 <SET TEM <TOP-TYPE <TYPE-OK? .TY STRUCTURED>>>
		 <TYPE-OK? <COND (<SET TY <TYPE-OK? .TY '<NOT STRUCTURED>>>
				  <TYPE-MERGE .TEM .TY>)
				 (ELSE .TEM)>
			   <DECL-SYM .SYM>>>
	    <DECL-SYM .SYM>>>

" Punt forms with segments in them."

<DEFINE SEGFLUSH (NOD RTYP) 
	#DECL ((NOD) NODE (L) <LIST [REST NODE]>)
	<COND
	 (<REPEAT ((L <KIDS .NOD>))
		  <AND <EMPTY? .L> <RETURN <>>>
		  <AND <==? <NODE-TYPE <1 .L>> ,SEGMENT-CODE> <RETURN T>>
		  <SET L <REST .L>>>
	  <COND (.VERBOSE
		 <ADDVMESS .NOD ("Not open compiled due to SEGMENT.")>)>
	  <SUBR-C-AN .NOD .RTYP>)>>

" Determine if the arg to STACKFORM is a SUBR."

<DEFINE APPLTYP (NOD "AUX" (NT <NODE-TYPE .NOD>) ATM TT) 
	#DECL ((ATM) ATOM (NOD TT) NODE (NT) FIX)
	<COND (<==? .NT ,GVAL-CODE>
	       <COND (<AND <==? <NODE-TYPE <SET TT <1 <KIDS .NOD>>>>
				,QUOTE-CODE>
			   <GASSIGNED? <SET ATM <NODE-NAME .TT>>>
			   <TYPE? ,.ATM MSUBR>>
		      <SUBR-TYPE ,.ATM>)
		     (ELSE ANY)>)
	      (ELSE ANY)>>

" Return type returned by a SUBR."

<DEFINE SUBR-TYPE (SUB "AUX" TMP) 
	#DECL ((SUB) MSUBR)
	<SET TMP <2 <GET-TMP .SUB>>>
	<COND (<TYPE? .TMP ATOM FORM> .TMP) (ELSE ANY)>>

" Access the SUBR data base for return type."

<DEFINE GET-TMP (SUB "AUX" (LS <MEMQ .SUB ,SUBRS>)) 
	#DECL ((VALUE) <LIST ANY ANY>)
	<COND (.LS <NTH ,TEMPLATES <LENGTH .LS>>) (ELSE '(ANY ANY))>>

" GVAL analyzer."

<DEFINE GVAL-ANA (NOD RTYP "AUX" (K <KIDS .NOD>) (LN <LENGTH .K>) TEM TT TEM1) 
   #DECL ((NOD TEM) NODE (TT) <VECTOR VECTOR ATOM ANY> (LN) FIX)
   <COND
    (<SEGFLUSH .NOD .RTYP>)
    (ELSE
     <ARGCHK .LN 1 GVAL .NOD>
     <PUT .NOD ,NODE-TYPE ,FGVAL-CODE>
     <EANA <1 .K> ATOM GVAL>
     <COND (<AND <==? <NODE-TYPE <SET TEM <1 .K>>> ,QUOTE-CODE>
		 <==? <RESULT-TYPE .TEM> ATOM>>
	    <PUT .NOD ,NODE-TYPE ,GVAL-CODE>
	    <COND (<MANIFEST? <SET TEM1 <NODE-NAME .TEM>>>
		   <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
		   <PUT .NOD ,NODE-NAME ,.TEM1>
		   <PUT .NOD ,KIDS ()>
		   <TYPE-OK? <GEN-DECL ,.TEM1> .RTYP>)
		  (<AND <GBOUND? .TEM1>
			<COND (<GASSIGNED? GLOC>
			       <SET TEM1 <GET-DECL <GLOC .TEM1>>>)
			      (ELSE <SET TEM1 <GET-DECL <GBIND .TEM1>>>)>>
		   <TYPE-OK? .TEM1 .RTYP>)
		  (ELSE <TYPE-OK? ANY .RTYP>)>)
	   (ELSE <TYPE-OK? ANY .RTYP>)>)>>

<COND (<GASSIGNED? GVAL-ANA> <PUTPROP ,GVAL ANALYSIS ,GVAL-ANA>)>

<DEFINE GASSIGNED?-ANA (NOD RTYP "AUX" (K <KIDS .NOD>) (LN <LENGTH .K>)
				       (NM <NODE-NAME .NOD>)) 
	#DECL ((NOD) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .NOD .RTYP>)
	      (ELSE
	       <ARGCHK .LN 1 .NM .NOD>
	       <PUT .NOD ,NODE-TYPE ,GASSIGNED?-CODE>
	       <EANA <1 .K> ATOM .NM>)>
	<TYPE-OK? '<OR ATOM FALSE> .RTYP>>

<COND (<GASSIGNED? GASSIGNED?-ANA>
       <PUTPROP ,GASSIGNED? ANALYSIS ,GASSIGNED?-ANA>)>

<COND (<AND <GASSIGNED? GBOUND?> <GASSIGNED? GASSIGNED?-ANA>>
       <PUTPROP ,GBOUND? ANALYSIS ,GASSIGNED?-ANA>)>

" Analyze SETG usage."

<DEFINE SETG-ANA (NOD RTYP
		  "AUX" (K <KIDS .NOD>) (LN <LENGTH .K>) TEM TT T1 TTT)
   #DECL ((NOD TEM) NODE (K) <LIST [REST NODE]> (LN) FIX (TT) VECTOR)
   <COND
    (<SEGFLUSH .NOD .RTYP>)
    (ELSE
     <ARGCHK .LN '(2 3) SETG .NOD>
     <PUT .NOD ,NODE-TYPE ,FSETG-CODE>
     <EANA <SET TEM <1 .K>> ATOM SETG>
     <PUT .NOD ,SIDE-EFFECTS (.NOD !<SIDE-EFFECTS .NOD>)>
     <COND (<==? <NODE-TYPE .TEM> ,QUOTE-CODE>
	    <COND (<MANIFEST? <SET TTT <NODE-NAME .TEM>>>
		   <COMPILE-WARNING "SETGing manifest GVAL?  " .TTT .NOD>)>
	    <PUT .NOD ,NODE-TYPE ,SETG-CODE>
	    <COND (<AND <GBOUND? .TTT>
			<COND (<GASSIGNED? GLOC>
			       <SET T1 <GET-DECL <GLOC .TTT>>>)
			      (ELSE <SET T1 <GET-DECL <GBIND .TTT>>>)>>
		   <COND (<NOT <ANA <2 .K> .T1>>
			  <COMPILE-ERROR "GLOBAL declaration violation"
					 .TTT
					 .NOD>)>
		   <SET TTT <TYPE-OK? .T1 .RTYP>>)
		  (ELSE
		   <SET TTT <ANA <2 .K> ANY>>
		   <SET TTT <TYPE-OK? .TTT .RTYP>>)>)
	   (ELSE <SET TTT <ANA <2 .K> ANY>> <SET TTT <TYPE-OK? .TTT .RTYP>>)>
     <COND (<==? .LN 3> <EANA <3 .K> ANY SETG>)>
     .TTT)>>

<COND (<GASSIGNED? SETG-ANA> <PUTPROP ,SETG ANALYSIS ,SETG-ANA>)>

<DEFINE BUILD-TYPE-LIST (V "OPT" (ALL T)) 
   #DECL ((V) <OR VECTOR SYMTAB> (VALUE) LIST)
   <COND (.ANALY-OK
	  <REPEAT ((L (())) (LP .L) TEM)
		  #DECL ((L LP) LIST)
		  <COND (<EMPTY? .V> <RETURN <REST .L>>)
			(<N==? <CODE-SYM .V> -1>
			 <SET TEM <GET-CURRENT-TYPE .V>>
			 <COND (<OR .ALL <N==? .TEM NO-RETURN>>
				<SET LP <REST <PUTREST .LP ((.V .TEM T))>>>)>)>
		  <SET V <NEXT-SYM .V>>>)
	 (ELSE ())>>

<DEFINE RESET-VARS (V "OPTIONAL" (VL '[]) (FLG <>)) 
	#DECL ((V VL) <OR SYMTAB VECTOR>)
	<REPEAT ()
		<COND (<==? .V .VL> <SET FLG T>)>
		<COND (<EMPTY? .V> <RETURN>)
		      (<NOT .FLG>
		       <PUT .V ,CURRENT-TYPE <>>
		       <PUT .V ,COMPOSIT-TYPE ANY>)>
		<PUT .V ,DEATH-LIST ()>
		<SET V <NEXT-SYM .V>>>>

<DEFINE GET-CURRENT-TYPE (SYM) 
	#DECL ((SYM) SYMTAB)
	<COND (<AND .ANALY-OK <CURRENT-TYPE .SYM>>) (ELSE <DECL-SYM .SYM>)>>

<DEFINE SET-CURRENT-TYPE (SYM ITYP "AUX" (OTYP <DECL-SYM .SYM>)) 
	#DECL ((SYM) SYMTAB)
	<COND (<AND .ANALY-OK <N==? <CODE-SYM .SYM> -1>>
	       <PUT .SYM ,CURRENT-TYPE <TYPE-AND .ITYP .OTYP>>
	       <PUT .SYM
		    ,COMPOSIT-TYPE
		    <TYPE-MERGE .ITYP <COMPOSIT-TYPE .SYM>>>)
	      (ELSE
	       <PUT .SYM ,CURRENT-TYPE <>>
	       <PUT .SYM ,COMPOSIT-TYPE .OTYP>)>>

<DEFINE ANDUPC (V L) 
	#DECL ((V) <OR VECTOR SYMTAB> (L) <LIST [REST <LIST SYMTAB ANY ANY>]>)
	<REPEAT (TMP)
		<COND (<EMPTY? .V> <RETURN>)>
		<COND (<AND <SET TMP <CURRENT-TYPE .V>> <N==? .TMP NO-RETURN>>
		       <SET L <ADD-TYPE-LIST .V <CURRENT-TYPE .V> .L T>>)>
		<SET V <NEXT-SYM .V>>>
	.L>

<DEFINE ANDUP (FROM TO) 
	#DECL ((TO FROM) <LIST [REST <LIST SYMTAB ANY ANY>]>)
	<MAPF <>
	      <FUNCTION (L) <SET TO <ADD-TYPE-LIST <1 .L> <2 .L> .TO T>>>
	      .FROM>
	.TO>

<DEFINE ORUPC (V L "AUX" WIN) 
   #DECL ((V) <OR VECTOR SYMTAB> (L) <LIST [REST <LIST SYMTAB ANY ANY>]>)
   <COND
    (.ANALY-OK
     <REPEAT ()
       <COND (<TYPE? .V VECTOR> <RETURN>)>
       <SET WIN <>>
       <MAPF <>
	<FUNCTION (LL) 
		#DECL ((LL) <LIST SYMTAB <OR ATOM FORM SEGMENT> ANY>)
		<COND (<==? <1 .LL> .V>
		       <PUT .LL 2 <TYPE-MERGE <2 .LL> <GET-CURRENT-TYPE .V>>>
		       <PUT .LL 3 T>
		       <MAPLEAVE <SET WIN T>>)>>
	.L>
       <COND (<AND <NOT .WIN> <CURRENT-TYPE .V>>
	      <SET L ((.V <DECL-SYM .V> T) !.L)>)>
       <SET V <NEXT-SYM .V>>>)>
   .L>

<DEFINE ORUP (FROM TO "AUX" NDECL (TOTUP <STACK <VECTOR !.TO>>)) 
   #DECL ((TO FROM)
	  <LIST [REST <LIST SYMTAB <OR ATOM FORM SEGMENT> <OR ATOM FALSE>>]>
	  (TOTUP) <<PRIMTYPE VECTOR>
		   [REST <OR <LIST SYMTAB <OR ATOM FORM SEGMENT>
				   <OR ATOM FALSE>>
			     FALSE>]>
	  (NDECL)
	  <OR ATOM FORM SEGMENT>)
   <MAPF <>
    <FUNCTION (L "AUX" (SYM <1 .L>) (WIN <>)) 
	    <MAPR <>
		  <FUNCTION (TP "AUX" (LL <1 .TP>)) 
			  <COND (<AND .LL <==? <1 .LL> .SYM>>
				 <SET NDECL <TYPE-MERGE <2 .LL> <2 .L>>>
				 <PUT .LL 2 .NDECL>
				 <PUT .LL 3 <3 .LL>>
				 <PUT .TP 1 <>>
				 <MAPLEAVE <SET WIN T>>)>>
		  .TOTUP>
	    <COND (<NOT .WIN>
		   <SET TO
			((.SYM
			  <TYPE-MERGE <GET-CURRENT-TYPE .SYM> <2 .L>>
			  <3 .L>)
			 !.TO)>)>>
    .FROM>
   <MAPF <>
	 <FUNCTION (LL) #DECL ((LL) <OR FALSE LIST>)
	      <COND (.LL
		     <PUT .LL 2 <TYPE-MERGE <GET-CURRENT-TYPE <1 .LL>>
					    <2 .LL>>>)>>
	 .TOTUP>
   .TO>

<DEFINE ASSERT-TYPES (L) 
	#DECL ((L) <LIST [REST <LIST SYMTAB ANY ANY>]>)
	<MAPF <> <FUNCTION (LL) <SET-CURRENT-TYPE <1 .LL> <2 .LL>>> .L>>

<DEFINE ADD-TYPE-LIST (SYM NDECL INF MUNG
		       "OPTIONAL" (NTH-REST ())
		       "AUX" (WIN <>) (OD <GET-CURRENT-TYPE .SYM>))
   #DECL ((SYM) SYMTAB (INF) LIST (NTH-REST) <LIST [REST ATOM FIX]>
	  (NDECL) <OR ATOM FALSE FORM SEGMENT> (MUNG) <OR ATOM FALSE>)
   <COND (.ANALY-OK
	  <SET NDECL <TYPE-NTH-REST .NDECL .NTH-REST>>
	  <MAPF <>
		<FUNCTION (L) 
			#DECL ((L) <LIST SYMTAB ANY>)
			<COND (<==? <1 .L> .SYM>
			       <SET NDECL
				    <COND (.MUNG <TYPE-AND .NDECL .OD>)
					  (ELSE <TYPE-AND .NDECL <2 .L>>)>>
			       <PUT .L 2 .NDECL>
			       <PUT .L 3 .MUNG>
			       <MAPLEAVE <SET WIN T>>)>>
		.INF>
	  <COND (<NOT .WIN>
		 <SET NDECL <TYPE-AND .NDECL .OD>>
		 <SET INF ((.SYM .NDECL .MUNG) !.INF)>)>)>
   .INF>

<DEFINE TYPE-NTH-REST (NDECL NTH-REST) 
	#DECL ((NTH-REST) <LIST [REST ATOM FIX]>)
	<REPEAT ((FIRST T) (NUM 0))
		#DECL ((NUM) FIX)
		<COND (<EMPTY? .NTH-REST> <RETURN .NDECL>)>
		<COND (<==? <1 .NTH-REST> NTH>
		       <SET NDECL
			    <FORM STRUCTURED
				  !<COND (<0? <SET NUM
						   <+ .NUM <2 .NTH-REST> -1>>>
					  ())
					 (<1? .NUM> (ANY))
					 (ELSE ([.NUM ANY]))>
				  .NDECL>>
		       <SET NUM 0>
		       <SET FIRST <>>)
		      (.FIRST <SET NDECL <REST-DECL .NDECL <2 .NTH-REST>>>)
		      (ELSE <SET NUM <+ .NUM <2 .NTH-REST>>>)>
		<SET NTH-REST <REST .NTH-REST 2>>>>

" AND/OR analyzer.  Called from AND-ANA and OR-ANA."

<DEFINE BOOL-AN (NOD RTYP ORER
		 "AUX" (L <KIDS .NOD>) FTYP FTY
		       (RTY
			<COND (<TYPE-OK? .RTYP FALSE> .RTYP)
			      (ELSE <FORM OR .RTYP FALSE>)>)
		       (FLG <==? .PRED <PARENT .NOD>>) (SINF ()) STR SUNT
		       (FIRST T) FNOK NFNOK PASS)
   #DECL ((NOD) NODE (L) <LIST [REST NODE]> (ORER RTYP) ANY (FTYP) FORM
	  (STR SINF SUNT) LIST)
   <PROG ((TRUTH ()) (UNTRUTH ()) (PRED .NOD) L-D)
     #DECL ((TRUTH UNTRUTH) <SPECIAL LIST> (PRED) <SPECIAL ANY> (L-D) LIST)
     <COND
      (<EMPTY? .L> <SET FTYP <TYPE-OK? FALSE .RTYP>>)
      (ELSE
       <SET FTY
	<MAPR ,TYPE-MERGE
	 <FUNCTION (N "AUX" (LAST <EMPTY? <REST .N>>) TY) 
	    #DECL ((N) <LIST NODE>)
	    <COND (<AND .LAST <NOT .FLG>> <SET PRED <>>)>
	    <SET TY <ANA <1 .N> <COND (.LAST .RTYP) (.ORER .RTY) (ELSE ANY)>>>
	    ; "FNOK seems to mean that this clause of the boolean can't
	       return false; NFNOK means it always returns false"
	    <SET FNOK <OR <==? .TY NO-RETURN> <NOT <TYPE-OK? .TY FALSE>>>>
	    <SET NFNOK <==? FALSE <ISTYPE? .TY>>>
	    ; "Therefore, PASS means this clause's result doesn't need to be
	       tested, because we'll always go to the next clause."
	    <SET PASS <COND (.ORER .NFNOK) (ELSE .FNOK)>>
	    <COND (<NOT .TY>
		   <SET TY ANY>
		   <COMPILE-WARNING "OR/AND clause returns wrong type: "
				    <1 .N>>)>
	    <COND
	     (<COND (.ORER .FNOK) (ELSE .NFNOK)>
	      ; "If OR, and FNOK, this will terminate the whole thing, etc..."
	      <COND
	       (<AND .VERBOSE <NOT .LAST>>
		<ADDVMESS .NOD
			  ("This object prematurely ends AND/OR:  "
			   <1 .N>
			   !<COND (<==? .TY NO-RETURN> '(" it never returns "))
				  (ELSE (" its type is:  " .TY))>)>)>
	      <SET LAST T>)>
	    <COND
	     (<AND <N==? .TY NO-RETURN> <NOT .PASS>>
	      ; "This clause actually returns an interesting condition..."
	      <COND (.FIRST
		     <SET L-D <SAVE-L-D-STATE .VARTBL>>
		     <SET STR <ANDUP <COPY-TYPE-LIST .TRUTH>
				     <BUILD-TYPE-LIST .VARTBL <>>>>
		     <SET SUNT <ANDUP <COPY-TYPE-LIST .UNTRUTH>
				      <BUILD-TYPE-LIST .VARTBL <>>>>
		     <SET SINF
			  <ANDUP <COND (.ORER .TRUTH) (ELSE .UNTRUTH)>
				 <BUILD-TYPE-LIST .VARTBL>>>)
		    (ELSE
		     <SET L-D <MSAVE-L-D-STATE .L-D .VARTBL>>
		     <COND (.ORER
			    <SET SUNT <ANDUP .UNTRUTH <ANDUPC .VARTBL .SUNT>>>
			    <SET STR <ORUP .STR .TRUTH>>)
			   (ELSE
			    <SET SUNT <ORUP .SUNT .UNTRUTH>>
			    <SET STR <ANDUP .TRUTH <ANDUPC .VARTBL .STR>>>)>
		     <SET SINF
			  <ORUP <COND (.ORER .TRUTH) (ELSE .UNTRUTH)>
				<ORUPC .VARTBL .SINF>>>)>
	      <SET FIRST <>>)
	     (<NOT .FIRST>
	      <COND (.ORER <SET SUNT <ANDUPC .VARTBL .SUNT>>)
		    (ELSE <SET STR <ANDUPC .VARTBL .STR>>)>
	      <SET SINF <ORUPC .VARTBL .SINF>>)
	     (T
	      <SET STR <ANDUP <COPY-TYPE-LIST .TRUTH>
			      <BUILD-TYPE-LIST .VARTBL <>>>>
	      <SET SUNT <ANDUP <COPY-TYPE-LIST .UNTRUTH>
			       <BUILD-TYPE-LIST .VARTBL <>>>>
	      <SET SINF <ANDUP <COND (.ORER .TRUTH) (T .UNTRUTH)>
			       <BUILD-TYPE-LIST .VARTBL>>>
	      <SET FIRST <>>)>
	    <ASSERT-TYPES <COND (.ORER .SUNT) (ELSE .STR)>>
	    <SET TRUTH <SET UNTRUTH ()>>
	    <OR .FIRST <RESTORE-L-D-STATE .L-D .VARTBL>>
	    <COND (<==? .TY NO-RETURN>
		   <COND (<NOT .LAST>
			  <COMPILE-WARNING "AND/OR clause is unreachable: "
					   <1 .N>>)>
		   <SET FLG <>>
		   <ASSERT-TYPES .SINF>
		   <MAPSTOP NO-RETURN>)
		  (.LAST <ASSERT-TYPES <ORUPC .VARTBL .SINF>> <MAPSTOP .TY>)
		  (<AND .ORER .NFNOK> <MAPRET>)
		  (.ORER .TY)
		  (.FNOK <MAPRET>)
		  (ELSE FALSE)>>
	 .L>>
       <COND (<AND .FNOK .ORER> <SET FTY <TYPE-OK? .FTY '<NOT FALSE>>>)>)>>
   <COND (.FLG <SET TRUTH .STR> <SET UNTRUTH .SUNT>)>
   .FTY>

<DEFINE COPY-TYPE-LIST (L) 
	#DECL ((L) LIST)
	<MAPF ,LIST
	      <FUNCTION (LL) 
		      #DECL ((LL) <LIST ANY ANY ANY>)
		      (<1 .LL> <2 .LL> <3 .LL>)>
	      .L>>

<DEFINE AND-ANA (NOD RTYP) 
	#DECL ((NOD) NODE)
	<PUT .NOD ,NODE-TYPE ,AND-CODE>
	<BOOL-AN .NOD .RTYP <>>>

<COND (<GASSIGNED? AND-ANA> <PUTPROP ,AND ANALYSIS ,AND-ANA>)>

<DEFINE OR-ANA (NOD RTYP) 
	#DECL ((NOD) NODE)
	<PUT .NOD ,NODE-TYPE ,OR-CODE>
	<BOOL-AN .NOD .RTYP T>>

<COND (<GASSIGNED? OR-ANA> <PUTPROP ,OR ANALYSIS ,OR-ANA>)>

" COND analyzer."

<DEFINE CASE-ANA (N R) <COND-CASE .N .R T>>

<DEFINE COND-ANA (N R) <COND-CASE .N .R <>>>


<DEFINE COND-CASE (NOD RTYP CASE?
		   "AUX" (L <KIDS .NOD>) (FIRST T) (LAST <>) TT FNOK NFNOK STR
			 SUNT (FIRST1 T) PRAT (DFLG <>) TST-TYP SVWHO
			 (PRED-FLG <==? .PRED <PARENT .NOD>>))
   #DECL ((NOD) NODE (L) <LIST [REST NODE]> (RTYP) ANY)
   <PROG ((TRUTH ()) (UNTRUTH ()) (TINF1 ()) (TINF ()) L-D L-D1 (PRED .PRED))
     #DECL ((TRUTH UNTRUTH) <SPECIAL LIST> (TINF1 TINF L-D L-D1) LIST
	    (PRED) <SPECIAL <OR FALSE NODE>>)
     <COND
      (<EMPTY? .L> <TYPE-OK? FALSE .RTYP>)
      (ELSE
       <COND (.CASE?
	      <SET PRAT <NODE-NAME <1 <KIDS <1 .L>>>>>
	      <PROG ((WHON .NOD) (WHO ()))
		    #DECL ((WHO) <SPECIAL LIST> (WHON) <SPECIAL NODE>)
		    <SET TST-TYP <EANA <2 .L> ANY CASE>>
		    <SET SVWHO .WHO>>
	      <SET L <REST .L 2>>)>
       <SET TT
	<MAPR ,TYPE-MERGE
	 <FUNCTION (BRN "AUX" (BR <1 .BRN>) (EC T) STR1 SUNT1) 
	    #DECL ((BRN) <LIST NODE> (BR) NODE)
	    <COND (<N==? <NODE-TYPE .BR> ,QUOTE-CODE>
		   <PUT .BR ,SIDE-EFFECTS <>>)>
	    <SET PRED .BR>
	    <COND (<AND .CASE? <==? <NODE-TYPE .BR> ,QUOTE-CODE> <SET DFLG T>>
		   <MAPRET>)>
	    <COND (<NOT <PREDIC .BR>>
		   <COMPILE-ERROR "Empty COND clause: " .BR>)>
	    <SET UNTRUTH <SET TRUTH ()>>
	    <SET LAST <EMPTY? <REST .BRN>>>
	    <SET TT
		 <COND (<NOT <EMPTY? <CLAUSES .BR>>> <SET EC <>> ANY)
		       (.LAST .RTYP)
		       (ELSE <TYPE-MERGE .RTYP FALSE>)>>
	    <SET TT
		 <COND (.CASE?
			<SPEC-ANA <NODE-NAME <CHTYPE <PREDIC .BR> NODE>>
				  .PRAT
				  .TST-TYP
				  .TT
				  .DFLG
				  .BR
				  .SVWHO>)
		       (ELSE <ANA <PREDIC .BR> .TT>)>>
	    <SET DFLG <SET PRED <>>>
	    <SET FNOK <OR <==? .TT NO-RETURN> <NOT <TYPE-OK? .TT FALSE>>>>
	    <SET NFNOK <==? <ISTYPE? .TT> FALSE>>
	    <COND
	     (.VERBOSE
	      <COND
	       (.NFNOK
		<ADDVMESS
		 .NOD
		 ("Cond predicate always FALSE:  "
		  <PREDIC .BR>
		  !<COND (<EMPTY? <CLAUSES .BR>> ())
			 (ELSE (" and non-reachable code in clause."))>)>)>
	      <COND
	       (<AND .FNOK <NOT .LAST>>
		<ADDVMESS
		 .NOD
		 ("Cond ended prematurely because predicate always true:  "
		  <PREDIC .BR>
		  " type of value:  "
		  .TT)>)>)>
	    <COND (.PRED-FLG
		   <SET STR1 <ANDUP <COPY-TYPE-LIST .TRUTH>
				    <BUILD-TYPE-LIST .VARTBL <>>>>
		   <SET SUNT1 <ANDUP <COPY-TYPE-LIST .UNTRUTH>
				     <BUILD-TYPE-LIST .VARTBL <>>>>)>
	    <COND (<NOT <OR .FNOK <AND <NOT .LAST> .NFNOK>>>
		   <SET L-D <SAVE-L-D-STATE .VARTBL>>
		   <COND (.FIRST
			  <SET TINF
			       <ANDUP .UNTRUTH <BUILD-TYPE-LIST .VARTBL>>>)
			 (ELSE
			  <SET TINF <ANDUP .UNTRUTH <ORUPC .VARTBL .TINF>>>)>
		   <COND (<NOT .EC> <ASSERT-TYPES .TRUTH>)>
		   <SET FIRST <>>)>
	    <COND (<AND <NOT .NFNOK>
			<OR .EC <SET TT <SEQ-AN <CLAUSES .BR>
						.RTYP .PRED-FLG>>>>
		   <COND (<N==? .TT NO-RETURN>
			  <COND (.PRED-FLG
				 <COND (.EC
					<COND (.FIRST1
					       <SET STR .STR1>
					       <SET SUNT .SUNT1>)
					      (ELSE
					       <SET STR <ORUP .STR .STR1>>
					       <SET SUNT
						    <ANDUP .SUNT .SUNT1>>)>)
				       (.FIRST1
					<SET STR
					     <ANDUP .TRUTH
						    <ANDUPC .VARTBL .STR1>>>
					<SET SUNT <ORUP .SUNT1 .UNTRUTH>>)
				       (ELSE
					<SET STR <ORUP .STR
						       <ANDUP .TRUTH
							      .STR1>>>
					<SET SUNT
					     <ANDUP .SUNT
						    <ORUP .SUNT1 .UNTRUTH>>>)>)>
			  <COND (.FIRST1
				 <SET TINF1 <BUILD-TYPE-LIST .VARTBL>>
				 <SET L-D1 <SAVE-L-D-STATE .VARTBL>>)
				(ELSE
				 <SET TINF1 <ORUPC .VARTBL .TINF1>>
				 <SET L-D1 <MSAVE-L-D-STATE .L-D1 .VARTBL>>)>
			  <SET FIRST1 <>>)>
		   <OR .FIRST <RESTORE-L-D-STATE .L-D .VARTBL>>
		   <COND (.LAST
			  <AND <NOT .FNOK> <SET TT <TYPE-MERGE .TT FALSE>>>)
			 (.EC <SET TT <TYPE-OK? .TT '<NOT FALSE>>>)>)
		  (.NFNOK <SET TT FALSE>)>
	    <UPDATE-SIDE-EFFECTS .BR .NOD>
	    <COND
	     (<AND <OR .LAST .FNOK> .TT>
	      <COND (.FNOK
		     <ASSERT-TYPES .TINF1>
		     <OR .FIRST1 <RESTORE-L-D-STATE .L-D1 .VARTBL>>)
		    (ELSE
		     <COND (.FIRST1
			    <ASSERT-TYPES .TINF>
			    <OR .FIRST <RESTORE-L-D-STATE .L-D .VARTBL>>)
			   (ELSE
			    <ASSERT-TYPES <ORUP .TINF .TINF1>>
			    <MRESTORE-L-D-STATE .L-D1 .L-D .VARTBL>)>)>
	      <MAPSTOP .TT>)
	     (.TT <ASSERT-TYPES .TINF> .TT)
	     
	     (ELSE <ASSERT-TYPES .TINF> <MAPRET>)>>
	 .L>>)>>
   <COND (.PRED-FLG
	  <SET TRUTH .STR>
	  <SET UNTRUTH .SUNT>)>
   .TT>

" PROG/REPEAT analyzer.  Hacks bindings and sets up info for GO/RETURN/AGAIN
  analyzers."

<DEFINE PRG-REP-ANA (PPNOD RT
		     "AUX" (OV .VARTBL) (VARTBL <SYMTAB .PPNOD>) TT L-D
			   (OPN <AND <ASSIGNED? PNOD> .PNOD>) PNOD PRTYP)
   #DECL ((PNOD) <SPECIAL NODE> (VARTBL) <SPECIAL SYMTAB> (OV) SYMTAB
	  (L-D) LIST (PPNOD) NODE)
   <COND (<N==? <NODE-SUBR .PPNOD> ,BIND> <SET PNOD .PPNOD>)
	 (.OPN <SET PNOD .OPN>)>
   <PROG ((TMPS 0) (HTMPS 0) (ACT? <ACTIV? <BINDING-STRUCTURE .PPNOD> T>))
     #DECL ((TMPS HTMPS) <SPECIAL FIX>)
     <BIND-AN <BINDING-STRUCTURE .PPNOD>>
     <SET L-D <SAVE-L-D-STATE .VARTBL>>
     <RESET-VARS .VARTBL .OV T>
     <COND (<NOT <SET PRTYP <TYPE-OK? .RT <INIT-DECL-TYPE .PPNOD>>>>
	    <COMPILE-ERROR 
"Required type of PROG/REPEAT call violates its decl."
			   "Required type is "
			   .RT
			   " and value decl is "
			   <INIT-DECL-TYPE .PPNOD>>)>
     <PUT .PPNOD ,RESULT-TYPE .PRTYP>
     <PROG ((STMPS .TMPS) (SHTMPS .HTMPS) (LL .LIFE) (OV .VERBOSE))
       #DECL ((STMPS SHTMPS) FIX (LL LIFE) LIST)
       <COND (.VERBOSE <PUTREST <SET VERBOSE .OV> ()>)>
       <MUNG-L-D-STATE .VARTBL>
       <SET LIFE .LL>
       <PUT .PPNOD ,AGND <>>
       <PUT .PPNOD ,DEAD-VARS ()>
       <PUT .PPNOD ,VSPCD ()>
       <PUT .PPNOD ,LIVE-VARS ()>
       <SET TMPS .STMPS>
       <SET HTMPS .SHTMPS>
       <PUT .PPNOD ,ASSUM <BUILD-TYPE-LIST .VARTBL>>
       <PUT .PPNOD ,ACCUM-TYPE NO-RETURN>
       <SET TT
	    <SEQ-AN <KIDS .PPNOD>
		    <COND (<N==? <NODE-SUBR .PPNOD> ,REPEAT> .PRTYP)
			  (ELSE ANY)>>>
       <COND (.ACT? <SPEC-FLUSH> <PUT-FLUSH ALL>)>
       <COND
	(<OR .ACT? <==? <NODE-SUBR .PPNOD> ,REPEAT> <AGND .PPNOD>>
	 <COND
	  (<NOT <ASSUM-OK? <ASSUM .PPNOD>
			   <COND (<AND <N==? <NODE-SUBR .PPNOD> ,REPEAT>
				       <AGND .PPNOD>>
				  <AGND .PPNOD>)
				 (<AGND .PPNOD>
				  <ORUPC .VARTBL <CHTYPE <AGND .PPNOD> LIST>>)
				 (ELSE <BUILD-TYPE-LIST .VARTBL>)>>>
	   <AGAIN>)>)
	(<AND <NOT .ACT?> <SET ACT? <ACTIV? <BINDING-STRUCTURE .PPNOD> T>>>
	 <ASSERT-TYPES <ASSUM .PPNOD>>
	 <AGAIN>)>>
     <COND (<==? <NODE-SUBR .PPNOD> ,REPEAT>
	    <COND (<AGND .PPNOD>
		   <PUT .PPNOD
			,LIVE-VARS
			<MSAVE-L-D-STATE <LIVE-VARS .PPNOD> .VARTBL>>)
		  (ELSE <PUT .PPNOD ,LIVE-VARS <SAVE-L-D-STATE .VARTBL>>)>)>
     <SAVE-SURVIVORS .L-D .LIFE T>
     <SAVE-SURVIVORS <LIVE-VARS .PPNOD> .LIFE>
     <COND (<NOT .TT>
	    <COMPILE-ERROR "PROG/REPEAT returns incorrect type "
			   .PRTYP
			   .PPNOD>)>
     <COND (<NOT <OR <==? .TT NO-RETURN> <==? <NODE-SUBR .PPNOD> ,REPEAT>>>
	    <PUT .PPNOD
		 ,DEAD-VARS
		 <MSAVE-L-D-STATE <DEAD-VARS .PPNOD> .VARTBL>>
	    <COND (<N==? <ACCUM-TYPE .PPNOD> NO-RETURN>
		   <ASSERT-TYPES <ORUPC .VARTBL <VSPCD .PPNOD>>>)>)
	   (<N==? <ACCUM-TYPE .PPNOD> NO-RETURN>
	    <ASSERT-TYPES <VSPCD .PPNOD>>)>
     <FREST-L-D-STATE <DEAD-VARS .PPNOD>>
     <SET LIFE <KILL-REM .LIFE .OV>>
     <PUT .PPNOD
	  ,ACCUM-TYPE
	  <COND (.ACT? <PUT .PPNOD ,SIDE-EFFECTS (ALL)> .PRTYP)
		(<==? <NODE-SUBR .PPNOD> ,REPEAT> <ACCUM-TYPE .PPNOD>)
		(ELSE <TYPE-MERGE .TT <ACCUM-TYPE .PPNOD>>)>>>
   <ACCUM-TYPE .PPNOD>>

" Determine if assumptions made for this loop are still valid."

<DEFINE ASSUM-OK? (AS TY "AUX" (OK? T)) 
   #DECL ((TY AS) <LIST [REST <LIST SYMTAB ANY ANY>]>)
   <COND
    (.ANALY-OK
     <MAPF <>
      <FUNCTION (L "AUX" (SYM <1 .L>) (TT <>)) 
	 #DECL ((L) <LIST SYMTAB <OR ATOM FORM SEGMENT>>)
	 <COND
	  (<N==? <2 .L> ANY>
	   <MAPF <>
	    <FUNCTION (LL) 
		    <COND (<AND <SET TT <==? <1 .LL> .SYM>>
				<N=? <2 .L> <2 .LL>>
				<OR <==? <2 .L> NO-RETURN>
				    <TYPE-OK? <2 .LL> <NOTIFY <2 .L>>>>>
			   <COND (.OK?
				  <SET BACKTRACK <+ .BACKTRACK 1>>
				  <COND (,STATUS-LINE
					 <UPDATE-STATUS "Comp" <> "ANA"
							.BACKTRACK>)>)>
			   <SET OK? <>>
			   <AND <GASSIGNED? DEBUGSW>
				,DEBUGSW
				<PRIN1 <NAME-SYM .SYM>>
				<PRINC " NOT OK current type:  ">
				<PRIN1 <2 .LL>>
				<PRINC " assumed type:  ">
				<PRIN1 <2 .L>>
				<CRLF>>)>
		    <AND .TT
			 <PUT .L 2 <TYPE-MERGE <2 .LL> <2 .L>>>
			 <MAPLEAVE>>>
	    .TY>)>>
      .AS>
     <COND (<NOT .OK?> <ASSERT-TYPES .AS>)>)>
   .OK?>

<DEFINE NOTIFY (D) 
	<COND (<AND <TYPE? .D FORM> <==? <LENGTH .D> 2> <==? <1 .D> NOT>>
	       <2 .D>)
	      (ELSE <FORM NOT .D>)>>

" Analyze RETURN from a PROG/REPEAT.  Check with PROGs final type."

<DEFINE RETURN-ANA (NOD RTYP "AUX" (TT <KIDS .NOD>) N (LN <LENGTH .TT>) TEM) 
	#DECL ((NOD) NODE (TT) <LIST [REST NODE]> (LN) FIX (N) <OR NODE
								   FALSE>)
	<SET RET-OR-AGAIN T>
	<COND (<G? .LN 2> <COMPILE-ERROR "Too many args to RETURN." .NOD>)
	      (<OR <AND <==? .LN 2> <SET N <ACT-CHECK <2 .TT>>>>
		   <AND <L=? .LN 1> <SET N <PROGCHK RETURN .NOD>>>>
	       <SET N <CHTYPE .N NODE>>
	       <AND <0? .LN>
		    <PUT .NOD
			 ,KIDS
			 <SET TT (<NODE1 ,QUOTE-CODE .NOD ATOM T ()>)>>>
	       <SET TEM <EANA <1 .TT> <INIT-DECL-TYPE .N> RETURN>>
	       <COND (<==? <ACCUM-TYPE .N> NO-RETURN>
		      <PUT .N ,VSPCD <BUILD-TYPE-LIST <SYMTAB .N>>>
		      <PUT .N ,DEAD-VARS <SAVE-L-D-STATE .VARTBL>>)
		     (ELSE
		      <PUT .N ,VSPCD <ORUPC <SYMTAB .N> <VSPCD .N>>>
		      <PUT .N
			   ,DEAD-VARS
			   <MSAVE-L-D-STATE <DEAD-VARS .N> .VARTBL>>)>
	       <PUT .N ,ACCUM-TYPE <TYPE-MERGE .TEM <ACCUM-TYPE .N>>>
	       <PUT .NOD ,NODE-TYPE ,RETURN-CODE>
	       NO-RETURN)
	      (ELSE <SUBR-C-AN .NOD ANY>)>>

<COND (<GASSIGNED? RETURN-ANA> <PUTPROP ,RETURN ANALYSIS ,RETURN-ANA>)>

<DEFINE MULTI-RETURN-ANA (NOD RTYP
			  "AUX" (TT <KIDS .NOD>) N (LN <LENGTH .TT>) TEM
				(SEG <>) (TYPS <FORM MULTI>)
				(TP <CHTYPE .TYPS LIST>))
	#DECL ((NOD) NODE (TT) <LIST [REST NODE]> (LN) FIX (N) <OR NODE
								   FALSE>)
	<COND (<L? .LN 1> <COMPILE-ERROR "Too few args to MULTI-RETURN." .NOD>)
	      (ELSE
	       <COND (<AND <==? <NODE-TYPE <SET N <1 .TT>>> ,QUOTE-CODE>
			   <==? <NODE-NAME .N> <>>>
		      <SET N <PROGCHK MULTI-RETURN .N>>)
		     (<SET N <ACT-CHECK .N>>)
		     (ELSE <EANA <1 .TT> '<OR FRAME T$FRAME> MULTI-RETURN>)>
	       <MAPR <>
		     <FUNCTION (NP "AUX" (NN <1 .NP>) TY) 
			     #DECL ((NN) NODE)
			     <COND (<==? <NODE-TYPE .NN> ,SEGMENT-CODE>
				    <SET TY
					 <EANA <1 <KIDS .NN>>
					       '<OR MULTI STRUCTURED>
					       MULTI-RETURN>>
				    <COND (<AND <N==? .TY ANY>
						<N==? <SET TY
							   <GET-ELE-TYPE .TY ALL>>
						      ANY>>
					   <COND (<AND <NOT .SEG>
						       <EMPTY? <REST .NP>>>
						  <PUTREST .TP ([REST .TY])>)
						 (<AND <EMPTY? <REST .NP>>
						       <N==? .SEG ANY>>
						  <PUTREST .TP
							   ([REST
							     <TYPE-MERGE .SEG
									 .TY>])>)
						 (<N==? .SEG ANY>
						  <SET SEG
						       <TYPE-MERGE .SEG .TY>>)>)
					  (ELSE <SET SEG ANY>)>)
				   (ELSE
				    <SET TY <EANA .NN ANY MULTI-RETURN>>
				    <COND (<NOT .SEG>
					   <PUTREST .TP <SET TP (.TY)>>)>)>>
		     <REST .TT>>
	       <COND (<AND .N <==? <ACCUM-TYPE .N> NO-RETURN>>
		      <PUT .N ,VSPCD <BUILD-TYPE-LIST <SYMTAB .N>>>
		      <PUT .N ,DEAD-VARS <SAVE-L-D-STATE .VARTBL>>)
		     (.N
		      <PUT .N ,VSPCD <ORUPC <SYMTAB .N> <VSPCD .N>>>
		      <PUT .N
			   ,DEAD-VARS
			   <MSAVE-L-D-STATE <DEAD-VARS .N> .VARTBL>>)>
	       <COND (.N <PUT .N ,ACCUM-TYPE <TYPE-MERGE .TYPS
							 <ACCUM-TYPE .N>>>)>
	       <PUT .NOD ,NODE-TYPE ,MULTI-RETURN-CODE>
	       NO-RETURN)>>

<COND (<AND <GASSIGNED? MULTI-RETURN> <GASSIGNED? MULTI-RETURN-ANA>>
       <PUTPROP ,MULTI-RETURN ANALYSIS ,MULTI-RETURN-ANA>)>

<DEFINE ACT-CHECK (N "OPT" (RETMNG T) "AUX" SYM RAO N1 (NT <NODE-TYPE .N>)) 
	#DECL ((N N1) NODE (SYM) <OR SYMTAB FALSE> (RAO VALUE) <OR FALSE NODE>
	       (NT) FIX)
	<COND (<OR <AND <==? .NT ,LVAL-CODE>
			<TYPE? <NODE-NAME .N> SYMTAB>
			<PURE-SYM <SET SYM <NODE-NAME .N>>>
			<==? <CODE-SYM .SYM> 1>>
		   <AND <OR <==? .NT ,RSUBR-CODE> <==? .NT ,SUBR-CODE>>
			<==? <NODE-SUBR .N> ,LVAL>
			<==? <LENGTH <KIDS .N>> 1>
			<==? <NODE-TYPE <SET N1 <1 <KIDS .N>>>> ,QUOTE-CODE>
			<TYPE? <NODE-NAME .N1> ATOM>
			<SET SYM <SRCH-SYM <NODE-NAME .N1>>>
			<PURE-SYM .SYM>
			<==? <CODE-SYM .SYM> 1>>>
	       <SET RAO <RET-AGAIN-ONLY <CHTYPE .SYM SYMTAB>>>
	       <EANA .N FRAME AGAIN-RETURN>
	       <COND (.RETMNG <PUT <CHTYPE .SYM SYMTAB> ,RET-AGAIN-ONLY .RAO>)>
	       .RAO)>>

" AGAIN analyzer."

<DEFINE AGAIN-ANA (NOD RTYP "AUX" (TEM <KIDS .NOD>) N) 
	#DECL ((NOD) NODE (TEM) <LIST [REST NODE]> (N) <OR FALSE NODE>)
	<SET RET-OR-AGAIN T>
	<COND (<OR <AND <EMPTY? .TEM> <SET N <PROGCHK AGAIN .NOD>>>
		   <AND <EMPTY? <REST .TEM>> <SET N <ACT-CHECK <1 .TEM>>>>>
	       <PUT .NOD ,NODE-TYPE ,AGAIN-CODE>
	       <SET N <CHTYPE .N NODE>>
	       <COND (<AGND .N>
		      <PUT .N
			   ,LIVE-VARS
			   <MSAVE-L-D-STATE <LIVE-VARS .N> .VARTBL>>)
		     (ELSE <PUT .N ,LIVE-VARS <SAVE-L-D-STATE .VARTBL>>)>
	       <PUT .N
		    ,AGND
		    <COND (<NOT <AGND .N>> <BUILD-TYPE-LIST <SYMTAB .N>>)
			  (ELSE <ORUPC <SYMTAB .N> <AGND .N>>)>>
	       NO-RETURN)
	      (<EMPTY? <REST .TEM>>
	       <COND (<NOT <ANA <1 .TEM> FRAME>>
		      <COMPILE-ERROR "Again not passed an activation" .NOD>)>
	       ANY)
	      (ELSE <COMPILE-ERROR "Too many arguments to AGAIN" .NOD>)>>

<COND (<GASSIGNED? AGAIN-ANA> <PUTPROP ,AGAIN ANALYSIS ,AGAIN-ANA>)>

" If not in PROG/REPEAT complain about NAME."

<DEFINE PROGCHK (NAME NOD) 
	#DECL ((NOD) NODE)
	<COND (<NOT <ASSIGNED? PNOD>>
	       <COMPILE-ERROR "Not in PROG/REPEAT " .NAME .NOD>)>
	.PNOD>

" Dispatch to special handlers for SUBRs.  Or use standard."

<DEFINE SUBR-ANA (NOD RTYP) 
	#DECL ((NOD) NODE)
	<APPLY <GETPROP <NODE-SUBR .NOD> ANALYSIS ',SUBR-C-AN> .NOD .RTYP>>

" Hairy SUBR call analyzer.  Also looks for internal calls."

<DEFINE SUBR-C-AN (NOD RTYP
		   "AUX" (ARGS 0) (TYP ANY) (TMPL <GET-TMP <NODE-SUBR .NOD>>)
			 (NRGS1 <1 .TMPL>))
   #DECL ((NOD) <SPECIAL NODE> (ARGS) <SPECIAL FIX> (TYP NRGS1) <SPECIAL ANY>
	  (TMPL) <SPECIAL LIST>)
   <MAPF
    <FUNCTION ("TUPLE" T
	       "AUX" NARGS TEM (NARGS1 .NRGS1) (N .NOD) (TPL .TMPL)
		     (RGS .ARGS))
	    #DECL ((T) TUPLE (ARGS RGS TL) FIX (TMPL TPL) <LIST ANY ANY>
		   (N NOD) NODE (NARGS) <LIST FIX FIX>)
	    <SET TYP <2 .TPL>>
	    <SPEC-FLUSH>
	    <PUT-FLUSH ALL>
	    <COND (<SEGS .N>
		   <COND (<TYPE? .TYP ATOM FORM>) (ELSE <SET TYP ANY>)>)
		  (ELSE
		   <COND (<TYPE? .NARGS1 FIX>
			  <ARGCHK .RGS .NARGS1 <NODE-NAME .N> .NOD>)
			 (<TYPE? .NARGS1 LIST>
			  <COND (<G? .RGS <2 <SET NARGS .NARGS1>>>
				 <COMPILE-ERROR "Too many arguments to "
						<NODE-NAME .N>
						.N>)>
			  <COND (<L? .RGS <1 .NARGS>>
				 <COMPILE-ERROR
				  "Too few arguments to "
				  <NODE-NAME .N>
				  .N>)>)>
		   <COND (<TYPE? .TYP ATOM FORM>)
			 (ELSE <SET TYP <APPLY .TYP !.T>>)>
		   <SET ARGS .RGS>)>>
    <FUNCTION (N "AUX" TYP) 
	    #DECL ((N NOD) NODE (ARGS) FIX (ARGACS) <PRIMTYPE LIST>)
	    <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE>
		   <EANA <1 <KIDS .N>> '<OR MULTI STRUCTURED> SEGMENT>
		   <PUT .NOD ,SEGS T>
		   ANY)
		  (ELSE <SET ARGS <+ .ARGS 1>> <SET TYP <ANA .N ANY>> .TYP)>>
    <KIDS .NOD>>
   <PUT .NOD ,SIDE-EFFECTS (ALL)>
   <TYPE-OK? .TYP .RTYP>>

<DEFINE SEGMENT-ANA (NOD RTYP) 
	<COMPILE-ERROR "Illegal segment (not in form or structure)" .NOD>>

" Analyze VECTOR, UVECTOR and LIST builders."

<DEFINE COPY-AN (NOD RTYP
		 "AUX" (ARGS 0) (RT <ISTYPE? <RESULT-TYPE .NOD>>)
		       (K <KIDS .NOD>) N (LWIN <==? .RT LIST>) NN COD)
   #DECL ((NOD N) NODE (ARGS) FIX (K) <LIST [REST NODE]>)
   <COND
    (<NOT <EMPTY? .K>>
     <REPEAT (DC STY PTY TEM TT (SG <>) (FRM <FORM .RT>)
	      (FRME <CHTYPE .FRM LIST>) (GOTDC <>))
       #DECL ((FRM) FORM (FRME) <LIST ANY>)
       <COND
	(<EMPTY? .K>
	 <COND (<==? .RT LIST>
		<RETURN <SET RT
			     <COND (<EMPTY? <REST .FRM>> <1 .FRM>)
				   (ELSE .FRM)>>>)>
	 <COND (.DC <PUTREST .FRME ([REST .DC])>)
	       (.STY <PUTREST .FRME ([REST .STY])>)
	       (.PTY <PUTREST .FRME ([REST <FORM PRIMTYPE .PTY>])>)>
	 <RETURN <SET RT .FRM>>)
	(<OR <==? <SET COD <NODE-TYPE <SET N <1 .K>>>> ,SEGMENT-CODE>
	     <==? .COD ,SEG-CODE>>
	 <SET TEM <GET-ELE-TYPE <EANA <1 <KIDS .N>>
				      '<OR MULTI STRUCTURED> SEGMENT> ALL>>
	 <PUT .NOD ,SEGS T>
	 <COND (<NOT .SG> <SET GOTDC <>>)>
	 <SET SG T>
	 <COND (<AND .LWIN
		     <MEMQ <STRUCTYP <RESULT-TYPE <1 <KIDS .N>>>>
			   '[LIST VECTOR UVECTOR TUPLE]>>)
	       (ELSE <SET LWIN <>>)>)
	(ELSE <SET ARGS <+ .ARGS 2>> <SET TEM <ANA .N ANY>>)>
       <COND (<NOT .GOTDC>
	      <SET GOTDC T>
	      <SET PTY
		   <COND (<SET STY <ISTYPE? <SET DC .TEM>>> <MTYPR .STY>)>>)
	     (<OR <NOT .DC> <N==? .DC .TEM>>
	      <SET DC <>>
	      <COND (<OR <N==? <SET TT <ISTYPE? .TEM>> .STY> <NOT .STY>>
		     <SET STY <>>
		     <COND (<AND .PTY <==? .PTY <AND .TT <MTYPR .TT>>>>)
			   (ELSE <SET PTY <>>)>)>)>
       <COND (<NOT .SG> <SET FRME <REST <PUTREST .FRME (.TEM)>>>)>
       <SET K <REST .K>>>)>
   <PUT .NOD ,RESULT-TYPE .RT>
   <COND
    (<AND <GASSIGNED? COPY-LIST-CODE> .LWIN>
     <MAPF <>
	   <FUNCTION (N) 
		   #DECL ((N) NODE)
		   <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE>
			  <PUT .N ,NODE-TYPE ,SEG-CODE>)>>
	   <KIDS .NOD>>
     <COND (<AND <==? <LENGTH <SET K <KIDS .NOD>>> 1>
		 <==? <NODE-TYPE <1 .K>> ,SEG-CODE>
		 <==? <STRUCTYP <RESULT-TYPE <SET NN <1 <KIDS <1 .K>>>>>>
		      LIST>>
	    <COND (<NOT <EMPTY? <PARENT .NOD>>>
		   <MAPR <>
			 <FUNCTION (L "AUX" (N <1 .L>)) 
				 #DECL ((N) NODE (L) <LIST [REST NODE]>)
				 <COND (<==? .NOD .N>
					<PUT .L 1 .NN>
					<MAPLEAVE>)>>
			 <KIDS <CHTYPE <PARENT .NOD> NODE>>>)>
	    <PUT .NN ,PARENT <CHTYPE <PARENT .NOD> NODE>>
	    <SET RT <RESULT-TYPE .NN>>)
	   (ELSE <PUT .NOD ,NODE-TYPE ,COPY-LIST-CODE>)>)
    (ELSE
     <MAPF <>
	   <FUNCTION (N) 
		   #DECL ((N) NODE)
		   <COND (<==? <NODE-TYPE .N> ,SEG-CODE>
			  <PUT .N ,NODE-TYPE ,SEGMENT-CODE>)>>
	   <KIDS .NOD>>
     <PUT .NOD ,NODE-TYPE ,COPY-CODE>)>
   <TYPE-OK? .RT .RTYP>>

" Analyze quoted objects, for structures hack type specs."

<DEFINE QUOTE-ANA (NOD RTYP) 
	#DECL ((NOD) NODE)
	<TYPE-OK? <GEN-DECL <NODE-NAME .NOD>> .RTYP>>

<DEFINE QUOTE-ANA2 (NOD RTYP) 
	#DECL ((NOD) NODE)
	<COND (<1? <LENGTH <KIDS .NOD>>>
	       <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
	       <PUT .NOD ,NODE-NAME <1 <KIDS .NOD>>>
	       <PUT .NOD ,KIDS ()>
	       <TYPE-OK? <RESULT-TYPE .NOD> .RTYP>)
	      (ELSE <COMPILE-ERROR "Empty QUOTE?">)>>

<COND (<GASSIGNED? QUOTE-ANA2> <PUTPROP ,QUOTE ANALYSIS ,QUOTE-ANA2>)>

" Analyze a call to an RSUBR."

<DEFINE RSUBR-ANA (NOD RTYP
		   "AUX" (ARGS 0)
			 (DCL:<LIST [REST !<LIST ATOM ANY!>]> <TYPE-INFO .NOD>)
			 (SEGF <>) (MUST-EMPTY T) FRST (TUPF <>) (OPTF <>)
			 (K:<LIST [REST NODE]> <KIDS .NOD>)
			 (NM:ATOM <NODE-NAME .NOD>) (RT <>))
   #DECL ((NOD) NODE (ARGS) FIX)
   <MAPF <>
    <FUNCTION (ARG "AUX" TY ET) 
	    #DECL ((ARG NOD) NODE)
	    <COND (<NOT <EMPTY? .DCL>>
		   <COND (<==? <SET FRST <1 <SET RT <1 .DCL>>>> OPTIONAL>
			  <SET OPTF T>)
			 (<==? .FRST TUPLE> <SET TUPF T>)>
		   <SET RT <2 .RT>>
		   <SET DCL <REST .DCL>>)
		  (<NOT .TUPF> <SET OPTF <SET RT <>>>)>
	    <COND (<==? <NODE-TYPE .ARG> ,SEGMENT-CODE>
		   <SET SEGF T>
		   <SET ET
			<GET-ELE-TYPE <SET TY <ANA <1 <KIDS .ARG>> ANY>> ALL>>
		   <COND (<COND (.TUPF <TYPE-OK? <GET-ELE-TYPE .RT ALL> .ET>)
				(.RT <TYPE-OK? .RT .ET>)>)
			 (<AND <OR <NOT .RT> .TUPF .OPTF> <L=? <MINL .TY> 0>>
			  <SET MUST-EMPTY T>
			  <COMPILE-WARNING "Segment must be empty:  " .NOD>)
			 (<NOT .RT> <COMPILE-ERROR "Too many arguments to:  "
						   .NM .ARG>)
			 (ELSE
			  <COMPILE-ERROR "Argument wrong type to:  "
					 .NM
					 .ARG>)>
		   <PUT .NOD ,SEGS T>)
		  (ELSE
		   <SET ARGS <+ .ARGS 1>>
		   <EANA .ARG
			 <COND (.TUPF <GET-ELE-TYPE .RT <COND (.SEGF ALL)
							      (ELSE .ARGS)>>)
			       (ELSE .RT)> .NM>)>>
    .K>
   <COND (<OR <==? .NM PRINC> <==? .NM PRINT> <==? .NM PRIN1>>
	  <RESULT-TYPE .NOD <TYPE-AND <RESULT-TYPE .NOD>
				      <RESULT-TYPE <1 .K>>>>)>
   <SPEC-FLUSH>
   <PUT-FLUSH ALL>
   <PUT .NOD ,SIDE-EFFECTS (ALL)>
   <TYPE-OK? <RESULT-TYPE .NOD> .RTYP>>

" Analyze CHTYPE, in some cases do it at compile time."

<DEFINE CHTYPE-ANA (NOD RTYP "AUX" (K <KIDS .NOD>) NTN NT OBN OB TARG S1 S2
		    TDECL) 
   #DECL ((NOD OBN NTN) NODE (K) <LIST [REST NODE]> (NT) ATOM)
   <COND
    (<SEGFLUSH .NOD .RTYP>)
    (ELSE
     <ARGCHK <LENGTH .K> 2 CHTYPE .NOD>
     <SET OB <ANA <SET OBN <1 .K>> ANY>>
     <EANA <SET NTN <2 .K>> ATOM CHTYPE>
     <COND
      (<==? <NODE-TYPE .NTN> ,QUOTE-CODE>
       <COND (<NOT <ISTYPE? <SET NT <NODE-NAME .NTN>>>>
	      <COMPILE-ERROR "Second arg to CHTYPE not a type " .NT .NOD>)>
       <COND (<NOT <TYPE-OK? .OB <FORM PRIMTYPE <MTYPR .NT>>>>
	      <COMPILE-ERROR "Primtypes differ in CHTYPE" .OB .NT .NOD>)>
       <COND (<==? <NODE-TYPE .OBN> ,QUOTE-CODE>
	      <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
	      <PUT .NOD ,KIDS ()>
	      <PUT .NOD ,NODE-NAME <CHTYPE <NODE-NAME .OBN> .NT>>)
	     (<TYPESAME .OB .NT>
	      <COMPILE-WARNING "Redundant CHTYPE" .NOD>
	      <PUT .NOD ,NODE-TYPE ,ID-CODE>)
	     (<SET TDECL <GET-DECL .NT>>
	      <SET TDECL <CHTYPE
			  (<FORM PRIMTYPE <TYPEPRIM .NT>> !<REST .TDECL>)
			  <TYPE .TDECL>>>
	      <COND (<NOT <TYPE-OK? .OB .TDECL>>
		     <COMPILE-ERROR "DECL violation in CHTYPE "
				    .NOD>)>
	      <PUT .NOD ,NODE-TYPE ,CHTYPE-CODE>)
	     (ELSE <PUT .NOD ,NODE-TYPE ,CHTYPE-CODE>)>
       <PUT .NOD ,RESULT-TYPE .NT>
       <TYPE-OK? .NT .RTYP>)
      (<AND <==? <NODE-TYPE .NTN> ,RSUBR-CODE> <==? <NODE-NAME .NTN> TYPE>>
       <COND
	(<AND <SET S1 <PRIMITIVE-TYPE .OB>>
	      <SET S2
		   <PRIMITIVE-TYPE <SET TARG <RESULT-TYPE <1 <KIDS .NTN>>>>>>
	      <NOT <TYPE-OK? .S1 .S2>>>
	 <COMPILE-ERROR "Primtypes differ in CHTYPE" .OB .TARG .NOD>)
	(ELSE
	 <PUT .NOD ,NODE-TYPE ,CHTYPE-CODE>
	 <PUT .NOD ,RESULT-TYPE .TARG>
	 <TYPE-OK? .TARG .RTYP>)>)
      (ELSE
       <COND (.VERBOSE <ADDVMESS .NOD ("Can't open compile CHTYPE.")>)>
       <TYPE-OK? ANY .RTYP>)>)>>

<COND (<GASSIGNED? CHTYPE-ANA> <PUTPROP ,CHTYPE ANALYSIS ,CHTYPE-ANA>)>

" Analyze use of ASCII sometimes do at compile time."

<DEFINE ASCII-ANA (NOD RTYP "AUX" (K <KIDS .NOD>) ITM TYP TEM) 
	#DECL ((NOD ITM) NODE (K) <LIST [REST NODE]>)
	<COND (<SEGFLUSH .NOD .RTYP>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 1 ASCII .NOD>
	       <SET TYP <EANA <SET ITM <1 .K>> '<OR FIX CHARACTER> ASCII>>
	       <COND (<==? <NODE-TYPE .ITM> ,QUOTE-CODE>
		      <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .NOD ,NODE-NAME <SET TEM <ASCII <NODE-NAME .ITM>>>>
		      <PUT .NOD ,RESULT-TYPE <TYPE .TEM>>
		      <PUT .NOD ,KIDS ()>)
		     (<==? <ISTYPE? .TYP> FIX>
		      <PUT .NOD ,NODE-TYPE ,CHTYPE-CODE>
		      <PUT .NOD ,RESULT-TYPE CHARACTER>)
		     (<==? .TYP CHARACTER>
		      <PUT .NOD ,NODE-TYPE ,CHTYPE-CODE>
		      <PUT .NOD ,RESULT-TYPE FIX>)
		     (ELSE <PUT .NOD ,RESULT-TYPE '<OR FIX CHARACTER>>)>
	       <TYPE-OK? <RESULT-TYPE .NOD> .RTYP>)>>

<COND (<GASSIGNED? ASCII-ANA> <PUTPROP ,ASCII ANALYSIS ,ASCII-ANA>)>

<DEFINE UNWIND-ANA (NOD RTYP "AUX" (K <KIDS .NOD>) ITYP) 
	#DECL ((NOD) NODE (K) <LIST [REST NODE]>)
	<SET ITYP <EANAQ <1 .K> ANY UNWIND .NOD>>
	<EANA <2 .K> ANY UNWIND>
	<PUTPROP .FCN UNWIND T>
	<TYPE-OK? .ITYP .RTYP>>

" Analyze READ type SUBRS in two cases (print uncertain usage message maybe?)"

<DEFINE READ-ANA (N R) 
   #DECL ((N) NODE)
   <MAPF <>
	 <FUNCTION (NN "AUX" TY) 
		 #DECL ((NN N) NODE)
		 <COND (<==? <NODE-TYPE .NN> ,EOF-CODE>
			<SPEC-FLUSH>
			<PUT-FLUSH ALL>
			<SET TY <EANAQ <1 <KIDS .NN>> ANY <NODE-NAME .N> .N>>
			<COND (<TYPE-OK? .TY '<OR FORM LIST VECTOR UVECTOR>>
			       <COMPILE-WARNING
				"Uncertain use of " <NODE-NAME .N> .N>)
			      (ELSE <PUT .N ,NODE-TYPE ,READ-EOF2-CODE>)>)
		       (ELSE <EANA .NN ANY <NODE-NAME .N>>)>>
	 <KIDS .N>>
   <SPEC-FLUSH>
   <PUT-FLUSH ALL>
   <TYPE-OK? ANY .R>>

<DEFINE READ2-ANA (N R) 
	#DECL ((N) NODE)
	<MAPF <>
	      <FUNCTION (NN) 
		      #DECL ((NN N) NODE)
		      <COND (<==? <NODE-TYPE .NN> ,EOF-CODE>
			     <EANAQ <1 <KIDS .NN>> ANY <NODE-NAME .N> .N>)
			    (ELSE <EANA .NN ANY <NODE-NAME .N>>)>>
	      <KIDS .N>>
	<SPEC-FLUSH>
	<PUT-FLUSH ALL>
	<TYPE-OK? ANY .R>>

<DEFINE GET-ANA (N R "AUX" TY (K <KIDS .N>) (NAM <NODE-NAME .N>)) 
	#DECL ((N) NODE (K) <LIST NODE NODE NODE>)
	<EANA <1 .K> ANY .NAM>
	<EANA <2 .K> ANY .NAM>
	<SET TY <EANAQ <3 .K> ANY .NAM .N>>
	<COND (<TYPE-OK? .TY '<OR LIST VECTOR UVECTOR FORM>>
	       <COMPILE-WARNING "Uncertain use of " .NAM .N>
	       <SPEC-FLUSH>
	       <PUT-FLUSH ALL>)
	      (ELSE <PUT .N ,NODE-TYPE ,GET2-CODE>)>
	<TYPE-OK? ANY .R>>

<DEFINE GET2-ANA (N R
		  "AUX" (K <KIDS .N>) (NAM <NODE-NAME .N>) (LN <LENGTH .K>))
	#DECL ((N) NODE (K) <LIST NODE NODE [REST NODE]> (LN) FIX)
	<EANA <1 .K> ANY .NAM>
	<EANA <2 .K> ANY .NAM>
	<COND (<==? .LN 3> <EANAQ <3 .K> ANY .NAM .N>)>
	<TYPE-OK? ANY .R>>

<DEFINE EANAQ (N R NAM INOD "AUX" SPCD) 
	#DECL ((N) NODE (SPCD) LIST)
	<SET SPCD <BUILD-TYPE-LIST .VARTBL>>
	<SET R <EANA .N .R .NAM>>
	<ASSERT-TYPES <ORUPC .VARTBL .SPCD>>
	.R>

<DEFINE ACTIV? (BST NOACT) 
	#DECL ((BST) <LIST [REST SYMTAB]>)
	<REPEAT ()
		<AND <EMPTY? .BST> <RETURN <>>>
		<AND <==? <CODE-SYM <1 .BST>> 1>
		     <OR <NOT .NOACT>
			 <NOT <RET-AGAIN-ONLY <1 .BST>>>
			 <SPEC-SYM <1 .BST>>>
		     <RETURN T>>
		<SET BST <REST .BST>>>>

<DEFINE SAME-DECL? (D1 D2) <OR <=? .D1 .D2> <NOT <TYPE-OK? .D2 <NOTIFY .D1>>>>>

<DEFINE SPECIALIZE (OBJ "AUX" T1 T2 SYM OB) 
	#DECL ((T1) FIX (OB) FORM (T2) <OR FALSE SYMTAB>)
	<COND (<AND <TYPE? .OBJ FORM SEGMENT>
		    <SET OB <CHTYPE .OBJ FORM>>
		    <OR <AND <==? <SET T1 <LENGTH .OB>> 2>
			     <==? <1 .OB> LVAL>
			     <TYPE? <SET SYM <2 .OB>> ATOM>>
			<AND <==? .T1 3>
			     <==? <1 .OB> SET>
			     <TYPE? <SET SYM <2 .OB>> ATOM>>>
		    <SET T2 <SRCH-SYM .SYM>>>
	       <COND (<NOT <SPEC-SYM .T2>>
		      <COMPILE-NOTE "Redeclared special " .SYM>
		      <PUT .T2 ,SPEC-SYM T>)>)>
	<COND (<MEMQ <PRIMTYPE .OBJ> '[FORM LIST UVECTOR VECTOR]>
	       <MAPF <> ,SPECIALIZE .OBJ>)>>

<DEFINE ADECL-ANA (NOD RTYP "AUX" (RT <NODE-NAME .NOD>) (N <1 <KIDS .NOD>>) TY)
 
	<COND (<NOT <SET TY <TYPE-OK? .RT .RTYP>>>
	       <COMPILE-ERROR "ADECL asserts incompatible type."
			      "Required type is "
			      .RTYP
			      " ADECL type is "
			      .RT>)
	      (<NOT <SET RT <ANA .N .TY>>>
	       <COMPILE-ERROR "ADECL asserts incompatible type."
			      "Result type is "
			      <RESULT-TYPE .N>
			      " ADECL type is "
			      .TY>)>
	<PUT .NOD ,RESULT-TYPE .RT>
	.RT>

<DEFINE CALL-ANA (N R "AUX" (K <KIDS .N>) INS TYP NN) 
   #DECL ((N INS) NODE (K) <LIST [REST NODE]> (NN) <OR FALSE NODE>)
   <COND
    (<EMPTY? .K> <COMPILE-ERROR "CALL has no instruction supplied" .N>)
    (<AND <==? <NODE-TYPE <SET INS <1 .K>>> ,QUOTE-CODE>
	  <TYPE? <NODE-NAME .INS> ATOM>
	  <SET TYP <LEGAL-MIM-INS .INS>>>
     <PUT .N ,SIDE-EFFECTS (.N !<SIDE-EFFECTS .N>)>
     <COND (<==? <NODE-NAME .INS> `RTUPLE>
	    <EANA <2 .K> FIX RTUPLE>
	    <COND (<SET NN <ACT-CHECK <3 .K> <>>>
		   <COND (<==? <ACCUM-TYPE .NN> NO-RETURN>
			  <PUT .NN ,VSPCD <BUILD-TYPE-LIST <SYMTAB .NN>>>
			  <PUT .NN ,DEAD-VARS <SAVE-L-D-STATE .VARTBL>>)
			 (ELSE
			  <PUT .NN ,VSPCD <ORUPC <SYMTAB .NN> <VSPCD .NN>>>
			  <PUT .NN
			       ,DEAD-VARS
			       <MSAVE-L-D-STATE <DEAD-VARS .NN> .VARTBL>>)>
		   <PUT .NN ,ACCUM-TYPE <TYPE-MERGE TUPLE <ACCUM-TYPE .NN>>>)
		  (ELSE <EANA <3 .K> FRAME RTUPLE>)>)
	   (ELSE
	    <MAPF <>
		  <FUNCTION (N) 
			  #DECL ((N) NODE)
			  <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE>
				 <EANA <1 <KIDS .N>> '<OR MULTI STRUCTURED> CALL>)
				(ELSE <EANA .N ANY CALL>)>>
		  <REST .K>>)>
     <TYPE-OK? .R .TYP>)
    (ELSE <COMPILE-ERROR "CALL with a non-instruction: " .N>)>>

<DEFINE LEGAL-MIM-INS (N "AUX" (ATM <NODE-NAME .N>) MIMOP) 
	#DECL ((FCN N) NODE (ATM) ATOM)
	<COND (<SET MIMOP <LOOKUP <SPNAME .ATM> ,MIM-OBL>>
	       <PUT .N ,NODE-NAME .MIMOP>
	       <COND (<=? <SPNAME .MIMOP> "ACTIVATION">
		      <PUT .FCN ,ACTIVATED T>)>
	       <COND (<GETPROP .MIMOP TYPE>) (ELSE ANY)>)>>

<DEFINE APPLY-ANA (N R "AUX" (K <KIDS .N>)) 
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<COND (<EMPTY? .K> <COMPILE-ERROR "APPLY has nothing to apply" .N>)
	      (ELSE
	       <PUT .N ,SIDE-EFFECTS (.N !<SIDE-EFFECTS .N>)>
	       <MAPF <>
		     <FUNCTION (N) 
			     #DECL ((N) NODE)
			     <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE>
				    <EANA <1 <KIDS .N>>
					  '<OR MULTI STRUCTURED> CALL>)
				   (ELSE <EANA .N ANY CALL>)>>
		     .K>
	       <PUT .N ,NODE-TYPE ,APPLY-CODE>
	       <TYPE-OK? .R ANY>)>>

<COND (<GASSIGNED? APPLY-ANA> <PUTPROP ,APPLY ANALYSIS ,APPLY-ANA>)>

<DEFINE ANALYSIS-DISPATCHER (NOD RTYP) 
	<CASE ,==?
	      <NODE-TYPE .NOD>
	      (,QUOTE-CODE <QUOTE-ANA .NOD .RTYP>)
	      (,FUNCTION-CODE <FUNC-ANA .NOD .RTYP>)
	      (,SEGMENT-CODE <SEGMENT-ANA .NOD .RTYP>)
	      (,FORM-CODE <FORM-AN .NOD .RTYP>)
	      (,PROG-CODE <PRG-REP-ANA .NOD .RTYP>)
	      (,SUBR-CODE <SUBR-ANA .NOD .RTYP>)
	      (,COND-CODE <COND-ANA .NOD .RTYP>)
	      (,COPY-CODE <COPY-AN .NOD .RTYP>)
	      (,RSUBR-CODE <RSUBR-ANA .NOD .RTYP>)
	      (,ISTRUC-CODE <ISTRUC-ANA .NOD .RTYP>)
	      (,ISTRUC2-CODE <ISTRUC2-ANA .NOD .RTYP>)
	      (,READ-EOF-CODE <READ-ANA .NOD .RTYP>)
	      (,READ-EOF2-CODE <READ2-ANA .NOD .RTYP>)
	      (,GET-CODE <GET-ANA .NOD .RTYP>)
	      (,GET2-CODE <GET2-ANA .NOD .RTYP>)
	      (,MAP-CODE <MAPPER-AN .NOD .RTYP>)
	      (,MARGS-CODE <MARGS-ANA .NOD .RTYP>)
	      (,ARITH-CODE <ARITH-ANA .NOD .RTYP>)
	      (,TEST-CODE <ARITHP-ANA .NOD .RTYP>)
	      (,0-TST-CODE <ARITHP-ANA .NOD .RTYP>)
	      (,1?-CODE <ARITHP-ANA .NOD .RTYP>)
	      (,MIN-MAX-CODE <ARITH-ANA .NOD .RTYP>)
	      (,ABS-CODE <ABS-ANA .NOD .RTYP>)
	      (,FIX-CODE <FIX-ANA .NOD .RTYP>)
	      (,FLOAT-CODE <FLOAT-ANA .NOD .RTYP>)
	      (,MOD-CODE <MOD-ANA .NOD .RTYP>)
	      (,LNTH-CODE <LENGTH-ANA .NOD .RTYP>)
	      (,MT-CODE <EMPTY?-ANA .NOD .RTYP>)
	      (,NTH-CODE <NTH-ANA .NOD .RTYP>)
	      (,REST-CODE <REST-ANA .NOD .RTYP>)
	      (,PUT-CODE <PUT-ANA .NOD .RTYP>)
	      (,PUTR-CODE <PUTREST-ANA .NOD .RTYP>)
	      (,UNWIND-CODE <UNWIND-ANA .NOD .RTYP>)
	      (,FORM-F-CODE <FORM-F-ANA .NOD .RTYP>)
	      (,IRSUBR-CODE <IRSUBR-ANA .NOD .RTYP>)
	      (,ROT-CODE <ROT-ANA .NOD .RTYP>)
	      (,LSH-CODE <LSH-ANA .NOD .RTYP>)
	      (,BIT-TEST-CODE <BIT-TEST-ANA .NOD .RTYP>)
	      (,CASE-CODE <CASE-ANA .NOD .RTYP>)
	      (,COPY-LIST-CODE <COPY-AN .NOD .RTYP>)
	      (,ADECL-CODE <ADECL-ANA .NOD .RTYP>)
	      (,CALL-CODE <CALL-ANA .NOD .RTYP>)
	      (,APPLY-CODE <APPLY-ANA .NOD .RTYP>)
	      (,FGETBITS-CODE <FGETBITS-ANA .NOD .RTYP>)
	      (,FPUTBITS-CODE <FPUTBITS-ANA .NOD .RTYP>)
	      (,STACK-CODE <STACK-ANA .NOD .RTYP>)
	      (,BACK-CODE <BACK-ANA .NOD .RTYP>)
	      (,TOP-CODE <TOP-ANA .NOD .RTYP>)
	      (,CHANNEL-OP-CODE <CHANNEL-OP-ANA .NOD .RTYP>)
	      (,ATOM-PART-CODE <ATOM-PART-ANA .NOD .RTYP>)
	      (,OFFSET-PART-CODE <OFFSET-PART-ANA .NOD .RTYP>)
	      (,PUT-GET-DECL-CODE <PUT-GET-DECL-ANA .NOD .RTYP>)
	      (,SUBSTRUC-CODE <SUBSTRUC-ANA .NOD .RTYP>)
	      (,MULTI-SET-CODE <MULTI-SET-ANA .NOD .RTYP>)
	      DEFAULT
	      (<SUBR-ANA .NOD .RTYP>)>>

<DEFINE SPEC-ANA (CONST PRED-NAME OTYPE RTYP DFLG NOD WHO "AUX" TEM PAT) 
	#DECL ((NOD) NODE)
	<SET PAT
	     <COND (<TYPE? .CONST LIST>
		    <COND (<==? .PRED-NAME ==?> <GEN-DECL <1 .CONST>>)
			  (<==? .PRED-NAME TYPE?> <TYPE-MERGE !.CONST>)
			  (ELSE
			   <MAPF ,TYPE-MERGE
				 <FUNCTION (X) <FORM PRIMTYPE .X>>
				 .CONST>)>)
		   (ELSE
		    <COND (<==? .PRED-NAME ==?> <GEN-DECL .CONST>)
			  (<==? .PRED-NAME TYPE?> .CONST)
			  (ELSE <FORM PRIMTYPE .CONST>)>)>>
	<COND
	 (.DFLG <PUT .NOD ,RESULT-TYPE <SET TEM <TYPE-OK? ATOM .RTYP>>> .TEM)
	 (ELSE
	  <COND (<AND <N==? .PRED-NAME ==?>
		      <N==? .OTYPE ANY>
		      <NOT <TYPE-OK? <FORM NOT .PAT> .OTYPE>>>
		 <SET TEM ATOM>)
		(<TYPE-OK? .OTYPE .PAT> <SET TEM '<OR FALSE ATOM>>)
		(ELSE <SET TEM FALSE>)>
	  <MAPF <>
		<FUNCTION (L "AUX" (FLG <1 .L>) (SYM <2 .L>)) 
			#DECL ((L) <LIST <OR ATOM FALSE> SYMTAB> (SYM) SYMTAB)
			<SET TRUTH
			     <ADD-TYPE-LIST .SYM .PAT .TRUTH .FLG <REST .L 2>>>
			<OR <==? .TEM ATOM>
			    <SET UNTRUTH
				 <ADD-TYPE-LIST .SYM
						<FORM NOT .PAT>
						.UNTRUTH
						.FLG
						<REST .L 2>>>>>
		.WHO>
	  <PUT .NOD ,RESULT-TYPE <SET TEM <TYPE-OK? .TEM .RTYP>>>
	  .TEM)>>

<DEFINE ISTRUC-ANA (N R "AUX" (K <KIDS .N>) FM NUM TY (NEL REST) SIZ) 
	#DECL ((N FM NUM) NODE)
	<EANA <SET NUM <1 .K>> FIX <NODE-NAME .N>>
	<SET TY
	     <EANA <SET FM <2 .K>>
		   <COND (<==? <NODE-NAME .FM> ISTRING> CHARACTER)
			 (<==? <NODE-NAME .FM> IBYTES> FIX)
			 (<==? <NODE-NAME .FM> UVECTOR> FIX)
			 (ELSE ANY)>
		   <NODE-NAME .N>>>
	<COND (<TYPE-OK? .TY '<OR FORM LIST VECTOR UVECTOR LVAL GVAL>>
	       <COMPILE-WARNING "Explicit EVAL required: " <NODE-NAME .N> .N>
	       <SPEC-FLUSH>
	       <PUT-FLUSH ALL>)>
	<COND (<==? <NODE-TYPE .NUM> ,QUOTE-CODE> <SET NEL <NODE-NAME .NUM>>)>
	<COND (<TYPE-OK? .TY FORM> <SET TY ANY>)>
	<TYPE-OK? <FORM <ISTYPE? <RESULT-TYPE .N>>
			!<COND (<TYPE? .NEL FIX> ([.NEL .TY])) (ELSE ())>
			!<COND (<==? .TY ANY> ()) (ELSE ([REST .TY]))>>
		  .R>>

<DEFINE ISTRUC2-ANA (N R "AUX" (K <KIDS .N>) GD NUM TY (NEL REST) SIZ) 
	#DECL ((N NUM GD) NODE)
	<EANA <SET NUM <1 .K>> FIX <NODE-NAME .N>>
	<SET TY
	     <COND (<==? <NODE-NAME .N> ISTRING> CHARACTER)
		   (<OR <==? <NODE-NAME .N> IBYTES>
			<==? <NODE-NAME .N> IUVECTOR>>
		    FIX)
		   (ELSE ANY)>>
	<COND (<==? <LENGTH .K> 2>
	       <SET TY <EANA <SET GD <2 .K>> .TY <NODE-NAME .N>>>)>
	<COND (<==? <NODE-TYPE .NUM> ,QUOTE-CODE> <SET NEL <NODE-NAME .NUM>>)>
	<TYPE-OK? <COND (<AND <==? .NEL REST> <==? .TY ANY>>
			 <ISTYPE? <RESULT-TYPE .N>>)
			(ELSE
			 <FORM <ISTYPE? <RESULT-TYPE .N>>
			       !<COND (<N==? .NEL REST> ([.NEL .TY]))
				      (ELSE ())>
			       !<COND (<==? .TY ANY> ())
				      (ELSE ([REST .TY]))>>)>
		  .R>>

<DEFINE STACK-ANA (N R) #DECL ((N) NODE) <EANA <1 <KIDS .N>> .R STACK>>

<DEFINE CHANNEL-OP-ANA (N R "AUX" (K <KIDS .N>) TY) 
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <PUT .N ,SIDE-EFFECTS (.N !<SIDE-EFFECTS .N>)>
	       <COND (<L? <LENGTH .K> 2> <ARGCHK <LENGTH .K> 2 CHANNEL-OP .N>)>
	       <SET TY <EANA <1 .K> CHANNEL CHANNEL-OP>>
	       <EANA <2 .K> ATOM CHANNEL-OP>
	       <MAPF <>
		     <FUNCTION (NN) #DECL ((NN) NODE) <ANA .NN ANY>>
		     <REST .K 2>>
	       <COND (<AND <TYPE? .TY FORM SEGMENT>
			   <==? <LENGTH .TY> 2>
			   <TYPE? <SET TY <2 .TY>> FORM>
			   <==? <LENGTH .TY> 2>
			   <==? <1 .TY> QUOTE>
			   <TYPE? <2 .TY> ATOM>>
		      <PUT .N ,NODE-TYPE ,CHANNEL-OP-CODE>
		      <PUT .N ,NODE-SUBR <2 .TY>>)>
	       <TYPE-OK? .R ANY>)>>

<COND (<AND <GASSIGNED? CHANNEL-OP> <GASSIGNED? CHANNEL-OP-ANA>>
       <PUTPROP ,CHANNEL-OP ANALYSIS ,CHANNEL-OP-ANA>)>

<ENDPACKAGE>
