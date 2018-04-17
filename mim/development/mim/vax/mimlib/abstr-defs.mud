<DEFINITIONS "ABSTR-DEFS">

<USE "NEWSTRUC" "SORTX" "ABSTR">

;"*** Object Definitions. ***"

;"A DU (Description Unit) models a package - created during using/loading.
  The same structure is used to model definition modules: the distinction
  between packages and definition modules is the presence or absence of
  the internal oblist in the DU, respectively."

<NEWSTRUC DU VECTOR
	  DU-NAME STRING                    ;"Name of package."
	  DU-OBL OBLIST                     ;"Entry oblist."
	  DU-IOBL <OR OBLIST FALSE>         ;"Internal oblist."
	  DU-ENTRIES <LIST [REST ATOM]>     ;"Entrys."
	  DU-RENTRIES <LIST [REST ATOM]>    ;"Rentrys."
	  DU-USES <LIST [REST DU]>          ;"Packages used."
	  DU-EXPORTS <LIST [REST DU]>       ;"Packages exported."
	  DU-INCLUDES <LIST [REST DU]>      ;"Definitions included."
	  DU-SPECIAL <LIST [REST FORM]>     ;"Special forms."
	  DU-MARKED <OR ATOM FALSE>>        ;"If du is used by toplevel du."

;"Macros for un/marking DUs."

