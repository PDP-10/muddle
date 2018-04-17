
<PACKAGE "TERMPRS">

<ENTRY PARSE-TERMCAP PARSE-TERM-TYPE>

<L-FLOAD "TTYTYPES.MUD">

<L-FLOAD "TTYOPS.MUD">

<SETG CRLF-STRING "
">

<SETG CRLF-LEN <LENGTH ,CRLF-STRING>>

"Write a TTY-DESC to the supplied file.  This produces a format that can be
 read by the TTY package."

<DEFINE WRITE-TTY-DESC (FN DESC
			"AUX" (DEV "USR") (SNM "MIM/TTYS") (NM2 "") CH
			      (BUFSTR <STACK <ISTRING 256>>))
   #DECL ((DESC) TTY-DESC (FN) STRING (CH) <OR CHANNEL FALSE> (BUFSTR) STRING
	  (DEV SNM NM2) <SPECIAL STRING>)
   <SET CH <CHANNEL-OPEN PARSE .FN>>
   <SET FN <CHANNEL-OP .CH NAME>>
   <CHANNEL-CLOSE .CH>
   <COND
    (<SET CH <CHANNEL-OPEN DISK .FN "CREATE" "ASCII">>
     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE <LENGTH <TD-NAME .DESC>> CHARACTER>>
     <CHANNEL-OP .CH WRITE-BUFFER <TD-NAME .DESC>>
     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE <TD-HEIGHT .DESC> CHARACTER>>
     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE <TD-WIDTH .DESC> CHARACTER>>
     <CHANNEL-OP .CH WRITE-BYTE <TD-PADCHR .DESC>>
     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE <TD-CRPAD .DESC> CHARACTER>>
     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE <TD-LFPAD .DESC> CHARACTER>>
     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE <LENGTH <TD-PRIMOPS .DESC>> CHARACTER>>
     <CHANNEL-OP .CH
		 WRITE-BYTE
		 <CHTYPE <MAPF ,+
			       <FUNCTION (X) <COND (.X 1) (0)>>
			       <TD-PRIMOPS .DESC>>
			 CHARACTER>>
     <PROG ((ID 1))
       #DECL ((ID) FIX)
       <MAPF <>
	<FUNCTION (X "AUX" (TLEN 0) NLEN) 
	   #DECL ((X) <OR FALSE TTY-OP> (TLEN) FIX)
	   <COND
	    (.X
	     <SET BUFSTR <TOP .BUFSTR>>
	     <1 .BUFSTR <CHTYPE .ID CHARACTER>>
	     <SET TLEN 2>
	     <COND (<TYPE? .X VECTOR>
		    <2 .BUFSTR <CHTYPE <LENGTH .X> CHARACTER>>
		    <MAPF <>
			  <FUNCTION (PART) 
				  <SET NLEN
				       <WRITE-PART .PART <REST .BUFSTR 2>>>
				  <SET TLEN <+ .TLEN .NLEN>>
				  <SET BUFSTR <REST .BUFSTR .NLEN>>>
			  .X>)
		   (T
		    <2 .BUFSTR <CHTYPE 1 CHARACTER>>
		    <SET NLEN <WRITE-PART .X <REST .BUFSTR 2>>>
		    <SET TLEN <+ .TLEN .NLEN>>)>
	     <CHANNEL-OP .CH WRITE-BYTE <CHTYPE .TLEN CHARACTER>>
	     <CHANNEL-OP .CH WRITE-BUFFER <TOP .BUFSTR> .TLEN>)>
	   <SET ID <+ .ID 1>>>
	<TD-PRIMOPS .DESC>>>
     <CLOSE .CH>)>>

