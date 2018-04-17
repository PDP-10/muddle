
<COND (<NOT <GASSIGNED? WIDTH-MUNG>> <FLOAD "MIMOC20DEFS.MUD">)>

<NEWTYPE XTYPE-W ATOM>

<NEWTYPE LOCAL-NAME FIX>

<NEWTYPE LOCAL VECTOR>

<NEWTYPE XGLOC ATOM>

<SETG PRIM-FIX 0>

<SETG PRIM-LIST 1>

<MANIFEST PRIM-LIST PRIM-FIX>

;"LIST manipulation"

<DEFINE NTHL!-MIMOC (L
		     "OPT" (AOS <>) (NOT-DEAD? T) LEN-VAR
		     "AUX" (LST <1 .L>) (AMT <2 .L>) (VAL <4 .L>)
			   (LOOP <GENLBL "LOOP">) (END <GENLBL "END">) (TAC <>)
			   CNT-AC (AHEAD <>) AC NAC (RES-TYP <EXTRAMEM TYPE .L>))
	#DECL ((LST) <OR LIST ATOM> (AMT) <OR FIX ATOM> (NAC LOOP END) ATOM
	       (AC) <OR AC ATOM FALSE> (MIML L) LIST (AHEAD) <OR AC FALSE>)
	<COND (<AND <NOT .AOS> <NTH-PUT-LOOK-AHEAD .L "PUTL" .LST .AMT .VAL>>)
	      (ELSE
	       <COND (<AND <ASSIGNED? LEN-VAR> .NOT-DEAD?> <SET VAL .LEN-VAR>)>
	       <COND (<AND <NOT <AND <SET TAC <IN-AC? .LST BOTH>>
				     <SET AC <NEXT-AC .TAC>>>>
			   <NOT <SET AC <IN-AC? .LST VALUE>>>>
		      <COND (<AND <OR <NOT .AOS> .NOT-DEAD?>
				  <N==? .LST .VAL>
				  <SET AHEAD
				       <LOOK-AHEAD <REST .MIML> .VAL BOTH>>>
			     <AC-TIME .AHEAD <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			     <AC-TIME <GET-AC <NEXT-AC .AHEAD>> ,AC-STAMP>)>
		      <SET AC <NEXT-AC <SET TAC <LOAD-AC .LST BOTH>>>>)>
	       <COND (<AND <NOT <WILL-DIE? .LST>>
			   <N==? .LST .VAL>
			   <N==? .AMT 1>>
		      <COND (.TAC <FLUSH-AC .TAC T>) (ELSE <FLUSH-AC .AC>)>)>
	       <COND (<AND <==? .AMT .VAL>
			   <SET NAC
				<OR <IN-AC? .VAL BOTH> <IN-AC? .VAL VALUE>>>>
		      <FLUSH-AC .NAC T>)>
	       <COND (<AND <OR <NOT .AOS> .NOT-DEAD?> <N==? .VAL STACK>>
		      <SET NAC <LOAD-AC .VAL BOTH T T .AHEAD>>
							 ;"Really an ASSIGN-AC"
		      <COND (<AND <==? .NAC .TAC> <==? .LST .VAL>>
			     <AC-TYPE <GET-AC .NAC> <>>)>)>
	       <COND (<==? .AMT 1>)
		     (ELSE
		      <COND
		       (<AND <TYPE? .AMT ATOM>
			     <OR <AND <SET CNT-AC <IN-AC? .AMT BOTH>>
				      <OR <AND <WILL-DIE? .AMT>
					       <DEAD!-MIMOC (.AMT) T>>
					  <NOT <AC-UPDATE
						<GET-AC <NEXT-AC .CNT-AC>>>>>
				      <PROG ()
					    <MUNGED-AC .CNT-AC T>
					    <SET CNT-AC <NEXT-AC .CNT-AC>>>>
				 <AND <SET CNT-AC <IN-AC? .AMT VALUE>>
				      <OR <AND <WILL-DIE? .AMT>
					       <DEAD!-MIMOC (.AMT) T>>
					  <NOT <AC-UPDATE <GET-AC .CNT-AC>>>>
				      <PROG ()
					    <MUNGED-AC .CNT-AC T>>>>>)
		       (ELSE
			<OCEMIT MOVE <SET CNT-AC O*> !<OBJ-VAL .AMT>>)>
		      <SETG LOOPTAGS (.LOOP !,LOOPTAGS)>
		     <LABEL .LOOP>
		      <OCEMIT SOJE .CNT-AC <XJUMP .END>>
		      <OCEMIT MOVE .AC (.AC)>
		      <OCEMIT JRST <XJUMP .LOOP>>
		      <LABEL .END>
		      <COND (<N==? .LST .VAL>
			     <COND (.TAC <MUNGED-AC .TAC T>)
				   (ELSE <MUNGED-AC .AC>)>)>)>
	       <COND (.AOS
		      <COND (<==? .VAL STACK>
			     <OCEMIT .AOS
				     O1*
				     <COND (<==? .AOS HRRZ> 1) (ELSE 2)>
				     (.AC)>
			     <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
			     <OCEMIT PUSH TP* O1*>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
			    (.NOT-DEAD?
			     <OCEMIT .AOS
				     <NEXT-AC .NAC>
				     <COND (<==? .AOS HRRZ> 1) (ELSE 2)>
				     (.AC)>
			     <AC-TYPE <GET-AC .NAC> FIX>)
			    (<TYPE? .AOS FORM>
			     <COND (<=? <SPNAME <1 .AOS>> "VEQUAL?">
				    <VEQUAL?!-MIMOC <REST .AOS> .AC <> 2>)
				   (<=? <SPNAME <1 .AOS>> "TYPE?">
				    <VEQUAL?!-MIMOC <REST .AOS 3> .AC <> 2
						    <2 .AOS>>)
				   (ELSE
				    <EQUAL?!-MIMOC <REST .AOS> .AC <> 1>)>)
			    (ELSE
			     <OCEMIT .AOS
				     <COND (<==? .AOS HRRZ> 1) (ELSE 2)>
				     (.AC)>)>)
		     (<==? .VAL STACK>
		      <OCEMIT PUSH TP* 1 (.AC)>
		      <OCEMIT PUSH TP* 2 (.AC)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		     (T <OCEMIT DMOVE .NAC 1 (.AC)>)>)>>

<DEFINE RESTL!-MIMOC (L
		      "AUX" (LST <1 .L>) (AMT <2 .L>) (VAL <4 .L>) AC NAC
			    (TAC <>) (END <GENLBL "END">)
			    (LOOP <GENLBL "LOOP">)
			    (LV
			     <OR <LMEMQ .VAL ,LOCALS>
				 <AND ,ICALL-FLAG <LMEMQ .VAL ,ICALL-TEMPS>>>)
			    (VD <COND (.LV <LDECL .LV>)>))
	#DECL ((LST) <OR LIST ATOM> (AMT) <OR FIX ATOM> (NAC END LOOP) ATOM
	       (AC) <OR ATOM FALSE> (L) LIST)
	<COND (<OR <==? .AMT 1> <==? .AMT 2>>
	       <OR <AND <SET TAC <IN-AC? .LST BOTH>> <SET AC <NEXT-AC .TAC>>>
		   <SET AC <IN-AC? .LST VALUE>>>)
	      (<AND <NOT <AND <SET AC <IN-AC? .LST BOTH>>
			      <SET TAC .AC>
			      <SET AC <NEXT-AC .AC>>>>
		    <NOT <SET AC <IN-AC? .LST VALUE>>>>
	       <SET AC <NEXT-AC <SET TAC <LOAD-AC .LST BOTH>>>>)>
	<COND (<AND <==? .AMT .VAL> <SET NAC <IN-AC? .AMT BOTH>>>
	       <FLUSH-AC .NAC T>)>
	<COND (<N==? .VAL .LST> <CLEAN-ACS .VAL>)>
	<COND (<AND .TAC <OR <==? .LST .VAL> <WILL-DIE? .LST>>> <SET NAC .TAC>)
	      (<AND .AC
		    <OR <==? .LST .VAL> <WILL-DIE? .LST>>
		    <SET TAC <GET-AC <GETPROP .AC AC-PAIR>>>
		    <==? <NEXT-AC <AC-NAME .TAC>> .AC>>
	       <SET NAC <AC-NAME .TAC>>
	       <AC-CODE .TAC TYPE>
	       <AC-ITEM .TAC .LST>
	       <SET TAC <>>
	       <FLUSH-AC .NAC>)
	      (ELSE <SET NAC <ASSIGN-AC .VAL BOTH T>>)>
	<COND (<==? .AMT 1>
	       <COND (.AC <OCEMIT MOVE <NEXT-AC .NAC> (.AC)>)
		     (ELSE <OCEMIT MOVE <NEXT-AC .NAC> @ !<OBJ-VAL .LST>>)>)
	      (<==? .AMT 2>
	       <COND (.AC <OCEMIT MOVE <NEXT-AC .NAC> @ (.AC)>)
		     (ELSE
		      <OCEMIT MOVE <NEXT-AC .NAC> @ !<OBJ-VAL .LST>>
		      <OCEMIT MOVE <NEXT-AC .NAC> (<NEXT-AC .NAC>)>)>)
	      (<==? .AMT 3>
	       <COND (.AC
		      <OCEMIT MOVE <NEXT-AC .NAC> @ (.AC)>
		      <OCEMIT MOVE <NEXT-AC .NAC> (<NEXT-AC .NAC>)>)
		     (ELSE
		      <OCEMIT MOVE <NEXT-AC .NAC> @ !<OBJ-VAL .LST>>
		      <OCEMIT MOVE <NEXT-AC .NAC> @ (<NEXT-AC .NAC>)>)>)
	      (<==? .AMT 4>
	       <COND (.AC
		      <OCEMIT MOVE <NEXT-AC .NAC> @ (.AC)>
		      <OCEMIT MOVE <NEXT-AC .NAC> @ (<NEXT-AC .NAC>)>)
		     (ELSE
		      <OCEMIT MOVE <NEXT-AC .NAC> @ !<OBJ-VAL .LST>>
		      <OCEMIT MOVE <NEXT-AC .NAC> @ (<NEXT-AC .NAC>)>
		      <OCEMIT MOVE <NEXT-AC .NAC> (<NEXT-AC .NAC>)>)>)
	      (T
	       <COND (<N==? .AC <NEXT-AC .NAC>>
		      <OCEMIT MOVE <NEXT-AC .NAC> .AC>)>
	       <SMASH-AC O* .AMT VALUE <N==? .AMT .VAL>>
	       <COND (<==? .AMT 0>)
		     (T
		      <COND (<TYPE? .AMT ATOM> <OCEMIT JUMPE O* <XJUMP .END>>)>
		      <SETG LOOPTAGS (.LOOP !,LOOPTAGS)>
		      <LABEL .LOOP>
		      <OCEMIT MOVE <NEXT-AC .NAC> (<NEXT-AC .NAC>)>
		      <OCEMIT SOJN O* <XJUMP .LOOP>>
		      <LABEL .END>
		      <AC-ITEM <GET-AC O*> 0>)>)>
	<COND (<AND <==? .AC <NEXT-AC .NAC>>
		    <N==? .VAL .LST> <N==? .VAL STACK>>
	       <AC-CODE <AC-ITEM <GET-AC .NAC> .VAL> TYPE>
	       <AC-CODE <AC-ITEM <GET-AC <NEXT-AC .NAC>> .VAL> VALUE>)>
	<COND (.VD <AC-UPDATE <GET-AC .NAC> <>>)
	      (ELSE <AC-UPDATE <GET-AC .NAC> T>)>
	<AC-UPDATE <GET-AC <NEXT-AC .NAC>> T>
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD LIST>>
	       <OCEMIT PUSH TP* <NEXT-AC .NAC>>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (ELSE
	       <COND (<N==? .NAC .TAC> <AC-TYPE <GET-AC .NAC> LIST>)>
	       <COND (.VD <AC-UPDATE <GET-AC .NAC> <>>)
		     (ELSE <AC-UPDATE <GET-AC .NAC> T>)>)>>

<DEFINE EMPL?!-MIMOC (L
		      "AUX" (LST <1 .L>) (FLAG <2 .L>) (TAG <3 .L>)
			    (JUMP JUMPE) (SKIP SKIPN) AC NEW (AC-T <>)
			    (LV
			     <OR <LMEMQ .LST ,LOCALS>
				 <AND ,ICALL-FLAG <LMEMQ .LST ,ICALL-TEMPS>>>)
			    TAC (AC-T-2 <>)
			    (VD
			     <COND (.LV <LDECL .LV>)
				   (ELSE <EXTRAMEM TYPE .L>)>))
	#DECL ((LST) <OR LIST ATOM> (FLAG TAG SKIP JUMP) ATOM
	       (AC) <OR FALSE ATOM> (L) LIST)
	<COND (<==? .FLAG -> <SET JUMP JUMPN> <SET SKIP SKIPE>)>
	<COND (<OR <AND <SET TAC <IN-AC? .LST BOTH>>
			<SET AC <NEXT-AC .TAC>>
			<SET NEW
			     <LABEL-UPDATE-ACS .TAG <> T .TAC .AC>>>
		   <AND <SET AC <IN-AC? .LST VALUE>>
			<SET NEW
			     <LABEL-UPDATE-ACS .TAG <> T .AC>>>>
	       <COND (.TAC
		      <SET AC-T-2 <AC-TIME <GET-AC <SET TAC <1 .NEW>>>>>
		      <COND (<N==? .AC <2 .NEW>>
			     <SET AC-T
				  <AC-TIME <GET-AC <SET AC <2 .NEW>>>>>)>)
		     (<N==? .AC <1 .NEW>>
		      <SET AC-T <AC-TIME <GET-AC <SET AC <1 .NEW>>>>>)>
	       <OCEMIT .JUMP .AC <XJUMP .TAG>>
	       <COND (.AC-T <AC-TIME <GET-AC .AC> .AC-T>)>
	       <COND (.AC-T-2 <AC-TIME <GET-AC .TAC> .AC-T-2>)>)
	      (T
	       <COND (<OR <AND <SET TAC <LABEL-PREF .TAG .LST BOTH>>
			       <SET AC <NEXT-AC <SET TAC <AC-NAME .TAC>>>>>
			  <AND <SET TAC <LABEL-PREF .TAG .LST VALUE>>
			       <SET AC <AC-NAME .TAC>>
			       <SET TAC <GETPROP .TAC AC-PAIR>>>>
		      <LOAD-AC .LST BOTH T T <GET-AC .TAC> <GET-AC .AC>>)
		     (ELSE
		      <SET AC <NEXT-AC <SET TAC <ASSIGN-AC .LST BOTH>>>>)>
	       <AC-UPDATE <GET-AC .AC> <>>
	       <AC-ITEM <GET-AC .AC> .LST>
	       <AC-CODE <GET-AC .AC> VALUE>
	       <MUNGED-AC .TAC>
	       <SETG ACA-AC <>>
	       <LABEL-UPDATE-ACS .TAG <>>
	       <OCEMIT .SKIP .AC !<OBJ-LOC .LST 1>>
	       <OCEMIT JRST <XJUMP .TAG>>)>>

