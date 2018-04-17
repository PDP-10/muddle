<PACKAGE "ABSTR">

;"*****************************************************************************

 ABSTR.MUD: EDIT HISTORY                                    Machine Independent

   COMPILATION: NOT CAREFUL, GLUEABLE

   1JUN84  [Shane] - Created package for abstracting compiled packages.
   18JUL84 [Shane] - Support definition modules.
   19JUL84 [Shane] - Divided abstract forms into 4 collection categories.
		     Support USE-WHEN, INCLUDE-WHEN, USE-DEFER.
   25JUL84 [Shane] - Cannot abstract RPACKAGE.
   30JUL84 [Shane] - Group loading is optional in DESCRIBE-PACKAGE.
   4AUG84  [Shane] - Sort vectors in PKGINFO. Add stupid optional arguments
		     for ABSTR END-DEFINITIONS, PACKAGE, ENDPACKAGE.
   7AUG84  [Shane] - Flush group loading feature in DESCRIBE-PACKAGE. Look
		     for MBIN files. Use filenames package.
  14AUG84  [Shane] - Flushed ABSTRACT-PACKAGES, add validation of USED-DU-LIST
		     so that DU's are built only once if possible. USED-DU-LIST
		     retains state between invocations of abstraction process.
  16AUG84  [Shane] - Mung MSUBR IMSUBR names and code offsets to set up for
		     magic loading of packages in compiler when an abstracted
		     MSUBR is called. The magic msubr loader must be named
		     ABSTRACT-MSUBR-LOADER and the corresponding IMSUBR must
		     be named abstract-msubr-loader-IMSUBR on the ROOT oblist
		     for this scheme to work.
  26AUG84  [Shane] - Flushed FILENAMES package since no one used it except me.
		     FILENAMES survives as new function SEARCH and macro
		     EXTRACT-NM1. Moved macros, internal type definitions to
		     definitions ABSTR-DEFS. Flushed usage of NEWSTRUC - define
		     PKGINFO type with MDL primitives.
  28AUG84  [Shane] - Support abstraction of NEW-CHANNEL-TYPE. Remove use of
		     associations. SEARCH is an ENTRY. Rewrite DU-DEFINES? and
		     others because of compiler woes. Channel types collected
		     in global NEW-CHANNEL-TYPES list.
  31AUG84  [Shane] - Flush module oblist when we build a DU if it's around.
		     See ABSTR-PACKAGE, ABSTR-DEFINITIONS. Mung copy of msubr -
		     see ABSTR-GROVEL. Updated PRELOADED package vector. USE
		     ABSTR-LOADER to get name of magic IMSUBR.
   5SEP84  [Shane] - Support abstraction of ADD-CHANNEL-OPS: similar to
		     NEW-CHANNEL-TYPE except for the name. These are no
		     longer collected in global list. DU's now contain a list
		     of special forms to be added to the abstract. Added
		     ABSTR-GROVEL-SPECIAL which checks these forms and takes
		     action based on the first element of the form. Future
		     special forms should use this mechanism - see
		     ABSTR-ADD-CHANNEL-OPS, ABSTR-NEW-CHANNEL-TYPE,
		     REDEFINE-ENVIRONMENT, RESTORE-ENVIRONMENT for example
		     of how to add special forms. See ABSTR-GROVEL-SPECIAL
		     for example of how to process them.
  20FEB85  [Shane] - Added switch ABSTRACT-IGNORE? - controls whether or
		     not file not found events cause errors.

 *****************************************************************************"

<ENTRY ABSTRACT-PACKAGE DESCRIBE-PACKAGE PKGINFO PKG-NAME PKG-CODE PKG-SOURCE
       PKG-ABSTRACT PKG-ENTRYS PKG-RENTRYS PKG-USES PKG-EXPORTS PKG-INCLUDES
       PKG-TYPE ABSTRACT-CAREFUL? ABSTRACT-NOISY? SEARCH ABSTRACT-IGNORE?>

;"<ABSTRACT-PACKAGE package:STRING OPT abstract:<OR STRING FALSE>>
  if package can be abstracted
     if abstract is unbound or not false
	returns the name of the abstract file (default: package.abstr)
     else
	returns vector of two elements:
	[1] list of forms representing package abstract
	[2] the associated oblist path
  else
     returns false describing why package cannot be abstracted."

;"<DESCRIBE-PACKAGE fn:STRING OPT abstract?:<OR ATOM FALSE>>
  Returns a PKGINFO for package contained in fn. If abstract? is T, the
  PKGINFO will contain an abstract for package (if it can be abstracted),
  otherwise false. Default: T. Note: fn can be either a package name or a
  file name. See description of PKGINFO below."

;"ABSTRACT-CAREFUL?:<OR ATOM FALSE> - If false, analysis of macros
  is inhibited. False is appropriate if no macro in the package to be
  abstracted references internal types, calls a non-primitive procedure, or
  references another package. Default: T."

;"ABSTRACT-NOISY?:<OR ATOM FALSE> - If false, loading messages are
  suppressed. Default: T."

;"ABSTRACT-IGNORE?:<OR ATOM FALSE> - If true, use of packages not found is
  ignored (an error message is written), else an error occurs."

;"<SEARCH name:STRING oper:ATOM OPT path:LIST second-names:VECTOR>
  Search path (default L-SEARCH-PATH) for file named name using
  second-names. If not found, result is false. Otherwise, result
  depends on oper (NAME -> STRING file name, VECTOR -> VECTOR of STRING
  file name components, CHANNEL -> CHANNEL open to file."

<USE "SORTX" "ABSTR-LOADER">

<INCLUDE-WHEN <COMPILING? "ABSTR"> "ABSTR-DEFS">

;"*** Object Definitions. ***"

;"A PKGINFO contains everything you ever wanted to know about a package or
  definition module. This structure is returned by DESCRIBE-PACKAGE. The
  meaning of the fields is as follows:

	PKG-TYPE:       Either PACKAGE or DEFINITIONS.
	PKG-NAME:       Name of described package.
	PKG-CODE:       Name of package msubr file, if any.
	PKG-SOURCE:     Name of package mud file, if any.
	PKG-ENTRYS:     Entrys of package: sorted.
	PKG-RENTRYS:    Rentrys of package: sorted.
	PKG-USES:       Names of packages used by package: sorted.
	PKG-EXPORTS:    Names of packages exported by package: sorted.
	PKG-INCLUDES:   Names of definitions included by package: sorted.
	PKG-ABSTRACT:   False if package was not abstracted, else
			a vector whose first element is the forms of the
			abstract and whose second element is the associated
			oblist path."

<COND (<NOT <VALID-TYPE? PKGINFO>>            ;"Who needs NEWSTRUC?"
       <BIND ((PKGINFO '<<PRIMTYPE VECTOR> ATOM
					   STRING
					   <OR FALSE !<VECTOR [5 STRING]>>
					   <OR FALSE !<VECTOR [5 STRING]>>
					   <VECTOR [REST ATOM]>
					   <VECTOR [REST ATOM]>
					   <VECTOR [REST STRING]>
					   <VECTOR [REST STRING]>
					   <VECTOR [REST STRING]>
					   <OR FALSE !<VECTOR [2 LIST]>>>))
	  <NEWTYPE PKGINFO VECTOR .PKGINFO>
	  <SETG PKG-TYPE     <OFFSET 1  PKGINFO <2  .PKGINFO>>>
	  <SETG PKG-NAME     <OFFSET 2  PKGINFO <3  .PKGINFO>>>
	  <SETG PKG-CODE     <OFFSET 3  PKGINFO <4  .PKGINFO>>>
	  <SETG PKG-SOURCE   <OFFSET 4  PKGINFO <5  .PKGINFO>>>
	  <SETG PKG-ENTRYS   <OFFSET 5  PKGINFO <6  .PKGINFO>>>
	  <SETG PKG-RENTRYS  <OFFSET 6  PKGINFO <7  .PKGINFO>>>
	  <SETG PKG-USES     <OFFSET 7  PKGINFO <8  .PKGINFO>>>
	  <SETG PKG-EXPORTS  <OFFSET 8  PKGINFO <9  .PKGINFO>>>
	  <SETG PKG-INCLUDES <OFFSET 9  PKGINFO <10 .PKGINFO>>>
	  <SETG PKG-ABSTRACT <OFFSET 10 PKGINFO <11 .PKGINFO>>>
	  <MANIFEST PKG-TYPE PKG-NAME PKG-CODE PKG-SOURCE PKG-ENTRYS
		    PKG-RENTRYS PKG-USES PKG-EXPORTS PKG-INCLUDES
		    PKG-ABSTRACT>>)>

;"Internal types defined in ABSTR-DEFS."

<COND (<NOT <VALID-TYPE? ABSTRACTION>> <NEWTYPE ABSTRACTION VECTOR>)>

<COND (<NOT <VALID-TYPE? DU>> <NEWTYPE DU VECTOR>)>

;"Names of preloaded packages - 1SEP84."

<SETG PRELOADED
      '["ARITH2" "SUBSTR" "FINDATOM" "MAP" "LIBRARY" "GC" "AMP" "PURIFY"
	"MISC-IO" "CHANNEL-OPERATION" "EDIT" "ENV" "GRLOAD" "DECLS" "INT"
	"HOMEDIR" "PKG" "ASOC" "PP" "TTY" "NETBASE"]
      '<VECTOR [REST STRING]>>

;"Preserve pointers to redefined package/definitions operations."

