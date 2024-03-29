<DEFINE T$HANG ("OPTIONAL" (PRED <>))
  <REPEAT (VAL)
    <COND (<SET VAL <T$EVAL .PRED>>
	   <RETURN .VAL>)>
    <ISYSCALL SIGPAUSE 0>>>

<DEFINE T$JNAME ("OPT" IGN 
		 "AUX" (JCL:<OR FALSE <VECTOR [REST STRING]>> <CALL GETS ARGV>))
   <COND (.JCL
	  <REPEAT ((ST <1 .JCL>) TS)
	     <COND (<SET TS <MEMQ !\/ .ST>>
		    <SET ST <REST .TS>>)
		   (T
		    <COND (<SET TS <MEMQ !\. .ST>>
			   <RETURN <I$STD-STRING .ST T .TS>>)
			  (T
			   <RETURN <I$STD-STRING .ST T>>)>)>>)
	 (T "XMDL")>>

<DEFINE T$SLEEP (TM "OPTIONAL" (PRED <>) "AUX" RTM1 RTM2 UV UVX)
  #DECL ((TM) <OR FIX FLOAT> (RTM1 RTM2) FIX (UVX UV) <UVECTOR [2 FIX]>)
  <COND (<TYPE? .TM FLOAT>
	 <SET RTM1 <FIX .TM>>
	 <SET RTM2 <FIX <* 1000000.0 <- .TM .RTM1>>>>)
	(<SET RTM1 .TM>
	 <SET RTM2 0>)>
  <COND (<NOT <GASSIGNED? UV-2>>
	 <SETG UV-X <IUVECTOR 4 0>>
	 <SETG UV-2 <IUVECTOR 2 0>>)>
  <SET UV ,UV-2>
  <SET UVX ,UV-X>
  <REPEAT (VAL STIME1 STIME2)
    #DECL ((STIME) FIX)
    <COND (<L=? .TM 0> <RETURN T>)>
    <COND (<SET VAL <T$EVAL .PRED>>
	   <RETURN .VAL>)>
    <CALL SYSCALL GETTIMEOFDAY .UV .UVX>
    ; "Get seconds and microseconds of current time; will discard time zone"
    <SET STIME1 <1 .UV>>
    <SET STIME2 <2 .UV>>
    ; "Set up seconds and microseconds of interval"
    <1 .UVX 0>
    <2 .UVX 0>
    <3 .UVX .RTM1>
    <4 .UVX .RTM2>
    <CALL SYSCALL SETITIMER ,ITIMER-REAL .UVX 0>
    <ISYSCALL SIGPAUSE 0>
    <CALL SYSCALL GETTIMEOFDAY .UV .UVX>
    ; "How many seconds left?"
    <SET RTM1 <- .RTM1 <- <1 .UV> .STIME1>>>
    ; "How many microseconds left?"
    <COND (<L? <SET RTM2 <- .RTM2 <- <2 .UV> .STIME2>>> 0>
	   <SET RTM2 <+ .RTM2 1000000>>
	   <SET RTM1 <- .RTM1 1>>)>
    <SET STIME1 <1 .UV>>
    <SET STIME2 <2 .UV>>
    <SET TM <+ <FLOAT .RTM1> </ <FLOAT .RTM2> 1000000.0>>>>>

<DEFINE T$STANDARD-NAME (STR "AUX" (NOCONV? <>) (QUOTE? <>) (QUOTER !\^)) 
   #DECL ((STR) STRING)
   <COND (<EMPTY? .STR> <STRING <ASCII 0>>)
	 (T
	  <MAPR ,STRING
		<FUNCTION (S "AUX" (C <1 .S>) VAL) 
		   #DECL ((S) STRING (C) CHARACTER
			  (VAL) <OR CHARACTER FALSE>)
		   <COND (<==? .C .QUOTER>
			  <COND (<AND <==? .S .STR>
				      <G? <LENGTH .S> 1>
				      <G=? <ASCII <2 .S>> <ASCII !\A>>
				      <L=? <ASCII <2 .S>> <ASCII !\Z>>>
				 <SET NOCONV? T>)
				(<SET QUOTE? T>)>
			  <SET VAL <>>)
			 (<OR .NOCONV? .QUOTE?>
			  <SET QUOTE? <>>
			  <SET VAL .C>)
			 (<AND <G=? <ASCII .C> <ASCII !\A>>
			       <L=? <ASCII .C> <ASCII !\Z>>>
			  <SET VAL
			       <ASCII <+ <- <ASCII .C> <ASCII !\A>>
					 <ASCII !\a>>>>)
			 (<==? .C <ASCII 0>> <SET VAL <>>)
			 (<SET VAL .C>)>
		   <COND (<==? <LENGTH .S> 1>
			  <COND (.VAL <MAPRET .VAL <ASCII 0>>)
				(<MAPRET <ASCII 0>>)>)
			 (T <COND (.VAL <MAPRET .VAL>) (T <MAPRET>)>)>>
		.STR>)>>

<DEFINE I$BMEMQ (CHR STR "OPTIONAL" (NS <REST .STR <LENGTH .STR>>))
  #DECL ((CHR) CHARACTER (STR NS) STRING)
  <REPEAT ()
    <COND (<==? .NS .STR> <RETURN <>>)>
    <SET NS <BACK .NS>>
    <COND (<==? <1 .NS> .CHR>
	   <RETURN .NS>)>>>

