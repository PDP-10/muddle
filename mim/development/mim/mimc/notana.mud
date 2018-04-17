
<PACKAGE "NOTANA">

<ENTRY NOT-ANA
       TYPE?-ANA
       ==?-ANA
       VALID-TYPE?-ANA
       TYPE-C-ANA
       =?-ANA
       S=?-ANA
       STRCOMP-ANA
       SUBSTRUC-ANA
       ATOM-PART-ANA
       OFFSET-PART-ANA
       PUT-GET-DECL-ANA>

<USE "SYMANA" "CHKDCL" "COMPDEC" "CARANA" "ADVMESS" "NPRINT">

"	This module contains analysis and generation functions for
NOT, TYPE? and ==?.  See SYMANA for more details about ANALYSIS and
CODGEN for more detali abour code generation.
"

"Analyze NOT usage make sure arg can be FALSE."

<DEFINE NOT-ANA (NOD RTYP
		 "AUX" TEM (FLG <==? .PRED <PARENT .NOD>>) (STR .TRUTH)
		       (SUNT .UNTRUTH))
	#DECL ((NOD) NODE (STR SUNT) LIST)
	<PROG ((PRED <AND .FLG .NOD>) (TRUTH ()) (UNTRUTH ()))
	      #DECL ((PRED) <SPECIAL ANY> (TRUTH UNTRUTH) <SPECIAL LIST>)
	      <COND (<SET TEM <SEGFLUSH .NOD .RTYP>> <SET FLG <>>)
		    (ELSE
		     <ARGCHK <LENGTH <KIDS .NOD>> 1 NOT .NOD>
		     <SET TEM <ANA <1 <KIDS .NOD>> ANY>>
		     <PUT .NOD ,NODE-TYPE ,NOT-CODE>
		     <SET TEM
			  <COND (<==? <ISTYPE? .TEM> FALSE>
				 <TYPE-OK? BOOL-TRUE .RTYP>)
				(<TYPE-OK? .TEM FALSE>
				 <TYPE-OK? BOOLEAN .RTYP>)
				(ELSE <TYPE-OK? BOOL-FALSE .RTYP>)>>
		     <SET STR .UNTRUTH>
		     <SET SUNT .TRUTH>)>>
	<COND (.FLG
	       <SET TRUTH (!.STR !.TRUTH)>
	       <SET UNTRUTH (!.SUNT !.UNTRUTH)>)>
	.TEM>

"	Analyze N==? and ==? usage.  Complain if types differ such that
 the args  can never be ==?."

<DEFINE ==?-ANA (NOD RTYP
		 "AUX" (K <KIDS .NOD>)
		       (WHON <AND <==? .PRED <PARENT .NOD>> .NOD>) (WHO ())
		       KT NT (GLN .NOD) (GLE ()))
	#DECL ((NOD) NODE (K) <LIST [REST NODE]> (WHON GLN) <SPECIAL NODE>
	       (WHO GLE) <SPECIAL LIST>)
	<COND (<SEGFLUSH .NOD .RTYP>)
	      (ELSE
	       <COND (<AND <==? <LENGTH .K> 1>
			   <==? <NODE-TYPE <SET NT <1 <KIDS .NOD>>>>
				,SUBR-CODE>
			   <==? <NODE-NAME .NT> LENGTH>
			   <==? <LENGTH <SET KT <KIDS .NT>>> 2>>
		      <COMPILE-WARNING
		       "Attempting to repair probable erroneous code:
"
		       .NOD
		       "
replaced by">
		      <PROG ()
			     <PUTREST .K <REST .KT>>
			     <PUTREST .KT ()>
			     <PUT <1 .KT> ,PARENT .NOD>>
		      <NODE-COMPLAIN .NOD>
		      <CRLF>)>
	       <ARGCHK 2 <LENGTH .K> ==? .NOD>
	       <ANA <1 .K> ANY>
	       <ANA <2 .K> ANY>
	       <COND (<AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
			   <==? <NODE-TYPE <2 .K>> ,QUOTE-CODE>>
		      <COND (<==? <NODE-NAME .NOD> ==?>
			     <PUT .NOD ,NODE-NAME <==? <NODE-NAME <1 .K>>
						       <NODE-NAME <2 .K>>>>)
			    (ELSE
			     <PUT .NOD ,NODE-NAME <N==? <NODE-NAME <1 .K>>
						        <NODE-NAME <2 .K>>>>)>
		      <PUT .NOD ,KIDS ()>
		      <PUT .NOD ,NODE-TYPE ,QUOTE-CODE>
		      <COND (<NODE-NAME .NOD> <TYPE-OK? ATOM .RTYP>)
			    (ELSE <TYPE-OK? FALSE .RTYP>)>)
		     (ELSE
		      <PUT .NOD ,NODE-TYPE ,EQ-CODE>
		      <COND (<AND <==? <ISTYPE? <RESULT-TYPE <1 .K>>> FIX>
				  <==? <ISTYPE? <RESULT-TYPE <2 .K>>> FIX>>
			     <PUT .NOD ,NODE-TYPE ,TEST-CODE>
			     <HACK-BOUNDS .WHO .GLE .NOD .K>)>
		      <TYPE-OK? BOOLEAN .RTYP>)>)>>


