<USE "FILE-INDEX">

<SETG WARN-PRINT T>

<DEFINE READIN (READ-INFO "OPTIONAL" (NXT <>) "AUX" RES LAST FROB ATM) 
	#DECL ((READ-INFO) TUPLE (RES) <PRIMTYPE LIST>)
	<SET RES <READ-LIST-INTERNAL .READ-INFO END!- <>>>
	<COND (<OR <NOT .RES>
		   <EMPTY? .RES>
		   <NOT <TYPE? <SET LAST <NTH .RES <LENGTH .RES>>> FORM>>
		   <EMPTY? .LAST>
		   <N==? <1 .LAST> END!- >>
	       <SETG END-READ T>)
	      (T
	       <COND (.NXT
		      <SET RES (.NXT !.RES)>)>
	       <REPEAT ((L .RES) (LL .RES) OBJ (IFL ()) (FLUSH? <>))
	         #DECL ((L) LIST)
		 <COND (<EMPTY? .L> <RETURN>)>
		 <COND (<AND <TYPE? <SET OBJ <1 .L>> FORM>
			     <FUDGE-MIMOP .OBJ>>
			<COND (<==? <SET FROB <1 .OBJ>> END!-MIMOP>
			       <RETURN>)>
			<COND (<==? .FROB IFSYS!-MIMOP>
			       <COND (<MEMBER <2 .OBJ> '["VAX" "UNIX"]>
				      <SET IFL (<2 .OBJ> !.IFL)>
				      <SET FLUSH? T>)
				     (T
				      <FLUSH-TO-ENDIF <2 .OBJ> <REST .L>
						      .LL>
				      <SET L <REST .LL>>
				      <AGAIN>)>)
			      (<==? .FROB IFCAN!-MIMOP>
			       <COND (<AND
				       <SET ATM <LOOKUP <2 .OBJ>
							<MOBLIST MIMOP>>>
				       <GASSIGNED? .ATM>>
				      <SET IFL (<2 .OBJ> !.IFL)>
				      <SET FLUSH? T>)
				     (T
				      <FLUSH-TO-ENDIF <2 .OBJ> <REST .L>
						      .LL>
				      <SET L <REST .LL>>
				      <AGAIN>)>)
			      (<==? .FROB IFCANNOT!-MIMOP>
			       <COND (<OR
				       <NOT <SET ATM
						 <LOOKUP <2 .OBJ>
							 <MOBLIST MIMOP>>>>
				      <NOT <GASSIGNED? .ATM>>>
				      <SET IFL (<2 .OBJ> !.IFL)>
				      <SET FLUSH? T>)
				     (T
				      <FLUSH-TO-ENDIF <2 .OBJ> <REST .L>
						      .LL>
				      <SET L <REST .LL>>
				      <AGAIN>)>)
			      (<==? .FROB ENDIF!-MIMOP>
			       <COND (<OR <EMPTY? .IFL>
					  <N=? <2 .OBJ> <1 .IFL>>>
				      <ERROR UNMATCHED-IFSYS!-ERRORS
					     .OBJ .IFL READIN>)
				     (<SET IFL <REST .IFL>>
				      <SET FLUSH? T>)>)>)>
		 <COND (.FLUSH?
			<SET FLUSH? <>>
			<COND (<==? .L .LL>
			       <SET RES <REST .RES>>
			       <SET L .RES>
			       <SET LL .RES>)
			      (T
			       <PUTREST .LL <SET L <REST .L>>>)>)
		       (T
			<SET LL .L>
			<SET L <REST .L>>)>>
	       .RES)>>

<DEFINE FLUSH-TO-ENDIF (FLG L LL "AUX" THING (CT 1))
  #DECL ((L LL) LIST)
  <REPEAT ()
    <COND (<EMPTY? .L>
	   <ERROR MISSING-ENDIF!-ERRORS .FLG>
	   <RETURN>)>
    <SET THING <1 .L>>
    <COND (<AND <TYPE? .THING FORM>
		<FUDGE-MIMOP .THING>>
	   <COND (<==? <1 .THING> ENDIF!-MIMOP>
		  <COND (<0? <SET CT <- .CT 1>>>
			 <PUTREST .LL <REST .L>>
			 <RETURN>)>)
		 (<OR <==? <1 .THING> IFSYS!-MIMOP>
		      <==? <1 .THING> IFCAN!-MIMOP>
		      <==? <1 .THING> IFCANNOT!-MIMOP>>
		  <SET CT <+ .CT 1>>)>)>
    <SET L <REST .L>>>>

<DEFINE FUDGE-MIMOP (FRM "AUX" NATM) 
	#DECL ((FRM) FORM)
	<COND (<SET NATM <LOOKUP <SPNAME <1 .FRM>> ,MIMOP-OBLIST>>
	       <PUT .FRM 1 .NATM>)>>

