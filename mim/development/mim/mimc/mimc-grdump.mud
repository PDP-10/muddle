
<PACKAGE "MIMC-GRDUMP">

<ENTRY MIMC-GROUP-DUMP DUMP-CODE>

<USE "COMFIL" "COMPDEC" "HASH">

<MSETG M$$PRINT 5>

<MSETG M$$OFF-FIX 1>

<MSETG M$$OFF-DCL 2>

<MSETG M$$OFF-ELT 3>

<MSETG M$$NTYPE 1>

<MSETG M$$PTYPE 2>

<MSETG M$$TYOFF 6>

<MSETG M$$TYPE-INFO-SIZE 1024>

<MSETG TUP-CHAN 1>

<MSETG TUP-OBL 2>

<MSETG TUP-BUF 3>

<MSETG TUP-BUFL 4>

<MSETG BUFLNT 1024>

<MSETG BACK-SLASH <ASCII 92>>


; "PRINT's magic finite-state machine for atoms"

<SETG M$$FS-NSTATE 9>	; "# states, not counting terminals"
<SETG M$$FS-NOSLASH <+ ,M$$FS-NSTATE 1>>	; "No initial \ needed"
<SETG M$$FS-SLASH1 <+ ,M$$FS-NSTATE 2>>	; "Initial \ needed"
<SETG M$$FS-SLASH2 <+ ,M$$FS-NSTATE 3>>	; "Initial \ needed, done otherwise"
<SETG M$$END-STATE 6>	; "Slot in state for end of string"
<MANIFEST M$$FS-NSTATE M$$FS-NOSLASH M$$FS-SLASH1 M$$FS-SLASH2 M$$END-STATE>
 
<GDECL (BUFFER) STRING (I$FLOAT-TABLE!-INTERNAL) <VECTOR [REST FLOAT]>
       (M$$TYPE-INFO!-INTERNAL) <VECTOR [REST <OR TYPE-ENTRY FALSE>]>>

<SETG M$$R-BACKS 15>
<SETG M$$R-MIN-NUM-PART 17>
<SETG M$$R-MAX-ATM-BRK 13>
<MANIFEST M$$R-MAX-ATM-BRK M$$R-BACKS M$$R-MIN-NUM-PART>

<SETG BUFFER <ISTRING ,BUFLNT>>

<SETG ROOT-OBL <ROOT>>

