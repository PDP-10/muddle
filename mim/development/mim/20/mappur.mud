<DEFINE T$PCODE (ID DBNAM "AUX" (PURVEC ,I$PURVEC) (DBVEC ,I$DBVEC) CPC
		 DBID)
  #DECL ((ID DBID) FIX (DBNAM) STRING
	 (DBVEC) <VECTOR [REST <OR DB FALSE>]> (PURVEC) <LIST [REST T$PCODE]>
	 (CPC) T$PCODE)
  <COND (<EMPTY? .PURVEC>
	 <SETG I$PURVEC
	       <SET PURVEC (<CHTYPE <REST <IUVECTOR <* 20 ,M$$PC-ENTLEN> 0>
					  <* 19 ,PC-ENTLEN>> T$PCODE>)>>)>
  ; "Get a DB ID to go with the file ID"
  <REPEAT ((CT 1) (DBV .DBVEC) DB)
    #DECL ((CT) FIX (DBV) <VECTOR [REST <OR DB FALSE>]>
	   (DB) <OR DB FALSE>)
    <COND (<AND <SET DB <1 .DBV>>
		<T$S=? <DB-NAME .DB> .DBNAM>>
	   <SET DBID .CT>
	   <RETURN>)
	  (<NOT .DB>
	   <SET DBID .CT>
	   <1 .DBV [.DBNAM <>]>
	   <RETURN>)>
    <SET CT <+ .CT 1>>
    <COND (<EMPTY? <SET DBV <REST .DBV>>>
	   <SET DBV <IVECTOR <+ <LENGTH .DBVEC> 5> <>>>
	   <MAPR <>
		 <FUNCTION (OLD NEW)
			   #DECL ((OLD NEW) VECTOR)
			   <1 .NEW <1 .OLD>>>
		 .DBVEC .DBV>
	   <SETG I$DBVEC <SET DBVEC .DBV>>
	   <CALL SETS DBVEC (,I$DBVEC)>
	   <PUT .DBVEC .CT [.DBNAM <>]>
	   <SET DBID .CT>
	   <RETURN>)>>
  <COND (<MAPF <>
	     <FUNCTION (PV) #DECL ((PV) <OR T$PCODE UVECTOR>)
	       <REPEAT ()
	         <COND (<AND <==? <M$$PC-ID .PV> .ID>
			     <==? <M$$PC-DB .PV> .DBID>>
			<MAPLEAVE .PV>)>
		 <COND (<EMPTY? <SET PV <REST .PV ,M$$PC-ENTLEN>>>
			<RETURN <>>)>
		 <SET PV <CHTYPE .PV T$PCODE>>>>
	     .PURVEC>)
	(T
	 <SET CPC <1 .PURVEC>>
	 <COND (<NOT <0? <M$$PC-ID .CPC>>>
		<COND (<==? <LENGTH .CPC> <* 20 ,M$$PC-ENTLEN>>
		       <SET CPC <CHTYPE <REST <IUVECTOR <* 20 ,M$$PC-ENTLEN>
							0>
					      <* 19 ,PC-ENTLEN>> T$PCODE>>
		       <SETG I$PURVEC <SET PURVEC (.CPC !.PURVEC)>>
		       <CALL SETS PURVEC ,I$PURVEC>)
		      (<SET CPC <CHTYPE <BACK .CPC ,M$$PC-ENTLEN> T$PCODE>>
		       <1 .PURVEC .CPC>)>)>
	 <M$$PC-ID .CPC .ID>
	 <M$$PC-DB .CPC .DBID>
	 <M$$PC-DBLOC .CPC -1>
	 <M$$PC-CORLOC .CPC 0>
	 <M$$PC-LEN .CPC 0>
	 .CPC)>>

<DEFINE X$PCODE-PRINT (PC "AUX" (OUTCHAN .OUTCHAN))
  #DECL ((PC) T$PCODE)
  <T$PRINC "%<" .OUTCHAN>
  <T$PRIN1 PCODE .OUTCHAN>
  <T$PRINC !\  .OUTCHAN>
  <T$PRIN1 <M$$PC-ID .PC> .OUTCHAN>
  <T$PRINC !\  .OUTCHAN>
  <T$PRIN1 <DB-NAME <NTH ,I$DBVEC:VECTOR <M$$PC-DB .PC>>:VECTOR> .OUTCHAN>
  <T$PRINC !\> .OUTCHAN>>

