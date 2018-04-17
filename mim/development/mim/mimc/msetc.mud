<DEFINE MULTI-SET!- ('L "TUPLE" X)
	#DECL ((L) <LIST [REST ATOM]>)
	<COND (<N==? <LENGTH .X> <LENGTH .L>>
	       <ERROR WRONG-NUMBER-OF-VARIABLES .L .X>)
	      (ELSE
	       <MAPF <>
		     <FUNCTION (A B "AUX" LB)
			  <COND (<AND ,M$$DECL-CHECK!-INTERNAL
				      <SET LB <CALL NTHR .A ,M$$LVAL>>
				      <SET LB <M$$DECL .LB>>
				      <NOT <DECL? .B .LB>>>
				 <ERROR DECL-VIOLATION!-ERRORS .A .B .LB
					MULTI-SET>)
				(ELSE
				 <SET .A .B>)>> .L .X>)>>