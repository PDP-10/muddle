<PACKAGE "ITIME">

<ENTRY ITIME QTIME LTIME ETIME BTIME IDAY TIME-ZONE DAY DAY-PART TIME-PART
       STIME DTIME>

<SETG TM-SECONDS 1>
<SETG TM-MICRO 2>
<SETG TZ-MINUTES 1>
<SETG TZ-DST 2>
<MANIFEST TM-SECONDS TM-MICRO TZ-MINUTES TZ-DST>

<SETG DAY *200000*>

<SETG MONTHS '["JAN" "FEB" "MAR" "APR" "MAY" "JUN" "JUL" 
               "AUG" "SEP" "OCT" "NOV" "DEC"]>
<GDECL (MONTHS) <VECTOR [REST STRING]>>
<SETG TIME-STRING <ISTRING 22 !\ >>
<GDECL (TIME-STRING) STRING>

<DEFINE DTIME ("OPT" (F <ITIME>) (DS ,TIME-STRING) "AUX" (DL ,TIME-LIST) L T S)
        #DECL ((F) <OR FIX FALSE> (DS) STRING (DL) !<LIST [2 LIST] STRING>
               (L) !<LIST [3 FIX]> (T) FIX (S) STRING)
        <COND (<NOT .F> <SET F <ITIME>>)>
        <COND (<G=? <LENGTH .DS> 22>
               <SET DS <REST .DS <- <LENGTH .DS> 22>>>
               <LTIME .F .DL>
               <SET L <1 .DL>>
               <SET T <3 .L>>
               <1 .DS <CHTYPE <+ </ .T 10> %<ASCII !\0>> CHARACTER>>
               <2 .DS <CHTYPE <+ <MOD .T 10> %<ASCII !\0>> CHARACTER>>
               <3 .DS !\ >
               <SET S <NTH ,MONTHS <2 .L>>>
               <4 .DS <1 .S>>
               <5 .DS <2 .S>>
               <6 .DS <3 .S>>
               <7 .DS !\ >
               <SET T <1 .L>>
               <8 .DS <CHTYPE <+ </ .T 10> %<ASCII !\0>> CHARACTER>>
               <9 .DS <CHTYPE <+ <MOD .T 10> %<ASCII !\0>> CHARACTER>>
               <10 .DS !\ >
               <SET L <2 .DL>>
               <SET T <1 .L>>
               <11 .DS <CHTYPE <+ </ .T 10> %<ASCII !\0>> CHARACTER>>
               <12 .DS <CHTYPE <+ <MOD .T 10> %<ASCII !\0>> CHARACTER>>
               <13 .DS !\:>
               <SET T <2 .L>>
               <14 .DS <CHTYPE <+ </ .T 10> %<ASCII !\0>> CHARACTER>>
               <15 .DS <CHTYPE <+ <MOD .T 10> %<ASCII !\0>> CHARACTER>>
               <16 .DS !\:>
               <SET T <3 .L>>
               <17 .DS <CHTYPE <+ </ .T 10> %<ASCII !\0>> CHARACTER>>
               <18 .DS <CHTYPE <+ <MOD .T 10> %<ASCII !\0>> CHARACTER>>
               <19 .DS !\ >
               <SET S <3 .DL>>
               <20 .DS <1 .S>>
               <21 .DS <2 .S>>
               <22 .DS <3 .S>>
               .DS)>>

<DEFINE DAY-PART (DT "OPT" D)
	#DECL ((DT D) FIX)
	<COND (<NOT <ASSIGNED? D>> <LHW .DT>)
	      (ELSE <ORB <LSH .D 16> <ANDB .DT *177777*>>)>>

<DEFINE TIME-PART (DT "OPT" T)
	#DECL ((DT T) FIX)
	<COND (<NOT <ASSIGNED? T>> <ANDB .DT *177777*>)
	      (ELSE <ORB <ANDB .DT *37777600000*> <ANDB .T *177777*>>)>>

<SETG TIME-LIST ((0 0 0) (0 0 0) "EST")>
<GDECL (TIME-LIST) <LIST LIST LIST STRING>>

<DEFINE LTIME ("OPTIONAL" (FF <ITIME>) (LST ,TIME-LIST))
	#DECL ((VALUE LST) <LIST [2 LIST] STRING>
	       (FF) <OR FIX UVECTOR>)
	<COND (<TYPE? .FF UVECTOR>
	       <ETIME <1 .FF> <2 .FF> .LST>)
	      (ELSE <ETIME .FF>)>>

