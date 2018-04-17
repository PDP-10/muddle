
<PACKAGE "PASS1">

<ENTRY PASS1
       PCOMP
       PMACRO
       PAPPLY-OBJECT
       PAPPLY-TYPE
       PTHIS-OBJECT
       PTHIS-TYPE
       GEN-D
       ACT-FIX
       FIND_DECL
       SEG?
       PSUBR-C>

<RENTRY REFERENCED>

<USE "GC-DUMP" "CHKDCL" "COMPDEC" "MIMGEN" "ADVMESS" "CDRIVE">

"	This file contains the first pass of the MUDDLE compiler.
The functions therein take a MUDDLE function and build a more detailed
model of it.  Each entity in the function is represented by an object
of type NODE.  The entire function is represented by the functions node
and it points to the rest of the nodes for the function."

"	Nodes vary in complexity and size depending on what they represent.
A function or prog/repeat node is contains more information than a node
for a quoted object.  All nodes have some fields in common to allow
general programs to traverse the model."

"	The model built by PASS1 is used by the analyzer (SYMANA), the
variable allocator (VARANA) and the code generator (CODGEN).  In some
cases the analyzers and generators for certain classes of SUBRs are 
together in their own files (e.g.  CARITH, STRUCT, ISTRUC)."

"	This the top level program for PASS1.  It takes a function as
input and returns the data structure representing the model."

<COND (<NOT ,MIM> <SETG PMAX ,NUMPRI!-MUDDLE>)>

<SETG MAX-DENSE 2>

<NEWTYPE ORQ LIST>

<COND (<NOT ,MIM> <FLOAD "PRCOD.NBIN">)>

<DEFINE PASS1 (FNAME FUNC
	       "AUX" RESULT (VARTBL ,LVARTBL) (DCL #DECL ()) (ARGL ())
		     (HATOM <>) (TT ()) (FCN .FUNC) TEM (RQRG 0) (TRG 0))
	#DECL ((FUNC) FUNCTION (VARTBL) <SPECIAL SYMTAB> (FNAME) <SPECIAL ATOM>
	       (FCN) <PRIMTYPE LIST> (ARGL TT) LIST (RESULT) <SPECIAL NODE>
	       (RQRG TRG) <SPECIAL FIX>)
	<COND (<EMPTY? .FCN> <COMPILE-ERROR "Empty function:  " .FNAME>)>
	<COND (<TYPE? <1 .FCN> ATOM ADECL>
	       <SET HATOM <1 .FCN>>
	       <SET FCN <REST .FCN>>)>
	<COND (<EMPTY? .FCN> <COMPILE-ERROR "Empty function:  " .FNAME>)>
	<SET ARGL <1 .FCN>>
	<SET FCN <REST .FCN>>
	<COND (<AND <NOT <EMPTY? .FCN>> <TYPE? <1 .FCN> DECL>>
	       <SET DCL <1 .FCN>>
	       <SET FCN <REST .FCN>>)>
	<COND (<EMPTY? .FCN> <COMPILE-ERROR "Function has no body:  " .FNAME>)>
	<SET RESULT
	     <NODEF ,FUNCTION-CODE () <FIND_DECL VALUE .DCL> .FNAME ()
		    () () .HATOM .VARTBL 0 0>>
	<GEN-D .ARGL .DCL .HATOM .RESULT>
	<PUTPROP .FNAME .IND .RESULT>
	<PUT .RESULT
	     ,RSUBR-DECLS
	     ("VALUE" <RESULT-TYPE .RESULT> !<RSUBR-DECLS .RESULT>)>
	<PUT .RESULT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .RESULT>> .FCN>>
	<ACT-FIX .RESULT <BINDING-STRUCTURE .RESULT>>
	<PUTPROP .FNAME .IND>
	<PUTPROP .FNAME RSUB-DEC <RSUBR-DECLS .RESULT>>
	.RESULT>

"Vector of legal strings in decl list."

<SETG TOT-MODES
      ["BIND"
       "CALL"
       "OPT"
       "OPTIONAL"
       "ARGS"
       "TUPLE"
       "AUX"
       "EXTRA"
       "ACT"
       "NAME"
       "DECL"
       "VALUE"]>

<PROG ((N <LENGTH ,TOT-MODES>))
      <MAPF <>
	    <FUNCTION (S "AUX" (ATM <PARSE <STRING "ACODE-" .S>>)) 
		    <SETG .ATM .N>
		    <MANIFEST .ATM>
		    <SET N <- .N 1>>>
	    ,TOT-MODES>
      <SET N <+ <LENGTH ,TOT-MODES> 1>>
      <MAPF <>
	    <FUNCTION (ATM) <SETG .ATM .N> <MANIFEST .ATM> <SET N <+ .N 1>>>
	    '[ACODE-INIT ACODE-INIT1 ACODE-ERR ACODE-NORM]>>

"Amount to rest off decl vector after each encounter."

<SETG RESTS ![1 1 1 2 1 2 1 2 1 2 1 1]>

"	This function (and others on this page) take an arg list and
decls and parses them.

	1) An RSUBR decl list.

	2) A machine readable binding specification.

Atoms are also entered into the symbol table."

<DEFINE GEN-D (ARGL DCL HATOM FCNNOD
	       "AUX" (SVTBL .VARTBL) (RES_TOP (())) (RES_BOT .RES_TOP) (ARGN 1)
		     (BNDL_TOP (())) (BNDL_BOT .BNDL_TOP) TIX VIX
		     (MODE ,TOT-MODES) (ST <>) T T1 SVT (IX ,ACODE-INIT))
	#DECL ((BNDL_BOT RES_BOT) <SPECIAL LIST> (BNDL_TOP RES_TOP) LIST
	       (ARGN) <SPECIAL FIX> (VIX) <VECTOR [REST STRING]>
	       (MODE) <SPECIAL <VECTOR [REST STRING]>> (IX) <SPECIAL FIX>
	       (ARGL) LIST (SVTBL SVT) SYMTAB (DCL) <SPECIAL <PRIMTYPE LIST>>)
	<REPEAT ()
		<COND (<EMPTY? .ARGL> <RETURN>)>
		<COND (<TYPE? <SET T <1 .ARGL>> ATOM FORM LIST ADECL>
		       <SET ST <>>
		       <RUN-ARGER .IX .T .FCNNOD>)
		      (<TYPE? .T STRING>
		       <COND (.ST
			      <COMPILE-ERROR "Two arg list strings in a row:  "
					     .ST
					     .T>)>
		       <SET ST .T>
		       <COND (<NOT <SET TIX <MEMBER .T .MODE>>>
			      <COMPILE-ERROR "Unrecognized arg list string:  "
					     .T>)>
		       <SET VIX .TIX>
		       <SET MODE
			    <REST .MODE <NTH ,RESTS <SET IX <LENGTH .VIX>>>>>
		       <COND (<NOT <OR <L? .IX 7> <G? .IX 11>>>
			      <PUT-RES (<COND (<=? <1 .ARGL> "OPT"> "OPTIONAL")
					      (ELSE <1 .ARGL>)>)>)>)
		      (ELSE
		       <COMPILE-ERROR "Unknown type of object in arglist "
				      .T>)>
		<SET ARGL <REST .ARGL>>>
	<COND (.HATOM <ACT-D .HATOM>)>
	<REPEAT (DC DC1)
		#DECL ((DC1) FORM (DC) ANY (VARTBL) <SPECIAL SYMTAB>)
		<COND (<EMPTY? .DCL> <RETURN>)
		      (<EMPTY? <REST .DCL>>
		       <COMPILE-ERROR "DECL in bad format (no DECL for):  "
				      <1 .DCL>>)>
		<SET DC <2 .DCL>>
		<COND (<AND <TYPE? .DC FORM>
			    <SET DC1 .DC>
			    <==? <LENGTH .DC1> 2>
			    <OR <==? <1 .DC1> SPECIAL>
				<==? <1 .DC1> UNSPECIAL>>>
		       <SET DC <2 .DC1>>)>
		<MAPF <>
		      <FUNCTION (ATM) 
			      <COND (<NOT <OR <==? .ATM VALUE>
					      <SRCH-SYM .ATM>>>
				     <ADDVAR .ATM T -1 0 T .DC <> <>>)>>
		      <CHTYPE <1 .DCL> LIST>>
		<SET DCL <REST .DCL 2>>>
	<SET SVT .VARTBL>
	<SET VARTBL .SVTBL>
	<COND (<N==? .SVTBL .SVT>
	       <REPEAT ((SV .SVT))
		       #DECL ((SV) SYMTAB)
		       <COND (<==? <NEXT-SYM .SV> .SVTBL>
			      <PUT .SV ,NEXT-SYM .VARTBL>
			      <SET VARTBL .SVT>
			      <RETURN>)
			     (ELSE <SET SV <NEXT-SYM .SV>>)>>)>
	<AND <L? <SET TRG <- .ARGN 1>> 0> <SET RQRG -1>>
	<PUT .FCNNOD ,BINDING-STRUCTURE <REST .BNDL_TOP>>
	<COND (<==? <NODE-TYPE .FCNNOD> ,FUNCTION-CODE>
	       <PUT <PUT <PUT .FCNNOD ,REQARGS .RQRG> ,TOTARGS .TRG>
		    ,RSUBR-DECLS
		    <REST .RES_TOP>>)>
	<PUT .FCNNOD ,SYMTAB .VARTBL>>

"RUN-ARGER dispatches to different arg handlers"

<DEFINE RUN-ARGER (INDX ARG N) 
	#DECL ((INDX) FIX)
	<CASE ,==?
	      .INDX
	      (,ACODE-BIND <BIND-D .ARG>)
	      (,ACODE-CALL <CALL-D .ARG>)
	      (,ACODE-OPT <OPT-D .ARG>)
	      (,ACODE-OPTIONAL <OPT-D .ARG>)
	      (,ACODE-ARGS <ARGS-D .ARG>)
	      (,ACODE-TUPLE <TUPL-D .ARG>)
	      (,ACODE-AUX <AUX-D .ARG>)
	      (,ACODE-EXTRA <AUX-D .ARG>)
	      (,ACODE-ACT <ACT-D .ARG>)
	      (,ACODE-NAME <ACT-D .ARG>)
	      (,ACODE-INIT <INIT-D .ARG>)
	      (,ACODE-INIT1 <INIT1-D .ARG>)
	      (,ACODE-NORM <NORM-D .ARG>)
	      (,ACODE-DECL <DECL-D .ARG>)
	      (,ACODE-VALUE <VDECL-D .ARG .N>)
	      (,ACODE-ERR <ERR-D .ARG>)>>

<DEFINE SRCH-SYM (ATM "AUX" (TB .VARTBL)) 
	#DECL ((ATM) ATOM (TB) <PRIMTYPE VECTOR>)
	<REPEAT ()
		<COND (<EMPTY? .TB> <RETURN <>>)>
		<COND (<==? .ATM <NAME-SYM .TB>> <RETURN .TB>)>
		<SET TB <NEXT-SYM .TB>>>>

"This function used for normal args when \"BIND\" and \"CALL\" still possible."

<DEFINE INIT-D (OBJ) 
	#DECL ((MODE) <VECTOR STRING>)
	<SET MODE <REST .MODE>>
	<INIT1-D .OBJ>>

"This function for normal args when \"CALL\" still possible."

<DEFINE INIT1-D (OBJ) 
	#DECL ((MODE) <VECTOR STRING>)
	<SET MODE <REST .MODE>>
	<SET IX ,ACODE-NORM>
	<NORM-D .OBJ>>

