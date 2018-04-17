<PACKAGE "NSTR">

"This package contains the useful stuff in the old STR package, rewritten
in Muddle instead of assembly code."

<ENTRY SUBSTR SUBSNC UPPERCASE SIXTOS STRTOX LOWERCASE>

"STRTOX -- String to Sixbit, takes a string and returns a single-word sixbit
representation of it"

<DEFINE STRTOX (STR "AUX" (W 0) (CNT 0) C) 
	#DECL ((STR) STRING (W) <PRIMTYPE WORD> (CNT C) FIX)
	<REPEAT ()
		<COND (<EMPTY? .STR> <SET C 0>)
		      (<G? <SET C <C2I <1 .STR>>> 31>
		       <REPEAT ()
			       <SET C <- .C 32>>
			       <COND (<L? .C 64> <RETURN>)>>)
		      (ELSE <SET C 0>)>
		<SET W <ORB <LSH .W 6> .C>>
		<COND (<==? <SET CNT <+ .CNT 1>> 6> <RETURN .W>)>
		<OR <EMPTY? .STR> <SET STR <REST .STR>>>>>

"SIXTOS -- Sixbit to String, takes a sixbit word and returns the string
corresponding to it.  Note that trailing sixbit spaces are not put in the
string returned."

<DEFINE SIXTOS (W "OPTIONAL" (Q <>)) 
	#DECL ((W) <PRIMTYPE WORD> (Q) <OR CHARACTER FALSE>)
	<MAPF ,STRING
	      <FUNCTION ("AUX" C) 
		      #DECL ((C) <PRIMTYPE FIX>)
		      <AND <0? <CHTYPE .W FIX>> <MAPSTOP>>
		      <SET W <ROT .W 6>>
		      <SET C <I2C <+ <ANDB .W 63> 32>>>
		      <SET W <ANDB .W -64>>
		      <COND (<AND .Q <MEMQ .C " :;">>
			     <MAPRET .Q .C>)
			    (.C)>>>>

"CHARACTER <-> FIX : Faster than ASCII."

<DEFMAC I2C ('I) <FORM CHTYPE .I CHARACTER>>

<DEFMAC C2I ('C) <FORM CHTYPE .C FIX>>

"SUBSTR -- Substring search, takes arguments such as MEMQ and optionally a maximum
length to search and a flag indicating whether case is to be considered
significant"

<DEFINE SUBSTR (S1 S2 "OPTIONAL" (N <LENGTH .S2>) (CASE? T)
		"AUX" (S .S1) (WIN <>) (CNT 0) C)
	#DECL ((S S1 S2) STRING (WIN) <OR STRING FALSE> (N CNT) FIX (C) CHARACTER)
	<MAPR <>
	      <FUNCTION (S2)
		  #DECL ((S2) STRING)
		  <COND (<G? <SET CNT <+ .CNT 1>> .N> <MAPLEAVE <>>)
			(<OR <==? <1 .S> <SET C <1 .S2>>>
			     <AND <NOT .CASE?>
				  <==? <COND (<AND <G=? <C2I .C> <C2I !\a>>
						   <L=? <C2I .C> <C2I !\z>>>
					      <I2C <- <C2I .C> 32>>)
					     (ELSE .C)>
				       <COND (<AND <G=? <C2I <1 .S>> <C2I !\a>>
						   <L=? <C2I <1 .S>> <C2I !\z>>>
					      <I2C <- <C2I <1 .S>> 32>>)
					     (ELSE <1 .S>)>>>>
			 <OR .WIN <SET WIN .S2>>
			 <COND (<EMPTY? <SET S <REST .S>>>
				<MAPLEAVE .WIN>)>)
			(ELSE
			 <SET S .S1>
			 <SET WIN <>>)>>
	      .S2>>

"SUBSNC -- Substring No Case, encapsulates SUBSTR with a fourth arg of <>"

<DEFINE SUBSNC (S1 S2 "OPTIONAL" (N <LENGTH .S2>))
	#DECL ((S1 S2) STRING (N) FIX)
	<SUBSTR .S1 .S2 .N <>>>

"UPPERCASE -- Uppercases a string, clobbers the old string."

<DEFINE UPPERCASE (S "OPTIONAL" (CNT <LENGTH .S>))
	#DECL ((S) STRING (CNT) FIX)
	<REPEAT ((S .S))
		#DECL ((S) STRING)
		<COND (<L? <SET CNT <- .CNT 1>> 0> <RETURN>)
		      (<AND <G=? <C2I <1 .S>> <C2I !\a>>
			    <L=? <C2I <1 .S>> <C2I !\z>>>
		       <PUT .S 1 <I2C <- <C2I <1 .S>> 32>>>)>
		<SET S <REST .S>>>
	.S>

"LOWERCASE -- Lowercases a string, clobbers the old string."

<DEFINE LOWERCASE (S "OPTIONAL" (CNT <LENGTH .S>))
	#DECL ((S) STRING (CNT) FIX)
	<REPEAT ((S .S))
		#DECL ((S) STRING)
		<COND (<L? <SET CNT <- .CNT 1>> 0> <RETURN>)
		      (<AND <G=? <C2I <1 .S>> <C2I !\A>>
			    <L=? <C2I <1 .S>> <C2I !\Z>>>
		       <PUT .S 1 <I2C <+ <C2I <1 .S>> 32>>>)>
		<SET S <REST .S>>>
	.S>

<ENDPACKAGE>
