<DEFINE X$DISK-OPEN DO (STYPE:ATOM OPR NAME:STRING MODS:STRING
			"OPTIONAL" (BYTES:STRING "ASCII")
		     (BUF?:<OR ATOM FALSE> T) (THAWED? <>) (NO-REF? <>)
		     "AUX" (NEW?:<OR ATOM FALSE> <>) (APP?:<OR ATOM FALSE> <>)
		     	   MODE:FIX JFN:<OR FIX FALSE> BINARY?:<OR ATOM FALSE>
			   (BYTE?:<OR ATOM FALSE> <>) NNAME:STRING PTR:FIX
			   (STOR:<PRIMTYPE VECTOR> <ITUPLE 5 <>>)
			   (STATUS 0) BUF)
  ; "THAWED? and NO-REF? are no-ops, due to the lossages of unix"
  <COND (<=? .MODS "READ">
	 <SET MODE ,O-RDONLY>
	 <SET STATUS <ORB .STATUS ,STATUS-READ>>)
	(<=? .MODS "CREATE">
	 <SET NEW? T>
	 <SET STATUS <ORB ,STATUS-NEW ,STATUS-WRITE ,STATUS-RACC>>
	 <SET MODE <+ ,O-RDWR ,O-CREAT ,O-EXCL>>)
	(<=? .MODS "MODIFY">
	 <SET STATUS <ORB ,STATUS-WRITE ,STATUS-RACC>>
	 <SET MODE ,O-RDWR>)
	(<=? .MODS "APPEND">
	 <SET APP? T>
	 <SET STATUS ,STATUS-WRITE>
	 <SET MODE <+ ,O-RDWR ,O-APPEND>>)
	(T
	 <ERROR %<P-E "ILLEGAL-MODE"> .MODS X$DISK-OPEN>)>
  <COND (<=? .BYTES "ASCII">
	 <SET BINARY? <>>
	 <SET STATUS <PUTLHW .STATUS ,BS-ASCII>>)
	(<=? .BYTES "8BIT">
	 <SET BINARY? <>>
	 <SET BYTE? T>
	 <SET STATUS <PUTLHW .STATUS ,BS-8BIT>>)
	(<=? .BYTES "BINARY">
	 <SET STATUS <PUTLHW .STATUS ,BS-BINARY>>
	 <SET BINARY? T>)
	(T
	 <ERROR %<P-E "ILLEGAL-BYTE-SIZE"> .BYTES X$DISK-OPEN>)>
  <SET NAME <T$PARSE-FILE-NAME .NAME <> T .STOR>>
  <SET JFN <>>
  <COND (.NEW?
	 <COND (<NOT <SET JFN
			  <CALL SYSCALL OPEN .NAME .MODE
				%<ORB ,FM-OWN-READ ,FM-OWN-WRITE
				  ,FM-GRP-READ ,FM-GRP-WRITE
				  ,FM-OTHER-READ ,FM-OTHER-WRITE>>>>
		; "Try to make shiny new file; come here if failed"
		<COND (<==? <1 .JFN> ,EEXIST>
		       ; "Failed because file already exists"
		       <SET NNAME <I$MAKE-BACKUP-NAME .NAME>>
		       <CALL SYSCALL RENAME .NAME .NNAME>
		       <SET STATUS <ORB .STATUS ,STATUS-RENAME>>
		       <SET JFN <CALL SYSCALL OPEN .NAME
					     .MODE
					     %<ORB ,FM-OWN-READ ,FM-OWN-WRITE
					       ,FM-OWN-XCT ,FM-GRP-READ
					       ,FM-GRP-WRITE ,FM-GRP-XCT
					       ,FM-OTHER-READ ,FM-OTHER-WRITE
					       ,FM-OTHER-XCT>>>)>)>
	 <COND (<NOT .JFN>
		<RETURN .JFN .DO>)>)>
  <COND (<OR .JFN
	     <SET JFN <CALL SYSCALL OPEN .NAME .MODE 0>>>
	 <CHTYPE [.JFN
		  !.STOR
		  .STATUS
		  .MODE
		  .BINARY?
		  <COND (.APP?
			 <SET PTR <CALL SYSCALL LSEEK .JFN 0 ,WHENCE-EOF>>
			 <COND (.BINARY?
				; "If appending in binary mode, maybe fill
				   last word of file out with 0's."
				<COND (<NOT <0? <MOD .PTR ,BYTES/WORD>>>
				       <CALL SYSCALL WRITE .JFN
					     %<ISTRING ,BYTES/WORD <ASCII 0>>
					     <- ,BYTES/WORD
						<MOD .PTR ,BYTES/WORD>>>)>
				<SET PTR </ <+ .PTR <- ,BYTES/WORD 1>>
					     ,BYTES/WORD>>)>
			 .PTR)
			(<SET PTR 0>)>
		  .PTR
		  <SET BUF
		   <COND (.BUF?
			  <T$REQUEST-BUFFER <> <COND (.BINARY? UVECTOR)
						     (.BYTE? BYTES)
						     (T STRING)>
					    <>>)>>
		  .BUF
		  0
		  0
		  <>]
		 I$DISK-CHANNEL>)>>