<DEFINE WRITE-PART (PART BUF "OPTIONAL" (PAD 0) "AUX" (CHRS 0)) 
   #DECL ((PART) <OR TTY-ELT STRING TTY-OUT> (CHRS) FIX (BUF) STRING (PAD) FIX)
   <COND
    (<TYPE? .PART STRING>
     <1 .BUF <CHTYPE .PAD CHARACTER>>
     <2 .BUF <CHTYPE <+ <LENGTH .PART> 2> CHARACTER>>
     <3 .BUF <ASCII 1>>
     <4 .BUF <CHTYPE <LENGTH .PART> CHARACTER>>
     <MAPR <>
	   <FUNCTION (X Y) #DECL ((X Y) STRING) <1 .X <1 .Y>>>
	   <REST .BUF 4>
	   .PART>
     <+ 4 <LENGTH .PART>>)
    (<TYPE? .PART TTY-OUT> <WRITE-PART <TO-STRING .PART> .BUF <TO-PAD .PART>>)
    (<TYPE? .PART TTY-ELT>
     <1 .BUF <CHTYPE .PAD CHARACTER>>
     <3 .BUF <CHTYPE <LENGTH .PART> CHARACTER>>
     <PROG ((TBUF <REST .BUF 3>) (LEN 0))
	   <MAPF <>
		 <FUNCTION (FROB) 
			 #DECL ((FROB) <OR STRING FIX>)
			 <COND (<TYPE? .FROB FIX>
				<1 .TBUF <CHTYPE .FROB CHARACTER>>
				<SET TBUF <REST .TBUF>>
				<SET LEN <+ .LEN 1>>)
			       (T
				<1 .TBUF <CHTYPE <LENGTH .FROB> CHARACTER>>
				<MAPR <>
				      <FUNCTION (X Y) 
					      #DECL ((X Y) STRING)
					      <1 .X <1 .Y>>>
				      <REST .TBUF>
				      .FROB>
				<SET TBUF <REST .TBUF <+ <LENGTH .FROB> 1>>>
				<SET LEN <+ .LEN 1 <LENGTH .FROB>>>)>>
		 .PART>
	   <2 .BUF <CHTYPE .LEN CHARACTER>>
	   <+ .LEN 3>>)>>

"Parse a TERMCAP file, making new files for each terminal described."

<SETG NAME-VEC
      '["dumb"
	"GLASS"
	"arpanet"
	"NVT"
	"c100rv"
	"C100"
	"c100"
	"C100"
	"h19"
	"H19"
	"altoh19"
	"H19"
	"cdc456"
	"CDC456"
	"cdc456tst"
	"CDC456"
	"dm1520"
	"DM1520"
	"dm1521"
	"DM1521"
	"dm2500"
	"DM2500"
	"dm3025"
	"DM3025"
	"3045"
	"DM3045"
	"dt80"
	"DT80"
	"dt80132"
	"DT80"
	"h1552"
	"H1552"
	"h1552rv"
	"H1552"
	"h1500"
	"H1500"
	"h1510"
	"H1500"
	"ibm"
	"IBM"
	"tab132"
	"TAB132"
	"tab132w"
	"TAB132"
	"tab132rv"
	"TAB132"
	"tab132wrv"
	"TAB132"
	"vc404"
	"VC404"
	"vc404s"
	"VC404"
	"vc404na"
	"VC404"
	"vc404sna"
	"VC404"
	"vc303a"
	"VC303"
	"vc303"
	"VC303"
	"aaadb"
	"AAA"
	"aa"
	"AAA"
	"aaajek"
	"AAA"
	"aaa"
	"AAA"
	"datapoint"
	"DATAPOINT"
	"vi200"
	"VI200"
	"vi200rvic"
	"VI200"
	"vi200f"
	"VI200"
	"vi200rv"
	"VI200"
	"vi200ic"
	"VI200"
	"regent"
	"REGENT"
	"regent100"
	"REGENT"
	"regent20"
	"REGENT"
	"regent25"
	"REGENT"
	"regent40"
	"REGENT"
	"regent60"
	"REGENT"
	"regent60na"
	"REGENT"
	"c108"
	"C108"
	"c100rvpp"
	"C100"
	"c100rvna"
	"C100"
	"c100s"
	"C100"
	"c100rvs"
	"C100"
	"c100-1200"
	"C100"
	"vt100n"
	"VT100"
	"vt100"
	"VT100"
	"vt100v"
	"VT100V"
	"vt125"
	"VT125"
	"ovt100"
	"VT100"
	"vt132"
	"VT132"
	"vt50"
	"VT50"
	"dw1"
	"LA30"
	"vt50h"
	"VT50"
	"vt100s"
	"VT100"
	"vt100w"
	"VT100"
	"vt52"
	"VT52"
	"bg"
	"BBN"
	"bbn"
	"BBN"
	"nvt52"
	"VT52"
	"vt52big"
	"VT52"
	"spdp"
	"SUPDUP"
	"dw2"
	"LA36"
	"hp"
	"HP2645"
	"h19A"
	"H19A"
	"h19bs"
	"H19"
	"h19us"
	"H19"
	"h19u"
	"H19"]>

