;"This is the MUM/MDL bootstrap file.  One hopes that, when compiled,
this file will cause an MDL to be brought up and initialized.
Fat chance."


;"READ part of bootstrap"

<DEFINE T$READ (T$INCHAN "AUX" VAL)
	#DECL ((T$INCHAN) <SPECIAL VECTOR>)
	<SETG I$CONT <>>
	<SETG I$R? .T$INCHAN>
	<COND (<TYPE? <I$RDBUF .T$INCHAN> T$UNBOUND>
	       <CHTYPE ,ZERO T$UNBOUND>)
	      (T <I$PARSE>)>>

<DEFINE I$RDBUF (C "AUX" (BUF <M$$BUFF .C>) LEN)
        #DECL ((C) T$BCHANNEL (BUF) STRING (LEN) FIX)
	<COND (<AND <NOT <0? <M$$BPOS .C>>> <NOT <EMPTY? .BUF>>>
	       <SETG BI$STR <REST .BUF <- <M$$BUFL .C> <M$$BPOS .C>>>>)
	      (T
	       <M$$BPOS .C
			<SET LEN <CALL READ <M$$CHAN .C>
				       .BUF
				       <LENGTH .BUF>
				       0>>>
	       <M$$BUFL .C .LEN>
	       <SETG BI$STR .BUF>
	       <COND (<0? <M$$BPOS .C>>
		      <CHTYPE ,ZERO T$UNBOUND>)>)>>

<DEFINE T$RCHR (CHN)
	#DECL ((CHN) VECTOR)
	<CALL READ <M$$CHAN .CHN> ,I$CHRSTR 1 0>
	<1 ,I$CHRSTR>>

<DEFINE I$NXTCHR ("AUX" CHR NCHR (R ,I$R?))
	#DECL ((CHR) CHARACTER (NCHR) <OR CHARACTER FALSE>
	       (R) <OR FALSE T$BCHANNEL>)
	<COND (<SET NCHR ,BI$NCHR>
	       <SETG BI$NCHR <>>
	       .NCHR)
	      (<OR <AND .R <0? <M$$BPOS .R>>>
		   <AND <NOT .R> <EMPTY? ,BI$STR>>>
	       <COND (.R
		      <COND (<OR ,I$CONT
				 <N==? <M$$CHAN .R> 64>>
			     <SETG I$CONT <>>
			     <AND <==? <M$$CHAN .R> 64>
				  <T$RCHR .R>>
			     <COND (<TYPE? <I$RDBUF .R> T$UNBOUND>
				    <CHTYPE ,ZERO CHARACTER>)
				   (T <I$NXTCHR>)>)
			    (T
			     <SETG I$CONT T>
			     <CHTYPE ,ZERO CHARACTER>)>)
		     (T <CHTYPE ,ZERO CHARACTER>)>)
	      (T
	       <SET CHR <1 ,BI$STR>>
	       <SETG BI$STR <REST ,BI$STR>>
	       <AND .R <M$$BPOS .R <- <M$$BPOS .R> 1>>>
	       .CHR)>>

