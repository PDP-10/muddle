<PUT-DECL DFLOAT '<<PRIMTYPE UVECTOR> [2 FIX]>>

<DEFINE DFLOAT (OPER "TUPLE" ARGS "AUX" (NARGS <LENGTH .ARGS>) RES)
  #DECL ((OPER) ATOM (ARGS) <TUPLE <OR FLOAT DFLOAT> [REST DFLOAT]>)
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
		<COND
		 (<==? .OPER ADD>
		  <CALL DOUBLE ADD <1 .ARGS> <2 .ARGS> .RES>)
		 (<==? .OPER MUL>
		  <CALL DOUBLE MUL <1 .ARGS> <2 .ARGS> .RES>)
		 (<==? .OPER SUB>
		  <CALL DOUBLE SUB <1 .ARGS> <2 .ARGS> .RES>)
		 (<==? .OPER DIV>
		  <CALL DOUBLE DIV <1 .ARGS> <2 .ARGS> .RES>)>
		.RES)>)
	(<OR <==? .OPER G?>
	     <==? .OPER =?>
	     <==? .OPER L?>>
	 <COND (<N==? .NARGS 2>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<COND
		 (<==? .OPER G?>
		  <CALL DOUBLE G? <1 .ARGS> <2 .ARGS>>)
		 (<==? .OPER =?>
		  <CALL DOUBLE =? <1 .ARGS> <2 .ARGS>>)
		 (<==? .OPER L?>
		  <CALL DOUBLE L? <1 .ARGS> <2 .ARGS>>)>)>)
	(<==? .OPER DOUBLE-TO-SINGLE>
	 <COND (<N==? .NARGS 1>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<CALL DOUBLE DOUBLE-TO-SINGLE <1 .ARGS>>)>)
	(<==? .OPER SINGLE-TO-DOUBLE>
	 <COND (<OR <L? .NARGS 1>
		    <G? .NARGS 2>>
		<ERROR WRONG-NUMBER-OF-ARGS!-ERRORS DOUBLE .OPER>)
	       (T
		<COND (<==? .NARGS 2>
		       <CALL DOUBLE SINGLE-TO-DOUBLE <1 .ARGS>
			     <SET RES <2 .ARGS>>>)
		      (T
		       <CALL DOUBLE SINGLE-TO-DOUBLE <1 .ARGS>
			     <SET RES <IUVECTOR 2>>>)>
		.RES)>)>>