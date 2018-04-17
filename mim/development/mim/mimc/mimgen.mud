
<PACKAGE "MIMGEN">

<ENTRY MAKE-TAG
       FIND-FRAME
       SPEC-GEN-TEMP
       PREV-FRAME
       GEN-VAL-==?
       GEN-==?
       GET-BINDING
       BRANCH-TAG
       RET-TMP-AC
       MIM-FCN
       MIM-RETURN
       REFERENCE
       GEN-TYPE?
       GEN-VT
       GEN-TC
       GEN-CHTYPE
       GEN-GVAL
       GEN-SETG
       MIM-TEMPS-HOLD
       MIM-TEMPS-EMIT
       EMIT
       IEMIT
       INSTRUCTION
       LABEL-TAG
       PUSH
       POP
       PUSH-CONSTANT
       GEN-FIX-BIND
       SPECIAL-BINDING
       FINISH-BINDING
       SET-TEMP
       SET-SYM
       CURRENT-FRAME
       GET-ARG-TUPLE
       ARG-TO-TEMP
       TEST-ARG
       MSUBR-CALL
       SEG-SUBR-CALL
       START-FRAME
       GEN-LIST
       GEN-VECTOR
       GEN-UVECTOR
       GEN-TUPLE
       MOVE-ARG
       GEN-CHTYPE
       D-B-TAG
       GEN-TEMP
       NTH-LIST
       NTH-UVECTOR
       NTH-VECTOR
       NTH-STRING
       NTH-RECORD
       NTH-BYTES
       REST-LIST
       REST-UVECTOR
       REST-VECTOR
       REST-STRING
       REST-BYTES
       REST-RECORD
       EMPTY-LIST
       EMPTY-UVECTOR
       EMPTY-VECTOR
       EMPTY-STRING
       EMPTY-BYTES
       EMPTY-RECORD
       PUT-LIST
       PUT-UVECTOR
       PUT-VECTOR
       PUT-STRING
       PUT-BYTES
       PUT-RECORD
       LENGTH-LIST
       LENGTH-UVECTOR
       LENGTH-VECTOR
       LENGTH-STRING
       LENGTH-BYTES
       LENGTH-RECORD
       PROTECT
       USE-TEMP
       FREE-TEMP
       DEALLOCATE-TEMP
       GEN-SHIFT
       GEN-ARG-NUM
       SET-VALUE
       GET-VALUE-X
       ATOMCHK
       ISPEC-BIND
       GEN-GASS
       ASS-GEN
       M$$VALU
       TYPIFY-TEMPS
       SPEC-IEMIT>

<USE "CHKDCL" "COMPDEC" "ADVMESS">

<SETG RAT (`RECORD-TYPE ATOM)>

<SETG RBN (`RECORD-TYPE LBIND)>

<SETG RGBN (`RECORD-TYPE GBIND)>

<SETG QQ-BIND <FORM QUOTE BIND>>

<BLOCK (<ROOT>)>

M$$BINDID 

<ENDBLOCK>

<SETG QQ-M$$BINDID <FORM QUOTE M$$BINDID>>

<SETG NO-DATUM '(1)>

<GDECL (MIMOPS) VECTOR>

<SETG M$$FRM-MSUB 1>

<SETG M$$FRM-PC 2>

<SETG M$$FRM-ARGN 3>

<SETG M$$FRM-ID 4>

<SETG M$$FRM-PREV 5>

<SETG M$$FRM-TP 6>

<SETG M$$FRM-ARGS 6>

<SETG M$$FRM-BIND 7>

<SETG M$$FRM-ACTN 8>

<MANIFEST M$$FRM-MSUB
	  M$$FRM-ARGN
	  M$$FRM-ID
	  M$$FRM-PREV
	  M$$FRM-BIND
	  M$$FRM-ARGS
	  M$$FRM-ACTN
	  M$$FRM-PC
	  M$$FRM-TP>

<SETG M$$GVAL 1>

<SETG M$$LVAL 2>

<SETG M$$PNAM 3>

<SETG M$$OBLS 4>

<SETG M$$TYPE 5>

<SETG M$$ATML 5>

<MANIFEST M$$LVAL M$$GVAL M$$PNAM M$$OBLS M$$TYPE M$$ATML>

<SETG M$$VALU 1>

<SETG M$$ATOM 2>

<SETG M$$DECL 3>

<SETG M$$PBND 4>

<SETG M$$PATM 5>

<SETG M$$UBID 6>

<SETG M$$BNDL 6>

<MANIFEST M$$VALU M$$ATOM M$$DECL M$$PBND M$$PATM M$$UBID M$$BNDL>

<SETG MIMOPS
      [("PUSH" ANY)
       ("POP" ANY)
       ("SET" ANY)
       ("SETS" ANY)
       ("GETS" ANY)
       ("ADJ" ANY)
       ("FRAME" ANY)
       ("VFRAME" ANY)
       ("CFRAME" ANY)
       ("ARGS" TUPLE)
       ("TUPLE" TUPLE)
       ("RFRAME" NO-RETURN)
       ("CALL" ANY)
       ("ACTIVATION" ANY)
       ("AGAIN" NO-RETURN)
       ("RET" NO-RETURN)
       ("RTUPLE" NO-RETURN)
       ("JUMP" NO-RETURN)
       ("HALT" ANY)
       ("OBJECT" ANY)
       ("TYPE" FIX)
       ("TYPE?" ANY)
       ("CHTYPE" ANY)
       ("NEWTYPE" FIX)
       ("VALUE" FIX)
       ("LIST" LIST)
       ("UBLOCK" ANY)
       ("RECORD" ANY)
       ("NTHL" ANY)
       ("NTHR" ANY T)
       ("NTHU" ANY)
       ("LENL" FIX)
       ("LENR" FIX T)
       ("LENU" FIX)
       ("EMPL?" ANY)
       ("EMPR?" ANY T)
       ("EMPU?" ANY)
       ("PUTL" LIST)
       ("PUTU" ANY)
       ("PUTR" ANY T)
       ("RESTL" LIST)
       ("RESTU" ANY)
       ("BACKU" ANY)
       ("TOPU" ANY)
       ("CONS" LIST)
       ("PUTREST" LIST)
       ("BIND" ANY)
       ("SETG" ANY)
       ("GVAL" ANY)
       ("OPEN" ANY)
       ("CLOSE" ANY)
       ("READ" ANY)
       ("PRINT" ANY)
       ("SAVE" ANY)
       ("RESTORE" ANY)
       ("ADD" FIX)
       ("ADDF" FLOAT)
       ("SUB" FIX)
       ("SUBF" FLOAT)
       ("MUL" FIX)
       ("MULF" FLOAT)
       ("DIV" FIX)
       ("DIVF" FLOAT)
       ("RANDOM" FIX)
       ("FIX" FIX)
       ("FLOAT" FLOAT)
       ("GRTR?" ANY)
       ("LESS?" ANY)
       ("AND" FIX)
       ("OR" FIX)
       ("XOR" FIX)
       ("EQV" FIX)
       ("LSH" FIX)
       ("ROT" FIX)
       ("EQUAL?" ANY)
       ("VEQUAL?" ANY)
       ("RESET" ANY)
       ("ATIC" FIX)
       ("MARKL?" ANY)
       ("MARKU?" ANY)
       ("MARKR?" ANY)
       ("MARKL" ANY)
       ("MARKU" ANY)
       ("MARKR" ANY)
       ("MARKUV?" ANY)
       ("MARKUV" ANY)
       ("MARKUU" ANY)
       ("MARKUU?" ANY)
       ("MARKUS" ANY)
       ("MARKUS?" ANY)
       ("MARKUB" ANY)
       ("MARKUB?" ANY)
       ("SWEEP" ANY)
       ("RETRY" NO-RETURN)
       ("LOOP" ANY)
       ("IRECORD" ANY)
       ("TEMPLATE-TABLE" ANY)
       ("CONTENTS" ANY)
       ("NEXTS" FIX)
       ("SWNEXT" ANY)
       ("RELL" ANY)
       ("RELU" ANY)
       ("RELR" ANY)
       ("INTGO" ANY)
       ("PFRAME" ANY)
       ("NTH1" ANY)
       ("REST1" ANY)
       ("EMPTY?" ANY)
       ("MONAD?" ANY)
       ("QUIT" ANY)
       ("SYSCALL" ANY)
       ("LEGAL?" ANY)
       ("SETZONE" ANY)
       ("BLT" ANY T)
       ("ALLOCR" ANY T)
       ("ALLOCUU" ANY)
       ("ALLOCUV" ANY)
       ("ALLOCL" ANY)
       ("ALLOCUS" ANY)
       ("ALLOCUB" ANY)
       ("PUTS" ANY)
       ("SYSOP" ANY)
       ("MPAGES" FIX)
       ("ACALL" ANY)
       ("LOCK" ANY)
       ("RNTIME" FLOAT)
       ("TYPEW" ANY)
       ("TYPEWC" ANY)
       ("SAVTTY" ANY)
       ("FATAL" ANY)
       ("GETTTY" ANY)
       ("FGETBITS" ANY)
       ("FPUTBITS" ANY)
       ("PIPE" ANY)
       ("IFSYS" ANY)
       ("ENDIF" ANY)
       ("CGC-UVECTOR" ANY)
       ("CGC-VECTOR" ANY)
       ("CGC-STRING" ANY)
       ("CGC-BYTES" ANY)
       ("CGC-LIST" ANY)
       ("CGC-RECORD" ANY T)
       ("MOVSTK" ANY)
       ("GETSTK" ANY)
       ("ON-STACK?" FIX)
       ("USBLOCK" ANY)
       ("SBLOCK" ANY)
       ("UUBLOCK" ANY)
       ("BBIND" ANY)
       ("GEN-LVAL" ANY)
       ("GEN-SET" ANY)
       ("STRING-EQUAL?" ANY)
       ("MOVE-STRING" ANY)
       ("MOVE-WORDS" ANY)
       ("STRCOMP" ANY)
       ("SETSIZ" ANY)
       ("BIGSTACK" ANY)]>

<MAPF <>
      <FUNCTION (L "AUX" (S <1 .L>) (TYP <2 .L>) A) 
	      #DECL ((L) <LIST STRING ANY>)
	      <COND (<NOT <SET A <LOOKUP .S ,MIM-OBL>>>
		     <SET A <INSERT .S ,MIM-OBL>>)>
	      <COND (<N==? .TYP ANY> <PUTPROP .A TYPE .TYP>)>
	      <COND (<G? <LENGTH .L> 2> <PUTPROP .A `RECORD-TYPE T>)>>
      ,MIMOPS>