<DEFINE I$PARSE ("OPTIONAL" (PFX <>) "AUX" CHR ASC NCHR TYP)
	#DECL ((CHR NCHR) CHARACTER (ASC) FIX (TYP) ANY
	       (PFX) <OR ATOM FALSE>)
	<REPEAT ()
		<COND (<MEMQ <SET CHR <I$NXTCHR>> ,BREAKS>)
		      (T
		       <RETURN>)>>
	<SET ASC <ASCII .CHR>>
	<COND (<==? .CHR !\(>
	       <RETVAL <I$PLIST> .PFX>)
	      (<==? .CHR !\<>
	       <RETVAL <CHTYPE <I$PLIST !\>> FORM> .PFX>)
	      (<==? .CHR !\[>
	       <RETVAL <I$PVECTOR> .PFX>)
	      (<==? .CHR !\">
	       <RETVAL <I$PSTRING> .PFX>)
	      (<==? .CHR !\|>
	       <RETVAL <I$PMCODE> .PFX>)
	      (<MEMQ .CHR ")]>">
	       <CHTYPE .ASC T$UNBOUND>)
	      (<==? .CHR !\!>
	       <COND (<==? <SET NCHR <I$NXTCHR>> <ASCII 0>>
		      <CHTYPE ,ZERO T$UNBOUND>)
		     (<==? .NCHR <ASCII 92>>
		      <SET CHR <I$NXTCHR>>
		      <RETVAL .CHR .PFX>)
		     (<==? .NCHR !\<>
		      <RETVAL <CHTYPE <I$PLIST !\>> SEGMENT> .PFX>)
		     (<==? .NCHR !\>>
		      <CHTYPE .NCHR T$UNBOUND>)
		     (<T$ERROR %<P-E "BAD-USE-OF-EXCL">>)>)
	      (<OR <AND <G=? .ASC <ASCII !\0>>
		        <L=? .ASC <ASCII !\9>>>
		   <==? .CHR !\+>
		   <==? .CHR !\->>
	       <SETG BI$NCHR .CHR>
	       <RETVAL <I$PNUMBER> .PFX>)
	      (<==? .CHR !\#>
	       <SET TYP <I$PARSE>>
	       <COND (<TYPE? .TYP FIX>
		      <SETG BI$RADIX .TYP>
		      <RETVAL <I$PARSE> .PFX>)
		     (T
		      <RETVAL <T$CHTYPE <I$PARSE> .TYP> .PFX>)>)
	      (<==? .CHR !\%>
	       <COND (<==? <SET NCHR <I$NXTCHR>> !\%>
		      <T$EVAL <I$PARSE>>
		      <I$PARSE>)
		     (T
		      <SETG BI$NCHR .NCHR>
		      <T$EVAL <I$PARSE>>)>)
	      (<==? .CHR !\,>
	       <SET TYP <I$PARSE T>>
	       <RETVAL <FORM <LOOKUP "GVAL" ,M$$ROOT> .TYP> .PFX>)
	      (<==? .CHR !\'>
	       <RETVAL <FORM <LOOKUP "QUOTE" ,M$$ROOT> <I$PARSE T>> .PFX>)
	      (<==? .CHR !\.>
	       <SETG I$FRC T>
	       <SET TYP <I$PARSE T>>
	       <SETG I$FRC <>>
	       <COND (<TYPE? .TYP FLOAT>
		      <RETVAL .TYP .PFX>)
		     (T
		      <RETVAL <FORM <LOOKUP "LVAL" ,M$$ROOT> .TYP> .PFX>)>)
	      (<==? .CHR !\;>
	       <I$PARSE>
	       <I$PARSE>)
	      (T
	       <SETG BI$NCHR .CHR>
	       <RETVAL <I$PNUMBER T> .PFX>)>> 
		       
<DEFINE RETVAL (RET PFX)
	#DECL ((RET) ANY (PFX) <OR ATOM FALSE>)
	.RET>

<DEFINE I$PLIST ("OPTIONAL" (TERM !\)))
	#DECL ((TERM) CHARACTER)
	<MAPF ,LIST
	      <FUNCTION ("AUX" ITM)
		   #DECL ((ITM) ANY)
		   <COND (<TYPE? <SET ITM <I$PARSE>> T$UNBOUND>
			  <COND (<OR <==? <CHTYPE .ITM FIX> <ASCII .TERM>>
				     <==? .ITM <CHTYPE ,ZERO T$UNBOUND>>>
				 <MAPSTOP>)
				(T
				 <I$PUNMATCH .ITM .TERM>)>)
			 (.ITM)>>>>
<DEFINE I$PVECTOR ()
	<MAPF ,VECTOR
	      <FUNCTION ("AUX" ITM)
		   #DECL ((ITM) ANY)
		   <COND (<TYPE? <SET ITM <I$PARSE>> T$UNBOUND>
			  <COND (<OR <==? <CHTYPE .ITM FIX> <ASCII !\]>>
				     <==? .ITM <CHTYPE ,ZERO T$UNBOUND>>>
				 <MAPSTOP>)
				(T
				 <I$PUNMATCH .ITM !\]>)>)
			 (.ITM)>>>>

<DEFINE I$PUNMATCH (TERMIN EXPECT)
	#DECL ((TERMIN) T$UNBOUND (EXPECT) CHARACTER)
	<T$ERROR %<P-E "SYNTAX-ERROR">
		 <STRING <CHTYPE .TERMIN CHARACTER>
			 " INSTEAD OF "
			 .EXPECT>
		 %<P-R "READ!-">>>