<DEFINE PUTREST!-MIMOC (L "AUX" (L1 <1 .L>) (L2 <2 .L>) AC NAC) 
	#DECL ((L) LIST (L1 L2) <OR LIST ATOM> (AC NAC) <OR FALSE ATOM>)
	<COND (<SET AC <IN-AC? .L1 VALUE>>
	       <SETG FIRST-AC <>>
	       <AC-TIME <GET-AC .AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)>
	<COND (<==? .L2 ()>
	       <COND (.AC <OCEMIT SETZM 0 (.AC)>)
		     (ELSE <OCEMIT SETZM @ !<OBJ-VAL .L1>>)>)
	      (ELSE
	       <COND (<SET NAC <IN-AC? .L2 VALUE>>)
		     (<AND <TYPE? .L2 ATOM> <NOT <WILL-DIE? .L2>>>
		      <SET NAC <NEXT-AC <LOAD-AC .L2 BOTH>>>)
		     (T <SMASH-AC O* .L2 VALUE> <SET NAC O*>)>
	       <COND (.AC <OCEMIT MOVEM .NAC (.AC)>)
		     (ELSE <OCEMIT MOVEM .NAC @ !<OBJ-VAL .L1>>)>)>>

<DEFINE CONS!-MIMOC (L "AUX" (L1 <1 .L>) (L2 <2 .L>) (VAL <4 .L>)) 
	#DECL ((L) LIST (L1) ANY (L1) <OR LIST ATOM> (VAL) ATOM)
	<COND (<OR <==? .L1 .VAL> <AND <TYPE? .L1 ATOM> <WILL-DIE? .L1>>>
	       <DEAD!-MIMOC (.L1) T>)>
	<COND (<OR <==? .L2 .VAL> <AND <TYPE? .L2 ATOM> <WILL-DIE? .L2>>>
	       <DEAD!-MIMOC (.L2) T>)>
	<UPDATE-ACS>
	<GET-INTO-ACS .L1 BOTH B1* .L2 VALUE C1*>
	<PUSHJ CONS .VAL>>

<DEFINE GET-INTO-ACS ("TUPLE" PTRNS "AUX" (FIRSTS ()) (LASTS ()) (OTHERS ())) 
   #DECL ((PTRNS) TUPLE (FIRSTS LASTS OTHERS) LIST)
   <REPEAT ((P .PTRNS) (WIN T) (CHANGE <>) AC ITM DAC KIND RAC)
     <COND (<AND <EMPTY? .P> .WIN> <RETURN>)>
     <COND
      (<EMPTY? .P>
       <COND
	(<NOT .CHANGE>
	 <PROG ((BOTH T))
	   <MAPF <>
	    <FUNCTION (ONE) 
		    #DECL ((ONE) !<LIST [3 ATOM] TUPLE>)
		    <COND (<AND <OR <AND <NOT .BOTH> <N==? <2 .ONE> BOTH>>
				    <AND .BOTH <==? <2 .ONE> BOTH>>>
				<N==? <1 .ONE> <3 .ONE>>>
			   <OCEMIT EXCH <1 .ONE> <3 .ONE>>
			   <FIXUP-ACS .FIRSTS <1 .ONE> <3 .ONE> .ONE <2 .ONE>>
			   <COND (<==? <2 .ONE> BOTH>
				  <OCEMIT EXCH
					  <NEXT-AC-FUNNY <1 .ONE>>
					  <NEXT-AC-FUNNY <3 .ONE>>>)>
			   <PUT <4 .ONE> 2 <>>)
			  (<==? <1 .ONE> <3 .ONE>> <PUT <4 .ONE> 2 <>>)>>
	    .FIRSTS>
	   <COND (.BOTH <SET BOTH <>> <AGAIN>)>>
	 <SET FIRSTS ()>)>
       <SET WIN T>
       <SET P .PTRNS>
       <AGAIN>)>
     <COND (<NOT <2 .P>>)
	   (<NOT <TYPE? <SET ITM <1 .P>> ATOM>>
	    <SET LASTS ((.ITM <2 .P> <3 .P>) !.LASTS)>
	    <PUT .P 2 <>>)
	   (<SET AC <IN-AC? .ITM <SET KIND <2 .P>>>>
	    <COND (<==? .AC <SET DAC <3 .P>>>
		   <COND (<AND <N==? .KIND VALUE>
			       <SET RAC <GETPROP .DAC AC>>
			       <AC-TYPE .RAC>>
			  <LOAD-TYPE-IN-AC .DAC <AC-TYPE .RAC>>
			  <AC-TYPE .RAC <>>)>)
		  (<OR <AND <==? .KIND BOTH>
			    <OR <AC-MEMQ .DAC .PTRNS>
				<AC-MEMQ <NEXT-AC-FUNNY .DAC> .PTRNS>>>
		       <AND <N==? .KIND BOTH> <AC-MEMQ .DAC .PTRNS>>>
		   <SET WIN <>>
		   <SET FIRSTS ((.AC .KIND .DAC .P) !.FIRSTS)>)
		  (ELSE
		   <SET WIN <>>
		   <SET CHANGE T>
		   <COND (<GETPROP .DAC AC>
			  <AC-TYPE <GET-AC .DAC> <>>
			  <COND (<==? .KIND BOTH>
				 <AC-TYPE <GET-AC <NEXT-AC .DAC>> <>>)>)>
		   <COND (<==? .KIND BOTH>
			  <OCEMIT DMOVE .DAC .AC>)
			 (ELSE <OCEMIT MOVE .DAC .AC>)>
		   <PUT .P 2 <>>)>)
	   (ELSE
	    <SET CHANGE T>
	    <PUT .P 2 <>>
	    <SET OTHERS ((.ITM .KIND <3 .P>) !.OTHERS)>)>
     <SET P <REST .P 3>>>
   <MAPF <>
	 <FUNCTION (ONE) 
		 #DECL ((ONE) !<LIST ATOM ATOM ATOM>)
		 <COND (<GETPROP <3 .ONE> AC>
			<AC-TYPE <GET-AC <3 .ONE>> <>>
			<COND (<==? <2 .ONE> BOTH>
			       <AC-TYPE <GET-AC <NEXT-AC <3 .ONE>>> <>>)>)>
		 <COND (<==? <2 .ONE> BOTH>
			<OCEMIT DMOVE <3 .ONE> !<OBJ-LOC <1 .ONE> 0>>)
		       (<==? <2 .ONE> VALUE>
			<OCEMIT MOVE <3 .ONE> !<OBJ-LOC <1 .ONE> 1>>)
		       (ELSE <OCEMIT MOVE <3 .ONE> !<OBJ-LOC <1 .ONE> 0>>)>>
	 .OTHERS>
   <MAPF <>
	 <FUNCTION (ONE "AUX" (AC <3 .ONE>) (TYP <2 .ONE>) (V <1 .ONE>)) 
		 #DECL ((ONE) !<LIST ANY ATOM ATOM>)
		 <COND (<GETPROP .AC AC> <MUNGED-AC .AC <==? .TYP BOTH>>)>
		 <COND (<AND <N==? .TYP TYPE>
			     <OR <MEMQ <PRIMTYPE .V> '[WORD FIX]>
				 <AND <==? <PRIMTYPE .V> LIST>
				      <EMPTY? <CHTYPE .V LIST>>>>>
			<COND (<==? .TYP BOTH>
			       <OCEMIT MOVSI .AC !<TYPE-CODE <TYPE .V> T>>
			       <SET AC <NEXT-AC-FUNNY .AC>>)>
			<COND (<==? <PRIMTYPE .V> LIST> <SET V 0>)
			      (ELSE <SET V <CHTYPE .V FIX>>)>
			<COND (<AND <G=? .V 0> <L=? .V ,MAX-IMMEDIATE>>
			       <OCEMIT MOVEI .AC .V>)
			      (<0? <ANDB .V 262143>>
			       <OCEMIT MOVSI .AC <LSH .V -18>>)
			      (<AND <L? .V 0> <L=? <ABS .V> ,MAX-IMMEDIATE>>
			       <OCEMIT MOVNI .AC <- .V>>)
			      (ELSE <OCEMIT MOVE .AC !<OBJ-LOC .V 1>>)>)
		       (<==? .TYP BOTH> <OCEMIT DMOVE .AC !<OBJ-LOC .V 0>>)
		       (<==? .TYP VALUE> <OCEMIT MOVE .AC !<OBJ-LOC .V 1>>)
		       (ELSE <OCEMIT MOVE .AC !<OBJ-LOC .V 0>>)>>
	 .LASTS>>

<DEFINE AC-MEMQ (AC P) 
	#DECL ((AC) ATOM (P) <PRIMTYPE VECTOR>)
	<REPEAT ()
		<COND (<EMPTY? .P> <RETURN <>>)>
		<COND (<AND <2 .P>
			    <OR <==? <IN-AC? <1 .P> <2 .P>> .AC>
				<AND <==? <2 .P> BOTH>
				     <OR <==? <IN-AC? <1 .P> TYPE> .AC>
					 <==? <IN-AC? <1 .P> VALUE> .AC>>>>>
		       <RETURN T>)>
		<SET P <REST .P 3>>>>

<DEFINE NEXT-AC-FUNNY (AC:ATOM)
	<OR <NEXT-AC .AC>
	    <AND <==? .AC O1*> O2*>
	    <AND <==? .AC O*> A1*>
	    <ERROR NEXT-AC-LOSSAGE!-ERRORS>>>

<DEFINE FIXUP-ACS (L ACA ACB NOT-ME KIND "AUX" AC2A AC2B) 
	#DECL ((L) LIST)
	<SET AC2B <COND (<==? .KIND BOTH> <NEXT-AC-FUNNY .ACB>)>>
	<SET AC2A <COND (<==? .KIND BOTH> <NEXT-AC-FUNNY .ACA>)>>
	<MAPF <>
	      <FUNCTION (LL "AUX" TAC) 
		      #DECL ((LL) !<LIST ATOM ATOM ATOM TUPLE>)
		      <COND (<AND <N==? .LL .NOT-ME>
				  <OR <AND <==? .ACB <SET TAC <1 .LL>>>
					   <SET TAC .ACA>>
				      <AND <==? .ACA .TAC> <SET TAC .ACB>>
				      <AND <==? .AC2A .TAC> <SET TAC .AC2B>>
				      <AND <==? .AC2B .TAC> <SET TAC .AC2A>>>>
			     <PUT .LL 1 .TAC>)>>
	      .L>>

<DEFINE PUTL!-MIMOC (L "AUX" (LST <1 .L>) (AMT <2 .L>) (VAL <3 .L>)
	                     (LOOP <GENLBL "LOOP">) (END <GENLBL "END">)
			     (TAC <>) AC NAC (PUT-TYP <EXTRAMEM TYPE .L>)
			     CNT-AC)
	#DECL ((LST) <OR LIST ATOM>
	       (AMT) <OR FIX ATOM>
	       (LOOP) ATOM (NAC AC TAC) <OR ATOM FALSE>
	       (L) LIST)
	<COND (<AND <NOT <AND <SET AC <IN-AC? .LST BOTH>>
			      <SET TAC .AC>
			      <SET AC <NEXT-AC .AC>>>>
		    <NOT <SET AC <IN-AC? .LST VALUE>>>>
	       <SET AC <NEXT-AC <SET TAC <LOAD-AC .LST BOTH>>>>)
	      (ELSE
	       <SETG FIRST-AC <>>
	       <AC-TIME <GET-AC .AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)>
	<COND (<==? .AMT 1>)
	      (<TYPE? .AMT FIX>
	       <COND (.TAC <FLUSH-AC .TAC T>)
		     (ELSE <FLUSH-AC .AC>)>
	       <COND (<L? <SET AMT <- .AMT 1>> 3>
		      <REPEAT ()
			      <OCEMIT MOVE .AC (.AC)>
			      <COND (<0? <SET AMT <- .AMT 1>>> <RETURN>)>>)
		     (ELSE
		      <SMASH-AC O* .AMT VALUE>
		      <SETG LOOPTAGS (.LOOP !,LOOPTAGS)>
		      <LABEL .LOOP>
		      <OCEMIT MOVE .AC (.AC)>
		      <OCEMIT SOJN O* <XJUMP .LOOP>>)>)
	      (T
	       <COND (.TAC <FLUSH-AC .TAC T>)
		     (ELSE <FLUSH-AC .AC>)>
	       <COND (<OR <AND <SET CNT-AC <IN-AC? .AMT BOTH>>
			       <OR <AND <WILL-DIE? .AMT> <DEAD!-MIMOC (.AMT) T>>
				   <NOT <AC-UPDATE <GET-AC <NEXT-AC .CNT-AC>>>>>
			       <PROG ()
				     <MUNGED-AC .CNT-AC T>
				     <SET CNT-AC <NEXT-AC .CNT-AC>>>>
			  <AND <SET CNT-AC <IN-AC? .AMT VALUE>>
			       <OR <AND <WILL-DIE? .AMT> <DEAD!-MIMOC (.AMT) T>>
				   <NOT <AC-UPDATE <GET-AC .CNT-AC>>>>
			       <PROG ()
				     <MUNGED-AC .CNT-AC T>>>>)
		     (ELSE
		      <OCEMIT MOVE <SET CNT-AC O*> !<OBJ-VAL .AMT>>)>
	       <OCEMIT SOJE .CNT-AC <XJUMP .END>>
	       <SETG LOOPTAGS (.LOOP !,LOOPTAGS)>
	       <LABEL .LOOP>
	       <OCEMIT MOVE .AC (.AC)>
	       <OCEMIT SOJN .CNT-AC <XJUMP .LOOP>>
	       <LABEL .END>)>
	<DO-PUT .PUT-TYP .AC .VAL 1>
	<COND (<N==? .AMT 1>
	       <COND (.TAC <MUNGED-AC .TAC T>)
		     (ELSE <MUNGED-AC .AC>)>)>>

<DEFINE DO-PUT (PUT-TYP AC VAL OFFS "AUX" NAC) 
	#DECL ((OFFS) FIX)
	<COND (.PUT-TYP <SET PUT-TYP <DECL-HACK <COND (<TYPE? .PUT-TYP LIST>
						       <2 .PUT-TYP>)
						      (ELSE .PUT-TYP)>>>)>
	<COND (<AND .PUT-TYP
		    <OR <NOT <TYPE? .VAL ATOM>> <SET NAC <IN-AC? .VAL VALUE>>>>
	       <COND (<TYPE? .VAL ATOM> <OCEMIT MOVEM .NAC <+ .OFFS 1> (.AC)>)
		     (<OR <AND <==? <PRIMTYPE .VAL> LIST> <EMPTY? .VAL>>
			  <AND <==? <PRIMTYPE .VAL> FIX>
			       <==? <CHTYPE .VAL FIX> 0>>>
		      <OCEMIT SETZM <+ .OFFS 1> (.AC)>)
		     (<AND <==? <PRIMTYPE .VAL> FIX>
			   <==? <CHTYPE .VAL FIX> -1>>
		      <OCEMIT SETOM <+ .OFFS 1> (.AC)>)
		     (ELSE
		      <FLUSH-AC O*>
		      <MUNGED-AC O*>
		      <GET-INTO-ACS .VAL VALUE O*>
		      <OCEMIT MOVEM O* <+ .OFFS 1> (.AC)>)>)
	      (.PUT-TYP
	       <COND (<SET NAC <IN-AC? .VAL VALUE>>)
		     (<OR <NOT <TYPE? .VAL ATOM>> <WILL-DIE? .VAL>>
		      <GET-INTO-ACS .VAL VALUE <SET NAC O*>>)
		     (ELSE
		      <SET NAC <NEXT-AC <LOAD-AC .VAL BOTH>>>)>
	       <OCEMIT MOVEM .NAC <+ .OFFS 1> (.AC)>)
	      (ELSE
	       <COND (<SET NAC <IN-AC? .VAL BOTH>>)
		     (<OR <NOT <TYPE? .VAL ATOM>> <WILL-DIE? .VAL>>
		      <GET-INTO-ACS .VAL BOTH <SET NAC O1*>>)
		     (ELSE
		      <SET NAC <LOAD-AC .VAL BOTH>>)>
	       <OCEMIT DMOVEM .NAC .OFFS (.AC)>)>>

