<DEFINITIONS "L-DEFS">

;"*****************************************************************************

  This file defines constants and macros related to library format, local
  library operations, and other random cruft.

  L-DEFS.MUD: EDIT HISTORY                                  Machine Independent

  COMPILATION: Include when compiling.

  JUN84   [Shane] - Created.
  4OCT84  [Shane] - Commented, cleaned up.
  20OCT84 [Shane] - Add bit for declaring entry applicable.
   9NOV84 [Shane] - Merge definitions for LIBLOCK, MAP-RECORDS state vector.
  ****************************************************************************"

<USE "NEWSTRUC">

;"LENGTHW -- Return number of words required to represent STRING."

<DEFMAC LENGTHW ('STRING)
   <FORM LSH <FORM + <FORM LENGTH .STRING> 3> -2>>

;"RDRWD -- Read and return word (FIX) from disk CHANNEL in binary mode."

<DEFMAC RDWRD ('CHANNEL)
   <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL> READ-BYTE>>

;"RDBUF -- Read words from disk CHANNEL open in binary mode into UVECTOR,
  returning number of words read."

<DEFMAC RDBUF ('CHANNEL 'UVECTOR "OPT" 'FIX)
   <COND (<ASSIGNED? FIX>
	  <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL>
		READ-BUFFER .UVECTOR .FIX>)
	 (T
	  <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL>
		READ-BUFFER .UVECTOR>)>>

;"WRWRD -- Write FIX to disk CHANNEL open in binary mode."

<DEFMAC WRWRD ('CHANNEL 'FIX)
   <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL> WRITE-BYTE .FIX>>

;"WRBUF -- Write words from UVECTOR to disk CHANNEL open in binary mode."

<DEFMAC WRBUF ('CHANNEL 'UVECTOR "OPT" 'FIX)
   <COND (<ASSIGNED? FIX>
	  <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL>
		WRITE-BUFFER .UVECTOR .FIX>)
	 (T
	  <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL>
		WRITE-BUFFER .UVECTOR>)>>

;"SETADR -- Access disk CHANNEL to address FIX."

<DEFMAC SETADR ('CHANNEL 'FIX)
   <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL> ACCESS .FIX>>

;"GETADR -- Return address of next word in disk CHANNEL."

<DEFMAC GETADR ('CHANNEL)
   <FORM CHANNEL-OP <CHTYPE [.CHANNEL '<CHANNEL 'DISK>] ADECL> ACCESS>>

;"BYTEn - Extract and return the nth byte from WORD. Leftmost byte is 3."

<DEFMAC BYTE3 ('WORD) <FORM GETBITS .WORD '<BITS 8 24>>>

<DEFMAC BYTE2 ('WORD) <FORM GETBITS .WORD '<BITS 8 16>>>

<DEFMAC BYTE1 ('WORD) <FORM GETBITS .WORD '<BITS 8 8>>>

<DEFMAC BYTE0 ('WORD) <FORM GETBITS .WORD '<BITS 8 0>>>

;"LHALF, RHALF -- Extract and return the leftmost (rightmost) 16 bits from WORD."

<DEFMAC LHALF ('WORD) <FORM GETBITS .WORD '<BITS 16 16>>>

<DEFMAC RHALF ('WORD) <FORM GETBITS .WORD '<BITS 16 0>>>

;"ADDRESS - Extract and return rightmost 24 bits from WORD (file address)."

<DEFMAC ADDRESS ('WORD) <FORM GETBITS .WORD '<BITS 24 0>>>

;"CHAR - Return WORD changed to character."

<DEFMAC CHAR ('WORD) <FORM CHTYPE .WORD CHARACTER>>

;"TESTBIT -- Return T if WORD contains the bits of MASK, otherwise FALSE. If
  SENSE is FALSE, the result is logically negated."

<DEFMAC TESTBIT ('WORD 'MASK "OPT" (SENSE T))
   #DECL ((SENSE) <OR ATOM FALSE>)
   <COND (.SENSE
	  <FORM N==? <FORM ANDB .WORD .MASK> 0>)
	 (T
	  <FORM ==? <FORM ANDB .WORD .MASK> 0>)>>

<GDECL (OLD-TYPES) FIX>                     ;"External."

;"TYPE-NAME? -- Return T if ATOM names a type."

<DEFMAC TYPE-NAME? ('ATOM)
   <FORM BIND ((A .ATOM)) '#DECL ((A) ATOM)
	 '<OR <AND <VALID-TYPE? .A> <G? <LSH <TYPE-C .A> -6> ,OLD-TYPES>>
	      <GET-DECL .A>>>>

;"EXTRACT-NMn -- Extract and return the specified part from file-spec NAME."

<DEFMAC EXTRACT-NM1 ('NAME)
   <FORM BIND ((CHANNEL <FORM CHANNEL-OPEN PARSE .NAME 0 0 0 0>)
	       '(STRING <CHANNEL-OP .CHANNEL NM1>))
	 '#DECL ((CHANNEL) <CHANNEL 'DISK> (STRING) STRING)
	 '<CHANNEL-CLOSE .CHANNEL>
	 '.STRING>>

<DEFMAC EXTRACT-NM2 ('NAME)
   <FORM BIND ((CHANNEL <FORM CHANNEL-OPEN PARSE .NAME 0 0 0 0>)
	       '(STRING <CHANNEL-OP .CHANNEL NM2>))
	 '#DECL ((CHANNEL) <CHANNEL 'DISK> (STRING) STRING)
	 '<CHANNEL-CLOSE .CHANNEL>
	 '.STRING>>

;"DIRECTORY HEADER CONSTANTS."

<MSETG DIR-TABSIZ 0> 	;"File address of hash table size."
<MSETG DIR-LERCNT 1>	;"File address of entry count."
<MSETG DIR-LPDCNT 2>	;"File address of package count."
<MSETG DIR-FRELST 3>	;"File address of free list."
<MSETG DIR-EOFPTR 4>    ;"File address of EOF pointer."
<MSETG DIR-HDRLEN 5>    ;"Header size = file address of first hash bucket."

;"HASH BUCKET CONSTANTS."

<MSETG BKT-M *20000000000*>	;"Bit indicating bucket points to list."
<MSETG BKT-P *10000000000*>	;"Bit indicating bucket points to package."
<MSETG BKT-E *4000000000*>	;"Bit indicating bucket points to entry."

;"RECORD INFORMATION WORD CONSTANTS."

<MSETG RINFO-CFN? *400*>	;"Bit indicating presence of code file."
<MSETG RINFO-SFN? *1000*>       ;"Bit indicating presence of source file."
<MSETG RINFO-AFN? *2000*>       ;"Bit indicating presence of abstract file."
<MSETG RINFO-DFN? *4000*>	;"Bit indicating presence of doc file."
<MSETG RINFO-DOC? *10000*>      ;"Bit indicating presence of doc string."
<MSETG RINFO-PKG? *20000*>	;"Bit indicating record is for package."

;"ENTRY/RENTRY DESCRIPTOR CONSTANTS."

<MSETG ERTYP-MANIFEST? *10000*>	   ;"Bit indicating r/entry is manifested."
<MSETG ERTYP-TYPE? *20000*>	   ;"Bit indicating r/entry is type name."
<MSETG ERTYP-ENTRY? *40000*>  	   ;"Bit indictaing r/entry is entry."
<MSETG ERTYP-APPLICABLE? *100000*> ;"Bit indicating gval is applicable."

;"USE/EXPORT/INCLUDE DESCRIPTOR CONSTANTS."

<MSETG UXI-USED? *200000*>	;"Bit indicating module is used."
<MSETG UXI-EXPORTED? *400000*>  ;"Bit indicating module is exported."
<MSETG UXI-INCLUDED? *1000000*> ;"Bit indicating module is included."

;"HASH TABLE CONSTANTS."

<MSETG INITIAL-BUCKETS 4001>	;"Default number of buckets for new library."
<MSETG HASH-ROT 13>             ;"Magic constant for hashing functions."

;"STRUCTURE SIZE CONSTANTS."

<MSETG MAXREC 4096>	;"No record may exceed this size in words (arbitrary)."
<MSETG MAXSTRU 256>     ;"No string may exceed this size in words (library law)."
<MSETG MAXSTRS 1024>    ;"No string may exceed this size in chars (library law)."

;"OFFSETS FOR STATE VECTOR IN MAP-RECORDS, NEXT-RECORD (see L-QUERY-BASE.MUD)."

<MSETG NEXT-BUCKET <OFFSET 1 UVECTOR FIX>>	;"File address of next bucket."
<MSETG BUCKET-CDR <OFFSET 2 UVECTOR FIX>>	;"File address of cdr in list."
<MSETG LAST-BUCKET <OFFSET 3 UVECTOR FIX>>	;"File address of last in table."

;"LUP TYPE DEFINITIONS. (See LUP-BASE.MUD)."

;"A LIBLOCK represents a locked local library."

<NEWSTRUC LIBLOCK VECTOR
          ;"Channel to current library locked against writing (using FLOCK under
            UNIX, thawed (open in MODIFY mode) access under TOPS-20)."
          LL-OLD       <CHANNEL 'DISK>      
          ;"Channel to shadow copy of library. Changes modify this file."
	  LL-NEW       <CHANNEL 'DISK>
          ;"Channel to log file for update record."
	  LL-LOG       <CHANNEL 'DISK>      
          ;"The files (names) in LL-TMP-FILES are to be renamed to the
            corresponding files (names) in LL-ADD-FILES when the updated
            library is installed."
	  LL-ADD-FILES <LIST [REST STRING]> 
	  LL-TMP-FILES <LIST [REST STRING]>
          ;"The files (names) in LL-DEL-FILES are to be deleted when the updated
            library is installed."
	  LL-DEL-FILES <LIST [REST STRING]> 
          ;"Unique suffix for generating temporary file names."
	  LL-SUFFIX    FIX>

<MSETG LOCK-FILE 6>                         ;"Mask for locking in FLOCK (UNIX)."
<MSETG UNLOCK-FILE 8>                       ;"Mask for releasing in FLOCK."

<PUT-DECL DSK '<CHANNEL 'DISK>>             ;"Convenient synonym."

<ENV-COND (("MACHINE" "TOPS20")             
           ;"Suppress generation number in NAME CHANNEL-OP under TOPS-20."
           <MSETG NO-GENERATION *56*>
           ;"Following dont exist under TOPS20."
           <EVAL <PARSE "<PUT-DECL NET '<CHANNEL 'NETWORK>>">>
           <EVAL <PARSE "<NEWTYPE NET-ADDRESS UVECTOR>">>)
          (("MACHINE" "VAX")
           ;"No effect on vax."
           <MSETG NO-GENERATION *77*>)>

<END-DEFINITIONS>