<DEFINE I$PSTRING ("AUX" (QUOTE <>) STR)
	#DECL ((QUOTE) <OR FALSE ATOM> (STR VALUE) STRING)
	<SET STR <MAPF ,STRING
		       <FUNCTION ("AUX" (CHR <I$NXTCHR>))
			    #DECL ((CHR) CHARACTER)
			    <COND (.QUOTE
				   <SET QUOTE <>>
				   .CHR)
				  (<==? .CHR <ASCII 92>>
				   <SET QUOTE T>
				   <MAPRET>)
				  (<==? .CHR !\">
				   <MAPSTOP>)
				  (.CHR)>>>>
	 <COND (<EMPTY? .STR> .STR)
	       (<T$LOOKUP .STR ,STOBLIST>
		<M$$PNAM <CHTYPE <T$LOOKUP .STR ,STOBLIST> T$ATOM>>)
	       (.STR)>>

<DEFINE I$NOLF ("AUX" CHR1)
	#DECL ((CHR1 VALUE) CHARACTER)
	<COND (<OR <==? <SET CHR1 <I$NXTCHR>> <ASCII 13>>
		   <==? .CHR1 <ASCII 10>>>
	       <COND (<==? <SET CHR1 <I$NXTCHR>> <ASCII 10>>
		      <SET CHR1 <I$NXTCHR>>)>)>
	.CHR1>

<DEFINE I$PMCODE ("AUX" (NUM 0) MC (VERT? <>))
	#DECL ((NUM) FIX (MC) <PRIMTYPE UVECTOR> (VERT?) <OR FALSE ATOM>)
	<REPEAT ((N 2) CHR1)
		#DECL ((N) FIX (CHR1) CHARACTER)
		<SET CHR1 <I$NOLF>>
		<SET NUM <+ .NUM
			    <CHTYPE <ORB <- <CHTYPE <I$NOLF> FIX>
					    <ASCII !\A>>
					 <LSH <- <ASCII .CHR1> <ASCII !\A>> 5>>
				    FIX>>>
		<COND (<L? <SET N <- .N 1>> 0> <RETURN>)
		      (T <SET NUM <CHTYPE <LSH .NUM 8> FIX>>)>>
	<SET MC <CALL IRECORD
			    *1006* ;<T$TYPE-C MCODE>
			    .NUM
			    .NUM>>
	<MAPR <>
	      <FUNCTION (MCD "AUX" CHR1)
		   #DECL ((CHR1) CHARACTER (MCD) <PRIMTYPE UVECTOR>)
		   <SET CHR1 <I$NOLF>>
		   <COND (<==? .CHR1 !\|>
			  <SET VERT? T>
			  <MAPLEAVE T>)
			 (T
			  <REPEAT ((I 3) QW (WD <ONE-Q-WD .CHR1>))
				  #DECL ((I WD) FIX (QW) <OR FALSE FIX>)
			      <COND (<SET QW <ONE-Q-WD>>
				     <SET WD
					  <ORB <LSH .WD ,QWSIZ> .QW>>)
				    (ELSE
				     <SET WD <LSH .WD <* .I ,QWSIZ>>>
				     <PUT .MCD 1 .WD>
				     <RETURN>)>
			      <COND (<0? <SET I <- .I 1>>>
				     <PUT .MCD 1 .WD>
				     <RETURN>)>>)>>
	      .MC>
	<COND (<NOT .VERT?> <I$NOLF>)>
	.MC>

<DEFINE ONE-Q-WD ("OPT" (FCHR <I$NOLF>) "AUX" CHR)
	#DECL ((CHR FCHR) CHARACTER)
	<COND (<AND <N==? .FCHR !\|>
		    <N==? <SET CHR <I$NOLF>> !\|>>
	       <ORB <- <CHTYPE .CHR FIX> <ASCII !\A>>
		    <LSH <- <ASCII .FCHR> <ASCII !\A>> 5>>)>>

