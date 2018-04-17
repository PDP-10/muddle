<PACKAGE "GETORD">

<ENTRY GETORDER>
"GETORDER FUNCTIONS"

<DEFINE CHECK (ATM)
	#DECL ((ATM) ATOM)
	<AND <GASSIGNED? .ATM>
	     <OR <TYPE? ,.ATM FUNCTION>
		 <TYPE? ,.ATM MACRO>>>>

<DEFINE PREV (LS SUBLS)
	#DECL ((LS SUBLS) LIST (VALUE) LIST)
	<REST .LS <- <LENGTH .LS> <LENGTH .SUBLS> 1>>>

<DEFINE SPLOUTEM (FL OU)
	#DECL ((FL) LIST (OU) ATOM)
	<REPEAT (TEM)
		#DECL ((TEM) <OR FALSE LIST>)
		<COND (<EMPTY? .FL> <RETURN T>)
		      (<SET TEM <MEMQ .OU <1 .FL>>>
		       <COND (<==? <1 .FL> .TEM> <PUT .FL 1 <REST .TEM>>)
			     (ELSE <PUTREST <PREV <1 .FL> .TEM> <REST .TEM>>)>)>
		<SET FL <REST .FL 2>>>>

<DEFINE REVERSE (LS)
	#DECL ((LS) LIST)
	<REPEAT ((RES ()) (TEM ()))
		#DECL ((RES TEM) LIST)
		<COND (<EMPTY? .LS> <RETURN .RES>)>
		<SET TEM <REST .LS>>
		<SET RES <PUTREST .LS .RES>>
		<SET LS .TEM>>>

<DEFINE ORDEREM (FLIST)
   #DECL ((FLIST) LIST)
   <REPEAT (TEM (RES ()))
     #DECL ((RES) <LIST [REST <OR ATOM LIST>]>
	    (VALUE) <LIST [REST <OR ATOM LIST>]>
	    (TEM) <PRIMTYPE LIST>)
     <COND
      (<EMPTY? .FLIST> <RETURN <REVERSE .RES>>)
      (<SET TEM <MEMQ () .FLIST>>
       <SET RES (<2 .TEM> !.RES)>
       <COND (<==? .TEM .FLIST> <SET FLIST <REST .FLIST 2>>)
	     (ELSE <PUTREST <PREV .FLIST .TEM> <REST .TEM 2>>)>
       <SPLOUTEM .FLIST <1 .RES>>)
      (ELSE
       <PROG ((RES2 ()) GOTONE)
	     #DECL ((RES2) LIST)
	     <SET GOTONE <>>
	     <REPEAT ((RES1 .FLIST))
		     #DECL ((RES1) LIST)
		     <COND (<NOT <CALLME <2 .RES1> .FLIST>>
			    <SET GOTONE T>
			    <SET RES2 (<2 .RES1> !.RES2)>
			    <COND (<==? .FLIST .RES1>
				   <SET FLIST <REST .FLIST 2>>)
				  (ELSE
				   <PUTREST <PREV .FLIST .RES1>
					    <REST .RES1 2>>)>)>
		     <AND <EMPTY? <SET RES1 <REST .RES1 2>>> <RETURN>>>
	     <COND (.GOTONE <AGAIN>)
		   (<NOT <EMPTY? .FLIST>> <SET FLIST <CORDER .FLIST>>)>
	     <SET TEM <REVERSE .RES>>
	     <COND (<NOT <EMPTY? .FLIST>>
		    <COND (<EMPTY? .RES>
			   <SET TEM .FLIST>
			   <SET RES <REST .FLIST <- <LENGTH .FLIST> 1>>>)
			  (ELSE
			   <SET RES
				<REST <PUTREST .RES .FLIST>
				      <LENGTH .FLIST>>>)>)>
	     <COND (<EMPTY? .RES> <SET RES .RES2>)
		   (ELSE <PUTREST .RES .RES2> <SET RES .TEM>)>>
       <RETURN .RES>)>>>

<DEFINE CALLME (ATM LST)
	#DECL ((ATM) ATOM (LST) <LIST [REST <LIST [REST ATOM]> ATOM]>)
	<REPEAT ()
		<AND <EMPTY? .LST> <RETURN <>>>
		<AND <MEMQ .ATM <1 .LST>> <RETURN>>
		<SET LST <REST .LST 2>>>>

