

<DEFINE MOVE-STRING!-MIMOC (L "AUX" (FROM <1 .L>) (TO <2 .L>) (CNT <3 .L>)
				    (NO-OVERLAP? <EXTRAMEM NO-OVERLAP .L>))
	#DECL ((L) LIST)
	<COND (.NO-OVERLAP? <SET NO-OVERLAP? <2 .NO-OVERLAP?:LIST>>)>
	<COND (<WILL-DIE? .FROM> <DEAD!-MIMOC (.FROM) T>)>
	<COND (<WILL-DIE? .TO> <DEAD!-MIMOC (.TO) T>)>
	<COND (<WILL-DIE? .CNT> <DEAD!-MIMOC (.CNT) T>)>
	<UPDATE-ACS>
	<COND (.NO-OVERLAP?
	       <GET-INTO-ACS .CNT VALUE A1* .FROM VALUE A2*
			     .TO VALUE C1*>
	       <OCEMIT SETZB B1* C2*>
	       <OCEMIT MOVEI B2* '(A1*)>
	       <OCEMIT XBLT A1* !<OBJ-VAL *016000000000*>>
	       <OCEMIT JRST <XJUMP IOERR>>
	       <FLUSH-ACS>)
	      (ELSE
	       <GET-INTO-ACS .FROM VALUE O1* .TO VALUE O2* .CNT VALUE O*>
	       <FLUSH-ACS>
	       <PUSHJ MOVSTR>)>>

<DEFINE MOVE-WORDS!-MIMOC (L "AUX" (FROM <1 .L>) (TO <2 .L>) (CNT <3 .L>)
				   (TY <EXTRAMEM TYPE .L>) (TG <GENLBL "BLT">) 
				   (DIRECTION <EXTRAMEM DIRECTION .L>))
	#DECL ((L) LIST)
	<COND (.TY <SET TY <2 .TY:LIST>>)>
	<COND (.DIRECTION <SET DIRECTION <2 .DIRECTION:LIST>>)>
	<COND (<AND <TYPE? .CNT FIX> <==? .TY VECTOR>> <SET CNT <* .CNT 2>>)>
	<GET-INTO-ACS .FROM VALUE O1* .TO VALUE O2*>
	<COND (<NOT .DIRECTION>
	       <GET-INTO-ACS .CNT VALUE T*>
	       <COND (<AND <NOT <TYPE? .CNT FIX>> <==? .TY VECTOR>>
		      <OCEMIT ASH T* 1>)>
	       <OCEMIT CAMG O2* O1*>
	       <OCEMIT JRST <XJUMP .TG>>
	       <OCEMIT ADD O1* T*>
	       <OCEMIT ADD O2* T*>
	       <OCEMIT MOVNS O* T*>
	       <LABEL .TG>)
	      (<==? .DIRECTION BACKWARD>
	       <COND (<TYPE? .CNT FIX>
		      <OCEMIT MOVNI T* .CNT>
		      <OCEMIT ADDI O1* .CNT>
		      <OCEMIT ADDI O2* .CNT>)
		     (ELSE
		      <OCEMIT MOVN T* !<OBJ-VAL .CNT>>
		      <COND (<==? .TY VECTOR> <OCEMIT ASH T* 1>)>
		      <OCEMIT SUB O1* T*>
		      <OCEMIT SUB O2* T*>)>)
	      (ELSE
	       <GET-INTO-ACS .CNT VALUE T*>
	       <COND (<AND <NOT <TYPE? .CNT FIX>> <==? .TY VECTOR>>
		      <OCEMIT ASH T* 1>)>)>
	<OCEMIT XBLT T* !<OBJ-VAL *020000000000*>>>

