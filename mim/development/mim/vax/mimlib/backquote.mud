<PACKAGE "BACKQUOTE">

;"NOTE: This pakcage can only be used compiled.

  Loading BACKQUOTE causes subsequent READs to interpret backquote as a 
  special character.  Backquote quotes the following object EXCEPT for objects
  within it that are preceeded by a tilde.  Thus

	`<+ ~.A .INC>

  is equivalent to

	<CHTYPE (+ .A '.INC) FORM>

  This is most useful in defining MACROs, although it can be used anywhere a
  program needs to construct a large object, most of which is constant.  Note
  that BACKQUOTE makes no guarantees about ==?-ness of the objects it creates,
  so no PUTs or PUTRESTs should be done on them.

  Backquotes can be nested--they can be used to define macros that define 
  macros.  Tilde is not treated as a special character unless it is inside a
  backquoted object."

<NEWTYPE TILDE LIST '<<PRIMTYPE LIST> ANY>>

<DEFINE TILDE-READ-MACRO (CHAN CHAR) 
   <CHTYPE (<READ .CHAN>) TILDE>>

<DEFINE BACKQUOTE-READ-MACRO (CHAN CHAR) 
   <BIND ((ORT:<OR FALSE <PRIMTYPE VECTOR>>
	   <COND (<ASSIGNED? READ-TABLE> .READ-TABLE) 
		 (<GASSIGNED? READ-TABLE> ,READ-TABLE)>)
	  (NRT:<PRIMTYPE VECTOR> <STACK <IVECTOR 128 %<>>>))
      <COND (.ORT
	     <SUBSTRUC .ORT 0 <LENGTH .ORT> .NRT>)>
      <PUT .NRT %<+ <ASCII !\~> 1>
	   [!\~ !\A %<> ,TILDE-READ-MACRO %<>]>
      <PROG ((READ-TABLE:<SPECIAL <PRIMTYPE VECTOR>> .NRT))
	 <BIND ((B <BACKQUOTIFY <READ .CHAN>>))
	    <COND (<TYPE? .B TILDE> <1 .B>) (ELSE <FORM QUOTE .B>)>>>>>

;"Objects wrapped in a tilde should be evaluated.  All other objects should be
  quoted.  BACKQUOTIFY's job is to return an object that contains no TILDEs,
  although it may (and usually will) return an object of type TILDE to 
  indicate that the EVALUATION of the contents is the object desired, not the
  object itself.
  
  The convention of marking objects that should be evaluated with TILDE could
  be changed to marking objects that should not be evaluated with QUOTE, but
  since we expect most of the item to be quoted, this would be less efficient."

<DEFINE BACKQUOTIFY (OBJ) 
   <COND
    ;"If the object needs to be evaluated, or couldn't contain any TILDEs,
      then pass it on."
    (<OR <TYPE? .OBJ TILDE> <MONAD? .OBJ>> .OBJ)
    (ELSE
     <BIND ((PTYP:ATOM <PRIMTYPE .OBJ>))
	;"Only lists and vectors can contain interesting objects (like TILDEs),
          so any other primtype can just be passed on like the monads."
	<COND
	 (<==? .PTYP LIST>
	  <BIND ((FLAG:<OR FALSE TILDE> %<>))
	     ;"BACKQUOTIFY each of the sub-objects, and remember the last one
	       that came back tilded."
	     <MAPR %<>
		   <FUNCTION (ROBJ "AUX" B) 
		      <1 .ROBJ <SET B <BACKQUOTIFY <1 .ROBJ>>>>
		      <COND (<TYPE? .B TILDE> <SET FLAG .B>)>>
		   .OBJ:<PRIMTYPE LIST>>
	     <COND
	      ;"If there was a tilded one, then remove the tildes on the 
	       sub-objects, quote the un-tilded objects that need quotes,
	       and wrap a tlde around the whole thing.  In other words,
	       create an object that wll evaluate to the desired object.
	       
	       If enough objects (three or more in the interpreter, one or
	       more in the compiler) at the end of the list are quoted, use
	       the !'(...) trick to avoid copying list structure."
	      (.FLAG
	       <MAPR %<>
		     <FUNCTION (ROBJ "AUX" (SUBOBJ <1 .ROBJ>)) 
			<COND
			 (<TYPE? .SUBOBJ TILDE>
			  <1 .ROBJ <1 .SUBOBJ>>
			  <COND (<AND <==? .SUBOBJ .FLAG>
				      <NOT <LENGTH? 
					    .ROBJ 
					    <COND (<FEATURE? "COMPILER"> 0)
						  (ELSE 2)>>>>
				 <PUTREST .ROBJ
					  (<CHTYPE (QUOTE <REST .ROBJ>) 
						   SEGMENT>)>
				 <MAPLEAVE>)>)
			 (<NOT <TYPE? .SUBOBJ
				      ATOM FIX FLOAT STRING BYTES UVECTOR>>
			  ;"the list of self-quoting objects that I trust"
			  <1 .ROBJ <FORM QUOTE .SUBOBJ>>)>>
		     .OBJ:<PRIMTYPE LIST>>
	       ;"Make sure the object evaluates to the right type, shove it in
	         a tilde, and return it."
	       <COND (<NOT <TYPE? .OBJ LIST>>
		      <SET OBJ <FORM CHTYPE <CHTYPE .OBJ LIST> <TYPE .OBJ>>>)>
	       <1 .FLAG .OBJ>
	       .FLAG)
	      ;"If all of the sub-objects were quoted, just return the
		(now un-tilded) object."
	      (ELSE .OBJ)>>)
	 (<==? .PTYP VECTOR>
	  ;"All of the comments for lists apply to vectors, except for the 
	    !'(...) trick."
	  <BIND ((FLAG %<>))
	     #DECL ((FLAG) <OR FALSE TILDE>)
	     <MAPR %<>
		   <FUNCTION (ROBJ "AUX" B) 
		      <1 .ROBJ <SET B <BACKQUOTIFY <1 .ROBJ>>>>
		      <COND (<TYPE? .B TILDE> <SET FLAG .B>)>>
		   .OBJ:<PRIMTYPE VECTOR>>
	     <COND (.FLAG
		    <MAPR %<>
			  <FUNCTION (ROBJ "AUX" (SUBOBJ <1 .ROBJ>)) 
			     <COND (<TYPE? .SUBOBJ TILDE>
				    <1 .ROBJ <1 .SUBOBJ>>)
				   (<NOT <TYPE? .SUBOBJ 
						ATOM FIX FLOAT STRING BYTES 
						UVECTOR>>
				    ;"the list of self-quoting objects that
				      I trust"
				    <1 .ROBJ <FORM QUOTE .SUBOBJ>>)>>
			  .OBJ:<PRIMTYPE VECTOR>>
		    <COND (<NOT <TYPE? .OBJ VECTOR>>
			   <SET OBJ
				<FORM CHTYPE
				      <CHTYPE .OBJ VECTOR>
				      <TYPE .OBJ>>>)>
		    <1 .FLAG .OBJ>
		    .FLAG)
		   (ELSE .OBJ)>>)
	 (ELSE .OBJ)>>)>>

<DEFINE BACKQUOTE-INIT ("AUX" RT:<PRIMTYPE VECTOR>)
   <COND (<GASSIGNED? READ-TABLE>
	  <BIND ((GRT:<OR FALSE VECTOR> ,READ-TABLE))
	     <COND (.GRT
		    <COND (<L? <LENGTH .GRT> 128>
			   <BIND ((NRT <IVECTOR 128 %<>>))
				<SUBSTRUC .GRT 0 <LENGTH .GRT> .NRT>
				<SET RT .NRT>>)
			  (ELSE <SET RT .GRT>)>)
		   (ELSE <SET RT <IVECTOR 128 %<>>>)>>)
	 (ELSE <SET RT <IVECTOR 128 %<>>>)>
   <PUT .RT %<+ <ASCII !\`> 1>
	[!\` !\A %<> ,BACKQUOTE-READ-MACRO %<>]>
   <SETG READ-TABLE .RT>
   <REPEAT ((LBIND:<OR FALSE LBIND> <CALL NTHR READ-TABLE ,M$$LVAL>))
      <COND (.LBIND
	     <BIND ((LVAL <CALL NTHR .LBIND ,M$$VALU>))
		<COND (<TYPE? .LVAL UNBOUND FALSE>
		       <CALL PUTR .LBIND ,M$$VALU .RT>)
		      (ELSE
		       <BIND ((LRT:<PRIMTYPE VECTOR> .LVAL))
			  <COND (<L? <LENGTH .LRT> 128>
				 <BIND ((NRT:VECTOR <IVECTOR 128 %<>>))
				    <SUBSTRUC .LRT 0 <LENGTH .LRT> .NRT>
				    <SET LRT .NRT>>)>
			  <CALL PUTR .LBIND ,M$$VALU .LRT>
			  <PUT .LRT %<+ <ASCII !\`> 1>
			       [!\` !\A %<> ,BACKQUOTE-READ-MACRO %<>]>>)>>
	     <SET LBIND <CALL NTHR .LBIND ,M$$PATM>>)
	    (ELSE <RETURN>)>>
   T>

<COND (<AND <GASSIGNED? BACKQUOTE-INIT>
	    <TYPE? ,BACKQUOTE-INIT MSUBR>>
       <BACKQUOTE-INIT>)>
       
<ENDPACKAGE>
