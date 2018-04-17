<DEFINE DISPATCH!-MIMOC (L
			 "AUX" (VAR <1 .L>) (BASE <2 .L>) DELBL AC (DF <>)
			       (DLBL <GENLBL "DISP">) RLBLS (LL .MIML) NEW AC-T
			       TAC (NV <- <LENGTH .L> 2>) (DISP-L ()))
	#DECL ((LL MIML L) LIST (BASE NV) FIX (DISP-L) <SPECIAL LIST>)
	<SET RLBLS
	     <MAPF ,LIST
		   <FUNCTION (LBL "AUX" LB LBX) 
			   <COND (<AND <SET LB <FIND-LABEL .LBL>>
				       <LAB-LOOP .LB>>
				  <COND (<NOT <FIND-LABEL
					       <SET LBX <GENLBL "LOOPD">>>>
					 <MAKE-LABEL .LBX <> ()>)>
				  (.LBL .LBX))
				 (ELSE (.LBL .LBL))>>
		   <REST .L 2>>>
	<SET DISP-L <MAPF ,LIST <FUNCTION (L:LIST) <2 .L>> .RLBLS>>
	<REPEAT (ITM)
		<COND (<OR <EMPTY? <SET LL <REST .LL>>>
			   <AND <TYPE? <SET ITM <1 .LL>> FORM>
				<OR <EMPTY? .ITM> <N==? <1 .ITM> DEAD>>>>
		       <RETURN>)
		      (<TYPE? .ITM ATOM>
		       <SET DELBL .ITM>
		       <SET DF T>
		       <RETURN>)>>
	<COND (<SET AC <IN-AC? .VAR BOTH>> <SET AC <NEXT-AC <SET TAC .AC>>>)
	      (<SET AC <IN-AC? .VAR VALUE>>)
	      (ELSE <SET AC <NEXT-AC <SET TAC <LOAD-AC .VAR BOTH>>>>)>
	<COND (<NOT .DF>
	       <SET DELBL <GENLBL "DEFAULT">>
	       <COND (<NOT <FIND-LABEL .DELBL>>
		      <MAKE-LABEL .DELBL <> ()>)>)>
	<LABEL-UPDATE-ACS .DELBL <>>
	<COND (<AND <G=? .BASE 0> <L=? .BASE 1>>
	       <OCEMIT <COND (<==? .BASE 0> JUMPL) (ELSE JUMPLE)>
		       .AC
		       <XJUMP .DELBL>>
	       <OCEMIT CAILE .AC <+ .NV .BASE -1>>
	       <OCEMIT JRST O* <XJUMP .DELBL>>)
	      (ELSE
	       <COND (<G? .BASE 0> <OCEMIT CAIL .AC .BASE>)
		     (ELSE <OCEMIT CAML .AC !<OBJ-VAL .BASE>>)>
	       <COND (<G? <SET NV <+ .NV .BASE -1>> 0> <OCEMIT CAILE .AC .NV>)
		     (ELSE <OCEMIT CAMLE .AC !<OBJ-CAL .NV>>)>
	       <OCEMIT JRST O* <XJUMP .DELBL>>)>
	<OCEMIT XMOVEI O1* <XJUMP .DLBL>>
	<OCEMIT ADD O1* .AC>
	<MAPF <> <FUNCTION (LBL) <LABEL-UPDATE-ACS <2 .LBL> <>>> .RLBLS>
	<SETG LAST-UNCON T>
	<OCEMIT JRST @ <- .BASE> '(O1*)>
	<LABEL .DLBL>
	<MAPF <> <FUNCTION (LBL) <OCEMIT SETZ O* <XJUMP <2 .LBL>>>> .RLBLS>
	<MAPF <>
	      <FUNCTION (LBL) 
		      <COND (<N==? <1 .LBL> <2 .LBL>>
			     <LABEL <2 .LBL>>
			     <JUMP!-MIMOC <1 .LBL>>)>>
	      .RLBLS>
	<COND (<NOT .DF>
	       <COND (,PASS1 <SET LB <LABEL .DELBL>> <SAVE-LABEL-STATE .LB>)
		     (,NO-AC-FUNNYNESS <SAVE-ACS> <SET LB <LABEL .DELBL>>)
		     (ELSE
		      <SET LB <FIND-LABEL .DELBL>>
		      <ESTABLISH-LABEL-STATE .LB>
		      <LABEL .DELBL>)>)>>