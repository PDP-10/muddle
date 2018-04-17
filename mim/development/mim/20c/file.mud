

<BLOCK (<ROOT>)>

;"GETS names"

<NEWTYPE LOSE FIX>

COMPILER-INPUT

<COND (<NOT <GASSIGNED? GVAL-CAREFUL>> <SETG GVAL-CAREFUL <>>)>
<COND (<NOT <GASSIGNED? ADJBP-HACK>> <SETG ADJBP-HACK <>>)>

ACTIVATION

MRETURN

LOOP

TBIND

BINDID

DISPATCH 

ARGS 

OBLIST 

INGC

UBLOCK 

UUBLOCK

USBLOCK

SBLOCK

BIND 

PAGPTR 

MINF 

ICALL 

ECALL 

NCALL 

UWATM 

MAPPER 

ENVIR 

RUNINT 

PURVEC 

DBVEC 

M$$BINDID 

FRAME 

SFRAME 

ADJ 

SCALL 

CALL 

NTHR 

= 

FCN 

GFCN 

IFSYS 

IFCANNOT

IFCAN

ENDIF 

TEMP 

MAKTUP 

END 

COMPERR 

UNWCONT 

IOERR 

JUMP 

OPT-DISPATCH 

ICALL 

ACALL 

BRANCH-FALSE 

DEAD-FALL

DEAD-JUMP

STACK 

TYPE-CODE 

TYPE-WORD 

RECORD-TYPE 

DEAD 

ALL 

<SETG TYPE-LENGTHS
      [T$LBIND
       16
       LBIND
       16
       T$GBIND
       10
       GBIND
       10
       T$ATOM
       10
       ATOM
       10
       T$OBLIST
       10
       OBLIST
       10
       T$LINK
       10
       LINK
       10
       T$LVAL
       10
       LVAL
       10
       T$GVAL
       10
       GVAL
       10
       T$FRAME
       12
       FRAME
       12
       T$SFRAME
       12
       SFRAME
       12
       T$PAGET
       256
       T$MINF
       10
       MSUBR
       4
       T$MSUBR
       4]>

<SETG TYPE-WORDS
      [UNBOUND
       0
       T$UNBOUND
       0
       FIX
       64
       CHARACTER
       128
       FLOAT
       192
       LIST
       257
       FALSE
       321
       DECL
       385
       STRING
       453
       MCODE
       518
       T$MCODE
       518
       VECTOR
       583
       MSUBR
       647
       T$MSUBR
       647
       IMSUBR
       *4007*
       T$IMSUBR
       *4007*
       FRAME
       706
       T$FRAME
       706
       LBIND
       770
       T$LBIND
       770
       ATOM
       834
       T$ATOM
       834
       OBLIST
       898
       T$OBLIST
       898
       GBIND
       962
       T$GBIND
       962
       FORM
       1025
       T$TYPE-C
       1088
       TYPE-C
       1088
       I$TERMIN
       1152
       SEGMENT
       1217
       T$DEFER
       1281
       DEFER
       1281
       T$FUNCTION
       1345
       FUNCTION
       1345
       T$MACRO
       1409
       MACRO
       1409
       T$CHANNEL
       1479
       CHANNEL
       1479
       I$SDTABLE
       2247
       I$DISK-CHANNEL
       2311
       T$MUD-CHAN
       2375
       MUD-CHAN
       2375
       T$TYPE-ENTRY
       1543
       ADECL
       1607
       T$OFFSET
       1671
       OFFSET
       1671
       T$LVAL
       1730
       LVAL
       1730
       T$GVAL
       1794
       GVAL
       1794
       T$LINK
       1858
       LINK
       1858
       T$TUPLE
       1927
       TUPLE
       1927
       T$UVECTOR
       1990
       UVECTOR
       1990
       T$TAT
       2183
       TAT
       2183
       T$PAGET
       1990						      ;"really UVECTOR"
       T$MINF
       1990							       ;"ditto"
       T$WORD
       2432
       WORD
       2432
       T$PCODE
       2502
       PCODE
       2502
       T$ZONE
       2567
       ZONE
       2567
       T$GC-PARAMS
       2630
       GC-PARAMS
       2630
       T$AREA
       2694
       AREA
       2694
       T$SFRAME
       2754
       SFRAME
       2754
       T$BYTES
       2820
       BYTES
       2820
       T$TYPE-W
       2880
       TYPE-W
       2880
       T$BITS
       3008
       BITS
       3008
       T$KIND-ENTRY
       *6007*
       KIND-ENTRY
       *6007*
       T$SPLICE
       *6101*
       SPLICE
       *6101*]>

<COND (<NOT <GASSIGNED? PEEP-ENABLED>> <SETG PEEP-ENABLED <>>)>

<COND (<NOT <GASSIGNED? LABEL-OBLIST>> <SETG LABEL-OBLIST <MOBLIST LB 0>>)>

<COND (<NOT <GASSIGNED? VICTIMS>> <SETG VICTIMS ()>)>

<COND (<NOT <GASSIGNED? SURVIVORS>> <SETG SURVIVORS ()>)>

<ENDBLOCK>

<COND (<NOT <GASSIGNED? WIDTH-MUNG>>
       <FLOAD "MIMOC20DEFS.MUD">
       <FLOAD "MSGLUE-PM.MUD">)>

<COND (<NOT <GASSIGNED? CONSTANT-TABLE>>
       <SETG CONSTANT-TABLE <IVECTOR ,CONSTANT-TABLE-LENGTH ()>>)>

<COND (<NOT <GASSIGNED? MV-TABLE>>
       <SETG MV-TABLE <IVECTOR ,MV-TABLE-LENGTH ()>>)>

<COND (<NOT <GASSIGNED? DEATH-TRQ>> <SETG DEATH-TRQ T>)>

<COND (<NOT <GASSIGNED? MIM-OBL>> <SETG MIM-OBL <LIST !.OBLIST>>)>

<COND (<NOT <GASSIGNED? NO-AC-FUNNYNESS>> <SETG NO-AC-FUNNYNESS <>>)>

<COND (<NOT <GASSIGNED? V1>> <SETG V1 <>>)>

<COND (<NOT <GASSIGNED? V2>> <SETG V2 <>>)>

<COND (<NOT <GASSIGNED? BOOT-MODE>> <SETG BOOT-MODE <>>)>