<DEFINE I$COMPONENTS (STR STOR DEFAULTS? "AUX" TS TNM1 TNM2)
  #DECL ((STR) STRING (STOR) <PRIMTYPE VECTOR> (DEFAULTS?) <OR ATOM FALSE>
	 (TS TNM1 TNM2) <OR STRING FIX FALSE>)
  <COND (<SET TS <MEMQ !\. .STR>>	; "Has nm1.nm2"
	 <SET TNM2 <STRING <REST .TS>>>	; "Get nm2, whatever it is"
	 <COND (<==? .TS .STR>
		<COND (.DEFAULTS?
		       <COND (<TYPE? <SET TNM1 <X$VALUE? %<P-R "NM1">>>
				     FIX>
			      <SET TNM1 <>>)>)
		      (T
		       <SET TNM1 <>>)>)
	       (T
		<SET TNM1 <I$NEW-STRING .STR .TS>>)>)
	(T
	 <COND (<EMPTY? .STR>
		<COND (.DEFAULTS?
		       <COND (<TYPE? <SET TNM1 <X$VALUE? %<P-R "NM1">>> FIX>
			      <SET TNM1 <>>)>)
		      (<SET TNM1 <>>)>)
	       (<SET TNM1 <STRING .STR>>)>
	 <COND (.DEFAULTS?
		<COND (<TYPE? <SET TNM2 <X$VALUE? %<P-R "NM2">>> FIX>
		       <SET TNM2 <>>)>)
	       (<SET TNM2 <>>)>)>
  <1 .STOR .TNM1>
  <2 .STOR .TNM2>>

<DEFINE I$NEW-STRING (STR1 STR2 "AUX" NS)
  #DECL ((STR1 NS) STRING (STR2) <OR STRING FIX>)
  <COND (<TYPE? .STR2 FIX>
	 <SET NS <ISTRING .STR2>>)
	(T
	 <SET NS <ISTRING <- <LENGTH .STR1> <LENGTH .STR2>>>>)>
  <MAPR <>
    <FUNCTION (S1 S2)
      #DECL ((S1 S2) STRING)
      <1 .S1 <1 .S2>>>
    .NS .STR1>
  .NS>

<DEFINE X$INIT-ENV ("AUX" VEC TMP (TUV <STACK <IUVECTOR 2>>))
  #DECL ((VEC) <VECTOR [REST STRING]> (TMP) <OR STRING FALSE>
	 (TUV) <UVECTOR [REST FIX]>)
  <CALL SYSCALL GETRLIMIT 3 .TUV>
  <SETG I$P1-SIZE <1 .TUV>>
  ; "Get current size of P1, so we can grow it when needed"
  <SETG T$HOME-STRUC <CALL GETS HOMSTR>>
  ; "Structure to look on for TTY descriptors, fbins, etc."
  <SET VEC <CALL GETS ENVIR>>
  <SETG I$ENVVEC .VEC>		       ;"Save vector for later use"
  ; "Sigh.  Dream on..."
  <COND (<SET TMP <T$GET-ENV-STR "CWD" .VEC>>
	 <I$SET-CONNECTED-DIR !<I$CANONICAL-DIR .TMP <>>>)
	(<SETG I$CONNECTED-DIR <>>)>
  <COND (<SET TMP <T$GET-ENV-STR "USER" .VEC>>
	 <SETG I$USER-NAME <I$STD-STRING .TMP <>>>)
	(<SETG I$USER-NAME <>>)>
  <COND (<SET TMP <T$GET-ENV-STR "TERM" .VEC>>
	 <SETG T$TERMNAME <I$STD-STRING .TMP T>>)
	(<SETG T$TERMNAME <>>)>
  <COND (<SET TMP <T$GET-ENV-STR "HOME" .VEC>>
	 <SETG T$HOME-DIR .TMP>)>
  T>

<DEFINE T$GET-ENV-STR (STR "OPTIONAL" (ENV ,I$ENVVEC))
  #DECL ((STR) STRING (ENV) <VECTOR [REST STRING]>)
  <REPEAT (TS)
    <COND (<EMPTY? .ENV> <RETURN <>>)>
    <SET TS <1 .ENV>>
    <COND (<REPEAT ((NS .STR) (NNS .TS))
	     <COND (<EMPTY? .NNS> <RETURN <>>)>
	     <COND (<EMPTY? .NS>
		    <COND (<==? <1 .NNS> !\=>
			   <SET TS <REST .NNS>>
			   <RETURN T>)
			  (<RETURN <>>)>)>
	     <COND (<N==? <1 .NS> <1 .NNS>>
		    <RETURN <>>)>
	     <SET NS <REST .NS>>
	     <SET NNS <REST .NNS>>>
	   <RETURN .TS>)
	  (<SET ENV <REST .ENV>>)>>>

<DEFINE T$UNAME ()
  ,I$USER-NAME>

; "Makes sure connected directory is known, then returns snm part and dev
   part."
<DEFINE T$GET-CONNECTED-DIR GCD ()
  <I$GET-CONNECTED-DIR>
  <MULTI-RETURN .GCD ,I$CDIR ,I$CDEV>>

; "Returns T if still connected to directory we used to be connected to."
<DEFINE I$STILL-CONNECTED? ("AUX" ST INODE DEV)
  #DECL ((ST) STRING (INODE DEV) FIX)
  <SET ST <T$FILE-STAT ". ">>
  <SET INODE <T$STAT-FIELD .ST ,INODE-OFFS ,INODE-SIZE>>
  <SET DEV <T$STAT-FIELD .ST ,DEV-OFFS ,DEV-SIZE>>
  <AND <==? .INODE ,I$CONNECTED-INODE>
       <==? .DEV ,I$CONNECTED-DEV>>>

; "Sets I$CONNECTED-DIR (full directory name), I$CDIR (snm part), I$CDEV
   (dev part), I$CONNECTED-INODE, I$CONNECTED-DEV"
<DEFINE I$SET-CONNECTED-DIR (DIR DEV NAME "AUX" ST)
  <SETG I$CONNECTED-DIR .NAME>
  <SETG I$CONNECTED-INODE
	<T$STAT-FIELD <SET ST <T$FILE-STAT ,I$CONNECTED-DIR>>
		      ,INODE-OFFS, INODE-SIZE>>
  <SETG I$CONNECTED-DEV
	<T$STAT-FIELD .ST ,DEV-OFFS ,DEV-SIZE>>
  <SETG I$CDIR .DIR>
  <SETG I$CDEV .DEV>>