"	Ananlyze TYPE? usage warn about any potential losers by using
TYPE-OK?. "

<DEFINE TYPE?-ANA (NOD RTYP
		   "AUX" (K <KIDS .NOD>) (LN <LENGTH .K>) ITYP (ALLGOOD T)
			 (WHO ()) (FTYP ()) (FNOK <>)
			 (WHON <AND <==? .PRED <PARENT .NOD>> .NOD>) TTYP)
   #DECL ((NOD) NODE (K) <LIST [REST NODE]> (LN) FIX (ITYP) ANY
	  (ALLGOOD) <OR FALSE ATOM> (WHON) <SPECIAL <OR NODE FALSE>>
	  (WHO) <SPECIAL LIST> (FTYP) LIST)
   <COND
    (<SEGFLUSH .NOD .RTYP> <TYPE-OK? .RTYP '<OR ATOM FALSE>>)
    (ELSE
     <COND (<L? .LN 2>
	    <COMPILE-ERROR "Too few arguments to TYPE? " .NOD>)>
     <SET ITYP <EANA <1 .K> ANY TYPE?>>
     <MAPF <>
	   <FUNCTION (N "AUX" FLG) 
		   #DECL ((N) NODE)
		   <PROG ()
			 <EANA .N ATOM TYPE?>
			 <COND (<N==? <NODE-TYPE .N> ,QUOTE-CODE>
				<RETURN <SET ALLGOOD <>>>)>
			 <COND (<NOT <ISTYPE? <NODE-NAME .N>>>
				<COMPILE-ERROR
					  "Argument to TYPE? not a type "
					  .NOD>)>
			 <AND <TYPE-OK? <NODE-NAME .N> .ITYP>
			     <SET FTYP (<NODE-NAME .N> !.FTYP)>>>>
	   <REST .K>>
     <COND (<AND .ALLGOOD <NOT <EMPTY? .FTYP>>>
	    <SET TTYP
		 <COND (<EMPTY? <REST .FTYP>> <1 .FTYP>)
		       (ELSE <CHTYPE (OR !.FTYP) FORM>)>>
	    <PUT .NOD ,NODE-TYPE ,TY?-CODE>
	    <SET FNOK <NOT <TYPE-OK? <FORM NOT .TTYP> .ITYP>>>
	    <MAPF <>
		  <FUNCTION (L "AUX" (FLG <1 .L>) (SYM <2 .L>)) 
			  #DECL ((L) <LIST <OR ATOM FALSE> SYMTAB> (SYM) SYMTAB)
			  <SET TRUTH
			       <ADD-TYPE-LIST .SYM
					      .TTYP
					      .TRUTH
					      .FLG
					      <REST .L 2>>>
			  <OR .FNOK
			      <SET UNTRUTH
				   <ADD-TYPE-LIST .SYM
						  <FORM NOT .TTYP>
						  .UNTRUTH
						  .FLG
						  <REST .L 2>>>>>
		  .WHO>)
	   (.ALLGOOD <PUT .NOD ,NODE-TYPE ,TY?-CODE>)
	   (ELSE
	    <AND .VERBOSE <ADDVMESS .NOD ("Not open compiled.")>>
	    <PUT .NOD ,NODE-TYPE ,ISUBR-CODE>)>
     <TYPE-OK? <COND (<NOT .ALLGOOD> '<OR FALSE ATOM>)
		   (<EMPTY? .FTYP> FALSE)
		   (.FNOK ATOM)
		   (ELSE '<OR FALSE ATOM>)>
	     .RTYP>)>>


<DEFINE VALID-TYPE?-ANA (N R "AUX" (K <KIDS .N>) (LN <LENGTH .K>))
	#DECL ((N) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK 1 .LN VALID-TYPE? .N>
	       <EANA <1 .K> ATOM VALID-TYPE?>
	       <PUT .N ,NODE-TYPE ,VALID-CODE>
	       <TYPE-OK? .R '<OR FALSE TYPE-C>>)>>

<DEFINE TYPE-C-ANA (N R "AUX" (K <KIDS .N>) (LN <LENGTH .K>)) 
	#DECL ((N) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK .LN '(1 2) VALID-TYPE? .N>
	       <EANA <1 .K> ATOM TYPE-C>
	       <COND (<==? .LN 2> <EANA <2 .K> ATOM TYPE-C>)>
	       <PUT .N ,NODE-TYPE ,TYPE-C-CODE>
	       <TYPE-OK? .R TYPE-C>)>>

<DEFINE =?-ANA (N R "AUX" (K <KIDS .N>) (LN <LENGTH .K>) N1 N2 T1 T2) 
	#DECL ((N N1 N2) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK .LN 2 <NODE-NAME .N> .N>
	       <EANA <SET N1 <1 .K>> ANY <NODE-NAME .N>>
	       <EANA <SET N2 <2 .K>> ANY <NODE-NAME .N>>
	       <COND (<==? <NODE-TYPE .N1> ,QUOTE-CODE>
		      <SET N1 <2 .K>>
		      <SET N2 <1 .K>>)>
	       <SET T2 <ISTYPE? <RESULT-TYPE .N2>>>
	       <COND (<OR <==? <SET T1 <ISTYPE? <RESULT-TYPE .N1>>> STRING>
			  <==? .T2 STRING>>
		      <PUT .N ,NODE-TYPE ,=?-STRING-CODE>
		      <TYPE-OK? BOOLEAN .R>)
		     (<AND .T1 .T2 <N==? .T1 .T2>> <TYPE-OK? BOOL-FALSE .R>)
		     (ELSE <TYPE-OK? BOOLEAN .R>)>)>>

<DEFINE S=?-ANA (N R "AUX" (K <KIDS .N>)) 
	#DECL ((N) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 2 <NODE-NAME .N> .N>
	       <EANA <1 .K> STRING S=?>
	       <EANA <2 .K> STRING S=?>
	       <PUT .N ,NODE-TYPE ,=?-STRING-CODE>
	       <TYPE-OK? BOOLEAN .R>)>>

