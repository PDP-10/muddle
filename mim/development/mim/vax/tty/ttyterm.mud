"Interpreted output routines--used for echoing and NORMAL-OUT."

<SETG TABS <ISTRING 8>>
<GDECL (TABS) STRING>

<DEFINE TTY-NORMAL-OUT (CHANNEL OPER CHRS
			"OPTIONAL" (LENGTH <>)
			"AUX" (TC <CHANNEL-DATA .CHANNEL>) (TTY <TC-TTY .TC>)
			      (TD <TT-DESC .TTY>))
  #DECL ((CHANNEL) CHANNEL (CHRS) <OR STRING CHARACTER> (LENGTH) <OR FIX FALSE>
	 (TC) TTY-CHANNEL (TTY) TTY (TD) TTY-DESC)
  <COND (<TEST-TC-MODE .TC ,TM-BADPOS>
	 ; "If we don't know where the cursor is, go to top of screen"
	 <HOME-CURSOR .CHANNEL .OPER>
	 <CLEAR-EOL .CHANNEL .OPER>)>
  <COND (<TYPE? .CHRS CHARACTER>
	 <SET CHRS <1 <CHTYPE ,BUF1 STRING> .CHRS>>
	 <SET LENGTH 1>)
	(<NOT .LENGTH>
	 <SET LENGTH <LENGTH .CHRS>>)
	(<SET LENGTH <MIN .LENGTH <LENGTH .CHRS>>>)>
  <COND (<G? .LENGTH 0>
	 <REPEAT ((CT 0) CHR (LASTCHR <ASCII 0>))
	   #DECL ((CT) FIX (LASTCHR CHR) CHARACTER)
	   <SET CHR <CHTYPE <ANDB <1 .CHRS> *177*> CHARACTER>>
	   <SET CHRS <REST .CHRS>>
	   <SET CT <+ .CT 1>>
	   <COND (<NOT <OR <L? <ASCII .CHR> 32>
			   <==? <ASCII .CHR> 127>>>
		  ; "Normal character"
		  <DO-CHAR .CHANNEL .TC .TTY .TD .CHR>)
		 (<==? .CHR <ASCII 27> ;"Char Alt">
		  <DO-CHAR .CHANNEL .TC .TTY .TD !\$>)
		 (<==? .CHR <ASCII 13> ;"Char C.R.">
		  <OUTPUT-RAW-STRING .CHANNEL .CHR>
		  <TT-X .TTY 0>
		  <COND (<G? <TD-CRPAD .TD> 0>
			 <OUTPUT-PAD .CHANNEL .TD <TD-CRPAD .TD>>)>)
		 (<==? .CHR <ASCII 10> ;"Char L.F.">
		  <COND (<N==? .LASTCHR <ASCII 13> ;"Char C.R.">
			 <OUTPUT-RAW-STRING .CHANNEL <ASCII 13> ;"Char C.R.">
			 <TT-X .TTY 0>
			 <COND (<G? <TD-CRPAD .TD> 0>
				<OUTPUT-PAD .CHANNEL .TD <TD-CRPAD .TD>>)>)>
		  <DO-LF .CHANNEL .TC .TTY .TD>)
		 (<==? .CHR <ASCII 9> ;"Char Tab">
		  <PROG ((X <TT-X .TTY>) (LEN <- 8 <MOD .X 8>>))
		    <COND (<G? <SET X <+ .X .LEN>> <- <TD-WIDTH .TD> 1>>
			   <DO-CHAR .CHANNEL .TC .TTY .TD
			     !<REST ,TABS <- 8 .LEN>>>)
			  (T
			   <TT-X .TTY .X>
			   <OUTPUT-RAW-STRING .CHANNEL .CHR>)>>)
		 (<==? .CHR <ASCII 7> ;"Char Bell">
		  ; "Ring bell, don't move cursor"
		  <OUTPUT-RAW-STRING .CHANNEL .CHR>)
		 (<N==? .CHR <ASCII 127> ;"Char ">
		  ; "Rubout is normally invisible, so ,NULL will work."
		  <DO-CHAR .CHANNEL .TC .TTY .TD !\^
			   <ASCII <ANDB <+ <ASCII .CHR> %<- <ASCII !\A> 1>>
					*177*>>>)>
	   <SET LASTCHR .CHR>
	   <COND (<G=? .CT .LENGTH>
		  <RETURN .CT>)>>)
	(.LENGTH)>>

