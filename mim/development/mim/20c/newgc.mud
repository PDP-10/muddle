<COND (<NOT <GASSIGNED? WIDTH-MUNG>> <FLOAD "MIMOC20DEFS.MUD">)>

<SETG NUM-TEMPS 4>

<SETG NUM-L-TEMPS 2>

<SETG MARK-BIT 65536>

<SETG FLEN 7>

<SETG LIST-LEN 3>

<SETG ATOM-LEN 5>

<SETG GBIND-LEN 5>

<SETG LBIND-LEN 8>

<MANIFEST NUM-TEMPS NUM-L-TEMPS MARK-BIT FLEN LIST-LEN ATOM-LEN GBIND-LEN
	  LBIND-LEN>

<DEFINE CGC-RECORD!-MIMOC (L
			   "AUX" (VAR <1 .L>) (ALLOC-ATOM <2 .L>)
				 (END-ATOM <3 .L>) (NEXT-ATOM <4 .L>)
				 (BOUNDS-ATOM <5 .L>) (RES <7 .L>) RLEN STK?
				 ALLOCADDR ENDADDR (BOUNDS-LAB <GENLBL "B">)
				 (IB-LAB <GENLBL "I">) (F-LAB <GENLBL "F">)
				 (EXIT-LAB <GENLBL "E">) (M-LAB <GENLBL "M">)
				 (F1 <GENLBL "?FRM">) (B1 <GENLBL "?FRM">)
				 (HINT <EXTRAMEM RECORD-TYPE .L>))
	#DECL ((END-ATOM ALLOC-ATOM BOUND-ATOM NEXT-ATOM) !<FORM ATOM ATOM>
	       (HINT) <PRIMTYPE LIST> (RLEN) FIX (L) LIST)
	<FLUSH-ACS>
	<SET ENDADDR <OBJ-VAL <CHTYPE <2 .END-ATOM> XGLOC>>>
	<SET ALLOCADDR <OBJ-VAL <CHTYPE <2 .ALLOC-ATOM> XGLOC>>>
	<COND (<AND .HINT <==? <1 .HINT> RECORD-TYPE>> <SET HINT <2 .HINT>>)>
	<COND (<==? .HINT ATOM> <SET RLEN ,ATOM-LEN> <SET STK? <>>)
	      (<==? .HINT GBIND> <SET RLEN ,GBIND-LEN> <SET STK? <>>)
	      (<==? .HINT LBIND> <SET RLEN ,LBIND-LEN> <SET STK? T>)
	      (T <ERROR BAD-HINT-FOR-CGC-RECORD!-ERRORS .HINT CGC-RECORD-GEN>)>
	<COND (.STK?
	       <OCEMIT CAMG TP* !<OBJ-VAL .VAR>>
					     ;"See if this guy is on the stack"
	       <OCEMIT JRST <XJUMP .BOUNDS-LAB>>
	       <OCEMIT MOVSI A1* <TYPE-CODE FALSE>>
	       <OCEMIT MOVEI A2* 0>
	       <OCEMIT JRST <XJUMP .EXIT-LAB>>
	       <LABEL .BOUNDS-LAB>
	       <FRAME!-MIMOC (.B1 <2 .BOUNDS-ATOM>)>
	       <OCEMIT PUSH TP* !<OBJ-TYP .VAR>>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT PUSH TP* !<OBJ-VAL .VAR>>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <CALL!-MIMOC (.BOUNDS-ATOM 1 .B1)>
	       <OCEMIT JUMPN A2* <XJUMP .IB-LAB>>
	       <OCEMIT MOVSI A1* <TYPE-CODE FIX>>
	       <OCEMIT MOVE A2* !<OBJ-VAL .VAR>>
	       <OCEMIT JRST <XJUMP .EXIT-LAB>>
	       <LABEL .IB-LAB>)>
	<OCEMIT MOVE O1* !<OBJ-VAL .VAR>>
	<OCEMIT MOVE O* .RLEN '(O1*)>
	<OCEMIT TLON O* ,MARK-BIT>
	<OCEMIT JRST <XJUMP .M-LAB>>
	<OCEMIT MOVE A1* !<OBJ-TYP .VAR>>
	<OCEMIT MOVE A2* <+ .RLEN 1> '(O1*)>
	<OCEMIT JRST <XJUMP .EXIT-LAB>>		      ;"Jump if already marked"
	<LABEL .M-LAB>
	<OCEMIT MOVEM O* .RLEN '(O1*)>
	<OCEMIT DMOVE B1* @ !.ALLOCADDR>
	<OCEMIT MOVE O2* B2*>
	<OCEMIT ADDI O2* <+ .RLEN 2>>
	<OCEMIT DMOVE C1* @ !.ENDADDR>
	<OCEMIT CAMG O2* C2*>
	<OCEMIT JRST <XJUMP .F-LAB>>
	<FRAME!-MIMOC (.F1 <2 .NEXT-ATOM>)>
	<OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	<OCEMIT PUSH TP* !<OBJ-VAL <+ .RLEN 2>>>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	<CALL!-MIMOC (.NEXT-ATOM 1 .F1)>
	<OCEMIT MOVE O1* !<OBJ-VAL .VAR>>
	<OCEMIT DMOVE B1* @ !.ALLOCADDR>
	<OCEMIT MOVE O2* B2*>
	<OCEMIT ADDI O2* <+ .RLEN 2>>
	<LABEL .F-LAB>
	<OCEMIT MOVEM B2* <+ .RLEN 1> '(O1*)>
	<OCEMIT MOVE T* !.ALLOCADDR>
	<OCEMIT MOVEM O2* 1 '(T*)>
	<OCEMIT DMOVE C1* .RLEN '(O1*)>
	<OCEMIT TLZ C1* ,MARK-BIT>
	<OCEMIT DMOVEM C1* .RLEN '(B2*)>
	<OCEMIT MOVE A2* B2*>
	<OCEMIT MOVSI A1* <TYPE-CODE FIX>>
	<LABEL .EXIT-LAB>
	<COND (<==? .RES STACK>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	       <OCEMIT PUSH TP* A1*>
	       <OCEMIT PUSH TP* A2*>)
	      (ELSE <LOAD-AC .RES BOTH T T <GET-AC A1*>>)>>

