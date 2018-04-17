
<PACKAGE "CHKDCL">

<ENTRY MTYPR
       TYPE-AND
       TYPE-OK?
       TASTEFUL-DECL
       GET-ELE-TYPE
       STRUCTYP
       STRUCTYP-SEG
       TYPE-ATOM-OK?
       ISTYPE-GOOD?
       TYPE-MERGE
       DEFERN
       TOP-TYPE
       ISTYPE?
       TYPESAME
       ANY-PAT
       STRUC
       GETBSYZ
       GEN-DECL
       REST-DECL
       MINL
       GET-RANGE
       PRIMITIVE-TYPE
       INTERPRETER-IMPLEMENTOR?
       DECL-GET
       BOOLEAN
       BOOL-TRUE
       BOOL-FALSE
       MAXL>

<PUT-DECL BOOLEAN '<OR ATOM !<FALSE>>>

<PUT-DECL BOOL-TRUE ATOM>

<PUT-DECL BOOL-FALSE '!<FALSE>>

<USE "COMPDEC" "ADVMESS">

<SETG INTERPRETER-IMPLEMENTOR? T>

<SETG DECL-RESTED 1>

<SETG DECL-ELEMENT 2>

<SETG DECL-ITEM-COUNT 3>

<SETG DECL-IN-REST 4>

<SETG DECL-IN-COUNT-VEC 5>

<SETG DECL-REST-VEC 6>

<MANIFEST DECL-RESTED
	  DECL-ELEMENT
	  DECL-ITEM-COUNT
	  DECL-IN-REST
	  DECL-IN-COUNT-VEC
	  DECL-REST-VEC>

<SETG HIGHBOUND 2>

<SETG LOWBOUND 1>

<MANIFEST HIGHBOUND LOWBOUND>

<SETG ALLWORDS '<PRIMTYPE WORD>>

<DEFINE TASTEFUL-DECL (D "AUX" TEM TT) 
	<COND (<OR <NOT .D> <==? .D NO-RETURN>> ANY)
	      (<AND <TYPE? .D ATOM> <VALID-TYPE? .D>> .D)
	      (<AND <OR <TYPE? <SET TEM .D> ATOM> <SET TEM <ISTYPE? .D>>>
		    <SET TT <DECL-GET .TEM>>>
	       <COND (<OR <==? .TEM BOOLEAN>
			  <==? .TEM BOOL-FALSE>
			  <==? .TEM BOOL-TRUE>>
		      .TT)
		     (ELSE .TEM)>)
	      (<TYPE? .D FORM SEGMENT>
	       <COND (<LENGTH? .D 1>
		      <OR <AND <EMPTY? .D> ANY> <TASTEFUL-DECL <1 .D>>>)
		     (<==? <1 .D> FIX> FIX)
		     (<AND <==? <LENGTH .D> 2> <==? <1 .D> NOT>> ANY)
		     (<TYPE? .D SEGMENT>
		      <CHTYPE <MAPF ,LIST ,TASTEFUL-DECL .D> SEGMENT>)
		     (ELSE <CHTYPE <MAPF ,LIST ,TASTEFUL-DECL .D> FORM>)>)
	      (<TYPE? .D VECTOR>
	       [<COND (<==? <1 .D> OPT> OPTIONAL) (ELSE <1 .D>)>
		!<MAPF ,LIST ,TASTEFUL-DECL <REST .D>>])
	      (ELSE .D)>>

<DEFINE TMERGE (P1 P2 "AUX" TEM) 
	<COND (<OR <==? .P1 ANY> <==? .P2 ANY>> ANY)
	      (<==? .P1 .P2> .P1)
	      (<AND <TYPE? .P1 FORM>
		    <==? <LENGTH .P1> 2>
		    <==? <1 .P1> NOT>
		    <OR <AND <==? <2 .P1> ANY> .P2> ANY>>)
	      (<AND <TYPE? .P2 FORM>
		    <==? <LENGTH .P2> 2>
		    <==? <1 .P2> NOT>
		    <OR <AND <==? <2 .P2> ANY> .P1> ANY>>)
	      (<AND <TYPE? .P1 ATOM>
		    <TYPE? .P2 ATOM>
		    <OR <==? .P1 BOOL-TRUE>
			<==? .P1 BOOL-FALSE>
			<==? .P1 BOOLEAN>>
		    <OR <==? .P2 BOOL-TRUE>
			<==? .P2 BOOL-FALSE>
			<==? .P2 BOOLEAN>>>
	       BOOLEAN)
	      (<OR <AND <TYPE? .P1 FORM SEGMENT>
			<==? <LENGTH .P1> 2>
			<TYPE? <2 .P1> LIST>>
		   <AND <TYPE? .P2 FORM SEGMENT>
			<==? <LENGTH .P2> 2>
			<TYPE? <2 .P2> LIST>>
		   <CTMATCH .P1 .P2 <> <> T>>
	       <CTMATCH .P1 .P2 T T <>>)
	      (ELSE <CHTYPE (OR !<PUT-IN <PUT-IN () .P1> .P2>) FORM>)>>

<DEFINE TYPE-AND (P1 P2)
	<COND (<NOT .P1> <SET P1 ANY>)>
	<COND (<NOT .P2> <SET P2 ANY>)>
	<COND (<==? .P1 ANY> .P2)
	      (<==? .P2 ANY> .P1)
	      (<==? .P1 .P2> .P1)
	      (ELSE <CTMATCH .P1 .P2 T <> <>>)>>

<DEFINE TMATCH (P1 P2)
	<COND (<==? .P1 ANY> .P2)
	      (<==? .P2 ANY> .P1)
	      (<==? .P1 .P2> .P1)
	      (ELSE <CTMATCH .P1 .P2 <> <> <>>)>>

<DEFINE CTMATCH (P1 P2 ANDF ORF MAYBEF "AUX" X) 
	#DECL ((ANDF ORF MAYBEF) <SPECIAL <OR FALSE ATOM>>)
	<DTMATCH .P1 .P2>>

