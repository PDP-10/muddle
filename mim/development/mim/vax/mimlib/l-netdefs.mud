<DEFINITIONS "L-NETDEFS">

;"*****************************************************************************

  This file defines constants and macros related to library format, local
  library operations, and other random cruft.

  L-NETDEFS.MUD: EDIT HISTORY            Machine Dependent (For use under UNIX)

  COMPILATION: Include when compiling.

  JUN84   [Shane] - Created.
  4OCT84  [Shane] - Commented, cleaned up.
  20OCT84 [Shane] - More sensible protocols.

  ****************************************************************************"

<USE "NEWSTRUC" "NETBASE" "HOSTS">

<INCLUDE "NETDEFS">

;"HOST NUMBERS FOR HOSTS RECOGNIZED BY LIBRARY SERVER.
  For some reason, calling HOST in MIMC loses, so abstract this DEFINITIONS
  so that the abstract will be included instead."

<MSETG MIT-AJAX 	<HOST "MIT-AJAX">>
<MSETG MIT-LCS-HQ 	<HOST "MIT-LCS-HQ">>
<MSETG MIT-HEINEKEN 	<HOST "MIT-HEINEKEN">>
<MSETG MIT-GRAPE-NEHI 	<HOST "MIT-GRAPE-NEHI">>
<MSETG MIT-MOLSON 	<HOST "MIT-MOLSON">>
<MSETG MIT-KIRIN	<HOST "MIT-KIRIN">>
<MSETG MIT-MACEWAN 	<HOST "MIT-MACEWAN">>
<MSETG MIT-DM 		<HOST "MIT-DM">>

;"SERVICE DESCRIPTOR FOR OBTAINING LIBRARY SERVICE."

<MSETG LIB-SERVICE <PUTLHW ,SERV-MIN-NONPRIV ,PROT-TCP>>

;"REQUEST TYPES RECOGNIZED BY LIBRARY SERVER."

<MSETG ABORT-REQUEST 		0>          ;"Toplevel request type codes."
<MSETG FILE-REQUEST 		1>
<MSETG PACKAGE-REQUEST          2>
<MSETG MAP-RECORDS-REQUEST 	3>
<MSETG RECORD-REQUEST 		4>
<MSETG ENTRY-REQUEST 		5>
<MSETG COUNT-REQUEST		6>
<MSETG UPDATE-REQUEST		7>

;"*******************************************************************************
  ABORT-REQUEST: Abort request in progress. If an update request is aborted, this
		 includes deletion of temporary files.

	*------------------------*--------*
	|XXXXXXXXXXXXXXXXXXXXXXXX|00000000|
	*------------------------*--------*

	RESPONSE: 	NACK (0) and the request is terminated.

  *******************************************************************************"

<MSETG FILE-CLOSE       0>
<MSETG FILE-READ	1>
<MSETG FILE-ACCESS	2>

