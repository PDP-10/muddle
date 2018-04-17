
<PACKAGE "CARANA">

<ENTRY ARITH-ANA
       MOD-ANA
       ASTATE
       ABS-ANA
       ROT-ANA
       LSH-ANA
       FIX-ANA
       FLOAT-ANA
       ARITHP-ANA
       HACK-BOUNDS
       BIT-TEST-ANA>

<USE "SYMANA" "CHKDCL" "COMPDEC" "ADVMESS" "NPRINT">

"	This file contains analyzers and code generators for arithmetic
 SUBRs and predicates.  For convenience many of the SUBRs that are
similar are combined into one analyzer/generator.  For more info
on analyzers see SYMANA and on generators see CODGEN.
"

<SETG ASTATE '[![2 3 5] ![2 4 5] ![4 3 5] ![4 4 5] ![5 5 5]]>

<GDECL (ASTATE) <VECTOR [REST <UVECTOR [REST FIX]>]>>

"	Analyze +,-,* and /.  Take care of no arg and one arg problems."

<DEFINE ARITH-ANA (NOD RTYP
		   "AUX" (NN <NODE-NAME .NOD>) (DEFLT <GET-DF .NN>) (STATE 1)
			 (K <KIDS .NOD>) (FIXDIV <>) RT
			 (ALL-CONST ALL-CONST))
	#DECL ((NOD) <SPECIAL NODE> (K) <LIST [REST NODE]> (STYP) FIX
	       (STATE) <SPECIAL FIX> (DEFLT) <OR FIX FLOAT>
	       (ALL-CONST) <SPECIAL ANY>)
	<SET RT
	     <COND (<NOT <TYPE-OK? .RTYP FLOAT>> FIX) (ELSE '<OR FIX FLOAT>)>>
	<COND
	 (<EMPTY? .K>
	  <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
	  <PUT .NOD ,RESULT-TYPE <TYPE .DEFLT>>
	  <PUT .NOD ,NODE-NAME .DEFLT>
	  <PUT .NOD ,KIDS ()>
	  <TYPE-OK? <TYPE .DEFLT> .RTYP>)
	 (<AND <EMPTY? <REST .K>>
	       <N==? <NODE-TYPE <1 .K>> ,SEGMENT-CODE>
	       <N==? <NODE-TYPE <1 .K>> ,SEG-CODE>
	       <COND (<==? <NODE-SUBR .NOD> ,/>
		      <SET FIXDIV T>
		      <PUT .NOD
			   ,KIDS
			   <SET K
				(<NODE1 ,QUOTE-CODE
					.NOD
					<TYPE .DEFLT>
					.DEFLT
					()>
				 !.K)>>
		      <>)
		     (ELSE T)>>
	  <SET RT <EANA <1 .K> .RT <NODE-NAME .NOD>>>
	  <COND (<==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
		 <COND (<==? <NODE-SUBR .NOD> ,->
			<PUT .NOD ,NODE-NAME <- <NODE-NAME <1 .K>>>>)
		       (ELSE <PUT .NOD ,NODE-NAME <NODE-NAME <1 .K>>>)>
		 <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
		 <PUT .NOD ,RESULT-TYPE <TYPE <NODE-NAME .NOD>>>
		 <PUT .NOD ,KIDS ()>)
		(<==? <NODE-SUBR .NOD> ,-> <PUT .NOD ,NODE-TYPE ,ABS-CODE>)
		(ELSE <PUT .NOD ,NODE-TYPE ,ID-CODE>)>
	  .RT)
	 (ELSE
	  <MAPF <> <FUNCTION (N) <ARITH-ELE .N .RT <NODE-SUBR .NOD>>> .K>
	  <COND (<==? .NN +> <PUT .NOD ,KIDS <FLUSH-CONST .K 0>>)
		(<==? .NN ->
		 <PUT .NOD ,KIDS <SET K (<1 .K> !<FLUSH-CONST <REST .K> 0>)>>
		 <COND (<==? <LENGTH .K> 1>
			<PUT .NOD ,NODE-NAME +>
			<PUT .NOD ,NODE-SUBR ,+>)>)
		(<==? .NN *>
		 <COND (<FIND-ZERO .K .NOD>
			<SET ALL-CONST <COND (<==? .STATE 2> 0) (ELSE 0.0)>>)
		       (ELSE <PUT .NOD ,KIDS <FLUSH-CONST .K 1>>)>)
		(<==? .NN />
		 <COND (<FIND-ZERO <REST .K> .NOD>
			<COMPILE-ERROR "Divide by 0 " .NOD>)
		       (<FIND-ZERO (<1 .K>) .NOD>
			<SET ALL-CONST <COND (<==? .STATE 2> 0) (ELSE 0.0)>>)
		       (ELSE
			<PUT .NOD
			     ,KIDS
			     (<1 .K> !<FLUSH-CONST <REST .K> 1>)>)>)>
	  <COND (.ALL-CONST
		 <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
		 <PUT .NOD ,RESULT-TYPE <TYPE .ALL-CONST>>
		 <PUT .NOD ,NODE-NAME .ALL-CONST>
		 <PUT .NOD ,KIDS ()>)
		(<L? .STATE 5>
		 <COND (<AND .FIXDIV <N==? .STATE 2>>
			<PUT <PUT <1 .K> ,NODE-NAME 1.0> ,RESULT-TYPE FLOAT>)>
		 <PUT .NOD
		      ,NODE-TYPE
		      <COND (<OR <==? .NN MAX> <==? .NN MIN>> ,MIN-MAX-CODE)
			    (ELSE ,ARITH-CODE)>>
		 <MAPF <>
		       <FUNCTION (NN) 
			       #DECL ((NN) NODE)
			       <COND (<==? <NODE-TYPE .NN> ,SEGMENT-CODE>
				      <PUT .NN ,NODE-TYPE ,SEG-CODE>)>>
		       .K>)
		(ELSE <PUT .NOD ,NODE-TYPE ,ISUBR-CODE>)>
	  <TYPE-OK? <NTH '[FIX FLOAT FLOAT <OR FIX FLOAT>] <- .STATE 1>>
		    .RTYP>)>>

<DEFINE FIND-ZERO (K NOD) #DECL ((NOD) NODE (K) <LIST [REST NODE]>)
	<COND (<AND <OR <L? <LENGTH .NOD>
			    <CHTYPE <INDEX ,SIDE-EFFECTS>
				    FIX>>
			<NOT <SIDE-EFFECTS .NOD>>>
		    <MAPF <>
			  <FUNCTION (NN) #DECL ((NN) NODE)
			       <COND (<AND <==? <NODE-TYPE .NN> ,QUOTE-CODE>
					   <==? <CHTYPE <NODE-NAME .NN> FIX>
						0>>
				      <MAPLEAVE>)>>
			  .K>>)>>

<DEFINE FLUSH-CONST (K C "AUX" (FC <FLOAT .C>) (KK .K) (KP ())) 
	#DECL ((KK KP K) <LIST [REST NODE]> (C) FIX (FC) FLOAT)
	<REPEAT (NN)
		<COND (<EMPTY? .KK> <RETURN .K>)>
		<COND (<AND <==? <NODE-TYPE <SET NN <1 .KK>>> ,QUOTE-CODE>
			    <OR <==? <NODE-NAME .NN> .C>
				<==? <NODE-NAME .NN> .FC>>>
		       <COND (<==? .K .KK>
			      <COND (<EMPTY? <SET K <SET KK <REST .K>>>>
				     <RETURN .K>)>)
			     (ELSE <PUTREST .KP <REST .KK>>)>)
		      (ELSE <SET KP .KK>)>
		<SET KK <REST .KK>>>>

<DEFINE GET-DF (S) 
	#DECL ((S) ATOM)
	<NTH ,DFS <LENGTH <CHTYPE <MEMQ .S '[MAX MIN * / - +]> VECTOR>>>> 
 
<SETG DFS [0 0 1 1 <CHTYPE <MIN> FIX> <CHTYPE <MAX> FIX>]>

<GDECL (DFS) VECTOR>

<DEFINE ARITH-ELE (N RT
		   "OPT" OP
		   "AUX" TT TEM (FL <>) (A-C .ALL-CONST) (NOD .NOD)
			 (ISTATE .STATE))
	#DECL ((N NOD) NODE (STATE TT ISTATE) FIX)
	<COND (<OR <==? <NODE-TYPE .N> ,SEGMENT-CODE>
		   <==? <NODE-TYPE .N> ,SEG-CODE>>
	       <SET FL T>
	       <SET TEM
		    <EANA <1 <KIDS .N>>
			  <FORM STRUCTURED [REST .RT]>
			  <NODE-NAME .NOD>>>
	       <PUT .N ,RESULT-TYPE <RESULT-TYPE <1 <KIDS .N>>>>
	       <SET ALL-CONST <>>
	       <SET TEM <OR <AND <ISTYPE? .TEM> <GET-ELE-TYPE .TEM ALL>> ANY>>)
	      (ELSE
	       <SET TEM <EANA .N .RT <NODE-NAME .NOD>>>
	       <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE>
		      <COND (<OR <==? .ISTATE 4> <==? .ISTATE 3>>
			     <PUT .N ,NODE-NAME <FLOAT <NODE-NAME .N>>>
			     <PUT .N ,RESULT-TYPE FLOAT>)>
		      <COND (<==? .A-C ALL-CONST>
			     <SET ALL-CONST <NODE-NAME .N>>)
			    (.A-C
			     <SET ALL-CONST <APPLY .OP .A-C <NODE-NAME .N>>>)>)
		     (ELSE <SET ALL-CONST <>>)>)>
	<SET TT
	     <COND (<==? <ISTYPE? .TEM> FIX> 1)
		   (<==? .TEM FLOAT> 2)
		   (<NOT <TYPE-OK? .TEM FLOAT>>
		    <PUT .N
			 ,RESULT-TYPE
			 <COND (.FL
				<TYPE-MERGE '<STRUCTURED [REST FIX]>
					    <RESULT-TYPE .N>>)
			       (ELSE FIX)>>
		    1)
		   (<NOT <TYPE-OK? .TEM FIX>>
		    <PUT .N
			 ,RESULT-TYPE
			 <COND (.FL
				<TYPE-MERGE '<STRUCTURED [REST FLOAT]>
					    <RESULT-TYPE .N>>)
			       (ELSE FLOAT)>>
		    2)
		   (ELSE 3)>>
	<COND (<AND .VERBOSE <==? .TT 3>>
	       <ADDVMESS <PARENT .N>
			 ("Arithmetic can't open compile because:  "
			  .N
			  " is of type:  "
			  .TEM)>)>
	<SET STATE <NTH <NTH ,ASTATE .ISTATE> .TT>>>