<DEFINE I$GET-DB (PC "AUX" (DBVEC ,I$DBVEC) DB (DBID <M$$PC-DB .PC>) CC ERR)
  #DECL ((PC) T$PCODE (DBVEC) <VECTOR [REST <OR DB FALSE>]> (DBID) FIX
	 (DB) DB (CC) <OR FIX FALSE>)
  <SET DB <NTH .DBVEC .DBID>>
  <PROG ()
    <COND (<NOT <SET CC <DB-CHANNEL .DB>>>
	   <COND (<SET CC <CALL SYSOP GTJFN-S-S %<CHTYPE <ORB ,GJ-OLD ,GJ-SHT>
						         FIX>
			        <DB-NAME .DB>>>
		  <COND (<SET ERR
			      <CALL SYSOP OPENF
				    .CC %<CHTYPE <ORB ,OF-RD ,OF-THW ,OF-PLN>
						 FIX>>>
			 <DB-CHANNEL .DB .CC>)
			(<OR <==? <1 .ERR> *600131*>
			     ; "Entire file structure full"
			     <==? <1 .ERR> *601727*>>
			 ; "Insufficient system resources"
			 <CALL SYSOP RLJFN .CC>
			 ; "Free the JFN"
			 <CALL PRINT *101* <DB-NAME .DB>
			       <LENGTH <DB-NAME .DB>>>
			 ; "Print a message"
			 <CALL SYSOP ESOUT %<STRING "Can't open database:  "
						    <ASCII 0>>>
			 <CALL SYSOP ERSTR *101* <PUTLHW <1 .ERR>
							 *400000*> 0>
			 <CALL QUIT *601727* ; "MONX01">
			 ; "Quit with special code, then try again
			    if continued"
			 <AGAIN>)
			(T
			 <CALL SYSOP RLJFN .CC>
			 <SET CC .ERR>)>)>
	   <COND (<NOT .CC>
		  <CALL PRINT *101* <DB-NAME .DB> <LENGTH <DB-NAME .DB>>>
		  <CALL PRINT *101* "
" 2>
		  <CALL FATAL "Can't find database">
		  <AGAIN>)>)>>
  .CC>

<DEFINE X$PLOAD (PC "AUX" (JFN <I$GET-DB .PC>) FS IV DV DIRLOC ENT
		 GCP)
  #DECL ((PC) T$PCODE (JFN) FIX (FS) T$ZONE (DIRLOC) FIX
	 (IV DV) UVECTOR (ENT) <OR UVECTOR FALSE> (GCP) T$GC-PARAMS)
  <COND (<G=? <M$$PC-DBLOC .PC> 0>
	 ; "Do we already know where this is?"
	 ; "Takes JFN, pcode; reads stuff in somewhere"
	 <I$MAP-IN .JFN .PC>)
	(T
	 <COND (<NOT ,I$FBIN-SPACE>
		<SETG I$FBIN-SPACE <T$CREATE-NEW-SPACE 1024>>
		<SET FS ,I$FBIN-SPACE>
		<GCSFLG <SET GCP <GC-PARAMS .FS>> -1>
		<T$SET-ZONE .FS>
		<SETG I$IND-VEC <IUVECTOR ,T$PSIZE 0>>
		<SETG I$DIR-VEC <IUVECTOR ,T$PSIZE 0>>
		<T$RESTORE-ZONE>)
	       (<SET FS ,I$FBIN-SPACE>)>
	 <SET IV ,I$IND-VEC>
	 <SET DV ,I$DIR-VEC>
	 <I$MAP-PAGE .JFN .IV ,ALLOC-PAGE T>
	 <SET DIRLOC <I$HASH-PCODE .PC .IV>>
	 <I$MAP-PAGE .JFN .DV .DIRLOC T>
	 <1 .DV <1 .DV>>
	 ; "Unshare this loser"
	 <COND (<SET ENT <I$BINSRC .PC .DV>>
		<M$$PC-DBLOC .PC <RHW <DIR-PAGE&LOC .ENT>>>
		<M$$PC-LEN .PC <- <LHW <DIR-PAGE&LOC .ENT>>
				  ,SAV-HEADER-LEN>>
		<I$MAP-IN .JFN .PC>)
	       (<T$ERROR %<P-E "MISSING-SAV-FILE"> .PC I$PLOAD>)>)>>

<DEFINE I$HASH-PCODE (PC IV "AUX" (ID <M$$PC-ID .PC>) DIRNUM) 
  #DECL ((PC) T$PCODE (IV) UVECTOR (ID DIRNUM) FIX)
  <SET DIRNUM <MOD .ID <ALLOC-DIRCNT .IV>>>
  <NTH .IV <+ ,ALLOC-HEADER-LEN <* .DIRNUM ,ALLOC-DIR-LEN>
	      ,ALLOC-DIRLOC>>>

