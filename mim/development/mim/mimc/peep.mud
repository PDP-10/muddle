<PACKAGE "PEEP">

<ENTRY PEEP>

<USE "NEWSTRUC" "COMPDEC" "ADVMESS" "CHKDCL" "NPRINT" "LIST-HACKS" "MIMGEN">

'<DEFMAC DEBUG ("ARGS" X) <FORM PROG () !.X>>

<DEFMAC DEBUG ("ARGS" X) T>

<DEFINE PEEP (L) <PEEP-PASS1 .L> <DEBUG <PRINC "Peep pass1 done"> <CRLF>>>

<DEFINE PEEP-PASS1 (L "AUX" LR (EQV ()) LP LLP (OUTCHAN .OUTCHAN) LBP RETS) 
   #DECL ((LBP RETS LP LLP L LR EQV) LIST (OUTCHAN) <SPECIAL CHANNEL>)
   <SETG CHANGED <>>
   <REPEAT (WIN BF)
     #DECL ((WIN) <OR ATOM FALSE> (BF) <OR FALSE LIST>)
     <SET LBP ()>
     <SET RETS ()>
     <SET EQV ()>
     <SET WIN <>>
     <REPEAT ((L .L) IT LN EQVP)
	     #DECL ((LN L) LIST)
	     <COND (<EMPTY? .L> <RETURN>)>
	     <COND (<TYPE? <SET IT <1 .L>> ATOM>
		    <SET EQVP <OR <MEMQ .IT .EQV> <SET EQV (.IT () !.EQV)>>>
		    <SET LN <REST .L>>
		    <SET LBP (.IT .L () !.LBP)>
		    <REPEAT ()
			    <COND (<EMPTY? .LN> <RETURN>)>
			    <COND (<TYPE? <1 .LN> ATOM>
				   <SET WIN T>
				   <DEBUG <PRINC "Successive labels ">
					  <PRIN1 <1 .LN>>
					  <PRINC " ">
					  <PRIN1 .IT>
					  <CRLF>>
				   <PUT .EQVP 2 (<1 .LN> !<2 .EQVP>)>
				   <SET LN <REST .LN>>)
				  (ELSE <RETURN>)>>
		    <PUTREST .L .LN>)
		   (<AND <TYPE? .IT FORM>
			 <NOT <EMPTY? .IT>>
			 <==? <1 .IT> `END>>
		    <RETURN>)>
	     <SET L <REST .L>>>
     <SET LR
      <MAPR ,LIST
       <FUNCTION (LL "AUX" (FRM <1 .LL>) M N I LBL A) 
	  #DECL ((FRM) <OR FORM ATOM> (M) <OR FALSE LIST> (LBL) ATOM
		 (N) <OR FALSE LIST> (I) FORM (LL) LIST)
	  <COND (<TYPE? .FRM ATOM> <SET BF <>> <MAPRET>)
		(<==? <1 .FRM> `END> <MAPSTOP>)
		(<OR <==? <1 .FRM> `OPT-DISPATCH> <==? <1 .FRM> `DISPATCH>>
		 <SET BF <>>
		 <MAPR <>
		       <FUNCTION (F "AUX" LBL P) 
			       #DECL ((F) LIST)
			       <PUT .F 1 <SET LBL <FIND-EQV <1 .F> .EQV>>>
			       <BUILD-LABEL-TABLE .LBL .LBP .LL>>
		       <REST .FRM 3>>
		 <MAPRET !<REST .FRM 3>>)
		(<OR <SET M <MEMQ + .FRM>>
		     <SET M <MEMQ - .FRM>>
		     <AND <==? <1 .FRM> `NTHR>
			  <TYPE? <SET A <NTH .FRM <LENGTH .FRM>>> LIST>
			  <==? <1 .A> `BRANCH-FALSE>
			  <SET BF <SET M <REST .A>>>>>
		 <COND (<SET N <MEMQ <SET LBL <FIND-EQV <2 .M> .EQV>> .L>>
			<PUT .M 2 .LBL>)
		       (<OR <==? .LBL `COMPERR>
			    <==? .LBL `UNWCONT>>
			<SET BF <>> <MAPRET>)
		       (T <COMPILE-LOSSAGE "Bad label: " .LBL .M .L>)>
		 <COND (<==? <1 <SET I <1 <NEXTINS .N>>>> `JUMP>
			<SET BF <>>
			<DEBUG <PRINC "Jump to jump ">
			       <PRIN1 .FRM>
			       <PRINC " ">
			       <PRIN1 .I>
			       <CRLF>>
			<PUT .M 2 <SET LBL
				       <CHTYPE <FIND-EQV <3 .I> .EQV> ATOM>>>
			<SET WIN T>
			<BUILD-LABEL-TABLE .LBL .LBP .LL>
			<MAPRET .LBL>)
		       (<AND <==? <1 .FRM> `JUMP>
			     <MEMQ <1 .I> '[`RETURN `MRETURN `RTUPLE `AGAIN]>>
			<PUT .LL 1 <FORM !.I>>
			<SET WIN T>
			<SET BF <>>
			<DEBUG <PRINC "Jump to RETURNish thing ">
			       <PRIN1 .FRM>
			       <PRINC " ">
			       <PRIN1 .I>
			       <CRLF>>
			<MAPRET>)
		       (<AND <N==? <1 .FRM> `JUMP>
			     <NOT <EMPTY? <SET LP <REST .LL>>>>
			     <NOT <TYPE? <1 .LP> ATOM>>
			     <==? <1 <SET I <1 .LP>>> `JUMP>
			     <NOT <EMPTY? <SET LLP <REST .LP>>>>
			     <TYPE? <1 .LLP> ATOM>
			     <==? <FIND-EQV <1 .LLP> .EQV> .LBL>
			     <NOT .BF>>
			<DEBUG <PRINC "Conditional jump followed by JUMP ">
			       <PRIN1 .FRM>
			       <PRINC " ">
			       <PRIN1 .I>
			       <CRLF>>
			<PUT .M 1 <COND (<==? <1 .M> +> -) (ELSE +)>>
			<PUT .M
			     2
			     <SET LBL <CHTYPE <FIND-EQV <3 .I> .EQV> ATOM>>>
			<PUT .LP 1 <FIND-EQV <1 .LLP> .EQV>>
			<PATCH-LABEL-TABLE .LBP <1 .LP> .LP>
			<PUTREST .LP <REST .LLP>>
			<SET WIN T>
			<BUILD-LABEL-TABLE .LBL .LBP .LL>
			<MAPRET .LBL>)
		       (T
			<COND (<N==? .BF .M> <SET BF <>>)>
			<BUILD-LABEL-TABLE .LBL .LBP .LL>
			<MAPRET .LBL>)>)
		(<==? <1 .FRM> `ICALL>
		 <PUT .FRM 2 <SET LBL <FIND-EQV <2 .FRM> .EQV>>>
		 <SET BF <>>
		 <BUILD-LABEL-TABLE .LBL .LBP .LL>
		 <MAPRET .LBL>)
		(T <SET BF <>> <MAPRET>)>>
       .L>>
     <REPEAT ((L .L) (OL .L) ITM TEM I TF IP TT)
	     #DECL ((L OL) LIST (ITM) ANY)
	     <COND (<EMPTY? .L> <RETURN>)
		   (<AND <TYPE? <1 .L> ATOM> <NOT <MEMQ <1 .L> .LR>>>
		    <PUTREST .OL <REST .L>>
		    <DEBUG <PRINC "Flush extra label  "> <PRIN1 <1 .L>> <CRLF>>
		    <SET WIN T>)
		   (<AND <TYPE? <SET ITM <1 .L>> FORM> <==? <1 .ITM> `END>>
		    <RETURN>)
		   (<AND <TYPE? .ITM FORM>
			 <SET TEM <OR <MEMQ + .ITM> <MEMQ - .ITM>>>
			 <NOT <LENGTH? .L 1>>
			 <==? <2 .L> <2 .TEM>>
			 <N==? <SET TEM <1 .ITM>> `SYSOP>
			 <N==? .TEM `SCALL>>
		    <DEBUG <PRINC "Jump to .+1  "> <PRINC .ITM> <CRLF>>
		    <REMOVE-LABEL .LBP <2 .L> .L>
		    <PUTREST .OL <REST .L>>
		    <SET WIN T>)
		   (<AND <TYPE? .ITM FORM>
			 <==? <1 .ITM> `SET>
			 <NOT <EMPTY? <REST .L>>>
			 <TYPE? <2 .L> FORM>
			 <==? <1 <2 .L>> `RETURN>
			 <==? <2 .ITM> <2 <2 .L>>>>
		    <PUT <2 .L> 2 <3 .ITM>>
		    <PUTREST .OL <REST .L>>
		    <DEBUG <PRINC "SET-RETURN combo"> <PRINC .ITM><CRLF>>)
		   (<AND <TYPE? .ITM FORM>
			 <OR <AND <==? <1 .ITM> `RETURN>
				  <SET RETS (.L !.RETS)>>
			     <MEMQ <1 .ITM>
				   '[`JUMP `RTUPLE `MRETURN `AGAIN]>>
			 <NOT <LENGTH? .L 1>>
			 <NOT <TYPE? <SET ITM <2 .L>> ATOM>>
			 <NOT <AND <TYPE? .ITM FORM>
				   <G=? <LENGTH .ITM> 1>
				   <MEMQ <1 .ITM> '[`END `DEAD `ENDIF]>>>>
		    <DEBUG <PRINC "Unreachable code after  ">
			   <PRIN1 <1 .L>>
			   <PRINC " ">
			   <PRIN1 .ITM>
			   <CRLF>>
		    <PUTREST .L <REST .L 2>>
		    <SET OL .L>
		    <SET WIN T>)
		   (<AND <TYPE? .ITM FORM>
			 <==? <1 .ITM> `CHTYPE>
			 <TYPE? <SET I <2 .L>> FORM>
			 <==? <1 .I> `CHTYPE>
			 <==? <2 .I> <5 .I>>
			 <==? <2 .I> <5 .ITM>>>
		    ;"Look for 2 CHTYPEs of same thing in a row"
		    <DEBUG <PRINC "Two CHTYPEs in a row  ">
			   <PRIN1 .ITM>
			   <PRINC " ">
			   <PRIN1 .I>
			   <CRLF>>
		    <PUT .ITM 3 <3 .I>>
		    <PUTREST .L <REST .L 2>>
		    <SET OL .L>
		    <SET WIN T>)
		   (<AND <TYPE? .ITM FORM>
			 <==? <1 .ITM> `SET>
			 <OR <==? <SET TF <3 .ITM>> <>>
			     <AND <TYPE? .TF FORM>
				  <==? <LENGTH .TF> 2>
				  <==? <1 .TF> QUOTE>
				  <==? <2 .TF> T>>>
			 <TYPE? <SET I <2 .L>> FORM>
			 <==? <1 .I> `JUMP>
			 <TYPE? <SET TEM <2 <SET IP <DEST-INS <3 .I> .LBP>>>>
				FORM>
			 <==? <1 .TEM> `TYPE?>
			 <==? <2 .TEM> <2 .ITM>>
			 <TYPE? <SET TT <3 .TEM>> FORM>
			 <==? <1 .TT> `TYPE-CODE>
			 <OR <==? <2 .TT> ATOM> <==? <2 .TT> FALSE>>>
		     <DEBUG <PRINC "Jump to conditional with known condition" >
			   <PRIN1 .ITM>
			   <PRINC " ">
			   <PRIN1 .I>
			   <PRINC " ">
			   <PRIN1 .TEM>
			   <CRLF>>
		     <COND (<JUMP? .TF <2 .TT> <4 .TEM>>
			    <PUT .L 2 <FORM `JUMP + <5 .TEM>>>)
			   (ELSE
			    <PUT .L 2 <FORM `JUMP +
					    <SET TEM <MAKE-TAG "PEEP">>>>
			    <SET LR (.TEM !.LR)>
			    <PUTREST <REST .IP> (.TEM !<REST .IP 2>)>)>
		     <SET OL .L>
		     <SET WIN T>)
		   (<AND <TYPE? .ITM FORM>
			 <==? <1 .ITM> `SET>
			 <OR <==? <SET TF <3 .ITM>> <>>
			     <AND <TYPE? .TF FORM>
				  <==? <LENGTH .TF> 2>
				  <==? <1 .TF> QUOTE>
				  <==? <2 .TF> T>>>
			 <TYPE? <SET TEM <2 .L>> FORM>
			 <==? <1 .TEM> `TYPE?>
			 <==? <2 .TEM> <2 .ITM>>
			 <TYPE? <SET TT <3 .TEM>> FORM>
			 <==? <1 .TT> `TYPE-CODE>
			 <OR <==? <2 .TT> ATOM> <==? <2 .TT> FALSE>>>
		     <DEBUG <PRINC " Conditional with known condition" >
			   <PRIN1 .ITM>
			   <PRINC " ">
			   <PRIN1 .TEM>
			   <CRLF>>
		     <COND (<JUMP? .TF <2 .TT> <4 .TEM>>
			    <PUT .L 2 <FORM `JUMP + <5 .TEM>>>)
			   (ELSE
			    <PUTREST .L <REST .L 2>>)>
		     <SET OL .L>
		     <SET WIN T>)
		   (<AND <TYPE? .ITM FORM>
			 <SET ITM <MEMQ = .ITM>>
			 <G=? <LENGTH .ITM> 2>
			 <TYPE? <SET ITM <2 .ITM>> FORM>
			 <==? <1 .ITM> QUOTE>
			 <==? <2 .ITM> FLUSHED>>
		    <DEBUG <PRINC "Instruction result being flushed: ">
			   <PRIN1 <1 .L>>
			   <CRLF>>
		    <PUTREST .OL <REST .L>>
		    <SET WIN T>)
		   (T <SET OL .L>)>
	     <SET L <REST .L>>>
     <COND (.WIN <SETG CHANGED T>)
	   (<EQV-CODE .L .LBP .RETS> <SETG CHANGED T>)
	   (ELSE <RETURN>)>>
   ,CHANGED>

