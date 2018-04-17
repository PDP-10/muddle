<SETG USAGE-STUFF <IUVECTOR 18>>

<DEFINE USAGE ("OPT" (STUFF ,USAGE-STUFF))
	#DECL ((STUFF) !<UVECTOR [18 FIX]>)
	<CALL SYSCALL GETRUSAGE 0 .STUFF>
	.STUFF>

<DEFINE PRINT-USAGE ("AUX" (STUFF ,USAGE-STUFF))
	#DECL ((STUFF) !<UVECTOR [18 FIX]>)
	<USAGE .STUFF>
	<PRINTSTRING "User time (sec):">
	<INDENT-TO 30>
	<PRIN1 <+ <FLOAT <1 .STUFF>> </ <FLOAT <2 .STUFF>> 1000000>>>
	<CRLF>
	<PRINTSTRING "System time (sec):">
	<INDENT-TO 30>
	<PRIN1 <+ <FLOAT <3 .STUFF>> </ <FLOAT <4 .STUFF>> 1000000>>>
	<CRLF>
	<PRINTSTRING "Max resident size (Kb):">
	<INDENT-TO 30>
	<PRIN1 <5 .STUFF>>
	<CRLF>
	<PRINTSTRING "Shared memory (Kb-sec):">
	<INDENT-TO 30>
	<PRIN1 <6 .STUFF>>
	<CRLF>
	<PRINTSTRING "Unshared data size (Kb-sec):">
	<INDENT-TO 30>
	<PRIN1 <7 .STUFF>>
	<CRLF>
	<PRINTSTRING "Unshared stack size (Kb-sec):">
	<INDENT-TO 30>
	<PRIN1 <8 .STUFF>>
	<CRLF>
	<PRINTSTRING "Minor page faults:">
	<INDENT-TO 30>
	<PRIN1 <9 .STUFF>>
	<CRLF>
	<PRINTSTRING "Major page faults:">
	<INDENT-TO 30>
	<PRIN1 <10 .STUFF>>
	<CRLF>
	<PRINTSTRING "Swaps:">
	<INDENT-TO 30>
	<PRIN1 <11 .STUFF>>
	<CRLF>
	<PRINTSTRING "Block input operations:">
	<INDENT-TO 30>
	<PRIN1 <12 .STUFF>>
	<CRLF>
	<PRINTSTRING "Block output operations:">
	<INDENT-TO 30>
	<PRIN1 <13 .STUFF>>
	<CRLF>
	<PRINTSTRING "Ipc messages sent:">
	<INDENT-TO 30>
	<PRIN1 <14 .STUFF>>
	<CRLF>
	<PRINTSTRING "Ipc messages received:">
	<INDENT-TO 30>
	<PRIN1 <15 .STUFF>>
	<CRLF>
	<PRINTSTRING "Signals delivered:">
	<INDENT-TO 30>
	<PRIN1 <16 .STUFF>>
	<CRLF>
	<PRINTSTRING "Vol. context switches:">
	<INDENT-TO 30>
	<PRIN1 <17 .STUFF>>
	<CRLF>
	<PRINTSTRING "Invol. context switches:">
	<INDENT-TO 30>
	<PRIN1 <18 .STUFF>>
	,NULL>
