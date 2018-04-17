
<PACKAGE "STRGEN">

<ENTRY NTH-GEN
       REST-GEN
       PUT-GEN
       LNTH-GEN
       MT-GEN
       PUTREST-GEN
       IPUT-GEN
       IREMAS-GEN
       COMMUTE-STRUC
       DEFER-IT
       LIST-LNT-SPEC
       EMPTY-CHECK
       NTH-DO
       REST-DO
       RECTYPE?
       MONAD?-GEN
       BACK-GEN
       TOP-GEN>

<USE "COMPDEC" "CODGEN" "CHKDCL" "SPCGEN" "CARGEN" "MIMGEN" "ADVMESS">

<SETG MAX-IN-ROW 4>

<SETG CMAX-IN-ROW 2>

<MANIFEST MAX-IN-ROW CMAX-IN-ROW>

<DEFINE LIST-LNT-SPEC (N W NF BR DI NUM SF
		       "AUX" (K <KIDS .N>) REG RAC (FLS <==? .W FLUSHED>)
			     (B2 <COND (<AND .BR .FLS> .BR) (ELSE <MAKE-TAG>)>)
			     (SDIR .DI) (B3 <>) B4 F1 F2 F3
			     (SBR <NODE-NAME .N>) TT)
	#DECL ((N) NODE (NUM) FIX (K) <LIST [REST NODE]>)
	<SET REG
	     <GEN <SET TT
		       <1 <KIDS <COND (<==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
				       <2 .K>)
				      (ELSE <1 .K>)>>>>>>
	<AND .NF <SET DI <NOT .DI>>>
	<COND (.SF
	       <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .W>>)>
	<SET DI <COND (<AND .BR <NOT .FLS>> <NOT .DI>) (ELSE .DI)>>
	<AND .DI <SET SBR <FLIP .SBR>>>
	<SET F1 <MEMQ .SBR '[==? G? G=? 1? 0?]>>
	<SET F2 <MEMQ .SBR '[G? G=?]>>
	<SET F3 <MEMQ .SBR '[L? L=?]>>
	<COND (<OR <==? .SBR L=?> <==? .SBR G?>> <SET NUM <- .NUM 1>>)>
	<COND (<L=? .NUM 2>
	       <REPEAT ((FLG T))
		       <EMPTY-LIST .REG
				   <COND (<L=? .NUM 0> .B2)
					 (.F3 .B2)
					 (<OR .F2 <NOT .F1>>
					  <OR .B3 <SET B3 <MAKE-TAG>>>)
					 (ELSE .B2)>
				   <OR <NOT <0? .NUM>> <NOT .F1>>>
		       <COND (<L? <SET NUM <- .NUM 1>> 0>
			      <AND .B3 <LABEL-TAG .B3>>
			      <RETURN>)>
		       <SET FLG <>>
		       <REST-LIST .REG
				  <COND (<OR <NOT <TYPE? .REG TEMP>>
					     <G=? <TEMP-REFS .REG> 2>>
					 <FREE-TEMP .REG <>>
					 <SET REG <GEN-TEMP LIST>>)
					(ELSE .REG)>
				  1>>
	       <FREE-TEMP .REG>)
	      (ELSE
	       <COND (<OR <NOT <TYPE? .REG TEMP>> <G=? <TEMP-REFS .REG> 2>>
		      <SET REG <MOVE-ARG .REG <GEN-TEMP <>>>>)>
	       <SET-TEMP <SET RAC <GEN-TEMP FIX>>
			 <COND (<OR .F2 .F3> <+ .NUM 1>) (ELSE .NUM)>
			 '(`TYPE FIX)>
	       <IEMIT `LOOP (<TEMP-NAME .REG> VALUE) (<TEMP-NAME .RAC> VALUE)>
	       <LABEL-TAG <SET B4 <MAKE-TAG>>>
	       <EMPTY-LIST .REG
			   <COND (<AND <NOT .F3> <OR .F2 <NOT .F1>>>
				  <OR .B3 <SET B3 <MAKE-TAG>>>)
				 (ELSE .B2)>
			   T>
	       <REST-LIST .REG .REG 1>
	       <IEMIT `SUB .RAC 1 = .RAC '(`TYPE FIX)>
	       <IEMIT `GRTR? .RAC 0 + .B4 '(`TYPE FIX)>
	       <COND (<OR .F3 .F2> <AND .B3 <BRANCH-TAG .B2>>)
		     (ELSE <EMPTY-LIST .REG .B2 <NOT .F1>>)>
	       <COND (.B3 <LABEL-TAG .B3>)>
	       <FREE-TEMP .REG>
	       <FREE-TEMP .RAC>)>
	<COND (<NOT .BR> <TRUE-FALSE .N .B2 .W>)
	      (<NOT .FLS>
	       <SET W <MOVE-ARG <REFERENCE .SDIR> .W>>
	       <BRANCH-TAG .BR>
	       <LABEL-TAG .B2>
	       .W)>>