"Generate function starting pseudo-op"

<DEFINE MIM-FCN (NAME DCL "OPT" (NEED-FR <>) "AUX" TT) 
	#DECL ((ARGS-NEXT) LIST)
	<EMIT <SET TT <FORM <COND (.NEED-FR `FCN)
				  (ELSE `GFCN)>
			    <CHTYPE .NAME FCN-ATOM>
			    <CHTYPE .DCL LIST>>>>
	<SET ARGS-NEXT <REST .TT 2>>>

"Generate temp pseudo-op and return pointer to list so that others can
 be dynamically added"

<DEFINE MIM-TEMPS-HOLD () 
	#DECL ((TMPS) <SPECIAL FORM> (TMPS-NEXT) <SPECIAL LIST>)
	<SET TMPS <FORM `TEMP>>
	<SET TMPS-NEXT <CHTYPE .TMPS LIST>>
	.TMPS-NEXT>

<DEFINE MIM-TEMPS-EMIT ()
	<EMIT .TMPS>
	<IEMIT `INTGO>>

"Here to change any TEMPS to ADECLs if possible"

<DEFINE TYPIFY-TEMPS (L) 
	#DECL ((L) <LIST [REST TEMP]>)
	<MAPF <>
	      <FUNCTION (TMP "AUX" TYP) 
		      #DECL ((TMP) TEMP)
		      <COND (<AND <SET TYP <TEMP-TYPE .TMP>>
				  <SET TYP <ISTYPE? .TYP>>
				  <N==? .TYP NO-RETURN>
				  <N==? .TYP ANY>>
			     <MUNG-TMP .TMP <REST <TEMP-FRAME .TMP>> .TYP>)>>
	      .L>>

<DEFINE MUNG-TMP (TMP TL TYP "AUX" (NM <TEMP-NAME .TMP>))
	#DECL ((TMP) TEMP (TL) LIST)
	<MAPR <>
	      <FUNCTION (LL "AUX" (NM1 <1 .LL>))
		   <COND (<==? .NM1 .NM>
			  <PUT .LL 1 <CHTYPE [.NM .TYP] ADECL>>
			  <MAPLEAVE>)>>
	      .TL>>

"Here to create a temporary"