<DEFINE I$PNUMBER ("OPTIONAL" (ATM? <>) "AUX" (EXP 0) (FRC 0) (NUM 0) VAL NV 
		   			      (EXP? <>) (FRC? ,I$FRC)
					      OBNAM OBL (FRCN 1) (SGN? <>) 
					      (QUOTE? <>) (NEG? <>) CHR ATM
					      (TRL? <>) (DIVIDE <>))
	#DECL ((ATM? EXP? FRC? TRL? SGN? NEG? QUOTE? DIVIDE) <OR FALSE ATOM>
	       (NUM EXP FRC RADIX FRCN) FIX (VAL) <OR STRING FALSE>
	       (NV) <OR FIX FLOAT> (CHR) CHARACTER (OBL) T$OBLIST
	       (ATM) <OR T$ATOM ANY> (OBNAM) ANY)
	<COND (<==? <SET CHR <I$NXTCHR>> <ASCII 0>>
	       <CHTYPE ,ZERO T$UNBOUND>)
	      (T
	       <SETG BI$NCHR .CHR>
	       <SET VAL 
		    <MAPF ,STRING
			  <FUNCTION ("AUX" (CHR <I$NXTCHR>) (ASC <ASCII .CHR>))
			       #DECL ((CHR) CHARACTER (ASC) FIX)
			       <COND (.QUOTE?
				      <SET QUOTE? <>>)
				     (<==? .CHR <ASCII 92>>
				      <SET ATM? T>
				      <SET QUOTE? T>)
				     (<OR <MEMQ .CHR ,BREAKS>
					  <MEMQ .CHR ,BRACKS>
					  <==? .CHR !\!>>
				      <COND (<==? .CHR !\!>
					     <COND (<==? <SET CHR <I$NXTCHR>>
							 !\->
						    <SET TRL? T>)
						   (<==? .CHR <ASCII 0>>
						    <SETG BI$NCHR .CHR>)
						   (<MAPRET>)>)
					    (T
					     <SETG BI$NCHR .CHR>)>
				      <COND (<OR .ATM?
						 <AND .SGN?
						      <0? .NUM>
						      <0? .FRC>>>
					     <MAPSTOP>)
					    (T
					     <MAPLEAVE <>>)>)
				     (<==? .ASC 0>
				      <COND (<OR .ATM?
						 <AND .SGN?
						      <0? .NUM>
						      <0? .FRC>>>
					     <MAPSTOP>)
					    (T <MAPLEAVE <>>)>)
				     (.ATM?)
				     (<OR <==? .CHR !\+> <==? .CHR !\->>
				      <COND (<AND .EXP? <0? .EXP>>
					     <COND (<==? .CHR !\->
						    <SET DIVIDE T>)>)
					    (<AND <0? .NUM>
						  <0? .FRC>
						  <NOT .NEG?>
						  <NOT .ATM?>>
					     <SET SGN? T>
					     <AND <==? .CHR !\->
						  <SET NEG? T>>)
					    (T <SET ATM? T>)>)
				     (<AND <G=? .ASC <ASCII !\0>>
					   <L=? .ASC <ASCII !\9>>>
				      <SET ASC <- .ASC <ASCII !\0>>>
				      <COND (.EXP?
					     <SET EXP <+ <* .EXP 10> .ASC>>)
					    (.FRC?
					     <SET FRC <+ <* .FRC 10> .ASC>>
					     <SET FRCN <* .FRCN 10>>)
					    (T
					     <SET NUM <+ <* .NUM ,BI$RADIX>
							 .ASC>>)>)
				     (<OR <==? .CHR !\E> <==? .CHR !\e>>
				      <COND (.EXP? <SET ATM? T>)
					    (T <SET EXP? T>)>)
				     (<==? .CHR !\.>
				      <COND (.FRC? <SET ATM? T>)
					    (T <SET FRC? T>)>)
				     (T <SET ATM? T>)>
			       <COND (.QUOTE? <MAPRET>)
				     (.CHR)>>>>
	       <COND (<NOT .VAL>
		      <SETG BI$RADIX 10>
		      <SET NV
			   <COND (.FRC?
				  <+ <FLOAT .NUM>
				     </ <FLOAT .FRC> <FLOAT .FRCN>>>)
				 (.NUM)>>
		      <COND (.EXP?
			     <COND (<0? .EXP>)
				   (<L=? .EXP 7>
				    <SET NV
					 <COND (.DIVIDE
						</ <FLOAT .NV>
						   <NTH ,I$POWERS .EXP>>)
					       (ELSE
						<* <FLOAT .NV>
						   <NTH ,I$POWERS .EXP>>)>>)
				   (T
				    <T$ERROR %<P-E "NUMBER-OUT-OF-RANGE">
				    	     %<P-R "READ">>)>)>
		      <COND (.NEG? <SET NV <- .NV>>)>
		      .NV)
		     (.TRL?
		      <COND (<OR <MEMQ <SET CHR <I$NXTCHR>> ,BREAKS>
				 <==? .CHR <ASCII 0>>
				 <==? .CHR !\!>>
			     <SET OBL ,M$$ROOT>)
			    (<MEMQ .CHR ,BRACKS>
			     <SET OBL ,M$$ROOT>
			     <SETG BI$NCHR .CHR>)
			    (<AND <SETG BI$NCHR .CHR>
				  <TYPE? <SET OBNAM <I$PARSE>> T$ATOM>
				  <=? <M$$PNAM .OBNAM>:STRING "IMSUBR">>
			     <SET OBL ,IMSUBOB>)
			    (<T$ERROR %<P-E "NON-ATOMIC-NAME">
				      .OBNAM>)>
		      <OR <T$LOOKUP .VAL .OBL>
			  <T$INSERT .VAL .OBL>>)
		     (<==? <1 .VAL> !\@>
		      <OR <T$LOOKUP <REST .VAL> ,EROBLIST>
			  <T$INSERT <REST .VAL> ,EROBLIST>>)
		     (<OR <T$LOOKUP .VAL ,M$$INTERNAL>
		          <T$INSERT .VAL ,M$$INTERNAL>>)>)>>