<DEFINE CGC-BYTES!-MIMOC (L "AUX" (VAR <1 .L>) (ALLOC-ATOM <2 .L>)
				  (END-ATOM <3 .L>) (NEXT-ATOM <4 .L>)
				  (RES <6 .L>))
	#DECL ((L) LIST)
	<FLUSH-ACS>
	<OCEMIT DMOVE A1* !<OBJ-TYP .VAR>>
	<OCEMIT ANDI A1* *777777*>
	<OCEMIT IBP A1* A2*>			;"Byte pointer to dope words."
	<OCEMIT TLZ A1* *770000*>		;"A1* points one before dopeword."
	<OCEMIT SUB A2* A1*>			;"A2* added to new dw pntr wins"
	<CGC-UV-ST .VAR .ALLOC-ATOM .END-ATOM .NEXT-ATOM .RES>>

<SETG CGC-STRING!-MIMOC ,CGC-BYTES!-MIMOC>

<DEFINE CGC-UVECTOR!-MIMOC (L "AUX" (VAR <1 .L>) (ALLOC-ATOM <2 .L>)
				    (END-ATOM <3 .L>) (NEXT-ATOM <4 .L>)
				    (RES <6 .L>))
	#DECL ((L) LIST)
	<OCEMIT DMOVE A1* !<OBJ-TYP .VAR>>
	<OCEMIT HRREI A1* -1 '(A1*)> 
	<OCEMIT ADD A1* A2*>
	<OCEMIT SUB A2* A1*>
	<CGC-UV-ST .VAR .ALLOC-ATOM .END-ATOM .NEXT-ATOM .RES>>

; "Call this guy with A1* pointing to dope word and A2* being what is added to new
   dw pointer to win.  All ACs are available"

