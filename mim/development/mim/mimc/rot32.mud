<SETG 32MASK #WORD *37777777777*>

<MANIFEST 32MASK>

<DEFMAC ROT32!- ('A 'B "AUX" PT)
	<FORM IFSYS ("UNIX" <FORM ROT .A .B>)
	      ("TOPS20"
	       <COND (<AND <OR <==? <SET PT <PRIMTYPE .A>> FIX>
			       <==? .PT WORD>
			       <==? <SET PT <TYPE .A>> GVAL>
			       <==? .PT LVAL>
			       <AND <TYPE? .A FORM>
				    <==? <LENGTH .A> 2>
				    <OR <==? <1 .A> LVAL> <==? <1 .A> GVAL>>
				    <TYPE? <2 .A> ATOM>>>
			   <TYPE? .B FIX>>
		      <COND (<==? .B 0> .A)
			    (ELSE
			     <FORM ANDB
				   <FORM ORB <FORM LSH .A .B>
					 <FORM LSH <FORM ANDB .A ,32MASK>
					       <COND (<L? .B 0> <+ .B 32>)
						     (ELSE <- .B 32>)>>>
				   ,32MASK>)>)
		     (<TYPE? .B FIX>
		      <FORM PROG ((OBJ .A))
			    <FORM ANDB
				  <FORM ORB <FORM LSH '.OBJ .B>
					<FORM LSH <FORM ANDB '.OBJ ,32MASK>
					      <COND (<L? .B 0> <+ .B 32>)
						    (ELSE <- .B 32>)>>>
				  ,32MASK>>)
		     (ELSE
		      <FORM PROG ((OBJ .A) (SHFT .B))
			    <FORM ANDB
				  <FORM ORB <FORM LSH '.OBJ '.SHFT>
					<FORM LSH <FORM ANDB '.OBJ ,32MASK>
					      <FORM COND (<FORM L? '.SHFT 0>
							  <FORM + '.SHFT 32>)
						    (ELSE <FORM - '.SHFT 32>)>>>
				  ,32MASK>>)>)>>
		       
						