<GDECL (*PACKAGE *ENDPACKAGE *RENTRY *USE *EXPORT *USE-WHEN *USE-TOTAL
	*USE-DEFER *INCLUDE *INCLUDE-WHEN *DEFINITIONS *END-DEFINITIONS
	*RPACKAGE *NEW-CHANNEL-TYPE *ADD-CHANNEL-OPS) <OR APPLICABLE FALSE>>

<COND
 (<NOT <FEATURE? "COMPILER">>
  <SETG *PACKAGE <AND <GASSIGNED? PACKAGE> ,PACKAGE>>
  <SETG *ENDPACKAGE <AND <GASSIGNED? ENDPACKAGE> ,ENDPACKAGE>>
  <SETG *RENTRY <AND <GASSIGNED? RENTRY> ,RENTRY>>
  <SETG *ENTRY <AND <GASSIGNED? RENTRY> ,ENTRY>>
  <SETG *USE <AND <GASSIGNED? USE> ,USE>>
  <SETG *EXPORT <AND <GASSIGNED? EXPORT> ,EXPORT>>
  <SETG *USE-WHEN <AND <GASSIGNED? USE-WHEN> ,USE-WHEN>>
  <SETG *USE-TOTAL <AND <GASSIGNED? USE-TOTAL> ,USE-TOTAL>>
  <SETG *USE-DEFER <AND <GASSIGNED? USE-DEFER> ,USE-DEFER>>
  <SETG *INCLUDE <AND <GASSIGNED? INCLUDE> ,INCLUDE>>
  <SETG *INCLUDE-WHEN <AND <GASSIGNED? INCLUDE-WHEN> ,INCLUDE-WHEN>>
  <SETG *DEFINITIONS <AND <GASSIGNED? DEFINITIONS> ,DEFINITIONS>>
  <SETG *END-DEFINITIONS <AND <GASSIGNED? END-DEFINITIONS> ,END-DEFINITIONS>>
  <SETG *RPACKAGE <AND <GASSIGNED? RPACKAGE> ,RPACKAGE>>
  <SETG *NEW-CHANNEL-TYPE
	<AND <GASSIGNED? NEW-CHANNEL-TYPE> ,NEW-CHANNEL-TYPE>>
  <SETG *ADD-CHANNEL-OPS
	<AND <GASSIGNED? ADD-CHANNEL-OPS> ,ADD-CHANNEL-OPS>>)>

;"*** Global State. ***"

;"ABSTRACT-CAREFUL? - If false, macros are not checked. If it is known
  that macros in a package call only primitive operations and that all types
  in the macro are primitive or defined by entrys or rentrys then false is
  appropriate. Default is careful."

<OR <GASSIGNED? ABSTRACT-CAREFUL?> <SETG ABSTRACT-CAREFUL? T '<OR ATOM FALSE>>>

;"ABSTRACT-NOISY? - Controls whether or not loading messages are printed.
  Default is noisy."

<OR <GASSIGNED? ABSTRACT-NOISY?> <SETG ABSTRACT-NOISY? T '<OR ATOM FALSE>>>

;"ABSTRACT-IGNORE? - Controls behavior in the event that a package cannot be
  loaded. Default is careful."

<OR <GASSIGNED? ABSTRACT-IGNORE?> <SETG ABSTRACT-IGNORE? %<> '<OR ATOM FALSE>>>

;"DU-LIST-VALID? - T iff last abstraction returned normally."

<SETG DU-LIST-VALID? %<> '<OR ATOM FALSE>>

;"TOPLEVEL-DU - Represents the package to be abstracted: initially false."

<GDECL (TOPLEVEL-DU) <OR DU FALSE>>

;"CURRENT-DU - Points to the DU under construction for package or definition
  module that is currently being evaluated."

<GDECL (CURRENT-DU) DU>

;"USED-DU-LIST - Contains every DU ever created during abstraction
  process so that DUs can be reused. Initially empty."

;"DU-STACK - Partially completed DUs that have been pushed because the
  corresponding source files used other packages for which DUs must be
  constructed. Initially empty."

<GDECL (USED-DU-LIST DU-STACK) <LIST [REST DU]>>

;"ABSTRACT - Contains the body of the abstraction and its associated oblist
  path. Initially empty, forms are enqueued as needed during abstraction."

<GDECL (ABSTRACT) ABSTRACTION>

;"NAME-STACK - Top is the atom currently being analyzed. Maintained by
  ABSTR-GROVEL for informational purposes in the event of an error."

;"ABSTRACTED - Contains every atom that has been ABSTRACTED during
  abstraction process to break recursion and prevent duplications."

<GDECL (ABSTRACTED NAME-STACK) <LIST [REST ATOM]>>

;"*** Operations ***"

;"ABSTRACT-PACKAGE - Given the name of a package or definition module to
  abstract, analyzes the package to determine the minimum amount of
  information necessary to describe the interface. Writes the information
  to specified file. All functions to be abstracted must be compiled.
  Returns the abstract (file name or forms) if successful, else false."

<DEFINE ABSTRACT-PACKAGE AP (NAME "OPT" OFN
				  "AUX" (OCH %<>) (OBLIS .OBLIST))
   #DECL ((NAME) STRING (AP) <SPECIAL FRAME> (OFN) <OR FALSE STRING>
	  (OCH) <OR <CHANNEL 'DISK> FALSE> (OBLIS) <LIST [REST OBLIST]>)
   <SET NAME <EXTRACT-NM1 .NAME>>
   <UNWIND <BIND (ABSTR)
	      #DECL ((ABSTR) !<VECTOR [2 LIST]>)
	      <BUILD-DU .NAME>
	      <COND (<NOT ,TOPLEVEL-DU>     ;"Make sure we built a DU."
		     <BARF !,TOPLEVEL-DU ABSTRACT-PACKAGE>)>
	      <COND (<NOT <ASSIGNED? OFN>>  ;"Then use default name."
		     <BIND ((NM2 "ABSTR")
			    (CH <CHANNEL-OPEN PARSE .NAME>))
			#DECL ((NM2) <SPECIAL STRING> (CH) <CHANNEL 'PARSE>)
			<SET OFN <CHANNEL-OP .CH NAME>>
			<CHANNEL-CLOSE .CH>>)>
	      <COND (.OFN
		     <SET OCH <CHANNEL-OPEN DISK .OFN "CREATE" "ASCII">>
		     <COND (<NOT .OCH>
			    <BARF CANT-OPEN-OUTPUT-FILE!-ERRORS
				  .OFN .OCH ABSTRACT-PACKAGE>)>)>
	      ;"Create the abstraction and associated oblist path."
	      <SET ABSTR <ABSTR-CREATE>>
	      <SETG TOPLEVEL-DU %<>>
	      <CRLF>
	      <COND (.OCH
		     ;"Set up oblist path for printing abstraction and do it."
		     <BLOCK <2 .ABSTR>>
		     <MAPF %<>
			   <FUNCTION (FROB) #DECL ((FROB) FORM)
			      <PRIN1 .FROB .OCH> <CRLF .OCH>>
			   <1 .ABSTR>>
		     <ENDBLOCK>
		     <SET OFN <CHANNEL-OP .OCH NAME>>
		     <CLOSE .OCH>
		     ;"Return the name of the abstraction file."
		     .OFN)
		    (T
		     ;"Return abstraction forms and oblist path."
		     .ABSTR)>>
	   ;"If there was an error - try to clean up ..."
	   <BIND () <SET OBLIST .OBLIS> <COND (.OCH <FLUSH .OCH>)>>>>

;"DESCRIBE-PACKAGE - Constructs and returns a PKGINFO for NAME. If ABSTRACT?
  is false, no abstract will be created, otherwise an abstract is attempted
  (the abstract will be false if the package cannot be abstracted)."

<DEFINE DESCRIBE-PACKAGE (NAME "OPT" (ABSTRACT? T) "AUX" (OBLIS .OBLIST))
   #DECL ((NAME) STRING (ABSTRACT?) <OR ATOM FALSE>
	  (OBLIS) <LIST [REST OBLIST]>)
   <SET NAME <EXTRACT-NM1 .NAME>>
   <UNWIND <PROG ((ABSTR %<>) (OUTCHAN .OUTCHAN))
	      #DECL ((OUTCHAN) CHANNEL (ABSTR) <OR FALSE !<VECTOR [2 LIST]>>)
	      <BUILD-DU .NAME>
	      <COND (<NOT ,TOPLEVEL-DU> <RETURN ,TOPLEVEL-DU:FALSE>)>
	      <COND (.ABSTRACT?                  ;"Create abstract if desired."
		     <COND (<SET ABSTR <PROG AP () #DECL ((AP) <SPECIAL FRAME>)
					  <ABSTR-CREATE>>>)
			   (,ABSTRACT-NOISY?
			    <CRLF>
			    <PRINTSTRING <STRING "Cant abstract " .NAME ":">>
			    <MAPF %<>
				  <FUNCTION (R) <CRLF> <PRINC .R>>
				  .ABSTR>)>)>
	      <CRLF>
	      <BIND ((TDU ,TOPLEVEL-DU) (PATH ,L-SEARCH-PATH))
		 #DECL ((TDU) DU (PATH) <LIST [REST <OR VECTOR STRING>]>)
		 <SETG TOPLEVEL-DU %<>>
		 <CHTYPE [<COND (<DU-IOBL .TDU> PACKAGE) (T DEFINITIONS)>
			  <DU-NAME .TDU>
			  <SEARCH .NAME VECTOR .PATH '["MBIN" "GSUBR" "MSUBR"]>
			  <SEARCH .NAME VECTOR .PATH '["MUD"]>
			  <SORTA [!<DU-ENTRIES .TDU>]>
			  <SORTA [!<DU-RENTRIES .TDU>]>
			  <SORTS <MAPF ,VECTOR ,DU-NAME <DU-USES .TDU>>>
			  <SORTS <MAPF ,VECTOR ,DU-NAME <DU-EXPORTS .TDU>>>
			  <SORTS <MAPF ,VECTOR ,DU-NAME <DU-INCLUDES .TDU>>>
			  .ABSTR]
			 PKGINFO>>>
	   ;"If there was an error, try to clean up."
	   <SET OBLIST .OBLIS>>>

