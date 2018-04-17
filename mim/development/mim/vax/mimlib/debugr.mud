;"A SINGLE STEP DEBUGR FOR MIM"

<PACKAGE "DEBUGR">

<RENTRY EVAL-IN         ;"Atom used by interrupt"
	EVAL-OUT>       ;"Atom used by interrupt"

<ENTRY DEBUG            ;"Establishes interrupt and returns enabled interrupt"
       DEBUG-IN		;"Last thing typed as about to be eval'ed"
       DEBUG-OUT	;"Last result printed"
       STOP             ;"Disables interrupt"
       START            ;"Enables interrupt"
       HELP             ;"Prints from help file"
       DEB-LEVEL       ;"Maintains value of # of eval frames until top level"
       DEB-IN          ;"Value of expression during last EVAL-IN interrupt"
       DEB-OUT         ;"Value of expression during last EVAL-OUT interrupt"
       INDENT-INC       ;"Spaces to indent each new level"
       INDENT-DIF       ;"Free spaces to leave on each line"
       INDENT-MOD       ;"Number of levels before indents begin on new line"
       SELF-FAST        ;"If true doesn't stop for objects which evaluate to 
                          themselves"
       FORM-FAST        ;"If true doesn't stop for simple forms: .FOO ,BAR 
                          'BLETCH"
       OUT-FAST         ;"If true won't stop on eval out"
       OUT-UNIQUE>;"If true won't stop for two successive outs of the
                          same thing"

<GDECL (DEB-LEVEL) FIX>

<INCLUDE-WHEN <COMPILING? "DEBUGR"> "DEBUGRDEFS">

<USE "TTY">