; "Called with a tuple of chars to be dumped.  Handles ! stuff, including
   invocation of LF.  Chars seen here need no special handlng."
<DEFINE DO-CHAR (CHANNEL TC TTY TD "TUPLE" CHARS "AUX" (X <TT-X .TTY>)
		 (WIDTH <- <TD-WIDTH .TD> 1>))
  #DECL ((CHANNEL) CHANNEL (TC) TTY-CHANNEL (TTY) TTY (TD) TTY-DESC
	 (CHARS) <TUPLE [REST CHARACTER]> (X WIDTH) FIX)
  <MAPF <>
    <FUNCTION (CHR)
      #DECL ((CHR) CHARACTER)
      <COND (<G? <SET X <+ .X 1>> .WIDTH>
	     ; "Line overflow"
	     <OUTPUT-RAW-STRING .CHANNEL !\!>
	     ; "Stuff out a CR"
	     <TTY-NORMAL-OUT .CHANNEL NORMAL-OUT <ASCII 13> ;"Char C.R.">
	     <SET X 1>
	     ; "Go to next line -- may provoke --More-- and friends"
	     <DO-LF .CHANNEL .TC .TTY .TD>)>
      <TT-X .TTY .X>
      <OUTPUT-RAW-STRING .CHANNEL .CHR>>
    .CHARS>>

<DEFINE TTY-MORE-LIMIT (CHANNEL OPER "OPTIONAL" NEW
			"AUX" (TC <CHANNEL-DATA .CHANNEL>) (TTY <TC-TTY .TC>))
  #DECL ((CHANNEL) CHANNEL (TC) TTY-CHANNEL (TTY) TTY (NEW) <OR FIX FALSE>)
  <COND (<NOT <ASSIGNED? NEW>>
	 <TT-MORE-LINES .TTY>)
	(T
	 <TT-MORE-LINES .TTY .NEW>)>>

<SETG MORE-TYPE-LIMIT 5>
<GDECL (MORE-TYPE-LIMIT) FIX>
<DEFINE DO-LF (CHANNEL TC TTY TD "AUX" (LIN <TT-LAST-IN .TTY>)
	       (Y <TT-Y .TTY>) (HEIGHT <TD-HEIGHT .TD>) (MODE <TC-MODE .TC>)
	       (MORE? <>) (MORE-LINES <COND (<NOT <TT-MORE-LINES .TTY>>
					     -1)
					    (T
					     <MIN <- .HEIGHT 2>
						  <TT-MORE-LINES .TTY>>)>))
  #DECL ((CHANNEL) CHANNEL (TC) TTY-CHANNEL (TTY) TTY (TD) TTY-DESC
	 (Y LIN HEIGHT MODE) FIX (MORE?) <OR ATOM FALSE>)
  <COND (<AND <TEST-MODE .MODE ,TM-PAGE>
	      <COND (<NOT <TEST-MODE .MODE ,TM-WRAP>>
		     <COND (<TEST-MODE .MODE ,TM-ITS>
			    <AND <G=? <TT-LAST-MORE .TTY> <- .HEIGHT 1>>
				 <G? <- .HEIGHT .LIN> .MORE-LINES>>)
			   (T
			    <==? <+ .LIN 1> .HEIGHT>)>)
		    (<AND <TEST-MODE .MODE ,TM-WRAP>
			  <NOT <TEST-MODE .MODE ,TM-ITS>>>
		     <==? .Y <- .HEIGHT 1>>)
		    (T
		     <AND <==? .Y <- .HEIGHT 2>>
			  <G? <- .HEIGHT .LIN>
				  .MORE-LINES>>)>>
	 ; "Need a more"
	 <SET MORE? <DO-MORE .CHANNEL .TC .TTY .TD>>)>
  <COND (<NOT .MORE?>
	 <COND (<NOT <TEST-MODE .MODE ,TM-WRAP>>
		; "Not a more, but scrolling"
		<TT-LAST-IN .TTY <MOD <+ .LIN 1> .HEIGHT>>
		; "Update last in, to trigger halt at screen bottom"
		<TT-LAST-MORE .TTY <+ <TT-LAST-MORE .TTY> 1>>
		<TT-Y .TTY <MIN <+ .Y 1> <- .HEIGHT 1>>>
		<OUTPUT-RAW-STRING .CHANNEL <ASCII 10>>
		; "Pad only if scrolling"
		<COND (<==? <TT-Y .TTY> <- .HEIGHT 1>>
		       <OUTPUT-PAD .CHANNEL .TD <TD-LFPAD .TD>>)>)
	       (T
		; "Down cursor wraps if at bottom"
		<DOWN-CURSOR .CHANNEL NORMAL-OUT>
		<CLEAR-EOL .CHANNEL NORMAL-OUT>)>)>>

