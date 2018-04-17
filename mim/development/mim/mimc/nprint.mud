<PACKAGE "NPRINT">

<ENTRY NODE-COMPLAIN NODE-PRINT>

<USE "COMPDEC" "NEWSTRUC">

<NEW-CHANNEL-TYPE INTCHAN DEFAULT
		  OPEN INTCHAN-OPEN
		  CLOSE INTCHAN-CLOSE
		  WRITE-BYTE INTCHAN-WRITE-BYTE
		  WRITE-BUFFER INTCHAN-WRITE-BUFFER>

<NEWSTRUC INTCHAN VECTOR
	  INTOUT <OR CHANNEL FALSE>
	  INTCOUNT FIX
	  INTMAX FIX>

<DEFINE NODE-COMPLAIN (N "OPTIONAL" (MAX 80) "AUX" (P .N) TEM) 
	#DECL ((N) NODE (MAX) FIX (P) <OR VECTOR NODE>)
	<REPEAT ((OPP .P))
		<AND <EMPTY? .OPP> <RETURN>>
		<OR <NODE-PRINT .OPP .N .MAX T> <RETURN>>
		<OR <TYPE? <SET TEM <PARENT <SET P .OPP>>> NODE>
		    <RETURN>>
		<OR <MEMQ .OPP <KIDS <SET OPP .TEM>>>
		    <RETURN>>>
	<NODE-PRINT .P .N .MAX>>

<DEFINE NODE-PRINT (N
		    "OPTIONAL" (LOSER <>) (MAX 80) (FLAT <>)
		    "AUX" (OUTC .OUTCHAN) NCHS
			  (OUTCHAN <CHANNEL-OPEN INTCHAN  ""
						 <COND (.FLAT <>)
						       (.OUTC)>
						 0 .MAX>))
	#DECL ((MAX) FIX (NCHS) ANY
	       (OUTCHAN) <SPECIAL CHANNEL>
	       (LOSER) <SPECIAL <OR FALSE NODE>>)
	<RESET .OUTCHAN>
	<M-HLEN .OUTCHAN <- <M-HLEN .OUTC> 2>>
	<COND (<PROG NACT ()
		     #DECL ((NACT) <SPECIAL FRAME>)
		     <NPRINT .N>
		     <>>
	       <OR .FLAT <PRINC " ..." .OUTC>>
	       <SET NCHS <>>)
	      (ELSE <SET NCHS <INTCOUNT <CHANNEL-DATA .OUTCHAN>>>)>
	<OR .FLAT <CRLF .OUTC>>
	<CLOSE .OUTCHAN>
	.NCHS>

<DEFINE INTCHAN-OPEN (TYP OPER NM C-OR-F CNT MAX)
	<CHTYPE [.C-OR-F .CNT .MAX] INTCHAN>>

<DEFINE INTCHAN-CLOSE (CHANNEL OPER) T>

<DEFINE INTCHAN-WRITE-BYTE (CHAN OPER CHR
			    "AUX" (D <CHANNEL-DATA .CHAN>) (INO <INTOUT .D>))
	#DECL ((CHAN) CHANNEL)
	<COND (<NOT .INO>
	       <COND (<G? <SET INO <+ <INTCOUNT .D> 1>> <INTMAX .D>>
		      <RETURN T .NACT>)
		     (ELSE
		      <INTCOUNT .D .INO>)>)
	      (<N==? <INTCOUNT .D> <INTMAX .D>>
	       <CHANNEL-OP <INTOUT .D> WRITE-BYTE .CHR>
	       <INTCOUNT .D <+ <INTCOUNT .D> 1>>)>>

<DEFINE INTCHAN-WRITE-BUFFER (CHAN OPER STR "OPT" (N <LENGTH .STR>)
			      "AUX" (D <CHANNEL-DATA .CHAN>) (INO <INTOUT .D>))
	#DECL ((STR) STRING (CHAN) CHANNEL (N) FIX)
	<COND (<NOT .INO>
	       <INTCOUNT .D <SET INO <MIN <INTMAX .D> <+ <INTCOUNT .D> .N>>>>
	       <COND (<==? .INO <INTMAX .D>> <RETURN T .NACT>)>)
	      (<L=? <SET N <+ .N <INTCOUNT .D>>> <INTMAX .D>>
	       <CHANNEL-OP .INO WRITE-BUFFER .STR <- .N <INTCOUNT .D>>>
	       <INTCOUNT .D .N>)
	      (<N==? <INTCOUNT .D> <INTMAX .D>>
	       <CHANNEL-OP .INO WRITE-BUFFER .STR <- <INTMAX .D> <INTCOUNT .D>>>
	       <INTCOUNT .D <INTMAX .D>>)>>