<DEFINE LENL!-MIMOC (L
		     "AUX" (LST <1 .L>) (VAL <3 .L>) NAC AC TAC
			   (END <GENLBL "END">) (LOOP <GENLBL "LOOP">))
	#DECL ((L) LIST (VAL AC NAC END LOOP) ATOM)
	<FLUSH-AC T*>
	<MUNGED-AC T*>
	<COND (<SET TAC <IN-AC? .LST VALUE>>
	       <SETG FIRST-AC <>>
	       <AC-TIME <GET-AC .TAC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>
	       <OCEMIT MOVEI T* .TAC>)
	      (ELSE <OCEMIT XMOVEI T* !<OBJ-VAL .LST>>)>
	<SET NAC <NEXT-AC <SET AC <ASSIGN-AC .VAL BOTH>>>>
	<COND (<==? .VAL STACK> <SET NAC O*>)
	      (<==? .LST .VAL> <SET NAC O*> <AC-TYPE <GET-AC .AC> FIX>)
	      (T <AC-TYPE <GET-AC .AC> FIX>)>
	<OCEMIT MOVSI .NAC 131072>
	<SETG LOOPTAGS (.LOOP !,LOOPTAGS)>
	<LABEL .LOOP>
	<OCEMIT SKIPE T* '(T*)>
	<OCEMIT AOBJN .NAC <XJUMP .LOOP>>
	<LABEL .END>
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <OCEMIT ANDI O* *777777*>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (<==? .VAL .LST> <OCEMIT HRRZ <NEXT-AC .AC> O*>)
	      (ELSE <OCEMIT MOVEI .NAC (.NAC)>)>>

\ 

;"UBLOCK manipulation"

<DEFINE NTHU!-MIMOC (L "AUX" (L1 <1 .L>))
	#DECL ((L) LIST (L1) ANY)
	<UPDATE-ACS>
	<SMASH-AC A1* .L1 TYPE>
	<OCEMIT MOVE O1* !<OBJ-VAL .L1>>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<PUSHJ NTHU <4 .L>>>

<DEFINE RESTU!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<PUSHJ RESTU <4 .L>>>

<DEFINE BACKU!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<PUSHJ BACKU <4 .L>>>

<DEFINE TOPU!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<PUSHJ TOPU <3 .L>>>

<SETG TOPUV!-MIMOC ,TOPU!-MIMOC>

<SETG TOPUS!-MIMOC ,TOPU!-MIMOC>

<SETG TOPUB!-MIMOC ,TOPU!-MIMOC>

<DEFINE PUTU!-MIMOC (L)
	#DECL ((L) LIST)
	<UPDATE-ACS>
	<SMASH-AC A1* <1 .L> BOTH>
	<SMASH-AC B1* <3 .L> BOTH>
	<OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>
	<PUSHJ PUTU>>

;"VECTOR manipulation"

<DEFINE NTHUU!-MIMOC (L) #DECL ((L) LIST)
	<NTHUV!-MIMOC .L T>>