<DEFINE DTMATCH (PAT1 PAT2 "AUX" (ORF .ORF) FP1 FP2) 
	<OR .PAT1 <SET PAT1 ANY>>
	<OR .PAT2 <SET PAT2 ANY>>
	<COND (<==? .PAT2 BOOLEAN> <SET PAT2 .PAT1> <SET PAT1 BOOLEAN>)
	      (<==? .PAT2 BOOL-TRUE> <SET PAT2 .PAT1> <SET PAT1 BOOL-TRUE>)
	      (<==? .PAT2 BOOL-FALSE> <SET PAT2 .PAT1> <SET PAT1 BOOL-FALSE>)>
	<COND (<OR <==? .PAT1 .PAT2>
		   <AND <OR <AND <TYPE? .PAT1 FORM> <TYPE? .PAT2 FORM>>
			    <AND <TYPE? .PAT1 SEGMENT> <TYPE? .PAT2 SEGMENT>>>
			<==? <LENGTH <CHTYPE .PAT1 LIST>>
			     <LENGTH <CHTYPE .PAT2 LIST>>>
			<==? <CALL TYPE <SET FP1 <1 <CHTYPE .PAT1 LIST>>>>
			     <CALL TYPE <SET FP2 <1 <CHTYPE .PAT2 LIST>>>>>
			<COND (<TYPE? .FP1 ATOM> <==? .FP1 .FP2>) (ELSE T)>
			<=? .PAT1 .PAT2>>>
	       .PAT1)
	      (<AND <==? .PAT1 BOOLEAN>
		    <OR <AND .ORF
			     <OR <==? .PAT2 BOOL-TRUE> <==? .PAT2 BOOL-FALSE>>
			     BOOLEAN>
			<AND <NOT .ORF>
			     <OR <AND <==? .PAT1 BOOL-TRUE> BOOL-TRUE>
				 <AND <==? .PAT2 BOOL-FALSE> BOOL-FALSE>>>>>)
	      (<AND <NOT .ORF> <==? .PAT1 BOOL-FALSE>>
	       <COND (<TEXP1 '!<FALSE> .PAT2> BOOL-FALSE)>)
	      (<AND <NOT .ORF> <==? .PAT1 BOOL-TRUE>>
	       <COND (<TYPMAT ATOM .PAT2> BOOL-TRUE)>)
	      (<AND <NOT .ORF> <==? .PAT1 BOOLEAN>>
	       <COND (<TYPMAT ATOM .PAT2>
		      <COND (<TEXP1 '!<FALSE> .PAT2> BOOLEAN)
			    (ELSE BOOL-TRUE)>)
		     (<TEXP1 '!<FALSE> .PAT2> BOOL-FALSE)>)
	      (<TYPE? <SET PAT1 <VTS .PAT1>> ATOM> <TYPMAT .PAT1 <VTS .PAT2>>)
	      (<TYPE? <SET PAT2 <VTS .PAT2>> ATOM> <TYPMAT .PAT2 .PAT1>)
	      (<AND <TYPE? .PAT1 FORM SEGMENT> <TYPE? .PAT2 FORM SEGMENT>>
	       <TEXP1 .PAT1 .PAT2>)
	      (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>>

<DEFINE VTS (X) 
	<OR <AND <TYPE? .X ATOM>
		 <OR <VALID-TYPE? .X>
		     <==? .X ANY>
		     <==? .X STRUCTURED>
		     <==? .X MULTI>
		     <==? .X APPLICABLE>>
		 .X>
	    <AND <TYPE? .X ATOM> <DECL-GET .X>>
	    .X>>

<DEFINE 2-ELEM (OBJ) 
	#DECL ((OBJ) <PRIMTYPE LIST>)
	<AND <NOT <EMPTY? .OBJ>> <NOT <EMPTY? <REST .OBJ>>>>>

<DEFINE TYPMAT (TYP PAT "AUX" TEM TT (ORF .ORF)) 
	#DECL ((TYP) ATOM)
	<OR <SET TEM
		 <COND (<TYPE? .PAT ATOM>
			<OR <AND <==? .PAT ANY> <COND (.ORF ANY) (ELSE .TYP)>>
			    <AND <==? .TYP ANY> <COND (.ORF ANY) (ELSE .PAT)>>
			    <AND <==? .PAT .TYP> .TYP>
			    <AND <==? <GETPROP .PAT ALT-DECL '.PAT>
				      <SET TT <GETPROP .TYP ALT-DECL '.TYP>>>
				 <COND (.ORF
					<COND (<==? .TT .TYP> .PAT)
					      (ELSE .TYP)>)
				       (ELSE .TT)>>
			    <STRUC .TYP .PAT T>
			    <STRUC .PAT .TYP <>>>)
		       (<TYPE? .PAT FORM SEGMENT> <TEXP1 .PAT .TYP>)
		       (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>>
	    <AND <EMPTY? .TEM>
		 <OR <AND <N==? <SET TEM <VTS .TYP>> .TYP> <DTMATCH .TEM .PAT>>
		     <AND <N==? <SET TEM <VTS .PAT>> .PAT>
			  <TYPMAT .TYP .TEM>>>>>>

""

<DEFINE TEXP1 (FORT PAT "AUX" FST) 
	#DECL ((FORT) <OR FORM SEGMENT>)
	<COND (<EMPTY? .FORT> #FALSE (EMPTY-TYPE-FORM!-ERRORS))
	      (<OR <==? <SET FST <1 .FORT>> OR>
		   <==? .FST AND>
		   <==? .FST NOT>
		   <==? .FST PRIMTYPE>>
	       <ACTORT .FORT .PAT>)
	      (<AND <==? .FST QUOTE>
		    <==? <LENGTH .FORT> 2>>
	       <DTMATCH <GEN-DECL <2 .FORT>> .PAT>)
	      (ELSE <FORMATCH .FORT .PAT>)>>

<DEFINE ACTORT (FORT PAT "AUX" (ACTOR <1 .FORT>) TEM1 (ORF .ORF) (ANDF .ANDF)) 
   #DECL ((FORT) <PRIMTYPE LIST>)
   <COND
    (<==? .ACTOR OR>
     <COND
      (<EMPTY? <SET FORT <REST .FORT>>> #FALSE (EMPTY-OR-MATCH!-ERRORS))
      (ELSE
       <REPEAT (TEM (AL ()))
	 #DECL ((AL) LIST)
	 <COND
	  (<OR <AND <TYPE? <SET TEM <1 .FORT>> ATOM>
		    <PROG ()
			  <COND (<VALID-TYPE? .TEM>)
				(<SET TEM1 <DECL-GET .TEM>>
				 <SET TEM .TEM1>
				 <AND <TYPE? .TEM ATOM> <AGAIN>>)
				(ELSE T)>>
		    <SET TEM <TYPMAT .TEM .PAT>>>
	       <AND <TYPE? .TEM FORM SEGMENT> <SET TEM <TEXP1 .TEM .PAT>>>>
	   <COND (.ANDF
		  <COND (.TEM
			 <COND (<==? .TEM ANY> <RETURN ANY>)>
			 <COND (.ORF <SET AL <PUT-IN .AL .TEM>>)
			       (ELSE
				<OR <MEMBER .TEM .AL>
				    <SET AL (.TEM !.AL)>>)>)>)
		 (ELSE <RETURN T>)>)
	  (<NOT <EMPTY? .TEM>> <RETURN .TEM>)>
	 <COND (<EMPTY? <SET FORT <REST .FORT>>>
		<RETURN <AND <NOT <EMPTY? .AL>>
			     <COND (<EMPTY? <REST .AL>> <1 .AL>)
				   (ELSE
				    <ORSORT <CHTYPE (.ACTOR !.AL)
						    FORM>>)>>>)>>)>)
    (<==? .ACTOR NOT> <NOT-IT .FORT .PAT>)
    (ELSE <PTACT .FORT .PAT>)>>

<DEFINE PTACT (FORTYP PAT) 
	<COND (<TYPE? .FORTYP FORM SEGMENT>
	       <COND (<AND <==? <LENGTH .FORTYP> 2> <==? <1 .FORTYP> PRIMTYPE>>
		      <PRIMATCH .FORTYP .PAT>)
		     (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>)
	      (<TYPE? .FORTYP ATOM> <TYPMAT .FORTYP .PAT>)
	      (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>>

""
<DEFINE STRUC (WRD TYP ACTAND "AUX" TC) 
	#DECL ((TYP) ATOM)
	<PROG (MT)
	 <COND (<COND (<==? .WRD STRUCTURED>
		       <COND (<==? .TYP APPLICABLE>
			      <RETURN <COND (.ORF '<OR APPLICABLE STRUCTURED>)
					    (ELSE
					     '<OR MSUBR
						  T$MSUBR
						  FUNCTION
						  T$FUNCTION
						  MACRO
						  T$MACRO>)>>)
			     (<AND <SET TC <VALID-TYPE? .TYP>>
			      <OR <==? <SET TC <ANDB .TC 7>> 1>
				  <G? .TC 3>
				  <AND ,INTERPRETER-IMPLEMENTOR?
				       <==? .TC 2>
				       <SET MT <GC-PRIMTYPE <TYPE-C .TYP>>>
				       <OR <==? .MT ATOM>
					   <==? .MT GBIND>
					   <==? .MT LBIND>
					   <==? .MT FRAME>>>>>)>)
		 (<==? .WRD APPLICABLE>
		  <COND (<==? .TYP STRUCTURED>
			 <RETURN <STRUC .TYP .WRD .ACTAND>>)
			(<MEMQ .TYP
			       '[MSUBR T$MSUBR FUNCTION T$FUNCTION MACRO
				 T$MACRO OFFSET T$OFFSET FIX]>)>)>
	   <COND (.ORF .WRD) (ELSE .TYP)>)
	  (ELSE
	   <COND (<AND .ORF <NOT .ACTAND>> <ORSORT <FORM OR .WRD .TYP>>)
		 (ELSE <>)>)>>>

<DEFINE PRIMATCH (PTYP PAT "AUX" PAT1 ACTOR TEM (ORF .ORF) (ANDF .ANDF)) 
	#DECL ((PAT1) <PRIMTYPE LIST>
	       (PTYP) <OR <FORM ANY ANY> <SEGMENT ANY ANY>>)
	<COND (<AND <TYPE? .PAT FORM SEGMENT>
		    <SET PAT1 .PAT>
		    <==? <LENGTH .PAT1> 2>
		    <==? <1 .PAT1> PRIMTYPE>>
	       <COND (<OR <==? <2 .PAT1> <2 .PTYP>>
			  <==? <GC-PRIMTYPE <TYPE-C <2 .PAT1>>>
			       <GC-PRIMTYPE <TYPE-C <2 .PTYP>>>>>
		      .PAT1)
		     (ELSE <COND (.ORF <ORSORT <FORM OR .PAT1 .PTYP>>)>)>)
	      (<TYPE? .PAT ATOM>
	       <COND (<==? .PAT ANY> <COND (.ORF ANY) (.ANDF .PTYP) (ELSE T)>)
		     (<OR <==? .PAT STRUCTURED> <==? .PAT APPLICABLE>>
		      <COND (<STRUC .PAT <2 .PTYP> T>
			     <COND (.ORF .PAT) (ELSE .PTYP)>)
			    (ELSE
			     <COND (.ORF <ORSORT <FORM OR .PAT .PTYP>>)>)>)
		     (<COND (<VALID-TYPE? .PAT>
			     <COND (<==? <GC-PRIMTYPE <TYPE-C .PAT>>
					 <GC-PRIMTYPE <TYPE-C <2 .PTYP>>>>
				    <COND (.ORF .PTYP) (ELSE .PAT)>)>)
			    (<N==? <SET TEM <DECL-GET .PAT>> .PAT>
			     <PRIMATCH .PTYP .TEM>)>)
		     (ELSE <COND (.ORF <ORSORT <FORM OR .PTYP .PAT>>)>)>)
	      (<AND <TYPE? .PAT FORM SEGMENT>
		    <SET PAT1 .PAT>
		    <NOT <EMPTY? .PAT1>>>
	       <COND (<==? <SET ACTOR <1 .PAT1>> OR> <ACTORT .PAT .PTYP>)
		     (<==? .ACTOR NOT>
		      <COND (.ORF <NOT-IT .PAT .PTYP>)
			    (ELSE
			     <SET TEM <PRIMATCH .PTYP <2 .PAT1>>>
			     <COND (<AND <NOT .TEM> <EMPTY? .TEM>> .PTYP)
				   (<NOT .TEM> .TEM)
				   (<NOT <AND <TYPE? .TEM FORM SEGMENT>
					      <==? <LENGTH .TEM> 2>
					      <==? <1 .TEM> PRIMTYPE>
					      <==? <2 .TEM> <2 .PTYP>>>>
				    ANY)>)>)
		     (<SET TEM <PRIMATCH .PTYP <1 .PAT1>>>
		      <COND (.ORF .TEM)
			    (.ANDF
			     <COND (<TYPE? .PAT FORM>
				    <FORM .TEM !<REST .PAT1>>)
				   (ELSE
				    <CHTYPE (.TEM !<REST .PAT1>) SEGMENT>)>)
			    (ELSE T)>)>)>>

""

<DEFINE NOT-IT (NF PAT "AUX" T1) 
	#DECL ((NF) <OR FORM SEGMENT>)
	<COND (<AND <TYPE? .PAT FORM SEGMENT>
		    <NOT <EMPTY? .PAT>>
		    <OR <==? <1 .PAT> OR> <==? <1 .PAT> AND>>>
	       <ACTORT .PAT .NF>)
	      (ELSE
	       <COND (<==? <LENGTH .NF> 2>
		      <COND (<NOT <SET T1 <TYPE-AND <2 .NF> .PAT>>>
			     <COND (.ORF .NF) (.ANDF .PAT) (ELSE T)>)
			    (<==? <2 .NF> ANY> <COND (.ORF .PAT)>)
			    (<==? <SET T1 <VTS .T1>>
				  <SET PAT <VTS .PAT>>>
			     <COND (.ORF ANY)>)
			    (<OR <AND <TYPE? .PAT ATOM> <TYPE? .T1 ATOM>>
				 <AND <OR <N==? <CALL TYPE .T1> <CALL TYPE .PAT>>
					  <N=? .T1 .PAT>>
				      <N=? <CANONICAL-DECL .PAT>
					   <CANONICAL-DECL .T1>>>>
			     <COND (.ANDF .PAT)
				   (.ORF ANY) (ELSE T)>)
			    (.ORF ANY)>)
		     (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>)>>

<DEFINE NOTIFY (D) 
	<COND (<AND <TYPE? .D FORM SEGMENT>
		    <==? <LENGTH .D> 2>
		    <==? <1 .D> NOT>>
	       <2 .D>)
	      (ELSE <FORM NOT .D>)>>

""

<DEFINE FORMATCH (FRM RPAT "AUX" TEM (PAT .RPAT) EX (ORF .ORF) (ANDF .ANDF)) 
   #DECL ((FRM) <OR <FORM ANY> <SEGMENT ANY>>
	  (RPAT) <OR ATOM FORM LIST SEGMENT VECTOR FIX>)
   <COND
    (<AND <TYPE? .RPAT ATOM> <TYPE? <1 .FRM> ATOM> <==? <1 .FRM> .RPAT>>
     <COND (.ORF .RPAT) (ELSE .FRM)>)
    (ELSE
     <COND (<TYPE? .RPAT ATOM> <SET PAT <SET EX <DECL-GET .RPAT .RPAT>>>)
	   (ELSE <SET RPAT <1 .PAT>>)>
     <COND
      (<TYPE? .PAT ATOM>
       <SET TEM
	    <COND (<AND .ORF <NOT <CTMATCH .PAT <1 .FRM> <> <> T>>>
		   <ORSORT <FORM OR .RPAT .FRM>>)
		  (ELSE
		   <COND (<TYPE? <1 .FRM> ATOM> <TYPMAT <1 .FRM> .PAT>)
			 (<TYPE? <1 .FRM> FORM> <ACTORT <1 .FRM> .PAT>)>)>>
       <COND (<AND .ANDF <NOT .ORF> .TEM>
	      <COND (<TYPE? .FRM FORM> <CHTYPE (.TEM !<REST .FRM>) FORM>)
		    (ELSE <CHTYPE (.TEM !<REST .FRM>) SEGMENT>)>)
	     (ELSE .TEM)>)
      (<TYPE? .PAT FORM SEGMENT>
       <COND (<OR <==? <SET TEM <1 .PAT>> OR>
		  <==? .TEM AND>
		  <==? .TEM NOT>
		  <==? .TEM PRIMTYPE>>
	      <ACTORT .PAT .FRM>)
	     (ELSE
	      <COND (<AND <==? <LENGTH .PAT> 2> <TYPE? <2 .PAT> LIST>>
		     <WRDFX .PAT .FRM .RPAT>)
		    (<AND .ORF
			  <ASSIGNED? EX>
			  <NOT <CTMATCH .RPAT .FRM <> <> T>>>
		     <ORSORT <FORM OR .RPAT .FRM>>)
		    (<AND .ORF <NOT <CTMATCH .PAT .FRM <> <> T>>>
		     <ORSORT <FORM OR .PAT .FRM>>)
		    (ELSE
		     <SET TEM <ELETYPE .PAT .FRM .RPAT>>
		     <AND <ASSIGNED? EX>
			  <TYPE? .TEM FORM SEGMENT>
			  <G? <LENGTH .TEM> 1>
			  <==? <1 .TEM> OR>
			  <MAPR <>
				<FUNCTION (EL) 
					<AND <=? <1 .EL> .EX>
					     <PUT .EL 1 .RPAT>
					     <MAPLEAVE>>>
				<REST .TEM>>>
		     .TEM)>)>)>)>>

""

<DEFINE FOSE ("TUPLE" TUP "AUX" (FLG <1 .TUP>)) 
	<COND (.FLG <CHTYPE (!<REST .TUP>) SEGMENT>)
	      (ELSE <CHTYPE (!<REST .TUP>) FORM>)>>

<DEFINE SEGANDOR (F1 F2 ORF) 
	<SET F1 <REAL-SEG? .F1>>
	<SET F2 <REAL-SEG? .F2>>
	<COND (.ORF <AND <TYPE? .F1 SEGMENT> <TYPE? .F2 SEGMENT>>)
	      (ELSE <OR <TYPE? .F1 SEGMENT> <TYPE? .F2 SEGMENT>>)>>

<DEFINE REAL-SEG? (F "AUX" LAST)
	<COND (<AND <TYPE? .F SEGMENT>
		    <G? <LENGTH .F> 1>
		    <TYPE? <SET LAST <NTH .F <LENGTH .F>>> VECTOR>
		    <==? <1 .LAST> REST>>
	       <CHTYPE .F FORM>)
	      (ELSE .F)>>

<DEFINE WRDFX (F11 F22 RPAT
	       "AUX" (F1 <CHTYPE .F11 FORM>) (F2 <CHTYPE .F22 FORM>) FST TL)
   #DECL ((F11 F22) <OR FORM SEGMENT> (F1 F2) FORM)
   <COND (<OR <EMPTY? .F1> <EMPTY? .F2>> #FALSE (EMPTY-FORM-IN-DECL!-ERRORS))>
   <SET FST
	<COND (<TYPE? .RPAT ATOM>
	       <COND (<TYPE? <1 .F2> ATOM> <TYPMAT <1 .F2> .RPAT>)
		     (<TYPE? <1 .F2> FORM> <ACTORT <1 .F2> .RPAT>)
		     (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>)
	      (<TYPE? .RPAT FORM> <ACTORT .RPAT <1 .F2>>)
	      (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>>
   <COND
    (<NOT .FST> .FST)
    (ELSE
     <COND (<CTMATCH .RPAT ,ALLWORDS <> <> <>>
	    <COND (<AND <==? <LENGTH .F2> 2> <TYPE? <2 .F2> LIST>>
		   <COND (<CTMATCH <1 .F2> ,ALLWORDS <> <> <>>
			  <COND (.ORF
				 <SET TL <MAP-MERGE !<2 .F1> !<2 .F2>>>
				 <COND (<EMPTY? .TL> .FST)
				       (ELSE <FORM .FST .TL>)>)
				(<SET TL <AND-MERGE <2 .F1> <2 .F2>>>
				 <FORM .FST .TL>)>)
			 (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>)
		  (ELSE <COND (.ORF <ORSORT <FORM OR .F11 .F22>>) (ELSE <>)>)>)
	   (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>)>>

<DEFINE MAP-MERGE ("TUPLE" PAIRS "AUX" (HIGH <2 .PAIRS>) (LOW <1 .PAIRS>)) 
	#DECL ((PAIRS) <<PRIMTYPE VECTOR> [REST FIX]> (HIGH LOW) FIX)
	<REPEAT ()
		<COND (<EMPTY? <SET PAIRS <REST .PAIRS 2>>> <RETURN>)>
		<SET HIGH <MAX .HIGH <2 .PAIRS>>>
		<SET LOW <MIN .LOW <1 .PAIRS>>>>
	<COND (<AND <==? .HIGH <CHTYPE <MIN> FIX>>
		    <==? .LOW <CHTYPE <MAX> FIX>>>
	       ())
	      (ELSE (.LOW .HIGH))>>

<DEFINE AND-MERGE (L1 L2 "AUX" (FLG <>) HIGH LOW TEM (L (0)) (LL .L)) 
	#DECL ((L LL L1 L2) <LIST [REST FIX]> (HIGH LOW) FIX)
	<COND (<G? <LENGTH .L1> <LENGTH .L2>>
	       <SET TEM .L1>
	       <SET L1 .L2>
	       <SET L2 .TEM>)>
	<REPEAT ()
		<SET LOW <1 .L2>>
		<SET HIGH <2 .L2>>
		<REPEAT ((L1 .L1) LO HI)
			#DECL ((L1) <LIST [REST FIX]> (LO HI) FIX)
			<COND (<EMPTY? .L1> <RETURN>)>
			<SET HI <2 .L1>>
			<COND (<OR <AND <G=? <SET LO <1 .L1>> .LOW>
					<L=? .LO .HIGH>>
				   <AND <L=? .HI .HIGH> <G=? .HI .LOW>>
				   <AND <G=? .LOW .LO> <L=? .LOW .HI>>
				   <AND <L=? .HIGH .HI> <G=? .HIGH .LO>>>
			       <SET LOW <MAX .LOW .LO>>
			       <SET HIGH <MIN .HIGH .HI>>
			       <SET L <REST <PUTREST .L (.LOW .HIGH)> 2>>
			       <SET FLG T>
			       <RETURN>)>
			<SET L1 <REST .L1 2>>>
		<COND (<EMPTY? <SET L2 <REST .L2 2>>>
		       <RETURN <COND (.FLG <REST .LL>) (ELSE <>)>>)>>>

""

<DEFINE GET-RANGE (L1 "AUX" TT) 
	<COND (<AND <TYPE? .L1 FORM>
		    <TMATCH .L1 ,ALLWORDS>
		    <TYPE? <2 .L1> LIST>>
	       <COND (<NOT <EMPTY? <SET TT <MAP-MERGE !<2 .L1>>>>> .TT)>)>>

""

<DEFINE ELETYPE (F1 F2 RTYP
		 "AUX" (S1 <STACK <VECTOR .F1 <> 0 <> <> '[]>>) (FAIL <>)
		       (S2 <STACK <VECTOR .F2 <> 0 <> <> '[]>>) (FL ()) (FP '<>)
		       (INOPT <>) FSTL SEGF RTEM (ORF .ORF) (ANDF .ANDF))
   #DECL ((S1 S2) <VECTOR <PRIMTYPE LIST> ANY FIX ANY ANY ANY>
	  (F1 F2) <PRIMTYPE LIST> (FP) <OR FORM SEGMENT> (FL) LIST)
   <SET SEGF <SEGANDOR .F1 .F2 .ORF>>
   <COND
    (<OR <EMPTY? .F1> <EMPTY? .F2>> #FALSE (EMPTY-FORM-IN-DECL!-ERRORS))
    (<AND .ANDF .ORF <NOT <TMATCH <1 .F2> .RTYP>>> <ORSORT <FORM OR .F1 .F2>>)
    (ELSE
     <COND
      (<SET FSTL
	    <COND (<TYPE? .RTYP ATOM>
		   <COND (<TYPE? <1 .F2> ATOM> <TYPMAT .RTYP <1 .F2>>)
			 (<TYPE? <1 .F2> FORM> <ACTORT <1 .F2> .RTYP>)
			 (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>)
		  (<TYPE? .RTYP FORM> <ACTORT .RTYP <1 .F2>>)
		  (ELSE #FALSE (BAD-SYNTAX!-ERRORS))>>
       <COND (.ANDF
	      <SET FL
		   <CHTYPE <SET FP
				<COND (.SEGF <CHTYPE (.FSTL) SEGMENT>)
				      (ELSE <FORM .FSTL>)>>
			   LIST>>)>
       <PUT .S1 ,DECL-RESTED <REST .F1>>
       <PUT .S2 ,DECL-RESTED <REST .F2>>
       <REPEAT ((TEM1 <>) (TEM2 <>) T1 T2 TEM TT)
	 #DECL ((TT) <VECTOR FIX ANY>)
	 <SET T1 <SET T2 <>>>
	 <COND
	  (<AND <OR <AND <SET TEM1 <NEXTP .S1>> <SET T1 <DECL-ELEMENT .S1>>>
		    <AND <EMPTY? .TEM1> <SET T1 ANY>>>
		<OR <AND <SET TEM2 <NEXTP .S2>> <SET T2 <DECL-ELEMENT .S2>>>
		    <AND .TEM1 <EMPTY? .TEM2> <SET T2 ANY>>>>
	   <COND (<AND .ORF <OR <NOT .TEM1> <NOT .TEM2>>>
		  <RETURN <ONE-CHECK .FP .SEGF>>)>
	   <OR <SET RTEM
		    <SET TEM
			 <COND (<NOT .TEM1>
				<COND (<OR <TYPE? .F1 FORM>
					   <DECL-IN-REST .S2>
					   <DECL-IN-COUNT-VEC .S2>>
				       .T2)
				      (ELSE <SET FAIL T> <>)>)
			       (<NOT .TEM2>
				<COND (<OR <TYPE? .F2 FORM>
					   <DECL-IN-REST .S1>
					   <DECL-IN-COUNT-VEC .S1>>
				       .T1)
				      (ELSE <SET FAIL T> <>)>)
			       (ELSE <DTMATCH .T1 .T2>)>>>
	       <COND (.ORF <SET TEM <ORSORT <FORM OR .T1 .T2>>>)
		     (.MAYBEF <COND (.FAIL <RETURN <>>) (ELSE <SET FAIL T>)>)
		     (ELSE <RETURN <>>)>>
	   <COND (<AND <NOT .INOPT>
		       <OR <AND .ORF
				<OR <DECL-IN-COUNT-VEC .S1>
				    <DECL-IN-COUNT-VEC .S2>>>
			   <AND .ANDF
				<NOT .ORF>
				<DECL-IN-COUNT-VEC .S1>
				<DECL-IN-COUNT-VEC .S2>>>>
		  <SET INOPT <COND (.ANDF (OPTIONAL .TEM)) (ELSE ())>>)
		 (<AND .INOPT .ANDF>
		  <PUTREST <REST .INOPT <- <LENGTH .INOPT> 1>> (.TEM)>)>
	   <COND (<AND .INOPT
		       <OR <AND .ORF
				<OR <0? <DECL-ITEM-COUNT .S1>>
				    <0? <DECL-ITEM-COUNT .S2>>>>
			   <AND .ANDF
				<0? <DECL-ITEM-COUNT .S1>>
				<0? <DECL-ITEM-COUNT .S2>>>>>
		  <AND .ANDF <SET TEM [!.INOPT]>>
		  <SET INOPT <>>)>
	   <COND
	    (<OR <AND .ORF
		      <OR <DECL-IN-REST .S1> <DECL-IN-REST .S2>>>
		 <AND <OR <DECL-IN-REST .S1>
			  <AND .ANDF <OR <NOT .TEM1> <DECL-IN-COUNT-VEC .S1>>>>
		      <OR <DECL-IN-REST .S2>
			  <AND .ANDF
			       <OR <NOT .TEM2> <DECL-IN-COUNT-VEC .S2>>>>>>
	     <COND
	      (<OR .ORF .ANDF>
	       <COND (<N==? 0
			    <SET T1
				 <RESTER? .S1
					  .S2
					  .FL
					  .RTEM
					  <TYPE? .F2 SEGMENT>>>>
		      <COND (<==? .T1 T>
			     <RETURN <ONE-CHECK .FP .SEGF>>)
			    (ELSE
			     <RETURN <COND (<AND <TYPE? .T1 FORM SEGMENT>
						 <LENGTH? .FP 1>>
					    <1 .T1>)
					   (ELSE .T1)>>)>)
		     (<N==? 0
			    <SET T1
				 <RESTER? .S2
					  .S1
					  .FL
					  .RTEM
					  <TYPE? .F1 SEGMENT>>>>
		      <COND (<==? .T1 T>
			     <RETURN <ONE-CHECK .FP .SEGF>>)
			    (ELSE
			     <RETURN <COND (<TYPE? .T1 FORM SEGMENT>
					    <ONE-CHECK .T1 .SEGF>)
					   (ELSE .T1)>>)>)>)
	      (ELSE <RETURN T>)>)
	    (<AND <NOT .ANDF>
		  <OR <DECL-IN-REST .S1> <NOT .TEM1>>
		  <OR <DECL-IN-REST .S2> <NOT .TEM2>>>
	     <RETURN T>)>
	   <COND (<AND <NOT .INOPT>
		       .ANDF
		       <OR <NOT .ORF>
			   <NOT <OR <DECL-IN-REST .S1> <DECL-IN-REST .S2>>>>>
		  <COND (<AND <TYPE? <1 .FL> VECTOR>
			      <=? <2 <SET TT <1 .FL>>> .TEM>>
			 <PUT .TT 1 <+ <1 .TT> 1>>)
			(<AND <N==? <CHTYPE .FP LIST> .FL> <=? .TEM <1 .FL>>>
			 <PUT .FL 1 [2 .TEM]>)
			(ELSE <SET FL <REST <PUTREST .FL (.TEM)>>>)>)>)
	  (ELSE
	   <COND (<AND <EMPTY? .TEM1> <EMPTY? <SET TEM1 .TEM2>>>
		  <COND (.ANDF
			 <RETURN <ONE-CHECK .FP .SEGF>>)
			(ELSE <RETURN T>)>)
		 (ELSE <RETURN .TEM1>)>)>>)>)>>

<DEFINE ONE-CHECK (FP:<OR FORM SEGMENT> SEGF)
	<COND (<AND <NOT .SEGF> <EMPTY? <REST .FP>>> <1 .FP>)
	      (ELSE .FP)>>
""

<DEFINE RESTER? (S1 S2 FL FST SEGF
		 "AUX" (TT <DECL-REST-VEC .S1>) (TEM1 T) (TEM2 T) (OPTIT <>))
   #DECL ((S1 S2) <VECTOR ANY ANY ANY ANY ANY VECTOR> (FL) <LIST ANY>
	  (TT) VECTOR)
   <COND (<AND <OR .ORF <DECL-IN-COUNT-VEC .S2>>
	       <EMPTY? <DECL-RESTED .S2>>
	       <NOT <DECL-IN-REST .S2>>>
	  <SET OPTIT T>)>
   <COND
    (<AND .SEGF
	  <NOT .ORF>
	  <OR <NOT <DECL-IN-REST .S1>> <NOT <DECL-IN-REST .S2>>>>
     T)
    (<AND <NOT <EMPTY? .TT>>
	  <OR <NOT <DECL-IN-REST .S2>>
	      <G=? <LENGTH .TT> <LENGTH <REST <TOP <DECL-REST-VEC .S2>>>>>>>
     <SET TT <REST <TOP .TT>>>
     <MAPR <>
      <FUNCTION (SO "AUX" T1) 
	      #DECL ((SO) <VECTOR ANY>)
	      <SET T1
		   <OR <AND <SET TEM1 <NEXTP .S2>> <DECL-ELEMENT .S2>>
		       <AND <EMPTY? .TEM1>
			    <COND (.ORF <MAPLEAVE>) (ELSE ANY)>>>>
	      <AND <OR .ORF <DECL-IN-COUNT-VEC .S2>>
		   <EMPTY? <DECL-RESTED .S2>>
		   <NOT <DECL-IN-REST .S2>>
		   <SET OPTIT T>>
	      <COND (<NOT .TEM1> <AND <EMPTY? .TEM1> <SET TEM1 T>>)>
	      <COND (.T1
		     <PUT .SO
			  1
			  <SET TEM2
			       <DTMATCH <AND <NEXTP .S1> <DECL-ELEMENT .S1>>
					.T1>>>)>
	      <AND <OR <NOT .T1> <NOT .TEM2>> <MAPLEAVE>>>
      <REST <SET TT [REST .FST !<REST .TT>]> 2>>
     <COND (.OPTIT <PUT .TT 1 OPTIONAL>)
	   (ELSE <SET TT <UNIQUE-VECTOR-CHECK .TT>>)>
     <COND (<AND .TEM1 .TEM2> <PUTREST .FL (.TT)> T)
	   (<AND <NOT .TEM1> <NOT <EMPTY? .TEM1>>> .TEM1)
	   (ELSE .TEM2)>)
    (ELSE 0)>>

<DEFINE UNIQUE-VECTOR-CHECK (V "AUX" (FRST <2 .V>)) 
	#DECL ((V) <VECTOR [2 ANY]>)
	<COND (<MAPF <>
		     <FUNCTION (X) <COND (<N=? .X .FRST> <MAPLEAVE .V>)>>
		     <REST .V 2>>)
	      (ELSE [REST .FRST])>>

<DEFINE NEXTP (S "AUX" TEM TT N) 
	#DECL ((S) <VECTOR <PRIMTYPE LIST> ANY FIX ANY ANY ANY> (N) FIX
	       (TT) VECTOR)
	<COND (<0? <DECL-ITEM-COUNT .S>> <PUT .S ,DECL-IN-COUNT-VEC <>>)>
	<COND (<DECL-IN-REST .S> <NTHREST .S>)
	      (<NOT <0? <DECL-ITEM-COUNT .S>>>
	       <PUT .S ,DECL-ITEM-COUNT <- <DECL-ITEM-COUNT .S> 1>>
	       <NTHREST .S>)
	      (<EMPTY? <SET TEM <DECL-RESTED .S>>> <>)
	      (<TYPE? <1 .TEM> ATOM FORM SEGMENT>
	       <SET TEM <1 .TEM>>
	       <PUT .S ,DECL-RESTED <REST <DECL-RESTED .S>>>
	       <PUT .S ,DECL-ELEMENT .TEM>)
	      (<TYPE? <1 .TEM> VECTOR>
	       <SET TT <1 .TEM>>
	       <PUT .S ,DECL-RESTED <REST <DECL-RESTED .S>>>
	       <PUT .S ,DECL-REST-VEC <REST .TT>>
	       <COND (<G? <LENGTH .TT> 1>
		      <COND (<==? <1 .TT> REST>
			     <COND (<AND <==? <LENGTH .TT> 2>
					 <==? <2 .TT> ANY>>
				    <>)
				   (ELSE
				    <PUT .S ,DECL-IN-REST T>
				    <PUT .S
					 ,DECL-ELEMENT
					 <DECL-ELEMENT .TT>>)>)
			    (<OR <AND <TYPE? <1 .TT> FIX> <SET N <1 .TT>>>
				 <AND <OR <==? <1 .TT> OPT>
					  <==? <1 .TT> OPTIONAL>>
				      <SET N 1>>>
			     <OR <TYPE? <1 .TT> FIX>
				 <PUT .S ,DECL-IN-COUNT-VEC T>>
			     <PUT .S
				  ,DECL-ITEM-COUNT
				  <- <* .N <- <LENGTH .TT> 1>> 1>>
			     <PUT .S ,DECL-ELEMENT <2 .TT>>
			     <COND (<L=? .N 0> <>) (ELSE .S)>)
			    (#FALSE (BAD-VECTOR-SYNTAX!-ERRORS))>)
		     (ELSE #FALSE (BAD-FORM-SYNTAX!-ERRORS))>)
	      (ELSE #FALSE (BAD-FORM-SYNTAX!-ERRORS))>>

""

<DEFINE NTHREST (S "AUX" (TEM <REST <DECL-REST-VEC .S>>)) 
	#DECL ((S) <VECTOR ANY ANY ANY ANY ANY VECTOR> (TEM) VECTOR)
	<COND (<EMPTY? .TEM> <SET TEM <REST <TOP .TEM>>>)>
	<PUT .S ,DECL-REST-VEC .TEM>
	<PUT .S ,DECL-ELEMENT <1 .TEM>>>

""

<DEFINE GET-ELE-TYPE (DCL2 NN
		      "OPTIONAL" (RST <>) (PT <>)
		      "AUX" PTY NN1 TYP VT (ET FIX))
	<COND (<AND ,MIM
		    <OR <AND <SET TYP <ISTYPE? .DCL2>>
			     <SET VT <VALID-TYPE? .TYP>>>
			<AND <SET PTY <STRUCTYP .DCL2>>
			     <SET VT <VALID-TYPE? .PTY>>
			     <SET TYP <FORM PRIMTYPE .PTY>>>>
		    <OR <==? <SET VT <ANDB .VT 7>> 4>
			<AND <==? .VT 5> <SET ET CHARACTER>>
			<==? .VT 6>>>
	       <COND (<AND .PT
			   <COND (<OR <==? .NN ALL>
				      <AND <TYPE? .NN FIX>
					   <L=? .NN <MINL .DCL2>>>>
				  .DCL2)
				 (<AND <TYPE? .NN FIX> <G? .NN 0>>
				  <FORM .TYP [.NN .ET] [REST .ET]>)>>)
		     (<AND .RST
			   <SET TYP
				<COND (<==? .VT 5> STRING)
				      (<==? .VT 4> BYTES)
				      (ELSE UVECTOR)>>
			   <COND (<==? .NN ALL> .TYP)
				 (<AND <TYPE? .NN FIX>
				       <G? <SET NN1 <- <MINL .DCL2> .NN>> 0>>
				  <FORM .TYP [.NN1 .ET] [REST .ET]>)
				 (<AND <TYPE? .NN FIX> <G=? .NN 0>> .TYP)>>)
		     (<OR <==? .NN ALL> <AND <TYPE? .NN FIX> <G? .NN 0>>> .ET)
		     (ELSE
		      <ERROR BAD-CALL-TO-GET-ELE-TYPE .DCL2 .NN .RST .PT>)>)
	      (ELSE <REAL-GET-ELE-TYPE .DCL2 .NN .RST .PT>)>>

<DEFINE REAL-GET-ELE-TYPE (DCL2 NN RST PT
			   "AUX" (LN 0) (CNT 0) ITYP DC SDC DCL (N 0) DC1
				 (QOK <>) (FMOK <>) STRU (GD '<>) (GP ()) (K 0)
				 (DCL1 .DCL2) (SEGF <>) TEM)
   #DECL ((LN CNT K N) FIX (DCL) <PRIMTYPE LIST> (SDC DC) VECTOR
	  (GD) <OR FORM SEGMENT> (GP) LIST)
   <PROG ()
     <COND (<AND .PT <SET TEM <ISTYPE? .DCL1>>>
	    <SET PT <TYPE-AND <GET-ELE-TYPE .TEM .NN> .PT>>)>
     <AND <TYPE? .DCL1 ATOM> <SET DCL1 <DECL-GET .DCL1 .DCL1>>>
     <COND (<TYPE? .DCL1 SEGMENT> <SET SEGF T>)>
     <COND (.RST <SET STRU <COND (<STRUCTYP .DCL1>) (ELSE STRUCTURED)>>)
	   (.PT
	    <SET STRU
		 <COND (<ISTYPE? .DCL2>)
		       (<SET STRU <STRUCTYP .DCL1>> <FORM PRIMTYPE .STRU>)
		       (ELSE STRUCTURED)>>)>
     <COND
      (<AND <TYPE? .DCL1 FORM SEGMENT>
	    <SET DCL .DCL1>
	    <G? <SET LN <LENGTH .DCL>> 1>
	    <NOT <SET FMOK <MEMQ <1 .DCL> '[OR AND NOT]>>>
	    <NOT <SET QOK <==? <1 .DCL> QUOTE>>>
	    <NOT <==? <1 .DCL> PRIMTYPE>>>
       <COND
	(<==? .NN ALL>
	 <AND .PT <SET GP <CHTYPE <SET GD <FOSE .SEGF .STRU>> LIST>>>
	 <OR
	  <AND <TYPE? <SET DC1 <2 .DCL>> VECTOR>
	       <SET DC .DC1>
	       <G=? <LENGTH .DC> 2>
	       <==? <1 .DC> REST>
	       <COND (<==? <LENGTH .DC> 2>
		      <COND (.RST <FORM .STRU [REST <2 .DC>]>)
			    (.PT <FORM .STRU [REST <TYPE-MERGE <2 .DC> .PT>]>)
			    (ELSE <2 .DC>)>)
		     (.RST <FORM .STRU [REST <TYPE-MERGE !<REST .DC>>]>)
		     (.PT
		      <FORM .STRU
			    [REST
			     <MAPF ,TYPE-MERGE
				   <FUNCTION (D) <TYPE-MERGE .D .PT>>
				   <REST .DC>>]>)
		     (ELSE <TYPE-MERGE !<REST .DC>>)>>
	  <REPEAT (TT (CK <DCX <SET TT <2 .DCL>>>) (D .DCL) TEM)
		  #DECL ((D) <PRIMTYPE LIST>)
		  <COND (<EMPTY? <SET D <REST .D>>>
			 <SET TEM
			      <OR .SEGF
				  <AND <TYPE? .TT VECTOR> <==? <1 .TT> REST>>>>
			 <RETURN <COND (.TEM
					<COND (.RST <FORM .STRU [REST .CK]>)
					      (.PT .GD)
					      (ELSE .CK)>)
				       (.PT .GD)
				       (.RST .STRU)
				       (ELSE ANY)>>)>
		  <SET CK <TYPE-MERGE .CK <DCX <SET TT <1 .D>>>>>
		  <AND
		   .PT
		   <SET GP
			<REST <PUTREST
			       .GP
			       (<COND (<TYPE? .TT VECTOR>
				       [<1 .TT>
					!<MAPF ,LIST
					  <FUNCTION (X) <TYPE-MERGE .X .PT>>
					  <REST .TT>>])
				      (ELSE <TYPE-MERGE .PT .TT>)>)>>>>>>)
	(ELSE
	 <SET N .NN>
	 <AND .PT <SET GP <CHTYPE <SET GD <FOSE .SEGF .STRU>> LIST>>>
	 <AND .RST <SET N <+ .N 1>>>
	 <COND (<EMPTY? <SET DCL <REST .DCL>>>
		<RETURN <COND (.RST .STRU)
			      (.PT <FOSE .SEGF .STRU !<ANY-PAT <- .N 1>> .PT>)
			      (ELSE ANY)>>)>
	 <REPEAT ()
	   <COND
	    (<NOT <0? .CNT>>
	     <COND
	      (<EMPTY? <SET SDC <REST .SDC>>>
	       <SET SDC <REST .DC>>
	       <AND
		<0? <SET CNT <- .CNT 1>>>
		<COND (<EMPTY? <SET DCL <REST .DCL>>>
		       <RETURN <COND (.RST .STRU)
				     (.PT
				      <PUTREST .GP (!<ANY-PAT <- .N 1>> .PT)>
				      .GD)
				     (ELSE ANY)>>)
		      (ELSE <AGAIN>)>>)>
	     <SET ITYP <1 .SDC>>)
	    (<TYPE? <1 .DCL> ATOM FORM SEGMENT>
	     <SET ITYP <1 .DCL>>
	     <SET DCL <REST .DCL>>)
	    (<TYPE? <SET DC1 <1 .DCL>> VECTOR>
	     <SET DC .DC1>
	     <COND
	      (<==? <1 .DC> REST>
	       <AND <OR <AND .RST <NOT <1? .N>>> .PT>
		    <==? 2 <LENGTH .DC>>
		    <=? <2 .DC> '<NOT ANY>>
		    <RETURN <>>>
	       <SET K <MOD <- .N 1> <- <LENGTH .DC> 1>>>
	       <SET N </ <- .N 1> <- <LENGTH .DC> 1>>>
	       <RETURN
		<COND
		 (.RST
		  <FOSE .SEGF
			.STRU
			<COND (<0? .K> .DC)
			      (ELSE [REST <TYPE-MERGE !<REST .DC>>])>>)
		 (.PT
		  <PUTREST
		   .GP
		   (!<COND (<L=? .N 0> ())
			   (<1? .N> (!<REST .DC>))
			   (ELSE ([.N !<REST .DC>]))>
		    !<MAPF ,LIST
			   <FUNCTION (O) 
				   <COND (<==? <SET K <- .K 1>> -1> .PT)
					 (ELSE .O)>>
			   <REST .DC>>
		    .DC)>
		  .GD)
		 (ELSE <NTH .DC <+ .K 2>>)>>)
	      (<OR <TYPE? <1 .DC> FIX>
		   <==? <1 .DC> OPT>
		   <==? <1 .DC> OPTIONAL>>
	       <SET CNT <COND (<TYPE? <1 .DC> FIX> <1 .DC>) (ELSE 1)>>
	       <SET SDC .DC>
	       <AGAIN>)>)>
	   <AND
	    <0? <SET N <- .N 1>>>
	    <RETURN
	     <COND
	      (.RST
	       <COND (<AND <EMPTY? .DCL> <0? .CNT>> .STRU)
		     (<FOSE .SEGF
			    .STRU
			    !<COND (<0? .CNT> (.ITYP !.DCL))
				   (<N==? .SDC <REST .DC>>
				    <COND (<0? <SET CNT <- .CNT 1>>>
					   (!.SDC !<REST .DCL>))
					  (ELSE
					   (!.SDC
					    [.CNT !<REST .DC>]
					    !<REST .DCL>))>)
				   (ELSE ([.CNT !.SDC] !<REST .DCL>))>>)>)
	      (.PT
	       <SET GP <REST <PUTREST .GP (.PT)>>>
	       <AND <ASSIGNED? SDC> <SET SDC <REST .SDC>>>
	       <COND (<AND <EMPTY? .DCL> <0? .CNT>> .GD)
		     (<PUTREST .GP
			       <COND (<OR <0? .CNT>
					  <AND <1? .CNT>
					       <==? .SDC <REST .DC>>>>
				      .DCL)
				     (<==? .SDC <REST .DC>>
				      ([.CNT !<REST .DC>] !<REST .DCL>))
				     (<L=? <SET CNT <- .CNT 1>> 0>
				      (!.SDC !<REST .DCL>))
				     (ELSE
				      (!.SDC
				       [.CNT !<REST .DC>]
				       !<REST .DCL>))>>
		      .GD)>)
	      (ELSE .ITYP)>>>
	   <AND <OR .PT .RST> <=? .ITYP '<NOT ANY>> <RETURN <>>>
	   <AND .PT <SET GP <REST <PUTREST .GP (.ITYP)>>>>
	   <COND (<EMPTY? .DCL>
		  <RETURN <COND (.RST .STRU)
				(.PT
				 <PUTREST .GP (!<ANY-PAT <- .N 1>> .PT)>
				 .GD)
				(ELSE ANY)>>)>>)>)
      (.QOK <SET DCL1 <GEN-DECL <2 .DCL>>> <SET QOK <>> <AGAIN>)
      (<AND .FMOK <==? <1 .FMOK> OR>>
       <MAPF ,TYPE-MERGE
	     <FUNCTION (D "AUX" IT) 
		     <COND (<SET IT <GET-ELE-TYPE .D .NN .RST .PT>>
			    <AND <==? .IT ANY> <MAPLEAVE ANY>>
			    .IT)
			   (ELSE <MAPRET>)>>
	     <REST .DCL>>)
      (<AND .FMOK <==? <1 .FMOK> AND>>
       <SET ITYP ANY>
       <MAPF <>
	     <FUNCTION (D) 
		     <SET ITYP <TYPE-OK? .ITYP <GET-ELE-TYPE .D .NN .RST>>>>
	     <REST .DCL>>
       .ITYP)
      (.RST <COND (<STRUCTYP .DCL1>) (ELSE STRUCTURED)>)
      (.PT
       <COND (<==? .NN ALL> .DCL1)
	     (ELSE <FOSE .SEGF .DCL1 !<ANY-PAT <- .NN 1>> .PT>)>)
      (ELSE ANY)>>>

""

<DEFINE MINL (DCL) <MIN-MAX-L .DCL <>>>

<DEFINE MAXL (DCL) <MIN-MAX-L .DCL T>>

<DEFINE MIN-MAX-L (DCL MAXF
		   "AUX" (N 0) DD D DC (LN 0) (QOK <>) (ANDOK <>) TT (OROK <>)
			 (IVAL <COND (.MAXF 0)(ELSE ,MAX-LENGTH)>)) 
   #DECL ((N VALUE LN) FIX (DC) <PRIMTYPE LIST> (D) VECTOR)
   <COND (<TYPE? .DCL ATOM> <SET DCL <DECL-GET .DCL .DCL>>)>
   <COND
    (<AND <TYPE? .DCL FORM SEGMENT>
	  <SET DC .DCL>
	  <G? <LENGTH .DC> 1>
	  <N==? <SET TT <1 .DC>> PRIMTYPE>
	  <NOT <SET OROK <==? .TT OR>>>
	  <NOT <SET QOK <==? .TT QUOTE>>>
	  <NOT <SET ANDOK <==? .TT AND>>>
	  <N==? .TT NOT>>
     <SET DC <REST .DC>>
     <COND (<AND .MAXF <TYPE? .DCL FORM>> ,MAX-LENGTH)
	   (ELSE
	    <REPEAT (FST)
	     #DECL ((VALUE) FIX)
	     <COND (<AND <TYPE? <SET DD <1 .DC>> VECTOR>
			 <SET D .DD>
			 <G? <LENGTH .D> 1>>
		    <COND (<OR <==? <SET FST <1 .D>> REST>
			       <==? .FST OPT>
			       <==? .FST OPTIONAL>>
			   <COND (.MAXF
				  <COND (<==? .FST REST>
					 <RETURN ,MAX-LENGTH>)
					(ELSE
					 <SET N <+ .N <- <LENGTH .D> 1>>>)>)
				 (ELSE
				  <RETURN .N>)>)
			  (<TYPE? <1 .D> FIX>
			   <SET LN <1 .D>>
			   <SET N <+ .N <* .LN <- <LENGTH .D> 1>>>>)
			  (ELSE
			   <COMPILE-ERROR "Bad DECL syntax" .DCL>)>)
		   (<TYPE? .DD ATOM FORM SEGMENT> <SET N <+ .N 1>>)
		   (ELSE <COMPILE-ERROR "Bad DECL syntax" .DCL>)>
	     <COND (<EMPTY? <SET DC <REST .DC>>> <RETURN .N>)>>)>)
    (<OR .OROK .ANDOK>
     <MAPF <>
	   <FUNCTION (EL)
		<COND (.OROK <COND (.MAXF
				    <SET IVAL <MAX .IVAL <MIN-MAX-L .EL .MAXF>>>)
				   (ELSE
				    <SET IVAL <MIN .IVAL <MIN-MAX-L .EL .MAXF>>>)>)
		      (.MAXF <SET IVAL <MIN .IVAL <MIN-MAX-L .EL .MAXF>>>)
		      (ELSE  <SET IVAL <MAX .IVAL <MIN-MAX-L .EL .MAXF>>>)>>
	   <REST .DC>>
     .IVAL)
    (.QOK <COND (<STRUCTURED? <2 .DC>> <LENGTH <2 .DC>>) (ELSE 0)>)
    (<TYPE? .DCL ATOM FALSE FORM SEGMENT>
     <COND (.MAXF ,MAX-LENGTH) (ELSE 0)>)
    (ELSE <COMPILE-ERROR "Bad DECL syntax" .DCL>)>>

<DEFINE STRUCTYP-SEG (DCL)
	<OR <STRUCTYP .DCL>
	    <AND <==? .DCL MULTI> MULTI>
	    <AND <TYPE? .DCL FORM SEGMENT>
		 <NOT <EMPTY? .DCL>>
		 <==? <1 .DCL> MULTI> MULTI>>>

<DEFINE STRUCTYP (DCL "AUX" VT) 
	<SET DCL <TYPE-AND .DCL STRUCTURED>>
	<COND (<TYPE? .DCL ATOM>
	       <AND <SET VT <VALID-TYPE? .DCL>> <GC-PRIMTYPE .VT>>)
	      (<TYPE? .DCL FORM SEGMENT>
	       <COND (<PRIMHK .DCL T>)
		     (<TYPE? <1 .DCL> FORM> <PRIMHK <1 .DCL> <>>)>)>>

<DEFINE PRIMHK (FRM FLG "AUX" TEM (LN <LENGTH .FRM>)) 
   #DECL ((FRM) <OR FORM SEGMENT> (LN) FIX)
   <COND (<AND <==? .LN 2>
	       <COND (<==? <SET TEM <1 .FRM>> PRIMTYPE>
		      <AND <TYPE? <SET TEM <2 .FRM>> ATOM>
			   <VALID-TYPE? .TEM>
			   <STRUCTYP <2 .FRM>>>)
		     (<==? .TEM QUOTE> <PRIMTYPE <2 .FRM>>)
		     (<==? .TEM NOT> <>)>>)
	 (<NOT <0? .LN>>
	  <COND (<==? <SET TEM <1 .FRM>> OR>
		 <SET TEM NO-RETURN>
		 <MAPF <>
		       <FUNCTION (D) <SET TEM <TYPE-MERGE <STRUCTYP .D> .TEM>>>
		       <REST .FRM>>
		 <COND (<AND <TYPE? .TEM ATOM> <VALID-TYPE? .TEM>> .TEM)>)
		(<==? .TEM AND>
		 <MAPF <>
		       <FUNCTION (D) 
			       <COND (<SET TEM <STRUCTYP .D>> <MAPLEAVE>)>>
		       <REST .FRM>>
		 .TEM)
		(<AND <TYPE? .TEM ATOM> <VALID-TYPE? .TEM>> <MTYPR .TEM>)>)>>

""

<DEFINE TYPESAME (T1 T2) 
	<OR <AND <SET T1 <ISTYPE? .T1>> <==? .T1 <SET T2 <ISTYPE? .T2>>>>
	    <AND .T1
		 .T2
		 <==? <GETPROP .T1 ALT-DECL '.T1>
		      <GETPROP .T2 ALT-DECL '.T2>>>>>

<DEFINE ISTYPE-GOOD? (TYP "OPTIONAL" (STRICT <>)) 
	<AND <SET TYP <ISTYPE? .TYP .STRICT>>
	     <NOT <MEMQ <MTYPR .TYP> '[BYTES STRING LOCD TUPLE FRAME]>>
	     .TYP>>

<DEFINE TOP-TYPE (TYP "AUX" TT) 
	<COND (<AND <TYPE? .TYP ATOM>
		    <NOT <VALID-TYPE? .TYP>>
		    <NOT <MEMQ .TYP '[STRUCTURED APPLICABLE ANY LOCATIVE]>>>
	       <SET TYP <DECL-GET .TYP .TYP>>)>
	<COND (<TYPE? .TYP ATOM> .TYP)
	      (<AND <TYPE? .TYP FORM SEGMENT> <NOT <LENGTH? .TYP 1>>>
	       <COND (<==? <SET TT <1 .TYP>> OR>
		      <MAPF ,TYPE-MERGE ,TOP-TYPE <REST .TYP>>)
		     (<==? .TT NOT> ANY)
		     (<==? .TT QUOTE> <TYPE <2 .TYP>>)
		     (<==? .TT PRIMTYPE> .TYP)
		     (ELSE .TT)>)>>

<DEFINE PRIMITIVE-TYPE (TYP "AUX" TT RES VT) 
	<COND (<AND <TYPE? .TYP ATOM>
		    <NOT <VALID-TYPE? .TYP>>
		    <NOT <MEMQ .TYP '[STRUCTURED APPLICABLE ANY]>>>
	       <SET TYP <DECL-GET .TYP .TYP>>)>
	<COND (<TYPE? .TYP ATOM>
	       <COND (<SET VT<VALID-TYPE? .TYP>>
		      <GC-PRIMTYPE .VT>)
		     (ELSE .TYP)>)
	      (<AND <TYPE? .TYP FORM SEGMENT> <NOT <LENGTH? .TYP 1>>>
	       <COND (<==? <SET TT <1 .TYP>> OR>
		      <SET RES <MAPF ,TYPE-MERGE ,PRIMITIVE-TYPE <REST .TYP>>>
		      <COND (<TYPE? .RES ATOM> .RES) (ELSE ANY)>)
		     (<==? .TT NOT> ANY)
		     (<==? .TT QUOTE> <PRIMTYPE <2 .TYP>>)
		     (<==? .TT PRIMTYPE> <2 .TYP>)
		     (ELSE <PRIMITIVE-TYPE <1 .TYP>>)>)>>

<DEFINE ISTYPE? (TYP "OPTIONAL" (STRICT <>) "AUX" TY) 
   <PROG ()
     <COND (<AND <NOT .STRICT>
		  <TYPE? .TYP FORM SEGMENT>
		  <NOT <EMPTY? .TYP>>
		  <==? <1 .TYP> OR>
		  <MEMQ UNBOUND <REST .TYP>>>
	     <SET TYP <TYPE-AND .TYP '<NOT UNBOUND>>>)>
     <COND (<TYPE? .TYP FORM SEGMENT>
	    <COND (<AND <==? <LENGTH .TYP> 2> <==? <1 .TYP> QUOTE>>
		   <SET TYP <TYPE <2 .TYP>>>)
		  (<==? <1 .TYP> OR>
		   <SET TYP <ISTYPE? <2 <SET TY .TYP>>>>
		   <MAPF <>
			 <FUNCTION (Z) 
				 <COND (<N==? .TYP <ISTYPE? .Z>>
					<MAPLEAVE <SET TYP <>>>)>>
			 <REST .TY 2>>)
		  (ELSE <SET TYP <1 .TYP>>)>)>
     <AND <TYPE? .TYP ATOM>
	  <COND (<VALID-TYPE? .TYP> .TYP)
		(<SET TYP <DECL-GET .TYP>> <AGAIN>)>>>>

<DEFINE DCX (IT "AUX" TT LN) 
	#DECL ((TT) VECTOR (LN) FIX)
	<COND (<AND <TYPE? .IT VECTOR>
		    <G=? <SET LN <LENGTH <SET TT .IT>>> 2>
		    <COND (<==? .LN 2> <2 .TT>)
			  (ELSE <TYPE-MERGE !<REST .TT>>)>>)
	      (ELSE .IT)>>

" Define a decl for a given quoted object for maximum winnage."

""

<DEFINE GEN-DECL (OBJ) 
   <COND
    (<==? .OBJ %<>> BOOL-FALSE)
    (<OR <MONAD? .OBJ> <APPLICABLE? .OBJ> <TYPE? .OBJ STRING BYTES>>
     <TYPE .OBJ>)
    (ELSE
     <REPEAT ((DC <GEN-DECL <1 .OBJ>>) (CNT 1)
	      (FRM <CHTYPE (<TYPE .OBJ>) SEGMENT>) (FRME .FRM) TT T1)
	     #DECL ((CNT) FIX (FRME) <<PRIMTYPE LIST> ANY>)
	     <COND (<EMPTY? <SET OBJ <REST .OBJ>>>
		    <COND (<G? .CNT 1>
			   <SET FRME <REST <PUTREST .FRME ([.CNT .DC])>>>)
			  (ELSE <SET FRME <REST <PUTREST .FRME (.DC)>>>)>
		    <RETURN .FRM>)
		   (<AND <=? <SET TT <GEN-DECL <1 .OBJ>>> .DC> .DC>
		    <SET CNT <+ .CNT 1>>)
		   (ELSE
		    <COND (<G? .CNT 1>
			   <SET FRME <REST <PUTREST .FRME ([.CNT .DC])>>>)
			  (ELSE <SET FRME <REST <PUTREST .FRME (.DC)>>>)>
		    <SET DC .TT>
		    <SET CNT 1>)>>)>>

""

<DEFINE REST-DECL (DC N "AUX" TT TEM) 
   #DECL ((N) FIX)
   <COND
    (<TYPE? .DC FORM SEGMENT>
     <COND
      (<OR <==? <SET TT <1 .DC>> OR> <==? .TT AND>>
       <SET TT
	<CHTYPE
	 (.TT
	  !<MAPF ,LIST
		 <FUNCTION (D "AUX" (IT <REST-DECL .D .N>)) 
			 <COND (<==? .IT ANY>
				<COND (<==? .TT OR> <MAPLEAVE (ANY)>)
				      (ELSE <MAPRET>)>)
			       (ELSE .IT)>>
		 <REST .DC>>)
	 FORM>>
       <COND (<EMPTY? <REST .TT>> ANY)
	     (<EMPTY? <REST .TT 2>> <2 .TT>)
	     (ELSE .TT)>)
      (<==? .TT NOT> ANY)
      (<==? .TT PRIMTYPE>
       <COND (<0? .N> .DC) (ELSE <CHTYPE (.DC !<ANY-PAT .N>) FORM>)>)
      (ELSE
       <FOSE <TYPE? .DC SEGMENT>
	     <COND (<SET TEM <STRUCTYP .TT>> <FORM PRIMTYPE .TEM>)
		   (ELSE STRUCTURED)>
	     !<ANY-PAT .N>
	     !<REST .DC>>)>)
    (<SET TEM <STRUCTYP .DC>>
     <COND (<0? .N> <FORM PRIMTYPE .TEM>)
	   (ELSE <CHTYPE (<FORM PRIMTYPE .TEM> !<ANY-PAT .N>) FORM>)>)
    (ELSE
     <COND (<0? .N> STRUCTURED)
	   (ELSE <CHTYPE (STRUCTURED !<ANY-PAT .N>) FORM>)>)>>

<DEFINE ANY-PAT (N) 
	#DECL ((N) FIX)
	<COND (<L=? .N 0> ()) (<1? .N> (ANY)) (ELSE ([.N ANY]))>>

" TYPE-OK? are two type patterns compatible.  If the patterns
  don't parse, send user a message."

<DEFINE TYPE-OK? (P1 P2 "AUX" TEM) 
	<COND (<OR <==? .P1 NO-RETURN> <==? .P2 NO-RETURN>> NO-RETURN)
	      (<SET TEM <TYPE-AND .P1 .P2>> .TEM)
	      (<EMPTY? .TEM> .TEM)
	      (ELSE <COMPILE-ERROR <1 .TEM> .P1 .P2>)>>

" TYPE-ATOM-OK? does an atom's initial value agree with its DECL?"

<DEFINE TYPE-ATOM-OK? (P1 P2 ATM) 
	#DECL ((ATM) ATOM)
	<COND (<TYPE-OK? .P1 .P2>)
	      (ELSE
	       <COMPILE-ERROR "Atom's intial value disagrees with DECL"
			      .ATM>)>>

" Merge a group of type specs into an OR."

""

<DEFINE TYPE-MERGE ("TUPLE" TYPS) 
	#DECL ((TYPS) <PRIMTYPE VECTOR> (FTYP) FORM (LN) FIX)
	<COND (<EMPTY? .TYPS> <>)
	      (ELSE
	       <REPEAT ((ORS <1 .TYPS>))
		       <COND (<EMPTY? <SET TYPS <REST .TYPS>>> <RETURN .ORS>)>
		       <SET ORS
			    <COND (<==? <1 .TYPS> NO-RETURN> .ORS)
				  (<==? .ORS NO-RETURN> <1 .TYPS>)
				  (ELSE <TMERGE .ORS <1 .TYPS>>)>>>)>>

<DEFINE PUT-IN (LST ELE) 
   #DECL ((LST) <PRIMTYPE LIST> (VALUE) LIST)
   <COND (<AND <TYPE? .ELE FORM SEGMENT> <NOT <EMPTY? .ELE>> <==? <1 .ELE> OR>>
	  <SET ELE <LIST !<REST .ELE>>>)
	 (ELSE <SET ELE (.ELE)>)>
   <SET LST
    <MAPF ,LIST
     <FUNCTION (L1 "AUX" TT) 
	     <COND (<EMPTY? .ELE> .L1)
		   (<REPEAT ((A .ELE) B)
			    #DECL ((A B) LIST)
			    <COND (<TMATCH <1 .A> .L1>
				   <SET TT <TMERGE <1 .A> .L1>>
				   <COND (<==? .A .ELE> <SET ELE <REST .ELE>>)
					 (ELSE <PUTREST .B <REST .A>>)>
				   <RETURN T>)>
			    <AND <EMPTY? <SET A <REST <SET B .A>>>>
				 <RETURN <>>>>
		    .TT)
		   (ELSE .L1)>>
     .LST>>
   <LSORT <COND (<EMPTY? .ELE> .LST)
		(ELSE <PUTREST <REST .ELE <- <LENGTH .ELE> 1>> .LST> .ELE)>>>

<DEFINE ORSORT (F) #DECL ((F) <FORM ANY ANY>) <PUTREST .F <LSORT <REST .F>>>>

<DEFINE LSORT (L "AUX" (M ()) (B ()) (TMP ()) (IT ()) (N 0) A1 A2) 
	#DECL ((L M B TMP IT VALUE) LIST (N) FIX
	       (CMPRSN) <OR FALSE APPLICABLE>)
	<PROG ()
	      <COND (<L? <SET N <LENGTH .L>> 2> <RETURN .L>)>
	      <SET B <REST <SET TMP <REST .L <- </ .N 2> 1>>>>>
	      <PUTREST .TMP ()>
	      <SET L <LSORT .L>>
	      <SET B <LSORT .B>>
	      <SET TMP ()>
	      <REPEAT ()
		      <COND (<EMPTY? .L>
			     <COND (<EMPTY? .TMP> <RETURN .B>)
				   (ELSE <PUTREST .TMP .B> <RETURN .M>)>)
			    (<EMPTY? .B>
			     <COND (<EMPTY? .TMP> <RETURN .L>)
				   (ELSE <PUTREST .TMP .L> <RETURN .M>)>)
			    (ELSE
			     <SET A1 <1 .L>>
			     <SET A2 <1 .B>>
			     <COND (<COND (<AND <TYPE? .A1 ATOM>
						<TYPE? .A2 ATOM>>
					   <L? <STRCOMP <SPNAME .A1>
							<SPNAME .A2>> 0>)
					  (<TYPE? .A1 ATOM> T)
					  (<TYPE? .A2 ATOM> <>)
					  (<L? <FCOMPARE .A1 .A2> 0>)>
				    <SET L <REST <SET IT .L>>>)
				   (ELSE <SET B <REST <SET IT .B>>>)>
			     <PUTREST .IT ()>
			     <COND (<EMPTY? .M> <SET M <SET TMP .IT>>)
				   (ELSE
				    <SET TMP <REST <PUTREST .TMP .IT>>>)>)>>>>

""

<DEFINE FCOMPARE (F1 F2 "AUX" TC TC2 (L1 <LENGTH .F1>) (L2 <LENGTH .F2>)) 
	#DECL ((F1 F2) <PRIMTYPE LIST> (VALUE TC TC2 L1 L2) FIX)
	<COND (<==? .L1 .L2>
	       <COND (<==? <SET TC <CALL TYPE .F1>>
			   <SET TC2 <CALL TYPE .F2>>>
		      <MAPF <>
			    <FUNCTION (E1 E2)
				 <COND (<N==? .E1 .E2>
					<COND (<N==? <SET TC <CALL TYPE .E1>>
						     <SET TC2 <CALL TYPE .E2>>>
					       <COND (<L? .TC .TC2> -1)
						     (ELSE <MAPLEAVE 1>)>)
					      (<TYPE? .E1 ATOM>
					       <MAPLEAVE
						 <STRCOMP <SPNAME .E1>
							  <SPNAME .E2>>>)
					      (<TYPE? .E1 VECTOR>
					       <MAPLEAVE <VCOMP .E1 .E2>>)
					      (ELSE
					       <MAPLEAVE <FCOMPARE .E1 .E2>>)>)
				       (ELSE 0)>>
			    .F1 .F2>)
		     (<L? .TC .TC2> -1)
		     (ELSE 1)>)
	      (<L? .L1 .L2> -1)
	      (ELSE 1)>>

<DEFINE VCOMP (V1 V2 "AUX" (L1 <LENGTH .V1>) (L2 <LENGTH .V2>) E1 E2)
	#DECL ((V1 V2) <VECTOR ANY> (VALUE L1 L2) FIX)
	<COND (<G? .L1 .L2> 1)
	      (<L? .L1 .L2> -1)
	      (<N==? <SET E1 <1 .V1>> <SET E2 <1 .V2>>>
	       <COND (<AND <TYPE? .E1 FIX> <TYPE? .E2 FIX>>
		      <COND (<G? .E1 .E2> 1) (ELSE -1)>)
		     (<TYPE? .E1 FIX> 1)
		     (<TYPE? .E2 FIX> -1)
		     (ELSE <STRCOMP <SPNAME .E1> <SPNAME .E2>>)>)
	      (ELSE
	       <MAPF <>
		     <FUNCTION (E1 E2 "AUX" TC1:FIX TC2:FIX)
			  <COND (<==? .E1 .E2> 0)
				(<==? <SET TC1 <CALL TYPE .E1>>
				      <SET TC2 <CALL TYPE .E2>>>
				 <COND (<TYPE? .E1 ATOM>
					<MAPLEAVE <STRCOMP <SPNAME .E1>
							   <SPNAME .E2>>>)
				       (ELSE
					<MAPLEAVE <FCOMPARE .E1 .E2>>)>)
				(<G? .TC1 .TC2> <MAPLEAVE 1>)
				(ELSE <MAPLEAVE -1>)>>
		     <REST .V1> <REST .V2>>)>>

<DEFINE CANONICAL-DECL (D) 
	<SET D <VTS .D>>
	<COND (<AND <TYPE? .D FORM SEGMENT> <NOT <EMPTY? .D>>>
	       <COND (<==? <1 .D> OR>
		      <ORSORT <FORM OR
				    !<MAPF ,LIST ,CANONICAL-DECL <REST .D>>>>)
		     (<==? <1 .D> QUOTE> <CANONICAL-DECL <GEN-DECL <2 .D>>>)
		     (ELSE <CAN-ELE .D>)>)
	      (ELSE .D)>>

<DEFINE CAN-ELE (L "AUX" (SAME <>) SAMCNT TT TEM X Y) 
   #DECL ((L) <PRIMTYPE LIST> (SAMCNT) FIX)
   <COND
    (<AND <TYPE? <1 .L> ATOM>
	  <VALID-TYPE? <1 .L>>
	  <SET X <DECL-GET <1 .L>>>
	  <TYPE? .X FORM SEGMENT>
	  <G=? <LENGTH .X> 2>
	  <OR <=? <REST .X> <REST .L>>
	      <=? <CANONICAL-DECL
		   <CHTYPE (<SET Y <FORM PRIMTYPE <MTYPR <1 .L>>>> !<REST .L>)
			   FORM>>
		  <CANONICAL-DECL <CHTYPE (.Y !<REST .X>) FORM>>>>>
     <1 .L>)
    (ELSE
     <CHTYPE
      (<CANONICAL-DECL <1 .L>>
       !<MAPR ,LIST
	 <FUNCTION (EL "AUX" (ELE <1 .EL>) (LAST <EMPTY? <REST .EL>>)) 
	    <COND
	     (<TYPE? .ELE VECTOR>
	      <COND
	       (<AND <==? <LENGTH .ELE> 2> <TYPE? <1 .ELE> FIX>>
		<SET TT <CANONICAL-DECL <2 .ELE>>>
		<COND (<AND .SAME <=? .SAME .TT>>
		       <SET SAMCNT <+ .SAMCNT <1 .ELE>>>
		       <COND (.LAST [.SAMCNT .TT]) (ELSE <MAPRET>)>)
		      (ELSE
		       <COND (.SAME <SET TEM <GR-RET .SAME .SAMCNT>>)
			     (ELSE <SET TEM <>>)>
		       <SET SAME .TT>
		       <SET SAMCNT <1 .ELE>>
		       <COND (.LAST
			      <COND (.TEM <MAPRET .TEM <GR-RET .TT .SAMCNT>>)
				    (ELSE <GR-RET .TT .SAMCNT>)>)
			     (.TEM)
			     (ELSE <MAPRET>)>)>)
	       (<AND <==? <1 .ELE> REST>
		     <==? <LENGTH .ELE> 2>
		     <==? <2 .ELE> ANY>>
		<COND (.SAME
		       <SET TEM <GR-RET .SAME .SAMCNT>>
		       <SET SAME <>>
		       <MAPRET .TEM>)
		      (ELSE <MAPRET>)>)
	       (ELSE
		<COND (.SAME <SET TEM <GR-RET .SAME .SAMCNT>>)
		      (ELSE <SET TEM <>>)>
		<SET TT <IVECTOR <LENGTH .ELE>>>
		<PUT .TT
		     1
		     <COND (<==? <1 .ELE> OPT> OPTIONAL) (ELSE <1 .ELE>)>>
		<COND (<AND <G=? <LENGTH .ELE> 2> <==? <1 .ELE> REST>>
		       <PUT .TT 2 <SET SAME <CANONICAL-DECL <2 .ELE>>>>)
		      (ELSE <SET SAME <>>)>
		<COND
		 (<G=? <LENGTH .ELE> 3>
		  <MAPR <>
			<FUNCTION (X Y "AUX" THIS) 
				<PUT .X 1 <SET THIS <CANONICAL-DECL <1 .Y>>>>
				<COND (<N=? .THIS .SAME> <SET SAME <>>)>>
			<REST .TT 2>
			<REST .ELE 2>>
		  <COND (.SAME <SET TT [<1 .TT> <2 .TT>]>)>)>
		<SET SAME <>>
		<COND (.TEM <MAPRET .TEM .TT>) (ELSE .TT)>)>)
	     (ELSE
	      <SET ELE <CANONICAL-DECL .ELE>>
	      <COND (<AND .SAME <=? .SAME .ELE>>
		     <SET SAMCNT <+ .SAMCNT 1>>
		     <COND (.LAST <GR-RET .ELE .SAMCNT>) (ELSE <MAPRET>)>)
		    (ELSE
		     <COND (.SAME <SET TEM <GR-RET .SAME .SAMCNT>>)
			   (ELSE <SET TEM <>>)>
		     <SET SAME .ELE>
		     <SET SAMCNT 1>
		     <COND (.LAST <COND (.TEM <MAPRET .TEM .ELE>) (ELSE .ELE)>)
			   (.TEM)
			   (ELSE <MAPRET>)>)>)>>
	 <REST .L>>)
      FORM>)>>

<DEFINE GR-RET (X N) #DECL ((N) FIX) <COND (<1? .N> .X) (ELSE [.N .X])>>

<DEFINE DECL-GET (DCL "OPT" (DEF <>) "AUX" X) 
	<COND (,MIM
	       <COND (<AND <SET X <GET-DECL .DCL>> <N==? .X ANY>> .X)
		     (ELSE <GETPROP .DCL ALT-DECL .DEF>)>)
	      (ELSE <GETPROP .DCL DECL .DEF>)>>

<DEFINE MTYPR (X) 
	<COND (<MEMQ .X '[OBLIST LVAL GVAL]> ATOM) (ELSE <TYPEPRIM .X>)>>

<DEFINE GC-PRIMTYPE (ARG "AUX" ENTRY (TYP <LSH .ARG -6>))
	#DECL ((VALUE) ATOM (ENTRY) <PRIMTYPE VECTOR> (TYP) FIX)
	<M$$PTYPE <SET ENTRY <NTH ,M$$TYPE-INFO!-INTERNAL <+ 1 .TYP>>>>>

<ENDPACKAGE>
