
<DEFINE MULTI-SET-GEN (N:NODE W
		       "AUX" (K:<LIST [REST NODE]> <KIDS .N>) (SEG? <>)
			     (SIDE-E <>) (MX:FIX 0) (MN:FIX 0)
			     (VARS:<LIST [REST LIST]> <NODE-NAME .N>) TL:LIST
			     (VLN:FIX <LENGTH .VARS>)
			     (LV:<OR ATOM SYMTAB> <1 <NTH .VARS .VLN>>) (I:FIX 0))
   <MAPF <>
    <FUNCTION (N:NODE "AUX" RT) 
	    <COND (<OR <==? <SET NT <NODE-TYPE .N>> ,SEG-CODE>
		       <==? .NT ,SEGMENT-CODE>>
		   <SET SEG? T>
		   <SET MX <MAX <+ <MAXL <SET RT <RESULT-TYPE <1 <KIDS .N>>>>> .MX>
				,MAX-LENGTH>>
		   <SET MN <+ <MINL .RT> .MN>>)
		  (ELSE
		   <SET I <+ .I 1>>
		   <SET MN <+ .MN 1>>
		   <SET MX <MAX <+ .MX 1> ,MAX-LENGTH>>)>
	    <COND (<AND <G=? <LENGTH .N> <INDEX ,SIDE-EFFECTS>>
			<SIDE-EFFECTS .N>>
		   <SET SIDE-E T>)>>
    <SET K <REST .K>>>
   <COND
    (.SEG?
     <PROG ((SEGLABEL <MAKE-TAG>) COUNTMP (SEGCALLED <>) SEGTMP)
       #DECL ((SEGLABEL COUNTMP SEGCALLED) <SPECIAL ANY>)
       <MAPF <>
	<FUNCTION (NN:NODE "AUX" (NT <NODE-TYPE .NN>) RES) 
	   <COND
	    (<OR <==? .NT ,SEG-CODE> <==? .NT ,SEGMENT-CODE>>
	     <COND (<NOT <ASSIGNED? SEGTMP>>
		    <SET SEGTMP <GEN-TEMP <>>>
		    <SET COUNTMP <GEN-TEMP FIX>>
		    <SET-TEMP .COUNTMP .I '(`TYPE FIX)>)>
	     <SET RES <GEN <SET NN <1 <KIDS .NN>>> .SEGTMP>>
	     <SET SEGTYP <STRUCTYP-SEG <RESULT-TYPE .NN>>>
	     <COND (<AND <N==? .RES ,NO-DATUM> <N==? .SEGTYP MULTI>>
		    <SEGMENT-STACK .SEGTMP
				   .COUNTMP
				   .SEGTYP
				   <ISTYPE? <RESULT-TYPE .NN>>
				   .SEGLABEL>
		    <SET SEGLABEL <MAKE-TAG>>)
		   (.SEGCALLED
		    <LABEL-TAG .SEGLABEL>
		    <SET SEGLABEL <MAKE-TAG>>)>)
	    (ELSE
	     <COND (.CNT <IEMIT `ADD .CNT 1 = .CNT>)>
	     <GEN .NN ,POP-STACK>)>>
	.K>
       <COND (<AND .CAREFUL <N==? .MX .MN>>
	      <IEMIT `VEQUAL? .COUNTMP .VLN - `COMPERR>)>
       <REPEAT ()
	       <IEMIT `POP = <TEMP-NAME-SYM <1 <NTH .VARS .VLN>>>>
	       <COND (<==? <SET VLN <- .VLN 1>> 0> <RETURN>)>>>)
    (.SIDE-E
     <SET TL
	  <MAPF ,LIST
		<FUNCTION (NN:NODE SYP:<LIST <OR ATOM SYMTAB>>
			   "AUX" (TY <RESULT-TYPE .NN>) PT
				 (SY:<OR ATOM SYMTAB> <1 .SYP>))
			<COND (<TYPE? .SY SYMTAB>
			       <SET TY <TYPE-AND <2 .SYP> .TY>>)>
			<COND (<AND <SET TY <ISTYPE? .TY>>
				    <OR <==? <SET PT <TYPEPRIM .TY>> FIX>
					<==? .PT LIST>>>)
			      (ELSE <SET TY ANY>)>
			<GEN .NN <GEN-TEMP .TY>>>
		.K
		.VARS>>
     <MAPF <>
	   <FUNCTION (SYP:<LIST <OR ATOM SYMTAB>> TMP:TEMP
		      "AUX" (SY:<OR ATOM SYMTAB> <1 .SYP>) (LCL <>)) 
		   <COND (<AND <TYPE? .SY SYMTAB>
			       <N==? <CODE-SYM .SY> -1>
			       <SET LCL T>
			       <NOT <SPEC-SYM .SY>>>
			  <IEMIT `SET <TEM-NAME-SYM .SY> .TMP>
			  <FREE-TEMP .TMP>)
			 (ELSE
			  <COND (<TYPE? .SY SYMTAB> <SET SY <NAME-SYM .SY>>)>
			  <SET-VALUE .SY .TMP <NOT .LCL>>
			  <FREE-TEMP .TMP>)>>
	   .VARS
	   .TL>)
    (ELSE
     <PROG (NL-LATER:LIST SL-LATER:LIST ANY-DONE (MUCH-LATER:LIST ())
	    TTMP:TEMP)
       <SET NL-LATER <SET SL-LATER ()>>
       <SET ANY-DONE <>>
       <MAPR <>
	<FUNCTION (SL NL
		   "AUX" (SYP:<LIST <OR ATOM SYMTAB TEMP>> <1 .SL>) (LCL <>) TY
			 (N:NODE <1 .NL>) (SY:<OR ATOM SYMTAB TEMP> <1 .SYP>) TMP)
		<COND (<OR <TYPE? .SY TEMP>
			   <AND <NOT <REF? .SY <REST .NL>>>
				<NOT <REF? .SY .NL-LATER>>>>
		       <SET ANY-DONE T>
		       <COND (<OR <AND <TYPE? .SY SYMTAB>
				       <N==? <CODE-SYM .SY> -1>
				       <SET LCL T>
				       <NOT <SPEC-SYM .SY>>
				       <SET TMP <TEMP-NAME-SYM .SY>>>
				  <AND <TYPE? .SY TEMP> <SET TMP .SY>>>
			      <GEN .N .TMP>)
			     (ELSE
			      <COND (<TYPE? .SY SYMTAB>
				     <SET SY <NAME-SYM .SY>>)>
			      <SET-VALUE .SY <GEN .N DONT-CARE> <NOT .LCL>>)>)
		      (ELSE
		       <SET SL-LATER (.SYP !.SL-LATER)>
		       <SET NL-LATER (.N !.NL-LATER)>)>>
	.VARS
	.K>
       <COND (<AND .ANY-DONE <NOT <EMPTY? .SL-LATER>>>
	      <SET VARS .SL-LATER>
	      <SET K .NL-LATER>
	      <AGAIN>)
	     (<NOT <EMPTY? .SL-LATER>>
	      <SET MUCH-LATER
		   ((<1 .SL-LATER> <SET TTMP <GEN-TEMP <>>>) !.MUCH-LATER)>
	      <SET VARS ((.TTMP) !<REST .SL-LATER>)>
	      <SET K .NL-LATER>
	      <AGAIN>)>
       <MAPF <>
	     <FUNCTION (L
			"AUX" (SY:<OR ATOM SYMTAB> <1 <1 .L>>) (LCL <>)
			      (TMP:TEMP <2 .L>))
		     <COND (<AND <TYPE? .SY SYMTAB>
				 <N==? <CODE-SYM .SY> -1>
				 <SET LCL T>
				 <NOT <SPEC-SYM .SY>>>
			    <IEMIT `SET <TEMP-NAME-SYM .SY> .TMP>
			    <FREE-TEMP .TMP>)
			   (ELSE
			    <COND (<TYPE? .SY SYMTAB> <SET SY <NAME-SYM .SY>>)>
			    <SET-VALUE .SY .TMP <NOT .LCL>>
			    <FREE-TEMP .TMP>)>>
	     .MUCH-LATER>>)>
   <COND (<N==? .W FLUSHED>
	  <SET LCL <>>
	  <COND (<AND <TYPE? .VL SYMTAB>
		      <N==? <CODE-SYM .VL> -1>
		      <SET LCL T>
		      <NOT <SPEC-SYM .VL>>>
		 <TEMP-REFS .VL <+ <TEMP-REFS .VL> 1>>
		 <MOVE-ARG .VL .W>)
		(ELSE
		 <COND (<TYPE? .VL SYMTAB> <SET VL <NAME-SYM .VL>>)>
		 <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>
		 <GET-VALUE-X .VL .W <NOT .LCL>>)>)
	 (ELSE .W)>>

<DEFINE REF? (SY:<OR ATOM SYMTAB> L:<LIST [REST NODE]>)
	<MAPF <>
	      <FUNCTION (N:NODE "AUX" (NT:FIX <NODE-TYPE .N>))
		    <PROG ()
			  <COND (<OR <==? .NT ,LVAL-CODE>
				     <==? .NT ,ASSIGNED?-CODE>
				     <==? .NT ,SET-CODE>>
				 <COND (<==? <NODE-NAME .N> .SY> <MAPLEAVE>)>)
				(<OR <==? .NT ,FLVAL-CODE> <==? .NT ,FSET-CODE>>
				 <COND (<OR <==? <NODE-NAME .N> .SY>
					    <COND (<==? <NODE-TYPE
							 <SET NN <1 <KIDS .N>>>>
							,QUOTE-CODE>
						   <==? <NODE-NAME .NN> .SY>)
						  (ELSE
						   <OR <TYPE? .SY ATOM>
						       <==? <CODE-SYM .SY> -1>
						       <SPEC-SYM .SY>>)>>
					<MAPLEAVE T>)>)
				(<AND <G? <LENGTH .N> <INDEX ,SIDE-EFFECTS>>
				      <MEMQ ALL <SIDE-EFFECTS .N>>
				      <OR <TYPE? .SY ATOM>
					  <SPEC-SYM .SY>
					  <==? <CODE-SYM .SY> -1>>>
				 <MAPLEAVE T>)
				(ELSE
				 <COND (<REF? .SY <KIDS .N>> <MAPLEAVE T>)>
				 <COND (<==? .NT ,BRANCH-CODE>
					<SET NT <NODE-TYPE <SET N <PREDIC .N>>>>
					<AGAIN>)>)>>>
	      .L>>
				 
<DEFINE GEN-DISPATCH (N W) 
	<CASE ,==?
	      <NODE-TYPE .N>
	      (,FORM-CODE <FORM-GEN .N .W>)
	      (,PROG-CODE <PROG-REP-GEN .N .W>)
	      (,SUBR-CODE <SUBR-GEN .N .W>)
	      (,COND-CODE <COND-GEN .N .W>)
	      (,LVAL-CODE <LVAL-GEN .N .W>)
	      (,SET-CODE <SET-GEN .N .W>)
	      (,OR-CODE <OR-GEN .N .W>)
	      (,AND-CODE <AND-GEN .N .W>)
	      (,RETURN-CODE <RETURN-GEN .N .W>)
	      (,COPY-CODE <COPY-GEN .N .W>)
	      (,AGAIN-CODE <AGAIN-GEN .N .W>)
	      (,ARITH-CODE <ARITH-GEN .N .W>)
	      (,RSUBR-CODE <SUBR-GEN .N .W>)
	      (,0-TST-CODE <0-TEST .N .W>)
	      (,NOT-CODE <NOT-GEN .N .W>)
	      (,1?-CODE <1?-GEN .N .W>)
	      (,TEST-CODE <TEST-GEN .N .W>)
	      (,EQ-CODE <==-GEN .N .W>)
	      (,TY?-CODE <TYPE?-GEN .N .W>)
	      (,LNTH-CODE <LNTH-GEN .N .W>)
	      (,MT-CODE <MT-GEN .N .W>)
	      (,REST-CODE <REST-GEN .N .W>)
	      (,NTH-CODE <NTH-GEN .N .W>)
	      (,PUT-CODE <PUT-GEN .N .W>)
	      (,PUTR-CODE <PUTREST-GEN .N .W>)
	      (,FLVAL-CODE <FLVAL-GEN .N .W>)
	      (,FSET-CODE <FSET-GEN .N .W>)
	      (,FGVAL-CODE <FGVAL-GEN .N .W>)
	      (,FSETG-CODE <FSETG-GEN .N .W>)
	      (,MIN-MAX-CODE <MIN-MAX .N .W>)
	      (,CHTYPE-CODE <CHTYPE-GEN .N .W>)
	      (,FIX-CODE <FIX-GEN .N .W>)
	      (,FLOAT-CODE <FLOAT-GEN .N .W>)
	      (,ABS-CODE <ABS-GEN .N .W>)
	      (,MOD-CODE <MOD-GEN .N .W>)
	      (,ID-CODE <ID-GEN .N .W>)
	      (,ASSIGNED?-CODE <ASSIGNED?-GEN .N .W>)
	      (,BITL-CODE <BITLOG-GEN .N .W>)
	      (,ISUBR-CODE <SUBR-GEN .N .W>)
	      (,EOF-CODE <ID-GEN .N .W>)
	      (,READ-EOF2-CODE <READ2-GEN .N .W>)
	      (,READ-EOF-CODE <SUBR-GEN .N .W>)
	      (,GET2-CODE <GET2-GEN .N .W>)
	      (,GET-CODE <GET-GEN .N .W>)
	      (,IPUT-CODE <SUBR-GEN .N .W>)
	      (,MAP-CODE <MAPFR-GEN .N .W>)
	      (,MARGS-CODE <MPARGS-GEN .N .W>)
	      (,MAPLEAVE-CODE <MAPLEAVE-GEN .N .W>)
	      (,MAPRET-STOP-CODE <MAPRET-STOP-GEN .N .W>)
	      (,UNWIND-CODE <UNWIND-GEN .N .W>)
	      (,GVAL-CODE <GVAL-GEN .N .W>)
	      (,SETG-CODE <SETG-GEN .N .W>)
	      (,MEMQ-CODE <MEMQ-GEN .N .W>)
	      (,LENGTH?-CODE <LENGTH?-GEN .N .W>)
	      (,FORM-F-CODE <FORM-F-GEN .N .W>)
	      (,ALL-REST-CODE <ALL-REST-GEN .N .W>)
	      (,COPY-LIST-CODE <LIST-BUILD .N .W>)
	      (,PUT-SAME-CODE <PUT-GEN .N .W>)
	      (,BACK-CODE <BACK-GEN .N .W>)
	      (,TOP-CODE <TOP-GEN .N .W>)
	      (,ROT-CODE <ROT-GEN .N .W>)
	      (,LSH-CODE <LSH-GEN .N .W>)
	      (,BIT-TEST-CODE <BIT-TEST-GEN .N .W>)
	      (,CALL-CODE <CALL-GEN .N .W>)
	      (,MONAD-CODE <MONAD?-GEN .N .W>)
	      (,GASSIGNED?-CODE <GASSIGNED?-GEN .N .W>)
	      (,APPLY-CODE <APPLY-GEN .N .W>)
	      (,ADECL-CODE <ADECL-GEN .N .W>)
	      (,MULTI-RETURN-CODE <MULTI-RETURN-GEN .N .W>)
	      (,VALID-CODE <VALID-TYPE?-GEN .N .W>)
	      (,TYPE-C-CODE <TYPE-C-GEN .N .W>)
	      (,=?-STRING-CODE <=?-STRING-GEN .N .W>)
	      (,CASE-CODE <CASE-GEN .N .W>)
	      (,FGETBITS-CODE <FGETBITS-GEN .N .W>)
	      (,FPUTBITS-CODE <FPUTBITS-GEN .N .W>)
	      (,ISTRUC-CODE <ISTRUC-GEN .N .W>)
	      (,ISTRUC2-CODE <ISTRUC-GEN .N .W>)
	      (,STACK-CODE <STACK-GEN .N .W>)
	      (,CHANNEL-OP-CODE <CHANNEL-OP-GEN .N .W>)
	      (,ATOM-PART-CODE <ATOM-PART-GEN .N .W>)
	      (,OFFSET-PART-CODE <OFFSET-PART-GEN .N .W>)
	      (,PUT-GET-DECL-CODE <PUT-GET-DECL-GEN .N .W>)
	      (,SUBSTRUC-CODE <SUBSTRUC-GEN .N .W>)
	      (,MULTI-SET-CODE <MULTI-SET-GEN .N .W>)
	      DEFAULT
	      (<DEFAULT-GEN .N .W>)>>