<DEFINE DEST-INS (ATM:ATOM LBP:<LIST [REST ATOM LIST LIST]>)
	<REPEAT ()
		<COND (<EMPTY? .LBP> <RETURN <>>)>
		<COND (<==? <1 .LBP> .ATM> <RETURN <2 .LBP>>)>
		<SET LBP <REST .LBP 3>>>>

<DEFINE JUMP? (TF TNAME:ATOM DIR:ATOM)
	<COND (.TF <SET TF ATOM>) (ELSE <SET TF FALSE>)>
	<COND (<==? .TF .TNAME>
	       <==? .DIR +>)
	      (ELSE
	       <==? .DIR ->)>>

<DEFINE EQV-CODE (L LBLS RETS "AUX" (WIN <>) LB OTS OIP)
	#DECL ((OTS OIP L RETS) LIST (LBLS) <LIST [REST ATOM LIST LIST]>)
	<SET L <LREVERSE .L>>
	<REPEAT (RL LAB) #DECL ((RL) <LIST [REST LIST]> (LAB) LAB)
	  <COND (<EMPTY? .LBLS> <RETURN>)>
	  <COND
	   (<NOT <EMPTY? <SET RL <3 .LBLS>>>>
	    <REPEAT ((TST <REST <2 .LBLS>>)) #DECL ((TST) LIST)
	      <COND
	       (<NOT <EMPTY? .TST>>
		<MAPF <>
		      <FUNCTION (INSP "AUX" (INS <1 .INSP>))
			 #DECL ((INSP) <LIST ANY> (INS) <FORM ATOM>)
			 <COND
			  (<==? <1 .INS> `JUMP>
			   <SET INSP <REST .INSP>>
			   <REPEAT ((IP .INSP) (TS .TST) ONE TWO)
			       #DECL ((IP TS) LIST)
			       <COND (<AND <TYPE? <SET ONE <1 .IP>> FORM>
					   <TYPE? <SET TWO <1 .TS>> FORM>
					   <==? <LENGTH .ONE:FORM>
						<LENGTH .TWO:FORM>>
					   <NOT <EMPTY? .ONE:FORM>>
					   <N==? <1 .ONE:FORM> `ENDIF>
					   <MAPF <>
						 <FUNCTION
						      (A B
						       "AUX" (TA <CALL
								  TYPE .A>)
							     (TB <CALL
								  TYPE .B>))
						     <COND (<==? .A .B>)
							   (<N==? .TA .TB>
							    <MAPLEAVE <>>)
							   (<N=? .A .B>
							    <MAPLEAVE <>>)>
						     T>
						 .ONE:FORM
						 .TWO:FORM>>
				      <SET IP <REST <SET OIP .IP>>>
				      <SET TS <REST <SET OTS .TS>>>)
				     (<AND <N==? .TS .TST>
					   <N==? <1 <1 .OIP>> `ENDIF>>
				      <SET WIN T>
				      <PUTREST .OTS
					       (<SET LB <MAKE-TAG "PEEP">>
						!<REST .OTS>)>
				      <PUT .OIP 1 <FORM `JUMP + .LB>>
				      <RETURN>)
				     (ELSE <RETURN>)>>)>>
		      .RL>)>
	      <COND (<AND <==? <1 <1 <SET TST <1 .RL>>>:FORM> `JUMP>
			  <NOT <EMPTY? <SET RL <REST .RL>>>>>
		     <SET TST <REST .TST>>)
		    (ELSE <RETURN>)>>)>
	  <SET LBLS <REST .LBLS 3>>>
	<COND
	 (<AND <NOT <EMPTY? .RETS>> <NOT <EMPTY? <REST .RETS>>>>
	  <MAPR <>
		<FUNCTION (RP "AUX" (RI <1 .RP>) (RRP <REST .RP>))
		  #DECL ((RP) <LIST LIST [REST LIST]>
			 (RI) <LIST FORM [REST <OR ATOM FORM>]>
			 (RRP) <LIST [REST LIST]>)
		  <COND
		   (<NOT <EMPTY? .RRP>>
		    <MAPF <>
			  <FUNCTION (TST "AUX" Y X)
			       #DECL ((TST) <LIST <FORM ANY>
						  [REST <OR ATOM FORM>]>
				      (X Y) <FORM ANY ANY>)
			       <COND
				 (<AND <==? <1 <SET X <1 .RI>>> 
					    <1 <SET Y <1 .TST>>>>
				       <==? <2 .X> <2 .Y>>>
				  <REPEAT ((IP <REST .RI>) (TS <REST .TST>)
					     ONE TWO)
				     #DECL ((IP TS)
					    <LIST [REST <OR ATOM FORM>]>)
				     <COND
				      (<AND <TYPE? <SET ONE <1 .IP>> FORM>
					    <TYPE? <SET TWO <1 .TS>> FORM>
					    <==? <LENGTH .ONE:FORM>
						 <LENGTH .TWO:FORM>>
					    <NOT <EMPTY? .ONE:FORM>>
					    <N==? <1 .ONE:FORM> `ENDIF>
					    <MAPF <>
						  <FUNCTION
						       (A B
							"AUX" (TA <CALL
								   TYPE .A>)
							(TB <CALL
							     TYPE .B>))
						       <COND (<==? .A .B>)
							     (<N==? .TA .TB>
							      <MAPLEAVE <>>)
							     (<N=? .A .B>
							      <MAPLEAVE <>>)>
						       T>
						  .ONE:FORM
						  .TWO:FORM>>
				       <SET IP <REST <SET OIP .IP>>>
				       <SET TS <REST <SET OTS .TS>>>)
				      (<AND <N==? .TS <REST .TST>>
					    <N==? <1 <1 .OIP>> `ENDIF>>
				       <SET WIN T>
				       <PUTREST .OIP
						(<SET LB <MAKE-TAG "PEEP">>
						 !<REST .OIP>)>
				       <PUT .OTS 1 <FORM `JUMP + .LB>>
				       <RETURN>)
				      (ELSE <RETURN>)>>)>>
			  .RRP>)>>
		.RETS>)>
	<SET L <LREVERSE .L>>
	.WIN>

