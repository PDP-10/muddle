<PACKAGE "INT">

<RENTRY CLASS ENABLE ENABLED? DISABLE ON ON? OFF HANDLER QUITTER
	STOPPER INT-LEVEL INTERRUPT INTON DISMISS EMERGENCY
	INTERRUPT-HANDLER>

<NEWTYPE DISMISS ATOM>

<NEWTYPE CLASS
	 VECTOR
	 '<<PRIMTYPE VECTOR> STRING
			     <OR ATOM FALSE>
			     <OR HANDLER FALSE>
			     <OR FIX FALSE>
			     FIX
			     <OR ATOM FALSE>>>

<NEWTYPE HANDLER
	 VECTOR
	 '<<PRIMTYPE VECTOR> CLASS
			     <OR APPLICABLE FUNCTION>
			     FIX
			     ANY
			     <OR FALSE HANDLER>>>

<DEFINE CLASS (CNAM "OPTIONAL" (PRI <>) (CREATE? <>) (CHAN <>)
	       (NO-DEFER? <>) "AUX" CATM C)
	#DECL ((CNAM) STRING (CATM CREATE?) <OR FALSE ATOM> (C) ANY
	       (PRI CHAN) <OR FIX FALSE>)
	<COND (<AND <SET CATM <LOOKUP .CNAM <INTERRUPTS>>>
		    <GASSIGNED? .CATM>
		    <TYPE? <SET C <GVAL .CATM>> CLASS>>
	       <COND (<NOT <M$$C-CHANNEL .C>>
		      <M$$C-CHANNEL .C .CHAN>)>
	       <COND (.PRI <M$$C-PRIORITY .C .PRI>)>
	       .C)
	      (.CREATE?
	       <COND (<NOT .PRI> <SET PRI 1>)>
	       <SETG <OR <LOOKUP .CNAM <INTERRUPTS>>
			 <INSERT .CNAM <INTERRUPTS>>>
		     <CHTYPE [.CNAM T <> .CHAN .PRI .NO-DEFER?] CLASS>>)>>

<DEFINE ENABLE (CNAM "OPTIONAL" (ENA? T) "AUX" C)
	#DECL ((CNAM) STRING (ENA?) <OR ATOM FALSE> (C) <OR FALSE CLASS>)
	<COND (<SET C <CLASS .CNAM>>
	       <M$$C-ENABLE .C .ENA?>)>>

<DEFINE DISABLE (CNAM)
	#DECL ((CNAM) STRING)
	<ENABLE .CNAM <>>>

<DEFINE ENABLED? (CNAM "AUX" C)
	#DECL ((CNAM) STRING (C) <OR FALSE CLASS>)
	<COND (<SET C <CLASS .CNAM>>
	       <M$$C-ENABLE .C>)>>

<DEFINE ON (HAND "AUX" C H HP ATM)
	#DECL ((HAND) <OR CLASS HANDLER> (C) CLASS (H) <OR FALSE HANDLER>
	       (HP) FIX)
	<COND (<TYPE? .HAND HANDLER>
	       <SET C <M$$H-CLASS .HAND>>
	       <SET H <M$$C-HANDLER .C>>
	       <SET HP <M$$H-PRIORITY .HAND>>
	       <COND (<N==? .C ,M$$EVALCLASS!-INTERNAL>
		      <M$$C-ENABLE .C T>)>
	       <COND (<ON? .HAND> .HAND)
		     (<OR <NOT .H>
			  <G? .HP <M$$H-PRIORITY .H>>>
		      <M$$H-NEXT .HAND .H>
		      <M$$C-HANDLER .C .HAND>
		      .HAND)
		     (T
		      <REPEAT (OH)
			      #DECL ((OH) HANDLER)
			      <COND (<OR <NOT .H>
					 <G? .HP <M$$H-PRIORITY .H>>>
				     <M$$H-NEXT .OH .HAND>
				     <M$$H-NEXT .HAND .H>
				     <RETURN .HAND>)
				    (T
				     <SET OH .H>
				     <SET H <M$$H-NEXT .H>>)>>)>)
	      (T
	       <SET ATM <OR <LOOKUP <M$$C-NAME .HAND> <INTERRUPTS>>
			    <INSERT <M$$C-NAME .HAND> <INTERRUPTS>>>>
	       <COND (<NOT <GASSIGNED? .ATM>>
		      <SETG .ATM .HAND>
		      <COND (<M$$C-CHANNEL .HAND>
			     <PUT ,M$$INT-CLASSES:VECTOR <M$$C-CHANNEL .HAND>
				  .HAND>)>
		      .HAND)
		     (<N==? ,.ATM .HAND>
		      <ERROR CLASS ALREADY-EXISTS!-ERRORS .ATM .HAND
			     ON>)>)>>

