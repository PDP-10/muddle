<DEFINITIONS "STORAGE-DEFS">

<USE "NEWSTRUC">

<COND (<FEATURE? "COMPILER"> <SET REDEFINE T>)>

"Storage types (low-order part of type code)"
<MSETG $PFIX 0>
<MSETG $PLIST 1>
<MSETG $PRECORD 2>
<MSETG $PBYTES 4>
<MSETG $PSTRING 5>
<MSETG $PUVECTOR 6>
<MSETG $PVECTOR 7>

<DEFMAC ADDR-S ('S) 
	<FORM PROG
	      ((RESULT .S))
	      '<IFSYS ("TOPS20"
		       <SET RESULT
			    <+ <ANDB <CALL VALUE .RESULT> 1073741823> 1>>)>
	      '.RESULT>>

<DEFMAC GET-SAT-FROM-TYPEC ('TYPE-CODE)
   <FORM ANDB .TYPE-CODE *77*>>

<DEFMAC GET-SAT-FROM-OBJ ('OBJ)
   <FORM ANDB <FORM CALL TYPE .OBJ> *77*>>

"Offsets into ZONE"
<MSETG GC-PARAMS <OFFSET 1 ZONE GC-PARAMS>>
<MSETG GC-FCN <OFFSET 2 ZONE>>
<MSETG MOVE-FCN <OFFSET 3 ZONE>>
<MSETG GROW-FCN <OFFSET 4 ZONE>>
<MSETG ZONE-ID <OFFSET 5 ZONE FIX>>
<MSETG ALL-SPACES <OFFSET 6 ZONE LIST>>
<MSETG GC-CTL <OFFSET 7 ZONE '<OR FALSE UVECTOR>>>

"Offsets into GC-CTL slot, if non-false"
<MSETG GCC-MIN-SPACE 1>
<MSETG GCC-MS-FREQ 2>
<MSETG GCC-MS-CT 3>

"Offsets in GC-PARAMS"
<MSETG RCL <OFFSET 1 GC-PARAMS>>
<MSETG RCLV <OFFSET 2 GC-PARAMS>>
<MSETG RCLV1 <OFFSET 3 GC-PARAMS>>
<MSETG RCLV2 <OFFSET 4 GC-PARAMS>>
<MSETG RCLV3 <OFFSET 5 GC-PARAMS>>
<MSETG RCLV4 <OFFSET 6 GC-PARAMS>>
<MSETG RCLV5 <OFFSET 7 GC-PARAMS>>
<MSETG RCLV6 <OFFSET 8 GC-PARAMS>>
<MSETG RCLV7 <OFFSET 9 GC-PARAMS>>
<MSETG RCLV8 <OFFSET 10 GC-PARAMS>>
<MSETG RCLV9 <OFFSET 11 GC-PARAMS>>
<MSETG RCLV10 <OFFSET 12 GC-PARAMS>>
<MSETG GCSBOT <OFFSET 13 GC-PARAMS>>
<MSETG GCSMIN <OFFSET 14 GC-PARAMS>>
<MSETG GCSMAX <OFFSET 15 GC-PARAMS>>
<MSETG GCSFLG <OFFSET 16 GC-PARAMS>>

"Offsets into AREA"
<MSETG ABOT <OFFSET 1 AREA>>
<MSETG AMIN <OFFSET 2 AREA>>
<MSETG AMAX <OFFSET 3 AREA>>
<MSETG AFLGS <OFFSET 4 AREA>>

<END-DEFINITIONS>