<DEFINE CGC-UV-ST (VAR ALLOC-ATOM END-ATOM NEXT-ATOM RES
		   "AUX" ENDADDR ALLOCADDR (M-LAB <GENLBL "M">)
			 (F-LAB <GENLBL "F">) (F1 <GENLBL "?FRM">))
	#DECL ((VAR RES) ATOM (NEXT-ATOM ALLOC-ATOM END-ATOM) !<FORM ATOM ATOM>)
	<SET ENDADDR <OBJ-VAL <CHTYPE <2 .END-ATOM> XGLOC>>>
	<SET ALLOCADDR <OBJ-VAL <CHTYPE <2 .ALLOC-ATOM> XGLOC>>>
				 ;"Pointers to GVAL slots for AL and END-SPACE"
	<OCEMIT MOVE O1* 1 '(A1*)>
	<OCEMIT TLOE O1* ,MARK-BIT>		      ;"Check and set mark bit"
	<OCEMIT JRST <XJUMP .M-LAB>>			      ;"Jump if marked"
	<OCEMIT MOVEM O1* 1 '(A1*)>		    ;"Store back with mark bit"
	<OCEMIT MOVEI O* 2 '(O1*)>	     ;"Add 2 to length for total words"
	<OCEMIT MOVE O2* !.ALLOCADDR>			 ;"Point to ALLOC slot"
	<OCEMIT ADD O* 1 '(O2*)>			  ;"Possible new ALLOC"
	<OCEMIT MOVE T* !.ENDADDR>		        ;"Now compare with end"
	<OCEMIT CAMG O* 1 '(T*)>
	<OCEMIT JRST <XJUMP .F-LAB>>			    ;"Jump if will fit"
	<OCEMIT SUB O* 1 '(O2*)>		    ;"Make O* be # words again"
	<OCEMIT PUSH TP* O*>				   ;"Save useful stuff"
	<OCEMIT PUSH TP* A1*>
	<OCEMIT PUSH TP* A2*>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 3>>)>
	<FRAME!-MIMOC (.F1 <2 .NEXT-ATOM>)>
	<OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	<OCEMIT PUSH TP* O*>		      ;"Pass space needed to NEXT-ATOM"
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	<CALL!-MIMOC (.NEXT-ATOM 1 .F1)>
	<OCEMIT MOVE O2* !.ALLOCADDR>			       ;"Restore stuff"
	<OCEMIT MOVE O* -2 '(TP*)>
	<OCEMIT MOVE A1* -1 '(TP*)>
	<OCEMIT MOVE A2* '(TP*)>
	<OCEMIT ADD O* 1 '(O2*)>			     ;"O* is new ALLOC"
	<OCEMIT SUBI TP* 3>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <- ,STACK-DEPTH 3>>)>
	<LABEL .F-LAB>
	<OCEMIT MOVEM O* 1 '(O2*)>			     ;"Store new ALLOC"
	<OCEMIT SUBI O* 2>			      ;"Now point to first dw."
	<OCEMIT MOVEM O* 2 '(A1*)>			    ;"Store relocation"
	<OCEMIT MOVE C1* O*>				       ;"Copy for XBLT"
	<OCEMIT HRRZ B1* 1 '(A1*)>
	<OCEMIT XMOVEI B2* 1 '(A1*)>
	<OCEMIT MOVE O* 1 '(A1*)>
	<OCEMIT TLZ O* ,MARK-BIT>
	<OCEMIT MOVEM O* '(C1*)>
	<OCEMIT MOVNS O* B1*>
	<OCEMIT XBLT B1* !<OBJ-VAL 2147483648>>
	<LABEL .M-LAB>
	<OCEMIT ADD A2* 2 '(A1*)>
	<OCEMIT SUBI A2* 1>
	<COND (<==? .RES STACK>
	       <OCEMIT PUSH TP* !<OBJ-TYP .VAR>>
	       <OCEMIT PUSH TP* A2*>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (ELSE
	       <OCEMIT MOVE A1* !<OBJ-TYP .VAR>>
	       <LOAD-AC .RES BOTH T T <GET-AC A1*>>)>>

<DEFINE CGC-VECTOR!-MIMOC (L
			   "AUX" (VAR <1 .L>) (ALLOC-ATOM <2 .L>)
				 (END-ATOM <3 .L>) (NEXT-ATOM <4 .L>)
				 (MARK-ATOM <5 .L>) (RES <7 .L>) ENDADDR
				 ALLOCADDR (NF-LAB <GENLBL "NF">)
				 (F-LAB <GENLBL "F">) (F1 <GENLBL "?FRM">)
				 (LOOP-LAB <GENLBL "LOOP">)
				 (NM-LAB <GENLBL "NM">) (F2 <GENLBL "?FRM">)
				 (DONE-LAB <GENLBL "DONE">)
				 (M-LAB <GENLBL "M">))
	#DECL ((END-ATOM ALLOC-ATOM NEXT-ATOM MARK-ATOM) !<FORM ATOM ATOM>
	       (L) LIST)
	<SET ENDADDR <OBJ-VAL <CHTYPE <2 .END-ATOM> XGLOC>>>
	<SET ALLOCADDR <OBJ-VAL <CHTYPE <2 .ALLOC-ATOM> XGLOC>>>
				 ;"Pointers to GVAL slots for AL and END-SPACE"
	<FLUSH-ACS>
	<OCEMIT HRRZ A1* !<OBJ-TYP .VAR>>
	<OCEMIT ASH A1* 1>				  ;"To number of words"
	<OCEMIT MOVE A2* A1*>
	<OCEMIT ADD A2* !<OBJ-VAL .VAR>>	   ;"A1* is #words, A2* 1st dw"
	<OCEMIT MOVE O1* '(A2*)>			       ;"Check marking"
	<OCEMIT SUBI A1* '(O1*)>
	<OCEMIT TLOE O1* ,MARK-BIT>
	<OCEMIT JRST <XJUMP .M-LAB>>
	<OCEMIT ADDI TP* ,NUM-TEMPS>			      ;"Allocate temps"
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH ,NUM-TEMPS>>)>
	<OCEMIT MOVEM O1* '(A2*)>				 ;"Mark bit on"
	<OCEMIT MOVEI O2* 2 '(O1*)>		       ;"O2 total size with dw"
	<OCEMIT MOVE T* !.ALLOCADDR>			   ;"Compute new ALLOC"
	<OCEMIT ADD O2* 1 '(T*)>
	<OCEMIT MOVE B1* !.ENDADDR>
	<OCEMIT HRRZM O1* '(TP*)>
	<OCEMIT MOVEM A2* -1 '(TP*)>
	<OCEMIT MOVEM A1* -2 '(TP*)>
	<OCEMIT CAMG O2* 1 '(B1*)>			   ;"Skip if area full"
	<OCEMIT JRST <XJUMP .F-LAB>>
	<FRAME!-MIMOC (.F1 <2 .NEXT-ATOM>)>
	<OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	<OCEMIT MOVEI O1* 2 '(O1*)>
	<OCEMIT PUSH TP* O1*>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	<CALL!-MIMOC (.NEXT-ATOM 1 .F1)>	;"Call to use next AREA"
	<OCEMIT MOVE T* !.ALLOCADDR>
	<OCEMIT MOVE O2* '(TP*)>
	<OCEMIT ADDI O2* 2>
	<OCEMIT ADD O2* 1 '(T*)>
	<OCEMIT MOVE A2* -1 '(TP*)>
	<LABEL .F-LAB>
	<OCEMIT MOVEM O2* 1 '(T*)>			     ;"Store new ALLOC"
	<OCEMIT XMOVEI O1* -2 '(O2*)>			        ;"Fudge for dw"
	<OCEMIT MOVEM O1* 1 '(A2*)>			       ;"Store new loc"
	<OCEMIT MOVE O* '(A2*)>
	<OCEMIT TLZ O* ,MARK-BIT>
	<OCEMIT MOVEM O* '(O1*)>		       ;"Store new dw not marked"
	<OCEMIT MOVE O2* '(TP*)>
	<OCEMIT SUB A2* O2*>
	<OCEMIT MOVEM A2* -1 '(TP*)>
	<OCEMIT SUB O1* O2*>
	<OCEMIT MOVEM O1* -3 '(TP*)>
	<OCEMIT ASH O2* -1>				  ;"Number of elements"
	<OCEMIT MOVEM O2* '(TP*)>
	<LABEL .LOOP-LAB>
	<OCEMIT SOSGE '(TP*)>
	<OCEMIT JRST <XJUMP .DONE-LAB>>
	<OCEMIT DMOVE A1* @ -1 '(TP*)>
	<OCEMIT HLRZ O* A1*>
	<OCEMIT ANDI O* 7>
	<OCEMIT JUMPE O* <XJUMP .NM-LAB>>
	<FRAME!-MIMOC (.F2 <2 .MARK-ATOM>)>
	<OCEMIT PUSH TP* A1*>
	<OCEMIT PUSH TP* A2*>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	<CALL!-MIMOC (.MARK-ATOM 1 .F2)>
	<LABEL .NM-LAB>
	<OCEMIT DMOVEM A1* @ -3 '(TP*)>
	<OCEMIT MOVEI O* 2>
	<OCEMIT ADDM O* -1 '(TP*)>
	<OCEMIT ADDM O* -3 '(TP*)>
	<OCEMIT JRST <XJUMP .LOOP-LAB>>
	<LABEL .DONE-LAB>
	<OCEMIT MOVE A2* -1 '(TP*)>
	<OCEMIT MOVE A1* -2 '(TP*)>
	<OCEMIT SUBI TP* ,NUM-TEMPS>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <- ,STACK-DEPTH ,NUM-TEMPS>>)>
	<LABEL .M-LAB>
	<OCEMIT MOVE A2* 1 '(A2*)>
	<OCEMIT HRRZ O1* '(A2*)>
	<OCEMIT ADD O1* A1*>
	<OCEMIT SUB A2* O1*>
	<COND (<==? .RES STACK>
	       <OCEMIT PUSH TP* !<OBJ-TYP .VAR>>
	       <OCEMIT PUSH TP* A2*>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (ELSE
	       <OCEMIT MOVE A1* !<OBJ-TYP .VAR>>
	       <LOAD-AC .RES BOTH T T <GET-AC A1*>>)>>

<DEFINE CGC-LIST!-MIMOC (L
			 "AUX" (VAR <1 .L>) (ALLOC-ATOM <2 .L>)
			       (END-ATOM <3 .L>) (NEXT-ATOM <4 .L>)
			       (BOUNDS-ATOM <5 .L>) (MARK-ATOM <6 .L>)
			       (LN <LENGTH .L>) (RES <NTH .L .LN>) ENDADDR
			       ALLOCADDR (M-LAB <GENLBL "M">)
			       (DONE-LAB <GENLBL "D">)
			       (LOOP-LAB <GENLBL "LOOP">) (F-LAB <GENLBL "F">)
			       (NB-LAB <GENLBL "NB">) (MC-LAB <GENLBL "MC">)
			       (F1 <GENLBL "?FRM">) (F2 <GENLBL "?FRM">)
			       (F3 <GENLBL "?FRM">) (UNDO-ABLE <>))
	#DECL ((LN) FIX (L) LIST
	       (BOUNDS-ATOM MARK-ATOM NEXT-ATOM ALLOC-ATOM END-ATOM)
	       !<FORM ATOM ATOM>)
	<COND (<AND <==? .LN 9> <7 .L>> <SET UNDO-ABLE T>)>
		;"UNDO-ABLE being true means old cdr clobbers new type word
		  so its not lost if the world has to be undone"
	<SET ENDADDR <OBJ-VAL <CHTYPE <2 .END-ATOM> XGLOC>>>
	<SET ALLOCADDR <OBJ-VAL <CHTYPE <2 .ALLOC-ATOM> XGLOC>>>
				 ;"Pointers to GVAL slots for AL and END-SPACE"
	<FLUSH-ACS>
	<OCEMIT ADDI TP* ,NUM-L-TEMPS>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH ,NUM-L-TEMPS>>)>
	<OCEMIT MOVE B1* !<OBJ-VAL .VAR>>
	<OCEMIT SETZM '(TP*)>
	<LABEL .LOOP-LAB>
	<OCEMIT DMOVE A1* 1 '(B1*)>
	<OCEMIT TLOE A1* ,MARK-BIT>
	<OCEMIT JRST <XJUMP .M-LAB>>
	<OCEMIT MOVEM A1* 1 '(B1*)>	 ;"Mark bit set, need to hack this up."
	<OCEMIT DMOVE O1* @ !.ALLOCADDR>
	<OCEMIT MOVE C2* O2*>
	<OCEMIT ADDI O2* ,LIST-LEN>
	<OCEMIT MOVE T* !.ENDADDR>
	<OCEMIT CAMG O2* 1 '(T*)>
	<OCEMIT JRST <XJUMP .F-LAB>>
	<OCEMIT MOVEM B1* -1 '(TP*)>
	<FRAME!-MIMOC (.F1 <2 .NEXT-ATOM>)>
	<OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	<OCEMIT PUSH TP* !<OBJ-VAL ,LIST-LEN>>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	<CALL!-MIMOC (.NEXT-ATOM 1 .F1)>
	<OCEMIT DMOVE O1* @ !.ALLOCADDR>
	<OCEMIT MOVE C2* O2*>
	<OCEMIT ADDI O2* ,LIST-LEN>
	<OCEMIT MOVE B1* -1 '(TP*)>
	<OCEMIT DMOVE A1* 1 '(B1*)>
	<LABEL .F-LAB>
	<OCEMIT DMOVEM O1* @ !.ALLOCADDR>
	<OCEMIT SKIPE O1* '(TP*)>	    ;"Pick up pointer to previous cell"
	<OCEMIT MOVEM C2* '(O1*)>	 ;"Fix up cdr pointer in previous cell"
	<OCEMIT MOVEM C2* '(TP*)>		   ;"New previous cell pointer"
	<OCEMIT MOVE C1* '(B1*)>			 ;"Pick up cdr pointer"
	<OCEMIT MOVEM C2* '(B1*)>		     ;"Relocation for old cell"
	<OCEMIT MOVEM C1* '(C2*)>
			 ;"Make sure new cell doesn't have garbage in cdr slot"
	<OCEMIT TLZ A1* ,MARK-BIT>		       ;"Clear mark bit in CAR"
	<OCEMIT HLRZ O* A1*>
	<OCEMIT ANDI O* 7>		     ;"See if car's type needs marking"
	<OCEMIT MOVEM C1* -1 '(TP*)>		        ;"Save old cdr pointer"
	<OCEMIT JUMPE O* <XJUMP .MC-LAB>>
	<FRAME!-MIMOC (.F2 <2 .MARK-ATOM>)>
	<OCEMIT PUSH TP* A1*>
	<OCEMIT PUSH TP* A2*>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	<CALL!-MIMOC (.MARK-ATOM 1 .F2)>		    ;"Mark the guy"
	<OCEMIT MOVE C1* -1 '(TP*)>
	<LABEL .MC-LAB>
	<OCEMIT MOVE O1* '(TP*)>
	<COND (.UNDO-ABLE
	       <OCEMIT MOVEM C1* 1 '(O1*)>	;"Save old CDR...KLUDGE"
	       <OCEMIT MOVEM A2* 2 '(O1*)>)
	      (ELSE <OCEMIT DMOVEM A1* 1 '(O1*)>)>
	<OCEMIT JUMPE C1* <XJUMP .DONE-LAB>>	       ;"All done if empty cdr"
	<FRAME!-MIMOC (.F3 <2 .BOUNDS-ATOM>)>
	<OCEMIT PUSH TP* !<TYPE-WORD LIST>>
	<OCEMIT PUSH TP* C1*>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	<CALL!-MIMOC (.BOUNDS-ATOM 1 .F3)>;"Check bounds of list cdr"
	<OCEMIT MOVE B1* -1 '(TP*)>
	<OCEMIT JUMPN A2* <XJUMP .LOOP-LAB>>	      ;"Loop back if in bounds"
	<OCEMIT JRST <XJUMP .DONE-LAB>>
	<LABEL .M-LAB>
	<OCEMIT SKIPN C1* '(TP*)>	        ;"Pick up pointer to last cell"
	<OCEMIT JRST <XJUMP .DONE-LAB>>	       ;"None, just clean up and leave"
	<OCEMIT MOVE O* '(B1*)>				  ;"Clean up last cell"
	<OCEMIT MOVEM O* '(C1*)>
	<LABEL .DONE-LAB>
	<OCEMIT SUBI TP* ,NUM-L-TEMPS>
	<COND (,WINNING-VICTIM
	       <SETG STACK-DEPTH <- ,STACK-DEPTH ,NUM-L-TEMPS>>)>
	<OCEMIT DMOVE A1* !<OBJ-TYP .VAR>>
	<OCEMIT MOVE A2* '(A2*)>
	<COND (<==? .RES STACK>
	       <OCEMIT PUSH TP* A1*>
	       <OCEMIT PUSH TP* A2*>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (ELSE <LOAD-AC .RES BOTH T T <GET-AC A1*>>)>>