<DEFINE OFF (HAND "AUX" C H CC)
	#DECL ((HAND) <OR CLASS STRING CHARACTER HANDLER>
	       (C) CLASS (H) <OR FALSE HANDLER>)
	<COND (<TYPE? .HAND HANDLER>
	       <SET C <M$$H-CLASS .HAND>>
	       <SET H <M$$C-HANDLER .C>>
	       <COND (<==? .H .HAND>
		      <M$$C-HANDLER .C <M$$H-NEXT <CHTYPE .H HANDLER>>>
		      T)
		     (T
		      <REPEAT ((H .H) LH)
		        #DECL ((H) <OR FALSE HANDLER> (LH) HANDLER)
			<COND (<NOT .H> <RETURN <>>)
			      (<==? .H .HAND>
			       <M$$H-NEXT .LH <M$$H-NEXT .H>>
			       <RETURN T>)
			      (T
			       <SET LH .H>
			       <SET H <M$$H-NEXT .H>>)>>)>)
	      (T
	       <COND (<TYPE? .HAND CHARACTER>
		      <SET HAND <STRING .HAND>>)>
	       <COND (<OR <AND <TYPE? .HAND CLASS>
			       <SET CC .HAND>
			       <SET CC <CLASS <M$$C-NAME .CC>>>>
			  <SET CC <CLASS .HAND>>>
		      <PROG (V)
		        #DECL ((V) <OR VECTOR FALSE>)
			<COND (<SET V <MEMQ .CC ,M$$INT-CLASSES:VECTOR>>
			       <1 .V <>>
			       <AGAIN>)>>
		      <GUNASSIGN <LOOKUP <M$$C-NAME .CC> <INTERRUPTS>>>
		      .CC)>)>>

<DEFINE ON? (HAND)
	#DECL ((HAND) <OR CLASS HANDLER>)
	<COND (<TYPE? .HAND CLASS>
	       <CLASS <M$$C-NAME .HAND>>)
	      (T
	       <REPEAT ((H <M$$C-HANDLER <M$$H-CLASS .HAND>>))
		 #DECL ((H) <OR FALSE HANDLER>)
		 <COND (<NOT .H> <RETURN <>>)
		       (<==? .H .HAND> <RETURN T>)
		       (T <SET H <M$$H-NEXT .H>>)>>)>>

%%<PROG ()
    <SETG M$$INFINT 19>
    <SETG M$$CONTINT 35>
    <SETG M$$PIPEINT 34>
    <SETG M$$URGINT 33>
    <SETG M$$IOINT 32>
    <SETG M$$STKINT 31>
    <MANIFEST M$$INFINT M$$CONTINT M$$PIPEINT M$$URGINT M$$IOINT M$$STKINT>>