<DEFINE I$MAP-PAGE (JFN UV PGNO ALLOW? "OPTIONAL" (NPGS 1) "AUX" EXBIT
		    ERR)
  #DECL ((JFN PGNO NPGS) FIX (UV) <OR UVECTOR FIX>)
  <COND (.ALLOW? <SET EXBIT *400*>)>
  <PROG ()
   <COND (<SET ERR
	       <CALL SYSOP PMAP <PUTLHW .PGNO .JFN>
		     <PUTLHW <ADDRESS-PAGE <CALL VALUE .UV>> *400000*>
		     <COND (<1? .NPGS>
			    <ORB *100000000000* <PUTLHW 0 .EXBIT>>)
			   (T
			    <PUTLHW .NPGS <ORB *500000* .EXBIT>>)>>>)
	 (<OR <==? <1 .ERR> *600131*>
	      <==? <1 .ERR> *601727*>>
	  <CALL SYSOP ESOUT %<STRING "Can't map in pages:  "
				     <ASCII 0>>>
	  <CALL SYSOP ERSTR *101* <PUTLHW <1 .ERR> *400000*> 0>
	  <CALL QUIT *601727* ;"MONX01">
	  <AGAIN>)
	 (T
	  <ERROR %<P-E "CANT-MAP-IN-PAGES"> .ERR X$PLOAD>)>>>


; "Binary search of directory (in DV) for pcode's entry."
<DEFINE I$BINSRC (PC DV "AUX" (ID <M$$PC-ID .PC>) (CNT <DIR-COUNT .DV>)
		  (EXIT .CNT))
  #DECL ((PC) T$PCODE (DV) <UVECTOR [REST FIX]> (ID) FIX (CNT) FIX)
  <SET DV <REST .DV ,DIR-HEADER>>
  <REPEAT UP ()
    <COND (<0? <SET CNT </ .CNT 2>>>
	   <REPEAT ()
	     <COND (<L=? .EXIT 0>
		    <RETURN <> .UP>)>
	     <SET EXIT <- .EXIT 1>>
	     <COND (<==? .ID <DIR-FILE-ID .DV>>
		    <RETURN .DV .UP>)>
	     <SET DV <REST .DV ,DIR-ENTRY-SIZE>>>)
	  (<==? .ID <DIR-FILE-ID .DV>>
	   <RETURN .DV>)
	  (<G=? .ID <NTH .DV <- <* ,DIR-ENTRY-SIZE <+ .CNT 1>> 1>>>
	   <SET DV <REST .DV <* ,DIR-ENTRY-SIZE .CNT>>>)>
    <SET EXIT <- .EXIT .CNT>>>>

<DEFINE I$MAP-IN (JFN PC "AUX" (RLEN <+ <M$$PC-LEN .PC> ,SAV-HEADER-LEN>)
		  PGN SADR NPGS)
  #DECL ((NPGS JFN RLEN SADR) FIX (PC) T$PCODE
	 (PGN) <OR FIX FALSE>)
  <COND (<OR <NOT <SET PGN
		       <T$GET-BLOCK-OF-SPACE <SET NPGS
						<ADDRESS-PAGE
						  <+ .RLEN <- ,T$PSIZE 1>>>>
					     ,M$$MP-IDENT>>>
	     <L? .PGN 0>>
	 <ERROR %<P-E "CANT-GET-PAGES"> .PC I$MAP-IN>)
	(T
	 <SET SADR <PAGE-ADDRESS .PGN>>
	 <I$MAP-PAGE .JFN .SADR <M$$PC-DBLOC .PC> <> .NPGS>
	 <M$$PC-CORLOC .PC <+ .SADR ,SAV-HEADER-LEN>>)>>

<DEFINE X$PURCLN ("AUX" PV DV FS GCP)
  #DECL ((PV) <LIST [REST T$PCODE]> (DV) <VECTOR [REST <OR DB FALSE>]>
	 (FS) T$ZONE (GCP) T$GC-PARAMS)
  <COND (,I$FBIN-SPACE
	 <T$RETURN-PAGES ,M$$MP-IDENT>		; "Get rid of pages"
	 <COND (<GASSIGNED? I$PURVEC>
		; "Unmap directory pages"
		<I$FLUSH-PAGES <ADDRESS-PAGE
				<GCSMIN <SET GCP
					     <GC-PARAMS
					      <SET FS ,I$FBIN-SPACE>>>>>
			        2>
		<SET PV ,I$PURVEC>
		<SET DV ,I$DBVEC>
		; "Say nothing is mapped in"
		<MAPF <>
		  <FUNCTION (PC)
		    #DECL ((PC) <OR T$PCODE <UVECTOR [REST FIX]>>)
		    <REPEAT ()
		      ; "Map the pages out"
		      <M$$PC-CORLOC .PC 0>
		      ; "Forget where they are in the sav file, to allow
			 us to compact it."
		      <M$$PC-DBLOC .PC -1>
		      <M$$PC-LEN .PC 0>
		      <COND (<EMPTY? <SET PC <REST .PC ,M$$PC-ENTLEN>>>
			     <RETURN>)>>>
		  .PV>
		; "Flush channels to sav files"
		<MAPF <>
		  <FUNCTION (DD)
		    <COND (<AND .DD
				<DB-CHANNEL .DD>>
			   <CALL SYSOP CLOSF <DB-CHANNEL .DD>>
			   <DB-CHANNEL .DD <>>)>>
		  .DV>)>)>
  T>
