
<PACKAGE "CARGEN">

<ENTRY ARITH-GEN
       ABS-GEN
       FLOAT-GEN
       FIX-GEN
       MOD-GEN
       ROT-GEN
       LSH-GEN
       1?-GEN
       GEN-FLOAT
       GENFLOAT
       MIN-MAX
       0-TEST
       FLIP
       TEST-GEN>

<USE "COMPDEC" "CODGEN" "CHKDCL" "STRGEN" "MIMGEN" "ADVMESS">

"	This file contains analyzers and code generators for arithmetic
 SUBRs and predicates.  For convenience many of the SUBRs that are
similar are combined into one analyzer/generator.  For more info
on analyzers see SYMANA and on generators see CODGEN.
"

"A type TRANS specifies to an inferior node what arithmetic transforms are
prohibited, permitted or desired.  A transform consists of 3 main elements:
a NODE, an input, an output.  The input and output are UVECTORS of 7 fixes:

1)	negative ok	0-no, 1-ok, 2-pref
2)	+ or - const ok	0-no, 1-ok, 2-pref
3)	const for + or -
4)	* or / const ok	0-no, 1-* ok, 2-* pref, 3-/ ok, 4-/ pref
5)	hw ok		0-no, 1-ok, 2-pref
6)	hw swapped also	0-no, 1-ok, 2-pref
"

<SETG SNODES <UVECTOR ,QUOTE-CODE ,LVAL-CODE ,GVAL-CODE>>

<SETG SNODES1 <REST ,SNODES>>

<GDECL (SNODES SNODES1) <UVECTOR [REST FIX]>>

<DEFINE COMMUTE (K OP L "AUX" TT FK KK TYP NN N CD CD1) 
   #DECL ((K KK FK) <LIST [REST NODE]> (N NN) NODE (CD1 CD) FIX (L) LIST)
   <PROG ((REDO <>))
     <COND (<EMPTY? .K> <RETURN>)>
     <COND (<EMPTY? <SET KK <REST <SET FK .K>>>> <RETURN>)>
     <SET TYP <ISTYPE? <RESULT-TYPE <1 .KK>>>>
     <REPEAT ()
       <AND <EMPTY? .KK> <RETURN>>
       <COND
	(<==? .TYP <SET TYP <ISTYPE? <RESULT-TYPE <SET NN <1 .KK>>>>>>
	 <SET CD1 <NODE-TYPE .NN>>
	 <COND
	  (<AND <==? <SET CD <NODE-TYPE <SET N <1 .FK>>>> ,QUOTE-CODE>
		<==? .CD1 ,QUOTE-CODE>>
	   <PUT .N ,NODE-NAME <APPLY ,.OP <NODE-NAME .N> <NODE-NAME .NN>>>
	   <PUTREST .FK <SET KK <REST .KK>>>
	   <SET REDO T>
	   <AGAIN>)
	  (<==? .CD ,QUOTE-CODE> <PUT .KK 1 .N> <PUT .FK 1 .NN> <SET REDO T>)
	  (<AND <NOT <MEMQ .CD1 ,SNODES>>
		<MEMQ .CD ,SNODES>
		<N==? .CD1 ,SEG-CODE>
		<NOT <SIDE-EFFECTS .NN>>>
	   <COND (<AND <==? .CD ,LVAL-CODE>
		       <COND (<==? <LENGTH <SET TT <TYPE-INFO .N>>> 2> <2 .TT>)
			     (ELSE T)>
		       <SET TT <NODE-NAME .N>>
		       <NOT <MAPF <>
				  <FUNCTION (LL) 
					  <AND <==? <1 .LL> .TT> <MAPLEAVE>>>
				  .L>>>
		  <SET L ((<NODE-NAME .N> <>) !.L)>)>
	   <PUT .KK 1 .N>
	   <PUT .FK 1 .NN>
	   <SET REDO T>)>)>
       <SET KK <REST <SET FK .KK>>>>
     <COND (.REDO <SET REDO <>> <AGAIN>)>
     .K>
   .L>

" Generate code for +,-,* and /."