<DEFINE I$MAKE-BACKUP-NAME (NAME:STRING "AUX" NNAME:STRING TN:STRING NLEN:FIX)
  <SET TN <OR <REST <I$BMEMQ !\/ .NAME>> .NAME>>
  <SET NLEN <MIN %<+ ,MAXNAMLEN 1> <+ <LENGTH .TN> %<LENGTH ".bak">>>>
  <SET NNAME <ISTRING <+ <- <LENGTH .NAME> <LENGTH .TN>> .NLEN>>>
  <SUBSTRUC .NAME 0 <LENGTH .NAME> .NNAME>
  <SET TN <REST .NNAME <- <LENGTH .NNAME> %<+ <LENGTH ".bak"> 1>>>>
  <SUBSTRUC ".bak" 0 4 .TN>
  <PUT .NNAME <LENGTH .NNAME> <ASCII 0>>>

<DEFINE X$DISK-FILE-HANDLE (CHANNEL:T$CHANNEL OPR
			    "AUX" (DATA:I$DISK-CHANNEL
				   <T$CHANNEL-DATA .CHANNEL>))
  <NS-JFN .DATA>>

<DEFINE X$DISK-QUERY (CHANNEL OPR BIT "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>))
  #DECL ((CHANNEL) T$CHANNEL (BIT) FIX (DATA) I$DISK-CHANNEL)
  <COND (<==? .BIT ,T$BIT-ACCESS>
	 T)>>

<DEFINE X$DISK-CLOSE (CHANNEL OPER "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)) 
	#DECL ((CHANNEL) T$CHANNEL (DATA) I$DISK-CHANNEL)
	<I$FLUSH-BUFFER .DATA>
	<COND (<NS-BUF .DATA>
	       <T$RELEASE-BUFFER <NS-BUF .DATA>>)>
	<CALL SYSCALL CLOSE <NS-JFN .DATA>>
	<NS-JFN .DATA -1>>

<DEFINE X$DISK-READ-BYTE (CHANNEL OPER
		       "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)
		       (BUF <NS-BUF .DATA>) (PT <ANDB <CALL TYPE .BUF> ,M$$TYSAT>)
		       BYTE BC)
	#DECL ((CHANNEL) T$CHANNEL (DATA) I$DISK-CHANNEL
	       (BUF) <OR BYTES STRING FALSE UVECTOR> (BC) FIX)
	<COND (<NOT .BUF>
	       <COND (<AND <SET BC
			    <X$DISK-READ-BUFFER .CHANNEL .OPER
						<SET BUF
						 <COND (<NS-BINARY? .DATA>
							,I$UBUF1)
						       (,I$SBUF1)>>>>
			   <NOT <0? .BC>>>
		      <1 .BUF>)>)
	      (T
	       <PROG ((ONCE? <>))
		     #DECL ((ONCE?) <OR ATOM FALSE>)
		     <COND (<NOT <0? <SET BC <NS-BC .DATA>>>>
			    <SET BYTE <1 .BUF>>
			    <NS-PTR .DATA <+ <NS-PTR .DATA> 1>>
			    <NS-BUF .DATA <CASE ,==? .PT
						(,M$$T-STR
						 <REST <CHTYPE .BUF STRING>>)
						(,M$$T-UVC
						 <REST <CHTYPE .BUF UVECTOR>>)
						(,M$$T-BYT
						 <REST <CHTYPE .BUF BYTES>>)>>
			    <NS-BC .DATA <- .BC 1>>
			    .BYTE)
			   (.ONCE? <>)
			   (<I$READ-BUFFER .DATA>
			    <SET BUF <NS-BUF .DATA>>
			    <SET ONCE? T>
			    <AGAIN>)>>)>>

<DEFINE I$READ-BUFFER (DATA
		     "AUX" (JFN <NS-JFN .DATA>) CT (OB <NS-BUF .DATA>)
			   (BUF <NS-TBUF .DATA>)
			   STS)
	#DECL ((DATA) I$DISK-CHANNEL (STS CT) <OR FIX FALSE> (JFN) FIX
	       (OB BUF) <OR BYTES UVECTOR STRING>)
	<COND (<NS-WRITE-BUF? .DATA> <I$FLUSH-BUFFER .DATA>)>
	<COND (<NOT <SET CT <CALL SYSCALL READ .JFN .BUF
				  <COND (<TYPE? .BUF STRING><LENGTH .BUF>)
					(<TYPE? .BUF BYTES> <LENGTH .BUF>)
					(<* ,BYTES/WORD <LENGTH .BUF>>)>>>>
	       <ERROR %<P-E "ERROR-ON-READ"> .CT I$READ-BUFFER>)>
	<COND (<NS-BINARY? .DATA>
	       <SET CT </ <+ .CT <- ,BYTES/WORD 1>> ,BYTES/WORD>>)>
	<NS-BUF .DATA .BUF>
	<NS-SPTR .DATA <+ <NS-SPTR .DATA> .CT>>
	<NS-BC .DATA .CT>
	<NS-OBC .DATA .CT>>

