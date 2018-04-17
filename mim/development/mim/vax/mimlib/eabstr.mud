;"Implements executable abstr save file with jcl. See abstr.doc."

<USE "JCL" "ABSTR" "PURIFY">

<DEFINE EABSTR ()
   <REMOVE EABSTR>
   <PURIFY-WORLD>
   <SNAME "">
   <PROG (JCL:<OR <VECTOR [REST STRING]> FALSE>)
      <COND (<AND <=? <SAVE "ABSTR"> "RESTORED">
		  <JCLARGS?>
		  <SET JCL <PROCESS-JCL <READARGS>>>>
	     <MAPF <>
		   <FUNCTION (NAME:STRING "AUX" RESULT (OUTCHAN:CHANNEL .OUTCHAN))
		      <COND (<NOT <SET RESULT <ABSTRACT-PACKAGE .NAME>>>
			     <MAPF %<>
				   <FUNCTION (REASON)
				      <CRLF> <PRINC .REASON>>
				   .RESULT>
			     <CRLF>)>>
		   .JCL>
	     <EXIT 0>)>
      <PRINC "Usage: abstr [-a -i -n -s -d directory] files ...">
      <CRLF>
      <EXIT 1>>>

<DEFINE PROCESS-JCL (J:<OR <VECTOR [REST STRING]> FALSE>)
   <COND (<AND .J <NOT <EMPTY? .J>>>
	  <REPEAT (ITEM:STRING)
	     <SET ITEM <1 .J>>
	     <COND (<AND <NOT <EMPTY? .J>> <==? <1 .ITEM> !\->>
		    <COND (<==? <2 .ITEM> !\I>
			   <SETG ABSTRACT-IGNORE? T>)
			  (<==? <2 .ITEM> !\S>
			   <SETG ABSTRACT-NOISY? %<>>)
			  (<==? <2 .ITEM> !\N>
			   <SETG ABSTRACT-CAREFUL? %<>>)
			  (<==? <2 .ITEM> !\A>
			   <SETG L-USE-ABSTRACTS? T>
			   <SETG L-SECOND-NAMES ["ABSTR" !,L-SECOND-NAMES]>)
			  (<AND <==? <2 .ITEM> !\D>
				<NOT <EMPTY? <SET J <REST .J>>>>>
			   <BIND (FN:<CHANNEL 'PARSE>)
			      <SET FN <CHANNEL-OPEN PARSE
						    <STRING <1 .J> "/FOO.BAR">>>
			      <SNAME <CHANNEL-OP .FN SNM>>
			      <SETG L-SEARCH-PATH
				    ([<SET DEV <CHANNEL-OP .FN DEV>>
				      <SET SNM <CHANNEL-OP .FN SNM>>]
				     !,L-SEARCH-PATH)>>)
			  (T
			   <RETURN %<>>)>)
		   (<NOT <EMPTY? .J>>
		    <RETURN .J>)
		   (T
		    <RETURN %<>>)>
	     <SET J <REST .J>>>)>>






