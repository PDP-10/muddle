<USE "NEWSTRUC" "MISC-IO" "JCL">

<SETG VERBOSE? T>

<DEFINE SAVE-MUDCOM ("AUX" A)
        #DECL ((A) <OR FALSE VECTOR>)
	<COND (<=? <SAVE "MUDCOM.SAVE"> "RESTORED">
	       <COND (<SET A <READARGS>>
		      <MUDCOM !.A>)
		     (ELSE
		      <PRINC "mudcom [oldfile] newfile
">)>
	       <QUIT>)>>

<DEFINE MUDCOM (OLDFILE "OPT" NEWFILE
		"AUX" NEWCHAN OLDCHAN OLDREST NEWSTART L OLD (NM2 "MIMA")
		(OUTCHAN .OUTCHAN))
	#DECL ((NEWFILE OLDFILE NEWSTART OLDREST) STRING (OUTCHAN) CHANNEL
	       (NEWCHAN OLDCHAN) <OR FALSE CHANNEL>
	       (NM2) <SPECIAL STRING> (L) <OR LIST FALSE> (OLD) <OR FALSE STRING>)
	<IFSYS (UNIX
		<COND (<AND <NOT <ASSIGNED? NEWFILE>>
			    <NOT <MEMBER ".BAK" .OLDFILE>>>
		       <COND (<NOT <MEMBER !\. .OLDFILE>>
			      <SET OLDFILE <STRING .OLDFILE ".MUD">>)>
		       <COND (<SET OLDCHAN
				   <OPEN "READ" <STRING .OLDFILE ".BAK">>>)
			     (ELSE
			      <SET OLDREST .OLDFILE>
			      <REPEAT (TMP)
				 <COND (<SET TMP <MEMQ !\/ .OLDFILE>>
					<SET OLDREST <REST .TMP>>)
				       (ELSE <RETURN>)>>
			      <COND (<G? <LENGTH .OLDREST> 10>
				     <SET OLDCHAN
					  <OPEN "READ"
						<STRING <SUBSTRUC .OLDFILE 0 10>
							".BAK">>>)>)>)
		      (ELSE <SET OLDCHAN <OPEN "READ" .OLDFILE>>)>)
	       (TOPS-20
		<SET OLDCHAN <OPEN "READ" .OLDFILE>>)>
	<COND (.OLDCHAN
	       <COND (<NOT <ASSIGNED? NEWFILE>>
		      <SET NEWSTART
			   <CHANNEL-OP .OLDCHAN NAME %<+ 16 8 4>>>
		      <SET NEWFILE <STRING .NEWSTART ".MUD">>)>
	       <SET NM2 "MUD">
	       <COND (<SET NEWCHAN <OPEN "READ" .NEWFILE>>
		      <SET OLDFILE <CHANNEL-OP .OLDCHAN NAME>>
		      <IFSYS
		       (TOPS-20
			<COND (<N=? <CHANNEL-OP .OLDCHAN NAME 2> ".MUD">
			       <COND (<SET OLD <FIND-OLD .OLDCHAN .NEWCHAN>>
				      <CLOSE .OLDCHAN>
				      <COND (<SET OLDCHAN <OPEN "READ" .OLD>>
					     <SET OLDFILE
						  <CHANNEL-OP .OLDCHAN NAME>>)
					    (ELSE
					     <SET OLDFILE .OLD>)>)
				     (ELSE
				      <CLOSE .OLDCHAN>
				      <SET OLDCHAN .OLD>)>)>)>
		      <PRINC "Comparing ">
		      <PRINC .OLDFILE>
		      <PRINC " with ">
		      <PRINC <CHANNEL-OP .NEWCHAN NAME>>
		      <CRLF>
		      <COND (.OLDCHAN
			     <SET L <FILE-COMPARE .NEWCHAN .OLDCHAN>>
			     <COND (,VERBOSE? <MUDCOM-PRINT .L> T)
				   (ELSE .L)>)
			    (ELSE
			     <CLOSE .NEWCHAN>
			     .OLDCHAN)>)
		     (ELSE <OPEN-FAILED .NEWCHAN>)>)
	      (ELSE
	       <OPEN-FAILED .OLDCHAN>)>>

<DEFINE OPEN-FAILED (F "AUX" (OUTCHAN .OUTCHAN))
	#DECL ((F) FALSE (OUTCHAN) CHANNEL)
	<PRINC "Open of ">
	<PRINC <2 .F>>
	<PRINC " failed: ">
	<PRINC <1 .F>>
	<>>