<DEFINE NTHUV!-MIMOC (L
		      "OPT" (UV? <>) (AOS <>) (NOT-DEAD? T) LEN-VAR
		      "AUX" (V <1 .L>) (AMT <2 .L>) AM-AC (TAC <>) (VAL <4 .L>)
			    AC NAC NUM (AHEAD <>))
   #DECL ((L) LIST (V) <OR VECTOR ATOM> (AMT) <OR FIX ATOM> (VAL NAC) ATOM
	  (NUM) FIX (AC TAC) <OR ATOM FALSE>)
   <COND
    (<AND <NOT .AOS>
	  <NTH-PUT-LOOK-AHEAD .L
			      <COND (.UV? "PUTUU") ("PUTUV")>
			      .V
			      .AMT
			      .VAL>>)
    (ELSE
     <COND (<AND <ASSIGNED? LEN-VAR> .NOT-DEAD?> <SET VAL .LEN-VAR>)>
     <COND (<AND <NOT <AND <SET TAC <IN-AC? .V BOTH>> <SET AC <NEXT-AC .TAC>>>>
		 <NOT <SET AC <IN-AC? .V VALUE>>>
		 <OR <N==? .AMT 1>
		     <AND <OR .AOS <==? .VAL STACK>> <NOT .UV?> <N==? .AOS HRRZ>>>
		 <TYPE? .AMT FIX>>
	    <COND (<AND <NOT .AOS>
			<N==? .V .VAL>
			<SET AHEAD <LOOK-AHEAD <REST .MIML> .VAL BOTH>>>
		   <AC-TIME .AHEAD <SETG AC-STAMP <+ ,AC-STAMP 1>>>
		   <AC-TIME <GET-AC <NEXT-AC .AHEAD>> ,AC-STAMP>)>
	    <SET AC <NEXT-AC <SET TAC <LOAD-AC .V BOTH>>>>)
	   (.AC
	    <SETG FIRST-AC <>>
	    <AC-TIME <GET-AC .AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)>
     <COND
      (<TYPE? .AMT FIX>
       <COND (<AND .NOT-DEAD? <N==? .VAL STACK>>
	      <SET NAC <LOAD-AC .VAL BOTH T T .AHEAD>> ;"Really an ASSIGN-AC")>
       <COND (.UV? <SET NUM <- .AMT 1>>) (ELSE <SET NUM <* <- .AMT 1> 2>>)>
       <COND (<==? .AOS HRRZ>
	      <OCEMIT HRRZ
		      <COND (<OR <NOT .NOT-DEAD?> <==? .VAL STACK>> O*)
			    (ELSE <AC-TYPE <GET-AC .NAC> FIX> <NEXT-AC .NAC>)>
		      !<COND (.AC (.NUM (.AC))) (ELSE (@ !<OBJ-VAL .V>))>>
	      <COND (<==? .VAL STACK>
		     <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		     <OCEMIT PUSH TP* O*>
		     <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)
	     (<TYPE? .AOS FORM>
	      <COND (<=? <SPNAME <1 .AOS>> "VEQUAL?">
		     <VEQUAL?!-MIMOC <REST .AOS>
				     .AC <> <COND (<NOT .UV?> <+ .NUM 1>)
						  (.AC .NUM)
						  (ELSE (@ !<OBJ-VAL .V>))>>)
		    (<=? <SPNAME <1 .AOS>> "TYPE?">
		     <VEQUAL?!-MIMOC <REST .AOS 3>
				     .AC <> <COND (<NOT .UV?> <+ .NUM 1>)
						  (.AC .NUM)
						  (ELSE (@ !<OBJ-VAL .V>))>
				     <2 .AOS>>)
		    (ELSE
		     <EQUAL?!-MIMOC <REST .AOS> .AC <> .NUM>)>)
	     (.AOS
	      <OCEMIT .AOS
		      <COND (.NOT-DEAD? <NEXT-AC .NAC>) (ELSE O*)>
		      !<COND (<NOT .UV?> (<+ .NUM 1> (.AC)))
			     (.AC (.NUM (.AC)))
			     (ELSE (@ !<OBJ-VAL .V>))>>
	      <COND (.NOT-DEAD? <AC-TYPE <GET-AC .NAC> FIX>)>)
	     (<AND <==? .VAL STACK> <NOT .UV?>>
	      <OCEMIT PUSH TP* .NUM (.AC)>
	      <OCEMIT PUSH TP* <+ .NUM 1> (.AC)>
	      <COND (,WINNING-VICTIM
		     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	     (<==? .VAL STACK>
	      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	      <COND (,WINNING-VICTIM
		     <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)> 
	      <COND (.AC <OCEMIT PUSH TP* .NUM (.AC)>)
		    (ELSE <OCEMIT PUSH TP* @ !<OBJ-VAL .V>>)>
	      <COND (,WINNING-VICTIM
		     <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	     (<NOT .AC>
	      <COND (.UV?
		     <OCEMIT MOVE <NEXT-AC .NAC> @ !<OBJ-VAL .V>>
		     <AC-TYPE <GET-AC .NAC> FIX>)
		    (ELSE <OCEMIT DMOVE .NAC @ !<OBJ-VAL .V>>)>)
	     (.UV?
	      <OCEMIT MOVE <NEXT-AC .NAC> .NUM (.AC)>
	      <AC-TYPE <GET-AC .NAC> FIX>)
	     (T <OCEMIT DMOVE .NAC .NUM (.AC)>)>)
      (T
       <COND
	(<OR <AND <SET AM-AC <IN-AC? .AMT VALUE>>
		  <OR <NOT <AC-UPDATE <GET-AC .AM-AC>>> <WILL-DIE? .AMT>>>
	     <AND <==? .AMT .VAL>
		  <OR .AM-AC
		      <AND .NOT-DEAD?
			   <SET NAC <LOAD-AC .VAL BOTH T T .AHEAD>>>>>>
	 <COND
	  (<NOT .AM-AC>
	   <OCEMIT MOVE <SET AM-AC <NEXT-AC .NAC>> !<OBJ-VAL .AMT>>)
	  (<AND <MEMQ .AM-AC '[A2* B2* C2*]> <N==? .VAL STACK>>
	   <SET NAC <GETPROP .AM-AC AC-PAIR>>
	   <CLEAN-ACS .VAL>
	   <AC-CODE <AC-ITEM <AC-UPDATE <AC-TYPE <GET-AC .NAC> <>> T> .VAL>
		    TYPE>
	   <AC-CODE <AC-ITEM <AC-UPDATE <AC-TYPE <GET-AC .AM-AC> <>> T> .VAL>
		    VALUE>)
	  (ELSE
	   <COND (<N==? .AMT .VAL> <MUNGED-AC .AM-AC>)>
	   <FLUSH-AC .AM-AC>
	   <COND (.NOT-DEAD? <SET NAC <LOAD-AC .VAL BOTH T T .AHEAD>>)>)>)
	(ELSE
	 <COND (.AM-AC <OCEMIT MOVE T* .AM-AC> <SET AM-AC T*>)
	       (ELSE <SMASH-AC <SET AM-AC T*> .AMT VALUE>)>
	 <COND (.NOT-DEAD? <SET NAC <LOAD-AC .VAL BOTH T T .AHEAD>>)>)>
       <COND (<AND <N==? .VAL STACK> <ASSIGNED? NAC>>
	      <AC-TYPE <GET-AC .NAC> <>>)>
       <COND (<NOT .UV?> <OCEMIT LSH .AM-AC 1>)>
       <COND (.AC <OCEMIT ADD .AM-AC .AC>)
	     (ELSE <OCEMIT ADD .AM-AC !<OBJ-LOC .V 1>>)>
       <COND (<==? .AOS HRRZ>
	      <OCEMIT HRRZ
		      <COND (<OR <NOT .NOT-DEAD?> <==? .VAL STACK>> O*)
			    (ELSE <AC-TYPE <GET-AC .NAC> FIX> <NEXT-AC .NAC>)>
		      -2
		      (.AM-AC)>
	      <COND (<==? .VAL STACK>
		     <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
		     <OCEMIT PUSH TP* O*>)>)
	     (<TYPE? .AOS FORM>
	      <COND (<=? <SPNAME <1 .AOS>> "VEQUAL?">
		     <VEQUAL?!-MIMOC <REST .AOS> .AM-AC <> -1>)
		    (<=? <SPNAME <1 .AOS>> "TYPE?">
		     <VEQUAL?!-MIMOC <REST .AOS 3> .AM-AC <> -2 <2 .AOS>>)
		    (ELSE
		     <EQUAL?!-MIMOC <REST .AOS> .AM-AC <> -2>)>)
	     (.AOS
	      <OCEMIT .AOS
		      <COND (.NOT-DEAD?
			     <AC-TYPE <GET-AC .NAC> FIX>
			     <NEXT-AC .NAC>)
			    (ELSE O*)>
		      -1
		      (.AM-AC)>)
	     (<AND <==? .VAL STACK> <NOT .UV?>>
	      <OCEMIT PUSH TP* -2 (.AM-AC)>
	      <OCEMIT PUSH TP* -1 (.AM-AC)>
	      <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	     (<==? .VAL STACK>
	      <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	      <OCEMIT PUSH TP* -1 (.AM-AC)>
	      <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	     (.UV?
	      <OCEMIT MOVE <NEXT-AC .NAC> -1 (.AM-AC)>
	      <AC-TYPE <GET-AC .NAC> FIX>)
	     (T <OCEMIT DMOVE .NAC -2 (.AM-AC)>)>
       <AC-CODE <GET-AC T*> DUMMY>)>)>>

<DEFINE PUTUU!-MIMOC (L) #DECL ((L) LIST)
	<PUTUV!-MIMOC .L T>>

<DEFINE PUTUV!-MIMOC (L
		      "OPT" (UV? <>)
		      "AUX" (V <1 .L>) (AMT <2 .L>) (TAC <>) (VAL <3 .L>) AC
			    AMT-AC NAC (PUT-TYP <EXTRAMEM TYPE .L>))
	#DECL ((L) LIST (V) <OR VECTOR ATOM> (AMT) <OR FIX ATOM> (NAC) ATOM
	       (VAL) ANY (AC TAC) <OR ATOM FALSE>)
	<COND (<AND <NOT <AND <SET TAC <IN-AC? .V BOTH>>
			      <SET AC <NEXT-AC .TAC>>>>
		    <NOT <SET AC <IN-AC? .V VALUE>>>
		    <N==? .AMT 1>
		    <TYPE? .AMT FIX>>
	       <SET AC <NEXT-AC <SET TAC <LOAD-AC .V BOTH>>>>)
	      (.AC
	       <SETG FIRST-AC <>>
	       <AC-TIME <GET-AC .AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)>
	<COND (<AND <TYPE? .AMT FIX> .UV?>
	       <COND (.AC <DO-PUT FIX .AC .VAL <- .AMT 2>>)
		     (<OR <AND <==? <PRIMTYPE .VAL> LIST> <EMPTY? .VAL>>
			  <AND <==? <PRIMTYPE .VAL> WORD>
			       <==? <CHTYPE .VAL FIX> 0>>>
		      <OCEMIT SETZM @ !<OBJ-VAL .V>>)
		     (<AND <==? <PRIMTYPE .VAL> WORD>
			   <==? <CHTYPE .VAL FIX> -1>>
		      <OCEMIT SETOM @ !<OBJ-VAL .V>>)
		     (<TYPE? .VAL ATOM>
		      <SET NAC <NEXT-AC <LOAD-AC .VAL BOTH>>>
		      <OCEMIT MOVEM .NAC @ !<OBJ-VAL .V>>)
		     (ELSE
		      <GET-INTO-ACS .VAL VALUE O*>
		      <OCEMIT MOVEM O* @ !<OBJ-VAL .V>>)>)
	      (<TYPE? .AMT FIX>
	       <COND (.AC <DO-PUT .PUT-TYP .AC .VAL <* <- .AMT 1> 2>>)
		     (ELSE
		      <SET NAC <LOAD-AC .VAL BOTH>>
		      <OCEMIT DMOVEM .NAC @ !<OBJ-VAL .V>>)>)
	      (T
	       <COND (<AND <SET AMT-AC <IN-AC? .AMT VALUE>>
			   <WILL-DIE? .AMT>>
		      <SETG FIRST-AC <>>
		      <DEAD!-MIMOC (.AMT) T>
		      <AC-TIME <GET-AC .AMT-AC> ,AC-STAMP>
		      <AC-TIME <GET-AC <GETPROP .AMT-AC AC-PAIR>> ,AC-STAMP>)
		     (ELSE
		      <GET-INTO-ACS .AMT VALUE <SET AMT-AC T*>>)>
	       <COND (<NOT .UV?> <OCEMIT LSH .AMT-AC 1>)>
	       <COND (.AC <OCEMIT ADD .AMT-AC .AC>)
		     (ELSE <OCEMIT ADD .AMT-AC !<OBJ-VAL .V>>)>
	       <COND (.UV? <DO-PUT FIX .AMT-AC .VAL -2>)
		     (ELSE <DO-PUT .PUT-TYP .AMT-AC .VAL -2>)>
	       <AC-CODE <GET-AC .AMT-AC> DUMMY>)>>

<DEFINE RESTUU!-MIMOC (L) #DECL ((L) LIST)
	<RESTUV!-MIMOC .L T>>

<DEFINE RESTUV!-MIMOC (L
		       "OPT" (UV? <>)
		       "AUX" (V <1 .L>) (AMT <2 .L>) (VAL <4 .L>) AC NAC
			     (RES-TYP <EXTRAMEM TYPE .L>))
	#DECL ((L) LIST (V) <OR VECTOR ATOM> (AMT) <OR ATOM FIX> (VAL) ATOM
	       (AC NAC) <OR ATOM FALSE>)
	<COND (<TYPE? .AMT FIX>
	       <COND (<AND <==? .AMT 1> <==? .V .VAL>>
		      <SET AC <IN-AC? .V BOTH>>)
		     (ELSE <SET AC <LOAD-AC .V BOTH>>)>
	       <COND (.AC
		      <COND (<AND <N==? .V .VAL>
				  <NOT <WILL-DIE? .V>>
				  <AC-UPDATE <GET-AC .AC>>>
			     <CLEAN-ACS .VAL>
			     <SET NAC <ASSIGN-AC .VAL BOTH T>>
			     <OCEMIT DMOVE .NAC .AC>)
			    (ELSE
			     <CLEAN-ACS .VAL>
			     <COND (<N==? .VAL STACK> <ALTER-AC .AC .VAL>)
				   (ELSE <MUNGED-AC .AC T>)>
			     <SET NAC .AC>)>
		      <OCEMIT ADDI
			      <NEXT-AC .NAC>
			      <COND (.UV? .AMT) (T <* .AMT 2>)>>
		      <OCEMIT SUBI .NAC .AMT>)
		     (ELSE
		      <SET NAC <ASSIGN-AC .VAL BOTH T>>
		      <OCEMIT SOS .NAC !<OBJ-LOC .V 0>>
		      <COND (.UV? <OCEMIT AOS <NEXT-AC .NAC> !<OBJ-LOC .V 1>>)
			    (ELSE
			     <OCEMIT MOVEI <NEXT-AC .NAC> 2>
			     <OCEMIT ADDB <NEXT-AC .NAC> !<OBJ-LOC .V 1>>)>
		      <AC-UPDATE <GET-AC .NAC> <>>
		      <AC-UPDATE <GET-AC <NEXT-AC .NAC>> <>>
		      <AC-ITEM <GET-AC .NAC> .V>
		      <AC-ITEM <GET-AC <NEXT-AC .NAC>> .V>
		      <AC-CODE <GET-AC .NAC> TYPE>
		      <AC-CODE <GET-AC <NEXT-AC .NAC>> VALUE>)>)
	      (<==? .V .VAL>
	       <SET NAC <LOAD-AC .V BOTH>>
	       <COND (<AND <SET AC <IN-AC? .AMT VALUE>>
			   <OR <AND <WILL-DIE? .AMT> <DEAD!-MIMOC (.AMT) T>>
			       <NOT <AC-UPDATE <GET-AC .AC>>>>>)
		     (ELSE <SET AC <>>)>
	       <OCEMIT SUB .NAC !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>
	       <COND (<AND <NOT .UV?> .AC> <OCEMIT LSH .AC 1>)
		     (<NOT .UV?>
		      <OCEMIT ADD
			      <NEXT-AC .NAC>
			      !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>)>
	       <OCEMIT ADD
		       <NEXT-AC .NAC>
		       !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>
	       <AC-UPDATE <GET-AC .NAC> T>
	       <AC-UPDATE <GET-AC <NEXT-AC .NAC>> T>)
	      (<==? .VAL .AMT>
	       <SET AC <IN-AC? .AMT VALUE>>
	       <SETG FIRST-AC <>>
	       <SET NAC <LOAD-AC .V BOTH>>
	       <FLUSH-AC .NAC T>
	       <MUNGED-AC .NAC T>
	       <CLEAN-ACS .AMT>
	       <OCEMIT SUB .NAC !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>
	       <COND (<AND <NOT .UV?> .AC> <OCEMIT LSH .AC 1>)
		     (<NOT .UV?>
		      <OCEMIT ADD
			      <NEXT-AC .NAC>
			      !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>)>
	       <OCEMIT ADD
		       <NEXT-AC .NAC>
		       !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>
	       <ALTER-AC .NAC .VAL>)
	      (T
	       <SET NAC <LOAD-AC .V BOTH>>
	       <FLUSH-AC .NAC T>
	       <MUNGED-AC .NAC T>
	       <COND (<AND <SET AC <IN-AC? .AMT VALUE>>
			   <OR <AND <WILL-DIE? .AMT> <DEAD!-MIMOC (.AMT) T>>
			       <NOT <AC-UPDATE <GET-AC .AC>>>
			       .UV?>>)
		     (ELSE <SET AC <>>)>
	       <OCEMIT SUB .NAC !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>
	       <COND (<AND <NOT .UV?> .AC> <OCEMIT LSH .AC 1>)
		     (<NOT .UV?>
		      <OCEMIT ADD
			      <NEXT-AC .NAC>
			      !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>)>
	       <OCEMIT ADD
		       <NEXT-AC .NAC>
		       !<COND (.AC (.AC)) (ELSE <OBJ-VAL .AMT>)>>
	       <COND (<N==? .VAL STACK> <ALTER-AC .NAC .VAL>)>)>
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* .NAC>
	       <OCEMIT PUSH TP* <NEXT-AC .NAC>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE EMPUV?!-MIMOC (L "AUX" (V <1 .L>) (TAG <3 .L>) (JUMP JUMPE) 
		       	       (TRN TRNN) AC)
	#DECL ((L) LIST (V) <OR VECTOR ATOM> (JUMP TRN TAG) ATOM
	       (AC) <OR FALSE ATOM>)
	<COND (<==? <2 .L> -> <SET JUMP JUMPN> <SET TRN TRNE>)>
	<LABEL-UPDATE-ACS .TAG <>>
	<COND (<SET AC <IN-AC? .V TYPE>>
	       <OCEMIT .TRN .AC *777777*>
	       <OCEMIT JRST <XJUMP .TAG>>)
	      (T
	       <OCEMIT HRRZ O* !<OBJ-TYP .V>>
	       <OCEMIT .JUMP O* <XJUMP .TAG>>)>>

<DEFINE LENUV!-MIMOC (L "AUX" (V <1 .L>) (VAL <3 .L>) AC)
	#DECL ((L) LIST (V) <OR VECTOR ATOM> (VAL AC) ATOM)
	<COND (<==? .VAL STACK>
	       <OCEMIT PUSH TP* !<TYPE-WORD FIX>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
	       <OCEMIT HRRZ O* !<OBJ-TYP .V>>
	       <OCEMIT PUSH TP* O*>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>)
	      (T
	       <SET AC <ASSIGN-AC .VAL BOTH>>
	       <OCEMIT HRRZ <NEXT-AC .AC> !<OBJ-TYP .V>>
	       <AC-TYPE <GET-AC .AC> FIX>)>>


;"STRING and BYTES manipulation"

<DEFINE NTHUB!-MIMOC (L)
  <NTHUS!-MIMOC .L T>>

<DEFINE NTHUS!-MIMOC (L
		      "OPTIONAL" (BYTES? <>)
		      "AUX" (V <1 .L>) (AMT <2 .L>) (VAL <4 .L>) AC NUM
			    (NAC <PUTPROP .L DONE>))
	#DECL ((L) LIST (V) <OR BYTES STRING ATOM> (AMT) <OR FIX ATOM>
	       (VAL) ATOM (NUM) FIX (AC BYTES?) <OR ATOM FALSE>)
	<SETG DIE-LATER <SETG REMEMBER-STRING <>>>
	<COND (<AND <NOT .NAC> <N==? .VAL .V> <TYPE? .AMT FIX>>
	       <SET NAC <STRING-PUT-NTH-LOOK-AHEAD .V NTH .VAL .BYTES? .AMT>>)>
	<COND (<NOT .NAC>
	       <COND (<SET AC <IN-AC? .V FUNNY-VALUE>>
		      <AC-CODE <GET-AC .AC> VALUE>
		      <SET AMT 1>
		      <SETG FIRST-AC <>>
		      <AC-TIME <GET-AC .AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)
		     (<AND <N==? .AMT 1> <N==? .AMT 2>>
		      <SET AC <LOAD-AC .AMT VALUE>>
		      <FLUSH-AC .AC>
		      <MUNGED-AC .AC>
		      <OCEMIT <COND (,ADJBP-HACK MADJBP)
				    (T ADJBP)>
			      .AC !<OBJ-VAL .V>>)
		     (<AND <SET AC <IN-AC? .V VALUE>>
			   <OR <WILL-DIE? .V>
			       <NOT <AC-UPDATE <GET-AC .AC>>>
			       <==? .V .VAL>
			       ,DIE-LATER>>
		      <MUNGED-AC .AC>
		      <SETG FIRST-AC <>>
		      <AC-TIME <GET-AC .AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)
		     (,REMEMBER-STRING
		      <COND (.AC
			     <FLUSH-AC .AC>
			     <SETG FIRST-AC <>>
			     <AC-TIME <GET-AC .AC>
				      <SETG AC-STAMP <+ ,AC-STAMP 1>>>)
			    (ELSE
			     <SETG FIRST-AC <>>
			     <SET AC <NEXT-AC <LOAD-AC .V BOTH>>>)>
		      <MUNGED-AC .AC>)
		     (ELSE <SET AC <>>)>
	       <COND (<==? .VAL STACK>
		      <COND (.BYTES? <OCEMIT PUSH TP* !<TYPE-WORD FIX>>)
			    (T <OCEMIT PUSH TP* !<TYPE-WORD CHARACTER>>)>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
		      <COND (<NOT .AC>
			     <OCEMIT MOVE O* !<OBJ-VAL .V>>
			     <SET AC O*>)>
		      <DNTH O* .AC .AMT>
		      <OCEMIT PUSH TP* O*>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
		      <AC-CODE <GET-AC .AC> DUMMY>)
		     (T
		      <SET NAC <ASSIGN-AC .VAL BOTH>>
		      <COND (<NOT .AC>
			     <OCEMIT MOVE
				     <SET AC <NEXT-AC .NAC>>
				     !<OBJ-VAL .V>>)>
		      <DNTH <NEXT-AC .NAC> .AC .AMT>
		      <COND (.BYTES? <AC-TYPE <GET-AC .NAC> FIX>)
			    (T <AC-TYPE <GET-AC .NAC> CHARACTER>)>)>
	       <COND (<AND .AC
			   <OR <NOT .NAC>
			       <AND <N==? .AC .NAC>
				    <N==? .AC <NEXT-AC .NAC>>>>>
		      <COND (,REMEMBER-STRING
			     <AC-UPDATE <AC-CODE <AC-ITEM <GET-AC .AC> .V>
						 FUNNY-VALUE> <>>)
			    (ELSE
			     <AC-CODE <GET-AC .AC> DUMMY>)>)>)>>

<DEFINE DNTH (AC1 AC2 AMT)
	#DECL ((AC1 AC2) ATOM (AMT) <OR ATOM FIX>)
	<COND (<OR <==? .AMT 1><==? .AMT 2>>
	       <COND (<==? .AMT 2>
		      <OCEMIT IBP O* .AC2>)>
	       <OCEMIT ILDB .AC1 .AC2>)
	      (ELSE
	       <OCEMIT LDB .AC1 .AC2>)>>

<DEFINE PUTUS!-MIMOC (L
		      "OPT" (BYTES? <>)
		      "AUX" (V <1 .L>) (AMT <2 .L>) (VAL <3 .L>) (AC <>) NAC
			    (DONE <PUTPROP .L DONE>) TAC)
	#DECL ((L) LIST (V) <OR BYTES STRING ATOM> (AMT) <OR FIX ATOM>
	       (NAC) <OR ATOM FALSE> (VAL) ANY (TAC AC) <OR ATOM FALSE>)
	<SETG DIE-LATER <SETG REMEMBER-STRING <>>>
	<COND (<AND <NOT .DONE> <TYPE? .AMT FIX>>
	       <SET DONE <STRING-PUT-NTH-LOOK-AHEAD
			  .V PUT .VAL .BYTES? .AMT>>)>
	<COND (<NOT .DONE>
	       <COND (<OR <SET AC <IN-AC? .V FUNNY-VALUE>>
			  <==? .AMT 1>
			  <==? .AMT 2>>
		      <COND (.AC
			     <AC-CODE <GET-AC .AC> VALUE>
			     <SET AMT 1>
			     <SETG FIRST-AC <>>
			     <AC-TIME <GET-AC .AC>
				      <SETG AC-STAMP <+ ,AC-STAMP 1>>>)
			    (<AND <SET AC <IN-AC? .V VALUE>>
				  <OR <WILL-DIE? .V> ,DIE-LATER>>
			     <SETG FIRST-AC <>>
			     <AC-TIME <GET-AC .AC>
				      <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			     <FLUSH-AC .AC>
			     <MUNGED-AC .AC>)
			    (,REMEMBER-STRING
			     <SETG FIRST-AC <>>
			     <SET AC <NEXT-AC <SET TAC <LOAD-AC .V BOTH>>>>
			     <COND (<NOT <OR ,DIE-LATER <WILL-DIE? .V>>>
				    <FLUSH-AC .TAC T>)>
			     <MUNGED-AC .TAC T>)
			    (ELSE
			     <OCEMIT MOVE <SET AC O*> !<OBJ-VAL .V>>)>
		      <COND (<==? .AMT 2>
			     <OCEMIT IBP O* .AC>)>
		      <COND (<SET NAC <IN-AC? .VAL VALUE>>)
			    (<AND <TYPE? .VAL ATOM>
				  <NOT <WILL-DIE? .VAL>>>
			     <SET NAC <NEXT-AC <LOAD-AC .VAL BOTH>>>)
			    (ELSE
			     <GET-INTO-ACS .VAL VALUE <SET NAC O1*>>)>
		      <OCEMIT IDPB .NAC .AC>
		      <COND (,REMEMBER-STRING
			     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .AC> <>>
					       .V> FUNNY-VALUE>)
			    (ELSE
			     <AC-CODE <GET-AC .AC> DUMMY>)>)
		     (ELSE
		      <COND (<OR <AND <SET TAC <IN-AC? .AMT BOTH>>
				      <SET AC <NEXT-AC .TAC>>>
				 <SET AC <IN-AC? .AMT VALUE>>>
			     <SETG FIRST-AC <>>
			     <COND (<WILL-DIE? .AMT>
				    <DEAD!-MIMOC (.AMT) T>)
				   (<AC-UPDATE <GET-AC .AC>>
				    <OCEMIT MOVE O1* .AC>
				    <SET AC O1*>)>
			     <COND (<N==? .AC O1*>
				    <COND (.TAC
					   <AC-TIME <GET-AC .TAC>
						    ,AC-STAMP>
					   <FLUSH-AC .TAC T>)
					  (ELSE <FLUSH-AC .AC>)>
				    <AC-TIME <GET-AC .AC> ,AC-STAMP>)>)
			    (,REMEMBER-STRING
			     <SET AC <LOAD-AC .AMT VALUE>>)
			    (ELSE
			     <GET-INTO-ACS .AMT VALUE <SET AC O1*>>)>
		      <OCEMIT <COND (,ADJBP-HACK MADJBP)
				    (T ADJBP)> .AC !<OBJ-VAL .V>>
		      <COND (<AND <TYPE? .VAL ATOM>
				  <NOT <WILL-DIE? .VAL>>>
			     <SET NAC <NEXT-AC <LOAD-AC .VAL BOTH>>>)
			    (ELSE
			     <GET-INTO-ACS .VAL VALUE <SET NAC O*>>)>
		      <OCEMIT DPB .NAC .AC>
		      <COND (<N==? .AC O1*>
			     <COND (.TAC <MUNGED-AC .TAC T>)
				   (ELSE <MUNGED-AC .AC>)>
			     <COND (,REMEMBER-STRING
				    <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .AC>
								 <>> .V>
					     FUNNY-VALUE>)>)>)>)>>

<DEFINE PUTUB!-MIMOC (L) <PUTUS!-MIMOC .L T>>

<DEFINE RESTUS!-MIMOC (L
		       "OPTIONAL" (BYTES? <>) (OTH-VAL <>) OP DEAD?
		       "AUX" (STR <1 .L>) (AMT <2 .L>) (VAL <4 .L>) AC
			     (OTH-AC <>) (NAC <PUTPROP .L DONE>))
   #DECL ((L) LIST (STR) ATOM (AMT) <OR FIX ATOM> (VAL) ATOM
	  (AC NAC) <OR ATOM FALSE> (BYTES?) <OR ATOM FALSE>)
   <COND
    (<AND <NOT .NAC> <==? .AMT 1> <N==? .STR .VAL> <NOT .OTH-VAL>>
     <SET NAC <STRING-REST-LOOK-AHEAD .L .STR .VAL .BYTES?>>)
    (.OTH-VAL
     <COND (<==? .OP PUT>
	    <COND (<SET OTH-AC <IN-AC? .OTH-VAL BOTH>>
		   <AC-TIME <GET-AC .OTH-AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>
		   <AC-TIME <GET-AC <SET OTH-AC <NEXT-AC .OTH-AC>>> ,AC-STAMP>)
		  (<SET OTH-AC <IN-AC? .OTH-VAL VALUE>>
		   <AC-TIME <GET-AC .OTH-AC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>)
		  (<TYPE? .OTH-VAL ATOM>
		   <OCEMIT MOVE <SET OTH-AC O*> !<OBJ-VAL .OTH-VAL>>)
		  (ELSE
		   <OCEMIT MOVEI <SET OTH-AC O*> <CHTYPE .OTH-VAL FIX>>)>)>)>
   <COND
    (.NAC <SET VAL T>)
    (<AND <==? .AMT 1> <NOT <IN-AC? .STR BOTH>> <==? .STR .VAL>>
     <COND (<AND <SET NAC <IN-AC? .STR TYPE>> <NOT <AC-UPDATE <GET-AC .NAC>>>>
	    <MUNGED-AC .NAC>)>
     <COND (<AND <SET NAC <IN-AC? .STR VALUE>> <NOT <AC-UPDATE <GET-AC .NAC>>>>
	    <MUNGED-AC .NAC>)>
     <OCEMIT SOS O* !<OBJ-TYP .STR>>
     <COND (.OTH-VAL
	    <COND (<==? .OP PUT> <OCEMIT IDPB .OTH-AC !<OBJ-VAL .STR>>)
		  (<==? .OTH-VAL STACK>
		   <OCEMIT ILDB O* !<OBJ-VAL .STR>>
		   <OCEMIT PUSH
			   TP*
			   !<TYPE-WORD <COND (.BYTES? FIX) (ELSE CHARACTER)>>>
		   <OCEMIT PUSH TP* O*>
		   <COND (,WINNING-VICTIM
			  <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		  (ELSE
		   <SET OTH-AC <ASSIGN-AC .OTH-VAL BOTH>>
		   <AC-TYPE <GET-AC .OTH-AC>
			    <COND (.BYTES? FIX) (ELSE CHARACTER)>>
		   <OCEMIT ILDB <NEXT-AC .OTH-AC> !<OBJ-VAL .STR>>)>)
	   (ELSE <OCEMIT IBP O* !<OBJ-VAL .STR>>)>)
    (<TYPE? .AMT FIX>
     <COND (<==? .AMT 1>
	    <SET NAC <LOAD-AC .STR BOTH>>
	    <COND (<OR <NOT .OTH-VAL> <==? .OP PUT> <==? .OTH-VAL STACK>>
		   <COND (<NOT <OR <AND <ASSIGNED? DEAD?> .DEAD?>
				   <AND <NOT <ASSIGNED? DEAD?>>
					<WILL-DIE? .STR>>
				   <==? .STR .VAL>>>
			  <FLUSH-AC .NAC T>)>
		   <MUNGED-AC .NAC T>)>)
	   (ELSE
	    <SET NAC <LOAD-AC .STR TYPE>>
	    <COND (<NOT <WILL-DIE? .STR>> <FLUSH-AC .NAC>)>
	    <MUNGED-AC .NAC>)>
     <OCEMIT SUBI .NAC .AMT>
     <COND
      (<==? .AMT 1>
       <COND (.OTH-VAL
	      <COND (<==? .OP PUT> <OCEMIT IDPB .OTH-AC <NEXT-AC .NAC>>)
		    (<==? .OTH-VAL STACK>
		     <OCEMIT ILDB O* <NEXT-AC .NAC>>
		     <OCEMIT PUSH
			     TP*
			     !<TYPE-WORD <COND (.BYTES? FIX)
					       (ELSE CHARACTER)>>>
		     <OCEMIT PUSH TP* O*>
		     <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
		    (ELSE
		     <COND (<NOT <OR <AND <ASSIGNED? DEAD?> .DEAD?>
				     <AND <NOT <ASSIGNED? DEAD?>>
					  <WILL-DIE? .STR>>
				     <==? .STR .VAL>>>
			    <FLUSH-AC .NAC T>)>
		     <MUNGED-AC .NAC T>
		     <SET OTH-AC <ASSIGN-AC .OTH-VAL BOTH>>
		     <AC-TYPE <GET-AC .OTH-AC>
			      <COND (.BYTES? FIX) (ELSE CHARACTER)>>
		     <OCEMIT ILDB <NEXT-AC .OTH-AC> <NEXT-AC .NAC>>)>)
	     (ELSE <OCEMIT IBP O* <NEXT-AC .NAC>>)>)
      (<AND <==? <IN-AC? .STR VALUE> <NEXT-AC .NAC>>
	    <AC-UPDATE <GET-AC <NEXT-AC .NAC>>>>
       <SMASH-AC O* .STR VALUE>
       <MUNGED-AC O*>
       <OCEMIT MOVEI <NEXT-AC .NAC> .AMT>
       <OCEMIT <COND (,ADJBP-HACK MADJBP)
		     (T ADJBP)> <NEXT-AC .NAC> O*>)
      (ELSE
       <FLUSH-AC <NEXT-AC .NAC>>
       <MUNGED-AC <NEXT-AC .NAC>>
       <OCEMIT MOVEI <NEXT-AC .NAC> .AMT>
       <OCEMIT <COND (,ADJBP-HACK MADJBP)
		     (T ADJBP)> <NEXT-AC .NAC> !<OBJ-VAL .STR>>)>
     <CLEAN-ACS .VAL>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .NAC> T> .VAL> TYPE>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC <NEXT-AC .NAC>> T> .VAL> VALUE>)
    (<==? .AMT .VAL>
     <COND (<SET AC <IN-AC? .AMT VALUE>>) (ELSE <SET AC <LOAD-AC .AMT VALUE>>)>
     <SET NAC <GETPROP .AC AC-PAIR>>
     <OCEMIT MOVE .NAC !<OBJ-TYP .STR>>
     <OCEMIT SUB .NAC !<OBJ-VAL .AMT>>
     <OCEMIT <COND (,ADJBP-HACK MADJBP)
		   (T ADJBP)> .AC !<OBJ-VAL .STR>>
     <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC .NAC> T> .VAL> TYPE>
     <AC-ITEM <AC-UPDATE <GET-AC .AC> T> .VAL>)
    (<==? .VAL .STR>
     <SET NAC <LOAD-AC .STR TYPE>>
     <OCEMIT SUB .NAC !<OBJ-VAL .AMT>>
     <FLUSH-AC <NEXT-AC .NAC>>
     <MUNGED-AC <NEXT-AC .NAC>>
     <OCEMIT MOVE <NEXT-AC .NAC> !<OBJ-VAL .AMT>>
     <OCEMIT <COND (,ADJBP-HACK MADJBP)
		   (T ADJBP)> <NEXT-AC .NAC> !<OBJ-VAL .STR>>
     <AC-ITEM <AC-UPDATE <GET-AC .NAC> T> .VAL>
     <AC-TIME <AC-CODE <AC-ITEM <AC-UPDATE <GET-AC <NEXT-AC .NAC>> T> .VAL>
		       VALUE>
	      ,AC-STAMP>)
    (T
     <SET NAC <ASSIGN-AC .VAL BOTH T>>
     <COND (<N==? <IN-AC? .STR TYPE> .NAC>
	    <OCEMIT MOVE .NAC !<OBJ-TYP .STR>>)>
     <OCEMIT SUB .NAC !<OBJ-VAL .AMT>>
     <OCEMIT MOVE <NEXT-AC .NAC> !<OBJ-VAL .AMT>>
     <OCEMIT <COND (,ADJBP-HACK MADJBP)
		   (T ADJBP)> <NEXT-AC .NAC> !<OBJ-VAL .STR>>)>
   <COND (<==? .VAL STACK>
	  <OCEMIT PUSH TP* .NAC>
	  <OCEMIT PUSH TP* <NEXT-AC .NAC>>
	  <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>>

<DEFINE RESTUB!-MIMOC (L)
  <RESTUS!-MIMOC .L T>>

<SETG LENU!-MIMOC ,LENUV!-MIMOC>

<SETG LENUS!-MIMOC ,LENUV!-MIMOC>

<SETG LENUB!-MIMOC ,LENUV!-MIMOC>

<SETG LENUU!-MIMOC ,LENUV!-MIMOC>

<SETG EMPU?!-MIMOC ,EMPUV?!-MIMOC>

<SETG EMPUU?!-MIMOC ,EMPUV?!-MIMOC>

<SETG EMPUS?!-MIMOC ,EMPUV?!-MIMOC>

<SETG EMPUB?!-MIMOC ,EMPUV?!-MIMOC>

<SETG LENR!-MIMOC ,LENUV!-MIMOC>

<DEFINE EMPR?!-MIMOC (L) T ;"NO CODE">


;"RECORD manipulation"

<DEFINE GVAL!-MIMOC (L "AUX" (ATM <1 .L>) (VAL <3 .L>) AC NAC (XGL <>)
			     (RATM .ATM))
	#DECL ((L) LIST (ATM) <OR ATOM <FORM ATOM ATOM>> (VAL AC) ATOM)
	<COND (<TYPE? .ATM FORM> 
	       <SET XGL <CHTYPE <2 .ATM> XGLOC>>
	       <SET RATM <1 .ATM>>)>
	<COND (<AND ,GVAL-CAREFUL <N=? <SPNAME .RATM> "M$$BINDID">>
	       <COND (.XGL
		      <SAVE-ACS>
		      <OCEMIT SKIPN @ !<OBJ-VAL .XGL>>
		      <OCEMIT GVERR !<OBJ-VAL .XGL>>
		      <OCEMIT DMOVE A1* @ !<OBJ-VAL .XGL>>)
		     (<SET NAC <IN-AC? .ATM VALUE>>
		      <COND (<OR <==? .VAL .ATM> <WILL-DIE? .ATM>>
			     <DEAD!-MIMOC (.ATM) T>)>
		      <SAVE-ACS>
		      <OCEMIT SKIPE (.NAC)>
		      <OCEMIT SKIPN @ (.NAC)>
		      <OCEMIT GVERR .NAC>
		      <OCEMIT DMOVE A1* @ (.NAC)>) 
		     (ELSE
		      <SAVE-ACS>
		      <OCEMIT SKIPE T* @ !<OBJ-VAL .ATM>>
		      <OCEMIT SKIPN '(T*)>
		      <OCEMIT GVERR !<OBJ-VAL .ATM>>
		      <OCEMIT DMOVE A1* '(T*)>)>
	       <PUSHJ-VAL .VAL>) 
	      (<==? .VAL STACK>
	       <COND (<AND .XGL <NOT ,BOOT-MODE>>
		      <SMASH-AC <SET NAC T*> .XGL VALUE>)
		     (<SET NAC <IN-AC? .ATM VALUE>>)
		     (ELSE
		      <SET NAC <NEXT-AC <LOAD-AC .ATM BOTH>>>)>
	       <COND (<OR ,BOOT-MODE <NOT .XGL>>
		      <OCEMIT MOVE T* (.NAC)>
		      <MUNGED-AC T*>)>
	       <OCEMIT PUSH TP* '(T*)>
	       <OCEMIT PUSH TP* 1 '(T*)>
	       <COND (,WINNING-VICTIM
		      <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	      (T
	       <COND (,BOOT-MODE
		      <SMASH-AC T* .ATM VALUE>
		      <SET AC <ASSIGN-AC .VAL BOTH>>
		      <OCEMIT DMOVE .AC @ '(T*)>
		      <AC-CODE <GET-AC T*> DUMMY>)
		     (.XGL
		      <SET AC <ASSIGN-AC .VAL BOTH>>
		      <OCEMIT DMOVE .AC @ !<OBJ-VAL .XGL>>)
		     (ELSE
		      <SET NAC <OR <IN-AC? .ATM VALUE>
				   <NEXT-AC <LOAD-AC .ATM BOTH>>>>
		      <SET AC <ASSIGN-AC .VAL BOTH>>
		      <OCEMIT DMOVE .AC @ (.NAC)>)>)>>

<DEFINE SETG!-MIMOC (L "AUX" (ATM <1 .L>) (VAL <2 .L>) AC)
	#DECL ((L) LIST (ATM) <FORM ATOM ATOM> (AC) ATOM (VAL) ANY)
	<SET AC <LOAD-AC .VAL BOTH>>
	<COND (,BOOT-MODE
	       <SMASH-AC T* .ATM VALUE>
	       <OCEMIT DMOVEM .AC @ '(T*)>
	       <AC-CODE <GET-AC T*> DUMMY>)
	      (T
	       <OCEMIT DMOVEM .AC @ !<OBJ-VAL <CHTYPE <2 .ATM> XGLOC>>>)>> 

<GDECL (NTHR-TABLE PUTR-TABLE) <VECTOR [REST ATOM]>>

<SETG NTHR-TABLE
      '[LBIND
	LBIND-NTH
	T$LBIND
	LBIND-NTH
	GBIND
	LBIND-NTH
	T$GBIND
	LBIND-NTH
	ATOM
	ATOM-NTH
	T$ATOM
	ATOM-NTH
	LVAL
	ATOM-NTH
	GVAL
	ATOM-NTH
	OBLIST
	ATOM-NTH
	T$OBLIST
	ATOM-NTH
	T$FRAME
	FRAME-NTH
	FRAME
	FRAME-NTH]>

<SETG PUTR-TABLE
      '[LBIND
	LBIND-PUT
	T$LBIND
	LBIND-PUT
	GBIND
	LBIND-PUT
	T$GBIND
	LBIND-PUT
	ATOM
	ATOM-PUT
	T$ATOM
	ATOM-PUT
	LVAL
	ATOM-PUT
	GVAL
	ATOM-PUT
	OBLIST
	ATOM-PUT
	T$OBLIST
	ATOM-PUT
	T$FRAME
	FRAME-PUT
	FRAME
	FRAME-PUT]>

<DEFINE FRAME-PUT (L "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <3 .L>) AC NAC)
	#DECL ((L) LIST)
	<COND (<N==? .ARG2 1>
	       <PUTR!-MIMOC .L T>)
	      (ELSE
	       <SET NAC <COND (<IN-AC? .ARG1 VALUE>)
			      (<NOT <WILL-DIE? .ARG1>>
			       <NEXT-AC <LOAD-AC .ARG1 BOTH>>)
			      (T <SMASH-AC T* .ARG1 VALUE>)>>
	       <SET AC <COND (<IN-AC? .VAL VALUE>)
			     (<OR <WILL-DIE? .VAL>
				  <NOT <TYPE? .VAL ATOM>>>
			      <SMASH-AC O* .VAL VALUE>)
			     (ELSE
			      <SETG FIRST-AC <>>
			      <AC-TIME <GET-AC .NAC>
				       <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			      <NEXT-AC <LOAD-AC .VAL BOTH>>)>>
	       <OCEMIT MOVEM .AC 0 (.NAC)>
	       <COND (<==? .NAC T*> <AC-CODE <GET-AC T*> DUMMY>)>)>>

<DEFINE FRAME-NTH (L "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <4 .L>) AC NAC XAC)
	#DECL ((L) LIST (ARG1) ANY (ARG2) FIX (AC NAC VAL) ATOM
	       (XAC) <OR FALSE ATOM> (EX) <OR FALSE <LIST ATOM ATOM ATOM>>)
	<COND (<AND <N==? .ARG2 1> <N==? .ARG2 5> <N==? .ARG2 7>>
	       <NTHR!-MIMOC .L T>)
	      (T
	       <SET NAC <COND (<AND <SET XAC <IN-AC? .ARG1 VALUE>>
				    <N==? .XAC O*>>
			       <AC-TIME <GET-AC .XAC>
					<SETG AC-STAMP <+ ,AC-STAMP 1>>>
			       <SETG FIRST-AC <>>
			       .XAC)
			      (<NOT <WILL-DIE? .ARG1>>
			       <NEXT-AC <LOAD-AC .ARG1 BOTH>>)
			      (T <SMASH-AC T* .ARG1 VALUE>)>>
	       <SET AC <ASSIGN-AC .VAL BOTH T>>
	       <COND (<==? .ARG2 1>		;"The frames MSUBR"
		      <AC-TYPE <GET-AC .AC> MSUBR>
		      <OCEMIT MOVE <NEXT-AC .AC> 0 (.NAC)>)
		     (<==? .ARG2 5>		;"The previous 'frame'"
		      <AC-TYPE <GET-AC .AC> FRAME>
		      <OCEMIT MOVE <NEXT-AC .AC> 3 (.NAC)>
		      <OCEMIT SKIPL (<NEXT-AC .AC>)>
		       <OCEMIT ADDI <NEXT-AC .AC> 4>)
		     (ELSE
		      <AC-TYPE <GET-AC .AC> LBIND>
		      <OCEMIT HRRZ <NEXT-AC .AC> 4 (.NAC)>
		      <OCEMIT HLLI <NEXT-AC .AC> (.NAC)>)>
	       <COND (<==? .NAC T*> <AC-CODE <GET-AC T*> DUMMY>)>
	       <COND (<==? .VAL STACK>
		      <OCEMIT PUSH TP* !<TYPE-WORD <AC-TYPE <GET-AC .AC>>>>
		      <OCEMIT PUSH TP* <NEXT-AC .AC>>
		      <COND (,WINNING-VICTIM
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>>

<DEFINE LBIND-NTH (L
		   "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <4 .L>) AC NAC XAC
			 EX)
	#DECL ((L) LIST (ARG1) ANY (ARG2) FIX (AC VAL) ATOM
	       (XAC) <OR FALSE ATOM> (EX) <OR FALSE <LIST ATOM ATOM ATOM>>)
	<COND (<OR <G? .ARG2 6> <L? .ARG2 1>>
	       <MIMOCERR OUT-OF-BOUNDS!-ERRORS NTHR LBIND .ARG2>)
	      (T
	       <SET NAC
		    <COND (<AND <SET XAC <IN-AC? .ARG1 VALUE>>
				<N==? .XAC O*>>
			   <AC-TIME <GET-AC .XAC>
				    <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			   <SETG FIRST-AC <>>
			   .XAC)
			  (<AND <==? .ARG2 1> <N==? .VAL STACK>> <>)
			  (<NOT <WILL-DIE? .ARG1>>
			   <NEXT-AC <LOAD-AC .ARG1 BOTH>>)
			  (T
			   <SMASH-AC T* .ARG1 VALUE>
			   <FLUSH-AC T*>
			   <MUNGED-AC T*>
			   T*)>>
	       <COND (<N==? .VAL STACK>
		      <SET AC <ASSIGN-AC .VAL BOTH T>>
		      <COND (<AND <==? <NEXT-AC .AC> .NAC>
				  <==? .VAL .ARG1>>
			     <AC-TYPE <GET-AC .AC> <>>)>)>
	       <COND (<==? .ARG2 1>
		      <COND (<==? .VAL STACK>
			     <OCEMIT PUSH TP* (.NAC)>
			     <OCEMIT PUSH TP* 1 (.NAC)>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
			    (.NAC <OCEMIT DMOVE .AC (.NAC)>)
			    (ELSE <OCEMIT DMOVE .AC @ !<OBJ-VAL .ARG1>>)>)
		     (<==? .ARG2 3>
		      <COND (<==? .VAL STACK>
			     <OCEMIT PUSH TP* 3 (.NAC)>
			     <OCEMIT PUSH TP* 4 (.NAC)>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
			    (ELSE <OCEMIT DMOVE .AC 3 (.NAC)>)>)
		     (<MEMQ .ARG2 '[2 6]>
		      <COND (<==? .VAL STACK>
			     <OCEMIT PUSH
				     TP*
				     !<TYPE-WORD <NTH '[#FALSE ()
							ATOM
							#FALSE ()
							#FALSE ()
							#FALSE ()
							FIX]
						      .ARG2>>>
			     <OCEMIT PUSH
				     TP*
				     <NTH '[#FALSE ()
					    2
					    #FALSE ()
					    #FALSE ()
					    #FALSE ()
					    7]
					  .ARG2>
				     (.NAC)>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
			    (ELSE
			     <AC-TYPE <GET-AC .AC>
				      <NTH '[#FALSE ()
					     ATOM
					     #FALSE ()
					     #FALSE ()
					     #FALSE ()
					     FIX]
					   .ARG2>>
			     <OCEMIT MOVE
				     <NEXT-AC .AC>
				     <NTH '[#FALSE ()
					    2
					    #FALSE ()
					    #FALSE ()
					    #FALSE ()
					    7]
					  .ARG2>
				     (.NAC)>)>)
		     (T
		      <COND (<==? .VAL STACK>
			     <SET AC <ASSIGN-AC .VAL BOTH T>>)>
		      <COND (<SET EX <EXTRAMEM BRANCH-FALSE .L>>
			     <LABEL-UPDATE-ACS <3 .EX> <>>)>
		      <OCEMIT MOVE .AC !<TYPE-WORD T$LBIND>>
		      <COND (.EX
			     <OCEMIT <COND (<==? <2 .EX> +> SKIPN) (T SKIPE)>
				     <NEXT-AC .AC>
				     <NTH '[#FALSE ()
					    #FALSE ()
					    #FALSE ()
					    5
					    6
					    #FALSE ()]
					  .ARG2>
				     (.NAC)>
			     <OCEMIT JRST <XJUMP <3 .EX>>>
			     <SETG NEXT-FLUSH 1>)
			    (T
			     <OCEMIT SKIPN
				     <NEXT-AC .AC>
				     <NTH '[#FALSE ()
					    #FALSE ()
					    #FALSE ()
					    5
					    6
					    #FALSE ()]
					  .ARG2>
				     (.NAC)>
			     <OCEMIT MOVE .AC !<TYPE-WORD FALSE>>)>
		      <COND (<==? .VAL STACK>
			     <OCEMIT PUSH TP* .AC>
			     <OCEMIT PUSH TP* <NEXT-AC .AC>>
			     <COND (,WINNING-VICTIM
				    <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>)>>

<DEFINE LBIND-PUT (L "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <3 .L>) AC NAC XAC)
	#DECL ((L) LIST (ARG1 VAL) ANY (ARG2) FIX (AC) ATOM)
	<COND (<OR <G? .ARG2 6> <L? .ARG2 1>>
	       <MIMOCERR OUT-OF-BOUNDS!-ERRORS NTHR LBIND .ARG2>)
	      (T
	       <SET AC <COND (<MEMQ .ARG2 '[1 3]>
		              <LOAD-AC .VAL BOTH>)
			     (<SET XAC <IN-AC? .VAL VALUE>>
			      <AC-TIME <GET-AC .XAC>
				       <SETG AC-STAMP <+ ,AC-STAMP 1>>>
			      <SETG FIRST-AC <>>
			      .XAC)
			     (<OR <NOT <TYPE? .VAL ATOM>>
				  <WILL-DIE? .VAL>>
			      <SMASH-AC O* .VAL VALUE>)
			     (ELSE <NEXT-AC <LOAD-AC .VAL BOTH>>)>>
	       <SET NAC <COND (<IN-AC? .ARG1 VALUE>)
			      (<==? .ARG1 1> <>)
			      (T
			       <SMASH-AC T* .ARG1 VALUE>
			       <AC-CODE <GET-AC T*> DUMMY>
			       T*)>>
	       <COND (<==? .ARG2 1>
		      <COND (.NAC <OCEMIT DMOVEM .AC (.NAC)>)
			    (ELSE <DMOVEM .AC @ !<OBJ-VAL .ARG1>>)>)
		     (<==? .ARG2 3>
		      <OCEMIT DMOVEM .AC 3 (.NAC)>)
		     (T
		      <OCEMIT MOVEM
			      .AC
			      <NTH '[%<> 2 %<> 5 6 7] .ARG2>
			      (.NAC)>)>)>>

<DEFINE ATOM-NTH (L
		  "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (VAL <4 .L>) AC NAC XAC EX
			(LAB <>) TY LBL (TEX <>) (WD <>) TG (AC-T1 <>)
			NEW (WD1 <>) (AC-T2 <>))
   #DECL ((L) LIST (ARG1) ANY (ARG2) FIX (NAC VAL SKIP) ATOM
	  (AC-T1 AC-T2) <OR FALSE FIX>
	  (AC XAC) <OR FALSE ATOM> (EX) <OR FALSE <LIST ATOM ATOM ATOM>>)
   <COND
    (<OR <G? .ARG2 5> <L? .ARG2 1>>
     <MIMOCERR OUT-OF-BOUNDS!-ERRORS NTHR ATOM .ARG2>)
    (T
     <SET NAC
	  <COND (<AND <SET XAC <IN-AC? .ARG1 VALUE>>
		      <N==? .XAC O*>>
		 <AC-TIME <GET-AC .XAC> <SETG AC-STAMP <+ ,AC-STAMP 1>>>
		 <SETG FIRST-AC <>>
		 .XAC)
		(<NOT <WILL-DIE? .ARG1>>
		 <NEXT-AC <LOAD-AC .ARG1 BOTH>>)
		(T
		 <SMASH-AC T* .ARG1 VALUE>
		 <FLUSH-AC T*>
		 <MUNGED-AC T*>
		 T*)>>
     <COND
      (<==? .ARG2 3>
       <COND (<==? .VAL STACK>
	      <OCEMIT PUSH TP* 2 (.NAC)>
	      <SMASH-AC O* <TYPE-CODE STRING> VALUE>
	      <OCEMIT HRLM O* '(TP*)>
	      <OCEMIT PUSH TP* 3 (.NAC)>
	      <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)
	     (ELSE
	      <SET AC <ASSIGN-AC .VAL BOTH T>>
	      <OCEMIT DMOVE .AC 2 (.NAC)>
	      <OCEMIT HRLI .AC <TYPE-CODE STRING>>)>)
      (T
       <COND (<SET EX <EXTRAMEM BRANCH-FALSE .L>>
	      <SET LAB <3 .EX>>
	      <SET WD <AND <SET WD1 <WILL-DIE? .VAL <REST .MIML>>>
			   <WILL-DIE? .VAL <LAB-CODE-PNTR ,.LAB>>>>)>
       <SET TEX <EXTRAMEM TYPE .L>>
       <COND (<NOT .WD>
	      <SET AC <ASSIGN-AC .VAL BOTH T>>)
	     (ELSE <SET AC <>>)>
       <COND (<AND <NOT .WD> <==? .ARG2 5>>
	      <COND (<NOT .EX>
		     <OCEMIT MOVSI .AC <TYPE-CODE TYPE-C>>)>)
	     (<AND <NOT .WD> <NOT .EX> <NOT .TEX>>
	      <OCEMIT MOVE
		      .AC
		      !<TYPE-WORD <NTH '[GBIND LBIND #FALSE () OBLIST]
				       .ARG2>>>)>
       <COND (<AND .EX <OR .WD <N==? .ARG2 5> <==? <2 .EX> +>>>
	      <SET NEW <LABEL-UPDATE-ACS .LAB <> <> .NAC>>
	      <AC-UPDATE <GET-AC .AC> T>
	      <AC-UPDATE <GET-AC <NEXT-AC .AC>> T>
	      <COND (<N==? .NAC <1 .NEW>>
		     <SET AC-T1 <AC-TIME <GET-AC <SET NAC <1 .NEW>>>>>)>
	      <OCEMIT <COND (<==? <2 .EX> +>
			     <COND (<==? .ARG2 5> SKIPGE) (ELSE SKIPN)>)
			    (<==? .ARG2 5> SKIPL)
			    (T SKIPE)>
		      <COND (.WD O*) (ELSE <NEXT-AC .AC>)>
		      <NTH '[0 1 #FALSE () 4 2] .ARG2>
		      (.NAC)>
	      <COND (<==? .ARG2 5>
		     <OCEMIT JRST <XJUMP .LAB>>
		     <COND (<NOT .WD1>
			    <COND (<==? <2 .EX> +>
				   <OCEMIT HLRZS O* <NEXT-AC .AC>>)>)>)
		    (ELSE <OCEMIT JRST <XJUMP .LAB>>)>
	      <COND (.AC-T1
		     <AC-TIME <GET-AC .NAC> .AC-T1>)>
	      <COND (<NOT .WD1>
		     <COND (<==? <2 .EX> +>
			    <AC-TYPE <GET-AC .AC>
				     <NTH '[GBIND LBIND T OBLIST TYPE-C]
					  .ARG2>>)
			   (ELSE
			    <AC-TYPE <GET-AC .AC> FALSE>)>)>
	      <SETG NEXT-FLUSH 1>)
	     (<==? .ARG2 5>
	      <OCEMIT HLRE <NEXT-AC .AC> 2 (.NAC)>
	      <COND (.EX
		     <AC-ITEM <GET-AC .AC> .VAL>
		     <AC-ITEM <GET-AC <NEXT-AC .AC>> .VAL>
		     <COND (.WD1 <AC-TYPE <GET-AC .AC> TYPE-C>)
			   (ELSE <OCEMIT MOVSI .AC <TYPE-CODE TYPE-C>>)>
		     <SET NEW <LABEL-UPDATE-ACS .LAB <> <> .NAC .AC>>
		     <COND (<N==? .NAC <1 .NEW>>
			    <SET AC-T1 <AC-TIME <GET-AC <SET NAC <1 .NEW>>>>>)>
		     <COND (<N==? .AC <2 .NEW>>
			    <SET AC-T2 <AC-TIME <GET-AC <SET AC <2 .NEW>>>>>)>
		     <SETG NEXT-FLUSH 1>)>
	      <COND (<NOT .TEX>
		     <OCEMIT JUMPGE
			     <NEXT-AC .AC>
			     <XJUMP <COND (.EX .LAB)
					  (ELSE <SET LBL <GENLBL "FOO">>)>>>
		     <COND (<NOT .WD1>
			    <OCEMIT MOVEI <NEXT-AC .AC> 0>
			    <OCEMIT MOVSI .AC <TYPE-CODE FALSE>>)>
		     <COND (<NOT .EX> <LABEL .LBL>)>)>
	      <COND (.AC-T1
		     <AC-TIME <GET-AC .NAC> .AC-T1>)>
	      <COND (.AC-T2
		     <AC-TIME <GET-AC .AC> .AC-T2>
		     <AC-TIME <GET-AC <NEXT-AC .AC>> .AC-T2>)>)
	     (.TEX
	      <OCEMIT MOVE <NEXT-AC .AC> <NTH '[0 1 #FALSE () 4] .ARG2>
		      (.NAC)>
	      <AC-TYPE <GET-AC .AC> <2 .TEX>>)
	     (T
	      <OCEMIT SKIPN
		      <NEXT-AC .AC>
		      <NTH '[0 1 #FALSE () 4] .ARG2>
		      (.NAC)>
	      <OCEMIT MOVSI .AC <TYPE-CODE FALSE>>)>
       <COND (<==? .VAL STACK>
	      <OCEMIT PUSH TP* .AC>
	      <OCEMIT PUSH TP* <NEXT-AC .AC>>
	      <COND (,WINNING-VICTIM <SETG STACK-DEPTH <+ ,STACK-DEPTH 2>>)>)>)>)>>

<DEFINE EXTRAMEM (NAM LST)
	#DECL ((NAM) ATOM (LST) LIST)
	<MAPF <>
	      <FUNCTION (ITM)
		   #DECL ((ITM) ANY)
		   <COND (<AND <TYPE? .ITM LIST>
			       <G? <LENGTH .ITM> 1>
			       <==? <1 .ITM> .NAM>>
			  <MAPLEAVE .ITM>)>>
	      .LST>>

<DEFINE ATOM-PUT (L "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) (V <3 .L>) AC NAC AC1)
	#DECL ((L) LIST (ARG1) ANY (ARG2) FIX (AC NAC) ATOM
	       (AC1) <OR ATOM FALSE>)
	<COND (<OR <G? .ARG2 5> <L? .ARG2 1>>
	       <MIMOCERR OUT-OF-BOUNDS!-ERRORS NTHR LBIND .ARG2>)
	      (T
	       <SET NAC <COND (<SET AC1 <IN-AC? .ARG1 VALUE>>
			       <AC-TIME <GET-AC .AC1>
					<SETG AC-STAMP <+ ,AC-STAMP 1>>>
			       <SETG FIRST-AC <>>
			       .AC1)
			      (T
			       <SMASH-AC T* .ARG1 VALUE>
			       <FLUSH-AC T*>
			       <MUNGED-AC T*>
			       T*)>>
	       <COND (<==? .ARG2 3>
		      <SET AC <LOAD-AC .V BOTH>>
		      <OCEMIT HRRM .AC 2 (.NAC)>
		      <OCEMIT MOVEM <NEXT-AC .AC> 3 (.NAC)>)
		     (<==? .ARG2 5>
		      <COND (<OR <==? <PRIMTYPE .V> WORD>
				 <==? <PRIMTYPE .V> FIX>>
			     <SET AC <COND (<IN-AC? .V VALUE>)
					   (T <SMASH-AC O* .V VALUE>)>>
			     <OCEMIT HRLM .AC 2 (.NAC)>)
			    (<TYPE? .V FALSE>
			     <OCEMIT HRROS O* 2 (.NAC)>)
			    (ELSE
			     <SET AC <COND (<IN-AC? .V VALUE>)
					   (T <SMASH-AC O* .V VALUE>)>>
			     <OCEMIT HRLM .AC 2 (.NAC)>
			     <COND (<SET AC1 <IN-AC? .V TYPE>>
				    <LOAD-TYPE O* (.AC1)>
				    <MUNGED-AC O*>)
				   (T <SMASH-AC O* .V TYPECODE>)>
			     <OCEMIT CAIN O* <TYPE-CODE FALSE>>
			     <OCEMIT HRROS O* 2 (.NAC)>)>)
		     (T
		      <SET AC <COND (<IN-AC? .V VALUE>)
				    (<OR <NOT <TYPE? .V ATOM>>
					 <WILL-DIE? .V>>
				     <SMASH-AC O* .V VALUE>)
				    (ELSE
				     <SETG FIRST-AC <>>
				     <AC-TIME <GET-AC .NAC>
					      <SETG AC-STAMP <+ ,AC-STAMP 1>>>
				     <NEXT-AC <LOAD-AC .V BOTH>>)>>
		      <OCEMIT MOVEM
			      .AC
			      <NTH '[0 1 %<> 4] .ARG2>
			      (.NAC)>)>)>>
			       	       
<DEFINE NTHR!-MIMOC (L  "OPT" (NOGP <>) "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) T M)
	#DECL ((L) LIST (ARG1 T) ANY (M) <OR FALSE VECTOR>
	       (ARG2) <OR ATOM FIX>)
	<COND (<AND <NOT .NOGP>
		    <TYPE? .ARG2 FIX>
		    <G? <LENGTH .L> 4>
		    <TYPE? <SET T <5 .L>> LIST>
		    <==? <1 .T> RECORD-TYPE>
		    <SET M <MEMQ <2 .T> ,NTHR-TABLE>>>
	       <APPLY ,<2 .M> .L>)
	      (T
	       <UPDATE-ACS>
	       <OCEMIT MOVE O1* !<OBJ-VAL .ARG1>>
	       <OCEMIT MOVE O2* !<OBJ-VAL .ARG2>>
	       <OCEMIT HLRZ A1* !<OBJ-TYP .ARG1>>
	       <OCEMIT ANDI A1* *177777*>
	       <OCEMIT LSH A1* -6>
	       <PUSHJ NTHR <4 .L>>)>>

<DEFINE PUTR!-MIMOC (L "OPT" (NOGP <>) "AUX" (ARG1 <1 .L>) (ARG2 <2 .L>) T M)
	#DECL ((L) LIST (ARG1 T) ANY (M) <OR FALSE VECTOR>
	       (ARG2) <OR ATOM FIX>)
	<COND (<AND <NOT .NOGP>
		    <TYPE? .ARG2 FIX>
		    <G? <LENGTH .L> 3>
		    <TYPE? <SET T <4 .L>> LIST>
		    <==? <1 .T> RECORD-TYPE>
		    <SET M <MEMQ <2 .T> ,PUTR-TABLE>>>
	       <APPLY ,<2 .M> .L>)
	      (T
	       <UPDATE-ACS>
	       <SMASH-AC C1* <3 .L> BOTH>
	       <OCEMIT MOVE O1* !<OBJ-VAL .ARG1>>
	       <OCEMIT MOVE O2* !<OBJ-VAL .ARG2>>
	       <OCEMIT HLRZ A1* !<OBJ-TYP .ARG1>>
	       <OCEMIT ANDI A1* *177777*>
	       <OCEMIT LSH A1* -6>
	       <OCEMIT MOVEI B2* C1*>
	       <PUSHJ PUTR>)>>


;"Structure creation"

<DEFINE LIST!-MIMOC (L)
	#DECL ((L) <LIST ANY ANY ANY>)
	<UPDATE-ACS>
	<COND (<AND <TYPE? <1 .L> FIX> <L=? <1 .L> *777777*>>
	       <COND (,WINNING-VICTIM <SETG STACK-DEPTH <- ,STACK-DEPTH
							   <* <1 .L> 2>>>)>
	       <OCEMIT MOVEI O1* <1 .L>>)
	      (ELSE
	       <OCEMIT MOVE O1* !<OBJ-VAL <1 .L>>>)>
	<PUSHJ LIST <3 .L>>>

<DEFINE UBLOCK!-MIMOC (L) <DO-UBLOCK UBLOCK .L <> T>>

<DEFINE UUBLOCK!-MIMOC (L) <DO-UBLOCK UUBLOCK .L <> <>>>

<DEFINE SBLOCK!-MIMOC (L) <DO-UBLOCK SBLOCK .L T T>>

<DEFINE USBLOCK!-MIMOC (L) <DO-UBLOCK USBLOCK .L T <>>>

<DEFINE DO-UBLOCK (NAM L STACK? INIT? "AUX" ATM NITMS NWRDS)
	#DECL ((L) LIST (NITMS NWRDS) FIX)
	<UPDATE-ACS>
	<COND (<AND <TYPE? <SET ATM <1 .L>> FIX> <L=? .ATM *777777*>>
	       <OCEMIT MOVEI O1* .ATM>)
	      (<OR <TYPE? .ATM ATOM>
		   <AND <TYPE? .ATM FORM>
			<NOT <EMPTY? .ATM>>
			<==? <1 .ATM> QUOTE>
			<TYPE? <SET ATM <2 .ATM>> ATOM>>>
	       <OCEMIT MOVEI O1* !<TYPE-CODE .ATM T>>)
	      (ELSE
	       <OCEMIT MOVE O1* !<OBJ-VAL .ATM>>)>
	<COND (<AND <TYPE? <2 .L> FIX> <L=? <SET NITMS <2 .L>> *777777*>>
	       <COND (<TYPE? .ATM ATOM> <SET ATM <CHTYPE <TYPE-C .ATM> FIX>>)>
	       <SET ATM <ANDB .ATM 7>>	;"Get SAT"
	       <COND (<==? .ATM 4> ;"BYTES"
		      <SET NWRDS </ <+ .NITMS 3> 4>>)
		     (<==? .ATM 5> ;"STRING"
		      <SET NWRDS </ <+ .NITMS 4> 5>>)
		     (<==? .ATM 6>
		      <SET NWRDS .NITMS>)
		     (ELSE <SET NWRDS <* .NITMS 2>>)>
	       <COND (,WINNING-VICTIM
		      <COND (<AND <NOT .STACK?> .INIT?>
			     <SETG STACK-DEPTH <- ,STACK-DEPTH
						  <* .NITMS 2>>>)
			    (<AND .STACK? <NOT .INIT?>>
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH
						  .NWRDS
						  2>>)
			    (.STACK?
			     <SETG STACK-DEPTH <+ ,STACK-DEPTH
						  .NWRDS
						  2
						  <- .NITMS>>>)>)>
	       <OCEMIT MOVEI O2* .NITMS>)
	      (ELSE
	       <OCEMIT MOVE O2* !<OBJ-VAL <2 .L>>>)>
	<PUSHJ .NAM <4 .L>>>

<DEFINE RECORD!-MIMOC (L "AUX" (TYP <1 .L>) TYP1)
	#DECL ((L) LIST (TYP) ANY)
	<UPDATE-ACS>
	<PROG ()
	      <COND (<AND <TYPE? .TYP FORM>
			  <G? <LENGTH .TYP> 1>
			  <==? <1 .TYP> QUOTE>>
		     <COND (<OR <==? <SET TYP1 <2 .TYP>> ATOM>
				<==? .TYP1 LBIND>
				<==? .TYP1 GBIND>>
			    <EXPLICIT-MAKE-RECORD .TYP1 .L>
			    <RETURN>)>
		     <OCEMIT MOVEI O1* !<TYPE-CODE <2 .TYP> T>>)
	      (<AND <TYPE? .TYP FIX> <L=? .TYP *777777*>>
	       <OCEMIT MOVEI O1* .TYP>)
	      (ELSE
	       <OCEMIT MOVE O1* !<OBJ-VAL .TYP>>)>
	<REPEAT ((LL <REST .L>) (CNT 0) ITM (WV ,WINNING-VICTIM)
		 (SD <AND .WV ,STACK-DEPTH>))
		#DECL ((LL) LIST (CNT SD) FIX (ITM) ANY (SD WV) <OR FALSE FIX>)
		<COND (<==? <SET ITM <1 .LL>> =>
		       <OCEMIT MOVEI O2* .CNT>
		       <SETG STACK-DEPTH .SD>
		       <RETURN>)
		      (T
		       <OCEMIT PUSH TP* !<OBJ-TYP .ITM>>
		       <COND (.WV <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
		       <OCEMIT PUSH TP* !<OBJ-VAL .ITM>>
		       <COND (.WV <SETG STACK-DEPTH <+ ,STACK-DEPTH 1>>)>
		       <SET CNT <+ .CNT 1>>
		       <SET LL <REST .LL>>)>>
	<PUSHJ RECORD <NTH .L <LENGTH .L>>>>>

<DEFINE EXPLICIT-MAKE-RECORD (TYP L)
	<COND (<==? .TYP ATOM>
	       <OCEMIT MOVEI O1* !<TYPE-CODE ATOM T>>
	       <OCEMIT MOVEI O2* 5>  ;"Length of atom in words"
	       <OCEMIT MOVEI C1* 10>  ;"LH of atom pointer"
	       <PUSHJ IRECORD>
	       <PUT-ELEMENTS .L 0 1 '(2 3) 4 -2>)
	      (<==? .TYP GBIND>
	       <OCEMIT MOVEI O1* !<TYPE-CODE GBIND T>>
	       <OCEMIT MOVEI O2* 5>  ;"Length of GBIND in words"
	       <OCEMIT MOVEI C1* 10>  ;"LH of GBIND pointer"
	       <PUSHJ IRECORD>
	       <PUT-ELEMENTS .L '(0 1) 2 '(3 4)>)
	      (<==? .TYP LBIND>
	       <OCEMIT MOVEI O1* !<TYPE-CODE LBIND T>>
	       <OCEMIT MOVEI O2* 8>  ;"Length of LBIND in words"
	       <OCEMIT MOVEI C1* 16>  ;"LH of LBIND pointer"
	       <PUSHJ IRECORD>
	       <PUT-ELEMENTS .L '(0 1) 2 '(3 4) 5 6 7>)>>

<DEFINE PUT-ELEMENTS (L "TUPLE" TUP "AUX" (VAL <NTH .L <LENGTH .L>>)
					  (B-USED <>) (C-USED <>))
	#DECL ((L) LIST (TUP) <TUPLE [REST <OR FIX <LIST FIX FIX>>]>)
	<MAPF <>
	      <FUNCTION (ITM OFFS "AUX" ACS)
		   <COND (<TYPE? .ITM ATOM>
			  <COND (<AND <NOT <OR <==? .ITM .VAL> <WILL-DIE? .ITM>>>
				      <OR <AND <NOT .B-USED> <SET B-USED T>>
					  <AND <NOT .C-USED> <SET C-USED T>>>>
				 <COND (.C-USED
					<LOAD-AC .ITM BOTH <> <>
						 <GET-AC <SET ACS C1*>>
						 <GET-AC C2*>>)
				       (ELSE
					<LOAD-AC .ITM BOTH <> <>
						 <GET-AC <SET ACS B1*>>
						 <GET-AC B2*>>)>
				 <COND (<TYPE? .OFFS FIX>
					<COND (<L? .OFFS 0>
					       <OCEMIT HRLM <NEXT-AC .ACS>
						       <- .OFFS>
						       '(A2*)>
					       <OCEMIT CAMN .ACS
						       !<TYPE-WORD FALSE>>
					       <OCEMIT HRROS <- .OFFS> '(A2*)>)
					      (ELSE
					       <OCEMIT MOVEM <NEXT-AC .ACS>
						       .OFFS '(A2*)>
					       <OCEMIT CAMN .ACS
						       !<TYPE-WORD FALSE>>
					       <OCEMIT SETZM .OFFS '(A2*)>)>)
				       (ELSE
					<OCEMIT DMOVEM .ACS <1 .OFFS>
						'(A2*)>)>)
				(<TYPE? .OFFS FIX>
				 <OCEMIT DMOVE O1* !<OBJ-TYP .ITM>>
				 <COND (<L? .OFFS 0>
					<OCEMIT HRLM O2* <- .OFFS> '(A2*)>
					<OCEMIT CAMN O1*
						!<TYPE-WORD FALSE>>
					<OCEMIT HRROS <- .OFFS> '(A2*)>)
				       (ELSE
					<OCEMIT MOVEM O2* .OFFS '(A2*)>
					<OCEMIT CAMN O1*
						!<TYPE-WORD FALSE>>
					<OCEMIT SETZM .OFFS '(A2*)>)>)
				(ELSE
				 <OCEMIT DMOVE O1* !<OBJ-TYP .ITM>>
				 <OCEMIT DMOVEM O1* <1 .OFFS> '(A2*)>)>)
			 (<TYPE? .OFFS FIX>
			  <COND (<NOT .ITM>
				 <COND (<L? .OFFS 0>
					<OCEMIT HRROS <- .OFFS> '(A2*)>)
				       (ELSE
					<OCEMIT SETZM .OFFS '(A2*)>)>)
				(ELSE
				 <GET-INTO-ACS .ITM VALUE O*>
				 <COND (<L? .OFFS 0>
					<OCEMIT HRLM O* <- .OFFS> '(A2*)>)
				       (ELSE
					<OCEMIT MOVEM O* .OFFS '(A2*)>)>)>)
			 (ELSE
			  <OCEMIT DMOVE O1* !<OBJ-TYP .ITM>>
			  <OCEMIT DMOVEM O1* <1 .OFFS> '(A2*)>)>>
	      <REST .L> .TUP>
	<PUSHJ-VAL .VAL>>

<DEFINE NTH-PUT-LOOK-AHEAD (OL INS STRUC AMT VAL
			    "AUX" (AC <>) (L <REST .MIML>) NXT INS-A (DEAD? <>)
				  THE-TY ITM FOO INSC NXT2 LBL)
   #DECL ((INS) STRING (L MIML OL) LIST)
   <COND (<AND <G=? <LENGTH .L> 4>
	       <TYPE? <SET NXT <1 .L>> FORM>
	       <G=? <LENGTH .NXT> 5>
	       <OR <=? <SET INS-A <SPNAME <1 .NXT>>> "ADD"> <=? .INS-A "SUB">>
	       <==? <2 .NXT> .VAL>
	       <==? <3 .NXT> 1>
	       <==? <5 .NXT> .VAL>
	       <TYPE? <SET NXT <2 .L>> FORM>
	       <G=? <LENGTH .NXT> 4>
	       <=? <SPNAME <1 .NXT>> .INS>
	       <==? <2 .NXT> .STRUC>
	       <==? <3 .NXT> .AMT>
	       <==? <4 .NXT> .VAL>>
	  <SETG NEXT-FLUSH 2>
	  <COND (<AND <TYPE? <SET NXT <3 .L>> FORM>
		      <G=? <LENGTH .NXT> 2>
		      <=? <SPNAME <1 .NXT>> "DEAD">
		      <MEMQ .VAL <REST .NXT>>>
		 <SET DEAD? T>)>
	  <COND (<=? .INS "PUTL">
		 <NTHL!-MIMOC .OL
			      <COND (<=? .INS-A "ADD"> AOS) (ELSE SOS)>
			      <NOT .DEAD?>>)
		(ELSE
		 <NTHUV!-MIMOC .OL
			       <=? .INS "PUTUU">
			       <COND (<=? .INS-A "ADD"> AOS) (ELSE SOS)>
			       <NOT .DEAD?>>)>
	  T)
	 (<AND <G=? <LENGTH .L> 4>
	       <TYPE? <SET NXT <1 .L>> FORM>
	       <G=? <LENGTH .NXT> 4>
	       <OR <AND <==? <LENGTH <SET INS-A <SPNAME <1 .NXT>>>> 5>
			<MEMBER "LENU" .INS-A>
			<==? <2 .NXT> .VAL>
			<OR <==? <4 .NXT> .VAL> <WILL-DIE? .VAL .L>>
			<COND (<AND <TYPE? <SET FOO <2 .L>> FORM>
				    <G=? <LENGTH .FOO> 5>
				    <MEMQ <LOOKUP <SPNAME <1 .FOO>>
						  ,MIMOC-OBLIST>
					  ,COMPARERS>
				    <MEMQ <4 .NXT> <REST .FOO>>
				    <WILL-DIE? <4 .NXT> <REST .L>>
				    ;"Check for death at branch"
				    <WILL-DIE?
				     <4 .NXT>
				     <LAB-CODE-PNTR
				      ,<MAPR <>	;"Find label"
					     <FUNCTION (FOOL:LIST "AUX" X)
					       <COND
						(<OR <==? <SET X <1 .FOOL>> +>
						     <==? .X ->>
						 <MAPLEAVE <2 .FOOL>>)
						(<EMPTY? <REST .FOOL>>
						 <ERROR HUH?!-ERRORS>)>>
					     .FOO>>>
				    >
			       <COND (<=? .INS "PUTL">
				      <NTHL!-MIMOC .OL HRRZ <>>
				      <SETG NEXT-FLUSH 1>)
				     (ELSE
				      <NTHUV!-MIMOC .OL <> HRRZ <>>
				      <SETG NEXT-FLUSH 1>)>
			       <AC-ITEM <AC-CODE <GET-AC O*> VALUE> <4 .NXT>>)
			      (ELSE
			       <COND (<=? .INS "PUTL">
				      <NTHL!-MIMOC .OL HRRZ T <4 .NXT>>
				      <SETG NEXT-FLUSH 1>)
				     (ELSE
				      <NTHUV!-MIMOC .OL <> HRRZ T <4 .NXT>>
				      <SETG NEXT-FLUSH 1>)>)>>
		   <AND <==? <LENGTH .INS-A> 6>
			<MEMBER "EMPU" .INS-A>
			<==? <2 .NXT> .VAL>
			<WILL-DIE? .VAL .L>
			<OR <==? <4 .NXT> COMPERR>
			    <AND <SET FOO <MEMQ <4 .NXT> <REST .L>>>
				 <WILL-DIE? .VAL .FOO>>>
			<PROG ()
			      <COND (<=? .INS "PUTL">
				     <NTHL!-MIMOC .OL HRRZ <>>
				     <SETG NEXT-FLUSH 1>)
				    (ELSE
				     <NTHUV!-MIMOC .OL <> HRRZ <>>
				     <SETG NEXT-FLUSH 1>)>
			      <LABEL-UPDATE-ACS <4 .NXT> <>>
			      <OCEMIT <COND (<==? <3 .NXT> +> JUMPE)
					    (ELSE JUMPN)>
				      O*
				      <XJUMP <4 .NXT>>>
			      T>>>>
	  T)
	 (<AND <G=? <LENGTH .L> 4>
	       <TYPE? <SET NXT <1 .L>> FORM>
	       <G=? <LENGTH .NXT> 5>
	       <OR <=? <SET INS-A <SPNAME <1 .NXT>>> "VEQUAL?">
		   <=? .INS-A "EQUAL?">>
	       <OR <==? <2 .NXT> .VAL>
		   <AND <==? <3 .NXT> .VAL>
			<SET NXT <FORM <1 .NXT> .VAL <2 .NXT> !<REST .NXT 3>>>>>
	       <PROG () <SET ITM <3 .NXT>> <SET DIR <4 .NXT>> T>
	       <OR <AND <COND (<=? .INS-A "VEQUAL?">
			       <SET AC <IN-AC? .ITM VALUE>>)
			      (ELSE
			       <SET AC <IN-AC? .ITM BOTH>>)>>
		   <AND <=? .INS-A "VEQUAL?">
			<OR <AND <==? <PRIMTYPE .ITM> FIX>
				 <==? <CHTYPE .ITM FIX> 0>>
			    <AND <==? <PRIMTYPE .ITM> LIST>
				 <EMPTY? <CHTYPE .ITM LIST>>>>>>
	       <WILL-DIE? .VAL .L>
	       <WILL-DIE? .VAL <LAB-CODE-PNTR <FIND-LABEL <5 .NXT>>>>>
	  <COND (<=? .INS "PUTL">
		 <NTHL!-MIMOC .OL .NXT <>>
		 <SETG NEXT-FLUSH 1>)
		(ELSE
		 <NTHUV!-MIMOC .OL <=? .INS "PUTUU"> .NXT <>>
		 <SETG NEXT-FLUSH 1>)>
	  T)
	 (<AND <G=? <LENGTH .L> 4>
	       <TYPE? <SET NXT <1 .L>> FORM>
	       <G=? <LENGTH .NXT> 5>
	       <=? <SPNAME <1 .NXT>> "TYPE?">
	       <==? <2 .NXT> .VAL>
	       <TYPE? <SET THE-TY <3 .NXT>> FIX>
	       <==? <4 .NXT> ->
	       <SET LBL <5 .NXT>>
	       <TYPE? <SET NXT <2 .L>> FORM>
	       <G=? <LENGTH .NXT> 5>
	       <=? <SPNAME <1 .NXT>> "VEQUAL?">
	       <OR <==? <2 .NXT> .VAL>
		   <AND <==? <3 .NXT> .VAL>
			<SET NXT <FORM <1 .NXT> .VAL <2 .NXT> !<REST .NXT 3>>>>>
	       <PROG () <SET ITM <3 .NXT>> <==? <4 .NXT> +>>
	       <OR <AND <TYPE? .ITM ATOM>
			<IN-AC? .ITM VALUE>
			<WILL-DIE? .VAL <REST .L>>
			<WILL-DIE? .VAL <LAB-CODE-PNTR <FIND-LABEL <5 .NXT>>>>>
		   <AND <OR <AND <==? <PRIMTYPE .ITM> FIX>
				 <==? <CHTYPE .ITM FIX> 0>>
			    <AND <==? <PRIMTYPE .ITM> LIST>
				 <EMPTY? <CHTYPE .ITM LIST>>>>>>
	       <OR <==? <3 .L> .LBL>
		   <AND <TYPE? <3 .L> FORM>
			<=? <SPNAME <1 <3 .L>>> "DEAD">
			<==? <4 .L> .LBL>>>>
	  <SETG NEXT-FLUSH 2>
	  <SET NXT <CHTYPE (TYPE? .THE-TY !.NXT) FORM>>
	  <COND (<=? .INS "PUTL">
		 <NTHL!-MIMOC .OL .NXT <>>)
		(ELSE
		 <NTHUV!-MIMOC .OL <=? .INS "PUTUU"> .NXT <>>)>
	  T)>>

<DEFINE STRING-PUT-NTH-LOOK-AHEAD (STR PUT-OR-NTH VAL BYTES? AMT
				   "AUX" (STACK-OK? T) (L <REST .MIML>))
   #DECL ((STR PUT-OR-NTH) ATOM (L MIML) LIST (AMT) FIX)
   <MAPR <>
	 <FUNCTION (LL "AUX" (INS <1 .LL>) NM X) 
		 #DECL ((INS) <OR ATOM <FORM ANY>> (NM) STRING)
		 <COND (<TYPE? .INS ATOM> <MAPLEAVE <>>)>
		 <COND (<OR <=? <SET NM <SPNAME <1 .INS>>> "CALL">
			    <=? .NM "FRAME">
			    <=? .NM "SFRAME">
			    <=? .NM "SCALL">
			    <=? .NM "ACALL">
			    <=? .NM "PUSH">
			    <=? .NM "ADJ">>
			<SET STACK-OK? <>>)>
		 <COND (<AND <OR <AND <=? <SET NM <SPNAME <1 .INS>>> "RESTUS">
				      <NOT .BYTES?>>
				 <AND .BYTES? <=? .NM "RESTUB">>>
			     <==? .AMT 1>
			     <==? <2 .INS> .STR>
			     <==? <3 .INS> 1>>
			<COND (<AND <NOT .STACK-OK?>
				    <MEMQ STACK .INS>>
			       <MAPLEAVE <>>)>
			<RESTUS!-MIMOC <REST .INS> .BYTES? .VAL .PUT-OR-NTH
				       <WILL-DIE? .STR .LL>>
			<PUTPROP <REST .INS> DONE T>
			<MAPLEAVE T>)
		       (<AND <=? .NM <OR <AND <==? .PUT-OR-NTH PUT>
					      <OR <AND .BYTES? "PUTUB">
						  "PUTUS">>
					 <AND .BYTES? "NTHUB">
					 "NTHUS">>
			     <==? <2 .INS> .STR>
			     <==? <3 .INS> <+ .AMT 1>>>
			<COND (<AND <NOT .STACK-OK?>
				    <MEMQ STACK .INS>>
			       <MAPLEAVE <>>)>
			<SETG REMEMBER-STRING T>
			<COND (<WILL-DIE? .STR .LL>
			       <SETG DIE-LATER T>)>
			<MAPLEAVE <>>)
		       (<OR <MEMQ .STR .INS>
			    <MEMQ + .INS>
			    <MEMQ - .INS>
			    <AND <TYPE? <SET X <NTH .INS <LENGTH .INS>>> LIST>
				 <OR <MEMQ + .X> <MEMQ - .X>>>>
			<MAPLEAVE <>>)
		       (<MEMQ STACK .INS>
			<SET STACK-OK? <>>)>>
	 .L>>

<DEFINE STRING-REST-LOOK-AHEAD (RINS STR VAL BYTES?
				"AUX" (L <REST .MIML>) (PUT? <>)) 
   #DECL ((STR) ATOM (L MIML) LIST)
   <MAPR <>
	 <FUNCTION (LL "AUX" (INS <1 .LL>) NM X DST) 
		 #DECL ((INS) <OR ATOM <FORM ANY>> (NM) STRING)
		 <COND (<TYPE? .INS ATOM> <MAPLEAVE <>>)>
		 <COND (<AND <OR <=? <SET NM <SPNAME <1 .INS>>> "NTHUS">
				 <AND <=? .NM "PUTUS"> <SET PUT? T>>>
			     <==? <2 .INS> .STR>
			     <==? <3 .INS> 1>
			     <PROG ()
				   <SET DST <COND (.PUT? <4 .INS>)
						  (ELSE <5 .INS>)>>
				   <MAPF <>
					 <FUNCTION (I) #DECL ((I) FORM)
					      <COND (<==? .I .INS>
						     <MAPLEAVE>)>
					      <COND (<MEMQ .DST <REST .I>>
						     <MAPLEAVE <>>)>>
					 .L>>>
			<RESTUS!-MIMOC .RINS
				       .BYTES?
				       <5 .INS>
				       <COND (<=? .NM "PUTUS"> PUT) (NTH)>
				       <WILL-DIE? .STR .LL>>
			<PUTPROP <REST .INS> DONE T>
			<MAPLEAVE T>)
		       (<OR <MEMQ .STR .INS>
			    <MEMQ + .INS>
			    <MEMQ - .INS>
			    <AND <TYPE? <SET X <NTH .INS <LENGTH .INS>>> LIST>
				 <OR <MEMQ + .X> <MEMQ - .X>>>>
			<MAPLEAVE <>>)>>
	 .L>>