<DEFINE MIMC-GROUP-DUMP (STR NAM TEMPCH
		       "AUX" OUTCHAN BKS POS TEM
			     (OBL <COND (<EMPTY? .OBLIST> FULL-OBL) (BLOCK)>)
			     (OOBLIST .OBLIST) (GROUP-INDICATOR DEFINE)
			     (IOTUP <TUPLE 0 0 ,BUFFER 0>)
			     IOB MACRO-NAME FUNC TEMP GOODS THIS-FORM)
   #DECL ((STR) STRING (POS) <PRIMTYPE LIST> (OUTCHAN) <OR FALSE <CHANNEL 'DISK>>
	  (NAM OBL GROUP-INDICATOR) ATOM (GOODS) LIST (THIS-FORM) FORM)
   <UNWIND
    <PROG ()
      <COND (<NOT <SET OUTCHAN <OPEN "PRINT" .STR>>>
	     <RETURN .OUTCHAN>)>
      <SET IOB <GETPROP .NAM .OBL '.OOBLIST>>
      <PUT .IOTUP ,TUP-CHAN .OUTCHAN>
      <PUT .IOTUP ,TUP-OBL .IOB>
      <SET GOODS ..NAM>
      <REPEAT (TEM CH)
	<COND (<EMPTY? .GOODS> <RETURN>)>
	<SET MACRO-NAME <>>
	<COND
	 (<AND <TYPE? <1 .GOODS> FORM>
	       <SET THIS-FORM <1 .GOODS>>
	       <G? <LENGTH .THIS-FORM> 1>
	       <OR <==? DEFINE <1 .THIS-FORM>>
		   <AND <==? DEFMAC <1 .THIS-FORM>>
			<SET MACRO-NAME <2 .THIS-FORM>>>>
	       <TYPE? <SET FUNC <GETPROP <2 .THIS-FORM> VALUE '<2 .THIS-FORM>>>
		      ATOM>>
	  <COND (<NOT <GASSIGNED? .FUNC>>)
		(ELSE
		 <COND (<TYPE? <SET TEM ,.FUNC> FUNCTION>
			<PUTREST <REST .THIS-FORM> .TEM>
			<MIMC-PRINT .THIS-FORM .IOTUP>
			<MIMC-CRLF .IOTUP>)
		       (<AND <TYPE? .TEM MACRO>
			     <NOT <EMPTY? .TEM>>
			     <TYPE? <1 .TEM> FUNCTION>>
			<PUTREST <REST .THIS-FORM> <1 .TEM>>
			<MIMC-PRINT .THIS-FORM .IOTUP>
			<MIMC-CRLF .IOTUP>)
		       (<TYPE? .TEM INS-LIST ACCESS-LIST>
			<COND (<TYPE? .TEM ACCESS-LIST>
			       <ACCESS <SET CH <1 .TEM>> <2 .TEM>>
			       <MIMC-PRINT <CHTYPE <4 .TEM> WORD> .IOTUP>
			       <MIMC-CRLF .IOTUP>
			       <CHANNEL-OP .OUTCHAN WRITE-BUFFER
					   <TUP-BUF .IOTUP> <TUP-BUFL .IOTUP>>
			       <TUP-BUFL .IOTUP 0>
			       <REPEAT ((SIZ <- <3 .TEM> <2 .TEM>>)
					(BUF <TUP-BUF .IOTUP>))
				  #DECL ((SIZ) FIX)
				  <COND (<G? .SIZ ,BUFLNT>
					 <CHANNEL-OP .CH READ-BUFFER .BUF>
					 <CHANNEL-OP .OUTCHAN
						     WRITE-BUFFER .BUF>)
					(ELSE
					 <CHANNEL-OP .CH READ-BUFFER .BUF .SIZ>
					 <CHANNEL-OP .OUTCHAN
						     WRITE-BUFFER .BUF .SIZ>
					 <COND (<G? <LENGTH .TEM> 4>
						<SET TEM <5 .TEM>>
						<SET SIZ <- <3 .TEM>
							    <2 .TEM> -1>>
						<ACCESS <SET CH <1 .TEM>>
							<2 .TEM>>
						<AGAIN>)
					       (ELSE <RETURN>)>)>
				  <SET SIZ <- .SIZ ,BUFLNT>>>)
			      (ELSE
			       <MIMC-PRINT <CHTYPE <1 .TEM> WORD> .IOTUP>
			       <MIMC-CRLF .IOTUP>
			       <IDUMP-CODE <REST .TEM> .IOTUP>)>
			<COND (.MACRO-NAME
			       <MIMC-OUTS "<COND (<AND <GASSIGNED? " .IOTUP>
			       <MIMC-PRIN-ATOM .FUNC .IOTUP>
			       <MIMC-OUTS "> <NOT <TYPE? ," .IOTUP>
			       <MIMC-PRIN-ATOM .FUNC .IOTUP>
			       <MIMC-OUTS " MACRO>>> <SETG " .IOTUP> 
			       <MIMC-PRIN-ATOM .FUNC .IOTUP>
			       <MIMC-OUTS " <CHTYPE (," .IOTUP>
			       <MIMC-PRIN-ATOM .FUNC .IOTUP>
			       <MIMC-OUTS ") MACRO>>)>" .IOTUP>
			       <MIMC-CRLF .IOTUP>)>)
		       (ELSE
			<SET THIS-FORM
			     <FORM SETG
				   <2 .THIS-FORM>
				   <FORM QUOTE ,.FUNC>>>
			<MIMC-PRINT .THIS-FORM .IOTUP>
			<MIMC-CRLF .IOTUP>)>)>)
	 (T
	  <COND (<MONAD? <1 .GOODS>>
		 <MIMC-PRINT <1 .GOODS> .IOTUP>
		 <MIMC-CRLF .IOTUP>)
		(T
		 <MIMC-PRINT <1 .GOODS> .IOTUP>
		 <MIMC-CRLF .IOTUP>)>)>
	<PUT .IOTUP ,TUP-OBL <SET IOB <GETPROP .GOODS .OBL '.IOB>>>
	<SET GOODS <REST .GOODS>>>
      <COND (<N==? <TUP-BUFL .IOTUP> 0>
	     <CHANNEL-OP .OUTCHAN WRITE-BUFFER <TUP-BUF .IOTUP>
			 <TUP-BUFL .IOTUP>>)>
      <CLOSE <TUP-CHAN .IOTUP>>
      .NAM>
    <PROG ()
	  <AND <ASSIGNED? OUTCHAN>
	       <TYPE? .OUTCHAN CHANNEL>
	       <CLOSE .OUTCHAN>>>>>