<DEFINE ETIME ("OPTIONAL" (FF <ITIME>) Z (LST ,TIME-LIST)
	       "AUX" F S D LY? Y M (DATE <1 .LST>) (TIME <2 .LST>))
	#DECL ((VALUE LST) <LIST [2 LIST] STRING> (F D S Y M Z) FIX
	       (FF) <OR FIX UVECTOR> (LY?) <OR ATOM FALSE>
	       (DATE TIME) <LIST [3 FIX]>)
	<SET F <COND (<TYPE? .FF FIX> .FF) (ELSE <1 .FF>)>>
	<PUT .LST
	     3
	     <COND (<ASSIGNED? Z> <TIME-ZONE .Z>)
		   (<TYPE? .FF FIX>
		    <TIME-ZONE <SET Z <TIME-ZONE <> .FF>>>)
		   (ELSE <TIME-ZONE <SET Z <2 .FF>> <1 .FF>>)>>
	<COND (<NOT <0? <ANDB .Z *200000*>>>
	       <SET Z <- .Z 1>>)>
	<SET F <- .F <* <ANDB .Z *77*> </ ,DAY 24>>>>
	<SET D <+ <DAY-PART .F> 366 365>>
	<SET Y <+ 68 <* 4 </ .D <+ 366 365 365 365>>>>>
	<SET D <MOD .D <+ 366 365 365 365>>>
	<COND (<SET LY? <L? <SET D <- .D 366>> 0>> <SET D <+ .D 366>>)
	      (<AND <SET Y <+ .Y 1>> <L? <SET D <- .D 365>> 0>>
	       <SET D <+ .D 365>>)
	      (<AND <SET Y <+ .Y 1>> <L? <SET D <- .D 365>> 0>>
	       <SET D <+ .D 365>>)
	      (ELSE <SET Y <+ .Y 1>>)>
	<PUT .DATE 1 .Y>
	<SET M 1>
	<MAPF <>
	      <FUNCTION (N) 
		   #DECL ((N) FIX)
		   <COND (<AND .LY? <==? .N 28>> <SET N 29>)>
		   <COND (<L? <- .D .N> 0>
			  <PUT .DATE 2 .M>
			  <PUT .DATE 3 <+ 1 .D>>
			  <MAPLEAVE>)
			 (ELSE <SET D <- .D .N>> <SET M <+ .M 1>>)>>
	      '![31 28 31 30 31 30 31 31 30 31 30 31!]>
	<SET S <QTIME <TIME-PART .F>>>
	<PUT .TIME 1 </ .S 3600>>
	<SET S <MOD .S 3600>>
	<PUT .TIME 2 </ .S 60>>
	<PUT .TIME 3 <MOD .S 60>>
	.LST>

\