<DEFINE ARITH-GEN AG (NOD WHERE
		      "AUX" REG (K <KIDS .NOD>) REG1 T1
			    (ATYP <LENGTH <CHTYPE <MEMQ <NODE-NAME .NOD>
							'[/ * - +]>
						  VECTOR>>)
			    TT (MODE 1) (TEM <1 .K>) SEGF SHFT TRIN
			    (COM <OR <==? .ATYP 1> <==? .ATYP 3>>) INA
			    (DONE <>) (NEGF <>) (ONO .NO-KILL)
			    (NO-KILL .NO-KILL) TRAN)
   #DECL ((NOD TEM TT) NODE (K) <LIST [REST NODE]> (ATYP MODE) FIX
	  (WHERE COM) ANY (NO-KILL) <SPECIAL LIST>
	  (TRANSFORM TRAN) TRANS)
   <SET NO-KILL
	<COMMUTE <REST .K <NTH '![0 1 0 1!] .ATYP>>
		 <NTH '[+ + * *] .ATYP>
		 .NO-KILL>>
   <COND
    (<AND <==? <RESULT-TYPE .NOD> FIX>
	  <==? <LENGTH .K> 2>
	  <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>>
     <COND
      (<AND <ASSIGNED? TRANSFORM>
	    <==? <PARENT .NOD> <1 <SET TRAN .TRANSFORM>>>
	    <SET TRIN <2 .TRAN>>
	    <COND
	     (<AND <L=? .ATYP 2>
		   <OR <1? <2 .TRIN>>
		       <AND <==? <2 .TRIN> 2>
			    <==? <3 .TRIN>
				 <COND (<1? .ATYP>
					<- <CHTYPE <NODE-NAME <2 .K>> FIX>>)
				       (ELSE <NODE-NAME <2 .K>>)>>>>>
	      <PUT <PUT <3 .TRAN> 2 1>
		   3
		   <COND (<1? .ATYP> <- <CHTYPE <NODE-NAME <2 .K>> FIX>>)
			 (ELSE <NODE-NAME <2 .K>>)>>)
	     (<AND <==? .ATYP 3>
		   <OR <1? <4 .TRIN>>
		       <AND <==? <4 .TRIN> 4>
			    <==? <5 .TRIN> <NODE-NAME <2 .K>>>>>>
	      <PUT <PUT <3 .TRAN> 4 4> 5 <NODE-NAME <2 .K>>>)
	     (ELSE <>)>>
       <RETURN <GEN <1 .K> .WHERE> .AG>)
      (<N==? <NODE-TYPE <SET TEM <1 .K>>> ,SEG-CODE>
       <PROG ((TRANSFORM
	       <MAKE-TRANS .NOD
			   0
			   <COND (<L? .ATYP 3> 2) (ELSE 0)>
			   <COND (<1? .ATYP> <NODE-NAME <2 .K>>)
				 (<==? .ATYP 2> <- <CHTYPE <NODE-NAME <2 .K>>
							   FIX>>)
				 (ELSE 0)>
			   <COND (<G? .ATYP 2>
				  <COND (<==? .ATYP 3> 2) (ELSE 4)>)
				 (ELSE 0)>
			   <COND (<G? .ATYP 2> <NODE-NAME <2 .K>>) (ELSE 1)>
			   0
			   0>))
	     #DECL ((TRANSFORM) <SPECIAL TRANS>)
	     <SET REG <GEN .TEM DONT-CARE>>
	     <SET DONE T>
	     <MAPF <>
		   <FUNCTION (NN) 
			   #DECL ((NN) FIX)
			   <COND (<NOT <0? .NN>>
				  <RETURN <MOVE-ARG .REG .WHERE> .AG>)>>
		   <3 .TRANSFORM>>>)>)>
   <COND (.DONE)
	 (<==? <NODE-TYPE <SET TEM <1 .K>>> ,SEG-CODE>
	  <SET REG1 <GEN <SET TEM <1 <KIDS .TEM>>> <GEN-TEMP <>>>>
	  <SET MODE
	       <SEGINS .ATYP
		       T
		       .TEM
		       <SET REG
			    <COND (<==? .WHERE DONT-CARE>
				   <SET WHERE <GEN-TEMP <>>>)
				  (<OR <NOT <TYPE? .WHERE TEMP>>
				       <G? <TEMP-REFS .WHERE> 0>>
				   <GEN-TEMP <>>)
				  (ELSE .WHERE)>>
		       .REG1
		       1
		       <GET-DF <NODE-NAME .NOD>>>>)
	 (ELSE
	  <SET REG <GEN .TEM>>
	  <COND (<AND <==? .WHERE DONT-CARE>
		      <TYPE? .REG TEMP>
		      <L? <TEMP-REFS .REG> 2>>
		 <SET WHERE .REG>)
		(<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP <>>>)>
	  <COND (<AND <TYPE? .REG TEMP> <NOT <EMPTY? <REST .K>>>>
		 <SET REG <INTERF-CHANGE .REG <2 .K>>>)>
	  <COND (<==? <RESULT-TYPE .TEM> FLOAT> <SET MODE 2>)>)>
   <MAPR <>
    <FUNCTION (N
	       "AUX" NN TEM TRANSFORM
		     (NXT
		      <COND
		       (<==? <NODE-TYPE <SET NN <1 .N>>> ,SEG-CODE>
			<SET SEGF T>
			<GEN <SET NN <1 <KIDS .NN>>>>)
		       (ELSE
			<SET SEGF <>>
			<SET TRANSFORM
			     <MAKE-TRANS .NOD
					 <COND (<AND .NEGF <G? .ATYP 2>> 2)
					       (ELSE 1)>
					 0
					 0
					 0
					 0
					 0
					 0>>
			<GEN .NN DONT-CARE>)>) (COM .COM)
		     (LAST <EMPTY? <REST .N>>))
	    #DECL ((N) <LIST NODE> (MODE) FIX (NN) NODE
		   (TRANSFORM) <SPECIAL TRANS>)
	    <COND (.SEGF
		   <COND (<OR <NOT <TYPE? .NXT TEMP>> <G? <TEMP-REFS .NXT> 1>>
			  <SET NXT <MOVE-ARG .NXT <GEN-TEMP <>>>>)>
		   <SET MODE <SEGINS .ATYP <> .NN .REG .NXT .MODE 0>>
		   <FREE-TEMP .NXT>)
		  (ELSE
		   <AND <ASSIGNED? TRANSFORM>
			<NOT <0? <1 <3 .TRANSFORM>>>>
			<PROG ()
			      <SET COM <NOT .COM>>
			      <SET NEGF <NOT .NEGF>>>>
		   <COND (<==? .MODE 2>
			  <COND (<==? <ISTYPE? <RESULT-TYPE .NN>> FIX>
				 <SET NXT
				      <GEN-FLOAT .NXT <PROT .NXT FLOAT>>>)>)
			 (<==? <ISTYPE? <RESULT-TYPE .NN>> FLOAT>
			  <SET REG <GEN-FLOAT .REG <PROT .REG FLOAT>>>
			  <SET MODE 2>)>
		   <COND (<AND <==? .ATYP 3>
			       <==? .MODE 1>
			       <==? <NODE-TYPE .NN> ,QUOTE-CODE>
			       <SET SHFT <POPWR2 <NODE-NAME .NN>>>>
			  <SET REG <SHIFT-INS .REG .SHFT .ATYP .LAST .WHERE>>)
			 (ELSE
			  <SET REG
			       <ARITH-INS <COND (<AND .NEGF <L? .ATYP 3>>
						 <SET NEGF <>>
						 <- 3 .ATYP>)
						(ELSE .ATYP)>
					  .REG
					  .NXT
					  .MODE
					  .LAST
					  .WHERE>>)>
		   <FREE-TEMP .NXT>)>>
    <REST .K>>
   <COND (.NEGF
	  <COND (<AND <ASSIGNED? TRANSFORM>
		      <==? <1 <SET TRAN .TRANSFORM>> <PARENT .NOD>>
		      <NOT <0? <1 <2 .TRAN>>>>>
		 <PUT <3 .TRAN> 1 1>)
		(ELSE <GEN-NEGATE .REG>)>)>
   <DELAY-KILL .NO-KILL .ONO>
   <MOVE-ARG .REG .WHERE>>

<DEFINE PROT (DAT TYP) 
	<COND (<TYPE? .DAT TEMP> <DEALLOCATE-TEMP .DAT>)>
	<COND (<AND <TYPE? .DAT TEMP> <L=? <TEMP-REFS .DAT> 0>>
	       <USE-TEMP .DAT .TYP>
	       .DAT)
	      (<TYPE? .DAT TEMP> <GEN-TEMP .TYP>)
	      (ELSE .DAT)>>

<DEFINE SHIFT-INS (REG SHFT ATYP LAST W) 
	#DECL ((SHFT ATYP) FIX)
	<GEN-SHIFT .REG
		   <COND (<==? .ATYP 3> .SHFT) (ELSE <- .SHFT>)>
		   <SET REG <COND (<AND .LAST <N==? .REG .W>>
				   <FREE-TEMP .REG <>>
				   <COND (<==? .W DONT-CARE>
					  <GEN-TEMP FIX>)
					 (<TYPE? .W TEMP> <USE-TEMP .W FIX> .W)
					 (ELSE .W)>)
				  (<TYPE? .REG TEMP> .REG)
				  (ELSE <GEN-TEMP <>>)>>>
	.REG>

