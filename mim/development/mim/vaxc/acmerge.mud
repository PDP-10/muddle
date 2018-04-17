<COND (<NOT <GASSIGNED? INST-NULLF>>
       <SETG INST-NULLF <CHTYPE <LSH ,INST-NULL 24> FIX>>)>

<DEFINE SAVE-LOAD-STATE () 
	#DECL ((VALUE) SLOAD-STATE)
	<MAPF ,VECTOR
	      <FCN (AC)
		   <AND <NOT <AC-USE .AC>>
			<CHTYPE <VECTOR <AC-LLOAD .AC> <AC-LLOAD-EA .AC>>
				AC-LOAD-STATE>>>
	      ,ALL-ACS>>

<DEFINE SET-AC-LOAD-STATE (LSTATE) 
	#DECL ((LSTATE) SLOAD-STATE)
	<MAPF <>
	      <FCN (AC ACLS)
		   <COND (.ACLS
			  <PUT .AC ,AC-USE <>>
			  <PUT .AC ,AC-LLOAD <ACL-LLOAD .ACLS>>
			  <PUT .AC ,AC-LLOAD-EA <ACL-LLOAD-EA .ACLS>>)
			 (<PUT .AC ,AC-USE T>
			  <PUT .AC ,AC-LLOAD <>>
			  <PUT .AC ,AC-LLOAD-EA <>>)>>
	      ,ALL-ACS
	      .LSTATE>>

<DEFINE SAVE-STATE ("AUX" (CACHE ,VARIABLE-CACHE)) 
	#DECL ((SSTATE) <OR FALSE VECTOR> (VALUE) <PRIMTYPE VECTOR>)
	<MAPF ,VECTOR <FCN (LVAR) <COPY-LINKVAR .LVAR>> .CACHE>>

<DEFINE PAIR-MERGE-STATE (SSTATE1 SSTATE2
			  "OPTIONAL" (SSTATE <>) LEN
			  "AUX" LKV2)
	#DECL ((SSTATE1 SSTATE2) AC-STATE
	       (SSTATE) <OR FALSE <PRIMTYPE VECTOR>>)
	<SET LEN <MAX <LENGTH .SSTATE1> <LENGTH .SSTATE2>>>
	<COND (.SSTATE <SET SSTATE <ADJUST-LENGTH .SSTATE .LEN>>)
	      (ELSE <SET SSTATE <IVECTOR .LEN>>)>
	<SET SSTATE <REST .SSTATE <LENGTH .SSTATE>>>
	<MAPF <>
	      <FCN (LKV1)
		   <COND (<SET LKV2 <LINK-FIND .LKV1 .SSTATE2>>
			  <COND (<SET LKV2 <ADJUST-LINKS .LKV1 .LKV2>>
				 <SET SSTATE <BACK .SSTATE>>
				 <PUT .SSTATE 1 .LKV2>)>)>>
	      .SSTATE1>
	.SSTATE>

<DEFINE LINK-FIND (LK1 LINKS "AUX" (VAR <LINKVAR-VAR .LK1>)) 
	#DECL ((LK1) LINKVAR (LINKS) <VECTOR [REST LINKVAR]>)
	<MAPF <>
	      <FCN (LK2)
		   <COND (<==? <LINKVAR-VAR .LK2> .VAR> <MAPLEAVE .LK2>)>>
	      .LINKS>>

<DEFINE ADJUST-LINKS (LK1 LK2
		      "AUX" DECL (VAC <>) (TAC <>) (TWAC <>) (CAC <>) MXREFS)
	#DECL ((LK1 LK2) LINKVAR)
	<COND (<==? <LINKVAR-DECL .LK1> <LINKVAR-DECL .LK2>>
	       <SET DECL <LINKVAR-DECL .LK1>>)
	      (ELSE <SET DECL <>>)>
	<COND (<==? <LINKVAR-TYPE-AC .LK1> <LINKVAR-TYPE-AC .LK2>>
	       <SET TAC <LINKVAR-TYPE-AC .LK1>>)>
	<COND (<==? <LINKVAR-VALUE-AC .LK1> <LINKVAR-VALUE-AC .LK2>>
	       <SET VAC <LINKVAR-VALUE-AC .LK1>>)>
	<COND (<==? <LINKVAR-COUNT-AC .LK1> <LINKVAR-COUNT-AC .LK2>>
	       <SET CAC <LINKVAR-COUNT-AC .LK1>>)>
	<COND (<==? <LINKVAR-TYPE-WORD-AC .LK1> <LINKVAR-TYPE-WORD-AC .LK2>>
	       <SET TWAC <LINKVAR-TYPE-WORD-AC .LK1>>)>
	<COND (<OR .VAC .TAC .TWAC .CAC>
	       <SET LK1 <COPY-LINKVAR .LK1>>
	       <PUT .LK1 ,LINKVAR-DECL .DECL>
	       <PUT .LK1 ,LINKVAR-TYPE-AC .TAC>
	       <PUT .LK1 ,LINKVAR-VALUE-AC .VAC>
	       <PUT .LK1 ,LINKVAR-TYPE-WORD-AC .TWAC>
	       <PUT .LK1 ,LINKVAR-COUNT-AC .CAC>
	       <SET MXREFS
		    <MERGE-XREFS <LINKVAR-POTENTIAL-SAVES .LK1>
				 <LINKVAR-POTENTIAL-SAVES .LK2>>>
	       <PUT .LK1
		    ,LINKVAR-VALUE-STORED
		    <AND <LINKVAR-VALUE-STORED .LK1>
			 <LINKVAR-VALUE-STORED .LK2>>>
	       <PUT .LK1
		    ,LINKVAR-TYPE-STORED
		    <AND <LINKVAR-TYPE-STORED .LK1>
			 <LINKVAR-TYPE-STORED .LK2>>>
	       <PUT .LK1
		    ,LINKVAR-COUNT-STORED
		    <AND <LINKVAR-COUNT-STORED .LK1>
			 <LINKVAR-COUNT-STORED .LK2>>>
	       <PUT .LK1 ,LINKVAR-POTENTIAL-SAVES .MXREFS>)>>

