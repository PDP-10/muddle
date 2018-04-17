%<USE "NEWSTRUC">

<NEWSTRUC TTY-DESC VECTOR
	  TD-NAME STRING
	  TD-HEIGHT FIX
	  TD-WIDTH FIX
	  TD-PADCHR CHARACTER
	  TD-CRPAD FIX
	  TD-LFPAD FIX
	  TD-PRIMOPS <VECTOR [REST <OR FALSE TTY-OP>]>>

<NEWSTRUC TTY-OUT VECTOR
	 TO-STRING <OR STRING TTY-ELT>
	 TO-PAD FIX>

<NEWTYPE TTY-ELT VECTOR '<<PRIMTYPE VECTOR> [REST <OR FIX STRING>]>>

<COND (<==? <TYPEPRIM FIX> FIX>
       <PUT-DECL TTY-OP
		 '<OR STRING TTY-ELT TTY-OUT
		      <VECTOR [REST <OR TTY-ELT STRING TTY-OUT>]>>>)
      (T
       <PUT TTY-OP DECL
	    '<OR STRING TTY-ELT TTY-OUT
		 <VECTOR [REST <OR STRING TTY-ELT TTY-OUT>]>>>)>

"TTY-CHANNELs contain buffers and channel/specific modes.  They point to
 TTYs, which contain the rest of the dynamic tty information (cursor pos,
 special characters, speed, etc.  A TTY points to a TTY-DESC, which contains
 static tty information (type, height, width, padding, escape sequences)."
<NEWSTRUC TTY-CHANNEL VECTOR
	  TC-IJFN FIX		; "Input descriptor (STDIN)"
	  TC-DEV <OR ATOM STRING FALSE>	; "Device name (/dev/tty)"
	  TC-SNM <OR ATOM STRING FALSE>	; "directory"
	  TC-NM1 <OR STRING FALSE>
	  TC-NM2 <OR STRING FALSE>
	  TC-DSN <OR STRING FALSE>
	  TC-STATUS FIX
	  TC-OJFN FIX
	  TC-IBUF <OR STRING FALSE>	; "input buffer"
	  TC-TIBUF <OR STRING FALSE>	; "top of input buffer"
	  TC-IBC FIX		; "# chars in input buffer"
	  TC-OBUF <OR STRING FALSE>	; "output buffer"
	  TC-TOBUF <OR STRING FALSE>	; "top of output buffer"
	  TC-OBC FIX		; "# chars in output buffer"
	  TC-QUEUE <OR STRING CHARACTER FALSE>
	  TC-QCT FIX
	  TC-MODE FIX
	  TC-SMODE FIX		; "Mode information for TTY"
	  TC-TTY <OR TTY FALSE>	; "TTY information">

; "Bits in TC-MODE and TC-SMODE"
<MSETG TM-ECHO 1>	; "Defaultly on"
<MSETG TM-IMAGE 2>	; "Defaultly off"
<MSETG TM-PAGE 4>	; "Defaultly on--do something at end of page"
<MSETG TM-WRAP 8>	; "Defaultly on--wrap at end of page"
<MSETG TM-ITS 16>	; "Defaultly on--do --more-- instead of ^S/^Q"
<MSETG TM-BADPOS 32>	; "On until we know what the cursor position is"

<SETG TM-DEFAULT <CHTYPE <ORB ,TM-ECHO ,TM-PAGE ,TM-WRAP ,TM-ITS> FIX>>

; "Offsets in TT-SPEC-CHARS"
<MSETG TS-REPRINT 1>	; "ctrl-R"
<MSETG TS-WORD 2>	; "ctrl-W"
<MSETG TS-QUOTE 3>	; "ctrl-V"
<MSETG TS-RUBOUT 4>	; "rubout"
<MSETG TS-KILL 5>	; "ctrl-U"
<NEWSTRUC TTY VECTOR
	  TT-OSTATE	TTSTATE	; "Saved state of tty, to win when quit"
	  TT-NSTATE	TTSTATE	; "Current state of tty, to win when continue"
	  TT-SCREWED	<OR ATOM FALSE> ; "True when in funny mode"
	  TT-SPEC-CHARS STRING	; "User's definitions of editing chars"
	  TT-OSPEED	FIX	; "Output speed, for padding"
	  TT-X		FIX	; "Current column"
	  TT-Y		FIX	; "Current line"
	  TT-SAV-X	<OR FIX FALSE>	; "Saved X position"
	  TT-SAV-Y	<OR FIX FALSE>	; "Saved Y position"
	  TT-LAST-IN	<OR FIX FALSE>	; "Last line input happened on"
	  TT-LAST-MORE	FIX		; "Set to 0 when more happens"
	  TT-DESC	TTY-DESC
	  TT-MORE-LINES <OR FIX FALSE>>

<NEWSTRUC TTSTATE VECTOR
	  TST-TCHARS STRING
	  TST-BITS <UVECTOR FIX>
	  TST-SGTTYB STRING
	  TST-LTCHARS STRING>


"MACROS"

; "Test the mode word of the channel"
<DEFMAC TEST-MODE ('MD 'MODE "ARGS" FOO)
  <COND (<NOT <EMPTY? .FOO>>
	 <FORM NOT <FORM 0? <FORM ANDB .MD
				  <FORM + .MODE !.FOO>>>>)
	(<FORM NOT <FORM 0? <FORM ANDB .MODE .MD>>>)>>

<DEFMAC TEST-TC-MODE ('TC 'MODE "ARGS" FOO)
  <FORM TEST-MODE <FORM TC-MODE .TC> .MODE !.FOO>>

<DEFMAC ECHO-ON? ('MD)
  <FORM AND <FORM TEST-MODE .MD ,TM-ECHO>
	    <FORM NOT <FORM TEST-MODE .MD ,TM-IMAGE>>>>

; "Update the mud-chan, to account for cursor motion"
<DEFMAC UPDATE-MC ('CH 'X "OPTIONAL" 'Y "AUX" (L ()))
  <COND (<AND <ASSIGNED? X> .X <OR <NOT <STRUCTURED? .X>>
				   <NOT <EMPTY? .X>>>>
	 <SET L (<COND (<TYPE? .X LIST>
			<FORM MC-HPOS '.SU <FORM + <FORM MC-HPOS '.SU>
						   <1 .X>>>)
		       (<FORM MC-HPOS '.SU .X>)>)>)>
  <COND (<AND <ASSIGNED? Y> .Y <OR <NOT <STRUCTURED? .Y>>
				   <NOT <EMPTY? .Y>>>>
	 <SET L (<COND (<TYPE? .Y LIST>
			<FORM MC-VPOS '.SU <FORM + <FORM MC-VPOS '.SU>
						   <1 .Y>>>)
		       (<FORM MC-VPOS '.SU .Y>)> !.L)>)>
  <COND (<NOT <EMPTY? .L>>
	 <FORM BIND ((SU <FORM CHANNEL-USER .CH>))
	       <FORM COND (<FORM TYPE? '.SU MUD-CHAN> !.L)>>)>>

<DEFMAC DO-TTY-PARM ('TC OPER "OPTIONAL" 'NEW "AUX" (TTY <FORM TC-TTY .TC>)
		     (TD <FORM TT-DESC .TTY>))
  <COND (<==? .OPER PAGE-WIDTH>
	 <COND (<ASSIGNED? NEW>
		<FORM TD-WIDTH .TD .NEW>)
	       (T
		<FORM - <FORM TD-WIDTH .TD> 1>)>)
	(<==? .OPER PAGE-HEIGHT>
	 <COND (<ASSIGNED? NEW>
		<FORM TD-HEIGHT .TD .NEW>)
	       (T
		<FORM TD-HEIGHT .TD>)>)
	(<==? .OPER PAGE-X>
	 <COND (<ASSIGNED? NEW>
		<COND (<AND <TYPE? .NEW FIX>
			    <0? .NEW>>
		       <FORM TT-X .TTY .NEW>)
		      (T
		       <FORM BIND ((RTTY .TTY) (TD <FORM TT-DESC '.RTTY>)
				   (RNEW <FORM MIN <FORM ABS .NEW>
					       <FORM - <FORM TD-WIDTH '.TD>
						     1>>))
			     <FORM TT-X '.RTTY '.RNEW>>)>)
	       (T
		<FORM TT-X .TTY>)>)
	(<==? .OPER PAGE-Y>
	 <COND (<ASSIGNED? NEW>
		<COND (<AND <TYPE? .NEW FIX>
			    <0? .NEW>>
		       <FORM TT-Y .TTY .NEW>)
		      (T
		       <FORM BIND ((RTTY .TTY) (TD <FORM TT-DESC '.RTTY>)
		                   (RNEW <FORM MIN <FORM ABS .NEW>
					       <FORM - <FORM TD-HEIGHT '.TD>
						     1>>))
			     <FORM TT-Y '.RTTY '.RNEW>>)>)
	       (T
		<FORM TT-Y .TTY>)>)>>

  