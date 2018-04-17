<PACKAGE "GC-DUMP-D">

<ENTRY GC-DUMP>

<INCLUDE-WHEN <FEATURE? "COMPILER"> "GC-DUMP-DEFS">

%%<GDECL (PURE-ZONE) <OR ZONE FALSE>>	;"to override GDECL in compiler"

<DEFINE GC-DUMP (OBJ
		 "OPT" (CHAN .OUTCHAN)  ;"default to OUTCHAN (???)"
		 "AUX" GCP NEW-SIZE CZN NEW-ZONE NGCP AL BLOCK BLOCK-LENGTH
		       HEADER NEWOBJ FLAG PZN)
	#DECL ((CHAN) <CHANNEL 'DISK> (OBJ) ANY (GCP NGCP) GC-PARAMS
	       (NEW-SIZE BLOCK-LENGTH) FIX (PZN CZN NEW-ZONE) ZONE 
	       (HEADER) LIST (BLOCK) UVECTOR)
	<COND
	 (<S=? <CHANNEL-OP .CHAN GET-BYTE-SIZE> "BINARY">
	  <IFSYS ("TOPS20"
		  <COND (<AND <GASSIGNED? PURE-ZONE> ,PURE-ZONE>
			 <SET PZN ,PURE-ZONE>
			 <MAPF <>
			       <FUNCTION (A) #DECL ((A) AREA)
				    <DO-SPACS </ <AMIN .A> ,PSIZE>
					      </ <ABOT .A> ,PSIZE>
					      ,M$$COPY-ON-WRITE>>
			       <ALL-SPACES .PZN>>)>)> 
	  <SET GCP <GC-PARAMS <SET CZN ,CURRENT-ZONE>>>
	  ;"calculate how large a zone we (could possibly) need"
	  <SET NEW-SIZE
	       <MAPF ,+
		     <FUNCTION (A) 
			     #DECL ((A) AREA)
			     <COND (<==? <AMIN .A> <GCSMIN .GCP>>
				    <AMAX .A <GCSMAX .GCP>>
				    <ABOT .A <GCSBOT .GCP>>)>
			     <- <ABOT .A> <AMIN .A>>>
		     <ALL-SPACES .CZN>>>
	  <IFSYS ("TOPS20"
		  <SET NEW-SIZE
		       <* 261632 </ <+ .NEW-SIZE 261632 -1> 261632>>>)>
	  ;"create the new zone"
	  <SETG NEW-ZONE
		<SET NEW-ZONE
		     <CREATE-NEW-GC-SPACE  ;"change to CREATE-NEW-SPACE ???"
		      <LSH .NEW-SIZE <- ,ADDR-SHIFT>> <GC-CTL .CZN>>>>
	  <SETG AL <GCSMIN <SET NGCP <GC-PARAMS .NEW-ZONE>>>>
	  <SETG SPACE-END <GCSMAX .NGCP>>
	  <SETG WORDS-NEEDED 0>
	  ;"WORDS-NEEDED counts how many words of memory might be needed
	    by GC-READ when it reads in this object."
	  <SETG NUMBER-OF-NEWTYPES 0>
	  <SET FLAG
	       <PROG DUMP-FRAME ()
		  #DECL ((DUMP-FRAME) <SPECIAL FRAME>)
		  ;"Provide DUMP-FRAME as an emergency exit"
		  <SET NEWOBJ <DUMP .OBJ>>
		  %<>>>
	  <UNMARK .OBJ>  ;"whether dump succeeded or not, clean up"
	  <IFSYS ("TOPS20"
		  <COND (<ASSIGNED? PZN>
			 <MAPF <>
			       <FUNCTION (A) #DECL ((A) AREA)
				    <DO-SPACS </ <AMIN .A> ,PSIZE>
					      </ <ABOT .A> ,PSIZE>
					      ,M$$READ-ONLY-EXECUTE>>
			       <ALL-SPACES .PZN>>)>)>
	  <COND (<TYPE? .FLAG ATOM> ;"if general error occured"
		 <FLUSH-ZONE .NEW-ZONE>
		 <ERROR .FLAG GC-DUMP>)
		(.FLAG ;"if he tried to dump something on the stack"
		 <FLUSH-ZONE .NEW-ZONE>
		 <ERROR UNDUMPABLE-OBJECT!-ERRORS .FLAG GC-DUMP>)
		(ELSE ;"winnage"
		 <SET HEADER <CALL ALLOCL ,AL>>
		 <PUT .HEADER 1 .NEWOBJ>
		 <PUTREST .HEADER .HEADER>
		 ;"dump one more object, the `header', a circular list of one
		   element, the object dumped"
		 <SET BLOCK-LENGTH
		      <LSH <- <+ ,AL <LSH ,LENGTH-LIST ,ADDR-SHIFT>>
			      <GCSMIN .NGCP>>
			   <- ,ADDR-SHIFT>>>
		 <SET BLOCK
		      <CALL OBJECT
			    ,TYPE-C-UVECTOR
			    .BLOCK-LENGTH
			    <GCSMIN .NGCP>>>
		 ;"create a uvector out of the dumped object"
		 <CHANNEL-OP .CHAN WRITE-BYTE ,NUMBER-OF-NEWTYPES>
		 <CHANNEL-OP .CHAN WRITE-BYTE ,WORDS-NEEDED>
		 <CHANNEL-OP .CHAN WRITE-BYTE .BLOCK-LENGTH>
		 <CHANNEL-OP .CHAN WRITE-BUFFER .BLOCK>
		 ;"write the data to the file"
		 <FLUSH-ZONE .NEW-ZONE>
		 .OBJ)>)
	 (ELSE <ERROR CHANNEL-HAS-WRONG-BYTE-SIZE!-ERRORS GC-DUMP>)>>

