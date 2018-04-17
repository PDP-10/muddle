
<PACKAGE "NOTGEN">

<ENTRY NOT-GEN
       TYPE?-GEN
       ==-GEN
       PRED-BRANCH-GEN
       TYPE-C-GEN
       VALID-TYPE?-GEN
       =?-STRING-GEN
       ATOM-PART-GEN
       OFFSET-PART-GEN
       PUT-GET-DECL-GEN
       SUBSTRUC-GEN>

<USE "COMPDEC"
     "MIMGEN"
     "CODGEN"
     "CHKDCL"
     "CARGEN"
     "STRGEN"
     "ADVMESS"
     "LNQGEN"
     "MMQGEN"
     "MAPGEN"
     "NEWREP">

" Generate NOT code.  This is done in a variety of ways.
	1) If NOTs arg is a predicate itself and this is a predicate usage
	    (flagged by BRANCH arg), just pass through setting the NOTF arg.
	2) If NOTs arg is a predicate but a value is needed,
	    set up a predicate like situation and return NOT of the normal
	    value.
	3) Else just compile and complement result."

<DEFINE NOT-GEN (NOD WHERE
		 "OPTIONAL" (NOTF <>) (BRANCH <>) (DIR T) (SETF <>)
		 "AUX" (P <1 <KIDS .NOD>>) (RW .WHERE)
		       (PF <PRED-CHECK? .P .DIR .WHERE>) T1 T2 TT (FLG <>))
	#DECL ((NOD P) NODE)
	<SET NOTF <NOT .NOTF>>
	<COND (<AND .BRANCH .PF>
	       <SET WHERE
		    <PGEN-DISPATCH .P
				   <COND (<==? .RW FLUSHED> FLUSHED)
					 (ELSE .WHERE)>
				   .NOTF
				   .BRANCH
				   .DIR
				   .SETF>>)
	      (<AND .BRANCH <==? .RW FLUSHED>>
	       <AND .NOTF <SET DIR <NOT .DIR>>>
	       <SET WHERE <GEN .P DONT-CARE>>
	       <D-B-TAG .BRANCH .WHERE .DIR <RESULT-TYPE .P>>)
	      (.BRANCH
	       <SET TT <GEN .P DONT-CARE>>
	       <SET T1 <MAKE-TAG>>
	       <D-B-TAG .T1 .TT .DIR <RESULT-TYPE .P>>
	       <FREE-TEMP .TT>
	       <SET WHERE <MOVE-ARG <REFERENCE .DIR> .WHERE>>
	       <BRANCH-TAG .BRANCH>
	       <LABEL-TAG .T1>
	       <COND (.SETF
		      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .DIR>> .WHERE>>)>)
	      (<==? .RW FLUSHED> <SET WHERE <GEN .P FLUSHED>>)
	      (<OR <SET FLG <==? <ISTYPE? <RESULT-TYPE .NOD>> FALSE>>
		   <NOT <TYPE-OK? <RESULT-TYPE .NOD> FALSE>>>
	       <GEN .P FLUSHED>
	       <SET WHERE <MOVE-ARG <REFERENCE <NOT .FLG>> .WHERE>>)
	      (.PF
	       <SET T1 <MAKE-TAG>>
	       <SET T2 <MAKE-TAG>>
	       <PGEN-DISPATCH .P FLUSHED .NOTF .T1 .DIR .SETF>
	       <COND (<NOT <TYPE? .WHERE TEMP>> <SET WHERE <GEN-TEMP <>>>)>
	       <MOVE-ARG <REFERENCE <>> .WHERE>
	       <BRANCH-TAG .T2>
	       <LABEL-TAG .T1>
	       <DEALLOCATE-TEMP .WHERE>
	       <MOVE-ARG <REFERENCE T> .WHERE>
	       <LABEL-TAG .T2>)
	      (ELSE
	       <SET T1 <MAKE-TAG>>
	       <SET T2 <MAKE-TAG>>
	       <SET TT <GEN .P DONT-CARE>>
	       <D-B-TAG .T1 .TT T <RESULT-TYPE .P>>
	       <FREE-TEMP .TT>
	       <COND (<NOT <TYPE? .WHERE TEMP>> <SET WHERE <GEN-TEMP <>>>)>
	       <MOVE-ARG <REFERENCE T> .WHERE>
	       <BRANCH-TAG .T2>
	       <LABEL-TAG .T1>
	       <DEALLOCATE-TEMP .WHERE>
	       <MOVE-ARG <REFERENCE <>> .WHERE>
	       <LABEL-TAG .T2>)>
	<MOVE-ARG .WHERE .RW>>

<DEFINE PRED? (N) #DECL ((N) FIX) <N==? <NTH ,PREDV .N> 0>>