<COND (<NOT <GASSIGNED? INT-MODE>> <SETG INT-MODE <>>)>

<COND (<NOT <GASSIGNED? GC-MODE>> <SETG GC-MODE <>>)>

<COND (<NOT <GASSIGNED? GLUE-MODE>> <SETG GLUE-MODE <>>)>

<COND (<NOT <GASSIGNED? ACA-AC>> <SETG ACA-AC <>>)>

<COND (<NOT <GASSIGNED? NEXT-FLUSH>> <SETG NEXT-FLUSH 0>)>

<COND (<NOT <GASSIGNED? MAX-SPACE>> <SETG MAX-SPACE <>>)>

<COND (<NOT <GASSIGNED? SURVIVOR-MODE>> <SETG SURVIVOR-MODE <>>)>

<COND (<NOT <GASSIGNED? LIST-OF-FCNS>> <SETG LIST-OF-FCNS ()>)>

<SETG CB-LENGTH 512>

<SETG BUFL 1024>

<MANIFEST CB-LENGTH BUFL>

<USE "FILE-INDEX">

<COND (<NOT <GASSIGNED? CODE-BUFFER>>
       <SETG CODE-BUFFER <IUVECTOR ,CB-LENGTH 0>>
       <SETG ONE-WD ![0]>)>

<COND (<NOT <GASSIGNED? OUTPUT-BUFFER>>
       <SETG OUTPUT-BUFFER <ISTRING ,OUTPUT-LENGTH>>)>

<SETG CTLZ+1 <+ <SETG CTLZ 26> 1>>

<SETG MIM <==? <TYPEPRIM FIX> FIX>>

<COND (<GASSIGNED? CRLF-STRING!-INTERNAL>
       <SETG WORD-STRING <STRING ,CRLF-STRING!-INTERNAL "#WORD " <ASCII ,CTLZ>>>)>

<COND (,MIM <SETG PKG-OBL <CHTYPE PACKAGE OBLIST>>)
      (ELSE <SETG PKG-OBL <GETPROP PACKAGE OBLIST>>)>

<COND (<OR <NOT <ASSIGNED? READ-TABLE>> <L? <LENGTH .READ-TABLE> ,CTLZ+1>>
       <SETG READ-TABLE <SET READ-TABLE <IVECTOR ,CTLZ+1 <>>>>)>

<SETG FCN-OBL <MOBLIST FOO>>

<SETG FCN-OBL-L (,FCN-OBL)>

<DEFINE TERMIN-PRINT (TERMIN)
	#DECL ((TERMIN) I$TERMIN)
	<PRINC "#I$TERMIN ">
	<PRIN1 <CHTYPE .TERMIN FIX>>
	<PRINC !\ >>

<COND (<NOT <GASSIGNED? FOOSTR>> <SETG FOOSTR " ">)>

<GDECL (FOOSTR) STRING>

<DEFINE CHR-PRINT (CHR)
	#DECL ((CHR) CHARACTER)
	<COND (<G? <CHTYPE .CHR FIX> 127>
	       <PRINC "#CHARACTER ">
	       <PRIN1 <CHTYPE .CHR FIX>>)
	      (<PRINC  "!\\">
	       <PUT ,FOOSTR 1 .CHR>
	       <PRINC ,FOOSTR>)>>

<PRINTTYPE I$TERMIN ,TERMIN-PRINT>

<DEFINE ATOM-PRINT (ATM "AUX" (SPN <SPNAME .ATM>))
	#DECL ((ATM) ATOM (SPN) STRING)
	<COND (<AND <G=? <LENGTH .SPN> 2>
		    <==? <1 .SPN> !\T>
		    <==? <2 .SPN> !\$>>
	       <PRINC <REST .SPN 2>>
	       <OR ,BOOT-MODE <PRINC "!-">>)
	      (<AND <OR <==? <OBLIST? .ATM> <ROOT>>
			<MEMBER <SPNAME .ATM> ,ROOT-ATOMS>>
	            <NOT ,BOOT-MODE>>
	       <PRINC .SPN>
	       <PRINC "!-">)
	      (T <PRINC .SPN>)>
	<PRINC " ">>

<COND (<NOT <GASSIGNED? ROOT-ATOMS>>
       <SETG ROOT-ATOMS ["M$$BINDID" "M$$INT-LEVEL"]>)>

<GDECL (ROOT-ATOMS) <VECTOR [REST STRING]>>

<DEFINE T$UNBOUND-PRINT (UNB)
	#DECL ((UNB) T$UNBOUND)
	<PRINC "#UNBOUND ">
	<PRIN1 <CHTYPE .UNB FIX>>
	<PRINC !\ >>

<PRINTTYPE T$UNBOUND ,T$UNBOUND-PRINT>

<DEFINE XGLOC-PRINT (X)
	#DECL ((X) XGLOC)
	<COND (,BOOT-MODE
	       <PRIN1 <CHTYPE .X ATOM>>)
	      (<PRINC "%<GBIND ">
	       <PRIN1 <CHTYPE .X ATOM>>
	       <PRINC " T> ">)>>

<PRINTTYPE XGLOC ,XGLOC-PRINT>

<SET REDEFINE T>

<DEFINE XTYPE-C-PRINT  (X "AUX" ATM)
	#DECL ((X) XTYPE-C (ATM) ATOM)
	<SET ATM <CHTYPE .X ATOM>>
	<PRINC "%<TYPE-C ">
	<PRIN1 .ATM>
	<PRINC !\ >
	<COND (<==? <SET ATM <TYPEPRIM .ATM>> WORD>
	       <SET ATM FIX>)>
	<PRIN1 .ATM>
	<PRINC ">">>

<DEFINE XTYPE-W-PRINT  (X "AUX" ATM)
	#DECL ((X) XTYPE-W (ATM) ATOM)
	<SET ATM <CHTYPE .X ATOM>>
	<PRINC "%<TYPE-W ">
	<PRIN1 .ATM>
	<PRINC !\ >
	<COND (<==? <SET ATM <TYPEPRIM .ATM>> WORD>
	       <SET ATM FIX>)>
	<PRIN1 .ATM>
	<PRINC ">">>

<PRINTTYPE XTYPE-C ,XTYPE-C-PRINT>

<PRINTTYPE XTYPE-W ,XTYPE-W-PRINT>