<DEFINE MERGE-XREFS (LX1 LX2) 
	#DECL ((LX1 LX2) <LIST [REST XREF-INFO]>)
	<MAPF ,LIST
	      <FCN (XF1) <COND (<MEMQ .XF1 .LX2> <MAPRET .XF1>) (<MAPRET>)>>
	      .LX1>>

<DEFINE SET-AC-STATE (SSTATE) 
	#DECL ((SSTATE) AC-STATE)
	<FLUSH-VAR-TEMP-DECLS>
	<SETG VARIABLE-CACHE <REST ,VARIABLE-CACHE <LENGTH ,VARIABLE-CACHE>>>
	<MAPF <>
	      <FUNCTION (AC "AUX" (VARS <AC-VARS .AC>)) 
		      <USE-AC .AC>
		      <PUT .AC ,AC-VARS <REST .VARS <LENGTH .VARS>>>>
	      ,ALL-ACS>
	<MAPF <>
	      <FCN (LV "AUX" (VAR <LINKVAR-VAR .LV>) DCL)
		   <CACHE-VAR .VAR .LV>
		   <AND <SET DCL <LINKVAR-DECL .LV>>
			<INDICATE-VAR-TEMP-DECL .VAR .DCL>>>
	      .SSTATE>
	<MAPF <>
	      <FCN (FLKV "AUX" VAC (LKV <FIND-CACHE-VAR <LINKVAR-VAR .FLKV>>))
		   <AND <SET VAC <LINKVAR-VALUE-AC .LKV>>
			<PLACE-LV-IN-AC .VAC .LKV>>
		   <AND <SET VAC <LINKVAR-TYPE-AC .LKV>>
			<PLACE-LV-IN-AC .VAC .LKV>>
		   <AND <SET VAC <LINKVAR-COUNT-AC .LKV>>
			<PLACE-LV-IN-AC .VAC .LKV>>
		   <AND <SET VAC <LINKVAR-TYPE-WORD-AC .LKV>>
			<PLACE-LV-IN-AC .VAC .LKV>>>
	      .SSTATE>
	T>

<DEFINE PROCESS-LABEL-MERGE (LABEL UCB? PATCH
			     "AUX" SSTATE NSSTATE (PRE-STATE <>))
	#DECL ((LABEL) LABEL-REF (UCB?) BOOLEAN (PATCH) FIX)
	<COND (<NOT .UCB?> <SET PRE-STATE <SAVE-STATE>>)>
	<SET SSTATE <COMPUTE-MERGE-STATE .PRE-STATE .LABEL>>
	<OR .UCB? <ADJUST-PRE-LABEL .PRE-STATE .SSTATE .PATCH>>
	<MAPF <>
	      <FCN (XREF)
		   <COND (<SET NSSTATE <XREF-INFO-SAVED-AC-INFO .XREF>>
			  <ADJUST-JUMP .XREF .NSSTATE .SSTATE>)>>
	      <LABEL-REF-XREFS .LABEL>>
	<SET SSTATE <COMPUTE-MERGE-STATE .PRE-STATE .LABEL>>
	<COND (.SSTATE <SET-AC-STATE .SSTATE>)
	      (<MAPF <> ,CLEAR-VARS-FROM-AC ,ALL-ACS>)>
	<CLEAN-UP-LABEL .LABEL>>

<DEFINE CLEAN-UP-LABEL (LABEL) 
	#DECL ((LABEL) LABEL-REF)
	<MAPF <>
	      <FCN (JUMP)
		   <PUT .JUMP ,XREF-INFO-SAVED-AC-INFO <>>
		   <PUT .JUMP ,XREF-INFO-SLSTATE <>>>
	      <LABEL-REF-XREFS .LABEL>>>

<DEFINE COMPUTE-MERGE-STATE (PSSTATE LABEL "AUX" NSSTATE (SSTATE .PSSTATE)) 
	#DECL ((PSSTATE) <OR FALSE AC-STATE> (LABEL) LABEL-REF)
	<MAPF <>
	      <FCN (XREF)
		   <COND (<SET NSSTATE <XREF-INFO-SAVED-AC-INFO .XREF>>
			  <COND (<NOT .PSSTATE>
				 <SET PSSTATE .NSSTATE>
				 <SET SSTATE .PSSTATE>)
				(ELSE
				 <SET SSTATE
				      <PAIR-MERGE-STATE .PSSTATE .NSSTATE>>
				 <SET PSSTATE .SSTATE>)>)>>
	      <LABEL-REF-XREFS .LABEL>>
	.SSTATE>

