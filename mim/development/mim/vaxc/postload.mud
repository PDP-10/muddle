
<SETG DEAD-MIM-CODES
      <UVECTOR ,ADD!-MIMOP ,SUB!-MIMOP ,AND!-MIMOP ,XOR!-MIMOP ,EQV!-MIMOP>>

<MSETG FT-ADDR <TYPE-CODE FALSE EXTWORD>>

<SET REDEFINE T>

;<DEFINE FLOATCONVERT (CNS "AUX" RES) 
	#DECL ((CNS) <OR FIX FLOAT>)
	<COND (<==? .CNS 0.0000000> 0)
	      (ELSE
	       <SET RES
		    <COND (<L? .CNS 0.0000000> <PUTBITS 0 <BITS 1 15> 1>)
			  (ELSE 0)>>
	       <SET CNS <CHTYPE <ABS .CNS> FIX>>
	       <COND (<NOT <0? <CHTYPE <ANDB .CNS 4> FIX>>>
		      <SET CNS <+ .CNS 8>>)>
	       <SET RES
		    <PUTBITS .RES <BITS 8 7> <GET-FIELD .CNS <BITS 8 27>>>>
	       <SET RES <PUTBITS .RES <BITS 16 16>
				 <GET-FIELD .CNS <BITS 16 2>>>>
	       <CHTYPE <PUTBITS .RES <BITS 7> <GET-FIELD .CNS <BITS 7 19>>>
		       FIX>)>>

;<DEFINE FLOAT-IMM (X) #DECL ((X) FIX)
	<COND (<AND <0? <CHTYPE <ANDB .X *777777736017*> FIX>>
		    <NOT <0? <CHTYPE <ANDB .X *40000*> FIX>>>>
	       <MA-IMM <CHTYPE <GETBITS .X <BITS 6 4>> FIX>>)
	      (ELSE <MA-IMM .X>)>>

;<DEFINE FIX-CONSTANT? (CONST) 
	#DECL ((CONST) ANY)
	<COND (<TYPE? .CONST FLOAT> <FLOATCONVERT .CONST>)
	      (<==? <TYPEPRIM <TYPE .CONST>> FIX>
	       <SET CONST <CHTYPE .CONST FIX>>
	       <COND (<==? .CONST <CHTYPE <MIN> FIX>> ,32MIN)
		     (<==? .CONST <CHTYPE <MAX> FIX>> ,32MAX)
		     (.CONST)>)
	      (<AND <==? <TYPEPRIM <TYPE .CONST>> LIST> <EMPTY? .CONST>> 0)>>


<SET REDEFINE <>>