<DEFINE PRED-CHECK? (N TF W "AUX" SY K NN NT) 
   #DECL ((N) NODE (SY) SYMTAB)
   <OR
    <N==? <NTH ,PREDV <NODE-TYPE .N>> 0>
    <AND <==? <SET NT <NODE-TYPE .N>> ,CALL-CODE>
	 <G=? <LENGTH <SET K <KIDS .N>>> 2>
	 <OR <AND <OR .TF <==? .W FLUSHED>> <==? <NODE-NAME <1 .K>> `SYSOP>>
	     <=? <SPNAME <NODE-NAME <1 .K>>> "STRING-EQUAL?">>>
    <AND <==? .NT ,SET-CODE>
	 <==? .W FLUSHED>
	 <NOT <SPEC-SYM <SET SY <NODE-NAME .N>>>>
	 <==? <NTH ,PREDV <NODE-TYPE <2 <KIDS .N>>>> 1>>
    <AND
     <OR
      <==? .NT ,PROG-CODE>
      <AND <==? .NT ,MAP-CODE>
	   <==? <NODE-TYPE <SET NN <1 <SET K <KIDS .N>>>>> ,QUOTE-CODE>
	   <NOT <NODE-NAME .NN>>
	   <==? <NODE-TYPE <SET N <2 .K>>> ,MFCN-CODE>
	   <OR <==? <ISTYPE? <SET NT <RESULT-TYPE .N>>> FALSE>
	       <NOT <TYPE-AND .NT FALSE>>>
	   <NOT <MAPF <>
		 <FUNCTION (X:NODE) 
			 <COND (<OR <==? <SET NT <NODE-TYPE .X>> ,SEGMENT-CODE>
				    <==? .NT ,SEG-CODE>>
				<MAPLEAVE T>)>>
		 <REST .K 2>>>>>
     <NOT <ACTIVATED .N>>
     <NOT <ACTIV? <BINDING-STRUCTURE .N>>>
     <==? .W FLUSHED>
     <NOT
      <MAPF <>
       <FUNCTION (SYM:SYMTAB "AUX" NN) 
	       <COND (<OR <SPEC-SYM .SYM>
			  <AND <SET NN <INIT-SYM .SYM>>
			       <OR <==? <SET NT <NODE-TYPE .NN>> ,STACK-CODE>
				   <AND <==? .NT ,COPY-CODE>
					<==? <NODE-NAME .NN> TUPLE>>
				   <AND <OR <==? .NT ,ISTRUC-CODE>
					    <==? .NT ,ISTRUC2-CODE>>
					<==? <NODE-NAME .NN> ITUPLE>>>>>
		      <MAPLEAVE T>)>>
       <BINDING-STRUCTURE .N>>>>>>

" Generate code for ==?.  If types are the same then just compare values,
otherwise generate a full comparison."

<DEFINE ==-GEN (NOD WHERE
		"OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		"AUX" (K <KIDS .NOD>) REG REG2 B2 T2OK T2 T1
		      (TY1 <RESULT-TYPE <1 .K>>) (TY2 <RESULT-TYPE <2 .K>>)
		      (T1OK <ISTYPE? .TY1>)
		      (TYPSAM
		       <AND
			<OR <==? .T1OK <SET T2OK <ISTYPE? .TY2>>>
			    <==? <GETPROP .T1OK ALT-DECL '.T1OK>
				 <GETPROP .T2OK ALT-DECL '.T2OK>>>
			.T1OK>) (RW .WHERE) (SDIR .DIR) (FLS <==? .RW FLUSHED>)
		      INA)
	#DECL ((NOD) NODE (K) <LIST [REST NODE]>)
	<COND (<AND <NOT .TYPSAM>
		    <NOT <TYPE-OK? .TY1 '<PRIMTYPE FIX>>>
		    <NOT <TYPE-OK? .TY2 '<PRIMTYPE FIX>>>
		    <NOT <POINTER-OVERLAP? .TY1 .TY2>>>
	       <SET TYPSAM T>)>
	<COND (<==? <NODE-SUBR .NOD> ,N==?> <SET NOTF <NOT .NOTF>>)>
	<AND <NOT .TYPSAM>
	     <NOT <TYPE-OK? .TY1 .TY2>>
	     <COMPILE-WARNING "Arguments can never be ==? "
			      <NODE-NAME .NOD>
			      .NOD>>
	<COND (<OR <==? <NODE-TYPE <SET T1 <1 .K>>> ,QUOTE-CODE>
		   <AND <NOT <SIDE-EFFECTS .NOD>>
			<N==? <NODE-TYPE <SET T2 <2 .K>>> ,QUOTE-CODE>
			<MEMQ <NODE-TYPE .T1> ,SNODES>
			<N==? <NODE-TYPE .T2> ,LVAL-CODE>>>
	       <PUT .K 1 <2 .K>>
	       <PUT .K 2 .T1>
	       <SET T1 .T1OK>
	       <SET T1OK .T2OK>
	       <SET T2OK .T1>)>
	<COND (.BRANCH
	       <AND .NOTF <SET DIR <NOT .DIR>>>
	       <COND (.SETF
		      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
	       <GEN-EQTST <1 .K>
			  <2 .K>
			  .T1OK
			  .T2OK
			  <COND (.FLS .DIR) (ELSE <NOT .DIR>)>
			  .TYPSAM
			  <COND (.FLS .BRANCH) (ELSE <SET B2 <MAKE-TAG>>)>>
	       <COND (<NOT .FLS>
		      <SET RW
			   <MOVE-ARG <MOVE-ARG <REFERENCE .SDIR> .WHERE> .RW>>
		      <BRANCH-TAG .BRANCH>
		      <LABEL-TAG .B2>
		      .RW)>)
	      (ELSE
	       <SET BRANCH <MAKE-TAG>>
	       <GEN-EQTST <1 .K> <2 .K> .T1OK .T2OK .NOTF .TYPSAM .BRANCH>
	       <COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP <>>>)>
	       <MOVE-ARG <REFERENCE T> .WHERE>
	       <DEALLOCATE-TEMP .WHERE>
	       <BRANCH-TAG <SET B2 <MAKE-TAG>>>
	       <LABEL-TAG .BRANCH>
	       <MOVE-ARG <REFERENCE <>> .WHERE>
	       <LABEL-TAG .B2>
	       <MOVE-ARG .WHERE .RW>)>>

<DEFINE GEN-EQTST (N1 N2 T1 T2 DIR TYPS BR "AUX" (TMP <>) R1 R2) 
	#DECL ((N1 N2) NODE)
	<SET R1 <GEN .N1>>
	<SET R2 <GEN .N2>>
	<COND (.TYPS <GEN-VAL-==? .R1 .R2 .DIR .BR>)
	      (ELSE <GEN-==? .R1 .R2 .DIR .BR>)>
	<FREE-TEMP .R1>
	<FREE-TEMP .R2>>

<DEFINE POINTER-OVERLAP? (TY1 TY2 "AUX" TEM)
	<COND (<AND <TYPE? .TY1 FORM SEGMENT>
		    <NOT <EMPTY? .TY1>>
		    <==? <1 .TY1> OR>>
	       <MAPF <>
		     <FUNCTION (EL)
			  <COND (<POINTER-OVERLAP? .TY2 .EL>
				 <MAPLEAVE T>)>>
		     <REST .TY1>>)
	      (<AND <TYPE? .TY2 FORM SEGMENT>
		    <NOT <EMPTY? .TY2>>
		    <==? <1 .TY2> OR>>
	       <MAPF <>
		     <FUNCTION (EL)
			  <COND (<POINTER-OVERLAP? .TY1 .EL>
				 <MAPLEAVE T>)>>
		     <REST .TY2>>)
	      (<OR <AND <TYPE? .TY1 FORM SEGMENT> <NOT <EMPTY? .TY1>>>
		   <AND <TYPE? .TY2 FORM SEGMENT>
			<NOT <EMPTY? .TY2>>
			<SET TEM .TY1>
			<SET TY1 .TY2>
			<SET TY2 .TEM>>>
	       <COND (<OR <==? <1 .TY1> PRIMTYPE>
			  <AND <TYPE? <SET TEM <1 .TY1>> FORM SEGMENT>
			       <NOT <EMPTY? .TEM>>
			       <==? <1 .TEM> PRIMTYPE>
			       <SET TY1 .TEM>>>
		      <COND (<==? <STRUCTYP .TY2> <2 .TY1>> T)
			    (ELSE <>)>)
		     (ELSE
		      <POINTER-OVERLAP? <1 .TY1> .TY2>)>)
	      (<==? .TY1 .TY2> <>)
	      (<OR <NOT <STRUCTYP .TY1>>
		   <NOT <STRUCTYP .TY2>>
		   <==? <STRUCTYP .TY1> <STRUCTYP .TY2>>>
	       T)
	      (ELSE <>)>>
	       

"	Generate TYPE? code for all various cases."

<DEFINE TYPE?-GEN (NOD WHERE
		   "OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		   "AUX" B2 REG (RW .WHERE) (K <KIDS .NOD>) (SDIR .DIR)
			 (FLS <==? .RW FLUSHED>) B3 (TEST? T) (FIRST T))
   #DECL ((NOD) NODE (K) <LIST [REST NODE]> (WHERE BRANCH B2 B3) ANY)
   <COND (<==? <RESULT-TYPE .NOD> FALSE>
	  <COMPILE-WARNING "TYPE? never true: " .NOD>
	  <SET TEST? #FALSE (1)>)
	 (<NOT <TYPE-OK? <RESULT-TYPE .NOD> FALSE>>
	  <COMPILE-WARNING "TYPE? always true: " .NOD>
	  <SET TEST? #FALSE (2)>)>
   <SET REG <GEN <1 .K> DONT-CARE>>
   <AND .NOTF <SET DIR <NOT .DIR>>>
   <SET K <REST .K>>
   <COND
    (<AND .BRANCH .FLS>
     <AND <NOT <EMPTY? <REST .K>>> <NOT .DIR> <SET B2 <MAKE-TAG>>>
     <REPEAT ()
	     <COND
	      (<EMPTY? <REST .K>>
	       <FREE-TEMP .REG <>>
	       <COND (.TEST? <GEN-TYPE? .REG <NODE-NAME <1 .K>> .BRANCH .DIR>)>
	       <COND (<OR <AND <NOT .TEST?> .DIR <==? <1 .TEST?> 2>>
			  <AND <NOT .TEST?> <NOT .DIR> <==? <1 .TEST?> 1>>>
		      <BRANCH-TAG .BRANCH>)>
	       <AND <ASSIGNED? B2> <LABEL-TAG .B2>>
	       <RETURN>)
	      (ELSE
	       <COND (.TEST?
		      <GEN-TYPE? .REG
				 <NODE-NAME <1 .K>>
				 <COND (.DIR .BRANCH) (ELSE .B2)>
				 T>
		      <GEN-TYPE? .REG
				 <NODE-NAME <2 .K>>
				 <COND (.DIR .BRANCH) (ELSE .B2)>
				 T>)>
	       <COND (<EMPTY? <SET K <REST .K 2>>>
		      <COND (<OR <AND <NOT .DIR> .TEST?>
				 <AND <NOT .TEST?>
				      <OR <AND .DIR <==? <1 .TEST?> 2>>
					  <AND <NOT .DIR>
					       <==? <1 .TEST?> 1>>>>>
			     <BRANCH-TAG .BRANCH>
			     <LABEL-TAG .B2>)>
		      <RETURN>)>)>>)
    (<AND .FLS <NOT .TEST?> <NOT .BRANCH>>)
    (<OR .NOTF <AND <NOT <==? <NOT .BRANCH> <NOT .DIR>>> <NOT .SETF>>>
     <SET B2 <MAKE-TAG>>
     <SET B3 <MAKE-TAG>>
     <COND
      (.TEST?
       <COND (.SETF
	      <COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP <>>>)>
	      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
       <REPEAT ()
	       <COND (<EMPTY? <REST .K>>
		      <FREE-TEMP .REG <>>
		      <GEN-TYPE? .REG
				 <NODE-NAME <1 .K>>
				 .B2
				 <COND (.BRANCH <NOT .DIR>) (ELSE .DIR)>>
		      <RETURN>)
		     (ELSE
		      <GEN-TYPE? .REG
				 <NODE-NAME <1 .K>>
				 <COND (<COND (.BRANCH <NOT .DIR>) (ELSE .DIR)>
					.B2)
				       (ELSE .B3)>
				 T>
		      <GEN-TYPE? .REG
				 <NODE-NAME <2 .K>>
				 <COND (<COND (.BRANCH <NOT .DIR>) (ELSE .DIR)>
					.B2)
				       (ELSE .B3)>
				 T>
		      <COND (<EMPTY? <SET K <REST .K 2>>>
			     <COND (<COND (.BRANCH .DIR) (ELSE <NOT .DIR>)>
				    <BRANCH-TAG .B2>)>
			     <RETURN>)>)>>
       <LABEL-TAG .B3>
       <COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP <>>>)>
       <COND (.BRANCH
	      <SET WHERE <MOVE-ARG <REFERENCE .SDIR> .WHERE>>
	      <BRANCH-TAG .BRANCH>
	      <LABEL-TAG .B2>)
	     (ELSE <TRUE-FALSE .NOD .B2 .WHERE>)>)
      (ELSE
       <COND (.BRANCH
	      <COND (<OR <AND .DIR <==? <1 .TEST?> 2>>
			 <AND <NOT .DIR> <==? <1 .TEST?> 1>>>
		     <SET WHERE <MOVE-ARG <REFERENCE .SDIR> .WHERE>>
		     <BRANCH-TAG .BRANCH>)>)
	     (ELSE <SET WHERE <MOVE-ARG <==? <1 .TEST?> 2> .WHERE>>)>)>)
    (ELSE
     <COND (<NOT <TYPE? .WHERE TEMP>>
	    <COND (<AND <TYPE? .REG TEMP>
			<==? <LENGTH .K> 1>
			<L=? <TEMP-REFS .REG> 1>>
		   <SET WHERE .REG>)
		  (ELSE <SET WHERE <GEN-TEMP <>>>)>)>
     <SET B2 <MAKE-TAG>>
     <COND
      (<OR .TEST? <AND <G=? <LENGTH .K> 2> <==? <1 .TEST?> 2>>>
       <COND (.SETF
	      <DEALLOCATE-TEMP <SET WHERE <MOVE-ARG <REFERENCE <>> .WHERE>>>)>
       <MAPR <>
	<FUNCTION (TYL "AUX" (TY <1 .TYL>)) 
	   <COND (<NOT <AND <NOT .TEST?> <EMPTY? <REST .TYL>>>>
		  <GEN-TYPE?
		   .REG
		   <NODE-NAME .TY>
		   <COND (<OR <NOT .BRANCH> .DIR <NOT <EMPTY? <REST .TYL>>>>
			  <SET B3 <MAKE-TAG>>)
			 (ELSE .BRANCH)>
		   <>>)>
	   <SET WHERE <MOVE-ARG <REFERENCE <NODE-NAME .TY>> .WHERE>>
	   <COND (<NOT .FIRST> <DEALLOCATE-TEMP .WHERE>) (ELSE <SET FIRST <>>)>
	   <COND
	    (<EMPTY? <REST .TYL>>
	     <LABEL-TAG .B2>
	     <COND (<AND .BRANCH .DIR> <BRANCH-TAG .BRANCH> <LABEL-TAG .B3>)
		   (<NOT .BRANCH>
		    <BRANCH-TAG <SET B2 <MAKE-TAG>>>
		    <LABEL-TAG .B3>
		    <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <>> .WHERE>>
		    <LABEL-TAG .B2>)>
	     <FREE-TEMP .REG <>>)
	    (ELSE <BRANCH-TAG .B2> <LABEL-TAG .B3>)>>
	.K>)
      (ELSE
       <COND
	(.BRANCH
	 <COND (<OR <AND .DIR <==? <1 .TEST?> 2>>
		    <AND <NOT .DIR> <==? <1 .TEST?> 1>>>
		<SET WHERE
		     <MOVE-ARG <REFERENCE <AND .DIR <NODE-NAME <1 .K>>>>
			       .WHERE>>
		<BRANCH-TAG .BRANCH>)>)
	(ELSE
	 <SET WHERE
	      <MOVE-ARG <REFERENCE <AND .DIR <NODE-NAME <1 .K>>>>
			.WHERE>>)>)>)>
   <MOVE-ARG .WHERE .RW>>

<DEFINE PGEN-DISPATCH (N W NF B D SF) 
	<CASE ,==?
	      <NODE-TYPE .N>
	      (,CALL-CODE <CALL-GEN .N .W .NF .B .D>)
	      (,COND-CODE <COND-GEN .N .W .NF .B .D>)
	      (,OR-CODE <OR-GEN .N .W .NF .B .D>)
	      (,AND-CODE <AND-GEN .N .W .NF .B .D>)
	      (,0-TST-CODE <0-TEST .N .W .NF .B .D .SF>)
	      (,NOT-CODE <NOT-GEN .N .W .NF .B .D .SF>)
	      (,1?-CODE <1?-GEN .N .W .NF .B .D .SF>)
	      (,TEST-CODE <TEST-GEN .N .W .NF .B .D .SF>)
	      (,EQ-CODE <==-GEN .N .W .NF .B .D .SF>)
	      (,TY?-CODE <TYPE?-GEN .N .W .NF .B .D .SF>)
	      (,MT-CODE <MT-GEN .N .W .NF .B .D .SF>)
	      (,MONAD-CODE <MT-GEN .N .W .NF .B .D .SF>)
	      (,ASSIGNED?-CODE <ASSIGNED?-GEN .N .W .NF .B .D .SF>)
	      (,GET-CODE <GET-GEN .N .W .NF .B .D .SF>)
	      (,GET2-CODE <GET2-GEN .N .W .NF .B .D .SF>)
	      (,MEMQ-CODE <MEMQ-GEN .N .W .NF .B .D .SF>)
	      (,LENGTH?-CODE <LENGTH?-GEN .N .W .NF .B .D .SF>)
	      (,GASSIGNED?-CODE <GASSIGNED?-GEN .N .W .NF .B .D .SF>)
	      (,VALID-CODE <VALID-TYPE?-GEN .N .W .NF .B .D .SF>)
	      (,=?-STRING-CODE <=?-STRING-GEN .N .W .NF .B .D .SF>)
	      (,SET-CODE <SET-GEN .N .W .NF .B .D>)
	      (,MAP-CODE <MAPFR-GEN .N .W .NF .B .D>)
	      (,PROG-CODE <PROG-REP-GEN .N .W .NF .B .D>)
	      DEFAULT
	      (<COMPILE-LOSSAGE "Inconsisent use of predicate internally:  "
				.N>)>>

<DEFINE PRED-BRANCH-GEN (TAG NOD TF
			 "OPTIONAL" (WHERE FLUSHED) (NF <>) (SETF <>)
			 "AUX" (W2
				<COND (<==? .WHERE FLUSHED> DONT-CARE)
				      (ELSE .WHERE)>) TT TAG2)
	#DECL ((NOD) NODE)
	<COND (<==? <RESULT-TYPE .NOD> NO-RETURN> <GEN .NOD FLUSHED> ,NO-DATUM)
	      (<PRED-CHECK? .NOD .TF .WHERE>
	       <PGEN-DISPATCH .NOD .WHERE .NF .TAG .TF .SETF>)
	      (.NF
	       <SET TT <GEN .NOD DONT-CARE>>
	       <COND (<==? .WHERE FLUSHED>
		      <D-B-TAG .TAG .TT <NOT .TF> <RESULT-TYPE .NOD>>)
		     (ELSE
		      <D-B-TAG <SET TAG2 <MAKE-TAG>>
			       .TT
			       .TF
			       <RESULT-TYPE .NOD>>
		      <FREE-TEMP .TT>
		      <SET TT <MOVE-ARG <REFERENCE .TF> .WHERE>>
		      <BRANCH-TAG .TAG>
		      <LABEL-TAG .TAG2>
		      .TT)>)
	      (ELSE
	       <SET TT <GEN .NOD .W2>>
	       <D-B-TAG .TAG .TT .TF <RESULT-TYPE .NOD>>
	       <MOVE-ARG .TT .WHERE>)>>

<DEFINE VALID-TYPE?-GEN (N W
			 "OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
			 "AUX" (NN <1 <KIDS .N>>) (SDIR .DIR) (RW .W)
			       (FLS <==? .RW FLUSHED>) B2 B3 DATA)
	#DECL ((N NN) NODE)
	<COND (.NOTF <SET DIR <NOT .DIR>>)>
	<SET DATA <GEN .NN>>
	<COND (<AND .BRANCH .FLS>
	       <GEN-VT .DATA .BRANCH .DIR>
	       <FREE-TEMP .DATA>
	       ,NO-DATUM)
	      (<AND .FLS <NOT .BRANCH>>)
	      (<OR .NOTF <AND <NOT <==? <NOT .BRANCH> <NOT .DIR>>> <NOT .SETF>>>
	       <SET B2 <MAKE-TAG>>
	       <SET B3 <MAKE-TAG>>
	       <GEN-VT .DATA .B2 <COND (.BRANCH <NOT .DIR>) (ELSE .DIR)>>
	       <FREE-TEMP .DATA>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>
	       <COND (.BRANCH
		      <SET W <MOVE-ARG <REFERENCE .SDIR> .W>>
		      <BRANCH-TAG .BRANCH>
		      <LABEL-TAG .B2>
		      <COND (.SETF
			     <DEALLOCATE-TEMP .W>
			     <MOVE-ARG <REFERENCE <NOT .SDIR>> .W>)>)
		     (ELSE <TRUE-FALSE .N .B2 .W>)>
	       <MOVE-ARG .W .RW>)
	      (ELSE
	       <SET B2 <MAKE-TAG>>
	       <SET B3 <MAKE-TAG>>
	       <COND (<NOT <TYPE? .W TEMP>>
		      <COND (<AND <TYPE? .DATA TEMP> <L=? <TEMP-REFS .DATA> 1>>
			     <SET W .DATA>)
			    (ELSE <SET W <GEN-TEMP <>>>)>)>
	       <COND (.SETF
		      <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <>> .W>>)>
	       <GEN-VT .DATA
		       <COND (.BRANCH) (ELSE .B3)>
		       .DIR .W>
	       <FREE-TEMP .DATA>
	       <COND (<NOT .BRANCH>
		      <BRANCH-TAG .B2>
		      <LABEL-TAG .B3>
		      <MOVE-ARG <REFERENCE <>> .W>
		      <LABEL-TAG .B2>)>
	       <MOVE-ARG .W .RW>)>>

<DEFINE TYPE-C-GEN (N W "AUX" (DATA <GEN <1 <KIDS .N>>>) (RW .W)) 
	<COND (<NOT <TYPE? .W TEMP>>
	       <COND (<AND <TYPE? .DATA TEMP> <L=? <TEMP-REFS .DATA> 1>>
		      <SET W .DATA>)
		     (ELSE <SET W <GEN-TEMP <>>>)>)>
	<GEN-TC .DATA .W>
	<FREE-TEMP .DATA>
	<MOVE-ARG .W .RW>>

<DEFINE =?-STRING-GEN (N W
		       "OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		       "AUX" (N1 <1 <KIDS .N>>) (N2 <2 <KIDS .N>>) (SDIR .DIR)
			     (RW .W) (FLS <==? .RW FLUSHED>) B2 B3 L1 L2)
	#DECL ((N N1 N2) NODE)
	<COND (<==? <NODE-NAME .N> N=?> <SET NOTF <NOT .NOTF>>)>
	<COND (.BRANCH
	       <COND (.NOTF <SET DIR <NOT .DIR>>)>
	       <DO-STR-EQ .N1
			  .N2
			  <COND (.FLS .DIR) (ELSE <NOT .DIR>)>
			  <COND (.FLS .BRANCH) (ELSE <SET B2 <MAKE-TAG>>)>
			  <NODE-NAME .N>>
	       <COND (<NOT .FLS>
		      <COND (.SETF
			     <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>)>
		      <SET RW <MOVE-ARG <MOVE-ARG <REFERENCE .SDIR> .W> .RW>>
		      <BRANCH-TAG .BRANCH>
		      <LABEL-TAG .B2>
		      <COND (.SETF
			     <DEALLOCATE-TEMP .RW>
			     <MOVE-ARG <REFERENCE <NOT .SDIR>> .RW>)>
		      .RW)>)
	      (<==? <NODE-NAME .N> STRCOMP>
	       <DO-STR-EQ .N1 .N2 <> <> STRCOMP .W>)
	      (ELSE
	       <SET BRANCH <MAKE-TAG>>
	       <DO-STR-EQ .N1 .N2 .NOTF .BRANCH <NODE-NAME .N>>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP <>>>)>
	       <MOVE-ARG <REFERENCE T> .W>
	       <DEALLOCATE-TEMP .W>
	       <BRANCH-TAG <SET B2 <MAKE-TAG>>>
	       <LABEL-TAG .BRANCH>
	       <MOVE-ARG <REFERENCE <>> .W>
	       <LABEL-TAG .B2>
	       <MOVE-ARG .W .RW>)>>

<DEFINE DO-STR-EQ (N1 N2 DIR BR NM
		   "OPT" W
		   "AUX" L1 L2 D1 D2 T1 T2 INS TG1 TG2 TG4 TG3 TG5)
   #DECL ((N1 N2) NODE)
   <COND (.DIR <SET TG1 <MAKE-TAG>>)>
   <SET D1 <GEN .N1>>
   <SET D2 <GEN .N2>>
   <COND (<AND <N==? .NM STRCOMP>
	       <N==? .NM S=?>
	       <N==? <ISTYPE? <RESULT-TYPE .N1>> STRING>>
	  <GEN-TYPE? .D1 STRING <COND (.DIR .TG1) (ELSE .BR)> <>>)
	 (<AND <N==? .NM S=?>
	       <N==? .NM STRCOMP>
	       <N==? <ISTYPE? <RESULT-TYPE .N2>> STRING>>
	  <GEN-TYPE? .D2 STRING <COND (.DIR .TG1) (ELSE .BR)> <>>)>
   <COND (<==? .NM STRCOMP>
	  <SET D1 <FIX-STR-TYP <RESULT-TYPE .N1> .D1>>
	  <SET D2 <FIX-STR-TYP <RESULT-TYPE .N2> .D2>>)>
   <IEMIT `IFCAN
	  <SET INS
	       <COND (<==? .NM STRCOMP> "STRCOMP") (ELSE "STRING-EQUAL?")>>>
   <COND (<==? .NM STRCOMP>
	  <SET BR <MAKE-TAG>>
	  <IEMIT `STRCOMP
		 .D1
		 .D2
		 =
		 <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP>>)
		       (<TYPE? .W TEMP> <USE-TEMP .W> .W)
		       (ELSE .W)>>)
	 (ELSE <IEMIT `STRING-EQUAL? .D1 .D2 <COND (.DIR +) (ELSE -)> .BR>)>
   <IEMIT `ENDIF .INS>
   <IEMIT `IFCANNOT .INS>
   <COND (<OR <TYPE? .D1 STRING> <AND <TYPE? .D1 TEMP> <G? <TEMP-REFS .D1> 1>>>
	  <SET D1 <MOVE-ARG .D1 <GEN-TEMP <>>>>)>
   <COND (<OR <TYPE? .D2 STRING> <AND <TYPE? .D2 TEMP> <G? <TEMP-REFS .D2> 1>>>
	  <SET D2 <MOVE-ARG .D2 <GEN-TEMP <>>>>)>
   <LENGTH-STRING .D1 <SET L1 <GEN-TEMP>>>
   <COND (<==? .NM STRCOMP> <LENGTH-STRING .D2 <SET L2 <GEN-TEMP FIX>>>)
	 (ELSE
	  <GEN-VAL-==?
	   .L1
	   <COND (<==? <NODE-TYPE .N2> ,QUOTE-CODE>
		  <LENGTH <CHTYPE <NODE-NAME .N2> STRING>>)
		 (ELSE
		  <LENGTH-STRING .D2 <SET L2 <GEN-TEMP FIX>>>
		  <FREE-TEMP .L2 <>>
		  .L2)>
	   <>
	   <COND (.DIR .TG1) (ELSE .BR)>>)>
   <SET T1 <GEN-TEMP>>
   <SET T2 <GEN-TEMP>>
   <IEMIT `LOOP
	  (<TEMP-NAME .D1> VALUE LENGTH)
	  (<TEMP-NAME .D2> VALUE LENGTH)
	  (<TEMP-NAME .L1> VALUE)
	  !<COND (<==? .NM STRCOMP> ((<TEMP-NAME .L2> VALUE))) (ELSE ())>>
   <LABEL-TAG <SET TG2 <MAKE-TAG>>>
   <NTH-STRING .D1 .T1 1>
   <NTH-STRING .D2 .T2 1>
   <GEN-VAL-==? .T1 .T2 <> <COND (.DIR .TG1) (ELSE .BR)>>
   <COND (<N==? .NM STRCOMP> <FREE-TEMP .T1> <FREE-TEMP .T2>)>
   <REST-STRING .D1 .D1 1>
   <REST-STRING .D2 .D2 1>
   <COND (<==? .NM STRCOMP>
	  <IEMIT `SUB .L2 1 = .L2 '(`TYPE FIX)>
	  <IEMIT `GRTR? .L2 0 - <SET TG3 <MAKE-TAG>> '(`TYPE FIX)>)>
   <IEMIT `SUB .L1 1 = .L1 '(`TYPE FIX)>
   <IEMIT `GRTR? .L1 0 + .TG2 '(`TYPE FIX)>
   <COND (<==? .NM STRCOMP>
	  <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP FIX>>)>
	  <MOVE-ARG 1 .W>
	  <BRANCH-TAG <SET TG4 <MAKE-TAG>>>
	  <LABEL-TAG .TG3>
	  <IEMIT `SUB .L1 1 = .L1 '(`TYPE FIX)>
	  <IEMIT `VEQUAL .L1 0 - <SET TG5 <MAKE-TAG>>>
	  <MOVE-ARG 0 .W>
	  <BRANCH-TAG .TG4>
	  <LABEL-TAG .TG5>
	  <MOVE-ARG -1 .W>
	  <BRANCH-TAG .TG4>
	  <LABEL-TAG .BR>
	  <IEMIT `GRTR? .T1 .T2 - .TG5>
	  <FREE-TEMP .T1>
	  <FREE-TEMP .T2>
	  <MOVE-ARG 1 .W>
	  <LABEL-TAG .TG4>)>
   <COND (.DIR <BRANCH-TAG .BR>)>
   <FREE-TEMP .D1>
   <FREE-TEMP .D2>
   <IEMIT `ENDIF .INS>
   <COND (.DIR <LABEL-TAG .TG1>)>
   <COND (<ASSIGNED? W> .W)>>

<DEFINE FIX-STR-TYP (TYP D "AUX" B)
	<COND (<TYPE? .TYP FORM>
	       <COND (<AND <TYPE? .D TEMP> <G? <TEMP-REFS .D> 1>>
		      <SET D <MOVE-ARG .D <GEN-TEMP <>>>>)>
	       <GEN-TYPE? .D STRING <SET B <MAKE-TAG>> T>
	       <IEMIT `NTHR .D 3 = .D>
	       <LABEL-TAG .B>)>
	.D>