;"*** Description Units (DUs) are built by following routines: First Pass. ***"

;"BUILD-DU - If USED-DU-LIST is valid, and a DU for NAME is found, then
  it becomes TOPLEVEL-DU. Otherwise, the package corresponding to NAME is
  loaded, creating TOPLEVEL-DU in the process."

<DEFINE BUILD-DU (NAME "AUX" (ICH %<>))
   #DECL ((NAME) STRING (ICH) <OR CHANNEL FALSE>)
   <COND (<NOT <AND <GASSIGNED? DU-LIST-VALID?> ,DU-LIST-VALID?
		    <GASSIGNED? USED-DU-LIST>>>
	  <SETG USED-DU-LIST '()>)>
   <COND (<NOT <SETG TOPLEVEL-DU <FIND-DU .NAME>>>
	  <COND (<SET ICH <SEARCH .NAME CHANNEL>>
		 <SETG DU-LIST-VALID? %<>>
		 <UNWIND <BIND ((REDEFINE T)) #DECL ((REDEFINE) <SPECIAL ANY>)
			    <BLURB "Loading: " <CHANNEL-OP .ICH NAME>>
			    <SETG DU-STACK '()>
			    <REDEFINE-ENVIRONMENT>
			    <LOAD .ICH>
			    <RESTORE-ENVIRONMENT>
			    <CLOSE .ICH>
			    <GUNASSIGN CURRENT-DU>
			    <GUNASSIGN DU-STACK>>
			 <BIND ()
			    <RESTORE-ENVIRONMENT>
			    <CLOSE .ICH>
			    <GUNASSIGN CURRENT-DU>
			    <GUNASSIGN DU-STACK>>>
		 <SETG DU-LIST-VALID? T>)
		(T
		 <BARF <STRING "Not found: " .NAME> BUILD-DU>
		 <SETG TOPLEVEL-DU .ICH>)>)>
   T>

;"REDEFINE-ENVIRONMENT - Replace definitions of package routines with
  routines that manipulate global state (build DUs) as well as loading
  and evaluating packages (or definition modules)."

<DEFINE REDEFINE-ENVIRONMENT ()
   <SETG PACKAGE ,ABSTR-PACKAGE>
   <SETG ENDPACKAGE ,ABSTR-ENDPACKAGE>
   <SETG RENTRY ,ABSTR-RENTRY>
   <SETG ENTRY ,ABSTR-ENTRY>
   <SETG USE ,ABSTR-USE>
   <SETG EXPORT ,ABSTR-EXPORT>
   <SETG USE-WHEN ,ABSTR-USE-WHEN>
   <SETG USE-TOTAL ,ABSTR-USE-TOTAL>
   <SETG USE-DEFER ,ABSTR-USE>              ;"Disallow deferral."
   <SETG INCLUDE ,ABSTR-INCLUDE>
   <SETG INCLUDE-WHEN ,ABSTR-INCLUDE-WHEN>
   <SETG DEFINITIONS ,ABSTR-DEFINITIONS>
   <SETG END-DEFINITIONS ,ABSTR-END-DEFINITIONS>
   <SETG RPACKAGE ,ABSTR-RPACKAGE>
   <SETG NEW-CHANNEL-TYPE ,ABSTR-NEW-CHANNEL-TYPE>
   <SETG ADD-CHANNEL-OPS ,ABSTR-ADD-CHANNEL-OPS>
   T>

;"RESTORE-ENVIRONMENT - Restore normal definitions of package routines."

<DEFINE RESTORE-ENVIRONMENT ()
   <SETG PACKAGE ,*PACKAGE>
   <SETG ENDPACKAGE ,*ENDPACKAGE>
   <SETG RENTRY ,*RENTRY>
   <SETG ENTRY ,*ENTRY>
   <SETG USE ,*USE>
   <SETG EXPORT ,*EXPORT>
   <SETG USE-WHEN ,*USE-WHEN>
   <SETG USE-TOTAL ,*USE-TOTAL>
   <SETG USE-DEFER ,*USE-DEFER>
   <SETG INCLUDE ,*INCLUDE>
   <SETG INCLUDE-WHEN ,*INCLUDE-WHEN>
   <SETG DEFINITIONS ,*DEFINITIONS>
   <SETG END-DEFINITIONS ,*END-DEFINITIONS>
   <SETG RPACKAGE ,*RPACKAGE>
   <SETG NEW-CHANNEL-TYPE ,*NEW-CHANNEL-TYPE>
   <SETG ADD-CHANNEL-OPS ,*ADD-CHANNEL-OPS>
   T>

;"ABSTR-PACKAGE - Replaces definition of PACKAGE during abstraction process.
  Performs the actions that PACKAGE performs, creates a DU for the package,
  adds the new DU to USED-DU-LIST, pushes CURRENT-DU onto DU-STACK and sets
  CURRENT-DU to be the new DU."

<DEFINE ABSTR-PACKAGE (NAME "OPT" INAME
			    "AUX" OBL IOBL NEW-DU (TNAME <TRANSLATED .NAME>))
   #DECL ((NAME INAME TNAME) STRING (OBL IOBL) <OR ATOM OBLIST FALSE>
	  (NEW-DU) DU)
   <SET INAME <STRING !\I .TNAME>>
   <COND (<SET OBL <LOOKUP .TNAME #OBLIST PACKAGE>>	;"Flush previous."
	  <DROP .TNAME>
	  <REMOVE .OBL #OBLIST PACKAGE>)>
   <*PACKAGE .NAME .INAME>
   ;"Use translated name for lookup, untranslated name for DU name!"
   <SET OBL <CHTYPE <LOOKUP .TNAME #OBLIST PACKAGE> OBLIST>>
   <SET IOBL <CHTYPE <LOOKUP .INAME .OBL> OBLIST>>
   <SET NEW-DU <CHTYPE [.NAME .OBL .IOBL '() '() '() '() '() '() %<>] DU>>
   <COND (,TOPLEVEL-DU
	  <SETG DU-STACK (,CURRENT-DU !,DU-STACK)>)
	 (T ;"First package is the file to be abstracted."
	  <SETG TOPLEVEL-DU .NEW-DU>)>
   <SETG USED-DU-LIST (.NEW-DU !,USED-DU-LIST)>
   <SETG CURRENT-DU .NEW-DU>
   T>

;"ABSTR-DEFINITIONS - Replaces definition of DEFINITIONS during abstraction
  process. Performs the actions that DEFINITIONS performs, creates a DU for
  the definition module, adds the new DU to USED-DU-LIST, pushes CURRENT-DU
  onto DU-STACK and sets CURRENT-DU to be the new DU."

<DEFINE ABSTR-DEFINITIONS (NAME "AUX" OBL NEW-DU (TNAME <TRANSLATED .NAME>))
   #DECL ((TNAME NAME) STRING (OBL) <OR ATOM OBLIST FALSE> (NEW-DU) DU)
   <COND (<SET OBL <LOOKUP .TNAME #OBLIST PACKAGE>>	;"Flush previous."
	  <DROP .TNAME>
	  <REMOVE .OBL #OBLIST PACKAGE>)>
   <*DEFINITIONS .NAME>
   ;"Use translated name for lookup, untranslated name for DU name!"
   <SET OBL <CHTYPE <LOOKUP <TRANSLATED .NAME> <MOBLIST PACKAGE>> OBLIST>>
   <SET NEW-DU <CHTYPE [.NAME .OBL %<> '() '() '() '() '() '() %<>] DU>>
   <COND (,TOPLEVEL-DU
	  <SETG DU-STACK (,CURRENT-DU !,DU-STACK)>)
	 (T ;"First definitions is the file to be abstracted."
	  <SETG TOPLEVEL-DU .NEW-DU>)>
   <SETG USED-DU-LIST (.NEW-DU !,USED-DU-LIST)>
   <SETG CURRENT-DU .NEW-DU>
   T>

;"ABSTR-USE - Replaces definition of USE during abstraction process. Performs
  the actions that USE performs. If a DU does not exist, the package
  is loaded (which creates a DU) otherwise the existing DU is used. The DU
  for each name is prepended to the uses list of CURRENT-DU."

<DEFINE ABSTR-USE ("TUPLE" NAMES)
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST STRING]>)
   <PROG ((CDU ,CURRENT-DU) DU?)
      #DECL ((DU?) <OR FALSE DU> (CDU) DU)
      <COND (<NOT ,TOPLEVEL-DU>
	     <BARF TOPLEVEL-MODULE-IS-NEITHER-PACKAGE-NOR-DEFINITIONS!-ERRORS
		   ABSTR-USE>
	     <RETURN %<>>)>
      <SET NAMES
	   <MAPF ,VECTOR
		 <FUNCTION (NAME)
		    #DECL ((NAME) STRING)
		    <COND (<NOT <SET DU? <FIND-DU .NAME>>>
			   <LOAD-PACKAGE .NAME>
			   <SET DU? <FIND-DU .NAME>>)>
		    <COND (.DU?
			   <DU-USES .CDU (.DU? !<DU-USES .CDU>)>
			   <MAPRET .NAME>)
			  (<AND <GASSIGNED? ABSTRACT-IGNORE?> ,ABSTRACT-IGNORE?>
			   <MESSAGE PACKAGE-NOT-FOUND!-ERRORS .NAME ABSTR-USE>
			   <MAPRET>)
			  (T
			   <BARF PACKAGE-NOT-FOUND!-ERRORS .NAME ABSTR-USE>
			   <MAPRET>)>>
		 .NAMES>>
      <*USE !.NAMES>>>


