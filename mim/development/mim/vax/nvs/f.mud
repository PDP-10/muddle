<USE "VS100">
<INCLUDE "VSUDEFS" "VSUTYPES">

<DEFINE F ("OPT" (CHN .CH) "AUX" EV)
   <REPEAT ()
      <COND (<AND <TYPE? <SET EV <CHANNEL-OP .CHN READ-BYTE-IMMEDIATE>>
			 MOUSE-EVENT>
		  <==? <ME-KIND .EV> ,ME-LEFT-PRESSED>>
	     <RETURN <CHANNEL-OP .CHN MOUSE-RESIZE-WINDOW ,MOUSE-LEFT>>)>>>