<DEFINE ADJUST-JUMP (XREF JSSTATE LSSTATE "AUX" SVEC) 
	#DECL ((XREF) XREF-INFO (JSSTATE LSSTATE) AC-STATE)
	<SET-AC-LOAD-STATE <XREF-INFO-SLSTATE .XREF>>
	<SET SVEC <GEN-INSERT .JSSTATE .LSSTATE .XREF>>
	<SET SVEC
	     <PRE-INSERT .SVEC
			 <XREF-INFO-STATUS .XREF>
			 <XREF-INFO-LILEN .XREF>
			 <XREF-INFO-CP .XREF>>>
	<PUT .XREF ,XREF-INFO-STACK-SAVE-CODE .SVEC>>

<DEFINE PRE-INSERT (CDV STATUS? LILEN CP "AUX" INS1 (INS2 <>) RES) 
	#DECL ((CDV) CODEVEC (STATUS?) ANY (LILEN CP) FIX)
	<COND (<OR <==? .STATUS? UNCONDITIONAL-BRANCH> <EMPTY? .CDV>> .CDV)
	      (ELSE
	       <SET INS1 <NTH-CODE <- .CP .LILEN>>>
	       <COND (<G=? .LILEN 2>
		      <SET INS2
			   <REPEAT ((L ()) (NLILEN 0)) #DECL ((L) LIST)
				   <COND (<G=? <SET NLILEN <+ .NLILEN 1>>
					       .LILEN> 
					  <RETURN .L>)>
				   <SET L (<NTH-CODE <- .CP .NLILEN>> !.L)>
				   <PUT-CODE <- .CP .NLILEN> ,INST-NULLF>>>)>
	       <COND (<TYPE? .STATUS? AC>
		      <SET RES <RE-GEN .CDV .STATUS? .INS1 .INS2>>)
		     (<==? .LILEN 1> <SET RES <UVECTOR !.CDV .INS1>>)
		     (<SET RES <UVECTOR !.CDV .INS1 !.INS2>>)>
	       <PUT-CODE <- .CP .LILEN> ,INST-NULLF>
	       .RES)>>

<DEFINE RE-GEN (CDV AC INS1 INS2) 
	#DECL ((INS1) FIX (INS2) <OR FALSE <LIST [REST FIX]>>
	       (CDV) CODEVEC (AC) AC)
	<SETG RE-GEN-POST ()>
	<SETG RE-GEN-PRE ()>
	<INT-RE-GEN .CDV .AC <>>
	<COND (.INS2 <UVECTOR !,RE-GEN-PRE .INS1 !.INS2 !,RE-GEN-POST>)
	      (<UVECTOR !,RE-GEN-PRE .INS1 !,RE-GEN-POST>)>>


<DEFINE GET-I-FIELD (X) <CHTYPE <LSH .X -24> FIX>>

<DEFINE GET-S-FIELD (X "AUX" (OP1 <CHTYPE <ANDB <LSH .X -16> *377*> FIX>))
	<COND (<==? <CHTYPE <ANDB .OP1 *360*> FIX> ,AM-REG>
	       <CHTYPE <ANDB .OP1 *17*> FIX>)
	      (ELSE -1)>>

<DEFINE INT-RE-GEN (CDV AC PSAVE) 
	#DECL ((AC) AC (CDV) CODEVEC (PSAVE) <OR FALSE PTN-SAVE>)
	<REPEAT (IFLD IREG INST)
		<COND (<EMPTY? .CDV> <RETURN>)>
		<SET IFLD <GET-I-FIELD <SET INST <1 .CDV>>>>
		<SET IREG <GET-S-FIELD .INST>>
		<COND (<==? .IFLD ,INST-PSTORE>
		       <SET PSAVE <GET-PTNS <CHTYPE <ANDB .INST
							  *377777*> FIX>>>
		       <PSTORE-RE-GEN <PTNS-CODE .PSAVE> .AC .PSAVE .INST>
		       <SET CDV <REST .CDV>>)
		      (<AND <OR <==? .IFLD ,INST-MOVW>
				<==? .IFLD ,INST-MOVL>
				<==? .IFLD ,INST-MOVB>>
			    <==? .IREG <AC-NUMBER .AC>>>
		       <GROUP-INST POST .PSAVE .INST (<2 .CDV>)>
		       <SET CDV <REST .CDV 2>>)
		      (ELSE
		       <COND (<OR <==? .IFLD ,INST-MOVB>
				  <==? .IFLD ,INST-MOVW>
				  <==? .IFLD ,INST-MOVL>>
			      <GROUP-INST PRE .PSAVE .INST (<2 .CDV>)>
			      <SET CDV <REST .CDV 2>>)
			     (ELSE
			      <GROUP-INST PRE .PSAVE .INST <>>
			      <SET CDV <REST .CDV>>)>)>>>