; "Gets actual connected directory, properly split up and such.  Calls
   I$SET-CONNECTED-DIR when done.  If still connected, doesn't do anything."
<DEFINE I$GET-CONNECTED-DIR ()
  <COND (<AND <GASSIGNED? I$CONNECTED-DIR>
	      ,I$CONNECTED-DIR
	      <I$STILL-CONNECTED?>>
	 <COND (<OR <NOT <GASSIGNED? I$CDIR>>
		    <NOT ,I$CDIR>>
		<I$SET-CONNECTED-DIR !<I$CANONICAL-DIR ,I$CONNECTED-DIR T>>)>)
	(T
	 <I$SET-CONNECTED-DIR !<I$CANONICAL-DIR "." <>>>)>>

<DEFINE X$PURCLN ()
  T>

<DEFINE X$VALUE? (ATM "AUX" TS)
  #DECL ((ATM) ATOM (TS) <OR FALSE FIX STRING>)
  <SET TS <COND (<ASSIGNED? .ATM>
		 ..ATM)
		(<GASSIGNED? .ATM>
		 ,.ATM)>>
  <COND (<OR <NOT .TS> <TYPE? .TS FIX> <EMPTY? .TS>> 0)
	(.TS)>>

<DEFINE T$GEN-OPEN (NAME "OPTIONAL" (MODE "READ") (BSZ "ASCII")
		    (DEVNAM <>) "AUX" (NEW? <>) VAL STDNAM (DEVTYP ,DEV-DISK)
		    VEC RES)
  #DECL ((NAME MODE BSZ) STRING (DEVNAM) <OR ATOM FALSE VECTOR>
	 (NEW?) <OR ATOM FALSE>)
  <COND (<=? .MODE "CREATE">
	 <SET NEW? T>)>
  <COND (<SET STDNAM <T$PARSE-FILE-NAME .NAME T T>>
	 <SET NAME <I$STD-STRING .STDNAM T>>
	 <COND (<NOT .DEVNAM>
		<COND (<OR <SET DEVTYP <T$GET-DEVICE-TYPE .STDNAM T>>
			   .NEW?>
		       <COND (<SET VEC <MEMQ .DEVTYP ,T$DEVVEC>>
			      <SET DEVNAM <2 .VEC>>)
			     (<SET DEVNAM %<P-R "DISK">>)>)
		      (<SET RES <I$STD-ERROR .NAME .DEVTYP>>)>)>
	 <COND (<NOT .DEVNAM> .RES)
	       (<NOT <SET VAL
			  <COND (<TYPE? .DEVNAM ATOM>
				 <T$CHANNEL-OPEN .DEVNAM .NAME
						 .MODE .BSZ>)
				(<TYPE? .DEVNAM VECTOR>
				 <T$CHANNEL-OPEN
				  <1 .DEVNAM> .NAME .MODE
				  .BSZ !<REST .DEVNAM>>)>>>
		<I$STD-ERROR .NAME .VAL>)
	       (.VAL)>)
	(<I$STD-ERROR .NAME .STDNAM>)>>

