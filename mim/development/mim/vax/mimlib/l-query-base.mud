;"*****************************************************************************

  This file defines a means for mapping over all records in LOCAL library.
  Used by iterative queries in L-QUERY and the server for handling the same
  over the network.

  L-QUERY-BASE.MUD: EDIT HISTORY                            Machine Independent

  COMPILATION: Spliced in at compile time.

  JUN84   [Shane] - Created.
  8OCT84  [Shane] - Commented, cleaned up.

  ****************************************************************************"

;"MAP-RECORDS --
  Effect:    Create a state descriptor for NEXT-RECORD (somewhat like
	     ASSOCIATIONS). The state descriptor is a UVECTOR with the
	     following format:

	     [next-bucket bucket-cdr last-bucket]

	     where next-bucket is the file address of the next bucket in
		   the hash table to examine (initially the first bucket).
		   bucket-cdr is the file address of the next cons in the
		   current bucket if it contained a list, else nil (0).
		   (initially nil).
		   last-bucket is the file address of the last bucket in
		   the hash table.
   Modifies: STATE, LIB (the channel access pointer).
   Returns:  state descriptor (UVECTOR).
   Requires: LIB is channel to correctly formatted library file (as defined
	     in LIBRARY.FORMAT), size(STATE) >= 3.
   Note:     The offsets are defined in L-DEFS.MUD."

<DEFINE MAP-RECORDS (LIB:<CHANNEL 'DISK>
		     "OPT" (STATE:<UVECTOR [3 FIX]> <IUVECTOR 3>))
   ;"The address of the first bucket is DIR-HDRLEN. The address of the
     last bucket is DIR-HDRLEN+DIR-TABSIZ-1. Point to DIR-TABSIZ and read."
   <SETADR .LIB ,DIR-TABSIZ>
   <LAST-BUCKET .STATE <+ <RDWRD .LIB>:FIX %<- ,DIR-HDRLEN 1>>>
   <BUCKET-CDR .STATE 0>
   <NEXT-BUCKET .STATE ,DIR-HDRLEN>>

;"NEXT-RECORD --
  Effect:   Determine the file address of the next record in the iteration
	    over the library. Addresses are yielded in bucket order, position
	    in bucket list (if bucket contains a list).
  Modifies: STATE, LIB (the channel access pointer).
  Returns:  File address of next record in sequence if any, else false.
  Requires: LIB is channel to correctly formatted library file (as defined in
	    LIBRARY.FORMAT), STATE is a state descriptor created by MAP-RECORDS
	    and modified by NEXT-RECORD (only!)."

<DEFINE NEXT-RECORD (LIB:<CHANNEL 'DISK> STATE:<UVECTOR [3 FIX]>)
   <REPEAT ((LAST:FIX <LAST-BUCKET .STATE>) (BKT:FIX <NEXT-BUCKET .STATE>)
	    (BCDR:FIX <BUCKET-CDR .STATE>) BCAR:FIX "NAME" NEXTR)
      <COND (<N==? .BCDR 0>                    ;"Are we in a list?"
	     <SETADR .LIB .BCDR   >            ;"Point to cons."
	     <SET BCAR <RDWRD .LIB>>           ;"Pointer to car."
	     <SET BCDR <RDWRD .LIB>>           ;"Pointer to cdr."
	     <COND (<TESTBIT .BCAR ,BKT-P>     ;"Package?"
		    <NEXT-BUCKET .STATE .BKT>  ;"Set things up for next time."
		    <BUCKET-CDR .STATE .BCDR>
		    <RETURN <ADDRESS .BCAR> .NEXTR>)
		   (T
		    <AGAIN .NEXTR>)>)          ;"Check out the cdr."
	    (T                                 ;"Empty bucket or end of list."
	     <REPEAT ()
		<COND (<G? .BKT .LAST>         ;"Every bucket done?"
		       <NEXT-BUCKET .STATE .BKT>
		       <BUCKET-CDR .STATE 0>
		       <RETURN %<> .NEXTR>)
		      (T
		       <SETADR .LIB .BKT>       ;"Point to next bucket."
		       <SET BKT <+ .BKT 1>>	;"Bump next."
		       <SET BCAR <RDWRD .LIB>>	;"Read current bucket."
		       <COND (<TESTBIT .BCAR ,BKT-M>	;"List?"
			      <SET BCDR <ADDRESS .BCAR>>
			      <RETURN>)     ;"Check out first cons above."
			     (<TESTBIT .BCAR ,BKT-P>	;"Package?"
			      <NEXT-BUCKET .STATE .BKT>;"Next."
			      <BUCKET-CDR .STATE 0>	;"Not in list."
			      <RETURN <ADDRESS .BCAR> .NEXTR>)>)>>)>>>
