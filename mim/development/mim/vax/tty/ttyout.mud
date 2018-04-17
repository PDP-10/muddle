"Low-level TTY output routines:  raw output, padding, do terminal ops"

"Perform simple tty ops--interpret specifications in tty-desc."
<DEFINE DO-TTY-OP (OPCODE CHANNEL "OPTIONAL" (NEWX <>) (NEWY <>)
		   (SET? T)
		   "AUX" (TC <CHANNEL-DATA .CHANNEL>) (TTY <TC-TTY .TC>)
			 (TD <TT-DESC .TTY>) OD)
  #DECL ((OPCODE) FIX (CHANNEL) CHANNEL (NEWX NEWY) <OR FALSE FIX>
	 (TC) TTY-CHANNEL (TTY) TTY (TD) TTY-DESC (SET?) <OR ATOM FALSE>)
  <COND (.NEWX
	 <COND (.SET?
		<TT-X .TTY <SET NEWX <MIN .NEWX <- <TD-WIDTH .TD> 1>>>>)>)
	(<SET NEWX <TT-X .TTY>>)>
  <COND (.NEWY
	 <COND (.SET?
		<TT-Y .TTY <SET NEWY <MIN .NEWY <- <TD-HEIGHT .TD> 1>>>>)>)
	(<SET NEWY <TT-Y .TTY>>)>
  <TC-MODE .TC <ANDB <TC-MODE .TC> %<XORB ,TM-BADPOS -1>>>
  <COND (.SET? <UPDATE-MC .CHANNEL .NEWX .NEWY>)>
  <COND (<SET OD <AND <G=? <LENGTH <TD-PRIMOPS .TD>> .OPCODE>
		      <NTH <TD-PRIMOPS .TD> .OPCODE>>>
	 <OUTPUT-OP .OD .CHANNEL .TD .NEWX .NEWY>)>>

<DEFINE OUTPUT-OP (OD CHANNEL TD X Y "OPTIONAL" (PAD 0))
  #DECL ((OD) TTY-OP (CHANNEL) CHANNEL (TD) TTY-DESC (X Y PAD) FIX)
  <COND (<TYPE? .OD VECTOR>
	 <MAPF <>
	   <FUNCTION (OC)
	     <OUTPUT-OP .OC .CHANNEL .TD .X .Y>>
	   .OD>
	 T)
	(T
	 <COND (<TYPE? .OD TTY-OUT>
		<SET PAD <TO-PAD .OD>>
		<SET OD <TO-STRING .OD>>)>
	 <COND (<TYPE? .OD STRING>
		<OUTPUT-RAW-STRING .CHANNEL .OD>)
	       (<TYPE? .OD TTY-ELT>
		<MAPF <>
		  <FUNCTION (ELT "AUX" VAL)
		    #DECL ((ELT) <OR FIX STRING> (VAL) FIX)
		    <COND (<TYPE? .ELT STRING>
			   <OUTPUT-RAW-STRING .CHANNEL .ELT>)
			  (T
			   <COND (<0? <ANDB .ELT ,TTY-X/Y>>
				  <SET VAL .X>)
				 (<SET VAL .Y>)>
			   <COND (<NOT <0? <ANDB .ELT ,TTY-INC-ARG>>>
				  <SET VAL <+ .VAL 1>>)>
			   <COND (<NOT <0? <ANDB .ELT ,TTY-BCD-ARG>>>
				  <SET VAL <+ <* 16 </ .VAL 10>>
					      <MOD .VAL 10>>>)>
			   <SET ELT <ANDB .ELT ,TTY-ARG-DESC>>
			   <COND (<==? .ELT ,TTY-LITERAL>
				  <OUTPUT-RAW-STRING .CHANNEL <ASCII .VAL>>)
				 (<==? .ELT ,TTY-LIT+>
				  <OUTPUT-RAW-STRING .CHANNEL
						     <ASCII <+ .VAL 32>>>)
				 (<==? .ELT ,TTY-DECIMAL>
				  <OUTPUT-NUMBER .CHANNEL .VAL <>>)
				 (<==? .ELT ,TTY-RJD2>
				  <OUTPUT-NUMBER .CHANNEL .VAL <>>)
				 (<==? .ELT ,TTY-RJD3>
				  <OUTPUT-NUMBER .CHANNEL .VAL <>>)>)>>
		  .OD>)>
	 <COND (<NOT <0? .PAD>>
		<OUTPUT-PAD .CHANNEL .TD .PAD>)>
	 T)>>

<SETG BUF1 <ISTRING 1>>
<GDECL (BUF1) STRING>

"Lowest level output routine--stuff uninterpreted characters out or into
 output buffer"