<DEFINE ABS-ANA (N RT "AUX" (K <KIDS .N>) TEM) 
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<COND (<SEGFLUSH .N .RT>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 1 ABS .N>
	       <PUT .N ,NODE-TYPE ,ABS-CODE>
	       <SET TEM <EANA <1 .K> '<OR FIX FLOAT> ABS>>
	       <TYPE-OK? <TYPE-OK? ,ABS-DECL .RT>
			 .TEM>)>>

<SETG ABS-DECL
      <FORM OR FLOAT <FORM FIX (0 <MIN>)>>>

<COND (<GASSIGNED? ABS-ANA> <PUTPROP ,ABS ANALYSIS ,ABS-ANA>)>

<DEFINE MOD-ANA (N R "AUX" (K <KIDS .N>)) 
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 2 MOD .N>
	       <EANA <1 .K> FIX MOD>
	       <EANA <2 .K> FIX MOD>
	       <COND (<AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
			   <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>>
		      <PUT .N ,NODE-NAME <MOD <NODE-NAME <1 .K>>
					      <NODE-NAME <2 .K>>>>
		      <PUT .N ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .N ,KIDS ()>)
		     (ELSE
		      <PUT .N ,NODE-TYPE ,MOD-CODE>)>)>
	<TYPE-OK? <COND (<AND <NOT <EMPTY? <KIDS .N>>>
			      <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>>
			 <FORM FIX (0 <- <CHTYPE <NODE-NAME <2 .K>> FIX> 1>)>)
			(ELSE FIX)> .R>>