<DEFINE LNTH-GEN (NOD WHERE
		  "AUX" (STRN <1 <KIDS .NOD>>) T1 T2 STR
			(ITYP <RESULT-TYPE .STRN>) (TYP <STRUCTYP .ITYP>))
	#DECL ((STRN NOD) NODE (K) <LIST [REST NODE]> (T1 T2) ATOM)
	<SET STR <GEN .STRN DONT-CARE>>
	<FREE-TEMP .STR <>>
	<COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP FIX>>)
	      (<TYPE? .WHERE TEMP> <USE-TEMP .WHERE FIX>)>
	<COND (<==? .TYP LIST> <LENGTH-LIST .STR .WHERE>)
	      (<OR <==? .TYP VECTOR>
		   <==? .TYP TUPLE>>
	       <LENGTH-VECTOR .STR .WHERE>)
	      (<==? .TYP STRING> <LENGTH-STRING .STR .WHERE>)
	      (<==? .TYP BYTES> <LENGTH-BYTES .STR .WHERE>)
	      (<==? .TYP UVECTOR> <LENGTH-UVECTOR .STR .WHERE>)
	      (<==? .TYP TEMPLATE> <LENGTH-RECORD .STR .WHERE .ITYP>)
	      (ELSE <LENGTH-RECORD .STR .WHERE .TYP>)>
	.WHERE>

<DEFINE MONAD?-GEN (NOD WHERE) <MT-GEN .NOD .WHERE>>

<DEFINE MT-GEN (NOD WHERE
		"OPTIONAL" (NOTF <>) (BRANCH <>) (DIR <>) (SETF <>)
		"AUX" (STRN <1 <KIDS .NOD>>) STR (ITYP <RESULT-TYPE .STRN>)
		      (SDIR .DIR) (TYP <STRUCTYP .ITYP>) (TY <ISTYPE? .ITYP>)
		      (FLS <==? .WHERE FLUSHED>)
		      (B2
		       <COND (<AND .BRANCH .FLS> .BRANCH) (ELSE <MAKE-TAG>)>))
	#DECL ((STRN NOD) NODE (B2) ATOM (BRANCH) <OR ATOM FALSE>)
	<COND (<==? .WHERE DONT-CARE> <SET WHERE <GEN-TEMP <>>>)>
	<AND .NOTF <SET DIR <NOT .DIR>>>
	<COND (.SETF
	       <DEALLOCATE-TEMP <MOVE-ARG <REFERENCE <NOT .SDIR>> .WHERE>>)>
	<SET DIR <COND (<AND .BRANCH <NOT .FLS>> <NOT .DIR>) (ELSE .DIR)>>
	<SET STR <GEN .STRN>>
	<COND (<==? <NODE-TYPE .NOD> ,MONAD-CODE>
	       <IEMIT `MONAD? .STR <COND (.DIR +) (ELSE -)> .B2>)
	      (<==? .TYP LIST> <EMPTY-LIST .STR .B2 .DIR .TY>)
	      (<OR <==? .TYP VECTOR>
		   <==? .TYP TUPLE>>
	       <EMPTY-VECTOR .STR .B2 .DIR .TY>)
	      (<==? .TYP UVECTOR> <EMPTY-UVECTOR .STR .B2 .DIR .TY>)
	      (<==? .TYP STRING> <EMPTY-STRING .STR .B2 .DIR .TY>)
	      (<==? .TYP BYTES> <EMPTY-BYTES .STR .B2 .DIR .TY>)
	      (<==? .TYP TEMPLATE> <EMPTY-RECORD .STR .B2 .DIR .ITYP>)
	      (<ISTYPE? .ITYP> <EMPTY-RECORD .STR .B2 .DIR .TYP>)
	      (ELSE <IEMIT `EMPTY? .STR <COND (.DIR +) (ELSE -)> .B2>)>
	<FREE-TEMP .STR>
	<COND (<NOT .BRANCH> <TRUE-FALSE .NOD .B2 .WHERE>)
	      (<NOT .FLS>
	       <SET WHERE <MOVE-ARG <REFERENCE .SDIR> .WHERE>>
	       <BRANCH-TAG .BRANCH>
	       <LABEL-TAG .B2>
	       .WHERE)>>