<DEFINE GET-STANDARD-NAME (NAME "AUX" TV) 
	#DECL ((NAME) STRING (TV) <OR VECTOR FALSE>)
	<COND (<SET TV <MEMBER .NAME ,NAME-VEC>> <2 .TV>)
	      (<MAPF ,STRING
		     <FUNCTION (X) 
			     #DECL ((X) CHARACTER)
			     <COND (<AND <G=? <ASCII .X> <ASCII !\a>>
					 <L=? <ASCII .X> <ASCII !\z>>>
				    <ASCII <+ <ASCII .X>
					      <- <ASCII !\A> <ASCII !\a>>>>)
				   (.X)>>
		     .NAME>)>>

<DEFINE PARSE-TERM-TYPE ("AUX" (VEC <CALL GETS ENVIR>) ST) 
	<COND (<SET ST <GET-ENV-STR "TERMCAP" .VEC>>
	       <PARSE-TERMCAP "FOO" .ST>)
	      (#FALSE ("TERMCAP ENTRY NOT IN ENVIRONMENT"))>>

<DEFINE GET-NEXT-STRING (CH
			 "AUX" (BUF <STACK <ISTRING 512>>)
			       (CUR <CHANNEL-OP .CH ACCESS>) CT)
   #DECL ((CHANNEL) CHANNEL (BUF) STRING (CUR) FIX)
   <REPEAT OLOOP (TS (TBUF .BUF))
     <COND
      (<SET CT <CHANNEL-OP .CH READ-BUFFER .TBUF>>
       <COND (<0? .CT> <RETURN <>>)>
       <SET CT <- 512 <- <LENGTH .TBUF> .CT>>>
       <COND (<N==? .CT 512> <SUBSTRUC .BUF 0 .CT <REST .BUF <- 512 .CT>>>)>
       <PROG ((TS .BUF))
	     <COND (<SET TS <MEMQ !\: .TS>>
		    <COND (<==? <LENGTH .TS> 1>
			   <1 .BUF !\:>
			   <SET TBUF <REST .BUF>>
			   <AGAIN .OLOOP>)>
		    <COND (<==? <2 .TS> <ASCII 10>>
			   <SET BUF
				<ISTRING <- <CHANNEL-OP .CH ACCESS>
					    <- <LENGTH .TS> 2>
					    .CUR>>>
			   <CHANNEL-OP .CH ACCESS .CUR>
			   <CHANNEL-OP .CH READ-BUFFER .BUF>
			   <RETURN .BUF .OLOOP>)>
		    <SET TS <REST .TS>>
		    <AGAIN>)
		   (<SET TBUF .BUF>)>>)
      (<RETURN .CT>)>>>

<DEFINE PARSE-TERMCAP ("OPTIONAL" (FN "/ETC/TERMCAP") ST "AUX" (CH <>) DESCS) 
   #DECL ((FN ST) STRING (CH) <OR CHANNEL FALSE>)
   <COND
    (<OR <ASSIGNED? ST>
	 <AND <SET CH <CHANNEL-OPEN DISK .FN "READ" "ASCII">>
	      <RESET .CH>>>
     <COND (<NOT <ASSIGNED? ST>> <SET ST "">)>
     <SET DESCS
      <MAPF ,VECTOR
       <FUNCTION ("AUX" DSTR TSS TS NAME STDNAME TS1 TS2 NS) 
	  #DECL ((TS) <OR STRING FALSE> (TSS NAME STDNAME) STRING)
	  <COND (<EMPTY? .ST>
		 <COND (<OR <NOT .CH> <NOT <SET NS <GET-NEXT-STRING .CH>>>>
			<MAPSTOP>)
		       (T <SET ST .NS>)>)>
	  <COND (<==? <1 .ST> !\#>
		 <COND (<SET TS <MEMBER ,CRLF-STRING .ST>>
			<SET ST <REST .TS ,CRLF-LEN>>
			<MAPRET>)
		       (<MAPSTOP>)>)>
	  <SET TSS <MEMQ !\| .ST>>
	  <SET TS1 <MEMQ !\| <REST .TSS>>>
	  <SET TS2 <MEMQ !\: <REST .TSS>>>
	  <COND (<AND .TS1 .TS2>
		 <COND (<L? <LENGTH .TS1> <LENGTH .TS2>> <SET TS1 .TS2>)>)
		(<SET TS1 <OR .TS1 .TS2>>)
		(<SET TS1 "">)>
	  <SET NAME <SUBSTRUC <REST .TSS> 0 <- <LENGTH .TSS> 1 <LENGTH .TS1>>>>
	  <SET STDNAME <GET-STANDARD-NAME .NAME>>
	  <SET ST <MEMQ !\: .TSS>>
	  <SET DSTR
	   <MAPF ,STRING
	    <FUNCTION ("AUX" CHR NUM) 
	       <COND (<AND <G=? <LENGTH .ST> 2>
			   <==? <1 .ST> !\:>
			   <OR <==? <2 .ST> <ASCII 10>>
			       <==? <2 .ST> <ASCII 13>>>>
		      <SET ST <REST .ST 2>>
		      <COND (<AND <NOT <EMPTY? .ST>> <==? <1 .ST> <ASCII 10>>>
			     <SET ST <REST .ST>>)>
		      <MAPSTOP !\:>)>
	       <COND (<EMPTY? .ST> <MAPSTOP>)>
	       <COND
		(<==? <1 .ST> <ASCII 10>> <SET ST <REST .ST>> <MAPRET>)
		(<==? <1 .ST> <ASCII 13>> <SET ST <REST .ST>> <MAPRET>)
		(<==? <1 .ST> <ASCII 92>>
		 <COND
		  (<MEMQ <SET CHR <2 .ST>> "01234567">
		   <SET NUM 0>
		   <MAPR <>
			 <FUNCTION (STR "AUX" (CHR <1 .STR>)) 
				 #DECL ((CHR) CHARACTER (STR) STRING)
				 <COND (<MEMQ .CHR "01234567">
					<SET NUM
					     <+ <* .NUM 8>
						<- <ASCII .CHR> <ASCII !\0>>>>)
				       (T <SET ST .STR> <MAPLEAVE>)>>
			 <REST .ST>>
		   <COND (<==? .NUM 128> <SET NUM 0>)
			 (<==? .NUM <ASCII !\:>> <MAPRET "\\;">)>
		   <ASCII .NUM>)
		  (T
		   <SET ST <REST .ST 2>>
		   <COND (<==? .CHR <ASCII 10>> <MAPRET>)
			 (<==? .CHR <ASCII 13>> <MAPRET>)
			 (<==? .CHR !\E> <ASCII 27>)
			 (<==? .CHR !\n> <ASCII 10>)
			 (<==? .CHR !\r> <ASCII 13>)
			 (<==? .CHR !\t> <ASCII 9>)
			 (<==? .CHR !\b> <ASCII 8>)
			 (<==? .CHR !\f> <ASCII 12>)
			 (T .CHR)>)>)
		(<==? <1 .ST> !\^>
		 <SET CHR <2 .ST>>
		 <SET ST <REST .ST 2>>
		 <CHTYPE <ANDB .CHR 31> CHARACTER>)
		(T <SET CHR <1 .ST>> <SET ST <REST .ST>> .CHR)>>>>
	  [.NAME .STDNAME .DSTR]>>>
     <SET ST "">
     <MAPF <>
	   <FUNCTION (STDESC "AUX" DESC) 
		   #DECL ((STDESC) <VECTOR [3 STRING]>)
		   <SET DESC <MAKE-DESC <2 .STDESC> <3 .STDESC> .DESCS>>
		   <WRITE-TTY-DESC <1 .STDESC> .DESC>>
	   .DESCS>
     T)>>

<DEFINE GET-NUM (TARG MAIN "OPTIONAL" (AUX <>) (DEF 0) "AUX" (NUM 0) TS) 
	#DECL ((TARG MAIN) STRING (AUX TS) <OR STRING FALSE> (NUM) FIX)
	<COND (<AND <SET TS <MEMBER .TARG .MAIN>>
		    <==? <NTH .TS <+ <LENGTH .TARG> 1>> !\#>>
	       <SET TS <REST .TS <+ <LENGTH .TARG> 1>>>
	       <MAPF <>
		     <FUNCTION (C) 
			     #DECL ((C) CHARACTER)
			     <COND (<==? .C !\:> <MAPLEAVE>)>
			     <SET NUM
				  <+ <* .NUM 10> <- <ASCII .C> <ASCII !\0>>>>>
		     .TS>
	       .NUM)
	      (.AUX <GET-NUM .TARG .AUX <> .DEF>)
	      (.DEF)>>

<DEFINE GET-STR (TARG MAIN "OPTIONAL" (AUX <>) (DEF <>) "AUX" TS (QUOTE <>)) 
	#DECL ((TARG MAIN) STRING (AUX TS) <OR FALSE STRING>)
	<COND (<SET TS <MEMBER .TARG .MAIN>>
	       <SET TS <REST .TS <LENGTH .TARG>>>
	       <COND (<==? <1 .TS> !\@> "")
		     (T
		      <MAPF ,STRING
			    <FUNCTION (C) 
				    #DECL ((C) CHARACTER)
				    <COND (.QUOTE
					   <SET QUOTE <>>
					   <COND (<==? .C !\;> !\:) (.C)>)
					  (<==? .C <ASCII 92>>
					   <SET QUOTE T>
					   <MAPRET>)
					  (<==? .C !\:> <MAPSTOP>)
					  (.C)>>
			    <REST .TS>>)>)
	      (.AUX <GET-STR .TARG .AUX <> .DEF>)
	      (.DEF)>>

<DEFINE GET-AUX-DESC (NAME DESCS) 
	#DECL ((NAME) STRING
	       (DESCS) <VECTOR [REST <VECTOR STRING STRING STRING>]>)
	<MAPF <>
	      <FUNCTION (DD) <COND (<=? .NAME <1 .DD>> <MAPLEAVE <3 .DD>>)>>
	      .DESCS>>

