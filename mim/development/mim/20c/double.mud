<OP-20 DFAD *110*>
<OP-20 DFSB *111*>
<OP-20 DFMP *112*>
<OP-20 DFDV *113*>

<DEFINE DOUBLE!-MIMOC (L "AUX" (OP <1 .L>) (A1 <2 .L>) (A2 <3 .L>)
			       (VV <4 .L>) (VAL <6 .L>) AC INS
			       (RFALSE <GENLBL "DBL">))
	#DECL ((L) LIST (OP) <OR <FORM ATOM ATOM> ATOM>)
	<COND (<TYPE? .OP FORM> <SET OP <2 .OP>>)>
	<UPDATE-ACS>
	<COND (<SET AC <IN-AC? .A1 VALUE>>
	       <OCEMIT DMOVE O1* (.AC)>)
	      (ELSE
	       <OCEMIT DMOVE O1* @ !<OBJ-VAL .A1>>)>
	<SET INS <COND (<==? .OP +> DFAD)
		       (<==? .OP -> DFSB)
		       (<==? .OP *> DFMP)
		       (ELSE DFDV)>>
	<COND (<SET AC <IN-AC? .A2 VALUE>> <OCEMIT .INS O1* (.AC)>)
	      (ELSE <OCEMIT .INS O1* @ !<OBJ-VAL .A2>>)>
	<OCEMIT JFCL A1* <XJUMP .RFALSE>>
	<COND (<AND <==? .A2 .VV> .AC>
	       <OCEMIT DMOVEM O1* (.AC)>)
	      (ELSE <OCEMIT DMOVEM O1* @ !<OBJ-VAL .VV>>)>
	<OCEMIT MOVSI A1* <TYPE-CODE FIX>>
	<OCEMIT CAIA O* O*>
	<LABEL .RFALSE>
	<OCEMIT MOVSI A1* <TYPE-CODE FALSE>>
	<OCEMIT MOVEI A2* 0>
	<PUSHJ-VAL .VAL>>