<DEFINE GEN-TEMP ("OPTIONAL" (ALLOCATE ANY) (NM "TEMP") (ARG-TEMP <>)
			     (NO-RECYC <>)
		  "AUX" TMP (TN .TMPS-NEXT) (FT .FREE-TEMPS))
   #DECL ((TMP) TEMP (EVERY-TEMP TN FT FREE-TEMPS TMPS-NEXT) LIST)
   <COND
    (<OR <EMPTY? .FT> .ARG-TEMP>
     <SET NM <MAKE-TAG .NM>>
     <COND (.ALLOCATE <PUTREST .TN <SET TMPS-NEXT (<CHTYPE .NM ATOM>)>>)>
     <SET TMP
	  <CHTYPE [.NM
	      <COND (<OR .ALLOCATE <AND .NO-RECYC .ARG-TEMP>> 1) (ELSE 0)>
	      .TMPS
	      <COND (<OR .ALLOCATE .ARG-TEMP> T) (ELSE <>)>
	      .NO-RECYC
	      <COND (.ALLOCATE <ISTYPE? .ALLOCATE>) (ELSE NO-RETURN)>]
	     TEMP>>
     <SET EVERY-TEMP (.TMP !.EVERY-TEMP)>
     .TMP)
    (<AND .ALLOCATE
	  <N==? .ALLOCATE ANY>
	  <REPEAT ((FT .FT) (OF .FT))
		  <COND (<EMPTY? .FT> <RETURN <>>)>
		  <COND (<OR <==? <TEMP-TYPE <SET TMP <1 .FT>>> NO-RETURN>
			     <AND <TEMP-TYPE .TMP>
				  <ISTYPE? <TYPE-MERGE <TEMP-TYPE .TMP>
						       .ALLOCATE>>>>
			 <COND (<==? .OF .FT> <SET FREE-TEMPS <REST .FT>>)
			       (ELSE <PUTREST .OF <REST .FT>>)>
			 <RETURN>)>
		  <SET FT <REST <SET OF .FT>>>>>
     <USE-TEMP .TMP .ALLOCATE>
     .TMP)
    (ELSE
     <SET TMP <1 .FT>>
     <SET FREE-TEMPS <REST .FT>>
     <COND (.ALLOCATE <USE-TEMP .TMP .ALLOCATE>)>
     .TMP)>>

;"Special version of GEN-TEMP for in other frame"

<DEFINE SPEC-GEN-TEMP (TTMPS
		       "OPTIONAL" (ALLOCATE ANY) (NM "TEMP")
		       "AUX" TMP L (TMPS-NEXT .TMPS-NEXT)
			     (FREE-TEMPS .FREE-TEMPS) (TMPS .TMPS))
	#DECL ((TMPS) <SPECIAL FORM> (TMPS-NEXT FREE-TEMPS) <SPECIAL LIST>
	       (ALL-TEMPS-LIST) <LIST [REST <LIST FORM LIST LIST ANY>]>)
	<COND (<N==? .TMPS .TTMPS>
	       <SET L <FIND-FRAME <SET TMPS .TTMPS> T>>
	       <COND (<EMPTY? .L>
		      <COMPILE-LOSSAGE "Bad frame model">)>
	       <SET TMPS-NEXT <2 .L>>
	       <SET FREE-TEMPS <3 .L>>
	       <SET TMP <GEN-TEMP .ALLOCATE .NM>>
	       <PUT .L 2 .TMPS-NEXT>
	       <PUT .L 3 .FREE-TEMPS>)
	      (ELSE <SET TMP <GEN-TEMP .ALLOCATE .NM>>)>
	.TMP>

<DEFINE FIND-FRAME (TMPS "OPTIONAL" (LOC <>) "AUX" (L .ALL-TEMPS-LIST)) 
	#DECL ((L ALL-TEMPS-LIST) <LIST [REST <LIST FORM LIST LIST TEMP>]>)
	<REPEAT ()
		<COND (<EMPTY? .L>
		       <COND (.LOC <RETURN ()>)
			     (ELSE <COMPILE-LOSSAGE "Bad frame model">)>)>
		<COND (<N==? <1 <1 .L>> .TMPS> <SET L <REST .L>>)
		      (ELSE <RETURN <COND (.LOC <1 .L>) (ELSE <4 <1 .L>>)>>)>>>

<DEFINE USE-TEMP (TMP
		  "OPT" (TY <>) INIT
		  "AUX" (NM <TEMP-NAME .TMP>) L (SPEC <CHTYPE .NM ATOM>))
	#DECL ((TMPS-NEXT) LIST (NM) <PRIMTYPE ATOM> (TMP) TEMP)
	<COND (<NOT <TEMP-ALLOC .TMP>>
	       <COND (<==? <TEMP-FRAME .TMP> .TMPS>
		      <PUTREST .TMPS-NEXT <SET TMPS-NEXT (.SPEC)>>)
		     (ELSE
		      <SET L <FIND-FRAME <TEMP-FRAME .TMP> T>>
		      <COND (<EMPTY? .L> <COMPILE-LOSSAGE "Bad frame model">)>
		      <PUTREST <2 .L> <2 <PUT .L 2 (.SPEC)>>>)>
	       <PUT .TMP ,TEMP-ALLOC T>)>
	<COND (<AND .TY <TEMP-TYPE .TMP>>
	       <PUT .TMP ,TEMP-TYPE
		    <ISTYPE? <TYPE-MERGE <TEMP-TYPE .TMP> .TY>>>)
	      (<NOT .TY> <PUT .TMP ,TEMP-TYPE <>>)>
	<PUT .TMP ,TEMP-REFS <+ <TEMP-REFS .TMP> 1>>>

