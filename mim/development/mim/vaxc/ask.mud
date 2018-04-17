<USE "JCL">

<DEFINE SAV ()
	<GC-MON <>>
	<RESET .INCHAN>
	<SNAME "">
	<COND (<=? <SAVE "MV"> "SAVED"> T)
	      (<RUN-QUESTIONS>)>>

<SETG BUFSTRING <ISTRING 200>>

<DEFINE RQ ("OPT" (NOJCL? <>))
  <PROG ()
    <RESET ,INCHAN>
    <RUN-QUESTIONS .NOJCL?>>>

<DEFINE RUN-QUESTIONS ("OPT" (NOJCL? <>) "AUX" FIL FILLEN REC (BUF ,BUFSTRING) CH
		       (JCL-STR <>) REM-STR (JCL-VEC <>) REM-VEC
		       (QUICK? <>) (UN <UNAME>) (ANY-JCL? <>)) 
  #DECL ((REM-STR JCL-STR) <OR STRING FALSE>
	 (JCL-VEC REM-VEC) <OR VECTOR FALSE> (FIL) LIST)
  <PROG ()
   <IFSYS ("TOPS20" <COND (.NOJCL? <SET JCL-STR <>>)
			  (T <SET JCL-STR <READJCL>>)>)
	  ("VAX" <COND (.NOJCL? <SET JCL-VEC <>>)
		       (T <SET JCL-VEC <READARGS>>)>)>
   <COND (<NOT .QUICK?>
	  <UNASSIGN PRECOMPILED>
	  <UNASSIGN AUTO-PRECOMP>
	  <UNASSIGN REDO>)>
   <COND (<OR .JCL-VEC .JCL-STR>
	  <SET NOJCL? T>
	  <SET QUICK? T>
	  <SETG VERBOSE? <>>
	  <SET DOC <>>
	  <SETG GLUE <>>
	  <SETG BOOT-MODE <>>
	  <SETG INT-MODE <>>
	  <SETG GC-MODE <>>
	  <IFSYS ("TOPS20"
		  <COND
		   (<SET REM-STR <MEMQ !\/ .JCL-STR>>
		    <SET FIL <LEX <SUBSTRUC .JCL-STR 0 <- <LENGTH .JCL-STR>
							  <LENGTH .REM-STR>>>>>
		    <SET REM-STR <LPARSE <REST .REM-STR>>>
		    <MAPF <>
			  <FUNCTION (TOKEN)
				    <COND (<TYPE? .TOKEN ATOM>
					   <COND (<MEMQ .TOKEN '[L /L D /D]>
						  <SET ANY-JCL? T>
						  <SET DOC T>)
						 (<MEMQ .TOKEN '[V /V]>
						  <SETG VERBOSE? T>)
						 (<MEMQ .TOKEN '[G /G]>
						  <SET ANY-JCL? T>
						  <SETG GLUE T>)
						 (<MEMQ .TOKEN '[GC /GC]>
						  <SET ANY-JCL? T>
						  <SETG GC-MODE T>)
						 (<MEMQ .TOKEN '[I /I]>
						  <SET ANY-JCL? T>
						  <SETG INT-MODE T>)
						 (<MEMQ .TOKEN '[P /P]>
						  <SET PRECOMPILED T>)
						 (<MEMQ .TOKEN '[PA /PA]>
						  <SET PRECOMPILED T>
						  <SET AUTO-PRECOMP T>)>)
					  (<TYPE? .TOKEN ADECL>
					   <COND (<MEMQ <1 .TOKEN> '[P /P
								     PA /PA]>
						  <SET PRECOMPILED
						       <2 .TOKEN>>
						  <COND (<MEMQ <1 .TOKEN>
							       '[PA /PA]>
							 <SET AUTO-PRECOMP
							      T>)>)>)
					  (T
					   <EVAL .TOKEN>)>>
			  .REM-STR>)
		   (<SET FIL <LEX .JCL-STR <LENGTH .JCL-STR>>>)>)
		 ("VAX"
		  <SET REM-VEC <>>
		  <MAPR <>
			<FUNCTION (VV "AUX" (ST <1 .VV>))
				  #DECL ((VV) <VECTOR [REST STRING]>)
				  <COND (<AND <NOT <EMPTY? .ST>>
					      <==? <1 .ST> !\->>
					 <SET REM-VEC .VV>
					 <MAPLEAVE>)>>
			.JCL-VEC>
		  <COND
		   (.REM-VEC
		    <SET FIL <ILIST <- <LENGTH .JCL-VEC>
				       <LENGTH .REM-VEC>>>>
		    <MAPR <>
			  <FUNCTION (X Y)
				    <1 .X <1 .Y>>>
			  .FIL .JCL-VEC>
		    <MAPF <>
			  <FUNCTION (TOKEN)
				    <COND (<MEMBER .TOKEN '["L" "-L" "D" "-D"]>
					   <SET ANY-JCL? T>
					   <SET DOC T>)
					  (<MEMBER .TOKEN '["V" "-V"]>
					   <SETG VERBOSE? T>)
					  (<MEMBER .TOKEN '["G" "-G"]>
					   <SET ANY-JCL? T>
					   <SETG GLUE T>)
					  (<MEMBER .TOKEN '["GC" "-GC"]>
					   <SET ANY-JCL? T>
					   <SETG GC-MODE T>)
					  (<MEMBER .TOKEN '["I" "-I"]>
					   <SET ANY-JCL? T>
					   <SETG INT-MODE T>)
					  (<MEMBER .TOKEN '["P" "-P"]>
					   <SET PRECOMPILED T>)
					  (<MEMBER .TOKEN '["PA" "-PA"]>
					   <SET PRECOMPILED T>
					   <SET AUTO-PRECOMP T>)
					  (T
					   <MAPF <>
					     <FUNCTION (X)
					       <COND (<AND <TYPE? .X ADECL>
							   <MEMQ <1 .X>
								 '[P -P
								   PA -PA]>>
						      <COND
						       (<TYPE?
							 <SET PRECOMPILED
							      <2 .X>> ATOM>
							<COND
							 (<MEMQ <1 .X>
								'[PA -PA]>
							  <SET AUTO-PRECOMP
							       T>)>
							<SET PRECOMPILED
							     <SPNAME
							      .PRECOMPILED>>)>)
						     (T
						      <EVAL .X>)>>
					     <LPARSE .TOKEN>>)>>
			  .REM-VEC>)
		   (<SET FIL (!.JCL-VEC)>)>)>
	  <COND (<NOT .ANY-JCL?>
		 <SET QUICK? <>>)>
	  <COND (<EMPTY? .FIL>
		 <AGAIN>)
		(<=? <1 .FIL> "BOOT">
		 <SETG BOOT-MODE T>
		 <SETG INT-MODE T>
		 <SETG GC-MODE <>>)>
	  <COND (,INT-MODE
		 <SET EXPFLOAD T>)>)
	 (T
	  <SETG VERBOSE? <>>
	  <PRINC "File(s): ">
	  <SET FILLEN <READSTRING .BUF .INCHAN "">>
	  <SET FIL <LEX .BUF .FILLEN>>
	  <CRLF>
	  <COND (<EMPTY? .FIL>
		 <LEAVE-MIMOC .UN>
		 <AGAIN>)>
	  <COND
	   (<NOT .QUICK?>
	    <PRINC "Doc: ">
	    <COND (<SET DOC <MEMQ <TYI> "YyTt ">> <PRINC " [Listing]"> <CRLF>)
		  (T <PRINC " [No Listing]"> <CRLF>)>)>
	  <COND (<N=? <1 .FIL> "BOOT">
		 <SETG BOOT-MODE <>>
		 <COND
		  (<NOT .QUICK?>
		   <PRINC "Interpreter: ">
		   <COND (<MEMQ <TYI> " YyTt">
			  <PRINC " [Interpreter Code]">
			  <SET EXPFLOAD T>
			  <SETG INT-MODE T>)
			 (T <SETG INT-MODE <>> <PRINC " [User Code]">)>
		   <CRLF>
		   <PRINC "GC: ">
		   <COND (<MEMQ <TYI> " YyTt">
			  <PRINC " [GC Code]">
			  <SETG GC-MODE T>)
			 (T <SETG GC-MODE <>> <PRINC " [Non-GC Code]">)>
		   <CRLF>)>)
		(ELSE
		 <PRINC " [Boot mode]">
		 <CRLF>
		 <SETG BOOT-MODE <SETG INT-MODE T>>
		 <SETG GC-MODE <>>)>
	  <COND (<AND <NOT .QUICK?> <NOT ,BOOT-MODE>>
		 <PRINC "Glue: ">
		 <COND (<MEMQ <TYI> " YyTt"> <SETG GLUE T> <PRINC " [Glue]">)
		       (T <PRINC " [No Glue]"> <SETG GLUE <>>)>
		 <CRLF>)>
	  <COND (<AND <NOT .QUICK?> <NOT ,INT-MODE>>
		 <PRINC "Things to do: ">
		 <REPEAT ()
			 <COND (<==? <NEXTCHR> <ASCII 27>> <CRLF> <RETURN>)>
			 <EVAL <READ>>>)>)>
   <COND (<SET CH <CHANNEL-OPEN PARSE <1 .FIL>>>
	  <FILE-MIMOC <CHANNEL-OP .CH NM1> <> <> .DOC !.FIL>
	  <CHANNEL-CLOSE .CH>
	  <CRLF>
	  <PRINC "Done">
	  <LEAVE-MIMOC .UN>)
	 (T
	  <SET CH <SYS-ERR <1 .FIL> .CH T>>
	  <PRINT-MANY .OUTCHAN PRINC "Can't find name of output file:  "
		 <1 .CH> "--" <2 .CH>>
	  <CRLF>
	  <SET QUICK? T>
	  <SET NOJCL? T>
	  <AGAIN>)>
   <SET NOJCL? T>
   <AGAIN>>>

<DEFINE LEAVE-MIMOC (UN)
  #DECL ((UN) STRING)
  <COND (<=? .UN "TAA"> <QUIT>)
	(T <EXIT>)>>

<DEFINE LEX (BUF "OPTIONAL" (LEN <LENGTH .BUF>))
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