"Handle a normal argument or quoted normal argument."

<DEFINE NORM-D (OBJ "OPTIONAL" DC "AUX" DC1) 
	#DECL ((RQRG ARGN) FIX (DCL) DECL)
	<COND (<TYPE? .OBJ LIST>
	       <COMPILE-ERROR "LIST not in OPT(IONAL) or AUX:  " .OBJ>)>
	<COND (<TYPE? .OBJ ATOM>
	       <PUT-RES (<PUT-DCL ,ARGL-ARG
				  .OBJ
				  <>
				  <COND (<ASSIGNED? DC> .DC)
					(ELSE <FIND_DECL .OBJ .DCL>)>
				  T>)>)
	      (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <NORM-D <1 .OBJ> <2 .OBJ>>)
	      (<SET OBJ <QUOTCH .OBJ>>
	       <COND (<TYPE? .OBJ ADECL>
		      <COND (<N==? <LENGTH .OBJ> 2>
			     <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
		      <SET DC1 <2 .OBJ>>
		      <SET OBJ <1 .OBJ>>)>
	       <PUT-RES ("QUOTE"
			 <PUT-DCL ,ARGL-QUOTE
				  .OBJ
				  <>
				  <COND (<ASSIGNED? DC> .DC)
					(<ASSIGNED? DC1> .DC1)
					(ELSE <FIND_DECL .OBJ .DCL>)>
				  T>)>)>
	<COND (<NOT <ASSIGNED? DC>>
	       <SET ARGN <+ .ARGN 1>>
	       <SET RQRG <+ .RQRG 1>>)>>

"Handle \"BIND\" decl."

<DEFINE BIND-D (OBJ "AUX" DC) 
	#DECL ((TYP) ATOM (ARGN) FIX (DCL) DECL)
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET OBJ <1 .OBJ>>
	       <SET DC <2 .OBJ>>)>
	<COND (<NOT <TYPE? .OBJ ATOM>>
	       <COMPILE-ERROR "Bad object after \"BIND\":  " .OBJ>)>
	<SET DC
	     <PUT-DCL ,ARGL-BIND
		      .OBJ
		      <>
		      <COND (<ASSIGNED? DC> .DC) (ELSE <FIND_DECL .OBJ .DCL>)>
		      T>>
	<TYPE-ATOM-OK? .DC FRAME .OBJ>
	<SET IX ,ACODE-INIT1>>

"Handle \"CALL\" decl."

<DEFINE CALL-D (OBJ "AUX" DC) 
	#DECL ((TYP) ATOM (RQRG ARGN) FIX (DCL) DECL)
	<SET RQRG <+ .RQRG 1>>
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET DC <2 .OBJ>>
	       <SET OBJ <1 .OBJ>>)>
	<COND (<NOT <TYPE? .OBJ ATOM>>
	       <COMPILE-ERROR "Bad object after \"CALL\":  " .OBJ>)>
	<PUT-RES (<SET DC
		       <PUT-DCL ,ARGL-CALL
				.OBJ
				<>
				<COND (<ASSIGNED? DC> .DC)
				      (ELSE <FIND_DECL .OBJ .DCL>)>
				T>>)>
	<TYPE-ATOM-OK? .DC FORM .OBJ>
	<SET ARGN <+ .ARGN 1>>
	<SET IX ,ACODE-ERR>>

"Flush on extra atoms after \"CALL\", \"ARGS\" etc."

<DEFINE ERR-D (OBJ) <COMPILE-ERROR "Bad DECL syntax:  " .OBJ>>

"Handle \"OPTIONAL\" decl."

<DEFINE OPT-D (OBJ "AUX" DC OBJ1) 
	#DECL ((TYP) ATOM (ARGN) FIX (DCL) DECL)
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET DC <2 .OBJ>>
	       <SET OBJ <1 .OBJ>>)>
	<COND (<TYPE? .OBJ ATOM>
	       <PUT-RES (<PUT-DCL ,ARGL-OPT
				  .OBJ
				  <>
				  <COND (<ASSIGNED? DC> .DC)
					(ELSE <FIND_DECL .OBJ .DCL>)>
				  <>>)>)
	      (<TYPE? .OBJ FORM>
	       <SET OBJ <QUOTCH .OBJ>>
	       <COND (<TYPE? .OBJ ADECL>
		      <COND (<N==? <LENGTH .OBJ> 2>
			     <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
		      <SET DC <2 .OBJ>>
		      <SET OBJ <1 .OBJ>>)>
	       <PUT-RES ("QUOTE"
			 <PUT-DCL ,ARGL-QOPT
				  .OBJ
				  <>
				  <COND (<ASSIGNED? DC> .DC)
					(ELSE <FIND_DECL .OBJ .DCL>)>
				  <>>)>)
	      (<TYPE? <SET OBJ1 <LISTCH .OBJ>> ATOM ADECL>
	       <COND (<TYPE? .OBJ1 ADECL>
		      <COND (<N==? <LENGTH .OBJ1> 2>
			     <COMPILE-ERROR "Bad ADECL:  " .OBJ1>)>
		      <SET DC <2 .OBJ1>>
		      <SET OBJ1 <1 .OBJ1>>)>
	       <PUT-RES (<PAUX .OBJ1
			       <2 <CHTYPE .OBJ LIST>>
			       <COND (<ASSIGNED? DC> .DC)
				     (ELSE <FIND_DECL .OBJ1 .DCL>)>
			       ,ARGL-IOPT>)>)
	      (<TYPE? .OBJ1 FORM>
	       <SET OBJ1 <QUOTCH .OBJ1>>
	       <COND (<TYPE? .OBJ1 ADECL>
		      <COND (<N==? <LENGTH .OBJ1> 2>
			     <COMPILE-ERROR "Bad ADECL:  " .OBJ1>)>
		      <SET DC <2 .OBJ1>>
		      <SET OBJ1 <1 .OBJ1>>)>
	       <PUT-RES ("QUOTE"
			 <PAUX .OBJ1
			       <2 <CHTYPE .OBJ LIST>>
			       <COND (<ASSIGNED? DC> .DC)
				     (ELSE <FIND_DECL .OBJ1 .DCL>)>
			       ,ARGL-QIOPT>)>)
	      (ELSE <COMPILE-ERROR "Bad use of \"OPT(IONAL)\":  " .OBJ>)>
	<SET ARGN <+ .ARGN 1>>>

"Handle \"ARGS\" decl."

<DEFINE ARGS-D (OBJ "AUX" DC) 
	#DECL ((TYP) ATOM (RQRG ARGN) FIX (DCL) DECL (BNDL_BOT) <LIST SYMTAB>)
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET DC <2 .OBJ>>
	       <SET OBJ <1 .OBJ>>)>
	<COND (<NOT <TYPE? .OBJ ATOM>>
	       <COMPILE-ERROR "Bad use of \"ARGS\":  " .OBJ>)>
	<PUT-RES (<SET DC
		       <PUT-DCL ,ARGL-ARGS
				.OBJ
				<>
				<COND (<ASSIGNED? DC> .DC)
				      (ELSE <FIND_DECL .OBJ .DCL>)>
				<>>>)>
	<TYPE-ATOM-OK? .DC LIST .OBJ>
	<SET IX ,ACODE-ERR>
	<SET ARGN <+ .ARGN 1>>>

"Handle \"TUPLE\" decl."

<DEFINE TUPL-D (OBJ "AUX" DC) 
	#DECL ((TYP) ATOM (ARGN) FIX (DCL) DECL)
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET DC <2 .OBJ>>
	       <SET OBJ <1 .OBJ>>)>
	<COND (<NOT <TYPE? .OBJ ATOM>>
	       <COMPILE-ERROR "Bad use of \"TUPLE\":  " .OBJ>)>
	<PUT-RES (<SET DC
		       <PUT-DCL ,ARGL-TUPLE
				.OBJ
				<>
				<COND (<ASSIGNED? DC> .DC)
				      (ELSE <FIND_DECL .OBJ .DCL>)>
				<>>>)>
	<TYPE-ATOM-OK? .DC TUPLE .OBJ>
	<SET IX ,ACODE-ERR>>

"Handle \"AUX\" decl."

<DEFINE AUX-D (OBJ "AUX" DC OBJ1) 
	#DECL ((ARGN) FIX (DCL) DECL)
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET DC <2 .OBJ>>
	       <SET OBJ <1 .OBJ>>)>
	<COND (<TYPE? .OBJ ATOM>
	       <PUT-DCL ,ARGL-AUX
			.OBJ
			<>
			<COND (<ASSIGNED? DC> .DC)
			      (ELSE <FIND_DECL .OBJ .DCL>)>
			<>>)
	      (<AND <TYPE? .OBJ LIST> <TYPE? <SET OBJ1 <LISTCH .OBJ>> ADECL ATOM>>
	       <COND (<TYPE? .OBJ1 ADECL>
		      <COND (<N==? <LENGTH .OBJ1> 2>
			     <COMPILE-ERROR "Bad ADECL:  " .OBJ1>)>
		      <SET DC <2 .OBJ1>>
		      <SET OBJ1 <1 .OBJ1>>)>
	       <PAUX .OBJ1
		     <2 .OBJ>
		     <COND (<ASSIGNED? DC> .DC) (ELSE <FIND_DECL .OBJ1 .DCL>)>
		     ,ARGL-IAUX>)
	      (ELSE <COMPILE-ERROR "Bad usage of \"AUX\" :  " .OBJ>)>>

"Handle \"NAME\" and \"ACT\" decl."

<DEFINE ACT-D (OBJ "AUX" DC) 
	#DECL ((TYP) ATOM (ARGN) FIX (DCL) DECL)
	<COND (<TYPE? .OBJ ADECL>
	       <COND (<N==? <LENGTH .OBJ> 2>
		      <COMPILE-ERROR "Bad ADECL:  " .OBJ>)>
	       <SET DC <2 .OBJ>>
	       <SET OBJ <1 .OBJ>>)>
	<COND (<NOT <TYPE? .OBJ ATOM>>
	       <COMPILE-ERROR "Bad use of \"ACT\":  " .OBJ>)>
	<SET DC
	     <PUT-DCL ,ARGL-ACT
		      .OBJ
		      <>
		      <COND (<ASSIGNED? DC> .DC) (ELSE <FIND_DECL .OBJ .DCL>)>
		      <>>>
	<TYPE-ATOM-OK? .DC FRAME .OBJ>>

"Fixup activation atoms after node generated."

<DEFINE ACT-FIX (N L "AUX" (FLG <>)) 
	#DECL ((N) NODE (L) <LIST [REST SYMTAB]>)
	<REPEAT (SYM)
		#DECL ((SYM) SYMTAB)
		<COND (<EMPTY? .L> <RETURN .FLG>)>
		<COND (<AND <==? <CODE-SYM <SET SYM <1 .L>>> ,ARGL-ACT>
			    <SET FLG T>
			    <NOT <SPEC-SYM .SYM>>>
		       <PUT .SYM ,RET-AGAIN-ONLY .N>)>
		<SET L <REST .L>>>>

<DEFINE DECL-D (ARG)
	<COND (<TYPE? .ARG ADECL>
	       <COND (<NOT <SRCH-SYM <1 .ARG>>>
		      <ADDVAR <1 .ARG> T -1 0 T <2 .ARG> <> <>>)>)
	      (ELSE
	       <COMPILE-ERROR "DECL in bad format (no DECL for):  " .ARG>)>>

<DEFINE VDECL-D (ARG N)
	#DECL ((N) NODE)
	<PUT .N ,RESULT-TYPE .ARG>
	<PUT .N ,INIT-DECL-TYPE .ARG>>	        