<DEFINE X$IO-INIT ()
  <SETG T$MUDDLE-SYSTEM "U">
  <SETG CRLF-STRING <STRING <ASCII 10>>>
  <SETG CRLF-LENGTH 1>
  <SETG I$RDBLEN <* 4 256>>
  <SETG %<P-R "NM2"> "MUD">
  <SETG %<P-R "DEVVEC"> [,DEV-DISK %<P-R "DISK">
			 ,DEV-BDISK %<P-R "DISK">
			 ,DEV-VDISK %<P-R "DISK">
			 ,DEV-OTHER-DISK %<P-R "DISK">
			 ,DEV-OVDISK %<P-R "DISK">
			 ,DEV-CONSOLE %<P-R "TTY">
			 ,DEV-PTY %<P-R "TTY">
			 ,DEV-TTY %<P-R "TTY">
			 ,DEV-TTYN %<P-R "TTY">
			 ,DEV-NETTTY %<P-R "TTY">
			 ,DEV-DMFTTY %<P-R "TTY">]>
  <SETG I$CHANNEL-TYPES ()>
  ; "Try to fool everybody into thinking ttys exist"
  <T$NEW-CHANNEL-TYPE %<P-R "DEFAULT"> <>
		      T$FILE-HANDLE I$DEF-FILE-HANDLE
		      T$DEV I$DEF-DEV
		      T$SNM I$DEF-SNM
		      T$NM1 I$DEF-NM1
		      T$NM2 I$DEF-NM2
		      T$NAME I$DEF-NAME
		      T$SHORT-NAME I$DEF-SHORT-NAME
		      T$READ-DATE X$DEF-HACK-DATE
		      T$WRITE-DATE X$DEF-HACK-DATE
		      T$GET-MODE X$DEF-GET-MODE
		      T$GET-BYTE-SIZE X$DEF-GET-BYTE-SIZE>
  <SETG I$SBUF1 <ISTRING 1>>
  <SETG %<P-R "DD-DEV"> 2>
  <SETG %<P-R "DD-SNM"> 3>
  <SETG %<P-R "DD-NM1"> 4>
  <SETG %<P-R "DD-NM2"> 5>
  <SETG %<P-R "DD-DSN"> 6>
  <T$NEW-CHANNEL-TYPE T$DISK T$DEFAULT
		      T$OPEN X$DISK-OPEN
		      T$CLOSE X$DISK-CLOSE
		      T$FLUSH X$DISK-FLUSH
		      T$READ-BUFFER X$DISK-READ-BUFFER
		      T$QUERY X$DISK-QUERY
		      T$ACCESS X$DISK-ACCESS
		      T$READ-BYTE X$DISK-READ-BYTE
		      T$BUFOUT X$DISK-BUFOUT
		      T$WRITE-BUFFER X$DISK-WRITE-BUFFER
		      T$WRITE-BYTE X$DISK-WRITE-BYTE
		      T$FILE-LENGTH X$DISK-FILE-LENGTH
		      T$FILE-HANDLE X$DISK-FILE-HANDLE
		      T$PRINT-DATA X$DISK-PRINT-DATA>
  <T$NEW-CHANNEL-TYPE I$UNPARSE <>
		 %<P-R "WRITE-BUFFER"> X$UP-WRITE-BUF
		 %<P-R "WRITE-BYTE"> X$UP-WRITE-BYTE
		 %<P-R "READ-BYTE"> X$UP-READ-BYTE>
  <T$SETG BYTES/WORD 4>
  <SETG BUFLEN 80>
  <SETG SBUFLEN <* ,BYTES/WORD ,BUFLEN>>
  <SETG I$UBUF1 <IUVECTOR 1>>
  <SETG I$STAT-STRING <ISTRING ,STAT-LEN>>
  <SETG I$ERROR-STRINGS <VECTOR "Not file owner or super-user"
				"No such file or directory"
				"No such process"
				"Interrupted system call"
				"Physical I/O error"
				"No such device or address"
				"Arg list too long to EXEC"
				"EXEC format error"
				"Bad file number or wrong mode"
				"No children"
				"No more processes in system"
				"Not enough core in system"
				"File protection violation"
				"Bad address to system call"
				"Block device required"
				"Mount device busy"
				"File already exists"
				"Cross-device link"
				"No such device"
				"Not a directory"
				"Is a directory"
				"Invalid argument"
				"System file table overflow"
				"Too many open files in process"
				"Not a typewriter"
				"Text file busy"
				"File too large"
				"No space left on device"
				"Illegal seek"
				"Read-only file system"
				"Too many links to file"
				"Broken pipe"
				"Math argument out of range"
				"Result too large"
				"Operation would block"
				"Operation now in progress"
				"Operation already in progress"
				"Socket operation on non-socket"
				"Destination address required"
				"Message too long"
				"Protocol wrong type for socket"
				"Bad protocol option"
				"Protocol not supported"
				"Socket type not supported"
				"Operation not suported on socket"
				"Protocol family not supported"
				"Address family not supported by protocol family"
				"Address already in use"
				"Can't assign requested address"
				"Network is down"
				"Network is unreachable"
				"Network dropped connection on reset"
				"Software caused connection abort"
				"Connection reset by peer"
				"No buffer space available"
				"Socket is already connected"
				"Socket is not connected"
				"Can't send after socket shutdown"
				"unused"
				"Connection timed out"
				"Connection refused"
				"Too many levels of symbolic links"
				"File name too long"
				"Directory not empty">>T>

<DEFINE X$IO-LOAD (BOOTYP)
   <T$FLOAD "/USR/MIM/CHANNEL-OPERATION.MSUBR">
   <T$FLOAD "/USR/MIM/HOMEDIR.MSUBR">
   <T$FLOAD "/USR/MIM/TTY.MSUBR">
   <SETG M$$FLATCHAN
		<X$RESET <CHTYPE [I$FLATSIZE <> <> T 0 <>] T$CHANNEL>>>
   <SETG M$$INTCHAN <X$RESET <CHTYPE [I$UNPARSE <> <> T "" <>] T$CHANNEL>>>
   T>

; "Eventually this needs to do something about the name (if that's
   possible).  Note that cretinous UNIX doesn't provide an error-name
   system call."
<DEFINE T$SYS-ERR (NAME ERR "OPTIONAL" (NAME? T))
  #DECL ((NAME) STRING (ERR) <FALSE FIX> (NAME?) <OR ATOM FALSE>)
  <I$STD-ERROR .NAME .ERR .NAME?>>

<DEFINE T$TRANSLATE-ERROR (ERR:<FALSE FIX> "AUX" (EC:FIX <1 .ERR>)
			   (ERRS:VECTOR ,I$ERROR-STRINGS))
   <COND (<G? .EC <LENGTH .ERRS>>
	  "Unknown error")
	 (T
	  <NTH .ERRS .EC>)>>

<DEFINE I$STD-ERROR (NAME ERR "OPTIONAL" (NAME? T)
		     "AUX" ES)
  #DECL ((ES NAME) STRING (ERR) <FALSE FIX> (NAME?) <OR ATOM FALSE>)
  <SET ES <T$TRANSLATE-ERROR .ERR>>
  <COND (.NAME?
	 <SET NAME <I$STD-STRING <T$PARSE-FILE-NAME .NAME T T> T>>)>
  <CHTYPE (.ES .NAME !.ERR) FALSE>>

<DEFINE T$FILE-STAT (FIL "OPTIONAL" (SST ,I$STAT-STRING))
  #DECL ((FIL) <OR STRING FIX> (SST) STRING)
  <COND (<COND (<TYPE? .FIL STRING>
		<CALL SYSCALL STAT .FIL .SST>)
	       (T
		<CALL SYSCALL FSTAT .FIL .SST>)>
	 .SST)>>

<DEFINE T$STAT-FIELD (STR OFFS SIZE)
  #DECL ((STR) STRING (OFFS SIZE) FIX)
  <COND (<==? .SIZE 4>
	 <ORB <NTH .STR .OFFS>
	      <LSH <NTH .STR <+ .OFFS 1>> 8>
	      <LSH <NTH .STR <+ .OFFS 2>> 16>
	      <LSH <NTH .STR <+ .OFFS 3>> 24>>)
	(<==? .SIZE 2>
	 <ORB <NTH .STR .OFFS>
	      <LSH <NTH .STR <+ .OFFS 1>> 8>>)
	(<1? .SIZE>
	 <CHTYPE <NTH .STR .OFFS> FIX>)>>