<DEFINE FIND-OLD (OLDCHAN NEWCHAN
		  "AUX" (CMPDATE 0) (CMPFILE #FALSE ("No older file"))
		  (R T) C OLDDATE NEWDATE NEW)
	#DECL ((OLDCHAN NEWCHAN) <OR CHANNEL FALSE> (CMPDATE OLDDATE NEWDATE) FIX)
	<COND (<L? <SET OLDDATE <CHANNEL-OP .OLDCHAN WRITE-DATE>>
		   <SET NEWDATE <CHANNEL-OP .NEWCHAN WRITE-DATE>>>
	       <SET NEW <STRING <CHANNEL-OP .NEWCHAN NAME %<+ 16 8 4 2>>
				".*">>
	       <SET C <CHANNEL-OPEN GNJFN .NEW .NEW>>
	       <MAPF <>
		     <FUNCTION ()
			  <COND (<NOT .R>
				 <CLOSE .C>
				 <MAPLEAVE .CMPFILE>)
				(<AND <L? <SET NEWDATE <CHANNEL-OP .C WRITE-DATE>>
					  .OLDDATE>
				      <G? .NEWDATE .CMPDATE>>
				 <SET CMPFILE <CHANNEL-OP .C NAME>>
				 <SET CMPDATE .NEWDATE>)
				(ELSE
				 <SET R <CHANNEL-OP .C NEXT-FILE>>)>>>)
	      (ELSE .CMPFILE)>>

<DEFINE MUDCOM-PRINT (L "AUX" (OUTCHAN .OUTCHAN))
	#DECL ((L) <OR FALSE <LIST [REST <VECTOR STRING ATOM ANY>]>>
	       (OUTCHAN) CHANNEL)
	<COND (<NOT .L>
	       <PRINC <1 .L>>
	       <PRINC !\ >
	       <PRIN1 <2 .L>>)
	      (<EMPTY? .L> <PRINC "No differences."> <CRLF>)
	      (ELSE
	       <MAPF <>
		     <FUNCTION (V)
			  #DECL ((V) <VECTOR STRING ATOM ANY>)
			  <PRINC <COND (<==? <3 .V> 'N==?> "Changed ")
				       (<==? <3 .V> '+> "Added ")
				       (<==? <3 .V> '-> "Removed ")>>
			  <PRINC <2 .V>>
			  <PRINC !\ >
			  <PRINC <1 .V>>
			  <CRLF>>
		     .L>)>>

<DEFINE FILE-COMPARE (NEWCHAN OLDCHAN
		      "AUX" NEW OLD (NEWNAME <CHANNEL-OP .NEWCHAN NAME>)
		      (OLDNAME <CHANNEL-OP .OLDCHAN NAME>))
	#DECL ((NEW OLD) <OR FALSE LIST> (NEWNAME OLDNAME) STRING)
	<COND (<AND <SET NEW <FILE-HASH .NEWCHAN>>
		    <SET OLD <FILE-HASH .OLDCHAN>>>
	       <MAPF ,LIST
		     <FUNCTION ("AUX" N)
			  #DECL ((N) <OR <VECTOR STRING ATOM ANY> FALSE>)
			  <COND (<EMPTY? .NEW>
				 <COND (<EMPTY? .OLD> <MAPSTOP>)
				       (ELSE
					<SET N <1 .OLD>>
					<SET OLD <REST .OLD>>
					<COND (.N
					       <PUT .N 3 '->
					       <MAPRET .N>)
					      (ELSE <MAPRET>)>)>)
				(ELSE
				 <SET N <1 .NEW>>
				 <SET NEW <REST .NEW>>
				 <COND (<DIFF? .N .OLD>
					<MAPRET .N>)
				       (ELSE <MAPRET>)>)>>>)
	      (.NEW <CHTYPE (.OLDNAME .OLD) FALSE>)
	      (ELSE <CHTYPE (.NEWNAME .NEW) FALSE>)>>

<DEFINE DIFF? (N OL)
	#DECL ((N) <VECTOR STRING ATOM ANY> (OL) LIST)
	<MAPR <>
	      <FUNCTION (OL "AUX" (O <1 .OL>))
		   #DECL ((OL) LIST (O) <OR FALSE <VECTOR STRING ATOM ANY>>)
		   <COND (<AND .O <=? <1 .N> <1 .O>>>
			  <PUT .OL 1 <>>
			  <COND (<AND <==? <2 .N> <2 .O>>
				      <==? <3 .N> <3 .O>>>
				 <MAPLEAVE <>>)
				(ELSE
				 <PUT .N 3 'N==?>
				 <MAPLEAVE .N>)>)
			 (<EMPTY? <REST .OL>>
			  <PUT .N 3 '+>
			  <MAPLEAVE .N>)>>
	      .OL>>

<SETG BUFFER <REST <SETG TOPBUFFER <ISTRING 1000>> 1000>>
<SETG N 0>
<SETG BLANKS " 	
">
<SETG BRACKETS <ISTRING 100>>
<GDECL (TOPBUFFER BUFFER BLANKS BRACKETS) STRING (N) FIX>

<MSETG ITEM-NAME 1>
<MSETG ITEM-TYPE 2>
<MSETG ITEM-CODE 3>

<DEFINE FILE-HASH (FIL "AUX" CHAN (ITEM-LIST ()) ITEM
		   (BLANKS ,BLANKS) (QUOTE? <>) (STR? <>) (BLANK? <>)
		   (WAS-BLANK? <>) (BRACKETS ,BRACKETS) LEFT
		   (BUFFER ,BUFFER) (LEVEL 0) (HASH? <>) CHR)
	#DECL ((BUFFER BLANKS BRACKETS) STRING (CHAN) <OR FALSE CHANNEL>
	       (FIL) <OR STRING CHANNEL> (ITEM-LIST) LIST (LEFT) CHARACTER
	       (ITEM) <OR FALSE VECTOR> (QUOTE? STR? BLANK?) <OR ATOM FALSE>
	       (LEVEL) FIX (HASH?) <OR FALSE FIX> (CHR) <OR CHARACTER FALSE>)
	<COND (<SET CHAN
		    <COND (<TYPE? .FIL STRING> <OPEN "READ" .FIL>)
			  (ELSE .FIL)>>
	       <SETG BUFFER <REST .BUFFER <LENGTH .BUFFER>>>
	       <SETG N 0>
	       <SETG CHAN .CHAN>
	       <REPEAT ()
		       <PROG ((BUFFER ,BUFFER) (N ,N))
			     #DECL ((BUFFER) STRING (N) FIX)
			     <COND (<EMPTY? .BUFFER>
				    <SET BUFFER <SETG BUFFER ,TOPBUFFER>>
				    <COND (<G? <SET N
						    <CHANNEL-OP ,CHAN
								READ-BUFFER
								.BUFFER>>
					       0>)
					  (ELSE <RETURN <SET CHR <>>>)>)
				   (<0? .N> <RETURN <SET CHR <>>>)>
			     <SET CHR <1 .BUFFER>>
			     <SETG BUFFER <REST .BUFFER>>
			     <SETG N <- .N 1>>>
		       <COND (<NOT .CHR>
			      <CLOSE .CHAN>
			      <RETURN
			       <COND (<N==? .BRACKETS ,BRACKETS>
				      <CHTYPE ("EOF" <1 <BACK .BRACKETS>> .ITEM)
					      FALSE>)
				     (.STR?
				      <CHTYPE ("UNTERMINATED STRING" <> .ITEM)
					      FALSE>)
				     (ELSE .ITEM-LIST)>>)>
		       <COND (<AND <NOT .STR?>
				   <NOT .QUOTE?>
				   <MEMQ .CHR .BLANKS>>
			      <COND (.BLANK? <AGAIN>)
				    (ELSE
				     <SET BLANK? T>
				     <SET CHR !\ >)>)
			     (ELSE
			      <SET WAS-BLANK? .BLANK?>
			      <SET BLANK? <>>)>
		       <COND (.HASH?
			      <SET HASH? <XORB <ASCII .CHR> <ROT .HASH? 5>>>)>
		       <COND (.QUOTE? <SET QUOTE? <>>)
			     (<==? .CHR %<ASCII 92>> <SET QUOTE? T>)
			     (<==? .CHR !\"> <SET STR? <NOT .STR?>>)
			     (.STR?)
			     (<MEMQ .CHR "<[({">
			      <SET BRACKETS <REST <PUT .BRACKETS 1 .CHR>>>
			      <COND (<AND <==? .LEVEL 0> <==? .CHR !\<>>
				     <COND (<SET ITEM <DO-TLF>>
					    <SET HASH? 0>)>)
				    (<AND .HASH? <NOT .WAS-BLANK?>>
				     <SET HASH?
					  <XORB <ASCII !\ > <ROT .HASH? 5>>>)>
			      <SET LEVEL <+ .LEVEL 1>>)
			     (<MEMQ .CHR ">])}">
			      <COND (<==? .BRACKETS ,BRACKETS>
				     <CLOSE .CHAN>
				     <RETURN <CHTYPE ("EXTRA" .CHR .ITEM) FALSE>>)
				    (ELSE
				     <SET LEFT
					  <1 <SET BRACKETS
						  <CALL BACKU .BRACKETS 1>>>>)>
			      <COND (<OR <AND <==? .LEFT !\<>
					      <==? .CHR !\>>>
					 <AND <==? .LEFT !\[>
					      <==? .CHR !\]>>
					 <AND <==? .LEFT !\(>
					      <==? .CHR !\)>>
					 <AND <==? .LEFT !\{>
					      <==? .CHR !\}>>>)
				    (ELSE
				     <CLOSE .CHAN>
				     <RETURN <CHTYPE (.LEFT .CHR .ITEM) FALSE>>)>
			      <COND (<AND .HASH? <NOT .WAS-BLANK?>>
				     <SET HASH?
					  <XORB <ASCII !\ > <ROT .HASH? 5>>>)>
			      <COND (<==? <SET LEVEL <- .LEVEL 1>> 0>
				     <COND (.ITEM
					    <ITEM-CODE .ITEM .HASH?>
					    <SET ITEM-LIST (.ITEM !.ITEM-LIST)>)>
				     <SET HASH? <>>)>)>>)>>

<DEFINE DO-TLF ("AUX" (TYP <>) BUF NAM)
	#DECL ((TYP) <OR ATOM FALSE> (BUF) <OR FIX FALSE>
	       (NAM) <OR STRING FALSE>)
	<COND (<SET BUF <CHECK-FOR "SET">>
	       <SET TYP LVAL>)
	      (<SET BUF <CHECK-FOR "SETG">>
	       <SET TYP GVAL>)
	      (<SET BUF <CHECK-FOR "MSETG">>
	       <SET TYP MANIFEST>)
	      (<SET BUF <CHECK-FOR "DEFINE">>
	       <SET TYP FUNCTION>)
	      (<SET BUF <CHECK-FOR "DEFMAC">>
	       <SET TYP MACRO>)>
	<COND (<AND .TYP <SET NAM <NEXT-TOKEN .BUF>>>
	       <VECTOR .NAM .TYP 0>)>>

<DEFINE CHECK-FOR (STR "AUX" BUF N (BUFFER ,BUFFER) (M ,N) BLANKS)
	#DECL ((STR BUFFER BLANKS BUF) STRING (N M) FIX)
	<PROG ()
	      <COND (<L=? .M <LENGTH .STR>>
		     <SUBSTRUC .BUFFER 0 .M
			       <SETG BUFFER ,TOPBUFFER>>
		     <SET BUFFER ,BUFFER>
		     <SET BUF <REST .BUFFER .M>>
		     <COND (<G? <SET N <CHANNEL-OP ,CHAN READ-BUFFER .BUF>>
				0>
			    <SETG N <+ .N .M>>)
			   (ELSE <RETURN <>>)>)>
	      <COND (<AND <FIRST? .STR .BUFFER>
			  <MEMQ <NTH .BUFFER <+ 1 <SET N <LENGTH .STR>>>>
				<SET BLANKS ,BLANKS>>>
		     .N)>>>

<DEFINE NEXT-TOKEN (O "AUX" N (START? <>) (M ,N) (BUFFER ,BUFFER)
		    BUF BLANKS)
	#DECL ((BUF BUFFER BLANKS) STRING
	       (START?) <OR ATOM FALSE> (M O N) FIX)
	<PROG ()
	      <COND (<L=? .M 100>
		     <SUBSTRUC .BUFFER
			       0 .M
			       <SETG BUFFER ,TOPBUFFER>>
		     <SET BUFFER ,BUFFER>
		     <SET BUF <REST .BUFFER .M>>
		     <COND (<G? <SET N <CHANNEL-OP ,CHAN READ-BUFFER .BUF>>
				0>
			    <SETG N <+ .N .M>>)>)
		    (ELSE <SET BUF ,BUFFER>)>
	      <SET BUF <REST .BUFFER .O>>
	      <MAPF ,STRING
		    <FUNCTION (CHR)
			 #DECL ((CHR) CHARACTER)
			 <COND (<NOT .START?>
				<COND (<MEMQ .CHR <SET BLANKS ,BLANKS>>
				       <MAPRET>)
				      (ELSE
				       <SET START? T>
				       <MAPRET .CHR>)>)
			       (<MEMQ .CHR <SET BLANKS ,BLANKS>>
				<MAPSTOP>)
			       (ELSE
				<MAPRET .CHR>)>>
		    .BUF>>>

<DEFINE FIRST? (STR BUF)
	#DECL ((STR BUF) STRING)
	<MAPF <>
	      ,==?
	      .STR
	      .BUF>>