<DEFINE FREE-TEMP (TMP "OPTIONAL" (KILL T) "AUX" REFS L) 
	#DECL ((REFS) FIX (L FREE-TEMPS) LIST)
	<COND (<TYPE? .TMP TEMP>
	       <SET REFS <TEMP-REFS .TMP>>
	       <PUT .TMP ,TEMP-REFS <SET REFS <MAX <- .REFS 1> 0>>>
	       <COND (<0? .REFS>
		      <COND (<NOT <TEMP-NO-RECYCLE .TMP>>
			     <COND (<AND <==? .TMPS <TEMP-FRAME .TMP>>
					 <NOT <MEMQ .TMP .FREE-TEMPS>>>
				    <SET FREE-TEMPS (.TMP !.FREE-TEMPS)>)
				   (ELSE
				    <SET L <FIND-FRAME <TEMP-FRAME .TMP> T>>
				    <COND (<AND <NOT <EMPTY? .L>>
						<NOT <MEMQ .TMP <3 .L>>>>
					   <PUT .L 3 (.TMP !<3 .L>)>)>)>)>
		      <COND (.KILL <IEMIT `DEAD <TEMP-NAME .TMP>>)>)>)>
	.TMP>

<DEFINE DEALLOCATE-TEMP (TMP "AUX" REFS)
	#DECL ((REFS) FIX)
	<COND (<TYPE? .TMP TEMP>
	       <SET REFS <TEMP-REFS .TMP>>
	       <PUT .TMP ,TEMP-REFS <MAX <- .REFS 1> 0>>)>
	.TMP>

"Generate a unique atom for label, temp name, var name etc."

<DEFINE MAKE-TAG ("OPTIONAL" (S "TAG") "AUX" LC TC) 
	#DECL ((S) <OR ATOM STRING>)
	<COND (<TYPE? .S ATOM> <SET S <SPNAME .S>>)>
	<SET TC <UNPARSE <SET TAG-COUNT <+ .TAG-COUNT 1>>>>
	<COND (<AND <G=? <SET LC <- <CHTYPE <NTH .S <LENGTH .S>> FIX>
				    48>> 0>
		    <L=? .LC 9>>
	       <SET S <STRING .S "-" .TC>>)
	      (ELSE
	       <SET S <STRING .S .TC>>)>
	<OR <LOOKUP .S ,TMP-OBL> <INSERT .S ,TMP-OBL>>>

"Add an instruction to the output code"

<DEFINE EMIT (THING) 
	#DECL ((CODE-PTR) <LIST ANY>)
	<PUTREST .CODE-PTR <SET CODE-PTR (.THING !<REST .CODE-PTR>)>>>

<SETG INSTRUCTION ,FORM>

<DEFINE IEMIT ("TUPLE" X) <REAL-IEMIT <> .X>>

<DEFINE SPEC-IEMIT ("TUPLE" X) <REAL-IEMIT T .X>>

<DEFINE REAL-IEMIT (SKIP-DEAD X
		    "AUX" (DEAD-TEMPS ()) (INS <1 .X>) (PAST= <>) FOR-SETRL
			  (DO-LATER-SETRL <>) (FREED-TEMPS ()) TMP CP)
   #DECL ((X) <TUPLE ANY> (DEAD-TEMPS FREED-TEMPS) LIST (CP CODE-PTR) LIST)
   <COND
    (<OR
      <EMPTY? <REST .X>>
      <MAPR <>
       <FUNCTION (XP "AUX" (Y <1 .XP>) Z) 
	  #DECL ((XP) <PRIMTYPE VECTOR> (Z) TEMP)
	  <COND (<==? .Y => <SET PAST= T>)>
	  <COND
	   (<TYPE? .Y MIM-SPECIAL> <PUT .XP 1 <CHTYPE .Y ATOM>>)
	   (<TYPE? .Y TEMP>
	    <COND
	     (<AND <N==? <TEMP-FRAME .Y> .TMPS>
		   <OR <N==? .INS `SETRL> <N==? .XP <REST .X 2>>>>
	      <COND (<==? .INS `SET>
		     <COND (<==? .XP <REST .X>>
			    <IEMIT `SETRL
				   <FIND-FRAME <TEMP-FRAME .Y>>
				   <TEMP-NAME .Y>
				   <2 .XP>
				   !<REST .X 3>>)
			   (ELSE
			    <IEMIT `SETLR
				   <2 .X>
				   <FIND-FRAME <TEMP-FRAME .Y>>
				   <TEMP-NAME .Y>
				   !<REST .X 3>>)>
		     <MAPLEAVE <>>)
		    (<NOT .PAST=>
		     <SET FREED-TEMPS (<SET Z <LOOP-FRAME .Y>> !.FREED-TEMPS)>
		     <SET DEAD-TEMPS (<TEMP-NAME .Z> !.DEAD-TEMPS)>)
		    (ELSE
		     <SET DO-LATER-SETRL <GEN-TEMP>>
		     <SET Z .DO-LATER-SETRL>
		     <SET FOR-SETRL .Y>)>)
	     (ELSE <SET Z .Y>)>
	    <PUT .XP 1 <TEMP-NAME .Z>>
	    <COND (<==? <TEMP-REFS .Y> 0>
		   <SET DEAD-TEMPS (<TEMP-NAME .Y> !.DEAD-TEMPS)>)>)
	   (<AND <TYPE? .Y ATOM>
		 <N==? .Y =>
		 <N==? .Y +>
		 <N==? .Y ->
		 <N==? .Y `COMPERR>
		 <N==? .Y `UNWCONT>
		 <N==? .Y ,POP-STACK>
		 <N==? <OBLIST? .Y> ,TMP-OBL>>
	    <PUT .XP 1 <FORM QUOTE .Y>>)>
	  1>
       <REST .X>>>
     <SET INS <INSTRUCTION .INS !<REST .X>>>
     <COND (<AND .SKIP-DEAD
		 <TYPE? <SET TMP <1 <SET CP .CODE-PTR>>> FORM>
		 <NOT <EMPTY? .TMP>>
		 <==? <1 .TMP> `DEAD>>
	    <PUT .CP 1 .INS>
	    <SET INS .TMP>)>
     <EMIT .INS>
     <COND (.DO-LATER-SETRL
	    <IEMIT `SETRL
		   <FIND-FRAME <TEMP-FRAME .FOR-SETRL>>
		   <TEMP-NAME .FOR-SETRL>
		   .DO-LATER-SETRL>)>)>
   <MAPF <>
	 <FUNCTION (TMP) #DECL ((TMP) TEMP) <FREE-TEMP .TMP <>>>
	 .FREED-TEMPS>
   <COND (<NOT <EMPTY? .DEAD-TEMPS>>
	  <EMIT <CHTYPE (`DEAD !.DEAD-TEMPS) FORM>>)>
   T>

<DEFINE LOOP-FRAME (TMP
		    "OPTIONAL" LTMP (TNAME <TEMP-NAME <4 <1 .ALL-TEMPS-LIST>>>)
		    "AUX" (XTMP
			   <COND (<ASSIGNED? LTMP> .LTMP) (ELSE <GEN-TEMP>)>)
			  (TMPS <1 <1 .ALL-TEMPS-LIST>>)
			  (ALL-TEMPS-LIST <REST .ALL-TEMPS-LIST>))
	#DECL ((TMPS) <SPECIAL FORM>
	       (ALL-TEMPS-LIST) <SPECIAL <LIST [REST
						<LIST FORM LIST LIST TEMP>]>>)
	<COND (<N==? .TMPS <TEMP-FRAME .TMP>>
	       <IEMIT `SETLR
		      <TEMP-NAME .XTMP>
		      .TNAME
		      <TEMP-NAME <4 <1 .ALL-TEMPS-LIST>>>>
	       <LOOP-FRAME .TMP .XTMP <TEMP-NAME .XTMP>>)
	      (ELSE <IEMIT `SETLR <TEMP-NAME .XTMP> .TNAME <TEMP-NAME .TMP>>)>
	.XTMP>

"Generate a label in the code"

<DEFINE LABEL-TAG (TG) <EMIT .TG>>

"Generate jump to label"

<DEFINE BRANCH-TAG (TG) <IEMIT `JUMP + .TG>>

"Generate code to PUSH something onto stack.  It can be called with various
 arguments:
	1) #TEMP - refernce to a named temporary
	3) #MIM-SPECIAL atom - MIM special variable
	4) other - quoted object "

<DEFINE PUSH (ITM) 
	<COND (<TYPE? .ITM MIM-SPECIAL> <IEMIT `PUSH <CHTYPE .ITM ATOM>>)
	      (<TYPE? .ITM TEMP> <IEMIT `PUSH .ITM>)
	      (<==? .ITM ,POP-STACK>)
	      (ELSE <IEMIT `PUSH <ATOMCHK .ITM>>)>
	,TOP-STACK>

<DEFINE POP (ITM) 
	<COND (<TYPE? .ITM TEMP> <IEMIT `POP = <TEMP-NAME .ITM>>)
	      (<==? .ITM FLUSHED> <IEMIT `ADJ -2>)
	      (<AND <N==? .ITM ,TOP-STACK> <N==? .ITM DONT-CARE>>
	       <COMPILE-LOSSAGE "Bad arg to POP" .ITM>)
	      (ELSE <SET ITM ,POP-STACK>)>
	.ITM>