<DEFINE T$GET-DEVICE-TYPE (FIL "OPTIONAL" (NAME? <>) "AUX" SST)
  #DECL ((FIL) <OR STRING FIX> (NAME?) <OR ATOM FALSE> (SST) <OR FALSE STRING>)
  <COND (<OR <TYPE? .FIL FIX> .NAME?>
	 <SET SST <T$FILE-STAT .FIL>>)
	(<SET SST .FIL>)>
  <COND (.SST
	 <ORB <T$STAT-FIELD .SST ,MAJOR-DEV-OFFS ,MAJOR-DEV-SIZE>
	      <ANDB <T$STAT-FIELD .SST ,MODE-OFFS ,MODE-SIZE> ,FMT-MASK>>)>>

<DEFINE T$GET-BYTE-COUNT (FIL BINARY? "AUX" BC ST)
  #DECL ((FIL) <OR STRING FIX> (BC) FIX (ST) <OR STRING FALSE>
	 (BINARY?) <OR ATOM FALSE>)
  <COND (<SET ST <T$FILE-STAT .FIL>>
	 <SET BC <T$STAT-FIELD .ST ,SIZE-OFFS ,SIZE-SIZE>>
	 <COND (.BINARY?
		</ <+ .BC <- ,BYTES/WORD 1>> ,BYTES/WORD>)
	       (.BC)>)>>
\
<DEFINE T$PARSE-FILE-NAME (STR "OPTIONAL" (DEFAULTS? T) (STD? <>) STOR
			 "AUX" (NS <STACK <IVECTOR 5>>) TS
			 (TDEV <>) (TSNM <>) DT)
  #DECL ((STR) STRING (DEFAULTS?) <OR ATOM FALSE> (STOR NS) <PRIMTYPE VECTOR>
	 (TS) <OR STRING FALSE> (TDEV TSNM) <OR FIX FALSE STRING>)
  <COND (<NOT <ASSIGNED? STOR>>
	 <SET STOR .NS>)>
  <SET TS <T$STANDARD-NAME .STR>>
  <COND (<AND <N==? <SET DT <T$GET-DEVICE-TYPE .TS T>> ,DEV-DISK>
	      .DT
	      <N==? .DT ,DEV-OTHER-DISK>
	      <N==? .DT ,DEV-BDISK>
	      <N==? .DT ,DEV-VDISK>
	      <N==? .DT ,DEV-OVDISK>
	      <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 3> FIX>>
	      <N==? .DT %<CHTYPE ,FMT-IFDIR FIX>>
	      <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 7> FIX>>
	      <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 9> FIX>>
	      <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 15> FIX>>> 
	 <1 .STOR <I$STD-STRING .TS T>>
	 <2 .STOR <>>
	 <3 .STOR <>>
	 <4 .STOR <>>
	 .TS)
	(T
	 <COND (<SET TS <I$BMEMQ !\/ .STR>>
		<SET TS <REST .TS>>)
	       (<SET TS .STR>)>	; "Extract non-directory component"
	 <COND (<AND <NOT <EMPTY? .STR>>
		     <==? .TS <REST .STR>>
		     <==? <1 .STR> !\/>>
		; "Don't have any file name part"
		<SET TS <REST .TS <LENGTH .TS>>>)>
	 <I$COMPONENTS .TS <REST .STOR 2> .DEFAULTS?>	; "Make nm1 and nm2"
	 <COND (<OR <NOT .DEFAULTS?>
		    <TYPE? <SET TDEV <X$VALUE? %<P-R "DEV">>> FALSE FIX>>
		<SET TDEV <>>)>
	 <COND (<OR <NOT .DEFAULTS?>
		    <TYPE? <SET TSNM <X$VALUE? %<P-R "SNM">>> FALSE FIX>>
		<SET TSNM <>>)>
	 ; "Fill in device and directory from arg, directory, dev, snm."
	 <COND (<T$PARSE-DIR .STR .TS .STOR .TDEV .TSNM>
		<COND (.STD?
		       <T$STANDARD-NAME <I$UNPARSE-SPEC .STOR>>)
		      (<I$UNPARSE-SPEC .STOR>)>)>)>>

<DEFINE I$UNPARSE-SPEC (STOR "OPT" (BITS *37*) "AUX" TS)
  #DECL ((STOR) <<PRIMTYPE VECTOR> <OR T$ATOM STRING> <OR T$ATOM STRING FALSE>
			<OR STRING FALSE> <OR STRING FALSE> <OR STRING FALSE>>
	 (TS) <OR T$ATOM STRING FALSE>)
  <STRING <COND (<OR <TYPE? <SET TS <1 .STOR>> T$ATOM>
		     <0? <ANDB .BITS *20*>>>
		 ; "Don't include leading / if device not requested"
		 "")
		(<OR <EMPTY? .TS>
		     <N==? <1 .TS> !\/>>
		 !\/)
		(T
		 "")>
	  <COND (<AND <TYPE? .TS T$ATOM>
		      <NOT <0? <ANDB .BITS *30*>>>>
		 <I$STD-STRING <5 .STOR> T>)
		(<NOT <0? <ANDB .BITS *20*>>>
		 .TS)
		("")>
	  <COND (<OR <TYPE? <SET TS <2 .STOR>> ATOM FALSE>
		     <0? <ANDB .BITS *10*>>
		     <EMPTY? <1 .STOR>>
		     <AND <NOT <EMPTY? .TS>> <==? <1 .TS> !\/>>>
		 "")
		(!\/)>
	  <COND (<AND <TYPE? .TS STRING>
		      <NOT <EMPTY? .TS>>
		      <NOT <0? <ANDB .BITS *10*>>>>
		 .TS)
		("")>
	  <COND (<AND <OR <3 .STOR> <4 .STOR>>
		      <NOT <0? <ANDB .BITS 6>>>
		      <NOT <0? <ANDB .BITS *30*>>>>
		 "/")
		("")>
	  <COND (<OR <NOT <3 .STOR>>
		     <0? <ANDB .BITS 4>>> "")
		(<3 .STOR>)>
	  <COND (<AND <4 .STOR>
		      <NOT <0? <ANDB .BITS 2>>>> ".")
		("")>
	  <COND (<OR <NOT <4 .STOR>>
		     <0? <ANDB .BITS 2>>> "")
		(<4 .STOR>)>>>