<DEFINE ATOM-PART-ANA (N R "AUX" (K <KIDS .N>) (NM <NODE-NAME .N>) NN)
	#DECL ((NN N) NODE (K) <LIST [REST NODE]> (NM) ATOM)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> <COND (<OR <==? .NM GBIND>
					      <==? .NM LBIND>> '(1 2))
					 (ELSE 1)> .NM .N>
	       <EANA <1 .K> ATOM .NM>
	       <COND (<NOT <EMPTY? <REST .K>>> <EANA <SET NN <2 .K>> ANY .NM>)>
	       <COND (<AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
			   <N==? .NM LBIND>
			   <N==? .NM GBIND>>
		      <PUT .N ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .N ,KIDS ()>
		      <PUT .N ,NODE-NAME <APPLY ,.NM <NODE-NAME <1 .K>>>>
		      <TYPE-OK? <TYPE <NODE-NAME .N>> .R>)
		     (ELSE
		      <COND (<OR <AND <N==? .NM GBIND> <N==? .NM LBIND>>
				 <EMPTY? <REST .K>>
				 <AND <==? <NODE-TYPE .NN> ,QUOTE-CODE>
				      <NOT <NODE-NAME .NN>>>>
			     <PUT .N ,NODE-TYPE ,ATOM-PART-CODE>)>
		      <TYPE-OK? .R <COND (<==? .NM SPNAME> STRING)
					 (<==? .NM OBLIST?> '<OR FALSE OBLIST>)
					 (ELSE .NM)>>)>)>>

