<PACKAGE "VSBASE">

<ENTRY SEND-PACKET RECEIVE-PACKET VSB-SEND VSB-DUMP VSB-WAIT
       VSB-DEBUG? VSB-PLIST>

<ENTRY PROCESS-EVENT NORMAL-KEYS FUNCTION-KEYS GET-EVENT FREE-MOUSE-EVENTS
       FREE-WINDOW-EVENTS ANY-INPUT? MOUSE-GRABBED? REDISPLAY-ICON
       FREE-RECTANGLES CURRENT-ROOT-ID>

<USE "NETBASE">

<INCLUDE "VSTYPES" "VSUTYPES">
<INCLUDE-WHEN <COMPILING? "VSBASE"> "VSDEFS" "VSUDEFS" "VSOPS">

<SETG VSB-DEBUG? <>>
<GDECL (VSB-DEBUG?) <OR ATOM !<FALSE>>
       (VSB-PLIST REST-PLIST) LIST>

<SETG SEND-PACKET <IUVECTOR 6>>
<SETG RECEIVE-PACKET <IUVECTOR 6>>
<GDECL (RECEIVE-PACKET SEND-PACKET) <UVECTOR [6 FIX]>>

<DEFINE VSB-SEND (VS:VS FORCE?:<OR ATOM FALSE> REPLY?:<OR ATOM FIX FALSE>
		  "TUPLE" STUFF
		  "AUX" (CHN:<CHANNEL 'NETWORK> <VS-CHANNEL .VS>) 
		  (RES:<OR FIX FALSE> 0) NVAL)
   <VS-REQ .VS <+ <VS-REQ .VS> 1>>
   <COND (,VSB-DEBUG?
	  <COND (<NOT <GASSIGNED? VSB-PLIST>>
		 <SETG VSB-PLIST (0)>
		 <SETG REST-PLIST ,VSB-PLIST>)>
	  <SETG REST-PLIST <REST <PUTREST ,REST-PLIST
					  (<VS-REQ .VS>
					   <SUBSTRUC <1 .STUFF>:UVECTOR>)>
				 2>>)>
   <SET NVAL
    <COND (<OR <NOT <VS-BUFFER .VS>>
	      <AND .FORCE? <0? <VS-BCT .VS>>>>
	  <COND (<REPEAT ((ST .STUFF) LEN OBJ)
		    <COND (<EMPTY? .ST> <RETURN T>)>
		    <COND
		     (<1? <LENGTH .ST>>
		      <COND (<NOT <SET LEN <CHANNEL-OP .CHN WRITE-BUFFER
						       <SET OBJ <1 .ST>>>>>
			     <RETURN <>>)>)
		     (T
		      <COND (<NOT <SET LEN <CHANNEL-OP .CHN WRITE-BUFFER
						       <SET OBJ <1 .ST>>
						       <2 .ST>>>>
			     <RETURN <>>)>
		      <SET ST <REST .ST 2>>)>
		    <COND (<AND <TYPE? .OBJ STRING BYTES>
				<NOT <0? <MOD .LEN:FIX 4>>>>
			   <CHANNEL-OP .CHN WRITE-BUFFER
				       "   "
				       <- 4 <MOD .LEN:FIX 4>>>)>>
		 <COND (.REPLY? <VSB-WAIT .VS .REPLY?>)>)>)
	 (T
	  <REPEAT (OBJ:<OR <PRIMTYPE STRING> <PRIMTYPE UVECTOR>> 
		   LEN:<OR FIX FALSE> NRES)
	     <COND (<EMPTY? .STUFF>
		    <COND (.FORCE?
			   <COND (<VSB-DUMP .VS>
				  <COND (.REPLY?
					 <RETURN <VSB-WAIT .VS .REPLY?>>)>
				  <RETURN .RES>)
				 (T <RETURN .NRES>)>)>
		    <RETURN .RES>)>
	     <SET OBJ <1 .STUFF>>
	     <COND (<==? <LENGTH .STUFF> 1>
		    <SET LEN <>>
		    <SET STUFF <REST .STUFF>>)
		   (T
		    <SET LEN <2 .STUFF>>
		    <SET STUFF <REST .STUFF 2>>)>
	     <COND (<SET NRES <STUFF .OBJ .LEN .VS>>
		    <SET RES <+ .RES .NRES>>)
		   (T
		    <RETURN .NRES>)>>)>>
   <COND (<AND <NOT .REPLY?> ,VSB-DEBUG?>
	  <VSOP .VS X-QUERY-WINDOW
		<COND (<ASSIGNED? CURRENT-ROOT-ID>
		       .CURRENT-ROOT-ID)
		      (T
		       <VW-ID <CHANNEL-DATA <VS-TOPCHAN .VS>>>)>>)>
   .NVAL>

<DEFINE STUFF ST (OBJ:<OR <PRIMTYPE STRING> <PRIMTYPE UVECTOR>>
	       LEN:<OR FIX FALSE> VS:VS "OPT" (ALLOW-ODD?  <>)
	       "AUX" (BUF:STRING <VS-BUFFER .VS>)
	       (CT <VS-BCT .VS>) NOBJ:STRING RES NRES
	       (CH:<CHANNEL 'NETWORK> <VS-CHANNEL .VS>))
   <COND (<==? <ANDB <CALL TYPE .OBJ> *7*> 6>
	  <COND (.LEN 
		 <SET RES .LEN>
		 <SET LEN <* 4 .LEN>>)
		(T
		 <SET RES <LENGTH .OBJ:<PRIMTYPE UVECTOR>>>
		 <SET LEN <* 4 .RES>>)>
	  <SET NOBJ <CALL OBJECT <TYPE-C STRING> 
			  <* 4 <LENGTH .OBJ:<PRIMTYPE UVECTOR>>>
			  <CALL VALUE .OBJ>>>)
	 (T
	  <COND (.LEN
		 <SET RES .LEN>)
		(T
		 <SET RES <SET LEN <LENGTH .OBJ:<PRIMTYPE STRING>>>>)>
	  <SET NOBJ <CHTYPE .OBJ:<PRIMTYPE STRING> STRING>>)>
   <COND (<AND <G? .LEN <LENGTH .BUF>> <NOT <0? .CT>>>
	  <COND (<NOT <SET NRES <VSB-DUMP .VS>>>
		 <RETURN .NRES .ST>)>
	  <SET BUF <VS-BUFFER .VS>>
	  <SET CT 0>)>
   <COND (<G? .LEN <LENGTH .BUF>>
	  <COND (<CHANNEL-OP .CH WRITE-BUFFER .NOBJ .LEN>
		 <COND (<AND <NOT .ALLOW-ODD?> <NOT <0? <MOD .LEN 4>>>>
			<STUFF "   " <- 4 <MOD .LEN 4>> .VS T>)>
		 .RES)>)
	 (T
	  <SUBSTRUC .NOBJ 0 .LEN .BUF>
	  <VS-BUFFER .VS <REST .BUF .LEN>>
	  <VS-BCT .VS <+ .CT .LEN>>
	  <COND (<AND <NOT .ALLOW-ODD?> <NOT <0? <MOD .LEN 4>>>>
		 <STUFF "   " <- 4 <MOD .LEN 4>> .VS T>)>
	  .RES)>>

<DEFINE VSB-DUMP (VS:VS "AUX" (CHN:<CHANNEL 'NETWORK> <VS-CHANNEL .VS>)
		  (BUF:STRING <VS-BUFFER .VS>) (CT:FIX <VS-BCT .VS>))
   <COND (<G? .CT 0>
	  <COND (<CHANNEL-OP .CHN WRITE-BUFFER <SET BUF <VS-BUFFER-TOP .VS>>
			     .CT>
		 <VS-BUFFER .VS .BUF>
		 <VS-BCT .VS 0>)>)
	 (T)>>

<DEFINE VSB-WAIT (VS:VS "OPT" (RACT <>) (NOT-REALLY?:<OR ATOM FALSE> <>)
		  "AUX" (CH:<CHANNEL 'NETWORK> <VS-CHANNEL .VS>) (ANY? <>)
		  (P:UVECTOR ,RECEIVE-PACKET) (REQ <VS-REQ .VS>) CODE)
   <PROG (RES)
      <COND (.NOT-REALLY?
	     <SET RES <AND <CHANNEL-OP .CH INPUT-WAITING>
			   <CHANNEL-OP .CH READ-BUFFER .P>>>)
	    (T
	     <SET RES <CHANNEL-OP .CH READ-BUFFER .P>>)>
      <COND
       (.RES
	<COND (<==? <SET CODE <VSI-CODE .P>> ,X-ERROR>
	       ; "Error packet"
	       <COND (<OR <NOT .RACT>
			  <N==? <I-LPAR0 .P> .REQ>>
		      ; "Out-of-band error"
		      <VSB-REPORT-ERROR .VS .P>
		      ; "Report, then try again"
		      <AGAIN>)
		     (T
		      ; "Error in response to request, so return it"
		      <CHTYPE (<VSERR-ERRCODE .P> <VSERR-REQCODE .P>
			       <NTH ,VS-ERRORS <VSERR-ERRCODE .P>>) FALSE>)>)
	      (<==? .CODE ,X-REPLY>
	       <COND (<NOT .RACT>
		      <AGAIN>)
		     (<==? .RACT ERROR>)
		     (<==? .RACT T> .P)
		     (<==? .RACT STRING>
		      <PROG ((LEN <I-SPAR0 .P>) ST:STRING)
			 <COND (<NOT <GASSIGNED? RANDOM-STRING>>
				<SET ST <SETG RANDOM-STRING <ISTRING .LEN>>>)
			       (<L? <LENGTH <SET ST ,RANDOM-STRING>> .LEN>
				<SET ST <SETG RANDOM-STRING <ISTRING .LEN>>>)
			       (<G? <LENGTH .ST> .LEN>
				<SET ST <REST .ST <- <LENGTH .ST> .LEN>>>)>
			 <CHANNEL-OP .CH READ-BUFFER .ST>
			 <COND (<NOT <0? <MOD .LEN 4>>>
				<CHANNEL-OP .CH READ-BUFFER ,GSTRING
					    <- 4 <MOD .LEN 4>>>)>
			 .ST>)
		     (<==? .RACT 1> <I-LPAR0 .P>)
		     (T <I-SPAR0 .P>)>)
	      (.RACT
	       <PROCESS-EVENT .VS .P>
	       <AGAIN>)
	      (T
	       <COND (<NOT <PROCESS-EVENT .VS .P>> <AGAIN>)
		     (T
		      <SET ANY? T>
		      ; "This hack enables optimization of mouse-moved events"
		      <COND (.NOT-REALLY? <AGAIN>)>)>)>)
       (<=? .RES #FALSE(4)>
	<AGAIN>)
       (.NOT-REALLY?
	.ANY?)
       (T
	<ERROR VS100-CONNECTION-DIED!-ERRORS .CH VSB-WAIT>
	<AGAIN>)>>>

<SETG GSTRING <ISTRING 3>>

<DEFINE VSB-REPORT-ERROR (VS:VS PACKET:UVECTOR)
   <COND (<TYPE? <INTERRUPT "VS-ERROR" .VS <VSERR-ERRCODE .PACKET>
			    <VSERR-REQCODE .PACKET>
			    <VSERR-REQNUM .PACKET>
			    <VSERR-REQFUNC .PACKET>
			    <OR <GET-WINDOW .VS <VSERR-WINDOW .PACKET>>
				<VSERR-WINDOW .PACKET>>>
		 DISMISS>)
	 (T
	  <ERROR RANDOM-ERROR-FROM-X!-ERRORS
		 <NTH ,VS-ERRORS <VSERR-ERRCODE .PACKET>>
		 <VSERR-REQCODE .PACKET>
		 <VSERR-REQNUM .PACKET>
		 <VSERR-REQFUNC .PACKET>
		 <OR <GET-WINDOW .VS <VSERR-WINDOW .PACKET>>
		     <VSERR-WINDOW .PACKET>>>)>>

<GDECL (FREE-MOUSE-EVENTS) <LIST [REST MOUSE-EVENT]>
       (FREE-WINDOW-EVENTS) <LIST [REST WINDOW-EVENT]>
       (FREE-RECTANGLES) <LIST [REST WE-RECTANGLE]>>
<COND (<NOT <GASSIGNED? FREE-MOUSE-EVENTS>>
       <SETG FREE-MOUSE-EVENTS ()>
       <SETG FREE-WINDOW-EVENTS ()>
       <SETG FREE-CELLS ()>
       <SETG FREE-RECTANGLES ()>)>

<DEFINE PROCESS-EVENT PE (VS:VS P:UVECTOR "AUX" WID:FIX (SW:ANY <>)
		       W:<OR VSCHAN FALSE> ML KIND:FIX (OUT <>) TL:<OR LIST FALSE>
		       ME:MOUSE-EVENT WE:WINDOW-EVENT MB:FIX VW:VSW NME
		       OWE:<OR WINDOW-EVENT FALSE>)
   <COND (<==? <SET KIND <VSI-CODE .P>> ,KEY-RELEASED>
	  <RETURN <> .PE>)>
   <COND (<NOT <0? <SET WID <VSI-SUBWINDOW .P>>>>
	  <COND (<NOT <SET W <GET-WINDOW .VS .WID>>>
		 <SET SW .WID>
		 <SET WID <VSI-WINDOW .P>>
		 <SET W <GET-WINDOW .VS .WID>>)>)
	 (T
	  <SET W <GET-WINDOW .VS <VSI-WINDOW .P>>>)>
   <COND
    (<AND .W
	  <CHANNEL-OPEN? .W>
	  <OR <N==? .W <VS-TOPCHAN .VS>>
	      <AND <ASSIGNED? MOUSE-GRABBED?>
		   .MOUSE-GRABBED?>>>
     <COND
      (<AND .SW <NOT <EMPTY? <SET ML <VW-MENU-WINDS <CHANNEL-DATA .W>:VSW>>>>>
       <REPEAT ()
	  <COND (<==? <MW-ID <1 .ML>> .SW>
		 <SET SW <1 .ML>>
		 <RETURN>)>
	  <COND (<EMPTY? <SET ML <REST .ML>>> <RETURN>)>>)>
     <COND
      (<==? .KIND ,KEY-PRESSED>
       <COND
	(<SET OUT <TRANSLATE-KEY .VS
				 <ANDB <VSI-DETAIL .P>
				       %<XORB <ORB ,X-LEFT-MASK
						   ,X-MIDDLE-MASK
						   ,X-RIGHT-MASK>
					      -1>>>>
	 <COND (<EMPTY? <SET TL ,FREE-CELLS>>
		<SET OUT (.OUT)>)
	       (T
		<SETG FREE-CELLS <REST .TL>>
		<1 .TL .OUT>
		<SET OUT .TL>
		<PUTREST .TL ()>)>)
	(<RETURN <> .PE>)>)
      (<OR <==? .KIND ,BUTTON-PRESSED>
	   <==? .KIND ,BUTTON-RELEASED>>
       <SET ME <NULL-MOUSE-EVENT>>
       <SET MB <ANDB <VSI-DETAIL .P> *377*>>
       <ME-KIND .ME <COND (<==? .KIND ,BUTTON-PRESSED>
			   <COND (<0? .MB> ,ME-RIGHT-PRESSED)
				 (<1? .MB> ,ME-MIDDLE-PRESSED)
				 (T ,ME-LEFT-PRESSED)>)
			  (<0? .MB>
			   ,ME-RIGHT-RELEASED)
			  (<1? .MB>
			   ,ME-MIDDLE-RELEASED)
			  (T ,ME-LEFT-RELEASED)>>
       <ME-STATE .ME <LSH <VSI-DETAIL .P> -8>>
       <ME-X .ME <VSI-X .P>>
       <ME-Y .ME <VSI-Y .P>>
       <ME-TIME .ME <VSI-TIME .P>>
       <ME-WINDOW .ME .W>
       <ME-SUBWINDOW .ME .SW>
       <ME-LOCATOR .ME <I-LPAR4 .P>>
       <VS-LAST-MOUSE .VS .ME>
       <SET OUT <1 <ME-CELL .ME> .ME>>)
      (<AND <==? .KIND ,MOUSE-MOVED>
	    <SET NME <VS-LAST-MOUSE .VS>>
	    <==? <ME-KIND .NME> ,ME-MOVED>>
       <ME-X .NME <VSI-X .P>>
       <ME-Y .NME <VSI-Y .P>>)
      (<OR <==? .KIND ,MOUSE-MOVED>
	   <==? .KIND ,ENTER-WINDOW>
	   <==? .KIND ,LEAVE-WINDOW>>
       <COND (<==? <ANDB <VSI-DETAIL .P> *377*> 2>
	      ; "Intermediate event when moving around hierarchy"
	      <RETURN <> .PE>)>
       <SET ME <NULL-MOUSE-EVENT>>
       <ME-KIND .ME <COND (<==? .KIND ,MOUSE-MOVED>
			   ,ME-MOVED)
			  (<==? .KIND ,ENTER-WINDOW>
			   ,ME-ENTER-WINDOW)
			  (T
			   ,ME-LEAVE-WINDOW)>>
       <ME-STATE .ME <LSH <VSI-DETAIL .P> -8>>
       <ME-X .ME <VSI-X .P>>
       <ME-Y .ME <VSI-Y .P>>
       <ME-TIME .ME <VSI-TIME .P>>
       <ME-WINDOW .ME .W>
       <ME-SUBWINDOW .ME .SW>
       <ME-LOCATOR .ME <I-LPAR4 .P>>
       <VS-LAST-MOUSE .VS .ME>
       <SET OUT <1 <ME-CELL .ME> .ME>>)
      (<==? .KIND ,UNMAP-WINDOW>
       <SET WE <NULL-WINDOW-EVENT>>
       <WE-KIND .WE ,WE-UNMAP-WINDOW>
       <WE-WINDOW .WE .W>
       <WE-SUBWINDOW .WE .SW>
       <VW-REDISPLAY <CHANNEL-DATA .W:CHANNEL>:VSW <>>
       <ADD-CHANGE .WE 0 0 0 0>
       <SET OUT <1 <WE-CELL .WE> .WE>>)
      (<AND <OR <==? .KIND ,EXPOSE-WINDOW>
		<==? .KIND ,EXPOSE-REGION>
		<==? .KIND ,EXPOSE-COPY>>
	    <N==? .W <VS-TOPCHAN .VS>>>
       <COND (<COND (<AND <TYPE? .SW MENU-WINDOW>
			  <TEST-VW-MODE <MW-BITS .SW> ,VWM-UNSEEN>>
		     <MW-BITS .SW <ANDB <MW-BITS .SW>
					<XORB ,VWM-UNSEEN -1>>>)
		    (<AND .W
			  <SET VW <CHANNEL-DATA .W:VSCHAN>>
			  <TEST-VW-MODE <VW-OUTMODE .VW> ,VWM-UNSEEN>>
		     <VW-OUTMODE .VW <ANDB <VW-OUTMODE .VW>
					   <XORB ,VWM-UNSEEN -1>>>)>
	      ; "Discard exposed events for new windows..."
	      <RETURN <> .PE>)>
       <COND (<NOT <SET OWE <VW-REDISPLAY <SET VW <CHANNEL-DATA .W>>>>>
	      <SET WE <NULL-WINDOW-EVENT>>)
	     (T
	      <SET WE .OWE>)>
       <COND (<==? .KIND ,EXPOSE-WINDOW>
	      <COND (.OWE
		     ; "If full redisplay, we can nuke previous saved
			events"
		     <VW-REDISPLAY .VW <>>
		     <RECYCLE-RECTANGLES <WE-CHANGES .OWE>>
		     <WE-CHANGES .OWE ()>)>
	      <COND (<OR <N==? <I-SPAR4 .P> <VW-WIDTH .VW>>
			 <N==? <I-SPAR5 .P> <VW-HEIGHT .VW>>>
		     <SET KIND ,WE-RESIZE-WINDOW>
		     <WE-OLDH .WE <VW-HEIGHT .VW>>
		     <WE-OLDW .WE <VW-WIDTH .VW>>
		     <VW-WIDTH .VW <I-SPAR4 .P>>
		     <VW-HEIGHT .VW <I-SPAR5 .P>>)
		    (T
		     <SET KIND ,WE-EXPOSE-WINDOW>)>
	      <ADD-CHANGE .WE 0 0 <VW-WIDTH .VW> <VW-HEIGHT .VW>>)
	     (<==? .KIND ,EXPOSE-COPY>
	      <SET KIND ,WE-EXPOSE-COPY>
	      <COND (.OWE
		     <VW-REDISPLAY .VW <>>
		     <SET WE <NULL-WINDOW-EVENT>>)>
	      <ADD-CHANGE .WE <I-SPAR8 .P> <I-SPAR9 .P>
			  <I-SPAR4 .P> <I-SPAR5 .P>>)
	     (T
	      <SET KIND ,WE-EXPOSE-REGION>
	      ; "Remember this guy in case we need to catch some events later"
	      <VW-REDISPLAY .VW .WE>
	      <ADD-CHANGE .WE <I-SPAR8 .P> <I-SPAR9 .P>
			  <I-SPAR4 .P> <I-SPAR5 .P>>)>
       <COND (.OWE
	      ; "This event is already on the queue, so don't return it"
	      <WE-KIND .OWE .KIND>
	      <SET OUT <>>)
	     (T
	      <WE-KIND .WE .KIND>
	      <WE-WINDOW .WE .W>
	      <WE-SUBWINDOW .WE .SW>
	      <SET OUT <1 <WE-CELL .WE> .WE>>)>)>
     <COND (.OUT
	    <COND (<EMPTY? <SET TL <VS-ILIST .VS>>>
		   <VS-IBUFFER .VS .OUT>
		   <VS-ILIST .VS .OUT>)
		  (T
		   <PUTREST .TL .OUT>
		   <VS-ILIST .VS <REST .TL>>)>)>)>>

<DEFINE ADD-CHANGE (WE:WINDOW-EVENT TOP:FIX LEFT:FIX WIDTH:FIX HEIGHT:FIX
		    "AUX" (L:LIST <WE-CHANGES .WE>) (LL:LIST ,FREE-RECTANGLES)
		    REC:WE-RECTANGLE CELL:LIST)
   <COND (<EMPTY? .LL>
	  <SET CELL
	       (<SET REC <CHTYPE <UVECTOR
				  .TOP .LEFT .WIDTH .HEIGHT>
				 WE-RECTANGLE>>)>)
	 (T
	  <SET CELL .LL>
	  <SETG FREE-RECTANGLES <REST .LL>>
	  <PUTREST .CELL ()>
	  <REC-TOP <SET REC <1 .CELL>> .TOP>
	  <REC-LEFT .REC .LEFT>
	  <REC-WIDTH .REC .WIDTH>
	  <REC-HEIGHT .REC .HEIGHT>)>
   <WE-CHANGES .WE <PUTREST .CELL .L>>>

<DEFINE RECYCLE-RECTANGLES (L:LIST)
   <COND (<NOT <EMPTY? .L>>
	  <PUTREST <REST .L <- <LENGTH .L> 1>> ,FREE-RECTANGLES>
	  <SETG FREE-RECTANGLES .L>)>>

<DEFINE ANY-INPUT? (VS:VS)
   <OR <NOT <EMPTY? <VS-IBUFFER .VS>>>
       <CHANNEL-OP <VS-CHANNEL .VS> INPUT-WAITING>>>

<DEFINE GET-WINDOW (VS:VS WID:FIX "VALUE" <OR VSCHAN FALSE>)
  <REPEAT ((L:<LIST [REST FIX VSCHAN]> <VS-ALL .VS>))
     <COND (<EMPTY? .L> <RETURN <>>)>
     <COND (<==? <1 .L> .WID> <RETURN <2 .L>>)>
     <SET L <REST .L 2>>>>

<DEFINE GET-EVENT (VS:VS "OPT" (WAIT?:<OR ATOM FALSE> T)
		   "AUX" L TL (W:<OR VSCHAN FALSE> <>) FROB TCHN VW:VSW)
   <PROG ()
      <COND (<EMPTY? <SET L <VS-IBUFFER .VS>>>
	     <COND (.WAIT?
		    <VSB-DUMP .VS>
		    <VSB-WAIT .VS <>>
		    <SET L <VS-IBUFFER .VS>>)
		   (<NOT <VSB-WAIT .VS <> T>>
		    <RETURN <>>)
		   (T
		    <SET L <VS-IBUFFER .VS>>)>)>
      <VS-IBUFFER .VS <SET TL <REST .L>>>
      <COND (<EMPTY? .TL>
	     <VS-ILIST .VS .TL>)>
      <COND (<TYPE? <SET FROB <1 .L>> FIX CHARACTER>
	     <SETG FREE-CELLS <PUTREST .L ,FREE-CELLS>>
	     .FROB)
	    (<TYPE? .FROB MOUSE-EVENT>
	     <COND (<AND <==? <ME-KIND .FROB> ,ME-MOVED>
			 <==? .FROB <VS-LAST-MOUSE .VS>>>
		    <VSB-WAIT .VS <> T>)>
	     <COND (<==? .FROB <VS-LAST-MOUSE .VS>>
		    <VS-LAST-MOUSE .VS <>>)>
	     <COND (<CHANNEL-OPEN? <ME-WINDOW .FROB>>
		    <ME-CELL .FROB <1 .L 1>>)
		   (T
		    <1 <SETG FREE-MOUSE-EVENTS
			     <PUTREST <ME-CELL .FROB> ,FREE-MOUSE-EVENTS>>
		       .FROB>
		    <AGAIN>)>)
	    (<TYPE? .FROB WINDOW-EVENT>
	     <COND (<CHANNEL-OPEN? <SET TCHN <WE-WINDOW .FROB>>>
		    <COND (<VW-REAL <SET VW <CHANNEL-DATA .TCHN:CHANNEL>>:VSW>
			   ; "Handle window events for icons"
			   <CHANNEL-OP .TCHN:VSCHAN REDISPLAY-ICON>
			   <VW-REDISPLAY .VW <>>
			   <1 <SETG FREE-WINDOW-EVENTS
				    <PUTREST <WE-CELL .FROB>
					     ,FREE-WINDOW-EVENTS>>
			      .FROB>
			   <RECYCLE-RECTANGLES <WE-CHANGES .FROB>>
			   <AGAIN>)>
		    <COND (<==? <VW-REDISPLAY .VW>
				.FROB>
			   <VSB-WAIT .VS <> T>
			   <VW-REDISPLAY .VW <>>)>
		    <WE-CELL .FROB <1 .L 1>>)
		   (T
		    <RECYCLE-RECTANGLES <WE-CHANGES .FROB>>
		    <1 <SETG FREE-WINDOW-EVENTS
			     <PUTREST <WE-CELL .FROB> ,FREE-WINDOW-EVENTS>>
		       .FROB>
		    <AGAIN>)>)>
      .FROB>>

<DEFINE NULL-MOUSE-EVENT ("AUX" (L:LIST ,FREE-MOUSE-EVENTS) ME:MOUSE-EVENT)
   <COND (<EMPTY? .L>
	  <CHTYPE [0 0 0 0 0 ,OUTCHAN <> 0 (1)] MOUSE-EVENT>)
	 (T
	  <SET ME <1 .L>>
	  <ME-CELL .ME <1 .L 1>>
	  <SETG FREE-MOUSE-EVENTS <REST .L>>
	  <PUTREST .L ()>
	  .ME)>>

<DEFINE NULL-WINDOW-EVENT ("AUX" (L:LIST ,FREE-WINDOW-EVENTS) WE:WINDOW-EVENT)
   <COND (<EMPTY? .L>
	  <CHTYPE [0 ,OUTCHAN 0 () (1) 0 0] WINDOW-EVENT>)
	 (T
	  <SET WE <1 .L>>
	  <WE-CELL .WE <1 .L 1>>
	  <SETG FREE-WINDOW-EVENTS <REST .L>>
	  <PUTREST .L ()>
	  .WE)>>

<DEFINE TRANSLATE-KEY (VS:VS DETAIL:FIX "AUX" (KEYNO:FIX <ANDB .DETAIL 255>)
		       (MAPS:<OR VECTOR FALSE> <VS-MAPS .VS>)
		       MAP KEY:<OR KEY FALSE> NUM:FIX)
   <COND (<NOT .MAPS> <>)
	 (<AND <G=? .KEYNO ,KEY-MIN-SHIFT>
	       <L=? .KEYNO ,KEY-MAX-SHIFT>>
	  ; "Throw away shift key events"
	  <>)
	 (T
	  <COND (<AND <G=? .KEYNO ,KEY-MIN-NORM>
		      <L=? .KEYNO ,KEY-MAX-NORM>>
		 <SET MAP <1 .MAPS>>)
		(T
		 <SET MAP <2 .MAPS>>)>
	  <SET KEYNO <- .KEYNO <1 .MAP> -1>>
	  <COND
	   (<AND <L=? .KEYNO <LENGTH <2 .MAP>:VECTOR>>
		 <SET KEY <NTH <2 .MAP>:VECTOR .KEYNO>>>
	    <COND (<NOT <0? <ANDB .DETAIL ,X-CONTROL-MASK>>>
		   <COND (<NOT <0? <ANDB .DETAIL ,X-SHIFT-MASK>>>
			  <SET NUM <KD-CS .KEY>>)
			 (T
			  <SET NUM <KD-CTRL .KEY>>)>)
		  (<NOT <0? <ANDB .DETAIL ,X-SHIFT-MASK>>>
		   <SET NUM <KD-SHIFT .KEY>>)
		  (<NOT <0? <ANDB .DETAIL ,X-SHIFT-LOCK-MASK>>>
		   <SET NUM <KD-LOCK .KEY>>)
		  (T
		   <SET NUM <KD-NORM .KEY>>)>
	    <COND (<G=? .NUM 0> <CHTYPE .NUM CHARACTER>)
		  (T <- .NUM>)>)>)>>

<ENDPACKAGE>
