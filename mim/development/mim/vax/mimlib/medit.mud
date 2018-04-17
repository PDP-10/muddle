"++ UNIX ++*****************************************************************

 This is the MDL half of an interface between EMACS and MDL. An EMACS is
 created as an inferior of MDL. Stuff marked in EMACS for return to MDL is
 written to a temporary file when EMACS exits. MDL checks for the existence
 of this file when control is returned; if the file exists, its content is
 read into MDL, and then the file is deleted.    -Shane

 The other half is /usr/mlisp/medit.ml and /usr/mlisp/mim-mode.ml.
 (gosling emacs).
		  /a/gnu/emacs/medit.el and /usr/mlisp/mim-mode.el
 ***************************************************************************"

<PACKAGE "MEDIT">

<PACKAGE "PIPES">			;"FORKS uses pipes, but I dont."

<RENTRY PIPE>

<ENTRY GET-PIPE READ-DESC WRITE-DESC READ-SAFE-BUFFER>

<ENDPACKAGE>

<RENTRY *MEDIT-EDITOR* *MEDIT-JCL*>

<ENTRY MEDIT MEDIT-RESET MEDIT-QUERY MEDIT-PATH MEDIT-HELP MEDIT-ADD-DEFAULTS
       *MEDIT-FILENAME*>

<USE "FORKS" "TTY">

<GDECL (*MEDIT-EDITOR* *MEDIT-FILENAME*) STRING 
       (*MEDIT-JCL*) <OR STRING <LIST [REST STRING]> FALSE>
       (*MEDIT-QUERY?*) <OR ATOM FALSE> (*MEDIT-FORK*) <OR FALSE <CHANNEL 'FORK>>
       (*MEDIT-DEFAULT-PATH*) <OR FALSE <LIST [REST OBLIST]>>>

<SETG *MEDIT-FORK* <>>

;"*MEDIT-EDITOR* is the name of the exe file for the editor fork."

<OR <GASSIGNED? *MEDIT-EDITOR*>
    ;<SETG *MEDIT-EDITOR* "GEMACS">	;"For gosling emacs."
    <SETG *MEDIT-EDITOR* "GNUMACS">>	;"For gnu emacs."


<OR <GASSIGNED? *MEDIT-JCL*>
    ;<SETG *MEDIT-JCL* "-LMEDIT">	        ;"For gosling emacs."
    <SETG *MEDIT-JCL* ("-L" "/USR/MIM/MEDIT")>>	;"For gnu emacs."

<SETG *MEDIT-QUERY?* <>>

<SETG *MEDIT-DEFAULT-PATH* <>>

;"*MEDIT-FILENAME* is the name of the filename the editor writes as output."

<OR <GASSIGNED? *MEDIT-FILENAME*>
    <SETG *MEDIT-FILENAME* <STRING "/tmp/" <UNAME> ".medit.mud">>>

<DEFINE MEDIT ("OPT" (F <>) "AUX" (OUTCHAN .OUTCHAN) FN)
   #DECL ((OUTCHAN) <CHANNEL 'TTY> (F) <OR STRING FALSE> (FN) <CHANNEL 'PARSE>)
   <CHANNEL-OP .OUTCHAN CLEAR-SCREEN>
   <PRINTSTRING "[MDL => MEDIT]">
   <CRLF>
   <COND (,*MEDIT-FORK*
	  <CONTINUE-FORK ,*MEDIT-FORK* T>)
	 (.F
	  <SET FN <CHANNEL-OPEN PARSE .F>>
	  <SET F <CHANNEL-OP .FN NAME>>
	  <CHANNEL-CLOSE .FN>
	  <COND (<TYPE? ,*MEDIT-JCL* STRING>
		 <SETG *MEDIT-FORK* 
		       <RUN-FORK ,*MEDIT-EDITOR* T T ,*MEDIT-JCL* .F>>)
		(<TYPE? ,*MEDIT-JCL* LIST>
		 <SETG *MEDIT-FORK* 
		       <RUN-FORK ,*MEDIT-EDITOR* T T !,*MEDIT-JCL* .F>>)>)
	 (T 
	  <COND (<TYPE? ,*MEDIT-JCL* STRING>
		 <SETG *MEDIT-FORK* 
		       <RUN-FORK ,*MEDIT-EDITOR* T T ,*MEDIT-JCL*>>)
		(<TYPE? ,*MEDIT-JCL* LIST>
		 <SETG *MEDIT-FORK* 
		       <RUN-FORK ,*MEDIT-EDITOR* T T !,*MEDIT-JCL*>>)>)>
   <CHANNEL-OP .OUTCHAN CLEAR-SCREEN>
   <PRINTSTRING "[MDL <= MEDIT]">
   <CRLF>
   <MEDIT-READ-FILE>
   "DONE">

<DEFINE MEDIT-RESET ()
   <COND (,*MEDIT-FORK*
	  <CLOSE ,*MEDIT-FORK*>
	  <SETG *MEDIT-FORK* <>>)>
   T>