<SETG OP-VEC
      [[,TTY-FWD GET-TTY-OP ":nd"]
       [,TTY-BCK GET-TTY-BCK]
       [,TTY-UP GET-TTY-OP ":up"]
       [,TTY-DWN GET-TTY-OP ":do"]
       [,TTY-HRZ GET-TTY-OP ":ch" ":cm"]
       [,TTY-VRT GET-TTY-OP ":cv" ":cm"]
       [,TTY-MOV GET-TTY-OP ":cm"]
       [,TTY-HOM GET-TTY-HOME]
       [,TTY-HMD GET-TTY-HOMD]
       [,TTY-CLR GET-TTY-CLR]
       [,TTY-CEW GET-TTY-OP ":cd"]
       [,TTY-CEL GET-TTY-OP ":ce"]
       [,TTY-ERA GET-TTY-ERA]
       [,TTY-BEC GET-TTY-BEC]
       [,TTY-IL GET-TTY-OP ":al"]
       [,TTY-DL GET-TTY-OP ":dl"]
       [,TTY-IC GET-TTY-OP ":ic"]
       [,TTY-DC GET-TTY-OP ":dc"]
       [,TTY-DS GET-TTY-OP ":cs"]
       [,TTY-SU GET-TTY-OP ":sf"]
       [,TTY-SD GET-TTY-OP ":sr"]]>

