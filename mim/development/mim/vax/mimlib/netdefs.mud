<DEFINITIONS "NETDEFS">

<USE "NEWSTRUC" "NETBASE">

<GDECL (NET-CHANNELS) <LIST [REST FIX CHANNEL]>>

<NEWSTRUC CONNECTION VECTOR
	  C-SOCKET FIX
	  C-ADDR NET-ADDRESS
	  C-SERVICE FIX
	  C-FLAGS FIX
	  C-TIMEOUT <OR UVECTOR FALSE>
	  C-ALTCHANNEL <OR <CHANNEL 'NETWORK> FIX FALSE>>

<MSETG ADDR-LEN 16>
<MSETG ADDR-WORD-LEN 4>

<NEWSTRUC NET-ADDRESS UVECTOR
	  NA-SOCKET FIX
	  NA-HOST FIX
	  NA-OTH1 FIX
	  NA-OTH2 FIX>

<MSETG IN-ADDR-HOST ,NA-HOST>

<DEFMAC WORD-BYTE ('WD 'WHICH "OPT" 'NEW)
   <COND (<NOT <ASSIGNED? NEW>>
	  <FORM GETBITS .WD <BITS 8 <* .WHICH 8>>>)
	 (T
	  <FORM PUTBITS .WD <BITS 8 <* .WHICH 8>> .NEW>)>>

<DEFMAC REV-WD ('WD)
   <FORM BIND ((NW .WD))
	 <FORM PUTBITS
	       <FORM GETBITS '.NW <BITS 8 8>>
	       <BITS 8 8>
	       <FORM GETBITS '.NW <BITS 8 0>>>>>

<DEFMAC IN-ADDR-FAMILY ('ADDR "OPT" 'NEW)
   <COND (<NOT <ASSIGNED? NEW>>
	  <FORM RHW <FORM NA-SOCKET .ADDR>>)
	 (T
	  <FORM NA-SOCKET .ADDR <FORM PUTRHW <FORM NA-SOCKET .ADDR> .NEW>>)>>

<DEFMAC IN-ADDR-PORT ('ADDR "OPT" 'NEW)
   <COND (<NOT <ASSIGNED? NEW>>
	  <FORM REV-WD <FORM LHW <FORM NA-SOCKET .ADDR>>>)
	 (T
	  <FORM NA-SOCKET .ADDR <FORM PUTLHW <FORM NA-SOCKET .ADDR>
				       <FORM REV-WD .NEW>>>)>>

<DEFMAC BUILD-ADDRESS ('SERVICE 'H "OPT" 'UV)
  <FORM BIND (NEW-ADDR)
    <COND (<NOT <ASSIGNED? UV>>
	   <FORM SET NEW-ADDR <FORM CHTYPE <FORM IUVECTOR ,ADDR-WORD-LEN>
				      NET-ADDRESS>>)
	  (T
	   <FORM SET NEW-ADDR .UV>)>
    <FORM NA-HOST '.NEW-ADDR .H>
    <FORM NA-OTH1 '.NEW-ADDR 0>
    <FORM NA-SOCKET '.NEW-ADDR
	  <FORM PUTLHW ,AF-INET <FORM REV-WD .SERVICE>>>>>

<MSETG FIONREAD *10001063177*>

<MSETG TIMED-OUT <CHTYPE (60) FALSE>>

<MSETG F-DUPFD 0>
<MSETG F-GETFD 1>
<MSETG F-SETFD 2>
<MSETG F-GETFL 3>
<MSETG F-SETFL 4>
<MSETG F-GETOWN 5>
<MSETG F-SETOWN 6>

<MSETG FNDELAY 4>
<MSETG FAPPEND *10*>
<MSETG FASYNC *100*>

<MSETG O-RDONLY 0>
<MSETG O-WRONLY 1>
<MSETG O-RDWR 2>
<MSETG O-NDELAY ,FNDELAY>
<MSETG O-APPEND ,FAPPEND>



<MSETG SHUT-RECV 0>
<MSETG SHUT-SEND 1>
<MSETG SHUT-ALL 2>

; "Socket types for socket call"
<MSETG SOCK-STREAM 1>		; "Stream"
<MSETG SOCK-DGRAM 2>		; "Datagrams"
<MSETG SOCK-RAW 3>		; "raw-protocol interface"
<MSETG SOCK-RDM 4>		; "reliably-delivered message"
<MSETG SOCK-SEQPACKET 5>	; "sequenced packets"

; "Option flags per-socket"
<MSETG SO-DEBUG 1>		; "Turn on debugging info recording"
<MSETG SO-ACCEPTCONN 2>		; "Socket has had listen()"
<MSETG SO-REUSEADDR 4>		; "Allow local address reuse"
<MSETG SO-KEEPALIVE 8>		; "keep connections alive"
<MSETG SO-DONTROUTE 16>		; "just use interface addresses"
<MSETG SO-USELOOPBACK 64>	; "bypass hardware when possible"
<MSETG SO-LINGER 128>		; "Linger on close if data present"

<MSETG NET-ADDR-ANY 0>		       ;"special address for listening"

; "Address format parameters for socket call"
<MSETG AF-UNSPEC 0>
<MSETG AF-UNIX 1>
<MSETG AF-INET 2>
<MSETG AF-PUP 3>
<MSETG AF-IMPLINK 4>
<MSETG AF-CHAOS 5>
<MSETG AF-NS 6>
<MSETG AF-NBS 7>
<MSETG AF-ECMA 8>
<MSETG AF-DATAKIT 9>
<MSETG AF-CCITT 10>
<MSETG AF-SNA 11>

<MSETG PS-UNSPEC ,AF-UNSPEC>
<MSETG PF-UNIX ,AF-UNIX>
<MSETG PF-INET ,AF-INET>
<MSETG PF-IMPLINK ,AF-IMPLINK>
<MSETG PF-PUP ,AF-PUP>
<MSETG PF-CHAOS ,AF-CHAOS>
<MSETG PF-NS ,AF-NS>
<MSETG PF-NBS ,AF-NBS>
<MSETG PF-ECMA ,AF-ECMA>
<MSETG PF-DATAKIT ,AF-DATAKIT>
<MSETG PF-CCITT ,AF-CCITT>
<MSETG PF-SNI ,AF-SNA>
\
; "Protocols"
<MSETG PROT-IP 0>		       ;"Internet"
<MSETG PROT-ICMP 1>		       ;"Internet control message"
<MSETG PROT-GGP 3>		       ;"gateway-gateway protocol"
<MSETG PROT-TCP 6>		       ;"transmission control protocol"
<MSETG PROT-PUP 12>		       ;"PARC universal packet"
<MSETG PROT-ACP 13>		       ;"Argus"
<MSETG PROT-UDP 17>		       ;"user datagrams"
<MSETG PROT-RVD 66>		       ;"remote virtual disk"

<MSETG SERV-MIN-NONPRIV 1025>	       ;"smaller sockets can't listen"
<MSETG SERV-TEST <PUTLHW ,SERV-MIN-NONPRIV ,PROT-TCP>>
<MSETG SERV-TEST-UDP <PUTLHW ,SERV-MIN-NONPRIV ,PROT-UDP>>

; "Services.  Protocol is LH, socket is RH"
<MSETG SERV-TCP-ECHO <PUTLHW 7 ,PROT-TCP>> ;"for debugging"
<MSETG SERV-UDP-ECHO <PUTLHW 7 ,PROT-UDP>>
<MSETG SERV-TCP-DISCARD <PUTLHW 9 ,PROT-TCP>>
<MSETG SERV-UDP-DISCARD <PUTLHW 9 ,PROT-UDP>>
<MSETG SERV-SYSTAT <PUTLHW 11 ,PROT-TCP>>	;"Users"
<MSETG SERV-DAYTIME <PUTLHW 13 ,PROT-TCP>>	;"Time of day"
<MSETG SERV-NETSTAT <PUTLHW 15 ,PROT-TCP>>
<MSETG SERV-TCP-QOTD <PUTLHW 17 ,PROT-TCP>>	;"quote"
<MSETG SERV-UDP-QOTD <PUTLHW 17 ,PROT-UDP>>
<MSETG SERV-CHARGEN <PUTLHW 19 ,PROT-TCP>>
<MSETG SERV-FTP <PUTLHW 21 ,PROT-TCP>>
<MSETG SERV-TELNET <PUTLHW 23 ,PROT-TCP>>
<MSETG SERV-SMTP <PUTLHW 25 ,PROT-TCP>>
<MSETG SERV-TCP-TIME <PUTLHW 37 ,PROT-TCP>>
<MSETG SERV-UDP-TIME <PUTLHW 37 ,PROT-UDP>>
<MSETG SERV-NAME <PUTLHW 42 ,PROT-TCP>>
<MSETG SERV-WHOIS <PUTLHW 43 ,PROT-TCP>>
<MSETG SERV-MTP <PUTLHW 57 ,PROT-TCP>>
<MSETG SERV-HOSTNAMES <PUTLHW 101 ,PROT-TCP>>
<MSETG SERV-TFTP <PUTLHW 69 ,PROT-UDP>>
<MSETG SERV-RJE <PUTLHW 77 ,PROT-TCP>>
<MSETG SERV-FINGER <PUTLHW 79 ,PROT-TCP>>
<MSETG SERV-LINK <PUTLHW 87 ,PROT-TCP>>
<MSETG SERV-SUPDUP <PUTLHW 95 ,PROT-TCP>>
<MSETG SERV-WRITE <PUTLHW 115 ,PROT-TCP>>
<MSETG SERV-INGRESLOCK <PUTLHW 1524 ,PROT-TCP>>

<MSETG SERV-EXEC <PUTLHW 512 ,PROT-TCP>>
<MSETG SERV-LOGIN <PUTLHW 513 ,PROT-TCP>>
<MSETG SERV-SHELL <PUTLHW 514 ,PROT-TCP>>
<MSETG SERV-PRINTER <PUTLHW 515 ,PROT-TCP>>
<MSETG SERV-BIFF <PUTLHW 512 ,PROT-UDP>>
<MSETG SERV-WHO <PUTLHW 513 ,PROT-UDP>>
<MSETG SERV-SYSLOG <PUTLHW 514 ,PROT-UDP>>
<MSETG SERV-TALK <PUTLHW 517 ,PROT-UDP>>
<MSETG SERV-ROUTE <PUTLHW 520 ,PROT-UDP>>
<MSETG SERV-NEW-RWHO <PUTLHW 550 ,PROT-UDP>>
<MSETG SERV-RMONITOR <PUTLHW 560 ,PROT-UDP>>
<MSETG SERV-MONITOR <PUTLHW 561 ,PROT-UDP>>

<MSETG SERV-VS100 <PUTLHW 5800 ,PROT-TCP>>



<END-DEFINITIONS>