<COND (<NOT <GASSIGNED? OPS>>
       <COND (<GASSIGNED? BLOAT> <BLOAT 100000 5000 100 1500>)>
       <FLOAD "<MIM.20C>OP.MUD">)
      (<GASSIGNED? BLOAT> <BLOAT 100000 5000 100 100>)>

<COND (<NOT <GASSIGNED? OPCODE>> <FLOAD "<MIM.20C>MIMOPS.MUD">)>

<GDECL (SURVIVORS INCHANS) LIST (OPT-LIST) <OR FALSE LIST>
       (THIS-GUY) <LIST ATOM <LIST [REST OBLIST]>>>

<DEFINE PROCESS-IFSYS (L) #DECL ((L) LIST)
	<REPEAT ((IFL ()) IFOBJ ITM (LP .L) (LL <REST .L>))
		#DECL ((IFL LP LL) LIST)
		<COND (<EMPTY? .LL> <RETURN>)>
		<COND (<AND <TYPE? <SET ITM <1 .LL>> FORM>
			    <MEMQ <SET IFOBJ <1 .ITM>>
				  '[IFSYS ENDIF IFCAN IFCANNOT]>>
		       <COND (<==? .IFOBJ IFSYS>
			      <COND (<=? <2 .ITM> "TOPS20">
				     <SET IFL (<2 .ITM> !.IFL)>
				     <PUTREST .LP <SET LL <REST .LL>>>)
				    (T
				     <PUTREST .LP <SET LL <FLUSH-TO-ENDIF
							   .LL  <2 .ITM>>>>)>)
			     (<OR <==? .IFOBJ IFCAN> <==? .IFOBJ IFCANNOT>>
			      <COND (<COND (<==? .IFOBJ IFCAN>
					    <LOOKUP <2 .ITM> ,MIMOC-OBLIST>)
					   (ELSE
					    <NOT <LOOKUP <2 .ITM> ,MIMOC-OBLIST>>)>
				     <SET IFL (<2 .ITM> !.IFL)>
				     <PUTREST .LP <SET LL <REST .LL>>>)
				    (T
				     <PUTREST .LP <SET LL <FLUSH-TO-ENDIF
							   .LL  <2 .ITM>>>>)>)
			     (T
			      <COND (<OR <EMPTY? .IFL> <N=? <2 .ITM> <1 .IFL>>>
				     <ERROR UNBALANCED-IFSYS!-ERRORS
					    <2 .ITM> .IFL>)
				    (ELSE
				     <SET IFL <REST .IFL>>)>
			      <PUTREST .LP <SET LL <REST .LL>>>)>
		       <AGAIN>)>
		<SET LL <REST <SET LP .LL>>>>>

<DEFINE FLUSH-TO-ENDIF (L FLG "AUX" THING (CT 1) FRST)
	#DECL ((L) LIST)
  <REPEAT ()
    <COND (<EMPTY? <SET L <REST .L>>>
	   <ERROR EOF-BEFORE-ENDIF!-ERRORS>
	   <RETURN>)>
    <SET THING <1 .L>>
    <COND (<TYPE? .THING FORM>
	   <COND (<==? <SET FRST <1 .THING>> ENDIF>
		  <COND (<0? <SET CT <- .CT 1>>> <RETURN <REST .L>>)>)
		 (<OR <==? .FRST IFSYS> <==? .FRST IFCAN> <==? .FRST IFCANNOT>>
		  <SET CT <+ .CT 1>>)>)>>>

<DEFINE GET-NM1 (STR "AUX" (SEEN-OP <>)) #DECL ((STR) STRING)
	<MAPF ,STRING <FUNCTION (CH) <COND (<==? .CH !\<> <SET SEEN-OP T>)
					   (<==? .CH !\>> <SET SEEN-OP <>>)
					   (<AND <NOT .SEEN-OP>
						 <==? .CH !\.>> <MAPSTOP>)
					   (ELSE .CH)>> .STR>>

