<DEFINE LVAL-GVAL? (X "AUX" Y)
	<OR <TYPE? .X LVAL GVAL>
	    <AND <TYPE? .X FORM>
		 <==? <LENGTH .X> 2>
		 <OR <==? <SET Y <1 .X>> LVAL> <==? .Y GVAL>>>>>

<DEFINE LSH-LVAL? (X)
	<AND <TYPE? .X FORM>
	     <==? <LENGTH .X> 3>
	     <OR <AND <==? <1 .X> LSH>
		      <LVAL-GVAL? <2 .X>>
		      <TYPE? <3 .X> FIX>
		      .X>
		 <AND <==? <1 .X> CHTYPE>
		      <==? <3 .X> FIX>
		      <LSH-LVAL? <2 .X>>>>>>

<DEFMAC PRINTBYTE ('BYT "OPT" (MSK1 *17*) (MSK2 *37*)
		   "AUX" (X '.RBYT) (PRE-LSH 0) PL)
	<COND (<SET PL <LSH-LVAL? .BYT>>
	       <SET PRE-LSH <3 <SET BYT <CHTYPE .PL FORM>>>>
	       <SET BYT <2 .BYT>>)>
	<COND (<LVAL-GVAL? .BYT> <SET X .BYT>)>
	<FORM PROG <COND (<==? .BYT .X> ())
			 (ELSE ((RBYT .BYT)))> #DECL ((RBYT) FIX)
	      <FORM PUT '.OB 1 <FORM ASCII <FORM + <ASCII !\A>
					      <FORM CHTYPE
						 <FORM ANDB
						       <FORM LSH .X
							     <- .PRE-LSH 5>>
						       .MSK1> FIX>>>>
	      '<COND (<EMPTY? <SET OB <REST .OB>>>
		      <CHANNEL-OP .OC WRITE-BUFFER <SET OB ,OUTPUT-BUFFER>>)>
	      <FORM PUT '.OB 1 <FORM ASCII <FORM + <ASCII !\A>
					      <FORM CHTYPE
						<FORM ANDB
						      <COND (<==? .PRE-LSH 0> .X)
							    (ELSE
							     <FORM LSH .X
								   .PRE-LSH>)>
						      .MSK2> FIX>>>>
	      '<COND (<EMPTY? <SET OB <REST .OB>>>
		      <CHANNEL-OP .OC WRITE-BUFFER <SET OB ,OUTPUT-BUFFER>>)>>>

