
<DEFINE RPUTBITS (L "AUX" (WD <1 .L>) (WL <2 .L>) (SHL <3 .L>) (NEW <4 .L>)
			  (DST <6 .L>) (TAC? <>) (AC? <>) AN BP (OL <>) (AC <>)
			  (W 0) (SH 0) IX (VT <>) (WAS-TYPED <>))
	#DECL ((L) LIST (OL) <OR FALSE LIST>)
	<COND (<TYPE? .WL FIX> <SET W .WL>)>
	<COND (<TYPE? .SHL FIX> <SET SH .SHL>)>
	<COND (<TYPE? .WD ATOM>
	       <SET OL <OBJ-LOC .WD 1>>
	       <SET TAC? <IN-AC? .WD BOTH>>
	       <SET AC? <IN-AC? .WD VALUE>>
	       <SET VT <VAR-TYPED? .WD>>)>
	<SET BP <CHTYPE <ORB <LSH .SH 30> <LSH .W 24>> FIX>>
	<COND (<OR <N==? .WD .DST> <AND <NOT .VT> <NOT .AC?>>>
	       <SET TAC? <LOAD-AC .WD BOTH>>
	       <SET AC? <NEXT-AC .TAC?>>
	       <COND (<AND <N==? .WD .DST>
			   <NOT <WILL-DIE? .WD>>>
		      <FLUSH-AC .TAC? T>)>)>
	<COND (<N==? .WD .DST>
	       <COND (.TAC?
		      <SET WAS-TYPED <AC-TYPE <GET-AC .TAC?>>>
		      <MUNGED-AC .TAC? T>)
		     (.AC? <MUNGED-AC .AC?>)>)>
	<COND (.AC? <SET AN <2 <CHTYPE <MEMQ .AC? ,ACS> VECTOR>>>)>
	<COND (.AC? <SET BP <CHTYPE <ORB .BP .AN> CONSTANT>>)
	      (.OL
	       <SET BP
		    <CHTYPE (<2 .OL>
			     <+ <CHTYPE <LSH <2 <MEMQ <1 <CHTYPE <3 .OL> LIST>>
						      ,ACS>>
					     18>
					FIX>
				<CHTYPE <1 .OL> FIX>
				.BP>) CONST-W-LOCAL>>)>
	<COND (<AND <TYPE? .WL FIX> <TYPE? .SHL FIX>>
	       <COND (<OR <NOT <TYPE? .NEW ATOM>>
			  <AND <WILL-DIE? .NEW>
			       <NOT <SET AC <IN-AC? .NEW VALUE>>>>>
		      <GET-INTO-ACS .NEW VALUE <SET AC T*>>)
		     (<NOT .AC>
		      <SET AC <NEXT-AC <LOAD-AC .NEW BOTH>>>)>
	       <CONST-LOC .BP VALUE>
	       <OCEMIT DPB .AC !<OBJ-VAL .BP>>)
	      (ELSE
	       <COND (.AC? <OCEMIT MOVEI O* .AC?>)
		     (ELSE
		      <CONST-LOC .BP VALUE>
		      <OCEMIT MOVE O* !<OBJ-VAL .BP>>)>
	       <COND (<NOT <TYPE? .SHL FIX>>
		      <OCEMIT DPB <COND (<IN-AC? .SHL VALUE>)
					(ELSE <NEXT-AC <LOAD-AC .SHL BOTH>>)>
			      !<OBJ-VAL <SET BP <CHTYPE *360600000000*
							CONSTANT>>>>
		      <CONST-LOC .BP VALUE>)>
	       <COND (<NOT <TYPE? .WL FIX>>
		      <OCEMIT DPB <COND (<IN-AC? .WL VALUE>)
					(ELSE <NEXT-AC <LOAD-AC .WL BOTH>>)>
			      !<OBJ-VAL <SET BP <CHTYPE *300600000000*
							CONSTANT>>>>
		      <CONST-LOC .BP VALUE>)>
	       <COND (.AC?
		      <AC-TIME <GET-AC .AC?>
			       <SETG AC-STAMP <+ ,AC-STAMP 1>>>
		      <COND (.TAC? <AC-TIME <GET-AC .TAC?> ,AC-STAMP>)>)>
	       <SET AC <LOAD-AC .NEW BOTH>>
	       <OCEMIT DPB <NEXT-AC .AC> O*>)>
	<COND (<==? .DST STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <OCEMIT PUSH TP* .AC?>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (<N==? .WD .DST>
	       <CLEAN-ACS .DST>
	       <AC-UPDATE <AC-ITEM <AC-CODE <GET-AC .TAC?> TYPE>
				   .DST> T>
	       <COND (.WAS-TYPED <AC-TYPE <GET-AC .TAC?> FIX>)>
	       <AC-CODE
		<AC-TYPE
		 <AC-ITEM
		  <AC-UPDATE <GET-AC <SET AC .AC?>> T> .DST> <>> VALUE>)
	      (.AC?
	       <COND (<NOT .TAC?>
		      <SET TAC? <GETPROP .AC? AC-PAIR>>
		      <AC-UPDATE <AC-ITEM <AC-CODE <GET-AC .TAC?> TYPE>
					  .DST> T>)>
	       <AC-UPDATE <GET-AC .AC?> T>
	       <COND (<NOT .VT> <AC-TYPE <GET-AC .TAC?> FIX>)>)>>