<DEFINE PUT-GET-DECL-ANA (N R "AUX" (K <KIDS .N>) (NM <NODE-NAME .N>) ST)
	#DECL ((N) NODE (K) <LIST [REST NODE]> (NM) ATOM)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> <COND (<==? .NM PUT-DECL> 2)
					 (ELSE 1)> .NM .N>
	       <SET ST <EANA <1 .K> '<OR ATOM OFFSET GBIND LBIND> .NM>>
	       <COND (<==? .NM PUT-DECL>
		      <SET ST <OR <TYPE-AND .ST .R> .ST>>
		      <EANA <2 .K> '<OR ATOM FALSE FORM SEGMENT> .NM>
		      <PUT .N ,SIDE-EFFECTS (.N !<SIDE-EFFECTS .N>)>)>
	       <COND (<AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE> <==? .NM GET-DECL>>
		      <PUT .N ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .N ,KIDS ()>
		      <PUT .N ,NODE-NAME <GET-DECL <NODE-NAME <1 .K>>>>
		      <TYPE-OK? <TYPE <NODE-NAME .N>> .R>)
		     (ELSE
		      <COND (<MEMQ <ISTYPE? .ST> '[LBIND GBIND OFFSET]>
			     <PUT .N ,NODE-TYPE ,PUT-GET-DECL-CODE>)
			    (.VERBOSE
			     <ADDVMESS .N (.NM "Not open compiled because type is "
					  .ST)>)>
		      <TYPE-OK? <COND (<==? .NM GET-DECL>
				       '<OR ATOM FALSE FORM SEGMENT>)
				      (ELSE .ST)> .R>)>)>>

