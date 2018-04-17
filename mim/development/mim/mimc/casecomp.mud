
<PACKAGE "CASECOMP">

<ENTRY CASE-GEN>

<USE "CODGEN" "MIMGEN" "CHKDCL" "COMPDEC" "SORTX">

<SETG MAX-DENSE 2>

<DEFINE CASE-GEN (N W
		  "AUX" (K <KIDS .N>) (P <NODE-NAME <1 <KIDS <1 .K>>>>)
			(N1 <2 .K>) (SKIP-CH <>) (RW .W) (LNT 0) (DF <>) DN
			(DFT <MAKE-TAG "CASEDF">) MI MX RNGS (TAGS (X)) LLABS
			LABS (ET <MAKE-TAG "CASEND">) NOW (WSET <>) LOCN DAC TG
			TT W2 (FIRST T) S1 (S2 ()) TNUM LRT)
   #DECL ((N DN N1) NODE (P) ATOM (RNGS) UVECTOR)
   <SET TT <ISTYPE? <RESULT-TYPE .N1>>>
   <COND (<OR <==? .W ,POP-STACK>
	      <AND <TYPE? .W TEMP>
		   <TEMP-NO-RECYCLE .W>
		   <N==? <TEMP-NO-RECYCLE .W> ANY>>>
	  <SET W DONT-CARE>)>
   <SET K
	<MAPR ,LIST
	      <FUNCTION (NP "AUX" (N <1 .NP>)) 
		      #DECL ((N) NODE)
		      <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE>
			     <SET DF T>
			     <MAPRET>)>
		      <COND (.DF <SET DN .N> <SET DF <>> <MAPRET>)>
		      <COND (<==? <RESULT-TYPE .N> FALSE>
			     <COMPILE-NOTE "Case phrase always false " .N>
			     <MAPRET>)>
		      <COND (<AND <==? <RESULT-TYPE .N> ATOM>
				  <NOT <EMPTY? <REST .NP>>>>
			     <COMPILE-NOTE "Non reachable CASE clauses "
					   <2 .NP>>
			     (.N () FOO))>
		      (.N () FOO)>
	      <REST .K 2>>>
   <SET LNT
    <LENGTH
     <SET RNGS
      <MAPF ,UVECTOR
       <FUNCTION (L "AUX" (N <1 .L>) (NN <NODE-NAME <PREDIC .N>>)) 
	  #DECL ((N) NODE)
	  <PUT .L 3 <MAKE-TAG "CASE">>
	  <COND
	   (<==? .P ==?>
	    <COND (<TYPE? .NN LIST>
		   <MAPR <> <FUNCTION (L) <PUT .L 1 <FIX <1 .L>>>> .NN>)
		  (ELSE <SET NN <CHTYPE .NN FIX>>)>)
	   (<==? .P TYPE?>
	    <COND (<TYPE? .NN LIST>
		   <MAPR <>
			 <FUNCTION (L "AUX" TT) 
				 <COND (<G? <SET TT <CHTYPE <1 .L> FIX>> ,PMAX>
					<SET SKIP-CH T>)>
				 <PUT .L 1 .TT>>
			 .NN>)
		  (ELSE
		   <COND (<G? <SET NN <CHTYPE <TYPE-C .NN> FIX>> ,PMAX>
			  <SET SKIP-CH T>)>
		   .NN)>)
	   (<TYPE? .NN LIST>
	    <MAPR <>
		  <FUNCTION (L) <PUT .L 1 <CHTYPE <PTYPE-C <1 .L>> FIX>>>
		  .NN>)
	   (ELSE <SET NN <CHTYPE <PTYPE-C .NN> FIX>>)>
	  <COND (<TYPE? .NN LIST> <PUT .L 2 .NN> <MAPRET !.NN>)
		(ELSE <PUT .L 2 (.NN)> .NN)>>
       .K>>>>
   <SORT <> .RNGS>
   <SET TNUM <1 .RNGS>>
   <COND (<L=? .LNT 3> <SET SKIP-CH T>)
	 (<G? <- <SET MX <NTH .RNGS .LNT>> <SET MI .TNUM>>
	      <* .LNT ,MAX-DENSE>>
	  <SET SKIP-CH T>)>
   <MAPF <>
	 <FUNCTION (NUM) 
		 <COND (<==? .NUM .TNUM>
			<COMPILE-ERROR "Duplicate case entry " .N>)>
		 <SET TNUM .NUM>>
	 <REST .RNGS>>
   <SET W2 <GEN .N1 DONT-CARE>>
   <COND
    (<==? .P ==?>
     <COND
      (<NOT <ISTYPE? <RESULT-TYPE .N1>>>
       <GEN-TYPE?
	.W2
	<TYPE <COND (<TYPE? <SET TT <NODE-NAME <PREDIC <1 <1 .K>>>>> LIST>
		     <1 .TT>)
		    (ELSE .TT)>>
	.DFT
	<>>)>)
    (<==? .P TYPE?>)
    (ELSE)>
   <COND
    (<NOT .SKIP-CH>
     <SET NOW <+ .MI 1>>
     <SET LLABS <SET LABS (.MI)>>
     <REPEAT ()
	     <COND (<EMPTY? .RNGS> <RETURN>)>
	     <COND (<N==? .NOW <+ <1 .RNGS> 1>>
		    <SET NOW <+ .NOW 1>>
		    <PUTREST .LLABS <SET LLABS (.DFT)>>)
		   (ELSE
		    <PUTREST .LLABS <SET LLABS (<DOTAGS <1 .RNGS> .K>)>>
		    <SET NOW <+ .NOW 1>>
		    <SET RNGS <REST .RNGS>>)>>
     <IEMIT `DISPATCH .W2 !.LABS>
     <LABEL-TAG .DFT>
     <COND (<ASSIGNED? DN>
	    <SET LOCN <SEQ-GEN <KIDS .DN> .W>>
	    <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .W FLUSHED>>
		   <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		   <SET WSET T>)>
	    <COND (<OR <N==? <RESULT-TYPE .DN> NO-RETURN>
		       <N==? .LOCN ,NO-DATUM>>
		   <BRANCH-TAG .ET>)>)
	   (ELSE
	    <COND (<N==? .W FLUSHED>
		   <SET LOCN <MOVE-ARG <REFERENCE <>> .W>>
		   <COND (<AND <NOT .WSET>
			       <N==? .LOCN ,NO-DATUM>
			       <N==? .W FLUSHED>>
			  <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
			  <SET WSET T>)>)>
	    <BRANCH-TAG .ET>)>
     <MAPF <>
      <FUNCTION (L "AUX" (N <1 .L>) (TG <3 .L>)) 
	 <COND (<AND <NOT .FIRST> <N==? .LRT NO-RETURN>> <BRANCH-TAG .ET>)
	       (ELSE <SET FIRST <>>)>
	 <SET LRT <RESULT-TYPE .N>>
	 <LABEL-TAG .TG>
	 <COND
	  (<NOT <EMPTY? <KIDS .N>>>
	   <SET LOCN <SEQ-GEN <KIDS .N> .W>>
	   <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .W FLUSHED>>
		  <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		  <SET WSET T>)>)
	  (<N==? .W FLUSHED>
	   <SET LOCN
		<MOVE-ARG
		 <REFERENCE <COND (<==? .P ==?> T)
				  (ELSE <NODE-NAME <PREDIC .N>>)>>
		 .W>>
	   <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .W FLUSHED>>
		  <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		  <SET WSET T>)>)>>
      .K>)
    (ELSE
     <REPEAT (L KK) #DECL ((KK L) LIST)
	     <COND (<EMPTY? .K> <RETURN>)>
	     <DISTAG <2 <SET L <1 .K>>> .W2 <SET TG <3 .L>>>
	     <COND (<NOT <EMPTY? <SET KK <KIDS <1 .L>>>>>
		    <SET LOCN <SEQ-GEN .KK .W>>)
		   (<N==? .W FLUSHED> <SET LOCN <MOVE-ARG <REFERENCE T> .W>>)>
	     <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .W FLUSHED>>
		    <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
		    <SET WSET T>)>
	     <COND (<AND <NOT <EMPTY? .KK>>
			 <N==? <RESULT-TYPE <NTH .KK <LENGTH .KK>>> NO-RETURN>>
		    <BRANCH-TAG .ET>)>
	     <LABEL-TAG .TG>
	     <SET K <REST .K>>>
     <COND (<ASSIGNED? DN> <SET LOCN <SEQ-GEN <KIDS .DN> .W>>)
	   (ELSE <SET LOCN <MOVE-ARG <REFERENCE <>> .W>>)>
     <COND (<AND <NOT .WSET> <N==? .LOCN ,NO-DATUM> <N==? .W FLUSHED>>
	    <SET LOCN <SET W <FIXUP-TEMP .W .LOCN>>>
	    <SET WSET T>)>)>
   <LABEL-TAG .ET>
   <MOVE-ARG .W .RW>>

<DEFINE DOTAGS (N L) 
	#DECL ((N) FIX (L) <LIST [REST <LIST NODE <LIST [REST FIX]> ATOM>]>)
	<MAPF <>
	      <FUNCTION (LL) <COND (<MEMQ .N <2 .LL>> <MAPLEAVE <3 .LL>>)>>
	      .L>>

<DEFINE DISTAG (L DAC ATM "AUX" TG) 
	#DECL ((L) <LIST [REST FIX]> (ATM) ATOM)
	<COND (<G=? <LENGTH .L> 2> <SET TG <MAKE-TAG>>)>
	<REPEAT ()
		<COND (<EMPTY? .L>
		       <BRANCH-TAG .ATM>
		       <AND <ASSIGNED? TG> <LABEL-TAG .TG>>
		       <RETURN>)
		      (<EMPTY? <REST .L>>
		       <IEMIT `VEQUAL? .DAC <1 .L> - .ATM>
		       <AND <ASSIGNED? TG> <LABEL-TAG .TG>>
		       <RETURN>)
		      (ELSE <IEMIT `VEQUAL? .DAC <1 .L> + .TG>)>
		<SET L <REST .L 1>>>>

<DEFINE PTYPE-C (ATM) <PRIM-CODE <TYPE-C .ATM>>>  

<DEFINE FIXUP-TEMP (W LOCN) 
	<COND (<AND <TYPE? .LOCN TEMP> <L=? <TEMP-REFS .LOCN> 1>> .LOCN)
	      (<==? .LOCN .W> .LOCN)
	      (ELSE <MOVE-ARG .LOCN <GEN-TEMP <>>>)>>

<ENDPACKAGE>