<DEFINE SEGINS (ATYP FD N REG REG2 MD DEFLT
		"AUX" SAC SL TYP (STYP <RESULT-TYPE .N>) (TG <MAKE-TAG>)
		      (LOOP <MAKE-TAG>) RAC)
	#DECL ((N) NODE (ATYP SL MD) FIX)
	<SET TYP <COND (<==? <GET-ELE-TYPE .STYP ALL> FIX> 1) (ELSE 2)>>
	<SET STYP <STRUCTYP .STYP>>
	<SET SL <MINL <RESULT-TYPE .N>>>
	<COND (.FD
	       <SET MD .TYP>
	       <AND <==? .TYP 2> <==? .DEFLT 1> <SET DEFLT 1.0>>
	       <COND (<L? .SL 1>
		      <SET-TEMP .REG
				.DEFLT
				(`TYPE <COND (<==? .TYP 1> FIX) (ELSE FLOAT)>)>
		      <EMPTY-JUMP .STYP .REG2 .TG>)>
	       <COND (<OR <==? .ATYP 2> <==? .ATYP 4>>
		      <SET REG <GETEL .REG .REG2 .STYP>>
		      <ADVANCE .STYP .REG2>
		      <SET SL <- .SL 1>>)
		     (ELSE <SET SL 1>)>)
	      (<AND <1? .MD> <==? .TYP 2>>
	       <SET REG <GEN-FLOAT .REG <PROT .REG FLOAT>>>)>
	<COND (<L? .SL 1> <EMPTY-JUMP .STYP .REG2 .TG>)>
	<LABEL-TAG .LOOP>
	<EMITSEG .REG .REG2 .STYP .ATYP .TYP .MD>
	<ADVANCE-AND-CHECK .STYP .REG2 .LOOP>
	<LABEL-TAG .TG>
	.MD>

<DEFINE ADVANCE (STYP SAC "AUX" AMT) 
	#DECL ((STYP) ATOM (AMT) FIX)
	<SET AMT <COND (<==? .STYP UVECTOR> 1) (ELSE 2)>>
	<COND (<==? .STYP LIST>
	       <NTH-LIST .SAC 1 .SAC>)
	      (<==? .STYP UVECTOR>
	       <NTH-UVECTOR .SAC .SAC 1>) 
	      (ELSE
	       <NTH-VECTOR .SAC .SAC 1>)>>

<DEFINE ADVANCE-AND-CHECK (STYP SAC TG) 
	#DECL ((STYP) ATOM)
	<COND (<==? .STYP LIST>
	       <REST-LIST .SAC .SAC 1>
	       <EMPTY-LIST .SAC .TG <>>)
	      (<==? .STYP VECTOR>
	       <REST-VECTOR .SAC .SAC 1>
	       <EMPTY-VECTOR .SAC .TG <>>)
	      (ELSE
	       <REST-UVECTOR .SAC .SAC 1>
	       <EMPTY-UVECTOR .SAC .TG <>>)>>

<DEFINE EMPTY-JUMP (STYP SAC TG) 
	#DECL ((STYP TG) ATOM)
	<COND (<==? .STYP LIST>
	       <EMPTY-LIST .SAC .TG T>)
	      (<==? .STYP VECTOR>
	       <EMPTY-VECTOR .SAC .TG T>)
	      (ELSE
	       <EMPTY-UVECTOR .SAC .TG T>)>>

<DEFINE EMITSEG (RAC SAC STYP ATYP TYP MD "AUX" DAT (TMP <GEN-TEMP>)) 
	#DECL ((TYP MD ATYP) FIX)
	<COND (<AND <==? .MD 2> <==? .TYP 1>>
	       <GETEL .TMP .SAC .STYP>
	       <GEN-FLOAT .TMP .TMP>
	       <GENINS .ATYP .MD .RAC .TMP>)
	      (ELSE <GETEL .TMP .SAC .STYP> <GENINS .ATYP .MD .RAC .TMP>)>
	<FREE-TEMP .TMP>>

<DEFINE GENINS (ATYP MD RAC ADD "AUX" INS (TG <MAKE-TAG>)) 
	#DECL ((MD ATYP) FIX)
	<COND (<G? .ATYP 4>
	       <IEMIT <NTH '[`GRTR? `LESS?] <- .ATYP 4>> .RAC .ADD + .TG>
	       <IEMIT `SET .RAC .ADD>
	       <LABEL-TAG .TG>)
	      (ELSE
	       <SET INS <NTH <NTH ,INS1 .MD> .ATYP>>
	       <IEMIT .INS
		      .RAC
		      .ADD
		      =
		      .RAC
		      (`TYPE <COND (<==? .MD 1> FIX) (ELSE FLOAT)>)>)>>

<DEFINE GETEL (RAC SAC STYP) 
	<COND (<==? .RAC DONT-CARE> <SET RAC <GEN-TEMP>>)>
	<COND (<==? .STYP LIST> <NTH-LIST .SAC .RAC 1>)
	      (<==? .STYP VECTOR> <NTH-VECTOR .SAC .RAC 1>)
	      (ELSE <NTH-UVECTOR .SAC .RAC 1>)>
	.RAC>

<SETG INS1 [[`ADD `SUB `MUL `DIV] [`ADDF `SUBF `MULF `DIVF]]>

<GDECL (INS1) !<VECTOR [2 !<VECTOR [4 ANY]>]>>

" Do the actual arithmetic code generation here with all args set up."

<DEFINE ARITH-INS (ATYP REG REG2 MODE LAST W "AUX" INS) 
	#DECL ((ATYP MODE REFS) FIX)
	<SET INS <NTH <NTH ,INS1 .MODE> .ATYP>>
	<IEMIT .INS
	       .REG
	       .REG2
	       =
	       <SET REG
		    <COND (<AND .LAST <N==? .REG .W>>
			   <FREE-TEMP .REG <>>
			   <COND (<==? .W DONT-CARE>
				  <GEN-TEMP <COND (<==? .MODE 1> FIX)
						  (ELSE FLOAT)>>)
				 (<TYPE? .W TEMP>
				  <USE-TEMP .W <COND (<==? .MODE 1> FIX)
						     (ELSE FLOAT)>> .W)
				 (ELSE .W)>)
			  (<AND .LAST <==? .REG .W>> .REG)
			  (<AND <TYPE? .REG TEMP> <L=? <TEMP-REFS .REG> 1>>
			   .REG)
			  (<AND <TYPE? .W TEMP> <L? <TEMP-REFS .W> 1>>
			   <USE-TEMP .W <COND (<==? .MODE 1> FIX)
					      (ELSE FLOAT)>>
			   .W)
			  (ELSE
			   <FREE-TEMP .REG>
			   <GEN-TEMP <COND (<==? .MODE 1> FIX)
					   (ELSE FLOAT)>>)>>
	       <COND (<==? .MODE 2> '(`TYPE FLOAT))(ELSE '(`TYPE FIX))>>
	.REG>

<DEFINE MIN-MAX (NOD WHERE
		 "AUX" (MAX? <==? MAX <NODE-NAME .NOD>>) (K <KIDS .NOD>) REG
		       (MODE 1) REG1 SEGF (C <OR <AND .MAX? 5> 6>) TEM
		       (ONO .NO-KILL) (NO-KILL .ONO))
   #DECL ((NOD) NODE (MODE C) FIX (MAX?) ANY  (K) <LIST [REST NODE]>
	  (NO-KILL) <SPECIAL LIST>)
   <SET NO-KILL <COMMUTE .K <NODE-NAME .NOD> .NO-KILL>>
   <SET REG <GEN-TEMP <>>>
   <COND (<==? <NODE-TYPE <SET TEM <1 .K>>> ,SEG-CODE>
	  <SET REG1
	       <GEN <SET TEM <1 <KIDS .TEM>>> <GEN-TEMP <>>>>
	  <SET MODE
	       <SEGINS .C
		       T
		       .TEM
		       .REG
		       .REG1
		       1
		       <CHTYPE <OR <AND .MAX? <MAX>> <MIN>>
			       <RESULT-TYPE .NOD>>>>
	  <FREE-TEMP .REG1>)
	 (ELSE
	  <SET REG <GEN .TEM .REG>>
	  <AND <==? <RESULT-TYPE .TEM> FLOAT> <SET MODE 2>>)>
   <MAPF <>
    <FUNCTION (N
	       "AUX" (NXT
		      <COND
		       (<==? <NODE-TYPE .N> ,SEG-CODE>
			<SET SEGF T>
			<GEN <SET N <1 <KIDS .N>>> <GEN-TEMP <>>>)
		       (ELSE <SET SEGF <>> <GEN .N DONT-CARE>)>) TG)
       #DECL ((N) NODE (MODE) FIX)
       <COND (.SEGF
	      <SET MODE <SEGINS .C <> .N .REG .NXT .MODE 0>>)
	     (ELSE
	      <COND (<==? .MODE 2>
		     <COND (<==? <ISTYPE? <RESULT-TYPE .N>> FIX>
			    <SET NXT <GEN-FLOAT .NXT <PROT .NXT FLOAT>>>)>)
		    (<==? <ISTYPE? <RESULT-TYPE .N>> FLOAT>
		     <SET REG <GEN-FLOAT .REG <PROT .REG FLOAT>>>
		     <SET MODE 2>)>
	      <IEMIT <COND (.MAX? `LESS?) (ELSE `GRTR?)> .REG .NXT -
		     <SET TG <MAKE-TAG>>>
	      <SET-TEMP .REG .NXT (`TYPE <COND (<==? .MODE 2> FLOAT)
					       (ELSE FIX)>)>
	      <FREE-TEMP .NXT>
	      <LABEL-TAG .TG>)>>
    <REST .K>>
   <DELAY-KILL .NO-KILL .ONO>
   <MOVE-ARG .REG .WHERE>>

<DEFINE ABS-GEN ACT (N W
		     "AUX" (K1 <1 <KIDS .N>>) NUM (TRIN <>)
			   (ABSFLG <==? <NODE-NAME .N> ABS>) (DONE <>) W1
			   TG (RT <RESULT-TYPE .N>))
   #DECL ((N K1) NODE (TRANSFORM) TRANS)
   <PROG ((TRANSFORM <MAKE-TRANS .N 2 0 0 0 1 0 0>))
	 #DECL ((TRANSFORM) <SPECIAL TRANS>)
	 <SET NUM <GEN .K1 <COND (<==? .W ,POP-STACK> DONT-CARE) (ELSE .W)>>>
	 <COND (<NOT <0? <1 <3 .TRANSFORM>>>>
		<RETURN <MOVE-ARG .NUM .W> .ACT>)>>
   <COND (<AND <ASSIGNED? TRANSFORM>
	       <==? <1 .TRANSFORM> <PARENT .N>>
	       <NOT .ABSFLG>>
	  <SET TRIN <2 .TRANSFORM>>)>
   <COND (<AND .TRIN <NOT <0? <1 .TRIN>>>>
	  <PUT <3 .TRANSFORM> 1 1>
	  <MOVE-ARG .NUM .W>)
	 (ELSE
	  <COND (.ABSFLG
		 <COND (<TYPE? .W TEMP> <USE-TEMP <SET W1 .W> .RT>)
		       (<AND <TYPE? .NUM TEMP> <L=? <TEMP-REFS .NUM> 1>>
			<SET W1 .NUM>)
		       (ELSE <SET W1 <GEN-TEMP .RT>>)>
		 <COND (<N==? .NUM .W1>
			<DEALLOCATE-TEMP <SET NUM <MOVE-ARG .NUM .W1>>>)>
		 <DO-LESS? .NUM <SET TG <MAKE-TAG>> .RT>
		 <DO-SUB .NUM .W1 .RT>
		 <LABEL-TAG .TG>
		 <SET W <MOVE-ARG .W1 .W>>)
		(ELSE
		 <COND (<AND <==? .W DONT-CARE>
			     <TYPE? .NUM TEMP>
			     <L=? <TEMP-REFS .NUM> 1>>
			<SET W .NUM>)
		       (<==? .W DONT-CARE> <SET W <GEN-TEMP .RT>>)>
		 <DO-SUB .NUM .W .RT>
		 <COND (<N==? .W .NUM> <FREE-TEMP .NUM>)>)>
	  .W)>>

<DEFINE DO-SUB (NUM W TY "AUX" TG1 TG2) 
	#DECL ((TG1 TG2) ATOM)
	<COND (<==? <ISTYPE? .TY> FIX> <IEMIT `SUB 0 .NUM = .W '(`TYPE FIX)>)
	      (<==? <ISTYPE? .TY> FLOAT>
	       <IEMIT `SUBF 0 .NUM = .W '(`TYPE FLOAT)>)
	      (ELSE
	       <SET TG1 <MAKE-TAG>>
	       <SET TG2 <MAKE-TAG>>
	       <GEN-TYPE? .NUM FIX .TG1 <>>
	       <IEMIT `SUB 0 .NUM = .W '(`TYPE FIX)>
	       <BRANCH-TAG .TG2>
	       <LABEL-TAG .TG1>
	       <COND (<TYPE-OK? .TY '<NOT <OR FIX FLOAT>>>
		      <GEN-TYPE? .NUM FLOAT `COMPERR <>>)>
	       <IEMIT `SUBF 0.0000000 .NUM = .W '(`TYPE FLOAT)>
	       <LABEL-TAG .TG2>)>>


<DEFINE DO-LESS? (NUM TG TY "AUX" TG1 TG2) 
	#DECL ((TG1 TG2) ATOM)
	<COND (<==? <ISTYPE? .TY> FIX>
	       <IEMIT `LESS? .NUM 0 - .TG '(`TYPE FIX)>)
	      (<==? <ISTYPE? .TY> FLOAT>
	       <IEMIT `LESS? .NUM 0.0 - .TG '(`TYPE FLOAT)>)
	      (ELSE
	       <SET TG1 <MAKE-TAG>>
	       <SET TG2 <MAKE-TAG>>
	       <GEN-TYPE? .NUM FIX .TG1 <>>
	       <IEMIT `LESS? .NUM 0 - .TG '(`TYPE FIX)>
	       <BRANCH-TAG .TG2>
	       <LABEL-TAG .TG1>
	       <COND (<AND .CAREFUL <TYPE-OK? .TY '<NOT <OR FIX FLOAT>>>>
		      <GEN-TYPE? .NUM FLOAT `COMPERR <>>)>
	       <IEMIT `LESS? .NUM 0.0 - .TG '(`TYPE FLOAT)>
	       <LABEL-TAG .TG2>)>>

<DEFINE MOD-GEN (N W
		 "AUX" (N1 <1 <KIDS .N>>) (N2 <2 <KIDS .N>>)
		       W1 W2)
   #DECL ((N) NODE)
   <COND
    (<AND <==? <NODE-TYPE .N2> ,QUOTE-CODE>
	  <POPWR2 <NODE-NAME .N2>>>
     <FREE-TEMP <SET W1 <GEN .N1 DONT-CARE>>>
     <IEMIT `AND .W1 <- <CHTYPE <NODE-NAME .N2> FIX> 1> =
		       <COND (<TYPE? .W TEMP>
			      <USE-TEMP .W FIX>
			      .W)
			     (<==? .W DONT-CARE>
			      <SET W <GEN-TEMP FIX>>)
			     (ELSE .W)>>)
    (ELSE
     <COND (<AND <MEMQ <NODE-TYPE .N1> ,SNODES>
		 <NOT <MEMQ <NODE-TYPE .N2> ,SNODES>>
		 <NOT <SIDE-EFFECTS .N2>>>
	    <SET W2 <GEN .N2 DONT-CARE>>
	    <SET W2 <INTERF-CHANGE .W2 .N1>>
	    <SET W1 <GEN .N1 DONT-CARE>>)
	   (ELSE
	    <SET W1 <GEN .N1 DONT-CARE>>
	    <SET W1 <INTERF-CHANGE .W1 .N2>>
	    <SET W2 <GEN .N2 DONT-CARE>>)>
     <FREE-TEMP .W1 <>>
     <FREE-TEMP .W2 <>>
     <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP FIX>>)
	   (<TYPE? .W TEMP> <USE-TEMP .W FIX>)>
     <IEMIT `MOD .W1 .W2 = .W '(`TYPE FIX)>)>
   .W>

<DEFINE ROT-GEN (N W) <ROT-LSH-GEN .N .W `ROT>>

<DEFINE LSH-GEN (N W) <ROT-LSH-GEN .N .W `LSH>>

<DEFINE ROT-LSH-GEN (N W INS
		     "AUX" (K <KIDS .N>) (A1 <1 .K>) (A2 <2 .K>) W1 W2)
	#DECL ((N A1 A2) NODE (K) <LIST [2 NODE]>)
	<COND (<==? <NODE-TYPE .A2> ,QUOTE-CODE>
				 ;" LSH-ROT by fixed amount"
	       <SET W1 <GEN .A1 DONT-CARE>>
	       <FREE-TEMP .W1 <>>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP FIX>>)
		     (<TYPE? .W TEMP> <USE-TEMP .W FIX>)>
	       <IEMIT .INS .W1 <NODE-NAME .A2> = .W '(`TYPE FIX)>)
	      (ELSE
	       <COND (<AND <MEMQ <NODE-TYPE .A1> ,SNODES>
			   <NOT <MEMQ <NODE-TYPE .A2> ,SNODES>>
			   <NOT <SIDE-EFFECTS .A2>>>
		      <SET W2 <GEN .A2 DONT-CARE>>
		      <SET W2 <INTERF-CHANGE .W2 .A1>>
		      <SET W1 <GEN .A1 DONT-CARE>>)
		     (ELSE
		      <SET W1 <GEN .A1 DONT-CARE>>
		      <SET W1 <INTERF-CHANGE .W1 .A2>>
		      <SET W2 <GEN .A2 DONT-CARE>>)>
	       <FREE-TEMP .W1 <>>
	       <FREE-TEMP .W2 <>>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP FIX>>)
		     (<TYPE? .W TEMP> <USE-TEMP .W FIX>)>
	       <IEMIT .INS .W1 .W2 = .W '(`TYPE FIX)>)>
	.W>

<DEFINE FLOAT-GEN (N W
		   "AUX" (NUM <1 <KIDS .N>>) TEM1 (RT <RESULT-TYPE .NUM>) TG
			 TEM)
	#DECL ((N NUM) NODE (TG) ATOM)
	<COND (<==? .RT FLOAT>
	       <COMPILE-WARNING "Unnecessary FLOAT: " .N>
	       <GEN .NUM .W>)
	      (<==? <ISTYPE? .RT> FIX>
	       <SET TEM <GEN .NUM>>
	       <FREE-TEMP .TEM <>>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP FLOAT>>)
		     (<TYPE? .W TEMP> <USE-TEMP .W FLOAT>)>
	       <GEN-FLOAT .TEM .W>
	       .W)
	      (ELSE
	       <COND (<OR <NOT <TYPE? .W TEMP>>
			  <NOT <TEMP-NO-RECYCLE .W>>
			  <N==? <TEMP-NO-RECYCLE .W> ANY>>
		        <SET TEM <GEN-TEMP <>>>)
		     (ELSE <SET TEM .W>)>
	       <SET TEM <GEN .NUM .TEM>>
	       <SET TG <MAKE-TAG>>
	       <GEN-TYPE? .TEM FLOAT .TG T>
	       <GEN-FLOAT .TEM .TEM>
	       <LABEL-TAG .TG>
	       <COND (<N==? .TEM .W> <MOVE-ARG .TEM .W>)
		     (ELSE .W)>)>>

<DEFINE FIX-GEN (N W
		 "AUX" (NUM <1 <KIDS .N>>) (RT <RESULT-TYPE .NUM>) TEM TEM1
		       BR)
	#DECL ((N NUM) NODE (BR) ATOM)
	<COND (<==? <ISTYPE? .RT> FIX>
	       <COMPILE-WARNING "Unnecessary  FIX: " .N>
	       <GEN .NUM .W>)
	      (<==? .RT FLOAT>
	       <SET TEM <GEN .NUM>>
	       <FREE-TEMP .TEM <>>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP FIX>>)
		     (<TYPE? .W TEMP> <USE-TEMP .W FIX>)>
	       <GEN-FIX .TEM .W>
	       .W)
	      (ELSE
	       <COND (<OR <NOT <TYPE? .W TEMP>>
			  <NOT <TEMP-NO-RECYCLE .W>>
			  <N==? <TEMP-NO-RECYCLE .W> ANY>>
		        <SET TEM <GEN-TEMP <>>>)
		     (ELSE <SET TEM .W>)>
	       <SET TEM <GEN .NUM .TEM>>
	       <GEN-TYPE? .TEM FIX <SET BR <MAKE-TAG>> T>
	       <GEN-FIX .TEM .TEM>
	       <LABEL-TAG .BR>
	       <COND (<N==? .TEM .W> <MOVE-ARG .TEM .W>)
		     (ELSE .W)>)>>