<DEFINE NPRINT (N "AUX" (COD <NODE-TYPE .N>) TC (FLG <==? .N .LOSER>)) 
	#DECL ((N) NODE (COD TC) FIX)
	<AND .FLG <PRINC " **** ">>
	<COND (<OR <==? .COD ,FUNCTION-CODE> <==? .COD ,MFCN-CODE>>
	       <PRINC "<FUNCTION ">
	       <PRNARGL <BINDING-STRUCTURE .N> <RESULT-TYPE .N> <>>
	       <PRINC " ">
	       <SEQ-PRINT <KIDS .N>>
	       <PRINC ">">)
	      (<==? .COD ,PROG-CODE>
	       <PRINC "<">
	       <PRIN1 <NODE-NAME .N>>
	       <PRINC " ">
	       <PRNARGL <BINDING-STRUCTURE .N> <RESULT-TYPE .N> T>
	       <PRINC " ">
	       <SEQ-PRINT <KIDS .N>>
	       <PRINC ">">)
	      (<==? .COD ,MFIRST-CODE>
	       <PRINC <NTH ,MAP-SPEC-PRINT <NODE-SUBR .N>>>)
	      (<==? .COD ,MPSBR-CODE>
	       <PRINC ",">
	       <OR <AND <EMPTY? <KIDS .N>> some-subr>
		   <PRIN1 <NODE-NAME <1 <KIDS .N>>>>>)
	      (<==? .COD ,COPY-CODE>
	       <PRINC <NTH ,ST-CHRS
			   <SET TC
				<LENGTH
				  <MEMQ <NODE-NAME .N>
					'[TUPLE UVECTOR VECTOR LIST]>>>>>
	       <SEQ-PRINT <KIDS .N>>
	       <PRINC <NTH ,EN-CHRS .TC>>)
	      (<OR <==? .COD ,SEG-CODE> <==? .COD ,SEGMENT-CODE>>
	       <PRINC "!">
	       <COND (<NOT <EMPTY? <KIDS .N>>>
		      <NPRINT <1 <KIDS .N>>>)>)
	      (<==? .COD ,BRANCH-CODE>
	       <PRINC "(">
	       <NPRINT <PREDIC .N>>
	       <COND (<NOT <EMPTY? <CLAUSES .N>>>
		      <PRINC " ">
		      <SEQ-PRINT <CLAUSES .N>>)>
	       <PRINC ")">)
	      (<==? .COD ,QUOTE-CODE>
	       <AND <TYPE? <NODE-NAME .N> VECTOR UVECTOR LIST FORM>
		    <PRINC !\'>>
	       <PRIN1 <NODE-NAME .N>>)
	      (<OR <==? .COD ,SET-CODE> <==? .COD ,FSET-CODE>>
	       <PRINC "<">
	       <PRIN1 SET>
	       <PRINC " ">
	       <SEQ-PRINT <KIDS .N>>
	       <PRINC ">">)
	      (<OR <MEMQ .COD ,LGV>
		   <AND <==? .COD ,SUBR-CODE>
			<OR <AND <==? <NODE-SUBR .N> ,LVAL>
				 <SET COD ,FLVAL-CODE>>
			    <AND <==? <NODE-SUBR .N> ,GVAL>
				 <SET COD ,FGVAL-CODE>>>>>
	       <COND (<OR <==? .COD ,LVAL-CODE> <==? .COD ,FLVAL-CODE>>
		      <PRINC !\.>)
		     (ELSE <PRINC !\,>)>
	       <COND (<TYPE? <NODE-NAME .N> SYMTAB>
		      <PRIN1 <NAME-SYM <NODE-NAME .N>>>)
		     (ELSE <OR <AND <EMPTY? <KIDS .N>> some-atom>
			       <NPRINT <1 <KIDS .N>>>>)>)
	      (<==? <NODE-NAME .N> INTH>
	       <PRINC "<">
	       <OR <EMPTY? <KIDS .N>> <NPRINT <2 <KIDS .N>>>>
	       <PRINC " ">
	       <OR <EMPTY? <KIDS .N>> <NPRINT <1 <KIDS .N>>>>
	       <PRINC ">">)
	      (ELSE
	       <PRINC "<">
	       <PRINC <NODE-NAME .N>>
	       <PRINC " ">
	       <SEQ-PRINT <KIDS .N>>
	       <PRINC ">">)>
	<AND .FLG <PRINC " **** ">>>