<DEFINE MIMC-PRINT (OBJ IOTUP)
	<MIMC-CRLF .IOTUP>
	<MIMC-PRIN1 .OBJ .IOTUP>>

<DEFINE MIMC-PRIN1 (DATA IOTUP
		    "AUX" (TYP <CALL TYPE .DATA>)
			  FROB (TYOFF <LSH .TYP -6>)
			  (INFO <NTH ,M$$TYPE-INFO!-INTERNAL <+ .TYOFF 1>>)
			  (PTYPE <M$$PRINT .INFO>) (CHN <TUP-CHAN .IOTUP>) LST)
	#DECL ((DATA) ANY (BREAK TYP TYSAT TYOFF) FIX (CHAN) CHANNEL
	       (INFO) TYPE-ENTRY (PTYPE) <OR ATOM APPLICABLE FALSE>
	       (LST) <PRIMTYPE LIST> (CHN) <CHANNEL 'DISK>
	       (IOTUP) <TUPLE <CHANNEL 'DISK> LIST STRING FIX>)
	<COND (<AND .PTYPE
		    <NOT <TYPE? .PTYPE ATOM>>
		    <NOT <AND <TYPE? .DATA ATOM> <SET PTYPE ATOM>>>
		    <NOT <AND <TYPE? .DATA FCN-ATOM> <SET PTYPE ATOM>>>>
	       <CHANNEL-OP .CHN
			   WRITE-BUFFER
			   <TUP-BUF .IOTUP>
			   <TUP-BUFL .IOTUP>>
	       <CHANNEL-OP .CHN BUFOUT>
	       <PUT .IOTUP ,TUP-BUFL 0>
	       <PROG ((OUTCHAN .CHN))
		     #DECL ((OUTCHAN) <SPECIAL CHANNEL>)
		     <APPLY .PTYPE .DATA>
		     <CHANNEL-OP .CHN BUFOUT>>)
	      (<==? .PTYPE ATOM>
	       <COND (<AND <TYPE? .DATA FCN-ATOM>
			   <GASSIGNED? CTLZ-PRINT>
			   ,CTLZ-PRINT>
		      <MIMC-OUTC <ASCII 26> .IOTUP>)>
	       <MIMC-PRIN-ATOM <CHTYPE .DATA ATOM> .IOTUP>)
	      (<==? .PTYPE FIX> <I$PRIN-FIX .DATA .IOTUP>)
	      (<==? .PTYPE FLOAT> <I$PRIN-FLOAT .DATA .IOTUP>)
	      (<==? .PTYPE STRING>
	       <MIMC-OUTC !\" .IOTUP>
	       <MAPF <>
		     <FUNCTION (CHR)
			  <COND (<OR <==? .CHR !\"> <==? .CHR ,BACK-SLASH>>
				 <MIMC-OUTC ,BACK-SLASH .IOTUP>)>
			  <MIMC-OUTC .CHR .IOTUP>>
		     <CHTYPE .DATA STRING>>
	       <MIMC-OUTC !\" .IOTUP>)
	      (<==? .PTYPE BYTES>
	       <MIMC-OUTS "!{" .IOTUP>
	       <MAPR <>
		     <FUNCTION (BP "AUX" (BY <1 .BP>)) 
			     #DECL ((BP) BYTES)
			     <I$PRIN-FIX .BY .IOTUP>
			     <COND (<NOT <EMPTY? <REST .BP>>>
				    <MIMC-OUTC <ASCII 32> .IOTUP>)>>
		     <CHTYPE .DATA BYTES>>
	       <MIMC-OUTS "!}" .IOTUP>)
	      (<==? .PTYPE CHARACTER>
	       <COND (<OR <G? <CHTYPE .DATA FIX> *177*>
			  <L? <CHTYPE .DATA FIX> 0>>
		      <MIMC-OUTS "#CHARACTER *" .IOTUP>
		      <MIMC-PRIN-OCT <CHTYPE .DATA FIX> .IOTUP>
		      <MIMC-OUTC !\* .IOTUP>)
		     (ELSE
		      <MIMC-OUTS "!\\" .IOTUP>
		      <MIMC-OUTC .DATA .IOTUP>)>)
	      (<==? .PTYPE ADECL>
	       <MIMC-PRIN1 <1 <CHTYPE .DATA VECTOR>> .IOTUP>
	       <MIMC-OUTC !\: .IOTUP>
	       <MIMC-PRIN1 <2 <CHTYPE .DATA VECTOR>> .IOTUP>)
	      (<AND <OR <==? .PTYPE FORM> <==? .PTYPE SEGMENT>>
		    <==? <LENGTH <CHTYPE .DATA LIST>> 2>
		    <OR <AND <==? <SET FROB <1 <CHTYPE .DATA LIST>>> LVAL>
			     <SET FROB !\.>>
		        <AND <==? .FROB GVAL> <SET FROB !\,>>
		        <AND <==? .FROB QUOTE> <SET FROB !\'>>>>
	       <COND (<==? .PTYPE SEGMENT> <MIMC-OUTC !\! .IOTUP>)>
	       <MIMC-OUTC .FROB .IOTUP>
	       <MIMC-PRIN1 <2 <CHTYPE .DATA LIST>> .IOTUP>)
	      (<OR <AND <==? .PTYPE FORM> <MIMC-OUTC !\< .IOTUP>>
		   <AND <==? .PTYPE LIST> <MIMC-OUTC !\( .IOTUP>>
		   <AND <==? .PTYPE SEGMENT> <MIMC-OUTS "!<" .IOTUP>>>
	       <MAPR <>
		     <FUNCTION (LP "AUX" (OBJ <1 .LP>)) 
			     #DECL ((LP) LIST)
			     <MIMC-PRIN1 .OBJ .IOTUP>
			     <COND (<NOT <EMPTY? <REST .LP>>>
				    <MIMC-OUTC <ASCII 32> .IOTUP>)>>
		     <CHTYPE .DATA LIST>>
	       <COND (<N==? .PTYPE LIST> <MIMC-OUTC !\> .IOTUP>)
		     (ELSE <MIMC-OUTC !\) .IOTUP>)>)
	      (<==? .PTYPE OFFSET>
	       <MIMC-OUTS "%<OFFSET " .IOTUP>
	       <I$PRIN-FIX <M$$OFF-FIX <CHTYPE .DATA VECTOR>> .IOTUP>
	       <COND (<TYPE? <SET FROB <M$$OFF-DCL <CHTYPE .DATA VECTOR>>>
			     ATOM>
		      <MIMC-OUTC <ASCII 32> .IOTUP>
		      <MIMC-PRIN-ATOM .FROB .IOTUP>)
		     (ELSE <MIMC-OUTS " '" .IOTUP> <MIMC-PRIN1 .FROB .IOTUP>)>
	       <COND (<TYPE? <SET FROB <M$$OFF-ELT <CHTYPE .DATA VECTOR>>>
			     ATOM>
		      <MIMC-OUTC <ASCII 32> .IOTUP>
		      <MIMC-PRIN-ATOM .FROB .IOTUP>)
		     (.FROB <MIMC-OUTS " '" .IOTUP> <MIMC-PRIN1 .FROB .IOTUP>)>
	       <MIMC-OUTC !\> .IOTUP>)
	      (<==? .PTYPE TYPE-C> <I$PRIN-TYPE-W-C .DATA <> .IOTUP>)
	      (<==? .PTYPE TYPE-W> <I$PRIN-TYPE-W-C .DATA T .IOTUP>)
	      (<==? .PTYPE UVECTOR>
	       <MIMC-OUTS "![" .IOTUP>
	       <MAPR <>
		     <FUNCTION (NP "AUX" (N <1 .NP>)) 
			     #DECL ((NP) UVECTOR)
			     <I$PRIN-FIX .N .IOTUP>
			     <COND (<NOT <EMPTY? <REST .NP>>>
				    <MIMC-OUTC <ASCII 32> .IOTUP>)>>
		     <CHTYPE .DATA UVECTOR>>
	       <MIMC-OUTS "!]" .IOTUP>)
	      (<==? .PTYPE VECTOR>
	       <MIMC-OUTC !\[ .IOTUP>
	       <MAPR <>
		     <FUNCTION (NP "AUX" (N <1 .NP>)) 
			     #DECL ((NP) VECTOR)
			     <MIMC-PRIN1 .N .IOTUP>
			     <COND (<NOT <EMPTY? <REST .NP>>>
				    <MIMC-OUTC <ASCII 32> .IOTUP>)>>
		     <CHTYPE .DATA VECTOR>>
	       <MIMC-OUTC !\] .IOTUP>)
	      (<==? .DATA <>>
	       <MIMC-OUTS "%<>" .IOTUP>)
	      (<==? .PTYPE GVAL>
	       <MIMC-OUTC !\, .IOTUP>
	       <MIMC-PRIN-ATOM <CHTYPE .DATA ATOM> .IOTUP>)
	      (<==? .PTYPE LVAL>
	       <MIMC-OUTC !\. .IOTUP>
	       <MIMC-PRIN-ATOM <CHTYPE .DATA ATOM> .IOTUP>)
	      (<TYPE? .DATA WORD>
	       <MIMC-OUTS "#WORD *" .IOTUP>
	       <MIMC-PRIN-OCT <CHTYPE .DATA FIX> .IOTUP>
	       <MIMC-OUTC !\* .IOTUP>)
	      (<==? <M$$NTYPE .INFO> <M$$PTYPE .INFO>>
	       <CHANNEL-OP .CHN
			   WRITE-BUFFER
			   <TUP-BUF .IOTUP>
			   <TUP-BUFL .IOTUP>>
	       <CHANNEL-OP .CHN BUFOUT>
	       <PUT .IOTUP ,TUP-BUFL 0>
	       <PROG ((OUTCHAN .CHN))
		     #DECL ((OUTCHAN) <SPECIAL CHANNEL>)
		     <PRIN1 .DATA>>)
	      (ELSE
	       <MIMC-OUTC !\# .IOTUP>
	       <MIMC-PRIN-ATOM <M$$NTYPE .INFO> .IOTUP>
	       <MIMC-OUTC <ASCII 32> .IOTUP>
	       <MIMC-PRIN1 <CHTYPE .DATA <M$$PTYPE .INFO>> .IOTUP>)>>

<DEFINE I$PRIN-TYPE-W-C (DATA W-C IOTUP "AUX" ENTRY TYOFF)
	#DECL ((DATA) ANY (BREAK TYOFF) FIX (CHAN) CHANNEL (RTRN) FRAME
	       (ENTRY) <OR TYPE-ENTRY FALSE>
	       (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<COND (.W-C <SET TYOFF <LSH <CALL TYPEWC .DATA> <- %,M$$TYOFF>>>)
	      (ELSE <SET TYOFF <LSH .DATA %<- ,M$$TYOFF>>>)>
	<COND (<AND <G=? .TYOFF 0>
		    <L=? .TYOFF ,M$$TYPE-INFO-SIZE>
		    <SET ENTRY <NTH ,M$$TYPE-INFO!-INTERNAL <+ .TYOFF 1>>>>
	       <COND (.W-C <MIMC-OUTS "%<TYPE-W " .IOTUP>)
		     (ELSE <MIMC-OUTS "%<TYPE-C " .IOTUP>)>
	       <MIMC-PRIN-ATOM <M$$NTYPE .ENTRY> .IOTUP>
	       <MIMC-OUTC <ASCII 32> .IOTUP>
	       <MIMC-PRIN-ATOM <M$$PTYPE .ENTRY> .IOTUP>
	       <MIMC-OUTC !\> .IOTUP>)
	      (<ERROR BAD-TYPE-CODE!-ERRORS .TYOFF PRINT>)>>

<DEFINE MIMC-PRIN-OCT (NUM IOTUP)
	#DECL ((NUM) FIX (IOTUP)  <TUPLE CHANNEL LIST STRING FIX>)
	<COND (<0? .NUM> <MIMC-OUTC !\0 .IOTUP>)
	      (ELSE
	       <MIMC-POCT .NUM .IOTUP>)>>

<DEFINE MIMC-POCT (X IOTUP)
	#DECL ((X) FIX (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<COND (<N==? .X 0>
	       <MIMC-POCT <LSH .X -3> .IOTUP>
	       <MIMC-OUTC <ASCII <+ <ANDB .X 7> <ASCII !\0>>> .IOTUP>)>>

<DEFINE I$PRIN-FIX (NUM IOTUP)
	#DECL ((NUM) FIX (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<COND (<==? .NUM <CHTYPE <MIN> FIX>>
	       <MIMC-OUTS "%<CHTYPE <MIN> FIX>" .IOTUP>)
	      (<==? .NUM <CHTYPE <MAX> FIX>>
	       <MIMC-OUTS "%<CHTYPE <MAX> FIX>" .IOTUP>)
	      (<==? .NUM -0>
	       <MIMC-OUTS "-0" .IOTUP>)
	      (<L? .NUM 0>
	       <MIMC-OUTC !\- .IOTUP>
	       <I$PRIN-INT <- 0 .NUM> .IOTUP>)
	      (<0? .NUM> <MIMC-OUTC !\0 .IOTUP>)
	      (ELSE <I$PRIN-INT .NUM .IOTUP>)>>