<DEFINE DUMP (X "AUX" (FTYP <ANDB <CALL TYPE .X> 7>) PTYP) 
	#DECL ((X) ANY (FTYP) FIX (PTYP) ATOM)
	<CASE ,==?
	      .FTYP
	      (,STYPE-FIX <DUMP-NEWTYPE? .X> .X)
	      (,STYPE-UVECTOR <DUMP-UVECTOR .X>)
	      (,STYPE-STRING <DUMP-STRING .X>)
	      (,STYPE-BYTES <DUMP-BYTES .X>)
	      (,STYPE-VECTOR <DUMP-VECTOR .X>)
	      (,STYPE-LIST <DUMP-LIST .X>)
	      (,STYPE-RECORD
	       <SET PTYP <PRIMTYPE .X>>
	       <COND (<==? .PTYP ATOM> <DUMP-ATOM .X>)
		     (<==? .PTYP GBIND> <DUMP-GBIND .X>)
		     (ELSE <RETURN .X .DUMP-FRAME>)>)
	      DEFAULT
	      (<RETURN .X .DUMP-FRAME>)>>

<DEFINE DUMP-NEWTYPE? (OBJ
		       "AUX" (TYP <LSH <CALL TYPE .OBJ> -6>) TYP-ATM PTYP-ATM
			     ENTRY)
	#DECL ((OBJ) ANY (TYP) FIX (ENTRY) TYPE-ENTRY (TYP-ATM PTYP-ATM) ATOM)
	<COND (<G? .TYP ,OLD-TYPES> ;"if the object is a newtype"
	       <SET ENTRY <NTH ,M$$TYPE-INFO!-INTERNAL <+ .TYP 1>>>
	       <SET TYP-ATM <DUMP-ATOM <M$$NTYPE .ENTRY>>>
	       ;"dump the atom naming the type (or get a pointer to it if it"
	       ;"already has been dumped)"
	       <COND (<NOT <M$$GVAL .TYP-ATM>>
		      ;"if the atom does not have a GVAL (which marks it as"
		      ;"being the name of a newtype)"
		      <SETG NUMBER-OF-NEWTYPES <+ ,NUMBER-OF-NEWTYPES 1>>
		      <SETG WORDS-NEEDED <+ ,WORDS-NEEDED ,LENGTH-TYPE-ENTRY>>
		      <SET PTYP-ATM <DUMP-ATOM <M$$PTYPE .ENTRY>>>
		      ;"then dump the atom naming the primtype"
		      <M$$GVAL .TYP-ATM
			       <CALL OBJECT
				     ,TYPE-C-GBIND
				     ,LENUU-GBIND
				     <CALL VALUE .PTYP-ATM>>>
		      ;"and shove it (directly) into the GVAL slot")>
	       T)>>