<DEFINE T$FLOAD (STR "OPTIONAL" (OSTR <>) "AUX" C)
	#DECL ((STR OSTR) <OR STRING FALSE> (C) <OR VECTOR FALSE>)
	<COND (<AND .STR <SET C <T$OPEN "READ" .STR>>>
	       <REPEAT (VAL)
		       <SET VAL <T$READ .C>>
		       <COND (<TYPE? .VAL T$UNBOUND> <RETURN>)
			     (T <T$EVAL .VAL>)>>
	       <T$CLOSE .C>
	       "DONE")
	      (.OSTR
	       <T$FLOAD .OSTR <>>)
	      (.C)>>

<DEFINE T$CLOSE (CHAN "AUX" (CNUM <M$$CHAN .CHAN>))
	#DECL ((CHAN) VECTOR (CNUM) FIX)
	<CALL CLOSE .CNUM>
	<M$$CHAN .CHAN 0>>

<DEFINE T$OPEN (DIR FNM "OPTIONAL" (RADX 10) "AUX" ID CHN)
	#DECL ((DIR FNM) STRING (RADX) FIX (ID) <OR FALSE FIX> (CHN) VECTOR)
	<COND (<SET ID <CALL OPEN 0 7 .FNM>>
	       <SET CHN [.ID .DIR "FOO" .FNM 79 0 24 0 10
			     "////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
//////////////////////////////////////////////" 0 0 0]>
	       <SETG BI$NCHR <>>
	       .CHN)>>

;"Primitive TYPEs"

<DEFINE T$CHTYPE (ITM TYP "AUX" (SPN <M$$PNAM .TYP>) TYPC)
	#DECL ((ITM) ANY (TYP) T$ATOM (SPN) STRING (TYPC) FIX)
	<COND (<=? .SPN "MSUBR">
	       <SET TYPC *1207*>)
	      (<=? .SPN "IMSUBR">
	       <SET TYPC *4007*>)
	      (<=? .SPN "MCODE">
	       <SET TYPC *1006*>)
	      (<=? .SPN "FALSE">
	       <SET TYPC *501*>)
	      (<=? .SPN "I$TERMIN">
	       <SET TYPC *2200*>)
	      (<=? .SPN "UNBOUND">
	       <SET TYPC 0>)
	      (<ERROR .SPN>)>
	<CALL CHTYPE .ITM .TYPC>>


;"Primitive structure builders"

<DEFINE T$ATOM (STR)
	#DECL ((STR) STRING)
	<CALL RECORD *1502* ;<TYPE-CODE ATOM> <> <> <STRING .STR> <> <>>>


;"Primitive EVAL"

<DEFINE T$EVAL (FOO "AUX" PN ATM)
	#DECL ((FOO) ANY (PN) STRING (ATM) T$ATOM)
	<COND (<TYPE? .FOO FORM>
	       <COND (<NOT <EMPTY? .FOO>>
		      <SET PN <M$$PNAM <SET ATM <1 .FOO>>>>
		      <COND (<=? .PN "SETG">
			     <T$SETG <2 .FOO> <3 .FOO>>)
			    (<=? .PN "GBIND">
			     <COND (<NOT <M$$GVAL <SET ATM <2 .FOO>>>>
				    <T$SETG .ATM <CHTYPE ,ZERO T$UNBOUND>>
				    <M$$GVAL .ATM>)
				   (<M$$GVAL .ATM>)>)
			    (<=? .PN "PCODE">
			     <T$PCODE <2 .FOO> <3 .FOO>>)
			    (<=? .PN "QUOTE">
			     .FOO)
			    (<ERROR LOSER>)>)
		     (T <>)>)
	      (.FOO)>>

;"ATOM part of bootstrap"

<DEFINE I$HASH (STR "OPTIONAL" (MOD 0) "AUX" (VAL 0) OFF)
	#DECL ((STR) STRING (MOD OFF VAL) FIX)
	<IFSYS ("TOPS20" <SET OFF 36>)("UNIX" <SET OFF 32>)>
	<MAPF <>
	  <FUNCTION (CHR)
	    <IFSYS ("TOPS20"
		    <COND (<L? <SET OFF <- .OFF 7>> 0>
			   <SET OFF 29>)>)
		   ("UNIX"
		    <COND (<L? <SET OFF <- .OFF 8>> 0>
			   <SET OFF 24>)>)>
	    <SET VAL <XORB .VAL <LSH .CHR .OFF>>>>
	  .STR>
	<SET VAL <ANDB .VAL <MIN>>>
	<COND (<0? .MOD> .VAL) (ELSE <+ <MOD .VAL .MOD> 1>)>>

<DEFINE T$LOOKUP (ARG1 ARG2 "AUX" BUCK)
	#DECL ((ARG1) STRING (ARG2) T$OBLIST (BUCK) <LIST [REST T$ATOM]>)
	<SET BUCK <NTH ,M$$OBLIST <I$HASH .ARG1 ,M$$SIZE>>>
	<MAPF <>
	      <FUNCTION (ATM)
		   #DECL ((ATM) T$ATOM)
		   <COND (<AND <==? <M$$OBLS .ATM> .ARG2>
			       <=? <M$$PNAM .ATM>:STRING .ARG1>>
			  <MAPLEAVE .ATM>)>>
	      .BUCK>>

<DEFINE T$INSERT (ARG1 ARG2 "AUX" ATM (OFF <I$HASH .ARG1 ,M$$SIZE>))
	#DECL ((ARG1) <OR T$ATOM STRING> (ARG2) T$OBLIST (OFF) FIX
	       (ATM) T$ATOM)
	<SET ATM <CALL RECORD T$ATOM <> <> <STRING .ARG1> <> <>>>
	<PUT ,M$$OBLIST .OFF (.ATM !<NTH ,M$$OBLIST .OFF>)>
	<M$$OBLS .ATM .ARG2>>