<DEFINE ATOM-PART-GEN (N W
		       "AUX" D (NM <NODE-NAME .N>) (RW .W)
			     (CARE
			      <AND .CAREFUL
				   <OR <==? .NM LBIND> <==? .NM GBIND>>>))
	#DECL ((N) NODE)
	<SET D <GEN <1 <KIDS .N>>>>
	<FREE-TEMP .D <>>
	<IEMIT
	 `NTHR
	 .D
	 <COND (<==? .NM GBIND> 1)
	       (<==? .NM LBIND> 2)
	       (<==? .NM SPNAME> 3)
	       (ELSE 4)>
	 =
	 <COND (<TYPE? .W TEMP> <USE-TEMP .W <ISTYPE? <RESULT-TYPE .N>>>)
	       (<OR <==? .W DONT-CARE> .CARE>
		<SET W <GEN-TEMP <OR <ISTYPE? <RESULT-TYPE .N>> T>>>)
	       (ELSE .W)>
	 '(`RECORD-TYPE ATOM)
	 !<COND (.CARE ('(`BRANCH-FALSE + `COMPERR))) (ELSE ())>>
	<COND (.CARE <SPEC-IEMIT `TYPE? .W '<`TYPE-CODE FALSE> + `COMPERR>)>
	<MOVE-ARG .W .RW>>

<DEFINE OFFSET-PART-GEN (N W
			 "AUX" D (NM <NODE-NAME .N>) (K <KIDS .N>)
			       E (RT <ISTYPE? <RESULT-TYPE .N>>))
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<SET D <GEN <1 .K>>>
	<COND (<EMPTY? <SET K <REST .K>>>
	       <FREE-TEMP .D <>>
	       <IEMIT `NTHUV
		      .D
		      <COND (<==? .NM INDEX> 1) (ELSE 3)>
		      =
		      <COND (<TYPE? .W TEMP> <USE-TEMP .W <OR .RT T>>)
			    (<==? .W DONT-CARE> <SET W <GEN-TEMP <OR .RT T>>>)
			    (ELSE .W)>>)
	      (ELSE
	       <SET E <GEN <1 .K>>>
	       <IEMIT `PUTUV .D 3 .E>
	       <FREE-TEMP .E>
	       <SET W <MOVE-ARG .D .W>>)>
	.W>

<DEFINE PUT-GET-DECL-GEN (N W
			  "AUX" D D1 (NM <NODE-NAME .N>) (NN <1 <KIDS .N>>)
				(ST <RESULT-TYPE .NN>) (RW .W))
	#DECL ((N) NODE)
	<COND (<==? .NM GET-DECL>
	       <SET D <GEN .NN>>
	       <FREE-TEMP .D <>>
	       <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP T>>)
		     (<TYPE? .W TEMP> <USE-TEMP .W>)>
	       <COND (<==? .ST OFFSET> <IEMIT `NTHUV .D 2 = .W>)
		     (ELSE
		      <IEMIT `NTHR .D 3 = .W (`RECORD-TYPE <ISTYPE? .ST>)>)>
	       .W)
	      (ELSE
	       <COND (<TYPE? .W TEMP> <SET D <GEN .NN .W>>)
		     (ELSE <SET D <GEN .NN>>)>
	       <SET D1 <GEN <2 <KIDS .N>>>>
	       <COND (<==? .W FLUSHED> <FREE-TEMP .D <>>)>
	       <FREE-TEMP .D1 <>>
	       <COND (<==? .ST OFFSET> <IEMIT `PUTUV .D 2 .D1>)
		     (ELSE
		      <IEMIT `PUTR .D 3 .D1 (`RECORD-TYPE <ISTYPE? .ST>)>)>
	       <COND (<N==? .W FLUSHED> <SET W <MOVE-ARG .D .W>>)>
	       .W)>>


<DEFINE SUBSTRUC-GEN (N W
		      "AUX" (K <KIDS .N>) (PT <STRUCTYP <RESULT-TYPE .N>>)
			    (LN <LENGTH .K>) (OVERLAP T) (DIR <>) TMP1 TMP2
			    (RSTN <>) (LNTN <>) (STRN <1 .K>) (RESN <>) AMT NT
			    (THE-SYM <>) RSTK NN (SRC-REST 0) (DEST-REST 0)
			    RSTINS LNTINS)
   #DECL ((STRN NN N) NODE (LN) FIX (RSTK K) <LIST [REST NODE]>
	  (RSTN LNTN RESN) <OR FALSE NODE> (SRC-REST DEST-REST) FIX)
   <COND (<G? .LN 1>
	  <SET RSTN <2 .K>>
	  <COND (<G? .LN 2>
		 <SET LNTN <3 .K>>
		 <COND (<G? .LN 3> <SET RESN <4 .K>>)>)>)>
   <COND (<AND .RSTN
	       <==? <NODE-TYPE .RSTN> ,QUOTE-CODE>>
	  <SET SRC-REST <+ <NODE-NAME .RSTN> .SRC-REST>>)>
   <COND (<AND <OR <AND <==? <SET NT <NODE-TYPE .STRN>> ,LVAL-CODE>
			<SET THE-SYM <NODE-NAME .STRN>>>
		   <AND <==? .NT ,REST-CODE>
			<==? <NODE-TYPE <SET NN <2 <SET RSTK <KIDS .STRN>>>>>
			     ,QUOTE-CODE>
			<SET SRC-REST <+ <NODE-NAME .NN> .SRC-REST>>
			<==? <NODE-TYPE <SET NN <1 .RSTK>>> ,LVAL-CODE>
			<SET THE-SYM <NODE-NAME .NN>>>>
	       .RSTN
	       <==? <NODE-TYPE .RSTN> ,QUOTE-CODE>
	       .LNTN
	       <OR <L? <LENGTH .LNTN> <CHTYPE <INDEX ,SIDE-EFFECTS> FIX>>
		   <NOT <SIDE-EFFECTS .LNTN>>>
	       .RESN
	       <OR <AND <==? <SET NT <NODE-TYPE .RESN>> ,LVAL-CODE>
			<==? <NODE-NAME .RESN> .THE-SYM>>
		   <AND <==? .NT ,REST-CODE>
			<==? <NODE-TYPE <SET NN <2 <SET RSTK <KIDS .RESN>>>>>
			     ,QUOTE-CODE>
			<SET DEST-REST <NODE-NAME .NN>>
			<==? <NODE-TYPE <SET NN <1 .RSTK>>> ,LVAL-CODE>
			<==? <NODE-NAME .NN> .THE-SYM>>>>
	  <COND (<G? .SRC-REST .DEST-REST> <SET DIR `FORWARD>)
		(<L? .SRC-REST .DEST-REST> <SET DIR `BACKWARD>)
		; "taa 5/26/88:  Swapped the two directions, for the
		   sake of mnemonicity.  When SRC-REST is greater than
		   DEST-REST, we can use what's conventionally known
		   as a FORWARD BLT, since the first word transferred
		   is not in the area being read, etc.  When SRC-REST
		   is LESS than DEST-REST, we're potentially transferring
		   into the area that will later be read, and therefore
		   need to do it backwards.  MIMOC20 in fact used to do
		   backwards blts with dir FORWARD, and vice versa..."
		(ELSE <COMPILE-ERROR "Bogus SUBSTRUC turkey" .N>)>)
	 (<N==? .LN 4> <SET OVERLAP <>> <SET DIR `FORWARD>)>
   <COND (<AND .THE-SYM
	       <NOT <MAPF <>
			  <FUNCTION (NN:NODE)
			       <COND (<INTERFERE? <TEMP-NAME-SYM .THE-SYM> .NN>
				      <MAPLEAVE T>)>>
			  <REST .K>>>>
	  <USE-TEMP <SET THE-SYM <TEMP-NAME-SYM .THE-SYM>>>)
	 (ELSE <SET THE-SYM <GEN .STRN <GEN-TEMP <>>>>)>
   <COND (<==? .PT VECTOR> <SET RSTINS `RESTUV> <SET LNTINS `LENUV>)
	 (<==? .PT UVECTOR> <SET RSTINS `RESTUU> <SET LNTINS `LENUU>)
	 (<==? .PT STRING> <SET RSTINS `RESTUS> <SET LNTINS `LENUS>)
	 (ELSE <SET RSTINS `RESTUB> <SET LNTINS `LENUB>)>
   <COND (<AND .RSTN <N==? <NODE-TYPE .RSTN> ,QUOTE-CODE>>
	  <SET TMP1 <GEN .RSTN>>
	  <IEMIT .RSTINS
		 .THE-SYM
		 .TMP1
		 =
		 <COND (<L=? <TEMP-REFS .THE-SYM> 1> .THE-SYM)
		       (ELSE
			<FREE-TEMP .THE-SYM>
			<SET THE-SYM <GEN-TEMP .PT>>)>>
	  <FREE-TEMP .TMP1>)
	 (<AND .RSTN <N==? .SRC-REST 0>>
	  <IEMIT .RSTINS
		 .THE-SYM
		 .SRC-REST
		 =
		 <COND (<L=? <TEMP-REFS .THE-SYM> 1> .THE-SYM)
		       (ELSE
			<FREE-TEMP .THE-SYM>
			<SET THE-SYM <GEN-TEMP .PT>>)>>)>
   <COND (.LNTN <SET TMP2 <GEN .LNTN>>)
	 (ELSE <IEMIT .LNTINS .THE-SYM = <SET TMP2 <GEN-TEMP FIX>>>)>
   <COND (.RESN
	  <SET TMP1 <GEN .RESN <COND (<AND <TYPE? .W TEMP> <N==? .W .THE-SYM>> .W)
				     (ELSE DONT-CARE)>>>
	  <COND (<OR <==? .PT VECTOR> <==? .PT UVECTOR>>
		 <IEMIT `MOVE-WORDS
			.THE-SYM
			.TMP1
			.TMP2
			(`TYPE .PT)
			(`DIRECTION .DIR)>)
		(ELSE
		 <IEMIT `MOVE-STRING
			.THE-SYM
			.TMP1
			.TMP2
			(`NO-OVERLAP <NOT .OVERLAP>)>)>)
	 (ELSE
	  <IEMIT `UUBLOCK
		 <FORM `TYPE-CODE .PT>
		 .TMP2
		 =
		 <COND (<AND <TYPE? .W TEMP> <N==? .W .THE-SYM>>
			<USE-TEMP .W>
			<SET TMP1 .W>)
		       (ELSE <SET TMP1 <GEN-TEMP .PT>>)>
		 (`TYPE .PT)>
	  <COND (<OR <==? .PT VECTOR> <==? .PT UVECTOR>>
		 <IEMIT `MOVE-WORDS
			.THE-SYM
			.TMP1
			.TMP2
			(`TYPE .PT)
			(`DIRECTION .DIR)>)
		(ELSE
		 <IEMIT `MOVE-STRING
			.THE-SYM
			.TMP1
			.TMP2
			(`NO-OVERLAP <NOT .OVERLAP>)>)>)>
   <FREE-TEMP .THE-SYM>
   <FREE-TEMP .TMP2>
   <MOVE-ARG .TMP1 .W>>

<ENDPACKAGE>