<DEFINE REST-GEN (NOD WHERE
		  "AUX" (STRNOD <1 <KIDS .NOD>>) (NUMNOD <2 <KIDS .NOD>>)
			(TYP <RESULT-TYPE .STRNOD>) (TPS <STRUCTYP .TYP>)
			(NUMKN <==? <NODE-TYPE .NUMNOD> ,QUOTE-CODE>)
			(NUM <COND (.NUMKN
				    ; "TAA 5/20/86"
				    <COND (<TYPE? <NODE-NAME .NUMNOD> OFFSET>
					   <INDEX <NODE-NAME .NUMNOD>>)
					  (T
					   <NODE-NAME .NUMNOD>)>)
				   (ELSE 0)>)
			(ML <MINL .TYP>) STR NUMN (ONO .NO-KILL)
			(NO-KILL .ONO) (LCAREFUL .CAREFUL) (W .WHERE) RV
			(NEED-CHTYPE <OR <N==? <ISTYPE? .TYP> .TPS>
					 <==? <NODE-TYPE .STRNOD>
					      ,CHTYPE-CODE>>)
			(NR <GET-RANGE <RESULT-TYPE .NUMNOD>>))
	#DECL ((NOD NUMNOD STRNOD) NODE (ML N MP NUM) FIX
	       (NUMNK RV) <OR ATOM FALSE> (NR) <OR FALSE <LIST FIX FIX>>
	       (NO-KILL) <SPECIAL LIST>)
	<SET RV <COMMUTE-STRUC <> .STRNOD .NUMNOD>>
	<COND (.NUMKN
	       <COND (<L? .NUM 0>
		      <COMPILE-ERROR "Negative " <NODE-NAME .NOD> .NOD>)
		     (<0? .NUM>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <SET W <GEN-TEMP>>>)
			    (<TYPE? .WHERE TEMP>
			     <USE-TEMP .WHERE <COND (.NEED-CHTYPE ANY) 
						    (.TYP)>>)
			    (<AND <==? .WHERE ,POP-STACK> .NEED-CHTYPE>
			     <SET W <GEN-TEMP ANY>>)>
		      <SET STR <GEN .STRNOD .W>>)
		     (<AND <==? .TPS LIST>
			   <OR <AND .LCAREFUL <G? .NUM .ML>>
			       <L=? .NUM ,MAX-IN-ROW>>>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <SET W <GEN-TEMP <>>>>)
			    (<TYPE? .WHERE TEMP>)
			    (<AND <==? .WHERE ,POP-STACK> .NEED-CHTYPE>
			     <SET W <GEN-TEMP <>>>)>
		      <SET W
			   <EXPANDED-LIST-REST
			    <GEN .STRNOD> .NUM .ML .LCAREFUL .W>>)
		     (.TPS
		      <SET STR <GEN .STRNOD>>
		      <COND (<AND .LCAREFUL <G? .NUM .ML>>
			     <LENGTH-CHECK .TPS .STR .NUM <RECTYPE? .TYP>>)>
		      <FREE-TEMP .STR <>>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <SET W <GEN-TEMP <COND (.NEED-CHTYPE
								ANY)
							       (.TYP)>>>>)
			    (<TYPE? .WHERE TEMP>
			     <USE-TEMP .WHERE <COND (.NEED-CHTYPE ANY)
						    (.TYP)>>)
			    (<AND <==? .WHERE ,POP-STACK> .NEED-CHTYPE>
			     <SET W <GEN-TEMP>>)>
		      <REST-DO .TPS .STR .W .NUM <RECTYPE? .TYP>>)
		     (ELSE
		      <SET STR <GEN .STRNOD>>
		      <FREE-TEMP .STR <>>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <SET W <GEN-TEMP>>>)
			    (<TYPE? .WHERE TEMP> <USE-TEMP .WHERE>)>
		      <SET NEED-CHTYPE <>>
		      <IEMIT `REST1 .STR = .W>)>
	       <COND (.NEED-CHTYPE
		      <GEN-CHTYPE .W .TPS .WHERE>)>
	       .WHERE)
	      (ELSE
	       <COND (.RV
		      <SET NUMN <GEN .NUMNOD DONT-CARE>>
		      <SET NUMN <INTERF-CHANGE .NUMN .STRNOD>>
		      <SET STR <GEN .STRNOD DONT-CARE>>)
		     (ELSE
		      <SET STR <GEN .STRNOD DONT-CARE>>
		      <SET STR <INTERF-CHANGE .STR .NUMNOD>>
		      <SET NUMN <GEN .NUMNOD DONT-CARE>>)>
	       <COND (<AND .LCAREFUL
			   <NOT <AND .NR <G=? <1 .NR> 0>>>
			   <N==? .TPS LIST>>
		      <LENGTH-CHECK .TPS .STR .NUMN <RECTYPE? .TYP>>)>
	       <COND (<N==? .TPS LIST>
		      <FREE-TEMP .STR <>>
		      <FREE-TEMP .NUMN <>>)>
	       <COND (<==? .TPS LIST>
		      <COND (<AND <==? .WHERE ,POP-STACK> .NEED-CHTYPE>
			     <SET W <GEN-TEMP>>)>
		      <SET W
			   <EXPANDED-LIST-REST .STR
					       .NUMN
					       .ML
					       .LCAREFUL
					       .W>>
		      <COND (<OR <NOT .NEED-CHTYPE>
				 <==? .WHERE DONT-CARE>>
			     <SET WHERE .W>)>)
		     (ELSE
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <SET W <GEN-TEMP <COND (.NEED-CHTYPE
								ANY)
							       (.TYP)>>>>)
			    (<TYPE? .WHERE TEMP>
			     <USE-TEMP .WHERE <COND (.NEED-CHTYPE ANY)
						    (.TYP)>>)
			    (<AND <==? .WHERE ,POP-STACK> .NEED-CHTYPE>
			     <SET W <GEN-TEMP>>)>
		      <REST-DO .TPS .STR .W .NUMN <RECTYPE? .TYP>>)>
	       <COND (.NEED-CHTYPE
		      <GEN-CHTYPE .W .TPS .WHERE>)>
	       .WHERE)>>

<DEFINE REST-DO (TPS STR WHERE NUM "OPTIONAL" (TYP ANY)) 
	<COND (<OR <==? .TPS VECTOR>
		   <==? .TPS TUPLE>>
	       <REST-VECTOR .STR .WHERE .NUM .TPS>)
	      (<==? .TPS UVECTOR> <REST-UVECTOR .STR .WHERE .NUM>)
	      (<==? .TPS STRING> <REST-STRING .STR .WHERE .NUM>)
	      (<==? .TPS BYTES> <REST-BYTES .STR .WHERE .NUM>)
	      (<==? .TPS LIST> <REST-LIST .STR .WHERE .NUM>)
	      (<==? .TPS TEMPLATE> <REST-RECORD .STR .WHERE .NUM .TYP>)
	      (ELSE <REST-RECORD .STR .WHERE .NUM .TPS>)>>

<DEFINE NTH-GEN (NOD WHERE
		 "AUX" (K <KIDS .NOD>) STR (TYP <RESULT-TYPE <1 .K>>)
		       (TPS <STRUCTYP .TYP>) (2ARG <2 .K>) NUMN
		       (NUMKN <==? <NODE-TYPE .2ARG> ,QUOTE-CODE>)
		       (NUM
			<COND (.NUMKN
			       <COND (<TYPE? <NODE-NAME .2ARG> OFFSET>
				      <INDEX <NODE-NAME .2ARG>>)
				     (ELSE <NODE-NAME .2ARG>)>)
			      (ELSE 1)>) (NR <GET-RANGE <RESULT-TYPE .2ARG>>)
		       (TEM <>) (1ARG <1 .K>) NDAT
		       (DONE <>) FLS (LCAREFUL .CAREFUL) (ML <MINL .TYP>)
		       (RV <==? <NODE-NAME .NOD> INTH>)
		       (RESTYP <ISTYPE? <RESULT-TYPE .NOD>>))
	#DECL ((NOD) NODE (K) <LIST NODE NODE> (TPS) ANY (NUM ML COD) FIX)
	<COND (.NUMKN <PUT .2ARG ,NODE-NAME .NUM>)>
	<COND (.NUMKN
	       <COND (<L=? .NUM 0>
		      <COMPILE-ERROR "Negative or 0 "
				     <NODE-NAME .NOD>
				     .NOD>)
		     (<1? .NUM>
		      <SET STR <GEN .1ARG>>
		      <COND (<AND .TPS .LCAREFUL <0? .ML>>
			     <EMPTY-CHECK .TPS .STR <RECTYPE? .TYP>>)>
		      <FREE-TEMP .STR <>>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
			    (<TYPE? .WHERE TEMP>
			     <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
		      <COND (.TPS
			     <NTH-DO .TPS .STR .WHERE 1 <RECTYPE? .TYP>
				     .RESTYP>)
			    (ELSE <IEMIT `NTH1 .STR = .WHERE>)>)
		     (<AND <==? .TPS LIST>
			   <OR <AND .LCAREFUL <G? .NUM .ML>>
			       <L=? .NUM ,MAX-IN-ROW>>>
		      <SET STR
			   <EXPANDED-LIST-REST
			    <GEN .1ARG> .NUM .ML .LCAREFUL>>
		      <FREE-TEMP .STR <>>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
			    (<TYPE? .WHERE TEMP>
			     <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
		      <NTH-DO LIST .STR .WHERE 1 LIST .RESTYP>)
		     (ELSE
		      <SET STR <GEN .1ARG DONT-CARE>>
		      <COND (<AND .LCAREFUL <G? .NUM .ML>>
			     <LENGTH-CHECK
			      .TPS .STR .NUM <RECTYPE? .TYP>>)>
		      <FREE-TEMP .STR <>>
		      <COND (<==? .WHERE DONT-CARE>
			     <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
			    (<TYPE? .WHERE TEMP>
			     <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
		      <NTH-DO .TPS .STR .WHERE .NUM <RECTYPE? .TYP>
			      .RESTYP>)>)
	      (ELSE
	       <COND (.RV
		      <SET NUMN <GEN .2ARG DONT-CARE>>
		      <SET NUMN <INTERF-CHANGE .NUMN .1ARG>>
		      <SET STR <GEN .1ARG DONT-CARE>>)
		     (ELSE
		      <SET STR <GEN .1ARG DONT-CARE>>
		      <SET STR <INTERF-CHANGE .STR .2ARG>>
		      <SET NUMN <GEN .2ARG DONT-CARE>>)>
	       <COND (<AND .LCAREFUL
			   <NOT <AND .NR <G? <1 .NR> 0>>>
			   <N==? .TPS LIST>>
		      <LENGTH-CHECK .TPS .STR .NUMN <RECTYPE? .TYP>>)>
	       <COND (<==? .WHERE DONT-CARE>
		      <SET WHERE <GEN-TEMP <RESULT-TYPE .NOD>>>)
		     (<TYPE? .WHERE TEMP>
		      <USE-TEMP .WHERE <RESULT-TYPE .NOD>>)>
	       <COND (<==? .TPS LIST>
		      <SET STR
			   <EXPANDED-LIST-REST .STR .NUMN .ML .LCAREFUL>>
		      <NTH-DO LIST .STR .WHERE 1 LIST .RESTYP>
		      <FREE-TEMP .STR <>>)
		     (ELSE
		      <NTH-DO .TPS .STR .WHERE .NUMN <RECTYPE? .TYP>
			      .RESTYP>
		      <FREE-TEMP .STR <>>
		      <FREE-TEMP .NUMN <>>)>)>
	.WHERE>

<DEFINE EXPANDED-LIST-REST (STR NUM ML LCAREFUL
			    "OPT" W
			    "AUX" TG1 TG2 (NUMN .NUM))
	#DECL ((ML) FIX)
	<COND (<AND <TYPE? .NUM FIX> <NOT <ASSIGNED? W>>>
	       <SET NUM <- .NUM 1>>)>
	<COND (<AND <TYPE? .NUM FIX>
		    <L=? .NUM
			 <COND (.LCAREFUL ,CMAX-IN-ROW) (ELSE ,MAX-IN-ROW)>>>
	       <REPEAT ()
		       <COND (<AND <L=? .ML 0> .LCAREFUL>
			      <EMPTY-CHECK LIST .STR LIST>)>
		       <COND (<AND <ASSIGNED? W> <1? .NUM>>
			      <FREE-TEMP .STR <>>
			      <COND (<==? .W DONT-CARE>
				     <SET W <GEN-TEMP LIST>>)
				    (<TYPE? .W TEMP> <USE-TEMP .W LIST>)>
			      <REST-DO LIST .STR .W 1>
			      <SET STR .W>)
			     (<AND <TYPE? .STR TEMP>
				   <OR <L=? <TEMP-REFS .STR> 1>
				       <AND <ASSIGNED? W> <==? .STR .W>>>>
			      <REST-DO LIST .STR .STR 1>)
			     (ELSE
			      <FREE-TEMP .STR <>>
			      <REST-DO LIST .STR <SET STR <GEN-TEMP LIST>> 1>)>
		       <COND (<L=? <SET NUM <- .NUM 1>> 0>
			      <COND (<AND .LCAREFUL
					  <NOT <ASSIGNED? W>>
					  <L=? .ML 1>>
				     <EMPTY-CHECK LIST .STR LIST>)>
			      <RETURN>)>
		       <SET ML <- .ML 1>>>)
	      (ELSE
	       <COND (<NOT <AND <TYPE? .NUM TEMP> <L=? <TEMP-REFS .NUM> 1>>>
		      <SET NUMN <MOVE-ARG .NUM <GEN-TEMP <>>>>)>
	       <SET TG1 <MAKE-TAG "RESTL">>
	       <COND (<NOT <AND <TYPE? .STR TEMP>
				<OR <L=? <TEMP-REFS .STR> 1>
				    <AND <ASSIGNED? W> <==? .W .STR>>>>>
		      <SET STR <MOVE-ARG .STR <GEN-TEMP <>>>>)>
	       <COND (<NOT <TYPE? .NUM FIX>>
		      <SET TG2 <MAKE-TAG "RESTL">>
		      <COND (<NOT <ASSIGNED? W>>
			     <IEMIT `SUB .NUMN 1 = .NUMN '(`TYPE FIX)>)>
		      <IEMIT `GRTR? .NUMN 0 - .TG2 '(`TYPE FIX)>)>
	       <IEMIT `LOOP (<TEMP-NAME .STR> VALUE) (<TEMP-NAME .NUMN> VALUE)>
	       <LABEL-TAG .TG1>
	       <IEMIT `INTGO>
	       <COND (<AND .LCAREFUL <OR <NOT <TYPE? .NUM FIX>> <G? .NUM .ML>>>
		      <EMPTY-CHECK LIST .STR LIST>)>
	       <REST-DO LIST .STR .STR 1>
	       <IEMIT `SUB .NUMN 1 = .NUMN '(`TYPE FIX)>
	       <IEMIT `GRTR? .NUMN 0 + .TG1 '(`TYPE FIX)>
	       <COND (<ASSIGNED? TG2> <LABEL-TAG .TG2>)>
	       <FREE-TEMP .NUMN>
	       <COND (<AND .LCAREFUL <NOT <ASSIGNED? W>>>
		      <EMPTY-CHECK LIST .STR LIST>)>
	       <COND (<ASSIGNED? W> <SET STR <MOVE-ARG .STR .W>>)>)>
	.STR>