<DEFINE X$DISK-READ-BUFFER (CHANNEL OPER BUFFER
			 "OPTIONAL" CT
			 (CONT 0)
			 "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)
			       (IBUF <NS-BUF .DATA>) (TIBUF <NS-TBUF .DATA>)
			       (TRANS 0) BC RD RTRANS
			       (PT <ANDB <CALL TYPE .BUFFER> ,M$$TYSAT>))
	#DECL ((CHANNEL) T$CHANNEL (BUFFER) <OR <PRIMTYPE BYTES>
						<PRIMTYPE STRING>
						<PRIMTYPE UVECTOR>>
	       (CT CONT) FIX 
	       (DATA) I$DISK-CHANNEL (IBUF) <OR BYTES STRING UVECTOR FALSE>
	       (BC) FIX (RD TRANS) <OR FIX FALSE>)
	<COND (<AND .IBUF <N==? <ANDB <CALL TYPE .IBUF> ,M$$TYSAT> .PT>>
	       ; "Can't use buffer, since wrong type"
	       <SET IBUF <>>
	       <I$FLUSH-BUFFER .DATA>)>
	<COND (<NOT <ASSIGNED? CT>>
	       <SET CT <CASE ,==? .PT
			     (,M$$T-STR <LENGTH <CHTYPE .BUFFER STRING>>)
			     (,M$$T-UVC <LENGTH <CHTYPE .BUFFER UVECTOR>>)
			     (,M$$T-BYT <LENGTH <CHTYPE .BUFFER BYTES>>)>>)>
	<REPEAT ((RD 0))
		#DECL ((RD) FIX)
		<COND
		 (<AND .IBUF <NOT <0? <SET BC <NS-BC .DATA>>>>>
		  <SET TRANS <MIN .BC .CT>>
		  <CASE ,==? .PT
		   (,M$$T-STR
		    <SUBSTRUC .IBUF:<PRIMTYPE STRING>
			      0 .TRANS .BUFFER:<PRIMTYPE STRING>>
		    <NS-BUF .DATA <REST .IBUF:<PRIMTYPE STRING> .TRANS>>
		    <SET BUFFER <REST .BUFFER:<PRIMTYPE STRING> .TRANS>>)
		   (,M$$T-BYT
		    <SUBSTRUC .IBUF:<PRIMTYPE BYTES>
			      0 .TRANS .BUFFER:<PRIMTYPE BYTES>>
		    <NS-BUF .DATA <REST .IBUF:<PRIMTYPE BYTES> .TRANS>>
		    <SET BUFFER <REST .BUFFER:<PRIMTYPE BYTES> .TRANS>>)
		   (,M$$T-UVC
		    <SUBSTRUC .IBUF:<PRIMTYPE UVECTOR>
			      0 .TRANS .BUFFER:<PRIMTYPE UVECTOR>>
		    <NS-BUF .DATA <REST .IBUF:<PRIMTYPE UVECTOR> .TRANS>>
		    <SET BUFFER <REST .BUFFER:<PRIMTYPE UVECTOR> .TRANS>>)>)>
		<SET RD <+ .RD .TRANS>>
		<SET CT <- .CT .TRANS>>
		<NS-BC .DATA <- .BC .TRANS>>
		<NS-PTR .DATA <+ <NS-PTR .DATA> .TRANS>>
		<COND (<NOT <0? .CT>>
		     ;"Only use the buffer here if it might save a system call"
		       <COND (<AND .IBUF
				   <L? .CT <CASE ,==? .PT
						 (,M$$T-STR
						  <LENGTH <CHTYPE .TIBUF
								  STRING>>)
						 (,M$$T-BYT
						  <LENGTH <CHTYPE .TIBUF
								  BYTES>>)
						 (,M$$T-UVC
						  <LENGTH <CHTYPE .TIBUF
								  UVECTOR>>)>>>
			      <I$READ-BUFFER .DATA>
			      <COND (<0? <NS-BC .DATA>>
				     <RETURN .RD>)>
			      <SET IBUF <NS-BUF .DATA>>)
			     (<SET TRANS
				   <CALL SYSCALL READ
					 <NS-JFN .DATA>
					 .BUFFER
					 <COND (<==? .PT 6>
						<* .CT ,BYTES/WORD>)
					       (.CT)>>>
			      <SET RTRANS .TRANS>
			      <COND (<==? .PT 6>
				     <SET TRANS </ <+ .TRANS <- ,BYTES/WORD 1>>
						   ,BYTES/WORD>>
				     <COND (<NS-BINARY? .DATA>
					    <SET RTRANS .TRANS>)>)>
			      <NS-PTR .DATA <+ <NS-PTR .DATA> .RTRANS>>
			      <NS-SPTR .DATA <+ <NS-SPTR .DATA> .RTRANS>>
			      ; "Don't get ACCESS confused--make sure he
				 knows there's nothing in the channel buffer
				 in this case."
			      <NS-OBC .DATA 0>
			      <COND (.IBUF <NS-BUF .DATA .TIBUF>)>
			      <RETURN <+ .TRANS .RD>>)
			     (<RETURN .TRANS>)>)
		      (<RETURN .RD>)>>>