<COND (<GASSIGNED? MOD-ANA> <PUTPROP ,MOD ANALYSIS ,MOD-ANA>)>

<DEFINE ROT-LSH-ANA (N R COD "AUX" (K <KIDS .N>) (NAM <NODE-NAME .N>)) 
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 2 .NAM .N>
	       <EANA <1 .K> '<PRIMTYPE WORD> .NAM>
	       <EANA <2 .K> FIX .NAM>
	       <COND (<AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
			   <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>>
		      <COND (<==? .COD ,LSH-CODE>
			     <PUT .N ,NODE-NAME <LSH <NODE-NAME <1 .K>>
						     <NODE-NAME <2 .K>>>>)
			    (ELSE
			     <PUT .N ,NODE-NAME <ROT <NODE-NAME <1 .K>>
						     <NODE-NAME <2 .K>>>>)>
		      <PUT .N ,KIDS ()>
		      <PUT .N ,NODE-TYPE ,QUOTE-CODE>)
		     (ELSE
		      <PUT .N ,NODE-TYPE .COD>)>)>
	<TYPE-OK? FIX .R>>

<DEFINE ROT-ANA (N R) <ROT-LSH-ANA .N .R ,ROT-CODE>>

<DEFINE LSH-ANA (N R) <ROT-LSH-ANA .N .R ,LSH-CODE>>