<DEFINE PSTORE-RE-GEN (CDV AC PSAVE INST) 
	#DECL ((AC) AC (CDV) CODEVEC (PSAVE) <OR FALSE PTN-SAVE> (INST) FIX)
	<COND (<==? <TEST-PRE-POST .CDV .AC> ALL-PRE>
	       <GROUP-INST PRE <> .INST <>>)
	      (<==? <TEST-PRE-POST .CDV .AC> ALL-POST>
	       <GROUP-INST POST <> .INST <>>)
	      (<INT-RE-GEN .CDV .AC .PSAVE>)>>

<DEFINE TEST-PRE-POST (CDV AC "AUX" (MODE <>)) 
	#DECL ((AC) AC (CDV) CODEVEC)
	<REPEAT (IFLD IREG IMOD INST)
		<COND (<EMPTY? .CDV> <RETURN .MODE>)>
		<SET IFLD <GET-I-FIELD <SET INST <1 .CDV>>>>
		<SET IREG <GET-S-FIELD .INST>>
		<COND (<AND <OR <==? .IFLD ,INST-MOVW> <==? .IFLD ,INST-MOVL>>
			    <==? .IREG <AC-NUMBER .AC>>>
		       <COND (<N==? .MODE ALL-PRE> <SET MODE ALL-POST>)
			     (<RETURN MIXED>)>
		       <SET CDV <REST .CDV 2>>)
		      (ELSE
		       <COND (<==? .MODE ALL-POST> <RETURN MIXED>)
			     (<SET MODE ALL-PRE>)>
		       <COND (<OR <==? .IFLD ,INST-MOVB>
				  <==? .IFLD ,INST-MOVW>
				  <==? .IFLD ,INST-MOVL>>
			      <SET CDV <REST .CDV 2>>)
			     (<SET CDV <REST .CDV>>)>)>>>

<DEFINE GROUP-INST (MODE PSAVE INST1 INST2 "AUX" ADD NPSAVE) 
	#DECL ((MODE) ATOM (PSAVE) <OR FALSE PTN-SAVE> (INST1) FIX
	       (INST2) <OR FALSE LIST>)
	<COND (.PSAVE
	       <COND (.INST2 <SET ADD <UVECTOR .INST1 !.INST2>>)
		     (<SET ADD <UVECTOR .INST1>>)>
	       <SET NPSAVE <COPY-PSAVE .PSAVE .ADD>>
	       <COND (<==? .MODE PRE> <SETG RE-GEN-PRE (.NPSAVE !,RE-GEN-PRE)>)
		     (<SETG RE-GEN-POST (.NPSAVE !,RE-GEN-POST)>)>)
	      (ELSE
	       <COND (<==? .MODE PRE>
		      <COND (.INST2
			     <SETG RE-GEN-PRE (.INST1 !.INST2 !,RE-GEN-PRE)>)
			    (<SETG RE-GEN-PRE (.INST1 !,RE-GEN-PRE)>)>)
		     (<COND (.INST2
			     <SETG RE-GEN-POST (.INST1 !.INST2 !,RE-GEN-POST)>)
			    (<SETG RE-GEN-POST (.INST1 !,RE-GEN-POST)>)>)>)>>

<DEFINE GEN-INSERT (JSSTATE LSSTATE "OPTIONAL" (XREF <>)) 
	#DECL ((JSSTATE LSSTATE) AC-STATE)
	<START-CODE-INSERT>
	<MAPF <>
	      <FCN (JLV "AUX" LLV (VAR <LINKVAR-VAR .JLV>))
		   <COND (<SET LLV <FIND-CACHE-VAR .VAR .LSSTATE>>
			  <CHECK-VALUE-STORED .JLV .LLV .XREF>
			  <CHECK-TYPE-STORED .JLV .LLV .XREF>
			  <CHECK-COUNT-STORED .JLV .LLV .XREF>)
			 (ELSE <ISTORE-VAR .JLV .XREF>)>>
	      .JSSTATE>
	<END-CODE-INSERT>>

<DEFINE ADJUST-PRE-LABEL (JSSTATE LSSTATE PATCH "AUX" SVEC) 
	#DECL ((JSSTATE LSSTATE) AC-STATE (PATCH) FIX)
	<SET SVEC <GEN-INSERT .JSSTATE .LSSTATE>>
	<INSERT-PATCH .PATCH .SVEC>>

<DEFINE CHECK-VALUE-STORED (JLV LLV XREF
			    "AUX" DADDR VAC (VAR <LINKVAR-VAR .JLV>) SVEC)
	#DECL ((JLV LLV) LINKVAR (XREF) <OR FALSE XREF-INFO>)
	<COND (<AND <LINKVAR-VALUE-AC .JLV>
		    <NOT <LINKVAR-VALUE-AC .LLV>>
		    <NOT <LINKVAR-VALUE-STORED .JLV>>>
	       <START-CODE-INSERT>
	       <COND (<NOT <SET VAC <LINKVAR-VALUE-AC .JLV>>>
		      <ERROR "VARIABLE NOT IN AC" CHECK-VALUE-STORED>)>
	       <SET DADDR <ADDR-VAR-VALUE .VAR>>
	       <EMIT-STORE-AC .VAC .DADDR LONG>
	       <PUT .JLV ,LINKVAR-VALUE-STORED T>
	       <SET SVEC <END-CODE-INSERT>>
	       <EMIT-POTENTIAL-STORE .SVEC VALUE .JLV>
	       <AND .XREF <KILL-STORES .XREF VALUE .VAR>>)>>