<DEFINE CORDER (LST "AUX" (RES ()))
	#DECL ((LST) <LIST [REST <LIST [REST ATOM]> ATOM]> (RES) LIST)
	<REPEAT ((LS .LST))
		#DECL ((LS) <LIST [REST LIST ATOM]>)
		<AND <EMPTY? .LS> <RETURN>>
		<PUT .LS 1 <ALLREACH (<2 .LS>) <1 .LS> .LST>>
		<SET LS <REST .LS 2>>>
	<REPEAT ((PNT ()))
		#DECL ((PNT) <LIST [REST LIST ATOM]>)
		<REPEAT ((SHORT <CHTYPE <MIN> FIX>) (TL 0) (LST .LST))
			#DECL ((SHORT TL) FIX (LST) <LIST [REST LIST ATOM]>)
			<AND <EMPTY? .LST> <RETURN>>
			<COND (<L? <SET TL <LENGTH <1 .LST>>> .SHORT>
			       <SET SHORT .TL>
			       <SET PNT .LST>)>
			<SET LST <REST .LST 2>>>
		<SET RES
		     (<COND (<1? <LENGTH <1 .PNT>>> <1 <1 .PNT>>)
			    (ELSE <1 .PNT>)>
		      !.RES)>
		<MAPF <> <FUNCTION (ATM) <SPLOUTEM .LST .ATM>> <1 .PNT>>
		<REPEAT (TEM)
			<COND (<SET TEM <MEMQ () .LST>>
			       <COND (<==? .TEM .LST> <SET LST <REST .TEM 2>>)
				     (ELSE
				      <PUTREST <PREV .LST .TEM>
					       <REST .TEM 2>>)>)
			      (ELSE <RETURN>)>>
		<AND <EMPTY? .LST> <RETURN>>>
	<REVERSE .RES>>

<DEFINE ALLREACH (LATM LST MLST)
   #DECL ((LATM LST) <LIST [REST ATOM]>
	  (MLST) <LIST [REST <LIST [REST ATOM]> ATOM]>)
   <MAPF <>
    <FUNCTION (ATM)
	    #DECL ((ATM) ATOM)
	    <COND (<MEMQ .ATM .LATM>)
		  (ELSE
		   <SET LATM
			<ALLREACH (.ATM !.LATM)
				  <REPEAT ((L .MLST))
					  #DECL ((L) <LIST [REST LIST ATOM]>)
					  <AND <==? <2 .L> .ATM>
					       <RETURN <1 .L>>>
					  <SET L <REST .L 2>>>
				  .MLST>>)>>
    .LST>
   .LATM>

<DEFINE REMEMIT (ATM)
	#DECL ((ATM) ATOM (FUNC) <SPECIAL ATOM>
	       (FUNCL) <SPECIAL <LIST [REST ATOM]>>)
	<OR <==? .ATM .FUNC>
	    <MEMQ .ATM .FUNCL>
	    <SET FUNCL (.ATM !.FUNCL)>>>

