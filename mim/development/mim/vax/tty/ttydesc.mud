"The following functions parse a terminal description file into
 the format used by the rest of the TTY package.  If GC-READ and
 friends ever exist, they will probably replace this.  PARSE-SPEC-FILE,
 the top-level, takes a channel (which it will close) to the description
 file, and returns a TTY-DESC.  Other information is needed to make the
 TTY object."

<DEFINE PARSE-SPEC-FILE (CH "AUX" BYTE NAME HEIGHT WIDTH PAD CRPAD LFPAD
			 OPCNT OPMAX TTY BUFSTR OPVEC LEN)
  #DECL ((CH) CHANNEL (BYTE) CHARACTER (NAME) STRING
	 (CRPAD LFPAD LEN HEIGHT WIDTH OPCNT OPMAX) FIX
	 (PAD) CHARACTER (TTY) TTY-DESC
	 (OPVEC) VECTOR (BUFSTR) STRING)
  <COND (<NOT <GASSIGNED? BUFSTR>>
	 <SETG BUFSTR <ISTRING 256>>)>
  <SET BUFSTR ,BUFSTR>
  <SET LEN <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET NAME <ISTRING .LEN>>
  <FCHANNEL-OP .CH READ-BUFFER .NAME>
  <SET HEIGHT <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET WIDTH <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET PAD <FCHANNEL-OP .CH READ-BYTE>>
  <SET CRPAD <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET LFPAD <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET OPMAX <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET OPCNT <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
  <SET OPVEC <IVECTOR .OPMAX <>>>
  <SET TTY <CHTYPE [.NAME .HEIGHT .WIDTH .PAD
		    .CRPAD .LFPAD .OPVEC] TTY-DESC>>
  <REPEAT ()
    <COND (<0? .OPCNT>
	   <CHANNEL-CLOSE .CH>
	   <RETURN .TTY>)>
    <SET LEN <CHTYPE <FCHANNEL-OP .CH READ-BYTE> FIX>>
    <COND (<G? .LEN 0>
	   <FCHANNEL-OP .CH READ-BUFFER .BUFSTR .LEN>
	   <PUT .OPVEC <CHTYPE <1 .BUFSTR> FIX>
		<PARSE-SPEC <REST .BUFSTR> <- .LEN 1>>>)>
    <SET OPCNT <- .OPCNT 1>>>>

"PARSE-SPEC parses the specification for a single terminal operation,
 and returns an appropriate structure."

<DEFINE PARSE-SPEC (SPECSTR LEN "AUX" NP VEC)
  #DECL ((SPECSTR) STRING (LEN) FIX)
  <SET NP <CHTYPE <1 .SPECSTR> FIX>>
  <SET SPECSTR <REST .SPECSTR>>
  <COND (<0? .NP> <>)
	(<1? .NP>
	 <GET-TTY-OP .SPECSTR>)
	(T
	 <SET VEC <IVECTOR .NP <>>>
	 <MAPR <>
	   <FUNCTION (VV)
	     #DECL ((VV) VECTOR)
	     <1 .VV <GET-TTY-OP .SPECSTR>>
	     <SET SPECSTR <REST .SPECSTR <+ <CHTYPE <2 .SPECSTR> FIX>
					    2>>>>
	   .VEC>
	 .VEC)>>

<DEFINE NEW-STRING (STR LEN "AUX" (NS <ISTRING .LEN>))
  #DECL ((STR NS) STRING (LEN) FIX)
  <MAPR <>
    <FUNCTION (X Y)
      <1 .X <1 .Y>>>
    .NS .STR>
  .NS>

<DEFINE GET-TTY-OP (STR "AUX" PAD ELTS NS)
  #DECL ((STR) STRING (PAD) FIX)
  <SET PAD <CHTYPE <1 .STR> FIX>>
  <SET ELTS <CHTYPE <3 .STR> FIX>>
  <COND (<AND <1? .ELTS>
	      <L? <CHTYPE <4 .STR> FIX> *200*>>
	 ; "JUST A STRING"
	 <SET NS <NEW-STRING <REST .STR 4> <CHTYPE <4 .STR> FIX>>>)
	(T
	 <SET NS <CHTYPE <IVECTOR .ELTS 0> TTY-ELT>>
	 <SET STR <REST .STR 3>>
	 ; "Rest off all but element descriptions"
	 <MAPR <>
	   <FUNCTION (NNS "AUX" NUM)
	     #DECL ((NNS) <PRIMTYPE VECTOR>)
	     <COND (<G=? <SET NUM <CHTYPE <1 .STR> FIX>> *200*>
		    <1 .NNS .NUM>
		    <SET STR <REST .STR>>)
		   (T
		    <1 .NNS <NEW-STRING <REST .STR> .NUM>>
		    <SET STR <REST .STR <+ .NUM 1>>>)>>
	   .NS>)>
  <COND (<0? .PAD> .NS)
	(<CHTYPE [.NS .PAD] TTY-OUT>)>>