<GDECL (OP-VEC) <VECTOR [REST VECTOR]>>

<DEFINE MAKE-DESC (STDNAME DESC DESCS
		   "AUX" (CUR-NAME .STDNAME) HEIGHT WIDTH PAD CRPAD LFPAD AUXN
			 (AUX <>) OPS)
	#DECL ((STDNAME DESC) STRING (HEIGHT WIDTH CRPAD LFPAD) FIX
	       (PAD) <OR STRING CHARACTER> (CUR-NAME) <SPECIAL STRING>)
	<COND (<SET AUXN <GET-STR ":tc" .DESC>>
	       <SET AUX <GET-AUX-DESC .AUXN .DESCS>>)>
	<SET HEIGHT <GET-NUM ":li" .DESC .AUX>>
	<SET WIDTH <GET-NUM ":co" .DESC .AUX>>
	<COND (<TYPE? <SET PAD <GET-STR ":pc" .DESC .AUX <ASCII 0>>> STRING>
	       <SET PAD <1 .PAD>>)>
	<SET CRPAD <GET-NUM ":dC" .DESC .AUX 0>>
	<SET LFPAD <GET-NUM ":dN" .DESC .AUX 0>>
	<SET OPS <IVECTOR ,MAX-TTY-OP <>>>
	<MAPF <>
	      <FUNCTION (OD) 
		      #DECL ((OD) <VECTOR FIX ATOM [REST ANY]>)
		      <PUT .OPS
			   <1 .OD>
			   <APPLY ,<2 .OD> .DESC .AUX !<REST .OD 2>>>>
	      ,OP-VEC>
	<CHTYPE [.STDNAME .HEIGHT .WIDTH .PAD .CRPAD .LFPAD .OPS] TTY-DESC>>