<DEFINE PUSH-CONSTANT (X) <PUSH <ATOMCHK .X>>>

" Generate FIXBIND to wrap bindings pending by linking up atoms."

<DEFINE GEN-FIX-BIND () <IEMIT `FIXBIND>>

" Generate code for optional arguments."

<DEFINE GEN-ARG-NUM (N) #DECL ((N) FIX) <IEMIT `ARGNUM .N>>

<DEFINE SPECIAL-BINDING (SYM FIXB "OPTIONAL" INIT) 
	<COND (<ASSIGNED? INIT>
	       <IEMIT `BBIND
		      <ATOMCHK <NAME-SYM .SYM>>
		      <ATOMCHK <DECL-SYM .SYM>>
		      <COND (.FIXB ''FIX) (ELSE <>)>
		      .INIT>)
	      (ELSE
	       <IEMIT `BBIND
		      <ATOMCHK <NAME-SYM .SYM>>
		      <ATOMCHK <DECL-SYM .SYM>>
		      <COND (.FIXB ''FIX) (ELSE <>)>>)>>

"Get the value of a special variable bound in the current function"

<DEFINE GET-VALUE-X (ATM TMP
		     "OPT" (EXT <>)
		     "AUX" (BTMP <COND (<AND <TYPE? .TMP TEMP>
					     <OR <NOT <TEMP-NO-RECYCLE .TMP>>
						 <==? <TEMP-NO-RECYCLE .TMP>
						      ANY>>
					     <NOT <TEMP-TYPE .TMP>>
					     <==? <TEMP-FRAME .TMP> .TMPS>>
					.TMP)
				       (ELSE <GEN-TEMP>)>) (FQA <ATOMCHK .ATM>)
			    (TG1 <MAKE-TAG>) (TG2 <MAKE-TAG>) BIDTMP1 BIDTMP2)
	#DECL ((BTMP BIDTMP1 BIDTMP2) TEMP)
	<COND (.EXT
	       <IEMIT `GEN-LVAL .FQA = .TMP>)
	      (ELSE
	       <USE-TEMP .BTMP <>>
	       <DEALLOCATE-TEMP .BTMP>
	       <IEMIT `NTHR .FQA ,M$$LVAL = .BTMP ,RAT '(`TYPE LBIND)>
	       <IEMIT `NTHR .BTMP ,M$$VALU = .TMP ,RBN>
	       <COND (<N==? .TMP .BTMP> <FREE-TEMP .BTMP>)>)>
	.TMP>

"See if a special variable is assigned"

<DEFINE ASS-GEN (ATM TG DIR
		 "OPT" (EXT <>)
		 "AUX" (BTMP <GEN-TEMP>) (FQA <ATOMCHK .ATM>) BIDTMP1 BIDTMP2
		       (TGX <COND (.DIR <MAKE-TAG>) (ELSE .TG)>))
	#DECL ((BTMP BIDTMP1 BIDTMP2) TEMP)
	<COND (.EXT <IEMIT `GEN-ASSIGNED? .FQA <COND (.DIR +) (ELSE -)> .TG>)
	      (ELSE
	       <IEMIT `NTHR .FQA ,M$$LVAL = .BTMP ,RAT '(`TYPE LBIND)>
	       <IEMIT `NTHR .BTMP ,M$$VALU = .BTMP ,RBN>
	       <GEN-TYPE? .BTMP UNBOUND .TG <NOT .DIR>>
	       <FREE-TEMP .BTMP>)>>

"Set the value of a special variable bound in the current function"

<DEFINE SET-VALUE (ATM TMP
		   "OPT" (EXT <>)
		   "AUX" BTMP
			 (FQA <ATOMCHK .ATM>) (TG1 <MAKE-TAG>) (TG2 <MAKE-TAG>)
			 BIDTMP1 BIDTMP2)
	#DECL ((BTMP BIDTMP1 BIDTMP2) TEMP)
	<COND (.EXT
	       <IEMIT `GEN-SET .FQA .TMP>)
	      (ELSE
	       <SET BTMP <GEN-TEMP LBIND>>
	       <IEMIT `NTHR .FQA ,M$$LVAL = .BTMP ,RAT '(`TYPE LBIND)>
	       <IEMIT `PUTR .BTMP ,M$$VALU <ATOMCHK .TMP> ,RBN>
	       <FREE-TEMP .BTMP>)>
	.TMP>

"Generate code to set a MIM local"

<DEFINE SET-SYM (SYM "OPTIONAL" VAL (USE-IT <>)
		 "AUX" (TMP <TEMP-NAME-SYM .SYM>) (TY ANY)
		       (REFS <TEMP-REFS .TMP>)) 
	#DECL ((SYM) SYMTAB (TMP) TEMP (REFS) FIX)
	<COND (<ASSIGNED? VAL>
	       <SET TY <COND (<TYPE? .VAL TEMP> <TEMP-TYPE .VAL>)
			     (ELSE <TYPE .VAL>)>>
	       <SET-TEMP .TMP .VAL>)>
	<COND (.USE-IT
	       <USE-TEMP .TMP .TY>
	       <PUT .TMP ,TEMP-REFS <+ .REFS 1>>)>>

<DEFINE SET-TEMP (TMP "OPTIONAL" VAL XTRA "AUX" REFS (TY ANY)) 
	#DECL ((TMP) TEMP (REFS) FIX)
	<COND (<ASSIGNED? VAL>
	       <SET TY
		    <COND (<TYPE? .VAL TEMP> <TEMP-TYPE .VAL>)
			  (ELSE <TYPE .VAL>)>>)>
	<USE-TEMP .TMP .TY>
	<COND (<ASSIGNED? VAL>
	       <COND (<TYPE? .VAL MIM-SPECIAL> <SET VAL <CHTYPE .VAL ATOM>>)
		     (ELSE <SET VAL <ATOMCHK .VAL>>)>
	       <COND (<ASSIGNED? XTRA> <IEMIT `SET .TMP .VAL .XTRA>)
		     (ELSE <IEMIT `SET .TMP .VAL>)>)>>

"Quote atom to protect the MIM assembler"

<DEFINE ATOMCHK (X)
	<COND (<REPEAT ((Y .X))
		       <COND (<TYPE? .Y ATOM> <RETURN T>)>
		       <COND (<AND <TYPE? .Y FORM>
				   <==? <LENGTH .Y> 2>
				   <==? <1 .Y> QUOTE>>
			      <SET Y <2 .Y>>)
			     (ELSE <RETURN <>>)>>
	       <FORM QUOTE .X>)
	      (ELSE .X)>>

" Return currently running FRAME "

<DEFINE CURRENT-FRAME ("OPTIONAL" (FR <GEN-TEMP FRAME>))
	<IEMIT `CFRAME = .FR '(`TYPE FRAME)> .FR>

" Return TUPLE of arguments"

<DEFINE GET-ARG-TUPLE (FR) 
	<USE-TEMP .FR TUPLE>
	<PUT .TMPS 1 `MAKTUP>
	<SET TMP-DEST <TEMP-NAME .FR>>
	.FR>

"Compare # of args supplied with a constant and jump in appropriate case"

<DEFINE TEST-ARG (TMP TG) 
	#DECL ((TMP) TEMP (TG) ATOM)
	<GEN-TYPE? .TMP UNBOUND .TG <>>
	T>

"Get current binding at top of world"

<DEFINE GET-BINDING (WHERE) <IEMIT `GETS ,QQ-BIND = .WHERE '(`TYPE LBIND)>>

"Get an arg by arg number and mung into a local"

<DEFINE ARG-TO-TEMP (SYM
		     "AUX" (TMP <TEMP-NAME-SYM .SYM>)
			   (ATMP <ARG-NAME-SYM .SYM>))
	#DECL ((SYM) SYMTAB (TMP) TEMP)
	<IEMIT `SET <TEMP-NAME .TMP> <TEMP-NAME .ATMP>>>

"Generate call to MSUBR"

<DEFINE MSUBR-CALL (NAM NARGS W) 
	<SET NAM <CHTYPE .NAM FCN-ATOM>>
	<COND (<==? .W FLUSHED>
	       <IEMIT `CALL <FORM QUOTE .NAM> .NARGS>)
	      (ELSE <IEMIT `CALL <FORM QUOTE .NAM> .NARGS = .W>)>>

<DEFINE SEG-SUBR-CALL (NAM NARGS W COUNT LABEL) 
	<SET NAM <CHTYPE .NAM FCN-ATOM>>
	<IEMIT `SCALL <FORM QUOTE .NAM> .NARGS = .W + .LABEL .COUNT>>

"Begin building a FRAME for a future call"

<DEFINE START-FRAME ("OPT" (NAME <>))
	 <COND (.NAME <IEMIT `FRAME <FORM QUOTE <CHTYPE .NAME FCN-ATOM>>>)
	       (ELSE <IEMIT `FRAME>)>>

"Generate a VECTOR of the top N things on the stack"

<DEFINE GEN-VECTOR (N V "OPT" (S? <>))
	<IEMIT <COND (.S? `SBLOCK)
		     (ELSE `UBLOCK)> '<`TYPE-CODE VECTOR> .N = .V>
	.V>

<DEFINE GEN-UVECTOR (N V "OPT" (S? <>))
	<IEMIT <COND (.S? `SBLOCK)
		     (ELSE `UBLOCK)> '<`TYPE-CODE UVECTOR> .N = .V>
	.V>

"Same for TUPLE"

<DEFINE GEN-TUPLE (N V)
	<IEMIT `TUPLE .N = .V '(`TYPE TUPLE)>
	.V>

