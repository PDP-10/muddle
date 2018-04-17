;"*****************************************************************************

  This file defines library update primitives for use with a network library.
  See PROTOCOLS.FORMAT for definition of server protocols. This file is
  spliced into LUP (vax version).

  LUP-NETWORK.MUD: EDIT HISTORY          Machine Dependent (For use under UNIX)

  COMPILATION: Spliced in at compile time.

  JUN84    [Shane] - Created.
  18OCT84  [Shane] - Commented, cleaned up.
  27OCT84  [Shane] - New protocols.
  ****************************************************************************"

;"NET-FILE-COPY --
  Effect:   Copies FROM to remote server. CNTL is the control connection,
	    used to send the file length and receive the acknowledgement.
	    DATA is the data connection over which the file is transmitted.
  Modifies: FROM, DATA, CNTL
  Returns:  T if transfer acknowledged, FALSE otherwise.
  Requires: DATA, CNTL are open to server awaiting file transaction."

<DEFINE NET-FILE-COPY (FROM:<CHANNEL 'DISK>
		       DATA:<CHANNEL 'NETWORK> CNTL:<CHANNEL 'NETWORK>
		       "AUX" (U:UVECTOR <STACK <UVECTOR <FILE-LENGTH .FROM>>>))
   <CHANNEL-OP .CNTL WRITE-BUFFER .U>
   <REPEAT ((BUFFER:STRING <STACK <ISTRING ,MAXSTRS>>) AMOUNT:FIX)
      <SET AMOUNT <OR <CHANNEL-OP .FROM READ-BUFFER .BUFFER> 0>>
      <COND (<==? .AMOUNT 0>
	     <RETURN <AND <GET-REMOTE-RESPONSE .CNTL .U> <==? <1 .U> ,ACK>>>)
	    (T
	     <CHANNEL-OP .DATA WRITE-BUFFER .BUFFER .AMOUNT>)>>>

;"REMOTE-UPDATE --
  Effect:   Add the module represented by RECORD and associated FILES to
	    remote library LIBC.
  Modifies: LIBC
  Returns:  T if update is successful, otherwise FALSE.
  Requires: LIBC is channel open to server processing file request. RECORD
	    is properly formatted library record as defined in LIBRARY.FORMAT.
	    The order of the file spec vectors (see SEARCH in ABSTR) in FILES
	    is the same as the order of the file names in RECORD (i.e. MSUBR,
	    MUD, ABSTR, DOC), with FALSE indicating omission."

<DEFINE REMOTE-UPDATE (RECORD:UVECTOR LIBC:<CHANNEL 'NETWORK>
		       "TUPLE" FILES:<PRIMTYPE VECTOR>)
   <PROG ((U:UVECTOR <STACK <IUVECTOR 4>>) (OUTCHAN:CHANNEL .OUTCHAN)
	  DATA:<OR <CHANNEL 'NETWORK> FALSE> FROM:<OR <CHANNEL 'DISK> FALSE>)
      ;"Request update, send data address, connect data channel."
      <CHANNEL-OP .LIBC WRITE-BUFFER <1 .U ,UPDATE-ADD> 1>
      <CHANNEL-OP .LIBC WRITE-BUFFER .RECORD <LHALF <1 .RECORD>>>
      <CHANNEL-OP .LIBC LISTEN-ON-DATA>
      <CHANNEL-OP .LIBC GET-DATA-ADDRESS <CHTYPE .U NET-ADDRESS>>
      <CHANNEL-OP .LIBC WRITE-BUFFER .U>
      <COND (<NOT <SET DATA <CHANNEL-OP .LIBC CONNECT-DATA-CHANNEL>>>
	     <ERROR CANT-OPEN-DATA-CONNECTION!-ERRORS
                    <SYS-ERR "" .DATA %<>> REMOTE-UPDATE>
	     <RETURN %<>>)>
      ;"Copy files."
      <MAPF %<>
	    <FUNCTION (FN:<OR <VECTOR [5 STRING]> FALSE>)
	       <COND (.FN
		      <PRINTSTRING "Copying ">
		      <PRINTSTRING <1 .FN>>
		      <CRLF>
		      <COND (<NOT <SET FROM <CHANNEL-OPEN DISK <1 .FN> "READ">>>
			     <ERROR FILE-NOT-FOUND!-ERRORS
				    <1 .FN> .FROM REMOTE-UPDATE>
			     <RETURN %<>>)
			    (<NOT <NET-FILE-COPY .FROM .DATA .LIBC>>
			     <CHANNEL-OP .LIBC CLOSE-DATA-CHANNEL>
			     <CLOSE .FROM>
			     <RETURN %<>>)>)>>
	    .FILES>
      <CHANNEL-OP .LIBC CLOSE-DATA-CHANNEL>
      <AND <GET-REMOTE-RESPONSE .LIBC .U> <==? <1 .U> ,ACK>>>>