<GDECL (TOT-MODES) <VECTOR [REST STRING]> (RESTS) <UVECTOR [REST FIX]>>

"Check for quoted arguments."

<DEFINE QUOTCH (OB) 
	#DECL ((OB) FORM (VALUE) <OR ATOM ADECL>)
	<COND (<AND <==? <LENGTH .OB> 2>
		    <==? <1 .OB> QUOTE>
		    <TYPE? <2 .OB> ATOM ADECL>>
	       <2 .OB>)
	      (ELSE <COMPILE-ERROR "Bad form in argument list" .OB> T)>>

"Chech for (arg init) or ('arg init)."

<DEFINE LISTCH (OB) 
	#DECL ((OB) LIST)
	<COND (<AND <==? <LENGTH .OB> 2>
		    <OR <TYPE? <1 .OB> ATOM ADECL>
			<AND <TYPE? <1 .OB> FORM> <QUOTCH <1 .OB>>>>>
	       <1 .OB>)
	      (ELSE <COMPILE-ERROR "Bad list in arg list:  " .OB> T)>>

"Add a decl to RSUBR decls and update AC call spec."

<DEFINE PUT-RES (L) 
	#DECL ((L) LIST (RES_BOT) LIST)
	<SET RES_BOT <REST <PUTREST .RES_BOT .L> <LENGTH .L>>>
	T>

"Add code to set up a certain kind of argument."

<DEFINE PUT-DCL (COD ATM VAL DC COM "AUX" SPC DC1 TT SYM) 
	#DECL ((DC1) FORM (ATM) ATOM (BNDL_BOT BNDL_TOP TT) LIST (COD) FIX
	       (SYM) SYMTAB)
	<COND (<AND <TYPE? .DC FORM>
		    <SET DC1 .DC>
		    <==? <LENGTH .DC1> 2>
		    <OR <SET SPC <==? <1 .DC1> SPECIAL>>
			<==? <1 .DC1> UNSPECIAL>>>
	       <SET DC <2 .DC1>>)
	      (ELSE <SET SPC .GLOSP>)>
	<SET SYM <ADDVAR .ATM .SPC .COD .ARGN T .DC <> .VAL>>
	<SET BNDL_BOT <REST <PUTREST .BNDL_BOT (.SYM)>>>
	.DC>

"Find decl associated with a variable, if none, use ANY."

<DEFINE FIND_DECL (ATM "OPTIONAL" (DC .DECLS)) 
	#DECL ((DC) <PRIMTYPE LIST> (ATM) ATOM)
	<REPEAT (TT)
		#DECL ((TT) LIST)
		<COND (<OR <EMPTY? .DC> <EMPTY? <SET TT <REST .DC>>>>
		       <RETURN ANY>)>
		<COND (<NOT <TYPE? <1 .DC> LIST>>
		       <COMPILE-ERROR "Malformed DECL:  " .DC>)>
		<COND (<MEMQ .ATM <CHTYPE <1 .DC> LIST>> <RETURN <1 .TT>>)>
		<SET DC <REST .TT>>>>

"Add an AUX variable spec to structure."

<SETG OBJ-BUILDERS
      '[VECTOR UVECTOR STRING BYTES ISTRING IBYTES IVECTOR IUVECTOR]>

<GDECL (OBJ-BUILDERS) <VECTOR [REST ATOM]>>

<DEFINE PAUX (ATM OBJ DC NTUP "AUX" EV TT AP OBJ2 AP2) 
	#DECL ((EV TT) NODE (TUP NTUP) FIX (ATM) ATOM)
	<COND (<PROG ((OBJ .OBJ))
		 <AND <TYPE? .OBJ FORM>
		      <NOT <EMPTY? .OBJ>>
		      <COND (<OR <AND <==? <SET AP <1 .OBJ>> STACK>
				      <==? <LENGTH .OBJ> 2>
				      <OR <AND <TYPE? <SET OBJ2 <2 .OBJ>> FORM>
					       <NOT <EMPTY? .OBJ2>>
					       <MEMQ <1 .OBJ2> ,OBJ-BUILDERS>>
					  <TYPE? .OBJ2 VECTOR UVECTOR>>>
				 <AND <==? .AP CHTYPE>
				      <==? <LENGTH .OBJ> 3>
				      <TYPE? <SET OBJ2 <2 .OBJ>> FORM>
				      <==? <LENGTH .OBJ2> 2>
				      <==? <1 .OBJ2> STACK>
				      <OR <AND <TYPE? <SET OBJ2 <2 .OBJ2>> FORM>
					       <NOT <EMPTY? .OBJ2>>
					       <MEMQ <1 .OBJ2> ,OBJ-BUILDERS>>
					  <TYPE? .OBJ2 VECTOR UVECTOR>>
				      <SET OBJ2 <CHTYPE (CHTYPE .OBJ2 <3 .OBJ>)
							FORM>>>>
			     <SET TT <NODEFM ,STACK-CODE () <> STACK () STACK>>
			     <PUT .TT ,KIDS (<PCOMP .OBJ2 .TT>)>)
			    (<==? .AP TUPLE>
			     <SET TT
				  <NODEFM ,COPY-CODE 
					  ()
					  TUPLE
					  .AP
					  ()
					  .AP>>
			     <PUT .TT
				  ,KIDS
				  <MAPF ,LIST
					<FUNCTION (O) <PCOMP .O .TT>>
					<REST .OBJ>>>)
			    (<==? .AP ITUPLE>
			     <PROG ((PARENT ()))
				   #DECL ((PARENT) <SPECIAL ANY>)
				   <SET TT
					<PSTRUC .OBJ ITUPLE ITUPLE TUPLE>>>)
			    (<AND <TYPE? .AP ATOM>
				  <GASSIGNED? .AP>
				  <TYPE? ,.AP MACRO>>
			     <SET OBJ <EXPAND .OBJ>>
			     <AGAIN>)>>>)
	      (ELSE <SET TT <PCOMP .OBJ ()>>)>
	<PUT-DCL .NTUP .ATM .TT .DC <>>>

"Main dispatch function during pass1."

<DEFINE PCOMP (OBJ PARENT) 
	#DECL ((PARENT) <SPECIAL ANY> (VALUE) NODE)
	<APPLY <OR <GETPROP .OBJ PTHIS-OBJECT>
		   <GETPROP <TYPE .OBJ> PTHIS-TYPE>
		   ,PDEFAULT>
	       .OBJ>>

"Build a node for <> or #FALSE ()."

<DEFINE FALSE-QT (O) 
	#DECL ((VALUE) NODE)
	<NODE1 ,QUOTE-CODE .PARENT BOOL-FALSE <> ()>>

<COND (<GASSIGNED? FALSE-QT> <PUTPROP '<> PTHIS-OBJECT ,FALSE-QT>)>

"Build a node for ()."

<DEFINE NIL-QT (O) #DECL ((VALUE) NODE) <NODE1 ,QUOTE-CODE .PARENT LIST () ()>>

<COND (<GASSIGNED? NIL-QT> <PUTPROP () PTHIS-OBJECT ,NIL-QT>)>

"Build a node for a LIST, VECTOR or UVECTOR."

<DEFINE PCOPY (OBJ
	       "AUX" (TT
		      <NODEFM ,COPY-CODE
			      .PARENT
			      <TYPE .OBJ>
			      <TYPE .OBJ>
			      ()
			      <>>))
	#DECL ((VALUE) NODE (TT) NODE)
	<PUT .TT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>> .OBJ>>>

<COND (<GASSIGNED? PCOPY>
       <PUTPROP VECTOR PTHIS-TYPE ,PCOPY>
       <PUTPROP UVECTOR PTHIS-TYPE ,PCOPY>
       <PUTPROP LIST PTHIS-TYPE ,PCOPY>)>

"Build a node for unknown things."

<DEFINE PDEFAULT (OBJ) 
	#DECL ((VALUE) NODE)
	<NODE1 ,QUOTE-CODE .PARENT <TYPE .OBJ> .OBJ ()>>

"Further analyze a FORM and build appropriate node."

<DEFINE PFORM (OBJ) 
	#DECL ((OBJ) <FORM ANY> (VALUE) NODE)
	<PROG APPLICATION ((APPLY <1 .OBJ>))
	      #DECL ((APPLICATION) <SPECIAL ANY> (APPLY) <SPECIAL ANY>)
	      <APPLY <OR <GETPROP .APPLY PAPPLY-OBJECT>
			 <AND <GETPROP .APPLY ANALYSIS> ,PSUBR-C>
			 <GETPROP <TYPE .APPLY> PAPPLY-TYPE>
			 ,PAPDEF>
		     .OBJ
		     .APPLY>>>

<COND (<GASSIGNED? PFORM> <PUTPROP FORM PTHIS-TYPE ,PFORM>)>

"Build a SEGMENT node."

<DEFINE SEG-FCN (OBJ "AUX" (TT <NODE1 ,SEGMENT-CODE .PARENT <> <> ()>)) 
	#DECL ((TT VALUE PARENT) NODE)
	<PROG ((PARENT .TT)) #DECL ((PARENT) <SPECIAL NODE>)
	      <PUT .TT ,KIDS (<PFORM <CHTYPE .OBJ FORM>>)>>>

<COND (<GASSIGNED? SEG-FCN> <PUTPROP SEGMENT PTHIS-TYPE ,SEG-FCN>)>

"Analyze a form or the form <ATM .....>"

<DEFINE ATOM-FCN (OB AP:ATOM "AUX" L:<PRIMTYPE LIST>) 
	#DECL ((AP) ATOM (VALUE) NODE)
	<COND (<GASSIGNED? .AP> <SET APPLY ,.AP> <AGAIN .APPLICATION>)
	      (.REASONABLE
	       <COND (<NOT <GASSIGNED? REFERENCED>>
		      <SETG REFERENCED (.AP 1)>)
		     (<NOT <SET L <MEMQ .AP ,REFERENCED:LIST>>>
		      <SETG REFERENCED (.AP 1 !,REFERENCED)>)
		     (T
		      <2 .L <+ <2 .L>:FIX 1>>)>
	       <PSUBR-C .OB DUMMY>)
	      (ELSE
	       <COMPILE-WARNING "No value for:  " .AP " using EVAL">
	       <PAPDEF .OB .AP>)>>

<COND (<GASSIGNED? ATOM-FCN> <PUTPROP ATOM PAPPLY-TYPE ,ATOM-FCN>)>

"Expand MACRO and process result."

<NEWTYPE FUNNY VECTOR>

<DEFINE PMACRO (OBJ AP "AUX" ERR TEM) 
	<ON <SET ERR <HANDLER "ERROR" ,MACROERR 100>>>	   ;"Turn On new Error"
	<SET TEM
	     <PROG MACACT ()
		   #DECL ((MACACT) <SPECIAL ANY>)
		   <SETG ERR .ERR>
		   <SETG MACACT .MACACT>
		   <EXPAND .OBJ>>>
	<OFF .ERR>					  ;"Turn OFF new Error"
	<COND (<TYPE? .TEM FUNNY>
	       <COMPILE-ERROR "ERROR during macro expansion" ,CR !.TEM>)
	      (ELSE <PCOMP .TEM .PARENT>)>>

<COND (<GASSIGNED? PMACRO> <PUTPROP MACRO PAPPLY-TYPE ,PMACRO>)>

<DEFINE MACROERR (IGN FR "TUPLE" T) 
	#DECL ((T) TUPLE)
	<COND (<AND <NOT <EMPTY? .T>> <==? <1 .T> CONTROL-G!-ERRORS>>
	       <INT-LEVEL 0>
	       <OFF ,ERR>
	       <ERROR !.T>
	       <ON ,ERR>
	       <ERRET T .FR>)
	      (<AND <GASSIGNED? MACACT> <LEGAL? ,MACACT>>
	       <DISMISS <CHTYPE [!.T] FUNNY> ,MACACT>)
	      (ELSE
	       <OFF ,ERR>
	       <ERROR INTERNAL-COMPILER-LOSSAGE!-ERRORS>)>>

"Build a node for a form whose 1st element is a form (could be NTH)."

<DEFINE PFORM-FORM (OBJ AP "AUX" TT) 
	#DECL ((TT) NODE (VALUE) NODE (OBJ) FORM)
	<COND (<AND <==? <LENGTH .OBJ> 2> <NOT <SEG? .OBJ>>>
	       <SET TT <NODEFM ,FORM-F-CODE .PARENT <> .OBJ () .AP>>
	       <PUT .TT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>> .OBJ>>)
	      (ELSE <PAPDEF .OBJ .AP>)>>

<COND (<GASSIGNED? PFORM-FORM> <PUTPROP FORM PAPPLY-TYPE ,PFORM-FORM>)>

"Build a node for strange forms."

<DEFINE PAPDEF (OBJ AP) 
	#DECL ((VALUE) NODE)
	<COMPILE-WARNING "Form not being compiled:  " .OBJ>
	<SPECIALIZE .OBJ>
	<NODEFM ,FORM-CODE .PARENT <> .OBJ () .AP>>

"For objects that require EVAL, make sure all atoms used are special."

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
		      <COMPILE-NOTE "Redclared special:  " .SYM>
		      <PUT .T2 ,SPEC-SYM T>)>)>
	<COND (<MEMQ <PRIMTYPE .OBJ> '[FORM LIST UVECTOR VECTOR]>
	       <MAPF <> ,SPECIALIZE .OBJ>)>>