<DEFINE KILL-STORES (XREF KIND VAR) 
	#DECL ((XREF) XREF-INFO (KIND) ATOM (VAR) VARTBL)
	<MAPF <>
	      <FCN (PSAVE)
		   <COND (<AND <==? <PTNS-VAR .PSAVE> .VAR>
			       <STRONGER-SAVE? .KIND <PTNS-KIND .PSAVE>>>
			  <KILL-PSAVE .PSAVE>)>>
	      <XREF-INFO-PSAVES .XREF>>>

<DEFINE STRONGER-SAVE? (KIND1 KIND2) 
	#DECL ((KIND1 KIND2) ATOM)
	<OR <==? .KIND1 .KIND2>
	    <==? .KIND1 TYPE-COUNT-VALUE>
	    <AND <==? .KIND1 TYPE-COUNT>
		 <OR <==? .KIND2 TYPE> <==? .KIND2 COUNT>>>
	    <AND <==? .KIND1 TYPE-VALUE>
		 <OR <==? .KIND2 TYPE> <==? .KIND2 VALUE>>>
	    <AND <==? .KIND1 COUNT-VALUE>
		 <OR <==? .KIND2 COUNT> <==? .KIND2 VALUE>>>>>

<DEFINE CHECK-TYPE-STORED (JLV LLV XREF
			   "AUX" DADDR TAC DCL (VAR <LINKVAR-VAR .JLV>) SVEC
				 (KIND TYPE))
	#DECL ((JLV LLV) LINKVAR (XREF) <OR FALSE XREF-INFO>)
	<COND (<AND <NOT <LINKVAR-TYPE-STORED .JLV>>
		    <NOT <LINKVAR-DECL .LLV>>
		    <NOT <LINKVAR-TYPE-AC .LLV>>
		    <NOT <LINKVAR-TYPE-WORD-AC .LLV>>>
	       <START-CODE-INSERT>
	       <SET DADDR <ADDR-VAR-TYPE .VAR>>
	       <PUT .JLV ,LINKVAR-TYPE-STORED T>
	       <COND (<SET TAC <LINKVAR-TYPE-WORD-AC .JLV>>
		      <EMIT-STORE-AC .TAC .DADDR LONG>
		      <PUT .JLV ,LINKVAR-COUNT-STORED T>
		      <SET KIND TYPE-COUNT>)
		     (<SET DCL <LINKVAR-DECL .JLV>>
		      <STORE-TYPE .DCL .DADDR>
		      <COND (<NOT <COUNT-NEEDED? .DCL>>
			     <PUT .JLV ,LINKVAR-COUNT-STORED T>)>)
		     (<SET TAC <LINKVAR-TYPE-AC .JLV>>
		      <EMIT-STORE-AC .TAC .DADDR WORD>)
		     (<ERROR "VARIABLE NOT IN AC" ISTORE-ADDR>)>
	       <SET SVEC <END-CODE-INSERT>>
	       <EMIT-POTENTIAL-STORE .SVEC .KIND .JLV>
	       <AND .XREF <KILL-STORES .XREF .KIND .VAR>>)>>

<DEFINE CHECK-COUNT-STORED (JLV LLV XREF
			    "AUX" DADDR TAC DCL SVEC (KIND COUNT)
				  (VAR <LINKVAR-VAR .JLV>))
	#DECL ((JLV LLV) LINKVAR (XREF) <OR FALSE XREF-INFO>)
	<COND (<AND <NOT <LINKVAR-COUNT-AC .LLV>>
		    <NOT <LINKVAR-TYPE-WORD-AC .LLV>>
		    <NOT <LINKVAR-COUNT-STORED .JLV>>
		    <OR <NOT <SET DCL <LINKVAR-DECL .LLV>>>
			<COUNT-NEEDED? .DCL>>
		    <OR <NOT <SET DCL <LINKVAR-DECL .JLV>>>
			<COUNT-NEEDED? .DCL>>>
	       <START-CODE-INSERT>
	       <SET DADDR <ADDR-VAR-COUNT <LINKVAR-VAR .JLV>>>
	       <PUT .JLV ,LINKVAR-COUNT-STORED T>
	       <COND (<SET TAC <LINKVAR-TYPE-WORD-AC .JLV>>
		      <SET DADDR <ADDR-VAR-TYPE <LINKVAR-VAR .JLV>>>
		      <EMIT-STORE-AC .TAC .DADDR LONG>
		      <PUT .JLV ,LINKVAR-TYPE-STORED T>
		      <SET KIND TYPE-COUNT>)
		     (<SET TAC <LINKVAR-COUNT-AC .JLV>>
		      <EMIT-STORE-AC .TAC .DADDR WORD>)>
	       <SET SVEC <END-CODE-INSERT>>
	       <EMIT-POTENTIAL-STORE .SVEC .KIND .JLV>
	       <AND .XREF <KILL-STORES .XREF .KIND .VAR>>)>>

