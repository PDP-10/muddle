
<GDECL (LOOKAHEAD?) <OR ATOM FALSE>>

<SETG ARITH
      '[ADD!-MIMOP
	SUB!-MIMOP
	MUL!-MIMOP
	DIV!-MIMOP
	ADDF!-MIMOP
	SUBF!-MIMOP
	MULF!-MIMOP
	DIVF!-MIMOP
	AND!-MIMOP
	OR!-MIMOP
	XOR!-MIMOP
	EQV!-MIMOP]>

<SETG EMPU '[EMPUV?!-MIMOP EMPUU?!-MIMOP EMPUS?!-MIMOP EMPUB?!-MIMOP]>

<SETG LENU '[LENUV!-MIMOP LENUU!-MIMOP LENUS!-MIMOP LENUB!-MIMOP]>

<SETG NTHU '[NTHUV!-MIMOP NTHUU!-MIMOP NTHUS!-MIMOP NTHUB!-MIMOP]>

<SETG PUTU '[PUTUV!-MIMOP PUTUU!-MIMOP PUTUS!-MIMOP PUTUB!-MIMOP]>

<SETG RESTU '[RESTUV!-MIMOP RESTUU!-MIMOP RESTUS!-MIMOP RESTUB!-MIMOP]>

<PUTPROP RESTUV!-MIMOP PUT-PAIR PUTUV!-MIMOP>

<PUTPROP PUTUV!-MIMOP PUT-PAIR RESTUV!-MIMOP>

<PUTPROP RESTUU!-MIMOP PUT-PAIR PUTUU!-MIMOP>

<PUTPROP PUTUU!-MIMOP PUT-PAIR RESTUU!-MIMOP>

<PUTPROP RESTUS!-MIMOP PUT-PAIR PUTUS!-MIMOP>

<PUTPROP PUTUS!-MIMOP PUT-PAIR RESTUS!-MIMOP>

<PUTPROP RESTUB!-MIMOP PUT-PAIR PUTUB!-MIMOP>

<PUTPROP PUTUB!-MIMOP PUT-PAIR RESTUB!-MIMOP>

<PUTPROP RESTUV!-MIMOP PAIR NTHUV!-MIMOP>

<PUTPROP NTHUV!-MIMOP PAIR RESTUV!-MIMOP>

<PUTPROP RESTUU!-MIMOP PAIR NTHUU!-MIMOP>

<PUTPROP NTHUU!-MIMOP PAIR RESTUU!-MIMOP>

<PUTPROP RESTUS!-MIMOP PAIR NTHUS!-MIMOP>

<PUTPROP NTHUS!-MIMOP PAIR RESTUS!-MIMOP>

<PUTPROP RESTUB!-MIMOP PAIR NTHUB!-MIMOP>

<PUTPROP NTHUB!-MIMOP PAIR RESTUB!-MIMOP>

<GDECL (ARITH NTHU PUTU RESTU LENU EMPU) <VECTOR [REST ATOM]>>

<NEWSTRUC OP-INFO (VECTOR)
	  OP-ARGS VECTOR
	  OP-RES <OR ATOM VARTBL>
	  OP-HINT <OR LIST ATOM FALSE>
	  OP-BRANCH <OR ATOM FALSE>
	  OP-DIR ATOM>

<SETG OP-INFO [<IVECTOR 5 <>> T <> <> T]>