<DEFINE X$DISK-WRITE-BYTE (CHANNEL OPER BYTE
			"AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)
			      (BUF <NS-BUF .DATA>) (PT <ANDB <CALL TYPE .BUF>
							     ,M$$TYSAT>)
			      (TBUF <NS-TBUF .DATA>))
	#DECL ((CHANNEL) T$CHANNEL (BYTE) <OR FIX CHARACTER>
	       (DATA) I$DISK-CHANNEL
	       (BUF) <OR FALSE BYTES STRING UVECTOR>)
	<COND (<0? <ANDB <NS-MODE .DATA> ,O-RDWR>>
	       <ERROR %<P-E "CHANNEL-NOT-OPEN-FOR-WRITING">
		      .CHANNEL X$DISK-WRITE-BYTE>)>
	<COND (<NOT .BUF>
	       <COND (<NS-BINARY? .DATA>
		      <SET BUF ,I$UBUF1>
		      <1 .BUF .BYTE>)
		     (T
		      <SET BUF ,I$SBUF1>
		      <1 .BUF .BYTE>)>
	       <CALL SYSCALL WRITE <NS-JFN .DATA> .BUF
		     <COND (<TYPE? .BUF UVECTOR>
			    ,BYTES/WORD)
			   (1)>>
	       <NS-PTR .DATA <+ <NS-PTR .DATA> 1>>
	       <NS-SPTR .DATA <+ <NS-SPTR .DATA> 1>>
	       .BYTE)
	      (T
	       <COND (<CASE ,==? .PT
			    (,M$$T-STR <EMPTY? .BUF:<PRIMTYPE STRING>>)
			    (,M$$T-BYT <EMPTY? .BUF:<PRIMTYPE BYTES>>)
			    (,M$$T-UVC <EMPTY? .BUF:<PRIMTYPE UVECTOR>>)>
		      <I$FLUSH-BUFFER .DATA>
		      <SET BUF <NS-BUF .DATA>>)>
	       <CASE ,==? .PT
		     (,M$$T-STR
		      <1 .BUF:<PRIMTYPE STRING> .BYTE>
		      <NS-BUF .DATA <SET BUF <REST .BUF:<PRIMTYPE STRING>>>>
		      <NS-OBC .DATA
			      <MAX <NS-OBC .DATA>
				   <- <LENGTH
				       .TBUF:<PRIMTYPE STRING>>
				      <LENGTH .BUF:<PRIMTYPE STRING>>>>>)
		     (,M$$T-BYT
		      <1 .BUF:<PRIMTYPE BYTES> .BYTE>
		      <NS-BUF .DATA <SET BUF <REST .BUF:<PRIMTYPE BYTES>>>>
		      <NS-OBC .DATA
			      <MAX <NS-OBC .DATA>
				   <- <LENGTH
				       .TBUF:<PRIMTYPE BYTES>>
				      <LENGTH .BUF:<PRIMTYPE BYTES>>>>>)
		     (,M$$T-UVC
		      <1 .BUF:<PRIMTYPE UVECTOR> .BYTE>
		      <NS-BUF .DATA <SET BUF <REST .BUF:<PRIMTYPE UVECTOR>>>>
		      <NS-OBC .DATA
			      <MAX <NS-OBC .DATA>
				   <- <LENGTH
				       .TBUF:<PRIMTYPE UVECTOR>>
				      <LENGTH .BUF:<PRIMTYPE UVECTOR>>>>>)>
	       <NS-PTR .DATA <+ <NS-PTR .DATA> 1>>
	       <NS-WRITE-BUF? .DATA T>
	       <NS-BC .DATA <MAX 0 <- <NS-BC .DATA> 1>>>
	       .BYTE)>>