<DEFINE MEDIT-QUERY ("OPT" (BOOLEAN ,*MEDIT-QUERY?*))
   #DECL ((BOOLEAN) <OR ATOM FALSE>)
   <SETG *MEDIT-QUERY?* .BOOLEAN>>

<DEFINE MEDIT-PATH ("OPT" (PATH ,*MEDIT-DEFAULT-PATH*))
   #DECL ((PATH) <OR FALSE <LIST [REST OBLIST]>>)
   <SETG *MEDIT-DEFAULT-PATH* .PATH>>

<DEFINE MEDIT-FILENAME () <STRING "/tmp/" <UNAME> ".medit.mud">>

<DEFINE MEDIT-READ-FILE ("AUX" (FILE <OPEN "READ" ,*MEDIT-FILENAME*>)
			       (OUTCHAN .OUTCHAN) (REDEFINE T)
			       (PATH (!<GET-PATH> !.OBLIST)) FN)
   #DECL ((FILE) <OR <CHANNEL 'DISK> FALSE> (OUTCHAN) <CHANNEL 'TTY>
	  (REDEFINE) <SPECIAL ANY> (FN) STRING (PATH) <LIST [REST OBLIST]>)
   <COND (.FILE
	  <SET FN <CHANNEL-OP .FILE NAME>>
	  <UNWIND <BIND ()
		     <BLOCK .PATH>
		     <PRINC "Reading from MEDIT:">
		     <REPEAT () <PRINT <EVAL <READ .FILE '<RETURN>>>>>
		     <ENDBLOCK>
		     <CLOSE .FILE>
		     <DELFILE .FN>>
	     <BIND ()
		<ENDBLOCK>
		<CLOSE .FILE>
		<DELFILE .FN>>>)>>

<DEFINE GET-PATH ("AUX" (PATH ()) (OUTCHAN .OUTCHAN) (INCHAN .INCHAN))
   #DECL ((PATH) <LIST [REST OBLIST]> (INCHAN OUTCHAN) <CHANNEL 'TTY>)
   <COND
    (<NOT ,*MEDIT-QUERY?*>
     <OR ,*MEDIT-DEFAULT-PATH* ()>)
    (<AND ,*MEDIT-DEFAULT-PATH* <YES-NO "Use default path?">>
     ,*MEDIT-DEFAULT-PATH*)
    (<YES-NO "Do you wish to name a package?">
     <REPEAT (NAME OBL (RESPONSE <QUERY "Package name" .INCHAN>) CH)
	#DECL ((OBL) OBLIST (NAME) <OR ATOM FALSE> (RESPONSE) STRING
	       (CH) <OR <CHANNEL 'DISK> FALSE>)
	<COND
	 (<EMPTY? .RESPONSE>
	  <RETURN .PATH>)
	 (<SET NAME <LOOKUP .RESPONSE <MOBLIST PACKAGE>>>
	  <SET PATH (<SET OBL <MOBLIST .NAME>> !.PATH)>
	  <COND (<SET NAME <LOOKUP <STRING !\I .RESPONSE> .OBL>>
		 <SET PATH (<MOBLIST .NAME> !.PATH)>)>)
	 (T
	  <PRINC .RESPONSE>
	  <PRINC " is not loaded.">
	  <CRLF>
	  <COND (<YES-NO <STRING "Load " .RESPONSE "?">>
		 <COND (<SET CH <L-OPEN .RESPONSE>>
			<LOAD .CH>
			<CLOSE .CH>)
		       (<NOT <EMPTY? <SET RESPONSE <QUERY "Filename" .INCHAN>>>>
			<COND (<SET CH <L-OPEN .RESPONSE>>
			       <LOAD .CH>
			       <CLOSE .CH>)>)>
		 <COND (<AND <NOT <EMPTY? .RESPONSE>>
			     <SET NAME <LOOKUP .RESPONSE <MOBLIST PACKAGE>>>>
			<SET PATH (<SET OBL <MOBLIST .NAME>> !.PATH)>
			<COND (<SET NAME <LOOKUP <STRING !\I .RESPONSE> .OBL>>
			       <SET PATH (<MOBLIST .NAME> !.PATH)>)>)>)>)>
	<SET RESPONSE <QUERY "Another package name" .INCHAN>>>)>>

<DEFINE YES-NO (PROMPT "AUX" (INCHAN .INCHAN) (OUTCHAN .OUTCHAN))
   #DECL ((PROMPT) STRING (INCHAN OUTCHAN) <CHANNEL 'TTY>)
   <REPEAT (RESPONSE)
      #DECL ((RESPONSE) CHARACTER)
      <PRINC .PROMPT>
      <PRINC " (Y or N): ">
      <RESET .INCHAN>
      <SET RESPONSE <TYI>>
      <CRLF>
      <COND (<MEMQ .RESPONSE "Yy"> <RETURN>)
	    (<MEMQ .RESPONSE "Nn"> <RETURN <>>)>>>