<DEFINE I$PRIN-INT (NUM IOTUP)
	#DECL ((NUM) FIX (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<COND (<NOT <0? .NUM>> 
	       <I$PRIN-INT </ .NUM 10> .IOTUP>
	       <MIMC-OUTC <ASCII <+ %<ASCII !\0> <MOD .NUM 10>>> .IOTUP>)>>

<DEFINE I$PRIN-FLOAT (NUM IOTUP
		      "AUX" (MANT .NUM) (EXP 0) DIG (SIGD 7) (OFFSET 1))
	#DECL ((NUM MANT) FLOAT (EXP DIG SIGD) FIX
	       (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<COND (<==? .NUM ,MINFL> <MIMC-OUTS "%,MINFL" .IOTUP>)
	      (<==? .NUM ,MAXFL> <MIMC-OUTS "%,MAXFL" .IOTUP>)
	      (ELSE
	       <COND (<L? .NUM 0.0>
		      <MIMC-OUTC !\- .IOTUP>
		      <SET MANT <SET NUM <- 0.0 .NUM>>>)>
	       <COND (<G=? .NUM 10.0>
		      <REPEAT ()
			      <SET MANT </ .MANT 10.0>>
			      <SET EXP <+ .EXP 1>>
			      <COND (<L? .MANT 10.0>  <RETURN>)>>)
		     (<0? .NUM> <SET EXP -1>)
		     (<L? .NUM 1.0>
		      <REPEAT ()
			      <SET MANT <* .MANT 10.0>>
			      <SET EXP <- .EXP 1>>
			      <COND (<G=? .MANT 1.0> <RETURN>)>>)>
	       <COND (<OR <G? .EXP 7> <L? .EXP -2>>
		      <I$PRIN-INT <SET DIG <FIX .MANT>> .IOTUP>
		      <I$PRIN-DEC <- .MANT .DIG> .SIGD .IOTUP .OFFSET>
		      <MIMC-OUTC !\E .IOTUP>
		      <COND (<G? .EXP .SIGD>
			     <MIMC-OUTC !\+ .IOTUP>
			     <I$PRIN-INT .EXP .IOTUP>)
			    (ELSE
			     <SET OFFSET 8>
			     <MIMC-OUTC !\- .IOTUP>
			     <I$PRIN-INT <- 0 .EXP> .IOTUP>)>)
		     (<G=? .EXP 0>
		      <COND (<L=? .EXP 7> <SET OFFSET <- 8 .EXP>>)>
		      ; "This may cause rounding to the next integer, so must do
			    addition BEFORE calling FIX"
		      <COND (<G? <FIX <+ <NTH ,I$FLOAT-TABLE!-INTERNAL .OFFSET>
					 .NUM>>
				 <FIX .NUM>>
			     <SET NUM <+ <NTH ,I$FLOAT-TABLE!-INTERNAL .OFFSET>
					 .NUM>>
			     <SET OFFSET 1>)>
		      <I$PRIN-INT <SET DIG <FIX .NUM>> .IOTUP>
		      <I$PRIN-DEC <- .NUM .DIG> <- .SIGD .EXP> .IOTUP .OFFSET>)
		     (ELSE
		      <COND (<NOT <0? .NUM>>
			     <SET NUM <+ .NUM <8 ,I$FLOAT-TABLE!-INTERNAL>>>)>
		      <SET OFFSET 1>
		      <COND (<G=? .NUM 1.0>
			     <MIMC-OUTC !\1 .IOTUP>
			     <SET NUM <- .NUM 1.0>>)
			    (T
			     <MIMC-OUTC !\0 .IOTUP>)>
		      <I$PRIN-DEC .NUM .SIGD .IOTUP .OFFSET>)>)>>

<DEFINE I$PRIN-DEC (NUM MIN IOTUP OFFSET "AUX" (Z-COUNT 0))
	#DECL ((NUM) FLOAT (MIN OFF Z-COUNT) FIX (BUF) STRING
	       (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<MIMC-OUTC !\. .IOTUP>
	<COND (<0? .NUM>
	       <MIMC-OUTC !\0 .IOTUP>)
	      (ELSE <SET NUM <+ .NUM <NTH ,I$FLOAT-TABLE!-INTERNAL .OFFSET>>>
	       <REPEAT (DIG) #DECL ((DIG) FIX)
		       <SET DIG <FIX <SET NUM <* .NUM 10.0>>>>
		       <COND (<0? .DIG>
			      <SET Z-COUNT <+ .Z-COUNT 1>>)
			     (ELSE <SET Z-COUNT 0>)>		 
		       <MIMC-OUTC <ASCII <+ %<ASCII !\0> .DIG>> .IOTUP>
		       <COND (<OR <0? <SET NUM <- .NUM .DIG>>>
				  <L=? <SET MIN <- .MIN 1>> 0>>
			      <RETURN>)>>)>>


<DEFINE MIMC-CRLF (IOTUP) 
	<MAPF <> <FUNCTION (CH) <MIMC-OUTC .CH .IOTUP>> ,CRLF-STRING!-INTERNAL>>

<DEFINE MIMC-PRIN-ATOM (ATM IOTUP "AUX" (SP <SPNAME .ATM>) (O? <OBLIST? .ATM>)
		      		        (OB <TUP-OBL .IOTUP>))
	#DECL ((CHAN) CHANNEL (ATM) ATOM (OB) <LIST [REST OBLIST]>
	       (O?) <OR FALSE OBLIST>
	       (IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<PROG ()
	      <MIMC-PRIN-ATM .SP .IOTUP>
	      <COND (<AND .O?
			  <N==? .O? ,MIM-OBL>
			  <N==? .O? ,TMP-OBL>
			  <N==? .O? ,ROOT-OBL>
			  <NOT <MEMQ .O? .OB>>>
		     <MIMC-OUTS "!-" .IOTUP>
		     <SET SP <SPNAME <SET ATM <CHTYPE .O? ATOM>>>>
		     <SET O? <OBLIST? .ATM>>
		     <AGAIN>)
		    (<NOT .O?>
		     <ERROR CANT-PRINT-ATOM!-ERRORS .ATM>)>>>

<DEFINE MIMC-PRIN-ATM (STR IOTUP "AUX" (FSM ,I$ATM-FSM!-INTERNAL)
		     (CSTATE <1 .FSM>) CTRANS (TR-TABLE ,I$TRANS-TABLE!-INTERNAL)
		     TN)
	#DECL ((STR) STRING (TN) FIX (FSM) <VECTOR [REST BYTES]>
	       (CSTATE) BYTES (CTRANS) FIX (TR-TABLE) BYTES)
	; "Run FSM to decide if initial backslash needed.  If any character
	   that can't be part of number is encountered, exit immediately,
	   don't put  backslash in.  Other transitions out of states are
	   E, ., 0-9, +/-, *, and end of string.  This is basically ripped
	   off from old muddle."
	<COND (<NOT
	        <MAPF <>
	         <FUNCTION (CHR)
		   #DECL ((CHR) CHARACTER)
		   <COND (<L? <SET CTRANS <NTH .TR-TABLE <+ <ASCII .CHR> 1>>>
			      ,M$$R-MIN-NUM-PART>
			  ; "Not part of number, so done."
			  <MAPLEAVE>)
			 (<SET TN <+ <- .CTRANS ,M$$R-MIN-NUM-PART> 1>>)>
		   <COND (<L=? <SET TN <NTH .CSTATE .TN>> ,M$$FS-NSTATE>
			  ; "Legal state number, go to it"
			  <SET CSTATE <NTH .FSM .TN>>
			  <>)
			 (<N==? .TN ,M$$FS-NOSLASH>
			  ; "Leading ., so always need backslash"
			  <MAPLEAVE <>>)
			 (T
			  ; "Thing can't be number, so leave"
			  <MAPLEAVE>)>>
		 .STR>>
	       <COND (<OR <G? .TN ,M$$FS-NSTATE>	
			  <N==? <M$$END-STATE .CSTATE> ,M$$FS-NOSLASH>>
		      ; "Put in \ if hit terminal state before end of string
			 or if current-state's end-state calls for it."
		      <MIMC-OUTC <ASCII 92> .IOTUP>)>)>
	<MAPF <>
	      <FUNCTION (CHAR) #DECL ((CHAR) CHARACTER)
	       <SET CTRANS <NTH .TR-TABLE <+ <ASCII .CHAR> 1>>>
	       <COND (<OR <L=? .CTRANS ,M$$R-MAX-ATM-BRK>
			  <==? .CTRANS ,M$$R-BACKS>>
		      <MIMC-OUTC <ASCII 92> .IOTUP>)>
	       <MIMC-OUTC .CHAR .IOTUP>>
	      .STR>>

<DEFINE MIMC-OUTC (CHR IOTUP "AUX" LNT) 
	#DECL ((IOTUP) <TUPLE CHANNEL LIST STRING FIX>)
	<COND (<G? <SET LNT <+ <TUP-BUFL .IOTUP> 1>> ,BUFLNT>
	       <CHANNEL-OP <TUP-CHAN .IOTUP>:<CHANNEL 'DISK>
			   WRITE-BUFFER <TUP-BUF .IOTUP>>
	       <SET LNT 1>)>
	<PUT .IOTUP ,TUP-BUFL .LNT>
	<PUT <TUP-BUF .IOTUP> .LNT .CHR>>

<DEFINE MIMC-OUTS (STR IOTUP
		 "AUX" (LNT <TUP-BUFL .IOTUP>) (BUF <TUP-BUF .IOTUP>))
	#DECL ((IOTUP) <TUPLE CHANNEL LIST STRING FIX> (LNT) FIX
	       (BUF) STRING)
	<REPEAT ()
		<COND (<EMPTY? .STR> <PUT .IOTUP ,TUP-BUFL .LNT> <RETURN>)>
		<COND (<G? <SET LNT <+ .LNT 1>> ,BUFLNT>
		       <CHANNEL-OP <TUP-CHAN .IOTUP>:<CHANNEL 'DISK>
				   WRITE-BUFFER .BUF>
		       <SET LNT 1>)>
		<PUT .BUF .LNT <1 .STR>>
		<SET STR <REST .STR>>>>


<DEFINE IDUMP-CODE (L IOTUP) #DECL ((L) LIST (IOTUP) TUPLE)
	<MAPF <>
	      <FUNCTION (X)
		   #DECL ((X) <OR ATOM FORM>)
		   <COND
		    (<TYPE? .X ATOM>
		     <MIMC-PRIN-ATOM .X .IOTUP>
		     <MIMC-CRLF .IOTUP>)
		    (ELSE
		     <MIMC-OUTS "		    " .IOTUP>
		     <MIMC-OUTC !\< .IOTUP>
		     <MAPR <>
			   <FUNCTION (YP "AUX" (Y <1 .YP>) O)
				#DECL ((YP) <LIST ANY>)
				<COND (<TYPE? .Y ATOM>
				       <MIMC-PRIN-ATOM .Y .IOTUP>)
				      (ELSE
				       <MIMC-PRIN1 .Y .IOTUP>)>
				<COND (<NOT <EMPTY? <REST .YP>>>
				       <MIMC-OUTC <ASCII 32>
						  .IOTUP>)>>
			   .X>
		     <MIMC-OUTC !\> .IOTUP>
		     <MIMC-CRLF .IOTUP>)>>
	      .L>>

<DEFINE DUMP-CODE (L CH OBL "AUX" (IOTUP <TUPLE .CH .OBL ,BUFFER 0>))
	<IDUMP-CODE .L .IOTUP>
	<CHANNEL-OP <TUP-CHAN .IOTUP>:<CHANNEL 'DISK>
		    WRITE-BUFFER <TUP-BUF .IOTUP> <TUP-BUFL .IOTUP>>
	T>

<ENDPACKAGE>
