<PACKAGE "CODGEN">

<ENTRY GEN
       CODE-GEN
       SEQ-GEN
       SEGMENT-STACK
       GOOD-TUPLE
       NO-KILL
       DELAY-KILL
       BASEF
       LADDR
       TRUE-FALSE
       SUBR-GEN
       BIND-CODE
       NPRUNE
       ARG?
       OPT?
       COND-GEN
       OR-GEN
       AND-GEN
       ASSIGNED?-GEN
       BIND-B
       ACT-B
       AUX1-B
       AUX2-B
       SMSUBR-CALL
       CALL-GEN
       T-NAME
       GASSIGNED?-GEN
       INTERFERE?
       INTERF-CHANGE
       SEGLABEL
       SEGCALLED
       COUNTMP
       SET-GEN
       PSEQ-GEN>

<USE "CHKDCL"
     "COMPDEC"
     "MIMGEN"
     "STRGEN"
     "MAPGEN"
     "MMQGEN"
     "BUILDL"
     "BITSGEN"
     "LNQGEN"
     "CARGEN"
     "NOTGEN"
     "ALLR"
     "SUBRTY"
     "NEWREP"
     "ADVMESS"
     "CASECOMP">

<SETG THE-UNBOUND <CHTYPE 0 T$UNBOUND>>

"	This file contains the major general codde generators.  These include
 variable access functions (LVAL, SETG etc.), FSUBRs (COND, AND, REPEAT)
 and a few assorted others."

" Main generator, dispatches to specific code generators. "

<DEFINE GEN (NOD "OPT" (WHERE DONT-CARE) "AUX" TEMP) 
	#DECL ((NOD) NODE)
	<SET TEMP <GEN-DISPATCH .NOD .WHERE>>
	<OR <ASSIGNED? NPRUNE> <PUT .NOD ,KIDS ()>>
	.TEMP>

" Generate a sequence of nodes flushing all values except the ladt."

<DEFINE SEQ-GEN (L WHERE
		 "OPTIONAL" (INPROG <>) (SINPROG <>) (INCODE-GEN <>)
		 "AUX" K (WSET <>))
   #DECL ((K L) <LIST [REST NODE]> (LAST) NODE)
   <MAPR <>
    <FUNCTION (N "AUX" (ND <1 .N>) NX W) 
       #DECL ((N) <LIST NODE> (ND) NODE)
       <COND (<NOT <EMPTY? <REST .N>>>
	      <SET NX <2 .N>>
	      <COND (<AND <==? <NODE-TYPE .NX> ,CALL-CODE>
			  <G=? <LENGTH <SET K <KIDS .NX>>> 2>
			  <==? <NODE-NAME <1 .K>> `ENDIF>>
		     <SET W <GEN .ND .WHERE>>
		     <COND (<AND <NOT .WSET>
				 <N==? .WHERE FLUSHED>
				 <N==? .W ,NO-DATUM>
				 <N==? .WHERE ,POP-STACK>>
			    <SET WHERE <FIXUP-TEMP .WHERE .W>>
			    <SET WSET T>)>
		     <COND (<NOT <EMPTY? <REST .N 2>>>
			    <DEALLOCATE-TEMP .WHERE>)>)
		    (<OR <AND <G=? <LENGTH .ND>
				   <CHTYPE <INDEX ,SIDE-EFFECTS> FIX>>
			      <SIDE-EFFECTS .ND>>
			 <GETPROP .ND DONT-FLUSH-ME>
			 ,DONT-FLUSH-ME>
		     <GEN .ND FLUSHED>)>)
	     (<AND <==? <NODE-TYPE .ND> ,CALL-CODE>
		   <G=? <LENGTH <SET K <KIDS .ND>>> 2>
		   <==? <NODE-NAME <1 .K>> `ENDIF>>
	      <GEN .ND FLUSHED>)
	     (ELSE <SET WHERE <GEN .ND .WHERE>>)>>
    .L>
   .WHERE>

" The main code generation entry (called from CDRIVE).  Sets up initial
 stack model, calls to generate code for the bindings and generates code for
 the function's body."

<DEFINE CODE-GEN (BASEF EXTRA-CODE
		  "AUX" (K <KIDS .BASEF>) CD (NO-KILL ()) (KILL-LIST ())
			(ATAG <MAKE-TAG "AGAIN">) (RTAG <MAKE-TAG "RETURN">)
			(CODE-START .EXTRA-CODE) (CODE-PTR .CODE-START)
			(EVERY-TEMP ()) ARGS-NEXT TMPS TMPS-NEXT (STK 0)
			(FREE-TEMPS ()) (ALL-TEMPS-LIST ()) TMP-DEST SPECD
			BNDTMP STKTMP (STK-CHARS7 0) (STK-CHARS8 0))
	#DECL ((STK-CHARS7 STK-CHARS8 STK) <SPECIAL FIX> (STKTMP) <SPECIAL
								   ANY>
	       (BASEF) <SPECIAL NODE>
	       (KILL-LIST NO-KILL CODE-START CODE-PTR TMPS-NEXT ARGS-NEXT
		EVERY-TEMP ALL-TEMPS-LIST) <SPECIAL LIST> (TMPS) <SPECIAL
								  FORM>
	       (K) <LIST [REST NODE]> (ATAG RTAG) ATOM
	       (TMP-DEST) <SPECIAL ATOM> (SPECD) <SPECIAL ANY>
	       (FREE-TEMPS) <SPECIAL <LIST [REST TEMP]>>)
	<MIM-FCN <NODE-NAME .BASEF>
		 <RSUBR-DECLS .BASEF>
		 <OR <ACTIVATED .BASEF>
		     <ACTIV? <BINDING-STRUCTURE .BASEF>>
		     <GETPROP <NODE-NAME .BASEF> FRAME>
		     <GETPROP .BASEF UNWIND>>>
	<MIM-TEMPS-HOLD>
	<SET SPECD <BIND-CODE .BASEF <> <SET BNDTMP <GEN-TEMP <>>>>>
	<COND (<AGND .BASEF> <IEMIT `LOOP>)>
	<LABEL-TAG .ATAG>
	<PUT .BASEF ,DST DONT-CARE>
	<PUT .BASEF ,CDST DONT-CARE>
	<PUT .BASEF ,ATAG .ATAG>
	<PUT .BASEF ,RTAG .RTAG>
	<COND (<N==? <SET CD <SEQ-GEN .K DONT-CARE <> <> T>> ,NO-DATUM>)
	      (ELSE <SET CD <CDST .BASEF>>)>
	<COND (<N==? <CDST .BASEF> .CD> <SET CD <MOVE-ARG .CD <CDST .BASEF>>>)>
	<LABEL-TAG .RTAG>
	<COND (<ASSIGNED? TMP-DEST> <PUTREST .TMPS-NEXT (= .TMP-DEST)>)>
	<FREE-TEMP .CD <>>
	<COND (.SPECD <IEMIT `UNBIND .BNDTMP> <FREE-TEMP .BNDTMP>)>
	<COND (<N==? .STK-CHARS8 0>
	       <SET STK-CHARS8 <+ .STK-CHARS8 .STK>>
	       <SET STK-CHARS7 <+ .STK-CHARS7 .STK>>
	       <SET STK 0>)>
	<COND (<ASSIGNED? STKTMP>
	       <COND (<N==? .STK 0>
		      <IEMIT `SUB .STKTMP .STK = .STKTMP (`TYPE FIX)>)
		     (<N==? .STK-CHARS7 0>
		      <IEMIT `IFSYS "TOPS20">
		      <IEMIT `SUB .STKTMP .STK-CHARS7 = .STKTMP>
		      <IEMIT `ENDIF "TOPS20">
		      <IEMIT `IFSYS "UNIX">
		      <IEMIT `SUB .STKTMP .STK-CHARS8 = .STKTMP>
		      <IEMIT `ENDIF "UNIX">)>
	       <IEMIT `ADJ .STKTMP>
	       <FREE-TEMP .STKTMP>)
	      (<N==? .STK 0> <IEMIT `ADJ <- .STK>>)
	      (<N==? .STK-CHARS8 0>
	       <IEMIT `IFSYS "TOPS20">
	       <IEMIT `ADJ <- .STK-CHARS7>>
	       <IEMIT `ENDIF "TOPS20">
	       <IEMIT `IFSYS "UNIX">
	       <IEMIT `ADJ <- .STK-CHARS8>>
	       <IEMIT `ENDIF "UNIX">)>
	<MIM-RETURN .CD>
	<TYPIFY-TEMPS .EVERY-TEMP>
	<IEMIT `END <CHTYPE <NODE-NAME .BASEF> FCN-ATOM>>
	.CODE-START>

" Generate code for setting up and binding agruments."

<DEFINE BIND-CODE (NOD
		   "OPTIONAL" (FORPROG <>) BNDTMP
		   "AUX" (BST <BINDING-STRUCTURE .NOD>) (NPRUNE T) (LARG <>)
			 (ANY-ARG <>) (ANY-SPEC <>) (OPTS? <>) (OL ()) T-NAME
			 (TUP? <>))
   #DECL ((NOD) NODE (BST B) <LIST [REST SYMTAB]> (NPRUNE) <SPECIAL ANY>
	  (INAME) <UVECTOR [REST ATOM]> (BASEF) NODE (TMPS-NEXT OL) LIST
	  (T-NAME) <SPECIAL ANY>)
   <COND
    (<NOT .FORPROG>
     <SET OL
	  <MAPF ,LIST
		<FUNCTION (SYM) 
			#DECL ((SYM) SYMTAB)
			<COND (<OPT? .SYM> <MAKE-TAG "OPT">)
			      (ELSE
			       <COND (<==? <CODE-SYM .SYM> ,ARGL-TUPLE>
				      <SET TUP? <TOTARGS .NOD>>)>
			       <MAPRET>)>>
		.BST>>
     <COND (<NOT <EMPTY? .OL>>
	    <PUTREST <REST .OL <- <LENGTH .OL> 1>> (<MAKE-TAG "OPT">)>
	    <IEMIT `OPT-DISPATCH <REQARGS .NOD> .TUP? !.OL>)>
     <MAPF <>
      <FUNCTION (SYM "AUX" (NT 0)) 
	 #DECL ((SYM) SYMTAB (NT) FIX)
	 <PUT .SYM
	      ,TEMP-NAME-SYM
	      <GEN-TEMP <> <NAME-SYM .SYM> T <DECL-SYM .SYM>>>
	 <COND
	  (<OPT? .SYM>
	   <LABEL-TAG <1 .OL>>
	   <SET OL <REST .OL>>
	   <COND (<AND <NOT <SPEC-SYM .SYM>>
		       <N==? <CODE-SYM .SYM> ,ARGL-OPT>
		       <N==? <CODE-SYM .SYM> ,ARGL-QOPT>
		       <OR <==? <SET NT <NODE-TYPE <INIT-SYM .SYM>>>
				,QUOTE-CODE>
			   <==? .NT ,LVAL-CODE>>>
		  <GEN <INIT-SYM .SYM> ,POP-STACK>)
		 (ELSE <PUSH ,THE-UNBOUND>)>
	   <COND (<EMPTY? <REST .OL>> <LABEL-TAG <1 .OL>>)>)>>
      .BST>
     <COND (<==? <NODE-TYPE .NOD> ,FUNCTION-CODE> <MIM-TEMPS-EMIT>)>)>
   <MAPR <>
	 <FUNCTION (BS
		    "AUX" (SYM <1 .BS>) TMP (A? <ARG? .SYM>) (O? <OPT? .SYM>))
		 #DECL ((SYM) SYMTAB (TMP) TEMP (BS) <LIST SYMTAB>)
		 <COND (<NOT <USED-AT-ALL .SYM>>
			<COND (<SPEC-SYM .SYM>
			       <COMPILE-NOTE "Special variable never used: "
					     <NAME-SYM .SYM>>)
			      (ELSE
			       <COMPILE-WARNING
				"Variable never used: " <NAME-SYM .SYM>>)>)>
		 <COND (<AND <NOT .LARG> <NOT .A?> <NOT .O?>>
			<COND (<AND .ANY-SPEC .ANY-ARG> <GEN-FIX-BIND>)>
			<SET LARG T>)>
		 <COND (<NOT <TYPE? <TEMP-NAME-SYM .SYM> TEMP>>
			<PUT .SYM
			     ,TEMP-NAME-SYM
			     <GEN-TEMP <> <NAME-SYM .SYM> T <DECL-SYM .SYM>>>)>
		 <COND (<AND .O? <NOT .OPTS?>> <SET OPTS? T>)>
		 <COND (<AND <ASSIGNED? BNDTMP>
			     <SPEC-SYM .SYM>
			     <NOT .ANY-SPEC>>
			<SET ANY-SPEC T>
			<USE-TEMP .BNDTMP LBIND>
			<GET-BINDING .BNDTMP>)>
		 <PUT <SET TMP <TEMP-NAME-SYM .SYM>>
		      ,TEMP-TYPE
		      <COND (<ASS? .SYM> ANY) (ELSE <COMPOSIT-TYPE .SYM>)>>
		 <COND (<OR .A? .O?>
			<PUTREST .ARGS-NEXT
				 <SET ARGS-NEXT
				      (<CHTYPE <TEMP-NAME .TMP> ATOM>)>>)>
		 <COND (<OR .A? .O?> <SET ANY-ARG T>)>
		 <SET T-NAME <TEMP-NAME .TMP>>
		 <COND (<AND <BIND-GENERATE .SYM .FORPROG>
			     <NOT .A?>
			     <NOT .O?>
			     <NOT <SPEC-SYM .SYM>>>
			<PUTREST .TMPS-NEXT <SET TMPS-NEXT (.T-NAME)>>
			<USE-TEMP .TMP <ISTYPE? <COMPOSIT-TYPE .SYM>>>
			<PUT .TMP ,TEMP-REFS 1>)>
		 <COND (<AND <NOT .LARG> <EMPTY? <REST .BS>>>
			<COND (<AND .ANY-SPEC .ANY-ARG> <GEN-FIX-BIND>)>
			<SET LARG T>)>>
	 .BST>
   <COND (<ACTIVATED .NOD> <IEMIT `ACTIVATION>)>
   <COND (<AND <ASSIGNED? BNDTMP> <NOT .ANY-SPEC> <PUTPROP .NOD UNWIND>>
	  <USE-TEMP .BNDTMP LBIND>
	  <GET-BINDING .BNDTMP>)>
   <COND (.ANY-SPEC .BNDTMP)>>

" Generate \"BIND\" binding code."

<DEFINE BIND-B (SYM "AUX" TMP FTMP) 
	#DECL ((STK) FIX (SYM) SYMTAB (BASEF) NODE)
	<COND (<SPEC-SYM .SYM>
	       <SET FTMP <PREV-FRAME <GEN-TEMP FRAME>>>
	       <SPECIAL-BINDING .SYM T .FTMP>
	       <SET STK <+ .STK ,BINDING-LENGTH>>
	       <FREE-TEMP .FTMP>)
	      (ELSE
	       <PREV-FRAME <TEMP-NAME-SYM .SYM>>
	       <USE-TEMP <TEMP-NAME-SYM .SYM>>)>
	T>

" Do code generation for normal  arguments."

<DEFINE NORM-B (SYM) 
	#DECL ((SYM) SYMTAB (STK) FIX)
	<COND (<SPEC-SYM .SYM>
	       <SPECIAL-BINDING .SYM <> <TEMP-NAME-SYM .SYM>>
	       <SET STK <+ .STK ,BINDING-LENGTH>>)>
	T>

" Initialized optional argument binder."

<DEFINE OPT1-B (SYM "AUX" NT) 
	#DECL ((SYM) SYMTAB)
	<COND (<OR <SPEC-SYM .SYM>
		   <AND <N==? <SET NT <NODE-TYPE <INIT-SYM .SYM>>> ,QUOTE-CODE>
			<N==? .NT ,LVAL-CODE>>>
	       <OPTBIND .SYM <INIT-SYM .SYM>>)>>

" Uninitialized optional argument binder."

<DEFINE OPT2-B (SYM) 
	#DECL ((SYM) SYMTAB)
	<COND (<SPEC-SYM .SYM> <OPTBIND .SYM>)>
	T>

" Create a binding for either intitialized or unitialized optional."

<DEFINE OPTBIND (SYM
		 "OPTIONAL" DVAL
		 "AUX" (GIVE <MAKE-TAG>) (DEF <MAKE-TAG>) DV TMP
		       (SPEC <SPEC-SYM .SYM>) BLBL)
	#DECL ((STK) FIX (SYM) SYMTAB (BASEF DVAL) NODE (GIVE DEF) ATOM)
	<COND (<OR <ASSIGNED? DVAL> .SPEC>
	       <COND (.SPEC
		      <SET TMP <GEN-TEMP FIX>>
		      <IEMIT `SET .TMP 0>)>
	       <TEST-ARG <TEMP-NAME-SYM .SYM> .GIVE>
	       <COND (<ASSIGNED? DVAL>
		      <GEN .DVAL <TEMP-NAME-SYM .SYM>>)>
	       <COND (.SPEC
		      <IEMIT `SET .TMP 1>
		      <FREE-TEMP <TEMP-NAME-SYM .SYM> <>>)>
	       <LABEL-TAG .GIVE>)>
	<COND (.SPEC
	       <SPECIAL-BINDING .SYM <> <TEMP-NAME-SYM .SYM>>
	       <SET STK <+ .STK ,BINDING-LENGTH>>
	       <IEMIT `VEQUAL? .TMP 0 + <SET BLBL <MAKE-TAG>>>
	       <GEN-FIX-BIND>
	       <LABEL-TAG .BLBL>
	       <FREE-TEMP .TMP>)>
	T>