"Build a MSUBR call node."

<DEFINE PSUBR-C (OBJ AP
		 "AUX" (TT
			<NODEFM ,SUBR-CODE
				.PARENT
				<>
				<COND (<TYPE? .AP MSUBR> <2 .AP>)
				      (ELSE <1 .OBJ>)>
				()
				.AP>))
	#DECL ((TT) NODE (VALUE) NODE (OBJ) FORM)
	<PUT .TT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>> <REST .OBJ>>>>

<DEFINE LVAL-FCN (OBJ "AUX" (TT <NODEFM ,SUBR-CODE .PARENT <> LVAL () ,LVAL>))
	#DECL ((TT VALUE) NODE)
	<PUT .TT ,KIDS (<PCOMP <CHTYPE .OBJ ATOM> .TT>)>>

<DEFINE GVAL-FCN (OBJ "AUX" (TT <NODEFM ,SUBR-CODE .PARENT <> GVAL () ,GVAL>))
	#DECL ((TT VALUE) NODE)
	<PUT .TT ,KIDS (<PCOMP <CHTYPE .OBJ ATOM> .TT>)>>

<COND (<GASSIGNED? LVAL-FCN>
       <PUTPROP LVAL PTHIS-TYPE ,LVAL-FCN>
       <PUTPROP GVAL PTHIS-TYPE ,GVAL-FCN>)>

<DEFINE FIX-FCN (OBJ AP "AUX" TT (LN <LENGTH .OBJ>)) 
	#DECL ((TT VALUE) NODE (OBJ) FORM)
	<COND (<NOT <OR <==? .LN 2> <==? .LN 3>>>
	       <COMPILE-ERROR 
"Number (FIX) applied to other than 2 or 3 args:  "
			      .OBJ>)>
	<SET TT
	     <NODEFM ,SUBR-CODE
		     .PARENT
		     <>
		     <COND (<==? .LN 2> INTH) (ELSE IPUT)>
		     ()
		     <COND (<==? .LN 2> ,NTH) (ELSE ,PUT)>>>
	<PUT .TT
	     ,KIDS
	     (<PCOMP <2 .OBJ> .TT>
	      <PCOMP .AP .TT>
	      !<COND (<==? .LN 2> ()) (ELSE (<PCOMP <3 .OBJ> .TT>))>)>>

<COND (<GASSIGNED? FIX-FCN>
       <PUTPROP FIX PAPPLY-TYPE ,FIX-FCN>
       <PUTPROP OFFSET PAPPLY-TYPE ,FIX-FCN>)>

"PROG/REPEAT node."

<DEFINE PPROG-REPEAT (OBJ AP
		      "AUX" (NAME <1 .OBJ>) TT (DCL #DECL ()) (HATOM <>) ARGL
			    (VARTBL .VARTBL)
			    (IN-IFSYS <COND (<ASSIGNED? IN-IFSYS> .IN-IFSYS)>))
	#DECL ((OBJ) <PRIMTYPE LIST> (TT) NODE (VALUE) NODE (DCL) DECL
	       (ARGL) LIST (VARTBL) <SPECIAL SYMTAB> (IN-IFSYS) <SPECIAL ANY>)
	<COND (<EMPTY? <SET OBJ <REST .OBJ>>>
	       <COMPILE-ERROR "Empty " .NAME " " .OBJ>)>
	<COND (<TYPE? <1 .OBJ> ATOM ADECL>
	       <SET HATOM <1 .OBJ>>
	       <SET OBJ <REST .OBJ>>)>
	<SET ARGL <1 .OBJ>>
	<SET OBJ <REST .OBJ>>
	<COND (<AND <NOT <EMPTY? .OBJ>> <TYPE? <1 .OBJ> DECL>>
	       <SET DCL <1 .OBJ>>
	       <SET OBJ <REST .OBJ>>)>
	<COND (<EMPTY? .OBJ> <COMPILE-ERROR "Empty body for " .NAME .OBJ>)>
	<SET TT
	     <NODEPR ,PROG-CODE
		     .PARENT
		     <FIND_DECL VALUE .DCL>
		     .NAME
		     ()
		     .AP
		     ()
		     .HATOM
		     .VARTBL>>
	<GEN-D <COND (<AND <NOT <EMPTY? .ARGL>> <TYPE? <1 .ARGL> STRING>>
		      .ARGL)
		     (ELSE ("AUX" !.ARGL))>
	       .DCL
	       .HATOM
	       .TT>
	<ACT-FIX .TT <BINDING-STRUCTURE .TT>>
	<PUT .TT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>> .OBJ>>
	.TT>

<COND (<GASSIGNED? PPROG-REPEAT>
       <PUTPROP ,PROG PAPPLY-OBJECT ,PPROG-REPEAT>
       <PUTPROP ,REPEAT PAPPLY-OBJECT ,PPROG-REPEAT>
       <PUTPROP ,BIND PAPPLY-OBJECT ,PPROG-REPEAT>)>

"Unwind compiler."

<DEFINE UNWIND-FCN (OBJ AP
		    "AUX" (TT
			   <NODEFM ,UNWIND-CODE .PARENT <> <1 .OBJ> () .AP>))
	#DECL ((PARENT VALUE TT) NODE (OBJ) FORM)
	<COND (<==? <LENGTH .OBJ> 3>
	       <PUT .TT ,KIDS (<PCOMP <2 .OBJ> .TT> <PCOMP <3 .OBJ> .TT>)>)
	      (ELSE <COMPILE-ERROR "Wrong number of args to UNIWND: " .OBJ>)>>

<COND (<AND <GASSIGNED? UNWIND-FCN> <GASSIGNED? UNWIND>>
       <PUTPROP ,UNWIND PAPPLY-OBJECT ,UNWIND-FCN>)>

"Build a node for a COND."

<DEFINE COND-FCN (OBJ AP
		  "AUX" (PARENT <NODECOND ,COND-CODE .PARENT <> COND ()>))
   #DECL ((PARENT) <SPECIAL NODE> (OBJ) <FORM ANY> (VALUE) NODE)
   <PUT .PARENT
	,KIDS
	<MAPF ,LIST
	      <FUNCTION (CLA "AUX" (TT <NODEB ,BRANCH-CODE .PARENT <> <> ()>)) 
		      #DECL ((TT) NODE)
		      <COND (<AND <TYPE? .CLA LIST> <NOT <EMPTY? .CLA>>>
			     <PUT .TT ,PREDIC <PCOMP <1 .CLA> .TT>>
			     <PUT .TT
				  ,CLAUSES
				  <MAPF ,LIST
					<FUNCTION (O) <PCOMP .O .TT>>
					<REST .CLA>>>)
			    (ELSE
			     <COMPILE-ERROR 
"COND clause not a LIST or empty:  "
					    .OBJ>)>>
	      <REST .OBJ>>>>

<COND (<GASSIGNED? COND-FCN>
       <PUTPROP ,COND PAPPLY-OBJECT ,COND-FCN>
       <PUTPROP ,AND PAPPLY-OBJECT ,PSUBR-C>
       <PUTPROP ,OR PAPPLY-OBJECT ,PSUBR-C>)>

"Build a node for '<-object>-."

<DEFINE QUOTE-FCN (OBJ AP "AUX" (TT <NODE1 ,QUOTE-CODE .PARENT <> () ()>)) 
	#DECL ((TT VALUE) NODE (OBJ) FORM)
	<COND (<NOT <EMPTY? <REST .OBJ>>>
	       <PUT .TT ,RESULT-TYPE <COND (<==? <2 .OBJ> #FALSE()>
					    BOOL-FALSE)
					   (ELSE <TYPE <2 .OBJ>>)>>
	       <PUT .TT ,NODE-NAME <2 .OBJ>>)>>

<COND (<GASSIGNED? QUOTE-FCN> <PUTPROP ,QUOTE PAPPLY-OBJECT ,QUOTE-FCN>)>

"Build a node for a call to an RSUBR."

<DEFINE RSUBR-FCN (OBJ AP
		   "AUX" (PARENT
			  <NODEFM ,RSUBR-CODE .PARENT <> <1 .OBJ> () .AP>))
	#DECL ((OBJ) FORM (AP) MSUBR (PARENT) <SPECIAL NODE>
	       (VALUE) NODE)
	<COND (<AND <G? <LENGTH .AP> 2> <TYPE? <3 .AP> DECL LIST>>
	       <PUT .PARENT ,KIDS <PRSUBR-C <1 .OBJ> .OBJ <3 .AP>>>
	       <PUT .PARENT ,TYPE-INFO <SANITIZE-DECL <3 .AP>>>)
	      (ELSE <PSUBR-C .OBJ .AP>)>>

<COND (<GASSIGNED? RSUBR-FCN> <PUTPROP MSUBR PAPPLY-TYPE ,RSUBR-FCN>)>

<DEFINE SANITIZE-DECL (DCL:LIST "AUX" (OPT <>) (TUPF <>))
	<COND (<=? <1 .DCL> "VALUE"> <SET DCL <REST .DCL 2>>)>
	<MAPF ,LIST <FUNCTION (EL)
			 <COND (<OR <=? .EL "QUOTE"> <=? .EL "ARGS">> <MAPRET>)
			       (<OR <=? .EL "OPT"> <=? .EL "OPTIONAL">>
				<SET OPT T>
				<MAPRET>)
			       (<=? .EL "TUPLE"> <SET TUPF T> <MAPRET>)>
			 <COND (.TUPF (TUPLE .EL))
			       (.OPT (OPTIONAL .EL))
			       (ELSE (NORMAL .EL))>>
	      .DCL>>

"Predicate:  any segments in this object?"