"Same for LIST"

<DEFINE GEN-LIST (N L) <IEMIT `LIST .N = .L '(`TYPE LIST)>>

"Generate code to move datum from place to place"

<DEFINE MOVE-ARG (FROM TO "OPT" XTRA "AUX" (TY ANY)) 
	<COND (<AND <NOT <ASSIGNED? XTRA>> <NOT <TYPE? .FROM TEMP>>>
	       <SET XTRA <COND (<AND <TYPE? .FROM FORM>
				     <==? <LENGTH .FROM> 2>
				     <==? <1 .FROM> QUOTE>
				     <TYPE? <2 .FROM> ATOM>>
				'(`TYPE ATOM))
			       (ELSE (`TYPE <TYPE .FROM>))>>
	       <SET TY <2 .XTRA>>)
	      (<AND <ASSIGNED? XTRA> <TYPE? .XTRA LIST>> <SET TY <2 .XTRA>>)
	      (<TYPE? .FROM TEMP> <SET TY <TEMP-TYPE .FROM>>)
	      (ELSE <SET TY <TYPE .FROM>>)>
	<COND (<==? .TO FLUSHED>
	       <COND (<==? .FROM ,POP-STACK> <POP FLUSHED>)>
	       <FREE-TEMP .FROM>
	       ,NO-DATUM)
	      (<TYPE? .TO LIST>
	       <MAPF <>
		     <FUNCTION (TTO) <MOVE-ARG .FROM .TTO .XTRA>>
		     .TO>)
	      (<N==? .TO .FROM>
	       <COND (<==? .TO ,POP-STACK> <PUSH .FROM> <FREE-TEMP .FROM> .TO)
		     (<AND <ASSIGNED? THE-BOOL> <==? .THE-BOOL .TO>>
		      <COND (<NOT .FROM>
			     <IEMIT `AND .THE-BOOL .THE-BIT = .THE-BOOL>)
			    (<==? .FROM T>
			     <IEMIT `OR .THE-BOOL .THE-BIT = .THE-BOOL>)
			    (ELSE <ERROR OH-SHIT!-ERRORS>)>
		      .TO)
		     (<TYPE? .TO TEMP>
		      <USE-TEMP .TO .TY>
		      <COND (<TYPE? .FROM TEMP>
			     <COND (<ASSIGNED? XTRA>
				    <IEMIT `SET  .TO .FROM .XTRA>)
				   (ELSE
				    <IEMIT `SET .TO .FROM>)>
			     <FREE-TEMP .FROM>)
			    (ELSE
			     <COND (<ASSIGNED? XTRA>
				    <IEMIT `SET .TO <ATOMCHK  .FROM> .XTRA>)
				   (ELSE
				    <IEMIT `SET .TO <ATOMCHK  .FROM>>)>)>
		      .TO)
		     (<==? .TO DONT-CARE>
		      <COND (<==? .FROM ,TOP-STACK> ,POP-STACK)
			    (ELSE .FROM)>)>)
	      (ELSE .TO)>>

<DEFINE REFERENCE (X) .X>

"Generate a TYPE? instruction"

<DEFINE GEN-TYPE? (ITM TYP TG DIR) 
	<IEMIT `TYPE?
	       .ITM
	       <COND (<TYPE? .TYP TEMP> .TYP) (ELSE <FORM `TYPE-CODE .TYP>)>
	       <COND (.DIR +) (ELSE -)>
	       .TG>>

<DEFINE GEN-VT (ITM TG DIR
		"OPT" RTMP
		"AUX" TMP (SIGN <COND (.DIR -) (+)>))
	<COND (<ASSIGNED? RTMP> <SET TMP .RTMP>)
	      (ELSE <SET TMP <GEN-TEMP <>>>)>
	<USE-TEMP .TMP>
	<IEMIT `NTHR .ITM ,M$$TYPE = .TMP ,RAT (`BRANCH-FALSE .SIGN .TG)>
	<SPEC-IEMIT `TYPE? .TMP '<`TYPE-CODE FALSE>
		    <COND (.DIR -)(ELSE +)> .TG>
	<COND (<NOT <ASSIGNED? RTMP>> <FREE-TEMP .TMP>)>>

<DEFINE GEN-TC (TMP "OPT" RTMP) 
	<COND (<ASSIGNED? RTMP> <USE-TEMP .RTMP TYPE-C>)
	      (ELSE <SET RTMP <GEN-TEMP TYPE-C>>)>
	<COND (.CAREFUL
	       <IEMIT `NTHR .TMP ,M$$TYPE = .RTMP ,RAT
		      '(`BRANCH-FALSE + `COMPERR)>
	       <SPEC-IEMIT `TYPE? .RTMP '<`TYPE-CODE FALSE> + `COMPERR>)
	      (ELSE
	       <IEMIT `NTHR
		      .TMP
		      ,M$$TYPE
		      =
		      .RTMP
		      ,RAT
		      '(`TYPE TYPE-C)>)>
	.RTMP>

"Generate SETG/GVAL things"

<DEFINE GEN-GVAL (ATM W "OPT" (TYP <>) "AUX" TEM TG1 TG2) 
	<COND (<TYPE? .ATM ATOM> <SET ATM <FORM QUOTE .ATM>>)>
	<COND (.TYP <IEMIT `GVAL .ATM = .W (`TYPE .TYP)>)
	      (ELSE <IEMIT `GVAL .ATM = .W>)>>

<DEFINE GEN-GASS (ATM TG DIR NM "AUX" (TG1 <COND (<N==? .NM GASSIGNED?> .TG)
						 (.DIR <MAKE-TAG>)
					         (ELSE .TG)>) (SIGN +) TEM)
	<COND (<AND .DIR <N==? .NM GASSIGNED?>> <SET SIGN ->)>
	<IEMIT `NTHR <COND (<TYPE? .ATM ATOM> <FORM QUOTE .ATM>)
			   (ELSE .ATM)>
	       ,M$$GVAL = <SET TEM <GEN-TEMP>> ,RAT
	       (`BRANCH-FALSE .SIGN .TG1)>
	<SPEC-IEMIT `TYPE? .TEM '<`TYPE-CODE FALSE> .SIGN .TG1>
	<COND (<==? .NM GASSIGNED?>
	       <IEMIT `NTHR .TEM ,M$$VALU = .TEM ,RGBN>
	       <GEN-TYPE? .TEM UNBOUND .TG <NOT .DIR>>)>
	<COND (<N==? .TG .TG1> <LABEL-TAG .TG1>)>
	<FREE-TEMP .TEM>>


<DEFINE GEN-SETG (ATM VAL DCL WHERE "AUX" TEM TG1 TG2)
	<COND (<TYPE? .ATM ATOM>
	       <IEMIT `SETG <FORM QUOTE .ATM> <ATOMCHK .VAL>>)
	      (ELSE
	       <IEMIT `NTHR .ATM ,M$$GVAL = <SET TEM <GEN-TEMP>> ,RAT
		      (`BRANCH-FALSE + <SET TG1 <MAKE-TAG>>)>
	       <SPEC-IEMIT `TYPE? .TEM '<`TYPE-CODE FALSE> + .TG1>
	       <IEMIT `PUTR .TEM ,M$$VALU .VAL ,RGBN>
	       <COND (.DCL
		      <IEMIT .TEM `PUTR ,M$$DECL .DCL ,RGBN>)>
	       <BRANCH-TAG <SET TG2 <MAKE-TAG>>>
	       <LABEL-TAG .TG1>
	       <START-FRAME SETG>
	       <PUSH .ATM>
	       <PUSH .VAL>
	       <COND (.DCL <PUSH .DCL>)>
	       <COND (<N==? .WHERE FLUSHED>
		      <MSUBR-CALL SETG <COND (.DCL 3) (ELSE 2)> .VAL>)
		     (ELSE
		      <MSUBR-CALL SETG <COND (.DCL 3) (ELSE 2)> FLUSHED>)>
	       <LABEL-TAG .TG2>
	       <FREE-TEMP .TEM>)>>

"Generate CHTYPE"

<DEFINE GEN-CHTYPE (ITM TYP W) 
	<IEMIT `CHTYPE .ITM <COND (<AND <TYPE? .TYP ATOM>
					<VALID-TYPE? .TYP>>
				   <FORM `TYPE-CODE .TYP>)
				  (ELSE .TYP)> = .W>>

<DEFINE D-B-TAG (BR WH DIR TYP)
	<COND (<AND <NOT <TYPE-OK? .TYP '<FALSE ANY>>>
		    <SET TYP <TYPE-AND .TYP '<NOT FALSE>>>
		    <NOT <TYPE-OK? .TYP '<PRIMTYPE FIX>>>
		    <OR <NOT <SET TYP <TYPE-AND .TYP '<PRIMTYPE LIST>>>>
			<G? <MINL .TYP> 0>>>
	       <IEMIT `VEQUAL? .WH 0 <COND (.DIR -)(ELSE +)> .BR>)
	      (ELSE
	       <GEN-TYPE? .WH FALSE .BR <NOT .DIR>>)>>

<DEFINE MIM-RETURN ("OPTIONAL" (VAL ,POP-STACK))
	<IEMIT `RETURN <ATOMCHK .VAL>>>

<DEFINE RET-TMP-AC (X) .X>

<DEFINE GEN-SHIFT (DAT AMT W) <IEMIT `LSH .DAT .AMT = .W '(`TYPE FIX)>>

<DEFINE NTH-LIST (SRC DST AMT "OPT" (RESTYP <>))
	<COND (.RESTYP <IEMIT `NTHL .SRC .AMT = .DST (`TYPE .RESTYP)>)
	      (ELSE <IEMIT `NTHL .SRC .AMT = .DST>)>>

<DEFINE NTH-UVECTOR (SRC DST AMT "OPT" (RESTYP <>))
	<COND (.RESTYP <IEMIT `NTHUU .SRC .AMT = .DST (`TYPE .RESTYP)>)
	      (ELSE <IEMIT `NTHUU .SRC .AMT = .DST>)>>

<DEFINE NTH-VECTOR (SRC DST AMT "OPT" (RESTYP <>))
	<COND (.RESTYP <IEMIT `NTHUV .SRC .AMT = .DST (`TYPE .RESTYP)>)
	      (ELSE <IEMIT `NTHUV .SRC .AMT = .DST>)>>

<DEFINE NTH-STRING (SRC DST AMT "OPT" (RESTYP <>))
	<COND (.RESTYP <IEMIT `NTHUS .SRC .AMT = .DST (`TYPE .RESTYP)>)
	      (ELSE <IEMIT `NTHUS .SRC .AMT = .DST>)>>

<DEFINE NTH-BYTES (SRC DST AMT "OPT" (RESTYP <>))
	<COND (.RESTYP <IEMIT `NTHUB .SRC .AMT = .DST (`TYPE .RESTYP)>)
	      (ELSE <IEMIT `NTHUB .SRC .AMT = .DST>)>>

<DEFINE NTH-RECORD (SRC DST AMT TPS "OPT" (RESTYP <>))
	<COND (.RESTYP
	       <IEMIT `NTHR .SRC .AMT = .DST (`RECORD-TYPE .TPS)
		      (`TYPE .RESTYP)>)
	      (ELSE
	       <IEMIT `NTHR .SRC .AMT = .DST (`RECORD-TYPE .TPS)>)>>

<DEFINE REST-LIST (SRC DST AMT) <IEMIT `RESTL .SRC .AMT = .DST
				       '(`TYPE LIST)>>

<DEFINE REST-UVECTOR (SRC DST AMT) <IEMIT `RESTUU .SRC .AMT = .DST
					  '(`TYPE UVECTOR) >>