" Do a binding for a named activation."

<DEFINE ACT-B (SYM "AUX" TMP FTMP) 
	#DECL ((STK) FIX (SYM) SYMTAB (BASEF) NODE)
	<COND (<SPEC-SYM .SYM>
	       <SET FTMP <CURRENT-FRAME>>
	       <SPECIAL-BINDING .SYM T .FTMP>
	       <SET STK <+ .STK ,BINDING-LENGTH>>
	       <FREE-TEMP .FTMP>
	       <PUT .BASEF ,ACTIVATED T>)
	      (<OR <ACTIVATED .BASEF> <ACTIV? <BINDING-STRUCTURE .BASEF>>>
	       <PUT .BASEF ,ACTIVATED T>
	       <CURRENT-FRAME <TEMP-NAME-SYM .SYM>>
	       <USE-TEMP <TEMP-NAME-SYM .SYM>>)>
	T>

" Bind an \"AUX\" variable."

<DEFINE AUX1-B (SYM
		"OPT" (FORCE-INIT <>)
		"AUX" (TMP <TEMP-NAME-SYM .SYM>) TY PT INIT
		      (NOD <INIT-SYM .SYM>))
	#DECL ((SYM) SYMTAB (NOD) NODE (STK) FIX)
	<COND (<AND <SET TY <ISTYPE? <COMPOSIT-TYPE .SYM>>>
		    <OR <==? <SET PT <TYPEPRIM .TY>> FIX>
			<==? .PT WORD>
			<==? .PT LIST>>
		    <NOT <ASS? .SYM>>>)
	      (ELSE <SET TY <>>)>
	<COND (<SPEC-SYM .SYM>
	       <SPECIAL-BINDING .SYM T <SET INIT <GEN .NOD>>>
	       <SET STK <+ .STK ,BINDING-LENGTH>>
	       <FREE-TEMP .INIT>)
	      (<AND <NOT .FORCE-INIT> <==? <NODE-TYPE .NOD> ,QUOTE-CODE>>
	       <USE-TEMP .TMP .TY>
	       <SET T-NAME
		    (<COND (.TY <CHTYPE [<TEMP-NAME .TMP> .TY] ADECL>)
			   (ELSE <TEMP-NAME .TMP>)>
		     <ATOMCHK <NODE-NAME .NOD>>)>)
	      (ELSE
	       <COND (.TY <SET T-NAME <CHTYPE [<TEMP-NAME .TMP> .TY] ADECL>>)>
	       <GEN .NOD <TEMP-NAME-SYM .SYM>>)>
	T>

" Do a binding for an uninitialized \"AUX\" "

<DEFINE AUX2-B (SYM FP "AUX" TMP) 
	#DECL ((SYM) SYMTAB (STK) FIX)
	<COND (<SPEC-SYM .SYM>
	       <SPECIAL-BINDING .SYM T>
	       <SET STK <+ .STK ,BINDING-LENGTH>>)
	      (<AND .FP <ASS? .SYM>> <SET-SYM .SYM ,THE-UNBOUND T> T)
	      (<ASS? .SYM>)
	      (ELSE
	       <SET TMP <PUT <TEMP-NAME-SYM .SYM> ,TEMP-ALLOC <>>>
	       <PUT .TMP ,TEMP-REFS 0>
	       <>)>>

" Do a \"TUPLE\" binding."

<DEFINE TUPL-B (SYM "AUX" (TMP1 <TEMP-NAME-SYM .SYM>) TMP2) 
	#DECL ((SYM) SYMTAB (STK) FIX)
	<GET-ARG-TUPLE .TMP1>
	<COND (<SPEC-SYM .SYM>
	       <SPECIAL-BINDING .SYM T .TMP1>
	       <SET STK <+ .STK ,BINDING-LENGTH>>)>
	T>

" Dispatch table for binding generation code."

<DEFINE BIND-GENERATE (SYM FORPROG "AUX" (COD <CODE-SYM .SYM>)) 
	#DECL ((SYM) SYMTAB (COD) FIX)
	<CASE ,==?
	      .COD
	      (,ARGL-ACT <ACT-B .SYM>)
	      (,ARGL-IAUX <AUX1-B .SYM .FORPROG>)
	      (,ARGL-AUX <AUX2-B .SYM .FORPROG>)
	      (,ARGL-TUPLE <TUPL-B .SYM>)
	      (,ARGL-ARGS <NORM-B .SYM>)
	      (,ARGL-QIOPT <OPT1-B .SYM>)
	      (,ARGL-IOPT <OPT1-B .SYM>)
	      (,ARGL-QOPT <OPT2-B .SYM>)
	      (,ARGL-OPT <OPT2-B .SYM>)
	      (,ARGL-CALL <NORM-B .SYM>)
	      (,ARGL-BIND <BIND-B .SYM>)
	      (,ARGL-QUOTE <NORM-B .SYM>)
	      (,ARGL-ARG <NORM-B .SYM>)>>

" Appliacation of a form could still be an NTH."

<DEFINE FORM-F-GEN (NOD WHERE "AUX" (K <KIDS .NOD>) TY) 
	#DECL ((NOD) NODE)
	<COND (<==? <ISTYPE? <SET TY <RESULT-TYPE <1 .K>>>> FIX>
	       <PUT .NOD ,NODE-NAME INTH>
	       <PUT .NOD ,NODE-TYPE <NODE-SUBR .NOD>>
	       <PUT .NOD ,NODE-SUBR ,NTH>
	       <COND (<OR <==? <NODE-TYPE .NOD> ,ALL-REST-CODE>
			  <==? <NODE-TYPE .NOD> ,NTH-CODE>>
		      <SET K (<2 .K> <1 .K>)>)>
	       <PUT .NOD ,KIDS .K>
	       <GEN .NOD .WHERE>)
	      (.TY <FORM-GEN .NOD .WHERE>)
	      (ELSE
	       <COMPILE-ERROR "Non-applicabe object type "
			      <NODE-NAME .NOD>
			      .NOD>)>>

" Generate a call to EVAL for uncompilable FORM."

<DEFINE FORM-GEN (NOD WHERE) 
	#DECL ((NOD) NODE)
	<COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP>>)>
	<START-FRAME EVAL>
	<PUSH <REFERENCE <NODE-NAME .NOD>>>
	<MSUBR-CALL EVAL 1 .WHERE>
	.WHERE>

" Generate code for LIST/VECTOR etc. evaluation."

<GDECL (COPIERS) <UVECTOR [REST ATOM]>>