<DEFINE FILE-MIMOC ("TUPLE" FILES "AUX" C OC (OUTCHAN .OUTCHAN)
		    (EXPFLOAD <AND <ASSIGNED? EXPFLOAD> .EXPFLOAD>)
		    F-OR-G (PREC <>) PRE-INDEX COMPILER-INPUT
		    (REDO <AND <ASSIGNED? REDO> .REDO>) ON
		    (PRECOMPILED <AND <ASSIGNED? PRECOMPILED> .PRECOMPILED>))
	#DECL ((FILES) <<PRIMTYPE VECTOR> [REST STRING]> (OUTCHAN) <SPECIAL ANY>
	       (PREC OC C) <OR FALSE CHANNEL> (COMPILER-INPUT) <SPECIAL CHANNEL>
	       (PRE-INDEX) <LIST [REST !<LIST ATOM FIX FIX>]>
	       (REDO) <LIST [REST ATOM]>)
	<COND (<AND <SET C <OPEN "READ" <1 .FILES>>>
		    <SET OC <OPEN "PRINT" <SET ON <STRING <GET-NM1 <1 .FILES>>
							  ".MSUBR">>>>
		    <OR <NOT .PRECOMPILED>
			<AND <SET PREC <OPEN "READ" .PRECOMPILED>>
			     <SET PRE-INDEX <BUILD-INDEX .PREC ,FCN-OBL>>
			     <OR <EMPTY? .REDO>
				 <MAPR <>
				   <FUNCTION (L "AUX" (SN <SPNAME <1 .L>>))
					<PUT .L 1
					     <OR <LOOKUP .SN ,FCN-OBL>
						 <INSERT .SN ,FCN-OBL>>>>
				   .REDO>>>>>
	       <SET COMPILER-INPUT .C>
	       <SETG INCHANS (.C)>
	       <SET FILES <REST .FILES>> 
	       <REPEAT (ATM (BUFFER <ISTRING ,BUFL>)) #DECL ((BUFFER) STRING)
	         <REPEAT ((IFL ()) NAME L NXT (END <>) ITM NM ACCESS-DATA
			  SPN HASH-CODE)
		   #DECL ((L) LIST (NAME) <SPECIAL ATOM> (NXT) FORM
			  (END) <SPECIAL <OR FALSE ATOM>> (HASH-CODE) WORD
			  (ACCESS-DATA) <LIST FIX FIX>)
		   <COND (<SET ITM <FINISH-FILE .C .OC .EXPFLOAD>>
			  <COND (<TYPE? .ITM FORM>
				 <COND (<AND <G=? <LENGTH .ITM> 2>
					     <TYPE? <SET ATM <2 .ITM>> ATOM>>
					<SET SPN <SPNAME .ATM>>
					<SET NM
					     <OR <LOOKUP .SPN ,FCN-OBL>
						 <INSERT .SPN ,FCN-OBL>>>)>
				 <SET NXT .ITM>)>)
			 (T
			  <SET END T>)>
		   <AND .END <RETURN>>
		   <SET C <1 ,INCHANS>>
		   <COND
		    (<TYPE? .ITM WORD> <SET HASH-CODE .ITM>)
		    (<AND .PREC
			   <NOT <MEMQ .NM .REDO>>
			   <MAPF <>
				 <FUNCTION (LL)
				     #DECL ((LL) !<LIST ATOM FIX FIX>)
				     <COND (<==? <1 .LL> .NM>
					    <SET ACCESS-DATA <REST .LL>>
					    <COND (<OR <L? <LENGTH .ACCESS-DATA> 3>
						       <NOT <ASSIGNED? HASH-CODE>>
						       <==? <3 .ACCESS-DATA>
							    .HASH-CODE>>
						   <MAPLEAVE>)
						  (ELSE <MAPLEAVE <>>)>)>>
				 .PRE-INDEX>>
		     <ACCESS .PREC <1 .ACCESS-DATA>>
		     <CRLF .OC>
		     <REPEAT ((NCHRS <- <2 .ACCESS-DATA> <1 .ACCESS-DATA>>))
			     #DECL ((NCHRS) FIX)
			     <COND (<L? .NCHRS ,BUFL>
				    <READSTRING .BUFFER .PREC .NCHRS>
				    <PRINTSTRING .BUFFER .OC .NCHRS>
				    <RETURN>)
				   (ELSE
				    <READSTRING .BUFFER .PREC ,BUFL>
				    <PRINTSTRING .BUFFER .OC ,BUFL>
				    <SET NCHRS <- .NCHRS ,BUFL>>)>>
		     <SKIP-MIMA .C .NM>)
		    (ELSE
		     <SET L (.NXT !<READ-LIST .C END '<SET END T>>)>
		     <COND (.END <CLOSE .C>)>
		     <SET F-OR-G <1 .NXT>>
		     <SET NAME <2 .NXT>>
		     <COND (,VERBOSE
			    <OR <==? .OUTCHAN ,OUTCHAN>
				<PRINC <ASCII 12>>>
			    <CRLF>
			    <PRINC "Open coding: ">
			    <PRIN1 .NAME>)>
		     <PROCESS-IFSYS .L>
		     <CALL-ANA .L>
		     <MIMOC .L>
		     <LOCATION-CHECK>
		     <FIXUP-ONE-GLUE <REST ,CODE> ,LABELS>
		     <ALLOCATE-CONSTANTS ,CONSTANT-VECTOR ,CODE-LENGTH>
		     <FIXUP-CONSTANTS <REST ,CODE>>
		     <WRITE-MSUBR .OC <> .F-OR-G>
		     <MAPF <>
			   <FUNCTION (LB) #DECL ((LB) LAB)
				<GUNASSIGN <REMOVE <LAB-NAM .LB>>>>
			   ,LABELS>)>
		   <AND .END <RETURN>>>
		 <COND (<EMPTY? .FILES>
			<RETURN>)>
		 <CLOSE .C>
		 <COND (<SET C <OPEN "READ" <1 .FILES>>>
			<SET FILES <REST .FILES>>
			<SETG INCHANS (.C)>)
		       (<ERROR .C FILE-MIMOC>)>>
	       <CLOSE .C>
	       <CLOSE .OC>
	       ,NULL)
	      (ELSE
	       <COND (<AND <ASSIGNED? C> .C>
		      <CLOSE .C>
		      <COND (<AND <ASSIGNED? OC> .OC>
			     <CLOSE .OC>
			     <DELFILE .ON>
			     <ERROR .PREC>)
			    (ELSE <ERROR .OC>)>)
		     (ELSE
		      <ERROR .C>)>)>>