<DEFINE DUMP-VECTOR (V "AUX" (TOP-V <CALL TOPU .V>) FX NEW-V OLD-AL NEW-AL)
        ;"the classic case"
	#DECL ((V) <PRIMTYPE VECTOR> (TOP-V NEW-V) VECTOR
	       (FX NEW-AL OLD-AL) <OR FIX VECTOR>)
	<SET FX <CALL MARKUV? .TOP-V 1>> ;"see if the object is marked"
	<COND (<TYPE? .FX FIX> ;"if not"
	       <DUMP-NEWTYPE? .V> ;"take care of the object if it is a newtype"
	       <SET OLD-AL ,AL> ;"remember where we now are in the zone"
	       <CALL MARKUV .TOP-V <SET NEW-V <CALL ALLOCUV .OLD-AL .TOP-V>>>
	       ;"mark the old vector to point to where the new vector will be"
	       <SET NEW-AL
		    <+ .OLD-AL <LSH <+ <* <LENGTH .TOP-V> 2> 2> ,ADDR-SHIFT>>>
	       ;"calculate where this will put us in the zone"
	       <COND (<G? .NEW-AL ,SPACE-END>
		      ;"if we would run out of room, error"
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE ;"otherwise, make it official"
		      <SETG AL .NEW-AL>)>
	       <CALL BLT .TOP-V .NEW-V <+ <* <LENGTH .TOP-V> 2> 2>>
	       ;"actually copy the object"
	       <CALL MARKUV .NEW-V 0>
	       ;"unmark it (since we copied a marked object, this is"
	       ;"necessary)"
	       <MAPR %<> ;"dump the elements of the old vector and shove the"
			 ;"results into the new vector"
		     <FUNCTION (RV) 
			     #DECL ((RV) VECTOR)
			     <PUT .RV 1 <DUMP <1 .RV>>>>
		     .NEW-V>)
	      (ELSE ;"if the object has already been dumped, return it"
	       <SET NEW-V .FX>)>
	;"return an object of the correct length and type"
	<CHTYPE <REST .NEW-V <- <LENGTH .TOP-V> <LENGTH .V>>> <TYPE .V>>>

<DEFINE DUMP-UVECTOR (UV
		      "AUX" (TOP-UV <CALL TOPU .UV>) FX NEW-UV OLD-AL NEW-AL)
	#DECL ((UV) <PRIMTYPE UVECTOR> (TOP-UV NEW-UV) UVECTOR
	       (FX) <OR FIX UVECTOR> (NEW-AL OLD-AL) FIX)
	<SET FX <CALL MARKUU? .TOP-UV 1>>
	<COND (<TYPE? .FX FIX>
	       <DUMP-NEWTYPE? .UV>
	       <SET OLD-AL ,AL>
	       <CALL MARKUU
		     .TOP-UV
		     <SET NEW-UV <CALL ALLOCUU .OLD-AL .TOP-UV>>>
	       <SET NEW-AL
		    <+ .OLD-AL <LSH <+ <LENGTH .TOP-UV> 2> ,ADDR-SHIFT>>>
	       <COND (<G? .NEW-AL ,SPACE-END>
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE <SETG AL .NEW-AL>)>
	       <CALL BLT .TOP-UV .NEW-UV <+ <LENGTH .TOP-UV> 2>>
	       <CALL MARKUU .NEW-UV 0>)
	      (ELSE <SET NEW-UV .FX>)>
	<CHTYPE <REST .NEW-UV <- <LENGTH .TOP-UV> <LENGTH .UV>>> <TYPE .UV>>>