<DEFINE DO-MORE (CHANNEL TC TTY TD "AUX" ICHR (MODE <TC-MODE .TC>))
  #DECL ((CHANNEL) CHANNEL (TC) TTY-CHANNEL (TTY) TTY (TD) TTY-DESC
	 (MODE) FIX (ICHR) CHARACTER)
  <TT-LAST-MORE .TTY 0>
  <COND (<TEST-MODE .MODE ,TM-ITS>
	 <BOTTOM-CURSOR .CHANNEL NORMAL-OUT>
	 <CLEAR-EOL .CHANNEL NORMAL-OUT>
	 <TTY-NORMAL-OUT .CHANNEL NORMAL-OUT "**More**">)
	(<OUTPUT-RAW-STRING .CHANNEL <ASCII 7>>)>
  <DUMP-WRITE-BUFFER .TC>
  <COND (<TEST-MODE .MODE ,TM-ITS>
	 <READ-UNTIL .CHANNEL <> T %<STRING <ASCII 32> ;"Char Space"
					    <ASCII 127> ;"Char ">>)
	(T
	 <READ-UNTIL .CHANNEL <ASCII 17> ;"Char Cntl-Q"
		     <> %<STRING <ASCII 17> ;"Char Cntl-Q"
				 <ASCII 19> ;"Char Cntl-S">>)>
  <COND (<TEST-MODE .MODE ,TM-WRAP>
         <HOR-POS-CURSOR .CHANNEL NORMAL-OUT 0>
	 <>)>>

<DEFINE READ-UNTIL (CHANNEL RETURNS CHECK-QUEUE? DONT 
		    "AUX" (TC <CHANNEL-DATA .CHANNEL>) (OM <TC-MODE .TC>)
			  CHR Q)
  #DECL ((CHANNEL) CHANNEL (TC) TTY-CHANNEL
	 (RETURNS) <OR FALSE CHARACTER STRING> (CHECK-QUEUE?) <OR ATOM FALSE>
	 (DONT Q) <OR CHARACTER STRING FALSE>)
  <UNWIND
   <PROG ()
     <TC-MODE .TC <ANDB .OM %<XORB ,TM-ECHO -1>>>
     <COND (<AND .CHECK-QUEUE?
		 <NOT <0? <TC-QCT .TC>>>>
	    <COND (.DONT
		   <COND (<NOT <TYPE? <SET Q <TC-QUEUE .TC>> CHARACTER>>
			  <SET Q <1 .Q>>)>
		   <COND (<COND (<TYPE? .DONT CHARACTER>
				 <==? .Q .DONT>)
				(<MEMQ .Q .DONT>)>
			  <SET CHR <GET-QUEUE-CHAR .TC>>)>)>)
	   (T
	    <REPEAT ()
	      <SET CHR <TTY-READ-IMMEDIATE .CHANNEL READ-IMMEDIATE <> <>>>
	      <COND (.DONT
		     <COND (<NOT <COND (<TYPE? .DONT CHARACTER>
					<==? .DONT .CHR>)
				       (<MEMQ .CHR .DONT>)>>
			    <STORE-QUEUE-CHAR .TC .CHR>)>)>
	      <COND (<OR <NOT .RETURNS>
			 <AND <TYPE? .RETURNS CHARACTER>
			      <==? .CHR .RETURNS>>
			 <MEMQ .CHR .RETURNS>>
		     <RETURN>)>>)>
     <TC-MODE .TC .OM>
     .CHR>
   <TC-MODE .TC .OM>>>