<DEFINE SEG? (OB) 
	#DECL ((OB) <PRIMTYPE LIST>)
	<REPEAT ()
		<COND (<EMPTY? .OB> <RETURN <>>)>
		<COND (<TYPE? <1 .OB> SEGMENT> <RETURN T>)>
		<SET OB <REST .OB>>>>

"Analyze a call to an MSUBR with decls checking number of args and types wherever
 possible."

<DEFINE PRSUBR-C RSB
	         (NAME OBJ RDCL
		  "AUX" (DOIT ,INIT-R) (SEGSW <>) (SGD '<>) (SGP '(1)) SGN
			(IX 0) DC (RM ,RMODES) (ARG-NUMBER 0) (KDS (()))
			(TKDS .KDS) RMT (OB <REST .OBJ>) (ST <>) (ODC "FOO"))
   #DECL ((TKDS KDS) <SPECIAL LIST> (OB) LIST (OBJ) <SPECIAL <PRIMTYPE LIST>>
	  (RM) <SPECIAL <VECTOR [REST STRING]>> (ARG-NUMBER) FIX
	  (RDCL) <SPECIAL <PRIMTYPE LIST>> (DOIT SEGSW) <SPECIAL ANY> (IX) FIX
	  (RSB NAME) <SPECIAL ANY> (SGD) FORM (SGP) <LIST ANY> (SGN) NODE)
   <REPEAT ()
     <COND
      (<NOT <EMPTY? .RDCL>>
       <COND (<NOT <EMPTY? .RM>> <SET DC <1 .RDCL>> <SET RDCL <REST .RDCL>>)>
       <COND
	(<TYPE? .DC STRING>
	 <COND (<=? .DC "OPT"> <SET DC "OPTIONAL">)>
	 <COND (<NOT <SET RMT <MEMBER .DC .RM>>>
		<COMPILE-ERROR "Unknown string in MSUBR decl: "
			       .DC
			       " "
			       .NAME>)>
	 <SET RM .RMT>
	 <SET DOIT <NTH ,RDOIT <SET IX <LENGTH .RM>>>>
	 <SET ST <APPLY <NTH ,SDOIT .IX> .ST .DC .ODC>>
	 <SET ODC .DC>
	 <COND (<EMPTY? .RM>					 ;"TUPLE seen."
		<SET DC <GET-ELE-TYPE <1 .RDCL> ALL>>)>)
	(<COND
	  (<EMPTY? .OB>
	   <AND <L? <LENGTH .RM> 4> <RETURN <REST .TKDS>>>
	   <COMPILE-ERROR "Too few arguments to:  " .NAME " " .OBJ>)
	  (.SEGSW
	   <SET ST <>>
	   <COND (<EMPTY? .RM>
		  <PUTREST .SGP ([REST .DC])>
		  <PUT .SGN ,RESULT-TYPE <TYPE-AND <RESULT-TYPE .SGN> .SGD>>
		  <RETURN <REST .TKDS>>)
		 (ELSE <SET SGP <REST <PUTREST .SGP (.DC)>>>)>)
	  (<TYPE? <1 .OB> SEGMENT>
	   <SET KDS <REST <PUTREST .KDS (<SET SGN <SEGCHK <1 .OB>>>)>>>
	   <COND
	    (<EMPTY? <REST .OB>>
	     <COND (<EMPTY? .RM>
		    <PUT .SGN
			 ,RESULT-TYPE
			 <SEGCH1 .DC <RESULT-TYPE .SGN> <1 .OB>>>
		    <RETURN <REST .TKDS>>)
		   (ELSE <SET SEGSW T>)>)
	    (ELSE
	     <PUTREST
	      .KDS
	      <MAPF ,LIST
	       <FUNCTION (O "AUX" TT) 
		  <SET TT <PCOMP .O .PARENT>>
		  <COND
		   (<EMPTY? .RM>
		    <COND
		     (<==? <NODE-TYPE .TT> ,SEGMENT-CODE>
		      <COND
		       (<NOT <TYPE-OK? <RESULT-TYPE <1 <KIDS .TT>>>
				       <FORM '<OR MULTI STRUCTURED> [REST .DC]>>>
			<COMPILE-ERROR "Argument wrong type to:  "
				       .NAME
				       .OB>)>)
		     (ELSE
		      <COND (<NOT <TYPE-OK? <RESULT-TYPE .TT> .DC>>
			     <COMPILE-ERROR "Argument wrong type to:  "
					    .NAME
					    .OB>)>
		      <COND (<NOT <RESULT-TYPE .TT>>
			     <PUT .TT ,RESULT-TYPE .DC>)>)>)>
		  .TT>
	       <REST .OB>>>
	     <RETURN <REST .TKDS>>)>
	   <SET SGP <REST <CHTYPE <SET SGD <FORM STRUCTURED .DC>> LIST>>>
	   <SET ST <>>
	   <AGAIN>)
	  (<SET KDS <REST <PUTREST .KDS (<APPLY .DOIT .DC .OB>)>>>
	   <SET OB <REST .OB>>
	   <SET ARG-NUMBER <+ .ARG-NUMBER 1>>
	   <SET ST <>>)>)>)
      (<EMPTY? .OB> <RETURN <REST .TKDS>>)
      (.SEGSW
       <PUT .SGN
	    ,RESULT-TYPE
	    <COND (<RESULT-TYPE .SGN> <TYPE-AND <RESULT-TYPE .SGN> .SGD>)
		  (ELSE .SGD)>>
       <RETURN <REST .TKDS>>)
      (<MAPF <>
	     <FUNCTION (X) <COND (<NOT <TYPE? .X SEGMENT>> <MAPLEAVE <>>)> T>
	     .OB>
       <SET KDS <REST <PUTREST .KDS (<SET SGN <SEGCHK <1 .OB>>>)>>>
       <RETURN <REST .TKDS>>) 
      (ELSE <COMPILE-ERROR "Too many arguments too: " .NAME " " .OBJ>)>>>

<DEFINE SQUOT (F S1 S2) T>

"Flush one possible decl away."

<DEFINE CHOPPER (F S1 S2) 
	#DECL ((RM) <VECTOR [REST STRING]>)
	<COND (.F
	       <COMPILE-ERROR "Two DECL strings in a row in:  " .S1 " " .S2>)>
	<SET RM <REST .RM>>
	T>

"Handle Normal arg when \"VALUE\" still possible."

<DEFINE INIT-R (DC OB) 
	#DECL ((RM) <VECTOR [REST STRING]>)
	<SET RM <REST .RM 2>>
	<SET DOIT ,INIT1-R>
	<INIT1-R .DC .OB>>

"Handle Normal arg when \"CALL\" still possible."

<DEFINE INIT2-R (DC OB) 
	#DECL ((RM) <VECTOR [REST STRING]>)
	<SET RM <REST .RM>>
	<SET DOIT ,INIT1-R>
	<INIT1-R .DC .OB>>

"Handle normal arg."

<DEFINE INIT1-R (DC OB "AUX" TT) 
	#DECL ((TT) NODE (OB) LIST)
	<COND (<NOT <TYPE-OK? <RESULT-TYPE <SET TT <PCOMP <1 .OB> .PARENT>>>
			      .DC>>
	       <COMPILE-ERROR "Argument wrong type to:  " .NAME " " <1 .OB>>)>
	<COND (<NOT <RESULT-TYPE .TT>> <PUT .TT ,RESULT-TYPE .DC>)>
	.TT>

"Handle \"QUOTE\" arg."

<DEFINE QINIT-R (DC OB "AUX" TT) 
	#DECL ((TT) NODE (OB) LIST)
	<COND (<NOT <TYPE-OK?
		     <RESULT-TYPE <SET TT
				       <NODE1 ,QUOTE-CODE
					      .PARENT
					      <TYPE <1 .OB>>
					      <1 .OB>
					      ()>>>
		     .DC>>
	       <COMPILE-ERROR "Argument wrong type to:  " .NAME " " <1 .OB>>)>
	<SET DOIT ,INIT1-R>
	.TT>

"Handle \"CALL\" decl."

<DEFINE CAL-R (DC OB "AUX" TT) 
	#DECL ((TKDS KDS) LIST (TT) NODE)
	<COND (<NOT <TYPE-OK?
		     <RESULT-TYPE <SET TT
				       <NODE1 ,QUOTE-CODE
					      .PARENT
					      FORM
					      .OBJ
					      ()>>>
		     .DC>>
	       <COMPILE-ERROR "Argument wrong type to:  " .NAME " " <1 .OB>>)>
	<PUTREST .KDS (.TT)>
	<RETURN <REST .TKDS> .RSB>>

"Handle \"ARGS\" decl."

<DEFINE ARGS-R (DC OB "AUX" TT) 
	#DECL ((TT) NODE (KDS TKDS) LIST)
	<COND (<NOT <TYPE-OK?
		     <RESULT-TYPE <SET TT
				       <NODE1 ,QUOTE-CODE
					      .PARENT
					      LIST
					      .OB
					      ()>>>
		     .DC>>
	       <COMPILE-ERROR "Argument wrong type to:  " .NAME " " <1 .OB>>)>
	<PUTREST .KDS (.TT)>
	<RETURN <REST .TKDS> .RSB>>

"Handle \"TUPLE\" decl."

<DEFINE TUPL-R (DC OB "AUX" TT) 
	#DECL ((OB) LIST (TT) NODE)
	<COND (<NOT <TYPE-OK? <RESULT-TYPE <SET TT <PCOMP <1 .OB> .PARENT>>>
			      .DC>>
	       <COMPILE-ERROR "Argument wrong type to:  " .NAME " " <1 .OB>>)>
	<COND (<NOT <RESULT-TYPE .TT>> <PUT .TT ,RESULT-TYPE .DC>)>
	.TT>

"Handle stuff with segments in arguments."

<DEFINE SEGCHK (OB "AUX" TT) 
	#DECL ((TT) NODE)
	<COND (<NOT <TYPE-OK? <RESULT-TYPE <SET TT <PCOMP .OB .PARENT>>>
			      '<OR MULTI STRUCTURED>>>
	       <COMPILE-ERROR "Non-structured segment?  " .OB>)>
	.TT>

<DEFINE SEGCH1 (DC RT OB) 
	<COND (<NOT <TYPE-AND .RT <FORM '<OR MULTI STRUCTURED> [REST .DC]>>>
	       <COMPILE-ERROR "Argument wrong type to:  " .NAME " " .OB>)>>

"Handle \"VALUE\" chop decl and do the rest."

<DEFINE VAL-R (F S1 S2) 
	#DECL ((RDCL) <PRIMTYPE LIST> (PARENT) NODE)
	<CHOPPER .F .S1 .S2>
	<PUT .PARENT ,RESULT-TYPE <1 .RDCL>>
	<SET DOIT ,INIT2-R>
	<SET F <TYPE? <1 .RDCL> STRING>>
	<SET RDCL <REST .RDCL>>
	.F>

<DEFINE ERR-R (DC OB) 
	<COMPILE-LOSSAGE "Entered MSUBR application illegal state" .DC .OB>>

<SETG RMODES ["VALUE" "CALL" "QUOTE" "OPTIONAL" "QUOTE" "ARGS" "TUPLE"]>

<COND (<GASSIGNED? TUPL-R>
       <SETG RDOIT [,TUPL-R ,ARGS-R ,QINIT-R ,INIT1-R ,QINIT-R ,CAL-R ,ERR-R]>
       <SETG SDOIT
	     [,CHOPPER ,CHOPPER ,SQUOT ,CHOPPER ,SQUOT ,CHOPPER ,VAL-R]>)>