; "Called with beginning of name string, name string rested to just
   past last /, 5-tuple, default dev and snm.  Maybe return <>, sometimes.
   Call with <> <> .STOR <> <> to force breakup of directory name into
   components; name is <5 .STOR>."
<DEFINE T$PARSE-DIR I$DIRACT (STR TS STOR TDEV TSNM "AUX" (FORCE? <>)
			RSNM RDEV TEMP TEMP2 USER DT RSTR FOO)
  #DECL ((STR TS) <OR STRING FALSE> (STOR) <PRIMTYPE VECTOR> (FOO RSTR) STRING
	 (TEMP2 TEMP TDEV TSNM) <OR STRING FALSE> (I$DIRACT) <SPECIAL FRAME>
	 (DT) <OR FIX FALSE> (FORCE?) <OR ATOM FALSE>)
  <COND (.STR
	 <COND (<AND <==? <LENGTH .STR> 1>
		     <==? <1 .STR> !\/>>
		; "Allow opening of /"
		<SET TS <REST .STR <LENGTH .STR>>>)
	       (<AND <==? .STR .TS>
		     <NOT <EMPTY? .TS>>
		     <==? <1 .TS> !\/>>
		<SET TS <REST .TS>>)
	       (<AND <N==? .STR .TS>
		     <==? <1 <SET FOO <BACK .TS>>> !\/>>
		<SET TS <BACK .TS>>)>
	 <SET RSTR <T$STANDARD-NAME <I$NEW-STRING .STR .TS>>>)
	(T
	 <SET RSTR <5 .STOR>>
	 <SET FORCE? T>)>
  <COND (<OR <EMPTY? .RSTR>
	     <AND <==? <LENGTH .RSTR> 1>
		  <==? <1 .RSTR> <ASCII 0>>>>
	 ; "User didn't supply directory, use default"
	 <COND (<OR <NOT .TDEV> <NOT .TSNM>>
		<I$GET-CONNECTED-DIR>
		<COND (<NOT .TDEV>
		       <SET TDEV ,I$CDEV>)>
		<COND (<NOT .TSNM>
		       <SET TSNM ,I$CDIR>)>
		<COND (<NOT <OR .TDEV .TSNM>>
		       <5 .STOR ,I$CONNECTED-DIR>)>)>
	 <1 .STOR .TDEV>
	 <2 .STOR .TSNM>)
	(T
	 <COND (<==? <1 .RSTR> !\~>	; "Home directory hack?"
		<SET RSTR <REST .RSTR>>
		<SET TEMP <MEMQ !\/ .RSTR>>
		<SET USER <I$NEW-STRING .RSTR .TEMP>>
		<COND (<SET TEMP2 <T$GET-HOME-DIR .USER T>>
		       <SET RSTR <STRING .TEMP2 .TEMP>>)
		      (T
		       ; "Couldn't find home directory"
		       <RETURN .TEMP2 .I$DIRACT>)>)>
	 <COND (<AND <N==? <SET DT <T$GET-DEVICE-TYPE .RSTR T>> ,DEV-DISK>
		     .DT
		     <N==? .DT ,DEV-OTHER-DISK>
		     <N==? .DT ,DEV-BDISK>
		     <N==? .DT ,DEV-OVDISK>
		     <N==? .DT ,DEV-VDISK>
		     <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 3> FIX>>
		     <N==? .DT %<CHTYPE ,FMT-IFDIR FIX>>
		     <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 7> FIX>>
		     <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 9> FIX>>
		     <N==? .DT %<CHTYPE <ORB ,FMT-IFDIR 15> FIX>>>
		<1 .STOR <I$STD-STRING .RSTR T>>
		<2 .STOR <>>)
	       (<AND <NOT .FORCE?>
		     <NOT <SET TEMP <MEMQ !\. .RSTR>>>
		     <==? <1 .RSTR> !\/>>
		; "No other funniness, just return.  Break down later,
		   if requested."
		<5 .STOR .RSTR>
		<1 .STOR T>
		<2 .STOR T>)
	       (T
		<I$SET-STUFF .STOR !<I$CANONICAL-DIR .RSTR T>>)>)>>

<DEFINE I$SET-STUFF (STOR SNM DEV STR)
  #DECL ((STOR) <PRIMTYPE VECTOR>)
  <5 .STOR .STR>
  <1 .STOR .DEV>
  <2 .STOR .SNM>>

