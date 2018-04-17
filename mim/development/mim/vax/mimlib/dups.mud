<PACKAGE "DUPS">

<ENTRY DUPS OBLISTS PACKAGES REFS DUP-LIST PACK-LIST OB-LIST REF-LIST
       REFS>

<GDECL (DUP-LIST) <LIST [REST STRING LIST]>
       (PACK-LIST OB-LIST) LIST>

<DEFINE PACKAGES ("AUX" (ATBL ,ATOM-TABLE)) 
	#DECL ((ATBL) <VECTOR [REST LIST]>)
	<SETG PACK-LIST ()>
	<MAPF <>
	      <FUNCTION (L) 
		   #DECL ((L) LIST)
		   <MAPF <>
			 <FUNCTION (A "AUX" O)
			      #DECL ((A) ATOM (O) <OR OBLIST FALSE>)
			      <COND (<AND <SET O <OBLIST? .A>>
					  <==? <CHTYPE .O ATOM> PACKAGE>
					  <NOT <MEMQ .A ,PACK-LIST>>>
				     <SETG PACK-LIST (.A !,PACK-LIST)>)>>
			 .L>>
	      .ATBL>
	,PACK-LIST>

<DEFINE OBLISTS ("AUX" (ATBL ,ATOM-TABLE)) 
	#DECL ((ATBL) <VECTOR [REST LIST]>)
	<SETG OB-LIST ()>
	<MAPF <>
	      <FUNCTION (L) 
		   #DECL ((L) LIST)
		   <MAPF <>
			 <FUNCTION (A "AUX" O)
			      #DECL ((A) ATOM (O) <OR OBLIST FALSE>)
			      <COND (<AND <SET O <OBLIST? .A>>
					  <NOT <MEMQ .O ,OB-LIST>>>
				     <SETG OB-LIST (.O !,OB-LIST)>)>>
			 .L>>
	      .ATBL>
	,OB-LIST>

<DEFINE DUPS ("AUX" (PACKS <PACKAGES>) (ATBL ,ATOM-TABLE) L) 
	#DECL ((PACKS) <LIST [REST ATOM]> (ATBL) <VECTOR [REST LIST]>
	       (L) LIST)
	<SETG DUP-LIST ()>
	<MAPF <>
	      <FUNCTION (LL) 
		   #DECL ((LL) LIST)
		   <MAPR <>
			 <FUNCTION (LL "AUX" (A <1 .LL>))
			      #DECL ((A) ATOM)
			      <COND (<AND <SAME-PNAME? .A <REST .LL>>
					  <NOT
					    <LENGTH? <SET L
							  <DLOOK .A .PACKS>>
						     1>>
					  <NOT <MEMBER <SPNAME .A> ,DUP-LIST>>>
				     <PRINC .A>
				     <INDENT-TO 20>
				     <PRINC .L>
				     <CRLF>
				     <SETG DUP-LIST
					   (<SPNAME .A> .L !,DUP-LIST)>)>>
			 .LL>>
	      .ATBL>
	T>	      

<DEFINE SAME-PNAME? (A L)
	#DECL ((A) ATOM (L) LIST)
	<MAPF <>
	      <FUNCTION (B)
		   #DECL ((B) ATOM)
		   <COND (<=? <SPNAME .A> <SPNAME .B>> <MAPLEAVE T>)>>
	      .L>>

<DEFINE DLOOK (A PACKS "AUX" (ENT? <>) L)
	#DECL ((A) ATOM (PACKS) <LIST [REST ATOM]> (L) LIST)
	<SET L
	     <MAPF ,LIST
		   <FUNCTION (P "AUX" PL O)
			#DECL ((P) ATOM (PL) <LIST [REST OBLIST]> (O) OBLIST)
			<COND (<NOT <GASSIGNED? .P>> <MAPRET>)>
			<SET PL ,.P>
			<COND (<AND <N==? <ROOT> <SET O <2 .PL>>>
				    <LOOKUP <SPNAME .A> .O>>
			       <SET ENT? T>
			       <MAPRET <CHTYPE .O ATOM>>)
			      (<AND <N==? <ROOT> <SET O <1 .PL>>>
				    <LOOKUP <SPNAME .A> .O>>
			       <SET ENT? T>
			       <MAPRET <CHTYPE .O ATOM>>)
			      (ELSE <MAPRET>)>>
		   .PACKS>>
	<COND (.ENT? .L)>>

<DEFINE REFS (L "OPTIONAL" (REFL (T)) "AUX" OB A)
	#DECL ((L) STRUCTURED (REFL) LIST (OB) <OR FALSE OBLIST>)
	<MAPF <>
	      <FUNCTION (O)
		   <COND (<TYPE? .O ATOM LVAL GVAL>
			  <COND (<SET OB <OBLIST? <SET A <CHTYPE .O ATOM>>>>
				 <COND (<NOT <MEMQ .OB .REFL>>
					<PUTREST .REFL (.OB !<REST .REFL>)>)>)>)
			 (<TYPE? .O LIST FORM VECTOR SEGMENT>
			  <REFS .O .REFL>)>>
	      .L>
	<REST .REFL>>

<ENDPACKAGE>