<SETG MAP-SPEC-PRINT [",+" ",-" ",*" ",/" ",LIST"]>

<SETG LGV
      <UVECTOR ,LVAL-CODE ,FLVAL-CODE ,GVAL-CODE ,FGVAL-CODE
	       ,ASSIGNED?-CODE>>

<SETG ST-CHRS ["(" "[" "![" "<TUPLE"]>

<SETG EN-CHRS [")" "]" "!]" ">"]>

<GDECL (MAP-SPEC-PRINT ST-CHRS EN-CHRS) <VECTOR [REST STRING]> 
       (LGV) <UVECTOR [REST FIX]>>


<DEFINE SEQ-PRINT (L) #DECL ((L) <LIST [REST NODE]>)
	<COND (<NOT <EMPTY? .L>>
	       <NPRINT <1 .L>>
	       <COND (<NOT <EMPTY? <SET L <REST .L>>>>
		      <MAPF <>
			    <FUNCTION (N)
				#DECL ((N) NODE)
				<PRINC " ">
				<NPRINT .N>>
			    .L>)>)>>

<DEFINE PRNARGL (B R "OPTIONAL" (INAUX <>) "AUX" (INOPT <>) (DC ()) (FIRST T)) 
	#DECL ((B) <LIST [REST SYMTAB]> (DC) LIST)
	<PRINC "(">
	<MAPF <>
	      <FUNCTION (SYM "AUX" (COD <CODE-SYM .SYM>)) 
		      #DECL ((SYM) SYMTAB (COD) FIX)
		      <OR .FIRST <PRINC " ">>
		      <SET FIRST <>>
		      <COND (<==? .COD 1>
			     <PRINC "\"NAME\" ">
			     <PRIN1 <NAME-SYM .SYM>>)
			    (<L=? .COD 3>
			     <COND (<NOT .INAUX>
				    <SET INAUX T>
				    <PRINC "\"AUX\" ">)>
			     <COND (<==? .COD 2>
				    <PRINC "(">
				    <PRIN1 <NAME-SYM .SYM>>
				    <PRINC " ">
				    <NPRINT <INIT-SYM .SYM>>
				    <PRINC ")">)
				   (ELSE <PRIN1 <NAME-SYM .SYM>>)>)
			    (<==? .COD 4>
			     <PRINC "\"TUPLE\" ">
			     <PRIN1 <NAME-SYM .SYM>>)
			    (<==? .COD 5>
			     <PRINC "\"ARGS\" ">
			     <PRIN1 <NAME-SYM .SYM>>)
			    (<L=? .COD 9>
			     <COND (<NOT .INOPT>
				    <SET INOPT T>
				    <PRINC "\"OPTIONAL\" ">)>
			     <COND (<L=? .COD 7>
				    <PRINC "(">
				    <AND <==? .COD 6> <PRINC "'">>
				    <PRIN1 <NAME-SYM .SYM>>
				    <PRINC " ">
				    <NPRINT <INIT-SYM .SYM>>
				    <PRINC ")">)
				   (ELSE
				    <AND <==? .COD 8> <PRINC "'">>
				    <PRIN1 <NAME-SYM .SYM>>)>)
			    (<==? .COD 10>
			     <PRINC "\"CALL\" ">
			     <PRIN1 <NAME-SYM .SYM>>)
			    (<==? .COD 11>
			     <PRINC "\"BIND\" ">
			     <PRIN1 <NAME-SYM .SYM>>)
			    (ELSE
			     <AND <==? .COD 12> <PRINC "'">>
			     <PRIN1 <NAME-SYM .SYM>>)>
		      <COND (<N==? <DECL-SYM .SYM> ANY>
			     <SET DC
				  ((<NAME-SYM .SYM>)
				   <DECL-SYM .SYM>
				   !.DC)>)>>
	      .B>
	<COND (<AND .R <N==? .R ANY>> <SET DC ('(VALUE) .R !.DC)>)>
	<PRINC ")">
	<COND (<NOT <EMPTY? .DC>> <PRINC " "> <PRIN1 <CHTYPE .DC DECL>>)>>





<ENDPACKAGE>
