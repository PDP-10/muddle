
<PACKAGE "FILE-INDEX">

<ENTRY BUILD-INDEX SKIP-MIMA>

<SETG BUFLENGTH 1024>

<SETG BUFFER <ISTRING ,BUFLENGTH>>

<SETG MAGIC-CHAR <ASCII 26>					  ;"Control Z">

<SETG LAST-CHAR1 !\0>

<SETG LAST-CHAR2 !\]>

<SETG LAST-CHAR3 !\>>

<SETG WORD-STRING "#WORD "		    ;"Comes before hash codes">

<SETG MAGIC-STRING "<SETG "		    ;"Comes before MSUBRs and IMSUBRs">

<SETG MAGIC-LENGTH <LENGTH ,MAGIC-STRING>>

<SETG MAGIC-MAX <- ,BUFLENGTH ,MAGIC-LENGTH>>

<SETG MAGIC-STRING2 "<END "			      ;"Comes at end of MIMAs">

<SETG MAGIC-LENGTH2 <LENGTH ,MAGIC-STRING2>>

<SETG MAGIC-MAX2 <- ,BUFLENGTH ,MAGIC-LENGTH2>>

<SETG IN-ATOM 0>

<SETG NEED-MINUS 1>

<SETG QUOTE-NEXT 2>

<SETG NON-ATOM 3>

<SETG M$$R-EXCL 8>

<SETG M$$R-BACKS 15>

<SETG M$$R-ALPHA 16>

<SETG M$$R-E 17>

<SETG M$$R-DIGIT 19>

<SETG M$$R-PLUS 20>

<SETG M$$R-STAR 21>

<MANIFEST IN-ATOM
	  NEED-MINUS
	  QUOTE-NEXT
	  NON-ATOM
	  M$$R-BACKS
	  M$$R-ALPHA
	  M$$R-EXCL
	  M$$R-E
	  M$$R-DIGIT
	  M$$R-PLUS>

<GDECL (I$TRANS-TABLE!-INTERNAL) BYTES>

<COND (<NOT <GASSIGNED? I$TRANS-TABLE!-INTERNAL>>
       <SETG I$TRANS-TABLE!-INTERNAL
	     <BYTES 8
		    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0
		    0 0 0 8 5 10 16 12 16 13 2 7 21 20 11 20 18 16 19 19 19 19 19
		    19 19 19 19 19 0 9 3 16 7 16 16 16 16 16 16 17 16 16 16 16 16
		    16 16 16 16 16 16 16 16 16 16 16 16 16 16 16 16 4 15 7 16 16
		    16 16 16 16 16 17 16 16 16 16 16 16 16 16 16 16 16 16 16 16 16
		    16 16 16 16 16 16 6 14 7 16 16>>)>