<DEFINE DEBUG ("OPTIONAL" 'TODO "AUX" (OUTCHAN:CHANNEL ,DEBUG-CHANNEL))
	<SETG DEBSTATE ,OPHF>
	<COND (<GASSIGNED? DEB-HANDLER>
	       <COND (<NOT <ASSIGNED? TODO>>
		      <PRINC "The Debugger is already loaded">
		      <CRLF>)>)
	      (ELSE
	       <INITIALIZE>
	       <CLASS "EVAL" <SETG DEBUGR-INT-LEV <+ <INT-LEVEL> 1>>>
	       <ON <SETG DEB-HANDLER
			 <HANDLER "EVAL" ,MAINLOOP>>>)>
	<SETG DEBSTATE ,NEXXT>
	<COND (<ASSIGNED? TODO>
	       <START>
	       <SET TODO <EVAL .TODO>>
	       <STOP>
	       .TODO)
	      (ELSE ,NEXXT)>>

<DEFINE STOP ()                      
	<SETG DEBSTATE ,OPHF>               ;"Turns off one step state"
	<COND (<GASSIGNED? DEB-HANDLER> <OFF ,DEB-HANDLER>)>
	<DISABLE "EVAL">                   ;"Disables interrupt"
	"OFF">


<DEFINE START ()
	#DECL ((VALUE) '1)
	<SET DEBUG-OUT <>>
	<SET DEBUG-IN <>>
	<COND (<NOT <GASSIGNED? DEB-HANDLER>>
	       <DEBUG>)
	      (<ON ,DEB-HANDLER>)>
	<ENABLE "EVAL">                   ;"Enables interrupt"
	<SETG DEBSTATE ,NEXXT>>            ;"Sets up one step state"

<SETG DEBUGR-HELP "DEBUGR.HELP">

<DEFINE HELP ("AUX" C (OUTCHAN:CHANNEL ,DEBUG-CHANNEL))
	<SETG DEBSTATE ,OPHF>
	<COND (<SET C <L-OPEN ,DEBUGR-HELP>> 
	       <FILECOPY .C .OUTCHAN>)
	      (ELSE <PRINC "No help available?"> <CRLF>)>
	<SETG DEBSTATE ,NEXXT>>

<DEFINE MAINLOOP (SHIT TYP ARG "OPT" VAL FOO
		  "AUX" (OUTCHAN ,DEBUG-CHANNEL) "NAME" LERR!-INTERRUPTS)
	#DECL ((TYP) ATOM (ARG VAL) ANY (OUTCHAN) CHANNEL
	       (LERR!-INTERRUPTS) <SPECIAL FRAME>)
	<COND (<==? ,DEBSTATE ,OPHF>) ;"Prevents stepping when not wanted"
	      (<==? .TYP EVAL-IN>  ;"The following prevents stepper from 
                                     stepping through part of itself"
	       <COND (<OR <=? .ARG '<STOP>>
			  <=? .ARG '<SETG DEBSTATE ,OPHF>>
			  <=? .ARG '<HELP>>
			  <=? .ARG '<START>>
			  <=? .ARG '<DEBUG>>
			  <=? .ARG 'DEBSTATE>
			  <=? .ARG ',OPHF>>)
		     (ELSE <EVAL-IN-DISPATCH .ARG>)>)
	      (<==? .TYP EVAL-OUT>
	       <COND (<OR <=? .ARG '<SETG DEBSTATE ,NEXXT>>
			  <=? .ARG '<SETG DEBSTATE ,OPHF>>
			  <=? .ARG '<START>>
			  <=? .ARG '<DEBUG>>
			  <=? .ARG '<HELP>>
			  <=? .ARG '<STOP>>
			  <=? .ARG 'DEBSTATE>
			  <=? .ARG ',OPHF>>)
		     (ELSE <EVAL-OUT-DISPATCH .VAL>)>)
	      (ELSE <PRINC "FOO!!!!">)>>   ;"Simple error checking, should never
                                             occur"

<DEFINE EVAL-IN-DISPATCH (EXPR "AUX" VAL)
	#DECL ((EXPR) ANY)
	<COND (<AND <STRUCTURED? ,DEB-IN>
		    <MEMQ .EXPR ,DEB-IN>>
	       <SETG DEB-LEVEL <+ ,DEB-LEVEL 1>>)
	      (ELSE <SETG DEB-LEVEL <FRAME-COUNT .LERR!-INTERRUPTS>>)>
	<SETG DEB-IN .EXPR>     ;"Binds check for user access"
	<COND (,MACRO-FLAG)
	      (<AND <==? ,DEB-LEVEL ,MACRO-LEVEL>
		    <OR <==? ,DEBSTATE ,FAST>
			<==? ,DEBSTATE ,WEER>>>
	       <SETG MACRO-FLAG T>)
	      (<==? ,DEBSTATE ,BODY>
	       <COND (<G? ,DEB-LEVEL <1 ,INFO>>)
		     (<AND <==? ,DEB-LEVEL <1 ,INFO>>
			   <MEMBER .EXPR <2 ,INFO>>>
		      <INPRINTER .EXPR ,DEB-LEVEL>
		      (<EVAL .EXPR>))
		     (ELSE <SETG DEBSTATE ,NEXXT>
		      <INPUT-PRINT-BREAK .EXPR ,DEB-LEVEL>)>)
	      (<AND <==? ,DEBSTATE ,PRED>
		    <EVAL ,PREDICATE>>
	       <INPUT-PRINT-BREAK .EXPR ,DEB-LEVEL>)
	      (<==? ,DEBSTATE ,WEER>
	       <COND (<G? ,DEB-LEVEL <1 ,INFO>>)
		     (<OR <AND <==? ,DEB-LEVEL <1 ,INFO>>
			       <=? .EXPR <2 ,INFO>>>
			  <L? ,DEB-LEVEL <1 ,INFO>>>
		      <SETG DEBSTATE ,NEXXT>
		      <INPUT-PRINT-BREAK .EXPR ,DEB-LEVEL>)
		     (<==? ,DEB-LEVEL <1 ,INFO>>
		      <INPRINTER .EXPR ,DEB-LEVEL>
		      ; "Just eval the expression, without further formalities"
			(<EVAL .EXPR>))>)
	      (<==? ,DEBSTATE ,NEXXT>
	       <INPUT-PRINT-BREAK .EXPR ,DEB-LEVEL>
	       <COND (<==? ,DEBSTATE ,FAST>
		      <UNWIND <SET VAL <EVAL .EXPR>>
			      <PROG ()
				 <SETG DEBSTATE ,NEXXT>
				 <ENABLE "EVAL">
				 <COND (<==? <INT-LEVEL> ,DEBUGR-INT-LEV>
					<INT-LEVEL <- ,DEBUGR-INT-LEV 1>>)>>>
		      <SETG DEBSTATE ,NEXXT>
		      (.VAL))
		     (<==? ,DEBSTATE ,FLUSH-STATE>
		      <SETG DEBSTATE ,NEXXT>
		      (<>))>)>>

<DEFINE EVAL-OUT-DISPATCH (EXPR)
	#DECL ((EXPR) ANY)
	<SETG DEB-LEVEL <FRAME-COUNT .LERR!-INTERRUPTS>>
	<SETG DEB-OUT .EXPR>   ;"Binds check for user access"
	<COND (<AND ,MACRO-FLAG <==? ,DEB-LEVEL ,MACRO-LEVEL>>
	       <SETG MACRO-LEVEL -1>
	       <SETG MACRO-FLAG <>>)
	      (,MACRO-FLAG)
	      (<OR <==? ,DEBSTATE ,NEXXT>
		   <AND <==? ,DEBSTATE ,BODY>       ;"The following are the"
			<L? ,DEB-LEVEL <1 ,INFO>>>;"terminating conditions"
		   <AND <==? ,DEBSTATE ,FAST>      ;"for BODY, FAST, WEER"
			<L=? ,DEB-LEVEL <1 ,INFO>>>;"and Predicate, in which"
		   <AND <==? ,DEBSTATE ,WEER>     ;"case state is changed"
			<L? ,DEB-LEVEL <1 ,INFO>>>>
	       <SETG DEBSTATE ,NEXXT>
	       <OUTPUT-PRINT-BREAK .EXPR ,DEB-LEVEL>)
	      (<AND <==? ,DEBSTATE ,PRED>
		    <EVAL ,PREDICATE>>
	       <SETG LO LO>
	       <OUTPUT-PRINT-BREAK .EXPR ,DEB-LEVEL>)
	      (<AND <OR <==? ,DEBSTATE ,WEER>
			<==? ,DEBSTATE ,BODY>>
		    <==? ,DEB-LEVEL <1 ,INFO>>
		    ,INFULL?>
	       <OUTPRINTER .EXPR ,DEB-LEVEL>)>>

<DEFINE INPUT-PRINT-BREAK (EXPRESSION LEVEL "AUX" I/O-MODE)
	#DECL ((EXPRESSION) ANY (LEVEL) FIX)
	<COND (<AND <TYPE? .EXPRESSION ATOM>
		    <NOT ,INFULL?>
		    <N==? ,DEBSTATE ,PRED>>)
	      (ELSE
	       <SET DEBUG-IN .EXPRESSION>
	       <INPRINTER .EXPRESSION .LEVEL>
	       <SETG DEBSTATE <READER ,INFULL?>> ;"Reader returns explicit 
					     debug state"
	       <COND (<==? ,DEBSTATE ,BODY> 
		      <SETG INFO [<+ .LEVEL 1> .EXPRESSION]>
		      <SETG MACRO-LEVEL .LEVEL>)
		     (<OR <==? ,DEBSTATE ,FAST>
			  <==? ,DEBSTATE ,WEER>>
		      <SETG MACRO-LEVEL .LEVEL>
		      <SETG INFO [.LEVEL .EXPRESSION]>)>)>>

<DEFINE INPRINTER (EXPRESSION LEVEL "AUX" (OUTCHAN ,DEBUG-CHANNEL)
		   (INDENT <MIN <* ,INDENT-INC
				   <MOD <MAX .LEVEL 1> ,INDENT-MOD>>
				<- <CHANNEL-OP .OUTCHAN PAGE-WIDTH>:FIX
				   ,INDENT-DIF>>))
	#DECL ((LEVEL INDENT) FIX (VALUE) <OR FALSE 'T>
	       (OUTCHAN) CHANNEL)
	<SETG LO LO>            ;"This is in so flush last out value"
	<INDENT-TO .INDENT .OUTCHAN>     ;"Pprints indent routine"
	<PRIN1 .LEVEL>
	<COND (<==? ,DEBSTATE ,PRED>
	       <NORMAL-PRINTER .EXPRESSION>)
	      (<AND ,FORM-FAST        ;"Checks for simple forms:"
		    <TYPE? .EXPRESSION FORM>>
	       <COND (<OR <EMPTY? .EXPRESSION> ;"Like <>"
			  <==? <1 .EXPRESSION> FUNCTION>
			  <==? <1 .EXPRESSION> QUOTE> ;"Like 'BLETCH"
			  <AND <==? <LENGTH? .EXPRESSION 2> 2> 
			       <OR <==? <1 .EXPRESSION> LVAL>  ;"Like .FOO"
				   <==? <1 .EXPRESSION> GVAL>> ;"Like ,BAR"
			       <TYPE? <2 .EXPRESSION> ATOM>>>
		      <QUICK-PRINTER .EXPRESSION>)
		     (ELSE <NORMAL-PRINTER .EXPRESSION>)>)
	      (<AND ,FORM-FAST
		    <TYPE? .EXPRESSION LVAL GVAL>> ;"Checks for simple forms like 
                                                     .FOO ,BAR"
	       <QUICK-PRINTER .EXPRESSION>)
	      (<AND ,FORM-FAST
		    <TYPE? .EXPRESSION LIST>
		    <EMPTY? .EXPRESSION>>
	       <QUICK-PRINTER .EXPRESSION>)
	      (<AND ,SELF-FAST    ;"Checks for types evaluating to themselves"
		    <NOT <TYPE? .EXPRESSION LIST VECTOR UVECTOR FORM GVAL LVAL>>>
	       <SELF-PRINTER .EXPRESSION>)   
	      (ELSE <NORMAL-PRINTER .EXPRESSION>)>>


<DEFINE NORMAL-PRINTER (EXPRESSION "AUX" (OUTCHAN:CHANNEL ,DEBUG-CHANNEL))
   ;"Used to print arrow and value"
	#DECL ((EXPRESSION) ANY (VALUE) 'T)
	<PRINC "=> ">
	<&1 .EXPRESSION>
	<CRLF>
	<SETG INFULL? T>>  ;"Infull is a flag telling if the last printed was in 
                             full or abbreviated"

<DEFINE QUICK-PRINTER (EXPRESSION "AUX" (OUTCHAN:CHANNEL ,DEBUG-CHANNEL))
	#DECL ((VALUE) FALSE (EXPRESSION) ANY)
	<PRINC ":  ">
	<&1 .EXPRESSION>
	<PRINC " = ">
	<SETG LO <EVAL .EXPRESSION>>
	<SET DEBUG-OUT ,LO>
	<&1 ,LO>
	<CRLF>
	<SETG INFULL? <>>>

<DEFINE SELF-PRINTER (EXPRESSION "AUX" (OUTCHAN:CHANNEL ,DEBUG-CHANNEL))
   ;"Prints types evaluating to themselves"
	#DECL ((VALUE) FALSE (EXPRESSION) ANY)
	<PRINC ":  ">
	<&1 .EXPRESSION>
	<SET DEBUG-OUT .EXPRESSION>
	<CRLF>
	<SETG INFULL? <>>>

<DEFINE OUTPUT-PRINT-BREAK (EXPRESSION LEVEL)
	#DECL ((EXPRESSION) ANY (LEVEL) FIX)
	<COND (,INFULL?
	       <SET DEBUG-OUT .EXPRESSION>
	       <OUTPRINTER .EXPRESSION .LEVEL>)
	      (ELSE <SETG INFULL? T>)>>

<DEFINE OUTPRINTER (EXPRESSION LEVEL "AUX" (OUTCHAN ,DEBUG-CHANNEL) LO
		    (INDENT <MIN <* ,INDENT-INC <MOD <MAX .LEVEL>
						     ,INDENT-MOD>>
				 <- <CHANNEL-OP .OUTCHAN PAGE-WIDTH>
				    ,INDENT-DIF>>))
	#DECL ((INDENT LEVEL) FIX (OUTCHAN) CHANNEL (VALUE) ANY)
	<COND (<OR <NOT ,OUT-UNIQUE>
		   <N==? .EXPRESSION ,LO>> ;"Checks to see if same as last"
	       <INDENT-TO .INDENT .OUTCHAN>;"Pprints indent routine"
	       <PRIN1 .LEVEL>              
	       <PRINC "<= ">
	       <&1 .EXPRESSION>
	       <CRLF>
	       <COND (<OR <AND <NOT ,OUT-FAST>
			       <==? ,DEBSTATE ,NEXXT>>
			  <==? ,DEBSTATE ,PRED>>
		      <SETG DEBSTATE <READER T>>)>
	       <SETG LO <SET LO .EXPRESSION>>)>>

<DEFINE READER (ON?)         ;"On? is bound to INFULL?, return from printer
                               telling if a new value must be read or if 
                               state is still the same"
  #DECL ((ON?) <OR FALSE 'T>)
  <COND (.ON?
	 <COND (<L=? ,REPEAT-COUNT 0> <READ-INPUT>)> ;"Checks global repeat 
                                                       count and reads if 0"
	 <SETG REPEAT-COUNT <- ,REPEAT-COUNT 1>>     ;"Decrement repeat count"
	 <COND (<==? ,DEBSTATE ,OPHF> ,OPHF)	;"If off, stay that way"
	       (<==? ,LAST-CHAR ,NEXXT-CHAR> ,NEXXT)   ;"Dispatch to return "
	       (<==? ,LAST-CHAR ,BODY-CHAR> ,BODY)     ;"proper state"
	       (<==? ,LAST-CHAR ,FAST-CHAR> ,FAST)
	       (<==? ,LAST-CHAR ,WEER-CHAR> ,WEER)
	       (<==? ,LAST-CHAR ,PRED-CHAR> ,PRED)
	       (<==? ,LAST-CHAR ,FLUSH-CHAR> ,FLUSH-STATE)>)
	(ELSE ,DEBSTATE)>> ;"If reader wasn't on return previous state"
 
<SETG BUFFER <ISTRING 100>>

<DEFINE READ-INPUT ("AUX" (BUFFER ,BUFFER) (OUTCHAN:CHANNEL ,DEBUG-CHANNEL))
	#DECL ((BUFFER) STRING)
	<PROG (CT (TOT 0) NB PARSE-LIST FOO)
	      #DECL ((CT TOT) FIX (NB) STRING (PARSE-LIST) LIST)
	      <SET CT <READSTRING .BUFFER ,INCHAN ,CHAR-LIST 0 .TOT>>
	      <COND (<AND <==? .CT <LENGTH .BUFFER>>
			  <NOT <MEMQ <NTH .BUFFER <LENGTH .BUFFER>>
				     ,CHAR-LIST>>>
		     <SET TOT <+ .TOT .CT>>
		     <SET NB <ISTRING <+ <LENGTH .BUFFER> 100>>>
		     <SETG BUFFER .NB>
		     <SUBSTRUC .BUFFER 0 <LENGTH .BUFFER> .NB>
		     <SET BUFFER .NB>
		     <AGAIN>)>
	      <SET TOT 0>
	      <SETG LAST-CHAR <NTH .BUFFER .CT>>
	      <COND (<G? .CT 1>
		     <SET FOO <LPARSE <SUBSTRUC .BUFFER 0 <- .CT 1>
						<REST .BUFFER <- <LENGTH .BUFFER>
								 .CT -1>>>>>)
		    (<SET FOO ()>)>
	      <COND (<NOT <TYPE? .FOO LIST>>
		     <SET TOT .CT>
		     <AGAIN>)>
	      <SET PARSE-LIST .FOO>
	      <COND (<==? ,LAST-CHAR <ASCII 27>>
		     <CRLF>
		     <MAPF <>
			   <FUNCTION (X)
				<PRIN1 <SET LAST-OUT <EVAL .X>>>
				<CRLF>>
			   .PARSE-LIST>
		     <AGAIN>)
		    (T
		     <CHANNEL-OP .OUTCHAN HOR-POS-CURSOR
				 <- <CHANNEL-OP .OUTCHAN PAGE-X> 2>>
		     <CHANNEL-OP .OUTCHAN CLEAR-EOL>
		     <COND
		      (<EMPTY? .PARSE-LIST>
		       <SETG REPEAT-COUNT 1>
		       <RETURN FOO>)
		      (<AND <LENGTH? .PARSE-LIST 1>
			    <TYPE? <1 .PARSE-LIST> FIX>>
		       <SETG REPEAT-COUNT <1 .PARSE-LIST>>
		       <RETURN FOO>)
		      (<==? ,LAST-CHAR ,PRED-CHAR>
		       <COND (<LENGTH? .PARSE-LIST 1>
			      <SETG PREDICATE <1 .PARSE-LIST>>
			      <SETG REPEAT-COUNT 1>
			      <RETURN FOO>)
			     (<AND <LENGTH? .PARSE-LIST 2>
				   <TYPE? <1 .PARSE-LIST> FIX>>
			      <SETG REPEAT-COUNT <1 .PARSE-LIST>>
			      <SETG PREDICATE <2 .PARSE-LIST>>
			      <RETURN FOO>)
			     (ELSE
			      <PRINC "Too many arguments: ">
			      <PRIN1 .PARSE-LIST>
			      <PRINC  " try again">
			      <CRLF>
			      <AGAIN>)>)
		      (ELSE <PRINC "Unknown command: ">
		       <PRINC ,LAST-CHAR>
		       <PRINC " try again">
		       <CRLF>
		       <AGAIN>)>)>>>

;"Just a kluge procedure which should be replaced"

<DEFINE FRAME-COUNT (FRM)     ;"Counts eval frames until listen"
	#DECL ((FRM) FRAME (VALUE) FIX)
	<REPEAT ((I 0))
		#DECL ((VALUE I) FIX)
		<COND (<==? <FUNCT .FRM> LISTEN>
		       <RETURN .I>)
		      (<==? <FUNCT .FRM> EVAL> 
		       <SET I <+ .I 1>>)>
		<SET FRM <FRAME .FRM>>>>


;"== INITIALIZATION =========================================================="

<SETG INDENT-INC 2>
<SETG INDENT-MOD 10>
<SETG INDENT-DIF 20>
<SETG SELF-FAST T>
<SETG FORM-FAST T>
<SETG OUT-FAST T>
<SETG OUT-UNIQUE T>

<DEFINE INITIALIZE ()
	<SETG DEB-LEVEL 0>
	<SETG INFO '[0 '()]>
	<SETG LO LO>
	<SETG DEB-OUT DEB-OUT>
	<SETG DEB-IN DEB-IN>
	<SETG DEBSTATE 0>
	<SETG PREDICATE T>
	<SETG MACRO-FLAG <>>
	<SETG MACRO-LEVEL -1>
	<SETG LAST-CHAR !\ >
	<SETG REPEAT-COUNT 0>
	<SETG INFULL? T>>

<ENDPACKAGE>