<GDECL (RMODES) <VECTOR [REST STRING]> (RDOIT SDOIT) VECTOR>

"Create a node for a call to a function."

<DEFINE PFUNC (OB AP "AUX" TEM NAME) 
	#DECL ((OB) <PRIMTYPE LIST> (VALUE) NODE)
	<COND (<TYPE? <1 .OB> ATOM>
	       <COND (<==? <1 .OB> .FNAME> <RSUBR-CALL2 ,<1 .OB> <1 .OB> .OB>)
		     (<SET TEM <GETPROP <1 .OB> RSUB-DEC>>
		      <RSUBR-CALL3 .TEM <1 .OB> .OB>)
		     (.REASONABLE <PSUBR-C .OB DUMMY>)
		     (ELSE
		      <COMPILE-WARNING "Uncompiled function called:  "
					<1 .OB>>
		      <PAPDEF .OB ,<1 .OB>>)>)
	      (<TYPE? <1 .OB> FUNCTION>
	       <SET NAME <MAKE-TAG <STRING "ANONF" <SPNAME .FNAME>>>>
	       <ANONF .NAME <1 .OB>>
	       <RSUBR-CALL1 ,.NAME .NAME .OB>)>>

"Call compiler recursively to compile anonymous function."

<DEFINE ANONF (NAME BODY "AUX" (INT? <>) T GROUP-NAME) 
	#DECL ((EXTRA-CODE) <LIST ANY> (VALUE) NODE)
	<COMPILE-NOTE "Compiling anonymous function">
	<SETG .NAME .BODY>
	<PUTREST .EXTRA-CODE <APPLY ,COMPILE .NAME>>
	<SET EXTRA-CODE <REST .EXTRA-CODE <- <LENGTH .EXTRA-CODE> 1>>>
	<GUNASSIGN .NAME>
	<COMPILE-NOTE "Finished anonymous function">
	<PCOMP <FORM GVAL .NAME> .PARENT>>

"#FUNCTION (....) compiler -- call ANONF."

<DEFINE FCN-FCN (OB "AUX" (NAME <MAKE-TAG <STRING "ANONF" <SPNAME .FNAME>>>)) 
	<ANONF .NAME .OB>>

<COND (<GASSIGNED? FCN-FCN>
       <PUTPROP FUNCTION PTHIS-TYPE ,FCN-FCN>
       <PUTPROP FUNCTION PAPPLY-TYPE ,PFUNC>)>

"<FUNCTION (..) ....> compiler -- call ANONF."

<DEFINE FCN-FCN1 (OB AP "AUX"
		        (NAME <MAKE-TAG <STRING "ANONF" <SPNAME .FNAME>>>)) 
	#DECL ((OB) <PRIMTYPE LIST>)
	<ANONF .NAME <CHTYPE <REST .OB> FUNCTION>>>

<COND (<GASSIGNED? FCN-FCN1> <PUTPROP ,FUNCTION PAPPLY-OBJECT ,FCN-FCN1>)>

"Handle RSUBR that is really a function."

<DEFINE RSUBR-CALL2 (BODY NAME OBJ
		     "AUX" ACF DCL
			   (PARENT
			    <NODEFM ,RSUBR-CODE .PARENT <> .NAME () .BODY>))
	#DECL ((PARENT) <SPECIAL NODE> (VALUE) NODE)
	<PUT .PARENT
	     ,KIDS
	     <PRSUBR-C .NAME
		       .OBJ
		       <SET DCL <RSUBR-DECLS <SET ACF <GETPROP .NAME .IND>>>>>>
	<PUT .PARENT ,TYPE-INFO <SANITIZE-DECL .DCL>>>

"Handle an RSUBR that is already an RSUBR."

<DEFINE RSUBR-CALL1 (BODY NAME OBJ
		     "AUX" (PARENT
			    <NODEFM ,RSUBR-CODE .PARENT <> .NAME () .BODY>))
	#DECL ((BODY) <PRIMTYPE LIST> (PARENT) <SPECIAL NODE> (VALUE) NODE)
	<PUT .PARENT ,KIDS <PRSUBR-C .NAME .OBJ <3 .BODY>>>
	<PUT .PARENT ,TYPE-INFO <SANITIZE-DECL <2 .BODY>>>>

<DEFINE RSUBR-CALL3 (DC NAME OBJ
		     "AUX" (PARENT
			    <NODEFM ,RSUBR-CODE .PARENT <> .NAME () FOO>))
	#DECL ((PARENT) <SPECIAL NODE> (VALUE) NODE)
	<PUT .PARENT ,KIDS <PRSUBR-C .NAME .OBJ .DC>>
	<PUT .PARENT ,TYPE-INFO <SANITIZE-DECL .DC>>>

;"ILIST, ISTRING, IVECTOR AND IUVECTOR"

<DEFINE PLIST (O A) <PSTRUC .O .A ILIST LIST>>

<DEFINE PIVECTOR (O A) <PSTRUC .O .A IVECTOR VECTOR>>

<DEFINE PISTRING (O A) <PSTRUC .O .A ISTRING STRING>>

<DEFINE PIUVECTOR (O A) <PSTRUC .O .A IUVECTOR UVECTOR>>

<DEFINE PIFORM (O A) <PSTRUC .O .A IFORM FORM>>

<DEFINE PIBYTES (O A) <PSTRUC .O .A IBYTES BYTES>>

<COND (<GASSIGNED? PLIST>
       <PUTPROP ,ILIST PAPPLY-OBJECT ,PLIST>
       <PUTPROP ,IUVECTOR PAPPLY-OBJECT ,PIUVECTOR>
       <COND (<NOT ,MIM> <PUTPROP ,IFORM PAPPLY-OBJECT ,PIFORM>)>
       <PUTPROP ,IBYTES PAPPLY-OBJECT ,PIBYTES>
       <PUTPROP ,IVECTOR PAPPLY-OBJECT ,PIVECTOR>
       <PUTPROP ,ISTRING PAPPLY-OBJECT ,PISTRING>)>

<DEFINE PSTRUC (OBJ AP NAME TYP
		"AUX" (TT <NODEFM ,ISTRUC-CODE .PARENT .TYP .NAME () ,.NAME>)
		      (LN <LENGTH .OBJ>) N EV SIZ)
	#DECL ((VALUE N EV TT) NODE (LN) FIX (OBJ) <PRIMTYPE LIST>)
	<COND (<SEG? .OBJ> <RSUBR-FCN .OBJ .AP>)
	      (ELSE
	       <COND (<==? .LN 1>
		      <COMPILE-ERROR "Too few args: " <1 .OBJ>>)
		     (<G? .LN 3> <COMPILE-ERROR "Too many args: "
						<1 .OBJ>>)>
	       <SET N <PCOMP <2 .OBJ> .TT>>
	       <COND (<==? .LN 3>
		      <SET EV <PCOMP <3 .OBJ> .PARENT>>
		      <COND (<==? <NODE-TYPE .EV> ,QUOTE-CODE>
			     <SET EV <PCOMP <NODE-NAME .EV> .TT>>
			     <PUT .TT ,NODE-TYPE ,ISTRUC2-CODE>)>)
		     (ELSE <PUT .TT ,NODE-TYPE ,ISTRUC2-CODE>)>
	       <PUT .TT ,RESULT-TYPE .TYP>
	       <COND (<ASSIGNED? EV> <PUT .TT ,KIDS (.N .EV)>)
		     (ELSE <PUT .TT ,KIDS (.N)>)>)>>

"READ, READCHR, READSTRING, NEXTCHR, READB, GET, GETL, GETPROP, GETPL"

<PUTPROP ,READ PAPPLY-OBJECT <FUNCTION (O A) <CHANFCNS .O .A READ 2 ANY>>>

<COND (<NOT <GASSIGNED? READ-INTERNAL>> <SETG READ-INTERNAL (1)>)>

<PUTPROP ,READ-INTERNAL
	 PAPPLY-OBJECT
	 <FUNCTION (O A) <CHANFCNS .O .A READ-INTERNAL 2 ANY>>>

<COND (<GASSIGNED? GC-READ>
       <PUTPROP ,GC-READ
	        PAPPLY-OBJECT
	        <FUNCTION (O A) <CHANFCNS .O .A GC-READ 2 ANY>>>)>

<PUTPROP ,READCHR
	 PAPPLY-OBJECT
	 <FUNCTION (O A) <CHANFCNS .O .A READCHR 2 ANY>>>

<PUTPROP ,NEXTCHR
	  PAPPLY-OBJECT
	  <FUNCTION (O A) <CHANFCNS .O .A NEXTCHR 2 ANY>>>

<PUTPROP ,READB PAPPLY-OBJECT <FUNCTION (O A) <CHANFCNS .O .A READB 4 ANY>>>

<PUTPROP ,READSTRING
	 PAPPLY-OBJECT
	 <FUNCTION (O A) <CHANFCNS .O .A READSTRING 4 ANY>>>

<DEFINE CHANFCNS (OBJ AP NAME ARGN TYP "AUX" TT (LN <LENGTH .OBJ>) N (TEM 0)) 
   #DECL ((VALUE) NODE (TT) NODE (N) <LIST [REST NODE]> (LN) FIX (TEM ARGN) FIX
	  (OBJ) <PRIMTYPE LIST>)
   <COND
    (<OR <SEG? .OBJ> <L? <- .LN 1> .ARGN>> <RSUBR-FCN .OBJ .AP>)
    (ELSE
     <SET TT <NODEFM ,READ-EOF-CODE .PARENT .TYP .NAME () ,.NAME>>
     <SET N
      <MAPF ,LIST
	    <FUNCTION (OB "AUX" (EV <PCOMP .OB .TT>)) 
		    #DECL ((EV) NODE)
		    <COND (<==? <SET TEM <+ .TEM 1>> .ARGN>
			   <COND (<==? <NODE-TYPE .EV> ,QUOTE-CODE>
				  <SET EV <PCOMP <NODE-NAME .EV> .TT>>
				  <PUT .TT ,NODE-TYPE ,READ-EOF2-CODE>)>
			   <SET EV
				<NODE1 ,EOF-CODE
				       .TT
				       <RESULT-TYPE .EV>
				       <>
				       (.EV)>>)>
		    .EV>
	    <REST .OBJ>>>
     <PUT .TT ,KIDS .N>)>>

<PUTPROP ,GETPROP PAPPLY-OBJECT <FUNCTION (O A) <GETFCNS .O .A GETPROP>>>

'<PUTPROP ,GETPL PAPPLY-OBJECT <FUNCTION (O A) <GETFCNS .O .A GETPL>>>

<DEFINE GETFCNS (OBJ AP NAME "AUX" EV TEM T2 (LN <LENGTH .OBJ>) TT) 
	#DECL ((OBJ) FORM (LN) FIX (TT VALUE TEM T2 EV) NODE)
	<COND (<OR <AND <N==? .LN 4> <N==? .LN 3>> <SEG? .OBJ>>
	       <RSUBR-FCN .OBJ .AP>)
	      (ELSE
	       <SET TT <NODEFM ,GET-CODE .PARENT ANY .NAME () ,.NAME>>
	       <SET TEM <PCOMP <2 .OBJ> .TT>>
	       <SET T2 <PCOMP <3 .OBJ> .TT>>
	       <COND (<==? .LN 3>
		      <PUT .TT ,NODE-TYPE ,GET2-CODE>
		      <PUT .TT ,KIDS (.TEM .T2)>)
		     (ELSE
		      <SET EV <PCOMP <4 .OBJ> .TT>>
		      <COND (<==? <NODE-TYPE .EV> ,QUOTE-CODE>
			     <SET EV <PCOMP <NODE-NAME .EV> .TT>>
			     <PUT .TT ,NODE-TYPE ,GET2-CODE>)>
		      <PUT .TT ,KIDS (.TEM .T2 .EV)>)>
	       .TT)>>