<DEFINE FILE-GLUE ("TUPLE" FILES "AUX" C OC (TC <>) NMSTR (LEN 0) (FCN-COUNT 0)
		   MSUBR-ACCESS (LOWERSTR <>) (TFILES .FILES) TN (OUTCHAN .OUTCHAN)
		   (EXPFLOAD <AND <ASSIGNED? EXPFLOAD> .EXPFLOAD>) TOC PN ON TON
		   TFILE-LENGTH COMPILER-INPUT (OB ,OUTPUT-BUFFER))
	#DECL ((TFILES FILES) <<PRIMTYPE VECTOR> [REST STRING]> (OB) STRING
	       (OC TC C) <OR FALSE CHANNEL> (LEN MSUBR-ACCESS TFILE-LENGTH) FIX
	       (FCN-COUNT) FIX (LOWERSTR) <OR FALSE STRING>
	       (OUTCHAN) <SPECIAL ANY> (COMPILER-INPUT) <SPECIAL CHANNEL>)
	<COND (,SURVIVOR-MODE
	       <COND (<OR <NOT <ASSIGNED? READ-TABLE>>
			  <L? <LENGTH .READ-TABLE> ,CTLZ+1>>
		      <SETG READ-TABLE <SET READ-TABLE <IVECTOR ,CTLZ+1 <>>>>)>
	       <COND (<NOT <NTH .READ-TABLE ,CTLZ+1>>
		      <PUT .READ-TABLE
			   ,CTLZ+1
			   [<ASCII ,CTLZ> <ASCII !\A> <> <> <>]>)>)>
	<SETG GLUE-MODE T>
	<SETG PRE-LIST ()>
	<SETG PRE-NAMES ()>
	<SETG PRE-OPTS ()>
	<SETG GLUE-LIST ()>
	<SETG GLUE-PC 0>
	<SETG MVECTOR (T FOO FOO)>
	<MAPR <> <FUNCTION (B:<VECTOR LIST>) <PUT .B 1 ()>> ,MV-TABLE>
	<SETG MV-COUNT 0>
	<SETG FREE-CONSTS ()>
	<SETG CONSTANT-VECTOR ()>
	<MAPR <> <FUNCTION (B:<VECTOR LIST>) <PUT .B 1 ()>> ,CONSTANT-TABLE>
	<SETG FINAL-LOCALS ()>
	<SETG MV <REST ,MVECTOR 2>>
	<COND (<AND <SET C <OPEN "READ" <1 .FILES>>>
		    <SET OC <OPEN "PRINT" <SET ON <STRING <GET-NM1 <1 .FILES>>
						  ".MSUBR">>>>
		    <SET TOC <OPEN "PRINT" <SET TON <STRING <GET-NM1 <1 .FILES>>
							    ".TMSUBR">>>>
		    <OR <NOT ,MAX-SPACE>
			<SET TC <OPEN "PRINTB"
				      <SET TN <STRING <GET-NM1 <1 .FILES>>
						       ".MIMOCTEMP">>>>>>
	       <SETG INCHANS (.C)>
	       <SET COMPILER-INPUT .C>
	       <SET FILES <REST .FILES>>
	       <REPEAT () 
	         <REPEAT (NAME ITM TMP SPN L X)
		       #DECL ((NAME) ATOM (ITM) <OR <FORM ANY> FALSE>)
		       <COND (<SET ITM <FINISH-FILE .C <> .EXPFLOAD>>
			      <SET C <1 ,INCHANS>>
			      <SET FCN-COUNT <+ .FCN-COUNT 1>>
			      <COND (<AND ,SURVIVOR-MODE
					  <==? <1 <SET SPN <SPNAME <2 .ITM>>>>
					       <ASCII ,CTLZ>>>
				     <SET SPN <REST .SPN>>
				     <SET NAME <OR <LOOKUP .SPN ,FCN-OBL>
						   <INSERT .SPN ,FCN-OBL>>>
				     <PUT .ITM 2 .NAME>
				     <COND (<MAPF <>
						  <FUNCTION (X:<LIST ATOM LIST>)
						       <COND (<AND <==? <1 .X>
									.NAME>
								   <=? <2 .X>
								       .OBLIST>>
							      <MAPLEAVE>)>>
						  ,LIST-OF-FCNS>)
					   (ELSE
					    <SETG LIST-OF-FCNS
						  ((.NAME <LIST !.OBLIST>)
						   !,LIST-OF-FCNS)>)>)
				    (ELSE
				     <SET NAME <2 .ITM>>)>
			      <COND
			       (<NOT .LOWERSTR>
				<SET LOWERSTR
				 <MAPF ,STRING
				  <FUNCTION (CHR "AUX" (I <ASCII .CHR>))
				    #DECL ((CHR) CHARACTER)
				    <COND (<AND <L=? .I <ASCII !\Z>>
						<G=? .I <ASCII !\A>>>
					   <ASCII <+ .I 32>>)
					  (.CHR)>>
				  <SPNAME .NAME>>>)>
			      <COND
			       (<==? <1 .ITM> GFCN>
				<COND (<EMPTY? ,PRE-NAMES>
				       <PUT ,MVECTOR 2 .NAME>)>
				<SETG PRE-NAMES (.NAME !,PRE-NAMES)>
				<COND (<MEMBER "TUPLE" <3 .ITM>>
				       <SETG PRE-OPTS
					     (.NAME <> !,PRE-OPTS)>)
				      (<MEMBER "OPTIONAL" <3 .ITM>>
				       <SET TMP <READ .C>>
				       <MAPR <>
					     <FUNCTION (TP)
						  #DECL ((TP) <LIST ATOM>)
						  <PUT .TP 1
						       <GENLBL
							<STRING <SPNAME <1 .TP>>
								<SPNAME .NAME>>>>>
					     <REST <CHTYPE .TMP LIST> 3>>
				       <SETG PRE-OPTS
					     (.NAME .TMP  !,PRE-OPTS)>)>)>
			      <SET L <READ-LIST .C END '<ERROR EOF!-ERRORS>>>
			      <COND (<N==? <1 .ITM> GFCN> <AGAIN>)>
			      <MAPF <>
				    <FUNCTION (ITM "AUX" OP)
					 <COND
					  (<TYPE? .ITM FORM>
					   <COND
					    (<OR <==? <SET OP <1 .ITM>> BIND>
						 <==? .OP BBIND>
						 <AND <OR <==? .OP TUPLE>
							  <==? .OP ADJ>>
						      <NOT <TYPE? <2 .ITM> FIX>>>
						 <AND <MEMQ .OP
							    '[CALL SCALL ACALL
							      UBLOCK SBLOCK
							      USBLOCK LIST]>
						      <NOT <TYPE? <3 .ITM> FIX>>>>
					     <PUTPROP ,PRE-NAMES NDFRM T>
					     <MAPLEAVE>)>)>>
				    .L>)
			     (ELSE <RETURN>)>>
		 <CLOSE .C>
		 <COND (<EMPTY? .FILES>
			<RETURN>)>
		 <COND (<SET C <OPEN "READ" <1 .FILES>>>
			<SETG INCHANS (.C)>
			<SET FILES <REST .FILES>>)
		       (<ERROR .C FILE-GLUE>)>>
	       <DETERMINE-VICTIMS>
	       <SET FILES .TFILES>
	       <PUT .READ-TABLE ,CTLZ+1 <>>
	       <COND (<SET C <OPEN "READ" <1 .FILES>>>
		      <SETG INCHANS (.C)>
		      <SET FILES <REST .FILES>>)
		     (<ERROR .C FILE-GLUE>)>
	       <REPEAT GLOOP (NAME L (NXT <>) (END <>) ITM (FCN-FOUND 0)
			(FIRST T) MSBASE (IFL ()))
		   #DECL ((L) LIST (NAME) <SPECIAL ATOM> (NXT) <OR FALSE FORM>
			  (END) <SPECIAL <OR FALSE ATOM>>
			  (ITM) ANY (FCN-FOUND) FIX (IFL MSBASE) LIST)
		   <REPEAT ()
			   <COND (<SET ITM <FINISH-FILE .C .TOC .EXPFLOAD>>
				  <SET C <1 ,INCHANS>>
				  <SET FCN-FOUND <+ .FCN-FOUND 1>>
				  <RETURN <SET NXT .ITM>>)
				 (T
				  <CLOSE .C>
				  <COND (<EMPTY? .FILES>
					 <RETURN T .GLOOP>)>
				  <COND (<SET C <OPEN "READ" <1 .FILES>>>
					 <SETG INCHANS (.C)>
					 <SET FILES <REST .FILES>>)
					(<ERROR .C FILE-GLUE>)>)>>
		   <SET L (.NXT !<READ-LIST .C END '<SET END T>>)>
		   <COND (.END <CLOSE .C>)>
		   <COND (,VERBOSE
			  <OR <==? .OUTCHAN ,OUTCHAN>
			      <PRINC <ASCII 12>>>
			  <CRLF>
			  <PRINC "Open coding: ">
			  <PRIN1 <SET NAME <2 .NXT>>>)
			 (ELSE
			  <SET NAME <2 .NXT>>)>
		   <PROCESS-IFSYS .L>
		   <CALL-ANA .L>
		   <MIMOC .L <AND ,SURVIVOR-MODE
				  <SET PN <FIND-CALL .NAME ,PRE-NAMES>>
				  <NOT <GETPROP .PN NDFRM>> 
				  <NOT <FIND-OPT .NAME ,PRE-OPTS>>
				  <NOT <SURVIVOR? .NAME>>>>
		   <UNASSIGN NAME>
		   <LOCATION-CHECK>
		   <COND (,MAX-SPACE
			  <PRINTTYPE LOCAL-NAME ,PRINT>
			  <PRINTTYPE CONSTANT-LABEL ,PRINT>
			  <FIXUP-ONE-GLUE <REST ,CODE> ,LABELS>
			  <FIXUP-CONSTANTS <REST ,CODE> ()>
			  <DUMP-CODE ,CODE .TC>
			  <PRINTTYPE LOCAL-NAME ,PLOCAL-NAME>
			  <PRINTTYPE CONSTANT-LABEL ,PCONST-LABEL>)>
		   <MAPF <>
			 <FUNCTION (LB) #DECL ((LB) LAB)
			      <LAB-STATE .LB ()>
			      <LAB-FINAL-STATE .LB <>>
			      <LAB-DEAD-VARS .LB ()>
			      <LAB-CODE-PNTR .LB ()>
			      <REMOVE <LAB-NAM .LB>>>
			 ,LABELS>
		   <SETG GLUE-LIST (<SET MSBASE
				     (,GLUE-NAME
				      ,GLUE-DECL
				      ,GLUE-PC
				      <COND (,MAX-SPACE ()) (ELSE ,CODE)>
				      ,LABELS
				      ,GREFS
				      ,GCALS)>
				    !,GLUE-LIST)>
		   <COND (.FIRST
			  <SET FIRST <>>
			  <SET MSUBR-ACCESS <DO-ACCESS .TOC>>)>
		   <COND (<OR <NOT ,SURVIVOR-MODE>
			      <SURVIVOR? <1 .MSBASE>>>
			  <PRINT-ENTRY .MSBASE .TOC .LOWERSTR>)>
		   <SETG GLUE-PC <+ ,GLUE-PC ,CODE-LENGTH>>
		   <COND (<==? .FCN-COUNT .FCN-FOUND>
			  <RETURN>)>>
	       <ALLOCATE-CONSTANTS ,CONSTANT-VECTOR  ,GLUE-PC>
	       <CLOSE .TOC>
	       <SET TFILE-LENGTH <- <FILE-LENGTH <SET TOC <OPEN "READ" .TON>>>
				    .MSUBR-ACCESS>>
	       <REPEAT ((BUFSTR <ISTRING 1024>))
		       <COND (<L? .MSUBR-ACCESS 1024>
			      <SET BUFSTR
				   <REST .BUFSTR <- 1024 .MSUBR-ACCESS>>>)>
		       <COND (<NOT <EMPTY? .BUFSTR>>
			      <READSTRING .BUFSTR .TOC>
			      <PRINTSTRING .BUFSTR .OC>)>
		       <COND (<L=? <SET MSUBR-ACCESS <- .MSUBR-ACCESS 1024>> 0>
			      <RETURN>)>>
	       <COND (.TC
		      <CLOSE .TC>
		      <SET TC <OPEN "READB" .TN>>
		      <COND (,VERBOSE
			     <PRINC "
Doing fixup and output
">)>
		      <SET NMSTR <WRITE-MSUBR .OC .LOWERSTR>>
		      <MAPF <>
			    <FUNCTION (FROB "AUX" (CODE <READ-CODE .TC>))
				 #DECL ((FROB) <LIST ATOM LIST FIX LIST LIST>
					(CODE) UVECTOR)
				 <MAPF <>
				       <FUNCTION (X) #DECL ((X) <LIST FIX>)
					   <PUT .CODE
						<1 .X>
						<CHTYPE <ORB <NTH .CODE <1 .X>>
							     <GFIND <2 .X> <3 .X>>>
							FIX>>>
				       <CHTYPE <7 .FROB> LIST>>
				 <MAPF <>
				       <FUNCTION (X)
					    #DECL ((X) <LIST FIX CONSTANT-BUCKET>)
					    <PUT .CODE
						 <1 .X>
						 <ORB <NTH .CODE <1 .X>>
						      <CB-LOC <2 .X>>>>>
				       <6 .FROB>>
				 <MAPF <>
				       <FUNCTION (WRD)
					   <REPEAT ((I 4)) #DECL ((I) FIX)
						   <PRINTBYTE
						        <SET WRD 
							     <CHTYPE
							      <ROT .WRD 9> FIX>>>
						   <COND (<==? <SET I <- .I 1>> 0>
							  <RETURN>)>>>
				       .CODE>
				 <SET LEN <+ <LENGTH .CODE> .LEN>>>
			    ,GLUE-LIST>
		      <CLOSE .TC>
		      <DELFILE .TN>
		      <SETG MAX-SPACE <>>
		      <WRITE-CODE .OC .NMSTR () .OB .LEN>
		      <AND ,INT-MODE <PRINTTYPE ATOM ,PRINT>>
		      <REPEAT ((BUFSTR <ISTRING 1024>))
			      #DECL ((BUFSTR) STRING)
			      <COND (<L? .TFILE-LENGTH 1024>
				     <SET BUFSTR
					  <REST .BUFSTR <- 1024 .TFILE-LENGTH>>>)>
			      <READSTRING .BUFSTR .TOC>
			      <PRINTSTRING .BUFSTR .OC>
			      <COND (<L? <SET TFILE-LENGTH
					      <- .TFILE-LENGTH  1024>> 0>
				     <RETURN>)>>
		      <FINISH-FILE .C .OC .EXPFLOAD>
		      <CLOSE .OC>)
		     (ELSE
		      <COND (,VERBOSE
			     <PRINC "
Fixing Up CALLs
">)>
		      <GLUE-FIXUP>
		      <COND (,VERBOSE
			     <PRINC "Writing MSUBR
">)>
		      <WRITE-MSUBR .OC .LOWERSTR>
		      <REPEAT ((BUFSTR <ISTRING 1024>))
		       #DECL ((BUFSTR) STRING)
		       <COND (<L? .TFILE-LENGTH 1024>
			      <SET BUFSTR
				   <REST .BUFSTR <- 1024 .TFILE-LENGTH>>>)>
		       <READSTRING .BUFSTR .TOC>
		       <PRINTSTRING .BUFSTR .OC>
		       <COND (<L? <SET TFILE-LENGTH
				       <- .TFILE-LENGTH  1024>> 0>
			      <RETURN>)>>
	       <FINISH-FILE .C .OC .EXPFLOAD>
	       <CLOSE .C>
	       <CLOSE .OC>)>
	       <CLOSE .TOC>
	       <DELFILE .TON>
	       ,NULL)
	      (ELSE
	       <COND (<AND <ASSIGNED? C> .C>
		      <CLOSE .C>
		      <COND (<AND <ASSIGNED? OC> .OC>
			     <CLOSE .OC>
			     <DELFILE .ON>
			     <ERROR .TC>)
			    (ELSE <ERROR .OC>)>)
		     (ELSE
		      <ERROR .C>)>)>>

<DEFMAC DO-ACCESS ('CH)
	<COND (<GASSIGNED? M-HLEN> <FORM ACCESS .CH>)
	      (ELSE <FORM 17 .CH>)>>

<DEFINE SURVIVOR? (A "AUX" (SP <SPNAME .A>) (VL ,VICTIMS)) 
	#DECL ((VL) LIST)
	<NOT <OR <MEMQ .A .VL>
		 <MEMBER .SP .VL>
		 <MAPF <>
		       <FUNCTION (OBJ) 
			       <COND (<AND <TYPE? .OBJ LIST>
					   <=? <1 .OBJ> .SP>
					   <MEMQ <OBLIST? .A>
						 <CHTYPE <2 .OBJ> LIST>>>
				      <MAPLEAVE>)>>
		       .VL>>>>

<DEFMAC CHTYPE-OBLIST ('O)
	<COND (<GASSIGNED? M-HLEN> <FORM CHTYPE .O ATOM>)
	      (ELSE <FORM GETPROP .O OBLIST>)>>

<DEFINE DETERMINE-VICTIMS ("AUX" (VL ()) (LOF ,LIST-OF-FCNS))
	#DECL ((VL LOF AO) LIST)
	<MAPF <>
	      <FUNCTION (LL "AUX" (A <1 .LL>) (SP <SPNAME .A>) O (PP <>)
				  PO)
		   #DECL ((LL) !<LIST ATOM LIST>)
		   <COND (<OR <EMPTY? ,PRE-NAMES>
			      <MAPR <>
				    <FUNCTION (PN "AUX" (NM <1 .PN>))
					 #DECL ((PN) LIST)
					 <COND (<=? <SPNAME .NM> .SP>
						<SET PP .PN>
						<MAPLEAVE <>>)
					       (ELSE T)>>
				    ,PRE-NAMES>
			      <AND ,INT-MODE
				   <OR <L? <LENGTH .SP> 2>
				       <NOT <AND <==? <1 .SP> !\I>
						 <==? <2 .SP> !\$>>>>>
			      <AND <SET O <OBLIST? .A>>
				   <SET O <OBLIST? <CHTYPE-OBLIST .O>>> 
				   <OR <==? .O ,PKG-OBL> <==? .O <ROOT>>>>
			      <MAPF <>
				    <FUNCTION (NM)
					 <COND (<AND <=? <SPNAME .NM> .SP>
						     <MEMQ <OBLIST? .NM> <2 .LL>>>
						<MAPLEAVE T>)>>
				    ,SURVIVORS>>)
			 (<NOT <MAPF <>
				<FUNCTION (O)
				     <COND (<LOOKUP .SP .O> <MAPLEAVE>)>>
				<2 .LL>>>
			  <SET VL ((.SP <2 .LL>) !.VL)>)>
		   <COND (.PP
			  <PUT .PP 1 <OR <MAPF <>
					       <FUNCTION (O "AUX" AA)
						    <COND (<SET AA
								<LOOKUP .SP
									.O>>
							   <MAPLEAVE .AA>)>>
					       <2 .LL>>
					 <INSERT .SP <1 <2 .LL>>>>>
			  <COND (<SET PO <MEMQ .A ,PRE-OPTS>>
				 <PUT .PO 1 <1 .PP>>)>)>>
	      .LOF>
	<SETG VICTIMS (!,VICTIMS !.VL)>
	<SETG FIRST-PASS-SURVIVOR-GLUE <>>>

<GDECL (GLUE-LIST) <LIST [REST LIST]>>

<DEFINE PRINT-ENTRY (MSBASE OUTCHAN LOWERSTR)
  #DECL ((MSBASE) LIST (OUTCHAN) CHANNEL)
  <COND (,INT-MODE <PRINTTYPE ATOM ,ATOM-PRINT>)>
  <WIDTH-MUNG .OUTCHAN 100000000>
  <PRINC "<SETG " .OUTCHAN>
  <PRIN1 <1 .MSBASE> .OUTCHAN>
  <PRINC " #MSUBR [" .OUTCHAN>
  <PRINC .LOWERSTR .OUTCHAN>
  <COND (,INT-MODE <PRINC "!-IMSUBR!- " .OUTCHAN>)
	(ELSE <PRINC "-IMSUBR " .OUTCHAN>)>
  <PRIN1 <1 .MSBASE> .OUTCHAN>
  <PRINC !\  .OUTCHAN>
  <PRIN1 <2 .MSBASE> .OUTCHAN>
  <PRINC !\  .OUTCHAN>
  <PRIN1 <3 .MSBASE> .OUTCHAN>
  <PRINC "]>" .OUTCHAN>
  <CRLF .OUTCHAN>
  <COND (,INT-MODE <PRINTTYPE ATOM ,PRINT>)>
  <WIDTH-MUNG .OUTCHAN 80>>

<DEFINE FINISH-FILE (INCHAN OUTCHAN EXPFLOAD "OPTIONAL" END?
		     (EVAL? T) "AUX" (IND '(1)) (WORD-OK? <>))
  #DECL ((INCHAN) CHANNEL (OUTCHAN) <OR CHANNEL FALSE>
	 (END?) <VECTOR [REST ATOM]> (EXPFLOAD EVAL?) <OR ATOM FALSE>)
  <COND (<NOT <ASSIGNED? END?>>
	 <SET WORD-OK? T>
	 <SET END? '[FCN GFCN]>)>
  <REPEAT (ITM NCH)
    <COND (<==? <SET ITM <READ .INCHAN '.IND>> .IND>
	   <CLOSE .INCHAN>
	   <COND (<EMPTY? <SETG INCHANS <REST ,INCHANS>>>
		  <RETURN <>>)>
	   <SET INCHAN <1 ,INCHANS>>
	   <AGAIN>)>
    <COND (<NOT <OR <TYPE? .ITM STRING CHARACTER FIX>
		    <AND <TYPE? .ITM ATOM>
			 <=? <SPNAME .ITM> "">>>>
	   <COND (<AND <TYPE? .ITM FORM>
		       <NOT <EMPTY? .ITM>>
		       <MEMQ <1 .ITM> .END?>>
		  <RETURN .ITM>)
		 (<AND .WORD-OK? <TYPE? .ITM WORD>>
		  <COND (<OR ,INT-MODE ,BOOT-MODE ,GLUE-MODE> <AGAIN>)>
		  <COND (.OUTCHAN
			 <PRINC ,WORD-STRING .OUTCHAN>
			 <PRIN-OCT <CHTYPE .ITM FIX> .OUTCHAN>
			 <CRLF .OUTCHAN>)>
		  <RETURN .ITM>)>
	   <COND (<AND .EXPFLOAD
		       <TYPE? .ITM FORM>
		       <NOT <EMPTY? .ITM>>
		       <COND (<==? <1 .ITM> FLOAD>
			      <SET NCH <OPEN "READ" !<REST .ITM>>>)
			     (<==? <1 .ITM> L-FLOAD>
			      <SET NCH <L-OPEN <2 .ITM>>>)>>
		  <SET INCHAN .NCH>
		  <SETG INCHANS (.NCH !,INCHANS)>)
		 (T
		  <COND (.EVAL?
			 <PROG (SG AZ TMP)
			       <COND (<AND <TYPE? .ITM FORM>
					    <NOT <EMPTY? .ITM>>
					    <MEMQ <1 .ITM>
						  '[INCLUDE-WHEN USE-WHEN]>
					    <NOT <EMPTY? <REST .ITM>>>
					    <TYPE? <SET TMP <2 .ITM>> FORM>
					    <NOT <EMPTY? .TMP>>
					    <==? <1 .TMP> COMPILING?>>
				       <EVAL .ITM>
				       <PUT .TMP 1 DEBUGGING?>)
				      (ELSE
				       <EVAL .ITM>)>>)>
		  <COND (.OUTCHAN
			 <COND (,INT-MODE <PRINTTYPE ATOM ,ATOM-PRINT>)>
			 <PRINTTYPE CHARACTER ,CHR-PRINT>
			 <WIDTH-MUNG .OUTCHAN 100000>
			 <PRIN1 .ITM .OUTCHAN>
			 <CRLF .OUTCHAN>
			 <WIDTH-MUNG .OUTCHAN 80>
			 <COND (,INT-MODE <PRINTTYPE ATOM ,PRINT>)>
			 <PRINTTYPE CHARACTER ,PRINT>)>)>)>>>

<DEFINE PRIN-OCT (X CH)
	#DECL ((X) FIX)
	<PRINC !\* .CH>
	<COND (<0? .X> <PRINC !\0 .CH>)
	      (ELSE <POCT .X .CH>)>
	<PRINC !\* .CH>>

<DEFINE POCT (X CH) #DECL ((X) FIX)
	<COND (<N==? .X 0>
	       <POCT <LSH .X -3> .CH>
	       <PRINC <ASCII <+ <ANDB .X 7> <ASCII !\0>>> .CH>)>>


<GDECL (SUBRIFIED-PKGS SUBRIFIED-MSUBRS) <LIST [REST ATOM]>>

<DEFINE SUBRIFY? (NAME "AUX" (OBL <OBLIST? .NAME>) MS OO)
	<COND (<AND <GASSIGNED? .NAME>
		    <TYPE? <SET MS ,.NAME> MSUBR>
		    <OR <AND .OBL
			     <OR <==? <SET OO <OBLIST? <CHTYPE .OBL ATOM>>>
				      #OBLIST PACKAGE>
				 <AND <==? <OBLIST? <CHTYPE .OO ATOM>>
					   #OBLIST PACKAGE>
				      <SET OBL .OO>>>
			     <MEMQ <CHTYPE .OBL ATOM> ,SUBRIFIED-PKGS>>
			<MEMQ .NAME ,SUBRIFIED-MSUBRS>>>
	       <CHTYPE [.NAME
			<REPEAT ((DCL:LIST <REST <3 .MS> 2>) (CNT:FIX 0) IT)
				<COND (<EMPTY? .DCL> <RETURN .CNT>)>
				<COND (<NOT <TYPE? <SET IT <1 .DCL>> STRING>>
				       <SET CNT <+ .CNT 1>>)
				      (<MEMQ .IT '["OPT" "OPTIONAL" "TUPLE"]>
				       <RETURN <>>)>
				<SET DCL <REST .DCL>>>] SUBR-INFO>)>>

<DEFINE PRINT-SUBR-INFO (S:SUBR-INFO)
	<PRINC "%<SUBR-ENTRY ">
	<PRIN1 <1 .S>>
	<PRINC ">">>

<COND (<GASSIGNED? PRINT-SUBR-INFO>
       <PRINTTYPE SUBR-INFO ,PRINT-SUBR-INFO>)>