<DEFINE HANDLER (CNAM APP "OPTIONAL" (LEV 0) (ARG <>) "AUX" C)
	#DECL ((CNAM) <OR STRING CHARACTER> (APP) APPLICABLE
	       (LEV) FIX (ARG) ANY)
	<COND (<TYPE? .CNAM CHARACTER>
	       <PUT ,M$$INT-CLASSES:VECTOR
		    <SET C <CALL ATIC .CNAM>>
		    <CLASS <SET CNAM <STRING .CNAM>> <> T .C>>)
	      (<=? .CNAM "INFERIOR">
	       <PUT ,M$$INT-CLASSES:VECTOR ,M$$INFINT
		    <CLASS .CNAM <> T ,M$$INFINT>>)
	      (T
	       <IFSYS ("UNIX"
		       <COND (<=? .CNAM "CONTINUE">
			      <PUT ,M$$INT-CLASSES:VECTOR ,M$$CONTINT
				   <CLASS .CNAM <> T ,M$$CONTINT>>)
			     (<=? .CNAM "PIPE">
			      <PUT ,M$$INT-CLASSES:VECTOR ,M$$PIPEINT
				   <CLASS .CNAM <> T ,M$$PIPEINT>>)
			     (<=? .CNAM "SOCKET">
			      ; "SIGURG"
			      <M$$URGINT ,M$$INT-CLASSES:VECTOR
					 <CLASS .CNAM <> T ,M$$URGINT>>)
			     (<=? .CNAM "IOINT">
			      <M$$IOINT ,M$$INT-CLASSES:VECTOR
					<CLASS .CNAM <> T ,M$$IOINT>>)
			     (<=? .CNAM "STKINT">
			      <M$$STKINT ,M$$INT-CLASSES:VECTOR
					 <CLASS .CNAM <> <> ,M$$STKINT>>)>)>)>
	<CHTYPE [<CLASS .CNAM <> T> .APP .LEV .ARG <>] HANDLER>>

<DEFINE NI$INTERRUPT II (CNUM "TUPLE" TUP
		          "AUX" (OLEV ,M$$INT-LEVEL)
			        C LEV (LV T) (NO-DEFER? <>) TC)
	 #DECL ((CNUM) <OR FIX CLASS VECTOR> (TUP) TUPLE (C) CLASS
		(LEV OLEV) FIX
		(LV) ANY)
	 <COND (<TYPE? .CNUM FIX>
		<COND (<SET TC <NTH ,M$$INT-CLASSES:VECTOR .CNUM>>
		       <SET C .TC>)
		      (T <RETURN <> .II>)>)
	       (<TYPE? .CNUM VECTOR>
		<SET C <CHTYPE .CNUM CLASS>>
		<SET NO-DEFER? T>)
	       (T <SET C .CNUM>)>
	 <COND (<6 .C>
		<SET NO-DEFER? T>)>
	 <COND (<M$$C-ENABLE .C>
		<COND (<L=? <M$$C-PRIORITY .C> .OLEV>
		       <COND (.NO-DEFER?
			      <REAL-ERROR
			       ATTEMPT-TO-DEFER-UNDEFERABLE-INTERRUPT!-ERRORS
			       .C
			       INTERRUPT>)
			     (<N==? .C ,M$$EVALCLASS!-INTERNAL>
			      ; "Not very useful to queue eval interrupts"
			      <PROG ((Q ,M$$INT-QUEUE)
				     (P <M$$C-PRIORITY .C>) TL)
			        #DECL ((Q) LIST (P) FIX
				       (TL) <OR FALSE <LIST FIX [2 LIST]>>)
				; "Maintain a separate queue for each
				   interrupt level."
				<COND (<SET TL <MEMQ .P .Q>>
				       <2 .TL <REST <PUTREST <2 .TL>
							     ((.C !.TUP))>>>)
				      (T
				       <REPEAT ((OL <REST .Q>)
						(NL (T (.C !.TUP))))
				         #DECL ((OL) <LIST [REST FIX LIST LIST]>
						(NL) LIST)
					 <COND (<OR <EMPTY? .OL> <L? <1 .OL> .P>>
						<PUTREST .Q
						  (.P <REST .NL> .NL !.OL)>
						<RETURN>)
					       (<==? <1 .OL> .P>
						<2 .OL
						   <REST <PUTREST <2 .OL>
								  ((.C !.TUP))>>>
						<RETURN>)>
					 <SET Q <REST .Q 3>>
					 <SET OL <REST .OL 3>>>)>>)>)
		      (T
		       <COND (<==? .C ,M$$EVALCLASS!-INTERNAL>
			      <COND (<AND <ASSIGNED? GC-RUNNING!- >
					  .GC-RUNNING!- >
				     ; "Don't run eval interrupts in GC"
				     <RETURN <> .II>)>
			      <M$$C-ENABLE .C <>>)>
		       <UNWIND
			<PROG ()
			  <SET LV <RUN-INTERRUPT .C .OLEV !.TUP>>
			  <COND (<==? .C ,M$$EVALCLASS!-INTERNAL>
				 <M$$C-ENABLE .C T>)
				(<SET LV T>)>
			  .LV>
			<PROG ()
			  <COND (<==? .C ,M$$EVALCLASS!-INTERNAL>
				 <M$$C-ENABLE .C T>)>>>)>)>>