<DEFMAC DU-MARKED? ('DU) <FORM DU-MARKED .DU>>

<DEFMAC MARK-DU ('DU) <FORM DU-MARKED .DU T>>

<DEFMAC UNMARK-DU ('DU) <FORM DU-MARKED .DU %<>>>

;"An ABSTRACTION is used for accumulating forms that will appear in abstract.
  It is a vector of four queues, one for each of the four kinds of forms that
  appear in an abstract: SETG, NEWTYPE and PUT-DECL, MANIFEST, GDECL."

<NEWSTRUC ABSTRACTION VECTOR
	  A-GVALS <LIST ATOM [REST FORM]>   ;"SETG forms."
	  A-GTAIL <LIST ANY>                ;"Tail of above."
	  A-TYPES <LIST ATOM [REST FORM]>   ;"NEWTYPE, PUT-DECL forms."
	  A-TTAIL <LIST ANY>                ;"Tail of above."
	  A-CONST <LIST [REST ATOM]>        ;"MANIFEST atoms."
	  A-DECLS LIST>                     ;"Body of GDECL form."

;"NEW-ABSTRACTION - Return an empty abstraction."

<DEFMAC NEW-ABSTRACTION ()
   ;"The atoms TYPES, GVALS are handles for PUTREST (enqueueing)."
   '<BIND ((GVALS (GVAL)) (TYPES (TYPE)))
       #DECL ((GVALS TYPES) <LIST ATOM>)
       <CHTYPE [.GVALS .GVALS .TYPES .TYPES () ()] ABSTRACTION>>>

;"ENQ-GVAL - Append <SETG ATOM GVAL> to gvals queue of ABSTRACTION."

<DEFMAC ENQ-GVAL ('ABSTRACTION 'ATOM 'GVAL)
   <FORM BIND ((A .ABSTRACTION) (TAIL (<FORM CHTYPE (SETG .ATOM .GVAL) FORM>)))
	 '#DECL ((A) ABSTRACTION (TAIL) <LIST FORM>)
	 '<PUTREST <A-GTAIL .A> .TAIL>
	 '<A-GTAIL .A .TAIL>>>

;"ENQ-TYPE - Append PUT-DECL, NEWTYPE, NEW-CHANNEL-TYPE FORM to types
  queue of ABSTRACTION."

<DEFMAC ENQ-TYPE ('ABSTRACTION 'FORM)
   <FORM BIND ((A .ABSTRACTION) (TAIL (.FORM)))
	 '#DECL ((A) ABSTRACTION (TAIL) <LIST FORM>)
	 '<PUTREST <A-TTAIL .A> .TAIL>
	 '<A-TTAIL .A .TAIL>>>

;"ENQ-CONST - Add ATOM to const (MANIFEST) list of ABSTRACTION."

<DEFMAC ENQ-CONST ('ABSTRACTION 'ATOM)
   <FORM BIND ((A .ABSTRACTION))
	 '#DECL ((A) ABSTRACTION)
	 <FORM A-CONST '.A (.ATOM '!<A-CONST .A>)>>>

;"ENQ-DECL - Add decl D for N to decls (GDECL) list of ABSTRACTION."

<DEFMAC ENQ-DECL ('A 'N 'D)
   ;"If there is a decl = D in decls, add N to the list.
     Else, append a decl pair to decls."
   <FORM BIND ((AA .A) (NN .N) (DD .D) '(DECLS <A-DECLS .AA>))
	 '#DECL ((AA) ABSTRACTION (NN) ATOM (DD) <OR ATOM SEGMENT>
		 (DECLS) LIST)
	 '<COND (<EMPTY? .DECLS>
		 <A-DECLS .AA ((.NN) .DD)>)
		(T
		 <REPEAT (RDECLS)
		    #DECL ((RDECLS) LIST)
		    <COND (<=? <1 <SET RDECLS <REST .DECLS>>> .DD>
			   <PUT .DECLS 1 (.NN !<1 .DECLS>)>
			   <RETURN>)
			  (<EMPTY? <SET DECLS <REST .RDECLS>>>
			   <PUTREST .RDECLS ((.NN) .DD)>
			   <RETURN>)>>)>>>

;"BLURB - Concatenate and print several strings to OUTCHAN if ABSTRACT-NOISY?."

<DEFMAC BLURB ("ARGS" BLURB)
   <FORM COND (',ABSTRACT-NOISY?
	       '<CRLF>
	       <FORM PRINTSTRING <FORM STRING !.BLURB>>)>>

;"SORTA, SORTS - Sort vectors of atoms and strings"

<DEFMAC SORTA ('V)
   <FORM BIND ((VV .V))
	 '#DECL ((VV) VECTOR)
	 '<COND (<EMPTY? .VV> .VV) (T <SORT ,ALESS? .VV> .VV)>>>

<DEFMAC SORTS ('V)
   <FORM BIND ((VV .V))
       '#DECL ((VV) VECTOR)
       '<COND (<EMPTY? .VV> .VV) (T <SORT %<> .VV> .VV)>>>

;"EXTRACT-NM1 - Get the first name from a file spec."

<DEFMAC EXTRACT-NM1 ('STRING)
   <FORM BIND ((CH <FORM CHANNEL-OPEN PARSE .STRING>)
	       '(NAME1 <CHANNEL-OP .CH NM1>))
	 '#DECL ((CH) <CHANNEL 'PARSE> (NAME1) STRING)
	 '<CHANNEL-CLOSE .CH>
	 '.NAME1>>

;"*** Definitions which depend on implementation of MDL environment. ***"

<UNMANIFEST OLD-TYPES>

<GDECL (OLD-TYPES) FIX (ATOM-TABLE) VECTOR> ;"External."

;"NEWTYPE-ATOM? - Return false if TYPE-NAME is not the name of a new type."

<DEFMAC NEWTYPE-ATOM? ('ATOM)
   <FORM AND <FORM VALID-TYPE? .ATOM>
	     <FORM G? <FORM LSH <FORM TYPE-C .ATOM> -6> ',OLD-TYPES>>>

;"NEWTYPE-OBJECT - Return false if type of OBJECT is not a new type."

<DEFMAC NEWTYPE-OBJECT? ('OBJECT)
   <FORM G? <FORM LSH <FORM TYPE-C <FORM TYPE .OBJECT>> -6> ',OLD-TYPES>>

;"Offsets for extracting interesting things from msubrs and macros."

<MSETG IMSUBR-NAME <OFFSET 1 '<PRIMTYPE VECTOR>>>

<MSETG MSUBR-NAME <OFFSET 2 '<PRIMTYPE VECTOR>>>

<MSETG MSUBR-ARG-DECL <OFFSET 3 '<PRIMTYPE VECTOR>>>

<MSETG IMSUBR-OFFSET <OFFSET 4 '<PRIMTYPE VECTOR>>>

<MSETG MACRO-BODY <OFFSET 1 '<PRIMTYPE LIST>>>

;"MSUBR-IMVECTOR - Return the mvector of the imsubr associated with MSUBR."

<DEFMAC MSUBR-IMVECTOR ('MSUBR)
   <FORM REST <FORM 1 <FORM GVAL <FORM IMSUBR-NAME .MSUBR>>>>>

;"MSUBR-IMSUBR - Return the imsubr associated with MSUBR."

<DEFMAC MSUBR-IMSUBR ('MSUBR) <FORM GVAL <FORM IMSUBR-NAME .MSUBR>>>

<END-DEFINITIONS>