"Buffered input routines"

<MSETG BUF-START 1>
<MSETG BUF-CURRENT 2>
<MSETG BUF-AVAIL 3>
<MSETG BUF-TOT 4>
<MSETG BUF-X 5>
<MSETG BUF-Y 6>
<MSETG BUF-CONT 7>

<DEFINE UPDATE-INPUT (TTY MODE)
  #DECL ((TTY) TTY (MODE) FIX)
  <COND (<NOT <TEST-MODE .MODE ,TM-WRAP>>
	 ; "Scroll mode"
	 <COND (<NOT <TEST-MODE .MODE ,TM-ITS>>
		; "Normal mode"
		<TT-LAST-IN .TTY 0>)
	       (T	; "ITS mode"
		<TT-LAST-IN .TTY <TT-LAST-MORE .TTY>>)>)
	(T
	 ; "Wrap mode"
	 <TT-LAST-IN .TTY <TT-Y .TTY>>)>>

<DEFINE DO-RDTTY (CHANNEL TC BUF CONT END PROMPT "AUX" TOT AVAIL CBUF
		  (MODE <TC-MODE .TC>)
		  (IMAGE? <TEST-MODE .MODE ,TM-IMAGE>)
		  (ECHO? <ECHO-ON? .MODE>)
		  (BUFFER <TUPLE "" "" 0 0 0 0 0>) (TTY <TC-TTY .TC>))
  #DECL ((TC) TTY-CHANNEL (BUF CBUF END) STRING (TOT AVAIL CONT) FIX
	 (IMAGE? ECHO?) <OR ATOM FALSE> (CHANNEL) CHANNEL
	 (BUFFER) <TUPLE [2 STRING] [5 FIX]> (MODE) FIX
	 (PROMPT) <OR FALSE STRING>)
  <SET AVAIL <- <LENGTH .BUF> .CONT>>
  <COND (<L=? .AVAIL 0>
	 <LENGTH .BUF>)
	(T
	 <SET TOT .CONT>
	 <SET CBUF <REST .BUF .TOT>>
	 <BUF-START .BUFFER .BUF>
	 <BUF-CURRENT .BUFFER .CBUF>
	 <BUF-AVAIL .BUFFER .AVAIL>
	 <BUF-TOT .BUFFER .TOT>
	 <BUF-X .BUFFER <TT-X .TTY>>
	 <BUF-Y .BUFFER <TT-Y .TTY>>
	 <BUF-CONT .BUFFER .CONT>
	 <DUMP-WRITE-BUFFER .TC>
	 <REPEAT (CHR (IJFN <TC-IJFN .TC>) (TTY <TC-TTY .TC>)
		  (ECHRS <TT-SPEC-CHARS .TTY>) RC TERM?)
	   #DECL ((RC) <OR FIX FALSE> (CHR) CHARACTER (IJFN) FIX
		  (ECHRS) STRING (TERM?) <OR STRING FALSE> (TTY) TTY)
	   <COND (<SET CHR <GET-BYTE .TC>>
		  <1 .CBUF .CHR>
		  <SET TERM? <MEMQ .CHR .END>>
		  <UPDATE-INPUT .TTY .MODE>
		  <COND (<AND .ECHO?
			      <OR .TERM?
				  <AND <NOT <MEMQ .CHR .ECHRS>>
				       <N==? .CHR <ASCII 13>>
				       <N==? .CHR <ASCII 10>>>>>
			 ; "Echo char in these cases"
			 <TTY-NORMAL-OUT .CHANNEL FILL-READ-BUFFER
					 .CHR>
			 <DUMP-WRITE-BUFFER .TC>)>
		  ; "Done.  Do this before checking for editing char"
		  <COND (.TERM?
			 <RETURN <+ .TOT 1>>)>
		  <COND (<OR <==? .CHR <TS-RUBOUT .ECHRS>>
			     <==? .CHR <TS-WORD .ECHRS>>
			     <==? .CHR <TS-KILL .ECHRS>>>
			 <BUF-CURRENT .BUFFER .CBUF>
			 <BUF-AVAIL .BUFFER .AVAIL>
			 <BUF-TOT .BUFFER .TOT>
			 <DO-RUBOUT .CHANNEL .TC .TTY .BUFFER
				    <COND (<==? .CHR <TS-RUBOUT .ECHRS>>
					   <ASCII 127>)
					  (<==? .CHR <TS-WORD .ECHRS>>
					   <ASCII 23> ;"Char Cntl-W")
					  (<==? .CHR <TS-KILL .ECHRS>>
					   <ASCII 21> ;"Char Cntl-U")>
				    .PROMPT>
			 <SET CBUF <BUF-CURRENT .BUFFER>>
			 <SET AVAIL <BUF-AVAIL .BUFFER>>
			 <SET TOT <BUF-TOT .BUFFER>>)
			(<==? .CHR <ASCII 12> ;"Char Cntl-L">
			 <CLEAR-SCREEN .CHANNEL FILL-READ-BUFFER>
			 <COND (.PROMPT
				<TTY-NORMAL-OUT .CHANNEL FILL-READ-BUFFER
						.PROMPT>)>
			 <BUF-CONT .BUFFER 0>
			 <BUF-X .BUFFER <TT-X .TTY>>
			 <BUF-Y .BUFFER <TT-Y .TTY>>; "Now know where we start"
			 <TTY-NORMAL-OUT .CHANNEL FILL-READ-BUFFER
					 .BUF .TOT>)
			(<==? .CHR <ASCII 4> ;"Char Cntl-D">
			 <FRESH-LINE .CHANNEL FILL-READ-BUFFER>
			 <BUF-CONT .BUFFER 0>
			 <COND (.PROMPT
				<TTY-NORMAL-OUT .CHANNEL FILL-READ-BUFFER
						.PROMPT>)>
			 <BUF-X .BUFFER <TT-X .TTY>>
			 <BUF-Y .BUFFER <TT-Y .TTY>>
			 <TTY-NORMAL-OUT .CHANNEL FILL-READ-BUFFER
					 .BUF .TOT>)
			(<==? .CHR <TS-REPRINT .ECHRS>>
			 ;"...")
			(T
			 <COND (<OR <==? .CHR <ASCII 13>>
				    <==? .CHR <ASCII 10>>>
				<1 .CBUF <ASCII 13>>
				<SET CBUF <REST .CBUF>>
				<SET TOT <+ .TOT 1>>
				<SET AVAIL <- .AVAIL 1>>
				<COND (<0? .AVAIL>
				       <RETURN .TOT>)>
				<1 .CBUF <ASCII 10>>
				<TTY-NORMAL-OUT .CHANNEL FILL-READ-BUFFER
						,CRLF-STRING>)>
			 <SET TOT <+ .TOT 1>>
			 <SET CBUF <REST .CBUF>>
			 <SET AVAIL <- .AVAIL 1>>
			 <COND (<0? .AVAIL>
				<RETURN .TOT>)>)>
		  <DUMP-WRITE-BUFFER .TC>)>>)>>