<DEFMAC GET-ACCESS ('CHAN)
	<COND (<GASSIGNED? NEW-CHANNEL-TYPE> <FORM ACCESS .CHAN>)
	      (ELSE <FORM 17 .CHAN>)>> 

<DEFINE BUILD-INDEX (CHAN OBL
		     "AUX" (B ,BUFFER) (BL ,BUFLENGTH) (CHAR ,MAGIC-CHAR)
			   (MAXL ,MAGIC-MAX) (TOTAL-ACCESS <- .BL>)
			   (MS ,MAGIC-STRING) (ML ,MAGIC-LENGTH)
			   (LC1 ,LAST-CHAR1) (LC2 ,LAST-CHAR2)
			   (LC3 ,LAST-CHAR3) SL (WS ,WORD-STRING)
			   WRD SETG-OK WORD-OK)
   #DECL ((CHAN) CHANNEL (WS MS B) STRING (WRD ML BL MAXL TOTAL-ACCESS SL) FIX
	  (OBL) OBLIST (CHAR LC1 LC2 LC3) CHARACTER)
   <REPEAT OUTER (START PL LEN POS (IM-POS <>) (INDEX ()) NAMESTR NAME-ATOM)
     #DECL ((PL LEN) FIX (POS) <OR FALSE STRING> (START) STRING)
     <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
     <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>
     <REPEAT ((BB .B))
       #DECL ((BB) STRING)
       <COND
	(<AND <SET POS <MEMQ .CHAR .BB>>
	      <SET PL <LENGTH .POS>>
	      <OR <==? .LEN .BL> <G? .PL <- .BL .LEN>>>>
	 <COND (<G? .PL .MAXL>			       ;"Foo! must back access"
		<COND (<G? .TOTAL-ACCESS 0>
		       <ACCESS .CHAN <SET TOTAL-ACCESS <- .TOTAL-ACCESS .ML>>>
		       <SET TOTAL-ACCESS <- .TOTAL-ACCESS .BL>>
		       <AGAIN .OUTER>)
		      (ELSE				  ;"Must be bogus char"
		       <SET BB <REST .POS>> <AGAIN>)>)>
	 <SET SL <LENGTH <SET START <REST .B <- .BL .PL .ML>>>>>
	 <SET SETG-OK <SET WORD-OK T>>
	 <COND
	  (<MAPF <>
		 <FUNCTION (C1 C2 C3) 
			 #DECL ((C1 C2 C3) CHARACTER)
			 <COND (<N==? .C1 .C2> <SET SETG-OK <>>)>
			 <COND (<N==? .C1 .C3> <SET WORD-OK <>>)>
			 .SETG-OK>
		 .START
		 .MS
		 .WS>
	   <SET NAMESTR
	    <MAPF ,STRING
	     <FUNCTION ("AUX" CH) 
		     <COND (<EMPTY? <SET POS <REST .POS>>>
			    <SET SL <+ .SL .BL>>
			    <COND (<L? .LEN .BL>
				   <ERROR BAD-FILE!-ERRORS .CHAN>)>
			    <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
			    <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>
			    <SET POS .B>)>
		     <COND (<OR <==? <SET CH <1 .POS>> <ASCII 32>>
				<==? .CH !\!>>
			    <MAPSTOP>)
			   (ELSE .CH)>>>>
	   <SET NAME-ATOM <OR <LOOKUP .NAMESTR .OBL> <INSERT .NAMESTR .OBL>>>
	   <COND
	    (.IM-POS
	     <PROG (CH)
		   <COND
		    (<SET POS <MEMQ .LC1 .POS>>
		     <SET POS <REST .POS>>
		     <PROG ()
			   <COND (<EMPTY? .POS>
				  <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
				  <SET POS .B>
				  <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>)>
			   <COND (<L=? <ASCII <SET CH <1 .POS>>> 32>
				  <SET POS <REST .POS>>
				  <AGAIN>)>>
		     <COND (<N==? <1 .POS> .LC2> <AGAIN>)>
		     <SET POS <REST .POS>>
		     <PROG ()
			   <COND (<EMPTY? .POS>
				  <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
				  <SET POS .B>
				  <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>)>
			   <COND (<L=? <ASCII <SET CH <1 .POS>>> 32>
				  <SET POS <REST .POS>>
				  <AGAIN>)>>
		     <COND (<N==? <1 .POS> .LC3> <AGAIN>)>
		     <SET POS <REST .POS>>)
		    (ELSE
		     <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
		     <SET POS .B>
		     <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>
		     <AGAIN>)>>
	     <SET INDEX
		  ((.NAME-ATOM .IM-POS <+ .TOTAL-ACCESS <- .BL <LENGTH .POS>>>
		    !<COND (<ASSIGNED? WRD> (<CHTYPE .WRD WORD>))
			   (ELSE ())>)
		   !.INDEX)>
	     <SET IM-POS <>>)
	    (ELSE <SET IM-POS <+ .TOTAL-ACCESS <- .BL .SL>>>)>)
	  (.WORD-OK
	   <SET WRD 0>
	   <MAPF <>
	     <FUNCTION ("AUX" CH) 
		     <COND (<EMPTY? <SET POS <REST .POS>>>
			    <SET SL <+ .SL .BL>>
			    <COND (<L? .LEN .BL>
				   <ERROR BAD-FILE!-ERRORS .CHAN>)>
			    <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
			    <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>
			    <SET POS .B>)>
		     <COND (<==? <SET CH <1 .POS>> !\*>
			    <COND (.WORD-OK <SET WORD-OK <>>)
				  (ELSE <MAPLEAVE>)>)
			   (<NOT .WORD-OK>
			    <SET WRD <ORB <LSH .WRD 3>
					  <- <ASCII .CH> <ASCII !\0>>>>)>>>)>
	 <SET BB .POS>)
	(ELSE <RETURN>)>>
     <COND (<N==? .LEN .BL> <RETURN .INDEX>)>>>