<DEFINE TIME-ZONE ("OPTIONAL" (Z <>) TIM
		   "AUX" (ZL ,ZONELIST) ZS IZ (UV ,ZONE-UV))
	#DECL ((Z) <OR FIX STRING FALSE> (ZL) VECTOR (IZ) FIX
	       (ZS) <OR FALSE VECTOR>
	       (UV) <UVECTOR [3 FIX]>)
	<COND (<OR <NOT .Z> <NOT <ASSIGNED? TIM>>>
	       <DO-FTIME .UV>
	       <SET IZ </ <TZ-MINUTES .UV> 60>>
	       <COND (<NOT <ASSIGNED? TIM>>
	              <SET TIM <ITIME>>)>)>
	<COND (<AND <G? <TZ-DST .UV> 0> <IN-DST? .TIM .IZ>>
	       <SET IZ <ORB .IZ *200000*>>)>
	<COND (<NOT .Z> .IZ)
	      (<TYPE? .Z FIX>
	       <COND (<SET ZS <MEMQ .Z .ZL>> <1 <BACK .ZS>>)
		     (ELSE .IZ)>)
	      (<SET ZS <MEMBER .Z .ZL>> <2 .ZS>)
	      (ELSE #FALSE ("Unknown time zone"))>>

"IN-DST? - are we in daylight savings time"

<DEFINE IN-DST? (F Z "AUX" Y M D LY? DOW)
	#DECL ((F Z Y M D DOW) FIX)
	<SET F <- .F <+ <* <ANDB .Z *77*> 2> </ ,DAY 24>>>>
	<SET D <+ <LHW .F> 366 365>>
	<SET Y <+ 68 <* 4 </ .D <+ 366 365 365 365>>>>>
	<SET D <MOD .D <+ 366 365 365 365>>>
	<COND (<SET LY? <L? <SET D <- .D 366>> 0>> <SET D <+ .D 366>>)
	      (<AND <SET Y <+ .Y 1>> <L? <SET D <- .D 365>> 0>>
	       <SET D <+ .D 365>>)
	      (<AND <SET Y <+ .Y 1>> <L? <SET D <- .D 365>> 0>>
	       <SET D <+ .D 365>>)
	      (ELSE <SET Y <+ .Y 1>>)>
	<SET M 1>
	<MAPF <>
	      <FUNCTION (N) 
		   #DECL ((N) FIX)
		   <COND (<AND .LY? <==? .N 28>> <SET N 29>)>
		   <COND (<L? <- .D .N> 0>
			  <SET D <+ 1 .D>>
			  <MAPLEAVE>)
			 (ELSE <SET D <- .D .N>> <SET M <+ .M 1>>)>>
	      '![31 28 31 30 31 30 31 31 30 31 30 31!]>
	<COND (<AND <G? .M 4> <L? .M 10>> T)
	      (<OR <==? .M 4> <==? .M 10>>
	       <SET DOW <IDAY .F>>
	       <SET DOW
		    <COND (<==? .DOW 6> -7)
			  (T <- .DOW 6>)>>
	       <COND (<==? .M 4>
		      <L? <+ 30 .DOW> .D>)
		     (<==? .M 10>
		      <G? <+ 31 .DOW> .D>)>)>>

<DEFINE DO-FTIME (UV)
	<CALL SYSCALL GETTIMEOFDAY ,TIME-UV .UV>>

<DEFINE DO-TIME () <CALL SYSCALL GETTIMEOFDAY ,TIME-UV ,ZONE-UV>>

<SETG TIME-UV <UVECTOR 0 0>>
<SETG ZONE-UV <UVECTOR 0 0>>
<GDECL (TIME-UV ZONE-UV) UVECTOR>

<SETG ZONELIST
      '["EST" 5 "EDT" *200005*
	"CST" 6 "CDT" *200006*
	"MST" 7 "MDT" *200007*
	"PST" 8 "PDT" *200010*
	"YST" 9 "YDT" *200011*
	"HST" 10 "HDT" *200012*
	"BST" 11 "BDT" *200013*
	"AST" 4 "ADT" *200004*
	"NST" 3
	"GMT" 0]>

<GDECL (ZONELIST) <VECTOR [REST STRING FIX]>>

\

<DEFINE BTIME ("OPTIONAL" (Y 0) (M 1) (D 1) (HH 0) (MM 0) (SS 0)
	       "AUX" S (LOSSAGE ,LOSSAGE) Z)
	#DECL ((VALUE Y M D HH MM SS Z) FIX (LOSSAGE) <UVECTOR [REST FIX]>)
	<COND (<L? .Y 0> 
	       <DO-TIME>
	       <SET S <TM-SECONDS ,TIME-UV>>
	       <SET Y </ .S %<* 365 24 60 60>>>)
	      (<G=? .Y 1970> <SET Y <- .Y 1970>>)
	      (<G=? .Y 70> <SET Y <- .Y 70>>)>
	<SET D
	     <+ <* .Y 365>
		</ <+ .Y 1> 4>
		<COND (<AND <0? <MOD <+ .Y 2> 4>> <G? .M 2>> 1)
		      (ELSE 0)>
		<NTH .LOSSAGE .M>
		.D
		-1>>
	<SET HH <+ .HH <SET Z <ANDB <TIME-ZONE> 63>>>>
	<SET HH <- .HH <LHW .Z>>>
	<ORB <LSH .D 16> <STIME <+ .SS <* .MM 60> <* .HH 3600>>>>>

<SETG LOSSAGE '![0 31 59 90 120 151 181 212 243 273 304 334]>

\

<DEFINE ITIME ("AUX" S)
	#DECL ((S) FIX)
	<DO-TIME>
	<SET S <TM-SECONDS ,TIME-UV>>
	<ORB <LSH </ .S %<* 24 60 60>> 16>
	     <STIME <MOD .S %<* 24 60 60>>>>>

"STIME - convert seconds to fraction of day"

<DEFINE STIME (T)
	#DECL ((T) FIX)
	<ANDB <FIX </ <* <FLOAT .T> *200000*> %<* 24 3600>>>
	      *177777*>>

"QTIME - convert fraction of day to seconds"

<DEFINE QTIME (T)
	#DECL ((T) FIX)
	<FIX </ <* <FLOAT <ANDB .T *177777*>> %<* 24 3600>>
	        *200000*>>>

"IDAY - day of week, MON=0, SUN=6"

<DEFINE IDAY ("OPTIONAL" (T <ITIME>))
	#DECL ((T) FIX)
	<MOD <+ <LHW .T> 3> 7>>

<ENDPACKAGE>
