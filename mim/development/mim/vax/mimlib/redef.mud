<PACKAGE "REDEF">

<USE "TTY">

<ENTRY REDEF-HANDLER>

<COND (<NOT <GASSIGNED? REDEF-THIS-CHAN>>
       <SETG REDEF-THIS-CHAN %<>>
       <SETG REDEF? %<>>)>

<DEFINE ERR-REDEF (IGNORE ERR-FRM "TUPLE" ARGS "AUX" NAME CHAR
		   (FLOAD-CHAN <COND (<ASSIGNED? LOAD-CHANNEL> .LOAD-CHANNEL)>)
		   (INCHAN ,DEBUG-CHANNEL) (OUTCHAN .INCHAN))
  #DECL ((ERR-FRM) FRAME (NAME) STRING (CHAR) CHARACTER 
	 (FLOAD-CHAN) <OR CHANNEL FALSE> (INCHAN OUTCHAN) <SPECIAL ANY>)
  <COND (<AND <G=? <LENGTH .ARGS> 2>
	      <==? <2 .ARGS>
		   ALREADY-DEFINED-ERRET-NON-FALSE-TO-REDEFINE!-ERRORS>>
	 <COND (<AND .FLOAD-CHAN <==? ,REDEF-THIS-CHAN .FLOAD-CHAN>>
		<DISMISS ,REDEF? .ERR-FRM>)>
	 <SET NAME <SPNAME <1 .ARGS>>>
	 <PRINTSTRING "Redefine ">
	 <PRINTSTRING .NAME>
	 <PRINTSTRING " ? ">
	 <CHANNEL-OP .INCHAN SET-ECHO-MODE T>
	 <REPEAT ()
	   <SET CHAR <TYI>>
           <COND (<MEMQ .CHAR "YyTt"> <CRLF> <DISMISS T .ERR-FRM>)
		 (<MEMQ .CHAR "NnFf"> <CRLF> <DISMISS %<> .ERR-FRM>)
		 (<==? .CHAR !\^>
		  <CRLF>
		  <SETG REDEF-THIS-CHAN .FLOAD-CHAN>
		  <SETG REDEF? %<>>
		  <DISMISS %<> .ERR-FRM>)
		 (<==? .CHAR !\*>
                  <CRLF>
		  <SETG REDEF-THIS-CHAN .FLOAD-CHAN>
		  <SETG REDEF? T>
		  <DISMISS T .ERR-FRM>)
                 (<MEMQ .CHAR "Rr">
                  <CRLF>
                  <SET REDEFINE T>
                  <DISMISS T .ERR-FRM>)
		 (<==? .CHAR !\?>
		  <PRINTSTRING "
	T or Y	redefine function
	F or N	don't redefine function
	R	redefine function and <SET REDEFINE T>
	*	redefine the rest of the functions from this file
	^	don't redefine any more functions from this file
	?	print this cruft
Redefine ">
		  <PRINTSTRING .NAME>
		  <PRINTSTRING " ? ">)
		 (ELSE
		  <CHANNEL-OP .OUTCHAN ERASE-CHAR>
		  <CHANNEL-OP .OUTCHAN IMAGE-OUT %<ASCII 7>>
		  <CHANNEL-OP .OUTCHAN SET-IMAGE-MODE %<>>
		  <CHANNEL-OP .OUTCHAN PAGE-X
			      <+ 12 <LENGTH .NAME>>>)>>)>>

<COND (<NOT <FEATURE? "COMPILER">>
       <COND (<GASSIGNED? REDEF-HANDLER> <OFF ,REDEF-HANDLER>)>
       <SETG REDEF-HANDLER <HANDLER "ERROR" ,ERR-REDEF 1>>
       <ON ,REDEF-HANDLER>)>

<ENDPACKAGE>