<DEFINE SETUP-PSAVES (XREF "AUX" (CACHE ,VARIABLE-CACHE)) 
	#DECL ((XREF) XREF-INFO)
	<MAPF <>
	      <FCN (LVAR "AUX" (PSAVES <LINKVAR-POTENTIAL-SAVES .LVAR>))
		   <PUT .LVAR ,LINKVAR-POTENTIAL-SAVES (.XREF !.PSAVES)>>
	      .CACHE>>

<DEFINE LOOP-GEN ("TUPLE" VARS) 
	#DECL ((VARS) <TUPLE [REST <OR ATOM LIST>]>)
	<CLEAR-STATUS>
	<MAPR <>
	      <FCN (MVARS "AUX" (VARLST <1 .MVARS>))
		   <COND (<TYPE? .VARLST ATOM>
			  <PUT .MVARS 1 <LIST <FIND-VAR .VARLST> VALUE>>)
			 (<PUT .MVARS
			       1
			       (<FIND-VAR <1 .VARLST>> !<REST .VARLST>)>)>>
	      .VARS>
	<SETUP-LOOP-ACS .VARS>
	<SETG LOOP-VARS <SAVE-STATE>>
	<CLEAR-STATUS>
	LOOP-LABEL>

<DEFINE SETUP-LOOP-ACS (VARS "AUX" TAC) 
   #DECL ((VARS) <TUPLE [REST LIST]>)
   <MAPF <>
	 <FCN (LVAR "AUX" (VAR <LINKVAR-VAR .LVAR>))
	      <COND (<NOT <FIND-INFO .VAR .VARS>>
		     <ISTORE-VAR .LVAR>
		     <DEAD-VAR .VAR>)>>
	 ,VARIABLE-CACHE>
   <MAPF <>
	 <FCN (LVAR "AUX" (VAR <LINKVAR-VAR .LVAR>) RVAR NLVAR
			  (CS <LINKVAR-COUNT-STORED .LVAR>)
			  (VS <LINKVAR-VALUE-STORED .LVAR>)
			  (TS <LINKVAR-TYPE-STORED .LVAR>))
	      <SET RVAR <FIND-INFO .VAR .VARS>>
	      <SET NLVAR <COPY-LINKVAR .LVAR>>
	      <AND <MEMQ TYPE .RVAR> <SET TS T>>
	      <AND <MEMQ VALUE .RVAR> <SET VS T>>
	      <COND (<MEMQ LENGTH .RVAR>
		     <SET CS T>
		     <SET TS T>)>
	      ; "Make sure that if we're storing the type we also store
		 the value, so  we don't get garbage pointers on the stack."
	      <COND (<OR <NOT .VS><NOT .TS><NOT .CS>>
		     <ISTORE-VAR .NLVAR>)
		    (<LINKVAR-COUNT-STORED .NLVAR .CS>
		     <LINKVAR-TYPE-STORED .NLVAR .TS>
		     <LINKVAR-VALUE-STORED .NLVAR .VS>)>
	      <COND (<AND <SET TAC <LINKVAR-TYPE-AC .NLVAR>>
			  <NOT <MEMQ TYPE .RVAR>>>
		     <AND <LINKVAR-TYPE-AC .LVAR> <BREAK-LINK .TAC .VAR>>
		     <PUT .LVAR ,LINKVAR-TYPE-STORED T>)>
	      <COND (<AND <SET TAC <LINKVAR-COUNT-AC .NLVAR>>
			  <NOT <MEMQ LENGTH .RVAR>>>
		     <PUT .LVAR ,LINKVAR-COUNT-STORED T>
		     <AND <LINKVAR-COUNT-AC .LVAR> <BREAK-LINK .TAC .VAR>>)>
	      <COND (<AND <SET TAC <LINKVAR-TYPE-WORD-AC .NLVAR>>
			  <NOT <MEMQ TYPE .RVAR>>
			  <NOT <MEMQ LENGTH .RVAR>>>
		     <AND <LINKVAR-TYPE-WORD-AC .LVAR> <BREAK-LINK .TAC .VAR>>
		     <PUT .LVAR ,LINKVAR-TYPE-STORED T>
		     <PUT .LVAR ,LINKVAR-COUNT-STORED T>)>>
	 ,VARIABLE-CACHE>
   <MAPF <>
    <FCN (RVAR "AUX" VAC (VAR <1 .RVAR>) LVAR)
	 <COND (<VARTBL-ASSIGNED? .VAR>
		<COND (<SET LVAR <FIND-CACHE-VAR .VAR>>
		       <AND <SET VAC <LINKVAR-TYPE-AC .LVAR>> <PROTECT .VAC>>
		       <AND <SET VAC <LINKVAR-COUNT-AC .LVAR>> <PROTECT .VAC>>
		       <AND <SET VAC <LINKVAR-TYPE-WORD-AC .LVAR>>
			    <PROTECT .VAC>>)>
		<AND <MEMQ VALUE .RVAR> <PROTECT <LOAD-VAR-APP .VAR <>>>>
		<COND (<AND <MEMQ TYPE .RVAR> <MEMQ LENGTH .RVAR>>
		       <PROTECT <LOAD-VAR .VAR TYPE-WORD <> PREF-TYPE>>)
		      (<MEMQ TYPE .RVAR>
		       <PROTECT <LOAD-VAR .VAR TYPE <> PREF-TYPE>>)
		      (<MEMQ LENGTH .RVAR>
		       <PROTECT <LOAD-VAR .VAR TYPE-WORD <> PREF-TYPE>>)>
		<SET LVAR <FIND-CACHE-VAR .VAR>>
		<LINKVAR-POTENTIAL-SAVES .LVAR ()>
		<AND <MEMQ TYPE .RVAR> <PUT .LVAR ,LINKVAR-TYPE-STORED <>>>
		<AND <MEMQ VALUE .RVAR> <PUT .LVAR ,LINKVAR-VALUE-STORED <>>>
		<AND <MEMQ LENGTH .RVAR>
		     <PUT .LVAR ,LINKVAR-COUNT-STORED <>>>)>>
    .VARS>
   T>