;"*******************************************************************************
  FILE-REQUEST: Open and access files accessible to server.

	*--------*-----------------*--------*
	|XXXXXXXX|      NAME LENGTH|00000001|
	*--------*--------*--------*--------*
	|   MASK3|   MASK2|   MASK1|   MASK0|
	*--------*--------*--------*--------*
	/				    /
	/ NAME (8-BIT ASCII)		    /
	/				    /
	*-----------------------------------*

	NAME LENGTH =   size(NAME), 0 < size(NAME) < 1025

	RESPONSE:	Either length of file in bytes or NACK (0).

  PACKAGE-REQUEST: Open and access a library module.

	Same picture, different type code.

	RESPONSE:	Either length of file in bytes or NACK (0).

	The only difference between FILE-REQUEST and PACKAGE-REQUEST is that
	PACKAGE-REQUEST looks up NAME of file in library but FILE-REQUEST
	assumes that NAME is a file name (which may contain a directory path
	other than server's directory). For FILE-REQUEST, DEV and SNM default
	to server's DEV and SNM. NM2 is not defaulted unless the MASK word is
	non-zero, in which case the implied second names will be tried in turn.
	The MASK word must be non-zero for PACKAGE-REQUEST. The MASK word is
	interpreted as an encoding of L-SECOND-NAMES, lower numbered bytes
	taking precedence; a zero byte denotes the end of the list. The allowed
	MASKS are:

	00000001 - MSUBR
	00000010 - MUD
	00000100 - ABSTR
	00001000 - DOC

  File requests honored after initial request is acknowledged.

	FILE-CLOSE:     Same as ABORT-REQUEST.

			*-----------------------*--------*
	FILE-READ:      |                 AMOUNT|00000001|
			*-----------------------*--------*

	RESPONSE:	The requested number of bytes is written from current
			position in file (provided end of file is not seen).
			It is the responsibility of the user to guarantee that
			the network pipe is empty at the time of the request.

			*-----------------------*--------*
	FILE-ACCESS:    |                ADDRESS|00000010|
			*-----------------------*--------*

	RESPONSE:	ACK (-1). The file pointer becomes ADDRESS.
  *******************************************************************************"

<MSETG MAP-NEXT-RECORD	3>
<MSETG MAP-SHORT-RECORD *20000000000*>

;"*******************************************************************************
  MAP-RECORDS-REQUEST: Obtain every record in the library in bucket order.

	*------------------------*--------*
	|XXXXXXXXXXXXXXXXXXXXXXXX|00000011|
	*------------------------*--------*

  RESPONSE: 	ACK (-1)

  Once the request has been acknowledged:

				*------------------------*--------*
	MAP-NEXT-RECORD:	|SXXXXXXXXXXXXXXXXXXXXXXX|00000011|
				*------------------------*--------*

	RESPONSE:		NACK (0) if all the records have been seen, and
				the request is terminated. Otherwise the record
				itself. The length of the record (including the
				first word) is BITS[31:16] in the first word of
				the record. If S is set (MAP-SHORT-RECORD) a short
				record is sent, otherwise, a long record is sent
				(see LIBRARY.FORMAT).

  *******************************************************************************"

<MSETG RECORD-SHORT	*20000000000*>

;"*******************************************************************************
  RECORD-REQUEST: Obtain library record by name.

	*--------*----------------*--------*
	|SXXXXXXX|     NAME LENGTH|00000100|
	*--------*----------------*--------*
	/		     	           /
	/ NAME (8-BIT ASCII)		   /
	/				   /
	*----------------------------------*

	NAME LENGTH = mod(size(NAME), 1024), 0 < size(NAME) < 1024

	RESPONSE:	NACK (0) if record is not found, otherwise the record
			itself. The length of the record (including the first
			word) is BITS[31:16] in the first word of the record.
			If S is set (RECORD-SHORT) a short record is sent,
			otherwise, a long record is sent (see LIBRARY.FORMAT).
			The request is terminated after response is transmitted.
  *******************************************************************************"

;"*******************************************************************************
  ENTRY-REQUEST: Obtain library information about every entry for given name.

	*--------*----------------*--------*
	|XXXXXXXX|     NAME LENGTH|00000101|
	*--------*----------------*--------*
	/		    	           /
	/ NAME (8-BIT ASCII)		   /
	/				   /
	*----------------------------------*

	NAME LENGTH = mod(size(NAME), 1024), 0 < size(NAME) < 1024

	RESPONSE: 	NACK (0) if no information is found, otherwise entry
			data block. The length of the block (including first
			word is in BITS[15:0] of the first word of block.
			BITS[31:16] contain count of entry descriptors in data
			block (see L-BASE.MUD, comment for ENTRY-DATA). The
			request is terminated after response is transmitted.
  *******************************************************************************"

;"*******************************************************************************
  COUNT-REQUEST: Obtain count of number of packages and entries.

	*------------------------*--------*
	|XXXXXXXXXXXXXXXXXXXXXXXX|00000110|
	*------------------------*--------*

	RESPONSE:	The number of entries/rentries followed by the number of
			packages/definitions as (32-BIT fixes). The request is
			terminated after response is transmitted.
  *******************************************************************************"

;"*******************************************************************************
  UPDATE-REQUEST: Lock library for update transactions.

	*------------------------*--------*
	|XXXXXXXXXXXXXXXXXXXXXXXX|00000111|
	*------------------------*--------*

	RESPONSE:	ACK (-1) if the library is locked. NACK (0), otherwise,
			and the request is terminated.
  *******************************************************************************"

<MSETG UPDATE-ABORT	0>                  ;"Toplevel update requests."
<MSETG UPDATE-EXISTS?	1>
<MSETG UPDATE-ADD	2>
<MSETG UPDATE-DEL	3>
<MSETG UPDATE-GC	4>
<MSETG UPDATE-INSTALL	5>
<MSETG UPDATE-UNLOCK	6>
<MSETG UPDATE-FILE      *20000000000*>      ;"Modifier for ADD, DEL, EXISTS?"

;"*******************************************************************************
  Update requests honored after REQUEST-UPDATE is acknowledged.

			*------------------------*--------*
  UPDATE-ABORT:		|XXXXXXXXXXXXXXXXXXXXXXXX|00000000|
			*------------------------*--------*

  RESPONSE:		NACK (0). All transactions occurring since the last
			install operation are aborted and the request
			is terminated.

			*--------*----------------*--------*
  UPDATE-EXISTS?:	|FXXXXXXX|     NAME LENGTH|00000001|
			*--------*----------------*--------*
			/		     		   /
			/ NAME (8-BIT ASCII)		   / size(NAME) < 1025
			/                                  /
			*----------------------------------*

  RESPONSE:		If F = 0 then ACK (-1) if record named NAME is in
			library, otherwise NACK (0). If F = 1 then ACK (-1)
			if file named NAME is in library directory, else NACK.

			*------------------------*--------*
  UPDATE-ADD:		|0XXXXXXXXXXXXXXXXXXXXXXX|00000010| F = 0
			*------------------------*--------*
			/				  /
			/ LIBRARY RECORD         	  /
			/				  /
			*---------------------------------*
			/ DATA ADDRESS (4 WORDS)          /
			*---------------------------------*
			|                      FILE LENGTH| CONTROL
			*---------------------------------*
			/ FILE (MSUBR)			  / DATA
			*---------------------------------*          -> ACK
			|                      FILE LENGTH| CONTROL
			*---------------------------------*
			/ FILE (MUD) 			  / DATA
			*---------------------------------*          -> ACK
			|                      FILE LENGTH| CONTROL
			*---------------------------------*
			/ FILE (ABSTR)			  / DATA
			*---------------------------------*          -> ACK
			|                      FILE LENGTH| CONTROL
			*---------------------------------*
			/ FILE (DOC)			  / DATA
			*---------------------------------*          -> ACK
								     -> ACK

  RESPONSE: 		Files are transferred in order shown, although not all
			types need be present (names and types specified by
			LIBRARY RECORD). The server responds with ACK (-1) after
			each file is received. The server responds with ACK (-1)
			when the request is serviced. Otherwise NACK (0) and the
			update is terminated. The protocol shown if for library
			records (F bit = 0). The protocol for file is similar
			and shown below.

			*--------*----------------*--------*
  UPDATE-ADD:		|1XXXXXXX|     NAME LENGTH|00000010| F = 1
			*--------*----------------*--------*
			/ NAME (8-BIT ASCII)               /
			*----------------------------------*
			/ DATA ADDRESS (4 WORDS)           /
			*----------------------------------*
			|                       FILE LENGTH| CONTROL
			*----------------------------------*
			/ FILE  			   / DATA
			*----------------------------------*          -> ACK
								    -> ACK
			*--------*----------------*--------*
  UPDATE-DEL:    	|FXXXXXXX|     NAME LENGTH|00000011|
			*--------*----------------*--------*
			/		        	   /
			/ NAME (8-BIT ASCII)		   / size(NAME) < 1025
			/                                  /
			*----------------------------------*

  RESPONSE:		If F = 0 then ACK (-1) if record named NAME is
			successfully removed from library, otherwise NACK (0)
			and update is aborted. If F = 1, then NAME is
			interpreted as a file name instead.

			*------------------------*--------*
  UPDATE-GC:		|XXXXXXXXXXXXXXXXXXXXXXXX|00000100|
			*------------------------*--------*

  RESPONSE:		ACK (-1) if library is successfully garbage collected,
			otherwise NACK (0) and update is terminated.

			*------------------------*--------*
  UPDATE-INSTALL:	|XXXXXXXXXXXXXXXXXXXXXXXX|00000101|
			*------------------------*--------*

  RESPONSE:		ACK (-1) if modified library is successfully installed
			and locked, otherwise NACK (0) and update is
			terminated.

			*------------------------*--------*
  UPDATE-UNLOCK:	|XXXXXXXXXXXXXXXXXXXXXXXX|00000110|
			*------------------------*--------*

  RESPONSE:		ACK (-1) if modified library is successfully installed
			and released, otherwise NACK (0). Update is terminated.
  *******************************************************************************"

<MSETG ACK -1>                   ;"Acknowledge."
<MSETG NACK 0>                   ;"Negative acknowledge."

;"REMOTE -- Return T if CHANNEL is NETWORK channel."

<DEFMAC REMOTE? ('CHANNEL)
   <CHTYPE (==? <CHTYPE (CHANNEL-TYPE .CHANNEL) FORM> NETWORK) FORM>>

;"Channel type synonym."

<PUT-DECL NET '<CHANNEL 'NETWORK>>

;"NFDATA -- Channel data for NETFILE channel."

<NEWSTRUC NFDATA VECTOR
	  NF-FSIZ FIX                 ;"File size in bytes."
	  NF-FPTR FIX                 ;"Current position in file."
	  NF-NAME STRING              ;"File name."
	  NF-CONN <CHANNEL 'NETWORK>> ;"Channel to network server."

;"TIMEOUTS (seconds)."

<MSETG STANDARD-TIMEOUT 4>        ;"Timeout for non-update requests."
<MSETG UPDATE-TIMEOUT   30>       ;"Timeout for update requests."

<END-DEFINITIONS>