<DEFINE COPY-GEN (NOD WHERE
		  "AUX" (I 0) (ARGS <KIDS .NOD>) SEGTYP (SEGLABEL <MAKE-TAG>)
			(INAME <NODE-NAME .NOD>) SEGTMP COUNTMP RES X
			(SEGCALLED <>)
			(STACK?
			 <COND
			  (<AND <TYPE? <SET X <PARENT .NOD>> NODE>
				<OR <==? <NODE-TYPE .X> ,STACK-CODE>
				    <AND <==? <NODE-TYPE .X> ,CHTYPE-CODE>
					 <TYPE? <SET X <PARENT .X>> NODE>
					 <==? <NODE-TYPE .X>
					      ,STACK-CODE>>>>)
			  (<==? .INAME TUPLE>)>))
   #DECL ((GT) <OR FALSE FIX> (NOD) NODE (ARGS) <LIST [REST NODE]> (I) FIX
	  (SEGCALLED SEGLABEL COUNTMP) <SPECIAL ANY> (STK) FIX)
   <SET I
	<MAPF ,+
	      <FUNCTION (N) 
		      #DECL ((N) NODE)
		      <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE> 0) (ELSE 1)>>
	      .ARGS>>
   <COND
    (<REPEAT (N)
	     #DECL ((N) NODE (STK) FIX)
	     <COND (<EMPTY? .ARGS> <RETURN>)>
	     <COND
	      (<==? <NODE-TYPE <SET N <1 .ARGS>>> ,SEGMENT-CODE>
	       <COND (<NOT <ASSIGNED? SEGTMP>>
		      <SET SEGTMP <GEN-TEMP <>>>
		      <SET COUNTMP <GEN-TEMP FIX>>
		      <SET-TEMP .COUNTMP .I '(`TYPE FIX)>)>
	       <SET RES <GEN <SET N <1 <KIDS .N>>> .SEGTMP>>
	       <SET SEGTYP <STRUCTYP-SEG <RESULT-TYPE .N>>>
	       <COND (<AND <==? <NODE-NAME .NOD> LIST>
			   <EMPTY? <REST .ARGS>>
			   <OR <NOT .SEGTYP> <==? .SEGTYP LIST>>
			   <N==? .RES ,NO-DATUM>> 
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <GEN-TEMP LIST>>)
			    (<TYPE? .WHERE TEMP> <USE-TEMP .WHERE LIST>)>
		      <SEGMENT-LIST .SEGTMP
				    .COUNTMP
				    .SEGTYP
				    .WHERE
				    .SEGLABEL
				    .RES>
		      <FREE-TEMP .SEGTMP>
		      <FREE-TEMP .COUNTMP>
		      <RETURN <>>)
		     (<AND <N==? .RES ,NO-DATUM> <N==? .SEGTYP MULTI>>
		      <SEGMENT-STACK .SEGTMP
				     .COUNTMP
				     .SEGTYP
				     <ISTYPE? <RESULT-TYPE .N>>
				     .SEGLABEL>
		      <SET SEGLABEL <MAKE-TAG>>)
		     (.SEGCALLED
		      <LABEL-TAG .SEGLABEL>
		      <SET SEGLABEL <MAKE-TAG>>)>)
	      (ELSE <GEN <1 .ARGS> ,POP-STACK>)>
	     <SET ARGS <REST .ARGS>>>
     <COND (<ASSIGNED? SEGTMP>
	    <FREE-TEMP .SEGTMP>
	    <COND (<NOT .STACK?> <FREE-TEMP .COUNTMP>)>)>
     <COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP .INAME>>)
	   (<TYPE? .WHERE TEMP> <USE-TEMP .WHERE .INAME>)>
     <COND (<==? .INAME VECTOR>
	    <GEN-VECTOR <COND (<ASSIGNED? SEGTMP> .COUNTMP) (ELSE .I)>
			.WHERE
			.STACK?>)
	   (<==? .INAME LIST>
	    <GEN-LIST <COND (<ASSIGNED? SEGTMP> .COUNTMP) (ELSE .I)> .WHERE>)
	   (<==? .INAME UVECTOR>
	    <GEN-UVECTOR <COND (<ASSIGNED? SEGTMP> .COUNTMP) (ELSE .I)>
			 .WHERE
			 .STACK?>)
	   (<==? .INAME TUPLE>
	    <GEN-TUPLE <COND (<ASSIGNED? SEGTMP> .COUNTMP) (ELSE .I)> .WHERE>)
	   (ELSE <ERROR "NOT READY YET">)>
     <COND
      (.STACK?
       <COND (<ASSIGNED? SEGTMP>
	      <COND (<N==? .INAME UVECTOR>
		     <IEMIT `LSH
			    .COUNTMP
			    1
			    =
			    <COND (<G? <TEMP-REFS .COUNTMP> 1>
				   <FREE-TEMP .COUNTMP <>>
				   <SET COUNTMP <GEN-TEMP FIX>>)>>)>
	      <FREE-TEMP .COUNTMP <>>
	      <COND (<ASSIGNED? STKTMP>
		     <IEMIT `SUB .STKTMP .COUNTMP = .STKTMP>)
		    (ELSE
		     <IEMIT `SUB 0 .COUNTMP = <SET STKTMP <GEN-TEMP FIX>>>)>
	      <SET STK <+ .STK 2>>)
	     (ELSE
	      <SET STK
		   <+ .STK
		      <COND (<==? .INAME UVECTOR> .I) (ELSE <* .I 2>)>
		      2>>)>)>)>
   .WHERE>

"Generate code for a call to a SUBR."

<DEFINE SUBR-GEN (NOD WHERE "AUX" N ST) 
	#DECL ((NOD) NODE)
	<COND (<AND <TYPE? <SET N <PARENT .NOD>> NODE>
		    <==? <NODE-TYPE .N> ,SEGMENT-CODE>
		    <OR <==? <SET ST <STRUCTYP-SEG <RESULT-TYPE .NOD>>> MULTI>
			<NOT .ST>>>
	       <SET SEGCALLED T>
	       <COMP-SUBR-CALL .NOD <KIDS .NOD> .WHERE .COUNTMP .SEGLABEL>)
	      (ELSE <COMP-SUBR-CALL .NOD <KIDS .NOD> .WHERE <> <>>)>>

" Compile call to a SUBR that doesn't compile or PUSHJ."

<DEFINE COMP-SUBR-CALL (N OBJ W PARENT-COUNT PARENT-LABEL
			"AUX" (I 0) SEGTMP COUNTMP (SEGLABEL <MAKE-TAG>) RES
			      (SUBR <NODE-NAME .N>) (SEGCALLED <>) X (SLNT 0)
			      (STACK?
			       <COND
				(<AND
				  <TYPE? <SET X <PARENT .N>> NODE>
				  <OR <==? <NODE-TYPE .X> ,STACK-CODE>
				      <AND
				       <==? <NODE-TYPE .X> ,CHTYPE-CODE>
				       <TYPE? <SET X <PARENT .X>> NODE>
				       <==? <NODE-TYPE .X> ,STACK-CODE>>>>)>))
   #DECL ((I) FIX (OBJ) <LIST [REST NODE]> (UNK) <OR FALSE ATOM> (N) NODE
	  (SEGCALLED SEGLABEL COUNTMP) <SPECIAL ANY>)
   <SET I
	<MAPF ,+
	      <FUNCTION (N) 
		      #DECL ((N) NODE)
		      <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE>
			     <SET SLNT <>>
			     0)
			    (ELSE
			     <COND (<AND <==? .SUBR STRING>
					 <TYPE? .SLNT FIX>
					 <==? <NODE-TYPE .N> ,QUOTE-CODE>>
				    <SET SLNT <+ .SLNT
						 <LENGTH <CHTYPE <NODE-NAME .N>
								 STRING>>>>)
				   (ELSE <SET SLNT <>>)>
			     1)>>
	      .OBJ>>
   <COND (<NOT <MEMQ .SUBR '[LIST VECTOR UVECTOR TUPLE BYTES STRING]>>
	  <COND (.PARENT-COUNT <IEMIT `SFRAME <FORM QUOTE .SUBR>>)
		(ELSE <START-FRAME .SUBR>)>)>
   <MAPF <>
    <FUNCTION (OB) 
       #DECL ((OB) NODE (I STA) FIX)
       <COND
	(<==? <NODE-TYPE .OB> ,SEGMENT-CODE>
	 <COND (<NOT <ASSIGNED? SEGTMP>>
		<SET SEGTMP <GEN-TEMP <>>>
		<SET COUNTMP <GEN-TEMP <>>>
		<SET-TEMP .COUNTMP .I '(`TYPE FIX)>)>
	 <SET RES <GEN <SET OB <1 <KIDS .OB>>> .SEGTMP>>
	 <COND (<AND <N==? .RES ,NO-DATUM>
		     <N==? <STRUCTYP-SEG <RESULT-TYPE .OB>> MULTI>>
		<SEGMENT-STACK
		 .SEGTMP
		 .COUNTMP
		 <STRUCTYP <RESULT-TYPE .OB>>
		 <ISTYPE? <RESULT-TYPE .OB>>
		 .SEGLABEL>)
	       (.SEGCALLED <LABEL-TAG .SEGLABEL>)>
	 <SET SEGLABEL <MAKE-TAG>>)
	(ELSE <GEN .OB ,POP-STACK>)>>
    .OBJ>
   <COND (<ASSIGNED? SEGTMP>
	  <FREE-TEMP .SEGTMP>
	  <COND (<NOT .STACK?> <FREE-TEMP .COUNTMP <>>)>)>
   <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <RESULT-TYPE .N>>>)
	 (<TYPE? .W TEMP> <USE-TEMP .W <RESULT-TYPE .N>>)>
   <COND (.PARENT-COUNT
	  <SEG-SUBR-CALL .SUBR
			 <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>
			 .W
			 .PARENT-COUNT
			 .PARENT-LABEL>)
	 (ELSE
	  <SMSUBR-CALL .SUBR
		       <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>
		       .W
		       .STACK?
		       .SLNT>)>
   .W>

""

<DEFINE SEGMENT-STACK (SEGTMP COUNTMP SEGTYP SEGTYP2
		       "OPT" (TG1 <MAKE-TAG>)
		       "AUX" (TG2 <MAKE-TAG>) TMP)
	<COND (<NOT .SEGTYP>
	       <IEMIT `LOOP
		      (<TEMP-NAME .SEGTMP> TYPE VALUE LENGTH)
		      (<TEMP-NAME .COUNTMP> VALUE)>)
	      (<==? .SEGTYP LIST>
	       <IEMIT `LOOP
		      (<TEMP-NAME .SEGTMP> VALUE)
		      (<TEMP-NAME .COUNTMP> VALUE)>)
	      (ELSE
	       <IEMIT `LOOP
		      (<TEMP-NAME .SEGTMP> VALUE LENGTH)
		      (<TEMP-NAME .COUNTMP> VALUE)>)>
	<LABEL-TAG .TG2>
	<IEMIT `INTGO>
	<COND (.SEGTYP <EMPTY-CHECK .SEGTYP .SEGTMP .SEGTYP2 T .TG1>)
	      (ELSE <IEMIT `EMPTY? .SEGTMP + .TG1>)>
	<COND (.SEGTYP
	       <NTH-DO .SEGTYP .SEGTMP ,POP-STACK 1 .SEGTYP2>
	       <REST-DO .SEGTYP .SEGTMP .SEGTMP 1 .SEGTYP2>)
	      (ELSE
	       <IEMIT `NTH1 .SEGTMP = ,POP-STACK>
	       <IEMIT `REST1 .SEGTMP = .SEGTMP>)>
	<IEMIT `ADD .COUNTMP 1 = .COUNTMP (`TYPE FIX)>
	<BRANCH-TAG .TG2>
	<LABEL-TAG .TG1>>

<DEFINE SEGMENT-LIST (SEGTMP COUNTMP LIST? W
		      "OPT" (TGX <MAKE-TAG>) (RES <>)
		      "AUX" (TG1 <MAKE-TAG>) (TG2 <MAKE-TAG>) (TG3 <MAKE-TAG>)
			    (TG4 <MAKE-TAG>) (OTMP <GEN-TEMP>))
	<COND (<NOT .LIST?>
	       <IEMIT `TYPE .SEGTMP = .OTMP>
	       <IEMIT `AND .OTMP 7 = .OTMP>
	       <IEMIT `VEQUAL? .OTMP 1 + .TG1>
	       <SEGMENT-STACK .SEGTMP .COUNTMP <> <>>
	       <GEN-LIST .COUNTMP .W>
	       <BRANCH-TAG .TG2>
	       <LABEL-TAG .TGX>
	       <SET-TEMP .SEGTMP 0>
	       <LABEL-TAG .TG1>)>
	<IEMIT `LOOP>
	<LABEL-TAG .TG4>
	<IEMIT `VEQUAL? .COUNTMP 0 + .TG3>
	<IEMIT `POP = .OTMP>
	<IEMIT `CONS .OTMP .SEGTMP = .SEGTMP '(`TYPE LIST)>
	<IEMIT `SUB .COUNTMP 1 = .COUNTMP '(`TYPE FIX)>
	<BRANCH-TAG .TG4>
	<LABEL-TAG .TG3>
	<FREE-TEMP .OTMP>
	<MOVE-ARG .SEGTMP .W>
	<COND (<NOT .LIST?> <LABEL-TAG .TG2>)>
	.W>

<GDECL (SUBRS TEMPLATES) VECTOR>

<DEFINE SIDES (L) 
	#DECL ((L) <LIST [REST NODE]>)
	<MAPF <>
	      <FUNCTION (N) 
		      <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE> <>)
			    (<OR <==? <NODE-TYPE .N> ,ISUBR-CODE>
				 <MEMQ ALL <SIDE-EFFECTS .N>:<OR LIST FALSE>>>
			     <MAPLEAVE T>)>>
	      .L>>

" Generate code for a COND."

<DEFINE COND-GEN (NOD W
		  "OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>)
		  "AUX" NW (RW .W) LOCN (COND <MAKE-TAG "COND">) W2 (WSET <>)
			(KK <CLAUSES .NOD>) (SDIR .DIR))
   #DECL ((NOD) NODE (COND) ATOM (KK) <LIST [REST NODE]>)
   <COND (.NOTF <SET DIR <NOT .DIR>>)>
   <COND (<OR <==? .W ,POP-STACK>
	      <AND <TYPE? .W TEMP>
		   <TEMP-NO-RECYCLE .W>
		   <N==? <TEMP-NO-RECYCLE .W> ANY>>>
	  <SET W DONT-CARE>)>
   <MAPR <>
    <FUNCTION (BRN
	       "AUX" (LAST <EMPTY? <REST .BRN>>) (BR <1 .BRN>) NEXT
		     (PRED-TRUE <>) (K <CLAUSES .BR>) (PR <PREDIC .BR>)
		     (NO-SEQ <>) (LEAVE <>) FLG K2 PR2 BR2 PRT2 (BRNCHED <>)
		     (PRT <RESULT-TYPE .PR>) CT)
       #DECL ((BR2 PR2 PR BR) NODE (BRN) <LIST NODE> (K) <LIST [REST NODE]>)
       <COND
	(<AND
	  <NOT .LAST>
	  <TYPE-OK? .PRT FALSE>
	  <NOT
	   <TYPE-OK?
	    <SET PRT2 <RESULT-TYPE <SET PR2 <PREDIC <SET BR2 <2 .BRN>>>>>>
	    FALSE>>
	  <OR <AND <EMPTY? <SET K2 <CLAUSES .BR2>>> <NOT .PRT2>>
	      <AND <NOT <EMPTY? .K2>>
		   <NOT <RESULT-TYPE <NTH .K2 <LENGTH .K2>>>>>>>
	 <COND-COMPLAIN "Predicate assumed true to avoid type mismatch" .PR>
	 <SET PRED-TRUE T>)>
       <COND
	(<EMPTY? .K>
	 <COND
	  (<OR <SET FLG <OR <NOT <TYPE-OK? .PRT FALSE>> .PRED-TRUE>> .LAST>
	   <COND (<NOT .LAST>
		  <COND-COMPLAIN "NON REACHABLE COND CLAUSE(S) " <2 .BRN>>)>
	   <COND
	    (<AND .FLG .BRANCH>
	     <SET LOCN <GEN .PR <COND (<==? .RW FLUSHED> FLUSHED) (ELSE .W)>>>
	     <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .RW FLUSHED>>
		    <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		    <SET WSET T>)>
	     <COND (.DIR <BRANCH-TAG .BRANCH>)>)
	    (<AND .BRANCH .LAST>
	     <SET LOCN
		  <PRED-BRANCH-GEN
		   .BRANCH
		   .PR
		   .SDIR
		   <COND (<==? .RW FLUSHED> FLUSHED)
			 (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			  <SET WSET T>
			  .W)
			 (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>
		   .NOTF>>)
	    (ELSE
	     <SET LOCN <GEN .PR <COND (<==? .RW FLUSHED> FLUSHED) (ELSE .W)>>>
	     <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .RW FLUSHED>>
		    <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		    <SET WSET T>)>)>
	   <MAPLEAVE>)
	  (<NOT .PRT>
	   <COND-COMPLAIN "Predicate assumed FALSE to satisfy type constraint "
			  .PR>
	   <GEN .PR FLUSHED>)
	  (<==? <ISTYPE? .PRT> FALSE> <GEN .PR FLUSHED>)
	  (<==? .RW FLUSHED>
	   <PRED-BRANCH-GEN <COND (<AND .BRANCH .SDIR> .BRANCH) (ELSE .COND)>
			    .PR
			    T
			    FLUSHED
			    .NOTF>)
	  (ELSE
	   <COND
	    (<AND .BRANCH .SDIR>
	     <FREE-TEMP <PRED-BRANCH-GEN .BRANCH .PR T FLUSHED .NOTF>>)
	    (ELSE
	     <SET LOCN
		  <PRED-BRANCH-GEN
		   .COND
		   .PR
		   T
		   <COND (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			  <SET WSET T>
			  .W)
			 (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>
		   .NOTF>>
	     <COND (<NOT .LAST> <DEALLOCATE-TEMP .LOCN>)>)>)>)
	(ELSE
	 <SET NEXT <MAKE-TAG "PHRASE">>
	 <SET CT <RESULT-TYPE <NTH .K <LENGTH .K>>>>
	 <COND
	  (<OR <AND <N==? <ISTYPE? .PRT> FALSE>
		    <NOT .CT>
		    <COND-COMPLAIN 
"Predicate assumed FALSE to satisfy type constraibnt"
				   .PR>>
	       <AND <==? <ISTYPE? .PRT> FALSE>
		    <COND-COMPLAIN "COND PREDICATE ALWAYS FALSE" .PR>>>
	   <COND (<AND .BRANCH .LAST <NOT .DIR>>
		  <SET LOCN <GEN .PR .W>>
		  <COND (<AND <NOT .WSET>
			      <N==? .LOCN ,NO-DATUM>
			      <N==? .RW FLUSHED>>
			 <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
			 <SET WSET T>)>
		  <BRANCH-TAG .BRANCH>)
		 (ELSE
		  <COND (<AND .LAST <NOT <==? .RW FLUSHED>>>
			 <SET LOCN <GEN .PR .W>>
			 <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM>>
				<SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
				<SET WSET T>)>)
			(ELSE <SET LOCN <GEN .PR FLUSHED>>)>
		  <COND (<N==? .PRT NO-RETURN> <BRANCH-TAG .NEXT>)>)>
	   <SET NO-SEQ T>)
	  (<AND <TYPE-OK? FALSE .PRT> <NOT .PRED-TRUE>>
	   <COND
	    (<AND .LAST <NOT .DIR> .BRANCH>
	     <SET LOCN
		  <PRED-BRANCH-GEN
		   .BRANCH
		   .PR
		   <>
		   <COND (<==? .RW FLUSHED> FLUSHED)
			 (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			  <SET WSET T>
			  .W)
			 (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>
		   .NOTF>>
	     <DEALLOCATE-TEMP .LOCN>)
	    (<AND .LAST .BRANCH>
	     <FREE-TEMP <PRED-BRANCH-GEN .NEXT .PR <> FLUSHED>>)
	    (<AND .LAST <NOT <==? .RW FLUSHED>>>
	     <SET LOCN
		  <PRED-BRANCH-GEN
		   .NEXT
		   .PR
		   <>
		   <COND (<==? .RW FLUSHED> FLUSHED)
			 (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			  <SET WSET T>
			  .W)
			 (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>>>
	     <DEALLOCATE-TEMP .LOCN>)
	    (ELSE <PRED-BRANCH-GEN .NEXT .PR <> FLUSHED>)>)
	  (ELSE
	   <SET K (.PR !.K)>
	   <COND (<NOT .LAST>
		  <SET LEAVE T>
		  <COND-COMPLAIN "NON REACHABLE COND CLAUSE(S)" <2 .BRN>>)>)>
	 <COND
	  (.BRANCH
	   <OR
	    .NO-SEQ
	    <COND
	     (<OR
	       <SET FLG
		    <NOT <TYPE-OK?
			  <RESULT-TYPE <SET PR <NTH .K <LENGTH .K>>>>
			  FALSE>>>
	       <NOT <TYPE-OK? <RESULT-TYPE .PR> '<NOT FALSE>>>>
	      <COND (.NOTF
		     <SEQ-GEN .K FLUSHED>
		     <COND (<==? .RW FLUSHED> <SET LOCN ,NO-DATUM>)
			   (ELSE
			    <SET LOCN <MOVE-ARG <REFERENCE <NOT .FLG>> .W>>
			    <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM>>
				   <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
				   <SET WSET T>)>)>)
		    (ELSE
		     <SET LOCN
			  <SEQ-GEN .K
				   <COND (<OR <==? .RW FLUSHED>
					      <N==? .SDIR .FLG>>
					  FLUSHED)
					 (ELSE .W)>>>
		     <COND (<AND <NOT .WSET>
				 <N==? .RW FLUSHED>
				 <N==? .LOCN ,NO-DATUM>>
			    <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
			    <SET WSET T>)>)>
	      <COND (<==? .FLG .SDIR> <SET BRNCHED T> <BRANCH-TAG .BRANCH>)>)
	     (ELSE
	      <SET LOCN
		   <PSEQ-GEN .K
			     <COND (<==? .RW FLUSHED> FLUSHED) (ELSE .W)>
			     .BRANCH
			     .SDIR
			     .NOTF>>
	      <COND (<AND <NOT .WSET>
			  <N==? .LOCN ,NO-DATUM>
			  <N==? .RW FLUSHED>>
		     <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		     <SET WSET T>)>)>>)
	  (<NOT .NO-SEQ>
	   <SET LOCN
		<PSEQ-GEN .K
			  <COND (<==? .RW FLUSHED> FLUSHED) (ELSE .W)>
			  .BRANCH
			  .SDIR
			  .NOTF>>
	   <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .RW FLUSHED>>
		  <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		  <SET WSET T>)>)>
	 <COND (<AND <NOT .LAST>
		     <N==? <RESULT-TYPE <NTH .K <LENGTH .K>>> NO-RETURN>>
		<OR .NO-SEQ <DEALLOCATE-TEMP .LOCN>>
		<OR .BRNCHED .NO-SEQ <BRANCH-TAG .COND>>)>
	 <LABEL-TAG .NEXT>)>
       <COND (<NOT <ASSIGNED? NPRUNE>> <PUT .BR ,CLAUSES ()>)>
       <AND .LEAVE <MAPLEAVE>>>
    .KK>
   <COND (<NOT <ASSIGNED? NPRUNE>> <PUT .NOD ,CLAUSES ()>)>
   <LABEL-TAG .COND>
   <SET NW
	<COND (<==? <RESULT-TYPE .NOD> NO-RETURN> ,NO-DATUM)
	      (ELSE <MOVE-ARG .W .RW>)>>
   .NW>