<DEFINE GET-TTY-OP (MAIN AUX TARG "OPTIONAL" (OTH <>) "AUX" TS) 
	#DECL ((MAIN TARG) STRING (OTH AUX) <OR STRING FALSE>)
	<COND (<AND <SET TS <GET-STR .TARG .MAIN .AUX <>>> <NOT <EMPTY? .TS>>>
	       <MAKE-OP .TS>)
	      (.OTH <GET-TTY-OP .MAIN .AUX .OTH>)>>

<DEFINE GET-TTY-BCK (MAIN AUX) 
	<COND (<OR <MEMBER ":bs" .MAIN> <MEMBER ":bs" .AUX>>
	       <STRING <ASCII 8>>)
	      (<GET-TTY-OP .MAIN .AUX ":bc">)>>

<DEFINE GET-TTY-CLR (MAIN AUX "AUX" HO CD) 
	<COND (<GET-TTY-OP .MAIN .AUX ":cl">)
	      (<AND <SET HO <GET-TTY-HOME .MAIN .AUX>>
		    <SET CD <GET-TTY-OP .MAIN .AUX ":cd">>>
	       <MERGE-OPS .HO .CD>)>>

<DEFINE GET-TTY-ERA (MAIN AUX "AUX" BS) 
	<COND (<SET BS <GET-TTY-BCK .MAIN .AUX>> <MERGE-OPS .BS " ">)>>

<DEFINE GET-TTY-BEC (MAIN AUX "AUX" BS) 
	<COND (<SET BS <GET-TTY-BCK .MAIN .AUX>>
	       <MERGE-OPS <MERGE-OPS .BS " "> .BS>)>>

<DEFINE GET-TTY-HOME (MAIN AUX "AUX" TS) 
	<COND (<GET-TTY-OP .MAIN .AUX ":ho">)
	      (<SET TS <GET-STR ":cm" .MAIN .AUX <>>> <MAKE-OP .TS 0 0>)>>

<DEFINE GET-TTY-HOMD (MAIN AUX "AUX" TS) 
	<COND (<GET-TTY-OP .MAIN .AUX ":ll">)
	      (<=? .CUR-NAME "VS100"> <>)
	      (<SET TS <GET-STR ":cm" .MAIN .AUX <>>>
	       <MAKE-OP .TS 0 <- <GET-NUM ":li" .MAIN .AUX> 1>>)>>

