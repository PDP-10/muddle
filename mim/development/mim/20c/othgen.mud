
<COND (<NOT <GASSIGNED? WIDTH-MUNG>> <FLOAD "MIMOC20DEFS.MUD">)>

<NEWTYPE XTYPE-W ATOM>

<NEWTYPE LOCAL-NAME FIX>

<NEWTYPE LOCAL VECTOR>

<NEWTYPE XGLOC ATOM>

<SETG PRIM-FIX 0>

<SETG PRIM-LIST 1>

<MANIFEST PRIM-LIST PRIM-FIX>

;"LIST manipulation"

<DEFINE TYPE!-MIMOC (L "AUX" (ARG <1 .L>) AC NAC)
	#DECL ((L) LIST (ARG) ANY (AC) ATOM (NAC) <OR FALSE ATOM>)
	<COND (<==? <3 .L> STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <LOAD-TYPE O* <OBJ-TYP .ARG>>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	       <MUNGED-AC O*>)
	      (T
	       <SET AC <ASSIGN-AC <3 .L> BOTH>>
	       <AC-TYPE <GET-AC .AC> FIX>
	       <LOAD-TYPE <NEXT-AC .AC> <OBJ-TYP .ARG>>)>>  

<DEFINE TYPE?!-MIMOC (L
		      "AUX" (ARG <1 .L>) (TYP <2 .L>) (CAM CAMN) (CAI CAIN)
			    (JMP JUMPE) AC)
	#DECL ((L) LIST (ARG) ANY (TYP) <OR ATOM FIX XTYPE-C>
	       (CAM CAI JMP) ATOM (AC) <OR FALSE ATOM>)
	<COND (<==? <3 .L> -> <SET CAM CAME> <SET CAI CAIE> <SET JMP JUMPN>)>
	<COND (<SET AC <IN-AC? .ARG TYPE>> <LOAD-TYPE O* (.AC)> <MUNGED-AC O*>)
	      (T <SET AC <SMASH-AC O* .ARG TYPECODE>>)>
	<LABEL-UPDATE-ACS <4 .L> <>>
	<COND (,GC-MODE <OCEMIT TRZ O* 56>)>
	<COND (<TYPE? .TYP FIX>
	       <COND (<==? .TYP 0> <OCEMIT .JMP O* <XJUMP <4 .L>>>)
		     (ELSE <OCEMIT .CAI O* .TYP>)>)
	      (T <OCEMIT .CAM O* !<OBJ-VAL .TYP>>)>
	<COND (<N==? .TYP 0> <OCEMIT JRST <XJUMP <4 .L>>>)>>