<DEFINE I$CANONICAL-DIR CD (STR STANDARD? "AUX" DEV DIR TS)
  #DECL ((DEV DIR STR) STRING (STANDARD?) <OR ATOM FALSE>
	 (TS) <OR STRING FALSE>)
  <COND (<EMPTY? .STR>
	 <SET STR ". ">
	 <SET STANDARD? T>)>
  <COND (<OR <MEMQ !\. .STR>
	     <N==? <1 .STR> !\/>>	; "Hair required"
	 <COND (<SET TS <I$CANONICAL-NAME .STR .STANDARD?>>
		<SET STANDARD? T>
		<SET STR .TS>)
	       (<ASSIGNED? I$DIRACT>
		<RETURN .TS .I$DIRACT>)
	       (<RETURN .TS .CD>)>)>
  <COND (<NOT .STANDARD?>
	 <SET STR <T$STANDARD-NAME .STR>>)>
  <REPEAT ((CDEV <T$STAT-FIELD <T$FILE-STAT .STR> ,DEV-OFFS ,DEV-SIZE>)
	   (RDEV <T$STAT-FIELD <T$FILE-STAT "/ "> ,DEV-OFFS ,DEV-SIZE>)
	   TS (TDEV -1) (RS <REST .STR <LENGTH .STR>>))
    #DECL ((TDEV CDEV RDEV) FIX (TS) <OR FALSE STRING>)
    <COND (<AND <SET TS <I$BMEMQ !\/ .STR .RS>>
		<N==? .TS .STR>>
	   <1 .TS <ASCII 0>>
	   <SET TDEV <T$STAT-FIELD <T$FILE-STAT .STR> ,DEV-OFFS ,DEV-SIZE>>
	   <1 .TS !\/>
	   <COND (<N==? .TDEV .CDEV>
		  <COND (<EMPTY? .RS>
			 <SET DEV "">
			 <SET DIR <I$STD-STRING <REST .STR> T <- <LENGTH .STR> 2>>>)
			(T
			 <SET DIR <I$STD-STRING <REST .RS> T <- <LENGTH .RS> 2>>>
			 <SET DEV <I$STD-STRING <REST .STR> T
						<- <LENGTH .STR> <LENGTH .RS> 1>>>)>
		  <RETURN>)>
	   <SET RS .TS>)
	  (<N==? .RDEV .TDEV>
	   ; "Handle /usr/taa, where /usr and /usr/taa are on same device,
	      but /usr is root of a filesystem"
	   <COND (<EMPTY? .RS>
		  <SET DEV "">
		  <SET DIR <I$STD-STRING <REST .STR> T
					 <- <LENGTH .STR> 2>>>)
		 (T
		  <SET DIR <I$STD-STRING <REST .RS> T <- <LENGTH .RS> 2>>>
		  <SET DEV <I$STD-STRING <REST .STR> T
					 <- <LENGTH .STR> <LENGTH .RS> 1>>>)>
	   <RETURN>)
	  (T
	   <SET DEV "">
	   <SET DIR <I$STD-STRING <REST .STR> T <- <LENGTH .STR> 2>>>
	   <RETURN>)>>
  <MULTI-RETURN .CD .DIR .DEV .STR>>

<DEFINE I$CANONICAL-NAME CN (STR STANDARD? "AUX" SINODE (CURR? <>)
			     TEMP (DOT ". ") (DOTDOT ".. ") (RNAM "/ ")
			     (L ()) STAT RINO RDEV INO DDEV
			     (ERR? T))
  #DECL ((STAT STR) STRING (STANDARD?) <OR ATOM FALSE>
	 (SINODE INO DDEV RINO RDEV) FIX
	 (L) <LIST [REST <OR STRING CHARACTER>]> (ERR?) <OR ATOM FALSE>)
  <COND (<OR <=? .STR ".">
	     <=? .STR .DOT>>
	 <SET CURR? T>)>
  <COND (<NOT .STANDARD?>
	 <SET STR <T$STANDARD-NAME .STR>>)>
  <COND (<NOT .CURR?>
	 <I$GET-CONNECTED-DIR>		; "Make sure we have it"
	 <COND (<NOT <SET TEMP <CALL SYSCALL CHDIR .STR>>>
		<RETURN .TEMP .CN>)>)>
  <COND (<NOT <GASSIGNED? I$DIR-BLOCK>>
	 <SETG I$DIR-BLOCK <ISTRING ,DIRBLKSIZ <ASCII 0>>>
	 <SETG I$NAM-BLOCK <ISTRING ,MAXNAMLEN <ASCII 0>>>)>
  <SET STAT <T$FILE-STAT .RNAM>>
  <SET RINO <T$STAT-FIELD .STAT ,INODE-OFFS ,INODE-SIZE>>
  <SET RDEV <T$STAT-FIELD .STAT ,DEV-OFFS ,DEV-SIZE>>
  <SET STAT <T$FILE-STAT .DOT>>
  <SET INO <T$STAT-FIELD .STAT ,INODE-OFFS ,INODE-SIZE>>
  <SET DDEV <T$STAT-FIELD .STAT ,DEV-OFFS ,DEV-SIZE>>
  <COND (<AND <==? .RINO .INO>
	      <==? .RDEV .DDEV>>
	 ; "Return immediately if looking at root"
	 <SET STR .RNAM>)
	(T
	 <REPEAT OUTLOOP (CH NINO NDDEV (DB ,I$DIR-BLOCK) DIFF?)
	   #DECL ((DDEV NINO) FIX (CH) <OR FIX FALSE> (DB STAT) STRING
		  (DIFF?) <OR ATOM FALSE>)
	   <COND (<SET CH <CALL SYSCALL OPEN .DOTDOT ,O-RDONLY 0>>
		  ; "Read the inode and device for the superior directory"
		  <SET NINO <T$STAT-FIELD <SET STAT <T$FILE-STAT .CH>>
					  ,INODE-OFFS ,INODE-SIZE>>
		  <SET NDDEV <T$STAT-FIELD .STAT ,DEV-OFFS ,DEV-SIZE>>
		  ; "And connect to it"
		  <CALL SYSCALL CHDIR .DOTDOT>
		  ; "If just changed devices, extra hair needed."
		  <COND (<==? .NDDEV .DDEV>
			 <SET DIFF? <>>)
			(<SET DIFF? T>)>
		  ; "Grovel through superior, looking for inferior's name"
		  <REPEAT (TS CT)
		    #DECL ((CT) <OR FIX FALSE>)
		    ; "Read a directory block"
		    <SET CT <CALL SYSCALL READ .CH .DB ,DIRBLKSIZ>>
		    <COND (<OR <NOT .CT> <L? .CT ,DIRBLKSIZ>>
			   <CALL SYSCALL CLOSE .CH>
			   <COND (.CT
				  <SET CT
				       #FALSE ("Directory has no superior?")>)>
			   <RETURN .CT .CN>)>
		    ; "Compare inodes, possibly devices.  In 4.2, probably more
		       than one file in directory block."
		    <COND
		     (<REPEAT ((DDB .DB) TINO NAMLEN RECLEN NNM)
		        #DECL ((DDB) STRING)
			<COND (<EMPTY? .DDB> <RETURN>)>
			<SET TINO <T$STAT-FIELD .DDB ,INODE-START ,INODE-LEN>>
			; "Pick up first inode #"
			<SET RECLEN <T$STAT-FIELD .DDB ,RECLEN-START ,RECLEN-LEN>>
			; "Length of this entry"
			<SET NAMLEN <T$STAT-FIELD .DDB ,NAMLEN-START ,NAMLEN-LEN>>
			; "Length of name in this entry"
			<SET NNM <REST .DDB ,NAME-START>>
			<COND (<COND (<NOT .DIFF?>
				      <==? .TINO .INO>)
				     (T
				      <AND <==? .INO
						<T$STAT-FIELD
						 <SET STAT
						      <T$FILE-STAT
						       ; "NAME IS NULL-TERMINATED"
						       .NNM>>
						 ,INODE-OFFS ,INODE-SIZE>>
					   <==? .DDEV
						<T$STAT-FIELD .STAT
							      ,DEV-OFFS
							      ,DEV-SIZE>>>)>
			       ; "Have name from superior"
			       <SET TS <MEMQ <ASCII 0> .NNM>>
			       ; "Cons onto list, close directory, return."
			       <SET L (!\/ <I$NEW-STRING .NNM .TS> !.L)>
			       <CALL SYSCALL CLOSE .CH>
			       <RETURN T>)>
			<COND (<EMPTY? <SET DDB <REST .DDB .RECLEN>>>
			       ; "Are we through with this block?"
			       <RETURN <>>)>>
		      ; "Now looking at superior"
		      <COND (<AND <==? .NINO .RINO>
				  <==? .NDDEV .RDEV>>
			     ; "Superior is root, no need to look further"
			     <RETURN T .OUTLOOP>)>
		      <SET INO .NINO>
		      <SET DDEV .NDDEV>
		      <RETURN>)>>)
		 (T
		  <SET ERR? .CH>
		  <RETURN>)>>
	 <SET STR <T$STRING !.L <ASCII 0>>>)>
  <COND (.CURR?
	 <CALL SYSCALL CHDIR .STR>)
	(<CALL SYSCALL CHDIR ,I$CONNECTED-DIR>)>
  <COND (.ERR?
	 .STR)>>