<DEFINE PRE-HACK (L "AUX" LR) 
   #DECL ((L LR) LIST)
   <REPEAT (WIN)
     #DECL ((WIN) <OR ATOM FALSE>)
     <SET WIN <>>
     <SET LR
      <MAPR ,LIST
	    <FUNCTION (LL "AUX" (FRM <1 .LL>) M N I LBL) 
		    #DECL ((FRM) <OR FORM ATOM> (M) <OR FALSE LIST> (LBL) ATOM
			   (N) <OR FALSE LIST> (I) FORM (LL) LIST)
		    <COND (<TYPE? .FRM ATOM> <MAPRET>)
			  (<==? <1 .FRM> OPT-DISPATCH!-MIMOP>
			   <MAPRET !<REST .FRM 3>>)
			  (<OR <SET M <MEMQ + .FRM>> <SET M <MEMQ - .FRM>>>
			   <COND (<SET N <MEMQ <SET LBL <2 .M>> .L>>)
				 (T <MIMOCERR BAD-LABEL!-ERRORS .LBL>)>
			   <COND (<==? <1 <SET I <NEXTINS .N>>> JUMP!-MIMOP>
				  <PUT .M 2 <3 .I>>
				  <MAPRET <3 .I>>)
				 (<AND <==? <1 .FRM> JUMP!-MIMOP>
				       <==? <1 .I> RETURN>>
				  <PUT .LL 1 .I>
				  <MAPRET>)
				 (T <MAPRET .LBL>)>)
			  (<==? <1 .FRM> ICALL!-MIMOP> <MAPRET <2 .FRM>>)
			  (T <MAPRET>)>>
	    .L>>
     <REPEAT ((L .L) (OL .L) ITM)
	     #DECL ((L OL) LIST (ITM) ANY)
	     <COND (<EMPTY? .L> <RETURN>)
		   (<AND <TYPE? <1 .L> ATOM> <NOT <MEMQ <1 .L> .LR>>>
		    <PUTREST .OL <REST .L>>
		    <SET WIN T>)
		   (<AND <TYPE? <SET ITM <1 .L>> FORM>
			 <==? <1 .ITM> JUMP>
			 <TYPE? <SET ITM <1 .OL>> FORM>
			 <==? <1 .ITM> JUMP>>
		    <PUTREST .OL <REST .L>>
		    <SET WIN T>)
		   (<AND <TYPE? <SET ITM <1 .L>> FORM>
			 <==? <1 .ITM> JUMP>
			 <NOT <LENGTH? .L 1>>
			 <==? <2 .L> <3 .ITM>>>
		    <PUTREST .OL <REST .L>>
		    <SET WIN T>)
		   (<AND <TYPE? <SET ITM <1 .L>> FORM>
			 <==? <1 .ITM> JUMP>
			 <NOT <LENGTH? .L 1>>
			 <NOT <TYPE? <2 .L> ATOM>>>
		    <PUTREST .L <REST .L 2>>
		    <SET WIN T>)
		   (T <SET OL .L>)>
	     <SET L <REST .L>>>
     <OR .WIN <RETURN>>>>

<SETG USE-PRE <>>