<COND (<GASSIGNED? ROT-ANA>
       <PUTPROP ,ROT ANALYSIS ,ROT-ANA>
       <PUTPROP ,LSH ANALYSIS ,LSH-ANA>)>

<DEFINE FLOAT-ANA (N R) 
	#DECL ((N) NODE)
	<FL-FI-ANA .N .R FLOAT FIX ,FLOAT-CODE>>    
 
<COND (<GASSIGNED? FLOAT-ANA> <PUTPROP ,FLOAT ANALYSIS ,FLOAT-ANA>)>

<DEFINE FIX-ANA (N R) #DECL ((N) NODE) <FL-FI-ANA .N .R FIX FLOAT ,FIX-CODE>>
 
<COND (<GASSIGNED? FIX-ANA> <PUTPROP ,FIX ANALYSIS ,FIX-ANA>)>

<DEFINE FL-FI-ANA (N RT OT IT COD "AUX" (K <KIDS .N>) TY NUM) 
	#DECL ((N NUM) NODE (OT IT) ATOM (K) <LIST [REST NODE]> (COD) FIX)
	<COND (<SEGFLUSH .N .RT>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 1 .OT .N>
	       <SET TY <EANA <SET NUM <1 .K>> '<OR FIX FLOAT> .OT>>
	       <COND (<==? <NODE-TYPE .NUM> ,QUOTE-CODE>
		      <PUT .N ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .N ,NODE-NAME <APPLY ,.OT <NODE-NAME .NUM>>>)
		     (ELSE <PUT .N ,NODE-TYPE .COD>)>)>
	<TYPE-OK? .OT .RT>>