<DEFINE NTH-LOOK-AHEAD NLA (CINS STRUC1 OFF1 RES
			    "OPTIONAL" (HINT <>) (STYPE1 <>)
			    "AUX" (L .CODPTR) INCINS NXT (OP-INFO ,OP-INFO)
				  (ADDVAL 0) STRUC2 OFF2 (ELTYPE1 <>)
				  (ELTYPE2 <>) (EMPTY? <>)
				  (ARGVEC <OP-ARGS .OP-INFO>) (ARITH? <>)
				  (ILDB? <>) OL (IDPB? <>) NINS RES1 RES2
				  (RES1? <>) (RES2? <>) PINS (STYPE2 <>) AMT
				  CMPINS TMIML (NOPUT? <>))
   #DECL ((CINS) ATOM (RES) <OR VARTBL ATOM> (NXT) <OR ATOM FORM>
	  (L) <SPECIAL <LIST [REST <OR ATOM FORM>]>> (OP-INFO) OP-INFO)
   <COND (<NOT ,LOOKAHEAD?> <RETURN <> .NLA>)>
   <COND (.STYPE1 <SET STYPE1 <PARSE-HINT .STYPE1 STRUCTURE-TYPE>>)
	 (T
	  <COND (<==? .CINS NTHUV!-MIMOP> <SET STYPE1 VECTOR>)
		(<==? .CINS NTHUU!-MIMOP> <SET STYPE1 UVECTOR>)
		(<==? .CINS NTHUS!-MIMOP> <SET STYPE1 STRING>)
		(<==? .CINS NTHUB!-MIMOP> <SET STYPE1 BYTES>)
		(<==? .CINS NTHL!-MIMOP> <SET STYPE1 LIST>)>)>
   <COND (<==? .CINS ILDB!-MIMOP> <SET ILDB? .OFF1> <SET OFF1 1>)>
   <COND
    (<AND <OR <MEMQ .CINS ,NTHU>
	      <==? .CINS ILDB!-MIMOP>
	      <==? .CINS NTHL!-MIMOP>>
	  <G=? <LENGTH .L> 3>
	  <TYPE? .RES VARTBL>
	  <TYPE? .STRUC1 VARTBL>
	  <N==? .RES .STRUC1>
	  <TYPE? <SET NXT <GET-NEXT-INST .L>> FORM>
	  <COND (<OR <SET ARITH? <MEMQ <SET INCINS <1 .NXT>> ,ARITH>>
		     <MEMQ .INCINS ,RESTU>>
		 <AND <PARSE-OP .NXT .OP-INFO>
		      <==? <1 <OP-ARGS .OP-INFO>> .RES>
		      <==? <OP-RES .OP-INFO> .RES>
		      <SET ADDVAL <2 <OP-ARGS .OP-INFO>>>
		      <TYPE? <SET NXT <GET-NEXT-INST .L>> FORM>>)
		(T <SET INCINS <>> T)>
	  <OR <NOT .ARITH?>
	      <NOT <MEMQ .INCINS ,LOGIC>>
	      <NOT <MEMQ .STYPE1 '[STRING BYTES]>>>
	  <OR <MEMQ <SET PINS <1 .NXT>> ,PUTU>
	      <==? .PINS PUTL!-MIMOP>
	      <SET IDPB? <==? .PINS IDPB!-MIMOP>>
	      <COND (.ARITH? <SET PINS <>> <SET NOPUT? T> <SET STRUC2 .RES>)>>
	 ;"In case of CHTYPE here (for rest), will fall into
	    normal code"
	  <COND (<NOT .NOPUT?>
		 <PARSE-OP .NXT .OP-INFO>
		 <SET ARGVEC <OP-ARGS .OP-INFO>>
		 <COND (.IDPB? <==? <2 .ARGVEC> .RES>)
		       (<==? <3 .ARGVEC> .RES>)>)
		(T)>
	  <COND (<NOT .NOPUT?>
		 <COND (<WILL-DIE? .RES .L>)
		       (.ARITH?
			; "Work for NTH ? ADD when NTH ? ADD ? PUT can't
			   because of life/death"
			<SET NOPUT? T>
			<SET PINS <>>
			<SET STRUC2 .RES>)>)
		(T)>>
     <COND (<NOT .NOPUT?> <SET STRUC2 <1 .ARGVEC>>) (T)>
     <COND (.NOPUT? <PROTECT-VAL .STRUC2>)
	   (.IDPB? <SET STYPE2 <PARSE-HINT <OP-HINT .OP-INFO> STRUCTURE-TYPE>>)
	   (<==? .PINS PUTUV!-MIMOP> <SET STYPE2 VECTOR>)
	   (<==? .PINS PUTL!-MIMOP> <SET STYPE2 LIST>)
	   (<==? .PINS PUTUU!-MIMOP> <SET STYPE2 UVECTOR> <SET ELTYPE2 FIX>)
	   (<==? .PINS PUTUS!-MIMOP>
	    <SET STYPE2 STRING>
	    <SET ELTYPE2 CHARACTER>)
	   (<==? .PINS PUTUB!-MIMOP> <SET ELTYPE2 FIX> <SET STYPE2 BYTES>)>
     <COND (.IDPB? <SET OFF2 1> <SET IDPB? <3 .ARGVEC>>)
	   (.NOPUT?)
	   (T
	    <SET OFF2 <2 .ARGVEC>>
	    <COND (<OP-HINT .OP-INFO>
		   <SET ELTYPE2 <PARSE-HINT <OP-HINT .OP-INFO> TYPE>>)>)>
     <COND (.HINT
	    <COND (<TYPE? .HINT ATOM> <SET ELTYPE1 .HINT>)
		  (<SET ELTYPE1 <PARSE-HINT .HINT TYPE>>)>)
	   (<==? .STYPE1 BYTES> <SET ELTYPE1 FIX>)
	   (<==? .STYPE1 STRING> <SET ELTYPE1 CHARACTER>)
	   (<==? .STYPE1 UVECTOR> <SET ELTYPE1 FIX>)>
     <COND (<AND <MEMQ .INCINS ,RESTU>
		 <OR <NOT .ELTYPE1> <NOT .ELTYPE2> <N==? .ELTYPE1 .ELTYPE2>>
		 <OR .ILDB? .IDPB? <N==? .STRUC1 .STRUC2> <N==? .OFF1 .OFF2>>>
	    <>)
	   (<NTH-AOS-PUT-GEN .CINS
			     .INCINS
			     .PINS
			     .STRUC1
			     .OFF1
			     .STRUC2
			     <COND (<NOT .NOPUT?> .OFF2)>
			     .ADDVAL
			     .L
			     .ILDB?
			     .IDPB?
			     .STYPE1
			     <COND (<NOT .NOPUT?> .STYPE2)>
			     .ELTYPE1
			     <COND (<NOT .NOPUT?> .ELTYPE2)>>
	    NORMAL)>)
    (<AND <SET L .CODPTR>
	  <OR <==? .CINS ILDB!-MIMOP>
	      <MEMQ .CINS ,NTHU>
	      <==? .CINS NTHL!-MIMOP>>
	  <G? <LENGTH .L> 1>
	  <TYPE? <SET NXT <GET-NEXT-INST .L>> FORM>>
     <COND
      (<AND <OR <MEMQ <1 .NXT> ,LENU>
		<SET EMPTY?
		     <OR <==? <1 .NXT> EMPL?!-MIMOP> <MEMQ <1 .NXT> ,EMPU>>>>
	    <PARSE-OP .NXT .OP-INFO>
	    <==? <1 <SET ARGVEC <OP-ARGS .OP-INFO>>> .RES>
	    <OR <==? <1 .ARGVEC> <OP-RES .OP-INFO>>
		<AND <WILL-DIE? .RES .L>
		     <OR <NOT .EMPTY?>
 ;
"If empty?, make sure <3 .x> isn't used after
			    the branch.  WILL-DIE? on .L won't find this,
			    because L has already been rested past the branch."
			 <AND <SET TMIML <MEMQ <OP-BRANCH .OP-INFO> .L>>
			      <WILL-DIE? .RES .TMIML>>>>>>
				     ;"Have <length <3 .x>> or <empty? <3 .x>>"
       <SET OL .L>
       <COND (.EMPTY?
	      <FLUSH-TO .L .CODPTR>
	      <NTH-LENGTH-COMP-GEN .CINS
				   .STRUC1
				   .OFF1
				   .STYPE1
				   0
				   <1 .NXT>
				   .OP-INFO>
	      CONDITIONAL-BRANCH)
	     (T
	      <SET ADDVAL <OP-RES .OP-INFO>>
	      <COND (<AND <G? <LENGTH .L> 2>
			  <TYPE? <SET NXT <GET-NEXT-INST .L>> FORM>
			  <MEMQ <1 .NXT>
				'[LESS?!-MIMOP GRTR?!-MIMOP VEQUAL?!-MIMOP]>
			  <PARSE-OP .NXT .OP-INFO>
			  <COND (<==? .ADDVAL
				      <1 <SET ARGVEC <OP-ARGS .OP-INFO>>>>
				 <SET CMPINS <1 .NXT>>
				 <SET AMT <2 .ARGVEC>>)
				(<==? .ADDVAL <2 .ARGVEC>>
				 <SET AMT <1 .ARGVEC>>
				 <COND (<==? <SET CMPINS <1 .NXT>>
					     LESS?!-MIMOP>
					<SET CMPINS GRTR?!-MIMOP>)
				       (<==? .CMPINS GRTR?!-MIMOP>
					<SET CMPINS LESS?!-MIMOP>)
				       (T)>)>
			  <WILL-DIE? .ADDVAL <REST .L>>>
					     ;"Have length comparison of nth.."
		     <FLUSH-TO .L .CODPTR>
		     <NTH-LENGTH-COMP-GEN .CINS
					  .STRUC1
					  .OFF1
					  .STYPE1
					  .AMT
					  .CMPINS
					  .OP-INFO>
		     CONDITIONAL-BRANCH)
		    (T
		     <FLUSH-TO .OL .CODPTR>
		     <NTH-LENGTH-GEN .CINS .STRUC1 .OFF1 .STYPE1 .ADDVAL>
		     NORMAL)>)>)
      (<AND <OR <==? <SET NINS <1 .NXT>> ILDB!-MIMOP>
		<MEMQ .NINS ,NTHU>
		<==? .NINS NTHL!-MIMOP>>
	    <NOT <EMPTY? <REST .L>>>
	    <PARSE-OP .NXT .OP-INFO>
	    <COND (<==? .NINS ILDB!-MIMOP>
		   <SET STYPE2 <PARSE-HINT <OP-HINT .OP-INFO> STRUCTURE-TYPE>>)
		  (<==? .NINS NTHL!-MIMOP> <SET STYPE2 LIST>)
		  (<SET STYPE2
			<2 <MEMBER <REST <SPNAME .NINS> 3>
				   '["UV"
				     VECTOR
				     "UU"
				     UVECTOR
				     "US"
				     STRING
				     "UB"
				     BYTES]>>>)>
	    <SET STRUC2 <1 <SET ARGVEC <OP-ARGS .OP-INFO>>>>
	    <OR <==? .STYPE1 .STYPE2>
		<AND <MEMQ .STYPE1 '[VECTOR UVECTOR LIST]>
		     <MEMQ .STYPE2 '[VECTOR UVECTOR LIST]>>
		<AND <MEMQ .STYPE1 '[STRING BYTES]>
		     <MEMQ .STYPE2 '[STRING BYTES]>>>
	    <SET OFF2 <2 .ARGVEC>>
	    <SET RES2 <OP-RES .OP-INFO>>
	    <WILL-DIE? .RES2 <REST .L>>
	    <TYPE? <SET NXT <GET-NEXT-INST .L>> FORM>
	    <MEMQ <1 .NXT> '[LESS?!-MIMOP GRTR?!-MIMOP VEQUAL?!-MIMOP]>
	    <OR <MEMQ .RES .NXT> <MEMQ .RES2 .NXT>>>
       <PARSE-OP .NXT .OP-INFO>
       <COND (<OR <NOT <SET TMIML <MEMQ <OP-BRANCH .OP-INFO> .L>>>
		  <NOT <WILL-DIE? .RES2 .TMIML>>>
					        ;"See comment above for EMPTY?"
	      <RETURN <> .NLA>)>
       <FLUSH-TO .L .CODPTR>
       <SLOT-COMPARE <COND (<==? <1 .ARGVEC> .RES> <SET RES1? 1> .STRUC1)
			   (<==? <1 .ARGVEC> .RES2> <SET RES2? 1> .STRUC2)
			   (<1 .ARGVEC>)>
		     <COND (<==? <2 .ARGVEC> .RES> <SET RES1? 2> .STRUC1)
			   (<==? <2 .ARGVEC> .RES2> <SET RES2? 2> .STRUC2)
			   (<2 .ARGVEC>)>
		     <1 .NXT>
		     .OP-INFO
		     <COND (<==? .RES1? 1> .OFF1) (<==? .RES2? 1> .OFF2)>
		     <COND (<==? .RES1? 1> .STYPE1) (<==? .RES2? 1> .STYPE2)>
		     <COND (<==? .RES1? 2> .OFF1) (<==? .RES2? 2> .OFF2)>
		     <COND (<==? .RES1? 2> .STYPE1) (<==? .RES2? 2> .STYPE2)>>
       CONDITIONAL-BRANCH)
      (<AND <MEMQ <1 .NXT> '[GRTR?!-MIMOP LESS?!-MIMOP VEQUAL?!-MIMOP]>
	    <PARSE-OP .NXT .OP-INFO>
	    <OR <==? <1 .ARGVEC> .RES> <==? <2 .ARGVEC> .RES>>
	    <AND <WILL-DIE? .RES .L>
		 <SET TMIML <MEMQ <OP-BRANCH .OP-INFO> .L>>
		 <WILL-DIE? .RES .TMIML>>>
       <COND (<==? <1 .ARGVEC> .RES> <SET RES1? T>)
	     (<==? <2 .ARGVEC> .RES> <SET RES2? T>)>
       <FLUSH-TO .L .CODPTR>
       <SLOT-COMPARE <COND (.RES1? .STRUC1) (<1 .ARGVEC>)>
		     <COND (.RES2? .STRUC1) (<2 .ARGVEC>)>
		     <1 .NXT>
		     .OP-INFO
		     <COND (.RES1? .OFF1)>
		     <COND (.RES1? .STYPE1)>
		     <COND (.RES2? .OFF1)>
		     <COND (.RES2? .STYPE1)>>
       CONDITIONAL-BRANCH)>)>>