<DEFINE GEN-FLOAT (DAT W)
	<COND (<TYPE? .DAT FIX> <FLOAT .DAT>)
	      (ELSE
	       <IEMIT `FLOAT .DAT = .W '(`TYPE FLOAT)>
	       .W)>>

<DEFINE GEN-FIX (DAT "OPTIONAL" (W <GEN-TEMP <>>))
	<COND (<TYPE? .DAT FLOAT> <FIX .DAT>)
	      (ELSE
	       <IEMIT `FIX .DAT = .W '(`TYPE FIX)>
	       .W)>>

<DEFINE FLOP (SUBR) 
	#DECL ((SUBR VALUE) ATOM)
	<1 <REST <MEMQ .SUBR
		       '[G? L? G? G=? L=? G=? ==? ==? N==? N==? 1? -1? 1? 0?
			 0?]>>>>

<DEFINE FLIP (SUBR "AUX" N) 
	#DECL ((N) FIX (SUBR VALUE) ATOM)
	<NTH ,0SUBRS
	     <- 13
		<SET N <LENGTH <CHTYPE <MEMQ .SUBR ,0SUBRS> VECTOR>>>
		<COND (<0? <MOD .N 2>> -1) (ELSE 1)>>>>



<DEFINE PRED? (N) #DECL ((N) FIX) <N==? <NTH ,PREDV .N> 0>>