<DEFINE I$FLUSH-BUFFER (DATA
		      "AUX" (BUF <NS-BUF .DATA>) LEN SP (JFN <NS-JFN .DATA>)
			    (PT <ANDB <CALL TYPE .BUF> ,M$$TYSAT>) TB)
	#DECL ((DATA) I$DISK-CHANNEL (BUF) <OR BYTES UVECTOR STRING FALSE>
	       (JFN SP LEN) FIX)
	<COND (<NS-WRITE-BUF? .DATA>
	       <NS-WRITE-BUF? .DATA <>>
	       <COND (.BUF
		      <SET SP <- <NS-PTR .DATA>
				 <CASE ,==? .PT
				  (,M$$T-STR <- <LENGTH
						 <SET TB
						      <NS-TBUF .DATA>:STRING>>
						<LENGTH
						 .BUF:<PRIMTYPE STRING>>>)
				  (,M$$T-BYT
				   <- <LENGTH
				       <SET TB
					    <NS-TBUF .DATA>:BYTES>>
				      <LENGTH .BUF:<PRIMTYPE BYTES>>>)
				  (,M$$T-UVC
				   <- <LENGTH
				       <SET TB
					    <NS-TBUF .DATA>:UVECTOR>>
				      <LENGTH .BUF:<PRIMTYPE UVECTOR>>>)>>>
		      <COND (<N==? <NS-SPTR .DATA> .SP>
			     <COND (<NS-BINARY? .DATA>
				    <CALL SYSCALL LSEEK .JFN
					  <* .SP ,BYTES/WORD>
					  ,WHENCE-ABS>)
				   (<CALL SYSCALL LSEEK .JFN
					  .SP ,WHENCE-ABS>)>
			     <NS-SPTR .DATA .SP>)>
		      <SET LEN <NS-OBC .DATA>>
		      <COND (<N==? .PT ,M$$T-UVC>
			     <CALL SYSCALL WRITE .JFN .TB .LEN>)
			    (<CALL SYSCALL WRITE .JFN .TB
				   <* .LEN ,BYTES/WORD>>)>
		      <SET SP <+ .LEN <NS-SPTR .DATA>>>
		      <COND (<N==? .SP <NS-PTR .DATA>>
			     <SET SP <NS-PTR .DATA>>
			     <NS-SPTR .DATA .SP>
			     <CALL SYSCALL LSEEK .JFN
				   <COND (<NS-BINARY? .DATA>
					  <* ,BYTES/WORD .SP>)
					 (.SP)> ,WHENCE-ABS>)
			    (<NS-SPTR .DATA .SP>)>
		      <NS-BUF .DATA .TB>
		      <NS-BC .DATA 0>
		      <NS-OBC .DATA 0>)>)
	      (T
	       <COND (<N==? <NS-PTR .DATA> <NS-SPTR .DATA>>
		      <CALL SYSCALL LSEEK .JFN
			    <COND (<NS-BINARY? .DATA>
				   <* ,BYTES/WORD <NS-PTR .DATA>>)
				  (<NS-PTR .DATA>)>
			    ,WHENCE-ABS>)>
	       <NS-SPTR .DATA <NS-PTR .DATA>>
	       <NS-BC .DATA 0>
	       <NS-OBC .DATA 0>
	       <COND (.BUF <NS-BUF .DATA <NS-TBUF .DATA>>)>)>>

