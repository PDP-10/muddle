<NEWTYPE ORQ LIST>

<USE "CHKDCL" "COMPDEC">

<DEFINE CASE-FCN (OBJ AP
		  "AUX" (OP .PARENT) (PARENT .PARENT) (FLG T) (WIN T) TYP
			(DF <>) P TEM X)
   #DECL ((PARENT) <SPECIAL NODE> (OBJ) <FORM ANY> (VALUE) NODE)
   <COND
    (<AND
      <G? <LENGTH .OBJ> 3>
      <PROG ()
	    <COND (<OR <AND <==? <TYPE <SET X <2 .OBJ>>> GVAL>
			    <==? <SET P <CHTYPE .X ATOM>> ==?>>
		       <AND <TYPE? <SET X <2 .OBJ>> FORM>
			    <==? <LENGTH .X> 2>
			    <==? <1 .X> GVAL>
			    <==? <SET P <2 .X>> ==?>
			    ;<MEMQ <SET P <2 .X>> '[==? TYPE? PRIMTYPE?]>>>)
		  (ELSE <SET WIN <>>)>
	    1>
      <MAPF <>
       <FUNCTION (O) 
	  <COND
	   (<AND .FLG <==? .O DEFAULT>> <SET DF T>)
	   (<AND .DF <TYPE? .O LIST>> <SET DF <>> <SET FLG <>>)
	   (<AND <NOT .DF> <TYPE? .O LIST> <NOT <EMPTY? .O>>>
	    <COND
	     (<SET TEM <VAL-CHK <1 .O>>>
	      <COND (<ASSIGNED? TYP> <OR <==? .TYP <TYPE .TEM>> <SET WIN <>>>)
		    (ELSE <SET TYP <TYPE .TEM>>)>)
	     (<AND <TYPE? <SET TEM <1 .O>> SEGMENT>
		   <==? <LENGTH .TEM> 2>
		   <==? <1 .TEM> QUOTE>
		   <NOT <MONAD? <SET TEM <2 .TEM>>>>>
	      <MAPF <>
		    <FUNCTION (TY) 
			    <COND (<NOT <SET TY <VAL-CHK .TY>>> <SET WIN <>>)
				  (ELSE
				   <COND (<ASSIGNED? TYP>
					  <OR <==? .TYP <TYPE .TY>>
					      <SET WIN <>>>)
					 (ELSE <SET TYP <TYPE .TY>>)>)>>
		    .TEM>)
	     (ELSE <SET WIN <>>)>)
	   (ELSE <MAPLEAVE <>>)>
	  T>
       <REST .OBJ 3>>
      <NOT .DF>>
     <COND (<AND .WIN
		 <NOT <OR <AND <MEMQ <TYPEPRIM .TYP> '[WORD FIX]>
			       <==? .P ==?>>
			  <AND <N==? .P ==?> <==? .TYP ATOM>>>>>
	    <SET WIN <>>)>
     <COND
      (.WIN
       <SET PARENT <NODECOND ,CASE-CODE .OP <> CASE ()>>
       <PUT
	.PARENT
	,KIDS
	(<PCOMP <2 .OBJ> .PARENT>
	 <PCOMP <3 .OBJ> .PARENT>
	 !<MAPF ,LIST
	   <FUNCTION (CLA "AUX" TT) 
		   #DECL ((CLA) <OR ATOM LIST> (TT) NODE)
		   <COND (.DF <SET CLA (ELSE !.CLA)>)>
		   <COND
		    (<NOT <TYPE? .CLA ATOM>>
		     <PUT <SET TT <NODEB ,BRANCH-CODE .PARENT <> <> ()>>
			  ,PREDIC
			  <PCOMP <COND (<TYPE? <SET TEM <1 .CLA>> SEGMENT>
					<FORM QUOTE
					      <MAPF ,LIST ,VAL-CHK <2 .TEM>>>)
				       (<TYPE? .TEM ORQ>
					<FORM QUOTE
					      <MAPF ,LIST ,VAL-CHK .TEM>>)
				       (ELSE <VAL-CHK .TEM>)>
				 .TT>>
		     <PUT .TT
			  ,CLAUSES
			  <MAPF ,LIST
				<FUNCTION (O) <PCOMP .O .TT>>
				<REST .CLA>>>
		     <SET DF <>>
		     .TT)
		    (ELSE <SET DF T> <PCOMP .CLA .PARENT>)>>
	   <REST .OBJ 3>>)>)
      (ELSE <PMACRO .OBJ .OP>)>)
    (ELSE <COMPILE-ERROR "CASE in incorrect format " .OBJ>)>>