<DEFINE FLUSH-TO (NL OL)
	#DECL ((NL OL) LIST)
	<SETG FLUSH-NEXT <- <LENGTH .OL> <LENGTH .NL>>>>

<DEFINE GET-NEXT-INST (LL) 
	#DECL ((LL) LIST)
	<REPEAT (FROB)
		<COND (<NOT <GETPROP <SET FROB <1 .LL>> DONE>>
		       <SET L <REST .LL>>
		       <RETURN .FROB>)>
		<COND (<EMPTY? <SET LL <REST .LL>>> <RETURN <>>)>>>

<DEFINE PARSE-OP (FRM OP-INFO
		  "AUX" (ARGVEC <OP-ARGS .OP-INFO>) (RES? <>) HINT
			(BRANCH? <>))
	#DECL ((FRM) FORM (OP-INFO) OP-INFO)
	<OP-HINT .OP-INFO <>>
	<OP-BRANCH .OP-INFO <>>
	<OP-RES .OP-INFO T>
	<MAPF <>
	      <FUNCTION (X) 
		      <COND (<OR <NOT <TYPE? .X LIST>> <EMPTY? .X>>
			     <COND (.RES? <SET RES? <>> <OP-RES .OP-INFO .X>)
				   (.BRANCH?
				    <SET BRANCH? <>>
				    <OP-BRANCH .OP-INFO .X>)
				   (<OR <==? .X -> <==? .X +>>
				    <OP-DIR .OP-INFO .X>
				    <SET BRANCH? T>)
				   (<TYPE? .X RES-IND> <SET RES? T>)
				   (<EMPTY? .ARGVEC>)
				   (T
				    <1 .ARGVEC .X>
				    <SET ARGVEC <REST .ARGVEC>>)>)
			    (<OR <==? <1 .X> TYPE> <==? <1 .X> STRUCTURE-TYPE>>
			     <OP-HINT .OP-INFO .X>)
			    (<==? <1 .X> BRANCH-FALSE>
			     <OP-BRANCH .OP-INFO <2 .X>>
			     <OP-DIR .OP-INFO ->)
			    (<==? <1 .X> BRANCH-TRUE>
			     <OP-BRANCH .OP-INFO <2 .X>>
			     <OP-DIR .OP-INFO +>)>>
	      <REST .FRM>>
	.OP-INFO>

<DEFINE WILL-DIE? (ARG
		   "OPT" (MIML .CODPTR) (BEG-LABEL T) "AUX" FOO (CP .CODPTR)
			 LR LABEL
			 (N
			  <COND (<==? .CP .MIML> ,FLUSH-NEXT)
				(<- ,FLUSH-NEXT
				    <- <LENGTH .CP> <LENGTH .MIML>>>)>))
   #DECL ((BEG-LABEL) ATOM (ARG) ANY (MIML) LIST (N) FIX)
 <COND
  (,LOOKAHEAD?
   <REPEAT LEAVE (NXT ITM JMP?)
     #DECL ((NXT) <OR ATOM FORM LIST>)
     <COND
      (<EMPTY? .MIML> <RETURN T>)
      (<AND <L=? <LENGTH .MIML> 1>
	    <OR <NOT <TYPE? <SET ITM <1 .MIML>> FORM>>
		<AND <N==? <1 .ITM> JUMP!-MIMOP>
		     <NOT <MEMQ + .ITM>>
		     <NOT <MEMQ - .ITM>>>>>
       <COND (<AND <TYPE? .ITM FORM>
		   <==? <1 .ITM> RETURN!-MIMOP>
		   <==? <2 .ITM> .ARG>>
	      <RETURN <>>)
	     (T
	      <RETURN T>)>)
      (<TYPE? <SET NXT <1 .MIML>> ATOM>
       <SET LR <GET-LREF .NXT T>>
       <COND (<MEMQ .ARG <LABEL-REF-LIVE-VARS .LR>> <RETURN <>>)
	     (<MEMQ .ARG <LABEL-REF-DEAD-VARS .LR>> <RETURN T>)>
       <COND (<WILL-DIE? .ARG <REST .MIML> .NXT>
	      <LABEL-REF-DEAD-VARS .LR (.ARG !<LABEL-REF-DEAD-VARS .LR>)>
	      <RETURN T>)
	     (T
	      <LABEL-REF-LIVE-VARS .LR (.ARG !<LABEL-REF-LIVE-VARS .LR>)>
	      <RETURN <>>)>)
      (<AND <TYPE?  .NXT FORM>
	    <L? <SET N <- .N 1>> 0>
	    <NOT <GETPROP .NXT DONE>>>
       <COND (<==? <SET ITM <1 .NXT>> DEAD!-MIMOP>
	      <COND (<MEMQ .ARG <REST .NXT>>
		     ; "Definitely dies if DEADed"
		     <RETURN T>)>)
	     (<==? .ITM RETURN!-MIMOP>
	      ; "Dies if not returned"
	      <RETURN <N==? <2 .NXT> .ARG>>)
	     (<==? .ITM END!-MIMOP>
	      ; "Dies if run out of code"
	      <RETURN T>)
	     (<==? .ITM SET!-MIMOP>
	      <COND (<==? <2 .NXT> .ARG>
		     ; "Dies if SET"
		     <RETURN T>)
		    (<==? <3 .NXT> .ARG>
		     ; "Doesn't die if something set to this"
		     <RETURN <>>)>)
	     (<AND <==? .ITM SETLR!-MIMOP>
		   <==? <2 .NXT> .ARG>>
	      ; "If doing SETLR, current value is dead"
	      <RETURN T>)
	     (T
	      <COND
	       (<==? .ITM JUMP!-MIMOP> <SET JMP? T>)
	       (T <SET JMP? <>>)>
	      ; "Unconditional jump is special case, slightly"
	      <MAPR <>
		 <FUNCTION (XP "AUX" (X <1 .XP>)) 
			 <COND (<TYPE? .X RES-IND>
				<COND (<==? <SET X <2 .XP>> .ARG>
				       ; "Result of something, so dead"
				       <RETURN T .LEAVE>)
				      (T <MAPLEAVE>)>)
			       (<==? .X .ARG>
				; "Arg to something, so not dead"
				<RETURN <> .LEAVE>)>>
		 .NXT>
	      <COND (<==? .ITM DISPATCH!-MIMOP>
		     <MAPF <>
		       <FUNCTION (LAB)
		         <COND (<==? .LAB .BEG-LABEL>)
			       (<SET FOO <MEMQ .LAB .MIML>>
				<SET LR <GET-LREF .LAB T>>
				<COND (<MEMQ .ARG <LABEL-REF-LIVE-VARS .LR>>
				       <RETURN <> .LEAVE>)
				      (<MEMQ .ARG <LABEL-REF-DEAD-VARS .LR>>)
				      (<WILL-DIE? .ARG <REST .FOO>>
				       <LABEL-REF-DEAD-VARS
					.LR (.ARG !<LABEL-REF-DEAD-VARS .LR>)>)
				      (T
				       <LABEL-REF-LIVE-VARS .LR
				        (.ARG !<LABEL-REF-LIVE-VARS .LR>)>
				       <RETURN <> .LEAVE>)>)
			       (T
				<RETURN <> .LEAVE>)>>
		       <REST .NXT 3>>)
		    (<OR <AND <==? .ITM ICALL!-MIMOP>
			      <SET FOO .NXT>>
			 <SET FOO <MEMQ + <SET NXT <REST .NXT>>>>
			 <SET FOO <MEMQ - .NXT>>
			 <AND <==? .ITM NTHR!-MIMOP>
			      <TYPE? <SET ITM <NTH .NXT <LENGTH .NXT>>> LIST>
			      <==? <1 .ITM> BRANCH-FALSE>
			      <SET FOO <REST .ITM>>>>
		     ; "Jump"
		     <COND (<SET FOO <MEMQ <SET LABEL <2 .FOO>> .MIML>>
			    ; "Hair to remember who's alive/dead at each place"
			    <SET LR <GET-LREF .LABEL T>>
			    <COND (<==? .LABEL .BEG-LABEL>
				   ; "If you hit a jump to the label where you
				      started, and you don't know the variable
				      is alive, then the jump won't make it live
				      either.  If the jump is unconditional,
				      the variable is dead."
				   <COND (.JMP? <RETURN T>)>)
				  (<MEMQ .ARG <LABEL-REF-LIVE-VARS .LR>>
				   <RETURN <>>)
				  (<MEMQ .ARG <LABEL-REF-DEAD-VARS .LR>>
				   <COND (.JMP? <RETURN T>)>)
				  (<WILL-DIE? .ARG <REST .FOO>>
				   <LABEL-REF-DEAD-VARS
				    .LR (.ARG !<LABEL-REF-DEAD-VARS .LR>)>
				   ; "If dies at branch loc, might die here"
				   <COND (.JMP?
					  ; "Unconditional jump, definitely dead"
					  <RETURN T>)>)
				  (T
				   <LABEL-REF-LIVE-VARS
				    .LR (.ARG !<LABEL-REF-LIVE-VARS .LR>)>
				   <RETURN <>>)>)
			   (T
			    ; "Lose, so not dead"
			    <RETURN <>>)>)>)>)>
     <SET MIML <REST .MIML>>>)>>