<DEFINE FIXIT (LST "AUX" LABS) 
	#DECL ((LST) LIST)
	<SETG COMPERR-FLAG <>>
	<SETG UNWCNT-FLAG <>>
	<AND ,USE-PRE <PRE-HACK .LST>>
	<REPLACE-LOOP-BRANCHES .LST>
	<SET LABS <FIND-DUAL-LABELS .LST>>
	<SET LABS (UNWCONT TUNWCNT COMPERR TCOMPERR !.LABS)>
	<FLUSH-DUAL-LABELS .LST .LABS>
	<COND (,COMPERR-FLAG
	       <PUTREST <REST .LST <- <LENGTH .LST> 1>>
			(TCOMPERR '<COMPERR!-MIMOP>)>)>
	<COND (,UNWCNT-FLAG
	       <PUTREST <REST .LST <- <LENGTH .LST> 1>>
			(TUNWCNT '<UNWCNT!-MIMOP>)>)>
	T>

<DEFINE NEXTINS (L) 
	#DECL ((L) LIST)
	<MAPF <>
	      <FUNCTION (ITM) 
		      #DECL ((ITM) <OR ATOM FORM>)
		      <COND (<TYPE? .ITM FORM> <MAPLEAVE .ITM>)>>
	      .L>>

<DEFINE FIND-DUAL-LABELS (LST "AUX" (PPTR .LST) (NPTR <REST .LST>)) 
	#DECL ((LST) LIST)
	<MAPF ,LIST
	      <FCN ("AUX" L1 L2)
		   <COND (<AND <TYPE? <SET L1 <1 .PPTR>> ATOM>
			       <TYPE? <SET L2 <1 .NPTR>> ATOM>>
			  <PUTREST .PPTR <REST .NPTR>>
			  <COND (<EMPTY? <SET NPTR <REST .PPTR>>>
				 <MAPSTOP .L2 .L1>)>
			  <MAPRET .L2 .L1>)>
		   <SET PPTR .NPTR>
		   <COND (<EMPTY? <SET NPTR <REST .PPTR>>> <MAPSTOP>)>
		   <MAPRET>>>>

<DEFINE FLUSH-DUAL-LABELS (LST LABS "AUX" PITEM FLAB PLAB) 
	#DECL ((LST) LIST (LABS) <LIST [REST ATOM]>
	       (PITEM) <OR ATOM <PRIMTYPE LIST>>)
	<MAPF <>
	      <FCN (ITEM)
		   <COND (<AND <TYPE? .ITEM FORM>
			       <OR <SET PITEM <MEMQ + .ITEM>>
				   <SET PITEM <MEMQ - .ITEM>>
				   <AND <NOT <EMPTY? .ITEM>>
					<TYPE? <SET PITEM
						    <NTH .ITEM <LENGTH .ITEM>>>
					       LIST>
					<OR <SET PITEM <MEMQ + .PITEM>>
					    <SET PITEM <MEMQ - .PITEM>>>>>
			       <SET FLAB <DMEMQ <2 .PITEM> .LABS>>>
			  <SET PLAB <2 .FLAB>>
			  <COND (<==? .PLAB TCOMPERR> <SETG COMPERR-FLAG T>)>
			  <COND (<==? .PLAB TUNWCNT> <SETG UNWCNT-FLAG T>)>
			  <PUT .PITEM 2 <2 .FLAB>>)>>
	      .LST>>

<DEFINE REPLACE-LOOP-BRANCHES (CODE "AUX" (LOOPS ())) 
	#DECL ((CODE) LIST)
	<REPEAT ((PTR .CODE) ITM RBRANCH LAB NLAB RPTR)
		<COND (<EMPTY? .PTR> <RETURN>)>
		<COND (<TYPE? <SET ITM <1 .PTR>> FORM>
		       <COND (<AND <==? <1 .ITM> LOOP!-MIMOP>
				   <G? <LENGTH .ITM> 1>>
			      <SET LOOPS (<2 .PTR> !.LOOPS)>
			      <SET PTR <REST .PTR 2>>)
			     (<==? <1 .ITM> DISPATCH!-MIMOP>
			      <HACK-DISPATCH-LABELS .PTR .LOOPS>
			      <SET PTR <REST .PTR>>)
			     (<AND <OR <SET RBRANCH <MEMQ + .ITM>>
				       <SET RBRANCH <MEMQ - .ITM>>
				       <AND <TYPE? <SET RBRANCH
							<NTH .ITM
							     <LENGTH .ITM>>>
						   LIST>
					    <OR <SET RBRANCH <MEMQ + .RBRANCH>>
						<SET RBRANCH
						     <MEMQ - .RBRANCH>>>>>
				   <MEMQ <SET LAB <2 .RBRANCH>> .LOOPS>
				   <N==? <1 .ITM> JUMP!-MIMOP>>
			      <SET NLAB <MAKE-LABEL "UNLOOP">>
			      <PUT .RBRANCH 2 .NLAB>
			      <COND (<==? <1 .RBRANCH> -> <PUT .RBRANCH 1 +>)
				    (<PUT .RBRANCH 1 ->)>
			      <SET RPTR <REST .PTR>>
			      <PUTREST .PTR (<FORM JUMP!-MIMOP + .LAB> .NLAB)>
			      <PUTREST <REST .PTR 2> .RPTR>
			      <SET PTR <REST .PTR 3>>)
			     (<SET PTR <REST .PTR>>)>)
		      (<SET PTR <REST .PTR>>)>>>

<DEFINE HACK-DISPATCH-LABELS (PTR LOOPS "AUX" (DEFLBL <>) (ANY? <>))
  #DECL ((PTR LOOPS) LIST (DEFLBL) <OR ATOM FALSE> (ANY?) <OR LIST FALSE>)
  <COND (<TYPE? <2 .PTR> ATOM>
	 <SET DEFLBL <2 .PTR>>)>
  <MAPR <>
    <FUNCTION (NP "AUX" (LBL <1 .NP>) NL)
      #DECL ((NP) LIST (NL LBL) ATOM)
      <COND (<MEMQ .LBL .LOOPS>
	     ; "We have to put in funny jumps, so the default case must become
		JUMP label..."
	     <COND (<NOT .ANY?>
		    <COND (<NOT .DEFLBL>
			   ; "Make sure we have a label to jump to"
			   <PUTREST .PTR (<SET DEFLBL <MAKE-LABEL "DEFCASE">>
					  !<REST .PTR>)>)>
		    ; "Put in the jump"
		    <PUTREST .PTR 
			     <SET ANY? (<FORM JUMP!-MIMOP + .DEFLBL>
					!<REST .PTR>)>>)>
	     <SET NL <MAKE-LABEL "LCASE">>
	     <PUTREST .ANY?
		      (.NL <FORM JUMP!-MIMOP + .LBL> !<REST .ANY?>)>
	     <1 .NP .NL>
	     ; "Find any other frobs to same place"
	     <REPEAT ((L <REST .NP>))
	       <COND (<SET L <MEMQ .LBL .L>>
		      <1 .L .NL>)
		     (<RETURN>)>>)>>
    <REST <1 .PTR> 3>>>

<DEFINE DMEMQ (X L) 
	#DECL ((X) ATOM (L) <LIST [REST ATOM]>)
	<REPEAT ()
		<COND (<EMPTY? .L> <RETURN <>>)
		      (<==? .X <1 .L>> <RETURN .L>)
		      (<SET L <REST .L 2>>)>>>

<DEFINE PRINT-MIM-CODE (LST
			"OPTIONAL" (OUTCHAN .OUTCHAN)
			"AUX" (OBLIST (,MIMOP-OBLIST !.OBLIST)))
	#DECL ((LST) LIST (OBLIST) <SPECIAL LIST> (OUTCHAN) <SPECIAL CHANNEL>)
	<CRLF>
	<CRLF>
	<MAPF <>
	      <FCN (X)
		   <COND (<TYPE? .X ATOM> <PRIN1 .X>)
			 (ELSE <PRINC "	  "> <PRIN1 .X>)>
		   <CRLF>>
	      .LST>>

<GDECL (GLUE-FCNS) <LIST [REST ATOM]>>

<GDECL (INCHANS) <LIST [REST CHANNEL]>>

<DEFINE FINISH-FILE (READ-INFO OUTCHAN EXPFLOAD "AUX" (IND '(1))
		     (EXPSPLICE <AND <ASSIGNED? EXPSPLICE> .EXPSPLICE>) TMP
		     (INCHAN <RI-CHANNEL .READ-INFO>) ST)
  #DECL ((READ-INFO) TUPLE (OUTCHAN) <SPECIAL <OR CHANNEL FALSE>>
	 (EXPSPLICE EXPFLOAD) <OR ATOM FALSE> (INCHAN) <SPECIAL CHANNEL>)
  <REPEAT (ITM NCH)
    <COND (<==? <SET ITM <READ-INTERNAL .READ-INFO '.IND>> .IND>
	   <COND (<EMPTY? <SETG INCHANS <REST ,INCHANS>>>
		  <CLOSE .INCHAN>
		  <RETURN <>>)>
	   <CLOSE <SET-RI-CHANNEL .READ-INFO <SET INCHAN <1 ,INCHANS>>>>
	   <AGAIN>)>
    <COND (<NOT <OR <TYPE? .ITM STRING CHARACTER FIX>
		    <AND <TYPE? .ITM ATOM>
			 <=? <SPNAME .ITM> "">>>>
	   <COND (<AND <TYPE? .ITM FORM>
		       <NOT <LENGTH? .ITM 2>>
		       <MEMBER <SPNAME <1 .ITM>> '["FCN" "GFCN"]>>
		  <RETURN .ITM>)>
	   <COND (<TYPE? .ITM WORD>
		  ; "Copy the new hash code over to the msubr file."
		  <COND (<NOT ,GLUE>
			 <SETG LAST-HASH .ITM>
			 <COND (<NOT ,INT-MODE>
				<SET ST <UNPARSE .ITM>>
				<PRINC "#WORD *" .OUTCHAN>
				<PRINTSTRING <REST .ST 7> .OUTCHAN
					     <- <LENGTH .ST> 8>>
				<PRINC !\* .OUTCHAN>
				<CRLF .OUTCHAN>)>)>)
		 (<AND .EXPFLOAD
		       <TYPE? .ITM FORM>
		       <NOT <EMPTY? .ITM>>
		       <COND (<==? <1 .ITM> FLOAD>
			      <SET NCH <OPEN "READ" !<REST .ITM>>>)
			     (<==? <1 .ITM> L-FLOAD>
			      <SET NCH <L-OPEN <2 .ITM>>>)>>
		  <PRINFILE .NCH>
		  <SET-RI-CHANNEL .READ-INFO <SET INCHAN .NCH>>
		  <SETG INCHANS (.NCH !,INCHANS)>)
		 (T
		  <COND (<AND <TYPE? .ITM FORM>
			      <NOT <EMPTY? .ITM>>>
			 <COND (<==? <1 .ITM> NEW-CHANNEL-TYPE>
				<SET TMP <EVAL <FORM NCT-NEW !<REST .ITM>>>>)
			       (<AND <MEMQ <1 .ITM> '[INCLUDE-WHEN USE-WHEN]>
				     <NOT <LENGTH? .ITM 1>>
				     <TYPE? <2 .ITM> FORM>
				     <NOT <EMPTY? <2 .ITM>>>
				     <==? <1 <2 .ITM>> COMPILING?>>
				<SET TMP <EVAL .ITM>>
				<1 <2 .ITM> DEBUGGING?>)
			       (T
				<SET TMP <EVAL .ITM>>)>)
			(T
			 <SET TMP <EVAL .ITM>>)>
		  <COND (.OUTCHAN
			 <COND (,INT-MODE
				<PRINTTYPE ATOM ,ATOM-PRINT>
				<PRINTTYPE LVAL ,ATOM-PRINT>
				<PRINTTYPE GVAL ,ATOM-PRINT>)>
			 <COND (<AND .EXPSPLICE <TYPE? .TMP SPLICE>>
				<MAPF <>
				  <FUNCTION (X)
				    <PRIN1 .X>
				    <CRLF>>
				  .TMP>)
			       (T
				<PRIN1 .ITM>
				<CRLF>)>
			 <COND (,INT-MODE
				<PRINTTYPE ATOM ,PRINT>
				<PRINTTYPE LVAL ,PRINT>
				<PRINTTYPE GVAL ,PRINT>)>)>)>)>>>

<GDECL (LAST-HASH) <OR FALSE WORD>>

<DEFINE FILE-PASS1 (NAMES READ-INFO OCH PMCH AMCH AACH EXPFLOAD
		    "AUX" LST NOFF ITM (STARCPU 0.0000000) (NM2 "MIMA")
			  (PRE-CH <>) (INDEX ()) (RREDO ()))
	#DECL ((OCH) CHANNEL (PMCH AMCH AACH) <OR FALSE CHANNEL>
	       (LST) <LIST [REST <OR ATOM FORM>]> (NM2) <SPECIAL STRING>
	       (NAMES) <<PRIMTYPE VECTOR> [REST STRING]> (READ-INFO) TUPLE
	       (INDEX RREDO) LIST)
	<SETG END-READ T>
	<SETG GLUE-FCNS ()>
	<SETG FCN-COUNT 0>
	<COND (<AND <NOT ,GLUE>
		    <ASSIGNED? PRECOMPILED>
		    .PRECOMPILED
		    ,PRE-CH>
	       <SET PRE-CH ,PRE-CH>
	       <CRLF .OUTCHAN>
	       <PRINT-MANY .OUTCHAN PRINC "Precompilation from "
			   <CHANNEL-OP .PRE-CH NAME>>
	       <SET INDEX <BUILD-INDEX .PRE-CH ,FCN-OBL>>
	       <COND (<AND <ASSIGNED? REDO>
			   .REDO>
		      <SET RREDO
			   <MAPF ,LIST
				 <FUNCTION (X) <SPNAME .X>>
				 .REDO>>)>)>
	<REPEAT READIT (NAME ITM (CH <>) COMPILER-INPUT OLD-FCN)
		#DECL ((COMPILER-INPUT) <SPECIAL CHANNEL>
		       (OLD-FCN) <OR FALSE LIST>)
		<SETG LAST-HASH <>>
		<COND (,END-READ
		       <AND .CH <CLOSE .CH>>
		       <COND (<EMPTY? .NAMES> <RETURN>)>
		       <COND (<NOT <SET CH <OPEN "READ" <1 .NAMES>>>>
			      <ERROR .CH>)>
		       <PRINFILE .CH>
		       <SETG INCHANS (.CH)>
		       <SET COMPILER-INPUT .CH>
		       <SET-RI-CHANNEL .READ-INFO .CH>
		       <SET NAMES <REST .NAMES>>
		       <SETG END-READ <>>)>
		<COND (<NOT <SET ITM
				 <IO-TIMER
				  <FINISH-FILE .READ-INFO
					       <COND (<NOT ,GLUE> .OCH)>
					      .EXPFLOAD>>>>
		       <SETG END-READ T>
		       <AGAIN .READIT>)
		      (T
		       <SET CH <1 ,INCHANS>>
		       <SETG FCN-COUNT <+ ,FCN-COUNT 1>>
		       <COND (<=? <SPNAME <1 .ITM>> "FCN">
			      <PUT .ITM 1 FCN!-MIMOP>)
			     (<PUT .ITM 1 GFCN!-MIMOP>)>
		       <SET NAME <2 .ITM>>
		       <COND (,GLUE
			      <IO-TIMER <SKIP .READ-INFO>>
			      <COND (<==? <1 .ITM> GFCN!-MIMOP>
				     <SETG GLUE-FCNS (.NAME !,GLUE-FCNS)>)>)
			     (ELSE
			      <COND
			       (<AND .PRE-CH
				     <NOT <MEMBER <SPNAME .NAME> .RREDO>>
				     <SET OLD-FCN
					  <FIND-OLD-FCN .NAME .INDEX>>
				     <OR <L? <LENGTH .OLD-FCN> 4>
					 <==? <4 .OLD-FCN> ,LAST-HASH>>>
				; "Skip if have precompiled, fcn is not
				   in redo list, is in index (--> in precompiled),
				   and either doesn't have hash or has right
				   hash"
				<COND (,VERBOSE?
				       <CRLF .OUTCHAN>
				       <PRINC "Skipping function " .OUTCHAN>
				       <PRIN1 .NAME .OUTCHAN>)>
				<IO-TIMER
				 <BIND ()
				       <COPY-OLD-FCN .OLD-FCN .PRE-CH .OCH>
				       <SET-RI-CHANNEL .READ-INFO <>>
				       <SKIP-MIMA .CH .NAME>
				       <SET-RI-CHANNEL .READ-INFO .CH>>>)
			       (T
				<COND (<AND ,WARN-PRINT ,VERBOSE?>
				       <CRLF>
				       <PRINC "Compiling: ">
				       <PRIN1 <2 .ITM>>)>
				<IO-TIMER <SET LST <READIN .READ-INFO .ITM>>>
				<SET STARCPU <TIME>>
				<FIXIT .LST>
				<AND .PMCH <PRINT-MIM-CODE .LST .PMCH>>
				<MIMOC .LST T>
				<AND .AMCH <PRINT-GEN-INST .AMCH>>
				<SET NAME ,FUNCTION-NAME>
				<ASSEMBLE-CODE 0 .NAME>
				<IO-TIMER
				 <COND (.AACH
					<CRLF .AACH>
					<CRLF .AACH>
					<PRIN1 .NAME .AACH>
					<CRLF .AACH>
					<CRLF .AACH>
					<PRINT-FINAL-INST .AACH>)>>
				<SETG INTERNAL-MSUBR-NAME
				      <GEN-NAME ,FUNCTION-NAME>>
				<COND (,INT-MODE
				       <PRINTTYPE ATOM ,ATOM-PRINT>
				       <PRINTTYPE LVAL ,ATOM-PRINT>
				       <PRINTTYPE GVAL ,ATOM-PRINT>)>
				<IO-TIMER <BIND ()
						<PRINT-IMSUBR .OCH>
						<PRINT-MSUBR 0 .OCH>>>
				<AND ,VERBOSE?
				     ,WARN-PRINT
				     <PRINT-RSUBR-STATS .STARCPU 0>>
				<COND (,INT-MODE
				       <PRINTTYPE ATOM ,PRINT>
				       <PRINTTYPE LVAL ,PRINT>
				       <PRINTTYPE GVAL ,PRINT>)>)>)>)>>>

<DEFMAC IO-TIMER ('THING)
  <FORM BIND ((STARCPU '<TIME>) VAL)
    <FORM SET VAL .THING>
    '<SETG IO-TIME <+ ,IO-TIME <- <TIME> .STARCPU>>>
    '.VAL>>
    

<DEFINE FILE-PASS2 (NAMES READ-INFO OCH PMCH AMCH AACH EXPFLOAD
		      "AUX" LST NOFF ITM (STARCPU 0.0000000) (NM2 "MIMA")
		      (REDEFINE T) (PASS2? T))
   #DECL ((OCH) CHANNEL (PMCH AMCH AACH) <OR FALSE CHANNEL>
	  (LST) <LIST [REST <OR ATOM FORM>]> (READ-INFO) TUPLE
	  (NM2) <SPECIAL STRING> (NAMES) <<PRIMTYPE VECTOR> [REST STRING]>
	  (PASS2? REDEFINE) <SPECIAL ATOM>)
   <SETG END-READ T>
   <SETG FIRST-FCN-ACCESS <>>
   <SETG FIRST-FCN-OBLIST ()>
   <REPEAT READIT (NAME (FIRST T) (OFF 0) (CH <>) (END T) ARES
		   COMPILER-INPUT CH2)
       #DECL ((ARES) <LIST [2 FIX]> (COMPILER-INPUT) <SPECIAL CHANNEL>)
       <COND (<0? ,FCN-COUNT>
	      <COND (<SET CH2 <OPEN "PRINT" ""
				    <CHANNEL-OP .OCH NM1>
				    <IFSYS ("TOPS20" "VSUBR")
					   ("VAX" "GSUBR")>
				    <CHANNEL-OP .OCH DEV>
				    <CHANNEL-OP .OCH SNM>>>
		     <PROG ((OBLIST ,FIRST-FCN-OBLIST))
		       #DECL ((OBLIST) <SPECIAL OBLIST>)
		       <BUFOUT .OCH>
		       <ACCESS .OCH 0>
		       <COND (,FIRST-FCN-ACCESS
			      <IO-TIMER
			       <DO-FILE-COPY .OCH .CH2 ,FIRST-FCN-ACCESS>>)>
		       <COND (,INT-MODE
			      <PRINTTYPE ATOM ,ATOM-PRINT>
			      <PRINTTYPE LVAL ,ATOM-PRINT>
			      <PRINTTYPE GVAL ,ATOM-PRINT>)>
		       <IO-TIMER <PRINT-IMSUBR .CH2>>
		       <COND (.AACH <IO-TIMER <PRINT-FINAL-INST .AACH>>)>
		       <COND (,INT-MODE
			      <PRINTTYPE ATOM ,PRINT>
			      <PRINTTYPE LVAL ,PRINT>
			      <PRINTTYPE GVAL ,PRINT>)>
		       <IO-TIMER <DO-FILE-COPY .OCH .CH2 -1>>>
		     <SET OCH .CH2>
		     <SETG FCN-COUNT -1>)
		    (<ERROR CANT-OPEN-MSUBR-FILE .CH2 FILE-PASS2>)>)>
       <COND (,END-READ
	      <AND .CH <CLOSE .CH>>
	      <COND (<EMPTY? .NAMES>
		     <CLOSE .CH2>
		     <RETURN>)>
	      <COND (<NOT <SET CH <OPEN "READ" <1 .NAMES>>>>
		     <ERROR .CH>)>
	      <PRINFILE .CH>
	      <SETG INCHANS (.CH)> 
	      <SET COMPILER-INPUT .CH>
	      <SET-RI-CHANNEL .READ-INFO .CH>
	      <SET NAMES <REST .NAMES>>
	      <SETG END-READ <>>)>
       <COND (<NOT <SET ITM <IO-TIMER <FINISH-FILE .READ-INFO .OCH .EXPFLOAD>>>>
	      <SETG END-READ T>
	      <AGAIN .READIT>)
	     (T
	      <SET CH <1 ,INCHANS>>
	      <SETG FCN-COUNT <- ,FCN-COUNT 1>>
	      <COND (.FIRST
		     <SETG FIRST-FCN-ACCESS <ACCESS .OCH>>
		     <SETG FIRST-FCN-OBLIST .OBLIST>)>
	      <COND (<=? <SPNAME <1 .ITM>> "FCN">
		     <PUT .ITM 1 FCN!-MIMOP>)
		    (<PUT .ITM 1 GFCN!-MIMOP>)>
	      <COND (<AND ,VERBOSE? ,WARN-PRINT>
		     <CRLF>
		     <PRINC "Compiling:  ">
		     <PRIN1 <2 .ITM>>)>
	      <IO-TIMER <SET LST <READIN .READ-INFO .ITM>>>
	      <SET STARCPU <TIME>>
	      <FIXIT .LST>
	      <MIMOC .LST .FIRST>
	      <AND .AMCH <PRINT-GEN-INST .AMCH>>
	      <SET NAME ,FUNCTION-NAME>
	      <AND .FIRST
		   <SETG INTERNAL-MSUBR-NAME <GEN-NAME .NAME>>>
	      <SET ARES <ASSEMBLE-CODE .OFF .NAME>>
	      <SET OFF <1 .ARES>>
	      <SET NOFF <2 .ARES>>
	      <COND (,INT-MODE
		     <PRINTTYPE ATOM ,ATOM-PRINT>
		     <PRINTTYPE LVAL ,ATOM-PRINT>
		     <PRINTTYPE GVAL ,ATOM-PRINT>)>
	      <IO-TIMER <PRINT-MSUBR .OFF .OCH>>
	      <COND (,INT-MODE
		     <PRINTTYPE ATOM  ,PRINT>
		     <PRINTTYPE LVAL ,PRINT>
		     <PRINTTYPE GVAL ,PRINT>)>
	      <SET FIRST <>>
	      <AND ,WARN-PRINT ,VERBOSE?
		   <PRINT-RSUBR-STATS .STARCPU .OFF>>
	      <SET OFF .NOFF>)>>>
   
<DEFINE PRINT-RSUBR-STATS (STARCPU OFF "AUX" (OUTCHAN .OUTCHAN)) 
	#DECL ((STARCPU) FLOAT (OFF) FIX)
	<PRINT-MANY .OUTCHAN PRINC "    " <- <TIME> .STARCPU>
		    " / " <- <* ,FBYTE-OFFSET 4> .OFF>>>

<DEFINE GEN-NAME (NAME "AUX" ISTR) 
	#DECL ((NAME) ATOM)
	<SET ISTR
	     <MAPF ,STRING
		   <FCN (X "AUX" (VAL <ASCII .X>))
			<COND (<AND <G=? .VAL <ASCII !\A>>
				    <L=? .VAL <ASCII !\Z>>>
			       <ASCII <+ .VAL <- <ASCII !\a> <ASCII !\A>>>>)
			      (.X)>>
		   <SPNAME .NAME>>>
	<PARSE <STRING .ISTR "-IMSUBR">>>

<DEFINE ATOM-PRINT (ATM "AUX" (SPN <SPNAME <CHTYPE .ATM ATOM>>)
		    (OUTCHAN .OUTCHAN)) 
	#DECL ((ATM) <OR ATOM LVAL GVAL> (SPN) STRING)
	<COND (<AND <NOT <LENGTH? .SPN 2>>
		    <==? <1 .SPN> !\T>
		    <==? <2 .SPN> !\$>>
	       <IPRINC <REST .SPN 2> .OUTCHAN <NOT ,BOOT-MODE> <TYPE .ATM>>)
	      (<AND <OR <==? <OBLIST? .ATM> <ROOT>>
			<MEMBER .SPN ,ROOT-ATOMS>
			<AND <==? <OBLIST? .ATM> ,MIMOP-OBLIST>
			     <LOOKUP .SPN <ROOT>>>>
		    <NOT ,BOOT-MODE>>
	       <IPRINC .SPN .OUTCHAN T <TYPE .ATM>>)
	      (T <IPRINC .SPN .OUTCHAN <> <TYPE .ATM>>)>
	<PRINC " ">>

<SETG FOOSTR "$">

<GDECL (FOOSTR) STRING>

<GDECL (GC-COUNT) FIX (IO-TIME) FLOAT>

<DEFINE FILE-MIMOC (OUTNAME PML AML AAL
		    "TUPLE" NAMES
		    "AUX" CH OCH (PMCH <>) (AMCH <>) (AACH <>)
			  (GC-HANDLER <>)
			  (READ-INFO <ITUPLE 9 <>>)
			  SAVED-OBLIST)
	#DECL ((NAME) STRING)
	<SETG PRE-CH <>>
	<SETUP-READ-TABLE>
	<INIT-RI .READ-INFO <> 2560 ,MIMOC-READ-TABLE>
	<PROG (NM2)
	      #DECL ((NM2) <SPECIAL STRING>)
	      <COND (<AND <ASSIGNED? PRECOMPILED>
			  .PRECOMPILED>
		     <IFSYS ("TOPS20"
			     <SET NM2 "VSUBR">)
			    ("UNIX"
			     <SET NM2 "MSUBR">)>
		     <COND (<NOT <TYPE? .PRECOMPILED STRING>>
			    <SETG PRE-CH <OPEN "READ" .OUTNAME>>)
			   (T
			    <SETG PRE-CH <OPEN "READ" .PRECOMPILED>>)>)>
	      <COND (<AND <ASSIGNED? AUTO-PRECOMP>
			  .AUTO-PRECOMP
			  ,PRE-CH>
		     ; "Have precompiled, and don't necessarily want to
			do anything"
		     <SET NM2 "MIMA">
		     <COND (<AND <SET OCH <OPEN "READ" .OUTNAME>>
				 <L=? <CHANNEL-OP .OCH WRITE-DATE>
				      <CHANNEL-OP ,PRE-CH WRITE-DATE>>>
			    ; "Have existing msubr, and it's later"
			      <PRINT-MANY ,OUTCHAN PRINC
					  "Not recompiling "
					  <CHANNEL-OP .OCH NAME>
					  ".">
			      <CRLF ,OUTCHAN>
			      <EXIT>)
			   (.OCH
			    <CLOSE .OCH>)>)>
	      <SET NM2 "MUD">
	      ; "Do things to do"
	      <COND (,GLUE
		     <SET NM2 "TMSUBR">)
		    (T
		     <IFSYS ("TOPS20"
			     <SET NM2 "VSUBR">)
			    ("VAX"
			     <SET NM2 "MSUBR">)>)>
	      <OR <SET OCH <OPEN "PRINT" .OUTNAME>>
		  <ERROR .OCH OUTPUT FILE-MIMOC>>
	      <SET NM2 "BMIM">
	      <AND .PML
		   <OR <SET PMCH <OPEN "PRINT" .OUTNAME>>
		       <ERROR .PMCH PRINT-MIM FILE-MIMOC>>>
	      <SET NM2 "AMIM">
	      <AND .AML
		   <OR <SET AMCH <OPEN "PRINT" .OUTNAME>>
		       <ERROR .AMCH PRINT-MIM FILE-MIMOC>>>
	      <SET NM2 "ASSEMBLY">
	      <AND .AAL
		   <OR <SET AACH <OPEN "PRINT" .OUTNAME>>
		       <ERROR .AACH PRINT-MIM FILE-MIMOC>>>>
	<SETG DO-CLOSE T>
	<UNWIND <PROG ((STARCPU <FIX <+ <TIME> 0.5>>) (GCTIME 0.0000000)
		       (EXPFLOAD <AND <ASSIGNED? EXPFLOAD> .EXPFLOAD>))
		      #DECL ((STARCPU) <SPECIAL FIX> (GCTIME) <SPECIAL FLOAT>)
		      <COND (,WARN-PRINT
			     <SET GC-HANDLER
				  <ON <HANDLER "GC" ,COUNT-GCS 10>>>)>
		      <SETG GC-COUNT 0>
		      <SETG IO-TIME 0.0>
		      <SET SAVED-OBLIST <LIST !.OBLIST>>
		      <FILE-PASS1 .NAMES .READ-INFO
				  .OCH .PMCH .AMCH .AACH .EXPFLOAD>
		      <BLOCK .SAVED-OBLIST>
		      <AND ,GLUE <FILE-PASS2 .NAMES .READ-INFO
					     .OCH .PMCH .AMCH .AACH
					     .EXPFLOAD>>
		      <ENDBLOCK>
		      <CLOSE .OCH>
		      <COND (,GLUE
			     <SET NM2 "TMSUBR">
			     <DELFILE .OUTNAME>)>
		      <AND .PMCH <CLOSE .PMCH>>
		      <AND .AMCH <CLOSE .AMCH>>
		      <AND .AACH <CLOSE .AACH>>
		      <SETG DO-CLOSE <>>
		      <AND .GC-HANDLER <OFF .GC-HANDLER>>
		      <COND (,WARN-PRINT <PRINTSTATS>)>
		      <RETURN T>>
		<PROG ()
		      <COND (,DO-CLOSE
			     <COND
			      (<AND <RI-CHANNEL .READ-INFO>
				    <CHANNEL-OPEN? <RI-CHANNEL .READ-INFO>>>
			       <CLOSE <RI-CHANNEL .READ-INFO>>)>
			     <COND
			      (<GASSIGNED? INCHANS>
			       <MAPF <>
			         <FUNCTION (X)
			           #DECL ((X) CHANNEL)
				   <COND (<CHANNEL-OPEN? .X>
					  <CLOSE .X>)>>
			         ,INCHANS>)>
			     <CLOSE .OCH>
			     <AND .PMCH <CLOSE .PMCH>>
			     <AND .AMCH <CLOSE .AMCH>>
			     <AND .AACH <CLOSE .AACH>>)>
		      <AND .GC-HANDLER <OFF .GC-HANDLER>>>>>

<DEFINE PRINFILE (CH "AUX" (OUTCHAN ,OUTCHAN))
  #DECL ((CH) CHANNEL)
  <COND
   (,VERBOSE?
    <CRLF .OUTCHAN>
    <PRINT-MANY .OUTCHAN PRINC <COND (<NOT ,GLUE>
				      "Reading file ")
				     (<AND <ASSIGNED? PASS2?> .PASS2?>
				      "Pass 2:  ")
				     (T
				      "Pass 1:  ")>
		<CHANNEL-OP .CH NAME>>)>>

<DEFINE PRINTSTATS ("AUX" (ECPU <FIX <+ <TIME> 0.5>>) (OUTCHAN .OUTCHAN)) 
	#DECL ((STARCPU) FIX (GCTIME) FLOAT)
	<CRLF .OUTCHAN>
	<PRINT-MANY .OUTCHAN PRINC  "Total time Used: " <- .ECPU .STARCPU>
		    " Gc Time Used: " <FIX .GCTIME> "
IO time: " <FIX <+ ,IO-TIME 0.5>>
	   <COND (,GLUE
		  " Total Glue Code Length: ")
		 ("")>
	   <COND (,GLUE
		  <* ,FBYTE-OFFSET 4>)
		 ("")>>
	<CRLF .OUTCHAN>>
	

<SETG ROOT-ATOMS ["M$$BINDID" "M$$INT-LEVEL"]>

<GDECL (ROOT-ATOMS) <VECTOR [REST STRING]>>

<DEFINE SKIP (READ-INFO) 
	#DECL ((N) FIX (READ-INFO) TUPLE)
	<REPEAT EREAD (E)
		<SET E
		     <READ-INTERNAL .READ-INFO '<PROG ()
				      <SETG END-READ T>
				      <RETURN T .EREAD>>>>
		<COND (<AND <TYPE? .E FORM>
			    <FUDGE-MIMOP .E>
			    <==? <1 .E> END!-MIMOP>>
		       <RETURN>)>>>

<SETG IP-BUFSTR <ISTRING 100>>

<GDECL (IP-BUFSTR) STRING>

<DEFINE IPRINC (X OUTCHAN
		"OPTIONAL" (PRINT-TRAIL <>) (TYPE ATOM)
		"AUX" (CNT 1) (STR ,IP-BUFSTR))
	#DECL ((X) STRING (OUTCHAN) <SPECIAL CHANNEL>)
	<COND (<==? .TYPE GVAL>
	       <1 .STR !\,>
	       <SET CNT 2>)
	      (<==? .TYPE LVAL>
	       <1 .STR !\.>
	       <SET CNT 2>)>
	<MAPF <>
	      <FCN (CH)
		   <COND (<==? .CH !\ >
			  <COND (<NOT ,INT-MODE>
				 <PUT .STR .CNT <ASCII 92>>
				 <PUT .STR <+ .CNT 1> !\ >
				 <SET CNT <+ .CNT 2>>)>)
			 (ELSE <PUT .STR .CNT .CH> <SET CNT <+ .CNT 1>>)>>
	      .X>
	<COND (.PRINT-TRAIL
	       <PUT .STR .CNT !\!>
	       <PUT .STR <+ .CNT 1> !\->
	       <SET CNT <+ .CNT 2>>)>
	<SET STR <SUBSTRUC .STR 0 <- .CNT 1> <REST .STR <- 101 .CNT>>>>
	<PRINC .STR>>

<DEFINE COUNT-GCS (IGN TI "TUPLE" X)
	#DECL ((TI GCTIME) FLOAT) 
	<SETG GC-COUNT <+ ,GC-COUNT 1>>
	<AND <ASSIGNED? GCTIME> <SET GCTIME <+ .GCTIME .TI>>>>

<DEFINE DO-FILE-COPY (INCH OUCH AMT "AUX" (BUF <ISTRING 512>))
  #DECL ((INCH OUCH) <CHANNEL 'DISK> (AMT) FIX (BUF) STRING)
  <COND (<==? .AMT -1> <SET AMT <MIN>>)>
  <REPEAT (CT RAMT)
    <COND (<SET CT <CHANNEL-OP .INCH READ-BUFFER .BUF <MIN 512 .AMT>>>
	   <CHANNEL-OP .OUCH WRITE-BUFFER .BUF .CT>
	   <COND (<OR <L? .CT 512>
		      <L=? <SET AMT <- .AMT .CT>> 0>>
		  <RETURN>)>)
	  (<ERROR READ-FAILED <SYS-ERR <CHANNEL-OP .INCH NAME> .CT <>>
		  DO-FILE-COPY>)>>>
\
<SETG CTLZ+1 <+ <SETG CTLZ 26> 1>>

<COND (<==? <PRIMTYPE FIX> FIX>
       <SETG PKG-OBL <CHTYPE PACKAGE OBLIST>>)
      (T
       <SETG PKG-OBL <GETPROP PACKAGE OBLIST>>)>

<DEFINE SETUP-READ-TABLE ("AUX" RT)
  #DECL ((RT) VECTOR)
  <SETG FCN-OBL <MOBLIST FOO>>
  <SETG FCN-OBL-L (,FCN-OBL)>
  <COND (<GASSIGNED? MIMOC-READ-TABLE>
	 <SET RT ,MIMOC-READ-TABLE>)
	(T
	 <SETG MIMOC-READ-TABLE <SET RT <IVECTOR ,CTLZ+1 <>>>>)>
  <PUT .RT ,CTLZ+1 [<ASCII ,CTLZ> ,CTLZ T ,CTLZ-RD <>]>>

<SETG FIRST-PASS-SURVIVOR-GLUE <>>

<DEFINE CTLZ-RD (X "OPT" Y "AUX" (O .OBLIST) (OBLIST ,FCN-OBL-L)) 
	#DECL ((OBLIST) <SPECIAL ANY>)
	<COND (<NOT ,FIRST-PASS-SURVIVOR-GLUE>
	       <SET OBLIST .O>)>
	<COND (<NOT <TYPE? <SET X <READ .X>> ATOM>>
	       <PROG ((OBLIST .O))
		     #DECL ((OBLIST) <SPECIAL ANY>)
		     <ERROR BAD-CTRL-Z-USAGE-BY-MIMC .X>>)
	      (<==? .OBLIST .O> .X)
	      (ELSE
	       <SET X (.X <LIST !.O>)>
	       <COND (<NOT <MEMBER .X ,LIST-OF-FCNS>>
		      <SETG LIST-OF-FCNS (.X !,LIST-OF-FCNS)>)>
	       <1 .X>)>>

<DEFINE FIND-OLD-FCN (NAME INDEX "AUX" (SPN <SPNAME .NAME>))
  #DECL ((NAME) ATOM (INDEX) <LIST [REST LIST]>)
  <MAPF <>
    <FUNCTION (L)
      <COND (<=? .SPN <SPNAME <1 .L>>>
	     <MAPLEAVE .L>)>>
    .INDEX>>

<DEFINE COPY-OLD-FCN (LIST INCH OUCH)
  #DECL ((LIST) <LIST ATOM FIX FIX> (INCH OUCH) <CHANNEL 'DISK>)
  <COND (<NOT <GASSIGNED? COPY-BUF>>
	 <SETG COPY-BUF <ISTRING 1024>>)>
  <ACCESS .INCH <2 .LIST>>
  <CRLF .OUCH>
  <REPEAT ((LEN <- <3 .LIST> <2 .LIST>>) CT)
    #DECL ((LEN CT) FIX)
    <SET CT <CHANNEL-OP .INCH READ-BUFFER ,COPY-BUF <MIN .LEN 1024>>>
    <CHANNEL-OP .OUCH WRITE-BUFFER ,COPY-BUF .CT>
    <COND (<L=? <SET LEN <- .LEN .CT>> 0>
	   <RETURN>)>>
  <CRLF .OUCH>>
