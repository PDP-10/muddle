<COND (<NOT <GASSIGNED? WIDTH-MUNG>>
       <FLOAD "MIMOC20DEFS.MUD">
       <FLOAD "MSGLUE-PM.MUD">)>

<DEFINE GLUE-FIXUP ()
	<MAPF <>
	      <FUNCTION (FROB "AUX" (LBL <5 .FROB>))
		   #DECL ((FROB) <LIST ATOM LIST FIX LIST LIST>
			  (LBL) LIST)
		   <FIXUP-ONE-GLUE <4 .FROB> .LBL>
		   <FIXUP-CONSTANTS <4 .FROB>>>
	      ,GLUE-LIST>>

<DEFINE FIXUP-ONE-GLUE (CODE LBL "AUX" (N 0)) 
   #DECL ((CODE LBL) LIST)
   <MAPR <>
    <FUNCTION (LST "AUX" (INS <1 .LST>) ITM CONST LB FC) 
       #DECL ((LST) LIST (CONST) CONSTANT (FC) CONSTANT-BUCKET
	      (INS) <OR ATOM INST CONSTANT CONST-W-LOCAL> (ITM) ANY)
       <COND (<NOT <TYPE? .INS ATOM>> <SET N <+ .N 1>>)>
       <COND
	(<TYPE? .INS INST>
	 <COND
	  (<TYPE? <SET ITM <1 .INS>> GFRM SGFRM SBFRM>
	   <COND (<==? <SET ITM <CHTYPE .ITM ATOM>> COMPERR>
		  <SET CONST <CHTYPE <+ ,SETZ 106> CONSTANT>>)
	         (<OR <==? .ITM UNWCONT> <==? .ITM IOERR>>
		  <SET CONST <CHTYPE <+ ,SETZ-IND <OPCODE .ITM>> CONSTANT>>)
	         (<OR <NOT <SET LB <OR <FIND-LABEL .ITM>
				       <LONG-FIND-LABEL .ITM .LBL>>>>
		      <NOT <SET LB <LAB-IND .LB>>>>
		  <MIMOCERR BAD-FRM-LABEL!-ERRORS .ITM>)
	         (ELSE
		  <SET CONST
		       <CHTYPE <+ <CHTYPE .LB FIX>
				  <COND (<TYPE? <1 .INS> GFRM> ,SETZ-R)
				        (<TYPE? <1 .INS> SBFRM> ,SETZQ-R)
					(ELSE ,SETZX-R)>>
			        CONSTANT>>)>
	   <SET FC <1 ,FREE-CONSTS>>
	   <CB-VAL .FC .CONST>
	   <SETG FREE-CONSTS <REST ,FREE-CONSTS>>
	   <SET ITM <CHTYPE [.FC] REF>>
	   <PUT .LST 1 <COND (<TYPE? <1 .INS> SBFRM> <CHTYPE [MOVE O* .ITM] INST>)
			     (ELSE <CHTYPE [PUSH TP* .ITM] INST>)>>)
	  (<TYPE? .ITM GCAL>
	   <COND (,MAX-SPACE
		  <PUT .LST 1 <CHTYPE [JRST 0 '(R*)] INST>>
		  <SETG GCALS ((.N <CHTYPE .ITM ATOM> <3 .INS>) !,GCALS)>)
	         (ELSE
		  <PUT .LST 1
		        <CHTYPE [JRST <GFIND <CHTYPE .ITM ATOM> <3 .INS>> '(R*)]
			        INST>>)>)>)>>
    .CODE>>

<DEFINE FIND-CALL (ATM LIST)
  #DECL ((ATM) ATOM (LIST) <LIST [REST ATOM]>)
  <REPEAT ()
    <COND (<EMPTY? .LIST> <RETURN <>>)>
    <COND (<SAME-NAME? .ATM <1 .LIST>> <RETURN .LIST>)>
    <SET LIST <REST .LIST>>>>

<DEFINE FIND-OPT (ATM LIST)
  #DECL ((ATM) ATOM (LIST) <LIST [REST ATOM <PRIMTYPE LIST>]>)
  <REPEAT ()
    <COND (<EMPTY? .LIST> <RETURN <>>)>
    <COND (<SAME-NAME? .ATM <1 .LIST>> <RETURN <REST .LIST>>)>
    <SET LIST <REST .LIST 2>>>>

<DEFINE SAME-NAME? (X Y "AUX" S1 S2)
  #DECL ((X Y) ATOM (S1 S2) STRING)
  <COND (<NOT ,INT-MODE>
	 <==? .X .Y>)
	(T
	 <SET S1 <SPNAME .X>>
	 <SET S2 <SPNAME .Y>>
	 <OR <==? .X .Y>
	     <AND <G? <LENGTH .S1> 2>
		  <==? <1 .S1> !\T>
		  <==? <2 .S1> !\$>
		  <=? <REST .S1 2> .S2>>
	     <AND <G? <LENGTH .S2> 2>
		  <==? <1 .S2> !\T>
		  <==? <2 .S2> !\$>
		  <=? <REST .S2 2> .S1>>>)>>

<DEFINE GFIND (NAM LBL?)
	#DECL ((NAM) ATOM (LBL?) <OR ATOM FALSE>)
	<COND (<MAPF <>
		     <FUNCTION (L "AUX" X)
			  #DECL ((L) <LIST ATOM LIST FIX>)
			  <COND (<SAME-NAME? <1 .L> .NAM>
				 <COND (.LBL?
					<COND (<AND <SET X
							 <FIND-LABEL .LBL?>>
						    <SET X <LAB-IND .X>>>
					       <MAPLEAVE .X>)
					      (ELSE
					       <MIMOCERR BAD-OPT-LABEL!-ERRORS
							 .LBL?>)>)
				       (ELSE <MAPLEAVE <3 .L>>)>)>>
		     ,GLUE-LIST>)
	      (ELSE
	       <MIMOCERR CANT-FIND-GL-ENTRY!-ERRORS .NAM>)>>

<DEFINE CALL-ANA (L "AUX" (ANA-L ()))
	#DECL ((L ANA-L) LIST)
	<MAPF <>
	      <FUNCTION (ITM "AUX" ONE LBL TEM IT X)
		   #DECL ((ITM) <OR ATOM FORM> (ONE LBL) ATOM)
		   <COND (<AND <TYPE? .ITM FORM>
			       <NOT <EMPTY? .ITM>>>
			  <COND (<OR <==? <SET ONE <1 .ITM>> FRAME>
				     <==? .ONE SFRAME>>
				 <SET ANA-L (.ITM !.ANA-L)>)
				(<OR <==? .ONE CALL> <==? .ONE SCALL>>
				 <COND (<AND <TYPE? <SET IT <2 .ITM>> FORM>
					     <==? <LENGTH .IT> 2>
					     <==? <1 .IT> QUOTE>
					     <PROG () <SET IT <2 .IT>> T>
					     <OR <AND ,GLUE-MODE
						      <FIND-CALL .IT
								 ,PRE-NAMES>>
						 <SUBRIFY? .IT>>
					     <NOT <MEMQ .IT
							'[GVAL GASSIGNED?]>>>
					<COND (<NOT <AND <TYPE? <SET TEM
								    <1 .ANA-L>>
							       FORM>
							 <G? <LENGTH .TEM> 1>
							 <TYPE? <SET X
								     <2 .TEM>>
							       FORM>
							 <==? <LENGTH .X> 2>
							 <==? <1 .X> QUOTE>
							 <==? .IT <2 .X>>>>
					       <MIMOCERR
						BAD-FRAME-CALL-MATCH!-ERRORS
						.ITM .TEM>)
					      (ELSE
					       <PUTREST
						 .TEM
						 (<SET LBL
						       <GENLBL "?FRM">>
						  .IT)>
					       <PUTREST <REST .ITM
							      <- <LENGTH .ITM>
								 1>>
							(.LBL)>)>)>
				 <SET ANA-L <REST .ANA-L>>)
				(<==? .ONE ACALL>
				 <SET ANA-L <REST .ANA-L>>)>)>>
	      .L>>

<DEFINE MIMOC (L "OPT" (WINNER <>)
		 "AUX" NAME (OBLIST .OBLIST) (OUTCHAN .OUTCHAN) PO
		 "NAME" MACT) 
   #DECL ((L) <LIST [REST <OR ATOM FORM>]> (NAME) ATOM
	  (MACT) <SPECIAL ANY> (OUTCHAN OBLIST) <SPECIAL ANY>)
   <COND (,NO-AC-FUNNYNESS <SETG PASS1 <>>) (ELSE <SETG PASS1 T>)>
   <SETG NEXT-LOOP <SETG LAST-UNCON <>>>
   <SETG AC-STAMP <SETG VISIT-COUNT 0>>
   <SETG LABELS ()>
   <PRE-HACK .L>
   <PROG ((LSEQ ,LBLSEQ) (OLD-LOCS ()))
     <FLUSH-ACS>
     <SETG STACK-DEPTH 0>  
     <SETG CHANGED <>>
     <COND (.WINNER <SETG WINNING-VICTIM 2>)
	   (ELSE <SETG WINNING-VICTIM <>>)>
     <MAPR <>
      <FUNCTION (MIML "AUX" (ITM <1 .MIML>) OP ITML M LB DCLIST (OPT? <>)) 
	 #DECL ((MIML) <SPECIAL LIST> (ITM) <OR ATOM FORM>
		(M) <OR FALSE <LIST ATOM ATOM>> (DCLIST) LIST)
	 <COND (,ACA-AC
		<AC-ITEM ,ACA-AC ,ACA-ITEM>
		<COND (,ACA-BOTH <AC-ITEM ,ACA-BOTH ,ACA-ITEM>)>
		<SETG ACA-AC <>>)>
	 <SETG FIRST-AC T>
	 <COND
	  (<TYPE? .ITM ATOM>
	   <COND
	    (<SET M <MEMQ .ITM ,ICALL-TAGS>>
	     <PUSHJ-VAL <3 .M>>
	     <SETG LAST-UNCON <>>
	     <LABEL <2 .M> <> .MIML>
	     <COND (<0? <SETG ICALL-FLAG <- ,ICALL-FLAG 1>>>
		    <SETG ICALL-FLAG <>>)>
	     <COND (<NOT ,PASS1>
		    <FIXUP-LOCALS <REST <CHTYPE <1 ,ALL-ICALL-TEMPS> LIST>>>)>
	     <PUTREST <1 ,ALL-ICALL-TEMPS> ()>
	     <SETG ALL-ICALL-TEMPS <REST ,ALL-ICALL-TEMPS>>
	     <SETG TEMP-CC <1 ,ALL-TEMP-CC>>
	     <SETG ALL-TEMP-CC <REST ,ALL-TEMP-CC>>)>
	   <COND (,PASS1 <SET LB <LABEL .ITM <> .MIML>> <SAVE-LABEL-STATE .LB>)
		 (,NO-AC-FUNNYNESS <SAVE-ACS> <SET LB <LABEL .ITM <> .MIML>>)
		 (ELSE
		  <SET LB <FIND-LABEL .ITM>>
		  <ESTABLISH-LABEL-STATE .LB>
		  <SET LB <LABEL .ITM <> .MIML>>)>
	   <SETG NEXT-LOOP <>>
	   <SETG LAST-UNCON <>>)
	  (T
	   <SET ITML <LENGTH .ITM>>
	   <COND
	    (<0? .ITML> <MIMOCERR BAD-SYNTAX!-ERRORS .ITM>)
	    (<NOT <TYPE? <SET OP <1 .ITM>> ATOM>>
	     <MIMOCERR BAD-SYNTAX!-ERRORS .ITM>)
	    (<MEMQ .OP '[FCN GFCN]>
	     <AND ,V1 <NOT ,PASS1> <PRINT .ITM>>
	     <FLUSH-ACS>
	     <COND (<L? .ITML 3> <MIMOCERR BAD-SYNTAX!-ERRORS .ITM>)
		   (T
		    <SET DCLIST <REST <CHTYPE <3 .ITM> LIST> 2>>
		    <SETG LOCALS
			  (T
			   !<MAPF ,LIST
				  <FUNCTION (ATM "AUX" DC) 
					  <PROG ()
						<COND (<TYPE? <SET DC <1 .DCLIST>>
							      STRING>
						       <COND (<=? .DC "OPTIONAL">
							      <SET OPT? T>)
							     (<==? .DC "TUPLE">
							      <SET OPT? <>>)>
						       <SET DCLIST <REST .DCLIST>>
						       <AGAIN>)>>
					  <COND (,WINNING-VICTIM
						 <SETG WINNING-VICTIM
						       <+ ,WINNING-VICTIM 2>>)>
					  <SET DCLIST <REST .DCLIST>>
					  <CHTYPE [.ATM
						   <COND (.OPT? OARG) (ELSE ARG)>
						   <CHTYPE
						    <SETG LBLSEQ <+ ,LBLSEQ 1>>
						    LOCAL-NAME>
						   <DECL-HACK .DC>
						   <>
						   <>]
						  LOCAL>>
				  <REST .ITM 3>>)>
		    <SETG ALL-TEMP-CC ()>
		    <SETG TYPED-LOCALS ()>
		    <SETG NRARGS <- <LENGTH .ITM> 3>>
		    <SET NAME <2 .ITM>>
		    <SETG CODE (T)>
		    <SETG CC ,CODE>
		    <COND (<NOT ,GLUE-MODE>
			   <SETG CONSTANT-VECTOR ()>
			   <SETG FREE-CONSTS ()>
			   <MAPR <>
				 <FUNCTION (B:<VECTOR LIST>)
				      <PUT .B 1 ()>> ,CONSTANT-TABLE>
			   <SETG MVECTOR (T .NAME <3 .ITM>)>
			   <MAPR <>
				 <FUNCTION (B:<VECTOR LIST>)
				      <PUT .B 1 ()>> ,MV-TABLE>
			   <SETG MV-COUNT 0>
			   <SETG FINAL-LOCALS ()>
			   <SETG MV <REST ,MVECTOR 2>>)
			  (T
			   <SETG GLUE-NAME .NAME>
			   <SETG GLUE-DECL <3 .ITM>>
			   <SETG GCALS <SETG GREFS ()>>)>
		    <SETG ICALL-FLAG <>>
		    <SETG ICALL-TAGS ()>
		    <SETG LOOPTAGS ()>
		    <SETG LOCATIONS ()>
		    <SETG OPT-LIST <>>)>)
	    (<==? .OP TEMP>
	     <AND ,V1 <NOT ,PASS1> <PRINT .ITM> <CRLF>>
	     <SET ITM <SORT-TEMPS .ITM>>
	     <TEMP-INIT <REST .ITM> <> .OLD-LOCS>
	     <COND (,WINNING-VICTIM
		    <SETG WINNING-VICTIM <+ ,WINNING-VICTIM
					    <* <LENGTH .ITM> 2> -2>>)>)
	    (<==? .OP OPT-DISPATCH> <OPT-INIT <REST .ITM>>)
	    (<==? .OP MAKTUP>
	     <AND ,V1 <NOT ,PASS1> <PRINT .ITM> <CRLF>>
	     <SET ITM <SORT-TEMPS .ITM>>
	     <TEMP-INIT <REST .ITM> T .OLD-LOCS>)
	    (<G? ,NEXT-FLUSH 0>
	     <COND (<AND ,V1 <NOT ,PASS1>> <PRINT .ITM>)>
	     <COND (<N==? .OP DEAD> <SETG NEXT-FLUSH <- ,NEXT-FLUSH 1>>)>)
	    (T
	     <COND (<N==? .OP DEAD> <SETG NEXT-LOOP <>> <SETG LAST-UNCON <>>)>
	     <OC .ITM .OBLIST>
	     <AC-TIME <GET-AC T*> <CHTYPE <MIN> FIX>>)>)>>
      .L>
     <COND (,PASS1
	    <SETG LBLSEQ .LSEQ>
	    <SET OLD-LOCS ,LOCALS>
	    <MERGE-LABEL-STATES>
	    <COND (<NOT ,CHANGED> <SETG PASS1 <>>)
		  (<GASSIGNED? LOOP-DEBUG>
		   <COND (<==? ,LOOP-DEBUG 1>
			  <PRINC "Changed: ">
			  <PRIN1 ,CHANGED>
			  <CRLF>)
			 (ELSE <ERROR ,CHANGED>)>)>
	    <AGAIN>)>>
   <FIXUP-LOCALS <REST ,LOCALS>>
   <COND (,PEEP-ENABLED <SETG CODE <PPOLE ,CODE !<REST ,CODE>>>)>
   <FIXUP-REFS>
   <COND (,OPT-LIST
	  <COND (<AND ,GLUE-MODE <SET PO <FIND-OPT .NAME ,PRE-OPTS>> <1 .PO>>
		 <MAPF <> <FUNCTION (A1 A2) #DECL ((A1 A2) ATOM)
			       <SETG .A1 ,.A2>>
		       <REST <1 .PO> 3> <REST ,OPT-LIST 2>>)>
	  <MAPR <>
		<FUNCTION (C L "AUX" (X <1 .C>) LI)
			#DECL ((C L) LIST (X) <OR INST ATOM>)
			<COND (<AND <TYPE? .X INST>
				    <==? <LENGTH .X> 2>
				    <==? <1 .X> DISPATCH>>
			       <PUT .C
				    1
				    <CHTYPE [SETZ
					     <SET LI <LAB-IND <FIND-LABEL <2 .X>>>>
					     '(R*)]
					    INST>>
			       <PUT .L 1 .LI>)
			      (T <MAPLEAVE T>)>>
		<REST ,CODE <+ ,OPT-OFFSET 2>> <REST ,OPT-LIST 2>>)>>

<DEFINE DECL-HACK (TYP)
	<PROG ((TY <>))
	      <COND (<TYPE? .TYP FORM SEGMENT>
		     <COND (<AND <==? <LENGTH .TYP> 2> <==? <1 .TYP> QUOTE>>
			    <SET TYP <TYPE <2 .TYP>>>)
			   (<==? <1 .TYP> OR>
			    <SET TYP <DECL-HACK <2 <SET TY .TYP>>>>
			    <MAPF <>
				  <FUNCTION (Z) 
				       <COND (<N==? .TYP <DECL-HACK .Z>>
					      <MAPLEAVE <SET TYP <>>>)>>
				  <REST .TY 2>>)
			   (ELSE <SET TYP <1 <SET TY .TYP>>>)>)>
	      <COND (<TYPE? .TYP ATOM>
		     <COND (<OR <AND <VALID-TYPE? .TYP>
				     <MEMQ <TYPEPRIM .TYP> '[WORD FIX LIST]>>
				<MEMQ .TYP ,TYPE-LENGTHS>> .TYP)
			   (<AND <SET TYP <GETPROP .TYP DECL>>
				 <N=? .TY .TYP>>
			    <AGAIN>)>)>>>


<DEFINE SORT-TEMPS (TEMPL "AUX" (ALIST '())(NON-ALIST '()))
  #DECL ((TEMPL) <PRIMTYPE LIST> (ALIST NON-ALIST) LIST)
  <MAPR <>
	<FUNCTION (L "AUX" (TEMP <1 .L>))
	  <COND (<==? .TEMP =>
		 <COND (<EMPTY? .ALIST> <SET ALIST .L>)
		       (ELSE
			<PUTREST <REST .ALIST <- <LENGTH .ALIST> 1>>
				 .L>)>
		 <MAPLEAVE>)
		(<TYPE? .TEMP ATOM>
		 <SET ALIST (.TEMP !.ALIST)>)
		(ELSE <SET NON-ALIST (.TEMP !.NON-ALIST)>)>>
	<REST .TEMPL>>
  <COND (<NOT <EMPTY? .NON-ALIST>>
	 <PUTREST <REST .NON-ALIST <- <LENGTH .NON-ALIST> 1>>
		  .ALIST>)
	(ELSE <SET NON-ALIST .ALIST>)>
  <CHTYPE (<1 .TEMPL> !.NON-ALIST) FORM>>

<DEFINE OPT-INIT (OPT "AUX" (OFF 1) MAX MAGIC)
	#DECL ((OPT) <LIST FIX <OR FIX FALSE> [REST ATOM]> (OFF MAGIC) FIX
	       (MAX) <OR FALSE FIX>)
	<COND (<SET MAX <2 .OPT>>
	       <SET OFF <+ .OFF 3>>
	       <OCEMIT CAILE O2* .MAX>
	       <OCEMIT JRST <XJUMP <NTH .OPT <LENGTH .OPT>>>>
	       <OCEMIT MOVEI O1*
		       <+ <- 5 <1 .OPT>> <COND (,GLUE-MODE ,GLUE-PC) (T 0)>>
		       '(R*)>
	       <OCEMIT ADD O1* O2*>
	       <OCEMIT JRST @ '(O1*)>)
	      (ELSE
	       <OCEMIT ADDI
		       O2*
		       <+ <- 2 <1 .OPT>> <COND (,GLUE-MODE ,GLUE-PC) (T 0)>>
		       '(R*)>
	       <OCEMIT JRST @ '(O2*)>)>
	<MAPF <> <FUNCTION (X) <OCEMIT DISPATCH .X>> <REST <SETG OPT-LIST .OPT> 2>>
	<SETG OPT-OFFSET .OFF>>

<DEFINE TEMP-INIT (LST
		   "OPTIONAL" (TUP <>) (OLD ())
		   "AUX" (STK TP*) (CNT 0) (TCC ,CC))
   #DECL ((LST) LIST (CNT) FIX (TUP) <OR FALSE ATOM>)
   <COND (.TUP
	  <OCEMIT MOVE O* O2*>
	  <OCEMIT MOVEI O1* ,NRARGS>
	  <OCEMIT MOVEI O2* <- <LENGTH .LST> 2>>
	  <PUSHJ MAKTUP <NTH .LST <LENGTH .LST>>>
	  <OCEMIT XMOVEI B1* <+ 1 <* ,NRARGS 2>> '(F*)>
	  <SET STK B1*>)>
   <COND (,ICALL-FLAG
	  <SETG ALL-TEMP-CC (,TEMP-CC !,ALL-TEMP-CC)>
	  <SETG ALL-ICALL-TEMPS
		(<REST ,ICALL-TEMPS <- <LENGTH ,ICALL-TEMPS> 1>>
		 !,ALL-ICALL-TEMPS)>)
	 (ELSE <SETG ALL-ICALL-TEMPS (<SETG ICALL-TEMPS (T)>)>)>
   <SETG TEMP-CC .TCC>
   <MAPF <>
	 <FUNCTION (TEMP "AUX" VAR TYP FROB (VAL #LOSE *000000000000*) LCL) 
		 #DECL ((TEMP)
			<OR ATOM
			    <ADECL ATOM ATOM>
			    <LIST <OR ATOM <ADECL ATOM ATOM>> ANY>>
			(VAR)
			ATOM
			(TYP)
			<OR ATOM FALSE>
			(FROB)
			<OR ADECL ATOM>
			(VAL)
			ANY
			(LCL)
			<OR FALSE LOCAL>)
		 <COND (<==? .TEMP => <MAPLEAVE T>)>
		 <COND (<TYPE? .TEMP ADECL>
			<SET VAR <1 .TEMP>>
			<SET TYP <2 .TEMP>>)
		       (<TYPE? .TEMP LIST>
			<COND (<TYPE? <SET FROB <1 .TEMP>> ADECL>
			       <SET VAR <1 .FROB>>
			       <SET TYP <2 .FROB>>)
			      (T <SET VAR .FROB>)>
			<SET VAL <2 .TEMP>>)
		       (T <SET VAR .TEMP>)>
		 <SET LCL <LMEMQ .VAR .OLD>>
		 <SET LCL
		      <CHTYPE [.VAR
			       <COND (.LCL <LUPD .LCL>)>
			       <CHTYPE <SETG LBLSEQ <+ ,LBLSEQ 1>> LOCAL-NAME>
			       <COND (<ASSIGNED? TYP> <SET TYP <DECL-HACK .TYP>>)
				     (ELSE <>)>
			       <>
			       <>]
			      LOCAL>>
		 <COND (<NOT <TYPE? .VAL LOSE>> <LUPD .LCL TEMP>)>
		 <COND (,ICALL-FLAG
			<PUTREST <REST ,ICALL-TEMPS
				       <- <LENGTH ,ICALL-TEMPS> 1>>
				 (.LCL)>)
		       (T
			<PUTREST <REST ,LOCALS <- <LENGTH ,LOCALS> 1>>
				 (.LCL)>)>
		 <COND (<AND <ASSIGNED? TYP> .TYP>
			<OCEMIT PUSH .STK !<TYPE-WORD .TYP>>
			<SETG TYPED-LOCALS (.LCL !,TYPED-LOCALS)>
			<AND <TYPE? .VAL LOSE> <SET VAL 0>>)
		       (<TYPE? .VAL LOSE>
			<OCEMIT PUSH .STK !<OBJ-VAL 0>>
			<SET VAL 0>)
		       (T <OCEMIT PUSH .STK !<OBJ-LOC .VAL 0>>)>
		 <OCEMIT PUSH .STK !<OBJ-VAL .VAL>>>
	 .LST>
   <COND (<==? .STK B1*> <AC-TIME <GET-AC B1*> 0>)>>

<DEFINE PRE-HACK (L "AUX" LR)
	#DECL ((L LR) LIST)
	<SETG THE-BIG-LABELS ()>
	<REPEAT (WIN (FIX-LABS <>) (FIRST T))
		#DECL ((FIRST WIN) <OR ATOM FALSE>)
		<SET WIN <>>
		<SET LR
		     <MAPR ,LIST
			   <FUNCTION (LL "AUX" (FRM <1 .LL>) M N I A LBL)
				#DECL ((FRM) <OR FORM ATOM> (M) <OR FALSE LIST>
				       (LBL) ATOM (N) <OR FALSE LIST> (I) FORM
				       (LL) LIST (A) ANY)
				<COND (<TYPE? .FRM ATOM>
				       <MAPRET>)>
				<COND (.FIRST <REMOVE-FUNNY-DEADS .FRM>)>
				<COND (<OR <==? <1 .FRM> OPT-DISPATCH>
					   <==? <1 .FRM> DISPATCH>>
				       <COND (.FIX-LABS
					      <MAPR <>
						    <FUNCTION (FP)
							 <PUT .FP 1
							      <FIX-LAB <1 .FP>>>>
						    <REST .FRM 3>>)>
				       <MAPRET !<REST .FRM 3>>)
				      (<OR <SET M <MEMQ + .FRM>>
					   <SET M <MEMQ - .FRM>>
					   <AND <==? <1 .FRM> NTHR>
						<TYPE?
						    <SET A <NTH .FRM
							        <LENGTH .FRM>>>
						    LIST>
						<==? <1 .A> BRANCH-FALSE>
						<SET M <REST .A>>>> 
				       <COND (<OR <==? <SET LBL <2 .M>> COMPERR>
						  <==? .LBL UNWCONT>
						  <==? .LBL IOERR>>
					      <MAPRET .LBL>)
					     (.FIX-LABS
					      <PUT .M 2 <FIX-LAB .LBL>>
					      <MAPRET .LBL>)
					     (<SET N <MEMQ .LBL .L>>)
					     (T <MIMOCERR BAD-LABEL!-ERRORS
						       .LBL>)>
				       <COND (<==? <1 <SET I <NEXTINS .N>>>
						   JUMP>
					      <PUT .M 2 <3 .I>>
					      <MAPRET <2 .M>>)
					     (<AND <==? <1 .FRM> JUMP>
						   <==? <1 .I> RETURN>>
					      <PUT .LL 1 .I>
					      <MAPRET>)
					     (T
					      <MAPRET .LBL>)>)
				      (<==? <1 .FRM> ICALL>
				       <COND (.FIX-LABS
					      <PUT .FRM 2 <FIX-LAB <2 .FRM>>>)>
				       <MAPRET <2 .FRM>>)
				      (T <MAPRET>)>>
			   .L>>
		<SET FIRST <>>
		<REPEAT ((L .L) (OL .L) ITM (NEXT-LOOP <>))
			#DECL ((L OL) LIST (ITM) ANY)
			<COND (<EMPTY? .L> <RETURN>)
			      (<TYPE? <SET ITM <1 .L>> ATOM>
			       <COND (.FIX-LABS
				      <PUT .L 1 <SET ITM <FIX-LAB .ITM>>>
				      <MAKE-LABEL .ITM <> .L .NEXT-LOOP>
				      <SET OL .L>)
				     (<NOT <MEMQ .ITM .LR>>
				      <PUTREST .OL <REST .L>>
				      <SET L .OL>
				      <SET WIN T>)
				     (ELSE <SET OL .L>)>)
			      (<AND .FIX-LABS
				    <TYPE? .ITM FORM>
				    <==? <1 .ITM> ACTIVATION>>
			       <SETG THE-BIG-LABELS (<SET ITM <GENLBL "ACT">>
						     !,THE-BIG-LABELS)>
			       <MAKE-LABEL .ITM  <> .L T>
			       <SET OL .L>)
			      (<AND <TYPE? .ITM FORM> <==? <1 .ITM> LOOP>>
			       <SET NEXT-LOOP T>
			       <SET L <REST <SET OL .L>>>
			       <AGAIN>)
			      (<AND <TYPE? .ITM FORM>
				    <==? <1 .ITM> JUMP>
				    <TYPE? <SET ITM <1 .OL>> FORM>
				    <==? <1 .ITM> JUMP>>
			       <PUTREST .OL <REST .L>>
			       <SET WIN T>)
			      (<AND <TYPE? <SET ITM <1 .L>> FORM>
				    <==? <1 .ITM> JUMP>
				    <G? <LENGTH .L> 1>
				    <==? <2 .L> <3 .ITM>>>
			       <PUTREST .OL <REST .L>>
			       <SET WIN T>)
			      (<AND <TYPE? .ITM FORM>
				    <==? <1 .ITM> JUMP>
				    <G? <LENGTH .L> 1>
				    <NOT <TYPE? <2 .L> ATOM>>>
			       <PUTREST .L <REST .L 2>>
			       <SET WIN T>)
			      (<AND <TYPE? .ITM FORM>
				    <OR <==? <1 .ITM> RETURN>
					<==? <1 .ITM> RTUPLE>
					<==? <1 .ITM> AGAIN>
					<==? <1 .ITM> RETRY>
					<==? <1 .ITM> MRETURN>>>
			       <REPEAT ((LL <REST .L>)) #DECL ((LL) LIST)
				       <COND (<OR <EMPTY? .LL>
						  <TYPE? <SET ITM <1 .LL>>
							 ATOM>>
					      <COND (<N==? <REST .L> .LL>
						     <SET WIN T>
						     <PUTREST .L .LL>)>
					      <RETURN>)>
				       <COND (<==? <1 .ITM> DEAD>
					      <COND (<N==? <REST .L> .LL>
						     <SET WIN T>
						     <PUTREST .L .LL>)>
					      <SET L .LL>)>
				       <SET LL <REST .LL>>>
			       <SET OL .L>)
			      (T <SET OL .L>)>
			<SET NEXT-LOOP <>>
			<SET L <REST .L>>>
		<COND (.FIX-LABS <RETURN>)
		      (<NOT .WIN> <SET FIX-LABS T>)>>>

<DEFINE REMOVE-FUNNY-DEADS (FRM:FORM "AUX" (N:FIX <LENGTH .FRM>))
	<REPEAT (L FOO)
		<COND (<AND <TYPE? <SET L <NTH .FRM .N>> LIST>
			    <NOT <EMPTY? .L>>
			    <OR <==? <SET FOO <1 .L>> DEAD-FALL>
				<==? .FOO DEAD-JUMP>>>
		       <PUTREST <REST .FRM <- .N 2>> <REST .FRM .N>>
		       <SET N <- .N 1>>)
		      (ELSE
		       <SET N <- .N 1>>)>
		<COND (<L=? .N 1> <RETURN>)>>>

<DEFINE FIX-LAB (X) <SET X <SPNAME .X>> <OR <LOOKUP .X ,LABEL-OBLIST>
					    <INSERT .X ,LABEL-OBLIST>>>


<DEFINE FIXUP-REFS ("AUX" (C <REST ,CODE>) (PC 0) FOO M TG
			  (OFF <COND (,GLUE-MODE ,GLUE-PC) (T 0)>) R
			  (WV ,WINNING-VICTIM))
   #DECL ((LABELS) LIST (PC OFF) FIX (C) LIST (FOO R) ANY
	  (M) <OR FALSE LAB LIST>)
   <MAPF <>
	 <FUNCTION (C "AUX" R M X) 
		 #DECL ((M) <OR FALSE LAB>)
		 <COND (<TYPE? .C INST>
			<COND (<TYPE? <SET R <NTH .C <LENGTH .C>>> REF>
			       <COND (<AND <TYPE? <SET X <1 .R>> ATOM>
					   <SET M <FIND-LABEL .X>>>
				      <PUT .M ,LAB-IND 0>)>)
			      (<TYPE? .R FORM GVAL>
			       <PUT .C <LENGTH .C> <EVAL .R>>)>)>>
	 .C>
   <REPEAT ()
	   <COND (<EMPTY? .C> <RETURN <SETG CODE-LENGTH .PC>>)
		 (<AND <TYPE? <SET FOO <1 .C>> ATOM> <SET M <FIND-LABEL .FOO>>>
		  <PUT .M ,LAB-IND <+ .PC .OFF>>)
		 (ELSE <SET PC <+ .PC 1>>)>
	   <SET C <REST .C>>>
   <MAPR <>
    <FUNCTION (COD "AUX" (C <1 .COD>) R NPC (FLG <>)) 
       #DECL ((COD) LIST (C R) ANY (NPC) FIX (FLG) <OR ATOM FALSE>)
       <COND (<AND <TYPE? .C INST>
		   <OR <TYPE? <SET R <2 .C>> REF>
		       <AND <G? <LENGTH .C > 2>
			    <TYPE? <SET R <3 .C>> REF>
			    <SET FLG T>>>>
	      <SET TG <1 <CHTYPE .R REF>>>
	      <SET M <>>
	      <COND (<OR <NOT <TYPE? .TG ATOM>>
			 <NOT <SET M <MEMQ .TG <REST ,CODE>>>>>)
		    (T <SET NPC <LAB-IND <FIND-LABEL <1 <CHTYPE .R REF>>>>>)>
	      <COND (<NOT .M>
		     <COND (<==? .TG COMPERR>
			    <COND (.FLG <PUT .C 3 106>) (T <PUT .C 2 106>)>)
			   (<OR <==? .TG UNWCONT> <==? .TG IOERR>>
			    <COND (.FLG
				   <PUT .COD
					1
					<CHTYPE [<1 .C> <2 .C> @ <OPCODE .TG>]
						INST>>)
				  (ELSE
				   <PUT .COD
					1
					<CHTYPE [JRST @ <OPCODE .TG>] INST>>)>)
			   (<NOT <TYPE? .TG CONSTANT-BUCKET>>
			    <MIMOCERR UNKNOWN-LABEL!-ERRORS
				      <1 <CHTYPE .R REF>>>)>)
		    (.FLG
		     <PUT .COD 1 <CHTYPE [<1 .C> <2 .C> .NPC '(R*)] INST>>)
		    (T <PUT .COD 1 <CHTYPE [JRST .NPC '(R*)] INST>>)>)>>
    <REST ,CODE>>>

<DEFINE WRITE-MSUBR (OC "OPTIONAL" (LOWERSTR <>) (F-OR-G <>)
		     "AUX" NUM (MVECTOR ,MVECTOR) (OUTCHAN .OC)
			   (OB ,OUTPUT-BUFFER))
	#DECL ((NAME) ATOM (DECL) <PRIMTYPE LIST> (MVECTOR) LIST
	       (NUM) FIX (OUTCHAN) <SPECIAL CHANNEL> (OB) STRING)
	<AND ,INT-MODE <PRINTTYPE ATOM ,ATOM-PRINT>>
	<COND (<NOT .LOWERSTR>
	       <SET LOWERSTR
		    <MAPF ,STRING
			  <FUNCTION (CHR "AUX" (ICHR <ASCII .CHR>))
				 #DECL ((CHR) CHARACTER (ICHR) FIX)
				 <COND (<AND <L=? .ICHR <ASCII !\Z>>
					     <G=? .ICHR <ASCII !\A>>>
					<ASCII <+ .ICHR 32>>)
				       (ELSE .CHR)>>
			    <SPNAME <2 .MVECTOR>>>>)>
	<WIDTH-MUNG .OC 100000000>
	<COND (,GLUE-MODE <SETG GLUE-LIST <LREVERSE ,GLUE-LIST>>)>
	<CRLF .OC>
	<COND (<NOT ,BOOT-MODE>
	       <PRINC "<SETG " .OC>
	       <COND (<NOT ,GLUE-MODE> <PRINC <ASCII 26> .OC>)>
	       <PRINC .LOWERSTR .OC>
	       <COND (<NOT ,BOOT-MODE>
		      <COND (,INT-MODE <PRINC "!-IMSUBR!- " .OC>)
			    (ELSE <PRINC "-IMSUBR " .OC>)>)>
	       <PRINC !\ >)>
	<PRINC "#IMSUBR [|" .OC>
	<COND (<AND ,GLUE-MODE <NOT ,MAX-SPACE>>
	       <SETG CODE
		     <MAPF ,LIST
			   <FUNCTION (L "AUX" C)
				#DECL ((L) <LIST ATOM LIST FIX <LIST ANY>>
				       (C) LIST)
				<SET C <REST <4 .L>>>
				<PUT .L 4 ()>
				<MAPRET !.C>>
			   ,GLUE-LIST>>
	       <SETG CODE (T !,CODE)>)>
	<COND (<NOT ,BOOT-MODE>
	       <PRINTBYTE <CHTYPE <LSH <SET NUM
					    <+ <COND (,GLUE-MODE ,GLUE-PC)
						     (T ,CODE-LENGTH)>
					       <LENGTH ,CONSTANT-VECTOR>>>
				       -16> FIX>
			  7>
	       <PRINTBYTE <CHTYPE <LSH .NUM -8> FIX> 7>
	       <PRINTBYTE .NUM 7>)>
	<COND (<NOT ,MAX-SPACE> <WRITE-CODE .OC .LOWERSTR <REST ,CODE> .OB>)
	      (ELSE
	       <CHANNEL-OP .OC WRITE-BUFFER ,OUTPUT-BUFFER
			   <- ,OUTPUT-LENGTH <LENGTH .OB>>>)>
	<COND (<NOT ,GLUE-MODE>
	       <COND (<==? .F-OR-G GFCN>
		      <PRIN1 ,CODE-LENGTH .OC>)
		     (ELSE
		      <PRIN1 <- ,CODE-LENGTH> .OC>)>
	       <CRLF .OC>
	       <COND (<NOT ,BOOT-MODE>
		      <PRINC "<SETG " .OC>
		      <COND (<NOT ,GLUE-MODE> <PRINC <ASCII 26> .OC>)>
		      <PRIN1 <2 .MVECTOR> .OC>
		      <PRINC !\  .OC>)>
	       <PRINC "#MSUBR [" .OC>
	       <PRINC .LOWERSTR .OC>
	       <COND (<NOT ,BOOT-MODE>
		      <COND (,INT-MODE <PRINC "!-IMSUBR!- " .OC>)
			    (ELSE <PRINC "-IMSUBR " .OC>)>)>
	       <PRINC " " .OC>
	       <PRIN1 <2 .MVECTOR> .OC>
	       <PRINC " " .OC>
	       <PRIN1 <3 .MVECTOR> .OC>
	       <PRINC " 0]" .OC>
	       <COND (<NOT ,BOOT-MODE> <PRINC ">" .OC>)>
	       <WIDTH-MUNG .OC 80>)>
	<AND ,INT-MODE <NOT ,MAX-SPACE> <PRINTTYPE ATOM ,PRINT>>
	<COND (,MAX-SPACE .LOWERSTR)>>


<DEFINE WRITE-CODE (OC LOWERSTR CODE OB
		    "OPT" (LEN 0)
		    "AUX" (MVECTOR ,MVECTOR) LCL (OUTCHAN .OC))
   #DECL ((CODE MVECTOR) LIST (LEN) FIX (OUTCHAN) <SPECIAL CHANNEL>
	  (LCL) <OR FALSE <LIST [REST LOCAL-NAME FIX]>> (OB) STRING)
   <MAPF <>
	 <FUNCTION (WRD)
	      <COND (<SET WRD <ASS-INS .WRD>>
		     <SET LEN <+ .LEN 4>>
		     <REPEAT ((I 4)) #DECL ((I) FIX)
			   <PRINTBYTE <SET WRD <CHTYPE <ROT .WRD 9> FIX>>>
			   <COND (<==? <SET I <- .I 1>> 0> <RETURN>)>>)>>
	 .CODE>
   <COND
    (<NOT ,MAX-SPACE>
     <MAPF <>
	   <FUNCTION (CB:CONSTANT-BUCKET "AUX" (WRD <CB-VAL .CB>))
		<COND (<TYPE? .WRD CONSTANT>
		       <REPEAT ((I 4)) #DECL ((I) FIX)
			   <PRINTBYTE <SET WRD <CHTYPE <ROT .WRD 9> FIX>>>
			   <COND (<==? <SET I <- .I 1>> 0> <RETURN>)>>
		       <SET LEN <+ .LEN 4>>)
		      (<TYPE? .WRD CONST-W-LOCAL>
		       <COND (<SET LCL <MEMQ <1 .WRD> ,FINAL-LOCALS>>
			      <SET WRD
				   <CHTYPE <ORB <ANDB <2 .WRD>
						      *777777000000*>
						<ANDB <+ <CHTYPE <2 .WRD> FIX>
							 <CHTYPE <2 .LCL> FIX>>
						      *777777*>> FIX>>)
			     (ELSE
			      <PRINC "**** WARNING unknown local: " ,OUTCHAN>
			      <PRIN1 <1 .WRD> ,OUTCHAN>
			      <PRINC " in fcn " ,OUTCHAN>
			      <PRIN1 .NAME ,OUTCHAN>
			      <CRLF ,OUTCHAN>
			      <SET WRD 0>)>
		       <REPEAT ((I 4)) #DECL ((I) FIX)
			   <PRINTBYTE <SET WRD <CHTYPE <ROT .WRD 9> FIX>>>
			   <COND (<==? <SET I <- .I 1>> 0> <RETURN>)>>
		       <SET LEN <+ .LEN 4>>)>>
	   ,CONSTANT-VECTOR>
     <CHANNEL-OP .OC WRITE-BUFFER ,OUTPUT-BUFFER <- ,OUTPUT-LENGTH <LENGTH .OB>>>
     <PRINC "| ">
     <PRINC .LOWERSTR>
     <COND (<NOT ,BOOT-MODE>
	    <COND (,INT-MODE <PRINC "!-IMSUBR!- " .OUTCHAN>)
		  (ELSE <PRINC "-IMSUBR " .OUTCHAN>)>)>
     <MAPF <>
	   <FUNCTION (MV) 
		   #DECL ((MV) ANY)
		   <PRINC !\ >
		   <COND (<>
			  ; "This used to strip off a level of quoting
			     for atoms, but that's already happened in
			     MVADD..."
			  ;<AND <TYPE? .MV FORM>
			       <G? <LENGTH .MV> 1>
			       <==? <1 .MV> QUOTE>
			       <TYPE? <2 .MV> ATOM>>
			  <SET MV <2 .MV>>)>
		   <COND (<TYPE? .MV CHARACTER>
			  <PRINTTYPE CHARACTER ,CHR-PRINT>
			  <PRIN1 .MV>
			  <PRINTTYPE CHARACTER ,PRINT>)
			 (<TYPE? .MV CONST-W-LOCAL>
			  <SET MV
			       <+ <CHTYPE <2 <MEMQ <1 .MV> ,FINAL-LOCALS>>
					  FIX>
				  <CHTYPE <2 .MV> FIX>>>
			  <PRIN1 .MV>)
			 (T <PRIN1 .MV>)>>
	   <REST .MVECTOR 3>>
     <COND (,GLUE-MODE <WIDTH-MUNG .OUTCHAN 80>)>
     <PRINC !\]>
     <COND (<NOT ,BOOT-MODE> <PRINC !\>>)>
     <CRLF>
     <COND (,VERBOSE
	    <PROG ((OUTCHAN <COND (,V2) (,V1 .OUTCHAN) (T ,OUTCHAN)>))
		  #DECL ((OUTCHAN) <SPECIAL CHANNEL>)
		  <PRINC " [Code: ">
		  <PRIN1 </ .LEN 4>>
		  <PRINC " / Vector: ">
		  <PRIN1 <* <- <LENGTH .MVECTOR> 1> 2>>
		  <PRINC !\]>>)>
     ,NULL)
    (ELSE .LEN)>>

<DEFINE ASS-INS (WRD "AUX" M (AC? <>) (ADR 0) (IDX 0) (INS 0) (IND 0) INAME LCL)
	#DECL ((WRD) <OR CONST-W-LOCAL CONSTANT FIX WORD INST ATOM>
	       (INS ADR IDX IND) FIX (AC?) <OR FALSE FIX> (INAME) ATOM
	       (M) <OR FALSE VECTOR>)
       <COND
	(<TYPE? .WRD ATOM> <>)
	(<TYPE? .WRD INST>
	 <MAPF <>
	  <FUNCTION (FROB) 
		  <COND (<==? .FROB @> <SET IND 16>)
			(<AND <TYPE? .FROB ATOM> <SET M <MEMQ .FROB ,ACS>>>
			 <COND (<OR .AC? <N==? .IND 0>>
				<SET ADR <+ .ADR <2 .M>>>)
			       (T <SET AC? <2 .M>>)>)
			(<TYPE? .FROB LOCAL-NAME>
			 <COND (<SET LCL <MEMQ .FROB ,FINAL-LOCALS>>
				<SET ADR <+ .ADR <CHTYPE <2 .LCL> FIX>>>)
			       (ELSE
				<SET ADR 0>
				<PRINC "**** WARNING unknown local: " ,OUTCHAN>
				<PRIN1 .FROB ,OUTCHAN>
				<PRINC " in fcn " ,OUTCHAN>
			        <PRIN1 .NAME ,OUTCHAN>
				<CRLF ,OUTCHAN>)>)
			(<TYPE? .FROB ATOM>
			 <SET INAME .FROB>
			 <SET FROB <COND (<LOOKUP <SPNAME .FROB> ,OPS>)
					 (<LOOKUP <SPNAME .FROB> ,JSYS-OBLIST>)
					 (ELSE .FROB)>>
			 <COND (<AND <GASSIGNED? .FROB>
				     <TYPE? ,.FROB JSYS>>
				<SET INS <CHTYPE <LSH ,.FROB -27> FIX>>
				<SET ADR <CHTYPE <ANDB ,.FROB *777777*> FIX>>)
			       (<GASSIGNED? .FROB>
				<SET INS ,.FROB>)
			       (ELSE
				<MIMOCERR BAD-OPCODE!-ERRORS .FROB>)>)
			(<TYPE? .FROB LIST>
			 <SET FROB <1 .FROB>>
			 <SET IDX <2 <SET M <CHTYPE <MEMQ .FROB ,ACS>
						    VECTOR>>>>)
			(<MEMQ <PRIMTYPE .FROB> '[WORD FIX]>
			 <SET ADR <+ .ADR <CHTYPE .FROB FIX>>>)
			(<MIMOCERR BAD-THING-IN-CODE!-ERRORS .FROB>)>>
	  .WRD>
	 <COND (<NOT .AC?> <SET AC? 0>)>
	 <CHTYPE <ORB <LSH .INS 27>
		      <LSH <+ <CHTYPE <LSH .AC? 5> FIX>
			      .IND .IDX> 18>
		      <ANDB .ADR *777777*>> FIX>)>>