<SETG CRLF-STRING <STRING <ASCII 13> <ASCII 10>>>
<SETG BREAKS <STRING <ASCII 32> ;"Char Space"
		     <ASCII 9> ;"Char Tab"
		     <ASCII 10> ;"Char L.F."
		     <ASCII 13> ;"Char C.R."
		     <ASCII 45> ;"Char -"
		     <ASCII 47> ;"Char /"
		     <ASCII 46> ;"Char .">>
; "BUFFER is:  initial buf, current buf, space left in buf,
   total chrs in buf"
<DEFINE DO-RUBOUT (CHANNEL TC TTY BUFFER WHICH PROMPT "AUX" KC (VERT 0)
		   (OY <TT-Y .TTY>))
  #DECL ((CHANNEL) CHANNEL (TC) TTY-CHANNEL (TTY) TTY (WHICH) CHARACTER
	 (BUFFER) <TUPLE [2 STRING] [5 FIX]> (KC) CHARACTER (VERT) FIX
	 (PROMPT) <OR FALSE STRING>)
  <COND (<0? <BUF-TOT .BUFFER>>
	 <TTY-IMAGE-OUT .CHANNEL FILL-READ-BUFFER <ASCII 7> ;"Char Bell">)
	(<==? .WHICH <ASCII 127> ;"Char ">
	 <BUF-CURRENT .BUFFER <BACK <BUF-CURRENT .BUFFER>>>
	 <SET KC <1 <BUF-CURRENT .BUFFER>>>
	 <BUF-AVAIL .BUFFER <+ <BUF-AVAIL .BUFFER> 1>>
	 <BUF-TOT .BUFFER <- <BUF-TOT .BUFFER> 1>>
	 <COND (<==? .KC <ASCII 10> ;"Char L.F.">
		<COND (<AND <G? <BUF-TOT .BUFFER> 0>
			    <==? <1 <BACK <BUF-CURRENT .BUFFER>>>
				 <ASCII 13> ;"Char C.R.">>
		       <BUF-CURRENT .BUFFER <BACK <BUF-CURRENT .BUFFER>>>
		       <BUF-AVAIL .BUFFER <+ <BUF-AVAIL .BUFFER> 1>>
		       <BUF-TOT .BUFFER <- <BUF-TOT .BUFFER> 1>>)>
		<UPDATE-CURSOR-POS .CHANNEL .BUFFER 1 T .PROMPT>)
	       (<OR <==? .KC <ASCII 9> ;"Char Tab">
		    <==? .KC <ASCII 13> ;"Char C.R.">>
		<UPDATE-CURSOR-POS .CHANNEL .BUFFER 0 <> .PROMPT>
		<COND (<==? <TT-Y .TTY> .OY>
		       <HOR-POS-CURSOR .CHANNEL FILL-READ-BUFFER
				       <TT-X .TTY>>)
		      (T
		       <MOVE-CURSOR .CHANNEL FILL-READ-BUFFER
				    <TT-X .TTY> <TT-Y .TTY>>)>
		<CLEAR-EOL .CHANNEL FILL-READ-BUFFER>)
	       (<AND <L? <ASCII .KC> <ASCII !\ >>
		     <N==? .KC <ASCII 27> ;"Char Alt">>
		<ERASE-CHAR .CHANNEL FILL-READ-BUFFER 2>)
	       (T
		<ERASE-CHAR .CHANNEL FILL-READ-BUFFER>)>)
	(<==? .WHICH <ASCII 23> ;"Char Cntl-W">
	 <DELTOCH .CHANNEL .BUFFER ,BREAKS .PROMPT>)
	(<==? .WHICH <ASCII 21> ;"Char Cntl-U">
	 <DELTOCH .CHANNEL .BUFFER ,CRLF-STRING .PROMPT>)>>