\ 

<DEFINE NTH-AOS-PUT-GEN NG 
	(NTHINS INCINS PUTINS STRUC1 OFFSET1 STRUC2 OFFSET2 AMOUNT CODELIST
	 ILDB? IDPB? STYPE1 STYPE2 ELTYPE1 ELTYPE2
	 "AUX" SAC1 SAC2 (ADDRTUP1 <ITUPLE 4 <>>) (ADDRTUP2 <ITUPLE 4 <>>)
	       TMPAC (SELF? <>))
	#DECL ((NTHINS) ATOM (INCINS) <OR ATOM FALSE> (STRUC) VARTBL)
	<SET SELF?
	     <AND <==? .STRUC1 .STRUC2>
		  <==? .OFFSET1 .OFFSET2>
		  <NOT .ILDB?>
		  <NOT .IDPB?>>>
	<COND (<OR <AND .OFFSET2
			<NOT .SELF?>
			.INCINS
			<OR <AND .ILDB? <==? .STYPE1 VECTOR>>
			    <AND .IDPB? <==? .STYPE2 VECTOR>>
			    <AND <MEMQ .STYPE1 '[VECTOR LIST UVECTOR]>
				 <NOT <MEMQ .STYPE2 '[VECTOR LIST UVECTOR]>>>
			    <AND <MEMQ .STYPE2 '[VECTOR LIST UVECTOR]>
				 <NOT <MEMQ .STYPE1 '[VECTOR
						      LIST
						      UVECTOR]>>>>>
		   <AND .ILDB?
			.IDPB?
			<NOT <OR <==? .STYPE1 .STYPE2>
				 <AND <MEMQ .STYPE1 '[STRING BYTES UVECTOR]>
				      <MEMQ .STYPE2
					    '[STRING BYTES UVECTOR]>>>>>
		   <AND .ILDB? <NOT <TYPE? .OFFSET2 FIX>>>
		   <AND .IDPB? <NOT <TYPE? .OFFSET1 FIX>>>>
 ;
"When we're dealing with the first element of a vector
 via ILDB/IDPB, might as well not try anything fancy here."
	       <RETURN <> .NG>)>
	<COND (.PUTINS <FLUSH-TO .CODELIST .CODPTR>)
	      (T
	       <FLUSH-TO <REST .CODPTR
			       <- <LENGTH .CODPTR> <LENGTH .CODELIST> 1>>
			 .CODPTR>)>
	<COND (<NOT <SET SAC1 <VAR-VALUE-IN-AC? .STRUC1>>>
	       <SET SAC1 <LOAD-VAR .STRUC1 VALUE <> PREF-VAL>>)>
	<PROTECT-USE .SAC1>
	<COND (<AND .PUTINS <NOT .SELF?>>
	       <COND (<AND <==? .STRUC1 .STRUC2> <N==? .STYPE1 LIST>>
		      <SET SAC2 .SAC1>)
		     (<NOT <SET SAC2 <VAR-VALUE-IN-AC? .STRUC2>>>
		      <SET SAC2 <LOAD-VAR .STRUC2 VALUE <> PREF-VAL>>
		      <PROTECT-USE .SAC2>)>)>
 ;