<DEFINE DUMP-CODE (CODE TC "AUX" (CB ,CODE-BUFFER) (TCB .CB))
	#DECL ((CODE) LIST (TC) CHANNEL (CB TCB) <UVECTOR [REST FIX]>)
	<PUT .CB 1 ,CODE-LENGTH>
	<SET CB <REST .CB>>
	<MAPF <>
	      <FUNCTION (WRD)
		   <COND (<SET WRD <ASS-INS .WRD>>
			  <PUT .CB 1 .WRD>
			  <COND (<EMPTY? <SET CB <REST .CB>>>
				 <PRINTB .TCB .TC>
				 <SET CB .TCB>)>)>>
	      .CODE>
	<COND (<N==? .CB .TCB>
	       <PRINTB .TCB .TC <- ,CB-LENGTH <LENGTH .CB>>>)>>

<DEFINE READ-CODE (TC "AUX" (FB ,ONE-WD)) #DECL ((FB) <UVECTOR FIX>)
	<READB .FB .TC>
	<READB <SET FB <IUVECTOR <1 .FB> 0>> .TC>
	.FB>

<DEFINE NOPE (L)
	#DECL ((L) LIST)
	<MIMOCERR CANT-OPEN-COMPILE!-ERRORS .L>> 

<DEFINE MIMOCERR ("TUPLE" T)
	<PRINC "
** Error - ">
	<MAPF <>
	      <FUNCTION (X)
		   <PRIN1 .X>
		   <PRINC !\ >>
	      .T>
	<ERROR !.T>
	<RETURN <> .MACT>>

<DEFINE DOC ("TUPLE" NAM)
	<PROG ((OUTCHAN <OPEN "PRINT" <STRING <GET-NM1 <1 .NAM>> ".OC">>))
	      #DECL ((OUTCHAN) <SPECIAL CHANNEL>)
	      <COND (.OUTCHAN
		     <SETG V1 T>
		     <SETG V2 .OUTCHAN>
		     <COND (,GLUE-MODE <FILE-GLUE !.NAM>)
			   (ELSE <FILE-MIMOC !.NAM>)>
		     <CLOSE .OUTCHAN>
		     T)
		    (ELSE
		     <ERROR .OUTCHAN>)>>>