<DEFINE FIXUP-TEMP (W LOCN) 
	<COND (<AND <TYPE? .LOCN TEMP> <L=? <TEMP-REFS .LOCN> 1>> .LOCN)
	      (<==? .LOCN .W> .LOCN)
	      (ELSE <MOVE-ARG .LOCN <GEN-TEMP <>>>)>>

<DEFINE PSEQ-GEN (L W B D NF "AUX" (WSET <>) WW) 
   #DECL ((L) <LIST [REST NODE]>)
   <MAPR <>
    <FUNCTION (N "AUX" (ND <1 .N>) NX K) 
	    #DECL ((N) <LIST NODE> (ND) NODE)
	    <COND (<NOT <EMPTY? <REST .N>>>
		   <SET NX <2 .N>>
		   <COND (<AND <==? <NODE-TYPE .NX> ,CALL-CODE>
			       <G=? <LENGTH <SET K <KIDS .NX>>> 2>
			       <==? <NODE-NAME <1 .K>> `ENDIF>>
			  <SET WW <GEN .ND .W>>
			  <COND (<AND <NOT .WSET>
				      <N==? .W FLUSHED>
				      <N==? .WW ,NO-DATUM>
				      <N==? .W ,POP-STACK>>
				 <SET W <FIXUP-TEMP .W .WW>>
				 <SET WSET T>)>
			  <COND (<NOT <EMPTY? <REST .N 2>>>
				 <DEALLOCATE-TEMP .W>)>)
			 (<OR <AND <G=? <LENGTH .ND> <INDEX ,SIDE-EFFECTS>>
				   <SIDE-EFFECTS .ND>>
			      <GETPROP .ND DONT-FLUSH-ME>
			      ,DONT-FLUSH-ME>
			  <GEN .ND FLUSHED>)>)
		  (<AND <==? <NODE-TYPE .ND> ,CALL-CODE>
			<G=? <LENGTH <SET K <KIDS .ND>>> 2>
			<==? <NODE-NAME <1 .K>> `ENDIF>>
		   <GEN .ND FLUSHED>)
		  (ELSE
		   <SET W
			<COND (.B <PRED-BRANCH-GEN .B .ND .D .W .NF>)
			      (ELSE <GEN .ND .W>)>>)>>
    .L>
   .W>

<DEFINE COND-COMPLAIN (MSG N1) #DECL ((N1) NODE) <COMPILE-NOTE .MSG .N1>>

" Generate code for OR use BOOL-GEN to do work."

<DEFINE OR-GEN (NOD WHERE "OPTIONAL" (NF <>) (BR <>) (DIR T)) 
	#DECL ((NOD) NODE)
	<BOOL-GEN .NOD <CLAUSES .NOD> T .WHERE .NF .BR .DIR>>

" Generate code for AND use BOOL-GEN to do work."

<DEFINE AND-GEN (NOD WHERE "OPTIONAL" (NF <>) (BR <>) (DIR <>)) 
	#DECL ((NOD) NODE)
	<BOOL-GEN .NOD <CLAUSES .NOD> <> .WHERE .NF .BR .DIR>>

<DEFINE BOOL-GEN (NOD PREDS RESULT W NOTF BRANCH DIR
		  "AUX" (RW .W) (BOOL <MAKE-TAG "BOOL">)
			(FLUSH <==? .RW FLUSHED>) (WSET <>)
			(FLS <AND <NOT .BRANCH> .FLUSH>) RTF SRES LOCN FIN)
   #DECL ((PREDS) <LIST [REST NODE]> (NOTF DIR FLUSH FLS RTF) ANY (BOOL) ATOM
	  (BRANCH) <OR ATOM FALSE> (NOD) NODE (LOCN) ANY (SRES RESULT) ANY)
   <COND (<OR <==? .W ,POP-STACK>
	      <AND <TYPE? .W TEMP>
		   <TEMP-NO-RECYCLE .W>
		   <N==? <TEMP-NO-RECYCLE .W> ANY>>>
	  <SET W DONT-CARE>)>
   <COND (.NOTF <SET RESULT <NOT .RESULT>>)>
   <SET SRES .RESULT>
   <SET RTF
	<AND <NOT .FLUSH>
	     <==? .SRES .DIR>
	     <TYPE-OK? <RESULT-TYPE .NOD> FALSE>>>
   <COND (.DIR <SET RESULT <NOT .RESULT>>)>
   <COND
    (<EMPTY? .PREDS> <SET LOCN <MOVE-ARG <REFERENCE .RESULT> .W>>)
    (ELSE
     <MAPR <>
      <FUNCTION (BRN
		 "AUX" (BR <1 .BRN>) (LAST <EMPTY? <REST .BRN>>)
		       (RT <RESULT-TYPE .BR>) (RTFL <>) TY)
	 #DECL ((BRN) <LIST NODE [REST NODE]> (BR) NODE)
	 <COND
	  (<AND .FLUSH
		<NOT .LAST>
		<EMPTY? <REST .BRN 2>>
		<OR <AND <==? <ISTYPE? <SET TY <RESULT-TYPE <2 .BRN>>>> FALSE>
			 <NOT .SRES>
			 <SET TY FALSE>>
		    <AND .SRES <NOT <TYPE-OK? .TY FALSE>>>>
		<OR <L? <LENGTH <2 .BRN>> <INDEX ,SIDE-EFFECTS>>
		    <NOT <SIDE-EFFECTS <2 .BRN>>>>>
	   <COND (<==? .TY FALSE> <SET RT ATOM>) (ELSE <SET RT FALSE>)>)>
	 <COND
	  (<AND <TYPE-OK? .RT FALSE>
		<NOT <SET RTFL <==? <ISTYPE? .RT> FALSE>>>>
	   <COND
	    (<OR .BRANCH <AND .FLS <NOT .LAST>>>
	     <COND
	      (.LAST
	       <SET LOCN
		<PRED-BRANCH-GEN
		 .BRANCH
		 .BR
		 .DIR
		 <COND (.FLUSH FLUSHED)
		       (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			<SET WSET T>
			.W)
		       (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>
		 .NOTF>>)
	      (ELSE
	       <SET LOCN
		<PRED-BRANCH-GEN
		 <COND (.FLS .BOOL) (.RESULT .BOOL) (ELSE .BRANCH)>
		 .BR
		 .SRES
		 <COND (<OR .FLUSH <NOT .RTF>> FLUSHED)
		       (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			<SET WSET T>
			.W)
		       (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>
		 .NOTF>>
	       <DEALLOCATE-TEMP .LOCN>)>)
	    (.LAST
	     <SET LOCN <GEN .BR .W>>
	     <COND (<AND <NOT .FLUSH> <N==? .LOCN ,NO-DATUM> <NOT .WSET>>
		    <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		    <SET WSET T>)>
	     .LOCN)
	    (ELSE
	     <SET LOCN
		  <PRED-BRANCH-GEN
		   .BOOL
		   .BR
		   .DIR
		   <COND (.FLUSH FLUSHED)
			 (<OR .WSET <AND <TYPE? .W TEMP> <0? <TEMP-REFS .W>>>>
			  <SET WSET T>
			  .W)
			 (ELSE <SET WSET T> <SET W <GEN-TEMP <>>>)>
		   .NOTF>>
	     <DEALLOCATE-TEMP .LOCN>)>)
	  (<OR <N==? .SRES <COND (.NOTF <SET RTFL <NOT .RTFL>>) (ELSE .RTFL)>>
	       .LAST>
	   <COND (<NOT .LAST>
		  <COMPILE-NOTE "NON REACHABLE AND/OR CLAUSE" <2 .BRN>>)>
	   <COND (.BRANCH
		  <SET LOCN
		       <GEN .BR <COND (<N==? .DIR .RTFL> .W) (ELSE FLUSHED)>>>
		  <COND (<AND <NOT .FLUSH>
			      <N==? .LOCN ,NO-DATUM>
			      <NOT .WSET>
			      <N==? .DIR .RTFL>>
			 <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
			 <SET WSET T>)>
		  <COND (<AND <N==? .DIR .RTFL>
			      <N==? <RESULT-TYPE .BR> NO-RETURN>>
			 <BRANCH-TAG .BRANCH>)>)
		 (ELSE
		  <SET LOCN <GEN .BR .W>>
		  <COND (<AND <NOT .FLUSH> <N==? .LOCN ,NO-DATUM> <NOT .WSET>>
			 <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
			 <SET WSET T>)>
		  .LOCN)>
	   <MAPLEAVE>)
	  (ELSE
	   <COND (<OR <L? <LENGTH .BR> <INDEX ,SIDE-EFFECTS>>
		      <NOT <SIDE-EFFECTS .BR>>
		      <==? .BRN .PREDS>>
		  <COMPILE-NOTE <STRING "PREDICATE ALWAYS "
					<COND (.RTFL "FALSE")
					      (ELSE "TRUE")>  " IN AND/OR">
				.BR>)>
	   <GEN .BR FLUSHED>)>>
      .PREDS>)>
   <COND (<NOT <ASSIGNED? NPRUNE>> <PUT .NOD ,CLAUSES ()>)>
   <COND (<NOT <AND .BRANCH <NOT .RESULT>>> <LABEL-TAG .BOOL>)>
   <SET FIN
	<COND (<==? <RESULT-TYPE .NOD> NO-RETURN> ,NO-DATUM)
	      (ELSE <MOVE-ARG .W .RW>)>>
   .FIN>

" Generate code for ASSIGNED?"

<DEFINE ASSIGNED?-GEN (N W
		       "OPTIONAL" (NF <>) (BR <>) (DIR <>) (SETF <>)
		       "AUX" (A <NODE-NAME .N>) (SDIR .DIR)
			     (FLS <==? .W FLUSHED>) B2 TMP (GLOBAL T))
	#DECL ((N) NODE)
	<COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>
	<COND (.NF <SET DIR <NOT .DIR>>)>
	<COND (.SETF <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>>
						.W>>)>
	<SET DIR <COND (<AND .BR <NOT .FLS>> <NOT .DIR>) (ELSE .DIR)>>
	<COND (<AND <TYPE? .A SYMTAB> <NOT <SPEC-SYM .A>>>
	       <SET A <LADDR .A>>
	       <COND (<AND .BR .FLS>
		      <GEN-TYPE? .A UNBOUND .BR <NOT .DIR>>
		      FLUSHED)
		     (.BR
		      <GEN-TYPE? .A UNBOUND <SET B2 <MAKE-TAG>> <NOT .DIR>>
		      <SET W <MOVE-ARG <REFERENCE .SDIR> .W>>
		      <BRANCH-TAG .BR>
		      <LABEL-TAG .B2>
		      .W)
		     (ELSE
		      <GEN-TYPE? .A UNBOUND <SET BR <MAKE-TAG>> <NOT .DIR>>
		      <TRUE-FALSE .N .BR .W>)>)
	      (ELSE
	       <COND (<TYPE? .A SYMTAB>
		      <COND (<N==? <CODE-SYM .A> -1> <SET GLOBAL <>>)>
		      <SET A <NAME-SYM .A>>)
		     (ELSE <SET A <GEN <1 <KIDS .N>>>>)>
	       <COND (<AND .BR .FLS>
		      <ASS-GEN .A .BR .DIR .GLOBAL>
		      <FREE-TEMP .A>
		      FLUSHED)
		     (.BR
		      <ASS-GEN .A <SET B2 <MAKE-TAG>> .DIR .GLOBAL>
		      <SET W <MOVE-ARG <REFERENCE .SDIR> .W>>
		      <BRANCH-TAG .BR>
		      <LABEL-TAG .B2>
		      <FREE-TEMP .A>
		      .W)
		     (ELSE
		      <ASS-GEN .A <SET BR <MAKE-TAG>> .DIR .GLOBAL>
		      <FREE-TEMP .A>
		      <TRUE-FALSE .N .BR .W>)>)>>

<DEFINE GASSIGNED?-GEN (N W
			"OPTIONAL" (NF <>) (BR <>) (DIR <>) (SETF <>)
			"AUX" (A <NODE-NAME .N>) (SDIR .DIR)
			      (NM <NODE-NAME .N>) (FLS <==? .W FLUSHED>) B2
			      TMP)
	#DECL ((N) NODE)
	<COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>
	<COND (.NF <SET DIR <NOT .DIR>>)>
	<COND (.SETF <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .W>>)>
	<SET DIR <COND (<AND .BR <NOT .FLS>> <NOT .DIR>) (ELSE .DIR)>>
	<SET A <GEN <1 <KIDS .N>>>>
	<COND (<AND .BR .FLS> <GEN-GASS .A .BR .DIR .NM> FLUSHED)
	      (.BR
	       <GEN-GASS .A <SET B2 <MAKE-TAG>> .DIR .NM>
	       <SET W <MOVE-ARG <REFERENCE .SDIR> .W>>
	       <BRANCH-TAG .BR>
	       <LABEL-TAG .B2>
	       .W)
	      (ELSE
	       <GEN-GASS .A <SET BR <MAKE-TAG>> .DIR .NM>
	       <TRUE-FALSE .N .BR .W>)>>

<DEFINE TRUE-FALSE (N B W "OPTIONAL" (THIS T) "AUX" (RW .W) (B2 <MAKE-TAG>)) 
	#DECL ((N) NODE (B2 B) ATOM)
	<MOVE-ARG <REFERENCE .THIS> .W>
	<BRANCH-TAG .B2>
	<LABEL-TAG .B>
	<MOVE-ARG <REFERENCE <NOT .THIS>> .W>
	<LABEL-TAG .B2>
	<DEALLOCATE-TEMP .W>
	<MOVE-ARG .W .RW>>

" Generate code for LVAL."

<DEFINE LVAL-GEN (NOD WHERE
		  "AUX" (SYM <NODE-NAME .NOD>) TT (ADDR <>) REFS
			(LIVE
			 <COND (<==? <LENGTH <SET TT <TYPE-INFO .NOD>>> 2>
				<2 .TT>)
			       (ELSE T)>) TMP)
   #DECL ((NOD) NODE (SYM) SYMTAB (NO-KILL) LIST (REFS) FIX)
   <COND (<==? <RESULT-TYPE .NOD> NO-RETURN>
	  <COMPILE-ERROR "Variable referenced before initialization: "
			 <NAME-SYM .SYM>
			 .NOD>)>
   <SET TT
    <MOVE-ARG
     <COND
      (<AND <SPEC-SYM .SYM> <N==? <CODE-SYM .SYM> -1>>
       <SET TMP
	    <COND (<TYPE? .WHERE TEMP> .WHERE)
		  (<==? .WHERE ,POP-STACK> .WHERE)
		  (ELSE <GEN-TEMP <>>)>>
       <COND (<TYPE? .TMP TEMP> <USE-TEMP .TMP <DECL-SYM .SYM>>)>
       <GET-VALUE-X <NAME-SYM .SYM> .TMP>
       .TMP)
      (<SPEC-SYM .SYM>
       <SET TMP <COND (<TYPE? .WHERE TEMP> .WHERE) (ELSE <GEN-TEMP <>>)>>
       <USE-TEMP .TMP>
       <START-FRAME LVAL>
       <PUSH-CONSTANT <NAME-SYM .SYM>>
       <MSUBR-CALL LVAL 1 .TMP>
       .TMP)
      (ELSE
       <SET ADDR <LADDR .SYM>>
       <COND (<TYPE? .ADDR TEMP>
	      <COND (<AND ,DEATH
			  <NOT .LIVE>
			  <NOT <SPEC-SYM .SYM>>
			  <NOT <MAPF <>
				     <FUNCTION (LL) 
					     #DECL ((LL) LIST)
					     <AND <==? <1 .LL> .SYM>
						  <PUT .LL 2 T>
						  <MAPLEAVE>>>
				     .NO-KILL>>>)
		    (<0? <SET REFS <TEMP-REFS .ADDR>>> <USE-TEMP .ADDR>)
		    (ELSE <PUT .ADDR ,TEMP-REFS <+ .REFS 1>>)>)>
       .ADDR)>
     .WHERE>>
   .TT>

<DEFINE DELAY-KILL (L1 L2 "AUX" TT TAC SYM) 
	#DECL ((L1 L2) <LIST [REST !<LIST SYMTAB <OR ATOM FALSE>>]>
	       (SYM) SYMTAB)
	<REPEAT ()
		<COND (<OR <==? .L1 .L2> <NOT ,DEATH>> <RETURN>)>
		<COND (<2 <SET TT <1 .L1>>>
		       <SET TT <TEMP-NAME-SYM <SET SYM <1 .TT>>>>
		       <FREE-TEMP .TT>)>
		<SET L1 <REST .L1>>>>

" Generate LVAL for free variable."

<DEFINE FLVAL-GEN (NOD WHERE "AUX" TMP T1) 
	#DECL ((NOD) NODE)
	<SET TMP <COND (<==? .WHERE DONT-CARE> <GEN-TEMP <>>) (ELSE .WHERE)>>
	<COND (<TYPE? .TMP TEMP> <USE-TEMP .TMP>)>
	<COND (<TYPE? <SET T1 <NODE-NAME .NOD>> SYMTAB>
	       <SET T1 <NAME-SYM .T1>>)
	      (<==? <NODE-TYPE <1 <KIDS .NOD>>> ,QUOTE-CODE>
	       <SET T1 <NODE-NAME <1 <KIDS .NOD>>>>)
	      (ELSE <SET T1 <GEN <1 <KIDS .NOD>>>>)>
	<GET-VALUE-X .T1 .TMP T>
	<FREE-TEMP .T1>
	<MOVE-ARG .TMP .WHERE>>

<DEFINE FSET-GEN (NOD WHERE "AUX" TT (TEM <>) T1) 
	#DECL ((NOD) NODE (TEM) <OR FALSE NODE>)
	<COND (<==? <NODE-SUBR .NOD> ,SET> <SET TEM <2 <KIDS .NOD>>>)>
	<COND (<TYPE? <SET TT <NODE-NAME .NOD>> SYMTAB>
	       <SET TT <NAME-SYM .TT>>)
	      (<==? <NODE-TYPE <SET T1 <1 <KIDS .NOD>>>> ,QUOTE-CODE>
	       <SET TT <NODE-NAME .T1>>)
	      (ELSE
	       <SET TT <GEN .T1>>
	       <COND (.TEM <SET TT <INTERF-CHANGE .TT .TEM>>)>)>
	<COND (.TEM
	       <SET T1
		    <GEN .TEM <COND (<TYPE? .WHERE TEMP> .WHERE)
				    (ELSE DONT-CARE)>>>)
	      (ELSE
	       <SET T1 ,THE-UNBOUND>)>
	<SET T1 <SET-VALUE .TT .T1 T>>
	<FREE-TEMP .TT>
	<MOVE-ARG <COND (<==? .T1 ,THE-UNBOUND> .TT) (ELSE .T1)> .WHERE>>

" Generate code for an internal SET."

<DEFINE SET-GEN (NOD WHERE "OPT" (NOTF <>) (BRANCH <>) (DIR <>)
		 "AUX" (SYM <NODE-NAME .NOD>) TY PT TEM (TT <>) REFS
				 (NM <2 <CHTYPE <NODE-SUBR .NOD> MSUBR>>))
	#DECL ((NOD) NODE (SYM) SYMTAB)
	<COND
	 (<AND <SPEC-SYM .SYM> <N==? <CODE-SYM .SYM> -1>>
	  <COND (<==? .NM SET>
		 <SET TEM
		      <GEN <2 <KIDS .NOD>>
			   <COND (<TYPE? .WHERE TEMP> .WHERE) (ELSE DONT-CARE)>>>
		 <SET-VALUE <NAME-SYM .SYM> .TEM>)
		(ELSE
		 <SET-VALUE <NAME-SYM .SYM> ,THE-UNBOUND>
		 <SET TEM <NAME-SYM .SYM>>)>
	  <MOVE-ARG .TEM .WHERE>)
	 (<AND <SPEC-SYM .SYM> <==? .NM UNASSIGN>>
	  <START-FRAME UNASSIGN>
	  <PUSH-CONSTANT <NAME-SYM .SYM>>
	  <COND (<==? .WHERE DONT-CARE>
		 <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
		(<TYPE? .WHERE TEMP> <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
	  <MSUBR-CALL UNASSIGN 1 .WHERE>
	  <COND (<==? .WHERE FLUSHED> ,NO-DATUM) (ELSE .WHERE)>)
	 (<SPEC-SYM .SYM>
	  <START-FRAME SET>
	  <PUSH-CONSTANT <NAME-SYM .SYM>>
	  <GEN <2 <KIDS .NOD>> ,POP-STACK>
	  <COND (<==? .WHERE DONT-CARE>
		 <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
		(<TYPE? .WHERE TEMP> <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
	  <MSUBR-CALL SET 2 .WHERE>
	  <COND (<==? .WHERE FLUSHED> ,NO-DATUM) (ELSE .WHERE)>)
	 (ELSE
	  <SET TEM <LADDR .SYM>>
	  <COND (<AND <NOT <TEMP-ALLOC .TEM>>
		      <COND (<AND <SET TY <ISTYPE? <DECL-SYM .SYM>>>
				  <OR <==? <SET PT <TYPEPRIM .TY>> FIX>
				      <==? .PT WORD>
				      <==? .PT LIST>>>
			     .TY)>>
		 <DEALLOCATE-TEMP <USE-TEMP .TEM .TY>>)>
	  <COND (<==? .NM SET>
		 <COND (.BRANCH
			<COND (.NOTF <SET DIR <NOT .DIR>>)>
			<PRED-BRANCH-GEN .BRANCH <2 <KIDS .NOD>> .DIR .TEM
					  <> T>)
		       (ELSE
			<SET TEM <GEN <2 <KIDS .NOD>> .TEM>>)>)
		(ELSE
		 <MOVE-ARG ,THE-UNBOUND .TEM>)>
	  <COND (<TYPE? .TEM TEMP>
		 <COND (<0? <SET REFS <TEMP-REFS .TEM>>> <SET REFS 1>)>
		 <PUT .TEM ,TEMP-REFS <+ .REFS 1>>)>
	  <MOVE-ARG .TEM .WHERE>)>>

<DEFINE ARG? (SYM) #DECL ((SYM) SYMTAB) <1? <NTH ,ARGTBL <CODE-SYM .SYM>>>>

<DEFINE OPT? (SYM) #DECL ((SYM) SYMTAB) <1? <NTH ,OPTBL <CODE-SYM .SYM>>>>

<SETG OPTBL ![0 0 0 0 0 1 1 1 1 0 0 0 0]>

<SETG ARGTBL ![0 0 0 0 1 0 0 0 0 1 0 1 1]>

<GDECL (OPTBL ARGTBL) <UVECTOR [REST FIX]>>

" Compute the address of a local variable using the stack model."

<DEFINE LADDR (S) #DECL ((S) SYMTAB) <TEMP-NAME-SYM .S>>

" Generate obscure stuff."

<DEFINE DEFAULT-GEN (NOD WHERE) 
	#DECL ((NOD) NODE)
	<MOVE-ARG <REFERENCE <NODE-NAME .NOD>> .WHERE>>

" Do GVAL using direct locative reference."

<DEFINE GVAL-GEN (N W "AUX" (RT <RESULT-TYPE .N>) (TYP <ISTYPE? .RT>)) 
	#DECL ((N) NODE)
	<GEN-GVAL <NODE-NAME <1 <KIDS .N>>>
		  <COND (<==? .W DONT-CARE>
			 <SET W <GEN-TEMP .RT>>)
			(<TYPE? .W TEMP> <USE-TEMP .W .RT> .W)
			(ELSE .W)>
		  .TYP>
	.W>

" Do SETG using direct locative reference."

<DEFINE SETG-GEN (N W "AUX" TEM) 
	#DECL ((N) NODE)
	<SET TEM <GEN <2 <KIDS .N>>>>
	<GEN-SETG <NODE-NAME <1 <KIDS .N>>>
		  .TEM
		  <COND (<==? <LENGTH <KIDS .N>> 3>
			 <GEN <3 <KIDS .N>> DONT-CARE>)
			(ELSE <>)>
		  FLUSHED>
	<MOVE-ARG .TEM .W>>

" Generate GVAL calls."

<DEFINE FGVAL-GEN (N W "AUX" TEM) 
	#DECL ((N) NODE)
	<GEN-GVAL <SET TEM <GEN <1 <KIDS .N>>>>
		  <COND (<==? .W DONT-CARE>
			 <SET W <GEN-TEMP <RESULT-TYPE .N>>>)
			(<TYPE? .W TEMP> <USE-TEMP .W <RESULT-TYPE .N>> .W)
			(ELSE .W)>>
	<FREE-TEMP .TEM>
	.W>

" Generate a SETG call."

<DEFINE FSETG-GEN (NOD W "AUX" TEM ATM) 
	#DECL ((NOD) NODE)
	<SET ATM <GEN <1 <KIDS .NOD>>>>
	<SET ATM <INTERF-CHANGE .ATM <2 <KIDS .NOD>>>>
	<SET TEM
	     <GEN <2 <KIDS .NOD>>
		  <COND (<TYPE? .W TEMP> .W) (ELSE DONT-CARE)>>>
	<GEN-SETG .ATM
		  .TEM
		  <COND (<==? <LENGTH <KIDS .NOD>> 3>
			 <GEN <3 <KIDS .NOD>> DONT-CARE>)
			(ELSE <>)>
		  .W>
	<FREE-TEMP .ATM>
	<MOVE-ARG .TEM .W>>

<DEFINE CHTYPE-GEN (NOD WHERE
		    "AUX" (TYP <ISTYPE? <RESULT-TYPE .NOD>>)
			  (N <1 <KIDS .NOD>>) N2 TEM TT)
	#DECL ((NOD N) NODE)
	<COND (<AND .TYP
		    <TYPE? <PARENT .NOD> NODE>
		    <MEMQ <NODE-TYPE <PARENT .NOD>> ,CHTYPE-FOR-FREE>
		    <OR <==? .WHERE ,POP-STACK> <==? .WHERE DONT-CARE>>>
	       <GEN .N .WHERE>)
	      (ELSE
	       <SET TEM <GEN .N>>
	       <COND (<AND <G? <LENGTH <KIDS .NOD>> 1>
			   <N==? <NODE-TYPE <SET N2 <2 <KIDS .NOD>>>>
				 ,QUOTE-CODE>>
		      <SET TEM <INTERF-CHANGE .TEM .N2>>
		      <SET TT <GEN <1 <KIDS .N2>>>>)>
	       <COND (<==? .WHERE DONT-CARE>
		      <COND (<AND <TYPE? .TEM TEMP> <L=? <TEMP-REFS .TEM> 1>>
			     <DEALLOCATE-TEMP <SET WHERE .TEM>>
			     <USE-TEMP .TEM .TYP>)
			    (ELSE
			     <SET WHERE <GEN-TEMP <COND (.TYP) (ELSE ANY)>>>)>)
		     (<TYPE? .WHERE TEMP> <USE-TEMP .WHERE .TYP>)>
	       <COND (<AND <ASSIGNED? N2> <N==? <NODE-TYPE .N2> ,QUOTE-CODE>>
		      <COND (<NOT <TYPE? .TT TEMP>>
			     <SET TT <MOVE-ARG .TT <GEN-TEMP <>>>>)>
		      <GEN-CHTYPE .TEM <FORM `TYPE <TEMP-NAME .TT>> .WHERE>
		      <FREE-TEMP .TT>)
		     (ELSE <GEN-CHTYPE .TEM .TYP .WHERE>)>
	       <COND (<N==? .TEM .WHERE> <FREE-TEMP .TEM>)>
	       .WHERE)>>

<GDECL (CHTYPE-FOR-FREE) <VECTOR [REST FIX]>>

<SETG CHTYPE-FOR-FREE
      [,NTH-CODE
       ,ARITH-CODE
       ,0-TST-CODE
       ,1?-CODE
       ,TEST-CODE
       ,LNTH-CODE
       ,MT-CODE
       ,REST-CODE
       ,MOD-CODE
       ,BITS-CODE
       ,BITL-CODE
       ,ROT-CODE
       ,LSH-CODE
       ,BIT-TEST-CODE]>

" Generate do-nothing piece of code."

<DEFINE ID-GEN (N W) #DECL ((N) NODE) <GEN <1 <KIDS .N>> .W>>

" Generate call to READ etc. with eof condition."

<DEFINE READ2-GEN (N W "AUX" (I 0) SPOB BRANCH TMP CF) 
	#DECL ((N) NODE (I) FIX (SPOB) NODE)
	<COND (<AND <TYPE? .W TEMP> <L? <TEMP-REFS .W> 1>> <SET TMP .W>)
	      (ELSE <SET TMP <GEN-TEMP <>>>)>
	<START-FRAME <NODE-NAME .N>>
	<MAPF <>
	      <FUNCTION (OB) 
		      #DECL ((OB SPOB) NODE (I) FIX)
		      <COND (<==? <NODE-TYPE .OB> ,EOF-CODE>
			     <SET SPOB .OB>
			     <CURRENT-FRAME ,POP-STACK>)
			    (ELSE <GEN .OB ,POP-STACK>)>
		      <SET I <+ .I 1>>>
	      <KIDS .N>>
	<USE-TEMP .TMP>
	<MSUBR-CALL <NODE-NAME .N> .I .TMP>
	<GEN-==? <SET CF <CURRENT-FRAME>> .TMP <> <SET BRANCH <MAKE-TAG>>>
	<FREE-TEMP .CF>
	<DEALLOCATE-TEMP .TMP>
	<GEN .SPOB .TMP>
	<LABEL-TAG .BRANCH>
	<MOVE-ARG .TMP .W>>

<DEFINE GET-GEN (N W) <GETGET .N .W T>>

<DEFINE GET2-GEN (N W) <GETGET .N .W <>>>

<GDECL (GETTERS) UVECTOR>

<DEFINE GETGET (N W REV
		"AUX" (K <KIDS .N>) (BR <MAKE-TAG>) TMP (LN <LENGTH .K>) CF)
	#DECL ((N) NODE (K) <LIST NODE NODE [REST NODE]> (LN) FIX)
	<START-FRAME <NODE-NAME .N>>
	<GEN <1 .K> ,POP-STACK>
	<GEN <2 .K> ,POP-STACK>
	<COND (<==? .LN 3> <CURRENT-FRAME ,POP-STACK>)>
	<MSUBR-CALL <NODE-NAME .N>
		    .LN
		    <COND (<AND <TYPE? .W TEMP>
				<OR <L? .LN 3> <L? <TEMP-REFS .W> 1>>>
			   <USE-TEMP <SET TMP .W>>)
			  (ELSE <SET TMP <GEN-TEMP>>)>>
	<COND (<==? .LN 3>
	       <GEN-==? <SET CF <CURRENT-FRAME>> .TMP <> <SET BR <MAKE-TAG>>>
	       <FREE-TEMP .CF>
	       <COND (.REV
		      <START-FRAME EVAL>
		      <GEN <3 .K> ,POP-STACK>
		      <DEALLOCATE-TEMP <MSUBR-CALL EVAL 1 .TMP>>)
		     (ELSE <DEALLOCATE-TEMP <GEN <3 .K> .TMP>>)>
	       <LABEL-TAG .BR>)>
	<MOVE-ARG .TMP .W>>

'<SETG GETTERS [,GET ,GETL ,GETPROP ,GETPL]>

<SETG STACK-INS [`CALL `UBLOCK `LIST `SYSCALL]>

<GDECL (STACK-INS) <VECTOR [REST ATOM]>>

<DEFINE CALL-GEN (NOD WHERE
		  "OPT" (NOTF <>) (B <>) (D <>)
		  "AUX" (K <KIDS .NOD>) (INS <NODE-NAME <1 .K>>) L RECSPEC
			(ON-STACK <>) COUNTMP SEGTMP I INS1 (REC? <>))
   #DECL ((NOD) NODE (K) <LIST NODE [REST NODE]>)
   <COND (.NOTF <SET D <NOT .D>>)>
   <COND
    (<MEMQ .INS ,STACK-INS>
     <SET ON-STACK T>
     <COND (<OR <==? .INS `CALL> <==? .INS `SCALL>>
	    <COND (<AND <==? <NODE-TYPE <SET INS1 <2 .K>>> ,QUOTE-CODE>
			<TYPE? <NODE-NAME .INS1> ATOM>>
		   <IEMIT <COND (<==? .INS `CALL> `FRAME) (ELSE `SFRAME)>
			  <FORM QUOTE
				<SET INS1
				     <CHTYPE <NODE-NAME .INS1> FCN-ATOM>>>>
		   <SET INS1 <FORM QUOTE .INS1>>)
		  (ELSE
		   <IEMIT <COND (<==? .INS `CALL> `FRAME) (ELSE `SFRAME)>>
		   <SET INS1 <GEN .INS1>>)>
	    <SET K <REST .K>>)
	   (<==? .INS `SYSCALL> <SET INS1 <GEN <2 .K>>> <SET K <REST .K>>)>)>
   <COND (<GETPROP .INS `RECORD-TYPE> <SET REC? T>)>
   <SET I
	<MAPF ,+
	      <FUNCTION (N) 
		      #DECL ((N) NODE)
		      <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE> 0) (ELSE 1)>>
	      <REST .K>>>
   <SET L
    <MAPR ,LIST
     <FUNCTION (NL "AUX" (N <1 .NL>) TMP) 
	#DECL ((N) NODE (NL) <LIST NODE>)
	<COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE>
	       <COND (<NOT <ASSIGNED? SEGTMP>>
		      <SET SEGTMP <GEN-TEMP <>>>
		      <SET COUNTMP <GEN-TEMP <>>>
		      <SET-TEMP .COUNTMP .I '(`TYPE FIX)>)>
	       <GEN <1 <KIDS .N>> .SEGTMP>
	       <SEGMENT-STACK
		.SEGTMP
		.COUNTMP
		<STRUCTYP <RESULT-TYPE <1 <KIDS .N>>>>
		<ISTYPE? <RESULT-TYPE <1 <KIDS .N>>>>>)
	      (ELSE
	       <SET TMP
		    <GEN .N <COND (.ON-STACK ,POP-STACK) (ELSE DONT-CARE)>>>
	       <COND (<NOT .ON-STACK>
		      <MAPF <>
			    <FUNCTION (NN) <SET TMP <INTERF-CHANGE .TMP .NN>>>
			    <REST .NL>>)>
	       .TMP)>>
     <REST .K>>>
   <COND (<NOT .ON-STACK> <MAPF <> <FUNCTION (X) <FREE-TEMP .X <>>> .L>)>
   <COND (<OR <==? .WHERE FLUSHED> <==? <RESULT-TYPE .NOD> NO-RETURN>>
	  <COND (.ON-STACK
		 <COND (<ASSIGNED? INS1>
			<IEMIT .INS
			       .INS1
			       <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>>
			<FREE-TEMP .INS1>)
		       (ELSE
			<IEMIT .INS
			       <COND (<ASSIGNED? COUNTMP> .COUNTMP)
				     (ELSE .I)>>)>)
		(.B <IEMIT .INS !.L <COND (.D +) (ELSE -)> .B>)
		(ELSE <IEMIT .INS !.L>)>
	  <SET WHERE ,NO-DATUM>)
	 (ELSE
	  <COND (<ASSIGNED? COUNTMP>
		 <FREE-TEMP .COUNTMP <>>
		 <FREE-TEMP .SEGTMP <>>)>
	  <COND (<==? .WHERE DONT-CARE>
		 <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
		(<TYPE? .WHERE TEMP> <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
	  <COND (.ON-STACK
		 <COND (<ASSIGNED? INS1>
			<IEMIT .INS
			       .INS1
			       <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>
			       =
			       .WHERE>
			<FREE-TEMP .INS1>)
		       (ELSE
			<IEMIT .INS
			       <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>
			       =
			       .WHERE>)>)
		(<AND .REC?
		      <TYPE? <SET RECSPEC <NTH .L <LENGTH .L>>> LIST>
		      <==? <LENGTH .RECSPEC> 2>
		      <=? <SPNAME <1 .RECSPEC>> "RECORD-TYPE">>
		 <COND (<==? <LENGTH .L> 1> <SET L ()>)
		       (ELSE <PUTREST <REST .L <- <LENGTH .L> 2>> ()>)>
		 <IEMIT .INS !.L = .WHERE .RECSPEC>)
		(.B <IEMIT .INS !.L = .WHERE <COND (.D +) (ELSE -)> .B>)
		(ELSE <IEMIT .INS !.L = .WHERE>)>)>
   .WHERE>

<DEFINE CHANNEL-OP-GEN (NOD WHERE
			"AUX" (CTY <NODE-SUBR .NOD>) (K <KIDS .NOD>) L I)
   #DECL ((NOD) NODE (K) <LIST NODE [REST NODE]> (L) LIST)
   <SET I <+ <LENGTH .K> 1>>
   <SET L
    <MAPR ,LIST
     <FUNCTION (NL "AUX" (N <1 .NL>) TMP) 
	     #DECL ((N) NODE (NL) <LIST NODE>)
	     <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE>
		    <COND (<TYPE? <SET TMP <NODE-NAME .N>> ATOM>
			   <FORM QUOTE .TMP>)
			  (ELSE .TMP)>)
		   (ELSE
		    <SET TMP <GEN .N DONT-CARE>>
		    <MAPF <>
			  <FUNCTION (NN) <SET TMP <INTERF-CHANGE .TMP .NN>>>
			  <REST .NL>>
		    .TMP)>>
     .K>>
   <MAPF <> <FUNCTION (X) <FREE-TEMP .X <>>> .L>
   <COND (<OR <==? .WHERE FLUSHED> <==? <RESULT-TYPE .NOD> NO-RETURN>>
	  <IEMIT `CHANNEL-OP <FORM QUOTE .CTY> <2 .L> <1 .L> !<REST .L 2>>)
	 (ELSE
	  <COND (<==? .WHERE DONT-CARE>
		 <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
		(<TYPE? .WHERE TEMP> <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
	  <IEMIT `CHANNEL-OP
		 <FORM QUOTE .CTY>
		 <2 .L>
		 <1 .L>
		 !<REST .L 2>
		 =
		 .WHERE>)>
   .WHERE>

<DEFINE SMSUBR-CALL (SUBRC NARGS WHERE "OPT" (STACK? <>) (SLNT <>)
		     "AUX"  (W <COND (<AND <==? .SUBRC STRING>
					   <NOT .SLNT>
					   .STACK?
					   <NOT <TYPE? .WHERE TEMP>>>
				      <GEN-TEMP STRING>)
				     (ELSE .WHERE)>)) 
	#DECL ((STK STK-CHARS7 STK-CHARS8) FIX)
	<COND (<OR <==? .SUBRC VECTOR>
		   <==? .SUBRC UVECTOR>
		   <==? .SUBRC STRING>
		   <==? .SUBRC BYTES>
		   <==? .SUBRC TUPLE>>
	       <IEMIT <COND (.STACK? `SBLOCK) (ELSE `UBLOCK)>
		      <FORM `TYPE-CODE .SUBRC>
		      .NARGS
		      =
		      .W
		      (`TYPE .SUBRC)>
	       <COND (.STACK?
		      <COND (<OR <TYPE? .NARGS TEMP>
				 <AND <NOT .SLNT>
				      <==? .SUBRC STRING>
				      <SET NARGS <GEN-TEMP FIX>>>>
			     <COND (<OR <==? .SUBRC VECTOR> <==? .SUBRC TUPLE>>
				    <IEMIT `DIV .NARGS 2 = .NARGS>)
				   (<==? .SUBRC BYTES>
				    <IEMIT `ADD .NARGS 3 =.NARGS>
				    <IEMIT `DIV .NARGS 4 = .NARGS>)
				   (<==? .SUBRC STRING>
				    <IEMIT `LENUS .W = .NARGS>
				    <IEMIT `IFSYS "TOPS20">
				    <IEMIT `ADD .NARGS 4 = .NARGS>
				    <IEMIT `DIV .NARGS 5 = .NARGS>
				    <IEMIT `ENDIF "TOPS20">
				    <IEMIT `IFSYS "UNIX">
				    <IEMIT `ADD .NARGS 3 = .NARGS>
				    <IEMIT `DIV .NARGS 4 = .NARGS>
				    <IEMIT `ENDIF "UNIX">)>
			     <FREE-TEMP .NARGS <>>
			     <COND (<ASSIGNED? STKTMP>
				    <IEMIT `SUB .STKTMP .NARGS = .STKTMP>)
				   (ELSE
				    <IEMIT `SUB 0 .NARGS =
					   <SET STKTMP <GEN-TEMP FIX>>>)>
			     <SET STK <+ .STK 2>>)
			    (<==? .SUBRC STRING>
			     <SET STK-CHARS7
				  <+ </ <+ .SLNT 4> 5> .STK-CHARS7>>
			     <SET STK-CHARS8
				  <+ </ <+ .SLNT 3> 4> .STK-CHARS8>>
			     <SET STK <+ .STK 2>>)
			    (ELSE
			     <SET STK
				  <+ .STK
				     <COND (<==? .SUBRC UVECTOR> .NARGS)
					   (<==? .SUBRC BYTES>
					    </ <+ .NARGS 3> 4>)
					   (ELSE <* .NARGS 2>)>
				     2>>)>)>
	       <COND (<N==? .W .WHERE> <MOVE-ARG .W .WHERE>)>)
	      (<==? .SUBRC LIST> <IEMIT `LIST .NARGS = .WHERE '(`TYPE LIST)>)
	      (ELSE <MSUBR-CALL .SUBRC .NARGS .WHERE>)>>

<DEFINE APPLY-GEN (NOD WHERE
		   "AUX" (K <KIDS .NOD>) COUNTMP SEGTMP (SEGLABEL <MAKE-TAG>)
			 (SEGCALLED <>) I MS)
   #DECL ((NOD) NODE (K) <LIST NODE [REST NODE]>
	  (COUNTMP SEGCALLED SEGLABEL) <SPECIAL ANY>)
   <START-FRAME>
   <SET MS <GEN <1 .K>>>
   <SET I
	<MAPF ,+
	      <FUNCTION (N) 
		      #DECL ((N) NODE)
		      <COND (<==? <NODE-TYPE .N> ,SEGMENT-CODE> 0) (ELSE 1)>>
	      <REST .K>>>
   <MAPF <>
    <FUNCTION (N "AUX" RES) 
       #DECL ((N) NODE (NL) <LIST NODE>)
       <COND
	(<==? <NODE-TYPE .N> ,SEGMENT-CODE>
	 <COND (<NOT <ASSIGNED? SEGTMP>>
		<SET SEGTMP <GEN-TEMP <>>>
		<SET COUNTMP <GEN-TEMP <>>>
		<SET-TEMP .COUNTMP .I '(`TYPE FIX)>)>
	 <SET RES <GEN <SET N <1 <KIDS .N>>> .SEGTMP>>
	 <COND (<AND <N==? .RES ,NO-DATUM>
		     <N==? <STRUCTYP-SEG <RESULT-TYPE .N>> MULTI>>
		<SEGMENT-STACK
		 .SEGTMP
		 .COUNTMP
		 <STRUCTYP <RESULT-TYPE .N>>
		 <ISTYPE? <RESULT-TYPE .N>>
		 .SEGLABEL>)
	       (.SEGCALLED <LABEL-TAG .SEGLABEL>)>
	 <SET SEGLABEL <MAKE-TAG>>)
	(ELSE <GEN .N ,POP-STACK>)>>
    <REST .K>>
   <COND (<ASSIGNED? COUNTMP> <FREE-TEMP .COUNTMP <>> <FREE-TEMP .SEGTMP <>>)>
   <COND (<OR <==? .WHERE FLUSHED> <==? <RESULT-TYPE .NOD> NO-RETURN>>
	  <IEMIT `ACALL .MS <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>>
	  <FREE-TEMP .MS>)
	 (ELSE
	  <COND (<==? .WHERE DONT-CARE>
		 <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
		(<TYPE? .WHERE TEMP> <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
	  <IEMIT `ACALL
		 .MS
		 <COND (<ASSIGNED? COUNTMP> .COUNTMP) (ELSE .I)>
		 =
		 .WHERE>
	  <FREE-TEMP .MS>)>
   .WHERE>

<DEFINE UNWIND-GEN (N W
		    "AUX" (UNBRANCH <MAKE-TAG>) (NOUNWIND <MAKE-TAG>)
			  (K1 <1 <KIDS .N>>) (K2 <2 <KIDS .N>>) W1 BND LBL)
	#DECL ((N K1 K2) NODE (BND) TEMP (STK) FIX)
	<SET SPECD T>
	<IEMIT `LOCATION + .UNBRANCH = <SET LBL <GEN-TEMP>>>
	<IEMIT `BBIND
	       <FORM QUOTE UNWIND>
	       .LBL
	       <FORM QUOTE FIX>
	       <CURRENT-FRAME>>
	<SET STK <+ .STK ,BINDING-LENGTH>>
	<SET W1 <GEN .K1 .W>>
	<SET-VALUE UNWIND 0>
	<FREE-TEMP .LBL>
	<BRANCH-TAG .NOUNWIND>
	<LABEL-TAG .UNBRANCH>
	<GEN .K2 FLUSHED>
	<BRANCH-TAG `UNWCONT>
	<LABEL-TAG .NOUNWIND>
	.W1>

<DEFINE INTERFERE? (TMP N "AUX" L) 
   #DECL ((N) NODE (TMP) TEMP (L) <OR FALSE LIST>)
   <AND
    <G=? <LENGTH .N> <INDEX ,SIDE-EFFECTS>>
    <SET L <SIDE-EFFECTS .N>>
    <MAPF <>
     <FUNCTION (NN "AUX" SYM) 
	     #DECL ((SYM) SYMTAB)
	     <COND (<AND <TYPE? .NN NODE>
			 <==? <NODE-TYPE .NN> ,SET-CODE>
			 <NOT <SPEC-SYM <SET SYM <NODE-NAME .NN>>>>
			 <N==? <CODE-SYM .SYM> -1>
			 <==? <TEMP-NAME-SYM .SYM> .TMP>>
		    <MAPLEAVE T>)>>
     <CHTYPE .L LIST>>>>

<DEFINE INTERF-CHANGE (TMP N) 
	#DECL ((N) NODE)
	<COND (<AND <TYPE? .TMP TEMP> <INTERFERE? .TMP .N>>
	       <MOVE-ARG .TMP <GEN-TEMP <>>>)
	      (ELSE .TMP)>>

<DEFINE ADECL-GEN (NOD WHERE "AUX" (N <1 <KIDS .NOD>>)) <GEN .N .WHERE>>

<DEFINE STACK-GEN (N W) <GEN <1 <KIDS .N>> .W>>

"ILIST, IVECTOR, IUVECTOR AND ISTRING."

<DEFINE ISTRUC-GEN (N W
		    "AUX" (NAM <NODE-NAME .N>) (K <KIDS .N>)
			  (NT <NODE-TYPE .N>) (LEN <1 .K>) EL
			  (TY <RESULT-TYPE .N>) NT-M NT-E EL-TMP EV-TMP STRT
			  NSTR STR END STR2 OBJ (CALL-EV <>) (GEN-EACH-TIME <>)
			  X EMP-INS PUT-INS REST-INS (ISTY <ISTYPE? .TY>)
			  CONS-T1 CONS-T2 CONS-TMP NT-S
			  (STACK?
			   <COND
			    (<AND
			      <TYPE? <SET X <PARENT .N>> NODE>
			      <OR <==? <NODE-TYPE .X> ,STACK-CODE>
				  <AND <==? <NODE-TYPE .X> ,CHTYPE-CODE>
				       <TYPE? <SET X <PARENT .X>> NODE>
				       <==? <NODE-TYPE .X> ,STACK-CODE>>>>)>))
   #DECL ((N LEN EL) NODE (K) <LIST NODE [OPT NODE]>
	  (STK STK-CHARS7 STK-CHARS8) FIX (STR) <OR FIX TEMP>)
   <COND (<==? .NAM ITUPLE> <SET STACK? T>)>
   <COND (<AND <==? <LENGTH .K> 1> <N==? .NAM ILIST>>
	  <IEMIT <COND (.STACK? `USBLOCK) (ELSE `UUBLOCK)>
		 <FORM `TYPE-CODE .ISTY>
		 <SET STR <GEN .LEN DONT-CARE>>
		 =
		 <COND (<TYPE? .W TEMP> <USE-TEMP .W .ISTY> .W)
		       (<==? .W DONT-CARE>
			<SET W <GEN-TEMP <COND (.ISTY) (ANY)>>>)
		       (ELSE .W)>
		 (`TYPE .ISTY)>
	  <COND (<NOT .STACK?> <FREE-TEMP .STR>)>)
	 (ELSE
	  <COND (<OR <==? .NAM IVECTOR> <==? .NAM ITUPLE>>
		 <SET REST-INS `RESTUV>
		 <SET PUT-INS `PUTUV>
		 <SET EMP-INS `EMPUV?>)
		(<==? .NAM IUVECTOR>
		 <SET REST-INS `RESTUU>
		 <SET PUT-INS `PUTUU>
		 <SET EMP-INS `EMPUU?>)
		(<==? .NAM ISTRING>
		 <SET REST-INS `RESTUS>
		 <SET PUT-INS `PUTUS>
		 <SET EMP-INS `EMPUS?>)
		(<==? .NAM IBYTES>
		 <SET REST-INS `RESTUB>
		 <SET PUT-INS `PUTUB>
		 <SET EMP-INS `EMPUB?>)
		(ELSE
		 <SET REST-INS `RESTL>
		 <SET PUT-INS `PUTL>
		 <SET EMP-INS `EMPL?>)>
	  <COND (<EMPTY? <REST .K>> <SET EL-TMP 0>)
		(<OR <AND <==? <SET NT-M <NODE-TYPE .N>> ,ISTRUC2-CODE>
			  <OR <L? <LENGTH <SET EL <2 .K>>>
				  <INDEX ,SIDE-EFFECTS>>
			      <AND <NOT <SIDE-EFFECTS .EL>>
				   <N==? <SET NT-S <NODE-TYPE .EL>> ,COPY-CODE>
				   <N==? .NT-S ,CHTYPE-CODE>
				   ; "TAA 11/5/85--otherwise
				      <IVECTOR .FOO '<CHTYPE [1 2 3] BAR>>
				      doesn't generate a new frob each time"
				   <N==? .NT-S ,ISTRUC-CODE>
				   <N==? .NT-S ,ISTRUC2-CODE>>>>
		     <AND <==? .NT-M ,ISTRUC-CODE>
			  <NOT <TYPE-OK?
				<RESULT-TYPE <SET EL <2 .K>>>
				'<OR FORM LIST VECTOR UVECTOR LVAL GVAL>>>>>
		 <SET EL-TMP <GEN .EL>>)
		(<==? .NT-M ,ISTRUC-CODE>
		 <SET EV-TMP <GEN .EL>>
		 <SET CALL-EV T>)
		(ELSE <SET GEN-EACH-TIME T>)>
	  <SET STR <GEN .LEN>>
	  <COND (<==? .NAM ILIST>
		 <IEMIT `SET
			<COND (<TYPE? .W TEMP> <USE-TEMP <SET OBJ .W> .ISTY>)
			      (ELSE <SET OBJ <GEN-TEMP>>)> ()>
		 <COND (<OR <TYPE? .STR FIX>
			    <G? <TEMP-REFS .STR> 1>>
			<IEMIT `SET <SET STR2 <GEN-TEMP FIX>> .STR>
			<SET STR .STR2>)>
		 <IEMIT `SET <SET STR2 <GEN-TEMP LIST>> ()>)
		(ELSE
		 <IEMIT <COND (.STACK? `USBLOCK) (ELSE `UUBLOCK)>
			<FORM `TYPE-CODE .ISTY>
			.STR
			=
			<COND (<TYPE? .W TEMP> <USE-TEMP <SET OBJ .W> .ISTY>)
			      (ELSE <SET OBJ <GEN-TEMP>>)>>
		 <COND (<NOT .STACK?> <FREE-TEMP .STR>)>
		 <IEMIT `SET <SET STR2 <GEN-TEMP>> .OBJ>)>
	  <IEMIT `LOOP
		 (<TEMP-NAME .STR2> VALUE LENGTH)
		 !<COND (.CALL-EV ((<TEMP-NAME .EV-TMP> TYPE VALUE LENGTH)))
			(<AND <NOT .GEN-EACH-TIME> <TYPE? .EL-TMP TEMP>>
			 ((<TEMP-NAME .EL-TMP> TYPE VALUE LENGTH)))
			(ELSE ())>
		 !<COND (<==? .NAM ILIST> ((<TEMP-NAME .STR> VALUE)))
			(ELSE ())>>
	  <LABEL-TAG <SET STRT <MAKE-TAG "ISTR">>>
	  <COND (<==? .NAM ILIST>
		 <IEMIT `VEQUAL? .STR 0 + <SET END <MAKE-TAG "ISTRE">>>)
		(ELSE
		 <IEMIT .EMP-INS .STR2 + <SET END <MAKE-TAG "ISTRE">>>)>
	  <COND (.CALL-EV
		 <START-FRAME EVAL>
		 <PUSH .EV-TMP>
		 <MSUBR-CALL EVAL 1 <SET EL-TMP <GEN-TEMP>>>)
		(.GEN-EACH-TIME <SET EL-TMP <GEN .EL>>)>
	  <COND (<==? .NAM ILIST>
		 <IEMIT `CONS .EL-TMP () = <SET CONS-TMP <GEN-TEMP LIST>>>
		 <IEMIT `EMPL? .STR2 + <SET CONS-T1 <MAKE-TAG>>>
		 <IEMIT `PUTREST .STR2 .CONS-TMP>
		 <IEMIT `SET .STR2 .CONS-TMP>
		 <BRANCH-TAG <SET CONS-T2 <MAKE-TAG>>>
		 <LABEL-TAG .CONS-T1>
		 <IEMIT `SET .STR2 .CONS-TMP>
		 <IEMIT `SET .OBJ .CONS-TMP>
		 <LABEL-TAG .CONS-T2>
		 <IEMIT `SUB .STR 1 = .STR>)
		(ELSE
		 <IEMIT .PUT-INS .STR2 1 .EL-TMP>
		 <IEMIT .REST-INS .STR2 1 = .STR2>)>
	  <COND (<OR .CALL-EV .GEN-EACH-TIME> <FREE-TEMP .EL-TMP>)>
	  <BRANCH-TAG .STRT>
	  <LABEL-TAG .END>
	  <FREE-TEMP .STR2>
	  <COND (.CALL-EV <FREE-TEMP .EV-TMP>)
		(<NOT .GEN-EACH-TIME> <FREE-TEMP .EL-TMP>)>
	  <SET W <MOVE-ARG .OBJ .W>>)>
   <COND (.STACK?
	  <COND (<TYPE? .STR TEMP>
		 <COND (<AND <N==? .NAM IUVECTOR> <G? <TEMP-REFS .STR> 1>>
			<SET NSTR <GEN-TEMP FIX>>)
		       (ELSE <SET NSTR .STR>)>
		 <COND (<OR <==? .NAM IVECTOR> <==? .NAM ITUPLE>>
			<IEMIT `LSH .STR 1 = .NSTR>)
		       (<==? .NAM IBYTES>
			<IEMIT `ADD .STR 3 = .NSTR>
			<IEMIT `LSH .NSTR -2 = .NSTR>)
		       (<==? .NAM ISTRING>
			<IEMIT `IFSYS "TOPS20">
			<IEMIT `ADD .STR 4 = .NSTR>
			<IEMIT `DIV .NSTR 5 = .NSTR>
			<IEMIT `ENDIF "TOPS20">
			<IEMIT `IFSYS "UNIX">
			<IEMIT `ADD .STR 3 = .NSTR>
			<IEMIT `LSH .NSTR -2 = .NSTR>
			<IEMIT `ENDIF "UNIX">)>
		 <FREE-TEMP .STR <>>
		 <COND (<ASSIGNED? STKTMP>
			<IEMIT `SUB .STKTMP .NSTR = .STKTMP>)
		       (ELSE
			<IEMIT `SUB 0 .NSTR = <SET STKTMP <GEN-TEMP FIX>>>)>
		 <COND (<N==? .STR .NSTR> <FREE-TEMP .NSTR>)>
		 <SET STK <+ .STK 2>>)
		(<==? .NAM ISTRING>
		 <SET STK-CHARS7 <+ </ <+ .STR 4> 5> .STK-CHARS7>>
		 <SET STK-CHARS8 <+ </ <+ .STR 3> 4> .STK-CHARS8>>
		 <SET STK <+ .STK 2>>)
		(ELSE
		 <SET STK
		      <+ .STK
			 <COND (<==? .NAM IUVECTOR> .STR)
			       (<==? .NAM IBYTES> </ <+ .STR 3> 4>)
			       (ELSE <* .STR 2>)>
			 2>>)>)>
   .W>


<DEFINE MULTI-SET-GEN (N:NODE W
		       "AUX" (K:<LIST [REST NODE]> <KIDS .N>) (SEG? <>)
			     (SIDE-E <>) (MX:FIX 0) (MN:FIX 0)
			     (VARS:<LIST [REST LIST]> <NODE-NAME .N>) TL:LIST
			     (VLN:FIX <LENGTH .VARS>) NT:FIX SEGTYP LCL
			     (LV:<OR ATOM SYMTAB> <1 <NTH .VARS .VLN>>) (I:FIX 0))
   <MAPF <>
    <FUNCTION (N:NODE "AUX" RT) 
	    <COND (<OR <==? <SET NT <NODE-TYPE .N>> ,SEG-CODE>
		       <==? .NT ,SEGMENT-CODE>>
		   <SET SEG? T>
		   <SET MX <MAX <+ <MAXL <SET RT <RESULT-TYPE <1 <KIDS .N>>>>> .MX>
				,MAX-LENGTH>>
		   <SET MN <+ <MINL .RT> .MN>>)
		  (ELSE
		   <SET I <+ .I 1>>
		   <SET MN <+ .MN 1>>
		   <SET MX <MAX <+ .MX 1> ,MAX-LENGTH>>)>
	    <COND (<AND <G=? <LENGTH .N> <INDEX ,SIDE-EFFECTS>>
			<SIDE-EFFECTS .N>>
		   <SET SIDE-E T>)>>
    <SET K <REST .K>>>
   <COND
    (.SEG?
     <PROG ((SEGLABEL <MAKE-TAG>) COUNTMP (SEGCALLED <>) SEGTMP)
       #DECL ((SEGLABEL COUNTMP SEGCALLED) <SPECIAL ANY>)
       <MAPF <>
	<FUNCTION (NN:NODE "AUX" (NT <NODE-TYPE .NN>) RES) 
	   <COND
	    (<OR <==? .NT ,SEG-CODE> <==? .NT ,SEGMENT-CODE>>
	     <COND (<NOT <ASSIGNED? SEGTMP>>
		    <SET SEGTMP <GEN-TEMP <>>>
		    <SET COUNTMP <GEN-TEMP FIX>>
		    <SET-TEMP .COUNTMP .I '(`TYPE FIX)>)>
	     <SET RES <GEN <SET NN <1 <KIDS .NN>>> .SEGTMP>>
	     <SET SEGTYP <STRUCTYP-SEG <RESULT-TYPE .NN>>>
	     <COND (<AND <N==? .RES ,NO-DATUM> <N==? .SEGTYP MULTI>>
		    <SEGMENT-STACK .SEGTMP
				   .COUNTMP
				   .SEGTYP
				   <ISTYPE? <RESULT-TYPE .NN>>
				   .SEGLABEL>
		    <SET SEGLABEL <MAKE-TAG>>)
		   (.SEGCALLED
		    <LABEL-TAG .SEGLABEL>
		    <SET SEGLABEL <MAKE-TAG>>)>)
	    (ELSE
	     <GEN .NN ,POP-STACK>)>>
	.K>
       <COND (<AND .CAREFUL <N==? .MX .MN>>
	      <IEMIT `VEQUAL? .COUNTMP .VLN - `COMPERR>)>
       <REPEAT (TVAR TSYM TMP)
	       <COND (<AND
		       <TYPE? <SET TSYM <1 <SET TVAR <NTH .VARS .VLN>>>>
			      SYMTAB>
		       <NOT <SPEC-SYM .TSYM>>
		       <N==? <CODE-SYM .TSYM> -1>>
		      <USE-TEMP <SET TMP <TEMP-NAME-SYM .TSYM>>
				<OR <2 .TVAR> T>>
		      <IEMIT `POP = .TMP>)
		     (ELSE
		      <IEMIT `POP = <SET TMP <GEN-TEMP <OR <2 .TVAR> T>>>>
		      <SET-VALUE <COND (<TYPE? .TSYM SYMTAB> <NAME-SYM .TSYM>)
				       (ELSE .TSYM)>
				 .TMP
				 <NOT <AND <TYPE? .TSYM SYMTAB>
					   <N==? <CODE-SYM .TSYM> -1>>>>
		      <FREE-TEMP .TMP>)>
	       <COND (<==? <SET VLN <- .VLN 1>> 0> <RETURN>)>>>)
    (.SIDE-E
     <SET TL
	  <MAPF ,LIST
		<FUNCTION (NN:NODE SYP:<LIST <OR ATOM SYMTAB>>
			   "AUX" (TY <RESULT-TYPE .NN>) PT
				 (SY:<OR ATOM SYMTAB> <1 .SYP>))
			<COND (<TYPE? .SY SYMTAB>
			       <SET TY <TYPE-AND <2 .SYP> .TY>>)>
			<COND (<AND <SET TY <ISTYPE? .TY>>
				    <OR <==? <SET PT <TYPEPRIM .TY>> FIX>
					<==? .PT LIST>>>)
			      (ELSE <SET TY ANY>)>
			<GEN .NN <GEN-TEMP .TY>>>
		.K
		.VARS>>
     <MAPF <>
	   <FUNCTION (SYP:<LIST <OR ATOM SYMTAB>> TMP:TEMP
		      "AUX" (SY:<OR ATOM SYMTAB> <1 .SYP>) (LCL <>)) 
		   <COND (<AND <TYPE? .SY SYMTAB>
			       <N==? <CODE-SYM .SY> -1>
			       <SET LCL T>
			       <NOT <SPEC-SYM .SY>>>
			  <IEMIT `SET <TEM-NAME-SYM .SY> .TMP>
			  <FREE-TEMP .TMP>)
			 (ELSE
			  <COND (<TYPE? .SY SYMTAB> <SET SY <NAME-SYM .SY>>)>
			  <SET-VALUE .SY .TMP <NOT .LCL>>
			  <FREE-TEMP .TMP>)>>
	   .VARS
	   .TL>)
    (ELSE
     <PROG (NL-LATER:LIST SL-LATER:LIST ANY-DONE (MUCH-LATER:LIST ())
	    TTMP:TEMP)
       <SET NL-LATER <SET SL-LATER ()>>
       <SET ANY-DONE <>>
       <MAPR <>
	<FUNCTION (SL NL
		   "AUX" (SYP:<LIST <OR ATOM SYMTAB TEMP>> <1 .SL>) (LCL <>) TY
			 (N:NODE <1 .NL>) (SY:<OR ATOM SYMTAB TEMP> <1 .SYP>) TMP)
		<COND (<OR <TYPE? .SY TEMP>
			   <AND <NOT <REF? .SY <REST .NL>>>
				<NOT <REF? .SY .NL-LATER>>>>
		       <SET ANY-DONE T>
		       <COND (<OR <AND <TYPE? .SY SYMTAB>
				       <N==? <CODE-SYM .SY> -1>
				       <SET LCL T>
				       <NOT <SPEC-SYM .SY>>
				       <SET TMP <TEMP-NAME-SYM .SY>>>
				  <AND <TYPE? .SY TEMP> <SET TMP .SY>>>
			      <GEN .N .TMP>)
			     (ELSE
			      <COND (<TYPE? .SY SYMTAB>
				     <SET SY <NAME-SYM .SY>>)>
			      <SET-VALUE .SY <GEN .N DONT-CARE> <NOT .LCL>>)>)
		      (ELSE
		       <SET SL-LATER (.SYP !.SL-LATER)>
		       <SET NL-LATER (.N !.NL-LATER)>)>>
	.VARS
	.K>
       <COND (<AND .ANY-DONE <NOT <EMPTY? .SL-LATER>>>
	      <SET VARS .SL-LATER>
	      <SET K .NL-LATER>
	      <AGAIN>)
	     (<NOT <EMPTY? .SL-LATER>>
	      <SET MUCH-LATER
		   ((<1 .SL-LATER> <SET TTMP <GEN-TEMP <>>>) !.MUCH-LATER)>
	      <SET VARS ((.TTMP) !<REST .SL-LATER>)>
	      <SET K .NL-LATER>
	      <AGAIN>)>
       <MAPF <>
	     <FUNCTION (L:LIST
			"AUX" (SY:<OR ATOM SYMTAB> <1 <1 .L>>) (LCL <>)
			      (TMP:TEMP <2 .L>))
		     <COND (<AND <TYPE? .SY SYMTAB>
				 <N==? <CODE-SYM .SY> -1>
				 <SET LCL T>
				 <NOT <SPEC-SYM .SY>>>
			    <IEMIT `SET <TEMP-NAME-SYM .SY> .TMP>
			    <FREE-TEMP .TMP>)
			   (ELSE
			    <COND (<TYPE? .SY SYMTAB> <SET SY <NAME-SYM .SY>>)>
			    <SET-VALUE .SY .TMP <NOT .LCL>>
			    <FREE-TEMP .TMP>)>>
	     .MUCH-LATER>>)>
   <COND (<N==? .W FLUSHED>
	  <SET LCL <>>
	  <COND (<AND <TYPE? .LV SYMTAB>
		      <N==? <CODE-SYM .LV> -1>
		      <SET LCL T>
		      <NOT <SPEC-SYM .LV>>>
		 <TEMP-REFS .LV <+ <TEMP-REFS .LV> 1>>
		 <MOVE-ARG .LV .W>)
		(ELSE
		 <COND (<TYPE? .LV SYMTAB> <SET LV <NAME-SYM .LV>>)>
		 <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>
		 <GET-VALUE-X .LV .W <NOT .LCL>>)>)
	 (ELSE .W)>>

