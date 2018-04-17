<COND (<NOT <GASSIGNED? M$$R-BHWD>> <SETG M$$R-BHWD 18>)>

<COND (<GASSIGNED? PUTBITS>
       <SETG OPUTBITS ,PUTBITS>
       <SETG OGETBITS ,GETBITS>
       <SETG OBITS ,BITS>)>

<DEFMAC BITS ('WID "OPTIONAL" ('SHFT 0))
  <FORM CHTYPE <FORM ORB .SHFT <FORM LSH .WID ,M$$R-BHWD>> BITS>>

<DEFMAC GETBITS ('FROM 'BTS "AUX" RB FV)
  <COND (<SET RB <HACK-BITS .BTS>>
	 <COND (<AND <SET FV <CONST? .FROM>>
		     <TYPE? <1 .RB> FIX>
		     <TYPE? <2 .RB> FIX>>
		<FGETBITS .FV <1 .RB> <2 .RB>>)
	       (<==? <1 .RB> 0> 0)
	       (<AND <==? <2 .RB> 0>
		     <TYPE? <1 .RB> FIX>>
		<FORM ANDB .FROM <XORB <LSH -1 <1 .RB>> -1>>)
	       (<FORM FGETBITS .FROM <1 .RB> <2 .RB>>)>)
	(T
	 <FORM BIND ((MSK <FORM LSH -1 <FORM - ',M$$R-BHWD>>)
		     (RB .BTS) (SHFT <FORM ANDB '.RB '.MSK>)
		     (WID <FORM ANDB <FORM LSH '.RB <FORM - ',M$$R-BHWD>>
				'.MSK>))
	   <FORM FGETBITS .FROM '.WID '.SHFT>>)>>

<DEFMAC PUTBITS ('TO 'BTS "OPTIONAL" ('FROM 0) "AUX" RB FV TV)
  <COND (<SET RB <HACK-BITS .BTS>>
	 <COND (<AND <SET FV <CONST? .FROM>>
		     <SET TV <CONST? .TO>>
		     <TYPE? <1 .RB> FIX>
		     <TYPE? <2 .RB> FIX>>
		<FPUTBITS .TV <1 .RB> <2 .RB> .FV>)
	       (<==? <1 .RB> 0>
		.TO)
	       (<AND <==? <2 .RB> 0>
		     <TYPE? <1 .RB> FIX>
		     <==? .FV 0>>
		<FORM ANDB .TO <LSH -1 <1 .RB>>>)
	       (<FORM FPUTBITS .TO <1 .RB> <2 .RB> .FROM>)>)
	(T
	 <FORM BIND ((MSK <FORM LSH -1 <FORM - ',M$$R-BHWD>>)
		     (RB .BTS) (SHFT <FORM ANDB '.RB '.MSK>)
		     (WID <FORM ANDB <FORM LSH '.RB <FORM - ',M$$R-BHWD>>
				'.MSK>))
	   <FORM FPUTBITS .TO '.WID '.SHFT .FROM>>)>>

<DEFINE CONST? (FROB)
  <COND (<MEMQ <PRIMTYPE .FROB> '[WORD FIX]>
	 .FROB)
	(<AND <TYPE? .FROB GVAL>
	      <MANIFEST? <CHTYPE .FROB ATOM>>>
	 ,<CHTYPE .FROB ATOM>)
	(<AND <TYPE? .FROB FORM>
	      <==? <LENGTH .FROB> 2>
	      <==? <1 .FROB> GVAL>
	      <TYPE? <2 .FROB> GVAL>
	      <MANIFEST? <2 .FROB>>>
	 ,<2 .FROB>)>>

<DEFINE HACK-BITS (BTS "AUX" WID SHIFT MSK HWD NV)
  <COND (<SET NV <CONST? .BTS>>
	 <COND (<==? <PRIMTYPE 1> FIX>
		<SET HWD ,M$$R-BHWD>)
	       (<SET HWD 18>)>
	 <SET MSK <LSH -1 <- .HWD>>>
	 <SET SHIFT <CHTYPE <ORB .NV .MSK> FIX>>
	 <SET WID <CHTYPE <ORB <LSH .NV <- .HWD>> .MSK> FIX>>
	 (.WID .SHIFT))
	(<AND <TYPE? .BTS FORM>
	      <NOT <LENGTH? .BTS 1>>
	      <==? <1 .BTS> BITS>>
	 (<2 .BTS> <COND (<LENGTH? .BTS 2> 0)
			 (<3 .BTS>)>))>>

<DEFINE FGETBITS (FROM WID SHIFT "AUX" (MSK <XORB <LSH -1 .WID> -1>))
  <CHTYPE <ANDB <LSH .FROM <- .SHIFT>> .MSK> FIX>>

<DEFINE FPUTBITS (TO WID SHIFT FROM "AUX" (MSK <LSH -1 .WID>))
  <CHTYPE <ORB <LSH <ANDB .FROM <XORB .MSK -1>> .SHIFT>
	       <ANDB .TO <ROT .MSK .SHIFT>>>
	  FIX>>