<DEFINE FINDREC (OBJ "AUX" (FM '<>))
	#DECL ((FM) FORM)
	<COND (<MONAD? .OBJ>)
	      (<AND <TYPE? .OBJ FORM SEGMENT>
		    <NOT <EMPTY? <SET FM <CHTYPE .OBJ FORM>>>>>
	       <COND (<AND <TYPE? <1 .FM> ATOM> <GASSIGNED? <1 .FM>>>
		      <AND <TYPE? ,<1 .FM> FUNCTION> <REMEMIT <1 .FM>>>
		      <AND <TYPE? ,<1 .FM> MACRO>
			<NOT <EMPTY? ,<1 .FM>>>
				<FINDREC <EMACRO .FM>>>
				;"Analyze expansion of MACRO call"
		      <AND <OR <==? ,<1 .FM> ,MAPF> <==? ,<1 .FM> ,MAPR>>
			   <NOT <LENGTH? .FM 3>>
			   <PROG ()
				 <AND <TYPE? <2 .FM> FORM> <CHK-GVAL <2 .FM>>>
				 T>
			   <PROG ()
				 <AND <TYPE? <3 .FM> FORM>
				      <CHK-GVAL <3 .FM>>>>>)
		     (<STRUCTURED? <1 .OBJ>> <MAPF <> ,FINDREC <1 .OBJ>>)>
	       <COND (<EMPTY? <REST .OBJ>>)
		     (ELSE <MAPF <> ,FINDREC <REST .OBJ>>)>)
	      (ELSE <MAPF <> ,FINDREC .OBJ>)>>

<DEFINE EMACRO (OBJ "AUX" (ERR <CLASS "ERROR">) TEM) 
	<COND (.ERR <OFF .ERR>)>
	<ON <HANDLER "ERROR"
		     <FUNCTION (FR "TUPLE" T) 
			<COND (<AND <GASSIGNED? MACACT> <LEGAL? ,MACACT>>
			       <DISMISS [!.T] ,MACACT>)
			      (ELSE <LISTEN .T>)>>
		     100>>
	<COND (<TYPE? <SET TEM
			   <PROG MACACT () #DECL ((MACACT) <SPECIAL ANY>)
				 <SETG MACACT .MACACT>
				 (<EXPAND .OBJ>)>>
		      VECTOR>
	       <OFF "ERROR">
	       <COND (.ERR <ON .ERR>)>
	       <ERROR " MACRO EXPANSION LOSSAGE " !.TEM>)
	      (ELSE <OFF "ERROR"> <AND .ERR <ON .ERR>> <1 .TEM>)>>

<DEFINE CHK-GVAL (FM) #DECL ((FM) FORM)
	<AND	<==? <LENGTH .FM> 2>
		<TYPE? <1 .FM> ATOM>
		<==? ,<1 .FM> ,GVAL>
		<TYPE? <2 .FM> ATOM>
		<GASSIGNED? <2 .FM>>
		<OR <TYPE? ,<2 .FM> FUNCTION>
			<AND <TYPE? ,<2 .FM> MACRO>
				<NOT <EMPTY? ,<2 .FM>>>
				<TYPE? <1 ,<2 .FM>> FUNCTION>>>
		<REMEMIT <2 .FM>>>>

<DEFINE FINDEM (FUNC "AUX" (FUNCL ()))
	#DECL ((FUNC) <SPECIAL ATOM> (FUNCL) <SPECIAL <LIST [REST ATOM]>>
	       (VALUE) <LIST [REST ATOM]>)
	<FINDREC ,.FUNC>
	.FUNCL>

<DEFINE FINDEMALL (ATM
		   "AUX" (TOPDO
			  <REPEAT ((TD ()))
				  #DECL ((TD) LIST
					 (VALUE)
					 <LIST <LIST [REST ATOM]> ATOM>)
				  <AND <EMPTY? .ATM> <RETURN .TD>>
				  <SET TD (<FINDEM <1 .ATM>> <1 .ATM> !.TD)>
				  <SET ATM <REST .ATM>>>))
	#DECL ((ATM) <<PRIMTYPE VECTOR> [REST ATOM]>
	       (TOPDO) <LIST <LIST [REST ATOM]> ATOM>)
	<REPEAT ((TODO .TOPDO) (CURDO <1 .TOPDO>))
		#DECL ((TODO) LIST
		       (CURDO) <LIST [REST ATOM]>)
		<COND (<EMPTY? .CURDO>
		       <COND (<EMPTY? <SET TODO <REST .TODO 2>>>
			      <RETURN .TOPDO>)
			     (ELSE <SET CURDO <1 .TODO>> <AGAIN>)>)
		      (<MEMQ <1 .CURDO> .TOPDO>)
		      (ELSE
		       <PUTREST <REST .TODO <- <LENGTH .TODO> 1>>
				(<FINDEM <1 .CURDO>> <1 .CURDO>)>)>
		<SET CURDO <REST .CURDO>>>>

<DEFINE GETORDER ("TUPLE" ATMS)
	#DECL ((ATMS) <TUPLE [REST ATOM]>)
	<COND (<NOT <MEMQ #FALSE () <MAPF ,LIST ,CHECK .ATMS>>>
	       <ORDEREM <FINDEMALL .ATMS>>)
	      (ELSE <ERROR BAD-ARG GETORDER>)>>



<SET LIST_OF_FUNCTIONS
     '(CHECK
       PREV
       SPLOUTEM
       REVERSE
       ORDEREM
       REMEMIT
       FINDREC
       FINDEM
       FINDEMALL
       GETORDER)>
<ENDPACKAGE>