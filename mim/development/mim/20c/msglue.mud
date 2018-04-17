
<PACKAGE "MSGLUE">

<ENTRY FILE-GLUE>

<USE "NEWSTRUC">

<NEWSTRUC GLUE-INFO VECTOR
	  IMSUBR-NAME ATOM
	  MSUBR-NAME ATOM
	  GLUED-CALL-OK? <OR ATOM FALSE>
	  MSUBR-DECL LIST
	  START-LOC FIX
	  REFS LIST
	  FINAL-LOC <OR FALSE FIX>
	  CONST-START FIX
	  MIN-MAX-ARGS FIX
	  MSUBR-OBLIST LIST>

<NEWSTRUC CONST-REF VECTOR C-VALUE FIX C-REFS <LIST [REST FIX]>>

<EVAL-WHEN ("SUBSYSTEM" "MIMC")
	   <FLOAD "PS:<MIM.20C>MSGLUE-PM.MUD">>

<COND (<N==? <PRIMTYPE 1> FIX>
       <DEFINE FLSH (A B) #DECL ((A B) FIX) <CHTYPE <LSH .A .B> FIX>>
       <DEFINE FORB ("TUPLE" X) <CHTYPE <ORB !.X> FIX>>
       <PUTPROP CODE DECL '<<PRIMTYPE UVECTOR> [REST FIX]>>)
      (ELSE
       <SETG FLSH ,LSH>
       <SETG FORB ,ORB>
       <PUT-DECL CODE '<<PRIMTYPE UVECTOR> [REST FIX]>>)>

<MSETG GLUE-FRM-INS 1>

<MSETG GLUE-LOAD-MS-INS 2>

<MSETG GLUE-LOAD-ARG 3>

<MSETG GLUE-CALL-INS 0>

<MSETG INDX-BP <BITS 4 18>>

<MSETG AC-BP <BITS 4 23>>

<MSETG INS-BP <BITS 9 27>>

<MSETG ADDR-BP <BITS 18>>

<MSETG FRAME-LOC *220*>

<MSETG CALL-LOC *221*>

<MSETG GVAL-LOC *160*>

<MSETG GASS-LOC *157*>

<MSETG ACALL-LOC 206>

<MSETG SFRAME-LOC 207>

<MSETG O2 9>

<MSETG O1 8>

<MSETG T 7>

<MSETG TP 14>

<MSETG F 13>

<MSETG R 10>

<MSETG M 11>

<MSETG P 15>

<MSETG P-AC <FLSH ,P 23>>

<MSETG T-AC <FLSH ,T 23>>

<MSETG PC-AC ,T-AC>

<MSETG F-INDX <FLSH ,F 18>>

<MSETG F-AC <FLSH ,F 23>>

<MSETG TP-INDX <FLSH ,TP 18>>

<MSETG TP-AC <FLSH ,TP 23>> 

<MSETG R-INDX <FLSH ,R 18>>

<MSETG IND <FLSH 1 22>>

<MSETG JSP <FLSH *265* 27>>

<MSETG SKIPL <FLSH *331* 27>>

<MSETG HRROI <FLSH *561* 27>>

<MSETG PUSH <FLSH *261* 27>>

<MSETG XMOVEI <FLSH *415* 27>>

<MSETG MOVEI *201*>

<MSETG SUB-INS <FLSH *274* 27>>

<MSETG JRST <FLSH *254* 27>>

<MSETG SETZ <FLSH *400* 27>>

<MSETG PUSHJ <FLSH *260* 27>>

<MSETG PUSHJ-GVAL <FORB ,PUSHJ ,P-AC ,IND ,GVAL-LOC>>

<MSETG PUSHJ-GASS <FORB ,PUSHJ ,P-AC ,IND ,GASS-LOC>>

<MSETG JSP-GVAL <FORB ,JSP ,PC-AC ,IND ,GVAL-LOC>>

<MSETG JSP-GASS <FORB ,JSP ,PC-AC ,IND ,GASS-LOC>> 

<MSETG JSP-ACALL <FORB ,JSP ,PC-AC ,IND ,ACALL-LOC>>

<SETG FUNNY-CALLS <UVECTOR ,PUSHJ-GVAL ,PUSHJ-GASS ,JSP-GVAL ,JSP-GASS ,JSP-ACALL>>

<GDECL (FUNNY-CALLS) <UVECTOR [REST FIX]>>

<MSETG JSP-FRAME <FORB ,JSP ,PC-AC ,IND ,FRAME-LOC>>

<MSETG JSP-CALL <FORB ,JSP ,PC-AC ,IND ,CALL-LOC>>

<MSETG JSP-SFRAME <FORB ,JSP ,PC-AC ,IND ,SFRAME-LOC>>

<MSETG SKIPL-T-1-PARENF <FORB ,SKIPL ,T-AC *777777* ,F-INDX>>

<MSETG HRROI-T <FORB ,HRROI ,T-AC ,F-INDX>>

<MSETG PUSH-TP-T <FORB ,PUSH ,TP-AC ,T>>

<MSETG PUSH-TP-F <FORB ,PUSH ,TP-AC ,F>>

<MSETG PUSH-TP-PARENR <FORB ,PUSH ,TP-AC ,R-INDX>>

<MSETG XMOVEI-F-1-TP <FORB ,XMOVEI ,F-AC *777777* ,TP-INDX>>

<MSETG SUB-F-O2 <FORB ,SUB-INS ,F-AC ,O2>>

<MSETG XMOVEI-TP <FORB ,XMOVEI ,F-AC ,TP-INDX>>

<MSETG JRST-R <FORB ,JRST ,R-INDX>> 

<MSETG SETZ-R <FORB ,SETZ ,R-INDX>>

<NEWTYPE GLUED-ATOM ATOM>

<GDECL (ALL-PACKAGES ALL-P OBJ-LIST OBJ-PTR CODE-LIST CODE-PTR) LIST>

<GDECL (CONST-PTR CONST-LIST) <LIST [REST CONST-REF]>>

<DEFINE FILE-GLUE ("TUPLE" FILES "AUX" C TMP-TXT TMP-CODE (OUTCHAN .OUTCHAN)
		   (EXPFLOAD <AND <ASSIGNED? EXPFLOAD> .EXPFLOAD>) (EST-LNT 0)
		   (FNM1 <GET-NM1 <1 .FILES>>) CP ITM OBP OC (NM2 "MSUBR")
		   (TEMP-FILE? <AND <GASSIGNED? TEMP-FILE?> ,TEMP-FILE?>)
		   (END <>))
	#DECL ((FILES) <<PRIMTYPE VECTOR> [REST STRING]> (OUTCHAN) <SPECIAL ANY>
	       (OBP CP) <LIST ANY> (OC C TMP-TXT TMP-CODE) <OR FALSE CHANNEL>
	       (EST-LNT) FIX (NM2) <SPECIAL STRING>)
	<COND (<AND <SET C <OPEN "READ" <1 .FILES>>>
		    <OR <NOT .TEMP-FILE?>
			<AND <SET TMP-TXT
				  <OPEN "PRINT"
					<STRING .FNM1
						".GLUE-TXT">>>
			     <SET TMP-CODE
				  <OPEN "PRINT"
					<STRING .FNM1 ".GLUE-CODE">>>>>>
	       <COND (<NOT .TEMP-FILE?>
		      <SET TMP-TXT <SET TMP-CODE <>>>
		      <SETG OBJ-LIST <SETG OBJ-PTR (T)>>)>
	       <SETG CODE-LIST <SET CP <SETG CODE-PTR (T)>>>
	       <SETG CONST-LIST <SETG CONST-PTR (<CHTYPE [0 ()] CONST-REF>)>>
	       <SETG INCHANS (.C)>
	       <SET FILES <REST .FILES>> 
	       <SETG ALL-P <SETG ALL-PACKAGES (T)>
	       <REPEAT (RES IMS) #DECL ((IMS) IMSUBR)
	         <REPEAT ()
		   <COND (<SET ITM <FINISH-FILE .C .TMP-TXT .EXPFLOAD>>)
			 (T
			  <RETURN>)>
		   <SET C <1 ,INCHANS>>
		   <COND (.TEMP-FILE? <PRIN1 .ITM .TMP-CODE>)
			 (ELSE <SET OBP ,OBJ-PTR>)>
		   <SET EST-LNT <+ <LENGTH <1 <SET IMS .ITM>>> .EST-LNT>>
		   <COND (<NOT <TYPE? <SET ITM <READ .C EOF>> FIX>>
			  <ERROR NOT-GLUEABLE!-ERRORS>)>
		   <SET RES <READ .C '<ERROR EOF-BAD-MSUBR-FILE!-ERRORS>>>
		   <COND (<NOT <TYPE? <SET RES <EVAL .RES>> MSUBR>>
			  <ERROR MSUBR-DOES-NOT-FOLLOW-IMSUBR!-ERRORS
				 .RES>)>
		   <COND (.TEMP-FILE? <PRIN1 .RES .TMP-CODE>)>
		   <PUTREST .CP <SET CP (<CHTYPE [<2 <CHTYPE .IMS VECTOR>>
						  <2 <CHTYPE .RES VECTOR>>
						  <G=? <CHTYPE .ITM FIX> 0>
						  <3 <CHTYPE .RES VECTOR>>
						  <4 <CHTYPE .RES VECTOR>>
						  ()
						  <>
						  <ABS <CHTYPE .ITM FIX>>
						  <ARG-SPEC <3 <CHTYPE .RES
								       VECTOR>>>
						  <LIST !.OBLIST>]
						 GLUE-INFO>)>>
		   <COND (.TEMP-FILE? <GUNASSIGN <2 <CHTYPE .IMS VECTOR>>>)>
		   <PUTPROP <2 <CHTYPE .RES VECTOR>> INFO <1 .CP>>>
		 <COND (<EMPTY? .FILES>
			<RETURN>)>
		 <CLOSE .C>
		 <COND (<SET C <OPEN "READ" <1 .FILES>>>
			<SET FILES <REST .FILES>>
			<SETG INCHANS (.C)>)
		       (<ERROR .C FILE-MIMOC>)>>
	       <CLOSE .C>
	       <COND (.TEMP-FILE?
		      <CHANNEL-OP .TMP-TXT ACCESS 0>
		      <CHANNEL-OP .TMP-CODE ACCESS 0>)>
	       <SET OBP <REST ,OBJ-LIST>>
	       <SET CP <REST ,CODE-LIST>>
	       <PROG ((ST <STRING .FNM1 ".GSUBR">))
		     <COND (<OR <NOT <TYPE? .ST STRING>>
				<NOT <SET OC <OPEN "PRINT" .ST>>>>
			    <SET ST <ERROR CANT-OPEN-OUTPUT!-ERRORS
					   .ST
					   ERRET-CORRECT-NAME!-ERRORS>>
			    <AGAIN>)>>
	       <COND (<G? <LENGTH ,ALL-PACKAGES> 3>
		      <REPEAT ((ALL-P:LIST <REST ,ALL-PACKAGES>) NP
			       (OBLIST:<SPECIAL ANY> .OBLIST) ITM:<FORM ATOM>)
			      <COND (<EMPTY? .ALL-P> <RETURN>)>
			      <COND (<==? <1 .ITM> PACKAGE>
				     <PRIN1 .ITM .OC>
				     <SET NP <LOOKUP <2 .ITM> #OBLIST PACKAGE>>)
				    (<ASSIGNED? NP>
				     <SET OBLIST (<CHTYPE .NP OBLIST> <ROOT>)>
				     <PRIN1 .ITM .OC>)>
			      <CRLF .OC>
			      <SET ALL-P <REST .ALL-P>>>)>
	       <REPEAT (INM ITM (FIRST T) (OBLIST .OBLIST))
		       #DECL ((OBLIST) <SPECIAL ANY>)
		       <COND (.TEMP-FILE? <SET ITM <READ .TMP-TXT '<RETURN>>>)
			     (<NOT <EMPTY? .OBP>>
			      <SET ITM <1 .OBP>>
			      <SET OBLIST <GETPROP .OBP BLOCK '.OBLIST>>
			      <SET OBP <REST .OBP>>)
			     (ELSE <RETURN>)>
		       <COND (<TYPE? .ITM GLUED-ATOM>
			      <COND (.FIRST
				     <GLUE-IT .CP .TMP-CODE .OC
					      <SET INM <CHTYPE .ITM ATOM>>
					      .EST-LNT>
				     <SET FIRST <>>)>
			      <WRITE-MSUBR <1 .CP> .OC .INM>
			      <SET CP <REST .CP>>)
			     (ELSE <PRIN1 .ITM .OC> <CRLF .OC>)>>
	       <CLOSE .OC>
	       T)
	      (<ASSIGNED? TMP-CODE>
	       <FLUSH .TMP-TXT>
	       <CLOSE .C>
	       .TMP-CODE)
	      (<ASSIGNED? TMP-TXT>
	       <CLOSE .C>
	       .TMP-TXT)
	      (ELSE .C)>>

<DEFINE FINISH-FILE (INCHAN OUTCHAN EXPFLOAD "AUX" (IND '(1)) OBP)
  #DECL ((INCHAN) CHANNEL (OUTCHAN) <OR CHANNEL FALSE> (EXPFLOAD) <OR ATOM FALSE>
	 (OBP) <LIST ANY>)
  <COND (<NOT .OUTCHAN> <SET OBP ,OBJ-PTR>)>
  <REPEAT (RES ITM NCH (OOBL <LIST !.OBLIST>))
    <COND (<==? <SET ITM <READ .INCHAN '.IND>> .IND>
	   <COND (<EMPTY? <SETG INCHANS <REST ,INCHANS>>>
		  <COND (<NOT .OUTCHAN> <SETG OBJ-PTR .OBP>)>
		  <RETURN <>>)>
	   <SET INCHAN <1 ,INCHANS>>
	   <AGAIN>)>
    <UNASSIGN NCH>
    <COND (<AND <TYPE? .ITM FORM>
		<G? <LENGTH .ITM> 1>
		<OR <==? <1 .ITM> PACKAGE> <==? <1 .ITM> ENTRY>>>
	   <PUTREST ,ALL-P <SETG ALL-P (.ITM)>>)
	  (<AND .EXPFLOAD
		<TYPE? .ITM FORM>
		<NOT <EMPTY? .ITM>>
		<PROG OUT ()
		      <COND (<==? <1 .ITM> FLOAD>
			     <SET NCH <OPEN "READ" !<REST .ITM>>>)
			    (<==? <1 .ITM> L-FLOAD>
			     <SET NCH <L-OPEN <2 .ITM>>>)
			    (ELSE <RETURN <>>)>
		      <COND (<NOT .NCH>
			     <PROG (NM)
				   <COND (<SET NM
					       <ERROR
						.NCH
						ERRET-NAME-OR-FALSE!-ERROS>>
					  <COND (<NOT <SET NCH <OPEN "READ" .NM>>>
						 <AGAIN>)>)
					 (ELSE
					  <RETURN <> .OUT>)>>)>
		      1>>
	   <SET INCHAN .NCH>
	   <SETG INCHANS (.NCH !,INCHANS)>)
	  (ELSE
	   <SET RES <>>
	   <COND (<NOT <ASSIGNED? NCH>> <SET RES <EVAL .ITM>>)>
	   <COND (<AND .RES <TYPE? .RES IMSUBR>>
		  <COND (.OUTCHAN
			 <PRIN1 <CHTYPE <2 .RES> GLUED-ATOM> .OUTCHAN>)
			(ELSE
			 <PUTREST .OBP
				  <SET OBP (<CHTYPE <2 .RES> GLUED-ATOM>)>>)>
		  <COND (<NOT .OUTCHAN> <SETG OBJ-PTR .OBP>)>
		  <RETURN .RES>)
		 (.OUTCHAN <PRIN1 .ITM .OUTCHAN>)
		 (ELSE
		  <PUTREST .OBP <SET OBP (.ITM)>>
		  <COND (<N=? .OOBL .OBLIST>
			 <PUTPROP .OBP BLOCK <SET OOBL <LIST !.OBLIST>>>)>)>)>>>

<SETG OUTPUT-LENGTH 1024>

<GDECL (OUTPUT-LENGTH) FIX>

<SETG OUTPUT-BUFFER <ISTRING ,OUTPUT-LENGTH>>

<DEFINE GLUE-IT (CP CHAN? OC NAM LNT
		 "AUX" (IMS (T)) (IMP .IMS) (NUM 0)
		       (NEW-CODE <IUVECTOR <+ </ .LNT 2> .LNT>>)
		       (OB ,OUTPUT-BUFFER) CNUM (CHRS 0))
	#DECL ((IMSP IMP) LIST (CP) <LIST [REST GLUE-INFO]> (CHRS OL LNT NUM) FIX
	       (OB) STRING)
	<MAPF <>
	      <FUNCTION (G-O) #DECL ((G-O) GLUE-INFO)
		   <FINAL-LOC .G-O .NUM>
		   <MAPF <>
			 <FUNCTION (LOC) #DECL ((LOC) FIX)
			      <PUT .NEW-CODE
				   .LOC
				   <ORB <NTH .NEW-CODE .LOC> .NUM>>>
			 <REFS .G-O>>
		   <REFS .G-O ()>
		   <SET NUM <DO-ONE-GLUE <COND (.CHAN? <READ .CHAN?>)
					       (ELSE ,<IMSUBR-NAME .G-O>)>
					 .IMS
					 .IMP
					 .NUM
					 <CONST-START .G-O>
					 .NEW-CODE>>
		   <SET IMP <REST .IMS <- <LENGTH .IMS> 1>>>>
	      .CP>
	<SET CNUM .NUM>
	<MAPF <>
	      <FUNCTION (C) #DECL ((C) CONST-REF)
		   <MAPF <>
			 <FUNCTION (LOC) #DECL ((LOC) FIX)
			      <PUT .NEW-CODE .LOC <ORB <NTH .NEW-CODE .LOC>
						       .CNUM>>>
			 <C-REFS .C>>
		   <SET CNUM <+ .CNUM 1>>
		   <C-REFS .C ()>>
	      <REST ,CONST-LIST>>
	<PRINC "<SETG " .OC>
	<PRIN1 .NAM .OC>
	<PRINC " #IMSUBR [|" .OC>
	<PRINTBYTE <LSH .CNUM -16>>
	<PRINTBYTE <LSH .CNUM -8>>
	<PRINTBYTE .CNUM>
	<MAPF <>
	      <FUNCTION (WRD)
		   #DECL ((WRD) FIX)
		   <REPEAT ((I 4)) #DECL ((I) FIX)
			   <PRINTBYTE <SET WRD <ROT .WRD 9>>>
			   <COND (<==? <SET I <- .I 1>> 0> <RETURN>)>>
		   <COND (<L=? <SET NUM <- .NUM 1>> 0> <MAPLEAVE>)>>
	      .NEW-CODE>
	<MAPF <>
	      <FUNCTION (C "AUX" (WRD <C-VALUE .C>))
		   #DECL ((C) CONST-REF (WRD) FIX)
		   <REPEAT ((I 4)) #DECL ((I) FIX)
			   <PRINTBYTE <SET WRD <ROT .WRD 9>>>
			   <COND (<==? <SET I <- .I 1>> 0> <RETURN>)>>>
	      <REST ,CONST-LIST>>
	<CHANNEL-OP .OC WRITE-BUFFER ,OUTPUT-BUFFER
		    <- ,OUTPUT-LENGTH <LENGTH .OB>>>
	<PRINC "| " .OC>
	<PRIN1 .NAM .OC>
	<MAPF <>
	      <FUNCTION (OBJ)
		   <PRINC !\ .OC>
		   <PRIN1 .OBJ .OC>>
	      <REST .IMS>>
	<PRINC "]>" .OC>
	<CRLF .OC>>

<DEFINE WRITE-MSUBR (G-I OC INM) #DECL ((G-I) GLUE-INFO)
	<PRINC "<SETG " .OC>
	<PRIN1 <MSUBR-NAME .G-I> .OC>
	<PUTPROP <MSUBR-NAME .G-I> INFO>
	<PRINC " #MSUBR [" .OC>
	<PRIN1 .INM .OC>
	<PRINC !\ .OC>
	<PRIN1 <MSUBR-NAME .G-I> .OC>
	<PRINC !\  .OC>
	<PRIN1 <MSUBR-DECL .G-I> .OC>
	<PRINC !\  .OC>
	<PRIN1 <FINAL-LOC .G-I> .OC>
	<PRINC "]>" .OC>
	<CRLF .OC>>

<DEFINE DO-ONE-GLUE (IMS MV MVP CURR CONST-S CV
		     "AUX" (COD <1 .IMS>) (REL-PC 0) (FRM-STACK ())
			   (GLUE-CALL-NO 0) (PC-DIFF 0)
			   (FRAME-CHANGES (T)) (FCP .FRAME-CHANGES)
			   (CV-LN <LENGTH .CV>) FUDGE (OUT-CNT <+ .CURR 1>))
	#DECL ((IMS) IMSUBR (MV MVP FRM-STACK FCP FRAME-CHANGES) LIST
	       (CALLS) <VECTOR [REST ATOM]>
	       (CV-LN REL-PC OUT-CNT GLUE-CALL-NO CURR CONST-S) FIX
	       (COD) CODE (DB) <LIST [REST GLUE-INFO]> (CV) <UVECTOR [REST FIX]>)
	<MAPR <>
	      <FUNCTION (IP "AUX" TMP (INS <1 .IP>) MOB (NARG <>) LD-NARG 
				  LD-AT AC MI MA (INDX <GETBITS .INS ,INDX-BP>))
		   #DECL ((MI MA AC INS INDX LD-AT LD-NARG) FIX
			  (NARG) <OR FALSE FIX>)
		   <COND (<==? .INS ,JSP-FRAME>
			  <SET FRM-STACK (<+ .REL-PC 1> !.FRM-STACK)>)
			 (<==? .INS ,JSP-SFRAME>
			  <SET FRM-STACK (-1 !.FRM-STACK)>)
			 (<==? .INS ,JSP-CALL>
			  <COND (<EMPTY? .FRM-STACK>
				 <ERROR BAD-CODE-UNMATCHED-FRAME-CALL!-ERRORS>)
				(<==? <1 .FRM-STACK> -1>
				 <SET FRM-STACK <REST .FRM-STACK>>)
				(ELSE
				 <REPEAT ((N <- <LENGTH .COD> <LENGTH .IP>>) I AC)
				  #DECL ((AC I N) FIX)
				  <COND (<==? <SET AC
						   <GETBITS <SET I <NTH .COD .N>>
							    ,AC-BP>>
					      ,O1>
					 <SET MOB
					      <NTH .IMS
						   <+ </ <ANDB .I *777777*>
							 2> 1>>>
					 <SET LD-AT .N>
					 <RETURN>)
					(<AND <==? .AC ,O2>
					      <==? <GETBITS .I ,INS-BP> ,MOVEI>>
					 <SET LD-NARG .N>
					 <SET NARG <ANDB .I *777777*>>)
					(<==? .AC ,O2> <SET LD-NARG .N>)>
				  <COND (<L=? <SET N <- .N 1>> 0>
					 <ERROR
					  BAD-CODE-NO-LOAD-OF-MSUBR!-ERRORS>)>>
				 <COND (<AND <GASSIGNED? .MOB>
					     <TYPE? <SET MOB
							 <GETPROP .MOB INFO>>
						    GLUE-INFO>
					     <GLUED-CALL-OK? .MOB>
					     <NOT <COND
						   (<AND
						     .NARG
						     <OR <G?
							  .NARG
							  <SET MA
							       <LSH <MIN-MAX-ARGS
								     .MOB>
								    -18>>>
							 <L?
							  .NARG
							  <SET MI
							       <ANDB <MIN-MAX-ARGS
								      .MOB>
								     *777777*>>>>>
						    <PRINC
						     <STRING
						      "Wrong number args to "
						      <SPNAME <MSUBR-NAME .MOB>>
						      " from "
						      <2 .IMS>
						      " supplied= "
						      <UNPARSE .NARG>
						      " max= "
						      <UNPARSE .MA>
						      " min= "
						      <UNPARSE .MI>
						      " not glued!"> ,OUTCHAN>
						    <CRLF ,OUTCHAN>
						    T)>>>
					<PUT .IP 1
					     <+ .GLUE-CALL-NO ,GLUE-CALL-INS>>
					<PUT .COD .LD-AT
					     <+ .GLUE-CALL-NO ,GLUE-LOAD-MS-INS>>
					<PUT .COD <CHTYPE <1 .FRM-STACK> FIX>
					     <+ .GLUE-CALL-NO ,GLUE-FRM-INS>>
					<SET FCP
					     <REST <PUTREST .FCP
							    (.MOB
							     <NTH .COD .LD-NARG>
							     <1 .FRM-STACK>)>
						   3>>
					<COND (<AND .NARG <==? .MI .MA>>
					       <PUT .COD .LD-NARG
						    <+ .GLUE-CALL-NO
						       ,GLUE-LOAD-ARG>>)> 
					<SET GLUE-CALL-NO <+ .GLUE-CALL-NO 4>>)>
				 <SET FRM-STACK <REST .FRM-STACK>>)>)
			 (<MEMQ .INS ,FUNNY-CALLS>
			  <SET FRM-STACK <REST .FRM-STACK>>)>
		   <COND (<G=? <SET REL-PC <+ .REL-PC 1>> .CONST-S>
			  <MAPLEAVE>)>>
	      .COD>
	<SET REL-PC 0>
	<SET FCP <REST .FRAME-CHANGES>>
	<MAPR <>
	      <FUNCTION (IP "AUX" TMP (INS <1 .IP>) MOB
				  CCOD (INDX <GETBITS .INS ,INDX-BP>))
		   #DECL ((CCOD INS INDX) FIX)
		   <COND (<L=? <ABS .INS> *777777*>
			  <COND (<==? <SET CCOD <ANDB .INS 3>> ,GLUE-FRM-INS>
				 <UPDATE-JUMPS <+ .REL-PC .PC-DIFF> .COD 4>
				 <SET PC-DIFF <+ .PC-DIFF 4>>)
				(<==? .CCOD ,GLUE-LOAD-MS-INS> <SET FUDGE <>>)
				(<==? .CCOD ,GLUE-LOAD-ARG> <SET FUDGE T>)
				(<OR .FUDGE
				     <N==? <GETBITS <SET INS <2 .FCP>> ,INS-BP>
					   ,MOVEI>>
				 <UPDATE-JUMPS <+ .REL-PC .PC-DIFF> .COD
					       <COND (.FUDGE -1) (ELSE 2)>>
				 <SET PC-DIFF <+ .PC-DIFF
						 <COND (.FUDGE -1) (ELSE 2)>>>)>
			  <COND (<==? .CCOD ,GLUE-CALL-INS>
				 <SET FCP <REST .FCP 3>>)>)
			 (<==? .INDX ,M>
			  <SET MOB <NTH .IMS <+ </ <ANDB .INS *777777*> 2> 1>>>
			  <COND (<SET TMP <MEMBER .MOB <REST .MV>>>)
				(ELSE
				 <PUTREST .MVP <SET TMP (.MOB)>>
				 <SET MVP .TMP>)>
			  <SET INS <PUTBITS .INS ,ADDR-BP
					    <+ <* <- <LENGTH .MV>
						     <LENGTH .TMP> -1> 2>
					       <MOD <GETBITS .INS
							     ,ADDR-BP> 2>>>>
			  <PUT .IP 1 .INS>)>
		   <COND (<G=? <SET REL-PC <+ .REL-PC 1>> .CONST-S>
			  <MAPLEAVE>)>>
	      .COD>
	<SET REL-PC 0>
	<SET FCP <REST .FRAME-CHANGES>>
	<MAPR <>
	      <FUNCTION (IP "AUX" (INS <1 .IP>) TMP MOB CCOD G-I FL
				  (INDX <GETBITS .INS ,INDX-BP>))
		   #DECL ((CCOD INS INDX) FIX (G-I) GLUE-INFO (FL) <OR FALSE FIX>)
		   <COND (<L? <- .CV-LN .OUT-CNT> 5>
			  <ERROR OUTPUT-CODE-VECTOR-OVERFLOW!-ERRORS>)>
		   <COND (<G? <SET REL-PC <+ .REL-PC 1>> .CONST-S>
			  <PUT .CV .OUT-CNT .INS>)
			 (<L=? <ABS .INS> *777777*>
			  <COND (<==? <SET CCOD <ANDB .INS 3>> ,GLUE-FRM-INS>
				 <PUT .CV .OUT-CNT ,SKIPL-T-1-PARENF>
				 <PUT .CV <SET OUT-CNT <+ .OUT-CNT 1>> ,HRROI-T>
				 <PUT .CV <SET OUT-CNT <+ .OUT-CNT 1>> ,PUSH-TP-T>
				 <PUT .CV <SET OUT-CNT <+ .OUT-CNT 1>>
				      ,PUSH-TP-PARENR>
				 <PUT .IP 1 .OUT-CNT>
				 <PUT .CV <SET OUT-CNT <+ .OUT-CNT 1>> ,PUSH-TP-F>)
				(<==? .CCOD ,GLUE-CALL-INS>
				 <COND (<N==? <GETBITS <SET INS <2 .FCP>> ,INS-BP>
					      ,MOVEI>
					<PUT .CV .OUT-CNT ,XMOVEI-F-1-TP>
					<PUT .CV <SET OUT-CNT <+ .OUT-CNT 1>>
					     ,SUB-F-O2>
					<PUT .CV <SET OUT-CNT <+ .OUT-CNT 1>>
					     ,SUB-F-O2>)
				       (ELSE
					<PUT .CV .OUT-CNT
					     <ORB ,XMOVEI-TP
						  <ANDB <- <+ <* <ANDB .INS
								       *777777*> 2>
							      1>>
							*777777*>>>)>
				 <SET OUT-CNT <+ .OUT-CNT 1>>
				 <COND (<SET FL <FINAL-LOC <SET G-I <1 .FCP>>>>
					<PUT .CV .OUT-CNT <ORB ,JRST-R .FL>>)
				       (ELSE
					<PUT .CV .OUT-CNT ,JRST-R>
					<REFS .G-I (.OUT-CNT !<REFS .G-I>)>)>
				 <ADD-CONST <ORB ,SETZ-R .OUT-CNT>
					    <NTH .COD <3 .FCP>>>
				 <SET FCP <REST .FCP 3>>)
				(ELSE <SET OUT-CNT <- .OUT-CNT 1>>)>)
			 (<==? .INDX ,R>
			  <PUT .CV
			       .OUT-CNT
			       <ORB <ANDB .INS *777777000000*>
				    <ANDB <+ .INS .CURR> *777777*>>>)
			 (ELSE <PUT .CV .OUT-CNT .INS>)>
		   <SET OUT-CNT <+ .OUT-CNT 1>>>
	      .COD>
	<- .OUT-CNT 1>>

<DEFINE ADD-CONST (X WHERE) #DECL ((X) FIX)
	<COND (<MAPF <>
		     <FUNCTION (C-R) #DECL ((C-R) CONST-REF)
			  <COND (<==? <C-VALUE .C-R> .X>
				 <C-REFS .C-R (.WHERE !<C-REFS .C-R>)>
				 <MAPEAVE T>)>>
		     <REST ,CONST-LIST>>)
	      (ELSE
	       <PUTREST ,CONST-PTR 
			<SETG CONST-PTR (<CHTYPE [.X (.WHERE)] CONST-REF>)>>)>>
			  

<DEFINE UPDATE-JUMPS (WHERE COD HOW-MUCH)
	#DECL ((COD) CODE (WHERE HOW-MUCH) FIX)
	<MAPR <>
	      <FUNCTION (IP "AUX" AD (INS <1 .IP>)
			 (INDX <GETBITS .INS ,INDX-BP>))
		   #DECL ((AD INS INDX) FIX)
		   <COND (<AND <==? .INDX ,R>
			       <G? <SET AD <ANDB .INS *777777*>> .WHERE>
			       <L? .AD *400000*>>
			  <PUT .IP
			       1
			       <ORB <ANDB .INS *777777000000*>
				    <ANDB <+ .AD .HOW-MUCH> *777777*>>>)>>
	      .COD>> 

<DEFINE ARG-SPEC (DCL "AUX" (MIN 0) (MAX 0) (OPT <>))
	#DECL ((DCL) LIST (MIN MAX) FIX)
	<COND (<OR <EMPTY? .DCL> <N=? <1 .DCL> "VALUE">>
	       <LSH -1 18>)
	      (ELSE
	       <MAPF <>
		     <FUNCTION (EL)
			  <COND (<TYPE? .EL ATOM FORM SEGMENT>
				 <SET MAX <+ .MAX 1>>
				 <COND (<NOT .OPT>
					<SET MIN <+ .MIN 1>>)>)
				(<MEMBER .EL '["OPT" "OPTIONAL" "ARGS"]>
				 <SET OPT T>)
				(<=? .EL "QUOTE">)
				(<=? .EL "TUPLE">
				 <SET MAX *777777*>
				 <MAPLEAVE>)
				(ELSE <ERROR BAD-DECL!-ERRORS>)>>
		     <REST .DCL 2>>
	       <ORB <LSH .MAX 18> .MIN>)>>

<DEFINE GET-NM1 (STR "AUX" (SEEN-OP <>)) #DECL ((STR) STRING)
	<MAPF ,STRING <FUNCTION (CH) <COND (<==? .CH !\<> <SET SEEN-OP T>)
					   (<==? .CH !\>> <SET SEEN-OP <>>)
					   (<AND <NOT .SEEN-OP>
						 <==? .CH !\.>> <MAPSTOP>)
					   (ELSE .CH)>> .STR>>

<ENDPACKAGE>