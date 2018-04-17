; "For now, I$DEF-CHANNEL is just a PUT FOO DECL hack."
%<NEWSTRUC I$DEF-CHANNEL (VECTOR)
  DC-IJFN FIX
  DC-DEV <OR ATOM STRING FALSE>
  DC-SNM <OR ATOM STRING FALSE>
  DC-NM1 <OR STRING FALSE>
  DC-NM2 <OR STRING FALSE>
  DC-DSN <OR STRING FALSE>
  DC-STATUS FIX
  DC-OJFN FIX
  DC-IBUF <OR STRING FALSE>
  DC-IBC FIX>

<DEFINE X$DEF-GET-MODE (CHANNEL OPER "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)
			(STS <DC-STATUS .DATA>))
  #DECL ((CHANNEL) T$CHANNEL (DATA) I$DEF-CHANNEL)
  <COND (<NOT <0? <ANDB .STS ,STATUS-WRITE>>>
	 <COND (<0? <ANDB .STS ,STATUS-RACC>>
		"APPEND")
	       (T
		"MODIFY")>)
	(T
	  "READ")>>

<DEFINE X$DEF-GET-BYTE-SIZE (CHANNEL OPER "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)
			 (BSZ <LHW <DC-STATUS .DATA>>))
  #DECL ((CHANNEL) T$CHANNEL (DATA) I$DEF-CHANNEL)
  <COND (<==? .BSZ ,BS-ASCII> "ASCII")
	(<==? .BSZ ,BS-8BIT> "8BIT")
	(<==? .BSZ ,BS-BINARY> "BINARY")>>

<DEFINE X$DEF-HACK-DATE (CHANNEL OPER "OPTIONAL" NEW
			  "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)
				UV ST NM)
  #DECL ((CHANNEL) T$CHANNEL (DATA) I$DEF-CHANNEL (OPER) T$ATOM
	 (NEW) FIX (UV) <UVECTOR [REST FIX]>)
  <COND (<NOT <ASSIGNED? NEW>>
	 <COND (<==? <DC-IJFN .DATA> -1>
		<SET NM <T$STANDARD-NAME <T$CHANNEL-OP .CHANNEL T$NAME>>>
		<SET ST <T$FILE-STAT .NM>>)
	       (T
		<SET ST <T$FILE-STAT <DC-IJFN .DATA>>>)>
	 <COND (<==? .OPER T$READ-DATE>
		<T$STAT-FIELD .ST ,ATIME-OFFS ,ATIME-SIZE>)
	       (T
		<T$STAT-FIELD .ST ,MTIME-OFFS ,MTIME-SIZE>)>)
	(T
	 <COND (<NOT <GASSIGNED? TIMEU>> <SETG TIMEU <UVECTOR 0 0>>)>
	 <SET UV ,TIMEU>
	 <COND (<==? .OPER T$READ-DATE>
		<1 .UV .NEW>
		<2 .UV <X$DEF-HACK-DATE .CHANNEL T$WRITE-DATE>>)
	       (T
		<2 .UV .NEW>
		<1 .UV <X$DEF-HACK-DATE .CHANNEL T$READ-DATE>>)>
	 <SET NM <T$STANDARD-NAME <T$CHANNEL-OP .CHANNEL T$NAME>>>
	 <COND (<CALL SYSCALL UTIMES .NM .UV>
		.NEW)>)>>

<DEFINE I$DEF-SHORT-NAME (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>)
			  (NM1 <DC-NM1 .DAT>) (NM2 <DC-NM2 .DAT>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL)
  <COND (<AND .NM1 .NM2>
	 <STRING .NM1 !\. .NM2>)
	(.NM1)
	(.NM2
	 <STRING !\. .NM2>)
	(<I$DEF-NAME .CHN .OPER>)>>

<DEFINE I$DEF-FILE-HANDLE (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL)
  <DC-IJFN .DAT>>

<DEFINE I$DEF-DEV (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>)
		   (STR <DC-DEV .DAT>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL)
  <COND (<TYPE? .STR ATOM>
	 <T$PARSE-DIR <> <> <REST .DAT 1> <> <>>
	 <DC-DEV .DAT>)
	(.STR)>>

<DEFINE I$DEF-SNM (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>)
		   (STR <DC-SNM .DAT>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL)
  <COND (<TYPE? .STR ATOM>
	 <T$PARSE-DIR <> <> <REST .DAT 1> <> <>>
	 <DC-SNM .DAT>)
	(.STR)>>

<DEFINE I$DEF-NM1 (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL)
  <DC-NM1 .DAT>>

<DEFINE I$DEF-NM2 (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL)
  <DC-NM2 .DAT>>

<DEFINE I$DEF-NAME (CHN OPER "OPT" (BITS *37*) "AUX" (DAT <T$CHANNEL-DATA .CHN>)
		    (STOR <ITUPLE 5 <>>))
  #DECL ((CHN) T$CHANNEL (DAT) I$DEF-CHANNEL (STOR) TUPLE)
  <1 .STOR <DC-DEV .DAT>>
  <2 .STOR <DC-SNM .DAT>>
  <3 .STOR <DC-NM1 .DAT>>
  <4 .STOR <DC-NM2 .DAT>>
  <5 .STOR <DC-DSN .DAT>>
  <I$UNPARSE-SPEC .STOR .BITS>>