<DEFINE X$DISK-WRITE-BUFFER (CHANNEL OPER BUFFER
			  "OPTIONAL" LEN
			  "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>) RVAL
				(IBUF <NS-BUF .DATA>) (JFN <NS-JFN .DATA>)
				VAL TIB (PT <ANDB <CALL TYPE .BUFFER> ,M$$TYSAT>))
   #DECL ((CHANNEL) T$CHANNEL (BUFFER) <OR <PRIMTYPE UVECTOR> <PRIMTYPE STRING>
					   <PRIMTYPE BYTES>>
	  (JFN LEN) FIX
	  (DATA) I$DISK-CHANNEL (IBUF) <OR BYTES UVECTOR STRING FALSE>
	  (VAL) <OR FALSE FIX> (TIB) FIX)
   <COND (<0? <ANDB <NS-MODE .DATA> ,O-RDWR>>
	  <ERROR %<P-E "CHANNEL-NOT-OPEN-FOR-WRITING">
		 .CHANNEL X$DISK-WRITE-BYTE>)>
   <COND (<NOT <ASSIGNED? LEN>>
	  <SET LEN
	       <CASE ,==? .PT
		     (,M$$T-STR
		      <LENGTH .BUFFER:<PRIMTYPE STRING>>)
		     (,M$$T-BYT
		      <LENGTH .BUFFER:<PRIMTYPE BYTES>>)
		     (,M$$T-UVC
		      <LENGTH .BUFFER:<PRIMTYPE UVECTOR>>)>>)>
   <COND (<OR <NOT .IBUF>
	      <N==? .PT <ANDB <CALL TYPE .IBUF> ,M$$TYSAT>>>
	  <COND (.IBUF
		 <I$FLUSH-BUFFER .DATA>)>
	  <COND (<SET VAL <CALL SYSCALL WRITE .JFN .BUFFER
				<COND (<==? .PT 6> <* ,BYTES/WORD .LEN>)
				      (.LEN)>>>
		 <SET RVAL .VAL>
		 <COND (<==? .PT 6>
			; "If we wrote out a uvector, get length right"
			<SET VAL </ .VAL ,BYTES/WORD>>
			<COND (<NS-BINARY? .DATA>
			       ; "but if not a binary channel, pointer
				  will still be in characters instead
				  of words"
			       <SET RVAL .VAL>)>)>
		 <NS-PTR .DATA <+ <NS-PTR .DATA> .RVAL>>
		 <NS-SPTR .DATA <+ <NS-SPTR .DATA> .RVAL>>)>)
	 (T
	  <CASE ,==? .PT
		(,M$$T-STR
		 <SET TIB <LENGTH <NS-TBUF .DATA>:STRING>>)
		(,M$$T-BYT
		 <SET TIB <LENGTH <NS-TBUF .DATA>:BYTES>>)
		(,M$$T-UVC
		 <SET TIB <LENGTH <NS-TBUF .DATA>:UVECTOR>>)>
	  <REPEAT ((RD 0) TRANS (IBUF .IBUF) IL)
		  #DECL ((RD TRANS) FIX (IBUF) <OR BYTES STRING UVECTOR>)
		  <SET IL <CALL LENU .IBUF>>
		  <COND (<AND <NOT <AND <==? .IL .TIB>
					<G=? .LEN .IL>>>
			      ; "If buffer is empty, and long transfer,
				 don't put any of it in buffer"
			      <NOT <CASE ,==? .PT
				    (,M$$T-STR
				     <EMPTY? .IBUF:<PRIMTYPE STRING>>)
				    (,M$$T-BYT
				     <EMPTY? .IBUF:<PRIMTYPE BYTES>>)
				    (,M$$T-UVC
				     <EMPTY? .IBUF:<PRIMTYPE UVECTOR>>)>>>
			 <CASE ,==? .PT
			       (,M$$T-STR
				<SET TRANS <MIN .LEN .IL>>
				<SUBSTRUC .BUFFER:<PRIMTYPE STRING> 0
					  .TRANS .IBUF:<PRIMTYPE STRING>>
				<SET BUFFER
				     <REST .BUFFER:<PRIMTYPE STRING> .TRANS>>
				<SET IL <LENGTH
					 <SET IBUF <REST
						    .IBUF:<PRIMTYPE STRING>
						    .TRANS>>>>)
			       (,M$$T-BYT
				<SET TRANS <MIN .LEN .IL>>
				<SUBSTRUC .BUFFER:<PRIMTYPE BYTES> 0 .TRANS
					  .IBUF:<PRIMTYPE BYTES>>
				<SET BUFFER <REST .BUFFER:<PRIMTYPE BYTES>
						  .TRANS>>
				<SET IL <LENGTH
					 <SET IBUF <REST .IBUF:<PRIMTYPE BYTES>
							 .TRANS>>>>)
			       (,M$$T-UVC
				<SET TRANS <MIN .LEN .IL>>
				<SUBSTRUC .BUFFER:<PRIMTYPE UVECTOR> 0 .TRANS
					  .IBUF:<PRIMTYPE UVECTOR>>
				<SET BUFFER <REST .BUFFER:<PRIMTYPE UVECTOR>
						  .TRANS>>
				<SET IL <LENGTH
					 <SET IBUF <REST
						    .IBUF:<PRIMTYPE UVECTOR>
						    .TRANS>>>>)>
			 <SET RD <+ .RD .TRANS>>
			 <SET LEN <- .LEN .TRANS>>
			 <NS-WRITE-BUF? .DATA T>
			 <NS-BUF .DATA .IBUF>
			 <NS-PTR .DATA <+ <NS-PTR .DATA> .TRANS>>
			 <NS-BC .DATA <MAX 0 <- <NS-BC .DATA> .TRANS>>>
			 <NS-OBC .DATA
				 <MAX <NS-OBC .DATA>
				      <- .TIB .IL>>>)>
		  <COND (<NOT <0? .LEN>>
			 <COND (<N==? .IL .TIB> <I$FLUSH-BUFFER .DATA>)>
			 <COND (<G=? .LEN .TIB>
				<SET TRANS
				     <CALL SYSCALL WRITE .JFN .BUFFER
					   <COND (<NS-BINARY? .DATA>
						  <* ,BYTES/WORD .LEN>)
						 (.LEN)>>>
				<COND (<NS-BINARY? .DATA>
				       <SET TRANS </ .TRANS ,BYTES/WORD>>)>
				<NS-SPTR .DATA <+ <NS-SPTR .DATA> .TRANS>>
				<NS-PTR .DATA <+ <NS-PTR .DATA> .TRANS>>
				<RETURN <+ .TRANS .RD>>)
			       (<SET IBUF <NS-BUF .DATA>>)>)
			(<RETURN .RD>)>>)>>