<DEFINE EMERGENCY (CNAM "TUPLE" TUP "AUX" C)
	#DECL ((CNAM) STRING (TUP) TUPLE (C) <OR FALSE CLASS>)
	<COND (<SET C <CLASS .CNAM>>
	       <I$INTERRUPT <CHTYPE .C VECTOR> !.TUP>)>>

<DEFINE INTERRUPT (CNAM "TUPLE" TUP "AUX" C)
	#DECL ((CNAM) STRING (TUP) TUPLE (C) <OR FALSE CLASS>)
	<COND (<SET C <CLASS .CNAM>>
	       <I$INTERRUPT .C !.TUP>)>>

; "How interrupts are handled:
I$INTERRUPT compares the priority of the class it's called with to
M$$INT-LEVEL.  If the interrupt cannot be run immediately, either it is
queued (from interrupt), or REAL-ERROR is called (from emergency).
If the interrupt can be run, RUN-INTERRUPT is called.  It raises
the interrupt level to the class's priority, and wanders down its
chain of handlers, applying each in turn.  Finally, <INT-LEVEL .OLEV>
is called, lowering the interrupt level.
When INT-LEVEL is called to lower the interrupt level, it wanders
down M$$INT-QUEUE processing (via RUN-INTERRUPT) those queued interrupts
that can now be handled.  Since RUN-INTERRUPT calls INT-LEVEL, this will
mostly happen recursively."

<DEFINE RUN-INTERRUPT (C INTENDED-LEVEL "TUPLE" ARGS "AUX" (OLEV ,M$$INT-LEVEL) H
		       (INT-LEVEL? <>))
  #DECL ((C) CLASS (OLEV) FIX (INTENDED-LEVEL) <SPECIAL FIX>)
  <COND (<SET H <M$$C-HANDLER .C>>
	 <COND (<G? <M$$C-PRIORITY .C> .OLEV>
		<SET INT-LEVEL? T>
		<INT-LEVEL <M$$C-PRIORITY .C>>)>
	 <REPEAT LINT (LV)
	   #DECL ((LINT) <SPECIAL FRAME>)
	   <SET LV <APPLY <M$$H-FUNCTION .H>
			  <M$$H-ARG .H>
			  !.ARGS>>
	   <COND (<OR <TYPE? .LV DISMISS> <NOT <SET H <M$$H-NEXT .H>>>>
		  <COND (.INT-LEVEL? <INT-LEVEL .OLEV>)>
		  <RETURN <COND (<TYPE? .LV DISMISS> T)(T .LV)>>)>>)>>