<DEFINE LN-LST (N) 
	#DECL ((N) NODE)
	<AND <==? <NODE-TYPE .N> ,LNTH-CODE>
	     <==? <STRUCTYP <RESULT-TYPE <1 <KIDS .N>>>> LIST>>>

<DEFINE 0-TEST (NOD WHERE
		"OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		"AUX" (REG ,NO-DATUM) (NN <1 <KIDS .NOD>>)
		      (TRANSFORM
		       <MAKE-TRANS .NOD 1 1 0 1 1 1 <SW? <NODE-NAME .NOD>>>))
	#DECL ((TRANSFORM) <SPECIAL TRANS> (NOD NN) NODE)
	<COND (<NOT <LN-LST .NN>>
	       <SET REG <GEN .NN DONT-CARE>>)>
	<TEST-DISP .NOD
		   .WHERE
		   .NOTF
		   .BRANCH
		   .DIR
		   .REG
		   <DO-A-TRANS 0 .TRANSFORM>
		   <NOT <0? <1 <3 .TRANSFORM>>>>
		   .SETF>>

<DEFINE SW? (SBR) 
	#DECL ((SBR) ATOM)
	<COND (<MEMQ .SBR '[0? N0? 1? -1? N1? N-1? ==? N==?]> 0)
	      (ELSE 1)>>

<DEFINE MAKE-TRANS (N NEG +- +-V */ */V HW SW) 
	#DECL ((N) NODE (NEG +- +-V */ */V HW SW) FIX)
	<CHTYPE [.N <UVECTOR .NEG .+- .+-V .*/ .*/V .HW .SW> <IUVECTOR 7 0>]
		TRANS>>

<DEFINE DO-A-TRANS (N TR "AUX" (X <3 .TR>) (NN <NODE-NAME <1 .TR>>)) 
	#DECL ((TR) TRANS (N) FIX (X) <UVECTOR [7 FIX]>)
	<COND (<AND <NOT <0? .N>> <NOT <0? <6 .X>>> <NOT <0? <7 .X>>>>
	       <COND (<==? .NN G?> <SET N <- .N 1>>)
		     (<==? .NN L=?> <SET N <- .N 1>>)>)>
	<COND (<NOT <0? <1 .X>>> <SET N <- .N>>)>
	<COND (<NOT <0? <2 .X>>> <SET N <+ .N <3 .X>>>)>
	<COND (<G? <4 .X> 2> <SET N </ .N <5 .X>>>)
	      (<NOT <0? <4 .X>>> <SET N <* .N <5 .X>>>)>
	<COND (<NOT <0? <6 .X>>>
	       <SET N <CHTYPE <ANDB .N 262143> FIX>>
	       <COND (<NOT <0? <7 .X>>>
		      <SET N <CHTYPE <PUTBITS 0 <BITS 18 18> .N> FIX>>)>)>
	.N>

<DEFINE UPDATE-TRANS (NOD TR "AUX" (X <3 .TR>) FLG) 
	#DECL ((TR) TRANS)
	<MAKE-TRANS .NOD
		    <COND (<NOT <0? <1 .X>>> 2) (ELSE 0)>
		    <COND (<SET FLG <NOT <0? <2 .X>>>> 2) (ELSE 0)>
		    <COND (.FLG <3 .X>) (ELSE 0)>
		    <COND (<SET FLG <G? <4 .X> 2>> 4)
			  (<SET FLG <NOT <0? <4 .X>>>> 2)
			  (ELSE 0)>
		    <COND (.FLG <5 .X>) (ELSE 1)>
		    <COND (<NOT <0? <6 .X>>> 2) (ELSE 0)>
		    <COND (<NOT <0? <7 .X>>> 2) (ELSE 0)>>>

<DEFINE TEST-DISP (N W NF BR DI REG NUM NEG SF) 
	#DECL ((NUM) <OR FIX FLOAT> (N) NODE)
	<COND (<==? .REG ,NO-DATUM> <LIST-LNT-SPEC .N .W .NF .BR .DI .NUM .SF>)
	      (<0? .NUM> <0-TEST1 .N .W .NF .BR .DI .REG .NEG .SF>)
	      (<AND <OR <==? .NUM 1> <==? .NUM 1.0> <==? .NUM -1>>
		    <OR <==? <NODE-NAME .N> 1?>
			<==? <ISTYPE? <RESULT-TYPE <1 <KIDS .N>>>> FIX>>>
	       <COND (<==? .NUM -1> <SET NEG T>)>
	       <1?-TEST .N .W .NF .BR .DI .REG .NEG .SF>)
	      (ELSE <TEST-GEN2 .N .W .NF .BR .DI .REG .NUM .NEG .SF>)>>

<DEFINE 0-TEST1 (NOD WHERE NOTF BRANCH DIR REG NEG SF
		 "AUX" (SBR <NODE-NAME .NOD>) B2 (RW .WHERE)
		       (ARG <1 <KIDS .NOD>>) (SDIR .DIR)
		       (ATYP <ISTYPE? <RESULT-TYPE .ARG>>) (LDAT <>) S TT)
	#DECL ((NOD ARG) NODE (S) SYMTAB)
	<SET WHERE <COND (<==? .WHERE DONT-CARE> <GEN-TEMP <>>) (ELSE .WHERE)>>
	<COND (.NEG
	       <COND (<==? <NODE-TYPE .NOD> ,0-TST-CODE> <SET SBR <FLOP .SBR>>)
		     (ELSE
		      <COND (<SET TT <MEMQ .SBR '[G? G=? G? L? L=? L?]>>
			     <SET SBR <2 .TT>>)>)>)>
	<COND (.BRANCH
	       <AND .NOTF <SET DIR <NOT .DIR>>>
	       <AND .DIR <SET SBR <FLIP .SBR>>>
	       <COND (.SF
		      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
	       <COND (<==? .RW FLUSHED>
		      <ZER-JMP .SBR .REG .BRANCH .ATYP>
		      ,NO-DATUM)
		     (ELSE
		      <SET B2 <MAKE-TAG>>
		      <SET SBR <FLIP .SBR>>
		      <ZER-JMP .SBR .REG .B2 .ATYP>
		      <SET RW
			   <MOVE-ARG <REFERENCE .SDIR>
				     <COND (<==? .RW DONT-CARE> <GEN-TEMP <>>)
					   (ELSE .RW)>>>
		      <BRANCH-TAG .BRANCH>
		      <LABEL-TAG .B2>
		      .RW)>)
	      (ELSE
	       <AND .NOTF <SET SBR <FLIP .SBR>>>
	       <ZER-JMP .SBR .REG <SET BRANCH <MAKE-TAG>> .ATYP>
	       <MOVE-ARG <REFERENCE T> .WHERE>
	       <BRANCH-TAG <SET B2 <MAKE-TAG>>>
	       <LABEL-TAG .BRANCH>
	       <MOVE-ARG <REFERENCE <>> .WHERE>
	       <LABEL-TAG .B2>
	       <MOVE-ARG .WHERE .RW>)>>

<DEFINE ZER-JMP (SBR REG BR ATYP "AUX" (TEM <LENGTH <CHTYPE <MEMQ .SBR ,0SUBRS>
							    VECTOR>>)
				       (B1 <MAKE-TAG>) (B2 <MAKE-TAG>)) 
	<COND (.ATYP
	       <IEMIT <NTH ,0SKPS .TEM> .REG
		      <COND (<==? .ATYP FIX> 0)
			    (ELSE 0.0)> <NTH ,0JSENS .TEM> .BR
		      (`TYPE .ATYP)>
	       <FREE-TEMP .REG>)
	      (<==? <NTH ,0SKPS .TEM> `VEQUAL?>
	       <IEMIT `VEQUAL? .REG 0 <NTH ,0JSENS .TEM> .BR '(`TYPE FIX)>
	       <FREE-TEMP .REG>)
	      (ELSE
	       <IEMIT <NTH ,0SKPS .TEM> .REG 0 <NTH ,0JSENS .TEM> .BR>
	       <FREE-TEMP .REG>)>>

<SETG 0SKPS [`VEQUAL? `VEQUAL? `LESS? `LESS? `GRTR? `GRTR? `VEQUAL? `VEQUAL?]>

<SETG 0JSENS [+ - + - + - + -]>

<SETG 0SUBRS [1? N1? -1? N-1? 0? N0? G? L=? L? G=? ==? N==?]>

<DEFINE 1?-GEN (NOD WHERE
		"OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		"AUX" (REG ,NO-DATUM) (NN <1 <KIDS .NOD>>)
		      (TRANSFORM
		       <MAKE-TRANS .NOD 1 2 -1 1 1 1 <SW? <NODE-NAME .NOD>>>))
	#DECL ((NOD NN) NODE (TRANSFORM) <SPECIAL TRANS>)
	<COND (<NOT <LN-LST .NN>>
	       <SET REG <GEN .NN DONT-CARE>>)>
	<TEST-DISP .NOD
		   .WHERE
		   .NOTF
		   .BRANCH
		   .DIR
		   .REG
		   <DO-A-TRANS 1 .TRANSFORM>
		   <NOT <0? <1 <3 .TRANSFORM>>>>
		   .SETF>>

<DEFINE 1?-TEST (NOD WHERE NOTF BRANCH DIR REG NEG SF
		 "AUX" (SBR <NODE-NAME .NOD>) B2 (RW .WHERE)
		       (K <1 <KIDS .NOD>>) (SDIR .DIR) (NM <>)
		       (ATYP <ISTYPE? <RESULT-TYPE .K>>))
	#DECL ((NOD K) NODE)
	<SET WHERE <COND (<==? .WHERE DONT-CARE> <GEN-TEMP <>>) (ELSE .WHERE)>>
	<COND (.BRANCH
	       <AND .NOTF <SET DIR <NOT .DIR>>>
	       <COND (.SF
		      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
	       <COND (<==? .RW FLUSHED>
		      <GEN-COMP .ATYP .REG .DIR .BRANCH .SBR .NEG .NM>
		      ,NO-DATUM)
		     (ELSE
		      <SET B2 <MAKE-TAG>>
		      <GEN-COMP .ATYP .REG <NOT .DIR> .B2 .SBR .NEG .NM>
		      <SET RW
			   <MOVE-ARG <MOVE-ARG <REFERENCE .SDIR> .WHERE> .RW>>
		      <BRANCH-TAG .BRANCH>
		      <LABEL-TAG .B2>
		      .RW)>)
	      (ELSE
	       <SET WHERE
		    <COND (<==? .WHERE DONT-CARE> <GEN-TEMP <>>)
			  (ELSE .WHERE)>>
	       <GEN-COMP .ATYP
			 .REG
			 .NOTF
			 <SET BRANCH <MAKE-TAG>>
			 .SBR
			 .NEG
			 .NM>
	       <MOVE-ARG <REFERENCE T> .WHERE>
	       <BRANCH-TAG <SET B2 <MAKE-TAG>>>
	       <LABEL-TAG .BRANCH>
	       <MOVE-ARG <REFERENCE <>> .WHERE>
	       <LABEL-TAG .B2>
	       <MOVE-ARG .WHERE .RW>)>>

<DEFINE GEN-COMP (TYP REG DIR BR SBR NEG NM
		  "AUX" TEM (LBL <MAKE-TAG>) (LBL2 <MAKE-TAG>))
	#DECL ((BR) ATOM)
	<COND (<OR <==? .TYP FIX> <==? .TYP FLOAT>>
	       <COND (.DIR <SET SBR <FLIP .SBR>>)>
	       <IEMIT <1 <SET TEM <NTH ,SKIPS <LENGTH <CHTYPE <MEMQ .SBR ,CMSUBRS>
							      VECTOR>>>>>
		      .REG
		      <COND (<==? .TYP FIX> <COND (.NEG -1) (ELSE 1)>)
			    (ELSE <COND (.NEG -1.0) (ELSE 1.0)>)>
		      <2 .TEM>
		      .BR
		      (`TYPE .TYP)>
	       <FREE-TEMP .REG>)
	      (ELSE
	       <GEN-TYPE? .REG FLOAT .LBL <>>
	       <IEMIT `VEQUAL?
		      .REG
		      <COND (.NEG -1.0) (ELSE 1.0)>
		      +
		      <COND (.DIR .BR) (ELSE .LBL2)>
		      '(`TYPE FLOAT)>
	       <COND (<NOT .DIR> <BRANCH-TAG .BR>)
		     (ELSE <BRANCH-TAG .LBL2>)>
	       <LABEL-TAG .LBL>
	       <GEN-TYPE? .REG FIX `COMPERR <>>
	       <IEMIT `VEQUAL?
		      .REG
		      <COND (.NEG -1) (ELSE 1)>
		      <COND (.DIR +) (ELSE -)>
		      .BR
		      '(`TYPE FIX)>
	       <LABEL-TAG .LBL2>
	       <FREE-TEMP .REG>)>>

<DEFINE TEST-GEN (NOD WHERE
		  "OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		  "AUX" (K <1 <KIDS .NOD>>) (K2 <2 <KIDS .NOD>>) REGT REGT2
			(S <SW? <NODE-NAME .NOD>>) TRANSFORM ATYP ATYP2 B2
			(SDIR .DIR) (RW .WHERE) TRANS1 (FLS <==? .RW FLUSHED>)
			TEM (ONO .NO-KILL) (NO-KILL .ONO)
		  "ACT" TA)
   #DECL ((NOD K K2) NODE (TRANSFORM) <SPECIAL TRANS> (TRANS1) TRANS
	  (NO-KILL) <SPECIAL LIST>)
   <SET WHERE
	<COND (<==? .WHERE FLUSHED> FLUSHED)
	      (<==? .WHERE DONT-CARE> <GEN-TEMP <>>)
	      (ELSE .WHERE)>>
   <COND (<OR <==? <NODE-TYPE .K2> ,QUOTE-CODE>
	      <AND <NOT <MEMQ <NODE-TYPE .K> ,SNODES>>
		   <NOT <SIDE-EFFECTS .NOD>>
		   <MEMQ <NODE-TYPE .K2> ,SNODES>>>
	  <COND (<AND <==? <NODE-TYPE .K> ,LVAL-CODE>
		      <COND (<==? <LENGTH <SET TEM <TYPE-INFO .K>>> 2>
			     <2 .TEM>)
			    (ELSE T)>
		      <SET TEM <NODE-NAME .K>>
		      <NOT <MAPF <>
				 <FUNCTION (LL) 
					 <AND <==? <1 .LL> .TEM> <MAPLEAVE>>>
				 .NO-KILL>>>
		 <SET NO-KILL ((<NODE-NAME .K> <>) !.NO-KILL)>)>
	  <SET K .K2>
	  <SET K2 <1 <KIDS .NOD>>>
	  <PUT .NOD ,NODE-NAME <FLOP <NODE-NAME .NOD>>>)>
   <SET ATYP <ISTYPE? <RESULT-TYPE .K2>>>
   <SET ATYP2 <ISTYPE-GOOD? <RESULT-TYPE .K>>>
   <COND
    (<N==? <NODE-TYPE .K> ,QUOTE-CODE>
     <SET REGT2
	  <GEN .K
	       <COND (<AND <N==? .ATYP .ATYP2> <==? .ATYP2 FIX>> <GEN-TEMP <>>)
		     (ELSE DONT-CARE)>>>
     <COND (<ASSIGNED? TRANSFORM>
	    <SET TRANS1 .TRANSFORM>
	    <SET TRANSFORM <UPDATE-TRANS .NOD .TRANS1>>)>
     <SET REGT2 <INTERF-CHANGE .REGT2 .K2>>
     <SET REGT
	  <GEN .K2
	       <COND (<AND <N==? .ATYP .ATYP2> <==? .ATYP FIX>> <GEN-TEMP <>>)
		     (ELSE DONT-CARE)>>>)
    (ELSE
     <COND (<OR <==? .ATYP FIX> <==? <NODE-NAME .K> 0>>
	    <SET TRANSFORM <MAKE-TRANS .NOD 1 1 0 1 1 <+ 2 <- .S>> .S>>)>
     <COND (<==? .ATYP FIX>
	    <PUT <PUT <2 .TRANSFORM> 2 1> 3 <FIX <NODE-NAME .K>>>)>
     <COND (<LN-LST .K2> <SET REGT ,NO-DATUM>) (ELSE <SET REGT <GEN .K2>>)>
     <RETURN <TEST-DISP .NOD
			.WHERE
			.NOTF
			.BRANCH
			.DIR
			.REGT
			<COND (<ASSIGNED? TRANSFORM>
			       <DO-A-TRANS <FIX <NODE-NAME .K>> .TRANSFORM>)
			      (ELSE <NODE-NAME .K>)>
			<AND <ASSIGNED? TRANSFORM>
			     <NOT <0? <1 <3 .TRANSFORM>>>>>
			.SETF>
	     .TA>)>
   <DELAY-KILL .NO-KILL .ONO>
   <AND <ASSIGNED? TRANSFORM>
	'<CONFORM .REGT .REGT2 .TRANSFORM .TRANS1>
	'<PUT .NOD ,NODE-NAME <FLOP <NODE-NAME .NOD>>>>
   <COND (.BRANCH
	  <AND .NOTF <SET DIR <NOT .DIR>>>
	  <COND (.SETF
		 <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
	  <GEN-COMP2 <FLOP <NODE-NAME .NOD>>
		     .ATYP2
		     .ATYP
		     .REGT
		     .REGT2
		     <COND (.FLS .DIR) (ELSE <NOT .DIR>)>
		     <COND (.FLS .BRANCH) (ELSE <SET B2 <MAKE-TAG>>)>>
	  <COND (<NOT .FLS>
		 <SET RW <MOVE-ARG <MOVE-ARG <REFERENCE .SDIR> .WHERE> .RW>>
		 <BRANCH-TAG .BRANCH>
		 <LABEL-TAG .B2>
		 .RW)>)
	 (ELSE
	  <GEN-COMP2 <FLOP <NODE-NAME .NOD>>
		     .ATYP2
		     .ATYP
		     .REGT
		     .REGT2
		     .NOTF
		     <SET BRANCH <MAKE-TAG>>>
	  <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE T> .WHERE>>
	  <BRANCH-TAG <SET B2 <MAKE-TAG>>>
	  <LABEL-TAG .BRANCH>
	  <MOVE-ARG <REFERENCE <>> .WHERE>
	  <LABEL-TAG .B2>
	  <MOVE-ARG .WHERE .RW>)>>

<DEFINE TEST-GEN2 (NOD WHERE NOTF BRANCH DIR REG NUM NEG SF
		   "AUX" (SDIR .DIR) (RW .WHERE) (FLS <==? .RW FLUSHED>) B2
			 (SBR <NODE-NAME .NOD>))
	#DECL ((NOD) NODE (NUM) <OR FIX FLOAT>)
	<SET WHERE
	     <COND (<==? .WHERE FLUSHED> FLUSHED)
		   (<==? .WHERE DONT-CARE> <GEN-TEMP <>>)
		   (ELSE .WHERE)>>
	<COND (.BRANCH
	       <COND (.NEG <SET SBR <FLOP .SBR>>)>
	       <AND .NOTF <SET DIR <NOT .DIR>>>
	       <COND (.SF
		      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
	       <GEN-COMP2 .SBR
			  <TYPE .NUM>
			  <>
			  <REFERENCE .NUM>
			  .REG
			  <COND (.FLS .DIR) (ELSE <NOT .DIR>)>
			  <COND (.FLS .BRANCH) (ELSE <SET B2 <MAKE-TAG>>)>>
	       <COND (<NOT .FLS>
		      <SET RW
			   <MOVE-ARG <MOVE-ARG <REFERENCE .SDIR> .WHERE> .RW>>
		      <BRANCH-TAG .BRANCH>
		      <LABEL-TAG .B2>
		      .RW)>)
	      (ELSE
	       <AND .NOTF <SET DIR <NOT .DIR>>>
	       <COND (.NEG <SET SBR <FLOP .SBR>>)>
	       <GEN-COMP2 .SBR
			  <TYPE .NUM>
			  <>
			  <REFERENCE .NUM>
			  .REG
			  .NOTF
			  <SET BRANCH <MAKE-TAG>>>
	       <MOVE-ARG <REFERENCE T> .WHERE>
	       <BRANCH-TAG <SET B2 <MAKE-TAG>>>
	       <LABEL-TAG .BRANCH>
	       <MOVE-ARG <REFERENCE <>> .WHERE>
	       <LABEL-TAG .B2>
	       <MOVE-ARG .WHERE .RW>)>>

<DEFINE GEN-COMP2 (SB T1 T2 R1 R2 D BR "AUX" TEM) 
	#DECL ((SB BR) ATOM)
	<AND .D <SET SB <FLIP .SB>>>
	<COND (<AND .T1 .T2 <N==? .T1 .T2> <TYPE? .R1 TEMP> <TYPE? .R2 TEMP>>
	       <COND (<==? .T1 FIX>
		      <SET T1 FLOAT>
		      <SET R2 <GEN-FLOAT .R2 .R2>>)>
	       <COND (<==? .T2 FIX>
		      <SET T2 FLOAT>
		      <SET R1 <GEN-FLOAT .R1 .R1>>)>)>
	<COND (<TYPE? .R1 TEMP> <FREE-TEMP .R1 <>>)>
	<COND (<TYPE? .R2 TEMP> <FREE-TEMP .R2 <>>)>
	<IEMIT <1 <SET TEM <NTH ,SKIPS <LENGTH <CHTYPE <MEMQ .SB ,CMSUBRS>
						       VECTOR>>>>>
	       .R2
	       .R1
	       <2 .TEM>
	       .BR
	       (`TYPE <OR .T1 .T2>)>>

<DEFINE GET-DF (S) 
	#DECL ((S) ATOM)
	<NTH ,DF-VALS
	     <LENGTH <CHTYPE <MEMQ .S '[MAX MIN * / - +]> VECTOR>>>>

<DEFINE POPWR2 (X) #DECL ((X) FIX)
	<COND (<==? .X 0> <>)
	      (<==? <CHTYPE <ANDB <- .X> .X> FIX> .X>
	       <REPEAT ((Y 0)) #DECL ((Y) FIX)
		       <COND (<==? .X 1> <RETURN .Y>)>
		       <SET X <CHTYPE <LSH .X -1> FIX>>
		       <SET Y <+ .Y 1>>>)>>

<SETG DF-VALS [0 0 1 1 <MIN> <MAX>]>

<GDECL (SKIPS)
       <VECTOR [REST <LIST ATOM ATOM>]>
       (0SUBRS 0SKPS 0JSENS CMSUBRS)
       <VECTOR [REST ATOM]>
       (DF-VALS)
       VECTOR>

<SETG CMSUBRS '[0? N0? 1? N1? -1? N-1? ==? N==? G? G=? L? L=?]>

<SETG SKIPS
      '[(`LESS? +)
	(`GRTR? -)
	(`GRTR? +)
	(`LESS? -)
	(`VEQUAL? +)
	(`VEQUAL? -)
	(`EQUAL? +)
	(`VEQUAL? -)
	(`VEQUAL? +)
	(`VEQUAL? -)
	(`VEQUAL? +)
	(`VEQUAL? -)]>

<ENDPACKAGE>
