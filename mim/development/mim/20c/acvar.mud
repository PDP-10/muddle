<USE "HASH">

<COND (<NOT <GASSIGNED? WIDTH-MUNG>> <FLOAD "MIMOC20DEFS.MUD">)>

<SETG AC-R 10>

<MANIFEST AC-R>

<SETG SETZ-R <CHTYPE <ORB *400000000000* <LSH ,AC-R 18>> FIX>>

<SETG SETZX-R <CHTYPE <ORB -25769803776 <LSH ,AC-R 18>> FIX>>

<SETG SETZQ-R <CHTYPE <ORB *600000000000* <LSH ,AC-R 18>> FIX>>

<SETG SETZ-IND -34355544064>

<SETG SETZ *400000000000*>

<SETG ACS
      [O*
       0
       A1*
       1
       A2*
       2
       B1*
       3
       B2*
       4
       C1*
       5
       C2*
       6
       T*
       7
       O1*
       8
       O2*
       9
       R*
       10
       M*
       11
       SP*
       12
       F*
       13
       TP*
       14
       P*
       15]>

<REPEAT ((A ,ACS))
	<SETG <1 .A> <2 .A>>
	<COND (<EMPTY? <SET A <REST .A 2>>> <RETURN>)>>

<SETG ACNAMS [A1 A2 B1 B2 C1 C2 T O1 O2 R M SP F TP P]>

<GDECL (ACNAMS) <VECTOR [REST ATOM]>>

<DEFINE NEXTINS (L)
	#DECL ((L) LIST)
	<MAPF <>
	      <FUNCTION (ITM)
		   #DECL ((ITM) <OR ATOM FORM>)
		   <COND (<TYPE? .ITM FORM> <MAPLEAVE .ITM>)>>
	      .L>>

<SETG AC-STAMP 0>

<SETG AC-TABLE
      '[#AC [O* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [A1* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [A2* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [B1* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [B2* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [C1* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [C2* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [X* #FALSE () DUMMY 0 #FALSE () #FALSE ()]
	#AC [T* #FALSE () DUMMY 34359738367 #FALSE () #FALSE ()]]>

<MAPR <>
      <FUNCTION (TBL "AUX" (AC <1 .TBL>)) 
	      #DECL ((TBL) <VECTOR [REST AC]> (AC) AC)
	      <COND (<1? <LENGTH .TBL>>
		     <PUTPROP <AC-NAME .AC> AC .AC>
		     <MAPLEAVE>)
		    (T
		     <PUTPROP <AC-NAME .AC>
			      NEXTAC
			      <COND (<==? <AC-NAME <2 .TBL>> X*> T*)
				    (ELSE <AC-NAME <2 .TBL>>)>>
		     <PUTPROP <COND (<==? <AC-NAME <2 .TBL>> X*> T*)
				    (ELSE <AC-NAME <2 .TBL>>)>
			      AC-PAIR
			      <AC-NAME .AC>>
		     <PUTPROP <COND (<==? <AC-NAME <2 .TBL>> X*> <3 .TBL>)
				    (ELSE <2 .TBL>)>
			      AC-PAIR
			      .AC>
		     <PUTPROP .AC
			      NEXTAC
			      <COND (<==? <AC-NAME <2 .TBL>> X*> T*)
				    (ELSE <AC-NAME <2 .TBL>>)>>
		     <PUTPROP <AC-NAME .AC> AC .AC>)>>
      ,AC-TABLE>

<SETG AC-PAIR-TABLE
      [<2 ,AC-TABLE>
       <3 ,AC-TABLE>
       <4 ,AC-TABLE>
       <5 ,AC-TABLE>
       <6 ,AC-TABLE>
       <7 ,AC-TABLE>]>

<SETG NULL-STATES
      <MAPF ,VECTOR
	    <FUNCTION (AC) <CHTYPE [.AC <> <> <> DUMMY] ACSTATE>>
	    ,AC-PAIR-TABLE>>

<DEFINE NEXT-AC (AC)
	#DECL ((AC) <OR ATOM AC>)
	<COND (<==? .AC STACK> STACK)
	      (T <GETPROP .AC NEXTAC>)>>

<DEFINE GET-AC (AC)
	#DECL ((AC) ATOM (VALUE) AC)
	<GETPROP .AC AC>>

<DEFINE IS-AC? (AC) #DECL ((AC) ATOM)
	<GETPROP .AC AC>>

<DEFINE PA () <PPRINT ,AC-TABLE>>

<DEFINE ASSIGN-AC (ITM TYP "OPTIONAL" (AC-FORCE <>))
	#DECL ((ITM) ANY (TYP) ATOM (AC-FORCE) <OR ATOM FALSE>)
	<COND (<AND <==? .ITM STACK> <NOT .AC-FORCE>> STACK)
	      (T <LOAD-AC .ITM .TYP T T>)>>

<DEFINE IN-AC? (ITM TYP "AUX" (BOTH <==? .TYP BOTH>))
	#DECL ((ITM) ANY (TYP) ATOM (BOTH) <OR FALSE ATOM>)
	<COND (<TYPE? .ITM ATOM>
	       <MAPR <>
		     <FUNCTION (ACT "AUX" (AC <1 .ACT>) NAC)
			  #DECL ((ACT) VECTOR (NAC AC) AC)
			  <COND (<==? .TYP FREE> <MAPLEAVE <>>)
				(<==? <AC-ITEM .AC> .ITM>
				 <COND (.BOTH
					<COND (<AND <==? <AC-CODE .AC> TYPE>
						    <SET NAC <2 .ACT>>
						    <==? <AC-CODE .NAC> VALUE>
						    <==? <AC-ITEM .NAC> .ITM>>
					       <AC-TIME .AC ,AC-STAMP>
					       <AC-TIME .NAC ,AC-STAMP>
					       <MAPLEAVE <AC-NAME .AC>>)>)
				       (<==? <AC-CODE .AC> .TYP>
					<AC-TIME .AC ,AC-STAMP>
					<MAPLEAVE <AC-NAME .AC>>)>)>>
		     ,AC-TABLE>)>>

<DEFINE SMASH-AC (NAM ITM TYP "OPTIONAL" (AC? T) "AUX" AC RAC) 
	#DECL ((NAM TYP) ATOM (RAC) AC (ITM) ANY (AC AC?) <OR FALSE ATOM>)
	<COND (<AND .AC? <SET AC <IN-AC? .ITM .TYP>>>
	       <COND (<==? .TYP BOTH>
		      <SET RAC <GET-AC .NAM>>
		      <COND (<N==? .NAM .AC>
			     <AC-TYPE .RAC <>>
			     <OCEMIT DMOVE .NAM .AC>
			     <FLUSH-AC .AC T>
			     <MUNGED-AC .AC T>)>
		      <COND (<TYPE? .ITM ATOM>
			     <AC-ITEM .RAC .ITM>
			     <AC-CODE .RAC TYPE>
			     <AC-ITEM <SET RAC <GET-AC <NEXT-AC .NAM>>> .ITM>
			     <AC-CODE .RAC VALUE>)
			    (ELSE
			     <AC-CODE .RAC DUMMY>
			     <AC-CODE <GET-AC <NEXT-AC .NAM>> DUMMY>)>)
		     (<==? .NAM .AC>)
		     (T
		      <AC-TYPE <SET RAC <GET-AC .NAM>> <>>
		      <OCEMIT MOVE .NAM .AC>
		      <FLUSH-AC .AC>
		      <MUNGED-AC .AC>
		      <COND (<TYPE? .ITM ATOM>
			     <AC-ITEM .RAC .ITM>
			     <AC-CODE .RAC .TYP>)
			    (ELSE
			     <AC-CODE .RAC DUMMY>)>)>
	       .NAM)
	      (T
	       <LOAD-AC .ITM
			.TYP
			<>
			<>
			<GET-AC .NAM>
			<COND (<==? .TYP BOTH> <GET-AC <NEXT-AC .NAM>>)>>)>>

<DEFINE CLEAN-ACS (ITM)
	#DECL ((ITM) ANY)
	<MAPF <>
	      <FUNCTION (AC)
		   #DECL ((AC) AC)
		   <COND (<==? <AC-ITEM .AC> .ITM>
			  <AC-ITEM .AC <>>
			  <AC-CODE .AC DUMMY>)>>
	      ,AC-TABLE>>

<DEFINE LOAD-TYPE (AC L "AUX" NUM (OFF 0)) 
   #DECL ((AC) ATOM (L) LIST (NUM) <OR CONSTANT FIX CONST-W-LOCAL>
	  (OFF) FIX)
   <COND
    (<1? <LENGTH .L>>
     <SET NUM <CHTYPE <ORB 19595788288 ,<1 .L>> CONSTANT>>)
    (T
     <COND (<==? <LENGTH .L> 3> <SET OFF <1 .L>> <SET L <REST .L>>)>
     <SET NUM
	  <CHTYPE (<1 .L>
		   <+ <CHTYPE <ORB 19595788288 <LSH ,<1 <2 .L>> 18>>
			      FIX>
		      <ANDB .OFF *777777*>>)
		  CONST-W-LOCAL>>)>
   <CONST-ADD .NUM>
   <OCEMIT LDB .AC !<OBJ-VAL .NUM>>>