<DEFINE MERGE-OPS (OP1 OP2) 
	#DECL ((OP1 OP2) <OR STRING TTY-OUT VECTOR TTY-ELT>)
	<COND
	 (<AND <TYPE? .OP1 STRING> <TYPE? .OP2 STRING>> <STRING .OP1 .OP2>)
	 (<AND <TYPE? .OP1 TTY-ELT> <TYPE? .OP2 TTY-ELT>>
	  <CHTYPE [!.OP1 !.OP2] TTY-ELT>)
	 (<AND <TYPE? .OP1 TTY-OUT> <TYPE? .OP2 TTY-OUT>> [.OP1 .OP2 ""])
	 (<AND <TYPE? .OP2 TTY-OUT> <TYPE? .OP1 STRING TTY-ELT>>
	  <COND (<TYPE? <TO-STRING .OP2> STRING>
		 <COND (<TYPE? .OP1 STRING>
			<TO-STRING .OP2 <STRING .OP1 <TO-STRING .OP2>>>)
		       (<TO-STRING .OP2 <CHTYPE [!.OP1 .OP2] TTY-ELT>>)>)
		(T
		 <COND (<TYPE? .OP1 STRING>
			<TO-STRING .OP2
				   <CHTYPE [.OP1 !<TO-STRING .OP2>] TTY-ELT>>)
		       (T
			<TO-STRING .OP2
				   <CHTYPE [!.OP1 !<TO-STRING .OP2>]
					   TTY-ELT>>)>)>)
	 (<AND <TYPE? .OP1 TTY-OUT STRING TTY-ELT>
	       <TYPE? .OP2 TTY-OUT STRING TTY-ELT>>
	  <COND (<AND <TYPE? .OP1 STRING> <TYPE? .OP2 TTY-ELT>>
		 <CHTYPE [.OP1 !.OP2] TTY-ELT>)
		(<AND <TYPE? .OP1 TTY-ELT> <TYPE? .OP2 STRING>>
		 <CHTYPE [!.OP1 .OP2] TTY-ELT>)
		(T [.OP1 .OP2 ""])>)
	 (<AND <TYPE? .OP1 VECTOR> <EMPTY? <NTH .OP1 <LENGTH .OP1>>>>
	  <PUT .OP1
	       <LENGTH .OP1>
	       <COND (<TYPE? .OP2 VECTOR> <2 .OP2>) (.OP2)>>)
	 (<ERROR CANT-MERGE .OP1 .OP2>)>>

<DEFINE MAKE-OP (STR "OPTIONAL" (X <>) (Y <>) "AUX" (PAD 0)) 
	#DECL ((STR) STRING (X Y) <OR FIX FALSE> (PAD) FIX)
	<COND (<EMPTY? .STR>
	       <>)
	      (<MEMQ <1 .STR> "0123456789">
	       <MAPR <>
		     <FUNCTION (ST "AUX" (C <1 .ST>)) 
			     #DECL ((ST) STRING (C) CHARACTER)
			     <COND (<==? .C !\*>
				    <SET PAD <- .PAD>>
				    <SET STR <REST .ST>>
				    <MAPLEAVE>)
				   (<AND <G=? <ASCII .C> <ASCII !\0>>
					 <L=? <ASCII .C> <ASCII !\9>>>
				    <SET PAD
					 <+ <* .PAD 10>
					    <- <ASCII .C> <ASCII !\0>>>>)
				   (T <SET STR .ST> <MAPLEAVE>)>>
		     .STR>)>
	<COND (<EMPTY? .STR> <>)
	      (<==? .PAD 0> <GET-TTY-ELTS .STR .X .Y>)
	      (<G? .PAD 0> <CHTYPE [<GET-TTY-ELTS .STR .X .Y> .PAD] TTY-OUT>)
	      (T
	       ["" <CHTYPE [<GET-TTY-ELTS .STR .X .Y> <- .PAD>] TTY-OUT> ""])>>