"Struc1 is now in sac1, appropriately rested; struc2 is in sac2,
	   also rested.  (Two may be same, if struc1==struc2 and not rested"
	<GET-ADDR .ADDRTUP1
		  .STRUC1
		  .SAC1
		  .OFFSET1
		  .STYPE1
		  .ILDB?
		  <>
		  <NOT .INCINS>>
	<COND (<AND .PUTINS <NOT .SELF?>>
	       <COND (<AND <3 .ADDRTUP1>
			   <==? .OFFSET1 .OFFSET2>
			   <OR <AND <==? .STYPE1 VECTOR> <==? .STYPE2 VECTOR>>
			       <AND <N==? .STYPE1 VECTOR>
				    <N==? .STYPE2 VECTOR>>>>
		      <GET-ADDR .ADDRTUP2
				.STRUC2
				.SAC2
				.OFFSET2
				.STYPE2
				.IDPB?
				<3 .ADDRTUP1>
				<NOT .INCINS>>)
		     (<GET-ADDR .ADDRTUP2
				.STRUC2
				.SAC2
				.OFFSET2
				.STYPE2
				.IDPB?
				<>
				<NOT .INCINS>>)>)>
	<COND (<NOT .INCINS>
	       <MOVE-ELT .ADDRTUP1
			 .ADDRTUP2
			 .STYPE1
			 .STYPE2
			 .ELTYPE1
			 .ELTYPE2
			 .IDPB?>)
	      (<MEMQ .INCINS ,ARITH>
	       <DO-ARITH .INCINS
			 .AMOUNT
			 <1 .ADDRTUP1>
			 <COND (.PUTINS <1 .ADDRTUP2>) (T .STRUC2)>
			 .SELF?
			 .STYPE1>)
	      (T
	       <DO-ARITH SUB!-MIMOP
			 .AMOUNT
			 <2 .ADDRTUP1>
			 <2 .ADDRTUP2>
			 .SELF?
			 WORD>			   ;"Decrement count on length"
	       <COND (<TYPE? .AMOUNT FIX>
		      <DO-ARITH ADD!-MIMOP
				<COND (<==? .INCINS RESTUV!-MIMOP>
				       <MA-IMM <* 8 .AMOUNT>>)
				      (<==? .INCINS RESTUU!-MIMOP>
				       <MA-IMM <* 4 .AMOUNT>>)
				      (<MA-IMM .AMOUNT>)>
				<1 .ADDRTUP1>
				<1 .ADDRTUP2>
				.SELF?
				VECTOR>)
		     (T
		      <COND (<OR <==? .INCINS RESTUS!-MIMOP>
				 <==? .INCINS RESTUB!-MIMOP>>
			     <SET TMPAC <VAR-VALUE-ADDRESS .AMOUNT>>)
			    (<SET TMPAC <VAR-VALUE-IN-AC? .AMOUNT>>
			     <MUNG-AC .TMPAC T>
			     <SET TMPAC <MA-REG .TMPAC>>
			     <EMIT ,INST-ASHL
				   <COND (<==? .INCINS RESTUV!-MIMOP>
					  <MA-IMM 3>)
					 (<MA-IMM 2>)>
				   .TMPAC
				   .TMPAC>)
			    (T
			     <SET TMPAC <GET-AC PREF-VAL>>
			     <EMIT ,INST-ASHL
				   <COND (<==? .INCINS RESTUV!-MIMOP>
					  <MA-IMM 3>)
					 (<MA-IMM 2>)>
				   <VAR-VALUE-ADDRESS .AMOUNT>
				   <SET TMPAC <MA-REG .TMPAC>>>)>
		      <DO-ARITH ADD!-MIMOP
				.TMPAC
				<1 .ADDRTUP1>
				<1 .ADDRTUP2>
				.SELF?
				VECTOR>)>)>
	<COND (.ILDB? <REST-BLOCK-GEN .STRUC1 1 .ILDB? 0 .STYPE1 T>)>
	<COND (.IDPB? <REST-BLOCK-GEN .STRUC2 1 .IDPB? 0 .STYPE2 T>)>
	NORMAL>

<DEFINE MOVE-ELT (TUP1 TUP2 ST1 ST2 EL1 EL2 IDPB? "AUX" INS ADDR1 ADDR2) 
	#DECL ((TUP1 TUP2) TUPLE (ST1 ST2 EL1 EL2) <OR ATOM FALSE>)
	<COND (<AND <MEMQ .ST1 '[VECTOR LIST]> <MEMQ .ST2 '[VECTOR LIST]>>
	       <SET INS ,INST-MOVQ>
	       <SET ADDR1 <4 .TUP1>>
	       <SET ADDR2 <4 .TUP2>>)
	      (T
	       <SET ADDR1 <1 .TUP1>>
	       <SET ADDR2 <1 .TUP2>>
	       <COND (<MEMQ .ST1 '[VECTOR LIST]>
		      <COND (<==? .ST2 UVECTOR>
			     <SET EL2 FIX>
			     <SET INS ,INST-MOVL>)
			    (<MEMQ .ST2 '[STRING BYTES]>
			     <COND (<==? .ST2 STRING> <SET EL2 CHARACTER>)
				   (<SET EL2 FIX>)>
			     <SET INS ,INST-CVTLB>)>)
		     (<==? .ST1 UVECTOR>
		      <COND (<AND .IDPB?
				  <==? .ST2 VECTOR>>
			     <EMIT ,INST-MOVL <TYPE-WORD FIX> !.ADDR2>)>
		      <COND (<MEMQ .ST2 '[VECTOR LIST UVECTOR]>
			     <SET EL2 FIX>
			     <SET INS ,INST-MOVL>)
			    (T
			     <COND (<==? .ST2 STRING> <SET EL2 CHARACTER>)
				   (<SET EL2 FIX>)>
			     <SET INS ,INST-CVTLB>)>)
		     (T
		      <COND (<AND .IDPB?
				  <==? .ST2 VECTOR>>
			     <EMIT ,INST-MOVL <TYPE-WORD FIX> !.ADDR2>)>
		      <COND (<MEMQ .ST2 '[VECTOR UVECTOR LIST]>
			     <COND (<==? .ST2 UVECTOR> <SET EL2 FIX>)>
			     <SET INS ,INST-MOVZBL>)
			    (T
			     <COND (<==? .ST2 STRING> <SET EL2 CHARACTER>)
				   (<SET EL2 FIX>)>
			     <SET INS ,INST-MOVB>)>)>)>
	<EMIT .INS !.ADDR1 !.ADDR2>
	<COND (<NOT .EL2>
	       <COND (.EL1 <EMIT ,INST-MOVW <TYPE-WORD .EL1> !<2 .TUP2>>)>)>>

<DEFINE DO-ARITH (INS AMOUNT ADDR1 ADDR2 SELF? STYPE1 "AUX" (VAC <>) RAC) 
   <COND (.SELF? <SET ADDR2 .ADDR1>)>
   <COND (<TYPE? .ADDR2 VARTBL>
	  <COND (<NOT <SET RAC <VAR-VALUE-IN-AC? .ADDR2>>>
		 <SET RAC <GET-AC PREF-VAL T>>
		 <PROTECT .RAC>)>
	  <DEST-DECL .RAC .ADDR2 <COND (<MEMQ .INS ,FLOATS> FLOAT)
				       (T FIX)>>)>
   <COND
    (<MEMQ .INS ,LOGIC>
     <COND (<TYPE? .AMOUNT FIX>
	    <COND (<==? .INS EQV!-MIMOP>
		   <SET AMOUNT <CHTYPE <XORB .AMOUNT -1> FIX>>
		   <SET INS XOR!-MIMOP>)
		  (<==? .INS AND!-MIMOP>
		   <SET AMOUNT <CHTYPE <XORB .AMOUNT -1> FIX>>)>)
	   (<OR <==? .INS EQV!-MIMOP> <==? .INS AND!-MIMOP>>
	    <EMIT ,INST-MCOML !.ADDR1 <SET VAC <GET-AC PREF-VAL T>>>
	    <COND (<==? .INS EQV!-MIMOP> <SET INS XOR!-MIMOP>)>)>
     <COND (.VAC
	    <COND (<TYPE? .ADDR2 VARTBL>
		   <EMIT <COND (<==? .INS AND!-MIMOP> ,INST-BICL3)
			       (<==? .INS XOR!-MIMOP> ,INST-XORL3)
			       (<==? .INS OR!-MIMOP> ,INST-BISL3)>
			 <MA-REG .VAC>
			 <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			       (<VAR-VALUE-ADDRESS .AMOUNT>)>
			 <MA-REG .RAC>>)
		  (T
		   <EMIT <COND (<==? .INS AND!-MIMOP> ,INST-BICL3)
			       (<==? .INS XOR!-MIMOP> ,INST-XORL3)
			       (<==? .INS OR!-MIMOP> ,INST-BISL3)>
			 <MA-REG .VAC>
			 <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			       (<VAR-VALUE-ADDRESS .AMOUNT>)>
			 !.ADDR2>)>)
	   (.SELF?
	    <EMIT <COND (<==? .INS AND!-MIMOP> ,INST-BICL2)
			(<==? .INS XOR!-MIMOP> ,INST-XORL2)
			(<==? .INS OR!-MIMOP> ,INST-BISL2)>
		  <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			(<VAR-VALUE-ADDRESS .AMOUNT>)>
		  !.ADDR1>)
	   (T
	    <COND (<TYPE? .ADDR2 VARTBL>
		   <EMIT <COND (<==? .INS AND!-MIMOP> ,INST-BICL3)
			       (<==? .INS XOR!-MIMOP> ,INST-XORL3)
			       (<==? .INS OR!-MIMOP> ,INST-BISL3)>
			 !.ADDR1
			 <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			       (<VAR-VALUE-ADDRESS .AMOUNT>)>
			 <MA-REG .RAC>>)
		  (T
		   <EMIT <COND (<==? .INS AND!-MIMOP> ,INST-BICL3)
			       (<==? .INS XOR!-MIMOP> ,INST-XORL3)
			       (<==? .INS OR!-MIMOP> ,INST-BISL3)>
			 !.ADDR1
			 <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			       (<VAR-VALUE-ADDRESS .AMOUNT>)>
			 !.ADDR2>)>)>)
    (<AND .SELF? <==? .AMOUNT 1>> <EMIT <PICK-ARITH .INS .STYPE1 1> !.ADDR1>)
    (.SELF?
     <EMIT <PICK-ARITH .INS .STYPE1 2>
	   <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
		 (<TYPE? .AMOUNT FLOAT> <FLOAT-IMM <FLOATCONVERT .AMOUNT>>)
		 (<TYPE? .AMOUNT VARTBL> <VAR-VALUE-ADDRESS .AMOUNT>)
		 (.AMOUNT)>
	   !.ADDR1>)
    (T
     <COND (<TYPE? .ADDR2 VARTBL>
	    <EMIT <PICK-ARITH .INS .STYPE1 3>
		  <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			(<TYPE? .AMOUNT FLOAT>
			 <FLOAT-IMM <FLOATCONVERT .AMOUNT>>)
			(<TYPE? .AMOUNT VARTBL> <VAR-VALUE-ADDRESS .AMOUNT>)
			(.AMOUNT)>
		  !.ADDR1
		  <VAR-VALUE-ADDRESS .ADDR2>>)
	   (T
	    <EMIT <PICK-ARITH .INS .STYPE1 3>
		  <COND (<TYPE? .AMOUNT FIX> <MA-IMM .AMOUNT>)
			(<TYPE? .AMOUNT FLOAT>
			 <FLOAT-IMM <FLOATCONVERT .AMOUNT>>)
			(<TYPE? .AMOUNT VARTBL> <VAR-VALUE-ADDRESS .AMOUNT>)
			(.AMOUNT)>
		  !.ADDR1
		  !.ADDR2>)>)>>

<SETG ADDS
      [[,INST-INCB ,INST-INCW ,INST-INCL]
       [,INST-ADDB2 ,INST-ADDW2 ,INST-ADDL2]
       [,INST-ADDB3 ,INST-ADDW3 ,INST-ADDL3]]>

<SETG SUBS
      [[,INST-DECB ,INST-DECW ,INST-DECL]
       [,INST-SUBB2 ,INST-SUBW2 ,INST-SUBL2]
       [,INST-SUBB3 ,INST-SUBW3 ,INST-SUBL3]]>

<SETG MULS
      [[]
       [,INST-MULB2 ,INST-MULW2 ,INST-MULL2]
       [,INST-MULB3 ,INST-MULW3 ,INST-MULL3]]>

<SETG DIVS
      [[]
       [,INST-DIVB2 ,INST-DIVW2 ,INST-DIVL2]
       [,INST-DIVB3 ,INST-DIVW3 ,INST-DIVL3]]>

<SETG FLOAT-OPS
      [[]
       [,INST-ADDF2 ,INST-SUBF2 ,INST-MULF2 ,INST-DIVF2]
       [,INST-ADDF3 ,INST-SUBF3 ,INST-MULF3 ,INST-DIVF3]]>

<GDECL (LOGIC) VECTOR (FLOAT-OPS ADDS SUBS MULS DIVS) <VECTOR [REST VECTOR]>>

<SETG LOGIC '[AND!-MIMOP OR!-MIMOP XOR!-MIMOP EQV!-MIMOP]>

<SETG FLOATS '[ADDF!-MIMOP SUBF!-MIMOP MULF!-MIMOP DIVF!-MIMOP]>

<DEFINE PICK-ARITH (OP STYPE NUMOPS "AUX" TV) 
	#DECL ((NUMOPS) FIX (OP) ATOM (STYPE) ATOM (TV) VECTOR)
	<COND (<==? .OP ADD!-MIMOP> <SET TV <NTH ,ADDS .NUMOPS>>)
	      (<==? .OP SUB!-MIMOP> <SET TV <NTH ,SUBS .NUMOPS>>)
	      (<==? .OP MUL!-MIMOP> <SET TV <NTH ,MULS .NUMOPS>>)
	      (<==? .OP DIV!-MIMOP> <SET TV <NTH ,DIVS .NUMOPS>>)
	      (T
	       <SET TV <NTH ,FLOAT-OPS .NUMOPS>>)>
	<COND (<MEMQ .OP ,FLOATS>
	       <COND (<==? .OP ADDF!-MIMOP> <1 .TV>)
		     (<==? .OP SUBF!-MIMOP> <2 .TV>)
		     (<==? .OP MULF!-MIMOP> <3 .TV>)
		     (<==? .OP DIVF!-MIMOP> <4 .TV>)>)
	      (<MEMQ .STYPE '[VECTOR UVECTOR LIST]> <3 .TV>)
	      (<==? .STYPE WORD> <2 .TV>)
	      (<1 .TV>)>>

<DEFINE GET-ADDR (TUP STRUC SAC OFFSET STYPE AINC?
		  "OPTIONAL" (RIDXAC <>) (FULL? <>)
		  "AUX" IDXAC)
	#DECL ((TUP) <TUPLE [3 ANY]> (SAC) AC (OFFSET) <OR FIX VARTBL>
	       (STYPE) ATOM)
	<COND (<AND <==? .STYPE LIST> <N==? .OFFSET 1>>
	       <COND (<TYPE? .OFFSET FIX>
		      <SET SAC <LIST-REST-CONSTANT-GEN .STRUC <- .OFFSET 1>>>)
		     (<SET SAC <LIST-REST-VAR-GEN .STRUC .OFFSET NTH>>)>
	       <SET OFFSET 1>)>
	<COND (.AINC? <1 .TUP (<MA-AINC .SAC>)>)
	      (<TYPE? .OFFSET FIX>
	       <COND (<1? .OFFSET>
		      <COND (<OR <==? .STYPE VECTOR> <==? .STYPE LIST>>
			     <4 .TUP (<MA-REGD .SAC>)>
			     <2 .TUP (<MA-DISP .SAC 2>)>
			     <1 .TUP (<MA-DISP .SAC 4>)>)
			    (<1 .TUP (<MA-REGD .SAC>)>)>)
		     (T
		      <COND (<==? .STYPE VECTOR>
			     <4 .TUP (<MA-DISP .SAC <* 8 <- .OFFSET 1>>>)>
			     <2 .TUP
				(<MA-DISP .SAC <+ 2 <* 8 <- .OFFSET 1>>>>)>
			     <1 .TUP
				(<MA-DISP .SAC <+ 4 <* 8 <- .OFFSET 1>>>>)>)
			    (<==? .STYPE UVECTOR>
			     <1 .TUP (<MA-DISP .SAC <* 4 <- .OFFSET 1>>>)>)
			    (T <1 .TUP (<MA-DISP .SAC <- .OFFSET 1>>)>)>)>)
	      (T
	       <COND (<AND <NOT .RIDXAC>
			   <NOT <SET IDXAC <VAR-VALUE-IN-AC? .OFFSET>>>>
		      <COND (<OR <N==? .STYPE VECTOR> .FULL?>
			     <SET IDXAC <LOAD-VAR .OFFSET VALUE <> PREF-VAL>>)
			    (T
			     <SET IDXAC <GET-AC PREF-VAL>>
			     <EMIT ,INST-ASHL
				   <MA-IMM 1>
				   <VAR-VALUE-ADDRESS .OFFSET>
				   <MA-REG .IDXAC>>)>
		      <PROTECT-USE .IDXAC>
		      <3 .TUP .IDXAC>)
		     (<AND <NOT .RIDXAC> <NOT .FULL?> <==? .STYPE VECTOR>>
		      <EMIT ,INST-ASHL
			    <MA-IMM 1>
			    <MA-REG .IDXAC>
			    <MA-REG .IDXAC>>
		      <MUNG-AC .IDXAC T>
		      <3 .TUP .IDXAC>)>
	       <COND (<==? .STYPE VECTOR>
		      <4 .TUP (<MA-INDX .IDXAC> <MA-DISP .SAC -8>)>
		      <2 .TUP (<MA-INDX .IDXAC> <MA-DISP .SAC -6>)>
		      <1 .TUP (<MA-INDX .IDXAC> <MA-DISP .SAC -4>)>)
		     (<==? .STYPE UVECTOR>
		      <1 .TUP (<MA-INDX .IDXAC> <MA-DISP .SAC -4>)>)
		     (T <1 .TUP (<MA-INDX .IDXAC> <MA-DISP .SAC -1>)>)>)>>

\ 

<DEFINE ILDB-LOOKAHEAD (L) 
   #DECL ((L) <LIST [REST <OR ATOM FORM>]>)
   <COND
    (,LOOKAHEAD?
     <MAPR <>
      <FUNCTION (LL "AUX" (FROB <1 .LL>) INS (REST? <>) (PUT? <>) NINS) 
	      <COND (<AND <TYPE? .FROB FORM> <NOT <GETPROP .FROB DONE>>>
		     <COND (<==? <SET INS <1 .FROB>> SETLR!-MIMOP>
			    <COND (<AND <NOT <EMPTY? <REST .LL>>>
					<TYPE? <SET NINS <2 .LL>> FORM>
					<==? <1 .NINS> PUSH!-MIMOP>
					<==? <2 .NINS> <2 .FROB>>
					<WILL-DIE? <2 .FROB> <REST .LL 2>>>
				   <2 .FROB STACK>
				   <PUTPROP .NINS DONE T>)>)
			   (<AND <OR <SET REST? <MEMQ .INS ,RESTU>>
				     <SET PUT? <MEMQ .INS ,PUTU>>
				     <MEMQ .INS ,NTHU>>
				 <==? <3 .FROB> 1>>
					 ;"This could be something interesting"
			    <ILDB-LOOKAHEAD-ONE .LL .REST? .PUT?>)>)>>
      .L>)>>

;
"Find ILDB/IDPB case, put MIMA code for it into list, kill other half of
   operation.  Form of ops is:
<ILDB STRUC NTHRES RESTRES (STRUCTURE-TYPE FOO)>
<IDPB STRUC NEWVAL RESTRES (STRUCTURE-TYPE FOO)>"

<DEFINE ILDB-LOOKAHEAD-ONE (L REST? PUT?
			    "AUX" (OP-INFO ,OP-INFO)
				  (ARGVEC <OP-ARGS .OP-INFO>) STRUC RES OP
				  OTHOP PUTOP)
   #DECL ((L) <LIST [REST <OR ATOM FORM>]> (OP-INFO) OP-INFO)
   <PARSE-OP <1 .L> .OP-INFO>
   <SET OP <1 <1 .L>>>
   <SET OTHOP <GETPROP .OP PAIR>>
   <SET PUTOP <GETPROP .OP PUT-PAIR>>
   <SET STRUC <1 .ARGVEC>>
   <SET RES <OP-RES .OP-INFO>>
   <MAPR <>
    <FUNCTION (LL "AUX" (FROB <1 .LL>) INS HINT) 
	    <COND (<TYPE? .FROB ATOM> <MAPLEAVE>)>
	    <COND (<AND <OR <==? <1 .FROB> .OTHOP>
			    <AND <OR .PUT? .REST?> <==? <1 .FROB> .PUTOP>>>
			<==? <2 .FROB> .STRUC>
			<==? <3 .FROB> 1>>	  ;"We now have the paired guy"
		   <COND (<MEMQ .OP ,RESTU> <SET HINT <REST <SPNAME .OP> 4>>)
			 (<SET HINT <REST <SPNAME .OP> 3>>)>
		   <COND (<=? .HINT "UV"> <SET HINT '(STRUCTURE-TYPE VECTOR)>)
			 (<=? .HINT "UU"> <SET HINT '(STRUCTURE-TYPE
						      UVECTOR)>)
			 (<=? .HINT "US"> <SET HINT '(STRUCTURE-TYPE STRING)>)
			 (T <SET HINT '(STRUCTURE-TYPE BYTES)>)>
		   <PARSE-OP .FROB .OP-INFO>
		   <COND (<OR .PUT? <MEMQ <1 .FROB> ,PUTU>>
			  <1 .L
			     <FORM IDPB!-MIMOP
				   .STRUC
				   <COND (.PUT? <4 <1 .L>>) (<3 .ARGVEC>)>
				   <COND (.PUT? <OP-RES .OP-INFO>) (.RES)>
				   .HINT>>
			  <PUTPROP .FROB DONE T>)
			 (<1 .L
			     <FORM ILDB!-MIMOP
				   .STRUC
				   <COND (.REST? <OP-RES .OP-INFO>) (.RES)>
				   <COND (.REST? .RES) (<OP-RES .OP-INFO>)>
				   .HINT>>
			  <PUTPROP .FROB DONE T>)>
		   <MAPLEAVE>)
		  (<OR <MEMQ .STRUC .FROB>
		       <MEMQ + .FROB>
		       <MEMQ - .FROB>
		       <AND <PARSE-OP .FROB .OP-INFO> <OP-BRANCH .OP-INFO>>>
		   <MAPLEAVE>)>>
    <REST .L>>>

"Generate ILDB/IDPB-like stuff.  Call with NTH/PUT inst, structure,
 result of nth/put, result of rest, flag, new value for put"

<DEFINE IDPB-GEN (STRUC ELVAL STRES HINT) 
	<ILDB-GEN .STRUC .ELVAL .STRES .HINT T>>

<DEFINE ILDB-GEN IG (STRUC ELVAL STRES HINT
		     "OPTIONAL" (PUT? <>)
		     "AUX" EHINT VINS STRAC ELAC (ELTAC <>) (DOUBLE? <>) LVAR
			   TAC VAC ELADDR (NO-TYPE? <>))
   #DECL ((STRUC) VARTBL (ELVAL) ANY)
   <COND (<AND <TYPE? .ELVAL ATOM VARTBL>
	       <NTH-LOOK-AHEAD ILDB!-MIMOP .STRUC .STRES .ELVAL <> .HINT>>
	  <RETURN NORMAL .IG>)>
   <SET HINT <PARSE-HINT .HINT STRUCTURE-TYPE>>
   <COND (<==? .HINT VECTOR>
	  <SET DOUBLE? T>
	  <SET VINS ,INST-MOVQ>
	  <SET EHINT <>>)
	 (<==? .HINT UVECTOR> <SET VINS ,INST-MOVL> <SET EHINT FIX>)
	 (<==? .HINT BYTES>
	  <SET EHINT FIX>
	  <COND (.PUT? <SET VINS ,INST-MOVB>) (<SET VINS ,INST-MOVZBL>)>)
	 (<==? .HINT STRING>
	  <SET EHINT CHARACTER>
	  <COND (.PUT? <SET VINS ,INST-MOVB>) (<SET VINS ,INST-MOVZBL>)>)>
   <COND (<NOT <SET STRAC <VAR-VALUE-IN-AC? .STRUC>>>
	  <SET STRAC <LOAD-VAR .STRUC VALUE <> PREF-VAL>>)>
						       ;"Get structure into AC"
   <PROTECT .STRAC>
   <COND (<N==? .STRAC ,AC-0> <PROTECT <PREV-AC .STRAC>>)>
   <COND
    (.PUT?
     <COND
      (<TYPE? .ELVAL VARTBL>
			  ;"Get the address to use for the thing we're putting"
       <COND
	(<SET LVAR <FIND-CACHE-VAR .ELVAL>>
	 <COND (.DOUBLE? <SET TAC <LINKVAR-TYPE-WORD-AC .LVAR>>)
	       (<SET TAC <>>)>
	 <SET VAC <LINKVAR-VALUE-AC .LVAR>>
	 <COND (<OR <NOT .DOUBLE?>
		    <AND .VAC .TAC <==? .VAC <NEXT-AC .TAC>>>
		    <AND <NOT .VAC> <NOT .TAC>>>
				     ;"Case where all in acs or all not in acs"
		<COND (.DOUBLE? <SET ELADDR <VAR-TYPE-ADDRESS .ELVAL>>)
		      (T <SET ELADDR <VAR-VALUE-ADDRESS .ELVAL>>)>)
	       (<AND <OR <NOT .TAC> <LINKVAR-TYPE-STORED .LVAR>>
		     <OR <NOT .VAC> <LINKVAR-VALUE-STORED .LVAR>>>
						  ;"Everything safely on stack"
		<SET ELADDR <ADDR-VAR-TYPE .ELVAL>>)
	       (T	  ;"Type and value live in separate places, can't MOVQ"
		<COND (<AND .LVAR
			    <NOT <LINKVAR-TYPE-STORED .LVAR>>
			    <NOT .TAC>
			    <VARTBL-DECL .ELVAL>>
		       <SET NO-TYPE? <TYPE-WORD <VARTBL-DECL .ELVAL>>>)
		      (T <SET NO-TYPE? <VAR-TYPE-ADDRESS .ELVAL>>)>
		<SET ELADDR <VAR-VALUE-ADDRESS .ELVAL>>)>)
	(.DOUBLE? <SET ELADDR <VAR-TYPE-ADDRESS .ELVAL>>)
	(<SET ELADDR <VAR-VALUE-ADDRESS .ELVAL>>)>)
      (.DOUBLE? <SET ELADDR <ADDR-TYPE-MQUOTE .ELVAL>>)
      (<SET ELADDR <MA-IMM .ELVAL>>)>)
    (<==? .ELVAL STACK>				    ;"Only happens in NTH case"
     <COND (<NOT .DOUBLE?> <EMIT-PUSH <TYPE-WORD .EHINT> LONG>)>
     <SET ELAC <MA-AINC ,AC-TP>>)
    (<==? .ELVAL .STRUC>
     <COND (.DOUBLE? <SET ELAC <GET-AC DOUBLE T>>)
	   (<SET ELAC <GET-AC PREF-VAL T>>)>)
    (<NOT <AND <SET ELAC <VAR-VALUE-IN-AC? .ELVAL>>
	       <OR <NOT .DOUBLE?>
		   <AND <SET ELTAC <VAR-TYPE-WORD-IN-AC? .ELVAL>>
			<==? <NEXT-AC .ELTAC> .ELAC>>>>>
     <DEAD-VAR .ELVAL>
     <COND (.DOUBLE? <SET ELAC <GET-AC DOUBLE T>>)
	   (<SET ELAC <GET-AC PREF-VAL T>>)>)
    (T
     <DEAD-VAR .ELVAL>
     <COND (.DOUBLE?
	    <STORE-AC .ELTAC T <FIND-CACHE-VAR .ELVAL>>
	    <STORE-AC .ELAC T <FIND-CACHE-VAR .ELVAL>>
	    <SET ELAC .ELTAC>)
	   (T <STORE-AC .ELAC T <FIND-CACHE-VAR .ELVAL>>)>)>
						        ;"Get AC[s] for result"
   <REST-BLOCK-GEN .STRUC
		   1
		   .STRES
		   0
		   <>
		   .VINS
		   <COND (.PUT? .ELADDR) (.ELAC)>
		   .PUT?
		   .NO-TYPE?>
   <COND (<AND <NOT .PUT?> <N==? .ELVAL STACK>>
	  <COND (.DOUBLE? <DEST-PAIR <NEXT-AC .ELAC> .ELAC .ELVAL>)
		(<LINK-VAR-TO-AC .ELVAL .ELAC VALUE <>>)>
	  <COND (.EHINT <DEST-DECL .ELAC .ELVAL .EHINT>)>)>
   NORMAL>

\ 

<DEFINE NTH-LENGTH-GEN (CINS STRUC OFF STYPE RES
			"AUX" SAC (TUP <ITUPLE 5 <>>) RAC)
	<COND (<NOT <SET SAC <VAR-VALUE-IN-AC? .STRUC>>>
	       <SET SAC <LOAD-VAR .STRUC VALUE <> PREF-VAL>>)>
	<PROTECT-USE .SAC>
	<GET-ADDR .TUP .STRUC .SAC .OFF .STYPE <> <> T>
	<COND (<NOT <SET RAC <VAR-VALUE-IN-AC? .RES>>>
	       <SET RAC <GET-AC PREF-VAL T>>)>
	<EMIT ,INST-MOVW !<2 .TUP> <MA-REG .RAC>>
	<LINK-VAR-TO-AC .RES .RAC VALUE <>>
	<DEST-DECL .RAC .RES FIX>
	NORMAL>

<DEFINE NTH-LENGTH-COMP-GEN (CINS STRUC OFF STYPE AMT CMPINS OP-INFO
			     "AUX" SAC (TUP <ITUPLE 5 <>>))
	#DECL ((OP-INFO) OP-INFO)
	<COND (<NOT <SET SAC <VAR-VALUE-IN-AC? .STRUC>>>
	       <SET SAC <LOAD-VAR .STRUC VALUE <> PREF-VAL>>)>
	<PROTECT-USE .SAC>
	<GET-ADDR .TUP .STRUC .SAC .OFF .STYPE <> <> T>
	<COND (<==? .AMT 0>
	       <COND (<==? .CMPINS EMPL?!-MIMOP>
		      <EMIT ,INST-TSTL !<1 .TUP>>)
		     (<EMIT ,INST-TSTW !<2 .TUP>>)>)
	      (<TYPE? .AMT FIX> <EMIT ,INST-CMPW !<2 .TUP> <MA-IMM .AMT>>)
	      (T <EMIT ,INST-CMPW !<2 .TUP> <VAR-VALUE-ADDRESS .AMT>>)>
	<GEN-TEST-INST
	 <COMPUTE-DIRECTION <OP-DIR .OP-INFO>
			    <COND (<MEMQ .CMPINS ,EMPU> ,CEQ-CODE)
				  (<==? .CMPINS EMPL?!-MIMOP> ,CEQ-CODE)
				  (<==? .CMPINS VEQUAL?!-MIMOP> ,CEQ-CODE)
				  (<==? .CMPINS LESS?!-MIMOP> ,CLT-CODE)
				  (<==? .CMPINS GRTR?!-MIMOP> ,CGT-CODE)>>
	 <OP-BRANCH .OP-INFO>
	 <>>
	CONDITIONAL-BRANCH>

<DEFINE SLOT-COMPARE (STRUC1 STRUC2 CMPINS OP-INFO OFF1 STYPE1 OFF2 STYPE2
		      "AUX" (SAC1 <>) (SAC2 <>) (ADDR1 <ITUPLE 5 <>>)
			    (ADDR2 <ITUPLE 5 <>>) (SHORT? <>) TMP FC)
	#DECL ((ADDR1 ADDR2) <OR TUPLE EFF-ADDR LADDR>)
	<COND (<OR <MEMQ .STYPE1 '[STRING BYTES]>
		   <MEMQ .STYPE2 '[STRING BYTES]>>
	       <SET SHORT? T>)>
	<COND (<AND .OFF2 <NOT .OFF1>>
	       <SET OFF1 .OFF2>
	       <SET OFF2 <>>
	       <SET STYPE1 .STYPE2>
	       <SET STYPE2 <>>
	       <SET TMP .STRUC2>
	       <SET STRUC2 .STRUC1>
	       <SET STRUC1 .TMP>
	       <SET CMPINS <COND (<==? .CMPINS GRTR?!-MIMOP>
				  LESS?!-MIMOP)
				 (<==? .CMPINS LESS?!-MIMOP>
				  GRTR?!-MIMOP)
				 (T .CMPINS)>>)>
	<COND (.OFF1
	       <COND (<NOT <SET SAC1 <VAR-VALUE-IN-AC? .STRUC1>>>
		      <SET SAC1 <LOAD-VAR .STRUC1 VALUE <> PREF-VAL>>)>
	       <PROTECT-USE .SAC1>)>
	<COND (.OFF2
	       <COND (<N==? .STRUC1 .STRUC2>
		      <COND (<NOT <SET SAC2 <VAR-VALUE-IN-AC? .STRUC2>>>
			     <SET SAC2 <LOAD-VAR .STRUC2 VALUE <> PREF-VAL>>)>
		      <PROTECT-USE .SAC2>)
		     (T <SET SAC2 .SAC1>)>)>
	<COND (.OFF1 <GET-ADDR .ADDR1 .STRUC1 .SAC1 .OFF1 .STYPE1 <>>)
	      (<TYPE? .STRUC1 VARTBL>
	       <SET ADDR1 <VAR-VALUE-ADDRESS .STRUC1>>)
	      (<FIX-CONSTANT? .STRUC1>
	       <COND (<NOT <TYPE? .STRUC1 FLOAT>>
		      <SET ADDR1 <MA-IMM .STRUC1>>)
		     (T
		      <SET ADDR1 <FLOAT-IMM <FLOATCONVERT .STRUC1>>>)>)
	      (<AND <==? <PRIMTYPE .STRUC1> LIST>
		    <EMPTY? .STRUC1>>
	       <SET STRUC1 0>
	       <SET ADDR1 <MA-IMM 0>>)
	      (T
	       <SET ADDR1 <ADDR-VALUE-MQUOTE .STRUC1>>)>
	<COND (<NOT .OFF2>
	       <COND (<TYPE? .STRUC2 VARTBL>
		      <SET ADDR2 <VAR-VALUE-ADDRESS .STRUC2>>)
		     (<FIX-CONSTANT? .STRUC2>
		      <COND (<NOT <TYPE? .STRUC2 FLOAT>>
			     <SET ADDR2 <MA-IMM .STRUC2>>)
			    (T
			     <SET ADDR2 <FLOAT-IMM <FLOATCONVERT .STRUC2>>>)>)
		     (<AND <==? <PRIMTYPE .STRUC2> LIST>
			   <EMPTY? .STRUC2>>
		      <SET STRUC2 0>
		      <SET ADDR2 <MA-IMM 0>>)
		     (T
		      <SET ADDR2 <ADDR-VALUE-MQUOTE .STRUC2>>)>)
	      (<AND <3 .ADDR1>		        ;"First guy had index register"
		    <==? .OFF1 .OFF2>
		    <TYPE? .OFF2 VARTBL>
		    <OR <==? .STYPE1 .STYPE2> .SHORT?>>
	       <GET-ADDR .ADDR2 .STRUC2 .SAC2 .OFF2 .STYPE2 <> <3 .ADDR1>>)
	      (T <GET-ADDR .ADDR2 .STRUC2 .SAC2 .OFF2 .STYPE2 <>>)>
	<COND (<OR <==? .STRUC1 0> <==? .STRUC2 0>>
	       <EMIT <COND (.SHORT? ,INST-TSTB) (,INST-TSTL)>
		     !<COND (<==? .STRUC1 0> <1 .ADDR2>) (<1 .ADDR1>)>>)
	      (<OR <==? .STRUC1 0.0> <==? .STRUC2 0.0>>
	       <EMIT ,INST-TSTF
		     !<COND (<==? .STRUC1 0.0> <1 .ADDR2>) (<1 .ADDR1>)>>)
	      (<OR <TYPE? .STRUC1 FLOAT> <TYPE? .STRUC2 FLOAT>>
	       <EMIT ,INST-CMPF
		     !<COND (<TYPE? .ADDR1 TUPLE> <1 .ADDR1>)((.ADDR1))>
		     !<COND (<TYPE? .ADDR2 TUPLE> <1 .ADDR2>)((.ADDR2))>>)
	      (T
	       <EMIT <COND (.SHORT? ,INST-CMPB) (T ,INST-CMPL)>
		     !<COND (<TYPE? .ADDR1 TUPLE> <1 .ADDR1>) ((.ADDR1))>
		     !<COND (<TYPE? .ADDR2 TUPLE> <1 .ADDR2>) ((.ADDR2))>>)>
	<GEN-TEST-INST
	 <COMPUTE-DIRECTION <OP-DIR .OP-INFO>
			    <COND (<==? .CMPINS VEQUAL?!-MIMOP> ,CEQ-CODE)
				  (<==? .CMPINS LESS?!-MIMOP> ,CLT-CODE)
				  (<==? .CMPINS GRTR?!-MIMOP> ,CGT-CODE)>>
	 <OP-BRANCH .OP-INFO>
	 <>>
	CONDITIONAL-BRANCH>