<DEFINE STRING-EQUAL?!-MIMOC (L "AUX" (S1 <1 .L>) (S2 <2 .L>) (DIR <3 .L>)
				     (LBL <4 .L>) (LBL2 <GENLBL "SE">))
	#DECL ((L) LIST)
	<COND (<OR <TYPE? .S2 STRING>
		   <==? <IN-AC? .S2 VALUE> A2*>
		   <AND <IN-AC? .S2 VALUE> <NOT <IN-AC? .S1 VALUE>>>>
	       <SET S1 .S2>
	       <SET S2 <1 .L>>)>
	<COND (<AND <TYPE? .S1 ATOM>
		    <WILL-DIE? .S1>
		    <LAB-WILL-DIE <FIND-LABEL .LBL> .S1
				  <SETG VISIT-COUNT <+ ,VISIT-COUNT 1>>
				  <>>>
	       <DEAD!-MIMOC (.S1) T>)>
	<COND (<AND <TYPE? .S2 ATOM>
		    <WILL-DIE? .S2>
		    <LAB-WILL-DIE <FIND-LABEL .LBL> .S2
				  <SETG VISIT-COUNT <+ ,VISIT-COUNT 1>>
				  <>>>
	       <DEAD!-MIMOC (.S2) T>)>
 	<UPDATE-ACS>
	<COND (<TYPE? .S1 STRING>
	       <OCEMIT HRRZ A1* !<OBJ-TYP .S2>>
	       <OCEMIT CAIE A1* <LENGTH .S1>>
	       <OCEMIT JRST <XJUMP <COND (<==? .DIR +> .LBL2) (ELSE .LBL)>>>
	       <COND (<N==? <IN-AC? .S2 VALUE> A2*>
		      <OCEMIT MOVE A2* !<OBJ-VAL .S2>>)>
	       <OCEMIT MOVE C1* !<OBJ-VAL .S1>>
	       <OCEMIT MOVEI B2* <LENGTH .S1>>)
	      (ELSE
	       <OCEMIT HRRZ A1* !<OBJ-TYP .S1>>
	       <COND (<AND <==? <IN-AC? .S1 VALUE> A2*>
			   <==? <IN-AC? .S2 VALUE> B2*>>
		      <OCEMIT MOVE C1* B2*>
		      <OCEMIT HRRZ B2* !<OBJ-TYP .S2>>)
		     (<==? <IN-AC? .S1 VALUE> B2*>
		      <OCEMIT MOVE A2* B2*>
		      <OCEMIT HRRZ B2* !<OBJ-TYP .S2>>
		      <OCEMIT MOVE C1* !<OBJ-VAL .S2>>)
		     (<==? <IN-AC? .S2 VALUE> B2*>
		      <OCEMIT MOVE C1* B2*>
		      <OCEMIT HRRZ B2* !<OBJ-TYP .S2>>
		      <COND (<N==? <IN-AC? .S1 VALUE> A2*>
			     <OCEMIT MOVE A2* !<OBJ-VAL .S1>>)>)
		     (ELSE
		      <OCEMIT HRRZ B2* !<OBJ-TYP .S2>>
		      <COND (<N==? <IN-AC? .S1 VALUE> A2*>
			     <OCEMIT MOVE A2* !<OBJ-VAL .S1>>)>
		      <OCEMIT MOVE C1* !<OBJ-VAL .S2>>)>
	       <OCEMIT CAIE A1* '(B2*)>
	       <OCEMIT JRST <XJUMP <COND (<==? .DIR +> .LBL2) (ELSE .LBL)>>>)>
	<FLUSH-ACS>
	<LABEL-UPDATE-ACS .LBL <>>
	<OCEMIT SETZB B1* C2*>
	<OCEMIT XBLT A1* !<OBJ-VAL <COND (<==? .DIR +> *006000000000*)
					 (ELSE *002000000000*)>>>
	<OCEMIT JRST <XJUMP .LBL>>
	<COND (<==? .DIR +> <LABEL .LBL2>)>>

<DEFINE STRCOMP!-MIMOC (L "AUX" (S1 <1 .L>) (S2 <2 .L>) (VAL <4 .L>)
				(T1 <GENLBL "TG">) (T2 <GENLBL "TG">)
				(T3 <GENLBL "TG">) AC)
	#DECL ((L) LIST)
	<COND (<TYPE? .S2 STRING>
	       <SET S1 .S2>
	       <SET S2 <1 .L>>)>
	<COND (<WILL-DIE? .S1> <DEAD!-MIMOC (.S1) T>)>
	<COND (<WILL-DIE? .S2> <DEAD!-MIMOC (.S2) T>)>
 	<UPDATE-ACS>
	<OCEMIT HRRZ O* !<OBJ-TYP .S1>>
	<OCEMIT HRRZ B1* !<OBJ-TYP .S2>>
	<GET-INTO-ACS .S1 VALUE A1* .S2 VALUE B2*>
	<FLUSH-ACS>
	<OCEMIT MOVEI C2* 1>
	<OCEMIT CAMN O* B1*>
	<OCEMIT SOJA C2* <XJUMP .T2>>
	<OCEMIT CAML O* B1*>
	<OCEMIT JRST <XJUMP .T3>>
	<OCEMIT MOVNI C2* 1>
	<OCEMIT SKIPA B1* O*>
	<LABEL .T3>
	<OCEMIT MOVE O* B1*>
	<LABEL .T2>
	<OCEMIT SETZB A2* C1*>
	<OCEMIT XBLT O* !<OBJ-VAL *006000000000*>>
	<OCEMIT JRST <XJUMP .T1>>
	<OCEMIT LDB O* A1*>
	<OCEMIT LDB B1* B2*>
	<OCEMIT MOVEI C2* 1>
	<OCEMIT CAMG O* B1*>
	<OCEMIT MOVNI C2* 1>
	<LABEL .T1>
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <OCEMIT PUSH TP* C2*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (.VAL
	       <SET AC <GET-AC C1*>>
	       <AC-ITEM .AC .VAL>
	       <AC-CODE .AC TYPE>
	       <AC-UPDATE .AC T>
	       <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
	       <AC-TYPE .AC FIX>
	       <SET AC <GET-AC C2*>>
	       <AC-ITEM .AC .VAL>
	       <AC-CODE .AC VALUE>
	       <AC-UPDATE .AC T>
	       <AC-TIME .AC ,AC-STAMP>)>> 