<DEFINE GET-TTY-ELTS (STR
		      "OPTIONAL" (X <>) (Y <>)
		      "AUX" (X-FIRST? <>) (FIRST-USED? <>) (LAST-START .STR)
			    (INC? <>) (BCD? <>) TE (SST .STR))
   #DECL ((STR) STRING (LAST-START) <OR STRING FALSE> (TE) VECTOR
	  (BCD? INC? X-FIRST? FIRST-USED?) <OR ATOM FALSE>
	  (X Y) <OR FIX FALSE>)
   <COND
    (<NOT <MEMQ !\% .STR>> .STR)
    (T
     <SET TE
      <MAPF ,VECTOR
       <FUNCTION ("AUX" C ANUM NS) 
	       <COND (<EMPTY? .STR>
		      <COND (<N==? .SST .STR> <MAPSTOP .SST>) (<MAPSTOP>)>)>
	       <COND
		(<N==? <SET C <1 .STR>> !\%> <SET STR <REST .STR>> <MAPRET>)
		(<N==? .SST .STR>
		 <SET NS <SUBSTRUC .SST 0 <- <LENGTH .SST> <LENGTH .STR>>>>
		 <SET SST .STR>
		 <MAPRET .NS>)
		(T
		 <SET C <2 .STR>>
		 <SET STR <REST .STR 2>>
		 <SET SST .STR>
		 <COND (<==? .C !\%> <MAPRET "%">)
		       (<==? .C !\r> <SET X-FIRST? <NOT .X-FIRST?>> <MAPRET>)
		       (<==? .C !\i> <SET INC? T> <MAPRET>)
		       (<==? .C !\B> <SET BCD? T> <MAPRET>)>
		 <COND (.X-FIRST?
			<COND (.FIRST-USED? <SET ANUM ,TTY-Y-POS>)
			      (T <SET FIRST-USED? T> <SET ANUM ,TTY-X-POS>)>)
		       (T
			<COND (.FIRST-USED? <SET ANUM ,TTY-X-POS>)
			      (T <SET FIRST-USED? T> <SET ANUM ,TTY-Y-POS>)>)>
		 <COND (.INC?
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-INC-ARG> FIX>>)>
		 <COND (.BCD?
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-BCD-ARG> FIX>>)>
		 <COND (<==? .C !\d>
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-DECIMAL> FIX>>)
		       (<==? .C !\2>
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-RJD2> FIX>>)
		       (<==? .C !\3>
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-RJD3> FIX>>)
		       (<==? .C !\.>
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-LITERAL> FIX>>)
		       (<==? .C !\+>
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-LIT+> FIX>>
			<SET STR <REST .STR>>
			<SET SST .STR>)
		       (T
			<PRINC "WARNING -- unknown descriptor `">
			<PRINC .C>
			<PRINC "' in ">
			<PRINC .CUR-NAME>
			<CRLF>
			<SET ANUM <CHTYPE <ORB .ANUM ,TTY-UNKNOWN> FIX>>)>
		 <COND (<AND .X <0? <CHTYPE <ANDB .ANUM ,TTY-X/Y> FIX>>>
			<MAPRET <PROCESS-ARG .ANUM .X>>)
		       (<AND .Y <NOT <0? <CHTYPE <ANDB .ANUM ,TTY-X/Y> FIX>>>>
			<MAPRET <PROCESS-ARG .ANUM .Y>>)>
		 .ANUM)>>>>
     <COND (<REPEAT ((TV .TE))
		    <COND (<EMPTY? .TV> <RETURN <>>)
			  (<NOT <TYPE? <1 .TV> STRING>> <RETURN T>)>
		    <SET TV <REST .TV>>>
	    <CHTYPE .TE TTY-ELT>)
	   (<STRING !.TE>)>)>>

<DEFINE PROCESS-ARG (ANUM ARG "AUX" TS) 
	#DECL ((ANUM ARG) FIX (TS) STRING)
	<COND (<NOT <0? <CHTYPE <ANDB .ANUM ,TTY-INC-ARG> FIX>>>
	       <SET ARG <+ .ARG 1>>)>
	<COND (<NOT <0? <CHTYPE <ANDB .ANUM ,TTY-BCD-ARG> FIX>>>
	       <SET ARG <+ <* 16 </ .ARG 10>> <MOD .ARG 10>>>)>
	<SET ANUM <CHTYPE <ANDB .ANUM ,TTY-ARG-DESC> FIX>>
	<COND (<==? .ANUM ,TTY-LITERAL> <STRING <ASCII .ARG>>)
	      (<==? .ANUM ,TTY-LIT+> <STRING <ASCII <+ .ARG 32>>>)
	      (<==? .ANUM ,TTY-DECIMAL> <UNPARSE .ARG>)
	      (<==? .ANUM ,TTY-RJD2> <UNPARSE .ARG>)
	      (<==? .ANUM ,TTY-RJD3> <UNPARSE .ARG>)>>

<ENDPACKAGE>