<DEFINE OFFSET-PART-ANA (N R "AUX" (K <KIDS .N>) (NM <NODE-NAME .N>))
	#DECL ((N) NODE (K) <LIST [REST NODE]> (NM) ATOM)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> <COND (<==? .NM INDEX> 1)
					 (ELSE '(1 2))> .NM .N>
	       <EANA <1 .K> OFFSET .NM>
	       <COND (<NOT <EMPTY? <REST .K>>>
		      <EANA <2 .K> '<OR ATOM FALSE FORM SEGMENT> .NM>)>
	       <COND (<AND <==? <NODE-TYPE <1 .K>> ,QUOTE-CODE>
			   <EMPTY? <REST .K>>>
		      <PUT .N ,NODE-TYPE ,QUOTE-CODE>
		      <PUT .N ,KIDS ()>
		      <PUT .N ,NODE-NAME <APPLY ,.NM <NODE-NAME <1 .K>>>>
		      <TYPE-OK? <TYPE <NODE-NAME .N>> .R>)
		     (ELSE
		      <PUT .N ,NODE-TYPE ,OFFSET-PART-CODE>
		      <TYPE-OK? .R
				<COND (<==? .NM INDEX> FIX)
				      (<NOT <EMPTY? <REST .K>>> OFFSET)
				      (ELSE '<OR ATOM FALSE FORM SEGMENT>)>>)>)>>

<DEFINE STRCOMP-ANA (N R "AUX" (K <KIDS .N>))
	#DECL ((N) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK <LENGTH .K> 2 <NODE-NAME .N> .N>
	       <COND (<AND <STRCOMP-ARG-ANA <1 .K> .N 1>
			   <STRCOMP-ARG-ANA <2 .K> .N 2>>
		      <PUT .N ,NODE-TYPE ,=?-STRING-CODE>)>
	       <TYPE-OK? FIX .R>)>>

<DEFINE STRCOMP-ARG-ANA (N:NODE P:NODE IDX:FIX "AUX" TYP ITYP NN:NODE)
	<SET TYP <EANA .N ANY STRCOMP>>
	<COND (<SET ITYP <ISTYPE? .TYP>>
	       <COND (<==? .ITYP ATOM>
		      <COND (<==? <NODE-TYPE .N> ,QUOTE-CODE>
			     <PUT .N ,NODE-NAME <SPNAME <NODE-NAME .N>>>
			     <PUT .N ,RESULT-TYPE STRING>)
			    (ELSE
			     <SET NN <NODEFM ,ATOM-PART-CODE .P STRING SPNAME
					     (.N) ,SPNAME>>
			     <PUT <KIDS .P> .IDX .NN>
			     <PUT .N ,PARENT .NN>)>)>
	       T)
	      (<=? .TYP '<OR ATOM STRING>> T)
	      (<NOT <TYPE-OK? .TYP '<OR ATOM STRING>>>
	       <COMPILE-ERROR "Argument wrong type to: " STRCOMP .P>)
	      (ELSE <>)>>

<DEFINE SUBSTRUC-ANA (N R "AUX" (K <KIDS .N>) (LN <LENGTH .K>) ST) 
	#DECL ((N) NODE (K) <LIST [REST NODE]> (LN) FIX)
	<COND (<SEGFLUSH .N .R>)
	      (ELSE
	       <ARGCHK .LN '(1 4) <NODE-NAME .N> .N>
	       <SET ST <EANA <1 .K> STRUCTURED SUBSTRUC>>
	       <COND (<G? .LN 1> <EANA <2 .K> FIX SUBSTRUC>)>
	       <COND (<G? .LN 2> <EANA <3 .K> FIX SUBSTRUC>)>
	       <COND (<G? .LN 3>
		      <SET ST <STRUCTYP .ST>>
		      <SET ST <EANA <4 .K> <COND (.ST <FORM PRIMTYPE .ST>)
						 (ELSE STRUCTURED)>
				    SUBSTRUC>>
		      <PUT .N ,SIDE-EFFECTS (.N !<SIDE-EFFECTS .N>)>)>
	       <COND (<MEMQ <STRUCTYP .ST> '[STRING VECTOR UVECTOR BYTES]>
		      <PUT .N ,NODE-TYPE ,SUBSTRUC-CODE>)>
	       <TYPE-OK? <STRUCTYP .ST> .R>)>>


<COND (<AND <GASSIGNED? NOT-ANA> <GASSIGNED? ELEMENT-DECL>>
       <PUTPROP ,NOT ANALYSIS ,NOT-ANA>
       <PUTPROP ,==? ANALYSIS ,==?-ANA>
       <PUTPROP ,N==? ANALYSIS ,==?-ANA>
       <PUTPROP ,TYPE? ANALYSIS ,TYPE?-ANA>
       <PUTPROP ,=? ANALYSIS ,=?-ANA>
       <PUTPROP ,N=? ANALYSIS ,=?-ANA>
       <PUTPROP ,VALID-TYPE? ANALYSIS ,VALID-TYPE?-ANA>
       <PUTPROP ,TYPE-C ANALYSIS ,TYPE-C-ANA>
       <PUTPROP ,INDEX ANALYSIS ,OFFSET-PART-ANA>
       <PUTPROP ,ELEMENT-DECL ANALYSIS ,OFFSET-PART-ANA>
       <PUTPROP ,PUT-DECL ANALYSIS ,PUT-GET-DECL-ANA>
       <PUTPROP ,GET-DECL ANALYSIS ,PUT-GET-DECL-ANA>
       <PUTPROP ,SPNAME ANALYSIS ,ATOM-PART-ANA>
       <PUTPROP ,OBLIST? ANALYSIS ,ATOM-PART-ANA>
       <PUTPROP ,LBIND ANALYSIS ,ATOM-PART-ANA>
       <PUTPROP ,GBIND ANALYSIS ,ATOM-PART-ANA>
       <PUTPROP ,S=? ANALYSIS ,S=?-ANA>
       <PUTPROP ,STRCOMP ANALYSIS ,STRCOMP-ANA>
       <PUTPROP ,SUBSTRUC ANALYSIS ,SUBSTRUC-ANA>)>

<ENDPACKAGE>