<DEFINE ARITHP-ANA (NOD RTYP
		    "AUX" (WHON <AND <==? .PRED <PARENT .NOD>> .NOD>) (WHO ())
			  (GLN .NOD) (GLE ()) (NN <NODE-NAME .NOD>)
			  (N
			   <COND (<OR <==? .NN 0?>
				      <==? .NN 1?>
				      <==? <NODE-TYPE .NOD> ,0-TST-CODE>>
				  1)
				 (ELSE 2)>) (K <KIDS .NOD>) TEM (STATE 1)
			  KT NT (ALL-CONST ALL-CONST) (TY BOOLEAN))
	#DECL ((WHO) <SPECIAL LIST> (WHON GLN ALL-CONST) <SPECIAL ANY>
	       (NOD NOD2) <SPECIAL NODE> (TEM) NODE (K) <LIST [REST NODE]>
	       (STATE) <SPECIAL FIX> (COD N) FIX (GLE) <SPECIAL LIST>)
	<COND (<SEGFLUSH .NOD .RTYP> <SET TY '<OR FALSE ATOM>>)
	      (ELSE
	       <COND (<AND <==? .N 2>
			   <==? <LENGTH .K> 1>
			   <==? <NODE-TYPE <SET NT <1 <KIDS .NOD>>>>
				,SUBR-CODE>
			   <==? <NODE-NAME .NT> LENGTH>
			   <==? <LENGTH <SET KT <KIDS .NT>>> 2>>
		      <COMPILE-WARNING
		       "Attempting to repair probable erroneous code:
"
		       .NOD
		       "
replaced by">
		      <PROG ()
			     <PUTREST .K <REST .KT>>
			     <PUTREST .KT ()>
			     <PUT <1 .KT> ,PARENT .NOD>>
		      <NODE-COMPLAIN .NOD>
		      <CRLF>)>
	       <ARGCHK <LENGTH .K> .N <NODE-NAME .NOD> .NOD>
	       <MAPF <> <FUNCTION (N) <ARITH-ELE .N '<OR FIX FLOAT>
						 <NODE-SUBR .NOD>>> .K>
	       <COND (.ALL-CONST
		      <COND (<==? .N 1>
			     <SET ALL-CONST
				  <APPLY <NODE-SUBR .NOD> .ALL-CONST>>)>
		      <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .NOD ,RESULT-TYPE <SET TY <TYPE .ALL-CONST>>>
		      <PUT .NOD ,NODE-NAME .ALL-CONST>
		      <PUT .NOD ,KIDS ()>
		      <SET ALL-CONST T>)
		     (<AND <==? .N 2>
			   <OR <AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
				    <OR <==? <NODE-NAME <1 .K>> 0>
					<==? <NODE-NAME <1 .K>> 0.0>>
				    <SET TEM <2 .K>>
				    <PUT .NOD
					 ,NODE-NAME
					 <FLOPP <NODE-NAME .NOD>>>>
			       <AND <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>
				    <OR <==? <NODE-NAME <2 .K>> 0>
					<==? <NODE-NAME <2 .K>> 0.0>>
				    <SET TEM <1 .K>>>>>
		      <PUT .NOD ,NODE-TYPE ,0-TST-CODE>
		      <PUT .NOD ,KIDS (.TEM)>)
		     (<==? <NODE-TYPE .NOD> ,0-TST-CODE>)
		     (<OR <==? <NODE-NAME .NOD> 0?> <==? <NODE-NAME .NOD> N0?>>
		      <PUT .NOD ,NODE-TYPE ,0-TST-CODE>)
		     (<L? .STATE 5>
		      <PUT .NOD
			   ,NODE-TYPE
			   <COND (<==? .N 2> ,TEST-CODE)
				 (<==? <NODE-NAME .NOD> 0?> ,0-TST-CODE)
				 (ELSE ,1?-CODE)>>)
		     (<==? <NODE-SUBR .NOD> ,1?>
		      <PUT .NOD ,NODE-TYPE ,1?-CODE>)
		     (<OR <==? <NODE-SUBR .NOD> ,==?>
			  <==? <NODE-SUBR .NOD> ,N==?>>
		      <PUT .NOD ,NODE-TYPE ,EQ-CODE>)
		     (ELSE
		      <SET TY '<OR ATOM FALSE>>
		      <PUT .NOD ,NODE-TYPE ,ISUBR-CODE>)>
	       <COND (<AND <==? .STATE 2> <NOT .ALL-CONST>>
		      <HACK-BOUNDS .WHO .GLE .NOD .K>)>
	       <CHECK-FOR-BIT-HACK .NOD>)>
	<TYPE-OK? .TY .RTYP>>

<DEFINE CHECK-FOR-BIT-HACK (N) <>>

'<DEFINE CHECK-FOR-BIT-HACK (N "AUX" (NN <1 <KIDS .N>>) DATA CONST K) 
	 #DECL ((NN DATA N) NODE (CONST) <PRIMTYPE WORD>)
	 <COND (<AND <==? <NODE-TYPE .N> ,0-TST-CODE>
		     <==? <NODE-TYPE .NN> ,CHTYPE-CODE>
		     <SET NN <1 <KIDS .NN>>>
		     <OR <AND <==? <NODE-TYPE .NN> ,GETBITS-CODE>
			      <SET K <KIDS .NN>>
			      <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>
			      <SET DATA <1 .K>>
			      <SET CONST <PUTBITS 0 <NODE-NAME <2 .K>> -1>>>
			 <AND <==? <NODE-TYPE .NN> ,BITL-CODE>
			      <==? <NODE-SUBR .NN> ,ANDB>
			      <==? <LENGTH <SET K <KIDS .NN>>> 2>
			      <OR <AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
				       <SET CONST <NODE-NAME <1 .K>>>
				       <SET DATA <2 .K>>>
				  <AND <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>
				       <SET CONST <NODE-NAME <2 .K>>>
				       <SET DATA <1 .K>>>
				  <SET CONST 0>>>>>
		<PUT .N ,NODE-TYPE ,BIT-TEST-CODE>
		<PUT .N ,NODE-SUBR .CONST>
		<PUT .N ,KIDS <COND (<ASSIGNED? DATA> (.DATA)) (ELSE .K)>>
		<COND (<ASSIGNED? DATA> <PUT .DATA ,PARENT .N>)
		      (ELSE
		       <PUT <1 .K> ,PARENT .N>
		       <PUT <2 .K> ,PARENT .N>)>)>>

<DEFINE BIT-TEST-ANA (N R "AUX" (K <KIDS .N>))
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<EANA <1 .K> '<PRIMTYPE WORD> BIT-TEST>
	<COND (<NOT <EMPTY? <SET K <REST .K>>>>
	       <EANA <1 .K> '<PRIMTYPE WORD> BIT-TEST>)>
	<TYPE-OK? <RESULT-TYPE .N> .R>>

<DEFINE HACK-BOUNDS (WHO GLE NOD K "AUX" NUM YES NO NOD2 (HACKT <>) DC) 
   #DECL ((WHO GLE) LIST (NOD NOD2) NODE (K) <LIST [REST NODE]>
	  (NUM) <OR FALSE FIX>)
   <SET NUM
	<COND (<OR <==? <NODE-NAME .NOD> 0?>
		   <==? <NODE-TYPE .NOD> ,0-TST-CODE>>
	       <SET NOD2 <1 .K>>
	       0)
	      (<==? <NODE-NAME .NOD> 1?> <SET NOD2 <1 .K>> 1)
	      (<==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
	       <SET NOD2 <2 .K>>
	       <NODE-NAME <1 .K>>)
	      (<==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>
	       <SET NOD2 <1 .K>>
	       <PUT .NOD ,NODE-NAME <FLOPP <NODE-NAME .NOD>>>
	       <PUT .NOD ,KIDS (<2 .K> <1 .K>)>
	       <NODE-NAME <2 .K>>)>>
   <COND (.NUM
	  <SET YES <FORM FIX <GTV .NOD .NUM>>>
	  <SET NO <FORM FIX <NGTV .NOD .NUM>>>
	  <MAPF <>
		<FUNCTION (L "AUX" (SYM <2 .L>)) 
			#DECL ((L) <LIST ANY SYMTAB> (SYM) SYMTAB)
			<SET TRUTH
			     <ADD-TYPE-LIST .SYM .YES .TRUTH <> <REST .L 2>>>
			<SET UNTRUTH
			     <ADD-TYPE-LIST .SYM .NO .UNTRUTH <> <REST .L 2>>>>
		.WHO>)>
   <COND (<AND .NUM <G=? .NUM 0>>
	  <COND (<OR <AND <NOT <0? .NUM>>
			  <OR <==? <NODE-NAME .NOD> G=?>
			      <==? <NODE-NAME .NOD> L?>>>
		     <AND <0? .NUM>
			  <OR <AND <==? <NODE-NAME .NOD> G?> <SET HACKT T>>
			      <==? <NODE-NAME .NOD> L=?>>>>
		 <SET NUM <+ .NUM 1>>)>
	  <OR .HACKT <SET HACKT <MEMQ <NODE-NAME .NOD> '[1? L? L=? ==?]>>>
	  <COND (<==? <NODE-NAME .NOD> 0?> <SET NUM 1>)>
	  <COND (<L=? .NUM 0> <SET DC STRUCTURED>)
		(ELSE <SET DC <CHTYPE (STRUCTURED !<ANY-PAT .NUM>) FORM>>)>
	  <MAPF <>
		<FUNCTION (L "AUX" (SYM <2 .L>) (FLG <1 .L>)) 
			#DECL ((L) <LIST ANY SYMTAB> (SYM) SYMTAB)
			<COND (.HACKT
			       <SET TRUTH
				    <ADD-TYPE-LIST .SYM
						   .DC
						   .TRUTH
						   <>
						   <REST .L 2>>>)
			      (ELSE
			       <SET UNTRUTH
				    <ADD-TYPE-LIST .SYM
						   .DC
						   .UNTRUTH
						   <>
						   <REST .L 2>>>)>
			T>
		.GLE>)>>

<SETG APSUBTAB [1? 0? L? L=? G? G=? ==? N==?]>

<GDECL (APSUBTAB) <VECTOR [REST ATOM]>>

<SETG DCLTAB
      [(1 1)
       (0 0)
       ('<COND (<==? .VAL ,PLUSINF> .VAL) (ELSE <+ .VAL 1>)> ,PLUSINF)
       ('.VAL ,PLUSINF)
       (,MINUSINF '<COND (<==? .VAL ,MINUSINF> .VAL) (ELSE <- .VAL 1>)>)
       (,MINUSINF '.VAL)
       ('.VAL '.VAL)
       (,MINUSINF
	'<COND (<==? .VAL ,MINUSINF> .VAL) (ELSE <- .VAL 1>)>
	'<COND (<==? .VAL ,PLUSINF> .VAL) (ELSE <+ .VAL 1>)>
	,PLUSINF)]>

<SETG NDCLTAB
      [(,MINUSINF 0 2 ,PLUSINF)
       (,MINUSINF -1 1 ,PLUSINF)
       (,MINUSINF '.VAL)
       (,MINUSINF '<COND (<==? .VAL ,MINUSINF> .VAL) (ELSE <- .VAL 1>)>)
       ('.VAL ,PLUSINF)
       ('<COND (<==? .VAL ,PLUSINF> .VAL) (ELSE <+ .VAL 1>)> ,PLUSINF)
       (,MINUSINF
	'<COND (<==? .VAL ,MINUSINF> .VAL) (ELSE <- .VAL 1>)>
	'<COND (<==? .VAL ,PLUSINF> .VAL) (ELSE <+ .VAL 1>)>
	,PLUSINF)
       ('.VAL '.VAL)]>

<GDECL (DCLTAB NDCLTAB) VECTOR>

<DEFINE NGTV (NOD VAL) 
	#DECL ((VAL) <SPECIAL ANY> (NOD) NODE)
	<EVAL <NTH ,NDCLTAB
		   <- 9 <LENGTH <MEMQ <NODE-NAME .NOD> ,APSUBTAB>>>>>>

<DEFINE GTV (NOD VAL) 
	#DECL ((NOD) NODE (VAL) <SPECIAL ANY>)
	<EVAL <NTH ,DCLTAB
		   <- 9 <LENGTH <MEMQ <NODE-NAME .NOD> ,APSUBTAB>>>>>>

<DEFINE FLOPP (SUBR) 
	#DECL ((SUBR VALUE) ATOM)
	<1 <REST <MEMQ .SUBR '[G? L? G? G=? L=? G=? ==? ==? N==? N==?]>>>>    

<COND (<GASSIGNED? ARITH-ANA>
       <PUTPROP ,+ ANALYSIS ,ARITH-ANA>
       <PUTPROP ,- ANALYSIS ,ARITH-ANA>
       <PUTPROP ,* ANALYSIS ,ARITH-ANA>
       <PUTPROP ,/ ANALYSIS ,ARITH-ANA>
       <PUTPROP ,MAX ANALYSIS ,ARITH-ANA>
       <PUTPROP ,MIN ANALYSIS ,ARITH-ANA>
       <PUTPROP ,0? ANALYSIS ,ARITHP-ANA>
       <PUTPROP ,1? ANALYSIS ,ARITHP-ANA>
       <PUTPROP ,L? ANALYSIS ,ARITHP-ANA>
       <PUTPROP ,G? ANALYSIS ,ARITHP-ANA>
       <PUTPROP ,G=? ANALYSIS ,ARITHP-ANA>
       <PUTPROP ,L=? ANALYSIS ,ARITHP-ANA>)>

<ENDPACKAGE>
