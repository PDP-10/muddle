<DEFMAC DFLOAT-MAC (OPER "ARGS" ARGS "AUX" (NARGS <LENGTH .ARGS>) RES)
  <COND (<OR <==? .OPER ADD>
	     <==? .OPER MUL>
	     <==? .OPER SUB>
	     <==? .OPER DIV>>
	 <COND (<OR <L? .NARGS 2>
		    <G? .NARGS 3>>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<COND (<==? .NARGS 2>
		       <SET RES <2 .ARGS>>)
		      (T
		       <SET RES <3 .ARGS>>)>
		<FORM CALL DOUBLE .OPER <1 .ARGS> <2 .ARGS> .RES>)>)
	(<OR <==? .OPER G?>
	     <==? .OPER =?>
	     <==? .OPER L?>>
	 <COND (<N==? .NARGS 2>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<FORM CALL DOUBLE .OPER <1 .ARGS> <2 .ARGS>>)>)
	(<==? .OPER DOUBLE-TO-SINGLE>
	 <COND (<N==? .NARGS 1>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<FORM CALL DOUBLE DOUBLE-TO-SINGLE <1 .ARGS>>)>)
	(<==? .OPER SINGLE-TO-DOUBLE>
	 <COND (<OR <L? .NARGS 1>
		    <G? .NARGS 2>>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<COND (<==? .NARGS 2>
		       <FORM CALL DOUBLE SINGLE-TO-DOUBLE <1 .ARGS>
			     <2 .ARGS>>)
		      (T
		       <FORM CALL DOUBLE SINGLE-TO-DOUBLE <1 .ARGS>
			     <FORM IUVECTOR 2>>)>)>)>>