<DEFINE DUMP-STRING (S "AUX" TOP-S FX NEW-S WL OLD-AL NEW-AL) 
	#DECL ((S) <PRIMTYPE STRING> (TOP-S NEW-S) STRING (FX) <OR FIX STRING>
	       (WL NEW-AL OLD-AL) FIX)
	<SET TOP-S <CALL TOPU .S>>
	<SET FX <CALL MARKUS? .TOP-S 1>>
	<COND (<TYPE? .FX FIX>
	       <DUMP-NEWTYPE? .S>
	       <SET OLD-AL ,AL>
	       <SET WL <+ </ <+ <LENGTH .TOP-S> ,CHARS-WD-1> ,CHARS-WD> 2>>
	       <CALL MARKUS .TOP-S <SET NEW-S <CALL ALLOCUS .OLD-AL .TOP-S>>>
	       <SET NEW-AL <+ .OLD-AL <LSH .WL ,ADDR-SHIFT>>>
	       <COND (<G? .NEW-AL ,SPACE-END>
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE <SETG AL .NEW-AL>)>
	       <CALL BLT <ADDR-S .TOP-S> <ADDR-S .NEW-S> .WL>
	       <CALL MARKUS .NEW-S 0>)
	      (ELSE <SET NEW-S .FX>)>
	<CHTYPE <REST .NEW-S <- <LENGTH .TOP-S> <LENGTH .S>>> <TYPE .S>>>

<DEFINE DUMP-BYTES (BS "AUX" TOP-BS NEW-BS FX WL OLD-AL NEW-AL) 
	#DECL ((BS) <PRIMTYPE BYTES> (TOP-BS NEW-BS) BYTES (FX) <OR FIX BYTES>
	       (WL NEW-AL OLD-AL) FIX)
	<SET TOP-BS <CALL TOPU .BS>>
	<SET FX <CALL MARKUB? .TOP-BS 1>>
	<COND (<TYPE? .FX FIX>
	       <DUMP-NEWTYPE? .BS>
	       <SET OLD-AL ,AL>
	       <SET WL <+ </ <+ <LENGTH .TOP-BS> ,BYTES-WD-1> ,BYTES-WD> 2>>
	       <CALL MARKUB
		     .TOP-BS
		     <SET NEW-BS <CALL ALLOCUB .OLD-AL .TOP-BS>>>
	       <SET NEW-AL <+ .OLD-AL <LSH .WL ,ADDR-SHIFT>>>
	       <COND (<G? .NEW-AL ,SPACE-END>
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE <SETG AL .NEW-AL>)>
	       <CALL BLT <ADDR-S .TOP-BS> <ADDR-S .NEW-BS> .WL>
	       <CALL MARKUB .NEW-BS 0>)
	      (ELSE <SET NEW-BS .FX>)>
	<CHTYPE <REST .NEW-BS <- <LENGTH .TOP-BS> <LENGTH .BS>>> <TYPE .BS>>>

;"Note that the code to dump (and unmark) lists is extremely hairy because 
  lists don't have relocation fields, which we need, yet we cannot permenantly 
  mung the old list.  

Solution:

1.  Dump the list as usual.

--------------------------         --------------------------
| rest of old list       |         | rest of new list       |
--------------------------         --------------------------
| type-c     | length    |         | type-c     | length    |
--------------------------         --------------------------
| pointer to old element |         | pointer to new element |
--------------------------         --------------------------

2.  Use the rest pointer of the old list as the relocation pointer (as is done
in the copy-gc).  However, store the old rest pointer (which will need to be
restored) in the type-c and length slots of the new list.

--------------------------         --------------------------
| pointer to new list    |         | rest of new list       |
--------------------------         --------------------------
| type-c     | length    |         | rest of old list       |
--------------------------         --------------------------
| pointer to old element |         | pointer to new element |
--------------------------         --------------------------

3.  During the unmarking phase, copy the old rest pointer from the new list to
the old list and copy the type-c and length from the new list to the old list.

--------------------------         --------------------------
| rest of old list       |         | rest of new list       |
--------------------------         --------------------------
| type-c     | length    |         | type-c     | length    |
--------------------------         --------------------------
| pointer to old element |         | pointer to new element |
--------------------------         --------------------------"