;"ABSTR-INCLUDE - Replaces definition of INCLUDE during abstraction
  process.  Performs the actions that INCLUDE performs. If a DU does not
  exist, the definitions is loaded (which creates a DU) otherwise the existing
  DU is used. The DU for each name is prepended to the includes list of
  CURRENT-DU."

<DEFINE ABSTR-INCLUDE ("TUPLE" NAMES)
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST STRING]>)
   <PROG ((CDU ,CURRENT-DU) DU?)
      #DECL ((DU?) <OR FALSE DU> (CDU) DU)
      <COND (<NOT ,TOPLEVEL-DU>
	     <BARF TOPLEVEL-MODULE-IS-NEITHER-PACKAGE-NOR-DEFINITIONS!-ERRORS
		   ABSTR-INCLUDE>
	     <RETURN %<>>)>
      <SET NAMES
	   <MAPF ,VECTOR
		 <FUNCTION (NAME)
		    #DECL ((NAME) STRING)
		    <COND (<NOT <SET DU? <FIND-DU .NAME>>>
			   <LOAD-PACKAGE .NAME>
			   <SET DU? <FIND-DU .NAME>>)>
		    <COND (.DU?
			   <DU-INCLUDES .CDU (.DU? !<DU-INCLUDES .CDU>)>
			   <MAPRET .NAME>)
			  (<AND <GASSIGNED? ABSTRACT-IGNORE?> ,ABSTRACT-IGNORE?>
			   <MESSAGE DEFINITIONS-NOT-FOUND!-ERRORS .NAME
				    ABSTR-INCLUDE>
			   <MAPRET>)
			  (T
			   <BARF DEFINITIONS-NOT-FOUND!-ERRORS .NAME
				 ABSTR-INCLUDE>
			   <MAPRET>)>>
		 .NAMES>>
      <*INCLUDE !.NAMES>>
   T>

;"ABSTR-EXPORT - Replaces definition of EXPORT during abstraction process.
  Performs the actions that EXPORT performs. If a DU does not exist,
  the package is loaded (which creates a DU) otherwise the existing DU is
  used. The DU for each name is prepended to the exports list of CURRENT-DU."

<DEFINE ABSTR-EXPORT ("TUPLE" NAMES)
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST STRING]>)
   <PROG ((CDU ,CURRENT-DU) DU?)
      #DECL ((DU?) <OR FALSE DU> (CDU) DU)
      <COND (<NOT ,TOPLEVEL-DU>
	     <BARF TOPLEVEL-MODULE-IS-NEITHER-PACKAGE-NOR-DEFINITIONS!-ERRORS
		   ABSTR-EXPORT>
	     <RETURN %<>>)>
      <SET NAMES
	   <MAPF ,VECTOR
		 <FUNCTION (NAME)
		    #DECL ((NAME) STRING)
		    <COND (<NOT <SET DU? <FIND-DU .NAME>>>
			   <LOAD-PACKAGE .NAME>
			   <SET DU? <FIND-DU .NAME>>)>
		    <COND (.DU?
			   <DU-EXPORTS .CDU (.DU? !<DU-EXPORTS .CDU>)>
			   <MAPRET .NAME>)
			  (<AND <GASSIGNED? ABSTRACT-IGNORE?> ,ABSTRACT-IGNORE?>
			   <MESSAGE PACKAGE-NOT-FOUND!-ERRORS .NAME ABSTR-EXPORT>
			   <MAPRET>)
			  (T
			   <BARF PACKAGE-NOT-FOUND!-ERRORS .NAME ABSTR-EXPORT>
			   <MAPRET>)>>
		 .NAMES>>
      <*EXPORT !.NAMES>>
   T>

;"ABSTR-RENTRY - Replaces definition of RENTRY during abstraction process.
  Performs the actions that entry performs and prepends NAMES to rentry list
  of CURRENT-DU."

<DEFINE ABSTR-RENTRY ("TUPLE" NAMES "AUX" (CDU ,CURRENT-DU))
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST ATOM]> (CDU) DU)
   <*RENTRY !.NAMES>
   <DU-RENTRIES .CDU (!.NAMES !<DU-RENTRIES .CDU>)>
   T>

;"ABSTR-ENTRY - Replaces definition of ENTRY during abstraction process.
  Performs the actions that entry performs and prepends NAMES to entry list
  of CURRENT-DU."

<DEFINE ABSTR-ENTRY ("TUPLE" NAMES "AUX" (CDU ,CURRENT-DU))
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST ATOM]> (CDU) DU)
   <*ENTRY !.NAMES>
   <DU-ENTRIES .CDU (!.NAMES !<DU-ENTRIES .CDU>)>
   T>

;"ABSTR-ENDPACKAGE - Replaces definition of ENDPACKAGE during abstraction
  process. Performs the actions that ENDPACKAGE performs, then sets CURRENT-DU
  to be the top of DU-STACK and pops DU-STACK."

<DEFINE ABSTR-ENDPACKAGE ("OPT" NAME "AUX" (STK ,DU-STACK))
   #DECL ((NAME) STRING (STK) <LIST [REST DU]>)
   <COND (<ASSIGNED? NAME> <*ENDPACKAGE .NAME>) (T <*ENDPACKAGE>)>
   <COND (<NOT <EMPTY? .STK>>           ;"Empty => CURRENT-DU == TOPLEVEL-DU."
	  <SETG CURRENT-DU <1 .STK>>
	  <SETG DU-STACK <REST .STK>>)>
   T>

;"ABSTR-END-DEFINITIONS - Replaces definition of END-DEFINITIONS during
  abstraction process. Performs the actions that END-DEFINITIONS performs,
  puts the entry list into CURRENT-DU, then sets CURRENT-DU to be the top
  of DU-STACK and pops DU-STACK."

<DEFINE ABSTR-END-DEFINITIONS ("OPT" NAME
			       "AUX" (STK ,DU-STACK) (CDU ,CURRENT-DU)
				     (L '()) (OBL <DU-OBL .CDU>))
   #DECL ((STK) <LIST [REST DU]> (CDU) DU (L) LIST (OBL) OBLIST)
   <COND (<ASSIGNED? NAME> <*END-DEFINITIONS .NAME>) (T <*END-DEFINITIONS>)>
   ;"Get the entry oblist - every atom in definition module is an entry."
   <MAPF %<>
	 <FUNCTION (BKT)
	    #DECL ((BKT) LIST)
	    <MAPF %<>
		  <FUNCTION (ATM)
		     #DECL ((ATM) <PRIMTYPE ATOM>)
		     <COND (<==? <OBLIST? <CHTYPE .ATM ATOM>> .OBL>
			    <SET L (.ATM !.L)>)>>
		  .BKT>>
	 ,ATOM-TABLE>
   <DU-ENTRIES .CDU .L>
   <COND (<NOT <EMPTY? .STK>>           ;"Empty => CURRENT-DU == TOPLEVEL-DU."
	  <SETG CURRENT-DU <1 .STK>>
	  <SETG DU-STACK <REST .STK>>)>
   T>

;"ABSTR-USE-WHEN - Force usage to occur during abstraction."

<DEFINE ABSTR-USE-WHEN ('TEST "TUPLE" NAMES)
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST STRING]>)
   <ABSTR-USE !.NAMES>>

;"ABSTR-INCLUDE-WHEN - Force inclusion to occur during abstraction."

<DEFINE ABSTR-INCLUDE-WHEN ('TEST "TUPLE" NAMES)
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST STRING]>)
   <ABSTR-INCLUDE !.NAMES>>

;"ABSTR-USE-TOTAL - Barf becuase USE-TOTAL should not appear in package."

<DEFINE ABSTR-USE-TOTAL ("TUPLE" JUNK)
   <BARF USE-TOTAL-IN-FILE!-ERRORS !.JUNK ABSTR-USE-TOTAL>
   %<>>

;"ABSTR-RPACKAGE - Barf becuase RPACKAGE is obsolete."

<DEFINE ABSTR-RPACKAGE ("TUPLE" JUNK)
   <BARF RPACKAGE-IN-FILE!-ERRORS !.JUNK ABSTR-USE-TOTAL>
   %<>>

;"ABSTR-NEW-CHANNEL-TYPE - Replaces definition of NEW-CHANNEL-TYPE during
  abstraction process. Performs the actions that NEW-CHANNEL-TYPE performs
  then adds the new channel type to the list of special forms of CURRENT-DU."