<DEFINE DELTOCH (CHANNEL BUFFER STOP PROMPT "AUX"
		 (CCT <BUF-TOT .BUFFER>) (CHRS <BUF-CURRENT .BUFFER>) (UP 0)
		 (NBREAKFLAG <>) (TC <CHANNEL-DATA .CHANNEL>) (TTY <TC-TTY .TC>)
		 (OX <TT-X .TTY>) (OY <TT-Y .TTY>) NX NY)
  #DECL ((CHANNEL) CHANNEL (BUFFER) <TUPLE [2 STRING] [5 FIX]>
	 (CCT UP) FIX (STOP CHRS) STRING (TC) TTY-CHANNEL (TTY) TTY
	 (PROMPT) <OR FALSE STRING>)
  <REPEAT (CHR)
    <COND (<0? .CCT>
	   <RETURN>)>
    <SET CCT <- .CCT 1>>
    <COND (<MEMQ <SET CHR <1 <SET CHRS <BACK .CHRS>>>> .STOP>
	   <COND (.NBREAKFLAG	; "Have we seen any non-breaks?"
		  <SET CHRS <REST .CHRS>>
		  <SET CCT <+ .CCT 1>>
		  <RETURN>)>)
	  (T
	   <SET NBREAKFLAG T>)>
    <COND (<==? .CHR <ASCII 10> ;"Char L.F.">
	   ; "First, kill everything after the linefeed"
	   <BUF-CURRENT .BUFFER <REST .CHRS>>
	   <BUF-TOT .BUFFER <+ .CCT 1>>
	   <UPDATE-CURSOR-POS .CHANNEL .BUFFER .UP T .PROMPT>
	   <CLEAR-EOL .CHANNEL FILL-READ-BUFFER>
	   <SET OX <TT-X .TTY>>
	   <SET OY <TT-Y .TTY>>
	   <SET UP 1>
	   ; "Now, delete the CR if there"
	   <COND (<AND <G? .CCT 0>
		       <==? <1 <BACK .CHRS>> <ASCII 13> ;"Char C.R.">>
		  <SET CHRS <BACK .CHRS>>
		  <SET CCT <- .CCT 1>>)>)>>
  ; "Update the buffer"
  <BUF-CURRENT .BUFFER .CHRS>
  <BUF-TOT .BUFFER .CCT>
  ; "And do the delete"
  <UPDATE-CURSOR-POS .CHANNEL .BUFFER .UP <> .PROMPT>
  ; "Computes new cursor pos, but doesn't move cursor"
  <SET NY <TT-Y .TTY>>
  <SET NX <TT-X .TTY>>
  <COND (<N==? .OY .NY>
	 <REPEAT ()
	   <COND (<N==? .OX 0>
		  <MOVE-CURSOR .CHANNEL FILL-READ-BUFFER 0 .OY>
		  <CLEAR-EOL .CHANNEL FILL-READ-BUFFER>
		  <SET OX -1>)>
	   <COND (<L? <SET OY <- .OY 1>> 0>
		  <SET OY <- <TD-HEIGHT <TT-DESC .TTY>> 1>>)>
	   <COND (<==? .OY .NY>
		  <MOVE-CURSOR .CHANNEL FILL-READ-BUFFER .NX .NY>
		  <RETURN>)>>)
	(T
	 <HOR-POS-CURSOR .CHANNEL FILL-READ-BUFFER .NX>)>
  <CLEAR-EOL .CHANNEL FILL-READ-BUFFER>>

