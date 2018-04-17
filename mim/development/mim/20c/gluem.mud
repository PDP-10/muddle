
<USE "MSGLUE" "PDUMP">

<DEFINE D-G-P (NUM "AUX" (PD-DP <STRING "MIM:SAV.M20C-" <UNPARSE .NUM>>))
	(<MAPF ,LIST
	       <FUNCTION (X)
		    (<FILE-GLUE <STRING .X ".MSUBR">>
		     <PDUMP <STRING .X ".GSUBR"> .PD-DP>)>
	       ("ACVAR" "FILE-INDEX" "JSYS" "MOVERS" "NEWGC" "OTHGEN" "PART1"
		"PEEP" "STRMAN" "FILE")>)>
<PROG (N)
      <PRINC "Type in M20C version:  " ,OUTCHAN>
      <COND (<TYPE? <SET N <READ ,INCHAN>> FIX> <D-G-P .N>)
	    (ELSE
	     <PRINC "Not fix, try again." ,OUTCHAN>
	     <CRLF ,OUTCHAN>
	     <AGAIN>)>>
      
		    