<DEFINE DUMP-LIST (L "AUX" NEW-L REST-L OLD-AL NEW-AL) 
	#DECL ((L) <PRIMTYPE LIST> (NEW-L REST-L) LIST (OLD-AL NEW-AL) FIX)
	<COND (<EMPTY? .L> <DUMP-NEWTYPE? .L> <SET NEW-L .L>)
	      (<==? <CALL MARKL? .L> 0>
	       <DUMP-NEWTYPE? .L>
	       <SET OLD-AL ,AL>
	       <SET NEW-L <CALL ALLOCL .OLD-AL>>
	       <SET NEW-AL <+ .OLD-AL <LSH ,LENGTH-LIST ,ADDR-SHIFT>>>
	       <COND (<G? .NEW-AL ,SPACE-END>
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE <SETG AL .NEW-AL>)>
	       <SET REST-L <REST .L>>
	       <PUTREST .NEW-L .REST-L>
	       <PUT .NEW-L 1 <1 .L>>
	       <CALL MARKL .L 1>
	       <PUTREST .L .NEW-L>
	       <PUTREST .NEW-L <DUMP .REST-L>>
	       <PUT .NEW-L
		    1
		    <CALL OBJECT
			  <LHW <CALL VALUE .REST-L>>
			  <RHW <CALL VALUE .REST-L>>
			  <CALL VALUE <DUMP <1 .NEW-L>>>>>)
	      (ELSE <SET NEW-L <REST .L>>)>
	<CHTYPE .NEW-L <TYPE .L>>>

<DEFINE DUMP-ATOM (ATM "AUX" OLD-AL NEW-AL FX NEW-ATM) 
	#DECL ((ATM NEW-ATM) <PRIMTYPE ATOM> (OLD-AL NEW-AL) FIX
	       (FX) <OR FIX ATOM>)
	<COND (<==? <CHTYPE .ATM ATOM> ROOT>
	       <SET NEW-ATM <CALL OBJECT <CALL TYPE .ATM> ,LENUU-ATOM -1>>)
	      (<TYPE? <SET FX <CALL MARKR? .ATM 1>> FIX>
	       <DUMP-NEWTYPE? .ATM>
	       <SET OLD-AL ,AL>
	       <SETG WORDS-NEEDED <+ ,WORDS-NEEDED ,LENGTH-LIST>>
	       <CALL MARKR .ATM <SET NEW-ATM <CALL ALLOCR .OLD-AL .ATM>>>
	       <SET NEW-AL <+ .OLD-AL <LSH ,LENGTH-ATOM ,ADDR-SHIFT>>>
	       <COND (<G? .NEW-AL ,SPACE-END>
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE <SETG AL .NEW-AL>)>
	       <CALL BLT .ATM .NEW-ATM ,LENGTH-ATOM>
	       <CALL MARKR .NEW-ATM 0>
	       <M$$GVAL .NEW-ATM %<>> 
	       <M$$LVAL .NEW-ATM %<>>
	       ;"don't dump GVALs or LVALs"
	       ;"Note:  The gval slot IS used to store the primtypes of"
	       ;"newtypes, but that is done by DUMP-NEWTYPE?"
	       <M$$PNAM .NEW-ATM <DUMP-STRING <M$$PNAM .NEW-ATM>>>
	       <M$$OBLS .NEW-ATM <DUMP <M$$OBLS .NEW-ATM>>>)
	      (ELSE <SET NEW-ATM .FX>)>
	.NEW-ATM>