<DEFINE I$STD-STRING (STR RAISE? "OPTIONAL" (ES? <REST .STR <LENGTH .STR>>))
  #DECL ((STR) STRING (RAISE?) <OR ATOM FALSE> (ES?) <OR STRING FIX>)
  <COND (<TYPE? .ES? FIX>
	 <SET ES? <REST .STR .ES?>>)>
  <MAPR ,STRING
    <FUNCTION (SS "AUX" (C <1 .SS>) (A <ASCII .C>))
      #DECL ((C) CHARACTER (A) FIX)
      <COND (<OR <0? .A> <==? .ES? .SS>> <MAPSTOP>)
	    (.RAISE?
	     <COND (<AND <G=? .A <ASCII !\a>>
			 <L=? .A <ASCII !\z>>>
		    <ASCII <+ .A <- <ASCII !\A> <ASCII !\a>>>>)
		   (<AND <G=? .A <ASCII !\A>>
			 <L=? .A <ASCII !\Z>>>
		    <MAPRET !\^ .C>)
		   (.C)>)
	    (.C)>>
    .STR>>

<DEFINE T$RENAME (OLD NEW "AUX" ONAME NNAME VAL)
  #DECL ((OLD NEW) STRING (ONAME NNAME) <OR STRING FALSE>)
  <COND (<AND <SET VAL <SET ONAME <T$PARSE-FILE-NAME .OLD T T>>>
	      <SET VAL <SET NNAME <T$PARSE-FILE-NAME .NEW T T>>>
	      <SET VAL <CALL SYSCALL RENAME .ONAME .NNAME>>>
	 <I$STD-STRING .NNAME T>)
	(T
	 <I$STD-ERROR .OLD .VAL>)>>

<DEFINE T$DELFILE (NM "OPTIONAL" (T$NM1 <X$VALUE? T$NM1>)
		   (T$NM2 <X$VALUE? T$NM2>) (T$DEV <X$VALUE? T$DEV>)
		   (T$SNM <X$VALUE? T$SNM>) "AUX" NAME VAL)
  #DECL ((NM) STRING (T$NM1 T$NM2 T$DEV T$SNM) <SPECIAL <OR STRING FIX>>)
  <COND (<SET NAME <T$PARSE-FILE-NAME .NM T T>>
	 <COND (<SET VAL <CALL SYSCALL UNLINK .NAME>>
		.NM)
	       (<I$STD-ERROR .NM .VAL>)>)
	(<I$STD-ERROR .NM .NAME>)>>

<DEFINE T$FILE-EXISTS? (NAME "OPTIONAL" (T$NM1 <X$VALUE? T$NM1>)
			(T$NM2 <X$VALUE? T$NM2>)(T$DEV <X$VALUE? T$DEV>)
			(T$SNM <X$VALUE? T$SNM>) "AUX" FID NN)
  #DECL ((NAME) STRING (T$NM1 T$NM2 T$DEV T$SNM) <SPECIAL <OR STRING FIX>>)
  <COND (<SET NN <T$PARSE-FILE-NAME .NAME T T>>
	 <COND (<SET FID <CALL SYSCALL ACCESS .NN ,F-OK>>
		T)
	       (T
		<I$STD-ERROR .NAME .FID>)>)
	(<I$STD-ERROR .NAME .NN>)>>