<DEFINE REST-VECTOR (SRC DST AMT "OPT" TY)
	<COND (<ASSIGNED? TY>
	       <IEMIT `RESTUV .SRC .AMT = .DST (`TYPE .TY)>)
	      (ELSE
	       <IEMIT `RESTUV .SRC .AMT = .DST>)>>

<DEFINE REST-STRING (SRC DST AMT) <IEMIT `RESTUS .SRC .AMT = .DST
					 '(`TYPE STRING) >>

<DEFINE REST-BYTES (SRC DST AMT) <IEMIT `RESTUB .SRC .AMT = .DST
					 '(`TYPE BYTES) >>

<DEFINE EMPTY-LIST (SRC TG DIR "OPT" (TY <>)) 
	<COND (.TY
	       <IEMIT `EMPL? .SRC <COND (.DIR +) (ELSE -)> .TG
		      (`TYPE .TY)>)
	      (ELSE
	       <IEMIT `EMPL? .SRC <COND (.DIR +) (ELSE -)> .TG>)>>

<DEFINE EMPTY-UVECTOR (SRC TG DIR "OPT" (TY <>)) 
	<COND (.TY
	       <IEMIT `EMPUU? .SRC <COND (.DIR +) (ELSE -)> .TG
		      (`TYPE .TY)>)
	      (ELSE
	       <IEMIT `EMPUU? .SRC <COND (.DIR +) (ELSE -)> .TG>)>>

<DEFINE EMPTY-VECTOR (SRC TG DIR "OPT" (TY <>)) 
	<COND (.TY
	       <IEMIT `EMPUV? .SRC <COND (.DIR +) (ELSE -)> .TG
		      (`TYPE .TY)>)
	      (ELSE
	       <IEMIT `EMPUV? .SRC <COND (.DIR +) (ELSE -)> .TG>)>>

<DEFINE EMPTY-STRING (SRC TG DIR "OPT" (TY <>)) 
	<COND (.TY
	       <IEMIT `EMPUS? .SRC <COND (.DIR +) (ELSE -)> .TG
		      (`TYPE .TY)>)
	      (ELSE
	       <IEMIT `EMPUS? .SRC <COND (.DIR +) (ELSE -)> .TG>)>>

<DEFINE EMPTY-BYTES (SRC TG DIR "OPT" (TY <>)) 
	<COND (.TY
	       <IEMIT `EMPUB? .SRC <COND (.DIR +) (ELSE -)> .TG
		      (`TYPE .TY)>)
	      (ELSE
	       <IEMIT `EMPUB? .SRC <COND (.DIR +) (ELSE -)> .TG>)>>

<DEFINE EMPTY-RECORD (SRC TG DIR TPS) 
	<IEMIT `EMPR? .SRC <COND (.DIR +) (ELSE -)> .TG
	       (`RECORD-TYPE .TPS)>>

<DEFINE LENGTH-LIST (SRC DST) <IEMIT `LENL .SRC = .DST '(`TYPE FIX)>>

<DEFINE LENGTH-UVECTOR (SRC DST) <IEMIT `LENUU .SRC = .DST '(`TYPE FIX)>>

<DEFINE LENGTH-VECTOR (SRC DST) <IEMIT `LENUV .SRC = .DST '(`TYPE FIX)>>