; "Takes channel, buffer, # lines moved up.  Positions screen cursor at
   end of current buffer.  If CONT is non-zero, and have erased into that,
   and CONT doesn't start at beginning of line, will do wrong thing with
   horizontal position.  VERT is then used to find new vertical position."
<DEFINE UPDATE-CURSOR-POS (CHANNEL BUFFER VERT "OPT" (MOVE? T) (PROMPT <>)
			   "AUX" IH (VLOSER? <>)
			   (LINES 0) NEWY HEIGHT (TC <CHANNEL-DATA .CHANNEL>))
  #DECL ((CHANNEL) CHANNEL (BUFFER) <TUPLE [2 STRING] [5 FIX]>
	 (HEIGHT NEWY VERT) FIX (MOVE? VLOSER?) <OR ATOM FALSE>
	 (PROMPT) <OR FALSE STRING> (TC) TTY-CHANNEL)
  <COND (<G? <BUF-CONT .BUFFER> <BUF-TOT .BUFFER>>
	 ; "Sigh.  Don't know where the text starts"
	 <BUF-CONT .BUFFER 0>
	 <BUF-X .BUFFER 0>
	 <BUF-Y .BUFFER -1>
	 <SET VLOSER? T>
	 <SET IH 0>)
	(T
	 <SET IH <BUF-X .BUFFER>>)>
  <REPEAT ((FLG? <AND .VLOSER? .PROMPT>)
	   (CT <COND (.FLG? <LENGTH .PROMPT>)
		     (T <BUF-TOT .BUFFER>)>)
	   CHR (BB <COND (.FLG? .PROMPT)
			 (T <BUF-START .BUFFER>)>)
	   (WIDTH <DO-TTY-PARM .TC PAGE-WIDTH>))
    #DECL ((WIDTH CT) FIX (CHR) CHARACTER (BB) STRING)
    <COND (<0? .CT>
	   <COND (.FLG?
		  <SET BB <BUF-START .BUFFER>>
		  <SET CT <BUF-TOT .BUFFER>>
		  <SET FLG? <>>
		  <AGAIN>)
		 (T
		  <RETURN>)>)>
    <SET CHR <1 .BB>>
    <SET CT <- .CT 1>>
    <SET BB <REST .BB>>
    <COND (<OR <AND <G=? <ASCII .CHR> 32>
		    <L? <ASCII .CHR> 127>>
	       <==? .CHR <ASCII 27> ;"Char Alt">>
	   <SET IH <+ .IH 1>>)
	  (<==? .CHR <ASCII 13> ;"Char C.R.">
	   <SET IH 0>)
	  (<==? .CHR <ASCII 10> ;"Char L.F.">
	   <SET LINES <+ .LINES 1>>)
	  (<==? .CHR <ASCII 9> ;"Char Tab">
	   <SET IH <+ .IH <- 8 <MOD .IH 8>>>>)
	  (<SET IH <+ .IH 2>>)>
    <COND (<G=? .IH <- .WIDTH 1>>
	   <SET LINES <+ .LINES 1>>
	   <SET IH <- .IH .WIDTH>>)>>
  <COND (<OR .VLOSER?
	     <L? <BUF-Y .BUFFER> 0>>
	 <SET NEWY <- <DO-TTY-PARM .TC PAGE-Y> .VERT>>)
	(<SET NEWY <+ <BUF-Y .BUFFER> .LINES>>)>
  <COND (<G=? .NEWY <SET HEIGHT <DO-TTY-PARM .TC PAGE-HEIGHT>>>
	 <SET NEWY <MOD .NEWY .HEIGHT>>)
	(<L? .NEWY 0>
	 <SET NEWY <- .HEIGHT <MOD <- .NEWY> .HEIGHT>>>)>
  <COND (.MOVE?
	 <COND (<N==? .NEWY <DO-TTY-PARM .TC PAGE-Y>>
		<MOVE-CURSOR .CHANNEL FILL-READ-BUFFER .IH .NEWY>)
	       (T
		<HOR-POS-CURSOR .CHANNEL FILL-READ-BUFFER .IH>)>)
	(T
	 <DO-TTY-PARM .TC PAGE-X .IH>
	 <DO-TTY-PARM .TC PAGE-Y .NEWY>)>>
