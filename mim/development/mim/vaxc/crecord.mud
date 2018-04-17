

<DEFINE INIT-RECORD-DEFS ()
	<SETG RECORD-TABLE ()>>

<DEFINE DEFINE-RECORD (TYP STACK "TUPLE" ELEMENTS "AUX" DESC ELIST) 
	<SET ELIST <LIST !.ELEMENTS>>
	<SET DESC <CHTYPE <VECTOR .TYP .ELIST .STACK> RECORD-DESCRIPTOR>>
	<SETG RECORD-TABLE (.DESC !,RECORD-TABLE)>>

<DEFINE PARSE-RED (TYP OFFSET
		   "OPTIONAL" (ALTOFF 0) (LEN? <>) (SBOOL? <>)
		   "AUX" RES)
	#DECL ((TYP) ATOM (OFFSET ALTOFF) FIX (LEN?) <OR FALSE FIX>
	       (SBOOL?) BOOLEAN)
	<COND (<==? .TYP ANY>
	       <SET RES <VECTOR .OFFSET .ALTOFF ANY 0 <> <> <>>>)
	      (<OR <==? .TYP BYTE>
		   <==? .TYP SMALL-INT>
		   <==? .TYP SMALL-POS-INT>
		   <==? .TYP SMALL-FR-OFFSET>>
	       <SET RES <VECTOR .OFFSET 0 .TYP 0 <> <> <>>>)
	      (<==? .TYP BOOLEAN>
	       <SET RES <VECTOR .OFFSET 0 BOOLEAN .ALTOFF <> <> <>>>)
	      (<==? .TYP TYPE-C>
	       <SET RES <VECTOR .OFFSET 0 TYPE-C 0 .SBOOL? <> .TYP>>)
	      (<AND <VALID-TYPE? .TYP>
		    <MEMQ <TYPEPRIM .TYP> '[VECTOR STRING UVECTOR BYTES]>
		    <NOT .LEN?>>
	       <SET RES <VECTOR .OFFSET .ALTOFF COUNTVWORD 0 .SBOOL? <> .TYP>>)
	      (<OR .LEN?
		   <MEMQ .TYP '[T$ATOM T$LBIND T$MSUBR T$GBIND T$FRAME
				T$OBLIST]>
		   <==? <TYPEPRIM .TYP> LIST> <==? <TYPEPRIM .TYP> FIX>>
	       <SET RES <VECTOR .OFFSET 0 VWORD1 0 .SBOOL? .LEN? .TYP>>)>
	<CHTYPE .RES RECORD-ELEMENT-DESCRIPTOR>>

<DEFINE GET-RELE-DESCRIPTOR (NUM HINT "AUX" RTYP RECTYP) 
	#DECL ((NUM) FIX (HINT) <OR ATOM HINT>)
	<COND (<TYPE? .HINT ATOM> <SET RTYP .HINT>)
	      (<SET RTYP <PARSE-HINT .HINT RECORD-TYPE>>)>
	<MAPF <>
	      <FCN (ELE)
		   <COND (<OR <MEMQ .RTYP <SET RECTYP <REC-TYPE-NAME .ELE>>>
			      <MEMQ <CLEAN-DECL .RTYP> .RECTYP>>
			  <MAPLEAVE <NTH <REC-ELEMENTS .ELE> .NUM>>)>>
	      ,RECORD-TABLE>>

<DEFINE GET-RSTACK? (HINT "AUX" RTYP RECTYP) 
	#DECL ((HINT) <OR ATOM HINT>)
	<COND (<TYPE? .HINT ATOM> <SET RTYP .HINT>)
	      (<SET RTYP <PARSE-HINT .HINT RECORD-TYPE>>)>
	<MAPF <>
	      <FCN (ELE)
		   <COND (<OR <MEMQ .RTYP <SET RECTYP <REC-TYPE-NAME .ELE>>>
			      <MEMQ <CLEAN-DECL .RTYP> .RECTYP>>
			  <MAPLEAVE <REC-STACK .ELE>>)>>
	      ,RECORD-TABLE>>

<DEFINE GET-RELE-BRANCH? (HINT2) 
	#DECL ((HINT2) <OR FALSE HINT>)
	<COND (<AND .HINT2
		    <OR <==? <1 .HINT2> BRANCH-FALSE>
			<==? <1 .HINT2> BRANCH-TAG>>>
	       <PROG ((CP .CODPTR) FROB)
	         #DECL ((CP) LIST)
		 <COND (<AND <NOT <EMPTY? .CP>>
			     <TYPE? <SET FROB <1 .CP>> FORM>>
			<COND (<N==? <1 .FROB> DEAD!-MIMOP>
			       <PUTPROP .FROB DONE T>)
			      (T
			       <SET CP <REST .CP>>
			       <AGAIN>)>)>>
	       <REST .HINT2>)>>

<DEFINE INIT-REC-DEFS () 
	<INIT-RECORD-DEFS>
	<DEFINE-RECORD [T$ATOM T$LINK T$GVAL T$LVAL ATOM LINK GVAL LVAL]
		       <>
		       <PARSE-RED T$GBIND 0 0 <> T>
		       <PARSE-RED T$LBIND 4 0 <> T>
		       <PARSE-RED STRING 12 10 <> <>>
		       <PARSE-RED T$OBLIST 16 0 <> T>
		       <PARSE-RED TYPE-C 8 0 <> T>>
	<DEFINE-RECORD [T$FRAME FRAME]
		       T
		       <PARSE-RED T$MSUBR -24 0 4 <>>
		       <PARSE-RED FIX -20 0 <> <>>
		       <PARSE-RED SMALL-POS-INT -16 0 <> <>>
		       <PARSE-RED SMALL-POS-INT -14 0 <> <>>
		       <PARSE-RED T$FRAME -12 0 <> <>>
		       <PARSE-RED SMALL-POS-INT -6 0 0 <>>
		       <PARSE-RED SMALL-FR-OFFSET -8 0 <> <>>
		       <PARSE-RED FIX -4 0 <> <>>>
	<DEFINE-RECORD [T$LBIND LBIND]
		       T
		       <PARSE-RED ANY 4 0 <> <>>
		       <PARSE-RED T$ATOM 8 0 <> <>>
		       <PARSE-RED ANY 16 12 <> <>>
		       <PARSE-RED T$LBIND 20 0 <> T>
		       <PARSE-RED T$LBIND 24 0 <> T>
		       <PARSE-RED FIX 28 0 <> <>>>
	<DEFINE-RECORD [T$GBIND GBIND]
		       <>
		       <PARSE-RED ANY 4 0 <> <>>
		       <PARSE-RED T$ATOM 8 0 <> <>>
		       <PARSE-RED ANY 16 12 <> <>>>>