<DEFINE FIND-INFO (VAR VARS) 
	#DECL ((VAR) VARTBL (VARS) <TUPLE [REST LIST]>)
	<MAPF <>
	      <FCN (RVAR) <COND (<==? .VAR <1 .RVAR>> <MAPLEAVE .RVAR>)>>
	      .VARS>>

<DEFINE RESTORE-LOOP-STATE (LSTATE) 
	#DECL ((LSTATE) AC-STATE)
	<MAPF <>
	      <FCN (LVAR "AUX" (VAR <LINKVAR-VAR .LVAR>) LVAR1)
		   <COND (<SET LVAR1 <FIND-CACHE-VAR .VAR .LSTATE>>
			  <PROTECT-MATCHES .LVAR .LVAR1>)
			 (ELSE <ISTORE-VAR .LVAR <> T> <DEAD-VAR .VAR>)>>
	      <SAVE-STATE>>
	<MAPF <>
	      <FCN (LVAR "AUX" (VAR <LINKVAR-VAR .LVAR>) VAC)
		   <AND <SET VAC <LINKVAR-VALUE-AC .LVAR>>
			<PROTECT <LP-LOAD-VAR .VAR VALUE <> .VAC>>>
		   <AND <SET VAC <LINKVAR-TYPE-AC .LVAR>>
			<PROTECT <LP-LOAD-VAR .VAR TYPE <> .VAC>>>
		   <AND <SET VAC <LINKVAR-TYPE-WORD-AC .LVAR>>
			<PROTECT <LP-LOAD-VAR .VAR TYPE-WORD <> .VAC>>>
		   <AND <SET VAC <LINKVAR-COUNT-AC .LVAR>>
			<PROTECT <LP-LOAD-VAR .VAR COUNT <> .VAC>>>>
	      .LSTATE>
	<SET-AC-STATE .LSTATE>>

<DEFINE PROTECT-MATCHES (LVAR1 LVAR2 "AUX" VAC (VAR <LINKVAR-VAR .LVAR1>)) 
	#DECL ((LVAR1 LVAR2) LINKVAR)
	<AND <LINKVAR-VALUE-AC .LVAR2> <PUT .LVAR1 ,LINKVAR-VALUE-STORED T>>
	<AND <LINKVAR-TYPE-AC .LVAR2> <PUT .LVAR1 ,LINKVAR-TYPE-STORED T>>
	<AND <LINKVAR-COUNT-AC .LVAR2> <PUT .LVAR2 ,LINKVAR-COUNT-STORED T>>
	<AND <LINKVAR-TYPE-WORD-AC .LVAR2>
	     <PUT .LVAR1 ,LINKVAR-TYPE-STORED T>
	     <PUT .LVAR1 ,LINKVAR-COUNT-STORED T>>
	<COND (<SET VAC <LINKVAR-TYPE-AC .LVAR1>>
	       <COND (<AND <NOT <LINKVAR-TYPE-AC .LVAR2>>
			   <NOT <LINKVAR-TYPE-WORD-AC .LVAR2>>>
		      <ISTORE-VAR .LVAR1 <> T>
		      <BREAK-LINK .VAC .VAR>)
		     (<==? .VAC <LINKVAR-TYPE-AC .LVAR2>> <PROTECT .VAC>)>)>
	<COND (<SET VAC <LINKVAR-VALUE-AC .LVAR1>>
	       <COND (<NOT <LINKVAR-VALUE-AC .LVAR2>>
		      <ISTORE-VAR .LVAR1 <> T>
		      <BREAK-LINK .VAC .VAR>)
		     (<==? .VAC <LINKVAR-VALUE-AC .LVAR2>> <PROTECT .VAC>)>)>
	<COND (<SET VAC <LINKVAR-TYPE-WORD-AC .LVAR1>>
	       <COND (<AND <NOT <LINKVAR-TYPE-WORD-AC .LVAR2>>
			   <NOT <LINKVAR-COUNT-AC .LVAR2>>
			   <NOT <LINKVAR-TYPE-AC .LVAR2>>>
		      <ISTORE-VAR .LVAR1 <> T>
		      <BREAK-LINK .VAC .VAR>)
		     (<==? .VAC <LINKVAR-TYPE-WORD-AC .LVAR2>>
		       <PROTECT .VAC>)>)>
	<COND (<SET VAC <LINKVAR-COUNT-AC .LVAR1>>
	       <COND (<AND <NOT <LINKVAR-COUNT-AC .LVAR2>>
			   <NOT <LINKVAR-TYPE-WORD-AC .LVAR2>>>
		      <ISTORE-VAR .LVAR1 <> T>
		      <BREAK-LINK .VAC .VAR>)
		     (<==? .VAC <LINKVAR-COUNT-AC .LVAR2>>
		       <PROTECT .VAC>)>)>>

