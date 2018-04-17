
<DEFINE SP ("OPT" (CC ,CODE-COUNT) (CV <>) (CLAB T) "AUX" OP-INF
	    (OUTCHAN .OUTCHAN)) 
   #DECL ((CC) FIX (CL) <LIST [REST <UVECTOR [REST FIX]>]>
	  (OUTCHAN) <SPECIAL CHANNEL>)
   <REPEAT ((C 0) NUM-OPS INS LREF OPCODE (IN-CASE? <>))
	   #DECL ((X NUM-OPS INS OPCODE) FIX (IN-CASE?) <OR FALSE FIX>)
     <COND (<G=? <SET C <+ .C 1>> .CC> <RETURN>)>
     <COND (<AND .CLAB <SET LREF <FIND-LABEL .C>>>
	    <PRIN1 <LABEL-REF-NAME .LREF>>
	    <CRLF>)>
     <SET INS <COND (.CV <NTH .CV .C>) (ELSE <NTH-CODE .C>)>>
     <SET OPCODE <CHTYPE <LSH .INS -24> FIX>>
     <SET OP-INF <GET-INST-INFO .OPCODE>>
     <SET NUM-OPS <CHTYPE <LSH <2 .OP-INF> <- ,INIT-SHIFT>> FIX>>
     <COND
      (<MEMQ .OPCODE ,BRANCH-INS>
       <BRANCH-PRINT <1 .OP-INF> .C .INS>)
      (.IN-CASE?
       <TAB>
       <BRANCH-PRINT <> .C .INS>
       <COND (<L? <SET IN-CASE? <- .IN-CASE? 1>> 0> <SET IN-CASE? <>>)>) 
      (<MEMQ .OPCODE ,SPECIAL-OPS> <SPECIAL-CODE-PRINT .INS>)
      (ELSE
       <COND (<MEMQ .OPCODE ,CASE-INS> <SET IN-CASE? 0>)>
       <PRINC "	">
       <PRINT-SQUOZE <1 .OP-INF>>
       <COND
	(<N==? .NUM-OPS 0>
	 <PRINC "	">
	 <REPEAT ((SHFT -16) (FNUM 1) EAC R-OR-L ADR SIZ (INDX <>) STR CB)
	   #DECL ((CB SHFT FNUM EAC R-OR-L ADR SIZ) FIX)
	   <COND (.INDX
		  <PRINC "[">
		  <PRIN-REG-NAME .INDX>
		  <PRINC "]">
		  <SET INDX <>>)>
	   <COND (<L? <SET NUM-OPS <- .NUM-OPS 1>> 0>
		  <COND (<==? .SHFT -24> <SET C <- .C 1>>)>
		  <RETURN>)>
	   <SET ADR <CHTYPE <ANDB <LSH .INS .SHFT> 255> FIX>>
	   <COND (<G? <SET SHFT <+ .SHFT 8>> 0>
		  <SET SHFT -24>
		  <SET C <+ .C 1>>
		  <SET INS
		       <COND (<AND .CV <G=? <LENGTH .CV> .C>> <NTH .CV .C>)
			     (.CV 0)
			     (ELSE <NTH-CODE .C>)>>)>
	   <SET EAC <CHTYPE <ANDB .ADR 240> FIX>>
	   <SET R-OR-L <CHTYPE <ANDB .ADR 15> FIX>>
	   <COND
	    (<L? .EAC ,AM-INX>
	     <PRINC "S^#">
	     <PRIN1 <SET ADR <CHTYPE <ANDB .ADR 63> FIX>>>
	     <COND (.IN-CASE?
		    <COND (<0? .NUM-OPS> <SET IN-CASE? .ADR>)
			  (<1? .NUM-OPS> <SET CB .ADR>)>)>)
	    (<==? .EAC ,AM-INX>
	     <SET NUM-OPS <+ .NUM-OPS 1>>
	     <SET INDX .R-OR-L>)
	    (<==? .EAC ,AM-REG> <PRIN-REG-NAME .R-OR-L>)
	    (<AND <==? .EAC ,AM-REGD>
		  <OR <AND <==? .R-OR-L ,NAC-F> <PRINT-STACK-REF 0>>
		      <AND <==? .R-OR-L ,NAC-M> <PROG ()
						      <PRINT-MREF 0>
						      1>>>>)
	    (<OR <==? .EAC ,AM-REGD> <AND <==? .EAC ,AM-ADEC> <PRINC "-">>>
	     <PRINC "(">
	     <PRIN-REG-NAME .R-OR-L>
	     <PRINC ")">)
	    (<OR <==? .EAC ,AM-AINC> <AND <==? .EAC ,AM-AINCD> <PRINC "@">>>
	     <COND
	      (<==? .R-OR-L ,NAC-PC>
	       <SET SIZ <CHTYPE <ANDB <GET-OP-INFO .FNUM .OP-INF> 7> FIX>>
	       <COND (<==? .EAC ,AM-AINCD> <SET SIZ 4>)
		     (<OR <==? .SIZ ,SZ-L> <==? .SIZ ,SZ-F>> <SET SIZ 4>)
		     (<==? .SIZ ,SZ-W> <SET SIZ 2>)
		     (ELSE <SET SIZ 1>)>
	       <REPEAT ((IM 0) (CNT -8) LB INAME IDISP
			(NM
			 <COND (<==? .SIZ 1> -256)
			       (<==? .SIZ 2> -65536)
			       (ELSE <IFSYS ("TOPS20"
					     <CHTYPE #WORD *740000000000* FIX>)
					    ("VAX" 0)>)>))
		       <COND (<L? <SET SIZ <- .SIZ 1>> 0>
			      <COND (<G? <CHTYPE .LB FIX> 127>
				     <SET IM <CHTYPE <ORB .IM .NM> FIX>>)>
			      <COND (<AND <MEMQ .OPCODE ,MIM-CALLS>
					  <L=? <SET IDISP <+ </ .IM 4> 1>>
					       ,RTE-DISPATCH-TABLE-SIZE>
					  <SET INAME
					       <NTH ,RTE-DISP-TABLE .IDISP>>>
				     <PRINC .INAME>)
				    (ELSE
				     <PRINC "#">
				     <PRIN1 .IM>)>
			      <COND (.IN-CASE?
				     <COND (<L=? .NUM-OPS 0>
					    <SET IN-CASE? .IM>)
					   (<1? .NUM-OPS> <SET CB .IM>)>)>
			      <RETURN>)>
		       <SET CNT <+ .CNT 8>>
		       <SET IM
			    <CHTYPE
			     <ORB .IM
				  <LSH <SET LB <ANDB <LSH .INS .SHFT> 255>>
				       .CNT>>
			     FIX>>
		       <COND (<G? <SET SHFT <+ .SHFT 8>> 0>
			      <SET SHFT -24>
			      <SET C <+ .C 1>>
			      <SET INS
				   <COND (<AND .CV <G=? <LENGTH .CV> .C>>
					  <NTH .CV .C>)
					 (.CV 0)
					 (ELSE <NTH-CODE .C>)>>)>>)
	      (ELSE <PRINC "("> <PRIN-REG-NAME .R-OR-L> <PRINC ")+">)>)
	    (ELSE
	     <SET STR
		  <COND (<==? .EAC ,AM-BDD> <SET SIZ 1> <PRINC "@"> "B^")
			(<==? .EAC ,AM-BD> <SET SIZ 1> "B^")
			(<==? .EAC ,AM-WDD> <SET SIZ 2> <PRINC "@"> "W^")
			(<==? .EAC ,AM-WD> <SET SIZ 2> "W^")
			(<==? .EAC ,AM-LDD> <SET SIZ 4> <PRINC "@"> "L^")
			(<==? .EAC ,AM-LD> <SET SIZ 4> "L^")>>
	     <REPEAT ((IM 0) (CNT -8) LB
		      (NM
		       <COND (<==? .SIZ 1> -256)
			     (<==? .SIZ 2> -65536)
			     (ELSE <IFSYS ("TOPS20"
					   <CHTYPE #WORD *740000000000* FIX>)
					  ("VAX" 0)>)>))
		     <COND (<L? <SET SIZ <- .SIZ 1>> 0>
			    <COND (<G? <CHTYPE .LB FIX> 127>
				   <SET IM <CHTYPE <ORB .IM .NM> FIX>>)>
			    <COND (<AND <==? .R-OR-L ,NAC-F>
					<PRINT-STACK-REF .IM>>)
				  (<==? .R-OR-L ,NAC-M> <PRINT-MREF .IM>)
				  (ELSE
				   <PRINC .STR>
				   <PRIN1 .IM>
				   <COND (.IN-CASE?
					  <COND (<L=? .NUM-OPS 0>
						 <SET IN-CASE? .IM>)
						(<1? .NUM-OPS> <SET CB .IM>)>)>
				   <PRINC "(">
				   <PRIN-REG-NAME .R-OR-L>
				   <PRINC ")">)>
			    <RETURN>)>
		     <SET CNT <+ .CNT 8>>
		     <SET IM
			  <CHTYPE <ORB .IM
				       <LSH <SET LB
						 <ANDB <LSH .INS .SHFT> 255>>
					    .CNT>>
				  FIX>>
		     <COND (<G? <SET SHFT <+ .SHFT 8>> 0>
			    <SET SHFT -24>
			    <SET C <+ .C 1>>
			    <SET INS
				 <COND (<AND .CV <G=? <LENGTH .CV> .C>>
					<NTH .CV .C>)
				       (.CV 0)
				       (ELSE <NTH-CODE .C>)>>)>>)>
	   <COND (<AND <NOT .INDX> <N==? .NUM-OPS 0>> <PRINC ",">)>>)>)>
     <CRLF>>>

<DEFINE PRIN-REG-NAME (N) 
	<PRINC <NTH '[R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 F TP SP PC]
		    <+ .N 1>>>>

<DEFINE BRANCH-PRINT (SQN PTR INS
		      "AUX" ECODE XREF CCODE (OUTCHAN .OUTCHAN))
	#DECL ((INS PTR EADISP) FIX (SQN) <OR FALSE FIX>)
	<SET XREF <FIND-XREF .PTR <CHTYPE <ANDB .INS 65535> FIX>>>
	<SET ECODE <XREF-INFO-STACK-SAVE-CODE .XREF>>
	<AND .ECODE <NOT <EMPTY? .ECODE>> <SP <+ <LENGTH .ECODE> 1> .ECODE <>>>
	<PRINC "	">
	<COND (.SQN <PRINT-SQUOZE .SQN>)>
	<PRINC "	">
	<PRIN1 <LABEL-REF-NAME <XREF-INFO-LABEL .XREF>>>>

<DEFINE SPECIAL-CODE-PRINT (INS
			    "OPT" DESTDISP
			    "AUX" (OFFS
				   <CHTYPE <ANDB .INS 65535> FIX>)
				  (CODE <CHTYPE <ANDB <LSH .INS -24> 255> FIX>)
				  PSAVE PATCH LREF UC (OUTCHAN .OUTCHAN)
				  DESTEA)
	#DECL ((INS) FIX)
	<COND (<==? .CODE ,INST-PATCH>
	       <COND (<NOT <0? .OFFS>>
		      <SET PATCH <PATCH-CODE <GET-PATCH .OFFS>>>
		      <OR <EMPTY? .PATCH>
			  <SP <+ <LENGTH .PATCH> 1> .PATCH <>>>)>)
	      (<==? .CODE ,INST-PSTORE>
	       <SET PSAVE <GET-PTNS .OFFS>>
	       <COND (<PTNS-USE .PSAVE>
		      <SET PATCH <PTNS-CODE .PSAVE>>
		      <OR <EMPTY? .PATCH>
			  <SP <+ <LENGTH .PATCH> 1> .PATCH <>>>)>)
	      (<==? .CODE ,INST-CALL>
	       <SET UC <NTH ,CALL-TABLE .OFFS>>
	       <TAB>
	       <PRINC "<CALL ">
	       <PRIN1 <UC-NAME .UC>>
	       <PRINC !\ >
	       <PRIN1 <UC-NUMBER-ARGS .UC>>
	       <PRINC !\>>
	       <CRLF>)
	      (<==? .CODE ,INST-PUSHLAB>
	       <SET LREF <NTH ,PUSH-LABEL-TABLE .OFFS>>
	       <TAB>
	       <PRINC "<PUSH-LABEL ">
	       <PRIN1 <LABEL-REF-NAME .LREF>>
	       <PRINC !\>>
	       <CRLF>)
	      (<==? .CODE ,INST-MOVELAB>
	       <SET LREF <NTH ,MOVE-LABEL-TABLE .OFFS>>
	       <TAB>
	       <PRINC "<MOVE-LABEL ">
	       <PRIN1 <LABEL-REF-NAME .LREF>>
	       <SET DESTEA <GET-FIELD .INS ,DESTEA-FIELD>>
	       <PRINC " ">
	       <PRINT-EA .DESTEA .DESTDISP 3>
	       <PRINC ">">
	       <CRLF>)>>

<DEFINE ICALL-TEST (INSNAME EAFIELD EADISP
		    "AUX" IDISP INAME (OUTCHAN .OUTCHAN))
	#DECL ((INSNAME EAFIELD EADISP) FIX)
	<COND (<AND <OR <==? .INSNAME ,NAME-JMP> <==? .INSNAME ,NAME-JSR>>
		    <==? <GET-FIELD .EAFIELD <BITS 3 3>> 5>
		    <L=? <SET IDISP <+ </ .EADISP 4> 1>>
			 ,RTE-DISPATCH-TABLE-SIZE>
		    <SET INAME <NTH ,RTE-DISP-TABLE .IDISP>>>
	       <TAB>
	       <PRINC !\<>
	       <PRINT-SQUOZE .INSNAME>
	       <TAB>
	       <PRINC .INAME>
	       T)>>

<DEFINE FIND-LABEL (PTR) 
	#DECL ((NUM) FIX)
	<REPEAT ((TAB ,LABEL-TABLE))
		<COND (<EMPTY? .TAB> <RETURN <>>)>
		<COND (<==? .PTR <LABEL-REF-CODE-PTR <1 .TAB>>>
		       <RETURN <1 .TAB>>)>
		<SET TAB <REST .TAB>>>>

<DEFINE FIND-XREF (PTR DISP "AUX" LREF) 
	#DECL ((PTR DISP) FIX)
	<COND (<0? .DISP> <SEARCH-OUTSTANDING-LABELS .PTR>)
	      (ELSE
	       <SET LREF <NTH ,LABEL-TABLE .DISP>>
	       <MAPF <>
		     <FCN (XREF)
			  <COND (<==? <XREF-INFO-POINT .XREF> .PTR>
				 <MAPLEAVE .XREF>)>>
		     <LABEL-REF-XREFS .LREF>>)>>

<DEFINE SEARCH-OUTSTANDING-LABELS (PTR) 
   #DECL ((PTR) FIX)
   <PROG LVL ()
	 <MAPF <>
	       <FCN (LREF)
		    <MAPF <>
			  <FCN (XREF)
			       <COND (<==? <XREF-INFO-POINT .XREF> .PTR>
				      <RETURN .XREF .LVL>)>>
			  <LABEL-REF-XREFS .LREF>>>
	       ,OUTST-LABEL-TABLE>>>

<DEFINE PRINT-HEX-NUM (X) 
	#DECL ((X) FIX)
	<PRINHC </ .X 4096>>
	<SET X <MOD .X 4096>>
	<PRINHC </ .X 256>>
	<SET X <MOD .X 256>>
	<PRINHC </ .X 16>>
	<SET X <MOD .X 16>>
	<PRINHC .X>>

<DEFINE PRINHC (X) 
	#DECL ((X) FIX)
	<PRINC <NTH "0123456789ABCDEF"
		    <+ .X 1>>>>

<DEFINE PRINT-HEX-CODE ("OPTIONAL" (OUTCHAN .OUTCHAN) (PTR 1)
				   (MAXPTR ,FBYTE-OFFSET))
	#DECL ((OUTCHAN) <SPECIAL CHANNEL> (PTR MAXPTR) FIX)
	<PRINC !\|>
	<REPEAT (WD)
		<SET WD <NTH-FCODE .PTR>>
		<REPEAT (VAL (BCNT 4))
			<SET VAL <GET-FIELD .WD <BITS 4 .BCNT>>>
			<COND (<L? .VAL 10>
			       <PRINC <ASCII <+ .VAL <ASCII !\0>>>>)
			      (ELSE
			       <PRINC <ASCII <+ <ASCII !\A> <- .VAL 10>>>>)>
			<COND (<L? <SET BCNT <- .BCNT 4>> 0> <RETURN>)>>
		<COND (<G? <SET PTR <+ .PTR 1>> .MAXPTR> <RETURN>)>>
	<PRINC !\|>>

<DEFINE PRINT-LABEL-TABLE ("AUX" (OUTCHAN .OUTCHAN)) 
	<MAPF <>
	      <FCN (LREF)
		   <PRIN1 .LREF>
		   <INDENT-TO 40>
		   <PRIN1 <LABEL-REF-CODE-PTR .LREF>>
		   <PRINC "	">
		   <PRIN1 <LABEL-REF-REL-ADDR .LREF>>
		   <CRLF>>
	      ,LABEL-TABLE>>

<DEFINE IPRINT-HEX-NUM (NUM "AUX" TOT REM) 
	#DECL ((NUM VALUE REM) FIX)
	<COND (<L? .NUM 0> <PRINC "-"> <IPRINT-HEX-NUM <- .NUM>>)
	      (<L? .NUM 16> <PRINHC .NUM> .NUM)
	      (ELSE
	       <SET TOT <IPRINT-HEX-NUM </ .NUM 16>>>
	       <SET TOT <* .TOT 16>>
	       <SET REM <- .NUM .TOT>>
	       <PRINHC .REM>
	       <+ .TOT .REM>)>>

<DEFINE PRINT-STACK-REF (DISP
			 "AUX" (VARLIST <SM-VARLIST ,TOP-MODEL>) OFF
			       (OUTCHAN .OUTCHAN))
	#DECL ((DISP) FIX)
	<COND (<G? <SET OFF <+ </ .DISP 8> 1>> <LENGTH .VARLIST>> <>)
	      (ELSE
	       <PRIN1 <VARTBL-NAME <NTH .VARLIST .OFF>>>
	       <COND (<NOT <0? <MOD .DISP 8>>>
		      <PRINC "+">
		      <PRIN1 <MOD .DISP 8>>)>
	       <PRINC "   [">
	       <IPRINT-HEX-NUM .DISP>
	       <PRINC "] ">)>>

<DEFINE PRINT-FINAL-INST ("OPTIONAL" (OUTCHAN .OUTCHAN) (BYTEOFF 0) (PTR 1)
				     (MAXPTR ,FBYTE-OFFSET))
   #DECL ((CL) LIST (CV) CODEVEC (MAXPTR) FIX (BYTEOFF PTR) FIX
	  (OUTCHAN) <SPECIAL CHANNEL>)
   <REPEAT (EAFIELD INSCODE EADISP INSPTR INST (OPSZ 0) AFLG INSBITS SZ LREF
	    (IN-CASE? <>) INSNAME OP-INF NUM-OPS R-OR-L CB ST-CASE)
     #DECL ((OP-INF) <UVECTOR [3 FIX]> (INSCODE NUM-OPS R-OR-L) FIX
	    (IN-CASE?) <OR FALSE FIX>)
     <SET AFLG T>
     <AND <SET LREF <FIND-LABEL-AT-BA <- .PTR 1>>>
	  <PRIN1 <LABEL-REF-NAME .LREF>>
	  <INDENT-TO 50>
	  <PRINC !\[>
	  <PRINT-HEX-NUM <- .PTR 1>>
	  <PRINC !\]>
	  <CRLF>>
     <SET INSCODE <NTH-FCODE .PTR>>
     <SET PTR <+ .PTR 1>>
     <SET OP-INF <GET-INST-INFO .INSCODE>>
     <SET NUM-OPS <CHTYPE <LSH <2 .OP-INF> <- ,INIT-SHIFT>> FIX>>
     <TAB>
     <COND (<NOT .IN-CASE?> <PRINT-SQUOZE <1 .OP-INF>>)>
     <COND
	(.IN-CASE?
	 <SET CB <CHTYPE <ORB .INSCODE <LSH <NTH-FCODE .PTR> 8>> FIX>>
	 <SET CB <EXTEND .CB>>
	 <SET PTR <+ .PTR 1>>
	 <FBRANCH-PRINT .ST-CASE .CB>
	 <COND (<L? <SET IN-CASE? <- .IN-CASE? 1>> 0> <SET IN-CASE? <>>)>)
	(<N==? .NUM-OPS 0>
	 <COND (<MEMQ .INSCODE ,CASE-INS> <SET IN-CASE? 0>)>
	 <TAB>
	 <REPEAT ((FNUM 1) R-OR-L ADR SIZ (INDX <>) STR EAT EAC)
	   #DECL ((FNUM R-OR-L ADR SIZ EAT EAC) FIX)
	   <COND (.INDX
		  <PRINC "[">
		  <PRIN-REG-NAME .INDX>
		  <PRINC "]">
		  <SET INDX <>>)>
	   <COND (<L? <SET NUM-OPS <- .NUM-OPS 1>> 0> <RETURN>)>
	   <SET ADR <NTH-FCODE .PTR>>
	   <SET PTR <+ .PTR 1>>
	   <SET EAC <CHTYPE <ANDB .ADR 240> FIX>>
	   <SET R-OR-L <CHTYPE <ANDB .ADR 15> FIX>>
	   <SET SIZ
		<CHTYPE <ANDB <SET EAT <GET-OP-INFO .FNUM .OP-INF>> 7> FIX>>
	   <SET FNUM <+ .FNUM 1>>
	   <COND
	    (<OR <AND <==? .EAT ,OP-BB> <SET ADR <EXTEND-BYTE .ADR>>> 
		 <AND <==? .EAT ,OP-BW>
		      <SET ADR <CHTYPE <ORB .ADR
					    <LSH <NTH-FCODE .PTR> 8>> FIX>>
		      <SET ADR <EXTEND .ADR>>
		      <SET PTR <+ .PTR 1>>>>
	     <FBRANCH-PRINT .PTR .ADR>)
	    (<L? .EAC ,AM-INX>
	     <PRINC "S^#">
	     <PRIN1 <SET ADR <CHTYPE <ANDB .ADR 63> FIX>>>
	     <COND (.IN-CASE?
		    <COND (<0? .NUM-OPS> <SET IN-CASE? .ADR>)
			  (<1? .NUM-OPS> <SET CB .ADR>)>)>)
	    (<==? .EAC ,AM-INX>
	     <SET NUM-OPS <+ .NUM-OPS 1>>
	     <SET INDX .R-OR-L>)
	    (<==? .EAC ,AM-REG> <PRIN-REG-NAME .R-OR-L>)
	    (<AND <==? .EAC ,AM-REGD>
		  <OR <AND <==? .R-OR-L ,NAC-F> <PRINT-STACK-REF 0>>
		      <AND <==? .R-OR-L ,NAC-M> <PROG ()
						      <PRINT-MREF 0>
						      1>>>>)
	    (<OR <==? .EAC ,AM-REGD> <AND <==? .EAC ,AM-ADEC> <PRINC "-">>>
	     <PRINC "(">
	     <PRIN-REG-NAME .R-OR-L>
	     <PRINC ")">)
	    (<OR <==? .EAC ,AM-AINC> <AND <==? .EAC ,AM-AINCD> <PRINC "@">>>
	     <COND
	      (<==? .R-OR-L ,NAC-PC>
	       <COND (<==? .EAC ,AM-AINCD> <SET SIZ 4>)
		     (<OR <==? .SIZ ,SZ-L> <==? .SIZ ,SZ-F>> <SET SIZ 4>)
		     (<==? .SIZ ,SZ-W> <SET SIZ 2>)
		     (ELSE <SET SIZ 1>)>
	       <REPEAT ((IM 0) (CNT -8) LB INAME IDISP
			(NM
			 <COND (<==? .SIZ 1> -256)
			       (<==? .SIZ 2> -65536)
			       (ELSE <IFSYS ("TOPS20"
					     <CHTYPE *740000000000* FIX>)
					    ("VAX" 0)>)>))
		       <COND (<L? <SET SIZ <- .SIZ 1>> 0>
			      <COND (<G? <CHTYPE .LB FIX> 127>
				     <SET IM <CHTYPE <ORB .IM .NM> FIX>>)>
			      <COND (<AND <MEMQ .INSCODE ,MIM-CALLS>
					  <L=? <SET IDISP <+ </ .IM 4> 1>>
					       ,RTE-DISPATCH-TABLE-SIZE>
					  <SET INAME
					       <NTH ,RTE-DISP-TABLE .IDISP>>>
				     <PRINC .INAME>)
				    (ELSE
				     <PRINC "#">
				     <PRIN1 .IM>)>
			      <COND (.IN-CASE?
				     <COND (<L=? .NUM-OPS 0>
					    <SET IN-CASE? .IM>)
					   (<1? .NUM-OPS> <SET CB .IM>)>)>
			      <RETURN>)>
		       <SET CNT <+ .CNT 8>>
		       <SET IM
			    <CHTYPE <ORB .IM
					 <LSH <SET LB <NTH-FCODE .PTR>> .CNT>>
				    FIX>>
		       <SET PTR <+ .PTR 1>>>)
	      (ELSE <PRINC "("> <PRIN-REG-NAME .R-OR-L> <PRINC ")+">)>)
	    (ELSE
	     <SET STR
		  <COND (<==? .EAC ,AM-BDD> <SET SIZ 1> <PRINC "@"> "B^")
			(<==? .EAC ,AM-BD> <SET SIZ 1> "B^")
			(<==? .EAC ,AM-WDD> <SET SIZ 2> <PRINC "@"> "W^")
			(<==? .EAC ,AM-WD> <SET SIZ 2> "W^")
			(<==? .EAC ,AM-LDD> <SET SIZ 4> <PRINC "@"> "L^")
			(<==? .EAC ,AM-LD> <SET SIZ 4> "L^")>>
	     <REPEAT ((IM 0) (CNT -8) LB
		      (NM
		       <COND (<==? .SIZ 1> -256)
			     (<==? .SIZ 2> -65536)
			     (ELSE <IFSYS ("TOPS20"
					   <CHTYPE #WORD *740000000000* FIX>)
					  ("VAX" 0)>)>))
		     <COND (<L? <SET SIZ <- .SIZ 1>> 0>
			    <COND (<G? <CHTYPE .LB FIX> 127>
				   <SET IM <CHTYPE <ORB .IM .NM> FIX>>)>
			    <COND (<AND <==? .R-OR-L ,NAC-F>
					<PRINT-STACK-REF .IM>>)
				  (<==? .R-OR-L ,NAC-M> <PRINT-MREF .IM>)
				  (ELSE
				   <PRINC .STR>
				   <PRIN1 .IM>
				   <COND (.IN-CASE?
					  <COND (<L=? .NUM-OPS 0>
						 <SET IN-CASE? .IM>)
						(<1? .NUM-OPS> <SET CB .IM>)>)>
				   <PRINC "(">
				   <PRIN-REG-NAME .R-OR-L>
				   <PRINC ")">)>
			    <RETURN>)>
		     <SET CNT <+ .CNT 8>>
		     <SET IM
			  <CHTYPE <ORB .IM
				       <LSH <SET LB <NTH-FCODE .PTR>> .CNT>>
				  FIX>>
		     <SET PTR <+ .PTR 1>>>)>
	   <COND (<AND <NOT .INDX> <N==? .NUM-OPS 0>> <PRINC ",">)>>
	 <COND (.IN-CASE? <SET ST-CASE .PTR>)>)>
     <CRLF>
     <COND (<G=? .PTR .MAXPTR> <RETURN>)>>>

<DEFINE FBRANCH-PRINT (PTR OFFS "AUX" OFFSET LREF) 
	#DECL ((PTR OFFS) FIX)
	<SET OFFSET <+ .PTR .OFFS -1>>
	<COND (<SET LREF <FIND-LABEL-AT-BA .OFFSET>>
	       <PRIN1 <LABEL-REF-NAME .LREF>>)
	      (ELSE
	       <PRINC ".">
	       <COND (<G? .OFFS 0> <PRINC "+">) (ELSE <PRINC "-">)>
	       <PRIN1 <ABS .OFFS>>)>>

<DEFINE FIND-LABEL-AT-BA (BYTEOFF) 
	#DECL ((NUM) FIX)
	<REPEAT ((TAB ,LABEL-TABLE))
		<COND (<EMPTY? .TAB> <RETURN <>>)>
		<COND (<==? .BYTEOFF <LABEL-REF-REL-ADDR <1 .TAB>>>
		       <RETURN <1 .TAB>>)>
		<SET TAB <REST .TAB>>>>