<DEFINE REF? (SY:<OR ATOM SYMTAB> L:<LIST [REST NODE]>)
	<MAPF <>
	      <FUNCTION (N:NODE "AUX" (NT:FIX <NODE-TYPE .N>) NN)
		    <PROG ()
			  <COND (<OR <==? .NT ,LVAL-CODE>
				     <==? .NT ,ASSIGNED?-CODE>
				     <==? .NT ,SET-CODE>>
				 <COND (<==? <NODE-NAME .N> .SY> <MAPLEAVE>)>)
				(<OR <==? .NT ,FLVAL-CODE> <==? .NT ,FSET-CODE>>
				 <COND (<OR <==? <NODE-NAME .N> .SY>
					    <COND (<==? <NODE-TYPE
							 <SET NN <1 <KIDS .N>>>>
							,QUOTE-CODE>
						   <==? <NODE-NAME .NN> .SY>)
						  (ELSE
						   <OR <TYPE? .SY ATOM>
						       <==? <CODE-SYM .SY> -1>
						       <SPEC-SYM .SY>>)>>
					<MAPLEAVE T>)>)
				(<AND <G? <LENGTH .N> <INDEX ,SIDE-EFFECTS>>
				      <MEMQ ALL <CHTYPE <SIDE-EFFECTS .N>
							LIST>>
				      <OR <TYPE? .SY ATOM>
					  <SPEC-SYM .SY>
					  <==? <CODE-SYM .SY> -1>>>
				 <MAPLEAVE T>)
				(ELSE
				 <COND (<REF? .SY <KIDS .N>> <MAPLEAVE T>)>
				 <COND (<==? .NT ,BRANCH-CODE>
					<SET NT <NODE-TYPE <SET N <PREDIC .N>>>>
					<AGAIN>)>)>>>
	      .L>>
				 