<DEFINE CHTYPE!-MIMOC (L
		       "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <4 .L>) AC PCOD
			     TYFRM VTYP ACT
			     (LV
			      <OR <LMEMQ .VAL ,LOCALS>
				  <AND ,ICALL-FLAG
				       <LMEMQ .VAL ,ICALL-TEMPS>>>))
   #DECL ((L) LIST (AC VAL) ATOM (ARG1 ARG2) ANY
	  (TYFRM) <OR FALSE <FORM ATOM ATOM>>)
   <COND
    (<AND .LV
	  <MEMQ .LV ,TYPED-LOCALS>
	  <SET VTYP <LDECL .LV>>
	  <OR <MEMQ <TYPEPRIM .VTYP> '[WORD FIX LIST]>
	      <MEMQ .VTYP ,TYPE-LENGTHS>>>
     <SET AC <LOAD-AC .ARG1 BOTH>>
     <COND (<AND <N==? .VAL .ARG1> <NOT <WILL-DIE? .ARG1>>>
	    <COND (<AC-UPDATE <GET-AC .AC>>
		   <UPDATE-AC <GET-AC .AC>>
		   <UPDATE-AC <GET-AC <NEXT-AC .AC>>>)>)>
     <CLEAN-ACS .VAL>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC <NEXT-AC .AC>> T> .VAL> VALUE>
     <AC-TYPE <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .AC> T> .VAL> TYPE> .VTYP>)
    (<TYPE? .ARG2 FIX>
     <COND (<AND <SET TYFRM <GETPROP <REST .L> EVAL>>
		 <OR <==? <SET PCOD <CHTYPE <ANDB .ARG2 7> FIX>> ,PRIM-FIX>
		     <==? .PCOD ,PRIM-LIST>
		     <MEMQ <2 .TYFRM> ,TYPE-LENGTHS>>>
	    <COND (<==? .VAL STACK>
		   <OCEMIT PUSH TP* !<TYPE-WORD <2 .TYFRM>>>
		   <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
		   <OCEMIT PUSH TP* !<OBJ-VAL .ARG1>>
		   <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
		  (ELSE
		   <SET AC <LOAD-AC .ARG1 BOTH>>
		   <COND (<WILL-DIE? .ARG1>
			  <AC-UPDATE <GET-AC .AC> <>>
			  <AC-UPDATE <GET-AC <NEXT-AC .AC>> <>>
			  <AC-TYPE <GET-AC .AC> <>>)>
		   <COND (<N==? .ARG1 .VAL> <CLEAN-ACS .VAL> <ALTER-AC .AC .VAL>)>
		   <AC-TYPE <GET-AC .AC> <2 .TYFRM>>
		   <AC-UPDATE <GET-AC .AC> T>)>)
	   (ELSE
	    <SET AC <LOAD-AC .ARG1 BOTH>>
	    <COND (<WILL-DIE? .ARG1>
		   <AC-UPDATE <GET-AC .AC> <>>
		   <AC-UPDATE <GET-AC <NEXT-AC .AC>> <>>
		   <AC-TYPE <GET-AC .AC> <>>)>
	    <COND (<N==? .ARG1 .VAL> <CLEAN-ACS .VAL> <ALTER-AC .AC .VAL>)>
	    <AC-TYPE <GET-AC .AC> <>>
	    <OCEMIT HRLI .AC .ARG2>
	    <AC-UPDATE <GET-AC .AC> T>
	    <COND (<==? .VAL STACK>
		   <OCEMIT PUSH TP* .AC>
		   <OCEMIT PUSH TP* <NEXT-AC .AC>>
		   <COND (,WINNING-VICTIM
			  <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>)
    (ELSE
     <SET AC <LOAD-AC .ARG1 BOTH>>
     <SET ACT <AC-TYPE <GET-AC .AC>>>
     <COND (<N==? .ARG1 .VAL>
	    <COND (<WILL-DIE? .ARG1>
		   <AC-UPDATE <GET-AC .AC> <>>
		   <AC-UPDATE <GET-AC <NEXT-AC .AC>> <>>)>
	    <FLUSH-AC .AC T>
	    <MUNGED-AC .AC T>)>
     <AC-TYPE <GET-AC .AC> <>>
     <COND (<AND <TYPE? .ARG2 FORM>
		 <==? <LENGTH .ARG2> 2>
		 <==? <1 .ARG2> TYPE>
		 <TYPE? <2 .ARG2> ATOM>>
	    <COND (<AND .ACT
			<MEMQ .ACT ,TYPE-LENGTHS>>
		   <LOAD-TYPE-IN-AC .AC .ACT>)>
	    <OCEMIT HLL .AC !<OBJ-TYP <2 .ARG2>>>)
	   (.ACT
	    <COND (<MEMQ .ACT ,TYPE-LENGTHS>
		   <OCEMIT MOVE .AC !<OBJ-VAL <CHTYPE .ARG2 XTYPE-W>>>)
		  (ELSE <OCEMIT HRLZ .AC !<OBJ-VAL .ARG2>>)>)
	   (ELSE <OCEMIT HRL .AC !<OBJ-VAL .ARG2>>)>
     <COND (<AND <N==? .VAL STACK> <N==? .VAL .ARG1>>
	    <CLEAN-ACS .VAL>
	    <ALTER-AC .AC .VAL>)>
     <AC-UPDATE <GET-AC .AC> T>
     <COND (<==? .VAL STACK>
	    <OCEMIT PUSH TP* .AC>
	    <OCEMIT PUSH TP* <NEXT-AC .AC>>
	    <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>>

<DEFINE NEWTYPE!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ NEWTYPE <3 .L>>>
	           

;"Randomness"

<DEFINE VALUE!-MIMOC (L "AUX" (IT <1 .L>) (VAL <3 .L>) AC)
	#DECL ((L) LIST (VAL) ATOM)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <OCEMIT PUSH TP* !<OBJ-VAL .IT>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (<AND <OR <==? .IT .VAL> <WILL-DIE? .IT>>
		    <OR <SET AC <IN-AC? .IT BOTH>>
			<AND <SET AC <IN-AC? .IT VALUE>>
			     <SET AC <GETPROP .AC AC-PAIR>>>>>
	       <COND (<N==? .IT .VAL> <CLEAN-ACS .VAL>)> 
	       <ALTER-AC .AC .VAL>
	       <AC-TYPE <GET-AC .AC> FIX>)
	      (T
	       <SET AC <ASSIGN-AC .VAL BOTH>>
	       <AC-TYPE <GET-AC .AC> FIX>
	       <OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL <1 .L>>>)>>

<DEFINE ON-STACK?!-MIMOC (L "AUX" (IT <1 .L>) (VAL <3 .L>) AC NAC)
	#DECL ((L) LIST (VAL) ATOM)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <COND (<AND <WILL-DIE? .IT> <SET AC <IN-AC? .IT VALUE>>>)
		     (ELSE <OCEMIT MOVE <SET AC O1*> !<OBJ-VAL .IT>>)>
	       <DO-ON-STACK .AC O*>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (<AND <==? .IT .VAL> <SET AC <IN-AC? .IT VALUE>>>
	       <CLEAN-ACS .IT>
	       <AC-TIME <GET-AC .AC> ,AC-STAMP>
	       <SETG FIRST-AC <>>
	       <DO-ON-STACK .AC <NEXT-AC <SET NAC <ASSIGN-AC .VAL BOTH>>>>
	       <AC-TYPE <GET-AC .NAC> FIX>)
	      (T
	       <COND (<AND <SET NAC <IN-AC? .IT VALUE>>
			   <WILL-DIE? .IT>>
		      <SETG FIRST-AC <>>
		      <AC-TIME <GET-AC .NAC> ,AC-STAMP>)
		     (ELSE
		      <OCEMIT MOVE <SET NAC O1*> !<OBJ-VAL .IT>>)>
	       <DO-ON-STACK .NAC <NEXT-AC <SET AC <ASSIGN-AC .VAL BOTH>>>>
	       <AC-TYPE <GET-AC .AC> FIX>)>>

<DEFINE DO-ON-STACK (ARG DEST "AUX" (LBL <GENLBL "DOS">))
	<OCEMIT MOVEI .DEST 0>
	<OCEMIT TLZ .ARG *770000*>
	<OCEMIT CAMLE .ARG !<OBJ-VAL *3000000*>>	;"Border btwn stk + gc"
	<OCEMIT JRST <XJUMP .LBL>>
	<OCEMIT MOVNI .DEST 1>				;"Assume legal"
	<OCEMIT HRRZ .ARG .ARG>
	<OCEMIT CAILE .ARG 0 '(TP*)>			;"Skip if legal"
	<OCEMIT MOVEI .DEST 1>				;"Not legal"
	<LABEL .LBL>>

<DEFINE OBJECT!-MIMOC (L "AUX" (TY <1 .L>) (CNT <2 .L>) (VAL <3 .L>)
			       (V-DONE <>) (RES <5 .L>) (AC <>) (TAC <>) (CAC <>))
	#DECL ((L) <LIST [5 <OR ATOM FIX>]>)
	<COND (<==? .RES STACK>
	       <COND (<AND <TYPE? .TY FIX> <TYPE? .CNT FIX>>
		      <OCEMIT PUSH TP*
			      !<OBJ-VAL <CHTYPE <ORB <LSH .TY 18> .CNT>
						FIX>>>)
		     (ELSE
		      <SMASH-AC O* .CNT VALUE>
		      <COND (<TYPE? .TY FIX>
			     <OCEMIT HRLI O* .TY>)
			    (ELSE
			     <OCEMIT HRL O* !<OBJ-VAL .TY>>)>
		      <OCEMIT PUSH TP* O*>)>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT PUSH TP* !<OBJ-VAL .VAL>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (ELSE
	       <COND (<AND <TYPE? .TY ATOM>
			   <OR <==? .RES .TY> <WILL-DIE? .TY>>>
		      <COND (<SET TAC <IN-AC? .TY BOTH>>
			     <MUNGED-AC .TAC T>
			     <SET TAC <NEXT-AC .TAC>>)
			    (<SET TAC <IN-AC? .TY VALUE>>
			     <MUNGED-AC .TAC>)>
		      <DEAD!-MIMOC (.TY) T>)>
	       <COND (<AND <TYPE? .CNT ATOM>
			   <OR <==? .RES .CNT> <WILL-DIE? .CNT>>>
		      <COND (<SET CAC <IN-AC? .CNT BOTH>>
			     <MUNGED-AC .CAC T>
			     <SET CAC <NEXT-AC .CAC>>)
			    (<SET CAC <IN-AC? .CNT VALUE>>
			     <MUNGED-AC .CAC>)>
		      <DEAD!-MIMOC (.CNT) T>)>
	       <COND (<AND <TYPE? .VAL ATOM>
			   <OR <==? .RES .VAL> <WILL-DIE? .VAL>>>
		      <DEAD!-MIMOC (.VAL) T>
		      <COND (<SET AC <IN-AC? .VAL BOTH>>
			     <SET V-DONE T>
			     <MUNGED-AC .AC>)
			    (<SET AC <IN-AC? .VAL VALUE>>
			     <SET AC <GETPROP .AC AC-PAIR>>
			     <MUNGED-AC .AC>
			     <SET V-DONE T>)>)>
	       <COND (<NOT .AC>
		      <SET AC <ASSIGN-AC .RES BOTH>>)>
	       <COND (<AND <TYPE? .TY FIX> <TYPE? .CNT FIX>>
		      <COND (<0? .CNT>
			     <OCEMIT MOVSI .AC .TY>)
			    (ELSE
			     <OCEMIT MOVE .AC
				     !<OBJ-VAL <CHTYPE <ORB <LSH .TY 18> .CNT>
						       FIX>>>)>)
		     (<TYPE? .TY FIX>
		      <COND (<0? .TY>
			     <COND (.CAC <OCEMIT HRRZ .AC .CAC>)
				   (ELSE <OCEMIT HRRZ .AC !<OBJ-VAL .CNT>>)>)
			    (ELSE
			     <OCEMIT MOVSI .AC .TY>
			     <COND (.CAC <OCEMIT HRR .AC .CAC>)
				   (ELSE <OCEMIT HRR .AC !<OBJ-VAL .CNT>>)>)>)
		     (<TYPE? .CNT FIX>
		      <COND (<0? .CNT>
			     <COND (.TAC <OCEMIT HRLZ .AC .TAC>)
				   (ELSE <OCEMIT HRLZ .AC !<OBJ-VAL .TY>>)>)
			    (ELSE
			     <OCEMIT MOVEI .AC .CNT>
			     <COND (.TAC <OCEMIT HRL .AC .TAC>)
				   (ELSE <OCEMIT HRL .AC !<OBJ-VAL .TY>>)>)>)
		     (ELSE
		      <COND (.CAC <OCEMIT MOVE .AC .CAC>)
			    (ELSE <OCEMIT MOVE .AC !<OBJ-VAL .CNT>>)>
		      <COND (.TAC <OCEMIT HRL .AC .TAC>)
			    (ELSE <OCEMIT HRL .AC !<OBJ-VAL .TY>>)>)>
	       <COND (<NOT .V-DONE>
		      <OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL .VAL>>)
		     (ELSE
		      <ALTER-AC .AC .RES>)>)>>


;"I/O routines"

<DEFINE OPEN!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<OCEMIT DMOVE B1* !<OBJ-TYP <3 .L>>>
	<PUSHJ OPEN <5 .L>>>

<DEFINE CLOSE!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE A1* !<OBJ-VAL <1 .L>>>
	<PUSHJ CLOSE <COND (<G? <LENGTH .L> 2> <3 .L>)>>>

<DEFINE RESET!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE A1* !<OBJ-VAL <1 .L> >>
	<PUSHJ RESET>> 

<DEFINE READ!-MIMOC (L "AUX" (LL <LENGTH .L>) (TL <MEMQ = .L>)
		     (NARGS <- <LENGTH .L> <LENGTH .TL>>))
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> VALUE>
	<SMASH-AC A2* <2 .L> VALUE>
	<SMASH-AC B1* <3 .L> VALUE>
	<SMASH-AC B2* <4 .L> VALUE>
	<COND (<G=? .NARGS 5>
	       <SMASH-AC C1* <5 .L> VALUE>)
	      (<SMASH-AC C1* 0 VALUE>)>
	<COND (<G=? .NARGS 6>
	       <SMASH-AC C2* <6 .L> VALUE>)
	      (<SMASH-AC C2* 0 VALUE>)>
	<PUSHJ READ <COND (.TL <2 .TL>)>>>

<DEFINE PRINT!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> VALUE>
	<SMASH-AC A2* <2 .L> VALUE>
	<SMASH-AC B1* <3 .L> VALUE>
	<PUSHJ PRINT>>


;"Stack, variable hacking"


<DEFINE SET!-MIMOC (L
		    "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VT <VAR-TYPED? .ARG1>)
			  (STK? <VAR-STACKED? .ARG1>) AC NAC ITM FARG2 LV TAC
			  LL (MIML .MIML))
   #DECL ((L MIML) LIST (AC ARG1) ATOM (ARG2 ITM) ANY (NAC) <OR FALSE ATOM>
	  (FARG2) FIX)
   <COND
    (<AND <TYPE? .ARG2 ATOM> <SET ITM <WILL-DIE? .ARG2>>>
     <CLEAN-ACS .ARG1>
     <DEAD!-MIMOC (.ARG2) T>
     <COND (<AND <TYPE? <2 .MIML> FORM>
		 <NOT <EMPTY? <2 .MIML>>>
		 <==? <1 <2 .MIML>> RETURN>>
	    <GET-INTO-ACS .ARG2 BOTH <SET AC A1*>>)
	   (<SET NAC <IN-AC? .ARG2 BOTH>> <SET AC .NAC>)
	   (<AND .VT <SET NAC <IN-AC? .ARG2 VALUE>>>
	    <SET AC .NAC>
	    <AC-TYPE <GET-AC <SET AC <GETPROP .AC AC-PAIR>>> .VT>)
	   (T <SET AC <LOAD-AC .ARG2 BOTH>>)>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .AC> <NOT .VT>> .ARG1> TYPE>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC <NEXT-AC .AC>> T> .ARG1> VALUE>)
    (<AND <NOT <TYPE? .ARG2 ATOM>>
	  <NOT <EMPTY? <SET LL <REST .MIML>>>>
	  <TYPE? <SET LL <1 .LL>> FORM>
	  <==? <1 .LL> RETURN>>
     <CLEAN-ACS .ARG1>
     <GET-INTO-ACS .ARG2 BOTH <SET AC A1*>>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .AC> <NOT .VT>> .ARG1> TYPE>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC <NEXT-AC .AC>> T> .ARG1> VALUE>)
    (T
     <COND (<AND <TYPE? .ARG2 ATOM>
		 <SET NAC <OR <IN-AC? .ARG2 BOTH> <IN-AC? .ARG2 VALUE>>>
		 <AC-UPDATE <GET-AC .NAC>>>
	    <AC-TIME <GET-AC .NAC> ,AC-STAMP>)>
     <SET AC <ASSIGN-AC .ARG1 BOTH>>
     <AC-TYPE <GET-AC .AC> <>>
     <COND (<AND <SET NAC <IN-AC? .ARG2 BOTH>> <NOT <AC-TYPE <GET-AC .NAC>>>>
	    <OCEMIT DMOVE .AC .NAC>)
	   (<AND <MEMQ <PRIMTYPE .ARG2> '[WORD FIX]>
		 <MEMQ <TYPE .ARG2> ,TYPE-WORDS>>
	    <COND (<==? <CHTYPE .ARG2 FIX> 0>
		   <COND (<AND .STK? .VT>
			  <OCEMIT SETZB <NEXT-AC .AC> !<OBJ-VAL .ARG1 <>>>
			  <AC-UPDATE <GET-AC <NEXT-AC .AC>> <>>)
			 (ELSE <OCEMIT MOVEI <NEXT-AC .AC> 0>)>)
		  (<==? <CHTYPE .ARG2 FIX> -1>
		   <COND (<AND .STK? .VT>
			  <OCEMIT SETOB <NEXT-AC .AC> !<OBJ-VAL .ARG1 <>>>
			  <AC-UPDATE <GET-AC <NEXT-AC .AC>> <>>)
			 (ELSE <OCEMIT MOVNI <NEXT-AC .AC> 1>)>)
		  (<==? <CHTYPE <ANDB .ARG2 262143> FIX> 0>
		   <OCEMIT MOVSI <NEXT-AC .AC> <CHTYPE <LSH .ARG2 -18> FIX>>)
		  (<L=? <ABS <SET FARG2 <CHTYPE .ARG2 FIX>>> ,MAX-IMMEDIATE>
		   <COND (<G=? .FARG2 0> <OCEMIT MOVEI <NEXT-AC .AC> .FARG2>)
			 (ELSE <OCEMIT MOVNI <NEXT-AC .AC> <ABS .FARG2>>)>)
		  (ELSE <OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL .FARG2>>)>
	    <AC-TYPE <GET-AC .AC> <TYPE .ARG2>>
	    <COND (<VAR-TYPED? .ARG1> <AC-UPDATE <GET-AC .AC> <>>)
		  (ELSE <AC-UPDATE <GET-AC .AC> T>)>)
	   (<AND <==? <PRIMTYPE .ARG2> LIST>
		 <EMPTY? <CHTYPE .ARG2 LIST>>
		 <MEMQ <TYPE .ARG2> ,TYPE-WORDS>>
	    <COND (<AND .STK? .VT>
		   <OCEMIT SETZB <NEXT-AC .AC> !<OBJ-VAL .ARG1 <>>>
		   <AC-UPDATE <GET-AC <NEXT-AC .AC>> <>>)
		  (ELSE <OCEMIT MOVEI <NEXT-AC .AC> 0>)>
	    <AC-TYPE <GET-AC .AC> <TYPE .ARG2>>
	    <COND (<VAR-TYPED? .ARG1> <AC-UPDATE <GET-AC .AC> <>>)>)
	   (<AND <SET LV <VAR-TYPED? .ARG1>> <SET NAC <IN-AC? .ARG2 VALUE>>>
	    <OCEMIT MOVE <NEXT-AC .AC> .NAC>
	    <AC-TYPE <AC-UPDATE <GET-AC .AC> <>> .LV>)
	   (<AND <SET NAC <IN-AC? .ARG2 VALUE>>
		 <SET LV
		      <OR <VAR-TYPED? .ARG2>
			  <AND <SET TAC <IN-AC? .ARG2 TYPE>>
			       <AC-TYPE <GET-AC .TAC>>>>>>
	    <OCEMIT MOVE <NEXT-AC .AC> .NAC>
	    <AC-TYPE <GET-AC .AC> .LV>)
	   (<AND <SET NAC <IN-AC? .ARG2 VALUE>> <AC-UPDATE <GET-AC .NAC>>>
	    <OCEMIT MOVE .AC !<OBJ-TYP .ARG2>>
	    <OCEMIT MOVE <NEXT-AC .AC> .NAC>)
	   (<AND <SET NAC <IN-AC? .ARG2 TYPE>> <AC-UPDATE <GET-AC .NAC>>>
	    <OCEMIT MOVE .AC .NAC>
	    <OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL .ARG2>>)
	   (T <OCEMIT DMOVE .AC !<OBJ-LOC .ARG2 0>>)>)>>

<DEFINE VAR-TYPED? (ARG1 "AUX" LV)
	#DECL ((ARG1) ATOM)
	<AND <SET LV <OR <LMEMQ .ARG1 ,LOCALS>
			 <AND ,ICALL-FLAG
			      <LMEMQ .ARG1 ,ICALL-TEMPS>>>>
	     <N==? <LUPD .LV> OARG>
	     <SET LV <LDECL .LV>>
	     <OR <MEMQ <TYPEPRIM .LV> '[WORD FIX LIST]>
		 <MEMQ .LV ,TYPE-LENGTHS>>
	     .LV>>

<DEFINE VAR-STACKED? (ARG1 "AUX" LV)
	#DECL ((ARG1) ATOM)
	<AND <SET LV <OR <LMEMQ .ARG1 ,LOCALS>
			 <AND ,ICALL-FLAG
			      <LMEMQ .ARG1 ,ICALL-TEMPS>>>>
	     <LUPD .LV>>>

<SETG SIMPLE-DEATH <>>

<NEWTYPE DEAD-VAR ATOM>

<DEFINE WILL-DIE? (ARG "OPT" (MIML .MIML)
			     (VISIT <SETG VISIT-COUNT <+ ,VISIT-COUNT 1>>)
		       "AUX" FOO LB) 
   #DECL ((ARG) ANY (MIML) LIST (VISIT) FIX)
   <PROG LEAVE (NXT ITM (SIMPLE ,SIMPLE-DEATH) LAB)
     #DECL ((NXT) <OR ATOM FORM LIST>)
     <COND
      (<NOT <TYPE? .ARG ATOM>> <RETURN T>)
      (<L=? <LENGTH .MIML> 1> <RETURN T>)
      (<TYPE? <SET NXT <2 .MIML>> FORM>
       <OR <AND <==? <SET ITM <1 .NXT>> DEAD>
		<OR <MEMQ .ARG <REST .NXT>>
		    <AND .SIMPLE <RETURN <>>>
		    <AND <SET MIML <REST .MIML>> <AGAIN>>>>
	   <AND <==? .ITM RETURN> <RETURN <N==? <2 .NXT> .ARG>>>
	   <AND <==? .ITM DISPATCH> <RETURN <>>>
	   <==? .ITM END>
	   <AND <==? .ITM SET>
		<COND (<==? <2 .NXT> .ARG>)
		      (<OR <==? <3 .NXT> .ARG> .SIMPLE> <RETURN <>>)
		      (ELSE <SET MIML <REST .MIML>> <AGAIN>)>>
	   <AND <N==? .ITM ICALL>
		<MAPR <>
		      <FUNCTION (XP "AUX" (X <1 .XP>)) 
			 <COND (<==? .X =>
				<COND (<==? <SET X <2 .XP>> .ARG>
				       <RETURN T .LEAVE>)
				      (ELSE <MAPLEAVE <>>)>)
			       (<==? .X .ARG> <RETURN <> .LEAVE>)>>
		      .NXT>>
	   <AND .SIMPLE <RETURN <>>>
	   <AND <OR <SET FOO <MEMQ + <SET NXT <REST .NXT>>>>
		    <SET FOO <MEMQ - .NXT>>
		    <AND <==? .ITM NTHR>
			 <TYPE? <SET ITM <NTH .NXT <LENGTH .NXT>>> LIST>
			 <==? <1 .ITM> BRANCH-FALSE>
			 <SET FOO <REST .ITM>>>
		    <AND <==? .ITM ICALL> <SET FOO <2 .MIML>>>>
		<COND (<AND <SET LB <FIND-LABEL <SET LAB <2 .FOO>>>>
			    <LAB-WILL-DIE .LB .ARG .VISIT
					  <COND (<AND <==? .ITM ICALL>
						      <G? <LENGTH .FOO> 1>>
						 <4 .FOO>)>>>
		       <SET MIML <REST .MIML>>
		       <COND (<==? .ITM JUMP> <RETURN T>)
			     (ELSE <AGAIN>)>)
		      (<OR <==? .LAB COMPERR>
			   <==? .LAB IOERR>
			   <==? .LAB UNWCNT>>
		       <COND (<==? .ITM JUMP> <RETURN T>)
			     (ELSE <>)>)
		      (ELSE <RETURN <>>)>>
	   <AND <NOT <EMPTY? ,THE-BIG-LABELS>>
		<OR <==? .ITM CALL> <==? .ITM ACALL> <==? .ITM SCALL>>
		<MAPF <>
		      <FUNCTION (NAM)
			   <COND (<LAB-WILL-DIE <FIND-LABEL .NAM> .ARG .VISIT
						<>>
				  T)
				 (ELSE <RETURN <>>)>>
		      ,THE-BIG-LABELS>
		<>>
	   <NOT <SET MIML <REST .MIML>>>
	   <AGAIN>>)
      (ELSE <SET MIML <REST .MIML>> <AGAIN>)>>>

<DEFINE LAB-WILL-DIE (LB:LAB ARG:ATOM VISIT:FIX ICALL-VAR:<OR ATOM FALSE>)
	<PROG ()
	      <COND (<==? .ICALL-VAR .ARG> <RETURN T>)>
	      <AND <OR <AND <GASSIGNED? DO-LOOPS> ,DO-LOOPS>
		       <NOT <LAB-LOOP .LB>>>
		   <OR <MAPF <>
			     <FUNCTION (X)
				  <COND (<==? <CHTYPE .X ATOM> .ARG>
					 <COND (<TYPE? .X ATOM>
						<RETURN <>>)
					       (ELSE <MAPLEAVE>)>)>
				  <>>
			     <LAB-DEAD-VARS .LB>>
		       <==? <LAB-VISIT-MARK .LB> .VISIT>
		       <AND <PUT .LB ,LAB-VISIT-MARK .VISIT> <>>
		       <COND (<WILL-DIE? .ARG <LAB-CODE-PNTR .LB> .VISIT>
			      <PUT .LB ,LAB-DEAD-VARS
				   (<CHTYPE .ARG DEAD-VAR>
				    !<LAB-DEAD-VARS .LB>)>)
			     (ELSE
			      <PUT .LB ,LAB-DEAD-VARS
				   (.ARG !<LAB-DEAD-VARS .LB>)>
			      <>)>>>>>
<NEWTYPE T$UNBOUND FIX>

<DEFINE PUSH!-MIMOC (L "AUX" (ARG <1 .L>) AC TY)
	#DECL ((L) LIST (ARG) ANY)
	<COND (<TYPE? .ARG T$UNBOUND>
	       <OCEMIT PUSH TP* !<OBJ-VAL 0>>
	       <OCEMIT PUSH TP* !<OBJ-VAL 0>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (T
	       <COND (<AND <TYPE? .ARG ATOM>
			   <SET AC <IN-AC? .ARG TYPE>>
			   <SET TY <AC-TYPE <GET-AC .AC>>>>
		      <OCEMIT PUSH TP* !<TYPE-WORD .TY>>)
		     (ELSE
		      <OCEMIT PUSH TP* !<OBJ-TYP .ARG>>)>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT PUSH TP* !<OBJ-VAL .ARG>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)>>

<DEFINE POP!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<SET AC <ASSIGN-AC <2 .L> BOTH>>
	<OCEMIT DMOVE .AC -1 '(TP*)>
	<OCEMIT ADJSP TP* -2>
	<COND (,WINNING-VICTIM <SETG STACK-DEPTH <- ,STACK-DEPTH 2>>)>>

<DEFINE ADJ!-MIMOC (L "AUX" (ARG <1 .L>))
	#DECL ((L) LIST (ARG) ANY)
	<COND (<TYPE? .ARG FIX>
	       <OCEMIT ADJSP TP* .ARG>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH
							   .ARG>>)>)
	      (T
	       <SMASH-AC T* .ARG VALUE>
	       <OCEMIT ADJSP TP* '(T*)>)>>

<DEFINE GETS!-MIMOC (L "AUX" (ARG1 <1 .L>) (VAL <3 .L>) (VAR <2 .ARG1>)
		             AC TEMP)
	#DECL ((L) LIST (ARG1) <FORM ATOM ATOM> (VAR VAL AC) ATOM)
	<COND (<==? .VAR ARGS>
	       <COND (<==? .VAL STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		      <OCEMIT HLRZ O* -2 '(F*)>
		      <MUNGED-AC O*>
		      <OCEMIT PUSH TP* O*>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (T
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
	              <AC-TYPE <GET-AC .AC> FIX>
	              <OCEMIT HLRZ <NEXT-AC .AC> -2 '(F*)>)>)
	      (<==? .VAR OBLIST>
	       <COND (<==? .VAL STACK>
		      <FLUSH-AC T*>
		      <MUNGED-AC T*>
		      <OCEMIT MOVE T* *144*>
		      <OCEMIT PUSH TP* '(T*)>
		      <OCEMIT PUSH TP* 1 '(T*)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (T
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <OCEMIT DMOVE .AC @ *144*>)>)
	      (<==? .VAR BIND>
	       <COND (<==? .VAL STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD T$LBIND>>
		      <OCEMIT PUSH TP* SP*>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (T
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <AC-TYPE <GET-AC .AC> T$LBIND>
		      <OCEMIT MOVE <NEXT-AC .AC> SP*>)>)
	      (<==? .VAR PAGPTR>
	       <COND (<==? .VAL STACK>
		      <FLUSH-AC T*>
		      <MUNGED-AC T*>
		      <OCEMIT MOVE T* *145*>
		      <OCEMIT PUSH TP* '(T*)>
		      <OCEMIT PUSH TP* 1 '(T*)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
		      <OCEMIT SKIPN '(TP*)>
		      <OCEMIT SETZM -1 '(TP*)>)
		     (ELSE
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <OCEMIT DMOVE .AC @ *145*>
		      <OCEMIT SKIPN O* <NEXT-AC .AC>>
		      <OCEMIT MOVEI .AC 0>)>)
	      (<==? .VAR MINF>
	       <COND (<==? .VAL STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD T$MINF>>
		      <OCEMIT PUSH TP* @ *143*>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
		      <OCEMIT SKIPN '(TP*)>
		      <OCEMIT SETZM -1 '(TP*)>)
		     (ELSE
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <OCEMIT MOVE .AC !<TYPE-WORD T$MINF>>
		      <OCEMIT SKIPN <NEXT-AC .AC> @ *143*>
		      <OCEMIT MOVEI .AC 0>)>)
	      (<SET TEMP <MEMQ .VAR '[ICALL ECALL NCALL UWATM MAPPER
				      PURVEC DBVEC TBIND]>>
	       <SET TEMP <LENGTH .TEMP>>
	       <COND (<==? .VAL STACK>
		      <COND (<==? .VAR TBIND>
			     <OCEMIT PUSH TP* !<TYPE-WORD T$LBIND>>)
			    (<MEMQ .VAR '[PURVEC DBVEC]>
			     <OCEMIT PUSH TP* !<TYPE-WORD LIST>>)
			    (<OCEMIT PUSH TP* !<TYPE-WORD T$ATOM>>)>
		      <OCEMIT PUSH TP* @ <NTH '![*136* *142* *141*
						 *140* *146* *151* *150* *147*]
					      .TEMP>>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
		      <OCEMIT SKIPN '(TP*)>
		      <OCEMIT SETZM -1 '(TP*)>)
		     (ELSE
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <COND (<==? .VAR TBIND>
			     <OCEMIT MOVE .AC !<TYPE-WORD T$LBIND>>)
			    (<MEMQ .VAR '[PURVEC DBVEC]>
			     <OCEMIT MOVE .AC !<TYPE-WORD LIST>>)
			    (<OCEMIT MOVE .AC !<TYPE-WORD T$ATOM>>)>
		      <OCEMIT SKIPN <NEXT-AC .AC> @
			      <NTH '![*136* *142* *141*
				      *140* *146* *151* *150* *147*] .TEMP>>
		      <OCEMIT MOVEI .AC 0>)>)
	      (<MEMQ .VAR '[ENVIR ARGV]>
	       <COND (<==? .VAL STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD FALSE>>
		      <OCEMIT PUSH TP* !<OBJ-VAL 0>>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (T
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <OCEMIT MOVE .AC !<TYPE-WORD FALSE>>
		      <OCEMIT MOVEI <NEXT-AC .AC> 0>)>)
	      (<OR <==? .VAR BINDID> <==? .VAR INGC>>
	       <COND (<==? .VAL STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		      <OCEMIT PUSH TP* @ <COND (<==? .VAR BINDID> *137*)
					       (ELSE *161*)>>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		      (ELSE
		       <SET AC <ASSIGN-AC .VAL BOTH T>>
		       <OCEMIT MOVSI .AC !<TYPE-CODE FIX T>>
		       <OCEMIT MOVE <NEXT-AC .AC> @ <COND (<==? .VAR BINDID> *137*)
							  (ELSE *161*)>>)>)
	      (T <MIMOCERR UNKNOWN-SPECIAL-VARIABLE!-ERRORS .VAR>)>>

<DEFINE ATIC!-MIMOC (L "AUX")
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ ATIC <3 .L>>>

<DEFINE SETS!-MIMOC (L "AUX" (ARG <1 .L>) (VAR <2 .ARG>) (VAL <2 .L>) AC)
	#DECL ((L) LIST (ARG) <FORM ATOM ATOM> (VAR) ATOM
	       (VAL) <OR ATOM <FORM ATOM ATOM>>)
	<COND (<MEMQ = .L> <ERROR CANT-ASSIGN-RESULT-OF-SETS!-ERRORS .L>)>
	<COND (<==? .VAR BIND>
	       <OCEMIT MOVE SP* !<OBJ-VAL .VAL>>)
	      (<==? .VAR ICALL>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *147*>)
	      (<==? .VAR INGC>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *161*>)
	      (<==? .VAR ECALL>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *150*>)
	      (<==? .VAR NCALL>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *151*>)
	      (<==? .VAR RUNINT>
	       <UPDATE-ACS>
	       <OCEMIT MOVE O1* !<OBJ-VAL .VAL>>
	       <PUSHJ IENABLE>)
	      (<==? .VAR UWATM>
	       <OCEMIT MOVE O1* !<OBJ-VAL .VAL>>
	       <PUSHJ SUNWAT>)
	      (<==? .VAR PAGPTR>
	       <COND (<NOT <SET AC <IN-AC? .VAL BOTH>>>
		      <GET-INTO-ACS .VAL BOTH <SET AC O1*>>)>
	       <OCEMIT DMOVEM .AC @ *145*>)
	      (<==? .VAR MINF>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *143*>)
	      (<==? .VAR MAPPER>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *140*>)
	      (<==? .VAR PURVEC>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *141*>)
	      (<==? .VAR DBVEC>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *142*>)
	      (<==? .VAR OBLIST>
	       <COND (<NOT <SET AC <IN-AC? .VAL BOTH>>>
		      <GET-INTO-ACS .VAL BOTH <SET AC O1*>>)>
	       <OCEMIT DMOVEM .AC @ *144*>)
	      (<==? .VAR TBIND>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *136*>)
	      (<==? .VAR BINDID>
	       <COND (<NOT <SET AC <IN-AC? .VAL VALUE>>>
		      <GET-INTO-ACS .VAL VALUE <SET AC O1*>>)>
	       <OCEMIT MOVEM .AC @ *137*>)
	      (T <MIMOCERR UNKNOWN-SPECIAL-VARIABLE!-ERRORS .VAR>)>>

;"Control"

<DEFINE JUMP!-MIMOC (L) 
	#DECL ((L) LIST)
	<LABEL-UPDATE-ACS <2 .L> T>
	<SETG LAST-UNCON T>
	<OCEMIT JRST <XJUMP <2 .L>>>>

<NEWTYPE GFRM ATOM>

<NEWTYPE GCAL ATOM>

<NEWTYPE SGFRM ATOM>

<SETG GLUE-FRAME 100>

<DEFINE SFRAME!-MIMOC (L) <FRAME!-MIMOC .L T>>

<DEFINE FRAME!-MIMOC (L "OPT" (SEG <>) "AUX" PN NM CN) 
	#DECL ((L) LIST)
	<COND (<AND ,GLUE-MODE <NOT <EMPTY? .L>> <NOT <TYPE? <1 .L> FORM>>>
	       <COND (<AND ,SURVIVOR-MODE
			   <SET PN <FIND-CALL <SET NM <2 .L>> ,PRE-NAMES>>
			   <NOT <GETPROP .PN NDFRM>>
			   <NOT <FIND-OPT .NM ,PRE-OPTS>>
			   <NOT <SURVIVOR? .NM>>>
		      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		      <COND (.SEG <OCEMIT <CHTYPE <1 .L> SGFRM> T>)
			    (ELSE <OCEMIT <CHTYPE <1 .L> GFRM> T>)>
		      <COND (<NOT ,PASS1> <CONST-ADD-FRM>)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (ELSE
		      <FLUSH-AC T*>
		      <MUNGED-AC T*>
		      <OCEMIT SKIPL T* -1 '(F*)>
		      <OCEMIT HRROI T* '(F*)>
		      <OCEMIT PUSH TP* T*>
		      <COND (.SEG <OCEMIT <CHTYPE <1 .L> SGFRM> T>)
			    (ELSE <OCEMIT <CHTYPE <1 .L> GFRM> T>)>
		      <COND (<NOT ,PASS1> <CONST-ADD-FRM>)>
		      <OCEMIT PUSH TP* F*>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 3>>)>)>)
	      (<AND <NOT <EMPTY? .L>>
		    <NOT <TYPE? <SET NM <1 .L>> FORM>>
		    <SUBRIFY? <2 .L>>>
	       <FLUSH-AC T*>
	       <MUNGED-AC T*>
	       <OCEMIT <CHTYPE .NM SBFRM> T>
	       <COND (<NOT ,PASS1> <CONST-ADD-FRM>)>
	       <OCEMIT JSP T* @ <- <OPCODE SBRFRAM>>>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 7>>)>)
	      (T
	       <UPDATE-ACS>
	       <PUSHJ <COND (.SEG SFRAME) (ELSE FRAME)>>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 7>>)>)>>

<DEFINE VFRAME!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<PUSHJ FRAME <2 .L>>>

<DEFINE CFRAME!-MIMOC (L "AUX" (VAL <2 .L>) AC)
	#DECL ((L) LIST (VAL AC) ATOM)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FRAME>>
	       <OCEMIT XMOVEI O* -4 '(F*)>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (T
	       <SET AC <ASSIGN-AC .VAL BOTH>>
	       <AC-TYPE <GET-AC .AC> FRAME>
	       <OCEMIT XMOVEI <NEXT-AC .AC> -4 '(F*)>)>>

<DEFINE PFRAME!-MIMOC (L "AUX" (VAL <3 .L>) AC NAC RNAC TAG)
	#DECL ((L) LIST (VAL AC NAC RNAC TAG) ATOM)
	<SET AC <LOAD-AC <1 .L> VALUE>>
	<SET NAC <ASSIGN-AC .VAL BOTH T>>
	<AC-TYPE <GET-AC .NAC> FRAME>
	<OCEMIT MOVE <SET RNAC <NEXT-AC .NAC>> 3 (.AC)>
	<OCEMIT SKIPL (.RNAC)>
	<OCEMIT JRST <XJUMP <SET TAG <GENLBL "END">>>>
	<OCEMIT HRR .RNAC -1 (.RNAC)>
	<OCEMIT SUBI .RNAC 4>
	<LABEL .TAG>
	<OCEMIT HLL .RNAC F*>
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* .NAC>
	       <OCEMIT PUSH TP* .RNAC>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>   

<DEFINE RFRAME!-MIMOC (L)
	#DECL ((L) LIST)
	<RETURN!-MIMOC .L <2 .L>>>

<DEFINE RTUPLE!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<OCEMIT JRST @ <OPCODE RTUPLE>>>

<DEFINE MRETURN!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<COND (<==? <2 .L> 0>
	       <OCEMIT MOVEI O2* 0>)
	      (ELSE
	       <OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>)>
	<OCEMIT JRST @ <OPCODE MRETURN>>>

<DEFINE ICALL!-MIMOC (L "AUX" (END <GENLBL "ICALL">))
	#DECL ((L) LIST)
	<COND (,ICALL-FLAG <SETG ICALL-FLAG <+ ,ICALL-FLAG 1>>)
	      (ELSE <SETG ICALL-FLAG 1>)>
	<UPDATE-ACS>
	<FLUSH-ACS>
	<OCEMIT JSP T* @ <- <OPCODE ICALL>>>
	<OCEMIT JRST <XJUMP .END>>
	<SETG ICALL-TAGS (<1 .L> .END <COND (<G=? <LENGTH .L> 3>
					     <3 .L>)
					    (ELSE <>)>  !,ICALL-TAGS)>>	

<DEFINE SCALL!-MIMOC (L) <CALL!-MIMOC .L T>>

<DEFINE CALL!-MIMOC (L
		     "OPT" (SEG <>)
		     "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) C AC PN OP-INF TAG COUNT
			   (XTAG <GENLBL "SC">) (SBYFINF <>))
	#DECL ((L) LIST (ARG1) <OR ATOM <FORM ATOM ATOM>> (C) ATOM
	       (ARG2) <OR FIX ATOM>
	       (OP-INF) <OR !<FALSE> <LIST <OR <FORM ANY FIX> !<FALSE>>>>)
	<COND (<AND .SEG <G? <LENGTH .L> 5>>
	       <SET TAG <6 .L>>
	       <SET COUNT <7 .L>>)>
	<COND (<AND <TYPE? .ARG1 FORM>
		    <OR <AND ,GLUE-MODE
			     <SET PN <FIND-CALL <2 .ARG1> ,PRE-NAMES>>>
			<SET SBYFINF <SUBRIFY? <2 .ARG1>>>>>
	       <COND (.SBYFINF
		      <COND (<NOT <TYPE? .ARG2 FIX>>
			     <OCEMIT MOVE O2* !<OBJ-VAL .ARG2>>)
			    (<NOT <KNOWN-ARGS .SBYFINF>>
			     <OCEMIT MOVEI O2* .ARG2>)>)
		     (<SET OP-INF <FIND-OPT <2 .ARG1> ,PRE-OPTS>>
		      <COND (<NOT <TYPE? .ARG2 FIX>>
			     <OCEMIT MOVE O2* !<OBJ-VAL .ARG2>>)
			    (<NOT <1 .OP-INF>> <OCEMIT MOVEI O2* .ARG2>)>)
		     (<AND <TYPE? .ARG2 ATOM> <NOT <IN-AC? .ARG2 VALUE>>>
		      <OCEMIT MOVE O2* !<OBJ-VAL .ARG2>>)>
	       <COND (<AND <TYPE? .ARG2 FIX>
			   ,SURVIVOR-MODE
			   <NOT <GETPROP .PN NDFRM>>
			   <NOT .OP-INF>
			   <NOT <SURVIVOR? <2 .ARG1>>>>
		      <UPDATE-ACS>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH
				   <- ,STACK-DEPTH <+ <* .ARG2 2> 2>>>)>)
		     (<TYPE? .ARG2 FIX>
		      <UPDATE-ACS>
		      <OCEMIT XMOVEI F* <- <+ <* .ARG2 2> 1>> (TP*)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH
				   <- ,STACK-DEPTH <+ <* .ARG2 2> 3>>>)>)
		     (T
		      <COND (<AND <TYPE? .ARG2 ATOM>
				  <OR <WILL-DIE? .ARG2>
				      <==? .ARG2
					   <COND (<G? <LENGTH .L> 3> <4 .L>)>>>>
			     <DEAD!-MIMOC (.ARG2) T>)>
		      <UPDATE-ACS>
		      <OCEMIT XMOVEI F* -1 '(TP*)>
		      <COND (<SET AC <IN-AC? .ARG2 VALUE>>
			     <OCEMIT LSH .AC 1>
			     <OCEMIT SUB F* .AC>)
			    (ELSE
			     <OCEMIT SUB F* O2*>
			     <OCEMIT SUB F* O2*>)>)>
	       <COND (.SBYFINF
		      <OCEMIT DMOVE A1* !<OBJ-TYP .SBYFINF>>
		      <OCEMIT DMOVEM A1* -3 '(F*)>
		      <OCEMIT MOVE M* 1 '(A2*)>
		      <OCEMIT XCT 3 '(A2*)>
		      <OCEMIT JRST @ 5 '(A2*)>)
		     (ELSE
		      <OCEMIT <CHTYPE <2 .ARG1> GCAL>
			      T
			      <COND (<AND .OP-INF <1 .OP-INF> <TYPE? .ARG2 FIX>>
				     <NTH <1 .OP-INF>
					  <- .ARG2
					     <CHTYPE <2 <1 .OP-INF>> FIX>
					     -4>>)>>)>
	       <LABEL <NTH .L <LENGTH .L>> 0>
	       <FLUSH-ACS>
	       <COND (<AND .SEG <ASSIGNED? TAG>>
		      <COND (<N==? .TAG <2 .MIML>>
			     <OCEMIT JRST <XJUMP .XTAG>>)
			    (ELSE
			     <OCEMIT JFCL O* O*>)>
		      <COND (<NOT <WILL-DIE? .COUNT>>
			     <CLEAN-ACS .COUNT>
			     <OCEMIT ADDB A2* !<OBJ-VAL .COUNT>>
			     <SET AC <GET-AC A1*>>
			     <AC-ITEM .AC .COUNT>
			     <AC-CODE .AC TYPE>
			     <AC-UPDATE .AC <>>
			     <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			     <SET AC <GET-AC A2*>>
			     <AC-ITEM .AC .COUNT>
			     <AC-CODE .AC VALUE>
			     <AC-UPDATE .AC <>>
			     <AC-TIME .AC ,AC-STAMP>)>
		      <COND (<N==? .TAG <2 .MIML>>
			     <LABEL-UPDATE-ACS .TAG <>>
			     <OCEMIT JRST <XJUMP .TAG>>
			     <LABEL .XTAG>
			     <SET AC <GET-AC A1*>>
			     <CLEAN-ACS <4 .L>>
			     <AC-ITEM .AC <4 .L>>
			     <AC-CODE .AC TYPE>
			     <AC-UPDATE .AC T>
			     <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			     <SET AC <GET-AC A2*>>
			     <AC-ITEM .AC <4 .L>>
			     <AC-CODE .AC VALUE>
			     <AC-UPDATE .AC T>
			     <AC-TIME .AC ,AC-STAMP>)>)
		     (ELSE
		      <COND (<G? <LENGTH .L> 3> <PUSHJ-VAL <4 .L>>)>)>)
	      (T
	       <OCEMIT MOVE O1* !<OBJ-VAL .ARG1>>
	       <COND (<TYPE? .ARG2 FIX>
		      <OCEMIT MOVEI O2* .ARG2>)
		     (T <OCEMIT MOVE O2* !<OBJ-VAL .ARG2>>)>
	       <COND (<AND <TYPE? .ARG1 ATOM>
			   <OR <WILL-DIE? .ARG1>
			       <==? .ARG1 <COND (<G? <LENGTH .L> 3> <4 .L>)>>>>
		      <DEAD!-MIMOC (.ARG1)>)>
	       <COND (<AND <TYPE? .ARG2 ATOM>
			   <OR <WILL-DIE? .ARG2>
			       <==? .ARG2 <COND (<G? <LENGTH .L> 3> <4 .L>)>>>>
		      <DEAD!-MIMOC (.ARG2)>)>
	       <UPDATE-ACS>
	       <COND (<AND ,WINNING-VICTIM <TYPE? .ARG2 FIX>>
		      <SETG STACK-DEPTH
			    <- ,STACK-DEPTH <* .ARG2 2> 7>>)>
	       <COND (<AND .SEG <ASSIGNED? TAG>>
		      <PUSHJ CALL>
		      <COND (<N==? .TAG <2 .MIML>>
			     <OCEMIT JRST <XJUMP .XTAG>>)
			    (ELSE
			     <OCEMIT JFCL O* O*>)>
		      <COND (<NOT <WILL-DIE? .COUNT>>
			     <SET AC <GET-AC A1*>>
			     <CLEAN-ACS .COUNT>
			     <OCEMIT ADDB A2* !<OBJ-VAL .COUNT>>
			     <AC-ITEM .AC .COUNT>
			     <AC-CODE .AC TYPE>
			     <AC-UPDATE .AC <>>
			     <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			     <SET AC <GET-AC A2*>>
			     <AC-ITEM .AC .COUNT>
			     <AC-CODE .AC VALUE>
			     <AC-UPDATE .AC <>>
			     <AC-TIME .AC ,AC-STAMP>)>
		      <COND (<N==? .TAG <2 .MIML>>
			     <LABEL-UPDATE-ACS .TAG <>>
			     <OCEMIT JRST <XJUMP .TAG>>
			     <LABEL .XTAG>
			     <SET AC <GET-AC A1*>>
			     <CLEAN-ACS <4 .L>>
			     <AC-ITEM .AC <4 .L>>
			     <AC-CODE .AC TYPE>
			     <AC-UPDATE .AC T>
			     <AC-TIME .AC <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			     <SET AC <GET-AC A2*>>
			     <AC-ITEM .AC <4 .L>>
			     <AC-CODE .AC VALUE>
			     <AC-UPDATE .AC T>
			     <AC-TIME .AC ,AC-STAMP>)>)
		     (ELSE
		      <COND (<L=? <LENGTH .L> 3> <PUSHJ CALL>)
			    (T <PUSHJ CALL <4 .L>>)>
		      <COND (.SEG <OCEMIT JFCL O* O*>)>)>)>>

<DEFINE ACALL!-MIMOC (L "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) C (VAL <>)) 
	#DECL ((L) LIST (ARG1) <OR ATOM <FORM ATOM ATOM>> (C) ATOM
	       (ARG2) <OR FIX ATOM>)
	<COND (<G? <LENGTH .L> 3> <SET VAL <4 .L>>)>
	<COND (<OR <==? .ARG1 .VAL> <WILL-DIE? .ARG1>>
	       <DEAD!-MIMOC (.ARG1) T>)>
	<COND (<OR <==? .ARG2 .VAL> <WILL-DIE? .ARG2>>
	       <DEAD!-MIMOC (.ARG2) T>)>
	<UPDATE-ACS>
	<GET-INTO-ACS .ARG1 BOTH A1* .ARG2 VALUE O2*>
	<COND (<AND <TYPE? .ARG2 FIX>
		    ,WINNING-VICTIM>
	       <SETG STACK-DEPTH <- ,STACK-DEPTH
				    <* .ARG2 2> 7>>)>
	<COND (<NOT .VAL> <PUSHJ ACALL>) (T <PUSHJ ACALL .VAL>)>>

<DEFINE SETLR!-MIMOC (L "AUX" AC LCL)
	#DECL ((L) LIST (AC) ATOM (P) <OR FALSE FIX>)
	<SET AC <ASSIGN-AC <1 .L> BOTH>>
	<OCEMIT MOVE T* !<OBJ-VAL <2 .L>>>
	<SET LCL <OR <LMEMQ <3 .L> ,LOCALS>
		     <LMEMQ <3 .L> ,ICALL-TEMPS>>>
	<OCEMIT DMOVE .AC <LNAME .LCL> '(T*)>>

<DEFINE SETRL!-MIMOC (L "AUX" AC LCL)
	#DECL ((L) LIST (AC) ATOM (P) <OR FALSE FIX>)
	<SET AC <LOAD-AC <3 .L> BOTH>>
	<OCEMIT MOVE T* !<OBJ-VAL <1 .L>>>
	<COND (<OR <SET LCL <LMEMQ <2 .L> ,LOCALS>>
		   <SET LCL <LMEMQ <2 .L> ,ICALL-TEMPS>>>
	       <COND (<NOT <LUPD .LCL>> <LUPD .LCL TEMP>)>)>
	<OCEMIT DMOVEM .AC <LNAME .LCL> '(T*)>>

<DEFINE RETURN!-MIMOC (L "OPTIONAL" (FRM <>) "AUX" TYP)
	#DECL ((L) LIST (TYP FRM) <OR FALSE ATOM>)
	<COND (.FRM <GET-INTO-ACS <1 .L> BOTH A1* .FRM VALUE T*>)
	      (ELSE <GET-INTO-ACS <1 .L> BOTH A1*>)>
	<COND (<SET TYP <AC-TYPE <GET-AC A1*>>>
	       <XEMIT MOVSI A1* !<TYPE-CODE .TYP T>>)>
	<COND (.FRM
	       <OCEMIT XMOVEI F* 4 '(T*)>
	       <OCEMIT SKIPGE '(F*)>
	        <OCEMIT HRR F* -1 '(F*)>
	       <OCEMIT JRST @ <OPCODE RETURN>>)
	      (,WINNING-VICTIM
	       <OCEMIT MOVE O* '(TP*) '<- 2 ,WINNING-VICTIM>>
	       <OCEMIT SUBI TP* ',WINNING-VICTIM>
	       <OCEMIT JRST @ O*>)
	      (T <OCEMIT JRST @ <OPCODE RETURN>>)>
	<SETG LAST-UNCON T>
	<FLUSH-ACS>>

<DEFINE BIND!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 9>>)>
	<PUSHJ BIND <2 .L>>>

<DEFINE ACTIVATION!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<PUSHJ ACTIVATION>>

<DEFINE AGAIN!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT JRST @ <OPCODE AGAIN>>
	<FLUSH-ACS>>

<DEFINE RETRY!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT JRST @ <OPCODE RETRY>>
	<FLUSH-ACS>>

<DEFINE FIXBIND!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<PUSHJ FIXBIND>>

<DEFINE UNBIND!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ UNBIND>>

<DEFINE ARGS!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ ARGS <3 .L>>>

<DEFINE TUPLE!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ TUPLE <3 .L>>>

<DEFINE ARGNUM!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVEI O1* <1 .L>>
	<PUSHJ ARGNUM>>


;"General Predicates"

<DEFINE EQUAL?!-MIMOC (L "OPT" (ADDR1 <>) (ADDR2 <>) (OFF <>)
		         "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (AC1 <>) (AC2 <>)
			       (AC-T1 <>) (AC-T2 <>) NEW (TY1 <>) (TY2 <>))
	#DECL ((NEW L) LIST (ARG1 ARG2) ANY (AC1 AC2) <OR ATOM FALSE>)
	<COND (<AND <NOT .ADDR1>
		    <SET AC1 <IN-AC? .ARG1 BOTH>>
		    <NOT <SET TY1 <AC-TYPE <GET-AC .AC1>>>>>
	       <AND <SET AC2 <IN-AC? .ARG2 BOTH>>
		    <SET TY2 <AC-TYPE <GET-AC .AC2>>>>)
	      (<AND <NOT .ADDR2>
		    <SET AC2 <IN-AC? .ARG2 BOTH>>
		    <NOT <SET TY2 <AC-TYPE <GET-AC .AC2>>>>>
	       <SET TY2 .TY1>
	       <SET AC1 .AC2>
	       <SET ARG2 .ARG1>
	       <SET ADDR2 .ADDR1>
	       <SET ARG1 <2 .L>>
	       <SET ADDR1 <SET TY1 <>>>
	       <SET AC2 <IN-AC? .ADDR2 BOTH>>)
	      (.AC1
	       <AND <SET AC2 <IN-AC? .ARG2 BOTH>>
		    <SET TY2 <AC-TYPE <GET-AC .AC2>>>>)
	      (.AC2
	       <SET TY2 .TY1>
	       <SET AC1 .AC2>
	       <SET ARG2 .ARG1>
	       <SET ADDR2 .ADDR1>
	       <SET ARG1 <2 .L>>
	       <SET ADDR1 <SET TY1 <>>>
	       <SET AC2 <>>)
	      (ELSE
	       <SET AC1 <LOAD-AC .ARG1 BOTH>>)>
	<SET NEW <LABEL-UPDATE-ACS <4 .L> <> <> .AC1 .AC2>>
	<COND (<N==? .AC1 <1 .NEW>>
	       <SET AC-T1 <AC-TIME <GET-AC <SET AC1 <1 .NEW>>>>>)>
	<COND (<AND .AC2 <N==? .AC2 <2 .NEW>>>
	       <SET AC-T2 <AC-TIME <GET-AC <SET AC2 <2 .NEW>>>>>)> 
	<OCEMIT CAMN .AC1 !<COND (.ADDR2 (.OFF (.ADDR2)))
				 (.TY2 <TYPE-WORD .TY2>)
				 (.AC2 (.AC2))
				 (ELSE <OBJ-TYP .ARG2>)>>
	<OCEMIT CAME <NEXT-AC .AC1>
		     !<COND (.AC2 (<NEXT-AC .AC2>))
			    (.ADDR2 (<+ .OFF 1> (.ADDR2)))
			    (ELSE <OBJ-VAL .ARG2>)>>
	<COND (<==? <3 .L> +> <OCEMIT CAIA O* O*>)>
	<OCEMIT JRST <XJUMP <4 .L>>>
	<COND (.AC-T1
	       <AC-TIME <GET-AC .AC1> .AC-T1>
	       <AC-TIME <GET-AC <NEXT-AC .AC1>> .AC-T1>)>
	<COND (.AC-T2
	       <AC-TIME <GET-AC .AC2> .AC-T2>
	       <AC-TIME <GET-AC <NEXT-AC .AC2>> .AC-T2>)>>

<DEFINE VEQUAL?!-MIMOC (L
			"OPTIONAL" (ADDR1 <>) (ADDR2 <>) (OFF <>) (TY <>)
				   (CAI CAIN)
				   (CAM CAMN) (JUMP JUMPE) (CAIX CAIE) (CAMX CAME)
				   (JUMPX JUMPN) (SOJ SOJE) (SOJX SOJN)
				   (SKIP SKIPN) (SKIPX SKIPE)
			"AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (TAG <4 .L>) AC1 NEW
			      (AC-T1 <>) (AC-T2 <>) AC2 TEM (DIR <3 .L>)
			      BP (KL <>) TMP (SWAPPED? <>))
	#DECL ((L) LIST (ARG1 ARG2) ANY (KL) <OR FALSE ATOM>
	       (AC1 CAI CAM JUMP CAIX CAMX JUMPX TAG SKIP SKIPX) ATOM)
	<COND (<TYPE? .ARG2 FLOAT WORD LOSE CHARACTER>
	       <SET ARG2 <CHTYPE .ARG2 FIX>>)
	      (<AND <==? <PRIMTYPE .ARG2> LIST> <EMPTY? .ARG2>> <SET ARG2 0>)>
	<SET AC1
	     <COND (.ADDR1)
		   (<IN-AC? .ARG1 VALUE>)
		   (<==? .ARG2 0> X*)
		   (<AND <TYPE? .ARG2 ATOM>
			 <OR <IN-AC? .ARG2 VALUE> <NOT <TYPE? .ARG1 ATOM>>>>
		    <COND (<==? .CAI CAIGE>			       ;"LESS?"
			   <SET KL T>
			   <COND (<==? .DIR +> <SET CAI CAILE> <SET CAM CAMLE>)
				 (T <SET CAI CAIG> <SET CAM CAMG>)>)
			  (<==? .CAI CAILE>			       ;"GRTR?"
			   <SET KL T>
			   <COND (<==? .DIR +> <SET CAI CAIGE> <SET CAM CAMGE>)
				 (T <SET CAI CAIL> <SET CAM CAML>)>)>
		    <SET SWAPPED? T>
		    <SET TEM .ARG1>
		    <SET ARG1 .ARG2>
		    <SET ARG2 .TEM>
		    <COND (<IN-AC? .ARG1 VALUE>)
			  (ELSE <NEXT-AC <LOAD-AC .ARG1 BOTH>>)>)
		   (T <NEXT-AC <LOAD-AC .ARG1 BOTH>>)>>
	<SET AC2
	     <COND (.ADDR2)
		   (<AND <TYPE? .ARG2 ATOM> <IN-AC? .ARG2 VALUE>>)
		   (<AND .ADDR1 <TYPE? .ARG2 ATOM>> <LOAD-AC .ARG2 VALUE>)
		   (ELSE X*)>>
	<COND (<AND <==? .ARG2 1> <NOT <AC-UPDATE <GET-AC .AC1>>>>
	       <COND (<SET TMP <IN-AC? .ARG1 BOTH>>
		      <MUNGED-AC .TMP T>)
		     (ELSE <MUNGED-AC .AC1>)>)
	      (ELSE
	       <SET SOJ <>>)>
	<SET NEW
	     <LABEL-UPDATE-ACS .TAG
			       <>
			       T
			       <COND (<AND <N==? .AC1 X*> <N==? .AC1 O*>> .AC1)>
			       <COND (<AND <N==? .AC2 X*> <N==? .AC2 O*>> .AC2)>>>
	<COND (<AND <N==? .AC1 X*> <N==? .AC1 O*> <N==? .AC1 <1 .NEW>>>
	       <SET AC-T1 <AC-TIME <GET-AC <SET AC1 <1 .NEW>>>>>)>
	<COND (<AND <N==? .AC2 X*> <N==? .AC2 O*> <N==? .AC2 <2 .NEW>>>
	       <SET AC-T2 <AC-TIME <GET-AC <SET AC2 <2 .NEW>>>>>)>
	<COND (<AND <NOT .KL> <==? .DIR ->>
	       <SET CAI .CAIX>
	       <SET CAM .CAMX>
	       <SET JUMP .JUMPX>
	       <COND (.SOJ <SET SOJ .SOJX>)>
	       <SET SKIP .SKIPX>)>
	<COND (<AND .OFF .TY>
	       <SET BP <+ <CHTYPE <ORB 19595788288
				       <LSH <2 <CHTYPE <MEMQ .AC1 ,ACS> VECTOR>>
					    18>>
				  FIX>
			  <- .OFF 1>>>
	       <CONST-LOC .BP VALUE>
	       <OCEMIT LDB O* !<OBJ-VAL .BP>>
	       <OCEMIT CAIN O* .TY>
	       <SET CAI .CAIX>
	       <SET CAM .CAMX>
	       <SET SKIP .SKIPX>)>
	<COND (<==? .ARG2 0>
	       <COND (.OFF 
		      <COND (<TYPE? .OFF FIX>
			     <OCEMIT .SKIP O* .OFF (.AC1)>)
			    (ELSE
			     <OCEMIT .SKIP O* !.OFF>)>
		      <COND (.TY <OCEMIT CAIA O* O*>)>
		      <OCEMIT JRST <XJUMP .TAG>>)
		     (<==? .AC1 X*>
		      <OCEMIT .SKIP !<OBJ-VAL .ARG1>>
		      <OCEMIT JRST <XJUMP .TAG>>)
		     (T <OCEMIT .JUMP .AC1 <XJUMP .TAG>>)>)
	      (<AND <==? .ARG2 1> <NOT <AC-UPDATE <GET-AC .AC1>>> .SOJ>
	       <OCEMIT .SOJ .AC1 <XJUMP .TAG>>)
	      (<AND <TYPE? .ARG2 FIX> <G=? .ARG2 0> <L=? .ARG2 ,MAX-IMMEDIATE>>
	       <OCEMIT .CAI .AC1 .ARG2>
	       <OCEMIT JRST <XJUMP .TAG>>)
	      (.OFF
	       <COND (.SWAPPED?
		      <COND (<TYPE? .OFF FIX>
			     <OCEMIT .CAM .AC1 .OFF (.AC2)>)
			    (T
			     <OCEMIT .CAM .AC1 !.OFF>)>)
		     (<TYPE? .OFF FIX>
		      <OCEMIT .CAM .AC2 .OFF (.AC1)>)
		     (ELSE
		      <OCEMIT .CAM .AC2 !.OFF>)>
	       <COND (.TY <OCEMIT CAIA O* O*>)>
	       <OCEMIT JRST <XJUMP .TAG>>)
	      (T
	       <COND (<==? .AC2 X*> <OCEMIT .CAM .AC1 !<OBJ-VAL .ARG2>>)
		     (ELSE <OCEMIT .CAM .AC1 .AC2>)>
	       <OCEMIT JRST <XJUMP .TAG>>)>
	<COND (.AC-T1 <AC-TIME <GET-AC .AC1> .AC-T1>)>
	<COND (.AC-T2 <AC-TIME <GET-AC .AC2> .AC-T2>)>>

<DEFINE LESS?!-MIMOC (L)
	#DECL ((L) LIST)
	<VEQUAL?!-MIMOC .L <> <> <> <> CAIGE CAMGE JUMPL CAIL CAML JUMPGE SOJL
			SOJGE SKIPGE SKIPL>>

<DEFINE GRTR?!-MIMOC (L)
	#DECL ((L) LIST)
	<VEQUAL?!-MIMOC .L <> <> <> <> CAILE CAMLE JUMPG CAIG CAMG JUMPLE SOJG
			SOJLE SKIPLE SKIPG>>

<SETG COMPARERS [VEQUAL!-MIMOC LESS?!-MIMOC GRTR?!-MIMOC]>

;"Arithmetics"

<DEFINE MUL!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L IMUL IMULI <> IMULB>>
<DEFINE MULF!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L FMPR FMPRI <> FMPRB
						       FLOAT>>

<DEFINE SUB!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L SUB SUBI SOS SUBB>>
<DEFINE SUBF!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L FSBR FSBRI <> FSBRB
						       FLOAT>>

<DEFINE DIV!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L IDIV IDIVI <> IDIVB>> 
<DEFINE DIVF!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L FDVR FDVRI <> FDVRB
						       FLOAT>>

<DEFINE ADD!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L>>
<DEFINE ADDF!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L FADR FADRI <> FADRB
						       FLOAT>>

<DEFINE MOD!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L IDIV IDIVI MOD <>>>
<DEFINE XOR!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L XOR XORI TLC XORB>>

<DEFINE EQV!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L EQV EQVI '(TLC TRC) EQVB>>
<DEFINE OR!-MIMOC (L) #DECL ((L) LIST) <ARITH!-MIMOC .L IOR IORI TLO IORB>>

<DEFINE ARITH!-MIMOC (L
		      "OPTIONAL" (NORM ADD) (IMMED ADDI) (HACK AOS) (BO ADDB)
			         (RESTYP FIX)
		      "AUX" AC OAC (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <4 .L>)
			    HACK2 (TEM .ARG1) (IMM-OK <>) (NEG-FIRST <>))
   #DECL ((L) LIST (NORM IMMED VAL) ATOM (HACK) <OR ATOM LIST FALSE>
	  (ARG1 ARG2) <OR ATOM FIX FLOAT> (AC) <OR FALSE ATOM>)
   <COND (<AND <==? .ARG1 1> <==? .NORM ADD>> <SET ARG1 .ARG2> <SET ARG2 1>)>
   <COND (<AND <OR <AND <==? .ARG2 .VAL>
			<NOT <AND <IN-AC? .ARG1 VALUE> <WILL-DIE? .ARG1>>>>
		   <COND (<SET AC <IN-AC? .ARG2 VALUE>>
			  <OR <NOT <SET OAC <IN-AC? .ARG1 VALUE>>>
			      <AND <N==? .ARG1 .VAL>
				   <OR <NOT <AC-UPDATE <GET-AC .OAC>>>
				       <WILL-DIE? .ARG2>>
				   <AC-UPDATE <GET-AC .AC>>
				   <NOT <WILL-DIE? .ARG1>>>>)>>
	       <N==? .ARG1 0>
	       <N==? .ARG1 0.0>
	       <OR <MEMQ .NORM '[ADD MUL IOR XOR AND EQV]>
		   <AND <==? .NORM SUB> 
			<SET NEG-FIRST T>
			<SET IMMED ADDI>
			<SET NORM ADD>
			<SET BO ADDB>>
		   <AND <==? .NORM FSBR>
			<SET NEG-FIRST T>
			<SET IMMED FADRI>
			<SET NORM FADR>
			<SET BO FADRB>>>>
	  <SET ARG1 .ARG2>
	  <SET ARG2 .TEM>)
	 (<AND <OR <==? <PRIMTYPE .ARG2> WORD> <==? <PRIMTYPE .ARG2> FIX>>
	       <OR <==? .NORM ADD> <==? .NORM SUB>>
	       <L? <CHTYPE .ARG2 FIX> 0>
	       <L? <ABS <CHTYPE .ARG2 FIX>> ,MAX-IMMEDIATE>>
	  <SET ARG2 <- .ARG2>>
	  <COND (<==? .NORM ADD> <SET NORM SUB> <SET IMMED SUBI>)
		(ELSE <SET NORM ADD> <SET IMMED ADDI>)>)>
   <COND
    (<AND <OR <==? <PRIMTYPE .ARG2> WORD> <==? <PRIMTYPE .ARG2> FIX>>
	  <OR <AND <L=? <SET ARG2 <CHTYPE .ARG2 FIX>> ,MAX-IMMEDIATE>
		   <G=? .ARG2 0>>
	      <AND <==? <CHTYPE <ANDB .ARG2 262143> FIX> 0>
		   <OR <AND <OR <==? .NORM IOR> <==? .NORM XOR>>
			    <SET ARG2 <CHTYPE <LSH .ARG2 -18> FIX>>
			    <SET IMMED .HACK>
			    <COND (<AND <==? .HACK TLO> <==? .ARG2 262143>>
				   <SET IMMED HRLI>
				   <SET HACK HRROS>
				   <SET HACK2 HRRO>)
				  (ELSE T)>>
		       <AND <MEMQ .NORM '[FADR FSBR FDVR FMPR]>
			    <SET ARG2 <CHTYPE <LSH .ARG2 -18> FIX>>>>>
	      <AND <OR <==? .NORM AND> <==? .NORM EQV>>
		   <OR <AND <==? <CHTYPE <ANDB .ARG2 262143> FIX> 262143>
			    <SET ARG2 <CHTYPE <LSH <XORB .ARG2 -1> -18> FIX>>
			    <SET IMMED <1 <CHTYPE .HACK LIST>>>>
		       <AND <==? <CHTYPE <ANDB <LSH .ARG2 -18> 262143> FIX>
				 262143>
			    <SET ARG2
				 <CHTYPE <ANDB <XORB .ARG2 -1> 262143> FIX>>
			    <SET IMMED <2 <CHTYPE .HACK LIST>>>
			    <COND (<AND <==? .ARG2 262143> <==? .IMMED TRZ>>
				   <SET HACK HLLZS>
				   <SET HACK2 HLLZ>)
				  (ELSE T)>>>>>
	  <SET IMM-OK T>
	  <OR <==? .ARG1 .VAL>
	      <AND <WILL-DIE? .ARG1>
		   <N==? .VAL STACK>
		   <PROG () <DEAD!-MIMOC (.ARG1) T> 1>>
	      <AND <NOT <IN-AC? .ARG1 VALUE>>
		   <OR <==? .HACK HRROS>
		       <==? .HACK HLLZS>
		       <AND <==? .IMMED ANDI> <==? .ARG2 262143>>>>>>
     <COND (<SET AC <IN-AC? .ARG1 VALUE>>
	    <COND (<AND <N==? .VAL STACK> <N==? .ARG1 .VAL>>
		   <CLEAN-ACS .VAL>
		   <AC-CODE <AC-ITEM <GET-AC .AC> .VAL> VALUE>
		   <PROG ((X <GET-AC <GETPROP .AC AC-PAIR>>) Y)
			 #DECL ((X) AC) 
			 <COND (<OR <==? <AC-ITEM .X> .ARG1>
				    <AND <SET Y <VAR-TYPED? .ARG1>>
					 <AC-TYPE .X .RESTYP>>>
				<AC-UPDATE <AC-CODE <AC-ITEM .X .VAL> TYPE>
					   T>
				<COND (<OR <AND <AC-TYPE .X>
						<N==? <AC-TYPE .X> .RESTYP>>
					   <AND <NOT <AC-TYPE .X>>
						<NOT <AND <SET Y
							       <VAR-TYPED? .ARG1>>
							  <==? .Y .RESTYP>>>>>
				       <AC-TYPE .X .RESTYP>)>)>>)> 
	    <COND (.NEG-FIRST <OCEMIT MOVNS O* .AC>)>
	    <COND (<AND <OR <==? .NORM IDIV> <==? .NORM FDVR>>
			<NOT <AC-TYPE <GET-AC <NEXT-AC .AC>>>>>
		   <FLUSH-AC <NEXT-AC .AC>>
		   <MUNGED-AC <NEXT-AC .AC>>)>
	    <OCEMIT .IMMED .AC .ARG2>
	    <AC-UPDATE <GET-AC .AC> T>
	    <COND (<==? .HACK MOD>
		   <PROG ((X <GET-AC <NEXT-AC .AC>>) (Y <AC-TYPE .X>))
			 #DECL ((X) AC)
			 <AC-TYPE .X <>>
			 <OCEMIT SKIPGE .AC <NEXT-AC .AC>>
			 <OCEMIT ADDI .AC .ARG2>
			 <AC-TYPE .X .Y>>)>)
	   (T
	    <COND (<AND <1? .ARG2> <MEMQ .NORM '[ADD SUB]>>
		   <SET AC <ASSIGN-AC .VAL BOTH>>
		   <AC-UPDATE <GET-AC <NEXT-AC .AC>> <N==? .ARG1 .VAL>>
		   <AC-UPDATE <GET-AC .AC> <N==? .ARG1 .VAL>>
		   <OCEMIT .HACK <NEXT-AC .AC> !<OBJ-VAL .ARG1>>
		   <AC-ITEM <GET-AC <NEXT-AC .AC>> .VAL>
		   <AC-CODE <GET-AC <NEXT-AC .AC>> VALUE>
		   <AC-TYPE <GET-AC .AC> FIX>)
		  (<OR <==? .HACK HRROS>
		       <==? .HACK HLLZS>
		       <AND <==? .IMMED ANDI>
			    <==? .ARG2 262143>
			    <SET HACK HRRZS>
			    <SET HACK2 HRRZ>>>
		   <COND (<N==? .VAL STACK>
			  <SET AC <ASSIGN-AC .VAL BOTH>>
			  <AC-UPDATE <GET-AC <NEXT-AC .AC>> <N==? .VAL .ARG1>>
			  <AC-UPDATE <GET-AC .AC> <N==? .VAL .ARG1>>
			  <OCEMIT <COND (<==? .VAL .ARG1> .HACK)
					(ELSE .HACK2)>
				  <NEXT-AC .AC> !<OBJ-VAL .ARG1>>
			  <AC-ITEM <GET-AC <NEXT-AC .AC>> .VAL>
			  <AC-CODE <GET-AC <NEXT-AC .AC>> VALUE>
			  <AC-TYPE <GET-AC .AC> FIX>)
			 (ELSE
			  <OCEMIT .HACK2 O* !<OBJ-VAL .ARG1>>
			  <OCEMIT PUSH TP* !<TYPE-WORD .RESTYP>>
			  <OCEMIT PUSH TP* O*>
			  <COND (,WINNING-VICTIM
				 <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)
		  (<==? .HACK MOD>
		   <SET AC <ASSIGN-AC .VAL BOTH T>>
		   <OCEMIT MOVE .AC !<OBJ-VAL .ARG1>>
		   <OCEMIT IDIVI .AC .ARG2>
		   <OCEMIT SKIPGE O* <NEXT-AC .AC>>
		   <OCEMIT ADDI <NEXT-AC .AC> .ARG2>
		   <AC-TYPE <GET-AC .AC> FIX>
		   <AC-ITEM <GET-AC <NEXT-AC .AC>> .VAL>
		   <AC-CODE <GET-AC <NEXT-AC .AC>> VALUE>
		   <AC-UPDATE <GET-AC <NEXT-AC .AC>> T>)
		  (T
		   <COND (.NEG-FIRST
			  <SET AC <ASSIGN-AC .ARG1 BOTH>>
			  <OCEMIT MOVN <NEXT-AC .AC> !<OBJ-VAL .ARG1>>
			  <AC-TYPE <GET-AC .AC> .RESTYP>)
			 (ELSE
			  <SET AC <LOAD-AC .ARG1 BOTH T>>)>
		   <COND (<N==? .ARG1 .VAL>
			  <DEAD!-MIMOC (.ARG1) T>
			  <PROG ((X <GET-AC .AC>) Y)
				<COND (<OR <AND <AC-TYPE .X>
						<N==? <AC-TYPE .X> .RESTYP>>
					   <AND <NOT <AC-TYPE .X>>
						<NOT <AND <SET Y
							       <VAR-TYPED? .ARG1>>
							  <==? .Y .RESTYP>>>>>
				       <AC-TYPE .X .RESTYP>)>>
			  <CLEAN-ACS .VAL>
			  <ALTER-AC .AC .VAL>)>
		   <SET AC <NEXT-AC .AC>>
		   <COND (<OR <==? .NORM IDIV> <==? .NORM FDVR>>
			  <FLUSH-AC <NEXT-AC .AC>>
			  <MUNGED-AC <NEXT-AC .AC>>)>
		   <OCEMIT .IMMED .AC .ARG2>)>)>)
    (<AND <OR <==? .ARG1 0> <==? .ARG1 0.0000000>>
	  <OR <==? .NORM SUB> <==? .NORM FSBR>>>
     <COND (<SET AC <IN-AC? .ARG2 VALUE>>
	    <COND (<==? .ARG2 .VAL>
		   <AC-UPDATE <GET-AC .AC> T>
		   <OCEMIT MOVNS O* .AC>)
		  (<==? .VAL STACK>
		   <OCEMIT MOVN O* .AC>
		   <OCEMIT PUSH TP* !<TYPE-WORD .RESTYP>>
		   <OCEMIT PUSH TP* O*>
		   <COND (,WINNING-VICTIM
			  <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		  (ELSE
		   <SET OAC .AC>
		   <SET AC <ASSIGN-AC .VAL BOTH T>>
		   <AC-TYPE <GET-AC .AC> .RESTYP>
		   <AC-ITEM <GET-AC <NEXT-AC .AC>> .VAL>
		   <OCEMIT MOVN <NEXT-AC .AC> .OAC>)>)
	   (<==? .ARG2 .VAL> <OCEMIT MOVNS O* !<OBJ-VAL .ARG2>>)
	   (<==? .VAL STACK>
	    <OCEMIT MOVN O* !<OBJ-VAL .ARG2>>
	    <OCEMIT PUSH TP* !<TYPE-WORD .RESTYP>>
	    <OCEMIT PUSH TP* O*>
	    <COND (,WINNING-VICTIM
		   <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	   (ELSE
	    <SET AC <ASSIGN-AC .VAL BOTH T>>
	    <AC-TYPE <GET-AC .AC> .RESTYP>
	    <OCEMIT MOVN <NEXT-AC .AC> !<OBJ-VAL .ARG2>>)>)
    (<AND <==? .HACK MOD> <==? .ARG1 .VAL>>
     <SET AC <ASSIGN-AC .ARG1 BOTH T>>
     <OCEMIT MOVE .AC !<OBJ-VAL .ARG1>>
     <OCEMIT IDIV .AC !<OBJ-VAL .ARG2>>
     <OCEMIT SKIPGE O* <NEXT-AC .AC>>
     <OCEMIT ADD <NEXT-AC .AC> !<OBJ-VAL .ARG2>>
     <AC-TYPE <GET-AC .AC> FIX>
     <AC-ITEM <GET-AC <NEXT-AC .AC>> .ARG1>
     <AC-CODE <GET-AC <NEXT-AC .AC>> VALUE>
     <AC-UPDATE <GET-AC <NEXT-AC .AC>> T>)
    (<==? .ARG1 .VAL>
     <SET AC <NEXT-AC <LOAD-AC .ARG1 BOTH>>>
     <COND (.NEG-FIRST <OCEMIT MOVNS O* .AC>)>
     <COND (<OR <==? .NORM IDIV> <==? .NORM FDVR>>
	    <FLUSH-AC <NEXT-AC .AC>>
	    <MUNGED-AC <NEXT-AC .AC>>)>
     <OCEMIT .NORM .AC !<OBJ-VAL .ARG2>>
     <AC-UPDATE <GET-AC .AC> T>)
    (<==? .HACK MOD>
     <COND (<==? .ARG2 .VAL> <SMASH-AC T* .ARG2 VALUE>)>
     <CLEAN-ACS .VAL>
     <SET AC <ASSIGN-AC .VAL BOTH T>>
     <OCEMIT MOVE .AC !<OBJ-VAL .ARG1>>
     <COND (<TYPE? .ARG2 FIX>
	    <OCEMIT IDIVI .AC .ARG2>
	    <OCEMIT SKIPGE O* <NEXT-AC .AC>>
	    <OCEMIT ADDI <NEXT-AC .AC> .ARG2>)
	   (ELSE
	    <OCEMIT IDIV .AC !<OBJ-VAL .ARG2>>
	    <OCEMIT SKIPGE O* <NEXT-AC .AC>>
	    <OCEMIT ADD <NEXT-AC .AC> !<OBJ-VAL .ARG2>>)>
     <COND (<==? .VAL STACK>
	    <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	    <OCEMIT PUSH TP* <NEXT-AC .AC>>
	    <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>
	    <MUNGED-AC .AC T>)
	   (T
	    <AC-TYPE <GET-AC .AC> FIX>
	    <AC-ITEM <GET-AC <NEXT-AC .AC>> .ARG1>
	    <AC-CODE <GET-AC <NEXT-AC .AC>> VALUE>
	    <AC-UPDATE <GET-AC <NEXT-AC .AC>> T>)>)
    (T
     <SET TEM <>>
     <COND (<AND <==? .ARG2 .VAL>
		 <OR <AND <SET TEM <IN-AC? .ARG2 BOTH>>
			  <PROG ()
				<MUNGED-AC .TEM T>
				<SET TEM <NEXT-AC .TEM>>
				T>>
		     <AND <SET TEM <IN-AC? .ARG2 VALUE>> <MUNGED-AC .TEM>>>>)>
     <COND (<SET AC <IN-AC? .ARG1 BOTH>>
	    <COND (<WILL-DIE? .ARG1> <DEAD!-MIMOC (.ARG1) T>)
		  (<AND <AC-UPDATE <GET-AC <NEXT-AC .AC>>>
			<SET OAC <REALLY-FREE-AC-PAIR>>
			<N==? <NEXT-AC .OAC> .TEM>>
		   <COND (.NEG-FIRST
			  <OCEMIT MOVN <NEXT-AC .OAC> <NEXT-AC .AC>>
			  <SET NEG-FIRST <>>)
			 (ELSE
			  <OCEMIT MOVE <NEXT-AC .OAC> <NEXT-AC .AC>>)>
		   <SET AC .OAC>
		   <AC-TYPE <GET-AC .AC> .RESTYP>)>
	    <PROG ((TY <AC-TYPE <GET-AC .AC>>))
		  <FLUSH-AC .AC T>
		  <MUNGED-AC .AC T>
		  <AC-TYPE <GET-AC .AC> .TY>>
	    <COND (.NEG-FIRST <OCEMIT MOVNS O* <NEXT-AC .AC>>)>)
	   (ELSE
	    <SET AC <ASSIGN-AC .VAL BOTH T>>
	    <COND (<==? .TEM <NEXT-AC .AC>>
		   <OCEMIT MOVE T* .TEM>
		   <SET TEM T*>)>
	    <AC-TYPE <GET-AC .AC> .RESTYP>
	    <COND (<TYPE? .ARG1 ATOM>
		   <OCEMIT <COND (.NEG-FIRST MOVN)
				 (ELSE MOVE)> <NEXT-AC .AC> !<OBJ-VAL .ARG1>>)
		  (ELSE <LOAD-AC .ARG1 VALUE <> <> <GET-AC <NEXT-AC .AC>>>)>)>
     <COND (<AND <OR <==? .NORM IDIV> <==? .NORM FDVR>>
		 <N==? <NEXT-AC <NEXT-AC .AC>> T*>>
	    <FLUSH-AC <NEXT-AC <NEXT-AC .AC>>>
	    <MUNGED-AC <NEXT-AC <NEXT-AC .AC>>>)>
     <COND (.IMM-OK <OCEMIT .IMMED <NEXT-AC .AC> .ARG2>)
	   (.TEM <OCEMIT .NORM <NEXT-AC .AC> .TEM>)
	   (<AND .BO <==? .ARG2 .VAL>>
	    <OCEMIT .BO <NEXT-AC .AC> !<OBJ-VAL .ARG2>>)
	   (T <OCEMIT .NORM <NEXT-AC .AC> !<OBJ-VAL .ARG2>>)>
     <CLEAN-ACS .VAL>
     <AC-CODE <AC-ITEM <GET-AC .AC> .VAL> TYPE>
     <AC-UPDATE <GET-AC .AC> T>
     <AC-CODE <AC-ITEM <GET-AC <SET AC <NEXT-AC .AC>>> .VAL> VALUE>
     <AC-UPDATE <GET-AC .AC> <NOT <AND .BO <==? .ARG2 .VAL> <NOT .TEM>>>>
     <COND (<==? .VAL STACK>
	    <OCEMIT PUSH TP* !<TYPE-WORD .RESTYP>>
	    <OCEMIT PUSH TP* .AC>
	    <COND (,WINNING-VICTIM
		   <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>>

<DEFINE AND!-MIMOC (L "AUX" (ARG1 <1 .L>)
		           (ARG2 <2 .L>)
			   (VAL <4 .L>)
			   NEXTLINE AFTERNEXTLINE
			   DIR
			   DESTINATION
			   TRN (CONST <>)
			   TAC TEMP AC (MIML .MIML))
  #DECL ((TRN MIML L) LIST (ARG1 ARG2 TEMP) ANY
	 (VAL DIR DESTINATION) ATOM
	 (NEXTLINE AFTERNEXTLINE) <OR ATOM LIST FORM>)
  <COND (<AND <G=? <LENGTH .MIML> 3>
	      <OR <AND <==? <PRIMTYPE .ARG1> FIX>
		       <TYPE? .ARG2 ATOM>
		       <SET TEMP .ARG1>
		       <SET ARG1 .ARG2>
		       <SET ARG2 <CHTYPE .TEMP FIX>>>
		  <AND <TYPE? .ARG1 ATOM>
		       <==? <PRIMTYPE .ARG2> FIX>
		       <SET ARG2 <CHTYPE .ARG2 FIX>>>
		  <AND <TYPE? .ARG1 ATOM>
		       <TYPE? .ARG2 ATOM>
		       <NOT <WILL-DIE? .ARG1>>
		       <NOT <WILL-DIE? .ARG2>>
		       <N==? .ARG1 .VAL>
		       <N==? .ARG2 .VAL>
		       <PROG ()
			     <COND (<AND <IN-AC? .ARG2 VALUE>
					 <NOT <IN-AC? .ARG1 VALUE>>>
				    <SET TEMP .ARG1>
				    <SET ARG1 .ARG2>
				    <SET ARG2 .TEMP>)>
			     T>>>
	      <TYPE? <SET NEXTLINE <2 .MIML>> FORM>
	      <=? <SPNAME <1 .NEXTLINE>> "VEQUAL?">
	      <OR <AND <==? <2 .NEXTLINE> .VAL>
		       <==? <3 .NEXTLINE> 0>>
		  <AND <==? <2 .NEXTLINE> 0>
		       <==? <3 .NEXTLINE> .VAL>>>
	      <WILL-DIE? .VAL <REST .MIML>>
	      <WILL-DIE? .VAL <LAB-CODE-PNTR <FIND-LABEL <5 .NEXTLINE>>>>>
	 <SET DIR <4 .NEXTLINE>>
	 <SET DESTINATION <5 .NEXTLINE>>
	 <COND (<SET TAC <IN-AC? .ARG1 BOTH>>
		<SET AC <NEXT-AC .TAC>>)
	       (<SET AC <IN-AC? .ARG1 VALUE>>)
	       (ELSE <SET AC <NEXT-AC <SET TAC <LOAD-AC .ARG1 BOTH>>>>)>
	 <LABEL-UPDATE-ACS .DESTINATION <>>
	 <COND (<TYPE? .ARG2 ATOM> <SET CONST T>)
	       (<L=? .ARG2 *777777*> <SET TRN '(TRNN TRNE)>)
	       (<==? <CHTYPE <ANDB .ARG2 *777777*> FIX> 0>
		<SET ARG2 <CHTYPE <LSH .ARG2 -18> FIX>>
		<SET TRN '(TLNN TLNE)>)
	       (ELSE <SET CONST T>)>
	 <COND (<==? .DIR ->
		<COND (.CONST <OCEMIT TDNE .AC !<OBJ-VAL .ARG2>>)
		      (ELSE <OCEMIT <2 .TRN> .AC .ARG2>)>)
	       (<AND <TYPE? .ARG2 FIX>
		     <==? .ARG2 <CHTYPE <ANDB .ARG2 <- .ARG2>> FIX>>>
		;"Only one bit, can be TRNN..."
		<COND (.CONST <OCEMIT TDNN .AC !<OBJ-VAL .ARG2>>)
		      (ELSE <OCEMIT <1 .TRN> .AC .ARG2>)>)
	       (.CONST
		<OCEMIT TDNE .AC !<OBJ-VAL .ARG2>>
		<OCEMIT CAIA O* O*>)
	       (ELSE
		<OCEMIT <2 .TRN> .AC .ARG2>
		<OCEMIT CAIA O* O*>)>
	 <OCEMIT JRST <XJUMP .DESTINATION>>
	 <SETG NEXT-FLUSH 1>)
	(ELSE <ARITH!-MIMOC .L AND ANDI '(TLZ TRZ) ANDB>)>>

<DEFINE FLOAT!-MIMOC (L "AUX" (VAL <3 .L>) NAC)
	#DECL ((L) LIST (VAL NAC) ATOM)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FLOAT>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT FLTR O* !<OBJ-VAL <1 .L>>>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (T
	       <SET NAC <ASSIGN-AC <3 .L> BOTH>>
	       <AC-TYPE <GET-AC .NAC> FLOAT>
	       <OCEMIT FLTR <NEXT-AC .NAC> !<OBJ-VAL <1 .L>>>)>>

<DEFINE FIX!-MIMOC (L "AUX" (VAL <3 .L>) NAC)
	#DECL ((L) LIST (VAL NAC) ATOM)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT FIX O* !<OBJ-VAL <1 .L>>>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (T
	       <SET NAC <ASSIGN-AC <3 .L> BOTH>>
	       <AC-TYPE <GET-AC .NAC> FIX>
	       <OCEMIT FIX <NEXT-AC .NAC> !<OBJ-VAL <1 .L>>>)>>

<DEFINE LSH!-MIMOC (L
		    "OPTIONAL" (INS LSH)
		    "AUX" TAC (AC <>) (ARG <1 .L>) (AMT <2 .L>) (VAL <4 .L>)
			  FAC NAC AMT-AC)
   #DECL ((L) LIST (VAL INS NAC) ATOM (AMT) <OR FIX ATOM> (AC) <OR ATOM FALSE>)
   <COND
    (<AND <==? .INS LSH> <OR <==? .AMT 18> <==? .AMT -18>>>
     <DO-HWRD-INS .ARG .VAL .AMT>)
    (ELSE
     <COND (<TYPE? .ARG ATOM> <SET AC <NEXT-AC <SET TAC <LOAD-AC .ARG BOTH>>>>)>
     <COND (<SET AMT-AC <IN-AC? .AMT BOTH>>
	    <SETG FIRST-AC <>>
	    <COND (<OR <==? .AMT .VAL> <WILL-DIE? .AMT>>
		   <COND (<OR .AC
			      <SET FAC <REALLY-FREE-AC-PAIR>>>
			  <MUNGED-AC .AMT-AC T>)
			 (ELSE
			  <OCEMIT MOVE <SET FAC T*> <NEXT-AC .AMT-AC>>
			  <SET AMT-AC T*>)>)>
	    <COND (<N==? .AMT-AC T*>
		   <AC-TIME <GET-AC .AMT-AC> ,AC-STAMP>
		   <AC-TIME <GET-AC <NEXT-AC .AMT-AC>> ,AC-STAMP>
		   <SET AMT-AC <NEXT-AC .AMT-AC>>)>)>
     <COND (<AND <N==? .ARG .VAL>
		 <TYPE? .ARG ATOM>
		 <NOT <WILL-DIE? .ARG>>
		 <NOT <AND <NOT <AC-UPDATE <GET-AC .AC>>>
			   <PROG ()
				 <FLUSH-AC .TAC T>
				 <MUNGED-AC .TAC T>
				 1>>>>
	    <SET NAC <ASSIGN-AC .VAL BOTH T>>
	    <AC-TYPE <GET-AC .NAC> FIX>
	    <OCEMIT MOVE <SET NAC <NEXT-AC .NAC>> .AC>)
	   (.AC
	    <AC-TIME <GET-AC .TAC> ,AC-STAMP>
	    <AC-TIME <GET-AC <SET NAC .AC>> ,AC-STAMP>)
	   (ELSE
	    <AC-TYPE <GET-AC <SET NAC <ASSIGN-AC .VAL BOTH T>>> FIX>
	    <SET NAC <NEXT-AC .NAC>>)>
     <COND (<TYPE? .AMT FIX>
	    <COND (<NOT <TYPE? .ARG ATOM>>
		   <LOAD-NUM-INTO-AC .ARG .NAC>)>
	    <OCEMIT .INS .NAC .AMT>)
	   (.AMT-AC
	    <COND (<==? .AMT-AC .NAC>
		   <OCEMIT MOVE T* .AMT-AC>
		   <SET AMT-AC T*>)>
	    <COND (<NOT <TYPE? .ARG ATOM>>
		   <LOAD-NUM-INTO-AC .ARG .NAC>)>
	    <OCEMIT .INS .NAC (.AMT-AC)>)
	   (<WILL-DIE? .AMT>
	    <GET-INTO-ACS .AMT VALUE T*>
	    <COND (<NOT <TYPE? .ARG ATOM>>
		   <LOAD-NUM-INTO-AC .ARG .NAC>)>
	    <OCEMIT .INS .NAC '(T*)>)
	   (ELSE
	    <AC-TIME <GET-AC .NAC> ,AC-STAMP>
	    <AC-TIME <GET-AC <GETPROP .NAC AC-PAIR>> ,AC-STAMP>
	    <COND (<NOT <TYPE? .ARG ATOM>>
		   <LOAD-NUM-INTO-AC .ARG .NAC>)>
	    <SET AMT-AC <LOAD-AC .AMT BOTH>>
	    <OCEMIT .INS .NAC (<NEXT-AC .AMT-AC>)>)>
     <COND
      (<==? .NAC .AC>
       <CLEAN-ACS .VAL>
       <AC-CODE <AC-ITEM <AC-TYPE <AC-UPDATE <GET-AC .TAC> T> FIX> .VAL> TYPE>
       <AC-CODE
	<AC-ITEM <AC-TYPE <AC-UPDATE <GET-AC .AC> T> <>> .VAL>
	VALUE>)>
     <COND (<==? .VAL STACK>
	    <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	    <OCEMIT PUSH TP* .NAC>
	    <COND (,WINNING-VICTIM
		   <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>>

<DEFINE LOAD-NUM-INTO-AC (V AC) #DECL ((V) FIX (AC) ATOM)
	<COND (<AND <G=? .V 0> <L=? .V ,MAX-IMMEDIATE>>
	       <OCEMIT MOVEI .AC .V>)
	      (<AND <L? .V 0> <L=? <ABS .V> ,MAX-IMMEDIATE>>
	       <OCEMIT MOVNI .AC <- .V>>)
	      (<0? <CHTYPE <ANDB .V 262143> FIX>>
	       <OCEMIT MOVSI .AC <CHTYPE <LSH .V -18> FIX>>)
	      (ELSE <OCEMIT MOVE .AC !<OBJ-LOC .V 1>>)>>

<DEFINE DO-HWRD-INS (SRC VAL AMT "AUX" AC)
	#DECL ((AMT) FIX)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT <COND (<==? .AMT 18> HRLZ)
			     (ELSE HLRZ)>
		       O* !<OBJ-VAL .SRC>>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (<==? .SRC .VAL>
	       <COND (<SET AC <IN-AC? .SRC VALUE>>
		      <COND (<==? .AMT 18> <OCEMIT HRLZS O* .AC>)
			    (ELSE <OCEMIT HLRZS O* .AC>)>
		      <AC-UPDATE <GET-AC .AC> T>)
		     (<==? .AMT 18>
		      <OCEMIT HRLZS !<OBJ-VAL .SRC>>)
		     (ELSE
		      <OCEMIT HLRZS !<OBJ-VAL .SRC>>)>)
	      (ELSE
	       <SET AC <ASSIGN-AC .VAL BOTH>>
	       <AC-TYPE <GET-AC .AC> FIX>
	       <COND (<==? .AMT 18>
		      <OCEMIT HRLZ <NEXT-AC .AC> !<OBJ-VAL .SRC>>)
		     (ELSE <OCEMIT HLRZ <NEXT-AC .AC> !<OBJ-VAL .SRC>>)>)>>

<DEFINE ROT!-MIMOC (L) #DECL ((L) LIST) <LSH!-MIMOC .L ROT>>

<DEFINE RANDOM!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ RANDOM <3 .L>>>

;"Random user RECORD stuff"

<DEFINE TEMPLATE-TABLE!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<SMASH-AC A1* <2 .L> BOTH>
	<PUSHJ TEMPLATE-TABLE>>

<DEFINE IRECORD!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<OCEMIT MOVE C1* !<OBJ-VAL <3 .L>>>
	<PUSHJ IRECORD <5 .L>>>

;"Random GC stuff"

<DEFINE MARKL!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<MUNGED-AC O*>
	<OCEMIT MOVSI O* *200000*>
	<OCEMIT <COND (<==? <2 .L> 0> ANDCAM) (T IORM)> O* 1 (<NEXT-AC .AC>)>>

<DEFINE MARK-JOIN (NUM "AUX" NAC)
	<MUNGED-AC O*>
	<OCEMIT MOVSI O* *200000*>
	<COND (<TYPE? .NUM FIX>
	       <OCEMIT <COND (<0? .NUM> ANDCAM) (T IORM)> O* '(T*)>)
	      (ELSE
	       <OCEMIT IORM O* '(T*)>
	       <COND (<SET NAC <IN-AC? .NUM VALUE>>)
		     (ELSE
		      <SMASH-AC O* .NUM VALUE>
		      <SET NAC O*>)>
	       <OCEMIT MOVEM .NAC 1 '(T*)>)>>

<DEFINE MARKR!-MIMOC (L "AUX" AC (END <GENLBL "END">))
	#DECL ((L) LIST (AC END) ATOM)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<OCEMIT XMOVEI O* '(TP*)>
	<OCEMIT CAMG <NEXT-AC .AC> O*>
	 <OCEMIT JRST <XJUMP .END>>
	<OCEMIT HRRZ T* .AC>
	<OCEMIT LSH T* -1>
	<OCEMIT ADD T* <NEXT-AC .AC>>
	<MARK-JOIN <2 .L>>
	<LABEL .END>>

<DEFINE MARKU!-MIMOC (L)
	#DECL ((L) LIST)
	<MARK!-MIMOC MARKU <1 .L> <2 .L>>>

<DEFINE MARKUS!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<OCEMIT MOVEI T* 5 (.AC)>
	<OCEMIT ADJBP T* <NEXT-AC .AC>>
	<OCEMIT TLZ T* *770000*>
	<MARK-JOIN <2 .L>>>

<DEFINE MARKUB!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<OCEMIT MOVEI T* 4 (.AC)>
	<OCEMIT ADJBP T* <NEXT-AC .AC>>
	<OCEMIT TLZ T* *770000*>
	<MARK-JOIN <2 .L>>>

<DEFINE MARKUV!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<OCEMIT HRRZ T* .AC>
	<OCEMIT LSH T* 1>
	<OCEMIT ADD T* <NEXT-AC .AC>>
	<MARK-JOIN <2 .L>>>

<DEFINE MARKUU!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<OCEMIT HRRZ T* .AC>
	<OCEMIT ADD T* <NEXT-AC .AC>>
	<MARK-JOIN <2 .L>>>
      
<DEFINE MARK!-MIMOC (NAM OBJ VAL)
	#DECL ((NAM) ATOM (OBJ) ANY (VAL) FIX)
	<UPDATE-ACS>
	<SMASH-AC A1* .OBJ BOTH>
	<COND (<0? .VAL> <OCEMIT MOVEI B1* 0>)
	      (T <OCEMIT MOVSI B1* *200000*>)>
	<PUSHJ .NAM>>

<DEFINE MARKL?!-MIMOC (L "AUX" AC NAC)
	#DECL ((L) LIST (AC NAC) ATOM)
	<SET AC <LOAD-AC <1 .L> VALUE>>
	<SET NAC <ASSIGN-AC <3 .L> BOTH T>>
        <AC-TYPE <GET-AC .NAC> FIX>
	<OCEMIT LDB
		<NEXT-AC .NAC>
		!<OBJ-VAL
		   <CHTYPE <ORB <LSH <+ *420100* <2 <CHTYPE <MEMQ .AC ,ACS>
							    VECTOR>>> 18> 1>
			   FIX>>>
	<COND-PUSH <3 .L> .NAC>>

<DEFINE MARKR?!-MIMOC (L "AUX" AC NAC (END <GENLBL "END">) RES (REL <>))
	#DECL ((L) LIST (AC NAC END) ATOM)
	<COND (<==? <LENGTH .L> 4>
	       <SET RES <4 .L>>
	       <SET REL T>)
	      (ELSE
	       <SET RES <3 .L>>)>
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<SET NAC <ASSIGN-AC .RES BOTH T>>
	<OCEMIT MOVEI <NEXT-AC .NAC> 1>
	<COND (.REL <OCEMIT MOVE .NAC !<TYPE-WORD FIX>>)>
	<OCEMIT XMOVEI O* '(TP*)>
	<OCEMIT CAMG <NEXT-AC .AC> O*>
	 <OCEMIT JRST <XJUMP .END>>
	<OCEMIT HRRZ T* .AC>
	<OCEMIT LSH T* -1>
	<MARK?-JOIN .AC .NAC .REL <> .REL>
	<LABEL .END>
	<COND-PUSH .RES .NAC>>

<DEFINE MARKU?!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ MARKU? <3 .L>>>

<DEFINE MARKUS?!-MIMOC (L "AUX" AC NAC RES (REL <>))
	#DECL ((L) LIST (AC NAC) ATOM)
	<COND (<==? <LENGTH .L> 4>
	       <SET RES <4 .L>>
	       <SET REL T>)
	      (ELSE
	       <SET RES <3 .L>>)>
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<SET NAC <ASSIGN-AC .RES BOTH T>>
	<OCEMIT MOVEI T* 5 (.AC)>
	<MARK?-JOIN .AC .NAC .REL T>
	<COND-PUSH .RES .NAC>>

<DEFINE MARKUB?!-MIMOC (L "AUX" AC NAC RES (REL <>))
	#DECL ((L) LIST (AC NAC) ATOM)
	<COND (<==? <LENGTH .L> 4>
	       <SET RES <4 .L>>
	       <SET REL T>)
	      (ELSE
	       <SET RES <3 .L>>)>
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<SET NAC <ASSIGN-AC .RES BOTH T>>
	<OCEMIT MOVEI T* 4 (.AC)>
	<MARK?-JOIN .AC .NAC .REL T>
	<COND-PUSH .RES .NAC>>

<DEFINE MARKUU?!-MIMOC (L "AUX" AC NAC RES (REL <>))
	#DECL ((L) LIST (AC NAC) ATOM)
	<COND (<==? <LENGTH .L> 4>
	       <SET RES <4 .L>>
	       <SET REL T>)
	      (ELSE
	       <SET RES <3 .L>>)>
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<SET NAC <ASSIGN-AC .RES BOTH T>>
	<OCEMIT HRRZ T* .AC>
	<MARK?-JOIN .AC .NAC .REL>
	<COND-PUSH .RES .NAC>>

<DEFINE MARKUV?!-MIMOC (L "AUX" AC NAC RES (REL <>))
	#DECL ((L) LIST (AC NAC) ATOM)
	<COND (<==? <LENGTH .L> 4>
	       <SET RES <4 .L>>
	       <SET REL T>)
	      (ELSE
	       <SET RES <3 .L>>)>
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<SET AC <LOAD-AC <1 .L> BOTH>>
	<SET NAC <ASSIGN-AC .RES BOTH T>>
	<OCEMIT HRRZ T* .AC>
	<OCEMIT LSH T* 1>
	<MARK?-JOIN .AC .NAC .REL>
	<COND-PUSH .RES .NAC>>

<DEFINE COND-PUSH (ITM AC)
	#DECL ((ITM AC) ATOM)
	<COND (<==? .ITM STACK>
	       <OCEMIT PUSH TP* .AC>
	       <OCEMIT PUSH TP* <NEXT-AC .AC>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE MARK?-JOIN (AC NAC REL "OPT" (DIV <>) (NO-LOAD-TYPE <>)
		    "AUX" (L1 <GENLBL "L1">) (L2 <GENLBL "L2">))
	#DECL ((AC NAC L1 L2) ATOM)
	<COND (.DIV
	       <OCEMIT ADJBP T* <NEXT-AC .AC>>
	       <OCEMIT TLZ T* *770000*>)
	      (ELSE
	       <OCEMIT ADD T* <NEXT-AC .AC>>)>
	<COND (<NOT .REL>
	       <AC-TYPE <GET-AC .NAC> FIX>)>
	<OCEMIT LDB <NEXT-AC .NAC> !<OBJ-VAL ,LDB-PAREN-T>>
	<COND (.REL
	       <OCEMIT JUMPE <NEXT-AC .NAC> <XJUMP .L1>>
	       <OCEMIT MOVE .NAC .AC>
	       <OCEMIT MOVE <NEXT-AC .NAC> 1 '(T*)>
	       <OCEMIT JRST <XJUMP .L2>>
	       <LABEL .L1>
	       <COND (<NOT .NO-LOAD-TYPE>
		      <OCEMIT MOVE .NAC !<TYPE-WORD FIX>>)>
	       <OCEMIT MOVEI <NEXT-AC .NAC> 0>
	       <LABEL .L2>)>>



<SETG LDB-PAREN-T -32193642496>

<MANIFEST LDB-PAREN-T>

<DEFINE SWNEXT!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT DMOVE O1* !<OBJ-TYP <1 .L>>>
	<OCEMIT MOVE A1* !<OBJ-VAL <2 .L>>>
	<PUSHJ SWNEXT <4 .L>>>

<DEFINE NEXTS!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<PUSHJ NEXTS <3 .L>>>

<DEFINE CONTENTS!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<SMASH-AC T* <1 .L> VALUE>
	<SET AC <ASSIGN-AC <3 .L> BOTH T>>
	<OCEMIT DMOVE .AC '(T*)>
	<OCEMIT TLZE .AC *40*>
	<OCEMIT XMOVEI <NEXT-AC .AC> 1 '(T*)>
	<COND (<==? <3 .L> STACK>
	       <OCEMIT PUSH TP* .AC>
	       <OCEMIT PUSH TP* <NEXT-AC .AC>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE PUTS!-MIMOC (L "AUX" AC)
	#DECL ((L) LIST (AC) ATOM)
	<SET AC <LOAD-AC <2 .L> BOTH>> 
	<SMASH-AC T* <1 .L> VALUE>
	<FLUSH-AC O*>
	<MUNGED-AC O*>
	<OCEMIT MOVE O* '(T*)>
	<OCEMIT TLNN O* *40*>
	<OCEMIT DMOVEM .AC '(T*)>>

<DEFINE ALLOCL!-MIMOC (L "AUX" (AC <ASSIGN-AC <3 .L> BOTH T>))
	#DECL ((L) LIST (AC) ATOM)
	<OCEMIT MOVE .AC !<TYPE-WORD LIST>>
	<OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL <1 .L>>>
	<COND (<==? <3 .L> STACK>
	       <OCEMIT PUSH TP* .AC>
	       <OCEMIT PUSH TP* <NEXT-AC .AC>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE ALLOCUV!-MIMOC (L)
	#DECL ((L) LIST)
	<ALLOC-JOIN <1 .L> <2 .L> <4 .L> VECTOR>>

<DEFINE ALLOCUU!-MIMOC (L)
	#DECL ((L) LIST)
	<ALLOC-JOIN <1 .L> <2 .L> <4 .L> UVECTOR>>

<DEFINE ALLOCUS!-MIMOC (L "OPTIONAL" (BYTES? <>) "AUX" AC)
	#DECL ((L) LIST)
	<SET AC <ASSIGN-AC <4 .L> BOTH T>>
	<OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL <1 .L>>>
	<OCEMIT ADD <NEXT-AC .AC> !<OBJ-VAL <COND (.BYTES? *577777777777*)
						  (T *657777777777*)>>>
	<OCEMIT MOVE .AC !<OBJ-TYP <2 .L>>>
	<COND (<==? <4 .L> STACK>
	       <OCEMIT PUSH TP* .AC>
	       <OCEMIT PUSH TP* <NEXT-AC .AC>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE ALLOCUB!-MIMOC (L)
  <ALLOCUS!-MIMOC .L T>>

<DEFINE ALLOCR!-MIMOC (L) #DECL ((L) LIST)
	<ALLOC-JOIN <1 .L> <2 .L> <4 .L> RECORD>>

<DEFINE ALLOC-JOIN (WHERE OLD NEW TYP "AUX" AC)
	<COND (<==? .NEW STACK>
	       <OCEMIT PUSH TP* !<OBJ-TYP .OLD>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT PUSH TP* !<OBJ-VAL .WHERE>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (ELSE
	       <SET AC <ASSIGN-AC .NEW BOTH T>>
	       <OCEMIT MOVE .AC !<OBJ-TYP .OLD>>
	       <OCEMIT MOVE <NEXT-AC .AC> !<OBJ-VAL .WHERE>>)>>

<DEFINE BLT!-MIMOC (L)
	#DECL ((L) LIST)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<OCEMIT MOVE T* !<OBJ-VAL <3 .L>>>
	<OCEMIT XBLT T* !<OBJ-VAL *020000000000*>>>

<DEFINE RELL!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ RELL>>

<DEFINE RELU!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ RELU>>

<DEFINE RELR!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ RELR>>

<DEFINE LOOP!-MIMOC (L "AUX" VARS (LBNM <2 .MIML>) LB LFS)
    #DECL ((L VARS MIML) LIST (LB) LAB (LFS) <OR FALSE LABSTATE>)
     <COND
      (<TYPE? .LBNM ATOM>
       <SET LB ,.LBNM>
       <SET LFS <LAB-FINAL-STATE .LB>>
       <SETG NEXT-LOOP T>
       <SETG LOOPTAGS (<2 .MIML> !,LOOPTAGS)>
       <COND
        (<AND <GASSIGNED? DO-LOOPS> ,DO-LOOPS>
	 <SET VARS <MAPF ,LIST 1 .L>>
	 <MAPF <>
	       <FUNCTION (LL "AUX" (ITM <1 .LL>) NEED)
		 #DECL ((LL) LIST)
		 <COND
		  (<MEMQ VALUE <SET LL <REST .LL>>>
		   <COND (<NOT <EMPTY? <REST .LL>>> <SET NEED BOTH>)
			 (ELSE <SET NEED VALUE>)>)
		  (ELSE <SET NEED TYPE>)>
		 <COND
		  (<NOT <IN-AC? .ITM .NEED>>
		   <COND
		    (<NOT .LFS>
		     <REPEAT ((ACS <REST ,AC-TABLE>) A1 A2 IT)
			     #DECL ((ACS) VECTOR (A1 A2) AC)
			     <COND (<==? <AC-NAME <SET A1 <1 .ACS>>> X*>
				    <RETURN>)>
			     <COND
			      (<AND <OR <==? .NEED VALUE>
					<NOT <SET IT <AC-ITEM .A1>>>
					<TYPE? .IT LOSE>
					<AND <NOT <AC-UPDATE .A1>>
					     <NOT <MEMQ .IT .VARS>>>>
				    <OR <==? .NEED TYPE>
					<NOT <SET IT <AC-ITEM <SET A2
								   <2 .ACS>>>>>
					<TYPE? .IT LOSE>
					<AND <NOT <AC-UPDATE .A2>>
					     <NOT <MEMQ .IT .VARS>>>>>
			       <COND (<==? .NEED VALUE>
				      <LOAD-AC .ITM VALUE <> <> .A2>)
				     (<==? .NEED TYPE>
				      <LOAD-AC .ITM TYPE <> <> .A1>)
				     (ELSE
				      <LOAD-AC .ITM BOTH <> <> .A1 .A2>)>
			       <RETURN>)>
			     <SET ACS <REST .ACS 2>>>)
		    (ELSE
		     <REPEAT ((V <CHTYPE .LFS VECTOR>) ACS1 ACS2 ONE)
		       #DECL ((V) VECTOR (ACS1 ACS2) ACSTATE)
		       <COND (<EMPTY? .V> <RETURN>)>
		       <COND
			(<OR <SET ONE
				  <==? <LATM <ACS-LOCAL <SET ACS1 <1 .V>>>>
				       .ITM>>
			     <==? <LATM <ACS-LOCAL <SET ACS2 <2 .V>>>> .ITM>>
			 <COND (.ONE
				<LOAD-AC .ITM
					 BOTH
					 <COND (<==? <LATM <ACS-LOCAL
							    <SET ACS2 <2 .V>>>>
						     .ITM>
						<OR <NOT <ACS-STORED .ACS2>>
						    <NOT <ACS-STORED .ACS1>>>)
					       (ELSE
						<NOT <ACS-STORED .ACS1>>)>
					 <> <ACS-AC .ACS1> <ACS-AC .ACS2>>)
			       (ELSE
				<LOAD-AC .ITM
					 VALUE
					 <NOT <ACS-STORED .ACS2>>
					 <> <ACS-AC .ACS2>>)>
			 <RETURN>)>
			     <SET V <REST .V 2>>>)>)>>
	       .L>)>)>>

<DEFINE INTGO!-MIMOC (L) T>

<DEFINE SAVE!-MIMOC (L)
        #DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> VALUE>
	<SMASH-AC A2* <2 .L> VALUE>
	<SMASH-AC B1* <3 .L> VALUE>
	<PUSHJ SAVE <5 .L>>>

<DEFINE RESTORE!-MIMOC (L)
	#DECL ((L) LIST)
	<SMASH-AC A1* <1 .L> VALUE>
	<PUSHJ RESTORE <3 .L>>>

<DEFINE QUIT!-MIMOC (L)
	<UPDATE-ACS>
	<COND (<NOT <EMPTY? .L>>
	       ; "Stuff the return value into B, with authentication in A"
	       <SMASH-AC A2* <1 .L> VALUE>
	       <SMASH-AC A1* *777777000003* VALUE>)>
	<PUSHJ QUIT>>

<DEFINE SETSIZ!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ SETSIZ <3 .L>>>

<DEFINE RNTIME!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<COND (<EMPTY? .L>
	       <PUSHJ RNTIME>)
	      (T
	       <PUSHJ RNTIME <2 .L>>)>>

"Instructions for seedup of NTH,REST,EMPTY? and MONAD? of unknown type"

<DEFINE NTH1!-MIMOC (L)
	<NEW-FUNNY-CALL *154* .L>
	<ALTER-AC A1* <3 .L>>
	<PUSHJ-VAL <3 .L>>>

<DEFINE REST1!-MIMOC (L)
	<NEW-FUNNY-CALL *155* .L>
	<ALTER-AC A1* <3 .L>>
	<PUSHJ-VAL <3 .L>>>

<DEFINE EMPTY?!-MIMOC (L)
	<FUNNY-PRED *153* .L>>

<DEFINE MONAD?!-MIMOC (L)
	<FUNNY-PRED *156* .L>>

<DEFINE FUNNY-PRED (LOC L "AUX" (FLAG <2 .L>) (TAG <3 .L>)) 
	#DECL ((L) LIST)
	<NEW-FUNNY-CALL .LOC .L .TAG>
	<COND (<==? .FLAG +> <OCEMIT CAIA O* O*>)>
	<OCEMIT JRST <XJUMP .TAG>>>

<DEFINE NEW-FUNNY-CALL (LOC L "OPT" (TAG <>) "AUX" AC) 
	#DECL ((L) LIST)
	<COND (<N==? <SET AC <IN-AC? <1 .L> BOTH>> A1*>
	       <FLUSH-AC A1* T>
	       <MUNGED-AC A1* T>
	       <COND (.AC
		      <OCEMIT DMOVE A1* .AC>
		      <MUNGED-AC .AC T>
		      <ALTER-AC A1* <1 .L>>)
		     (ELSE
		      <SMASH-AC A1* <1 .L> BOTH>)>)>
	<COND (.TAG <LABEL-UPDATE-ACS .TAG <>>)
	      (ELSE
	       <COND (<N==? <1 .L> <3 .L>>
		      <CLEAN-ACS <3 .L>>
		      <COND (<NOT <WILL-DIE? <1 .L>>>
			     <FLUSH-AC A1* T>)>)>
	       <MUNGED-AC A1* T>)>
	<OCEMIT JSP T* @ .LOC>>

<DEFINE LEGAL?!-MIMOC (L)
	#DECL ((L) LIST)
	<FLUSH-AC A1* T>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ LEGAL? <3 .L>>>


<DEFINE SETZONE!-MIMOC (L)
	#DECL ((L) LIST)
	<SMASH-AC A1* <1 .L> BOTH>
	<COND (<==? <LENGTH .L> 3>
	       <PUSHJ SETZONE <3 .L>>)
	      (ELSE
	       <PUSHJ SETZONE>)>>

<DEFINE TYPEW!-MIMOC (L) #DECL ((L) LIST)
	<OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<PUSHJ TYPEW <4 .L>>>

<DEFINE TYPEWC!-MIMOC (L "AUX" AC) #DECL ((L) LIST)
	<SET AC <ASSIGN-AC <3 .L> BOTH>>
	<OCEMIT HLRZ <NEXT-AC .AC> !<OBJ-VAL <1 .L>>>
	<AC-TYPE <GET-AC .AC> TYPE-C>>


<DEFINE FATAL!-MIMOC (L) #DECL ((L) LIST)
	<SMASH-AC A1* <1 .L> BOTH>
	<COND (<EMPTY? <REST .L>> <PUSHJ FATAL>)
	      (ELSE <PUSHJ FATAL <3 .L>>)>>



<DEFINE GETBITS!-MIMOC (L
			"AUX" (WD <1 .L>) (WL <2 .L>) (SHL <3 .L>) (DST <5 .L>)
			      (TAC? <IN-AC? .WD BOTH>) AN BP
			      (AC? <IN-AC? .WD VALUE>) (OL <>) AC (W 0) (SH 0)
			      (IX <>) MSK)
   #DECL ((L) LIST (OL) <OR FALSE LIST>)
   <COND (<TYPE? .WL FIX> <SET W .WL>)>
   <COND (<TYPE? .SHL FIX> <SET SH .SHL>)>
   <COND (<TYPE? .WD ATOM> <SET OL <OBJ-LOC .WD 1>>)>
   <SET BP <CHTYPE <ORB <LSH .SH 30> <LSH .W 24>> FIX>>
   <COND (.AC? <SET AN <2 <CHTYPE <MEMQ .AC? ,ACS> VECTOR>>>)>
   <COND (.AC? <SET BP <CHTYPE <ORB .BP .AN> CONSTANT>>)
	 (.OL
	  <SET BP
	       <CHTYPE (<2 .OL>
			<+ <CHTYPE <LSH <2 <MEMQ <1 <CHTYPE <3 .OL> LIST>>
						 ,ACS>> 18> FIX>
			   <CHTYPE <1 .OL> FIX>
			   .BP>)
		       CONST-W-LOCAL>>)>
   <COND
    (<AND <TYPE? .WL FIX> <TYPE? .SHL FIX>>
     <SET AC <ASSIGN-AC .DST BOTH T>>
     <CONST-LOC .BP VALUE>
     <OCEMIT LDB <NEXT-AC .AC> !<OBJ-VAL .BP>>
     <AC-TYPE <GET-AC .AC> FIX>)
    (<TYPE? .WL FIX>
     <COND (<NOT <AND .AC? <OR <==? .DST .WD>
			       <AND <WILL-DIE? .WD>
				    <PROG () <DEAD!-MIMOC (.WD) T> 1>>>>>
	    <SET AC
		 <ASSIGN-AC <COND (<AND <==? .SHL .DST> <IN-AC? .SHL VALUE>>
				   .WD)
				  (ELSE .DST)>
			    BOTH
			    T>>
	    <AC-TYPE <GET-AC .AC> FIX>
	    <SET AC <NEXT-AC .AC>>
	    <OCEMIT MOVE .AC !<OBJ-VAL .WD>>)
	   (.TAC?
	    <AC-TYPE <GET-AC .TAC?> FIX>
	    <SET AC .AC?>
	    <ALTER-AC .TAC? .DST>)
	   (ELSE
	    <SET AC <ASSIGN-AC .DST BOTH T>>
	    <AC-TYPE <GET-AC .AC> FIX>
	    <OCEMIT MOVE <SET AC <NEXT-AC .AC>> .AC?>)>
     <FLUSH-AC T*>
     <MUNGED-AC T*>
     <OCEMIT MOVN T* !<OBJ-VAL .SHL>>
     <OCEMIT LSH
	     .AC
	     '(T*)>
     <COND (<L=? <SET W <CHTYPE <XORB <LSH -1 .W> -1> FIX>> 262143>
	    <OCEMIT ANDI .AC .W>)
	   (ELSE <OCEMIT TLZ .AC <CHTYPE <LSH <XORB .W -1> -18> FIX>>)>
     <COND (<==? .DST .SHL>
	    <CLEAN-ACS .DST>
	    <ALTER-AC <GETPROP .AC AC-PAIR> .DST>
	    <SETG ACA-AC <SETG ACA-BOTH <SETG ACA-ITEM <>>>>
	    <AC-TYPE <GET-AC <GETPROP .AC AC-PAIR>> FIX>)>)
    (<TYPE? .SHL FIX>
     <COND (<AND .TAC? <OR <==? .WD .DST> <WILL-DIE? .WD>>> <SET AC O*>)
	   (ELSE
	    <COND (<==? .WL .DST>
		   <COND (<SET AC <IN-AC? .WL BOTH>>
			  <SET IX <NEXT-AC .AC>>
			  <MUNGED-AC .AC T>
			  <AC-TIME <GET-AC .AC> ,AC-STAMP>
			  <AC-TIME <GET-AC <NEXT-AC .AC>> ,AC-STAMP>)
			 (<SET AC <IN-AC? .WL VALUE>>
			  <SET IX .AC>
			  <AC-TIME <GET-AC .AC> ,AC-STAMP>
			  <MUNGED-AC .AC>)>)>
	    <AC-TYPE <GET-AC <SET AC <ASSIGN-AC .DST BOTH T>>> FIX>
	    <SET AC <NEXT-AC .AC>>)>
     <SET MSK <CHTYPE <LSH -1 .SH> FIX>>
     <COND (<==? <CHTYPE <ANDB .MSK 262143> FIX> 0>
	    <OCEMIT MOVSI .AC <CHTYPE <LSH .MSK -18> FIX>>)
	   (ELSE <OCEMIT HRROI .AC <CHTYPE <ANDB .MSK 262143> FIX>>)>
     <OCEMIT LSH
	     .AC
	     !<COND (.IX ((.IX)))
		    (<AND <N==? .WL .DST> <SET IX <IN-AC? .WL VALUE>>>
		     ((.IX)))
		    (ELSE (@ !<OBJ-VAL .WL>))>>
     <COND
      (<==? .AC O*>
       <OCEMIT ANDCA .AC? O*>
       <OCEMIT LSH .AC? <- .SH>>
       <CLEAN-ACS .DST>
       <AC-UPDATE <AC-ITEM <AC-CODE <AC-TYPE <GET-AC .TAC?> FIX> TYPE> .DST> T>
       <AC-CODE <AC-TYPE <AC-ITEM <AC-UPDATE <GET-AC <SET AC .AC?>> T> .DST>
			 <>>
		VALUE>)
      (ELSE
       <OCEMIT ANDCA .AC !<COND (.AC? (.AC?)) (ELSE <OBJ-VAL .WD>)>>
       <OCEMIT LSH .AC <- .SH>>)>)
    (ELSE
     <COND (.AC? <OCEMIT MOVEI O* .AC?>)
	   (ELSE <CONST-LOC .BP VALUE> <OCEMIT MOVE O* !<OBJ-VAL .BP>>)>
     <OCEMIT DPB
	     <COND (<IN-AC? .SHL VALUE>) (ELSE <NEXT-AC <LOAD-AC .SHL BOTH>>)>
	     !<OBJ-VAL <SET BP <CHTYPE 32312918016 CONSTANT>>>>
     <CONST-LOC .BP VALUE>
     <OCEMIT DPB
	     <COND (<IN-AC? .WL VALUE>) (ELSE <NEXT-AC <LOAD-AC .WL BOTH>>)>
	     !<OBJ-VAL <SET BP <CHTYPE 25870467072 CONSTANT>>>>
     <CONST-LOC .BP VALUE>
     <SET AC <ASSIGN-AC .DST BOTH T>>
     <OCEMIT LDB <NEXT-AC .AC> O*>
     <AC-TYPE <GET-AC .AC> FIX>)>
   <COND (<==? .DST STACK>
	  <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	  <OCEMIT PUSH TP* <NEXT-AC .AC>>
	  <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE PUTBITS!-MIMOC (L "AUX" (WL <2 .L>) (SHL <3 .L>) (NEW <4 .L>) (OLD <1 .L>)
				AC? TAC? NAC (DST <6 .L>) (FLIP <>))
	#DECL ((L) LIST)
	<COND (<AND <==? .WL 18> <OR <==? .SHL 0> <==? .SHL 18>>>
	       <COND (<OR <==? .OLD 0>
			  <==? .OLD -1>
			  <AND <==? .SHL 0>
			       <OR <AND <NOT <IN-AC? .OLD VALUE>>
					<IN-AC? .NEW VALUE>>
				   <==? .NEW .DST>>>>
		      <SET FLIP T>
		      <SET NEW .OLD>
		      <SET OLD <4 .L>>)>
	       <COND (<OR <AND <SET TAC? <IN-AC? .OLD BOTH>>
			       <SET AC? <NEXT-AC .TAC?>>>
			  <AND <SET AC? <IN-AC? .OLD VALUE>>
			       <SET TAC? <GETPROP .AC? AC-PAIR>>>
			  <AND <N==? .OLD .DST>
			       <N==? .NEW 0>
			       <N==? .NEW -1>
			       <SET AC? <NEXT-AC <SET TAC? <LOAD-AC .OLD BOTH>>>>>>
		      <COND (<N==? .OLD .DST>
			     <COND (<WILL-DIE? .OLD> <DEAD!-MIMOC (.OLD) T>)>
			     <COND (.TAC?
				    <FLUSH-AC .TAC? T>
				    <MUNGED-AC .TAC? T>)
				   (ELSE
				    <FLUSH-AC .AC?>
				    <MUNGED-AC .AC?>)>)>
		      <SETG FIRST-AC <>>
		      <AC-TIME <GET-AC .TAC?> <SETG AC-STAMP <+ ,AC-STAMP 1>>>
		      <AC-UPDATE <AC-TIME <GET-AC .AC?>
					  <SETG AC-STAMP <+ ,AC-STAMP 1>>> T>)>
	       <COND (<AND <NOT .AC?>
			   <NOT <SET NAC <IN-AC? .NEW VALUE>>>
			   <N==? .NEW 0>
			   <N==? .NEW -1>>
		      <COND (<AND <TYPE? .NEW ATOM> <NOT <WILL-DIE? .NEW>>>
			     <SET NAC <NEXT-AC <LOAD-AC .NEW BOTH>>>)
			    (ELSE
			     <GET-INTO-ACS .NEW VALUE <SET NAC T*>>)>)>
	       <COND (<AND .FLIP <N==? .SHL 0>>
		      <COND (<==? .DST STACK>
			     <COND (.AC?
				    <OCEMIT <COND (<==? .NEW 0> HRLZ)
						  (ELSE HRLO)>
					    O*
					    .AC?>)
				   (ELSE
				    <OCEMIT <COND (<==? .NEW 0> HRLZ)
						  (ELSE HRLO)>
					    O*
					    !<OBJ-VAL .OLD>>)>
			     <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
			     <OCEMIT PUSH TP* O*>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
			    (.AC?
			     <COND (<==? .NEW 0> <OCEMIT HRLZS O* .AC?>)
				   (ELSE <OCEMIT HRLOS O* .AC?>)>
			     <COND (<N==? .DST .OLD>
				    <CLEAN-ACS .DST>
				    <ALTER-AC .TAC? .DST>
				    <AC-TYPE <GET-AC .TAC?> FIX>)>)
			    (<N==? .DST .OLD>
			     <SET AC? <ASSIGN-AC .DST BOTH>>
			     <COND (<==? .NEW 0>
				    <OCEMIT HRLZ <NEXT-AC .AC?> !<OBJ-VAL .OLD>>)
				   (ELSE
				    <OCEMIT HRLO <NEXT-AC .AC?> !<OBJ-VAL .OLD>>)>
			     <AC-TYPE <GET-AC .AC?> FIX>)
			    (<==? .NEW 0> <OCEMIT HRLZS O* !<OBJ-VAL .OLD>>)
			    (ELSE <OCEMIT HRLOS O* !<OBJ-VAL .OLD>>)>)
		     (.AC?
		      <OCEMIT <COND (<TYPE? .NEW ATOM>
				     <COND (<==? .SHL 0>
					    <COND (.FLIP HLL) (ELSE HRR)>)
					   (ELSE HRL)>)
				    (<==? .SHL 0>
				     <COND (.FLIP HRLI) (ELS HRRI)>)
				    (ELSE HRLI)>
			      .AC?
			      !<COND (<TYPE? .NEW ATOM> <OBJ-VAL .NEW>)
				     (.FLIP (<LSH .NEW -18>))
				     (ELSE (<CHTYPE <ANDB .NEW *777777*> FIX>))>>
		      <COND (<==? .DST STACK>
			     <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
			     <OCEMIT PUSH TP* .AC?>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
			    (<N==? .DST .OLD>
			     <CLEAN-ACS .DST>
			     <ALTER-AC .TAC? .DST>
			     <AC-TYPE <GET-AC .TAC?> FIX>)>)
		     (<NOT .NAC>
		      <COND (<==? .DST .OLD>
			     <OCEMIT <COND (<==? .NEW -1>
					    <COND (<==? .SHL 0>
						   <COND (.FLIP HRROS)
							 (ELSE HLLOS)>)
						  (.FLIP HRLOS)
						  (ELSE HRROS)>)
					   (<==? .SHL 0>
					    <COND (.FLIP HRRZS) (ELSE HLLZS)>)
					   (.FLIP HRLZS)
					   (ELSE HRRZS)> O* !<OBJ-VAL .OLD>>)
			    (ELSE
			     <COND (<N==? .DST STACK>
				    <SET NAC <ASSIGN-AC .DST BOTH>>)>
			     <OCEMIT <COND (<==? .NEW -1>
					    <COND (<==? .SHL 0>
						   <COND (.FLIP HRRO)
							 (ELSE HLLO)>)
						  (.FLIP HRLO)
						  (ELSE HRRO)>)
					   (<==? .SHL 0>
					    <COND (.FLIP HRRZ) (ELSE HLLZ)>)
					   (.FLIP HRLZ)
					   (ELSE HRRZ)>
				     <COND (<==? .DST STACK> O*)
					   (ELSE <NEXT-AC .NAC>)>
				     !<OBJ-VAL .OLD>>
			     <COND(<==? .DST STACK>
				   <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
				   <OCEMIT PUSH TP* O*>
				   <COND (,WINNING-VICTIM
					  <SETG STACK-DEPTH
						<+ ,STACK-DEPTH 2>>)>)
				   (ELSE
				    <AC-TYPE <GET-AC .NAC> FIX>)>)>)
		     (<==? .DST STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		      <OCEMIT PUSH TP* !<OBJ-VAL .OLD>>
		      <OCEMIT <COND (<==? .SHL 0>
				     <COND (.FLIP HLLM) (ELSE HRRM)>)
				    (ELSE HRLM)>
			      .NAC
			      '(TP*)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (ELSE
		      <OCEMIT <COND (<==? .SHL 0>
				     <COND (.FLIP HLLM) (ELSE HRRM)>)
				    (ELSE HRLM)>
			      .NAC
			      !<OBJ-VAL .OLD>>)>
	       <COND (<AND .TAC?
			   <N==? .OLD .DST>
			   <N==? .DST STACK>>
		      <CLEAN-ACS .DST>
		      <ALTER-AC .TAC? .DST>)>)
	      (ELSE <RPUTBITS .L>)>> 

<DEFINE RPUTBITS (L "AUX" (WD <1 .L>) (WL <2 .L>) (SHL <3 .L>) (NEW <4 .L>)
			  (DST <6 .L>) (TAC? <>) (AC? <>) AN BP (OL <>) (AC <>)
			  (W 0) (SH 0) IX (VT <>) (WAS-TYPED <>)
			  (DST-IN-O1 <>))
	#DECL ((L) LIST (OL) <OR FALSE LIST>)
	<COND (<TYPE? .WL FIX> <SET W .WL>)>
	<COND (<TYPE? .SHL FIX> <SET SH .SHL>)>
	<COND (<TYPE? .WD ATOM>
	       <SET OL <OBJ-LOC .WD 1>>
	       <SET TAC? <IN-AC? .WD BOTH>>
	       <SET AC? <IN-AC? .WD VALUE>>
	       <SET VT <VAR-TYPED? .WD>>)
	      (<N==? <PRIMTYPE .WD> FIX>
	       <MIMOCERR BAD-ARG-TO-PUTBITS .WD>)
	      (<==? .DST STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <OCEMIT PUSH TP* !<OBJ-VAL <CHTYPE .WD CONSTANT>>>
	       <CONST-LOC <CHTYPE .WD CONSTANT> VALUE>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (ELSE
	       <COND (<OR <==? .DST .NEW> <==? .DST SHL> <==? .DST .WL>>
		      <SET DST-IN-O1 T>
		      <OCEMIT MOVE O1* !<OBJ-VAL .DST>>)>
	       <SET AC? <NEXT-AC <SET TAC? <ASSIGN-AC .DST BOTH>>>>
	       <LOAD-AC .WD VALUE <> <> <GET-AC .AC?>>
	       <CLEAN-ACS .DST>
	       <ALTER-AC .TAC? .DST>
	       <SET WD .DST>)>
	<SET BP <CHTYPE <ORB <LSH .SH 30> <LSH .W 24>> FIX>>
	<COND (<AND <TYPE? .WD ATOM>
		    <OR <N==? .WD .DST> <AND <NOT .VT> <NOT .AC?>>>>
	       <SET TAC? <LOAD-AC .WD BOTH>>
	       <SET AC? <NEXT-AC .TAC?>>
	       <COND (<AND <N==? .WD .DST>
			   <NOT <WILL-DIE? .WD>>>
		      <FLUSH-AC .TAC? T>)>)>
	<COND (<N==? .WD .DST>
	       <COND (.TAC?
		      <SET WAS-TYPED <AC-TYPE <GET-AC .TAC?>>>
		      <MUNGED-AC .TAC? T>)
		     (.AC? <MUNGED-AC .AC?>)>)>
	<COND (.AC? <SET AN <2 <CHTYPE <MEMQ .AC? ,ACS> VECTOR>>>)>
	<COND (<AND <TYPE? .WD FIX> <==? .DST STACK>>
	       <SET BP <CHTYPE <ORB .BP <LSH ,TP* 18>> CONSTANT>>)
	      (.AC? <SET BP <CHTYPE <ORB .BP .AN> CONSTANT>>)
	      (.OL
	       <SET BP
		    <CHTYPE (<2 .OL>
			     <+ <CHTYPE <LSH <2 <MEMQ <1 <CHTYPE <3 .OL> LIST>>
						      ,ACS>>
					     18>
					FIX>
				<CHTYPE <1 .OL> FIX>
				.BP>) CONST-W-LOCAL>>)>
	<COND (<AND <TYPE? .WL FIX> <TYPE? .SHL FIX>>
	       <COND (<OR <NOT <TYPE? .NEW ATOM>>
			  <AND <WILL-DIE? .NEW>
			       <NOT <SET AC <IN-AC? .NEW VALUE>>>>>
		      <GET-INTO-ACS .NEW VALUE <SET AC T*>>)
		     (<AND .DST-IN-O1 <==? .NEW .DST>> <SET AC O1*>)
		     (<NOT .AC>
		      <SET AC <NEXT-AC <LOAD-AC .NEW BOTH>>>)>
	       <CONST-LOC .BP VALUE>
	       <OCEMIT DPB .AC !<OBJ-VAL .BP>>)
	      (ELSE
	       <COND (.AC? <OCEMIT MOVEI O* .AC?>)
		     (ELSE
		      <CONST-LOC .BP VALUE>
		      <OCEMIT MOVE O* !<OBJ-VAL .BP>>)>
	       <COND (<NOT <TYPE? .SHL FIX>>
		      <OCEMIT DPB <COND (<IN-AC? .SHL VALUE>)
					(<AND <==? .SHL .DST> .DST-IN-O1>
					 O1*)
					(ELSE <NEXT-AC <LOAD-AC .SHL BOTH>>)>
			      !<OBJ-VAL <SET BP <CHTYPE *360600000000*
							CONSTANT>>>>
		      <CONST-LOC .BP VALUE>)>
	       <COND (<NOT <TYPE? .WL FIX>>
		      <OCEMIT DPB <COND (<IN-AC? .WL VALUE>)
					(<AND <==? .WL .DST> .DST-IN-O1>
					 O1*)
					(ELSE <NEXT-AC <LOAD-AC .WL BOTH>>)>
			      !<OBJ-VAL <SET BP <CHTYPE *300600000000*
							CONSTANT>>>>
		      <CONST-LOC .BP VALUE>)>
	       <COND (.AC?
		      <AC-TIME <GET-AC .AC?>
			       <SETG AC-STAMP <+ ,AC-STAMP 1>>>
		      <COND (.TAC? <AC-TIME <GET-AC .TAC?> ,AC-STAMP>)>)>
	       <COND (<AND <==? .NEW .DST> .DST-IN-O1>
		      <OCEMIT DPB O1* O*>)
		     (ELSE
		      <SET AC <LOAD-AC .NEW BOTH>>
		      <OCEMIT DPB <NEXT-AC .AC> O*>)>)>
	<COND (<==? .DST STACK>
	       <COND (<TYPE? .WD ATOM>
		      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		      <OCEMIT PUSH TP* .AC?>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)
	      (<N==? .WD .DST>
	       <CLEAN-ACS .DST>
	       <AC-UPDATE <AC-ITEM <AC-CODE <GET-AC .TAC?> TYPE>
				   .DST> T>
	       <COND (.WAS-TYPED <AC-TYPE <GET-AC .TAC?> FIX>)>
	       <AC-CODE
		<AC-TYPE
		 <AC-ITEM
		  <AC-UPDATE <GET-AC <SET AC .AC?>> T> .DST> <>> VALUE>)
	      (.AC?
	       <COND (<NOT .TAC?>
		      <SET TAC? <GETPROP .AC? AC-PAIR>>
		      <AC-UPDATE <AC-ITEM <AC-CODE <GET-AC .TAC?> TYPE>
					  .DST> T>)>
	       <AC-UPDATE <GET-AC .AC?> T>
	       <COND (<NOT .VT> <AC-TYPE <GET-AC .TAC?> FIX>)>)>>

<DEFINE DISPATCH!-MIMOC (L
			 "AUX" (VAR <1 .L>) (BASE <2 .L>) DELBL AC (DF <>)
			       (DLBL <GENLBL "DISP">) RLBLS (LL .MIML) NEW AC-T
			       TAC (NV <- <LENGTH .L> 2>) (DISP-L ()))
	#DECL ((LL MIML L) LIST (BASE NV) FIX (DISP-L) <SPECIAL LIST>)
	<SET RLBLS
	     <MAPF ,LIST
		   <FUNCTION (LBL "AUX" LB LBX) 
			   <COND (<AND <SET LB <FIND-LABEL .LBL>>
				       <LAB-LOOP .LB>>
				  <COND (<NOT <FIND-LABEL
					       <SET LBX <GENLBL "LOOPD">>>>
					 <MAKE-LABEL .LBX <> ()>)>
				  (.LBL .LBX))
				 (ELSE (.LBL .LBL))>>
		   <REST .L 2>>>
	<SET DISP-L <MAPF ,LIST <FUNCTION (L:LIST) <2 .L>> .RLBLS>>
	<REPEAT (ITM)
		<COND (<OR <EMPTY? <SET LL <REST .LL>>>
			   <AND <TYPE? <SET ITM <1 .LL>> FORM>
				<OR <EMPTY? .ITM> <N==? <1 .ITM> DEAD>>>>
		       <RETURN>)
		      (<TYPE? .ITM ATOM>
		       <SET DELBL .ITM>
		       <SET DF T>
		       <RETURN>)>>
	<COND (<SET AC <IN-AC? .VAR BOTH>> <SET AC <NEXT-AC <SET TAC .AC>>>)
	      (<SET AC <IN-AC? .VAR VALUE>>)
	      (ELSE <SET AC <NEXT-AC <SET TAC <LOAD-AC .VAR BOTH>>>>)>
	<COND (<NOT .DF>
	       <SET DELBL <GENLBL "DEFAULT">>
	       <COND (<NOT <FIND-LABEL .DELBL>>
		      <MAKE-LABEL .DELBL <> ()>)>)>
	<LABEL-UPDATE-ACS .DELBL <>>
	<COND (<AND <G=? .BASE 0> <L=? .BASE 1>>
	       <OCEMIT <COND (<==? .BASE 0> JUMPL) (ELSE JUMPLE)>
		       .AC
		       <XJUMP .DELBL>>
	       <OCEMIT CAILE .AC <+ .NV .BASE -1>>
	       <OCEMIT JRST O* <XJUMP .DELBL>>)
	      (ELSE
	       <COND (<G? .BASE 0> <OCEMIT CAIL .AC .BASE>)
		     (ELSE <OCEMIT CAML .AC !<OBJ-VAL .BASE>>)>
	       <COND (<G? <SET NV <+ .NV .BASE -1>> 0> <OCEMIT CAILE .AC .NV>)
		     (ELSE <OCEMIT CAMLE .AC !<OBJ-CAL .NV>>)>
	       <OCEMIT JRST O* <XJUMP .DELBL>>)>
	<OCEMIT XMOVEI O1* <XJUMP .DLBL>>
	<OCEMIT ADD O1* .AC>
	<MAPF <> <FUNCTION (LBL) <LABEL-UPDATE-ACS <2 .LBL> <>>> .RLBLS>
	<SETG LAST-UNCON T>
	<OCEMIT JRST @ <- .BASE> '(O1*)>
	<LABEL .DLBL>
	<MAPF <> <FUNCTION (LBL) <OCEMIT SETZ O* <XJUMP <2 .LBL>>>> .RLBLS>
	<MAPF <>
	      <FUNCTION (LBL) 
		      <COND (<N==? <1 .LBL> <2 .LBL>>
			     <LABEL <2 .LBL>>
			     <JUMP!-MIMOC <1 .LBL>>)>>
	      .RLBLS>
	<COND (<NOT .DF>
	       <COND (,PASS1 <SET LB <LABEL .DELBL>> <SAVE-LABEL-STATE .LB>)
		     (,NO-AC-FUNNYNESS <SAVE-ACS> <SET LB <LABEL .DELBL>>)
		     (ELSE
		      <SET LB <FIND-LABEL .DELBL>>
		      <ESTABLISH-LABEL-STATE .LB>
		      <LABEL .DELBL>)>)>>


<DEFINE CHANNEL-OP!-MIMOC (L "AUX" (CTYP <1 .L>) (OPER <2 .L>) (EQSN <>) RES
				   (GC <>) (NUM 2) RTN  OC)
   #DECL ((L) LIST (CTYP OPER) <FORM ATOM ATOM>)
   <PROG ()
	<COND (<AND <SET OC <GETPROP <2 .CTYP> OC-INDICATOR>>
		    <SET OC <APPLY .OC <2 .OPER> <REST .L 2>>>>
	       <RETURN .OC>)>
	<SET RTN <CT-QUERY <2 .CTYP> <2 .OPER>>>
	<COND (.RTN
	       <COND (<AND ,GLUE-MODE <MEMQ .RTN ,PRE-NAMES>>
		      <FRAME!-MIMOC (<SET GC <GENLBL "?FRM">> .RTN)>
		      <SET RTN <FORM QUOTE .RTN>>)
		     (<SUBRIFY? .RTN>
		      <FRAME!-MIMOC (<SET GC <GENLBL "?FRM">> .RTN)>
		      <SET RTN <FORM QUOTE .RTN>>)
		     (ELSE
		      <SET RTN <FORM QUOTE .RTN>>
		      <FRAME!-MIMOC (.RTN)>)>)
	      (ELSE <FRAME!-MIMOC ()>)>
	<PUSH!-MIMOC (<3 .L>)>
	<PUSH!-MIMOC (.OPER)>
	<MAPF <>
	      <FUNCTION (ARG)
		   <COND (.EQSN <SET RES .ARG> <MAPLEAVE>)
			 (<==? .ARG => <SET EQSN T>)
			 (ELSE
			  <PUSH!-MIMOC (.ARG)>
			  <SET NUM <+ .NUM 1>>)>>
	      <REST .L 3>>
	<COND (.RTN
	       <CALL!-MIMOC (.RTN .NUM !<COND (.EQSN (= .RES)) (ELSE ())>
			     !<COND (.GC (.GC)) (ELSE ())>)>)
	      (ELSE
	       <OCEMIT MOVE O1* !<OBJ-VAL <CHTYPE (.CTYP .OPER) CHANNEL-ROUTINE>>>
	       <OCEMIT MOVE O1* 2 (O1*)>
	       <OCEMIT MOVEI O2* .NUM>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <- ,STACK-DEPTH <* .NUM 2> 7>>)>
	       <UPDATE-ACS>
	       <COND (<ASSIGNED? RES> <PUSHJ CALL .RES>)
		     (ELSE <PUSHJ CALL>)>)>>>

<DEFINE CHANNEL-ROUTINE-PRINT (L) #DECL ((L) CHANNEL-ROUTINE)
	<PRINC "%<CHANNEL-OPERATION ">
	<PRIN1 <1 .L>>
	<PRINC " ">
	<PRIN1 <2 .L>>
	<PRINC ">">>

<PRINTTYPE CHANNEL-ROUTINE ,CHANNEL-ROUTINE-PRINT>

<SETG BIND-DW *1442000000*>

<DEFINE BBIND!-MIMOC (L "AUX" (ATM <1 .L>) (DCL <2 .L>) (FXB <3 .L>) VAL AC)
	#DECL ((L) LIST (ATM) <OR ATOM <FORM ATOM ATOM>>)
	<OCEMIT PUSH TP* !<OBJ-VAL ,BIND-DW>>
	<COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	<COND (<==? <LENGTH .L> 4>
	       <OCEMIT PUSH TP* !<OBJ-TYP <SET VAL <4 .L>>>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT PUSH TP* !<OBJ-VAL .VAL>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (ELSE
	       <OCEMIT PUSH TP* !<OBJ-VAL 0>>
	       <OCEMIT PUSH TP* !<OBJ-VAL 0>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>
	<COND (<SET AC <IN-AC? .ATM VALUE>>)
	      (<TYPE? .ATM ATOM>
	       <SET AC <NEXT-AC <LOAD-AC .ATM BOTH>>>)
	      (ELSE
	       <OCEMIT MOVE <SET AC O1*> !<OBJ-VAL .ATM>>)>
	<OCEMIT PUSH TP* .AC>
	<OCEMIT PUSH TP* !<OBJ-TYP .DCL>>
	<OCEMIT PUSH TP* !<OBJ-VAL .DCL>>
	<OCEMIT PUSH TP* SP*>
	<OCEMIT PUSH TP* 1 (.AC)>
	<OCEMIT PUSH TP* @ *137*>
	<OCEMIT XMOVEI SP* -7 '(TP*)>
	<COND (.FXB <OCEMIT MOVEM SP* 1 (.AC)>)>
	<COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 6>>)>>

<DEFINE GEN-LVAL!-MIMOC (L "AUX" (ATM <1 .L>) (VAL <3 .L>))
	#DECL ((L) LIST)
	<OCEMIT MOVE O1* !<OBJ-VAL .ATM>>
	<SAVE-ACS>
	<PUSHJ ILVAL .VAL>>

<DEFINE GEN-ASSIGNED?!-MIMOC (L "AUX" (ATM  <1 .L>) (DIR <2 .L>) (TG <3 .L>))
	#DECL ((L) LIST)
	<OCEMIT MOVE O1* !<OBJ-VAL .ATM>>
	<LABEL-UPDATE-ACS .TG <>>
	<OCEMIT JSP T* @ <- <OPCODE IASS>>>
	<COND (<==? .DIR +> <OCEMIT CAIA O* O*>)>
	<OCEMIT JRST <XJUMP .TG>>>

<DEFINE GEN-SET!-MIMOC (L "AUX" (ATM <1 .L>) (NVAL <2 .L>)) 
	#DECL ((L) LIST)
	<COND (<WILL-DIE? .NVAL> <DEAD!-MIMOC (.NVAL) T>)>
	<COND (<AND <TYPE? .ATM ATOM> <WILL-DIE? .ATM>> <DEAD!-MIMOC (.ATM) T>)>
	<UPDATE-ACS>
	<GET-INTO-ACS .NVAL BOTH A1* .ATM VALUE O1*>
	<PUSHJ ISET>>