<DEFINE INT-LEVEL ("OPTIONAL" LEV "AUX" (OLEV ,M$$INT-LEVEL))
	#DECL ((LEV OLEV) FIX)
	<COND (<AND <ASSIGNED? LEV> <L? .LEV .OLEV>>
	       <REPEAT (MAIN-QUEUE RUN-QUEUE
			NLEV IL C LEV-QUEUE LEV-RUN-QUEUE)
		       #DECL ((RUN-QUEUE) <LIST [REST FIX LIST LIST]>
			      (IL) <LIST CLASS>
			      (C) CLASS (NLEV) FIX (MAIN-QUEUE) LIST)
		       <SET MAIN-QUEUE ,M$$INT-QUEUE>
		       <SET RUN-QUEUE <REST .MAIN-QUEUE>>
		       <COND (<EMPTY? .RUN-QUEUE> <RETURN>)>
		       <COND (<G=? .LEV <1 .RUN-QUEUE>>
			      ; "No interrupts with enough priority"
			      <RETURN>)>
		       <SET LEV-QUEUE <3 .RUN-QUEUE>>
		       <SET LEV-RUN-QUEUE <REST .LEV-QUEUE>>
		       <COND (<EMPTY? .LEV-RUN-QUEUE>
			      ; "No more queued interrupts at this level"
			      <PUTREST .MAIN-QUEUE <REST .RUN-QUEUE 3>>
			      ; "Try it again"
			      <AGAIN>)>
		       <SET C <1 <SET IL <1 .LEV-RUN-QUEUE>>>>
		       <COND (<==? <2 .RUN-QUEUE> .LEV-RUN-QUEUE>
			      ; "Running last thing on this queue, so 
				 make sure pointer doesn't get dropped"
			      <2 .RUN-QUEUE <3 .RUN-QUEUE>>)>
		       ; "Splice this interrupt out"
		       <PUTREST .LEV-QUEUE <REST .LEV-RUN-QUEUE>>
		       <RUN-INTERRUPT .C .LEV !<REST .IL>>>
	       <SETG M$$INT-LEVEL .LEV>)
	      (<ASSIGNED? LEV>
	       <SETG M$$INT-LEVEL .LEV>)>
	.OLEV>
			      
<DEFINE DISMISS (VAL "OPTIONAL" ACT LEV)
	#DECL ((VAL) ANY (ACT) FRAME (LEV) FIX)
	<COND (<ASSIGNED? LEV>
	       <INT-LEVEL .LEV>)
	      (<ASSIGNED? INTENDED-LEVEL>
	       <INT-LEVEL .INTENDED-LEVEL>)>
	<COND (<NOT <ASSIGNED? ACT>>
	       <COND (<NOT <ASSIGNED? LINT>>
		      <RETURN .VAL .LPROG!-INTERRUPTS>)
		     (<SET ACT .LINT>)>)>
	<RETURN .VAL .ACT>>
		      
<DEFINE QUITTER (ARG)
	<INT-LEVEL 0>
	<RESET ,OUTCHAN>
	<ERROR CONTROL-G!-ERRORS>>

<DEFINE STOPPER (ARG)
	<INT-LEVEL 0>
	<RESET ,OUTCHAN>
	<AGAIN .LERR!-INTERRUPTS>>

<DEFINE STACK-OVERFLOW (ARG "AUX" VAL)
	<IFSYS
	 ("UNIX"
	  <INT-LEVEL 0>
	  <RESET ,OUTCHAN>
	  <COND (<1? <CHTYPE <CALL BIGSTACK 0> FIX>>
		 ; "Will return 1 if stack is already big"
		 <REAL-ERROR STACK-AT-LIMIT!-ERRORS
			     INTERRUPT-HANDLER 
			     ERRET-T-TO-FATAL!-ERRORS>)
		(<SET VAL <REAL-ERROR STACK-OVERFLOW!-ERRORS 
				      INTERRUPT-HANDLER
				      ERRET-T-TO-CONTINUE!-ERRORS>>
		 ; "Say let stack become big"
		 <CALL BIGSTACK 1>)>)>
	T>

