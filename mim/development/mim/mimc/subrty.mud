<PACKAGE "SUBRTY">

<ENTRY SUBRS TEMPLATES>

<USE "COMPDEC" "CHKDCL">


; "Functions to decide arg dependent types."

<DEFINE FIRST-ARG ("TUPLE" T) <1 .T>>

<DEFINE SECOND-ARG ("TUPLE" T) <2 .T>>

<DEFINE LOC-FCN (STR "OPTIONAL" N
		     "AUX" (TEM <MEMQ <ISTYPE? .STR>
				      '[UVECTOR VECTOR ASOC TUPLE STRING
					 LIST]>))
	<COND (.TEM
	       <NTH '[LOCL LOCS LOCA LOCAS LOCV LOCU] <LENGTH .TEM>>)
	      (ELSE ANY)>>

<DEFINE MAPF-VALUE ("TUPLE" T) ANY>

<DEFINE MEM-VALUE (ITEM STR "AUX" TEM)
	<COND (<SET TEM <ISTYPE? .STR>> <FORM OR FALSE <TYPEPRIM .TEM>>)
	      (ELSE STRUCTURED)>>

<DEFINE SPFIRST-ARG ("TUPLE" T "AUX" TEM)
	<COND (<SET TEM <STRUCTYP <1 .T>>>
	       <COND (<==? .TEM TUPLE> VECTOR)(ELSE .TEM)>)>>
	       

<DEFINE PFIRST-ARG ("TUPLE" T "AUX" TEM)
	<COND (<SET TEM <STRUCTYP <1 .T>>>)
	      (ELSE ANY)>>

; "Data structure specifying return types and # of args to common subrs."

<SETG SUBR-DATA
	 [(,*!- ANY '<OR FIX FLOAT>)
	  (,+!- ANY '<OR FIX FLOAT>)
	  (,/!- ANY '<OR FIX FLOAT>)
	  (,-!- ANY '<OR FIX FLOAT>)
	  (,0?!- 1 '<OR ATOM !<FALSE!>>)
	  (,1?!- 1 '<OR ATOM !<FALSE!>>)
	  (,==?!- 2 '<OR ATOM !<FALSE!>>)
	  (,=?!- 2 '<OR ATOM !<FALSE!>>)
	  (,ABS!- 1 '<OR FIX FLOAT>)
	  (,ALLTYPES!- 0 '<VECTOR [REST ATOM]>)
	  (,ANDB!- ANY FIX)
	  (,APPLY!- ANY ANY)
	  (,APPLYTYPE!- '(1 2) '<OR FALSE ATOM APPLICABLE>)
	  (,ARGS!- 1 TUPLE)
	  (,ASCII!- 1 '<OR CHARACTER FIX>)
	  (,ASSIGNED?!- '(1 2) '<OR ATOM !<FALSE!>>)
	  (,ATAN!- 1 FLOAT)
	  (,ATOM!- 1 ATOM)
	  (,BACK!- '(1 2) ,PFIRST-ARG)
	  (,BLOCK!- 1 '<LIST [REST OBLIST]>)
	  (,BOUND?!- '(1 2) '<OR ATOM !<FALSE!>>)
	  (,CHANLIST!- 0 '<LIST [REST CHANNEL]>)
	  (,CHTYPE!- 2 ANY)
	  (,CLOSE!- 1 CHANNEL)
	  (,COS!- 1 FLOAT)
	  (,CRLF '(0 2) ATOM)
	  (,EMPTY?!- 1 '<OR !<FALSE!> ATOM>)
	  (,ENDBLOCK!- 0 '<LIST [REST OBLIST]>)
	  (,EQVB!- ANY FIX)
	  (,ERRET!- '(0 2) ANY)
	  (,ERRORS!- 0 OBLIST)
	  (,EVAL!- '(1 2) ANY)
	  (,EVALTYPE!- '(1 2) '<OR FALSE ATOM APPLICABLE>)
	  (,EXP!- 1 FLOAT)
	  (,FIX!- 1 FIX)
	  (,FLATSIZE!- '(2 3) '<OR !<FALSE!> FIX>)
	  (,FLOAD!- '(0 5) STRING)		;"\"DONE\""
	  (,FLOAT!- 1 FLOAT)
	  (,FORM!- ANY FORM)
	  (,FRAME!- '(0 1) '<OR FRAME !<FALSE!>>)
	  (,FUNCT!- 1 ATOM)
	  (,G=?!- 2 '<OR ATOM !<FALSE!>>)
	  (,G?!- 2 '<OR ATOM !<FALSE!>>)
	  (,GASSIGNED?!- 1 '<OR !<FALSE!> ATOM>)
	  (,GUNASSIGN!- 1 ATOM)
	  (,GVAL!- 1 ANY)
	  (,ILIST!- '(1 2) LIST)
	  (,INSERT!- 2 ATOM)
	  (,INTERRUPTS!- 0 OBLIST)
	  (,ISTRING!- '(1 2) STRING)
	  (,IUVECTOR!- '(1 2) UVECTOR)
	  (,IVECTOR!- '(1 2) VECTOR)
	  (,L=?!- 2 '<OR !<FALSE!> ATOM>)
	  (,L?!- 2 '<OR !<FALSE!> ATOM>)
	  (,LEGAL?!- 1 '<OR !<FALSE!> ATOM>)
	  (,LENGTH!- 1 FIX)
	  (,LENGTH? 2  '<OR !<FALSE!> FIX>)
	  (,LINK!- '(2 3) ,FIRST-ARG)
	  (,LIST!- ANY LIST)
	  (,LISTEN!- ANY ANY)
	  (,LOG!- 1 FLOAT)
	  (,LOOKUP!- 2 '<OR ATOM !<FALSE!>>)
	  (,LVAL!- '(1 2) ANY)
	  (,MEMBER!- 2 ,MEM-VALUE)
	  (,MEMQ!- 2 ,MEM-VALUE)
	  (,MOD!- 2 '<OR FIX FLOAT>)
	  (,MONAD?!- 1 '<OR ATOM !<FALSE!>>)
	  (,N==?!- 2 '<OR !<FALSE!> ATOM>)
	  (,N=?!- 2 '<OR !<FALSE!> ATOM>)
	  (,NEWTYPE!- '(2 3) ATOM)
	  (,NOT!- 1 '<OR ATOM !<FALSE!>>)
	  (,NTH!- '(1 2) ANY)
	  (,OBLIST?!- 1 '<OR !<FALSE!> OBLIST>)
	  (,OPEN!- '(0 6) '<OR CHANNEL FALSE>)
	  (,ORB!- ANY FIX)
	  (,PARSE!- '(0 5) ANY)
	  (,PNAME!- 1 STRING)
	  (,PRIMTYPE!- 1 ATOM)
	  (,PRINC!- '(1 3) ,FIRST-ARG)
	  (,PRIN1!- '(1 3) ,FIRST-ARG)
	  (,PRINT!- '(1 3) ,FIRST-ARG)
	  (,PRINTTYPE!- '(1 2) '<OR FALSE ATOM APPLICABLE>)
	  (,PUT!- '(2 3) ANY)
	  (,PUTREST!- 2 ,FIRST-ARG)
	  (,RANDOM!- '(0 2) FIX)
	  (,READ!- '(0 4) ANY)
	  (,READCHR!- '(0 2) ANY)
	  (,REMOVE!- '(1 2) '<OR ATOM !<FALSE!>>)
	  (,REST!- '(1 2) ,PFIRST-ARG)
	  (,RESTORE!- '(1 4) ANY)
	  (,RETRY!- '(0 1) ANY)
	  (,RETURN!- '(1 2) ANY)
	  (,ROOT!- 0 OBLIST)
	  (,SAVE!- '(0 4) STRING)
	  (,SET!- '(2 3) ,SECOND-ARG)
	  (,SETG!- 2 ,SECOND-ARG)
	  (,SIN!- 1 FLOAT)
	  (,SPNAME!- 1 STRING)
	  (,SQRT!- 1 FLOAT)
	  (,STRCOMP!- 2 FIX)
	  (,STRING!- ANY STRING)
	  (,STRUCTURED?!- 1 '<OR !<FALSE!> ATOM>)
	  (,TIME!- ANY FLOAT)
	  (,TOP!- 1 ,PFIRST-ARG)
	  (,TYPE!- 1 ATOM)
	  (,TYPE-C '(1 2) TYPE-C)
	  (,TYPE-W '(1 3) TYPE-W)
	  (,TYPE?!- ANY '<OR ATOM !<FALSE!>>)
	  (,TYPEPRIM!- 1 ATOM)
	  (,UNASSIGN!- '(1 2) ATOM)
	  (,UNPARSE!- '(1 2) STRING)
	  (,UVECTOR!- ANY UVECTOR)
	  (,VALID-TYPE? 1 '<OR !<FALSE!> TYPE-C>)
	  (,VECTOR!- ANY VECTOR)
	  (,XORB!- ANY FIX)]>

<SETG SUBRS <MAPF ,VECTOR 1 ,SUBR-DATA>>

<SETG TEMPLATES <MAPF ,VECTOR ,REST ,SUBR-DATA>>

<PROG (I)
	<SETG TEMPLATES
		<IVECTOR <SET I <LENGTH ,TEMPLATES>>
			 '<PROG ((T <NTH ,TEMPLATES .I>))
			       <SET I <- .I 1>> .T>>>>

<SETG SUBR-DATA ()>

<REMOVE SUBR-DATA>

<ENDPACKAGE>