<DEFINE LENGTH-STRING (SRC DST) <IEMIT `LENUS .SRC = .DST '(`TYPE FIX)>>

<DEFINE LENGTH-BYTES (SRC DST) <IEMIT `LENUB .SRC = .DST '(`TYPE FIX)>>

<DEFINE LENGTH-RECORD (SRC DST TPS) <IEMIT `LENR .SRC = .DST
					   (`RECORD-TYPE .TPS) '(`TYPE FIX)>>

<DEFINE PUT-LIST (SRC NUM NEW "OPT" (TY <>)) 
	<COND (.TY <IEMIT `PUTL .SRC .NUM <ATOMCHK .NEW> .TY>)
	      (ELSE <IEMIT `PUTL .SRC .NUM <ATOMCHK .NEW>>)>>

<DEFINE PUT-VECTOR (SRC NUM NEW "OPT" (TY <>))
	<COND (.TY <IEMIT `PUTUV .SRC .NUM <ATOMCHK .NEW> .TY>)
	      (ELSE <IEMIT `PUTUV .SRC .NUM <ATOMCHK .NEW>>)>>

<DEFINE PUT-UVECTOR (SRC NUM NEW) <IEMIT `PUTUU .SRC .NUM .NEW>>

<DEFINE PUT-STRING (SRC NUM NEW) <IEMIT `PUTUS .SRC .NUM .NEW>>

<DEFINE PUT-BYTES (SRC NUM NEW) <IEMIT `PUTUB .SRC .NUM .NEW>>

<DEFINE PUT-RECORD (SRC NUM NEW TPS "OPT" (TY <>)) 
	<COND (.TY <IEMIT `PUTR .SRC .NUM <ATOMCHK .NEW> (`RECORD-TYPE .TPS) .TY>)
	      (ELSE <IEMIT `PUTR .SRC .NUM <ATOMCHK .NEW> (`RECORD-TYPE .TPS)>)>>

<DEFINE PROTECT (ITM) 
	<COND (<AND <TYPE? .ITM TEMP>
		    <0? <TEMP-REFS .ITM>>>
	       .ITM)
	      (ELSE
	        <PUSH .ITM>)>>

<DEFINE GEN-VAL-==? (D1 D2 DIR BR) 
	<IEMIT `VEQUAL? <ATOMCHK .D1> <ATOMCHK .D2> <COND (.DIR +) (ELSE -)> .BR>>

<DEFINE GEN-==? (D1 D2 DIR BR) 
	<IEMIT `EQUAL? <ATOMCHK .D1> <ATOMCHK .D2> <COND (.DIR +) (ELSE -)> .BR>>


<DEFINE PREV-FRAME (WHERE)
	<IEMIT `CFRAME = .WHERE>
	<IEMIT `NTHR .WHERE ,M$$FRM-PREV = .WHERE (`RECORD-TYPE FRAME)>
	.WHERE>

<ENDPACKAGE>
