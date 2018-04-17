<PACKAGE "DEATH">
"VERSION 1.4"

"This version written by CLR 2/85 based entirely on SAMs previous version.
 The differences are:

	a)	Bit masks used instead of lists of names for efficiency.

	b)	Attempt to flush dead SETs.

There are two interesting structures:

	1)	Each temp atom's value is a uvector of fixes.
			The first element is its number (starting at 0)
			and increasing so each temp has a number.

			The rest of the elements are essentially constitute
			a string of 1 bit bytes big enough for the total
			number of temps.  The bit being on indicates a temp
			that can't be merged with this one.

	2)	The lists of live variables associated with branches is
		also the same kind of bit string."



<ENTRY REMOVE-DEADS FIXUP-DEATH DEBUG-DEATH MAINTAIN-DECLS>

<USE "NEWSTRUC">

<SETG DEBUG-DEATH %<>>
<SETG MAINTAIN-DECLS %<>>

"NAME-UV is a vector of temp names.  It is used to get from a number back to
 the name of a temp.  NOTE:  temp values start at 0 so 1 always must be added
 to index into this vector."

<GDECL (NAME-UV) <VECTOR [REST ATOM]> (UVSIZE) FIX>

<NEWTYPE DEAD-VAR ATOM>

<NEWSTRUC LABEL		VECTOR
	  L-INST	<OR ATOM FORM>
	  L-INS		<LIST [REST FIX]>
	  L-LEVEL	FIX
	  L-ASSIGN	<OR FALSE <LIST [REST !<LIST ATOM FIX>]>>>

<NEWSTRUC BRANCH	VECTOR
	  B-INST	FORM
	  B-OUTS	<LIST [REST FIX]>
	  B-LIVES	UVECTOR
	  B-FALL-DEADS	UVECTOR
	  B-JUMP-DEADS	<OR FALSE UVECTOR>>


<DEFMAC /32 ('X) <FORM LSH .X -5>>

<DEFINE FIXUP-DEATH (CODE:LIST "AUX" (OUTCHAN .OUTCHAN))
   <COND (,DEBUG-DEATH
	  <PRINTSTRING "Fixup-death: " .OUTCHAN>
	  <PRIN1 <2 <1 .CODE>:FORM> .OUTCHAN>
	  <CRLF .OUTCHAN>
	  <PRINTSTRING "Removing deads" .OUTCHAN>
	  <CRLF .OUTCHAN>)>
   <SETG ANY-FLUSHED-INS <>>
   <BIND ((CODELEN:FIX <REMOVE-DEADS .CODE>)
	  (VCODE:<SPECIAL VECTOR> <IVECTOR .CODELEN>) (VC:VECTOR .VCODE) 
	  LOOP-LABELS:<LIST [REST LABEL]>)
      <MAPF <>
	    <FUNCTION (X)
		 <COND (<AND <TYPE? .X FORM>
			     <NOT <EMPTY? .X>>
			     <==? <1 .X> `ENDIF>>
			<PUT .VC 1 .X> ;"Note:  ENDIFs go in twice!"
			<SET VC <REST .VC>>)>
		 <PUT .VC 1 .X>
		 <SET VC <REST .VC>>>
	    .CODE>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "Preparing labels and temps" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <SET LOOP-LABELS <PREPARE-LABELS-AND-TEMPS .VCODE>>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "Preparing branches" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <PREPARE-BRANCHES .VCODE 1 .CODELEN .CODELEN ()>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "Backwalking" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <REPEAT ((LEVEL 1))
	 <COND (,DEBUG-DEATH
		<PRINTSTRING "Pass " .OUTCHAN>
		<PRIN1 .LEVEL .OUTCHAN>
		<CRLF .OUTCHAN>)>
	 <SETG SOMETHING-CHANGED %<>>
	 <BACKWALK-FROM-LABEL .VCODE <NTH .VCODE .CODELEN> .LEVEL>
	 <MAPF %<>
	       <FUNCTION (LABEL:LABEL)
		  <BACKWALK-FROM-LABEL .VCODE .LABEL .LEVEL>>
	       .LOOP-LABELS>
	 <COND (<NOT ,SOMETHING-CHANGED>
		<RETURN>)>
	 <SET LEVEL <+ .LEVEL 1>>>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "SET optimization" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <OPTIMIZE-SETS .VCODE>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "General optimization" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <OPTIMIZE-TEMPS .VCODE>
      ;"This pass never seems to find anything it can merge."
      <COND (<NOT ,MAINTAIN-DECLS>
	     <COND (,DEBUG-DEATH
		    <PRINTSTRING "Optional optimization pass (ignoring decls)"
				 .OUTCHAN>
		    <CRLF .OUTCHAN>)>
	     <OPTIMIZE-TEMPS/BASH-DECLS .VCODE>)>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "Preparing deads" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <PREPARE-DEADS-FROM-LABEL .VCODE <NTH .VCODE .CODELEN>>
      <MAPF %<>
	    <FUNCTION (LABEL:LABEL)
	       <PREPARE-DEADS-FROM-LABEL .VCODE .LABEL>>
	    .LOOP-LABELS>
      <COND (,DEBUG-DEATH
	     <PRINTSTRING "Inserting deads" .OUTCHAN>
	     <CRLF .OUTCHAN>)>
      <INSERT-DEADS .CODE .VCODE>>
   <COND (,DEBUG-DEATH
	  <PRINTSTRING "Death complete: " .OUTCHAN>
	  <PRIN1 <2 <1 .CODE>:FORM> .OUTCHAN>
	  <CRLF .OUTCHAN>)>
   ,ANY-FLUSHED-INS>

"ADD-LIST ORs a bit into a uvector.  In the old world it addes an atom to
 a LIST."

<DEFINE ADD-LIST (ATM:ATOM L:UVECTOR "VALUE" UVECTOR
		  "AUX" (NUM:FIX <1 <GVAL .ATM>:UVECTOR>)
			(WD:FIX <+ </32 .NUM> 1>) (BIT:FIX <MOD .NUM 32>))
	<PUT .L .WD <ORB <NTH .L .WD> <LSH 1 .BIT>>>>

"ADD-LIST? same as ADD-LIST except returns #FALSE () if already there."

<DEFINE ADD-LIST? (ATM:ATOM L:UVECTOR "VALUE" <OR FALSE UVECTOR>
		   "AUX" (NUM:FIX <1 <GVAL .ATM>:UVECTOR>) TEM:FIX
			 (WD:FIX <+ </32 .NUM> 1>) (BIT:FIX <MOD .NUM 32>))
	<COND (<==? <ANDB <SET TEM <NTH .L .WD>> <SET BIT <LSH 1 .BIT>>> 0>
	       <PUT .L .WD <ORB .TEM .BIT>>)>>

"REM-LIST kill a bit in the uvector same way as ADD-LIST."

<DEFINE REM-LIST (ATM:ATOM L:UVECTOR
		  "AUX" (NUM:FIX <1 <GVAL .ATM>:UVECTOR>)
			(WD:FIX <+ </32 .NUM> 1>) (BIT:FIX <MOD .NUM 32>))
	<PUT .L .WD <ANDB <NTH .L .WD>  <ROT <XORB 1 -1> .BIT>>>>

"REM-LIST? return false if not there, else remove it and return true"

<DEFINE REM-LIST? (ATM:ATOM L:UVECTOR
		   "AUX" (NUM:FIX <1 <GVAL .ATM>:UVECTOR>) TEM:FIX
			 (WD:FIX <+ </32 .NUM> 1>) (BIT:FIX <MOD .NUM 32>))
	<SET BIT <LSH 1 .BIT>>
	<COND (<N==? <ANDB <SET TEM <NTH .L .WD>> .BIT> 0>
	       <PUT .L .WD <XORB .TEM .BIT>>)>>

"IN-LIST? see if bit is on"

<DEFINE IN-LIST? (ATM:ATOM L:UVECTOR "VALUE" <OR FALSE UVECTOR>
		  "AUX" (NUM:FIX <1 <GVAL .ATM>:UVECTOR>)
			(WD:FIX <+ </32 .NUM> 1>) (BIT:FIX <MOD .NUM 32>))
	<COND (<==? <ANDB <NTH .L .WD> <LSH 1 .BIT>> 0> <>)
	      (ELSE .L)>>

<DEFINE INTERSECT-LISTS (L1:<LIST [REST ATOM]> L2:<LIST [REST ATOM]>)
   ;"I know this isn't the most efficient way, but I'm too tired to figure
     it out now, and it doesn't get called much."
   <MAPF ,LIST
	 <FUNCTION (A1:ATOM)
	    <COND (<MEMQ .A1 .L2> <MAPRET .A1>)
		  (ELSE <MAPRET>)>>
	 .L1>>

<DEFINE ATOM-PART (TEMP:<OR ATOM ADECL LIST> "VALUE" ATOM)
   <COND (<TYPE? .TEMP ATOM> .TEMP)
	 (<TYPE? .TEMP ADECL> <1 .TEMP>)
	 (ELSE <ATOM-PART <1 .TEMP>>)>>

<DEFINE DECL-PART (TEMP:<OR ATOM ADECL LIST>)
   <COND (<TYPE? .TEMP ATOM> %<>)
	 (<TYPE? .TEMP ADECL> <2 .TEMP>)
	 (ELSE <DECL-PART <1 .TEMP>>)>>

<DEFINE INST-PART (INST)
   <COND (<TYPE? .INST BRANCH> <B-INST .INST>)
	 (<TYPE? .INST LABEL> <L-INST .INST>)
	 (ELSE .INST)>>

;"REMOVE-DEADS also counts number of ins (and one extra per ENDIF)"

<DEFINE REMOVE-DEADS (CODE:LIST)
   <REPEAT ((RCODE:LIST <REST .CODE>) INST OP (CODE-SIZE:FIX 1))
      <COND (<EMPTY? .RCODE> <RETURN .CODE-SIZE>)>
      <SET INST <1 .RCODE>>
      <COND (<AND <TYPE? .INST FORM>
		  <NOT <EMPTY? .INST>>
		  <KILL-FUNNY-DEADS .INST>
		  <COND (<==? <SET OP <1 .INST>> `DEAD>
			 <PUTREST .CODE <SET RCODE <REST .RCODE>>>
			 T)
			(<==? .OP `ENDIF>
			 <SET CODE-SIZE <+ .CODE-SIZE 1>>
			 <>)>>)
	    (ELSE
	     <SET CODE-SIZE <+ .CODE-SIZE 1>>
	     <SET RCODE <REST <SET CODE .RCODE>>>)>>>

<DEFINE KILL-FUNNY-DEADS (INST:FORM "AUX" (N:FIX <LENGTH .INST>) "VALUE" ATOM)
	<REPEAT (L FOO)
		<COND (<AND <TYPE? <SET L <NTH .INST .N>> LIST>
			    <NOT <EMPTY? .L>>
			    <OR <==? <SET FOO <1 .L>> `DEAD-FALL>
				<==? .FOO `DEAD-JUMP>>>
		       <PUTREST <REST .INST <- .N 2>> ()>
		       <SET N <- .N 1>>)
		      (ELSE <RETURN T>)>>>

<DEFINE PREPARE-LABELS-AND-TEMPS (CODE:VECTOR
				  "AUX" 
				  (ALL-VARS:LIST ()) (NTEMPS:FIX 0)
				  (CODELEN:FIX <LENGTH .CODE>)
				  (LOOP-LABELS:<LIST [REST LABEL]> ()))
   <REPEAT ((I:FIX 1) INST OP (LOOP-LABEL? %<>) LABEL:LABEL (DID-ENDIF <>))
      <SET INST <NTH .CODE .I>>
      <COND (<TYPE? .INST ATOM>
	     <SETG .INST .I>
	     <SET LABEL <CHTYPE [.INST () 0 %<>] LABEL>>
	     <COND (.LOOP-LABEL?
		    <SET LOOP-LABELS (.LABEL !.LOOP-LABELS)>
		    <SET LOOP-LABEL? %<>>)>
	     <PUT .CODE .I .LABEL>)
	    (<AND <TYPE? .INST FORM> <NOT <EMPTY? .INST>>>
	     <SET OP <1 .INST>>
	     <COND (<OR <==? .OP `END>
			<AND <==? .OP `ENDIF>
			     .DID-ENDIF>>
		    <SET DID-ENDIF <>>
		    <PUT .CODE .I <CHTYPE [.INST () 0 %<>] LABEL>>)
		   (<AND <==? .OP `ENDIF> <NOT .DID-ENDIF>>
		    <SET DID-ENDIF T>)
		   (<==? .OP `LOOP>
		    <SET LOOP-LABEL? T>)
		   (<==? .OP `ACTIVATION>
		    <SET LABEL <CHTYPE [.INST () 0 %<>] LABEL>>
		    <SET LOOP-LABELS (.LABEL !.LOOP-LABELS)>
		    <PUT .CODE .I .LABEL>)
		   (<OR <==? .OP `GFCN> 
			<==? .OP `FCN>>
		    <SET ALL-VARS (<SET INST <REST .INST 3>> !.ALL-VARS)>
		    <SET NTEMPS <+ .NTEMPS <LENGTH .INST>>>)
		   (<==? .OP `TEMP>
		    <SET ALL-VARS (<SET INST <REST .INST>> !.ALL-VARS)>
		    <SET NTEMPS <+ .NTEMPS <LENGTH .INST>>>)
		   (<==? .OP `MAKTUP>
		    <SET ALL-VARS (<REST .INST> !.ALL-VARS)>
		    <SET NTEMPS <+ .NTEMPS <LENGTH .INST> -3>>)>)>
      <COND (<==? .I .CODELEN> <RETURN>)>
      <SET I <+ .I 1>>>
   <CONSTRUCT-TEMPS .NTEMPS .ALL-VARS>
   .LOOP-LABELS>