<DEFINE ARGCHK (GIV REQ NAME OBJ "AUX" (HI .REQ) (LO .REQ)) 
	#DECL ((GIV) FIX (REQ HI LO) <OR <LIST FIX FIX> FIX>)
	<COND (<TYPE? .REQ LIST> <SET HI <2 .REQ>> <SET LO <1 .REQ>>)>
	<COND (<L? .GIV .LO>
	       <COMPILE-ERROR "Too few arguments to: " .NAME .OBJ>)
	      (<G? .GIV .HI>
	       <COMPILE-ERROR "Too many arguments to: " .NAME .OBJ>)>
	T>

""

<DEFINE PMAPF-R (OB AP
		 "AUX" (NAME <1 .OB>) TT ITRF OBJ (RQRG 0)
		       (LN <LENGTH <SET OBJ <REST .OB>>>) FINALF TAPL (APL ())
		       (DCL #DECL ()) (ARGL ()) (HATOM <>) (NN 0) TEM L2 L3
		       (TRG 0))
   #DECL ((OBJ OB) <PRIMTYPE LIST> (LN NN) FIX (DCL) DECL (ARGL APL) LIST
	  (ITRF FINALF TT) NODE (TRG RQRG) <SPECIAL FIX>)
   <PROG ()
     <COND (<L? .LN 2> <COMPILE-ERROR "Too few arguments:  " .NAME .OBJ>)>
     <SET TT <NODEFM ,MAP-CODE .PARENT <> .NAME () .AP>>
     <SET FINALF <PCOMP <1 .OBJ> .TT>>
     <COND
      (<OR <TYPE? <SET TAPL <2 .OBJ>> FUNCTION>
	   <AND <TYPE? .TAPL FORM>
		<NOT <EMPTY? <SET APL <CHTYPE .TAPL LIST>>>>
		<TYPE? <SET TEM <1 .APL>> ATOM>
		<GASSIGNED? .TEM>
		<==? ,.TEM ,FUNCTION>
		<SET TAPL <REST .APL>>>>
       <COND (<EMPTY? <SET APL <CHTYPE .TAPL LIST>>>
	      <COMPILE-ERROR "MAPF/R function is empty:  " .OBJ>)>
       <COND (<TYPE? <1 .APL> ATOM ADECL>
	      <SET HATOM <1 .APL>>
	      <SET APL <REST .APL>>)>
       <COND (<OR <EMPTY? .APL> <NOT <TYPE? <1 .APL> LIST>>>
	      <COMPILE-ERROR "MAPF/R function lacks arg list:  " .OBJ>)>
       <SET ARGL <1 .APL>>
       <SET APL <REST .APL>>
       <COND (<AND <NOT <EMPTY? .APL>> <TYPE? <1 .APL> DECL>>
	      <SET DCL <1 .APL>>
	      <SET APL <REST .APL>>)>
       <COND (<EMPTY? .APL>
	      <COMPILE-ERROR "MAPF/R function has no body:  " .OBJ>)>
       <PROG ((VARTBL .VARTBL))
	 #DECL ((VARTBL) <SPECIAL SYMTAB>)
	 <SET ITRF
	      <NODEPR ,MFCN-CODE
		      .TT
		      <OR <FIND_DECL VALUE .DCL> ANY>
		      <>
		      ()
		      <>
		      ()
		      .HATOM
		      .VARTBL>>
	 <GEN-D .ARGL .DCL .HATOM .ITRF>
	 <COND
	  (<ACT-FIX .ITRF <BINDING-STRUCTURE .ITRF>>
	   <SET L3 <SET L2 ()>>
	   <PUT
	    .ITRF
	    ,BINDING-STRUCTURE
	    <REPEAT ((L <BINDING-STRUCTURE .ITRF>) (LL .L) (L1 .L) SYM)
		    #DECL ((L L1 LL) <LIST [REST SYMTAB]>)
		    <AND <EMPTY? .L> <RETURN .L1>>
		    <COND
		     (<==? <CODE-SYM <SET SYM <1 .L>>> 1>
		      <SET L2 ("ACT" <NAME-SYM .SYM> !.L2)>
		      <SET L3
			   ((<NAME-SYM .SYM>)
			    <COND (<SPEC-SYM .SYM>
				   <FORM SPECIAL <DECL-SYM .SYM>>)
				  (ELSE <FORM UNSPECIAL <DECL-SYM .SYM>>)>
			    !.L3)>
		      <COND (<==? .L .L1> <SET L1 <REST .L1>>)
			    (ELSE <PUTREST .LL <REST .L>>)>)>
		    <SET L <REST <SET LL .L>>>>>
	   <SET APL (<FORM PROG .L2 <CHTYPE .L3 DECL> !.APL>)>)>
	 <PUT .ITRF ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .ITRF>> .APL>>>)
      (<OR <AND <TYPE? .TAPL FIX> <==? .LN 3>>
	   <AND <OR <AND <TYPE? .TAPL FORM>
			 <==? <LENGTH <SET APL <CHTYPE .TAPL LIST>>> 2>
			 <TYPE? <SET TEM <1 .APL>> ATOM>
			 <GASSIGNED? .TEM>
			 <==? ,.TEM ,GVAL>
			 <TYPE? <SET TEM <2 .APL>> ATOM>>
		    <AND <TYPE? .TAPL GVAL>
			 <SET TEM <CHTYPE .TAPL ATOM>>>>
		<OR .REASONABLE
		    <AND <GASSIGNED? .TEM>
			 <OR <NOT <TYPE? ,.TEM FUNCTION>>
			     <==? .TEM .FNAME>>>>>>
       <PUTPROP .IND PTHIS-OBJECT ,PMARGS>
       <SET ITRF
	    <COND (<TYPE? .TAPL FIX> <PCOMP <FORM NTH .IND .TAPL> .TT>)
		  (ELSE
		   <PCOMP <FORM .TEM
				!<MAPF ,LIST
				       <FUNCTION () <COND (<==? .LN 2> <MAPSTOP>)
							  (ELSE
							   <SET LN <- .LN 1>>
							   .IND)>>>> .TT>)>>
       <PUTPROP .IND PTHIS-OBJECT>
       <MAPF <>
	     <FUNCTION (N) 
		     #DECL ((N) NODE)
		     <AND <==? <NODE-TYPE .N> ,MARGS-CODE>
			  <PUT .N ,NODE-NAME <SET NN <+ .NN 1>>>>>
	     <KIDS .ITRF>>
       <SET ITRF <NODEFM ,MPSBR-CODE .TT <> <> (.ITRF) <>>>)
      (ELSE <SET ITRF <PCOMP .TAPL .TT>>)>
     <PUT .TT
	  ,KIDS
	  (.FINALF
	   .ITRF
	   !<MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>> <REST .OBJ 2>>)>
     .TT>>

\ 

<DEFINE PMARGS (O) 
	#DECL ((VALUE) NODE)
	<NODEFM ,MARGS-CODE .PARENT <> <> () <>>>

<COND (<GASSIGNED? PMAPF-R>
       <PUTPROP ,MAPF PAPPLY-OBJECT ,PMAPF-R>
       <PUTPROP ,MAPR PAPPLY-OBJECT ,PMAPF-R>)>

<DEFINE ADECL-FCN (OBJ "AUX" (TT <NODEFM ,ADECL-CODE .PARENT <> ADECL () <>>)
			     OBJ1) 
	#DECL ((TT VALUE) NODE (OBJ) ADECL)
	<COND (<==? <LENGTH .OBJ> 2>
	       <COND (<TYPE? <SET OBJ1 <1 .OBJ>> SEGMENT>
		      <PUT .TT ,NODE-TYPE ,SEGMENT-CODE>
		      <PUT .TT ,NODE-NAME <>>
		      <PUT .TT ,KIDS (<ADECL-FCN <CHTYPE [<CHTYPE .OBJ1 FORM>
							  <2 .OBJ>] ADECL>>)>)
		     (ELSE
		      <PUT .TT ,NODE-NAME <2 .OBJ>>
		      <PUT .TT ,KIDS (<PCOMP <1 .OBJ> .TT>)>)>)
	      (ELSE
	       <COMPILE-ERROR "ADECL has an incorrect number of elements: "
			      .OBJ>)>>

<COND (<GASSIGNED? ADECL-FCN> <PUTPROP ADECL PTHIS-TYPE ,ADECL-FCN>)>