<DEFINE BUILD-LABEL-TABLE (LBL:ATOM LBP:<LIST [REST ATOM LIST LIST]> L:LIST)
	<REPEAT ()
		<COND (<EMPTY? .LBP> <RETURN>)>
		<COND (<==? <1 .LBP> .LBL>
		       <3 .LBP (.L !<3 .LBP>)>
		       <RETURN>)>
		<SET LBP <REST .LBP 3>>>>

<DEFINE PATCH-LABEL-TABLE (LBP:<LIST [REST ATOM LIST LIST]> ATM:ATOM L:LIST)
	<REPEAT ()
		<COND (<EMPTY? .LBP> <RETURN>)>
		<COND (<==? <1 .LBP> .ATM>
		       <2 .LBP .L>
		       <RETURN>)>
		<SET LBP <REST .LBP 3>>>>

<DEFINE REMOVE-LABEL (LBP:<LIST [REST ATOM LIST LIST]> ATM:ATOM L:LIST)
	<REPEAT (A B)
		<COND (<EMPTY? .LBP> <RETURN>)>
		<COND (<==? <1 .LBP> .ATM>
		       <SET B <SET A <3 .LBP>>>
		       <REPEAT ()
			       <COND (<EMPTY? .A> <RETURN>)>
			       <COND (<==? <1 .A> .L>
				      <COND (<==? .A .B>
					     <3 .LBP <REST .A>>)
					    (ELSE
					     <PUTREST .B <REST .A>>)>
				      <RETURN>)>
			       <SET B .A>
			       <SET A <REST .A>>>
		       <RETURN>)>
		<SET LBP <REST .LBP 3>>>>

<DEFINE NEXTINS (L) 
	#DECL ((L VALUE) LIST)
	<MAPR <>
	      <FUNCTION (LL "AUX" (ITM <1 .LL>)) 
		      #DECL ((ITM) <OR ATOM FORM> (LL) <LIST <OR ATOM FORM>>)
		      <COND (<TYPE? .ITM FORM> <MAPLEAVE .LL>)>>
	      <REST .L>>>

<DEFINE FIND-EQV (ATM EQVL) 
	#DECL ((VALUE ATM) ATOM (EQVL) <LIST [REST ATOM <LIST [REST ATOM]>]>)
	<COND (<OR <==? .ATM `COMPERR> <==? .ATM `UNWCONT>> .ATM)
	      (ELSE
	       <REPEAT ()
		       <COND (<MEMQ .ATM <2 .EQVL>> <RETURN <1 .EQVL>>)>
		       <COND (<EMPTY? <SET EQVL <REST .EQVL 2>>>
			      <RETURN .ATM>)>>)>>

<ENDPACKAGE>