<DEFINE ABSTR-NEW-CHANNEL-TYPE (NAME INHERIT "TUPLE" SHIT "AUX" CDU DUS)
   #DECL ((NAME) ATOM (INHERIT) <OR FALSE ATOM <LIST [REST ATOM]>>
	  (SHIT) <<PRIMTYPE VECTOR> [REST ATOM <OR MSUBR ATOM FALSE>]>
	  (CDU) DU (DUS) <LIST [REST FORM]>)
   <*NEW-CHANNEL-TYPE .NAME .INHERIT !.SHIT>
   <REPEAT ((RSHIT .SHIT))
      #DECL ((RSHIT) <<PRIMTYPE VECTOR> [REST ATOM <OR MSUBR ATOM FALSE>]>)
      <COND (<EMPTY? .RSHIT> <RETURN>)
	    (<TYPE? <2 .RSHIT> MSUBR> <2 .RSHIT <MSUBR-NAME <2 .RSHIT>>>)>
      <SET RSHIT <REST .RSHIT 2>>>
   <COND (<NOT ,TOPLEVEL-DU>
	  <BARF TOPLEVEL-MODULE-IS-NEITHER-PACKAGE-NOR-DEFINITIONS!-ERRORS
		ABSTR-NEW-CHANNEL-TYPE>)
	 (<EMPTY? <SET DUS <DU-SPECIAL <SET CDU ,CURRENT-DU>>>>
	  <DU-SPECIAL .CDU
		      (<CHTYPE (NEW-CHANNEL-TYPE .NAME .INHERIT !.SHIT)
			       FORM>)>)
	 (T
	  <PUTREST <REST .DUS <- <LENGTH .DUS> 1>>
		   (<CHTYPE (NEW-CHANNEL-TYPE .NAME .INHERIT !.SHIT) FORM>)>)>
   T>

;"ABSTR-ADD-CHANNEL-OPS - Replaces definition of ADD-CHANNEL-OPS during
  abstraction process. Performs the actions that ADD-CHANNEL-OPS performs
  then adds the new channel type to the list of special forms of CURRENT-DU."

<DEFINE ABSTR-ADD-CHANNEL-OPS (NAME "TUPLE" SHIT "AUX" CDU DUS)
   #DECL ((NAME) ATOM (CDU) DU (DUS) <LIST [REST FORM]>
	  (SHIT) <<PRIMTYPE VECTOR> [REST ATOM <OR MSUBR ATOM FALSE>]>)
   <*ADD-CHANNEL-OPS .NAME !.SHIT>
   <REPEAT ((RSHIT .SHIT))
      #DECL ((RSHIT) <<PRIMTYPE VECTOR> [REST ATOM <OR MSUBR ATOM FALSE>]>)
      <COND (<EMPTY? .RSHIT> <RETURN>)
	    (<TYPE? <2 .RSHIT> MSUBR> <2 .RSHIT <MSUBR-NAME <2 .RSHIT>>>)>
      <SET RSHIT <REST .RSHIT 2>>>
   <COND (<NOT ,TOPLEVEL-DU>
	  <BARF TOPLEVEL-MODULE-IS-NEITHER-PACKAGE-NOR-DEFINITIONS!-ERRORS
		ABSTR-ADD-CHANNEL-OPS>)
	 (<EMPTY? <SET DUS <DU-SPECIAL <SET CDU ,CURRENT-DU>>>>
	  <DU-SPECIAL .CDU
		      (<CHTYPE (ADD-CHANNEL-OPS .NAME !.SHIT) FORM>)>)
	 (T
	  <PUTREST <REST .DUS <- <LENGTH .DUS> 1>>
		   (<CHTYPE (ADD-CHANNEL-OPS .NAME !.SHIT) FORM>)>)>
   T>

;"LOAD-PACKAGE - Find and load package named NAME, choking if not found.
  Employs the package system to open a channel to appropriate file."

<DEFINE LOAD-PACKAGE (NAME "AUX" (ICH <L-OPEN .NAME>))
   #DECL ((NAME) STRING (ICH) <OR CHANNEL FALSE>)
   <COND (.ICH
	  <BLURB "Loading: " <CHANNEL-OP .ICH NAME>>
	  <UNWIND <LOAD .ICH> <CLOSE .ICH>>
	  <CLOSE .ICH>)
	 (<AND <GASSIGNED? ABSTRACT-IGNORE?> ,ABSTRACT-IGNORE?> %<>)
	 (T <BARF <STRING "Not found: " .NAME> LOAD-PACKAGE> %<>)>
   T>

;"TRANSLATED - If NAME is translated by the library system, return the
  translated name, otherwise return NAME."

<DEFINE TRANSLATED (NAME)
   #DECL ((NAME) STRING)
   <REPEAT ((TRANSLATIONS ,L-TRANSLATIONS))
      #DECL ((TRANSLATIONS) <LIST [REST STRING]>)
      <COND (<EMPTY? .TRANSLATIONS>
	     <RETURN .NAME>)
	    (<=? .NAME <1 .TRANSLATIONS>>
	     <RETURN <2 .TRANSLATIONS>>)
	    (T
	     <SET TRANSLATIONS <REST .TRANSLATIONS 2>>)>>>

;"FIND-DU - Search USED-DU-LIST for DU named NAME, returning the DU if found.
  Else, if NAME is the name of preloaded package, create a dummy DU for
  preloaded package and return it. Otherwise, return false."

<DEFINE FIND-DU (NAME)
   #DECL ((NAME) STRING)
   <REPEAT ((USED ,USED-DU-LIST))
      #DECL ((USED) <LIST [REST DU]>)
      <COND (<EMPTY? .USED>
	     <BIND ((P <MEMBER .NAME ,PRELOADED>))
		#DECL ((P) <OR FALSE <VECTOR STRING>>)
		<COND (.P <RETURN <CREATE-PRELOADED-DU <1 .P>>>)
		      (T <RETURN %<>>)>>)
	    (<=? .NAME <DU-NAME <1 .USED>>>
	     <RETURN <1 .USED>>)
	    (T
	     <SET USED <REST .USED>>)>>>

;"CREATE-PRELOADED-DU - Creates and returns a dummy DU for NAME where NAME
  is the name of a preloaded package. The oblist, internal oblist, and name
  slots are set appropriately, but the entries, rentries, uses, and exports
  are empty. Adds created DU to USED-DU-LIST."

<DEFINE CREATE-PRELOADED-DU (NAME "AUX" OBL IOBL PDU)
   #DECL ((NAME) STRING (OBL IOBL) <OR ATOM OBLIST FALSE> (PDU) DU)
   <COND (<AND <SET OBL <LOOKUP .NAME <MOBLIST PACKAGE>>>
	       <SET OBL <CHTYPE .OBL OBLIST>>>
	  <COND (<SET IOBL <LOOKUP <STRING !\I .NAME> .OBL>>
		 <SET IOBL <CHTYPE .IOBL OBLIST>>)>
	  <SET PDU <CHTYPE [.NAME .OBL .IOBL '() '() '() '() '() '() %<>] DU>>
	  <SETG USED-DU-LIST (.PDU !,USED-DU-LIST)>
	  .PDU)
	 (T
	  <BARF PRELOADED-PKG-NOT-LOADED!-ERRORS .NAME CREATE-PRELOADED-DU>
	  %<>)>>

;"*** Following routines implement analysis of DUs: Second Pass. ***"

;"ABSTR-CREATE - Analyze the package corresponding to TOPLEVEL-DU. If no error
  arises during analysis, returns a vector of two elements: the first is the
  forms of the abstract and the second is the associated oblist path. Assumes
  global state is appropriately initialized."