<DEFINE X$DISK-ACCESS (CHANNEL OPER "OPTIONAL" PTR
		    "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>) (JFN <NS-JFN .DATA>)
			  (OPTR <NS-PTR .DATA>) (BUF <NS-BUF .DATA>) INC TL L
			  (PT <ANDB <CALL TYPE .BUF> ,M$$TYSAT>) TB)
	#DECL ((CHANNEL) T$CHANNEL (DATA) I$DISK-CHANNEL
	       (TL L OPTR JFN INC) FIX (PTR) <OR FIX FALSE>)
	<COND (.BUF
	       <CASE ,==? .PT
		     (,M$$T-STR
		      <SET L <LENGTH <CHTYPE .BUF STRING>>>
		      <SET TL <LENGTH <SET TB <CHTYPE <NS-TBUF .DATA>
						      STRING>>>>)
		     (,M$$T-BYT
		      <SET L <LENGTH <CHTYPE .BUF BYTES>>>
		      <SET TL <LENGTH <SET TB <CHTYPE <NS-TBUF .DATA>
						      BYTES>>>>)
		     (,M$$T-UVC
		      <SET L <LENGTH <CHTYPE .BUF UVECTOR>>>
		      <SET TL <LENGTH
			       <SET TB <CHTYPE <NS-TBUF .DATA> UVECTOR>>>>)>)>
	<COND (<OR <NOT <ASSIGNED? PTR>>
		   <NOT .PTR>>
	       <SET PTR .OPTR>)
	      (<==? .PTR .OPTR>)
	      (<AND .BUF
		    <G=? .PTR <- .OPTR <- .TL .L>>>
		    <L=? .PTR <+ .OPTR <NS-BC .DATA>>>>
	       <COND (<G? .PTR .OPTR>
		      <NS-BC .DATA <- <NS-BC .DATA> <SET INC <- .PTR .OPTR>>>>
		      <CASE ,==? .PT
			    (,M$$T-STR
			     <NS-BUF .DATA <REST <CHTYPE .BUF STRING> .INC>>)
			    (,M$$T-BYT
			     <NS-BUF .DATA <REST <CHTYPE .BUF BYTES> .INC>>)
			    (,M$$T-UVC
			     <NS-BUF .DATA
				     <REST <CHTYPE .BUF UVECTOR> .INC>>)>)
		     (T
		      <NS-BUF .DATA <CALL BACKU .BUF <SET INC <- .OPTR .PTR>>>>
		      <NS-BC .DATA <+ <NS-BC .DATA> .INC>>)>
	       <NS-PTR .DATA .PTR>)
	      (T
	       <I$FLUSH-BUFFER .DATA>
	       <SET PTR
		    <COND (<==? .PTR -1>
			   <CALL SYSCALL LSEEK .JFN 0 ,WHENCE-EOF>)
			  (<CALL SYSCALL LSEEK
				 .JFN <COND (<NS-BINARY? .DATA>
					     <* ,BYTES/WORD .PTR>)
					    (.PTR)>
				 ,WHENCE-ABS>)>>
	       <COND (<NS-BINARY? .DATA>
		      <SET PTR </ .PTR ,BYTES/WORD>>)>
	       <NS-PTR .DATA .PTR>
	       <NS-SPTR .DATA .PTR>)>
	.PTR>