<DEFINE OUTPUT-RAW-STRING (CHANNEL STR "OPTIONAL" (LENGTH <>)
			   "AUX" (TC <CHANNEL-DATA .CHANNEL>) OBUF)
  #DECL ((CHANNEL) CHANNEL (STR) <OR CHARACTER STRING> (TC) TTY-CHANNEL
	 (LENGTH) <OR FIX FALSE> (OBUF) STRING)
  <COND (<TYPE? .STR CHARACTER>
	 <SET STR <1 ,BUF1 .STR>>)>
  <COND (<NOT .LENGTH>
	 <SET LENGTH <LENGTH .STR>>)>
  <COND (<NOT <TC-OBUF .TC>>
	 <CALL SYSCALL WRITE <TC-OJFN .TC> .STR .LENGTH>
	 .LENGTH)
	(T
	 <SET OBUF <TC-OBUF .TC>>
	 <REPEAT ((WR 0) TRANS)
	   #DECL ((TRANS) FIX)
	   <COND (<0? .LENGTH>
		  <RETURN .WR>)
		 (<EMPTY? .OBUF>
		  <DUMP-WRITE-BUFFER .TC>
		  <SET OBUF <TC-OBUF .TC>>)>
	   <SET TRANS <MIN <LENGTH .OBUF> .LENGTH>>
	   <SUBSTRUC .STR 0 .TRANS .OBUF>
	   <SET STR <REST .STR .TRANS>>
	   <TC-OBUF .TC <SET OBUF <REST .OBUF .TRANS>>>
	   <TC-OBC .TC <+ <TC-OBC .TC> .TRANS>>
	   <SET WR <+ .WR .TRANS>>
	   <SET LENGTH <- .LENGTH .TRANS>>>)>>

"Output a specifed amount of padding (time in milliseconds)"
<DEFINE OUTPUT-PAD (CHANNEL TD AMT "AUX" (TC <CHANNEL-DATA .CHANNEL>)
		    (OSPEED <TT-OSPEED <TC-TTY .TC>>) PC)
  #DECL ((CHANNEL) CHANNEL (TD) TTY-DESC (AMT OSPEED) FIX (TC) TTY-CHANNEL)
  <COND (<G? .AMT 0>
	 <COND (<==? .OSPEED 0> <SET OSPEED 9600>)>
	 <SET AMT <FIX </ <* <FLOAT .OSPEED> <FLOAT .AMT>>
			  7000.0>>>	; "# chars to send"
	 <SET PC <TD-PADCHR .TD>>	; "Which char to send"
	 <COND (<NOT <TC-OBUF .TC>>
		<REPEAT ((OJFN <TC-OJFN .TC>) (ST <STRING .PC>))
		  <COND (<0? .AMT> <RETURN>)>
		  <CALL SYSCALL WRITE .OJFN .ST 1>
		  <SET AMT <- .AMT 1>>>)
	       (T
		<REPEAT ((OBUF <TC-OBUF .TC>) (OC <TC-OBC .TC>))
		  #DECL ((OBUF) STRING (OC) FIX)
		  <COND (<0? .AMT>
			 <TC-OBUF .TC .OBUF>
			 <TC-OBC .TC .OC>
			 <RETURN>)>
		  <COND (<EMPTY? .OBUF>
			 <TC-OBUF .TC .OBUF>
			 <TC-OBC .TC .OC>
			 <DUMP-WRITE-BUFFER .TC>
			 <SET OBUF <TC-OBUF .TC>>
			 <SET OC 0>)>
		  <1 .OBUF .PC>
		  <SET OC <+ .OC 1>>
		  <SET OBUF <REST .OBUF>>
		  <SET AMT <- .AMT 1>>>)>)>>

<SETG NUMBUF <ISTRING 10>>
<GDECL (NUMBUF) STRING>

"Output a number in raw mode"
<DEFINE OUTPUT-NUMBER (CHANNEL NUM WIDTH "AUX" (BUF <REST ,NUMBUF 10>)
		       CWIDTH (NEG? <>))
  #DECL ((CHANNEL) CHANNEL (NUM) FIX (WIDTH) <OR FIX FALSE> (BUF) STRING)
  <COND (<0? .NUM>
	 <1 <SET BUF <BACK .BUF>> !\0>
	 <SET CWIDTH 1>)
	(T
	 <COND (<L? .NUM 0>
		<SET NUM <- .NUM>>
		<SET NEG? T>)>
	 <REPEAT (DIG)
	   <SET DIG <MOD .NUM 10>>
	   <SET NUM </ .NUM 10>>
	   <1 <SET BUF <BACK .BUF>> <ASCII <+ .DIG <ASCII !\0>>>>
	   <COND (<0? .NUM>
		  <COND (.NEG?
			 <1 <SET BUF <BACK .BUF>> !\->)>
		  <RETURN>)>>)>
  <SET CWIDTH <LENGTH .BUF>>
  <COND (<AND .WIDTH <G? .WIDTH .CWIDTH>>
	 <REPEAT ()
	   <1 <SET BUF <BACK .BUF>> !\ >
	   <COND (<L=? .WIDTH <SET CWIDTH <+ .CWIDTH 1>>>
		  <RETURN>)>>)>
  <OUTPUT-RAW-STRING .CHANNEL .BUF .CWIDTH>>

"Dump the channel's output buffer"
<DEFINE DUMP-WRITE-BUFFER (TC "AUX" TOPB)
  #DECL ((TC) TTY-CHANNEL (TOPB) STRING)
  <COND (<G? <TC-OBC .TC> 0>
	 <CALL SYSCALL WRITE <TC-OJFN .TC>
	       <SET TOPB <TC-TOBUF .TC>> <TC-OBC .TC>>
	 <TC-OBC .TC 0>
	 <TC-OBUF .TC .TOPB>)>>