<DEFINE ABSTR-CREATE ("AUX" (TDU ,TOPLEVEL-DU)
			    (ABSTRACT <SETG ABSTRACT <NEW-ABSTRACTION>>)
			    (PRELOADED ,PRELOADED) BODY TAIL PATH STRINGS)
   #DECL ((ABSTRACT) ABSTRACTION (PRELOADED) <VECTOR [REST STRING]>
	  (BODY TAIL) <LIST ANY> (TDU) DU (PATH) <LIST [REST OBLIST]>
	  (STRINGS) <LIST [REST STRING]>)
   <BLURB "Abstracting: " <DU-NAME .TDU>>
   <SETG NAME-STACK '()>
   <SETG ABSTRACTED '()>
   ;"Grovel over every entry and rentry atom in package, adding information
     to ABSTRACT when necessary. Create the body of the abstraction. Grovel
     over special forms."
   <UNWIND <BIND ()
	      <MAPF %<>
		    <FUNCTION (A) #DECL ((A) ATOM) <ABSTR-GROVEL .A>>
		    (!<DU-RENTRIES .TDU> !<DU-ENTRIES .TDU>)>
	      <ABSTR-GROVEL-SPECIAL <DU-SPECIAL .TDU>>>
	   <BIND ()
	      <GUNASSIGN NAME-STACK>
	      <GUNASSIGN ABSTRACT>
	      <GUNASSIGN ABSTRACTED>
	      <MAPF %<> <FUNCTION (UDU) #DECL ((UDU) DU) <UNMARK-DU .UDU>>
		    ,USED-DU-LIST>>>
   <GUNASSIGN NAME-STACK>
   <GUNASSIGN ABSTRACT>
   <GUNASSIGN ABSTRACTED>
   ;"Cons up the body of the abstraction, simultaneously setting up
     oblist path as if we were inside the abstraction."
   <COND (<DU-IOBL .TDU>
	  <SET TAIL <SET BODY (<CHTYPE (PACKAGE <DU-NAME .TDU>) FORM>)>>
	  <PACKAGE <DU-NAME .TDU>>)
	 (T
	  <SET TAIL <SET BODY (<CHTYPE (DEFINITIONS <DU-NAME .TDU>) FORM>)>>
	  <DEFINITIONS <DU-NAME .TDU>>)>
   <COND (<AND <NOT <EMPTY? <DU-ENTRIES .TDU>>> <DU-IOBL .TDU>>
	  <PUTREST .TAIL
		   <SET TAIL (<CHTYPE (ENTRY !<DU-ENTRIES .TDU>) FORM>)>>)>
   <COND (<NOT <EMPTY? <DU-RENTRIES .TDU>>>
	  <PUTREST .TAIL
		   <SET TAIL (<CHTYPE (RENTRY !<DU-RENTRIES .TDU>) FORM>)>>)>
   <SET STRINGS <MAPF ,LIST
		      <FUNCTION (EDU)
			 #DECL ((EDU) DU)
			 ;"Exported packages dont need to be used."
			 <UNMARK-DU .EDU>
			 <MAPRET <DU-NAME .EDU>>>
		      <DU-EXPORTS .TDU>>>
   <COND (<NOT <EMPTY? .STRINGS>>
	  <PUTREST .TAIL <SET TAIL (<CHTYPE (EXPORT !.STRINGS) FORM>)>>
	  <EXPORT !.STRINGS>)>

   <SET STRINGS <MAPF ,LIST
		      <FUNCTION (UDU)
			 #DECL ((UDU) DU)
			 ;"Use marked and preloaded packages."
			 <COND (<OR <DU-MARKED? .UDU>
				    <MEMQ <DU-NAME .UDU> .PRELOADED>>
				<UNMARK-DU .UDU>
				<MAPRET <DU-NAME .UDU>>)
			       (T
				<MAPRET>)>>
		      <DU-USES .TDU>>>
   <COND (<NOT <EMPTY? .STRINGS>>
	  <PUTREST .TAIL <SET TAIL (<CHTYPE (USE !.STRINGS) FORM>)>>
	  <USE !.STRINGS>)>
   <SET STRINGS <MAPF ,LIST
		      <FUNCTION (IDU)
			 #DECL ((IDU) DU)
			 ;"Include marked and preloaded definitions."
			 <COND (<OR <DU-MARKED? .IDU>
				    <MEMQ <DU-NAME .IDU> .PRELOADED>>
				<UNMARK-DU .IDU>
				<MAPRET <DU-NAME .IDU>>)
			       (T
				<MAPRET>)>>
		      <DU-INCLUDES .TDU>>>
   <COND (<NOT <EMPTY? .STRINGS>>
	  <PUTREST .TAIL <SET TAIL (<CHTYPE (INCLUDE !.STRINGS) FORM>)>>
	  <INCLUDE !.STRINGS>)>
   <COND (<NOT <LENGTH? <A-TYPES .ABSTRACT> 1>>     ;"Ignore leading atom."
	  <PUTREST .TAIL <REST <A-TYPES .ABSTRACT>>>
	  <SET TAIL <A-TTAIL .ABSTRACT>>)>
   <COND (<NOT <LENGTH? <A-GVALS .ABSTRACT> 1>>     ;"Ignore leading atom."
	  <PUTREST .TAIL <REST <A-GVALS .ABSTRACT>>>
	  <SET TAIL <A-GTAIL .ABSTRACT>>)>
   <COND (<NOT <EMPTY? <A-DECLS .ABSTRACT>>>
	  <PUTREST .TAIL
		   <SET TAIL (<CHTYPE (GDECL !<A-DECLS .ABSTRACT>) FORM>)>>)>
   <COND (<NOT <EMPTY? <A-CONST .ABSTRACT>>>
	  <PUTREST .TAIL
		   <SET TAIL
			(<CHTYPE (MANIFEST !<A-CONST .ABSTRACT>) FORM>)>>)>
   <COND (<NOT <EMPTY? <DU-SPECIAL .TDU>>>
	  <PUTREST .TAIL <SET TAIL <LIST !<DU-SPECIAL .TDU>>>>
	  <SET TAIL <REST .TAIL <- <LENGTH .TAIL> 1>>>)>
   <SET PATH <LIST !.OBLIST>>               ;"Hang onto copy of oblist path."
   <COND (<DU-IOBL .TDU>
	  <PUTREST .TAIL (<CHTYPE '(ENDPACKAGE) FORM>)>
	  <ENDPACKAGE>)
	 (T
	  <PUTREST .TAIL (<CHTYPE '(END-DEFINITIONS) FORM>)>
	  <END-DEFINITIONS>)>
   ;"Return body of abstract and associated oblist path."
   [.BODY .PATH]>

;"ABSTR-GROVEL - Determines what information about NAME must be included in
  abstract. NAME should be an entry or rentry of TOPLEVEL-DU or on its internal
  oblist. NAME is marked ABSTRACTED to prevent cycles and duplications.
  This routine preserves the gvals of msubrs, macros, manifested GVALs that
  are not structured (except offsets are allowed). Type decls and gdecls
  (GDECL, PUT-DECL, NEWTYPE) are preserved."

<DEFINE ABSTR-GROVEL AG (NAME "AUX" VAL)
   #DECL ((NAME) ATOM (VAL) ANY (AG) FRAME)
   ;"Skip if already done or it is IMSUBR (means we are in DEFINITIONS)."
   <COND (<OR <MEMQ .NAME ,ABSTRACTED>
              <AND <GASSIGNED? .NAME> <TYPE? ,.NAME IMSUBR>>>
          <RETURN T .AG>)>
   <SETG NAME-STACK (.NAME !,NAME-STACK)>            ;"Push name onto stack."
   <SETG ABSTRACTED (.NAME !,ABSTRACTED)>             ;"Mark as abstracted."
   <COND (<OR <VALID-TYPE? .NAME> <GET-DECL .NAME>>
	  <SET VAL <OR <GET-DECL .NAME> <TYPEPRIM .NAME>>>
	  ;"NAME is a new type or an abbreviation for a type (PUT-DECL)."
	  <GROVEL-DECL .VAL>
	  <SET VAL <CHTYPE (QUOTE .VAL) FORM>>
	  <COND (<NEWTYPE-ATOM? .NAME>
		 <ENQ-TYPE ,ABSTRACT
			   <CHTYPE (NEWTYPE .NAME <TYPEPRIM .NAME> .VAL) FORM>>)
		(T
		 <ENQ-TYPE ,ABSTRACT <CHTYPE (PUT-DECL .NAME .VAL) FORM>>)>)>
   <COND (<AND <GBOUND? .NAME> <NOT <MANIFEST? .NAME>>>
	  <COND (<SET VAL <GET-DECL <GBIND .NAME %<>>>>
		 <GROVEL-DECL .VAL>         ;"NAME has been gdecled."
		 <ENQ-DECL ,ABSTRACT .NAME .VAL>)>)>
   <COND (<GASSIGNED? .NAME>
	  <SET VAL ,.NAME>
	  <COND (<AND <MANIFEST? .NAME>
		      <NOT <TYPE? .VAL OFFSET>> <STRUCTURED? .VAL>>
		 <BARF CANT-ABSTRACT-MANIFESTED-STRUCTURE!-ERRORS
		       .NAME ABSTR-GROVEL>)
		(<TYPE? .VAL FUNCTION>
		 <BARF CANT-ABSTRACT-UNCOMPILED-FUNCTION!-ERRORS .NAME
		       ABSTR-GROVEL>)
		(<TYPE? .VAL MSUBR>
		 <COND (<==? <MSUBR-NAME .VAL> .NAME>
			<MAPF %<>           ;"Analyze msubr argument decls."
			      <FUNCTION (DCL)
				 <COND (<NOT <TYPE? .DCL STRING>>
					<GROVEL-DECL .DCL>)>>
			      <MSUBR-ARG-DECL .VAL>:<PRIMTYPE LIST>>
			;"Copy MSUBR with new magic IMSUBR name."
			<SET VAL <CHTYPE <VECTOR !.VAL> MSUBR>>	;"Mung copy."
			<IMSUBR-NAME .VAL <IMSUBR-NAME ,ABSTRACT-MSUBR-LOADER>>
			<IMSUBR-OFFSET .VAL 0>	;"In case it was glued."
			<ENQ-GVAL ,ABSTRACT .NAME .VAL>)
		       (T                   ;"Preserve alias msubr names."
			<IF-NEEDED <MSUBR-NAME .VAL>>
			<ENQ-GVAL ,ABSTRACT .NAME <GVAL <MSUBR-NAME .VAL>>>)>)
		(<TYPE? .VAL MACRO>
		 <GROVEL-MACRO <MACRO-BODY .VAL>>
		 <ENQ-GVAL ,ABSTRACT .NAME .VAL>)
		(<TYPE? .VAL OFFSET>        ;"Analyze offset argument decl."
		 <COND (<GET-DECL .VAL>
			<GROVEL-DECL <GET-DECL .VAL>>)>
		 <COND (<ELEMENT-DECL .VAL> ;"Analyze offset element decl."
			<GROVEL-DECL <ELEMENT-DECL .VAL>>)>)
		(<AND <NEWTYPE-OBJECT? .VAL> <MANIFEST? .NAME>>
		 <GROVEL-DECL <TYPE .VAL>>)>)>
   <COND (<MANIFEST? .NAME>                 ;"Setg (if needed) and manifest."
	  <COND (<GASSIGNED? .NAME> <ENQ-GVAL ,ABSTRACT .NAME .VAL>)>
	  <ENQ-CONST ,ABSTRACT .NAME>)>
   <SETG NAME-STACK <REST ,NAME-STACK>>     ;"Pop name stack."
   T>

;"ABSTR-GROVEL-SPECIAL - Handle special forms in TOPLEVEL-DU on form by form
  basis. Currently, NEW-CHANNEL-TYPE and ADD-CHANNEL-OPS. The first element
  of the form determines the action taken."

<DEFINE ABSTR-GROVEL-SPECIAL (SPFORMS)
   #DECL ((SPFORMS) <LIST [REST <FORM ATOM>]>)
   <REPEAT (SPFORM KIND TEMP)
      #DECL ((SPFORM) FORM (KIND) ATOM)
      <COND (<EMPTY? .SPFORMS> <RETURN>)>
      <SET KIND <1 <SET SPFORM <1 .SPFORMS>>>>
      <SET SPFORMS <REST .SPFORMS>>
      <COND (<==? .KIND NEW-CHANNEL-TYPE>
	     ;"Grovel over channel types we inherit from."
	     <COND (<TYPE? <SET TEMP <3 .SPFORM>> ATOM>
		    <IF-NEEDED .TEMP>)
		   (T
		    <MAPF %<>
			  ,IF-NEEDED
			  .TEMP:<<PRIMTYPE LIST> [REST ATOM]>>)>)
	    (<==? .KIND ADD-CHANNEL-OPS>
	     ;"Check out the channel type we are augmenting."
	     <IF-NEEDED <2 .SPFORM>>)>>
   T>

;"GROVEL-DECL - Analyzes a DECL pattern fringe, abstracting ATOMs where
  necessary by invoking IF-NEEDED for ATOMs which represent types."

<DEFINE GROVEL-DECL (DCL)
   #DECL ((DCL) <OR ATOM FORM SEGMENT VECTOR>)
   <COND (<TYPE? .DCL ATOM>
	  ;"If it is a newtype or an abbreviation, then analyze if necessary."
	  <COND (<OR <NEWTYPE-ATOM? .DCL> <GET-DECL .DCL>> <IF-NEEDED .DCL>)>)
	 (<TYPE? .DCL FORM SEGMENT>
	  ;"Either quoted or composite."
	  <COND (<==? <1 .DCL> QUOTE>
		 <COND (<STRUCTURED? <2 .DCL>>
			<BARF CANT-ABSTRACT-QUOTED-STRUCTURE-DECL!-ERRORS .DCL
			      GROVEL-DECL>)
		       (<NEWTYPE-OBJECT? <2 .DCL>>
			;"Exact non-structured type - analyze its decl."
			<GROVEL-DECL <TYPE <2 .DCL>>>)
		       (<TYPE? <2 .DCL> ATOM>
			;"Maybe an atom from another module."
			<IF-NEEDED <2 .DCL>>)>)
		(T
		 ;"Composite type - analyze the parts of the decl."
		 <MAPF %<> ,GROVEL-DECL .DCL>)>)
	 (T
	  ;"Element specification (e.g. [REST ...]), analyze element decls."
	  <MAPF %<> ,GROVEL-DECL <REST .DCL>>)>
   T>

;"GROVEL-MACRO - Analyze the body of a macro (compiled or not). If the macro
  is compiled, include a setg for the imsubr of the compiled macro in the
  abstract. Analysis is inhibited if ABSTRACT-CAREFUL? is false."

<DEFINE GROVEL-MACRO (BODY)
   #DECL ((BODY) <OR MSUBR <PRIMTYPE LIST>>)
   <COND (<TYPE? .BODY MSUBR>
	  <COND (<NOT <MEMQ <IMSUBR-NAME .BODY> ,ABSTRACTED>>
		 ;"If package is glued, we dont want to setg the imsubr twice."
		 <ENQ-GVAL ,ABSTRACT <IMSUBR-NAME .BODY> <MSUBR-IMSUBR .BODY>>
		 <SETG ABSTRACTED (<IMSUBR-NAME .BODY> !,ABSTRACTED)>
		 <COND (,ABSTRACT-CAREFUL?
			<MAPF %<>
			      <FUNCTION (DCL) #DECL ((DCL) ANY)
				 <COND (<TYPE? .DCL ATOM FORM SEGMENT VECTOR>
					<GROVEL-DECL .DCL>)>>
			      <MSUBR-ARG-DECL .BODY>:<PRIMTYPE LIST>>
			<GROVEL-MACRO-COMP <MSUBR-IMVECTOR .BODY>>)>)
		(T
		 <MESSAGE "Glued package contains compiled macros"
			  GROVEL-MACRO>)>)
	 (,ABSTRACT-CAREFUL?
	  <MAPF %<> ,GROVEL-MACRO-PART-EVAL .BODY:<PRIMTYPE LIST>>)>
   T>

;"GROVEL-MACRO-FORM - Analyzes a form in a macro. Inspects the first element
  of the form, barfing if it is not a primitive atom or fix. Analyzes rest of the
  form in an quoted context or a evaluated context depending on whether or not
  the first element is QUOTE or some other primitive atom, respectively."

<DEFINE GROVEL-MACRO-FORM (F "AUX" FIRST)
   #DECL ((F) FORM (FIRST) ANY)
   <COND (<NOT <EMPTY? .F>>
	  <COND (<TYPE? <SET FIRST <1 .F>> ATOM FIX>
		 <COND (<==? .FIRST QUOTE>
			<GROVEL-MACRO-PART-QUOTE <REST .F>>)
		       (<OR <TYPE? .FIRST FIX> <PRIMITIVE? .FIRST>>
			<GROVEL-MACRO-PART-EVAL <REST .F>>)
		       (T
			<BARF CANT-ABSTRACT-IN-MACRO!-ERRORS .FIRST .F
			      GROVEL-MACRO-FORM>)>)
		(T
		 <BARF CANT-ABSTRACT-IN-MACRO!-ERRORS .FIRST .F
		       GROVEL-MACRO-FORM>)>)>
   T>

;"GROVEL-MACRO-PART-EVAL - Analyzes part of a macro in evaluated context. The
  first element of every form is required to be a primitive atom. Dives into
  interesting structures, abstracting newtypes and atoms."

<DEFINE GROVEL-MACRO-PART-EVAL (EP)
   #DECL ((EP) ANY)
   <COND (<NEWTYPE-OBJECT? .EP> <GROVEL-DECL <TYPE .EP>>)>
   <COND (<STRUCTURED? .EP>
	  <COND (<TYPE? .EP FORM>
		 <GROVEL-MACRO-FORM .EP>)
		(<==? <PRIMTYPE .EP> LIST>
		 <MAPF %<> ,GROVEL-MACRO-PART-EVAL .EP:<PRIMTYPE LIST>>)
		(<==? <PRIMTYPE .EP> VECTOR>
		 <MAPF %<> ,GROVEL-MACRO-PART-EVAL .EP:<PRIMTYPE VECTOR>>)>)
	 (<TYPE? .EP ATOM> <IF-NEEDED .EP>)>
   T>

;"GROVEL-MACRO-PART-QUOTE - Analyzes part of a macro in quoted context.
  Dives into  interesting structures, abstracting newtypes and atoms.
  Allows anything as first element of a form because it will not be evaluated."

<DEFINE GROVEL-MACRO-PART-QUOTE (QP)
   #DECL ((QP) ANY)
   <COND (<NEWTYPE-OBJECT? .QP> <GROVEL-DECL <TYPE .QP>>)>
   <COND (<STRUCTURED? .QP>
	  <COND (<==? <PRIMTYPE .QP> LIST>
		 <MAPF %<> ,GROVEL-MACRO-PART-QUOTE .QP:<PRIMTYPE LIST>>)
		(<==? <PRIMTYPE .QP> VECTOR>
		 <MAPF %<> ,GROVEL-MACRO-PART-QUOTE .QP:<PRIMTYPE VECTOR>>)>)
	 (<TYPE? .QP ATOM> <IF-NEEDED .QP>)>
   T>

;"GROVEL-MACRO-COMP - Beginning with the mvector of a compiled macro (see
  GROVEL-MACRO) descend to the fringe, analyzing types in the process."

<DEFINE GROVEL-MACRO-COMP (THING)
   #DECL ((THING) <OR <PRIMTYPE LIST> <PRIMTYPE VECTOR>>)
   <COND (<NEWTYPE-OBJECT? .THING> <GROVEL-DECL <TYPE .THING>>)>
   <COND (<==? <PRIMTYPE .THING> LIST>
	  <MAPF %<> ,GROVEL-MACRO-COMP-PART .THING:<PRIMTYPE LIST>>)
	 (<==? <PRIMTYPE .THING> VECTOR>
	  <MAPF %<> ,GROVEL-MACRO-COMP-PART .THING:<PRIMTYPE VECTOR>>)>
   T>

;"GROVEL-MACRO-PART-COMP - Check out the parts of the structures given to
  GROVEL-MACRO-COMP. If an atom is found which is gassigned but not manifest
  and it is not primitive, then an error occurs."

<DEFINE GROVEL-MACRO-COMP-PART (FROB)
   #DECL ((FROB) ANY)
   <COND (<MEMQ <PRIMTYPE .FROB> '[LIST VECTOR]>
	  <GROVEL-MACRO-COMP .FROB>)
	 (<TYPE? .FROB ATOM>
	  <COND (<MANIFEST? .FROB>
		 <IF-NEEDED .FROB>)
		(<AND <GASSIGNED? .FROB> <NOT <PRIMITIVE? .FROB>>>
		 <BARF CANT-ABSTRACT-IN-MACRO!-ERRORS .FROB
		       GROVEL-MACRO-COMP-PART>)
		(<OR <NEWTYPE-ATOM? .FROB> <GET-DECL .FROB>>
		 <IF-NEEDED .FROB>)>)
	 (<NEWTYPE-OBJECT? .FROB>
	  <GROVEL-DECL <TYPE .FROB>>)>
   T>

;"PRIMITIVE? - Returns false if NAME is not on known oblist or
  if NAME is a rentry defined by something which is not preloaded."

<DEFINE PRIMITIVE? (NAME "AUX" NOBL)
   #DECL ((NAME) ATOM (NOBL) <OR OBLIST FALSE>)
   <COND (<SET NOBL <OBLIST? .NAME>>
	  <OR <==? .NOBL #OBLIST ERRORS>
	      <AND <==? .NOBL #OBLIST ROOT>
		   ;"Note - Preloaded packages not found here because DUs
		     for preloaded packages contain no rentries. Assume
		     preloaded packages as primitive."
		   <NOT <MAPF %<>
			      <FUNCTION (UDU) #DECL ((UDU) DU)
				 <COND (<MEMQ .NAME <DU-RENTRIES .UDU>>
					<MAPLEAVE T>)>>
			      ,USED-DU-LIST>>>>)
	 (T
	  <BARF ATOM-NOT-ON-ANY-OBLIST!-ERRORS .NAME PRIMITIVE?>
	  %<>)>>

;"DU-DEFINES? - If DU has not been SEEN, then if NAME is defined by DU or
  by any DUs exported by DU, then non-false is returned. Includes DUs explored
  in SEEN to break cyles in usage of packages."

<DEFINE DU-DEFINES? (NAME NOBL DU SEEN)
   #DECL ((NAME) ATOM (NOBL) OBLIST (DU) DU (SEEN) <LIST [REST DU]>)
   <COND (<MEMQ .DU .SEEN> %<>)
	 (T
	  <SET SEEN (.DU !.SEEN)>
	  <COND (<==? .NOBL <DU-OBL .DU>> T)
		(<AND <==? .NOBL #OBLIST ROOT> <MEMQ .NAME <DU-RENTRIES .DU>>> T)
		(T
		 <REPEAT ((DUX <DU-EXPORTS .DU>))
		    #DECL ((DUX) <LIST [REST DU]>)
		    <COND (<EMPTY? .DUX>
			   <RETURN %<>>)
			  (<DU-DEFINES? .NAME .NOBL <SET DU <1 .DUX>> .SEEN>
			   <RETURN T>)
			  (T
			   <SET SEEN (.DU !.SEEN)>
			   <SET DUX <REST .DUX>>)>>)>)>>

;"IF-NEEDED - If NAME is defined by TDU, recursively invokes ABSTR-GROVEL
  on NAME. Else, if NAME is defined by a DU used by TDU, then that DU is
  marked so that it will be used in abstract. Else, if NAME is on root
  oblist it is assumed primitive (or preloaded), otherwise an error occurs."

<DEFINE IF-NEEDED (NAME "AUX" (NOBL <OBLIST? .NAME>) (TDU ,TOPLEVEL-DU))
   #DECL ((NAME) ATOM (NOBL) <OR OBLIST FALSE> (TDU) DU)
   <COND (.NOBL
	  ;"Abstract the atom if it belongs to TOPLEVEL-DU."
	  <COND (<OR <==? .NOBL <DU-OBL .TDU>>
		     <==? .NOBL <DU-IOBL .TDU>>
		     <MEMQ .NAME <DU-RENTRIES .TDU>>>
		 <ABSTR-GROVEL .NAME>)
		(T
		 <OR <MAPF %<>
			   <FUNCTION (DU) #DECL ((DU) DU)
			      <COND (<DU-DEFINES? .NAME .NOBL .DU (.TDU)>
				     <MARK-DU .DU>
				     <MAPLEAVE T>)>>
			   (!<DU-EXPORTS .TDU>
			    !<DU-INCLUDES .TDU>
			    !<DU-USES .TDU>)>
		     <==? .NOBL #OBLIST ROOT>
		     <==? .NOBL #OBLIST ERRORS>
		     <BARF ATOM-NOT-ON-KNOWN-OBLIST!-ERRORS .NAME
			   IF-NEEDED>>)>)
	 (T
	  <BARF ATOM-NOT-ON-ANY-OBLIST!-ERRORS .NAME IF-NEEDED>)>
   T>

;"BARF - Returns false from the frame named AP if AP is a legal frame,
  otherwise error. The error handler for the abstraction package."

<DEFINE BARF ("TUPLE" BARFAGE)
   #DECL ((BARFAGE) <<PRIMTYPE VECTOR> ANY>)
   <COND (<AND <GASSIGNED? NAME-STACK> <NOT <EMPTY? ,NAME-STACK>>>
	  <BIND ((WHO <STRING "While working on " <SPNAME <1 ,NAME-STACK>>>)
		 (PUKE (ABSTRACTION-ERROR!-ERRORS .WHO !.BARFAGE)))
	     #DECL ((WHO) STRING (PUKE) LIST)
	     <COND (<AND <ASSIGNED? AP> <LEGAL? .AP>>
		    <RETURN <CHTYPE .PUKE FALSE> .AP>)
		   (T
		    <ERROR !.PUKE>)>>)
	 (<AND <ASSIGNED? AP> <LEGAL? .AP>>
	  <RETURN <CHTYPE (!.BARFAGE) FALSE> .AP>)
	 (T
	  <ERROR !.BARFAGE>)>
   %<>>

;"MESSAGE - Prints BARFAGE to OUTCHAN."

<DEFINE MESSAGE ("TUPLE" BARFAGE)
   #DECL ((BARFAGE) <<PRIMTYPE VECTOR> [REST ANY]>)
   <BIND ((OUTCHAN .OUTCHAN))
      #DECL ((OUTCHAN) CHANNEL)
      <CRLF>
      <PRINC "*** Warning ***">
      <MAPF %<>
	    <FUNCTION (FROB)
	       <CRLF> <PRINC .FROB>>
	    .BARFAGE>>>

;"ALESS? - Return T if pname of A1 is greater than pname of A2."

<DEFINE ALESS? (A1 A2)
   #DECL ((A1 A2) ATOM)
   <==? <STRCOMP <SPNAME .A1> <SPNAME .A2>> 1>>

;"SEARCH - Find a filename in the library search path. Only files
  are considered - libraries are not consulted. If OPER = VECTOR,
  a vector of 5 elements is returned = [FN NM1 NM2 DEV SNM].
  If OPER = NAME, the file name is returned. If OPER = CHANNEL a channel
  open to the file is returned."

<DEFINE SEARCH (NAME OPER
		"OPT" (PATH ,L-SEARCH-PATH) (NAMES ,L-SECOND-NAMES)
		"AUX" ODEV OSNM)
   #DECL ((NAME) STRING (OPER) ATOM (PATH) LIST (NAMES) <VECTOR [REST STRING]>
	  (ODEV OSNM) STRING)
   <COND (<ASSIGNED? SNM> <SET OSNM .SNM>)
	 (<GASSIGNED? SNM> <SET OSNM ,SNM>)
	 (T <SET OSNM "">)>
   <COND (<ASSIGNED? DEV> <SET ODEV .DEV>)
	 (<GASSIGNED? DEV> <SET ODEV ,DEV>)
	 (T <SET ODEV "">)>
   <REPEAT (SPEC DEV SNM (RESULT %<>))
      #DECL ((SPEC) <OR VECTOR STRING> (DEV SNM) <SPECIAL STRING>
	     (RESULT) <OR STRING VECTOR <CHANNEL 'DISK> FALSE>)
      <COND (<OR .RESULT <EMPTY? .PATH>> <RETURN .RESULT>)>
      <SET SPEC <1 .PATH>>
      <COND (<TYPE? .SPEC VECTOR>
	     <COND (<==? <LENGTH .SPEC> 2>
		    <SET DEV <1 .SPEC>>
		    <SET SNM <2 .SPEC>>)
		   (T
		    <COND (<EMPTY? .ODEV> <UNASSIGN DEV>)
			  (T <SET DEV .ODEV>)>
		    <COND (<EMPTY? .OSNM> <UNASSIGN SNM>)
			  (T <SET SNM .OSNM>)>)>
	     <REPEAT ((RNAMES .NAMES) NM2 CH)
		#DECL ((RNAMES) <VECTOR [REST STRING]> (NM2) <SPECIAL STRING>
		       (CH) <OR <CHANNEL 'DISK> FALSE>)
		<COND (<EMPTY? .RNAMES> <RETURN>)>
		<SET NM2 <1 .RNAMES>>
		<COND (<SET CH <OPEN "READ" .NAME>>
		       <COND (<==? .OPER VECTOR>
			      <SET RESULT [<CHANNEL-OP .CH NAME>
					   <CHANNEL-OP .CH NM1>
					   <CHANNEL-OP .CH NM2>
					   <CHANNEL-OP .CH DEV>
					   <CHANNEL-OP .CH SNM>]>
			      <CLOSE .CH>)
			     (<==? .OPER NAME>
			      <SET RESULT <CHANNEL-OP .CH NAME>>
			      <CLOSE .CH>)
			     (T
			      <SET RESULT .CH>)>
		       <RETURN>)>
		<SET RNAMES <REST .RNAMES>>>)>
      <SET PATH <REST .PATH>>>>

<ENDPACKAGE>