<DEFINE X$DISK-BUFOUT (CHANNEL OPER "OPTIONAL" (FORCE? T)
		       "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>)) 
	#DECL ((CHANNEL) T$CHANNEL (DATA) I$DISK-CHANNEL
	       (FORCE?) <OR ATOM FALSE>)
	<COND (<NS-WRITE-BUF? .DATA>
	       <I$FLUSH-BUFFER .DATA>
	       <CALL SYSCALL FSYNC <NS-JFN .DATA>>)>>

<DEFINE X$DISK-FILE-LENGTH (CHANNEL OPER
			    "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>))
	#DECL ((CHANNEL) T$CHANNEL (DATA) I$DISK-CHANNEL)
	<T$GET-BYTE-COUNT <NS-JFN .DATA> <NS-BINARY? .DATA>>>

<DEFINE X$DISK-PRINT-DATA (CHANNEL OPER OUTCHAN
			  "AUX" (DATA <T$CHANNEL-DATA .CHANNEL>) BUF)
  #DECL ((CHANNEL) T$CHANNEL (DATA) I$DISK-CHANNEL)
  <PRINC "#DISK-CHANNEL [">
  <PRINC "JFN:">
  <PRIN1 <NS-JFN .DATA>>
  <PRINC " MODE:">
  <PRIN1 <NS-MODE .DATA>>
  <PRINC " BIN?:">
  <PRIN1 <NS-BINARY? .DATA>>
  <PRINC " PTR:">
  <PRIN1 <NS-PTR .DATA>>
  <PRINC " SPTR:">
  <PRIN1 <NS-SPTR .DATA>>
  <PRINC " BUF:">
  <COND (<SET BUF <NS-BUF .DATA>>
	 <PRIN1 <NS-BC .DATA>>
	 <PRINC !\/>
	 <COND (<TYPE? .BUF STRING>
		<PRIN1 <- <LENGTH <NS-TBUF .DATA>>
			  <LENGTH <NS-BUF .DATA>>>>
		<PRINC !\/>
		<PRIN1 <LENGTH <NS-BUF .DATA>>>)
	       (<PRIN1 <- <LENGTH <NS-TBUF .DATA>>
			  <LENGTH <NS-BUF .DATA>>>>
		<PRINC !\/>
		<PRIN1 <LENGTH <NS-BUF .DATA>>>)>)
	(T
	 <PRINC "<>">)>
  <PRINC !\]>
  T>

<DEFINE X$DISK-FLUSH (CHN OPER "AUX" (DAT <T$CHANNEL-DATA .CHN>)
		     (JFN <NS-JFN .DAT>) (STATUS <NS-STATUS .DAT>)
		     ONM BCKNM)
  #DECL ((CHN) T$CHANNEL (DAT) I$DISK-CHANNEL)
  <COND (<NS-BUF .DAT>
	 <T$RELEASE-BUFFER <NS-BUF .DAT>>)>
  <COND (<0? <ANDB .STATUS ,STATUS-NO-FLUSH>>
	 <COND (<CALL SYSCALL CLOSE .JFN>
		<COND (<NOT <0? <ANDB .STATUS ,STATUS-NEW>>>
		       <SET ONM <T$STANDARD-NAME <I$DEF-NAME .CHN .OPER>>>
		       <CALL SYSCALL UNLINK .ONM>
		       <COND (<NOT <0? <ANDB .STATUS ,STATUS-RENAME>>>
			      <SET BCKNM <I$MAKE-BACKUP-NAME .ONM>>
			      <CALL SYSCALL LINK .BCKNM .ONM>
			      <CALL SYSCALL UNLINK .BCKNM>)
			     (.CHN)>)
		      (.CHN)>)>)>>