"THE STATUS INFORMATION THAT IS CURRENTLY-GENERATED IS AN ATOM
 EITHER NORMAL, UNCONDITIONAL-BRANCH, LOOP-LABEL"

<DEFINE GEN-LABEL (LABEL STATUS "AUX" LREF PATCH) 
	#DECL ((LABEL STATUS) ATOM)
	<COND (<MEMQ .LABEL ,INT-LABELS>
	       <EMIT-LABEL .LABEL <>>
	       <MAPF <> ,CLEAR-VARS-FROM-AC ,ALL-ACS>)
	      (ELSE
	        <COND (<MEMQ .LABEL ,ICALL-LABELS>
		       <POP-MODEL>
		       <SETG ICALL-LEVEL <- ,ICALL-LEVEL 1>>
		       <MAPF <> ,CLEAR-VARS-FROM-AC ,ALL-ACS>)>
	       <AND <N==? .STATUS UNCONDITIONAL-JUMP>
		    <SET PATCH <ADD-PATCH LABEL-MERGE>>>
	       <COND (<==? .STATUS LOOP-LABEL>
		      <SET LREF <EMIT-LABEL .LABEL ,LOOP-VARS>>)
		     (<SET LREF <EMIT-LABEL .LABEL <>>>)>
	       <COND (<==? .STATUS UNCONDITIONAL-BRANCH>
		      <PROCESS-LABEL-MERGE .LREF T 0>)
		     (<PROCESS-LABEL-MERGE .LREF <> .PATCH>)>)>>

<DEFINE GEN-BRANCH (INST LABEL STATUS?
		    "OPTIONAL" (ACNUM <>) (FLONG? <>) (NO-KILL <>)
		    "AUX" XREF LREF INSRT (LLEN ,LAST-INST-LENGTH)
			  (CCOUNT ,CODE-COUNT) LSTATE)
	#DECL ((INST CC) FIX (LABEL) <OR ATOM SPEC-LABEL>
	       (ACNUM) ANY (STATUS?) ANY (FLONG?) BOOLEAN)
	<SET XREF <EMIT-BRANCH .INST .LABEL .STATUS? .LLEN .ACNUM .FLONG?>>
	<COND (<TYPE? .LABEL SPEC-LABEL>)
	      (<AND <SET LREF <XREF-INFO-LABEL .XREF>>
		    <SET LSTATE <LABEL-REF-LOOP-LABEL .LREF>>>
	       <START-CODE-INSERT>
	       <RESTORE-LOOP-STATE .LSTATE>
	       <SET INSRT <END-CODE-INSERT>>
	       <SET INSRT <PRE-INSERT .INSRT .STATUS? .LLEN .CCOUNT>>
	       <PUT .XREF ,XREF-INFO-STACK-SAVE-CODE .INSRT>)
	      (<NOT <MEMQ .LREF ,OUTST-LABEL-TABLE>>
	       <ERROR "JUMPING BACK TO A NON-LOOP LABEL" .LREF>)
	      (ELSE
	       <COND (<NOT .NO-KILL> <SET-DEATH .CODPTR T>)>
	       <SAVE-XREF-AC-INFO .XREF <SAVE-STATE> <SAVE-LOAD-STATE>>
	       <USE-ALL-ACS>
	       <SETUP-PSAVES .XREF>)>>

<DEFINE LP-LOAD-VAR (VAR TYP MUNG VAC "AUX" TAC LVAR) 
	#DECL ((VAR) VARTBL (TYP) ATOM (MUNG) BOOLEAN (VAC) AC)
	<COND (<AND <SET LVAR <FIND-CACHE-VAR .VAR>>
		    <OR <AND <==? .TYP TYPE>
			     <==? <LINKVAR-TYPE-AC .LVAR> .VAC>>
			<AND <==? .TYP VALUE>
			     <==? <LINKVAR-VALUE-AC .LVAR> .VAC>>
			<AND <==? .TYP COUNT>
			     <==? <LINKVAR-COUNT-AC .LVAR> .VAC>>
			<AND <==? .TYP TYPE-WORD>
			     <==? <LINKVAR-TYPE-WORD-AC .LVAR> .VAC>>>>)
	      (<NOT <ALL-DEAD? .VAC>>
	       <COND (<SET TAC <FREE-AC?>>
		      <EMIT-EXCH .VAC .TAC>
		      <EXCH-AC .TAC .VAC>)>)>
	<LOAD-VAR .VAR .TYP .MUNG .VAC>>       