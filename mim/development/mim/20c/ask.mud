<USE "JCL">

<DEFINE SAV ("OPTIONAL" (FN "<MIM>MIMOC20.EXE")
	     "AUX" FIL FILLEN REC (DIR "") TCH
	     (BUF <ISTRING 100>) JCL-STR REM-STR N1
	     GM (NM2 "MUD") SNM (OUTCHAN .OUTCHAN)
	     (AUTO-PREC <>) (THINGS (T)) (TTHINGS .THINGS) WDATE)
	#DECL ((SNM NM2) <SPECIAL STRING> (OUTCHAN) CHANNEL (BUF) STRING
	       (FN) <OR STRING FALSE>)
	<SNAME "">
	<RESET .INCHAN>
	<SETG DO-LOOPS
	      <SETG SURVIVOR-MODE <SET DOC <SETG GLUE-MODE <SETG INT-MODE <>>>>>>
	<COND (<AND .FN <=? <SAVE .FN> "SAVED">> T)
	      (T
	       <COND (<SET JCL-STR <READJCL>>
		      <COND (<SET REM-STR <MEMQ !\/ .JCL-STR>>
			     <SET JCL-STR <SUBSTRUC .JCL-STR 0
						    <- <LENGTH .JCL-STR>
						       <LENGTH .REM-STR>>>>)>
		      <SET FIL <LEX .JCL-STR <LENGTH .JCL-STR>>>
		      <SET NM2 "MIMA">
		      <COND (<SET TCH <OPEN "READ" <1 .FIL>>>
			     <SET N1 <CHANNEL-OP .TCH NM1>>
			     <CLOSE .TCH>)
			    (ELSE
			     <PRINT .TCH>
			     <QUIT>)>
		      <SET NM2 "MUD">
		      <SETG VERBOSE <>>
		      <COND (.REM-STR
			     <SET REM-STR <LPARSE <REST .REM-STR>>>
			     <MAPF <>
				<FUNCTION (TOKEN)
				  <COND (<TYPE? .TOKEN ADECL>
					 <COND (<OR <==? <1 .TOKEN> P>
						    <==? <1 .TOKEN> /P>>
						<COND
						 (<TYPE? <2 .TOKEN> ATOM>
						  <SET TOKEN
						       <SPNAME <2 .TOKEN>>>)
						 (T
						  <SET TOKEN <2 .TOKEN>>)>
						<SET PRECOMPILED
						     <STRING .TOKEN
							     ".MSUBR">>)>)
					(<TYPE? .TOKEN ATOM>
					 <COND (<OR <==? .TOKEN G>
						    <==? .TOKEN /G>>
						<SETG GLUE-MODE T>
						<COND (,INT-MODE
						       <SETG SURVIVOR-MODE
							     T>)>)
					       (<OR <==? .TOKEN I>
						    <==? .TOKEN /I>>
						<SETG INT-MODE T>
						<COND (,GLUE-MODE
						       <SETG SURVIVOR-MODE
							     T>)>)
					       (<OR <==? .TOKEN D>
						    <==? .TOKEN /D>
						    <==? .TOKEN L>
						    <==? .TOKEN /L>>
						<SET DOC T>)
					       (<OR <==? .TOKEN V>
						    <==? .TOKEN /V>>
						<SETG VERBOSE T>)
					       (<OR <==? .TOKEN /SV>
						    <==? .TOKEN SV>>
						<SETG SURVIVOR-MODE T>)
					       (<OR <==? .TOKEN /DL>
						    <==? .TOKEN DL>>
						<SETG DO-LOOPS T>)
					       (<OR <==? .TOKEN /P>
						    <==? .TOKEN P>>
						<SET PRECOMPILED
						     <STRING .N1
							     ".MSUBR">>)
					       (<OR <==? .TOKEN /PA>
						    <==? .TOKEN PA>>
						<SET PRECOMPILED
						     <STRING .N1
							     ".MSUBR">>
						<SET AUTO-PREC T>)>)
					(ELSE
					 <SET TTHINGS
					      <REST
					       <PUTREST .TTHINGS
							(.TOKEN)>>>)>>
				.REM-STR>)>)
		     (ELSE
		      <PROG ()
			    <PRINC "File(s): ">
			    <SET FILLEN <READSTRING .BUF .INCHAN "">>
			    <SET FIL <LEX .BUF .FILLEN>>
			    <SET NM2 "MIMA">
			    <COND (<SET TCH <OPEN "READ" <1 .FIL>>>
				   <SET N1 <CHANNEL-OP .TCH NM1>>
				   <CLOSE .TCH>)
				  (ELSE
				   <PRINT .TCH>
				   <RESET .INCHAN>
				   <AGAIN>)>>
		      <SET NM2 "MUD">
		      <SETG VERBOSE <>>
		      <CRLF>
		      <PRINC "Doc: ">
		      <COND (<SET DOC <MEMQ <TYI> "YyTt ">>
			     <PRINC " [Listing]
">)
			    (T
			     <PRINC " [No Listing]
">)>
		      <COND (<=? .N1 "BOOT">
			     <PRINC " [Boot mode]">
			     <CRLF>
			     <SETG BOOT-MODE <SETG INT-MODE T>>)
			    (T
			     <PRINC "Interpreter: ">
			     <COND (<MEMQ <TYI> " YyTt">
				    <PRINC " [Interpreter Code]">
				    <SET EXPFLOAD T>
				    <SETG INT-MODE T>)
				   (T
				    <SETG INT-MODE <>>
				    <PRINC " [User Code]">)>
			     <COND (<=? .FIL "MSG"> <SETG GC-MODE T>)>
			     <SETG BOOT-MODE <>>
			     <CRLF>
			     <PRINC "Glue: ">
			     <COND (<MEMQ <TYI> " YyTt">
				    <SET GM T>
				    <COND (,INT-MODE <SETG SURVIVOR-MODE T>)>
				    <PRINC " [Glue]">)
				   (T
				    <PRINC " [No Glue]">
				    <SET GM <>>)>
			     <CRLF>
			     <PRINC "Verbose ">
			     <COND (<MEMQ <TYI> " YyTt">
				    <SETG VERBOSE T>
				    <PRINC " [Verbose]]">)
				   (T
				    <PRINC " [No Verbose]">
				    <SETG VERBOSE <>>)>
			     <CRLF>
			     <PRINC "Things to do: ">
			     <REPEAT ()
				     <COND (<==? <NEXTCHR> <ASCII *33*>>
					    <CRLF>
					    <RETURN>)>
				     <SET TTHINGS <REST <PUTREST .TTHINGS
								 (<READ>)>>>>
			     <SETG GLUE-MODE .GM>)>)>
	       <COND (<AND <ASSIGNED? PRECOMPILED> .PRECOMPILED .AUTO-PREC
			   <SET TCH <OPEN "READ" .PRECOMPILED>>
			   <SET WDATE <CHANNEL-OP .TCH WRITE-DATE>>>
		      <CLOSE .TCH>
		      <SET NM2 "MIMA">
		      <COND (<SET TCH <OPEN "READ" .N1>>
			     <COND (<G? .WDATE <CHANNEL-OP .TCH WRITE-DATE>>
				    <PRINC
				     "Precompiled is more recent than source.">
				    <CRLF>
				    <EXIT>)>
			     <CLOSE .TCH>)>)>
	       <SET PACKAGE-MODE .N1>
	       <MAPF <> ,EVAL <REST .THINGS>>
	       <SET NM2 "MIMA">
	       <COND (.DOC
		      <DOC !.FIL>)
		     (,GLUE-MODE
		      <FILE-GLUE !.FIL>)
		     (T
		      <FILE-MIMOC !.FIL>)>  
	       <PRINC "
Done.">
	       <QUIT>)>>

<DEFINE LEX (BUF LEN)
  #DECL ((BUF) STRING (LEN) FIX)
  <SET BUF <SUBSTRUC .BUF 0 .LEN <REST .BUF <- <LENGTH .BUF> .LEN>>>>
  <REPEAT ((L ("")) CHR (LS <>))
    <COND (<EMPTY? .BUF>
	   <COND (.LS
		  <PUTREST <REST .L <- <LENGTH .L> 1>> (<STRING .LS>)>)>
	   <RETURN <REST .L>>)>
    <COND (<MEMQ <SET CHR <1 .BUF>> " 	,
">
	   <COND (.LS
		  <SET LS <SUBSTRUC .LS 0 <- <LENGTH .LS><LENGTH .BUF>>>>
		  <PUTREST <REST .L <- <LENGTH .L> 1>> (.LS)>
		  <SET LS <>>)>)
	  (<NOT .LS>
	   <SET LS .BUF>)>
    <SET BUF <REST .BUF>>>>