<DEFINE SKIP-MIMA (CHAN NAME "OPT" (FUDGE -2)
		   "AUX" (MCHAR ,MAGIC-CHAR) (MS ,MAGIC-STRING2)
				   (ML ,MAGIC-LENGTH2) (MAXL ,MAGIC-MAX2)
				   (SPN <SPNAME .NAME>) (ECHAR ,LAST-CHAR3))
   #DECL ((CHAN) CHANNEL (NAME) ATOM (MS) STRING (MAXL ML) FIX
	  (MCHAR ECHAR) CHARACTER)
   <REPEAT OUTER ((B ,BUFFER) (BL ,BUFLENGTH) POS PL LEN
		  (TOTAL-ACCESS <- <GET-ACCESS .CHAN> .BL>))
	   #DECL ((B) STRING (LEN PL BL TOTAL-ACCESS) FIX
		  (POS) <OR FALSE STRING>)
	   <SET LEN <CHANNEL-OP .CHAN READ-BUFFER .B>>
	   <SET TOTAL-ACCESS <+ .TOTAL-ACCESS .BL>>
	   <REPEAT ((BB .B) (STATE ,IN-ATOM))
		   #DECL ((BB) STRING (STATE) FIX)
	       <COND (<AND <SET POS <MEMQ .MCHAR .BB>>
			   <SET PL <LENGTH .POS>>
			   <OR <==? .BL .LEN> <G? .PL <- .BL .LEN>>>>
		      <COND (<G? .PL .MAXL>
			     <COND (<G? .TOTAL-ACCESS 0>
				    <ACCESS .CHAN
					    <SET TOTAL-ACCESS
						 <- .TOTAL-ACCESS .ML>>>
				    <SET TOTAL-ACCESS <- .TOTAL-ACCESS .BL>>
				    <AGAIN .OUTER>)
				   (ELSE
				    <SET BB <REST .POS>>
				    <AGAIN>)>)>
		      <COND
		       (<MAPF <>
			      <FUNCTION (C1 C2)
				   #DECL ((C1 C2) CHARACTER)
				   <COND (<N==? .C1 .C2>
					  <MAPLEAVE <>>)>
				   1>
			      <REST .B <- .BL .PL .ML>>
			      .MS>
			<MAPF <>
			      <FUNCTION ("AUX" C2)
				  <COND (<EMPTY? <SET POS <REST .POS>>>
					 <COND (<N==? .LEN .BL>
						<ERROR BAD-MIMA!-ERRORS
						       .NAME>)>
					 <SET LEN <CHANNEL-OP .CHAN
							      READ-BUFFER
							      <SET POS .B>>>
					 <SET TOTAL-ACCESS
					      <+ .TOTAL-ACCESS .BL>>)>
				  <SET C2 <1 .POS>>
				  <COND (<EMPTY? .SPN>
					 <COND (<==? .C2 .ECHAR> <MAPLEAVE>)
					       (<==? <SET STATE
							  <SKIP-TRL .C2 .STATE>>
						     ,NON-ATOM>
						<ERROR BAD-MIMA!-ERRORS .NAME>)>)
					(<N==? .C2 <1 .SPN>>
					 <ERROR BAD-MIMA!-ERRORS .NAME>)
					(ELSE <SET SPN <REST .SPN>>)>>>
			<ACCESS .CHAN
				<+ .TOTAL-ACCESS <- .BL <LENGTH .POS>
						    .FUDGE>>>
			<RETURN T .OUTER>)
		       (ELSE <SET BB <REST .POS>>)>)
		     (ELSE <RETURN>)>>
	   <COND (<N==? .LEN .BL> <ERROR BAD-MIMA!-ERRORS .NAME>)>>>

<DEFINE SKIP-TRL (CHAR STATE "AUX" (TRNS <NTH ,I$TRANS-TABLE!-INTERNAL
					      <+ <ASCII .CHAR> 1>>))
		 #DECL ((CHAR) CHARACTER (TRNS STATE) FIX)
	<COND (<AND <==? .STATE ,IN-ATOM> <==? .TRNS ,M$$R-EXCL>> ,NEED-MINUS)
	      (<==? .STATE ,NEED-MINUS>
	       <COND (<==? .CHAR !\-> ,IN-ATOM) (ELSE ,NON-ATOM)>)
	      (<==? .STATE ,QUOTE-NEXT> ,IN-ATOM)
	      (<==? .TRNS ,M$$R-BACKS> ,QUOTE-NEXT)
	      (<OR <==? .TRNS ,M$$R-ALPHA>
		   <==? .TRNS ,M$$R-DIGIT>
		   <==? .TRNS ,M$$R-PLUS>
		   <==? .TRNS ,M$$R-E>
		   <==? .TRNS ,M$$R-STAR>> ,IN-ATOM)
	      (ELSE ,NON-ATOM)>>
<ENDPACKAGE>
