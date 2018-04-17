<PACKAGE "BINARY">

<RENTRY BINARY>

<DEFINE BINARY (X)
   #DECL ((X) <OR FIX STRING> (OUTCHAN) CHANNEL)
   <COND (<TYPE? .X FIX>
	  <REPEAT ((D *20000000000*) (B <ISTRING 32>))
	     #DECL ((D) FIX (B) STRING)
	     <COND (<0? <ANDB .D .X>> <PUT .B 1 !\0>)
		   (T <PUT .B 1 !\1>)>
	     <COND (<0? <SET D <LSH .D -1>>> <RETURN <TOP .B>>)
		   (T <SET B <REST .B>>)>>)
	 (<AND <TYPE? .X STRING> <L=? <LENGTH .X> 32>>
	  <REPEAT ((D 0) (P <+ <LENGTH .X> 1>) (M 1))
	     #DECL ((D P M) FIX)
	     <COND (<0? <SET P <- .P 1>>> <RETURN <CHTYPE .D WORD>>)
		   (<==? <NTH .X .P> !\1> <SET D <+ .M .D>>)
		   (<N==? <NTH .X .P> !\0> <ERROR BAD-STRING!-ERRORS BINARY>)>
	     <SET M <LSH .M 1>>>)>>

<ENDPACKAGE>
