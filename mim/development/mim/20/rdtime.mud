<DEFINE T1 (NM "AUX" CH (TM <TIME>))
  <COND (<SET CH <OPEN "READ" .NM>>
	 <REPEAT ()
	   <READ .CH '<RETURN>>>
	 <COND (<==? <TYPEPRIM FIX> FIX><CLOSE .CH>)>
	 <- <TIME> .TM>)>>

<DEFINE T2 (NM "AUX" (TM <TIME>))
  <FLOAD .NM>
  <- <TIME> .TM>>