<DEFINE NTH-DO (TPS STR WHERE NUM "OPTIONAL" (TYP ANY) (RESTYP <>)) 
	<COND (<OR <==? .TPS VECTOR>
		   <==? .TPS TUPLE>>
	       <NTH-VECTOR .STR .WHERE .NUM .RESTYP>)
	      (<==? .TPS UVECTOR> <NTH-UVECTOR .STR .WHERE .NUM .RESTYP>)
	      (<==? .TPS STRING> <NTH-STRING .STR .WHERE .NUM .RESTYP>)
	      (<==? .TPS BYTES> <NTH-BYTES .STR .WHERE .NUM .RESTYP>)
	      (<==? .TPS LIST> <NTH-LIST .STR .WHERE .NUM .RESTYP>)
	      (<==? .TPS TEMPLATE> <NTH-RECORD .STR .WHERE .NUM .TYP .RESTYP>)
	      (ELSE <NTH-RECORD .STR .WHERE .NUM .TPS .RESTYP>)>>

<SETG STYPES [LIST TUPLE VECTOR UVECTOR STORAGE STRING BYTES TEMPLATE]>

<DEFINE NTH-PRED (C) #DECL ((C) FIX) <==? .C 1>>

<DEFINE PUT-GEN (NOD WHERE
		 "OPTIONAL" (SAME? <>)
		 "AUX" (ONO .NO-KILL) (K <KIDS .NOD>) (SNOD <1 .K>)
		       (NNOD <2 .K>) (VNOD <3 .K>) (TYP <RESULT-TYPE .SNOD>)
		       (TPS <STRUCTYP .TYP>) (ML <MINL .TYP>) VN STR NUMN
		       (NUMKN <==? <NODE-TYPE .NNOD> ,QUOTE-CODE>)
		       (NUM
			<COND (.NUMKN
			       <COND (<TYPE? <NODE-NAME .NNOD> OFFSET>
				      <INDEX <NODE-NAME .NNOD>>)
				     (ELSE <NODE-NAME .NNOD>)>)
			      (ELSE 1)>)
		       (RV <AND <NOT .SAME?> <COMMUTE-STRUC <> .NNOD .SNOD>>)
		       (RR
			<AND <NOT .SAME?>
			     <COMMUTE-STRUC <> .VNOD .SNOD>
			     <COMMUTE-STRUC <> .VNOD .NNOD>>)
		       (NR <GET-RANGE <RESULT-TYPE .NNOD>>) ETYP (W .WHERE)
		       FOO)
   #DECL ((NOD) NODE (K) <LIST NODE NODE NODE> (NUM ML) FIX)
   <COND (.NUMKN <PUT .NNOD ,NODE-NAME .NUM>)>
   <SET ETYP <GET-ELE-TYPE .TYP <COND (.NUMKN .NUM) (ALL)>>>
   <COND (<AND <MEMQ <STRUCTYP .ETYP> '[VECTOR UVECTOR STRING BYTES]>
	       <NOT <TYPE? .ETYP SEGMENT>>
	       <OR <NOT <TYPE? .ETYP ATOM>>
		   <NOT <TYPE? <DECL-GET .ETYP> SEGMENT>>>>
	  <SET ETYP <>>)
	 (<N==? <SET ETYP <ISTYPE? .ETYP>> <ISTYPE? <RESULT-TYPE .VNOD>>>
	  <SET ETYP <>>)>
   <COND
    (.NUMKN
     <COND
      (<NOT <G? .NUM 0>> <COMPILE-ERROR "PUT Number to small: " .NUM .NOD>)
      (<1? .NUM>
       <COND (.RR
	      <SET VN <GEN .VNOD DONT-CARE>>
	      <SET VN <INTERF-CHANGE .VN .SNOD>>
	      <SET STR <GEN .SNOD DONT-CARE>>
	      <COND (<AND <0? .ML> .CAREFUL>
		     <EMPTY-CHECK .TPS .STR <RECTYPE? .TYP>>)>)
	     (ELSE
	      <SET STR <GEN .SNOD DONT-CARE>>
	      <COND (<AND .CAREFUL <0? .ML>>
		     <EMPTY-CHECK .TPS .STR <RECTYPE? .TYP>>)>
	      <COND (<NOT .SAME?>
		     <SET STR <INTERF-CHANGE .STR .VNOD>>
		     <SET VN <GEN .VNOD DONT-CARE>>)>)>
       <DELAY-KILL .NO-KILL .ONO>
       <COND (.SAME? <SPEC-GEN .VNOD .STR .TPS .NUM>)
	     (ELSE <DATCLOB .STR .NUM .VN .TPS .TYP .ETYP>)>
       <COND (<NOT .SAME?> <FREE-TEMP .VN>)>
       <SET W <MOVE-ARG .STR .W>>)
      (ELSE
       <COND (.RR
	      <SET VN <GEN .VNOD DONT-CARE>>
	      <SET VN <INTERF-CHANGE .VN .SNOD>>
	      <SET STR <GEN .SNOD DONT-CARE>>)
	     (ELSE
	      <SET STR <GEN .SNOD DONT-CARE>>
	      <COND (<NOT .SAME?>
		     <SET STR <INTERF-CHANGE .STR .VNOD>>
		     <SET VN <GEN .VNOD DONT-CARE>>)>)>
       <DELAY-KILL .NO-KILL .ONO>
       <COND (<AND .CAREFUL <L? .ML .NUM> <NOT .SAME?> <N==? .TPS LIST>>
	      <LENGTH-CHECK .TPS .STR .NUM <RECTYPE? .TYP>>)>
       <SET FOO .STR>
       <COND
	(.SAME? <SPEC-GEN .VNOD .STR .TPS 1>)
	(ELSE
	 <COND (<AND <==? .TPS LIST>
		     <OR <AND .CAREFUL <G? .NUM .ML>> <L=? .NUM ,MAX-IN-ROW>>>
		<DATCLOB <SET FOO
			      <EXPANDED-LIST-REST
			       <USE-TEMP .STR> .NUM .ML .CAREFUL>>
			 1
			 .VN
			 .TPS
			 .TYP
			 .ETYP>)
	       (ELSE <DATCLOB .STR .NUM .VN .TPS .TYP .ETYP>)>)>
       <COND (<N==? .FOO .STR> <FREE-TEMP .FOO>)>
       <COND (<NOT .SAME?> <FREE-TEMP .VN>)>
       <SET W <MOVE-ARG .STR .W>>)>)
    (ELSE
     <COND (.RR
	    <SET VN <GEN .VNOD DONT-CARE>>
	    <SET VN <INTERF-CHANGE .VN .SNOD>>
	    <SET VN <INTERF-CHANGE .VN .NNOD>>)>
     <COND (.RV
	    <SET NUMN <GEN .NNOD DONT-CARE>>
	    <SET NUMN <INTERF-CHANGE .NUMN .SNOD>>
	    <SET STR <GEN .SNOD DONT-CARE>>
	    <COND (<NOT .RR>
		   <SET NUMN <INTERF-CHANGE .NUMN .VNOD>>
		   <SET STR <INTERF-CHANGE .STR .VNOD>>)>)
	   (ELSE
	    <SET STR <GEN .SNOD DONT-CARE>>
	    <SET STR <INTERF-CHANGE .STR .NNOD>>
	    <SET NUMN <GEN .NNOD DONT-CARE>>
	    <COND (<NOT .RR>
		   <SET NUMN <INTERF-CHANGE .NUMN .VNOD>>
		   <SET STR <INTERF-CHANGE .STR .VNOD>>)>)>
     <COND (.RR <DELAY-KILL .NO-KILL .ONO>)>
     <COND (<AND .CAREFUL <NOT <AND .NR <G? <1 .NR> 0>>>>
	    <IEMIT `GRTR? .NUMN 0 - `COMPERR '(`TYPE FIX)>)>
     <COND (<AND .CAREFUL
		 <N==? .TPS LIST>
		 <NOT <AND .NR <L=? <2 .NR> <MINL .TYP>>>>>
	    <LENGTH-CHECK .TPS .STR .NUMN <RECTYPE? .TYP>>)>
     <COND (<NOT .RR>
	    <DELAY-KILL .NO-KILL .ONO>
	    <COND (<NOT .SAME?> <SET VN <GEN .VNOD DONT-CARE>>)>)>
     <COND (.SAME? <SPEC-GEN .VNOD .NUMN .TPS 0>)
	   (ELSE
	    <COND (<AND <==? .TPS LIST> .CAREFUL>
		   <SET STR <EXPANDED-LIST-REST .STR .NUMN .ML .CAREFUL>>
		   <DATCLOB .STR 1 .VN .TPS .TYP .ETYP>)
		  (ELSE
		   <DATCLOB .STR .NUMN .VN .TPS .TYP .ETYP>
		   <FREE-TEMP .NUMN>)>)>
     <COND (<NOT .SAME?> <FREE-TEMP .VN>)>
     <SET W <MOVE-ARG .STR .W>>)>
   .W>

<DEFINE DATCLOB (STR NUM VDAT TPS TYP ETYP "AUX" TT TEM) 
	<COND (.ETYP <SET ETYP (`TYPE .ETYP)>)>
	<COND (<==? .TPS LIST> <PUT-LIST .STR .NUM .VDAT .ETYP>)
	      (<OR <==? .TPS VECTOR>
		   <==? .TPS TUPLE>>
	       <PUT-VECTOR .STR .NUM .VDAT .ETYP>)
	      (<==? .TPS UVECTOR> <PUT-UVECTOR .STR .NUM .VDAT>)
	      (<==? .TPS STRING> <PUT-STRING .STR .NUM .VDAT>)
	      (<==? .TPS BYTES> <PUT-BYTES .STR .NUM .VDAT>)
	      (<==? .TPS TEMPLATE> 
	       <PUT-RECORD .STR .NUM .VDAT <RECTYPE? .TYP> .ETYP>)
	      (ELSE <PUT-RECORD .STR .NUM .VDAT .TPS .ETYP>)>>

<DEFINE RECTYPE? (TYP)
	<COND (<ISTYPE? .TYP>)
	      (<AND <TYPE? .TYP FORM SEGMENT>
		    <G? <LENGTH .TYP> 1>
		    <==? <1 .TYP> OR>>
	       <RECTYPE? <2 .TYP>>)>>

<DEFINE PUTREST-GEN (NOD WHERE
		     "AUX" ST1 ST2 (K <KIDS .NOD>) (ONO .NO-KILL)
			   (NO-KILL .ONO) (2RET <>))
	#DECL ((NOD N) NODE (K) <LIST NODE NODE> (NO-KILL) <SPECIAL LIST>
	       (ONO) LIST)
	<COND (<==? <NODE-SUBR .NOD> ,REST>
	       <SET NOD <1 .K>>
	       <SET K <KIDS .NOD>>
	       <SET 2RET T>)>
	<COND (<AND <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>
		    <==? <NODE-NAME <2 .K>> ()>>
	       <SET ST1 <GEN <1 .K> DONT-CARE>>)
	      (ELSE
	       <SET ST1 <GEN <1 .K> DONT-CARE>>
	       <SET ST1 <INTERF-CHANGE .ST1 <2 .K>>>
	       <SET ST2 <GEN <2 .K> DONT-CARE>>)>
	<COND (<AND .CAREFUL <G? 1 <MINL <RESULT-TYPE <1 .K>>>>>
	       <EMPTY-CHECK LIST .ST1 LIST>)>
	<COND (<ASSIGNED? ST2> <IEMIT `PUTREST .ST1 .ST2>)
	      (ELSE <IEMIT `PUTREST .ST1 ()>)>
	<MOVE-ARG <COND (.2RET <FREE-TEMP .ST1> .ST2)
			(ELSE <FREE-TEMP .ST2> .ST1)>
		  .WHERE>>

<DEFINE SIDE-EFFECTS? (N) 
	#DECL ((N) NODE)
	<AND <N==? <NODE-TYPE .N> ,QUOTE-CODE> <SIDE-EFFECTS .N>>>

<DEFINE COMMUTE-STRUC (RV NUMNOD STRNOD "AUX" N (L .NO-KILL) CD (FLG T)) 
   #DECL ((NO-KILL) LIST (NUMNOD STRNOD) NODE (L) LIST)
   <COND (<OR <AND <NOT .RV>
		   <OR <AND <==? <NODE-TYPE .NUMNOD> ,QUOTE-CODE>
			    <NOT <SET FLG <>>>>
		       <NOT <SIDE-EFFECTS .NUMNOD>>>
		   <MEMQ <SET CD <NODE-TYPE <SET N .STRNOD>>> ,SNODES>>
	      <AND .RV
		   <OR <AND <==? <NODE-TYPE .STRNOD> ,QUOTE-CODE>
			    <NOT <SET FLG <>>>>
		       <NOT <SIDE-EFFECTS .STRNOD>>>
		   <NOT <MEMQ <SET CD <NODE-TYPE <SET N .NUMNOD>>> ,SNODES>>>>
	  <COND (<AND .FLG
		      <==? .CD ,LVAL-CODE>
		      <COND (<==? <LENGTH <SET CD <TYPE-INFO .N>>> 2> <2 .CD>)
			    (ELSE T)>
		      <SET CD <NODE-NAME .N>>
		      <NOT <MAPF <>
				 <FUNCTION (LL) 
					 #DECL ((LL) <LIST SYMTAB ANY>)
					 <AND <==? .CD <1 .LL>> <MAPLEAVE>>>
				 .L>>>
		 <SET NO-KILL ((.CD <>) !.L)>)>
	  <NOT .RV>)
	 (ELSE .RV)>>

\ 

<DEFINE EMPTY-CHECK (TPS STR TYP "OPTIONAL" (DIR T) (TG `COMPERR)) 
	<COND (<OR <==? .TPS VECTOR>
		   <==? .TPS TUPLE>>
	       <EMPTY-VECTOR .STR .TG .DIR>)
	      (<==? .TPS UVECTOR> <EMPTY-UVECTOR .STR .TG .DIR>)
	      (<==? .TPS STRING> <EMPTY-STRING .STR .TG .DIR>)
	      (<==? .TPS BYTES> <EMPTY-BYTES .STR .TG .DIR>)
	      (<==? .TPS LIST> <EMPTY-LIST .STR .TG .DIR>)
	      (<==? .TPS TEMPLATE> '<EMPTY-RECORD .STR .TG .DIR .TYP>)
	      (ELSE '<EMPTY-RECORD .STR .TG .DIR .TPS>)>>

<DEFINE LENGTH-CHECK (TPS STR NUM TYP "AUX" (TMP <GEN-TEMP FIX>)) 
	<PROG ()
	      <COND (<OR <==? .TPS VECTOR>
			 <==? .TPS TUPLE>>
		     <LENGTH-VECTOR .STR .TMP>)
		    (<==? .TPS LIST> <LENGTH-LIST .STR .TMP>)
		    (<==? .TPS UVECTOR> <LENGTH-UVECTOR .STR .TMP>)
		    (<==? .TPS STRING> <LENGTH-STRING .STR .TMP>)
		    (<==? .TPS BYTES> <LENGTH-BYTES .STR .TMP>)
		    (ELSE
		     <FREE-TEMP .TMP>
		     <RETURN>)>
	      <IEMIT `LESS? .TMP .NUM + `COMPERR '(`TYPE FIX)>
	      <FREE-TEMP .TMP>>>

<DEFINE TOP-GEN (N W "AUX" D)
	#DECL ((N) NODE)
	<SET D <GEN <1 <KIDS .N>> DONT-CARE>>
	<FREE-TEMP .D <>>
	<IEMIT `TOPU .D = <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP>>)
				(<TYPE? .W TEMP> <USE-TEMP .W> .W)
				(ELSE .W)>>
	.W>

<DEFINE BACK-GEN (N W "AUX" D NN (K <KIDS .N>)) 
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<SET D <GEN <1 .K> DONT-CARE>>
	<COND (<OR <AND <EMPTY? <REST .K>> <SET NN 1>>
		   <AND <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>
			<SET NN <NODE-NAME <2 .K>>>>>
	       <COND (<TYPE? .NN OFFSET>
		      <SET NN <INDEX .NN>>)>
	       <FREE-TEMP .D <>>
	       <IEMIT `BACKU
		      .D
		      .NN
		      =
		      <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP>>)
			    (<TYPE? .W TEMP> <USE-TEMP .W> .W)
			    (ELSE .W)>>)
	      (ELSE
	       <FREE-TEMP <SET NN <GEN <2 .K> DONT-CARE>> <>>
	       <FREE-TEMP .D <>>
	       <IEMIT `BACKU
		      .D
		      .NN
		      =
		      <COND (<==? .W DONT-CARE> <SET W <GEN-TEMP>>)
			    (<TYPE? .W TEMP> <USE-TEMP .W> .W)
			    (ELSE .W)>>)>
	.W>

<ENDPACKAGE>