<DEFINE GEN-DISPATCH (N W) 
	<CASE ,==?
	      <NODE-TYPE .N>
	      (,FORM-CODE <FORM-GEN .N .W>)
	      (,PROG-CODE <PROG-REP-GEN .N .W>)
	      (,SUBR-CODE <SUBR-GEN .N .W>)
	      (,COND-CODE <COND-GEN .N .W>)
	      (,LVAL-CODE <LVAL-GEN .N .W>)
	      (,SET-CODE <SET-GEN .N .W>)
	      (,OR-CODE <OR-GEN .N .W>)
	      (,AND-CODE <AND-GEN .N .W>)
	      (,RETURN-CODE <RETURN-GEN .N .W>)
	      (,COPY-CODE <COPY-GEN .N .W>)
	      (,AGAIN-CODE <AGAIN-GEN .N .W>)
	      (,ARITH-CODE <ARITH-GEN .N .W>)
	      (,RSUBR-CODE <SUBR-GEN .N .W>)
	      (,0-TST-CODE <0-TEST .N .W>)
	      (,NOT-CODE <NOT-GEN .N .W>)
	      (,1?-CODE <1?-GEN .N .W>)
	      (,TEST-CODE <TEST-GEN .N .W>)
	      (,EQ-CODE <==-GEN .N .W>)
	      (,TY?-CODE <TYPE?-GEN .N .W>)
	      (,LNTH-CODE <LNTH-GEN .N .W>)
	      (,MT-CODE <MT-GEN .N .W>)
	      (,REST-CODE <REST-GEN .N .W>)
	      (,NTH-CODE <NTH-GEN .N .W>)
	      (,PUT-CODE <PUT-GEN .N .W>)
	      (,PUTR-CODE <PUTREST-GEN .N .W>)
	      (,FLVAL-CODE <FLVAL-GEN .N .W>)
	      (,FSET-CODE <FSET-GEN .N .W>)
	      (,FGVAL-CODE <FGVAL-GEN .N .W>)
	      (,FSETG-CODE <FSETG-GEN .N .W>)
	      (,MIN-MAX-CODE <MIN-MAX .N .W>)
	      (,CHTYPE-CODE <CHTYPE-GEN .N .W>)
	      (,FIX-CODE <FIX-GEN .N .W>)
	      (,FLOAT-CODE <FLOAT-GEN .N .W>)
	      (,ABS-CODE <ABS-GEN .N .W>)
	      (,MOD-CODE <MOD-GEN .N .W>)
	      (,ID-CODE <ID-GEN .N .W>)
	      (,ASSIGNED?-CODE <ASSIGNED?-GEN .N .W>)
	      (,BITL-CODE <BITLOG-GEN .N .W>)
	      (,ISUBR-CODE <SUBR-GEN .N .W>)
	      (,EOF-CODE <ID-GEN .N .W>)
	      (,READ-EOF2-CODE <READ2-GEN .N .W>)
	      (,READ-EOF-CODE <SUBR-GEN .N .W>)
	      (,GET2-CODE <GET2-GEN .N .W>)
	      (,GET-CODE <GET-GEN .N .W>)
	      (,IPUT-CODE <SUBR-GEN .N .W>)
	      (,MAP-CODE <MAPFR-GEN .N .W>)
	      (,MARGS-CODE <MPARGS-GEN .N .W>)
	      (,MAPLEAVE-CODE <MAPLEAVE-GEN .N .W>)
	      (,MAPRET-STOP-CODE <MAPRET-STOP-GEN .N .W>)
	      (,UNWIND-CODE <UNWIND-GEN .N .W>)
	      (,GVAL-CODE <GVAL-GEN .N .W>)
	      (,SETG-CODE <SETG-GEN .N .W>)
	      (,MEMQ-CODE <MEMQ-GEN .N .W>)
	      (,LENGTH?-CODE <LENGTH?-GEN .N .W>)
	      (,FORM-F-CODE <FORM-F-GEN .N .W>)
	      (,ALL-REST-CODE <ALL-REST-GEN .N .W>)
	      (,COPY-LIST-CODE <LIST-BUILD .N .W>)
	      (,PUT-SAME-CODE <PUT-GEN .N .W>)
	      (,BACK-CODE <BACK-GEN .N .W>)
	      (,TOP-CODE <TOP-GEN .N .W>)
	      (,ROT-CODE <ROT-GEN .N .W>)
	      (,LSH-CODE <LSH-GEN .N .W>)
	      (,BIT-TEST-CODE <BIT-TEST-GEN .N .W>)
	      (,CALL-CODE <CALL-GEN .N .W>)
	      (,MONAD-CODE <MONAD?-GEN .N .W>)
	      (,GASSIGNED?-CODE <GASSIGNED?-GEN .N .W>)
	      (,APPLY-CODE <APPLY-GEN .N .W>)
	      (,ADECL-CODE <ADECL-GEN .N .W>)
	      (,MULTI-RETURN-CODE <MULTI-RETURN-GEN .N .W>)
	      (,VALID-CODE <VALID-TYPE?-GEN .N .W>)
	      (,TYPE-C-CODE <TYPE-C-GEN .N .W>)
	      (,=?-STRING-CODE <=?-STRING-GEN .N .W>)
	      (,CASE-CODE <CASE-GEN .N .W>)
	      (,FGETBITS-CODE <FGETBITS-GEN .N .W>)
	      (,FPUTBITS-CODE <FPUTBITS-GEN .N .W>)
	      (,ISTRUC-CODE <ISTRUC-GEN .N .W>)
	      (,ISTRUC2-CODE <ISTRUC-GEN .N .W>)
	      (,STACK-CODE <STACK-GEN .N .W>)
	      (,CHANNEL-OP-CODE <CHANNEL-OP-GEN .N .W>)
	      (,ATOM-PART-CODE <ATOM-PART-GEN .N .W>)
	      (,OFFSET-PART-CODE <OFFSET-PART-GEN .N .W>)
	      (,PUT-GET-DECL-CODE <PUT-GET-DECL-GEN .N .W>)
	      (,SUBSTRUC-CODE <SUBSTRUC-GEN .N .W>)
	      (,MULTI-SET-CODE <MULTI-SET-GEN .N .W>)
	      DEFAULT
	      (<DEFAULT-GEN .N .W>)>>

<ENDPACKAGE>