<DEFINE CASE-FCN (OBJ AP
		  "AUX" (OP .PARENT) (PARENT .PARENT) (FLG T) (WIN T) TYP
			(DF <>) P TEM X)
   #DECL ((PARENT) <SPECIAL NODE> (OBJ) <FORM ANY> (VALUE) NODE)
   <COND
    (<AND
      <G? <LENGTH .OBJ> 3>
      <PROG ()
	    <COND (<OR <AND <==? <TYPE <SET X <2 .OBJ>>> GVAL>
			    <==? <SET P <CHTYPE .X ATOM>> ==?>>
		       <AND <TYPE? <SET X <2 .OBJ>> FORM>
			    <==? <LENGTH .X> 2>
			    <==? <1 .X> GVAL>
			    <==? <SET P <2 .X>> ==?>
			    ;<MEMQ <SET P <2 .X>> '[==? TYPE? PRIMTYPE?]>>>)
		  (ELSE <SET WIN <>>)>
	    1>
      <MAPF <>
       <FUNCTION (O) 
	  <COND
	   (<AND .FLG <==? .O DEFAULT>> <SET DF T>)
	   (<AND .DF <TYPE? .O LIST>> <SET DF <>> <SET FLG <>>)
	   (<AND <NOT .DF> <TYPE? .O LIST> <NOT <EMPTY? .O>>>
	    <COND
	     (<SET TEM <VAL-CHK <1 .O>>>
	      <COND (<ASSIGNED? TYP> <OR <==? .TYP <TYPE .TEM>> <SET WIN <>>>)
		    (ELSE <SET TYP <TYPE .TEM>>)>)
	     (<AND <TYPE? <SET TEM <1 .O>> SEGMENT>
		   <==? <LENGTH .TEM> 2>
		   <==? <1 .TEM> QUOTE>
		   <NOT <MONAD? <SET TEM <2 .TEM>>>>>
	      <MAPF <>
		    <FUNCTION (TY) 
			    <COND (<NOT <SET TY <VAL-CHK .TY>>> <SET WIN <>>)
				  (ELSE
				   <COND (<ASSIGNED? TYP>
					  <OR <==? .TYP <TYPE .TY>>
					      <SET WIN <>>>)
					 (ELSE <SET TYP <TYPE .TY>>)>)>>
		    .TEM>)
	     (ELSE <SET WIN <>>)>)
	   (ELSE <MAPLEAVE <>>)>
	  T>
       <REST .OBJ 3>>
      <NOT .DF>>
     <COND (<AND .WIN
		 <NOT <OR <AND <MEMQ <TYPEPRIM .TYP> '[WORD FIX]>
			       <==? .P ==?>>
			  <AND <N==? .P ==?> <==? .TYP ATOM>>>>>
	    <SET WIN <>>)>
     <COND
      (.WIN
       <SET PARENT <NODECOND ,CASE-CODE .OP <> CASE ()>>
       <PUT
	.PARENT
	,KIDS
	(<PCOMP <2 .OBJ> .PARENT>
	 <PCOMP <3 .OBJ> .PARENT>
	 !<MAPF ,LIST
	   <FUNCTION (CLA "AUX" TT) 
		   #DECL ((CLA) <OR ATOM LIST> (TT) NODE)
		   <COND (.DF <SET CLA (ELSE !.CLA)>)>
		   <COND
		    (<NOT <TYPE? .CLA ATOM>>
		     <PUT <SET TT <NODEB ,BRANCH-CODE .PARENT <> <> ()>>
			  ,PREDIC
			  <PCOMP <COND (<TYPE? <SET TEM <1 .CLA>> SEGMENT>
					<FORM QUOTE
					      <MAPF ,LIST ,VAL-CHK <2 .TEM>>>)
				       (<TYPE? .TEM ORQ>
					<FORM QUOTE
					      <MAPF ,LIST ,VAL-CHK .TEM>>)
				       (ELSE <VAL-CHK .TEM>)>
				 .TT>>
		     <PUT .TT
			  ,CLAUSES
			  <MAPF ,LIST
				<FUNCTION (O) <PCOMP .O .TT>>
				<REST .CLA>>>
		     <SET DF <>>
		     .TT)
		    (ELSE <SET DF T> <PCOMP .CLA .PARENT>)>>
	   <REST .OBJ 3>>)>)
      (ELSE <PMACRO .OBJ .OP>)>)
    (ELSE <COMPILE-ERROR "CASE in incorrect format " .OBJ>)>>

<DEFINE VAL-CHK (TEM "AUX" TT) 
	<OR <AND <OR <TYPE? .TEM ATOM>
		     <==? <PRIMTYPE .TEM> WORD>
		     <==? <PRIMTYPE .TEM> FIX>> .TEM>
	    <AND <==? <TYPE .TEM> GVAL>
		 <MANIFESTQ <SET TEM <CHTYPE .TEM ATOM>>>
		 ,.TEM>
	    <AND <TYPE? .TEM FORM>
		 <==? <LENGTH .TEM> 2>
		 <OR <AND <==? <1 .TEM> QUOTE> <2 .TEM>>
		     <AND <==? <1 .TEM> GVAL> <MANIFESTQ <2 .TEM>> ,<2 .TEM>>
		     <AND <==? <1 .TEM> ASCII>
			  <TYPE? <2 .TEM> CHARACTER FIX>
			  <EVAL .TEM>>>>
	    <AND <TYPE? .TEM FORM>
		 <==? <LENGTH .TEM> 3>
		 <==? <1 .TEM> CHTYPE>
		 <TYPE? <3 .TEM> ATOM>
		 <NOT <TYPE? <2 .TEM> FORM LIST VECTOR UVECTOR SEGMENT>>
		 <EVAL .TEM>>
	    <AND <TYPE? .TEM FORM>
		 <NOT <EMPTY? .TEM>>
		 <TYPE? <SET TT <1 .TEM>> ATOM>
		 <GASSIGNED? .TT>
		 <TYPE? ,.TT MACRO>
		 <VAL-CHK <EMACRO .TEM>>>>>

<DEFINE MANIFESTQ (ATM)
	#DECL ((ATM) ATOM)
	<AND <MANIFEST? .ATM>
	     <GASSIGNED? .ATM>
	     <NOT <TYPE? ,.ATM MSUBR>>>>

<DEFINE EMACRO (OBJ "AUX" (ERR <HANDLER ,MACROERR 100>) TEM) 
	<ON .ERR>
	<COND (<TYPE? <SET TEM
			   <PROG MACACT ()
				 #DECL ((MACACT) <SPECIAL ANY>)
				 <SETG ERR .ERR>
				 <SETG MACACT .MACACT>
				 <EXPAND .OBJ>>>
		      FUNNY>
	       <OFF .ERR>
	       <COMPILE-ERROR "Macro expansion lossage " ,CR !.TEM>)
	      (ELSE <OFF .ERR> .TEM)>>

<COND (<AND <GASSIGNED? CASE> <GASSIGNED? CASE-FCN>>
       <PUTPROP ,CASE PAPPLY-OBJECT ,CASE-FCN>)>

<DEFINE P-CALL (OBJ AP
		 "AUX" (TT
			<NODEFM ,CALL-CODE
				.PARENT
				<>
				CALL
				()
				.AP>))
	#DECL ((TT) NODE (VALUE) NODE (OBJ) FORM)
	<COND (<AND <NOT <EMPTY? <REST .OBJ>>>
		    <TYPE? <SET CALLED <2 .OBJ>> ATOM>>
	       <COND (<==? .CALLED IFSYS>
		      <SET IN-IFSYS <3 .OBJ>>)
		     (<==? .CALLED ENDIF>
		      <SET IN-IFSYS <>>)>)>
	<PUT .TT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>> <REST .OBJ>>>>

<DEFINE P-APPLY PAP (OBJ AP "AUX" TT ITM TEM V)
	#DECL ((TT) NODE (VALUE) NODE (OBJ) FORM)
	<COND (<AND <NOT <EMPTY? <REST .OBJ>>>
		    <TYPE? <SET ITM <2 .OBJ>> SEGMENT>>
	       <COND (<AND <==? <LENGTH .ITM> 2>
			   <OR <==? <SET TEM <1 .ITM>> GVAL> <==? .TEM LVAL>>>
		      <SET OBJ <CHTYPE (<FORM 1 .ITM>
					<CHTYPE (REST .ITM) SEGMENT>
					!<REST .OBJ 2>) FORM>>)
		     (ELSE
		      <RETURN <PCOMP <FORM BIND ((<SET V <MAKE-TAG "A">> .ITM))
					   <CHTYPE (APPLY <FORM 1
								<FORM LVAL .V>>
						 <CHTYPE (REST <FORM LVAL .V>)
							  SEGMENT>
						 !<REST .OBJ 2>) FORM>>
				     .PARENT> .PAP>)>)
	      (ELSE <SET OBJ <CHTYPE <REST .OBJ> FORM>>)>
	<SET TT <NODEFM ,APPLY-CODE .PARENT <> APPLY () .AP>>
	<PUT .TT ,KIDS <MAPF ,LIST <FUNCTION (O) <PCOMP .O .TT>>  .OBJ>>>

<COND (<GASSIGNED? P-CALL> <PUTPROP `CALL PAPPLY-OBJECT ,P-CALL>)>

<DEFINE PRINT-HACKERS (OBJ AP "AUX" (LEN <COND (<==? <1 .OBJ> CRLF> 1)
					       (ELSE 2)>))
	#DECL ((OBJ) FORM (LEN) FIX)
	<COND (<==? <LENGTH .OBJ> .LEN>
	       <COND (<==? .LEN 1>
		      <SET OBJ <CHTYPE (<1 .OBJ> '.OUTCHAN) FORM>>)
		     (ELSE <SET OBJ <CHTYPE (<1 .OBJ> <2 .OBJ> '.OUTCHAN)
					    FORM>>)>)>
	<RSUBR-FCN .OBJ .AP>>

<COND (<GASSIGNED? PRINT-HACKERS>
       <PUTPROP ,PRINT PAPPLY-OBJECT ,PRINT-HACKERS>
       <PUTPROP ,PRIN1 PAPPLY-OBJECT ,PRINT-HACKERS>
       <PUTPROP ,PRINC PAPPLY-OBJECT ,PRINT-HACKERS>
       <PUTPROP ,CRLF PAPPLY-OBJECT ,PRINT-HACKERS>)>

<DEFINE P-MULTI-SET (OBJ:FORM AP
		     "AUX" (TT <NODEFM ,MULTI-SET-CODE .PARENT <> MULTI-SET
				       () ,MULTI-SET>) L)
	<COND (<L? <LENGTH .OBJ> 2>
	       <COMPILE-ERROR "Too few args to MULTI-SET:  " .OBJ>)>
	<COND (<OR <NOT <TYPE? <SET L <2 .OBJ>> LIST>>
		   <EMPTY? .L>
		   <MAPF <>
			 <FUNCTION (X)
			      <COND (<NOT <OR <TYPE? .X ATOM>
					      <AND <TYPE? .X ADECL>
						   <TYPE? <1 .X> ATOM>>>>
				     <MAPLEAVE T>)>
			      <>>
			 .L>>
	       <COMPILE-ERROR "Arg wrong type to MULTI-SET:  " .OBJ>)>
	<PUT .TT ,KIDS (<PCOMP <FORM QUOTE .L> .TT>
			!<MAPF ,LIST
			       <FUNCTION (O) <PCOMP .O .TT>>
			       <REST .OBJ 2>>)>>

<COND (<AND <GASSIGNED? MULTI-SET> <GASSIGNED? P-MULTI-SET>>
       <PUTPROP ,MULTI-SET PAPPLY-OBJECT ,P-MULTI-SET>)>  

<DEFINE PIFSYS (OBJ AP "AUX" L SYS) #DECL ((OBJ) <OR FORM LIST>)
	<COND (<AND <ASSIGNED? IN-IFSYS> .IN-IFSYS>
	       <REPEAT ((STUFF ()))
		       <COND (<EMPTY? <SET OBJ <REST .OBJ>>>
			      <RETURN <COND (<EMPTY? .STUFF>
					     <PDEFAULT <>>)
					    (<PPROG-REPEAT
					      <CHTYPE (BIND () !.STUFF) FORM>
					      BIND>)>>)>
		       <COND (<OR <NOT <TYPE? <SET L <1 .OBJ>> LIST>>
				  <EMPTY? .L>
				  <NOT <TYPE? <SET SYS <1 .L>> STRING ATOM>>>
			      <ERROR ARG-WRONG-TYPE <1 .OBJ> IFSYS>)
			     (ELSE
			      <COND (<TYPE? .SYS ATOM> <SET SYS <SPNAME .SYS>>)>
			      <COND (<OR <=? .SYS .IN-IFSYS>
					 <AND <=? .SYS "UNIX">
					      <OR <=? .IN-IFSYS "VAX">
						  <=? .IN-IFSYS "MAC">>>
					 <AND <OR <=? .SYS "VAX">
						  <=? .SYS "MAC">>
					      <=? .IN-IFSYS "UNIX">>>
				     ; "Allow for UNIX/VAX/MAC..."
				     <SET STUFF (!<REST .L> !.STUFF)>)>)>>)
	      (ELSE
	       <PMACRO <CHTYPE (IFSYS-MIMC !<REST .OBJ>) FORM>
		       .AP>)>>

<COND (<AND <GASSIGNED? IFSYS> <GASSIGNED? PIFSYS>>
       <PUTPROP ,IFSYS PAPPLY-OBJECT ,PIFSYS>)>

<DEFMAC IFSYS-MIMC ("ARGS" ARGS "AUX" (STUFF ()))
  #DECL ((ARGS) LIST)
  <REPEAT (L)
    <COND (<EMPTY? .ARGS> <RETURN .STUFF>)>
    <COND (<OR <NOT <TYPE? <SET L  <1 .ARGS>> LIST>>
	       <EMPTY? .L>
	       <NOT <TYPE? <1 .L> STRING ATOM>>>
	   <ERROR ARG-WRONG-TYPE <1 .ARGS> IFSYS>)
	  (T
	   <COND (<TYPE? <1 .L> ATOM>
		  <1 .L <SPNAME <1 .L>>>)>
	   <SET STUFF (<FORM CALL!- IFSYS <1 .L>> !<REST .L>
		       <FORM CALL!- ENDIF <1 .L>> !.STUFF)>)>
    <SET ARGS <REST .ARGS>>>
  <CHTYPE (BIND () !.STUFF) FORM>>

<ENDPACKAGE>