<DEFINE DUMP-GBIND (GB "AUX" NGB OLD-AL NEW-AL FX) 
	#DECL ((GB NGB) <PRIMTYPE GBIND> (FX) <OR FIX GBIND>
	       (OLD-AL NEW-AL) FIX)
	<COND (<TYPE? <SET FX <CALL MARKR? .GB 1>> FIX>
	       <DUMP-NEWTYPE? .GB>
	       <SET OLD-AL ,AL>
	       <CALL MARKR .GB <SET NGB <CALL ALLOCR .OLD-AL .GB>>>
	       <SET NEW-AL <+ .OLD-AL <LSH ,LENGTH-GBIND ,ADDR-SHIFT>>>
	       <COND (<G? .NEW-AL ,SPACE-END>
		      <RETURN NO-MORE-ROOM!-ERRORS .DUMP-FRAME>)
		     (ELSE <SETG AL .NEW-AL>)>
	       <CALL BLT .GB .NGB ,LENGTH-GBIND>
	       <CALL MARKR .NGB 0>
	       <M$$VALU .NGB ,M$$UNBOUND>
	       <M$$ATOM .NGB <DUMP <M$$ATOM .NGB>>>
	       <M$$DECL .NGB %<>>
	       ;"don't dump the decl of gbinds")
	      (ELSE <SET NGB .FX>)>
	.NGB>

<DEFINE UNMARK (OBJ "AUX" FX WEIRD FTYP PTYP)
        ;"unmark objects in general and repair lists in particular"
	#DECL ((OBJ WEIRD) ANY (FX) <OR FIX LIST> (PTYP) ATOM (FTYP) FIX)
	<BIND ((TYP <LSH <CALL TYPE .OBJ> -6>) ENTRY)
	   <COND (<G? .TYP ,OLD-TYPES>
		  <SET ENTRY <NTH ,M$$TYPE-INFO!-INTERNAL <+ .TYP 1>>>
		  <UNMARK <M$$NTYPE .ENTRY>>
		  <UNMARK <M$$PTYPE .ENTRY>>)>>
	<SET FTYP <ANDB <CALL TYPE .OBJ> 7>>
	<CASE ,==?
	      .FTYP
	      (,STYPE-UVECTOR <CALL MARKUU .OBJ 0>)
	      (,STYPE-STRING <CALL MARKUS .OBJ 0>)
	      (,STYPE-BYTES <CALL MARKUB .OBJ 0>)
	      (,STYPE-VECTOR
	       <COND (<NOT <TYPE? <CALL MARKUV? .OBJ 1> FIX>>
		      <CALL MARKUV .OBJ 0>
		      <MAPF %<> ,UNMARK <CHTYPE .OBJ VECTOR>>)>)
	      (,STYPE-LIST
	       <COND (<N==? <CALL MARKL? .OBJ> 0>
		      <SET FX <REST .OBJ>>
		      <SET WEIRD <1 .FX>>
		      <PUTREST .OBJ
			       <CALL OBJECT
				     ,TYPE-C-LIST
				     0
				     <PUTLHW <CALL LENUU .WEIRD>
					     <CALL TYPE .WEIRD>>>>
		      <PUT .FX
			   1
			   <CALL OBJECT
				 <CALL TYPE <1 .OBJ>>
				 <CALL LENUU <1 .OBJ>>
				 <CALL VALUE .WEIRD>>>
		      <CALL MARKL .OBJ 0>
		      <CALL MARKL .FX 0>
		      <UNMARK <1 .OBJ>>
		      <UNMARK <REST .OBJ>>)>)
	      (,STYPE-RECORD
	       <SET PTYP <PRIMTYPE .OBJ>>
	       <COND (<==? .PTYP ATOM>
		      <COND (<NOT <TYPE? <CALL MARKR? .OBJ 1> FIX>>
			     <CALL MARKR .OBJ 0>
			     <UNMARK <M$$PNAM <CHTYPE .OBJ ATOM>>>
			     <UNMARK <M$$OBLS <CHTYPE .OBJ ATOM>>>)>)
		     (<==? .PTYP GBIND>
		      <COND (<NOT <TYPE? <CALL MARKR? .OBJ 1> FIX>>
			     <CALL MARKR .OBJ 0>
			     <UNMARK <M$$ATOM <CHTYPE .OBJ GBIND>>>)>)>)>
	T>

<DEFINE DO-SPACS (START LAST MODE) 
   #DECL ((START LAST MODE) FIX)
   <REPEAT ()
      <IFSYS ("TOPS20"
	      <CALL SYSOP SPACS <ORB ,M$$MY-PROC-LH .START> .MODE>)>
      <COND (<==? .START .LAST> <RETURN>)>
      <SET START <+ .START 1>>>>

<ENDPACKAGE>