;"CONSTRUCT-TEMPS SETGs each temp to a uvector.  THe first element ins this temp's
  number and the rest are essentially bit masks for the unmeargeabl lists"

<DEFINE CONSTRUCT-TEMPS (NTEMPS:FIX ALL-VARS:<LIST [REST LIST]>
			 "AUX" (UVSIZE </32 <+ .NTEMPS 32 31>>)
			       (UV-OF-NAMES <IVECTOR .NTEMPS>) (I:FIX 0))
	<MAPF <>
	      <FUNCTION (L:LIST)
		   <MAPF <>
			 <FUNCTION (ATM "AUX" UV:UVECTOR)
			      <COND (<==? .ATM => <MAPLEAVE>)>
			      <SETG <SET ATM <ATOM-PART .ATM>>
				    <SET UV <IUVECTOR .UVSIZE 0>>>
			      <PUT .UV 1 .I>
			      <PUT .UV-OF-NAMES <+ .I 1> .ATM>
			      <SET I <+ .I 1>>>
			 .L>>
	      .ALL-VARS>
	<SETG NAME-UV .UV-OF-NAMES>
	<SETG UVSIZE <- .UVSIZE 1>>		;"Since only bit masks stored">

<DEFMAC MAKE-BRANCH ('INST)
   <FORM CHTYPE [.INST () <FORM IUVECTOR ',UVSIZE 0>
		 <FORM IUVECTOR ',UVSIZE 0> %<>] BRANCH>>

;"END is required to be the location of the return label."

<DEFINE PREPARE-BRANCHES (CODE:VECTOR START:FIX END:FIX RETURN-LABEL:FIX
			  ACT-LABELS:<LIST [REST FIX]>)
   <REPEAT ((I:FIX .START) INST OP TO ASSIGN LAB:LABEL INST2
	    (DONT-BRANCH-IFSYS <>))
      <SET INST <NTH .CODE .I>>
      <COND (<TYPE? .INST LABEL>
	     <SET INST <L-INST .INST>>
	     <COND (<AND <TYPE? .INST FORM> <==? <1 .INST> `ACTIVATION>>
		    <SET ACT-LABELS (.I .RETURN-LABEL !.ACT-LABELS)>)>
	     <MAKE-CONNECTION .CODE .I <+ .I 1>>)
	    (<AND <TYPE? .INST FORM> <NOT <EMPTY? .INST>>>
	     <SET OP <1 .INST>>
	     <COND (<==? .OP `ENDIF>
		    <COND (<AND <TYPE? <SET INST2 <NTH .CODE <+ .I 2>>> FORM>
				<NOT <EMPTY? .INST2>>
				<OR <AND <==? <SET OP <1 .INST2>> `IFSYS>
					 <NOT-MERGEABLE-IFSYS-TYPES <2 .INST2>
								    <2 .INST>>>
				    <AND <OR <==? .OP `IFCAN>
					     <==? .OP `IFCANNOT>>
					 <=? <2 .INST> <2 .INST2>>>>>
			   ;"ENDIF followed immediately by IFSYS, IFCAN,
			     IFCANNOT that is mutually exclusive should act
			     like jump to beyond the NEXT ENDIF"
			   <SET DONT-BRANCH-IFSYS T>
			   <PUT .CODE .I <MAKE-BRANCH .INST>>
			   <MAKE-CONNECTION
			    .CODE
			    .I
			    <FUNNY-FIND-ENDIF .CODE
					      <+ .I 1>
					      <2 .INST>
					      <2 .INST2>>>)
			  (ELSE
			   <MAKE-CONNECTION .CODE .I <+ .I 1>>)>)
		   (<==? .OP `JUMP>
		    <PUT .CODE .I <MAKE-BRANCH .INST>>
		    <SET TO <3 .INST>>
		    <COND (<GASSIGNED? .TO>
			   <MAKE-CONNECTION .CODE .I ,.TO>)
			  (ELSE
			   <MAKE-CONNECTION .CODE .I .RETURN-LABEL>)>)
		   (<OR <==? .OP `RETURN> 
			<==? .OP `MRETURN>
			<==? .OP `RTUPLE>>
		    <PUT .CODE .I <MAKE-BRANCH .INST>>
		    <MAKE-CONNECTION .CODE .I .RETURN-LABEL>)
		   (<==? .OP `SCALL>
		    <PUT .CODE .I <MAKE-BRANCH .INST>>
		    <COND (<NOT <EMPTY? .ACT-LABELS>>
			   <MAPF %<>
				 <FUNCTION (ACT)
				    <MAKE-CONNECTION .CODE .I .ACT>>
				 .ACT-LABELS>)>
		    <SET TO <7 .INST>>
		    <COND (<AND <GASSIGNED? .TO> <N==? ,.TO <+ .I 1>>>
			   <MAKE-CONNECTION .CODE .I ,.TO>)
			  (<NOT <GASSIGNED? .TO>>
			   <MAKE-CONNECTION .CODE .I .RETURN-LABEL>)>
		    <MAKE-CONNECTION .CODE .I <+ .I 1>>)
		   (<OR <==? .OP `CALL>
			<==? .OP `ACALL>
			<==? .OP `INTGO>
			<==? .OP `AGAIN>
			<==? .OP `RETRY>
			<==? .OP `CONS>
			<==? .OP `LIST>
			<==? .OP `UBLOCK>
			<==? .OP `UUBLOCK>>
		    <COND (<NOT <EMPTY? .ACT-LABELS>>
			   <PUT .CODE .I <MAKE-BRANCH .INST>>
			   <MAPF %<>
				 <FUNCTION (ACT)
				    <MAKE-CONNECTION .CODE .I .ACT>>
				 .ACT-LABELS>)>
		    <MAKE-CONNECTION .CODE .I <+ .I 1>>)
		   (<==? .OP `NTHR>
		    <SET TO <NTH .INST <LENGTH .INST>>>
		    <COND (<AND <TYPE? .TO LIST>
				<NOT <EMPTY? .TO>>
				<==? <1 .TO> `BRANCH-FALSE>>
			   <SET TO <3 .TO>>
			   <PUT .CODE .I <MAKE-BRANCH .INST>>
			   <MAKE-CONNECTION .CODE .I <+ .I 1>>
			   <COND (<GASSIGNED? .TO>
				  <MAKE-CONNECTION .CODE .I ,.TO>)
				 (ELSE
				  <MAKE-CONNECTION .CODE .I .RETURN-LABEL>)>)>)
		   (<==? .OP `DISPATCH>
		    <PUT .CODE .I <MAKE-BRANCH .INST>>
		    <MAPF %<>
			  <FUNCTION (TO)
			     <COND (<GASSIGNED? .TO>
				    <MAKE-CONNECTION .CODE .I ,.TO>)
				   (ELSE
				    <MAKE-CONNECTION .CODE .I .RETURN-LABEL>)>>
			  <REST .INST 3>>)
		   (<OR <==? .OP `IFSYS>
			<==? .OP `IFCAN>
			<==? .OP `IFCANNOT>>
		    <COND (<NOT .DONT-BRANCH-IFSYS>
			   <PUT .CODE .I <MAKE-BRANCH .INST>>)>
		    <MAKE-CONNECTION .CODE .I <+ .I 1>>
		    <COND (.DONT-BRANCH-IFSYS <SET DONT-BRANCH-IFSYS <>>)
			  (ELSE
			   <MAKE-CONNECTION .CODE .I <FIND-ENDIF .CODE .I>>)>)
		   (<==? .OP `LOCATION>
		    <SET TO ,<3 .INST>>
		    <PREPARE-BRANCHES .CODE <+ .I 1> .TO .RETURN-LABEL
				      (.TO !.ACT-LABELS)>
		    <SET I .TO>)
		   (<==? .OP `ICALL>
		    ;"ICALLs are weird."
		    <SET TO ,<2 .INST>>	;"the index of the return label"
		    ;"If there is an = FOO in the ICALL, this is actually
		      set at the return label, so make that happen."
		    <SET ASSIGN <MEMQ = <REST .INST 2>>>
		    <COND (.ASSIGN
			   <SET LAB <NTH .CODE .TO>>
			   <L-ASSIGN .LAB ((<2 .ASSIGN> .I)
					   !<L-ASSIGN .LAB>)>)>
		    <PREPARE-BRANCHES .CODE <+ .I 1> .TO .TO .ACT-LABELS>
		    <SET I .TO>)
		   (<OR <SET TO <MEMQ + .INST>>
			<SET TO <MEMQ - .INST>>>
		    <SET TO <2 .TO>>
		    <PUT .CODE .I <MAKE-BRANCH .INST>>
		    <MAKE-CONNECTION .CODE .I <+ .I 1>>
		    <COND (<GASSIGNED? .TO>
			   <MAKE-CONNECTION .CODE .I ,.TO>)
			  (ELSE
			   <MAKE-CONNECTION .CODE .I .RETURN-LABEL>)>)
		   (ELSE
		    <MAKE-CONNECTION .CODE .I <+ .I 1>>)>)>
      <SET I <+ .I 1>>
      <COND (<==? .I .END> <RETURN .CODE>)>>
   .CODE>
	     
<DEFINE MAKE-CONNECTION (CODE:VECTOR FROM:FIX TO:FIX 
			 "AUX" FROM-BRANCH TO-LABEL)
   <COND (<TYPE? <SET FROM-BRANCH <NTH .CODE .FROM>> BRANCH>
	  <B-OUTS .FROM-BRANCH (.TO !<B-OUTS .FROM-BRANCH>)>)>
   <COND (<TYPE? <SET TO-LABEL <NTH .CODE .TO>> LABEL>
	  <L-INS .TO-LABEL (.FROM !<L-INS .TO-LABEL>)>)>
   T>

;"NOT-MERGEABLE-IFSYS-TYPES returns true if the ifsys args aren't a subset"

<DEFINE NOT-MERGEABLE-IFSYS-TYPES (A B)
	<COND (<=? .A "TOPS20"> <N=? .B "TOPS20">)
	      (<=? .B "TOPS20"> T)
	      (<=? .A "UNIX"> <> ;"B must be VAX, MAC or UNIX")
	      (<=? .B "UNIX"> <> ;"A must be VAX, MAC or UNIX")
	      (<N=? .A .B> T)>>

<DEFINE FIND-ENDIF (CODE:VECTOR I:FIX)
	<REAL-FIND-ENDIF .CODE .I <>>>

<DEFINE FUNNY-FIND-ENDIF (CODE:VECTOR I:FIX "TUPLE" MTUP)
	<REAL-FIND-ENDIF .CODE .I .MTUP>>

<DEFINE REAL-FIND-ENDIF (CODE:VECTOR I:FIX MTUP:<OR FALSE <PRIMTYPE VECTOR>>
			 "AUX" (LEVEL:FIX 0))
   <REPEAT (INST OP)
      <SET I <+ .I 1>>
      <SET INST <NTH .CODE .I>>
      <COND (<AND <TYPE? .INST LABEL>
		  <TYPE? <SET INST <L-INST .INST>> FORM>
		  <NOT <EMPTY? .INST>>>
	     <SET OP <1 .INST>>
	     <COND (<==? .OP `ENDIF>
		    <COND
		     (<0? .LEVEL>
		      <COND
		       (<AND .MTUP
			     <TYPE? <SET INST <NTH .CODE <+ .I 2>>>
				    FORM>
			     <==? <1 .INST> `IFSYS>
			     <MAPF <>
				   <FUNCTION (S)
					<COND (<NOT-MERGEABLE-IFSYS-TYPES
						.S <2 .INST>>
					       T)
					      (ELSE <MAPLEAVE <>>)>>
				   .MTUP>>
			<SET I <+ .I 1>>)
		       (ELSE <RETURN .I>)>)
		     (ELSE <SET LEVEL <- .LEVEL 1>>)>)
		   (<OR <==? .OP `IFSYS>
			<==? .OP `IFCAN>
			<==? .OP `IFCANNOT>>
		    <SET LEVEL <+ .LEVEL 1>>)>)>>>

<DEFINE BACKWALK-FROM-LABEL (CODE:VECTOR LABEL:LABEL CUR-LEV:FIX)
   <MAPF %<>
	 <FUNCTION (IN:FIX "AUX" (INST <NTH .CODE .IN>))
	    <COND (<TYPE? .INST BRANCH>
		   <BACKWALK .CODE .IN <UVECTOR !<B-LIVES .INST>> .CUR-LEV>)>>
	 <L-INS .LABEL>>>   

<DEFINE BACKWALK (CODE:VECTOR I:FIX LIVE-TEMPS:UVECTOR CUR-LEV:FIX)
   <REPEAT (INST INS:<LIST [REST FIX]>
	    ASSIGN:<OR FALSE <LIST [REST !<LIST ATOM FIX>]>>)
      <SET INST <NTH .CODE .I>>
      <COND (<TYPE? .INST LABEL>
	     <COND (<L=? .CUR-LEV <L-LEVEL .INST>> <RETURN>)
		   (ELSE <L-LEVEL .INST .CUR-LEV>)>
	     <SET ASSIGN <L-ASSIGN .INST>>
	     <SET INS <L-INS .INST>>
	     <COND (<EMPTY? .INS>
		    <COND (<==? .CUR-LEV 1>
			   <PRINTSTRING 
			    "FILE-DEATH: Warning--unreachable code at "
			    .OUTCHAN>
			   <PRIN1 <L-INST .INST> .OUTCHAN>
			   <CRLF .OUTCHAN>
			   <RETURN>)>)
		   (ELSE
		    <MAPF %<>
			  <FUNCTION (IN "AUX" (LV:UVECTOR <UVECTOR !.LIVE-TEMPS>))
			     <COND (.ASSIGN
				    <MAPF <>
					  <FUNCTION (LL:!<LIST ATOM FIX>)
					       <COND (<==? <2 .LL> .IN>
						      <REM-LIST <1 .LL> .LV>
						      <UNMERGEABLE <1 .LL> .LV>
						      <MAPLEAVE>)>>
					  .ASSIGN>)>
			     <BACKWALK .CODE .IN .LV .CUR-LEV>>
			  <REST .INS>>
		    <SET I <1 .INS>>
		    <COND (.ASSIGN
			   <MAPF <>
				 <FUNCTION (LL:!<LIST ATOM FIX>)
				      <COND (<==? <2 .LL> .I>
					     <REM-LIST <1 .LL> .LIVE-TEMPS>
					     <UNMERGEABLE <1 .LL> .LIVE-TEMPS>
					     <MAPLEAVE>)>>
				 .ASSIGN>)>)>)
	    (<TYPE? .INST BRANCH>
	     <SET LIVE-TEMPS <MERGE-TEMPS .LIVE-TEMPS .INST>>
	     <SET LIVE-TEMPS <UPDATE-TEMPS <B-INST .INST> .LIVE-TEMPS>>
	     <SET I <- .I 1>>)
	    (ELSE	;"had better be a form"
	     <SET LIVE-TEMPS <UPDATE-TEMPS .INST .LIVE-TEMPS>>
	     <SET I <- .I 1>>)>
      <COND (<0? .I> <RETURN>)>>>

<DEFINE MERGE-TEMPS (LIVES:UVECTOR BRANCH:BRANCH
		     "AUX" B-LIVES:UVECTOR (TEMP-OFFS:FIX 0))
   ;"Add to each list the items on the other list."
   ;"Every time a temp is added to B-LIVES, it must be declared UNMERGEABLE 
     with the ones already there."
   <SET B-LIVES <B-LIVES .BRANCH>>
   ;"First put all temps from both into LIVES"
   <MAPR <>
	 <FUNCTION (LP:UVECTOR BP:UVECTOR)
	      <PUT .LP 1 <ORB <1 .LP> <1 .BP>>>>
	 .LIVES .B-LIVES>
   ;"Now make any to be added to B-LIVES unmeargable with those there and
     flag the fact that a change occured"
   <MAPR <>
	 <FUNCTION (LP:UVECTOR BP:UVECTOR
		    "AUX" (ADDED:FIX <XORB <1 .LP> <1 .BP>>))
	      <COND (<N==? .ADDED 0>
		     ;"Something was added to B-LIVES"
		     <SETG SOMETHING-CHANGED T>
		     ;"Now do the unmergeables"
		     <REPEAT ((TNO:FIX <+ .TEMP-OFFS 1>) (MSK:FIX 1))
			     <COND (<N==? <ANDB .MSK .ADDED> 0>
				    <SET ADDED <XORB .ADDED .MSK>>
				    <UNMERGEABLE <NTH ,NAME-UV .TNO> .LIVES>
				    <COND (<==? .ADDED 0> <RETURN>)>)>
			     <SET MSK <LSH .MSK 1>>
			     <SET TNO <+ .TNO 1>>>)>
	      <SET TEMP-OFFS <+ .TEMP-OFFS 32>>
	      <PUT .BP 1 <1 .LP>>>
	 .LIVES .B-LIVES>
   <B-LIVES .BRANCH .B-LIVES>
   .LIVES>

;"ICALL is weird.  Even though it can have an = FOO, this assignment 
  effectively takes place at the exit label."

<DEFINE UPDATE-TEMPS (INST:FORM LIVES:UVECTOR 
		      "AUX" OP ITEM TWO THREE FOUR)
   <COND (<NOT <EMPTY? .INST>>
	  <SET OP <1 .INST>>
	  <COND (<==? .OP `SET>
		 <REM-LIST <SET TWO <2 .INST>> .LIVES>
		 <UNMERGEABLE .TWO .LIVES>
		 <COND (<TYPE? <SET THREE <3 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .THREE .LIVES>>)>)
		(<==? .OP `SETLR>
		 <REM-LIST <SET TWO <2 .INST>> .LIVES>
		 <UNMERGEABLE .TWO .LIVES>
		 <COND (<TYPE? <SET THREE <3 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .THREE .LIVES>>)>
		 <COND (<TYPE? <SET FOUR <4 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .FOUR .LIVES>>)>)
		(<==? .OP `SETRL>
		 <REM-LIST <SET THREE <3 .INST>> .LIVES>
		 <UNMERGEABLE .THREE .LIVES>
		 <COND (<TYPE? <SET TWO <2 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .TWO .LIVES>>)>
		 <COND (<TYPE? <SET FOUR <4 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .FOUR .LIVES>>)>)
		(<==? .OP `TEMP>
		 <MAPF %<>
		       <FUNCTION (T "AUX" ATM)
			  <COND (<TYPE? .T LIST>
				 <REM-LIST <SET ATM <ATOM-PART .T>>
					   .LIVES>
				 <UNMERGEABLE .ATM .LIVES>)>>
		       <REST .INST>>)
		(<==? .OP `MAKTUP>
		 <MAPF %<>
		       <FUNCTION (T "AUX" ATM)
			  <COND (<==? .T => <MAPLEAVE>)
				(<TYPE? .T LIST>
				 <REM-LIST <SET ATM <ATOM-PART .T>>
					   .LIVES>
				 <UNMERGEABLE .ATM .LIVES>)>>
		       <REST .INST>>)
		(<==? .OP `DISPATCH>
		 <COND (<TYPE? <SET TWO <2 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .TWO .LIVES>>)>
		 <COND (<TYPE? <SET THREE <3 .INST>> ATOM>
			<SET LIVES <ADD-LIVE .THREE .LIVES>>)>)
		(<AND <N==? .OP `FCN>
		      <N==? .OP `GFCN>
		      <N==? .OP `LOOP>
		      <N==? .OP `END>
		      <N==? .OP `ICALL>
		      <N==? .OP `OPT-DISPATCH>>
		 <SET ITEM <MEMQ = <REST .INST>>>
		 <COND (.ITEM
			<COND (<N==? <SET TWO <2 .ITEM>> `STACK>
			       <REM-LIST .TWO .LIVES>
			       <UNMERGEABLE .TWO .LIVES>)>)>
		 <REPEAT ((RINST <REST .INST>) ONE)
		    <COND (<EMPTY? .RINST> <RETURN>)>
		    <SET ONE <1 .RINST>>
		    <COND (<OR <==? .ONE =>
			       <==? .ONE +>
			       <==? .ONE ->>
			   <SET RINST <REST .RINST 2>>)
			  (<TYPE? .ONE ATOM>
			   <SET LIVES <ADD-LIVE .ONE .LIVES>>
			   <SET RINST <REST .RINST>>)
			  (<AND <==? .OP `CHTYPE>
				<TYPE? .ONE FORM>
				<NOT <LENGTH? .ONE 1>>
				<==? <1 .ONE> `TYPE>
				<TYPE? <SET TWO <2 .ONE>> ATOM>>
			   <SET LIVES <ADD-LIVE .TWO .LIVES>>
			   <SET RINST <REST .RINST>>)
			  (ELSE
			   <SET RINST <REST .RINST>>)>>)>)>
   .LIVES>

<DEFINE ADD-LIVE (ATM:ATOM L:UVECTOR 
		  "AUX" NL:<OR FALSE UVECTOR>
		  "VALUE" UVECTOR)
   <SET NL <ADD-LIST? .ATM .L>>
   <COND (.NL <UNMERGEABLE .ATM .L> .NL)
	 (ELSE .L)>>

<DEFINE UNMERGEABLE (NEW-LIVE:ATOM LIVES:UVECTOR
		    "AUX" NL-LIST:UVECTOR NUM:FIX WD:FIX BIT:FIX
			  (TEMP-OFFS:FIX 0))
   ;"The error tests were removed to make things run faster.  Believe it
     or not, this function is one of the big time sinks of the package."
   <COND (<NOT <GASSIGNED? .NEW-LIVE>>
	  <ERROR TEMP-WITHOUT-LIST!-ERRORS .NEW-LIVE UNMERGEABLE>)>
   <COND (<N==? .NEW-LIVE `STACK>
	  <SET NL-LIST ,.NEW-LIVE>
	  <SET NUM <1 .NL-LIST>>
	  <SET NL-LIST <REST .NL-LIST>>
	  <MAPF <>
		<FUNCTION (LIVE:FIX "AUX" ATM)
		     <COND (<N==? .LIVE 0>
			    <REPEAT ((TNO:FIX .TEMP-OFFS) (MSK:FIX 1))
				    <COND (<AND <N==? <ANDB .LIVE .MSK> 0>
						<SET LIVE <XORB .LIVE .MSK>>
						<COND (<N==? .TNO .NUM>)
						      (<==? .LIVE 0>
						       <RETURN>)>>
					   <SET ATM <NTH ,NAME-UV
							 <+ .TNO 1>>>
					   <COND (<NOT <GASSIGNED? .ATM>>
						  <ERROR
						   TEMP-WITHOUT-LIST!-ERRORS
						   .ATM UNMERGEABLE>)>
					   <ADD-LIST .ATM .NL-LIST>
					   <ADD-LIST .NEW-LIVE <REST ,.ATM>>
					   <COND (<==? .LIVE 0> <RETURN>)>)>
				    <SET TNO <+ .TNO 1>>
				    <SET MSK <LSH .MSK 1>>>)>
		     <SET TEMP-OFFS <+ .TEMP-OFFS 32>>>
		.LIVES>)>
   T>

<DEFINE OPTIMIZE-SETS (CODE:VECTOR)
   <REPEAT ((I:FIX 1) (CODELEN:FIX <LENGTH .CODE>) INST ATM1 ATM2)
      <SET INST <NTH .CODE .I>>
      <COND (<AND <TYPE? .INST FORM>
		  <NOT <LENGTH? .INST 2>>
		  <==? <1 .INST> `SET>
		  <TYPE? <SET ATM1 <2 .INST>> ATOM>
		  <TYPE? <SET ATM2 <3 .INST>> ATOM>
		  <NOT <IN-LIST? .ATM1 <REST ,.ATM2>>>>
	     <MAYBE-MERGE .CODE .ATM1 .ATM2>)>
      <COND (<==? .I .CODELEN> <RETURN>)>
      <SET I <+ .I 1>>>>

<DEFINE MAYBE-MERGE (CODE:VECTOR ATM1:ATOM ATM2:ATOM)
   <REPEAT WHOLE-THING ((I:FIX 1) (CODELEN:FIX <LENGTH .CODE>) INST)
      <SET INST <NTH .CODE .I>>
      <COND (<AND <TYPE? .INST FORM> 
		  <NOT <EMPTY? .INST>>
		  <OR <==? <1 .INST> `TEMP>
		      <==? <1 .INST> `MAKTUP>>>
	     <REPEAT ((LONG:LIST <REST .INST>) ONE-LONG)
		<COND (<OR <EMPTY? .LONG>
			   <==? <SET ONE-LONG <1 .LONG>> =>>
		       <RETURN>)
		      (<==? <ATOM-PART .ONE-LONG> .ATM1>
		       <PROBABLY-MERGE .CODE .LONG .ATM1 .ATM2>
		       <RETURN T .WHOLE-THING>)
		      (<==? <ATOM-PART .ONE-LONG> .ATM2>
		       <PROBABLY-MERGE .CODE .LONG .ATM2 .ATM1>
		       <RETURN T .WHOLE-THING>)>
		<SET LONG <REST .LONG>>>)>
      <COND (<==? .I .CODELEN> <RETURN>)>
      <SET I <+ .I 1>>>
   T>

<DEFINE PROBABLY-MERGE (CODE:VECTOR LONG:LIST NEW-TEMP:ATOM OLD-TEMP:ATOM
			"AUX" (OUTCHAN:CHANNEL .OUTCHAN))
   <REPEAT ((MEDIUM:LIST .LONG) (SHORT:LIST <REST .LONG>) ONE-SHORT)
      <COND (<OR <EMPTY? .SHORT> <==? <SET ONE-SHORT <1 .SHORT>> =>> <RETURN>)
	    (<==? <ATOM-PART .ONE-SHORT> .OLD-TEMP>
	     <COND (<MERGEABLE? <1 .LONG> .ONE-SHORT>
		    <COND (<TYPE? .ONE-SHORT LIST>
			   <1 .LONG <1 .ONE-SHORT <1 .LONG>>>)>
		    <PUTREST .MEDIUM <REST .SHORT>>
		    <COND (,DEBUG-DEATH
			   <PRINTSTRING "Merging " .OUTCHAN>
			   <PRIN1 .OLD-TEMP .OUTCHAN>
			   <PRINTSTRING " with " .OUTCHAN>
			   <PRIN1 .NEW-TEMP .OUTCHAN>
			   <CRLF .OUTCHAN>)>
		    <UNMERGEABLE .NEW-TEMP <REST ,.OLD-TEMP>>
		    <PERFORM-MERGE .CODE .NEW-TEMP .OLD-TEMP>)>
	     <RETURN>)>
      <SET SHORT <REST <SET MEDIUM .SHORT>>>>
   T>

<DEFINE OPTIMIZE-TEMPS (CODE:VECTOR)
   <REPEAT ((I:FIX 1) (CODELEN:FIX <LENGTH .CODE>) INST OP)
      <SET INST <NTH .CODE .I>>
      <COND (<AND <TYPE? .INST FORM> 
		  <NOT <EMPTY? .INST>>>
	     <SET OP <1 .INST>>
	     <COND (<OR <==? .OP `TEMP> <==? .OP `MAKTUP>>
		    <REALLY-OPTIMIZE .CODE <REST .INST>>)>)>
      <COND (<==? .I .CODELEN> <RETURN>)>
      <SET I <+ .I 1>>>>

<DEFINE REALLY-OPTIMIZE (CODE:VECTOR TEMPS:LIST 
			 "AUX" (OUTCHAN:CHANNEL .OUTCHAN)
			 OLD-TEMP:ATOM NEW-TEMP:ATOM)
   <COND (<NOT <EMPTY? .TEMPS>>
	  <REPEAT ((LONG:LIST .TEMPS) ONE-LONG)
	     <COND (<OR <EMPTY? .LONG> <==? <SET ONE-LONG <1 .LONG>> =>> <RETURN>)>
	     <REPEAT ((MEDIUM:LIST .LONG) (SHORT:LIST <REST .MEDIUM>) ONE-SHORT)
		<COND (<OR <EMPTY? .SHORT> <==? <SET ONE-SHORT <1 .SHORT>> =>>
		       <RETURN>)>
		<COND (<MERGEABLE? .ONE-LONG .ONE-SHORT>
		       <SET NEW-TEMP <ATOM-PART .ONE-LONG>>
		       <SET OLD-TEMP <ATOM-PART .ONE-SHORT>>
		       <COND (<TYPE? .ONE-SHORT LIST>
			      <1 .LONG <1 .ONE-SHORT .ONE-LONG>>)>
		       <PUTREST .MEDIUM <SET SHORT <REST .SHORT>>>
		       <COND (,DEBUG-DEATH
			      <PRINTSTRING "Merging " .OUTCHAN>
			      <PRIN1 .OLD-TEMP .OUTCHAN>
			      <PRINTSTRING " with " .OUTCHAN>
			      <PRIN1 .NEW-TEMP .OUTCHAN>
			      <CRLF .OUTCHAN>)>
		       <UNMERGEABLE .NEW-TEMP <REST ,.OLD-TEMP>>
		       <PERFORM-MERGE .CODE .NEW-TEMP .OLD-TEMP>)
		      (ELSE
		       <SET SHORT <REST <SET MEDIUM .SHORT>>>)>>
	     <SET LONG <REST .LONG>>>)>>	  
	  
<DEFINE MERGEABLE? (TEMP1:<OR ATOM ADECL LIST> TEMP2:<OR ATOM ADECL LIST>)
   <AND <==? <DECL-PART .TEMP1> <DECL-PART .TEMP2>>
	<NOT <AND <TYPE? .TEMP1 LIST> <TYPE? .TEMP2 LIST>>>
	<NOT <IN-LIST? <ATOM-PART .TEMP1> <REST ,<ATOM-PART .TEMP2>>>>>>

<DEFINE OPTIMIZE-TEMPS/BASH-DECLS (CODE:VECTOR)
   <REPEAT ((I:FIX 1) (CODELEN:FIX <LENGTH .CODE>) INST OP)
      <SET INST <NTH .CODE .I>>
      <COND (<AND <TYPE? .INST FORM> 
		  <NOT <EMPTY? .INST>>>
	     <SET OP <1 .INST>>
	     <COND (<OR <==? .OP `TEMP> <==? .OP `MAKTUP>>
		    <REALLY-OPTIMIZE/BASH-DECLS .CODE <REST .INST>>)>)>
      <COND (<==? .I .CODELEN> <RETURN>)>
      <SET I <+ .I 1>>>>

<DEFINE REALLY-OPTIMIZE/BASH-DECLS (CODE:VECTOR TEMPS:LIST 
				    "AUX" (OUTCHAN:CHANNEL .OUTCHAN)
				    OLD-TEMP:ATOM NEW-TEMP:ATOM)
   <COND (<NOT <EMPTY? .TEMPS>>
	  <REPEAT ((LONG:LIST .TEMPS) ONE-LONG)
	     <COND (<OR <EMPTY? .LONG> <==? <SET ONE-LONG <1 .LONG>> =>> 
		    <RETURN>)>
	     <REPEAT ((MEDIUM:LIST .LONG) (SHORT:LIST <REST .MEDIUM>) ONE-SHORT)
		<COND (<OR <EMPTY? .SHORT> <==? <SET ONE-SHORT <1 .SHORT>> =>>
		       <RETURN>)>
		<COND (<MERGEABLE?/BASH-DECLS .ONE-LONG .ONE-SHORT>
		       <SET NEW-TEMP <ATOM-PART .ONE-LONG>>
		       <SET OLD-TEMP <ATOM-PART .ONE-SHORT>>
		       <COND (<AND <DECL-PART .ONE-LONG>
				   <N==? <DECL-PART .ONE-LONG> 
					 <DECL-PART .ONE-SHORT>>>
			      <COND (<TYPE? .ONE-LONG ADECL>
				     <1 .LONG <SET ONE-LONG <1 .ONE-LONG>>>)
				    (<TYPE? .ONE-LONG LIST>
				     <1 .ONE-LONG <1 <1 .ONE-LONG>>>)>)>
		       <COND (<TYPE? .ONE-SHORT LIST>
			      <1 .LONG <1 .ONE-SHORT .ONE-LONG>>)>
		       <PUTREST .MEDIUM <SET SHORT <REST .SHORT>>>
		       <COND (,DEBUG-DEATH
			      <PRINTSTRING "Merging " .OUTCHAN>
			      <PRIN1 .OLD-TEMP .OUTCHAN>
			      <PRINTSTRING " with " .OUTCHAN>
			      <PRIN1 .NEW-TEMP .OUTCHAN>
			      <CRLF .OUTCHAN>)>
		       <UNMERGEABLE .NEW-TEMP <REST ,.OLD-TEMP>>
		       <PERFORM-MERGE .CODE .NEW-TEMP .OLD-TEMP>)
		      (ELSE
		       <SET SHORT <REST <SET MEDIUM .SHORT>>>)>>
	     <SET LONG <REST .LONG>>>)>>

<DEFINE MERGEABLE?/BASH-DECLS (TEMP1:<OR ATOM ADECL LIST> 
			       TEMP2:<OR ATOM ADECL LIST>)
   <AND <NOT <AND <TYPE? .TEMP1 LIST> <TYPE? .TEMP2 LIST>>>
	<NOT <IN-LIST? <ATOM-PART .TEMP1> <REST ,<ATOM-PART .TEMP2>>>>>>

<DEFINE PERFORM-MERGE (CODE:VECTOR NEW-TEMP:ATOM OLD-TEMP:ATOM)
   <MAPF %<>
	 <FUNCTION (INST "AUX" OP L ASSIGN)
	    <COND (<TYPE? .INST BRANCH>
		   <COND (<IN-LIST? .OLD-TEMP <B-LIVES .INST>>
			  <REM-LIST .OLD-TEMP <B-LIVES .INST>>
			  <ADD-LIST .NEW-TEMP <B-LIVES .INST>>)>
		   <SET INST <B-INST .INST>>)
		  (<TYPE? .INST LABEL>
		   <COND (<SET ASSIGN <L-ASSIGN .INST>>
			  <MAPF <>
				<FUNCTION (LL:!<LIST ATOM FIX>)
				     <COND (<==? <1 .LL> .OLD-TEMP>
					    <PUT .LL 1 .NEW-TEMP>
					    <MAPLEAVE>)>>
				.ASSIGN>)>
		   <SET INST <L-INST .INST>>)>
	    <COND (<AND <TYPE? .INST FORM> <NOT <EMPTY? .INST>>>
		   <SET OP <1 .INST>>
		   <COND (<==? .OP `LOOP>
			  <MAPF %<>
				<FUNCTION (L) 
				   <REPLACE-ATOM .L .NEW-TEMP .OLD-TEMP>>
				<REST .INST>>)
			 (<==? .OP `ICALL>
			  <COND (<G=? <LENGTH .INST> 3>
				 <REPLACE-ATOM <REST .INST 3>
					       .NEW-TEMP
					       .OLD-TEMP>)>)
			 (<==? .OP `CHTYPE>
			  <REPLACE-ATOM <REST .INST> .NEW-TEMP .OLD-TEMP>
			  <MAPF %<>
				<FUNCTION (I)
				   <COND (<AND <TYPE? .I FORM>
					       <NOT <LENGTH? .I 1>>
					       <==? <1 .I> `TYPE>
					       <==? <2 .I> .OLD-TEMP>>
					  <2 .I .NEW-TEMP>)>>
				<REST .INST>>)
			 (ELSE
			  <REPLACE-ATOM <REST .INST> .NEW-TEMP .OLD-TEMP>)>)>>
	 .CODE>>

<DEFINE REPLACE-ATOM (L:<PRIMTYPE LIST> NEW-ATOM:ATOM OLD-ATOM:ATOM)
   <MAPR %<>
	 <FUNCTION (RL "AUX" (ONE <1 .RL>))
	    <COND (<==? .ONE .OLD-ATOM>
		   <1 .RL .NEW-ATOM>)>>
	 .L>
   T>

<DEFINE PREPARE-DEADS-FROM-LABEL (CODE:VECTOR LABEL:LABEL)
   <MAPF %<>
	 <FUNCTION (IN:FIX "AUX" (INST <NTH .CODE .IN>))
	    <COND (<TYPE? .INST BRANCH>
		   <PREPARE-DEADS .CODE .IN <UVECTOR !<B-LIVES .INST>> -1>)>>
	 <L-INS .LABEL>>>

<DEFINE PREPARE-DEADS (CODE:VECTOR I:FIX LIVE-TEMPS:UVECTOR
		       FROM:FIX)
   <REPEAT (INST INS:<LIST [REST FIX]>
	    ASSIGN:<OR FALSE <LIST [REST !<LIST ATOM FIX>]>>)
      <SET INST <NTH .CODE .I>>
      <COND (<TYPE? .INST LABEL>
	     <COND (<==? <L-LEVEL .INST> -1> <RETURN>)
		   (ELSE <L-LEVEL .INST -1>)>
	     <SET ASSIGN <L-ASSIGN .INST>>
	     <SET INS <L-INS .INST>>
	     <COND (<EMPTY? .INS>
		    <ERROR UNREACHABLE-CODE!-ERRORS PREPARE-DEADS>)
		   (ELSE
		    <MAPF %<>
			  <FUNCTION (IN "AUX" (LV:UVECTOR <UVECTOR !.LIVE-TEMPS>))
			     <COND (.ASSIGN
				    <MAPF <>
					  <FUNCTION (LL:!<LIST ATOM FIX>)
					       <COND (<==? <2 .LL> .IN>
						      <REM-LIST <1 .LL> .LV>
						      <MAPLEAVE>)>>
					  .ASSIGN>)>
			     <PREPARE-DEADS .CODE .IN .LV .I>>
			  <REST .INS>>
		    <SET FROM .I>
		    <SET I <1 .INS>>
		    <COND (.ASSIGN
			   <MAPF <>
				 <FUNCTION (LL:!<LIST ATOM FIX>)
				      <COND (<==? <2 .LL> .I>
					     <REM-LIST <1 .LL> .LIVE-TEMPS>
					     <MAPLEAVE>)>>
				 .ASSIGN>)>)>)
	    (<TYPE? .INST BRANCH>
	     <SET LIVE-TEMPS 
		  <MERGE-DEADS .LIVE-TEMPS .INST <==? .FROM <+ .I 1>>>>
	     <SET LIVE-TEMPS <UPDATE-DEADS <B-INST .INST> .LIVE-TEMPS>>
	     <SET FROM .I>
	     <SET I <- .I 1>>)
	    (ELSE	;"had better be a form"
	     <SET LIVE-TEMPS <UPDATE-DEADS .INST .LIVE-TEMPS>>
	     <SET FROM .I>
	     <SET I <- .I 1>>)>
      <COND (<0? .I> <RETURN>)>>>

<DEFINE MERGE-DEADS (LIVES:UVECTOR BRANCH:BRANCH FALL?
		     "AUX" B-LIVES:UVECTOR
		     (ND1:UVECTOR <IUVECTOR ,UVSIZE 0>) JD)
   ;"Add to LIVES any atoms that are not already there.  Do this without
     modifying B-LIVES.  Declare all atoms added DEAD in the appropriate
     place."
   ;"Since we know that LIVES is a subset of B-LIVES, much of the code
     goes away."
   <SET B-LIVES <B-LIVES .BRANCH>>
   <MAPR <>
	 <FUNCTION (LP:UVECTOR BP:UVECTOR NDP:UVECTOR "AUX" L:FIX B:FIX)
	      <COND (<N==? <SET L <1 .LP>> <SET B <1 .BP>>>
		     <PUT .LP 1 <ORB .L .B>>
		     <PUT .NDP 1 <XORB .L .B>>)>>
	 .LIVES .B-LIVES .ND1>
   <COND (.FALL?
	  <B-FALL-DEADS .BRANCH .ND1>)
	 (ELSE
	  <SET JD <B-JUMP-DEADS .BRANCH>>
	  <COND (.JD
		 <B-JUMP-DEADS .BRANCH <INTERSECT-UVS .ND1 .JD>>)
		(ELSE
		 <B-JUMP-DEADS .BRANCH .ND1>)>)>
   .LIVES>

<DEFINE INTERSECT-UVS (U1:UVECTOR U2:UVECTOR "AUX" (U3:UVECTOR <IUVECTOR ,UVSIZE>))
	<MAPR <>
	      <FUNCTION (UP1 UP2 UP3)
		   <PUT .UP3 1 <ANDB <1 .UP1> <1 .UP2>>>>
	      .U1 .U2 .U3>
	.U3>



;"ICALL is weird.  Even though it can have an = FOO, this assignment 
  effectively takes place at the exit label."

<DEFINE UPDATE-DEADS (INST:FORM LIVES:UVECTOR "AUX" SETTER OP TEM)
   ;"Any time an atom is added to the list of LIVES, it must be declared
     DEAD, unless it is also SET in the same instruction."
   <COND (<NOT <EMPTY? .INST>>
	  <SET OP <1 .INST>>
	  <COND (<==? .OP `SET>
		 <SET SETTER <CHTYPE <2 .INST> ATOM>>
		 <COND (<NOT <REM-LIST? .SETTER .LIVES>>
			<SETG ANY-FLUSHED-INS T>
			<PUT .INST 2 <CHTYPE .SETTER DEAD-VAR>>)>
		 <COND (<TYPE? <3 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 2> .LIVES .SETTER>)>)
		(<==? .OP `SETLR>
		 <SET SETTER <CHTYPE <2 .INST> ATOM>>
		 <COND (<NOT <REM-LIST? .SETTER .LIVES>>
			<SETG ANY-FLUSHED-INS T>
			<PUT .INST 2 <CHTYPE .SETTER DEAD-VAR>>)>
		 <COND (<TYPE? <3 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 2> .LIVES .SETTER>)>
		 <COND (<TYPE? <4 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 3> .LIVES .SETTER>)>)
		(<==? .OP `SETRL>
		 <SET SETTER <CHTYPE <3 .INST> ATOM>>
		 <COND (<NOT <REM-LIST? .SETTER .LIVES>>
			<SETG ANY-FLUSHED-INS T>
			<PUT .INST 3 <CHTYPE .SETTER DEAD-VAR>>)>
		 <COND (<TYPE? <2 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 1> .LIVES .SETTER>)>
		 <COND (<TYPE? <4 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 3> .LIVES .SETTER>)>)
		(<==? .OP `TEMP>
		 <MAPF %<>
		       <FUNCTION (T)
			  <COND (<TYPE? .T LIST>
				 <REM-LIST <ATOM-PART .T> .LIVES>)>>
		       <REST .INST>>)
		(<==? .OP `MAKTUP>
		 <MAPF %<>
		       <FUNCTION (T)
			  <COND (<==? .T => <MAPLEAVE>)
				(<TYPE? .T LIST>
				 <REM-LIST <ATOM-PART .T> .LIVES>)>>
		       <REST .INST>>)
		(<==? .OP `DISPATCH>
		 <COND (<TYPE? <2 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 1> .LIVES %<>>)>
		 <COND (<TYPE? <3 .INST> ATOM DEAD-VAR>
			<ADD-DEAD <REST .INST 2> .LIVES %<>>)>)
		(<AND <N==? .OP `FCN>
		      <N==? .OP `GFCN>
		      <N==? .OP `OPT-DISPATCH>
		      <N==? .OP `LOOP>
		      <N==? .OP `END>
		      <N==? .OP `ICALL>>
		 <SET TEM <MEMQ = <REST .INST>>>
		 <COND (.TEM 
			<SET SETTER <CHTYPE <2 .TEM> ATOM>>
			<COND (<N==? .SETTER `STACK>
			       <COND (<AND <NOT <REM-LIST? .SETTER .LIVES>>
					   <N==? .OP `SCALL>
					   <N==? .OP `SYSOP>
					   <N==? .OP `SYSCALL>>
				      <SETG ANY-FLUSHED-INS T>
				      <PUT .TEM 2 <CHTYPE .SETTER DEAD-VAR>>)>)>)
		       (ELSE <SET SETTER %<>>)>
		 <REPEAT ((RINST <REST .INST>) ONE)
		    <COND (<EMPTY? .RINST> <RETURN>)>
		    <SET ONE <1 .RINST>>
		    <COND (<OR <==? .ONE =>
			       <==? .ONE +>
			       <==? .ONE ->>
			   <SET RINST <REST .RINST 2>>)
			  (<TYPE? .ONE ATOM DEAD-VAR>
			   <ADD-DEAD .RINST .LIVES .SETTER>
			   <SET RINST <REST .RINST>>)
			  (<AND <==? .OP `CHTYPE>
				<TYPE? .ONE FORM>
				<NOT <LENGTH? .ONE 1>>
				<==? <1 .ONE> `TYPE>
				<TYPE? <2 .ONE> ATOM>>
			   <ADD-DEAD <REST .ONE> .LIVES .SETTER>
			   <SET RINST <REST .RINST>>)
			  (ELSE
			   <SET RINST <REST .RINST>>)>>)>)>
   .LIVES>

<DEFINE ADD-DEAD (RINST:<LIST <OR ATOM DEAD-VAR>> L:UVECTOR
		  SETTER:<OR ATOM FALSE>
		  "AUX" (ATM:ATOM <CHTYPE <1 .RINST> ATOM>))
   <COND (<AND <ADD-LIST? .ATM .L> <N==? .ATM .SETTER>>
	  <1 .RINST <CHTYPE .ATM DEAD-VAR>>)>>

<DEFINE INSERT-DEADS (CODE:LIST VCODE:VECTOR "AUX" (RCODE:LIST .CODE))
   <MAPF %<>
	 <FUNCTION (INST "AUX" DEADS:LIST FALL-DEADS:LIST JUMP-DEADS:LIST OP
			       TMPL:<OR FALSE LIST> BJL:<OR FALSE UVECTOR>)
	    <COND (<TYPE? .INST BRANCH>
		   <SET DEADS <FIND-DEADS <B-INST .INST>>>
		   <SET FALL-DEADS <UV-TO-L <B-FALL-DEADS .INST>>>
		   <SET BJL <B-JUMP-DEADS .INST>>
		   <COND (.BJL
			  <SET JUMP-DEADS <UV-TO-L .BJL>>)
			 (ELSE <SET JUMP-DEADS ()>)>
		   <SET INST <B-INST .INST>:FORM>
		   ;"BEGIN TEMPORARY HACK"
		   ;<SET FALL-DEADS <INTERSECT-LISTS .FALL-DEADS .JUMP-DEADS>>
		   ;<SET JUMP-DEADS ()>
		   ;"END TEMOPRARY HACK"
		   <COND (<NOT <EMPTY? .JUMP-DEADS>>
			  <PUTREST <REST .INST <- <LENGTH .INST> 1>>
				   ((`DEAD-JUMP !.JUMP-DEADS))>)>
		   <COND (<NOT <EMPTY? .FALL-DEADS>>
			  <PUTREST <REST .INST <- <LENGTH .INST> 1>>
				   ((`DEAD-FALL !.FALL-DEADS))>)>
		   <COND (<NOT <EMPTY? .DEADS>>
			  <PUTREST .RCODE 
				   (<CHTYPE (`DEAD !.DEADS) FORM> 
				    !<REST .RCODE>)>
			  <SET RCODE <REST .RCODE>>)>
		   <SET RCODE <REST <SET CODE .RCODE>>>)
		  (<TYPE? .INST FORM>
		   <COND (<AND <NOT <EMPTY? .INST>>
			       <OR <AND <==? <SET OP <1 .INST>> `SET>
					<OR <==? <2 .INST> <3 .INST>>
					    <TYPE? <2 .INST> DEAD-VAR>>>
				   <AND <==? .OP `SETLR>
					<TYPE? <2 .INST> DEAD-VAR>>
				   <AND <==? .OP `SETRL>
					<TYPE? <3 .INST> DEAD-VAR>>
				   <AND <SET TMPL <MEMQ = .INST>>
					<TYPE? <2 .TMPL> DEAD-VAR>>>
			       <SETG ANY-FLUSHED-INS T>
			       <COND (<OR <==? .OP `CALL> <==? .OP `ACALL>>
				      <PUTREST <REST .INST <- <LENGTH .INST>
							      <LENGTH .TMPL>
							      1>> ()>
				      <>)
				     (<OR <==? .OP `SCALL> <==? .OP `SYSOP>
					  <==? .OP `SYSCALL>>
				      <PUT .TMPL 2 <CHTYPE <2 .TMPL> ATOM>>
				      <>)
				     (<==? .OP `POP>
				      <PUT .RCODE 1 '<`ADJ -1>>
				      <SET RCODE <REST <SET CODE .RCODE>>>
				      T)
				     (ELSE
				      <PUTREST .CODE
					       <SET RCODE <REST .RCODE>>>
				      T)>>)
			 (ELSE
			  <SET DEADS <FIND-DEADS .INST>>
			  <COND (<NOT <EMPTY? .DEADS>>
				 <PUTREST .RCODE
					  (<FORM `DEAD !.DEADS>
					   !<REST .RCODE>)>
				 <SET RCODE <REST .RCODE>>)>
			  <SET RCODE <REST <SET CODE .RCODE>>>)>)
		  (<NOT <AND <TYPE? .INST LABEL>
			     <TYPE? <SET INST <L-INST .INST>> FORM>
			     <NOT <EMPTY? .INST>>
			     <==? <1 .INST> `ENDIF>>>
		   <SET RCODE <REST <SET CODE .RCODE>>>)>>
	 .VCODE>>

<DEFINE FIND-DEADS (INST:FORM "AUX" OP (PASSED=?:<OR FALSE <LIST ANY>> <>))
   <COND (<NOT <EMPTY? .INST>>
	  <SET OP <1 .INST>>
	  <MAPR ,LIST
		<FUNCTION (RINST "AUX" (ONE <1 .RINST>))
		   <COND (<==? .ONE =>
			  <SET PASSED=? .RINST>
			  <MAPRET>)
			 (<AND .PASSED=?
			       <OR <==? .OP `CALL> <==? .OP `ACALL>>
			       <TYPE? .ONE DEAD-VAR>>
			  <PUTREST <REST .INST
					 <- <LENGTH .INST>
					    <LENGTH .PASSED=?>
					    1>>
				   ()>
			  <MAPSTOP>)
			 (<TYPE? .ONE DEAD-VAR>
			  <SET ONE <CHTYPE .ONE ATOM>>
			  <1 .RINST .ONE>
			  <MAPRET .ONE>)
			 (<AND <TYPE? .ONE FORM>
			       <==? .OP `CHTYPE>
			       <NOT <LENGTH? .ONE 1>>
			       <==? <1 .ONE> `TYPE>
			       <TYPE? <2 .ONE> DEAD-VAR>>
			  <2 .ONE <CHTYPE <2 .ONE> ATOM>>
			  <MAPRET <2 .ONE>>)
			 (ELSE <MAPRET>)>>
		<REST .INST>>)
	 (ELSE ())>>

<DEFINE UV-TO-L (UV:UVECTOR "AUX" (L:LIST ()) (TEMP-OFFS:FIX 0))
	<MAPF <>
	      <FUNCTION (WD)
		   <COND (<N==? .WD 0>
			  <REPEAT ((TNO:FIX <+ .TEMP-OFFS 1>)
				   (MSK:FIX 1))
				  <COND (<N==? <ANDB .MSK .WD> 0>
					 <SET L (<NTH ,NAME-UV .TNO> !.L)>
					 <SET WD <XORB .WD .MSK>>
					 <COND (<==? .WD 0> <RETURN>)>)>
				  <SET TNO <+ .TNO 1>>
				  <SET MSK <LSH .MSK 1>>>)>
		   <SET TEMP-OFFS <+ .TEMP-OFFS 32>>>
	      .UV>
	.L> 

<ENDPACKAGE>
