<DEFINITIONS "GC-DUMP-DEFS">

<USE "NEWSTRUC" "BACKQUOTE">

<GDECL (SPACE-END AL OLD-TYPES WORDS-NEEDED NUMBER-OF-NEWTYPES) FIX
       (DUMP-FRAME READ-FRAME) FRAME (NEW-ZONE) ZONE
       (ATOM-TABLE) <VECTOR [REST LIST]>
       (M$$TYPE-INFO!-INTERNAL) <VECTOR [REST <OR FALSE TYPE-ENTRY>]>>

<MSETG STYPE-FIX 0> ;"The magic storage types--used in CASE statements"
<MSETG STYPE-LIST 1>
<MSETG STYPE-RECORD 2>
<MSETG STYPE-BYTES 4>
<MSETG STYPE-STRING 5>
<MSETG STYPE-UVECTOR 6>
<MSETG STYPE-VECTOR 7>

<MSETG LENGTH-ATOM 7> ;"The length in words of various objects."
<MSETG LENGTH-OFFSET 8>
<MSETG LENGTH-GBIND 7>
<MSETG LENGTH-TYPE-ENTRY 16>
<MSETG LENGTH-LIST 3>

<MSETG LENUU-GBIND 10> ;"The `LENUU' of various objects."
<MSETG LENUU-ATOM 10>

<MSETG TYPE-C-STRING <TYPE-C STRING>>
<MSETG TYPE-C-ATOM <TYPE-C ATOM>>
<MSETG TYPE-C-GBIND <TYPE-C GBIND>>
<MSETG TYPE-C-UVECTOR <TYPE-C UVECTOR>>
<MSETG TYPE-C-LIST <TYPE-C LIST>>

<DEFMAC ADDR-S ('S) 
	<FORM PROG
	      ((RESULT .S))
	      '<IFSYS ("TOPS20"
		       <SET RESULT
			    <+ <ANDB <CALL VALUE .RESULT> 1073741823> 1>>)>
	      '.RESULT>>

<DEFMAC RIGHT-ATOM ('ATM 'OFF) 
   `<BIND ((ATM ~.ATM) (OFF ~.OFF) (VAL <CALL VALUE .ATM>))
       #DECL ((ATM) <PRIMTYPE ATOM> (OFF VAL) FIX)
       <COND (<==? .VAL -1>
	      <CHTYPE ROOT <TYPE .ATM>>)
	     (ELSE
	      <CHTYPE <FIXUP-ATOM <CALL OBJECT
					,TYPE-C-ATOM
					,LENUU-ATOM
					<+ .VAL .OFF>>
				  .OFF>
		      <TYPE .ATM>>)>>>

<DEFMAC PAIR-UP ('OC 'NC)
   `<BIND ((OC ~.OC) (NC ~.NC) 
	   (OLD-CODES ,OLD-CODES) (NEW-CODES ,NEW-CODES))
       #DECL ((OLD-CODES NEW-CODES) <<PRIMTYPE VECTOR> <PRIMTYPE FIX>>
	      (OC NC) TYPE-C)
       <1 .OLD-CODES .OC>
       <SETG OLD-CODES <REST .OLD-CODES>>
       <1 .NEW-CODES .NC>
       <SETG NEW-CODES <REST .NEW-CODES>>>>

<END-DEFINITIONS>