<DEFINE T$SETG (ARG1 ARG2 "AUX" BIND)
	#DECL ((ARG1) T$ATOM (ARG2 VALUE) ANY (BIND) T$GBIND)
	<COND (<NOT <M$$GVAL .ARG1>>
	       <M$$GVAL .ARG1 <CALL RECORD T$GBIND .ARG2 .ARG1 <>>>)>
	<M$$VALU <SET BIND <M$$GVAL .ARG1>> .ARG2>
	.ARG2>

<DEFINE T$GVAL (ARG "AUX" G)
	#DECL ((ARG) T$ATOM (G) <OR FALSE T$GBIND>)
	<COND (<SET G <M$$GVAL .ARG>>
	       <M$$VALU .G>)>>

<DEFINE I$ATOM-INIT ("AUX" FOO)
	#DECL ((FOO) T$ATOM)
	<SETG M$$OBLIST <CALL GETS OBLIST>>
	<SETG M$$SIZE <LENGTH ,M$$OBLIST>>
	<SETG M$$INTERNAL <CHTYPE <T$ATOM "INTERNAL"> T$OBLIST>>
	<T$INSERT "INTERNAL" ,M$$INTERNAL>
	<SETG M$$ROOT <CHTYPE <SET FOO <T$INSERT "ROOT" ,M$$INTERNAL>>
			      T$OBLIST>>
	<M$$OBLS .FOO ,M$$ROOT>
	<SETG STOBLIST <CHTYPE <T$ATOM "STRINGS"> T$OBLIST>>
	<MAPF <>
	      <FUNCTION (X)
	        <T$INSERT .X ,STOBLIST>>
	      '["AUX" "NAME" "OPTIONAL" "OPT" "EXTRA" "QUOTE"
		"BIND" "CALL" "ARGS" "TUPLE" "ACT" "DECL" "OWN"
		"VALUE" "PRINT" "READ" "MUD" "DONE"]>
	<SETG EROBLIST <CHTYPE <T$INSERT "ERRORS" ,M$$ROOT> T$OBLIST>>
	<SETG IMSUBOB <CHTYPE <T$INSERT "IMSUBR" ,M$$ROOT> T$OBLIST>>
	<T$INSERT "STRINGS" ,M$$ROOT>
	<T$INSERT "QUOTE" ,M$$ROOT>
	<T$INSERT "LVAL" ,M$$ROOT>
	<T$INSERT "GVAL" ,M$$ROOT>>