<DEFINE QUERY (PROMPT "OPT" (INCHAN .INCHAN)
		      "AUX" (OUTCHAN .OUTCHAN) (S <STACK <ISTRING 64>>) N)
   #DECL ((PROMPT S) STRING (INCHAN OUTCHAN) CHANNEL (N) FIX)
   <PRINC .PROMPT>
   <PRINC " (text$): ">
   <RESET .INCHAN>
   <SET N <READSTRING .S .INCHAN <STRING <ASCII 27>>>>
   <CRLF>
   <COND (<AND <G? .N 0> <==? <ASCII 27> <NTH .S .N>>> <SET N <- .N 1>>)>
   <REPEAT ((SS:STRING <SUBSTRUC .S 0 .N <ISTRING .N>>))
      <COND (<OR <EMPTY? .SS>
		 <N==? <ASCII 32> <1 .SS>>
		 <N==? <ASCII 9> <1 .SS>>>
	     <RETURN .SS>)
	    (T
	     <SET SS <REST .SS>>)>>>

<DEFINE MEDIT-ADD-DEFAULTS ("TUPLE" NAMES "AUX" NAME OB (OUTCHAN .OUTCHAN))
   #DECL ((NAMES) <<PRIMTYPE VECTOR> [REST STRING]> (NAME) <OR ATOM FALSE>
	  (OB) OBLIST (OUTCHAN) <CHANNEL 'TTY>)
   <MAPF <>
      <FUNCTION (NEW)
	 #DECL ((NEW) STRING)
	 <COND (<SET NAME <LOOKUP .NEW <SET OB <MOBLIST PACKAGE>>>>
		<SETG *MEDIT-DEFAULT-PATH*
		      (<SET OB <MOBLIST .NAME>> !,*MEDIT-DEFAULT-PATH*)>
		<COND (<SET NAME <LOOKUP <STRING !\I .NEW> .OB>>
		       <SETG *MEDIT-DEFAULT-PATH*
			     (<MOBLIST .NAME> !,*MEDIT-DEFAULT-PATH*)>)>
		<PRINC "Added default ">
		<PRINC .NEW>)
	       (T
		<PRINC .NEW>
		<PRINC " is not loaded.">)>
	 <CRLF>>
      .NAMES>>

 <DEFINE MEDIT-HELP ("AUX" (OUTCHAN .OUTCHAN))
    #DECL ((OUTCHAN) <CHANNEL 'TTY>)
    <CHANNEL-OP .OUTCHAN CLEAR-SCREEN>
    <PRINTSTRING "
EMACS: M-z,M-Z: marks the current DEFINE, or the immediately following DEFINE.

       M-^Z:    marks the entire buffer.

       ^X Z:    exit from MEDIT.  Saves the current buffer if modified, then
		returns to MDL, sending marked stuff to MDL.

       ^X S:    exit from MEDIT.  Saves the current buffer if modified, then
		returns to MDL, sending the entire buffer.

MDL:   <MEDIT \"OPT\" FN:STRING>

       Enter EMACS. The first time that MEDIT is invoked, if FN is supplied
       (standard file name defaults), the EMACS will read that file. FN is
       ignored in subsequent invocations.

       <MEDIT-RESET>

       Kill the current EMACS if one exists. It is nice to call this before
       killing the MDL.

       <MEDIT-PATH \"OPT\" PATH:<OR FALSE <LIST [REST OBLIST]>>

       PATH will be spliced in front of the normal oblist path during loading
       from EMACS.

       <MEDIT-QUERY \"OPT\" BOOL:<OR ATOM FALSE>>

       If BOOL is non-false, you will be askeded if you wish to use the default
       path (if there is one) or if you wish to name packages to be spliced
       into the path during loading.

       <MEDIT-ADD-DEFAULTS PACKAGES:<TUPLE [REST STRING]>>

       Prepends oblists for PACKAGES to the default path. Each package must be
       loaded. Prepended proceeding from right to left (leftmost will be first
       in path).

       If you plan to debug a single package, say, \"FOO\" the best way is
       simply to do <MEDIT-ADD-DEFAULTS \"FOO\">. If you are editing multiple
       packages, do <MEDIT-QUERY T> and name the appropriate package(s) on
       return from EMACS. It is possible for new atoms internal to a package
       to end up on a wrong oblist if you zap stuff from more than one package
       at a time (this will occur if you create new functions and the first
       oblist in the path is different from the package in which the new
       functions were defined. You can set up the path yourself with
       MEDIT-PATH, but you must remember to place the internal oblist before
       the entry oblist.
	       
       <MEDIT-HELP>
		       
       The obvious.
       
       The following variables control which emacs is used (Gnu or Gosling).
       Currently, Gnu emacs is used by default.
       
       *MEDIT-EDITOR* name of editor to use {\"GNUMACS\"}
       *MEDIT-JCL* command line for editor {(\"-L\" \"/USR/MIM/MEDIT\")}
       *MEDIT-FILE* - name of zap file {\"/tmp/USER.medit.mud\"}
">
    ,NULL>

<ENDPACKAGE>
