<PACKAGE "LUP">

;"*****************************************************************************

  This package defines the update mechanism for the library system. This
  version incorporates a network library.

  COMPILATION: mimc lup -nc '<set expfload t>'

  EDIT HISTORY: LUP.MUD                  Machine Dependent (for use under UNIX)

   9OCT84 [Shane] - Created.
  10NOV84 [Shane] - Add LUP-ADD-FILE, LUP-INSTALL
  ****************************************************************************"

<ENTRY LUP-ADD-PACK LUP-DEL-PACK LUP-GC LUP-ACT LUP-DCT LUP-CREATE LUP-ABORT
       LUP-INSTALL LUP-ADD-FILE LUP-DEL-FILE>

<INCLUDE-WHEN <COMPILING? "LUP"> "L-DEFS" "L-NETDEFS" "NETDEFS">

<USE-WHEN <DEBUGGING? "LUP"> "ISYSCALL">

<USE "LIBRARY" "ABSTR" "NETWORK" "ITIME">

%%<PRINC "+LUP-BASE "> <L-FLOAD "LUP-BASE">

%%<PRINC "+LUP-NETWORK "> <L-FLOAD "LUP-NETWORK">

%%<PRINC "+LUP-USER "> <L-FLOAD "LUP-USER">

%%<CRLF>

<ENDPACKAGE>