<DEFINE T$PCODE (ID DBNAM "AUX" DBID (PURVEC ,I$PURVEC) CPC DBVEC)
  #DECL ((DBID ID) FIX (DBNAM) STRING (PURVEC) <LIST [REST T$PCODE]>
	 (CPC) T$PCODE (DBVEC) VECTOR)
  <COND (<EMPTY? .PURVEC>
	 <SET DBVEC [<> <> <> <> <>]>
	 <SETG I$DBVEC .DBVEC>)
	(<SET DBVEC ,I$DBVEC>)>
  <REPEAT ((CT 1) (DBV .DBVEC) DB)
    #DECL ((CT) FIX (DBV) <VECTOR [REST <OR DB FALSE>]>
	   (DB) <OR DB FALSE>)
    <COND (<AND <SET DB <1 .DBV>>
		<=? <DB-NAME .DB>:STRING .DBNAM>>
	   <SET DBID .CT>
	   <RETURN>)
	  (<NOT .DB>
	   <SET DBID .CT>
	   <1 .DBV [.DBNAM <>]>
	   <RETURN>)>
    <SET CT <+ .CT 1>>
    <COND (<EMPTY? <SET DBV <REST .DBV>>>
	   <T$ERROR>)>>
  <COND (<MAPF <>
	     <FUNCTION (PV) #DECL ((PV) <OR T$PCODE UVECTOR>)
	       <REPEAT ()
	         <COND (<AND <==? <M$$PC-ID .PV> .ID>
			     <==? <M$$PC-DB .PV> .DBID>>
			<MAPLEAVE .PV>)>
		 <COND (<EMPTY? <SET PV <REST .PV ,M$$PC-ENTLEN>>>
			<RETURN <>>)>
		 <SET PV <CHTYPE .PV T$PCODE>>>>
	     .PURVEC>)
	(T
	 <COND (<OR <EMPTY? .PURVEC>
		    <==? <LENGTH <SET CPC <1 .PURVEC>>> <* 20 ,M$$PC-ENTLEN>>>
		<SET PURVEC (<SET CPC <CHTYPE <REST <IUVECTOR 100>
						    <* 19 ,M$$PC-ENTLEN>>
				      T$PCODE>>
			     !.PURVEC)>
		<SETG I$PURVEC .PURVEC>)>
	 <COND (<NOT <0? <M$$PC-ID .CPC>>>
		<SET CPC <CHTYPE <CALL BACKU .CPC ,M$$PC-ENTLEN> T$PCODE>>
		<1 .PURVEC .CPC>)>
	 <M$$PC-ID .CPC .ID>
	 <M$$PC-DB .CPC .DBID>
	 <M$$PC-DBLOC .CPC -1>
	 <M$$PC-CORLOC .CPC 0>
	 <M$$PC-LEN .CPC 0>
	 .CPC)>>

;"Bootstrap routine"
; "Arg of 0 means use MBINs where possible.  Arg of 1 means use
   moby-glued stuff, MBINs where possible.  Arg of -1 means use
   only msubrs."
<DEFINE BOOT ("OPTIONAL" (BT 0) "AUX" ICH OCH MI)
	#DECL ((BT) FIX (ICH OCH) VECTOR (MI) <UVECTOR [REST FIX]>)
	<SET MI <CALL GETS MINF>>
	<SETG QWSIZ <LSH <I$MINF-WDSIZE .MI> -2>>
	<SETG ZERO 0>
	<SETG BI$RADIX 10>
	<SETG INMCODE <>>
	<SETG I$FRC <>>
	<SETG I$POWERS 