<DEFINE LOAD-AC (ITM TYP
		 "OPTIONAL" (UPDATE <>) (ASSIGN <>) (LAC <>) (NAC <>)
		 "AUX" (BOTH <==? .TYP BOTH>) (LOW <CHTYPE <MIN> FIX>) AC TIM
		       (FIRST-AC ,FIRST-AC) NUM LCL TAC PT IDX)
   #DECL ((ITM) ANY (TYP) ATOM (LOW TIM) FIX (LAC NAC) <OR AC FALSE>
	  (BOTH UPDATE ASSIGN AC) <OR FALSE ATOM> (NUM) <OR FALSE FIX>
	  (TAC) AC)
   <SETG FIRST-AC <>>
   <SETG AC-STAMP <+ ,AC-STAMP 1>>
   <COND
    (<AND
      <NOT .LAC>
      <TYPE? .ITM ATOM>
      <OR
       <AND <SET AC <IN-AC? .ITM .TYP>> <N==? .AC X*>>
       <AND
	<NOT .AC>
	<==? .TYP BOTH>	       ;"Check if either type or value already winning"
	<OR <AND <SET AC <IN-AC? .ITM TYPE>>
					   ;"Either load value or flush type.."
		 <OR <AND <OR <==? .AC A1*>
			      <==? .AC B1*>
			      <==? .AC B1*>>
			  <LOAD-AC .ITM
				   VALUE
				   .UPDATE
				   .ASSIGN
				   <GET-AC <NEXT-AC .AC>>>
					      ;"Undo what CLEAN-ACS does to AC"
			  <AC-ITEM <AC-CODE <GET-AC .AC> TYPE> .ITM>>
		     <COND (<AC-UPDATE <GET-AC .AC>>
			    <UPDATE-AC <GET-AC .AC>>
			    <AC-UPDATE <GET-AC .AC> <>>
			    <>)>>>
	    <AND <SET AC <IN-AC? .ITM VALUE>>
					  ;"Either load type or flush value..."
		 <OR <AND <OR <==? .AC A2*>
			      <==? .AC B2*>
			      <==? .AC C2*>>
			  <SET AC
			       <LOAD-AC .ITM
					TYPE
					.UPDATE
					.ASSIGN
					<GET-AC <GETPROP .AC AC-PAIR>>>>
					      ;"Undo what CLEAN-ACS does to AC"
			  <AC-ITEM <AC-CODE <GET-AC <NEXT-AC .AC>> VALUE>
				   .ITM>>
		     <COND (<AC-UPDATE <GET-AC .AC>>
			    <UPDATE-AC <GET-AC .AC>>
			    <AC-UPDATE <GET-AC .AC> <>>
			    <>)>>>>>>>
     <COND (.ASSIGN
	    <AC-UPDATE <SET LAC <GET-AC .AC>> .UPDATE>
	    <SETG ACA-AC .LAC>
	    <SETG ACA-ITEM .ITM>
	    <SETG ACA-BOTH .BOTH>
	    <COND (.BOTH
		   <AC-UPDATE <SET NAC <GET-AC <NEXT-AC .AC>>> .UPDATE>
		   <SETG ACA-BOTH .NAC>)>)>
     .AC)
    (T
     <CLEAN-ACS .ITM>
     <OR
      .LAC
      <AND <TYPE? .ITM ATOM>
	   <SET LAC <LOOK-AHEAD <REST .MIML> .ITM .TYP>>
	   <OR .FIRST-AC
	       <AND <NOT <TYPE? <AC-ITEM .LAC> ATOM>>
		    <OR <N==? .TYP BOTH>
			<NOT <TYPE? <AC-ITEM <GET-AC <NEXT-AC .LAC>>> ATOM>>>>>>
      <REPEAT ((ACT <REST ,AC-TABLE>))
	#DECL ((ACT) <VECTOR [REST AC]>)
	<COND
	 (<OR <EMPTY? .ACT> <AND .BOTH <1? <LENGTH .ACT>>>> <RETURN>)
	 (.BOTH
	  <COND
	   (<AND <N==? <AC-NAME <2 .ACT>> X*>
		 <N==? <AC-NAME <1 .ACT>> X*>>
	    <SET TIM <MAX <AC-TIME <1 .ACT>> <AC-TIME <2 .ACT>>>>
	    <COND (<AND .FIRST-AC
			<OR <NOT .LAC>
			    <AND <AC-ITEM .LAC>
				 <OR <NOT <AC-ITEM <1 .ACT>>>
				     <AND <AC-UPDATE .LAC>
					  <NOT <AC-UPDATE <1 .ACT>>>>>>>>
		   <SET LOW <MIN .TIM .LOW>>
		   <SET LAC <1 .ACT>>
		   <SET NAC <2 .ACT>>)
		  (<L=? .TIM .LOW>
		   <COND (<OR <N==? .LOW .TIM>
			      <NOT .LAC>
			      <AND <AC-ITEM .LAC>
				   <OR <NOT <AC-ITEM <1 .ACT>>>
				       <AND <AC-UPDATE .LAC>
					    <NOT <AC-UPDATE <1 .ACT>>>>>>>
			  <SET LOW .TIM>
			  <SET LAC <1 .ACT>>
			  <SET NAC <2 .ACT>>)>)>)>)
	 (<AND <N==? <AC-NAME <1 .ACT>> X*> <N==? <AC-NAME <1 .ACT>> T*>>
	  <SET TIM <AC-TIME <1 .ACT>>>
	  <COND (<AND .FIRST-AC
		      <OR <NOT .LAC>
			  <AND <AC-ITEM .LAC>
			       <OR <NOT <AC-ITEM <1 .ACT>>>
				   <AND <AC-UPDATE .LAC>
					<NOT <AC-UPDATE <1 .ACT>>>>>>>>
		 <SET LAC <1 .ACT>>
		 <SET LOW .TIM>)
		(<L=? .TIM .LOW>
		 <COND (<OR <N==? .LOW .TIM>
			    <NOT .LAC>
			    <AND <AC-ITEM .LAC>
				 <OR <NOT <AC-ITEM <1 .ACT>>>
				     <AND <AC-UPDATE .LAC>
					  <NOT <AC-UPDATE <1 .ACT>>>>>>>
			<SET LOW .TIM>
			<SET LAC <1 .ACT>>)>)>)>
	<COND (.BOTH <SET ACT <REST .ACT 2>>) (T <SET ACT <REST .ACT>>)>>>
     <COND (<AND .BOTH <NOT .NAC>> <SET NAC <GET-AC <NEXT-AC .LAC>>>)>
     <COND (<AC-UPDATE <CHTYPE .LAC AC>> <UPDATE-AC .LAC>)>
     <COND (.ASSIGN
	    <SETG ACA-AC .LAC>
	    <SETG ACA-ITEM .ITM>
	    <SETG ACA-BOTH .BOTH>
	    <AC-ITEM <CHTYPE .LAC AC> #LOSE *000000000000*>)
	   (<TYPE? .ITM ATOM> <AC-ITEM <CHTYPE .LAC AC> .ITM>)
	   (ELSE <AC-ITEM <CHTYPE .LAC AC> <>>)>
     <AC-CODE <CHTYPE .LAC AC> <COND (.BOTH TYPE) (.TYP)>>
     <OR <==? .LAC <GET-AC T*>> <AC-TIME <CHTYPE .LAC AC> ,AC-STAMP>>
     <AC-TYPE <CHTYPE .LAC AC> <>>
     <COND (.BOTH
	    <COND (<AC-UPDATE <CHTYPE .NAC AC>> <UPDATE-AC .NAC>)>
	    <COND (.ASSIGN
		   <SETG ACA-BOTH .NAC>
		   <AC-ITEM <CHTYPE .NAC AC> #LOSE *000000000000*>)
		  (<TYPE? .ITM ATOM> <AC-ITEM <CHTYPE .NAC AC> .ITM>)
		  (ELSE <AC-ITEM <CHTYPE .NAC AC> <>>)>
	    <AC-CODE <CHTYPE .NAC AC> VALUE>
	    <AC-TIME <CHTYPE .NAC AC> ,AC-STAMP>
	    <AC-UPDATE <CHTYPE .NAC AC> .UPDATE>
	    <AC-TYPE <CHTYPE .NAC AC> <>>)>
     <AC-UPDATE <CHTYPE .LAC AC> .UPDATE>
     <COND (.ASSIGN)
	   (<TYPE? .ITM ATOM>
	    <COND (<OR <SET LCL <LMEMQ .ITM ,LOCALS>>
		       <AND ,ICALL-FLAG <SET LCL <LMEMQ .ITM ,ICALL-TEMPS>>>>
		   <SET ITM <LNAME <CHTYPE .LCL LOCAL>>>
		   <SET IDX <COND (,WINNING-VICTIM '(TP*)) (ELSE '(F*))>>
		   <COND (.BOTH
			  <OCEMIT DMOVE .LAC <- ,STACK-DEPTH> .ITM .IDX>)
			 (<==? .TYP VALUE>
			  <OCEMIT MOVE .LAC <- 1 ,STACK-DEPTH> .ITM .IDX>)
			 (<==? .TYP LENGTH>
			  <OCEMIT HRRZ .LAC <- ,STACK-DEPTH> .ITM .IDX>)
			 (<==? .TYP TYPECODE>
			  <LOAD-TYPE <AC-NAME <CHTYPE .LAC AC>>
				     (<- ,STACK-DEPTH> .ITM .IDX)>)
			 (T <OCEMIT MOVE .LAC <- ,STACK-DEPTH> .ITM .IDX>)>)
		  (T <MIMOCERR UNKNOWN-LOCAL!-ERRORS .ITM>)>)
	   (<AND <OR <AND <OR <==? <SET PT <PRIMTYPE .ITM>> WORD> <==? .PT FIX>>
			  <OR <L? <ABS <CHTYPE .ITM FIX>> ,MAX-IMMEDIATE>
			      <0? <CHTYPE <ANDB .ITM 262143> FIX>>>>
		     <AND <==? <PRIMTYPE .ITM> LIST>
			  <EMPTY? <CHTYPE .ITM LIST>>>>
		 <OR <OR <==? .TYP FREE> <==? .TYP VALUE>>
		     <AND <==? .TYP BOTH> <MEMQ <TYPE .ITM> ,TYPE-WORDS>>>>
 ;
"Hacked by TAA to do immediate instructions when possible
	       even when loading BOTH.  TAC is AC that will have value
	       word; type word (when BOTH) goes into LAC, TAC becomes NAC.
	       Otherwise, TAC becomes LAC."
	    <COND (<==? .TYP BOTH>
		   <LOAD-TYPE-IN-AC <AC-NAME .LAC> <TYPE .ITM>>
		   <SET TAC .NAC>)
		  (<SET TAC .LAC>)>
	    <COND (<==? <PRIMTYPE .ITM> LIST> <OCEMIT MOVEI .TAC 0>)
		  (<0? <CHTYPE <ANDB .ITM 262143> FIX>>
		   <OCEMIT MOVSI .TAC <CHTYPE <LSH .ITM -18> FIX>>)
		  (T	 ;<L? <ABS <SET ITM <CHTYPE .ITM FIX>>> ,MAX-IMMEDIATE
>
		   <COND (<L? <SET ITM <CHTYPE .ITM FIX>> 0>
			  <OCEMIT MOVNI .TAC <ABS .ITM>>)
			 (ELSE <OCEMIT MOVEI .TAC .ITM>)>)>)
	   (T
	    <SET NUM <MVADD .ITM>>
	    <SET NUM <* <+ .NUM 1> 2>>
	    <COND (.BOTH <OCEMIT DMOVE .LAC .NUM '(M*)>)
		  (<==? .TYP VALUE> <OCEMIT MOVE .LAC 1 .NUM '(M*)>)
		  (<==? .TYP LENGTH> <OCEMIT HRRZ .LAC .NUM '(M*)>)
		  (<==? .TYP TYPECODE>
		   <LOAD-TYPE <AC-NAME <CHTYPE .LAC AC>> (.NUM '(M*))>)
		  (T <OCEMIT MOVE .LAC .NUM '(M*)>)>)>
     <AC-NAME <CHTYPE .LAC AC>>)>>

<DEFINE LABEL-PREF (LBL VAR TYP "AUX" (LB <FIND-LABEL .LBL>) L) 
   #DECL ((LBL VAR TYP) ATOM (LB) <OR FALSE LAB>)
   <COND
    (<AND .LB
	  <N==? .LBL COMPERR>
	  <OR <SET L <LAB-FINAL-STATE .LB>>
	      <AND <NOT <EMPTY? <LAB-STATE .LB>>>
		   <SET L <1 <LAB-STATE .LB>>>>>>
     <MAPR <>
      <FUNCTION (ACSP "AUX" (ACS <1 .ACSP>) NXT) 
	      #DECL ((ACS) ACSTATE (NXT) <OR ACSTATE FALSE>)
	      <COND (<OR <AND <ACS-LOCAL .ACS>
			      <==? <LATM <ACS-LOCAL .ACS>> .VAR>
			      <OR <==? <ACS-CODE .ACS> .TYP>
				  <AND <==? .TYP BOTH>
				       <==? <ACS-CODE .ACS> TYPE>>>>
			 <AND <==? .TYP BOTH>
			      <NOT <EMPTY? <REST .ACSP>>>
			      <ACS-LOCAL <SET NXT <2 .ACSP>>>
			      <==? <LATM <ACS-LOCAL .NXT>> .VAR>
			      <==? <ACS-CODE .NXT> VALUE>>>
		     <MAPLEAVE <ACS-AC .ACS>>)>>
      .L>)>>

<DEFINE LOOK-AHEAD (L ITM TYP) 
	#DECL ((L) LIST (ITM TYP) ATOM)
	<COND (<N==? .ITM STACK>
	       <REPEAT (IT X Y)
		<COND (<EMPTY? .L> <RETURN <>>)>
		<COND (<TYPE? <SET IT <1 .L>> ATOM>
		       <SET X <LABEL-PREF .IT .ITM .TYP>>
		       <COND (.X <RETURN .X>) (ELSE <RETURN <>>)>)
		      (<AND <TYPE? .IT FORM>
			    <NOT <EMPTY? .IT>>>
		       <COND (<SET Y <GETPROP <SET X <1 .IT>> LOOKA-AHEAD>>
			      <SPECIAL-PREF .Y .IT .ITM .TYP>)
			     (<==? .X CONS>
			      <COND (<==? .ITM <2 .IT>>
				     <RETURN <COND (<==? .TYP VALUE>
						    <GET-AC B2*>)
						   (ELSE
						    <GET-AC B1*>)>>)
				    (<==? .ITM <3 .IT>>
				     <RETURN <COND (<==? .TYP VALUE>
						    <GET-AC C2*>)
						   (ELSE
						    <GET-AC C1*>)>>)
				    (ELSE <RETURN <>>)>)
			     (<SET Y <OR <MEMQ + .IT> <MEMQ - .IT>>>
			      <SET Y <LABEL-PREF <2 .Y> .ITM .TYP>>
			      <COND (.Y <RETURN .Y>)>)
			     (<AND <==? .X SET> <==? <2 .IT> .ITM>>
			      <RETURN <>>)
			     (<AND <SET Y <MEMQ = .IT>> <==? <2 .Y> .ITM>>
			      <RETURN <>>)
			     (<AND <==? .X DEAD> <MEMQ .ITM <REST .IT>>>
			      <RETURN <>>)
			     (<AND <==? .X RETURN> <==? <2 .IT> .ITM>>
			      <COND (<==? .TYP VALUE> <RETURN <GET-AC A2*>>)
				    (ELSE <RETURN <GET-AC A1*>>)>)
			     (<==? .X RETURN> <RETURN <>>)>)>
		<SET L <REST .L>>>)>>

<DEFINE UPDATE-AC (AC
		   "OPT" (SAVE-TIME <>)
		   "AUX" (ITM <AC-ITEM .AC>) (TYP <AC-CODE .AC>) NAC NUM LCL
			 (T1 <AC-TIME .AC>) T2 (ACSTMP ,AC-STAMP))
	#DECL ((NAC AC) AC (ITM) ANY (TYP) ATOM (NUM ACSTMP) FIX
	       (LCL) <OR ATOM FALSE LOCAL>)
	<COND (<AND <TYPE? .ITM ATOM> <N==? .ITM STACK>>
	       <COND (<SET LCL <LMEMQ .ITM ,LOCALS>>
		      <COND (<AND <TYPE? .LCL LOCAL> <NOT <LUPD .LCL>>>
			     <LUPD .LCL TEMP>)>)
		     (<AND ,ICALL-FLAG <SET LCL <LMEMQ .ITM ,ICALL-TEMPS>>>
		      <COND (<AND <TYPE? .LCL LOCAL> <NOT <LUPD .LCL>>>
			     <LUPD .LCL TEMP>)>)
		     (T <MIMOCERR UNKNOWN-LOCAL!-ERRORS .ITM>)>
	       <SET ITM <LNAME <CHTYPE .LCL LOCAL>>>
	       <COND (<OR <AND <==? .TYP TYPE>
			       <SET NAC <GET-AC <NEXT-AC .AC>>>
			       <==? <AC-CODE .NAC> VALUE>
			       <==? <AC-ITEM .NAC> <LATM <CHTYPE .LCL LOCAL>>>
			       <AC-UPDATE .NAC>
			       <AC-UPDATE .NAC <>>>
			  <AND <==? .TYP VALUE>
			       <SET NAC <GETPROP .AC AC-PAIR>>
			       <==? <AC-CODE .NAC> TYPE>
			       <==? <AC-ITEM .NAC> <LATM <CHTYPE .LCL LOCAL>>>
			       <SET T2 <AC-TIME .NAC>>
			       <AC-UPDATE .NAC>
			       <AC-UPDATE .NAC <>>
			       <SET T1 <AC-TIME .NAC>>
			       <SET AC .NAC>
			       <SET NAC <GET-AC <NEXT-AC .AC>>>>>
		      <HACK-LAST-ACS .LCL TYPE>
		      <HACK-LAST-ACS .LCL VALUE>
		      <SET T2 <AC-TIME .NAC>>
		      <COND (<AND <MEMQ .LCL ,TYPED-LOCALS>
				  <N==? <LUPD .LCL> OARG>>
			     <OCEMIT MOVEM <AC-NAME .NAC> <- 1 ,STACK-DEPTH> .ITM
				     <COND (,WINNING-VICTIM '(TP*)) (ELSE '(F*))>>)
			    (T
			     <OCEMIT DMOVEM <AC-NAME .AC> <- ,STACK-DEPTH> .ITM
				     <COND (,WINNING-VICTIM '(TP*))
					   (ELSE '(F*))>>)>
		      <COND (.SAVE-TIME <AC-TIME .AC .T1> <AC-TIME .NAC .T2>)>
		      <AC-UPDATE .NAC <>>)
		     (<==? .TYP TYPE>
		      <HACK-LAST-ACS .LCL TYPE>
		      <COND (<NOT <MEMQ .LCL ,TYPED-LOCALS>>
			     <OCEMIT MOVEM <AC-NAME .AC> <- ,STACK-DEPTH> .ITM
				     <COND (,WINNING-VICTIM '(TP*)) (ELSE '(F*))>>
			     <COND (.SAVE-TIME <AC-TIME .AC .T1>)>)>)
		     (<==? .TYP VALUE>
		      <HACK-LAST-ACS .LCL VALUE>
		      <OCEMIT MOVEM <AC-NAME .AC> <- 1 ,STACK-DEPTH> .ITM
			      <COND (,WINNING-VICTIM '(TP*)) (ELSE '(F*))>>
		      <COND (.SAVE-TIME
			     <AC-TIME .AC .T1>
			     <COND (<ASSIGNED? T2> <AC-TIME .NAC .T2>)>)>)>)>
	<COND (.SAVE-TIME <SETG AC-STAMP .ACSTMP>)>>

<DEFINE HACK-LAST-ACS (LCL TYP "AUX" ACS)
	#DECL ((LCL) LOCAL (TYP) ATOM (ACS) <OR ACSTATE FALSE>)
	<COND (<AND <==? .TYP TYPE>
		    <SET ACS <LAST-ACST .LCL>>
		    <NOT <ACS-STORED .ACS>>>
	       <PUT .ACS ,ACS-STORED HACKED>
	       <PUT .LCL ,LAST-ACST <>>)
	      (<AND <==? .TYP VALUE>
		    <SET ACS <LAST-ACSV .LCL>>
		    <NOT <ACS-STORED .ACS>>>
	       <PUT .ACS ,ACS-STORED HACKED>
	       <PUT .LCL ,LAST-ACSV <>>)>>

<DEFINE UPDATE-ACS () <LABEL-UPDATE-ACS <> <>>>

<DEFINE LABEL-UPDATE-ACS (TAG UNCND
			  "OPT" (NO-TY <>) (A1 <>) (A2 <>)
			  "AUX" NXT LB (MIML .MIML))
	#DECL ((TAG) <OR ATOM FALSE> (NXT) ANY (MIML) LIST)
	<COND (<AND .TAG <SET LB <FIND-LABEL .TAG>>>)>
	<COND (<OR <==? .TAG COMPERR> <==? .TAG UNWCONT>>       ;"Don't bother"
	       <COND (.A1 <COND (.A2 (.A1 .A2)) (ELSE (.A1))>)>)
	      (T
	       <COND (<AND .TAG <NOT <LAB-LOOP .LB>> <NOT .UNCND>>
		      <PROG ()
			    <COND (<NOT <EMPTY? .MIML>>
				   <COND (<AND <TYPE? <SET NXT <2 .MIML>> FORM>
					       <==? <1 .NXT> DEAD>>
					  <DEAD!-MIMOC <REST .NXT> T .NO-TY>
					  <SET MIML <REST .MIML>>
					  <AGAIN>)
					 (<TYPE? .NXT ATOM>
					  <SET MIML <REST .MIML>>
					  <AGAIN>)>)>>
		      )>
	       <COND (<OR <NOT .TAG> ,NO-AC-FUNNYNESS>
		      <MAPF <>
			    <FUNCTION (AC) 
				    #DECL ((AC) AC)
				    <COND (<AC-UPDATE .AC>
					   <UPDATE-AC .AC>
					   <AC-UPDATE .AC <>>)>>
			    ,AC-TABLE>
		      <COND (.A1 <COND (.A2 (.A1 .A2)) (ELSE (.A1))>)>)
		     (,PASS1
		      <SAVE-BRANCH-STATE .LB .UNCND>
		      <COND (.A1 <COND (.A2 (.A1 .A2)) (ELSE (.A1))>)>)
		     (<NOT ,NO-AC-FUNNYNESS>
		      <ESTABLISH-BRANCH-STATE .LB .UNCND .A1 .A2>)>)>>

<DEFINE FLUSH-AC (AC "OPTIONAL" (BOTH <>) "AUX" RAC)
	#DECL ((AC) ATOM (RAC) AC (BOTH) <OR ATOM FALSE>)
	<COND (<AC-UPDATE <SET RAC <GET-AC .AC>>>
	       <UPDATE-AC .RAC>)>
	<COND (<AND .BOTH <AC-UPDATE <SET RAC <GET-AC <NEXT-AC .AC>>>>>
	       <UPDATE-AC .RAC>)>>
	      
<DEFINE ALTER-AC (AC WHAT "AUX" RAC)
	#DECL ((AC WHAT) ATOM (RAC) AC)
	<COND (<AC-UPDATE <SET RAC <GET-AC .AC>>> <UPDATE-AC .RAC>)>
	<AC-ITEM .RAC .WHAT>
	<AC-CODE .RAC TYPE>
	<AC-UPDATE .RAC T>
	<COND (<AC-UPDATE <SET RAC <GET-AC <NEXT-AC .AC>>>> <UPDATE-AC .RAC>)>
	<AC-ITEM .RAC .WHAT>
	<AC-CODE .RAC VALUE>
	<AC-UPDATE .RAC T>>

<DEFINE FLUSH-ACS ()
	<MAPF <>
	      <FUNCTION (AC)
		   #DECL ((AC) AC)
		   <AC-ITEM .AC <>>
		   <AC-CODE .AC DUMMY>
		   <AC-UPDATE .AC <>>
		   <AC-TYPE .AC <>>
		   <OR <==? <AC-NAME .AC> T*> <AC-TIME .AC 0>>>
	      ,AC-TABLE>>

<DEFINE REALLY-FREE-AC-PAIR ("AUX" OAC)
	<COND (<OR <AND <==? <AC-CODE <GET-AC <SET OAC A1*>>> DUMMY>
			<==? <AC-CODE <GET-AC A2*>> DUMMY>>
		   <AND <==? <AC-CODE <GET-AC <SET OAC B1*>>> DUMMY>
			<==? <AC-CODE <GET-AC B2*>> DUMMY>>
		   <AND <==? <AC-CODE <GET-AC <SET OAC C1*>>> DUMMY>
			<==? <AC-CODE <GET-AC C2*>> DUMMY>>>
	       .OAC)>>

<DEFINE MUNGED-AC (NAM "OPTIONAL" (NXT? <>) "AUX" AC)
	#DECL ((NAM) ATOM (NXT?) <OR ATOM FALSE> (AC) AC)
	<AC-ITEM <SET AC <GET-AC .NAM>> <>>
	<AC-CODE .AC DUMMY>
	<AC-UPDATE .AC <>>
	<AC-TYPE .AC <>>
	<COND (.NXT?
	       <AC-ITEM <SET AC <GET-AC <NEXT-AC .NAM>>> <>>
	       <AC-CODE .AC DUMMY>
	       <AC-UPDATE .AC <>>
	       <AC-TYPE .AC <>>)>>

<DEFINE SAVE-ACS ()
	<UPDATE-ACS>
	<FLUSH-ACS>>

<DEFINE MVADD (ITM "AUX" P HC:FIX IDX:FIX BK:LIST) 
	#DECL ((ITM) ANY)
	<COND (<REPEAT ((ITM .ITM))
		       <COND (<AND <TYPE? .ITM FORM>
				   <==? <LENGTH .ITM> 2>
				   <==? <1 .ITM> QUOTE>>
			      <COND (<TYPE? <SET ITM <2 .ITM>> ATOM>
				     <RETURN T>)>)
			     (ELSE <RETURN <>>)>>
	       ; "This will strip off one level of quoting only when the
		  thing ultimately quoted is an atom; in other cases, all
		  levels need to remain."
	       <SET ITM <2 .ITM>>)>
	<SET BK <NTH ,MV-TABLE
		     <SET IDX <+ <MOD <SET HC <HASH .ITM>>
				      ,MV-TABLE-LENGTH>
				 1>>>>
	<COND (<MAPF <>
		     <FUNCTION (MVB:MBUCK)
			  <COND (<AND <==? <MV-HASH .MVB> .HC>
				      <=? <MV-VAL .MVB> .ITM>>
				 <SET FMV .MVB>
				 <MAPLEAVE>)>>
		     .BK>)
	      (ELSE
	       <PUT ,MV-TABLE
		    .IDX
		    (<SET FMV <CHTYPE [.ITM .HC <SETG MV-COUNT <+ ,MV-COUNT 1>>]
				      MBUCK>> !.BK)>
	       <SETG MV <REST <PUTREST ,MV (.ITM)>>>)>
	<MV-LOC .FMV>>

<DEFINE POS (ITM LST "AUX" M)
	#DECL ((ITM) ANY (LST) LIST (M) <OR FALSE LIST>)
	<COND (<AND <TYPE? .ITM FORM>
		    <G? <LENGTH .ITM > 1>
		    <==? <1 .ITM> QUOTE>
		    <TYPE? <2 .ITM> ATOM>>
	       <SET ITM <2 .ITM>>)>
	<COND (<AND ,ICALL-FLAG
		    <==? .LST ,LOCALS>
		    <SET M <MEMQ .ITM ,ICALL-TEMPS>>>
	       <2 .M>)
	      (<SET M <MEMQ .ITM <REST .LST>>>
	       <- <LENGTH .LST> <LENGTH .M>>)>>

<DEFINE LMEMQ (ATM LST "AUX" ITM) 
	#DECL ((ATM) ATOM (LST) LIST (ITM) <OR ATOM LOCAL>)
	<REPEAT ()
		<COND (<EMPTY? .LST> <RETURN <>>)
		      (<AND <TYPE? <SET ITM <1 .LST>> LOCAL>
			    <==? <LATM .ITM> .ATM>>
		       <RETURN <1 .LST>>)
		      (<==? .ITM .ATM> <RETURN .ATM>)>
		<SET LST <REST .LST>>>>

<DEFINE L-N-LMEMQ (LN LST "AUX" ITM) 
	#DECL ((LN) LOCAL-NAME (LST) LIST (ITM) <OR ATOM LOCAL>)
	<REPEAT ()
		<COND (<EMPTY? .LST> <RETURN <>>)
		      (<AND <TYPE? <SET ITM <1 .LST>> LOCAL>
			    <==? <LNAME .ITM> .LN>>
		       <RETURN <1 .LST>>)
		      (<==? .ITM .LN> <RETURN .LN>)>
		<SET LST <REST .LST>>>>

<DEFINE LLOOKUP (ATM "AUX" M P)
	#DECL ((ATM) ATOM (M) <OR LIST FALSE> (P) <OR FALSE FIX>)
	<COND (<SET M <MEMQ .ATM ,ICALL-TEMPS>> <* <CHTYPE <2 .M> FIX> 2>)
	      (<SET P <POS .ATM ,LOCALS>> <* <CHTYPE .P FIX> 2>)
	      (<MIMOCERR UNKNOWN-LOCAL!-ERRORS .ATM>)>>

<DEFINE FIXUP-LOCALS (L
		      "AUX" (C ,TEMP-CC) (CFLG <>) (CNT 0) (LNUM 0) (TUP <>)
			    (FL ()) TMP)
	#DECL ((FL L C) LIST (CFLG) <OR ATOM FALSE> (CNT LNUM) FIX
	       (TUP) <OR FALSE INST>)
	<COND (<AND <TYPE? <SET TMP <2 .C>> INST>
		    <==? <1 .TMP> MOVE>
		    <NOT <EMPTY? .L>>>
	       <SET TUP <4 .C>>
	       <SET C <REST .C 5>>)>
	<MAPF <>
	      <FUNCTION (ITM "AUX" LU) 
		      #DECL ((ITM) LOCAL)
		      <COND (<NOT .CFLG> <SET CFLG T>)>
		      <COND (<SET LU <LUPD .ITM>>
			     <SET FL (<LNAME .ITM> <SET LNUM <+ .LNUM 2>> !.FL)>
			     <COND (<AND <N==? .LU ARG> <N==? .LU OARG>>
				    <SET C <REST .C 2>>)>)
			    (T
			     <COND (,WINNING-VICTIM
				    <SETG WINNING-VICTIM <- ,WINNING-VICTIM 2>>)>
			     <SET CNT <+ .CNT 1>>
			     <PUTREST .C <REST .C 3>>
			     <COND (.TUP
				    <PUT .TUP
					 3
					 <- <CHTYPE <3 .TUP> FIX> 1>>)>)>>
	      .L>
	<COND (,WINNING-VICTIM
	       <REPEAT ((WV ,WINNING-VICTIM) (L .FL))
			#DECL ((L) <LIST [REST ANY FIX]> (WV) FIX)
			<COND (<EMPTY? .L> <RETURN>)>
			<PUT .L 2 <- <CHTYPE <2 .L> FIX> .WV -1>>
			<SET L <REST .L 2>>>)>
	<COND (<NOT <EMPTY? .FL>>
	       <PUTREST <REST .FL <- <LENGTH .FL> 1>> ,FINAL-LOCALS>
	       <SETG FINAL-LOCALS .FL>)>
	<COND (<AND ,V1 <G? .CNT 0>>
	       <CRLF>
	       <PRIN1 .CNT>
	       <PRINC " flushed temporaries.">
	       <CRLF>)>>

<DEFINE OCEMIT ("TUPLE" T "AUX" (LABEL <>)) 
   #DECL ((T) TUPLE (LABEL) <OR ATOM FALSE>)
   <COND (<AND <1? <LENGTH .T>> <TYPE? <1 .T> ATOM>>
	  <AND ,V1 <NOT ,PASS1> <INDENT-TO 30>>
	  <SET LABEL T>)
	 (<AND ,V1 <NOT ,PASS1>>
	  <COND (<G? <M-HPOS .OUTCHAN> 45> <CRLF>)>
	  <INDENT-TO 45>)>
   <MAPR <>
	 <FUNCTION (Y "AUX" (X <1 .Y>) AC FOO AC1) 
		 #DECL ((X) ANY (AC) <OR FALSE AC> (FOO) <OR FALSE ATOM>)
		 <COND (<AND <TYPE? .X LIST> <SET AC <IS-AC? <1 .X>>>>
			<OR <==? .AC <GET-AC T*>>
			    <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>>
			<COND (<SET FOO <AC-TYPE .AC>>
			       <LOAD-TYPE-IN-AC <AC-NAME .AC> .FOO>
			       <AC-TYPE .AC <>>)>
			<COND (<AND <SET AC1 <GETPROP .AC AC-PAIR>>
				    <==? <AC-ITEM .AC1> <AC-ITEM .AC>>>
			       <AC-TIME .AC1 ,AC-STAMP>)>)>
		 <SET AC <>>
		 <COND (<AND <TYPE? .X ATOM>
			     <SET AC <IS-AC? .X>>
			     <SET FOO <AC-TYPE .AC>>>
			<LOAD-TYPE-IN-AC <AC-NAME .AC> .FOO>
			<AC-TYPE .AC <>>)
		       (<TYPE? .X AC>
			<PUT .Y 1 <AC-NAME <SET AC .X>>>
			<COND (<SET FOO <AC-TYPE .X>>
			       <LOAD-TYPE-IN-AC <AC-NAME .AC> .FOO>
			       <AC-TYPE .X <>>)>)>
		 <COND (.AC
			<AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			<COND (<AND <SET AC1 <GETPROP .AC AC-PAIR>>
				    <==? <AC-ITEM .AC> <AC-ITEM .AC1>>>
			       <AC-TIME .AC1 ,AC-STAMP>)>)>>
	 .T>
   <COND (<AND ,V1 <NOT ,PASS1>>
	  <MAPF <>
		<FUNCTION (ITM)
		     <COND (<TYPE? .ITM ATOM> <PRINC .ITM>)
			   (<TYPE? .ITM REF>
			    <PRINC "#REF [">
			    <COND (<TYPE? <1 .ITM> ATOM> <PRINC <1 .ITM>>)
				  (ELSE <PRIN1 <1 .ITM>>)>
			    <PRINC "]">)
			   (<TYPE? .ITM LIST>
			    <PRINC "(">
			    <COND (<TYPE? <1 .ITM> ATOM> <PRINC <1 .ITM>>)
				  (ELSE <PRIN1 <1 .ITM>>)>
			    <PRINC ")">)
			   (ELSE <PRIN1 .ITM>)>
		     <PRINC !\ >>
		.T>)>
   <COND (.LABEL <AND ,V1 <NOT ,PASS1> <PRINC ":">>)
	 (<NOT ,PASS1>
	  <AND ,V1 <CRLF>>
	  <SETG CC <REST <PUTREST ,CC (<CHTYPE [!.T] INST>)>>>)>>

<DEFINE XEMIT ("TUPLE" T "AUX" M COD)
	#DECL ((T) <TUPLE ATOM ATOM <OR FIX XTYPE-C REF>>
	       (COD) <OR FIX XTYPE-C REF> (M) <OR VECTOR FALSE>)
	<COND (<NOT ,PASS1>
	       <COND (<AND <TYPE? <SET COD <3 .T>> FIX>
			   <SET M <MEMQ .COD
					'[*1502* 10
					  *1602* 10
					  *1302* 12
					  *1402* 16
					  *1702* 10]>>>
		      <SETG CC
			    <REST <PUTREST
				   ,CC
				   (<CHTYPE [MOVE
					     <2 .T>
					     !<OBJ-VAL
					       <CHTYPE
						<ORB <LSH .COD 18>
						     <2 .M>> FIX>>] INST>)>>>)
		     (T <SETG CC <REST <PUTREST ,CC (<CHTYPE [!.T] INST>)>>>)>
	       <COND (,V1
		      <INDENT-TO 40>
		      <PRINC "*TRQ*">
		      <MAPF <>
			    <FUNCTION (ITM)
				 <COND (<TYPE? .ITM ATOM> <PRINC .ITM>)
				       (<TYPE? .ITM REF>
					<PRINC "#REF [">
					<COND (<TYPE? <1 .ITM> ATOM>
					       <PRINC <1 .ITM>>)
					      (ELSE <PRIN1 <1 .ITM>>)>
					<PRINC "]">)
				       (<TYPE? .ITM LIST>
					<PRINC "(">
					<COND (<TYPE? <1 .ITM> ATOM>
					       <PRINC <1 .ITM>>)
					      (ELSE <PRIN1 <1 .ITM>>)>
					<PRINC ")">)
				       (ELSE <PRIN1 .ITM>)>
				 <PRINC !\ >>
			    .T>
		      <CRLF>
		      <INDENT-TO 45>)>)>>

<DEFINE CONST-LOC (ITM TYP "OPT" NEWV) 
	<COND (<==? .TYP TYPE>
	       <TYPE-WORD <TYPE .ITM>>)
	      (ELSE
	       <COND (<TYPE? .ITM CONST-W-LOCAL>
		      <CONST-ADD .ITM>)
		     (ELSE
		      <CONST-ADD <SET ITM <CHTYPE .ITM CONSTANT>>>)>)>>

<DEFINE CONST-ADD (ITM "AUX" LBL (LS <+ ,CONSTSEQ 1>) HC BUCK INDX FCB)
	#DECL ((INDX HC LS) FIX (ITM) <OR CONSTANT CONST-W-LOCAL>
	       (BUCK) <LIST [REST CONSTANT-BUCKET]> (FCB) CONSTANT-BUCKET)
	<COND (<TYPE? .ITM CONSTANT> <SET HC <CHTYPE .ITM FIX>>)
	      (ELSE <SET HC <XORB <1 .ITM> <2 .ITM>>>)>
	<SET BUCK <NTH ,CONSTANT-TABLE
		       <SET INDX <+ <MOD <SET HC <XORB .HC 3.141516>>
					 ,CONSTANT-TABLE-LENGTH> 1>>>>
	<COND (<MAPF <>
		     <FUNCTION (CB:CONSTANT-BUCKET "AUX" TEM)
			  <COND (<AND <==? .HC <CB-HASH .CB>>
				      <OR <AND <TYPE? .ITM CONSTANT>
					       <==? .ITM <CB-VAL .CB>>>
					  <AND <TYPE? .ITM CONST-W-LOCAL>
					       <TYPE? <SET TEM <CB-VAL .CB>>
						      CONST-W-LOCAL>
					       <==? <1 .TEM> <1 .ITM>>
					       <==? <2 .TEM> <2 .ITM>>>>>
				 <SET FCB .CB>
				 <MAPLEAVE T>)>>
		     .BUCK>)
	      (ELSE
	       <SET FCB <CHTYPE [.ITM .HC <CHTYPE <SETG CONSTSEQ .LS>
						   CONSTANT-LABEL> 0]
				CONSTANT-BUCKET>>
	       <SETG CONSTANT-VECTOR (.FCB !,CONSTANT-VECTOR)>
	       <PUT ,CONSTANT-TABLE .INDX (.FCB !.BUCK)>)>
	(<CHTYPE [.FCB] REF>)>

<DEFINE CONST-ADD-FRM ("AUX" CB)
	<SETG CONSTANT-VECTOR (<SET CB
				    <CHTYPE [FREE 0 <CHTYPE <SETG CONSTSEQ
								  <+ ,CONSTSEQ 1>>
							    CONSTANT-LABEL> 0]
					    CONSTANT-BUCKET>>
			       !,CONSTANT-VECTOR)>
	<SETG FREE-CONSTS (.CB !,FREE-CONSTS)>>

<DEFINE OBJ-LOC (ITM OFF "AUX" IDX NUM LCL) 
	#DECL ((ITM) ANY (OFF NUM) FIX (IDX) <OR FALSE FIX>)
	<COND (<TYPE? .ITM ATOM>
	       <SET LCL
		    <OR <LMEMQ .ITM ,LOCALS>
			<AND ,ICALL-FLAG <LMEMQ .ITM ,ICALL-TEMPS>>>>
	       (<- .OFF ,STACK-DEPTH> <LNAME <CHTYPE .LCL LOCAL>>
		<COND (,WINNING-VICTIM '(TP*)) (ELSE '(F*))>))
	      (T
	       <SET NUM <MVADD .ITM>>
	       <SET NUM <* <+ .NUM 1> 2>>
	       (<+ .OFF .NUM> '(M*)))>>

<DEFINE ALLOCATE-CONSTANTS (CV START)
	#DECL ((CV CL) LIST (START) FIX)
	<MAPF <>
	      <FUNCTION (CB:CONSTANT-BUCKET)
		   <CB-LOC .CB .START>
		   <SET START <+ .START 1>>>
	      .CV>>

<DEFINE FIXUP-CONSTANTS (C "AUX" (N 0)) 
   #DECL ((C CL) LIST)
   <MAPR <>
	 <FUNCTION (CP "AUX" (IT <1 .CP>) R X) 
		 <COND (<AND <TYPE? .IT INST>
			     <SET N <+ .N 1>>
			     <TYPE? <SET R <NTH .IT <LENGTH .IT>>> REF>>
			<COND (<NOT <TYPE? <SET X <1 .R>> CONSTANT-BUCKET>>
			       <MIMOCERR BAD-REF-IN-CODE!-ERRORS .X>)
			      (,MAX-SPACE
			       <SETG GREFS ((.N .X) !,GREFS)>
			       <PUT .CP 1 <CHTYPE [<1 .IT> <2 .IT> 0 '(R*)] INST>>)
			      (ELSE
			       <PUT .CP
				    1
				    <CHTYPE [<1 .IT> <2 .IT>
					     <CB-LOC .X>
					     '(R*)] INST>>)>)>>
	 .C>>

<DEFINE OBJ-VAL (ITM "OPTIONAL" (AC? T) "AUX" AC)
	#DECL ((ITM) ANY (AC AC?) <OR FALSE ATOM>)
	<COND (<AND .AC? <SET AC <IN-AC? .ITM VALUE>>> (.AC))
	      (<==? <PRIMTYPE .ITM> FIX>
	       <CONST-LOC <CHTYPE .ITM CONSTANT> VALUE>)
	      (<TYPE? .ITM CONST-W-LOCAL> <CONST-LOC .ITM VALUE>)
	      (T <OBJ-LOC .ITM 1>)>>

<DEFINE OBJ-TYP (ITM "AUX" AC)
	#DECL ((ITM) ANY (AC) <OR FALSE ATOM>)
	<COND (<SET AC <IN-AC? .ITM TYPE>> (.AC))
	      (<AND <==? <PRIMTYPE .ITM> FIX>
		    <MEMQ <TYPE .ITM> ,TYPE-WORDS>>
	       <CONST-LOC .ITM TYPE>)
	      (T <OBJ-LOC .ITM 0>)>>

<DEFINE XJUMP (TAG "AUX" X)
	<COND (<AND <N==? <OBLIST? .TAG> ,LABEL-OBLIST>
		    <SET X <LOOKUP <SPNAME .TAG> ,LABEL-OBLIST>>>
	       <SET TAG .X>)>
	<CHTYPE [.TAG] REF>>

<DEFINE DEAD!-MIMOC (LCLS "OPTIONAL" (PRED? <>) (NO-TY <>)) 
   #DECL ((LCLS) <LIST [REST ATOM]> (PRED?) <OR FALSE ATOM>)
   <COND (<NOT ,DEATH-TRQ> <SET NO-TY T>)>
   <MAPF <>
    <FUNCTION (AC "AUX" ITM FOO LCL) 
	    #DECL ((AC) AC (FOO) <OR FALSE ATOM> (LCL) LOCAL)
	    <COND (<MEMQ <SET ITM <AC-ITEM .AC>> .LCLS>
		   <SET LCL
			<OR <LMEMQ <AC-ITEM .AC> ,LOCALS>
			    <AND ,ICALL-FLAG
				 <LMEMQ <AC-ITEM .AC> ,ICALL-TEMPS>>>>
		   <PUT .LCL ,LAST-ACST <>>
		   <PUT .LCL ,LAST-ACSV <>>
		   <COND (<SET FOO <AC-TYPE .AC>>
			  <COND (<NOT .NO-TY>
				 <LOAD-TYPE-IN-AC <AC-NAME .AC> .FOO>
				 <AC-TYPE .AC <>>)>)>
		   <AC-UPDATE .AC <>>
		   <COND (<NOT .PRED?>
			  <AC-CODE .AC DUMMY>
			  <AC-ITEM .AC <>>
			  <AC-TIME .AC 0>)>)>>
    ,AC-TABLE>>

<COND (<NOT <GASSIGNED? LBLSEQ>> <SETG CONSTSEQ <SETG LBLSEQ 0>>)>

<DEFINE GENLBL (STR)
	#DECL ((STR) STRING)
	<SET STR <STRING .STR <UNPARSE <SETG LBLSEQ <+ ,LBLSEQ 1>>>>>
	<OR <LOOKUP .STR ,LABEL-OBLIST> <INSERT .STR ,LABEL-OBLIST>>>

<DEFINE LABEL (NAM "OPT" (IND <>) (CP ()) "AUX" (LB <>)) 
	#DECL ((NAM) ATOM (IND) <OR FALSE FIX>)
	<SET LB <FIND-LABEL .NAM>>
	<COND (,PASS1
	       <COND (<NOT .LB>
		      <SET LB <MAKE-LABEL .NAM .IND .CP>>)
		     (.IND
		      <LAB-IND .LB .IND>)>
	       <PUT .LB ,LAB-LOOP ,NEXT-LOOP>
	       .LB)
	      (ELSE <SETG CC <REST <PUTREST ,CC (.NAM)>>> <OCEMIT .NAM> .LB)>>

<DEFINE MAKE-LABEL (NAM IND CP "OPT" (NL <>) "AUX" LB)
	<SETG LABELS
	      (<SET LB <CHTYPE [.NAM .IND .NL () <> 0 .CP ()] LAB>>
	       !,LABELS)>
	<SETG .NAM .LB>>


<DEFINE LONG-FIND-LABEL (NAM LBLS) #DECL ((LBLS) <LIST [REST LAB]>)
	<MAPF <>
	      <FUNCTION (LB) #DECL ((LB) LAB)
		   <COND (<==? <LAB-NAM .LB> .NAM> <MAPLEAVE .LB>)>>
	      .LBLS>>

<DEFINE FIND-LABEL (NAM ) 
	#DECL ((LBLS) LIST)
	<COND (<GASSIGNED? .NAM> ,.NAM)>>

<DEFINE TYPE-CODE (TYP "OPT" (LS <>) "AUX" L)
	#DECL ((TYP) ATOM (L) <OR FALSE VECTOR>)
	<COND (<SET L <MEMQ .TYP ,TYPE-WORDS>>
	       <COND (.LS (<2 .L>)) (ELSE <2 .L>)>)
	      (<VALID-TYPE? .TYP>
	       <COND (.LS (@ !<OBJ-LOC <CHTYPE .TYP XTYPE-C> 1>))
		     (ELSE <CHTYPE .TYP XTYPE-C>)>)
	      (T <MIMOCERR UNDEFINED-TYPE!-ERRORS .TYP>)>>

<DEFINE TYPE-WORD (TYP "AUX" L VAL M) 
	#DECL ((TYP) ATOM (L M) <OR FALSE VECTOR> (VAL) CONSTANT)
	<COND (<SET L <MEMQ .TYP ,TYPE-WORDS>>
	       <SET VAL <CHTYPE <LSH <2 .L> 18> CONSTANT>>
	       <COND (<SET M <MEMQ .TYP ,TYPE-LENGTHS>>
		      <SET VAL <CHTYPE <ORB .VAL <2 .M>> CONSTANT>>)>
	       <CONST-ADD .VAL>
	       <CONST-LOC .VAL VALUE>)
	      (<VALID-TYPE? .TYP> <OBJ-LOC <CHTYPE .TYP XTYPE-W> 1>)
	      (T <MIMOCERR CANT-TYPE-WORD!-ERRORS .TYP>)>>

<DEFINE PUSHJ (NAM "OPTIONAL" (VAL <>) (TAG <>) (TYP <>) "AUX" AC
	       (OC <OPCODE .NAM>))
	#DECL ((NAM) ATOM (VAL) <OR ATOM FALSE> (AC) AC (OC) FIX)
	<FLUSH-ACS>
	<COND (<G? .OC 0>
	       <OCEMIT PUSHJ P* @ .OC>)
	      (ELSE
	       <OCEMIT JSP T* @ <- .OC>>)>
	<COND (.TAG <OCEMIT JRST <XJUMP .TAG>>)>
	<COND (.TYP <OCEMIT HRLI A1* !<TYPE-CODE .TYP T>>)>
	<PUSHJ-VAL .VAL>>

<DEFINE PUSHJ-VAL (VAL "AUX" AC)
	#DECL ((VAL) <OR FALSE ATOM> (AC) AC)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* A1*>
	       <OCEMIT PUSH TP* A2*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (.VAL
	       <SET AC <GET-AC A1*>>
	       <AC-ITEM .AC .VAL>
	       <AC-CODE .AC TYPE>
	       <AC-UPDATE .AC T>
	       <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
	       <SET AC <GET-AC A2*>>
	       <AC-ITEM .AC .VAL>
	       <AC-CODE .AC VALUE>
	       <AC-UPDATE .AC T>
	       <AC-TIME .AC ,AC-STAMP>)>>

;"Actual code for open-coding specific MIM instructions"

<SETG MIMOC-OBLIST <MOBLIST MIMOC 51>>

<SETG EVALABLES '[TYPE-CODE TYPE-WORD]>

<GDECL (EVALABLES) VECTOR>

<DEFINE OC (FRM OBLIST "AUX" ATM (EVF <>)) 
	#DECL ((FRM) FORM (ATM EVF) <OR FALSE ATOM> (OBLIST) <SPECIAL ANY>)
	<AND <NOT ,PASS1> ,V1 <PRINT .FRM>>
	<MAPR <>
	      <FUNCTION (L "AUX" (ITM <1 .L>)) 
		      #DECL ((L) LIST)
		      <COND (<AND <TYPE? .ITM FORM>
				  <NOT <EMPTY? .ITM>>
				  <MEMQ <1 .ITM> ,EVALABLES>>
			     <PUT .L 1 <EVAL .ITM>>
			     <PUTPROP .L EVAL .ITM>
			     <SET EVF T>)>>
	      .FRM>
	<COND (<SET ATM <LOOKUP <SPNAME <1 .FRM>> ,MIMOC-OBLIST>>
	       <APPLY ,.ATM <REST .FRM>>
	       <COND (<AND .EVF <NOT ,PASS1>>
		      <MAPR <> <FUNCTION (L) <PUTPROP .L EVAL>> .FRM>)>)
	      (T <MIMOCERR CANT-OPEN-COMPILE!-ERRORS .FRM>)>>

;"Gross and disgusting hack for UNWINDage"

<DEFINE LOCATION!-MIMOC (L "AUX" NAC)
	#DECL ((L) LIST (NAC) ATOM)
	<SET NAC <ASSIGN-AC <4 .L> BOTH>>
	<AC-TYPE <GET-AC .NAC> FIX>
	<COND (,GLUE-MODE <OCEMIT MOVEI <NEXT-AC .NAC> 0>)
	      (ELSE <OCEMIT XMOVEI <NEXT-AC .NAC> 0 '(R*)>)>
	<COND (<NOT ,PASS1>
	       <SETG LOCATIONS (<1 ,CC> <2 .L> !,LOCATIONS)>)>
	<COND (<NOT ,GLUE-MODE> <OCEMIT SUB <NEXT-AC .NAC> R*>)>>

<DEFINE LOCATION-CHECK ()
	<REPEAT ((O ,LOCATIONS))
		#DECL ((O) <LIST [REST INST ATOM]>)
		<COND (<EMPTY? .O> <RETURN>)
		      (T <PUT <1 .O> 3 <LAB-IND <FIND-LABEL <2 .O>>>>)>
		<SET O <REST .O 2>>>>

<DEFINE LOAD-TYPE-IN-AC (ACNAM TYP)
	<COND (<MEMQ .TYP ,TYPE-LENGTHS>
	       <XEMIT MOVE .ACNAM !<TYPE-WORD .TYP>>)
	      (ELSE
	       <XEMIT MOVSI .ACNAM !<TYPE-CODE .TYP T>>)>>


<DEFINE SAVE-BRANCH-STATE (LB UNCND "AUX" NS (LS <LAB-STATE .LB>)
					  (LOOP? <LAB-LOOP .LB>)) 
   #DECL ((LB) LAB (LS) LIST)
   <SET NS
    <CHTYPE
     <MAPF ,VECTOR
	   <FUNCTION (AC NULL-STATE "AUX" LCL ACS) 
		   #DECL ((AC) AC)
		   <COND (<AND <AC-ITEM .AC> <NOT <TYPE? <AC-ITEM .AC> LOSE>>>
			  <OR <SET LCL <LMEMQ <AC-ITEM .AC> ,LOCALS>>
			      <AND ,ICALL-FLAG
				   <SET LCL
					<LMEMQ <AC-ITEM .AC> ,ICALL-TEMPS>>>>)
			 (ELSE <SET LCL <>>)>
		   <COND (<AND <AC-UPDATE .AC>
			       <NOT .LOOP?>
			       <OR .UNCND <WILL-DIE? <AC-ITEM .AC>>>
			       <WILL-DIE? <AC-ITEM .AC> <LAB-CODE-PNTR .LB>>>
			  <SET LCL <>>
			  <AC-UPDATE .AC <>>
			  <AC-ITEM .AC <>>)>
		   <COND (.LCL
			  <COND (<AND <==? <AC-CODE .AC> TYPE>
				      <SET ACS <LAST-ACST .LCL>>
				      <NOT <ACS-STORED .ACS>>
				      <OR <N==? <ACS-AC .ACS> .AC>
					  <NOT <AC-UPDATE .AC>>>>
				 <PUT .ACS ,ACS-STORED HACKED>)>
			  <COND (<AND <==? <AC-CODE .AC> VALUE>
				      <SET ACS <LAST-ACSV .LCL>>
				      <NOT <ACS-STORED .ACS>>
				      <OR <N==? <ACS-AC .ACS> .AC>
					  <NOT <AC-UPDATE .AC>>>>
				 <PUT .ACS ,ACS-STORED HACKED>)>
			  <SET ACS <CHTYPE [.AC
					    .LCL
					    <NOT <AC-UPDATE .AC>>
					    <AC-TYPE .AC>
					    <AC-CODE .AC>]
					   ACSTATE>>
			  <COND (<==? <AC-CODE .AC> TYPE>
				 <PUT .LCL ,LAST-ACST .ACS>)
				(ELSE
				 <PUT .LCL ,LAST-ACSV .ACS>)>
			  .ACS)
			 (ELSE .NULL-STATE)>>
	   ,AC-PAIR-TABLE
	   ,NULL-STATES>
     LABSTATE>>
   <COND (<EMPTY? .LS> <PUT .LB ,LAB-STATE (.NS)>)
	 (ELSE <PUTREST <REST .LS <- <LENGTH .LS> 1>> (.NS)>)>
   <COND (<LAB-LOOP .LB>
	  <COND (<LAB-FINAL-STATE .LB>
		 <MERGE-TWO-FORCE .NS <LAB-FINAL-STATE .LB>>)>
	  <LOGICAL-ESTABLISH .NS>)
	 (ELSE
	  <COND (<LAB-FINAL-STATE .LB>
		 <MERGE-TWO .NS <LAB-FINAL-STATE .LB>>)>
	  <ESTABLISH-UPDATE .NS>)>
   <COND (.UNCND <FLUSH-ACS>) (ELSE <MUNGED-AC T*> <MUNGED-AC O*>)>>

<DEFINE SAVE-LABEL-STATE (LB "AUX" NS) 
   <COND
    (<NOT ,LAST-UNCON>
     <SET NS
      <CHTYPE
       <MAPF ,VECTOR
	     <FUNCTION (AC NULL-STATE "AUX" LCL (ITM <AC-ITEM .AC>) ACS) 
		     #DECL ((AC) AC)
		     <COND (<AND .ITM <NOT <TYPE? .ITM LOSE>>>
			    <OR <SET LCL <LMEMQ .ITM ,LOCALS>>
				<AND ,ICALL-FLAG
				     <SET LCL <LMEMQ .ITM ,ICALL-TEMPS>>>>)
			   (ELSE <SET LCL <>>)>
		     <COND (.LCL
			    <COND (<AND <==? <AC-CODE .AC> TYPE>
				      <SET ACS <LAST-ACST .LCL>>
				      <NOT <ACS-STORED .ACS>>
				      <OR <N==? <ACS-AC .ACS> .AC>
					  <NOT <AC-UPDATE .AC>>>>
				 <PUT .ACS ,ACS-STORED HACKED>)>
			  <COND (<AND <==? <AC-CODE .AC> VALUE>
				      <SET ACS <LAST-ACSV .LCL>>
				      <NOT <ACS-STORED .ACS>>
				      <OR <N==? <ACS-AC .ACS> .AC>
					  <NOT <AC-UPDATE .AC>>>>
				 <PUT .ACS ,ACS-STORED HACKED>)>
			    <SET ACS <CHTYPE [.AC
					      .LCL
					      <NOT <AC-UPDATE .AC>>
					      <AC-TYPE .AC>
					      <AC-CODE .AC>]
					     ACSTATE>>
			    <COND (<==? <AC-CODE .AC> TYPE>
				   <PUT .LCL ,LAST-ACST .ACS>)
				  (ELSE
				   <PUT .LCL ,LAST-ACSV .ACS>)>
			    .ACS)
			   (ELSE .NULL-STATE)>>
	     ,AC-PAIR-TABLE
	     ,NULL-STATES>
       LABSTATE>>
     <PUT .LB ,LAB-STATE (.NS !<LAB-STATE .LB>)>
     <COND (<NOT <LAB-LOOP .LB>> <KILL-DEAD-ACS .LB>)>
     <COND (<NOT <LAB-FINAL-STATE .LB>>
	    <PUT .LB ,LAB-FINAL-STATE .NS>)>
     <MERGE-TWO <1 <LAB-STATE .LB>> <LAB-FINAL-STATE .LB>>
     <ESTABLISH-LABEL-STATE .LB <1 <LAB-STATE .LB>>>
     T)
    (ELSE
     <COND (<NOT <LAB-LOOP .LB>> <KILL-DEAD-ACS .LB>)>
     <COND (<AND <NOT <LAB-FINAL-STATE .LB>> <NOT <EMPTY? <LAB-STATE .LB>>>>
	    <PUT .LB ,LAB-FINAL-STATE <1 <LAB-STATE .LB>>>)>
     <COND (<LAB-FINAL-STATE .LB> <ESTABLISH-LABEL-STATE .LB>)>)>>

<DEFINE KILL-DEAD-ACS (LB) 
	#DECL ((LB) LAB)
	<COND (<LAB-FINAL-STATE .LB> <KILL-ONE-STATE <LAB-FINAL-STATE .LB>>)>
	<MAPF <> ,KILL-ONE-STATE <LAB-STATE .LB>>>

<DEFINE KILL-ONE-STATE (LSTATE) 
	#DECL ((LSTATE) LABSTATE)
	<MAPF <>
	 <FUNCTION (ACST "AUX" LCL) 
		 #DECL ((ACST) ACSTATE (LCL) LOCAL)
		 <COND (<AND <ACS-LOCAL .ACST>
			     <WILL-DIE? <LATM <SET LCL <ACS-LOCAL .ACST>>>>>
			<PUT .LCL ,LAST-ACST <>>
			<PUT .LCL ,LAST-ACSV <>>
			<PUT .ACST ,ACS-LOCAL
			     <CHTYPE (<ACS-LOCAL .ACST>) FALSE>>
			<PUT .ACST ,ACS-STORED DEAD>)>>
	 .LSTATE>>

<DEFINE ESTABLISH-BRANCH-STATE (LB UNCND
				"OPT" (AC-P1 <>) (AC-P2 <>)
				      (LS <LAB-FINAL-STATE .LB>)
				"AUX" (LOOP? <LAB-LOOP .LB>) (MOVES-TO ())
				      SAVED? (MOVES-FROM ()))
   #DECL ((LB) LAB (LS) LABSTATE)
   <MAPF <>
    <FUNCTION (STAT
	       "AUX" LCL1 (AC <ACS-AC .STAT>) (LCL2 <AC-ITEM .AC>)
		     (NEW-AC? <>))
       #DECL ((STAT) ACSTATE (AC) AC)
       <COND (<TYPE? .LCL2 LOSE> <SET LCL2 <>>)>
       <COND (<AND <AC-UPDATE .AC>
		   <NOT .LOOP?>
		   .LCL2
		   <OR .UNCND <WILL-DIE? .LCL2>>
		   <WILL-DIE? .LCL2 <LAB-CODE-PNTR .LB>>
		   <COND (<ASSIGNED? DISP-L>
			  <MAPF <>
				<FUNCTION (X)
				     <COND (<WILL-DIE? .LCL2
						       <LAB-CODE-PNTR
							<FIND-LABEL .X>>>
					    T)
					   (ELSE <MAPLEAVE <>>)>>
				.DISP-L>)
			 (ELSE T)>>
	      <SET LCL2 <>>
	      <AC-UPDATE .AC <>>
	      <AC-ITEM .AC <>>)>
       <COND
	(<OR <AND <SET LCL1 <ACS-LOCAL .STAT>> <==? <LATM .LCL1> .LCL2>>
	     <AND <NOT .LCL1> <NOT .LOOP?>>>
	 <COND (<AND <AC-UPDATE .AC>
		     <OR <AND <NOT .LCL1> <EMPTY? .LCL1>>
			 <AND <ACS-STORED .STAT>
			      <OR .LCL1
				  <AND <NOT <EMPTY? .LCL1>>
				       <N==? <LATM <1 .LCL1>> .LCL2>>>>>>
		<UPDATE-AC .AC T>
		<AC-UPDATE .AC <>>)>)
	(<AND .LCL1
	      .LOOP?
	      <OR <NOT .LCL2> <N==? <LATM .LCL1> .LCL2>>
	      <SET NEW-AC? <FIND-AC .LCL1 <ACS-CODE .STAT>>>>
	 <COND (<NOT <AND <ACS-TYPE .STAT>
			  <OR <NOT <ACS-STORED .STAT>>
			      <LDECL .LCL1>
			      <==? <ACS-TYPE .STAT> <AC-TYPE .NEW-AC?>>>>>
		<SET MOVES-TO (.AC !.MOVES-TO)>
		<SET MOVES-FROM (.NEW-AC? !.MOVES-FROM)>)>)
	(<AND .LCL1 .LOOP? <NOT .NEW-AC?>> <ERROR AC-SCREW-UP!-ERRORS>)>
       <COND (<AND .LOOP?
		   .LCL2
		   <NOT <FIND-LOCAL .LCL2 <AC-CODE .AC> .LS T>>
		   <AC-UPDATE .AC>>
	      <UPDATE-AC .AC T>
	      <AC-UPDATE .AC <>>)>>
    .LS>
   <COND (<AND .AC-P1 <SET AC-P1 <GET-AC .AC-P1>> <MEMQ .AC-P1 .MOVES-TO>>
	  <COND (<SET SAVED? <MEMQ .AC-P1 .MOVES-FROM>>
		 <SET AC-P1
		      <NTH .MOVES-TO
			   <- <LENGTH .MOVES-FROM> <LENGTH .SAVED?> -1>>>)
		(ELSE
		 <SET MOVES-FROM (.AC-P1 !.MOVES-FROM)>
		 <SET MOVES-TO
		      (<SET AC-P1 <FIND-FREE-TO .MOVES-TO .MOVES-FROM>>
		       !.MOVES-TO)>)>)>
   <COND (<AND .AC-P2 <SET AC-P2 <GET-AC .AC-P2>> <MEMQ .AC-P2 .MOVES-TO>>
	  <COND (<SET SAVED? <MEMQ .AC-P2 .MOVES-FROM>>
		 <SET AC-P2
		      <NTH .MOVES-TO
			   <- <LENGTH .MOVES-FROM> <LENGTH .SAVED?> -1>>>)
		(ELSE
		 <SET MOVES-FROM (.AC-P2 !.MOVES-FROM)>
		 <SET MOVES-TO
		      (<SET AC-P2 <FIND-FREE-TO .MOVES-TO .MOVES-FROM>>
		       !.MOVES-TO)>)>)>
   <COND
    (<NOT <EMPTY? .MOVES-FROM>>
     <REPEAT ((WIN T) GOT-ONE)
       <SET GOT-ONE <>>
       <MAPR <>
	<FUNCTION (PT PF
		   "AUX" (AC-TO? <1 .PT>) PAT1 PAT2 AT1 AT2 AF P-TO? P-FROM)
	   #DECL ((AT1 AT2 PAT1 PAT2) FIX (AF P-FROM) AC
		  (PT PF) <LIST <OR AC FALSE>> (AC-TO? P-TO?) <OR AC FALSE>)
	   <COND
	    (<==? .AC-TO? <1 .PF>> <PUT .PF 1 <>> <PUT .PT 1 <>>)
	    (.AC-TO?
	     <SET WIN <>>
	     <COND (<NOT <MEMQ .AC-TO? .MOVES-FROM>>
		    <SET AT1 <AC-TIME .AC-TO?>>
		    <SET AT2 <AC-TIME <SET AF <1 .PF>>>>
		    <SET GOT-ONE T>
		    <COND (<AND <NOT <EMPTY? <REST .PT>>>
				<SET P-TO? <2 .PT>>
				<==? <NEXT-AC <AC-NAME .P-TO?>>
				     <AC-NAME .AC-TO?>>
				<SET P-FROM <2 .PF>>
				<==? <NEXT-AC <AC-NAME .P-FROM>> <AC-NAME .AF>>
				<NOT <MEMQ .P-TO? .MOVES-FROM>>>
			   <SET PAT1 <AC-TIME .P-TO?>>
			   <SET PAT2 <AC-TIME .P-FROM>>
			   <OCEMIT DMOVE <AC-NAME .P-TO?> <AC-NAME .P-FROM>>
			   <AC-TIME .P-TO? .PAT1>
			   <AC-TIME .P-FROM .PAT2>
			   <PUT .PT 2 <>>
			   <PUT .PF 2 <>>)
			  (<AC-TYPE .AF>
			   <LOAD-TYPE-IN-AC <AC-NAME .AC-TO?> <AC-TYPE .AF>>)
			  (ELSE <OCEMIT MOVE <AC-NAME .AC-TO?> <AC-NAME .AF>>)>
		    <AC-TIME .AC-TO? .AT1>
		    <AC-TIME .AF .AT2>
		    <PUT .PT 1 <>>
		    <PUT .PF 1 <>>)>)>>
	.MOVES-TO
	.MOVES-FROM>
       <COND (.WIN <RETURN>)>
       <COND
	(<NOT .GOT-ONE>
	 <MAPR <>
	  <FUNCTION (PT PF
		     "AUX" (AC-TO? <1 .PT>) (AC-FROM <1 .PF>) PP1 PP2 AT1 AT2)
		  #DECL ((AT1 AT2) FIX (PT PF) <LIST <OR AC FALSE>>
			 (AC-TO? AC-FROM) <OR AC FALSE>)
		  <COND (<AND .AC-TO? .AC-FROM>
			 <SET AT1 <AC-TIME .AC-TO?>>
			 <SET AT2 <AC-TIME .AC-FROM>>
			 <OCEMIT EXCH <AC-NAME .AC-TO?> <AC-NAME .AC-FROM>>
			 <AC-TIME .AC-TO? .AT1>
			 <AC-TIME .AC-FROM .AT2>
			 <PUT .PT 1 <>>
			 <PUT .PF 1 <>>
			 <COND (<SET PP1 <MEMQ .AC-TO? .MOVES-FROM>>
				<PUT .PP1 1 .AC-FROM>)>
			 <COND (<AND <SET PP2 <MEMQ .AC-FROM .MOVES-FROM>>
				     <N==? .PP1 .PP2>>
				<PUT .PP2 1 .AC-TO?>)>
			 <MAPLEAVE>)>>
	  .MOVES-TO
	  .MOVES-FROM>)>
       <SET WIN T>>)>
   <COND (.UNCND <FLUSH-ACS>) (.LOOP? <LOGICAL-ESTABLISH .LS>)>
   <COND (.AC-P1
	  <COND (.AC-P2 (<AC-NAME .AC-P1> <AC-NAME .AC-P2>))
		(ELSE (<AC-NAME .AC-P1>))>)>>

<DEFINE FIND-FREE-TO (L1 L2 "AUX" (BEST <>)) 
	#DECL ((L1 L2) <LIST [REST AC]>)
	<MAPF <>
	      <FUNCTION (AC) #DECL ((AC) AC)
		   <COND (<NOT <MEMQ .AC .L1>>
			  <COND (<MEMQ .AC .L2>
				 <SET BEST .AC>
				 <MAPLEAVE>)
				(<NOT .BEST> <SET BEST .AC>)>)>>
	      ,AC-PAIR-TABLE>
	.BEST>

<DEFINE LOGICAL-ESTABLISH (LS) 
   #DECL ((LS) LABSTATE)
   <MAPF <>
    <FUNCTION (STAT "AUX" (AC <ACS-AC .STAT>)) 
	    #DECL ((STAT) ACSTATE (AC) AC)
	    <COND (<ACS-LOCAL .STAT>
		   <AC-CODE <AC-ITEM .AC <LATM <ACS-LOCAL .STAT>>>
			    <ACS-CODE .STAT>>
		   <AC-TYPE <AC-UPDATE .AC <NOT <ACS-STORED .STAT>>>
			    <ACS-TYPE .STAT>>)
		  (<FIND-LOCAL <AC-ITEM .AC> <AC-CODE .AC> .LS>
		   <AC-TIME <AC-ITEM <AC-CODE <AC-TYPE .AC <>> DUMMY> <>> 0>)
		  (<OR <==? <AC-CODE .AC> TYPE> <==? <AC-CODE .AC> VALUE>>
		   <AC-UPDATE .AC <>>)>>
    .LS>>

<DEFINE ESTABLISH-UPDATE (LS) 
	#DECL ((LS) LABSTATE)
	<MAPF <>
	      <FUNCTION (STAT "AUX" (AC <ACS-AC .STAT>)) 
		      #DECL ((STAT) ACSTATE (AC) AC)
		      <COND (<OR <AND <ACS-LOCAL .STAT> <ACS-STORED .STAT>>
				 <NOT <ACS-LOCAL .STAT>>>
			     <AC-UPDATE .AC <>>)>>
	      .LS>>

<DEFINE FIND-LOCAL (ATM COD LS "OPT" (STORE-CHECK <>)) 
	#DECL ((LS) LABSTATE)
	<MAPF <>
	      <FUNCTION (STAT) 
		      #DECL ((STAT) ACSTATE)
		      <COND (<AND <ACS-LOCAL .STAT>
				  <==? <LATM <ACS-LOCAL .STAT>> .ATM>
				  <==? .COD <ACS-CODE .STAT>>
				  <NOT <AND .STORE-CHECK <ACS-STORED .STAT>>>>
			     <MAPLEAVE T>)>>
	      .LS>>

<DEFINE FIND-AC (LCL COD "AUX" (ATM <LATM .LCL>)) 
	#DECL ((LCL) LOCAL)
	<MAPF <>
	      <FUNCTION (AC) 
		      #DECL ((AC) AC)
		      <COND (<AND <==? <AC-ITEM .AC> .ATM>
				  <==? <AC-CODE .AC> .COD>>
			     <MAPLEAVE .AC>)>>
	      ,AC-PAIR-TABLE>>

<DEFINE ESTABLISH-LABEL-STATE (LB "OPT" (LS <LAB-FINAL-STATE .LB>)) 
   #DECL ((LB) LAB (LS) <OR FALSE LABSTATE>)
   <COND
    (.LS
     <MAPF <>
	   <FUNCTION (STAT "AUX" AC ACL) 
		   #DECL ((STAT) ACSTATE (AC) AC)
		   <SET AC <ACS-AC .STAT>>
		   <COND (<AND <NOT ,LAST-UNCON>
			       <OR <SET ACL <ACS-LOCAL .STAT>>
				   <EMPTY? .ACL>
				   <N==? <LATM <1 .ACL>> <AC-ITEM .AC>>>
			       <OR <NOT .ACL>
				   <AND <ACS-STORED .STAT>
					<OR <NOT <ACS-TYPE .STAT>>
					    <NOT <LDECL .ACL>>>>>
			       <AC-UPDATE .AC>>
			  <UPDATE-AC .AC T>)>
		   <COND (<NOT <ACS-LOCAL .STAT>>
			  <AC-UPDATE .AC <>>
			  <AC-ITEM .AC <>>
			  <AC-CODE .AC DUMMY>)
			 (ELSE
			  <AC-CODE .AC <ACS-CODE .STAT>>
			  <AC-ITEM .AC <LATM <ACS-LOCAL .STAT>>>
			  <AC-UPDATE .AC <NOT <ACS-STORED .STAT>>>
			  <AC-TYPE .AC <ACS-TYPE .STAT>>)>>
	   .LS>
     <FLUSH-AC T*>
     <MUNGED-AC T*>
     <FLUSH-AC O*>
     <MUNGED-AC O*>)
    (ELSE <FLUSH-ACS>)>
   T>

<DEFINE PLS (LAB "AUX" (N 0))
	<COND (<TYPE? .LAB ATOM> <SET LAB <FIND-LABEL .LAB>>)>
	<CRLF>
	<PRINC "States for label: ">
	<PRIN1 <LAB-NAM .LAB>>
	<COND (<LAB-LOOP .LAB> <PRINC " (loop)">)>
	<CRLF>
	<CRLF>
	<COND (<LAB-FINAL-STATE .LAB>
	       <PRINC "Current final state">
	       <CRLF> <CRLF>
	       <PSTATE <LAB-FINAL-STATE .LAB>>)>
	<COND (<NOT <EMPTY? <LAB-STATE .LAB>>>
	       <MAPF <>
		     <FUNCTION (S)
			  <PRINC "State ">
			  <PRIN1 <SET N <+ .N 1>>>
			  <CRLF>
			  <CRLF>
			  <PSTATE .S>>
		     <LAB-STATE .LAB>>)>>

<DEFINE PSTATE (LS) #DECL ((LS) LABSTATE)
	<MAPF <>
	      <FUNCTION (ACS) #DECL ((ACS) ACSTATE)
		   <COND (<ACS-LOCAL .ACS>
			  <PRIN1 <AC-NAME <ACS-AC .ACS>>>
			  <PRINC " ">
			  <PRIN1 <LATM <ACS-LOCAL .ACS>>>
			  <PRINC <COND (<ACS-STORED .ACS> " stored ")
				       (ELSE " not stored ")>>
			  <COND (<ACS-TYPE .ACS>
				 <PRINC "type is ">
				 <PRIN1 <ACS-TYPE .ACS>>)>
			  <CRLF>)
			 (<==? <ACS-STORED .ACS> DEAD>
			  <PRIN1 <AC-NAME <ACS-AC .ACS>>>
			  <PRINC " ">
			  <PRIN1 <LATM <1 <ACS-LOCAL .ACS>>>>
			  <PRINC " dead!">
			  <CRLF>)>>
	      .LS>>
		    
<DEFINE MERGE-LABEL-STATES () 
	<MAPF <>
	      <FUNCTION (LAB "AUX" (LS <LAB-STATE .LAB>) TEM) 
		      #DECL ((LAB) LAB)
		      <COND (<SET TEM <LAB-FINAL-STATE .LAB>>)
			    (<NOT <EMPTY? .LS>>
			     <SET TEM <1 .LS>>
			     <SET LS <REST .LS>>)>
		      <COND (<NOT <EMPTY? .LS>> <MERGE-ONE-SET .TEM .LS .LAB>)
			    (ELSE
			     <PUT .LAB ,LAB-STATE ()>
			     <PUT .LAB ,LAB-FINAL-STATE .TEM>)>>
	      ,LABELS>>

<DEFINE MERGE-ONE-SET (FIRST RESTP LAB) 
	#DECL ((RESTP) <LIST LABSTATE [REST LABSTATE]> (FIRST) LABSTATE
	       (LAB) LAB)
	<MAPF <>
	      <FUNCTION (NEXT "AUX" CH) 
		      #DECL ((NEXT) LABSTATE)
		      <SET CH
			   <COND (<LAB-LOOP .LAB>
				  <MERGE-TWO-FORCE .FIRST .NEXT>)
				 (ELSE <MERGE-TWO .FIRST .NEXT>)>>
		      <COND (.CH <SETG CHANGED .CH>)>>
	      .RESTP>
	<PUT .LAB ,LAB-FINAL-STATE .FIRST>
	<PUT .LAB ,LAB-STATE ()>>

<DEFINE MERGE-TWO (ONE TWO "AUX" (CHANGED <>)) 
   #DECL ((ONE TWO) LABSTATE)
   <MAPR <>
    <FUNCTION (AP1 AP2 NSP
	       "AUX" (ACST1 <1 .AP1>) (ACST2 <1 .AP2>) (NULL-STATE <1 .NSP>)
		     (LD <>))
       #DECL ((ACST1 ACST2 NULL-STATE) ACSTATE)
       <COND (<AND <ACS-LOCAL .ACST1>
		   <ACS-LOCAL .ACST2>
		   <==? <LATM <ACS-LOCAL .ACST1>> <LATM <ACS-LOCAL .ACST2>>>
		   <==? <ACS-CODE .ACST1> <ACS-CODE .ACST2>>
		   <OR <==? <ACS-TYPE .ACST1> <ACS-TYPE .ACST2>>
		       <AND <SET LD <LDECL <ACS-LOCAL .ACST1>>>
			    <ACS-TYPE <ACS-STORED .ACST1 T> .LD>
			    <ACS-TYPE <ACS-STORED .ACST2 T> .LD>
			    <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>>>>
	      <COND (<N==? <NOT <ACS-STORED .ACST2>> <NOT <ACS-STORED .ACST1>>>
		     <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
		     <COND (<AND <ACS-TYPE .ACST1> <LDECL <ACS-LOCAL .ACST1>>>
			    <ACS-STORED .ACST1 T>)
			   (<OR <==? <ACS-STORED .ACST1> HACKED>
				<==? <ACS-STORED .ACST2> HACKED>>
			    <ACS-STORED .ACST1 HACKED>)
			   (ELSE <ACS-STORED .ACST1 <>>)>)>)
	     (ELSE
	      <COND (<==? .ACST1 .NULL-STATE>
		     <PUT .AP1 1 .ACST2>
		     <PUT .AP2 1 <SET ACST2 .ACST1>>
		     <SET ACST1 <1 .AP1>>)>
	      <COND (<AND <ACS-LOCAL .ACST1>
			  <OR <ACS-LOCAL .ACST2>
			      <EMPTY? <ACS-LOCAL .ACST2>>
			      <N==? <LATM <ACS-LOCAL .ACST1>>
				    <LATM <1 <ACS-LOCAL .ACST2>>>>>>
		     <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
		     <LUPD <ACS-LOCAL .ACST1> T>
		     <ACS-STORED <ACS-LOCAL .ACST1 <>> <>>)>)>>
    .ONE
    .TWO
    ,NULL-STATES>
   .CHANGED>

<DEFINE MERGE-TWO-FORCE (ONE TWO "AUX" (CHANGED <>) (WINNERS 0)) 
   #DECL ((ONE TWO) LABSTATE (WINNERS) FIX)
   <MAPF <>
    <FUNCTION (ACST1) 
       #DECL ((ACST1) ACSTATE)
       <COND
	(<AND
	  <ACS-LOCAL .ACST1>
	  <SET WINNERS <+ .WINNERS 1>>
	  <MAPF <>
	   <FUNCTION (ACST2 "AUX" LCL) 
	      #DECL ((ACST2) ACSTATE)
	      <COND
	       (<AND <SET LCL <ACS-LOCAL .ACST2>>
		     <==? <LATM <ACS-LOCAL .ACST1>> <LATM <ACS-LOCAL .ACST2>>>
		     <==? <ACS-CODE .ACST1> <ACS-CODE .ACST2>>
		     <OR <AND <NOT <ACS-TYPE .ACST1>> <NOT <ACS-TYPE .ACST2>>>
			 <AND <==? <ACS-TYPE .ACST1> <ACS-TYPE .ACST2>>
			      <OR <==? <NOT <ACS-STORED .ACST1>>
				       <NOT <ACS-STORED .ACST2>>>
				  <AND <LDECL .LCL>
				       <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
				       <ACS-STORED .ACST1 T>
				       <ACS-STORED .ACST2 T>>
				  <AND <OR <==? <ACS-STORED .ACST1> HACKED>
					   <==? <ACS-STORED .ACST2> HACKED>>
				       <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
				       <ACS-STORED .ACST1 HACKED>
				       <ACS-STORED .ACST2 HACKED>>
				  <AND <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
				       <ACS-STORED .ACST1 <>>
				       <ACS-STORED .ACST2 <>>>>>
			 <AND <LDECL .LCL>
			      <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
			      <ACS-STORED <ACS-TYPE .ACST1 <LDECL .LCL>> T>
			      <ACS-STORED <ACS-TYPE .ACST2 <LDECL .LCL>> T>>>>
		<COND (<N==? <NOT <ACS-STORED .ACST1>>
			     <NOT <ACS-STORED .ACST2>>>
		       <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
		       <COND (<OR <==? <ACS-STORED .ACST1> HACKED>
				  <==? <ACS-STORED .ACST2> HACKED>>
			      <ACS-STORED .ACST1 HACKED>
			      <ACS-STORED .ACST2 HACKED>)
			     (ELSE
			      <ACS-STORED .ACST1 <>>
			      <ACS-STORED .ACST2 <>>)>)>
		<MAPLEAVE>)>>
	   .TWO>>)
	(ELSE
	 <COND (<ACS-LOCAL .ACST1>
		<SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
		<LUPD <ACS-LOCAL .ACST1> T>)>
	 <ACS-STORED <ACS-LOCAL .ACST1 <>> <>>)>>
    .ONE>
   <MAPF <>
	 <FUNCTION (ACST1) 
		 #DECL ((ACST1) ACSTATE)
		 <COND (<ACS-LOCAL .ACST1>
			<COND (<L? <SET WINNERS <- .WINNERS 1>> 0>
			       <SET CHANGED <LATM <ACS-LOCAL .ACST1>>>
			       <MAPLEAVE>)>)>>
	 .TWO>
   .CHANGED>

<DEFINE PLOCAL-NAME (LN "AUX" LCL) #DECL ((LN) LOCAL-NAME)
	<OR <SET LCL <L-N-LMEMQ .LN ,LOCALS>>
	    <AND ,ICALL-FLAG
		 <SET LCL
		      <L-N-LMEMQ .LN ,ICALL-TEMPS>>>>
	<COND (.LCL <PRINC <LATM .LCL>>)
	      (ELSE <PRINC "#LOC "><PRIN1 <CHTYPE .LN FIX>>)>>


<DEFINE PCONST-LABEL (CL "AUX" TEM) 
	#DECL ((CL) CONSTANT-LABEL)
	<COND (<SET TEM <MEMQ .CL ,CONSTANT-VECTOR>>
	       <SET TEM <2 .TEM>>
	       <COND (<TYPE? .TEM CONSTANT> <PRIN1 <CHTYPE .TEM FIX>>)
		     (ELSE <PRIN1 <CHTYPE .TEM LIST>>)>)
	      (ELSE <PRINC "#CL "> <PRIN1 <CHTYPE .CL FIX>>)>>

<DEFINE PCONST-BUCK (CB:CONSTANT-BUCKET "AUX" (TEM <CB-VAL .CB>))
	<COND (<TYPE? .TEM CONSTANT> <PRIN1 <CHTYPE .TEM FIX>>)
	      (ELSE <PRIN1 <CHTYPE .TEM LIST>>)>>

<COND (<GASSIGNED? PCONST-BUCK> <PRINTTYPE CONSTANT-BUCKET ,PCONST-BUCK>)>

<COND (<GASSIGNED? PLOCAL-NAME> <PRINTTYPE LOCAL-NAME ,PLOCAL-NAME>)>

<COND (<GASSIGNED? PCONST-LABEL> <PRINTTYPE CONSTANT-LABEL ,PCONST-LABEL>)>