<DEFINE INTON ("AUX" NM)
	<NEWTYPE CLASS VECTOR>
	<NEWTYPE HANDLER VECTOR>
	<CALL SETS ICALL 'I$INTERRUPT>
	<SETG M$$INT-QUEUE (T)>
	<SETG M$$INT-QUEUE-R ,M$$INT-QUEUE>
	<SETG M$$INT-LEVEL 0>
	<SETG M$$INT-CLASSES
	      [<> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <>
	       <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <> <>]>
	<SETG M$$EVALCLASS!-INTERNAL <M$$H-CLASS <HANDLER "EVAL" ,TIME 1>>>
	<DISABLE "EVAL">
	<COND (<SET NM <LOOKUP <STRING <ASCII 7>> <INTERRUPTS>>>
	       <GUNASSIGN .NM>
	       <REMOVE .NM>)>
	<COND (<SET NM <LOOKUP <STRING <ASCII 1>> <INTERRUPTS>>>
	       <GUNASSIGN .NM>
	       <REMOVE .NM>)>
	<CLASS <STRING <ASCII 7>> 6 T>
	<CLASS <STRING <ASCII 1>> 5 T>
	<IFSYS ("UNIX"
		<CLASS "STKINT" 1000 T ,M$$STKINT T>
		<ON <HANDLER "STKINT" ,STACK-OVERFLOW>>)>
	<ON <HANDLER <ASCII 7> ,QUITTER>>
	<ON <HANDLER <ASCII 1> ,STOPPER>>
	T>

<DEFINE PRINT-HANDLER (HAND "AUX" (OUTCHAN .OUTCHAN))
  #DECL ((HAND) HANDLER (OUTCHAN) CHANNEL)
  <PRINC "#HANDLER [" .OUTCHAN>
  <PRINC <M$$C-NAME <M$$H-CLASS .HAND>> .OUTCHAN>
  <COND (<NOT <ON? <M$$H-CLASS .HAND>>>
	 <PRINC ":OFF" .OUTCHAN>)>
  <PRINC !\  .OUTCHAN>
  <COND (<NOT <ON? .HAND>>
	 <PRINC "OFF " .OUTCHAN>)>
  <PRINC <M$$H-PRIORITY .HAND> .OUTCHAN>
  <PRINC !\  .OUTCHAN>
  <PRINC <M$$H-ARG .HAND> .OUTCHAN>
  <PRINC !\  .OUTCHAN>
  <PRINC <M$$H-FUNCTION .OUTCHAN> .OUTCHAN>
  <PRINC !\] .OUTCHAN>>

<DEFINE PRINT-CLASS (CLASS "AUX" (OUTCHAN .OUTCHAN))
  #DECL ((CLASS) CLASS (OUTCHAN) CHANNEL)
  <PRINC "#CLASS [" .OUTCHAN>
  <PRINC <M$$C-NAME .CLASS> .OUTCHAN>
  <PRINC !\  .OUTCHAN>
  <COND (<NOT <ON? .CLASS>>
	 <PRINC "OFF " .OUTCHAN>)>
  <COND (<NOT <M$$C-ENABLE .CLASS>>
	 <PRINC "DISABLED " .OUTCHAN>)>
  <COND (<M$$C-HANDLER .CLASS>
	 <PRINC "#HANDLER [&] " .OUTCHAN>)
	(<PRINC "<> " .OUTCHAN>)>
  <PRINC <M$$C-CHANNEL .CLASS> .OUTCHAN>
  <PRINC !\  .OUTCHAN>
  <PRINC <M$$C-PRIORITY .CLASS> .OUTCHAN>
  <PRINC !\] .OUTCHAN>>

<COND (<GASSIGNED? PRINT-HANDLER>
       <PRINTTYPE HANDLER ,PRINT-HANDLER>
       <PRINTTYPE CLASS ,PRINT-CLASS>)>

<ENDPACKAGE>