[10.0 100.0 1000.0 10000.0 100000.0 1000000.0 10000000.0]> 
	<SETG BREAKS "	
 :">
	<SETG BRACKS "|:,[(<>)]\"">
	<SETG BI$NCHR <>>
	<SETG I$CONT <>>
	<SETG I$R? <>>
	<SETG BI$STR "">
	<SETG I$CHRSTR " ">
	<SETG M$$R-TAT <IVECTOR ,M$$TYPE-INFO-SIZE <>>>
	<SETG M$$R-TDT <IVECTOR ,M$$TYPE-INFO-SIZE <>>>
	<I$ATOM-INIT>
	<SETG I$PURVEC ()>
	<SETG I$DBVEC <>>
	<SET ICH [64 "" "" "" 79 0 24 0 10 
"////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
//////////////////////////////////////////////" 0 0 0]>
	<SETG I$INCHAN .ICH>
	<SET OCH [65 "" "" "" 79 0 24 0 10
 "////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
//////////////////////////////////////////////" 0 0 0]>
	<COND (<0? .BT>
	       <T$FLOAD "APPLY.MBIN" "APPLY.MSUBR">
	       <T$FLOAD "ARITH.MBIN" "ARITH.MSUBR">
	       <T$FLOAD "ATOM.MBIN" "ATOM.MSUBR">
	       <IFSYS ("UNIX" <T$FLOAD "BUFFERS.MBIN" "BUFFERS.MSUBR">)>
	       <T$FLOAD "CHANNELS.MBIN" "CHANNELS.MSUBR">
	       <T$FLOAD "DECL.MBIN" "DECL.MSUBR">
	       <T$FLOAD "DEFAULT.MBIN" "DEFAULT.MSUBR">
	       <T$FLOAD "DISK.MBIN" "DISK.MSUBR">
	       <T$FLOAD "FRAME.MSUBR">
	       <T$FLOAD "FS.MSUBR">
	       <T$FLOAD "FSUBRS.MBIN" "FSUBRS.MSUBR">
	       <T$FLOAD "IO-UTILS.MBIN" "IO-UTILS.MSUBR">
	       <T$FLOAD "LOC.MBIN" "LOC.MSUBR">
	       <T$FLOAD "MAPPUR.MSUBR">
	       <T$FLOAD "PCK.MBIN" "PCK.MSUBR">
	       <T$FLOAD "PMAP.MSUBR">
	       <T$FLOAD "PRINT.MBIN" "PRINT.MSUBR">
	       <T$FLOAD "REUSE.MBIN" "REUSE.MSUBR">
	       <T$FLOAD "READ.MBIN" "READ.MSUBR">
	       <T$FLOAD "STRUC.MBIN" "STRUC.MSUBR">
	       <T$FLOAD "TYPE.MBIN" "TYPE.MSUBR">
	       <T$FLOAD "TYPINI.MSUBR">
	       <T$FLOAD "USER-IO.MBIN" "USER-IO.MSUBR">)
	      (<1? .BT>
	       <T$FLOAD "BIG.MBIN" "BIG.MSUBR">
	       <T$FLOAD "BIGIO.MBIN" "BIGIO.MSUBR">
	       <T$FLOAD "IO-UTILS.MBIN" "IO-UTILS.MSUBR">
	       <T$FLOAD "USER-IO.MBIN" "USER-IO.MSUBR">
	       <T$FLOAD "DEFAULT.MBIN" "DEFAULT.MSUBR">
	       <T$FLOAD "FRAME.MSUBR">
	       <T$FLOAD "FS.MSUBR">
	       <T$FLOAD "MAPPUR.MSUBR">
	       <T$FLOAD "PCK.MBIN" "PCK.MSUBR">
	       <T$FLOAD "PMAP.MSUBR">
	       <T$FLOAD "REUSE.MBIN" "REUSE.MSUBR">
	       <T$FLOAD "TYPINI.MSUBR">)
	      (<==? .BT -1>
	       <T$FLOAD "APPLY.MSUBR">
	       <T$FLOAD "ARITH.MSUBR">
	       <T$FLOAD "ATOM.MSUBR">
	       <IFSYS ("UNIX" <T$FLOAD "BUFFERS.MSUBR">)>
	       <T$FLOAD "CHANNELS.MSUBR">
	       <T$FLOAD "DECL.MSUBR">
	       <T$FLOAD "DEFAULT.MSUBR">
	       <T$FLOAD "DISK.MSUBR">
	       <T$FLOAD "FRAME.MSUBR">
	       <T$FLOAD "FS.MSUBR">
	       <T$FLOAD "FSUBRS.MSUBR">
	       <T$FLOAD "IO-UTILS.MSUBR">
	       <T$FLOAD "LOC.MSUBR">
	       <IFSYS ("TOPS20" <T$FLOAD "MAPPUR.MSUBR">)>
	       <T$FLOAD "PCK.MSUBR">
	       <T$FLOAD "PMAP.MSUBR">
	       <T$FLOAD "PRINT.MSUBR">
	       ;<T$FLOAD "REUSE.MSUBR">
	       <T$FLOAD "READ.MSUBR">
	       <T$FLOAD "STRUC.MSUBR">
	       <T$FLOAD "TYPE.MSUBR">
	       <T$FLOAD "TYPINI.MSUBR">
	       <T$FLOAD "USER-IO.MSUBR">)>
	<CALL CALL
	      <LOOKUP "I$INITIALIZE" ,M$$INTERNAL>
	      .BT
	      ,M$$ROOT
	      ,M$$INTERNAL
	      ,STOBLIST
	      ,I$PURVEC
	      ,I$DBVEC>>
