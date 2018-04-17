
<PACKAGE "BUILDL">

<ENTRY LIST-BUILD>

<USE "COMPDEC" "CODGEN" "CHKDCL" "ADVMESS" "MIMGEN" "STRGEN">

<DEFINE LIST-BUILD (NOD W
		    "AUX" (K <KIDS .NOD>) (KK ()) N TEM TT T1 D1 D2 D3
			  (OOPSF <>) TG1 TG2 (SUGGEST DONT-CARE))
   #DECL ((K KK) <LIST [REST NODE]> (N NOD) NODE)
   <COND (<AND <TYPE? .W TEMP> <==? <TEMP-REFS .W> 0>> <SET SUGGEST .W>)>
   <COND
    (<OR
      <AND <==? <LENGTH .K> 1> <SET KK .K>>
      <MAPF <>
	    <FUNCTION (N) 
		    #DECL ((N) NODE)
		    <COND (<AND <G=? <LENGTH .N>
				     <CHTYPE <INDEX ,SIDE-EFFECTS> FIX>>
				<SIDE-EFFECTS .N>>
			   <MAPLEAVE <>>)
			  (ELSE <SET KK (.N !.KK)> T)>>
	    .K>>
     <COND
      (<AND <==? <NODE-TYPE <SET N <1 .KK>>> ,SEG-CODE>
	    <==? <STRUCTYP <RESULT-TYPE <SET N <1 <KIDS .N>>>>>
		 LIST>>
       <SET TEM <GEN .N>>
       <SET KK <REST .KK>>)
      (ELSE <SET TEM <REFERENCE ()>>)>
     <MAPR <>
      <FUNCTION (NL "AUX" (N <1 .NL>)) 
	      #DECL ((NL) <LIST NODE> (N) NODE)
	      <COND (<==? <NODE-TYPE .N> ,SEG-CODE>
		     <SET TEM <SEG-BUILD-LIST <1 <KIDS .N>> .TEM <> <> <>>>)
		    (ELSE
		     <FREE-TEMP <SET T1 <GEN .N>> <>>
		     <COND (<AND <N==? .TEM .W> <N==? .TEM .SUGGEST>>
			    <FREE-TEMP .TEM <>>)
			   (ELSE <DEALLOCATE-TEMP .TEM>)>
		     <IEMIT `CONS
			    <ATOMCHK .T1>
			    .TEM
			    =
			    <SET TEM
				 <COND (<AND <EMPTY? <REST .NL>>
					     <N==? .W DONT-CARE>>
					<COND (<TYPE? .W TEMP>
					       <USE-TEMP .W LIST>)>
					.W)
				       (<TYPE? .SUGGEST TEMP>
					<USE-TEMP .SUGGEST LIST>
					.SUGGEST)
				       (ELSE <GEN-TEMP LIST>)>>>)>>
      .KK>
     <MOVE-ARG .TEM .W>)
    (ELSE
     <COND (<==? <NODE-TYPE <SET N <1 .K>>> ,SEG-CODE>
	    <SET TEM <SEG-BUILD-LIST <1 <KIDS .N>> <REFERENCE ()> T T <>>>
	    <SET D3 <2 .TEM>>
	    <SET D2 <1 .TEM>>
	    <SET OOPSF <3 .TEM>>)
	   (ELSE
	    <SET D1 <GEN .N DONT-CARE>>
	    <FREE-TEMP .D1 <>>
	    <IEMIT `CONS
		   <ATOMCHK .D1>
		   ()
		   =
		   <SET D2
			<SET D3
			     <COND (<TYPE? .SUGGEST TEMP>
				    <USE-TEMP .SUGGEST LIST>
				    .SUGGEST)
				   (ELSE <GEN-TEMP LIST>)>>>>)>
     <MAPR <>
      <FUNCTION (L "AUX" (N <1 .L>)) 
	 #DECL ((N) NODE)
	 <COND
	  (<==? <NODE-TYPE .N> ,SEG-CODE>
	   <COND
	    (<AND
	      <==? <STRUCTYP <RESULT-TYPE <SET N <1 <KIDS .N>>>>>
		   LIST>
	      <EMPTY? <REST .L>>>
	     <SET D1 <GEN .N DONT-CARE>>
	     <COND (.OOPSF <EMPTY-LIST .D3 <SET TG1 <MAKE-TAG>> T>)>
	     <IEMIT `PUTREST .D3 .D1>
	     <COND (.OOPSF
		    <LABEL-TAG .TG1>
		    <EMPTY-LIST .D3 <SET TG1 <MAKE-TAG>> <>>
		    <SET-TEMP .D2 .D1>
		    <LABEL-TAG .TG1>)>
	     <FREE-TEMP .D1>)
	    (ELSE <SET D3 <SEG-BUILD-LIST .N .D3 T <> <COND (.OOPSF .D2)>>>)>)
	  (ELSE
	   <FREE-TEMP <SET D1 <GEN .N DONT-CARE>> <>>
	   <IEMIT `CONS <ATOMCHK .D1> () = <SET D1 <GEN-TEMP LIST>>>
	   <COND (.OOPSF <EMPTY-LIST .D3 <SET TG1 <MAKE-TAG>> T>)>
	   <IEMIT `PUTREST .D3 .D1>
	   <COND (.OOPSF
		  <BRANCH-TAG <SET TG2 <MAKE-TAG>>>
		  <LABEL-TAG .TG1>
		  <SET-TEMP .D2 .D1>
		  <LABEL-TAG .TG2>)
		 (ELSE
		  <COND (<N==? .D3 .D2> <FREE-TEMP .D3>)>
		  <SET D3 .D1>)>)>>
      <REST .K>>
     <COND (<N==? .D2 .D3> <FREE-TEMP .D3>)>
     <MOVE-ARG .D2 .W>)>>

<DEFINE SEG-BUILD-LIST (NOD DAT FLG FST SMQ
			"AUX" (TYP <RESULT-TYPE .NOD>) (TG2 <MAKE-TAG>)
			      (ITYP <ISTYPE? .TYP>)
			      (TPS <STRUCTYP .TYP>)
			      (ET <GET-ELE-TYPE .TYP ALL>)
			      (ML <MINL .TYP>) TG3 TG4
			      (TG1 <MAKE-TAG>) TEM D1 (D3 .DAT) FDAT)
	#DECL ((NOD) NODE)
	<COND (<TYPE? .D3 TEMP> <USE-TEMP .D3 LIST>)>
	<SET ET <ISTYPE-GOOD? .ET>>
	<SET D1 <GEN .NOD <GEN-TEMP <>>>>
	<COND (<OR .FST <NOT .FLG>>
	       <COND (<0? .ML>
		      <SET DAT <MOVE-ARG .DAT <GEN-TEMP <>>>>
		      <MT-TEST .D1 .TG1 .TPS .ITYP>)
		     (ELSE <SET DAT <GEN-TEMP>>)>
	       <NTH-DO .TPS .D1 <SET TEM <GEN-TEMP>> 1>
	       <FREE-TEMP .TEM <>>
	       <IEMIT `CONS .TEM .D3 = <SET FDAT <GEN-TEMP LIST>>>
	       <SET-TEMP .DAT .FDAT>
	       <FREE-TEMP .DAT>)
	      (ELSE <SET-TEMP <SET FDAT <GEN-TEMP <>>> .DAT>)>
	<COND (<OR .FST <NOT .FLG>> <SET D1 <1REST .D1 .TPS>>)>
	<COND (<L=? .ML 1> <MT-TEST .D1 .TG1 .TPS .ITYP>)>
	<IEMIT `LOOP
	       <COND (<NOT .TPS> (<TEMP-NAME .D1> TYPE VALUE LENGTH))
		     (<==? .TPS LIST> (<TEMP-NAME .D1> VALUE))
		     (ELSE (<TEMP-NAME .D1> VALUE LENGTH))>
	       (<TEMP-NAME .FDAT> VALUE)
	       !<COND (<AND <NOT .FLG> <TYPE? .D3 TEMP>>
		       ((<TEMP-NAME .D3> VALUE)))
		      (ELSE ())>>
	<LABEL-TAG .TG2>
	<NTH-DO .TPS .D1 <SET TEM <GEN-TEMP>> 1>
	<IEMIT `CONS .TEM <COND (.FLG ()) (ELSE .D3)> = .TEM>
	<COND (.SMQ <EMPTY-LIST .FDAT <SET TG3 <MAKE-TAG>> T>)>
	<IEMIT `PUTREST .FDAT .TEM>
	<COND (.SMQ
	       <BRANCH-TAG <SET TG4 <MAKE-TAG>>>
	       <LABEL-TAG .TG3>
	       <EMPTY-LIST .FDAT .TG4 <>>
	       <SET-TEMP .SMQ .TEM>)>
	<SET-TEMP .FDAT .TEM>
	<FREE-TEMP .FDAT>
	<FREE-TEMP .TEM>
	<REST-N-JMP .D1 .TPS .TG2 .D1 .ITYP>
	<LABEL-TAG .TG1>
	<FREE-TEMP .D1>
	<COND (<AND .FLG .FST> (.DAT .FDAT <0? .ML>))
	      (.FLG .FDAT)
	      (ELSE <FREE-TEMP .FDAT> .DAT)>>

<DEFINE MT-TEST (D TG TP TYP) 
	#DECL ((TP) ATOM)
	<EMPTY-CHECK .TP .D .TYP T .TG>>

<DEFINE 1REST (D TP) #DECL ((TP) ATOM) <REST-DO .TP .D .D 1> .D>

<DEFINE REST-N-JMP (D TP TG D1 TYP) 
	<REST-DO .TP .D .D1 1>
	<EMPTY-CHECK .TP .D .TYP <> .TG>
	T>

<ENDPACKAGE>
