
<PACKAGE "BITSGEN">

<ENTRY BITLOG-GEN FGETBITS-GEN FPUTBITS-GEN>

<USE "COMPDEC" "CODGEN" "CHKDCL" "MIMGEN">

<DEFINE FGETBITS-GEN (N W "AUX" (K <KIDS .N>) REG S WI) 
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<SET REG <GEN <1 .K>>>
	<SET S <GEN <2 .K>>>
	<FREE-TEMP <SET WI <GEN <3 .K>>> <>>
	<FREE-TEMP .S <>>
	<IEMIT `GETBITS
	       .REG
	       .S
	       .WI
	       =
	       <COND (<N==? .W DONT-CARE>
		      <FREE-TEMP .REG <>>
		      <COND (<TYPE? .W TEMP> <USE-TEMP .W FIX>)>
		      .W)
		     (<AND <TYPE? .REG TEMP> <L=? <TEMP-REFS .REG> 1>>
		      <SET W .REG>)
		     (ELSE <FREE-TEMP .REG <>> <SET W <GEN-TEMP>>)>>
	.W>

<DEFINE FPUTBITS-GEN (N W
		      "AUX" (K <KIDS .N>) REG S WI F
			    (TY <ISTYPE? <RESULT-TYPE .N>>))
	#DECL ((N) NODE (K) <LIST [REST NODE]>)
	<SET REG <GEN <1 .K>>>
	<SET S <GEN <2 .K>>>
	<SET WI <GEN <3 .K>>>
	<FREE-TEMP <SET F <GEN <4 .K>>> <>>
	<FREE-TEMP .S <>>
	<FREE-TEMP .WI <>>
	<IEMIT `PUTBITS
	       .REG
	       .S
	       .WI
	       .F
	       =
	       <COND (<N==? .W DONT-CARE>
		      <FREE-TEMP .REG <>>
		      <COND (<TYPE? .W TEMP> <USE-TEMP .W .TY>)>
		      .W)
		     (<AND <TYPE? .REG TEMP> <L=? <TEMP-REFS .REG> 1>>
		      <SET W .REG>)
		     (ELSE
		      <FREE-TEMP .REG <>>
		      <SET W <GEN-TEMP <COND (.TY) (T)>>>)>>
	.W>

<DEFINE BITLOG-GEN (N W
		    "AUX" (K <KIDS .N>) (FST <1 .K>)
			  (INS <LGINS <NODE-SUBR .N>>) REG)
	#DECL ((FST N) NODE (K) <LIST [REST NODE]>)
	<COND (<==? <NODE-TYPE .FST> ,QUOTE-CODE>
	       <PUT .K 1 <2 .K>>
	       <PUT .K 2 .FST>)>
	<SET REG <GEN <1 .K>>>
	<MAPR <>
	      <FUNCTION (NP "AUX" (NN <1 .NP>) (NXT <GEN .NN DONT-CARE>) TT
				  (LAST <EMPTY? <REST .NP>>)) 
		      #DECL ((NN) NODE (NP) <LIST NODE>)
		      <IEMIT .INS
			     .REG
			     .NXT
			     =
			     <COND (<AND .LAST <OR <TYPE? .W TEMP>
						   <==? .W ,POP-STACK>>>
				    <COND (<N==? .W .REG>
					   <FREE-TEMP .REG <>>
					   <COND (<TYPE? .W TEMP>
						  <USE-TEMP .W FIX>)>)>
				    <SET REG .W>)
				   (<AND .LAST
					 <==? .W DONT-CARE>
					 <TYPE? .REG TEMP>
					 <L=? <TEMP-REFS .REG> 1>> .REG)
				   (<OR <NOT <TYPE? .REG TEMP>>
					<G? <TEMP-REFS .REG> 1>>
				    <COND (<TYPE? .REG TEMP>
					   <FREE-TEMP .REG <>>)>
				    <SET REG <GEN-TEMP FIX>>)
				   (ELSE .REG)>>
		      <FREE-TEMP .NXT>>
	      <REST .K>>
	<MOVE-ARG .REG .W>>

<DEFINE LGINS (SUBR) 
	<NTH '[`AND `OR `XOR `EQV]
	     <LENGTH <MEMQ .SUBR ,LSUBRS>>>>

<SETG LSUBRS [,EQVB ,XORB ,ORB ,ANDB]>

<GDECL (LSUBRS) VECTOR>

<ENDPACKAGE>
