<PACKAGE "PRESS">

<USE-WHEN <COMPILING? "PRESS"> "BACKQUOTE">
<USE "NEWSTRUC">

<ENTRY PRESS SET-X SET-Y SHOW-CHARACTERS FONT FONT-NUMBER SHOW-RECTANGLE
       SHOW-OBJECT SET-SPACE-X SET-SPACE-Y RESET-SPACE SPACE ONLY-ON-COPY
       SHOW-CHARACTER-IMMEDIATE NEW-ENTITY NEW-PAGE MOVETO DRAWTO DRAWCURVE> 

<NEW-CHANNEL-TYPE PRESS				DEFAULT
                  OPEN				PRESS-OPEN
                  CLOSE				PRESS-CLOSE
                  SET-X				PRESS-SET-X
                  SET-Y				PRESS-SET-Y
                  SHOW-CHARACTERS		PRESS-SHOW-CHARACTERS
                  SHOW-CHARACTER-IMMEDIATE	PRESS-SHOW-CHARACTER-IMMEDIATE
                  FONT				PRESS-FONT
                  SHOW-RECTANGLE		PRESS-SHOW-RECTANGLE
                  ;"These operations not implemented by stupid dover."
                  ;SHOW-OBJECT			;PRESS-SHOW-OBJECT
                  ;SET-SPACE-X			;PRESS-SET-SPACE-X
                  ;SET-SPACE-Y			;PRESS-SET-SPACE-Y
                  ;RESET-SPACE			;PRESS-RESET-SPACE
                  SPACE				PRESS-SPACE
                  ONLY-ON-COPY			PRESS-ONLY-ON-COPY
                  NEW-ENTITY			PRESS-NEW-ENTITY
                  NEW-PAGE			PRESS-NEW-PAGE>

<NEWSTRUC PRESS-CHAN	VECTOR
          DISK-CHAN	<CHANNEL 'DISK>
          FONTS		<VECTOR [16 <OR FALSE VECTOR>]>
          DATA-START	FIX
          PAGE-START	FIX
          COMMANDS	QUEUE
          ENTITIES	QUEUE
          PAGES		QUEUE>

<DEFINE PRINT-PRESS-CHAN (PC)
   #DECL ((PC) PRESS-CHAN)
   <PRIN1 <DISK-CHAN .PC>>>

<COND (<GASSIGNED? PRINT-PRESS-CHAN>
       <PRINTTYPE PRESS-CHAN ,PRINT-PRESS-CHAN>)>

<NEWSTRUC QUEUE		VECTOR
          LIST-Q	LIST
          LAST-Q	LIST>

<DEFINE NEW-Q () <CHTYPE [() ()] QUEUE>>

<DEFINE ENQ (Q OBJ "AUX" LQ) 
   #DECL ((Q) QUEUE (LQ) <LIST ANY>)
   <SET LQ (.OBJ)>
   <COND (<EMPTY? <LIST-Q .Q>> <LIST-Q .Q .LQ> <LAST-Q .Q .LQ>)
         (ELSE <PUTREST <LAST-Q .Q> .LQ> <LAST-Q .Q .LQ>)>
   .Q>

<DEFINE RESET-Q (Q) #DECL ((Q) QUEUE) <LIST-Q .Q ()> <LAST-Q .Q ()> .Q>

<NEWTYPE BYTE FIX>
<NEWTYPE LONG FIX>

<DEFINE PRESS-OPEN (STYPE OPR NAME) 
   #DECL ((NAME) STRING)
   <CHTYPE [<CHANNEL-OPEN DISK .NAME "CREATE" "8BIT">
            <IVECTOR 16 %<>>
            0
            0
            <NEW-Q>
            <NEW-Q>
            <NEW-Q>]
           PRESS-CHAN>>

<DEFINE PRESS-SET-X (CHAN OPER NUM
                     "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (NUM) FIX (CMDS) QUEUE)
   <ENQ .CMDS #BYTE *000000000356*>
   <ENQ .CMDS <CHTYPE .NUM WORD>>
   .NUM>

<DEFINE PRESS-SET-Y (CHAN OPER NUM
                     "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (NUM) FIX (CMDS) QUEUE)
   <ENQ .CMDS #BYTE *000000000357*>
   <ENQ .CMDS <CHTYPE .NUM WORD>>
   .NUM>

<DEFINE PRESS-SHOW-CHARACTER-IMMEDIATE (CHAN OPER CHAR
                                        "AUX"
                                        (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (CHAR) <OR CHARACTER FIX> (CMDS) QUEUE)
   <ENQ .CMDS #BYTE *363*>
   <ENQ .CMDS <CHTYPE .CHAR BYTE>>
   .CHAR>

<DEFINE PRESS-SHOW-CHARACTERS (CHAN OPER STR "OPT" LEN
                               "AUX" 
                               (DATA <CHANNEL-DATA .CHAN>)
                               (CMDS <COMMANDS .DATA>)
                               (DCHAN:<CHANNEL 'DISK> <DISK-CHAN .DATA>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (STR) <OR STRING BYTES>
          (CMDS) QUEUE (LEN) FIX)
   <COND (<NOT <ASSIGNED? LEN>>
          <COND (<TYPE? .STR STRING>
                 <SET LEN <LENGTH .STR>>)
                (ELSE
                 <SET LEN <LENGTH .STR>>)>)>
   <COND (<0? .LEN>)
         (<1? .LEN>
          <ENQ .CMDS #BYTE *363*>
          <ENQ .CMDS <CHTYPE .CHAR BYTE>>)
         (ELSE
          <WRITE-STRING .DCHAN .STR .LEN>
          <COND (<L=? .LEN 32>
                 <ENQ .CMDS <CHTYPE <- .LEN 1> BYTE>>)
                (ELSE
                 <ENQ .CMDS #BYTE *000000000360*>
                 <ENQ .CMDS <CHTYPE .LEN BYTE>>)>)>
   .LEN>

<DEFINE PRESS-FONT (CHAN OPER FONT
                    "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (FONT) STRING (CMDS) QUEUE)
   <ENQ .CMDS <CHTYPE <+ 112 <FONT-NUMBER .CHAN .FONT>> BYTE>>
   .FONT>

;<DEFINE PRESS-SET-SPACE-X (CHAN OPER NUM
                            "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
    #DECL ((CHAN) <CHANNEL 'PRESS> (NUM) FIX (CMDS) QUEUE)
    <ENQ .CMDS #BYTE *000000000364*>
    <ENQ .CMDS <CHTYPE .NUM WORD>>
    .NUM>

;<DEFINE PRESS-SET-SPACE-Y (CHAN OPER NUM
                            "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
    #DECL ((CHAN) <CHANNEL 'PRESS> (NUM) FIX (CMDS) QUEUE)
    <ENQ .CMDS #BYTE *000000000365*>
    <ENQ .CMDS <CHTYPE .NUM WORD>>
    .NUM>

;<DEFINE PRESS-RESET-SPACE (CHAN OPER
                            "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
    #DECL ((CHAN) <CHANNEL 'PRESS> (CMDS) QUEUE)
    <ENQ .CMDS #BYTE *000000000366*>
    T>

<DEFINE PRESS-SPACE (CHAN OPER) 
   #DECL ((CHAN) <CHANNEL 'PRESS>)
   <ENQ <COMMANDS <CHANNEL-DATA .CHAN>> #BYTE *000000000367*>
   T>

<DEFINE PRESS-SHOW-RECTANGLE (CHAN OPER WIDTH HEIGHT
                              "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (WIDTH HEIGHT) FIX (CMDS) QUEUE)
   <ENQ .CMDS #BYTE *000000000376*>
   <ENQ .CMDS <CHTYPE .WIDTH WORD>>
   <ENQ .CMDS <CHTYPE .HEIGHT WORD>>
   T>

;<DEFINE PRESS-SHOW-OBJECT (CHAN OPER "TUPLE" MOVES
                            "AUX" 
                            (DATA <CHANNEL-DATA .CHAN>)
                            (CMDS <COMMANDS .DATA>)
                            (DCHAN:<CHANNEL 'DISK> <DISK-CHAN .DATA>)
                            START)
    #DECL ((CHAN) <CHANNEL 'PRESS> (MOVES) <TUPLE [REST <LIST ATOM>]>
           (CMDS) QUEUE (START) FIX)
    <SET START <MY-ACCESS .DCHAN>>
    <MAPF %<>
          <FUNCTION (MV "AUX" (ATM <1 .MV>))
             #DECL ((MV) <LIST ATOM> (ATM) ATOM)
             <COND (<==? .ATM MOVETO>
                    <WRITE-WORD .DCHAN 0>
                    <WRITE-WORD .DCHAN <2 .MV>>
                    <WRITE-WORD .DCHAN <3 .MV>>)
                   (<==? .ATM DRAWTO>
                    <WRITE-WORD .DCHAN 1>
                    <WRITE-WORD .DCHAN <2 .MV>>
                    <WRITE-WORD .DCHAN <3 .MV>>)
                   (<==? .ATM DRAWCURVE>
                    <WRITE-WORD .DCHAN 2>
                    <WRITE-FLOAT .DCHAN <2 .MV>>
                    <WRITE-FLOAT .DCHAN <3 .MV>>
                    <WRITE-FLOAT .DCHAN <4 .MV>>
                    <WRITE-FLOAT .DCHAN <5 .MV>>
                    <WRITE-FLOAT .DCHAN <6 .MV>>
                    <WRITE-FLOAT .DCHAN <7 .MV>>)>>
          .MOVES>
    <ENQ .CMDS #BYTE *373*>
    <ENQ .CMDS <CHTYPE <- <MY-ACCESS .DCHAN> .START> WORD>>
    T>

<DEFINE PRESS-ONLY-ON-COPY (CHAN OPER "OPT" (NUM 0)
                            "AUX" (CMDS <COMMANDS <CHANNEL-DATA .CHAN>>))
   #DECL ((CHAN) <CHANNEL 'PRESS> (CMDS) QUEUE)
   <ENQ .CMDS #BYTE *355*>
   <ENQ .CMDS <CHTYPE .NUM BYTE>>
   .NUM>

<DEFINE FONT-NUMBER (CHAN STR "AUX" (FONT <PARSE-FONT-NAME .STR>)) 
   #DECL ((CHAN) <CHANNEL 'PRESS> (STR) STRING (FONT) VECTOR)
   <MAPR %<>
         <FUNCTION (RFN "AUX" (THIS <1 .RFN>)) 
            #DECL ((RFN) <VECTOR [REST <OR VECTOR FALSE>]>
                   (THIS) <OR VECTOR FALSE>)
            <COND (<NOT .THIS>
                   <1 .RFN .FONT>
                   <MAPLEAVE <- 16 <LENGTH .RFN>>>)
                  (<=? .THIS .FONT>
                   <MAPLEAVE <- 16 <LENGTH .RFN>>>)>>
         <FONTS <CHANNEL-DATA .CHAN>>>>

<DEFINE PRESS-NEW-ENTITY (CHAN OPER
                          "AUX" (DATA <CHANNEL-DATA .CHAN>)
                          (DCHAN:<CHANNEL 'DISK> <DISK-CHAN .DATA>)
                          (CMDS <COMMANDS .DATA>) (EL <ENTITIES .DATA>)
                          BCMDS BTRLR END-OF-DATA)
   #DECL ((CHAN) <CHANNEL 'PRESS> (DATA) PRESS-CHAN (EL CMDS) QUEUE
          (BCMDS BTRLR) BYTES (END-OF-DATA) FIX)
   <COND (<NOT <EMPTY? <LIST-Q .CMDS>>>
          <COND (<1? <MOD <BYTE-LENGTH <LIST-Q .CMDS>> 2>>
                 <ENQ .CMDS #BYTE *000000000377*>)>
          <SET END-OF-DATA <MY-ACCESS .DCHAN>>
          <SET BCMDS <MAKE-BYTES !<LIST-Q .CMDS!>>>
          <SET BTRLR
               <MAKE-BYTES #BYTE *000000000000*
                           #BYTE *000000000000*
                           <CHTYPE <- <PAGE-START .DATA>
                                      <DATA-START .DATA>> LONG>
                           <CHTYPE <- .END-OF-DATA <DATA-START .DATA>>
                                   LONG>
                           #WORD *000000000000*
                           #WORD *000000000000*
                           #WORD *000000000000*
                           #WORD *000000000000*
                           #WORD *000000052126*
                           #WORD *000000066444*
                           <CHTYPE </ <+ <LENGTH .BCMDS> 24> 2> WORD>>>
          <ENQ .EL .BCMDS>
          <ENQ .EL .BTRLR>
          <DATA-START .DATA .END-OF-DATA>
          <RESET-Q .CMDS>)>
   T>

<DEFINE PRESS-NEW-PAGE (CHAN OPER "AUX" (DATA <CHANNEL-DATA .CHAN>)
                        (DCHAN:<CHANNEL 'DISK> <DISK-CHAN .DATA>)
                        (EL <ENTITIES .DATA>) PAGE-END END-OF-EL) 
   #DECL ((CHAN) <CHANNEL 'PRESS> (PAGE-END END-OF-EL) FIX)
   <PRESS-NEW-ENTITY .CHAN .OPER>
   <COND (<NOT <EMPTY? <LIST-Q .EL>>>
          <COND (<1? <MOD <MY-ACCESS .DCHAN> 2>> <WRITE-BYTE .DCHAN 0>)>
          <WRITE-WORD .DCHAN 0>
          <MAPF %<>
                <FUNCTION (BUF) #DECL ((BUF) BYTES)
                   <WRITE-BYTES .DCHAN .BUF>>
                <LIST-Q .EL>>
          <SET END-OF-EL <MY-ACCESS .DCHAN>>
          <SET PAGE-END <NEXT-RECORD .DCHAN>>
          <ENQ <PAGES .DATA>
               <MAKE-BYTES #WORD *000000000000*
                           <CHTYPE </ <PAGE-START .DATA> 512> WORD>
                           <CHTYPE </ <- .PAGE-END <PAGE-START .DATA>>
                                      512>
                                   WORD>
                           <CHTYPE </ <- .PAGE-END .END-OF-EL> 2>
                                   WORD>>>
          <PAGE-START .DATA .PAGE-END>
          <DATA-START .DATA .PAGE-END>
          <RESET-Q .EL>)>
   T>

<SETG PADDING <IBYTES 117 255>>

<DEFINE PRESS-CLOSE (CHAN OPER "AUX" (DATA <CHANNEL-DATA .CHAN>)
                     (DCHAN:<CHANNEL 'DISK> <DISK-CHAN .DATA>)
                     FONT-DIR-START PART-DIR-START
                     DOC-DIR-START (PAGE-COUNT 0))
   #DECL ((CHAN) <CHANNEL 'PRESS>)
   <PRESS-NEW-PAGE .CHAN .OPER>
   <SET FONT-DIR-START <MY-ACCESS .DCHAN>>
   <COND (<NOT <1 <FONTS .DATA>>>
          <1 <FONTS .DATA> '["HELVETICA" 12 0]>)>
   <MAPR %<>
         <FUNCTION (RFONTS "AUX" (FONT <1 .RFONTS>))
            #DECL ((FONT) <OR FALSE <VECTOR STRING FIX FIX>>)
            <COND (.FONT
                   <WRITE-WORD .DCHAN 16>
                   <WRITE-BYTE .DCHAN 0>
                   <WRITE-BYTE .DCHAN <- 16 <LENGTH .RFONTS>>>
                   <WRITE-BYTE .DCHAN 0>
                   <WRITE-BYTE .DCHAN 255>
                   <WRITE-BCPL .DCHAN <1 .FONT>>
                   <MY-ACCESS .DCHAN
                              <+ <MY-ACCESS .DCHAN>
                                 <- 19 <LENGTH <1 .FONT>>>>>
                   <WRITE-BYTE .DCHAN <3 .FONT>>
                   <WRITE-BYTE .DCHAN 0>
                   <WRITE-WORD .DCHAN <2 .FONT>>
                   <WRITE-WORD .DCHAN 0>)
                  (ELSE <MAPLEAVE>)>>
         <FONTS .DATA>>
   
   <SET PART-DIR-START <NEXT-RECORD .DCHAN>>
   <MAPF %<>
         <FUNCTION (PAGE)
            <SET PAGE-COUNT <+ .PAGE-COUNT 1>>
            <WRITE-BYTES .DCHAN .PAGE>>
         <LIST-Q <PAGES .DATA>>>
   <WRITE-WORD .DCHAN 1>
   <WRITE-WORD .DCHAN </ .FONT-DIR-START 512>>
   <WRITE-WORD .DCHAN </ <- .PART-DIR-START .FONT-DIR-START> 512>>
   <WRITE-WORD .DCHAN 0>
   
   <SET DOC-DIR-START <NEXT-RECORD .DCHAN>>
   <WRITE-WORD .DCHAN 27183>
   <WRITE-WORD .DCHAN <+ </ .DOC-DIR-START 512> 1>>
   <WRITE-WORD .DCHAN <+ .PAGE-COUNT 1>>
   <WRITE-WORD .DCHAN </ .PART-DIR-START 512>>
   <WRITE-WORD .DCHAN </ <- .DOC-DIR-START .PART-DIR-START> 512>>
   <WRITE-WORD .DCHAN </ .DOC-DIR-START 512>>
   <WRITE-LONG .DCHAN 0>
   <WRITE-WORD .DCHAN 1>
   <WRITE-WORD .DCHAN 1>
   <WRITE-WORD .DCHAN -1>
   <WRITE-WORD .DCHAN -1>
   <WRITE-WORD .DCHAN -1>
   <WRITE-BYTES .DCHAN ,PADDING>
   <WRITE-BCPL .DCHAN "FOO.PRESS">
   <MY-ACCESS .DCHAN <+ .DOC-DIR-START 154>>
   <WRITE-BCPL .DCHAN "SAM">
   <MY-ACCESS .DCHAN <+ .DOC-DIR-START 170>>
   <WRITE-BCPL .DCHAN "TODAY">
   <MY-ACCESS .DCHAN <+ .DOC-DIR-START 511>>
   <WRITE-BYTE .DCHAN 0>
   <CLOSE <DISK-CHAN .DATA>>
   .CHAN>

<DEFMAC MY-ACCESS ('DCHAN "OPT" 'NUM)
   <COND (<ASSIGNED? NUM>
          `<CHANNEL-OP ~.DCHAN ACCESS ~.NUM>)
         (ELSE
          `<CHANNEL-OP ~.DCHAN ACCESS>:FIX)>>

<DEFINE NEXT-RECORD (DCHAN "AUX" N) 
   #DECL ((DCHAN) <CHANNEL 'DISK> (N) FIX)
   <SET N <* <+ </ <MY-ACCESS .DCHAN> 512> 1> 512>>
   <MY-ACCESS .DCHAN .N>
   .N>

<DEFMAC WRITE-BYTE ('DCHAN 'NUM) 
   `<CHANNEL-OP ~.DCHAN WRITE-BYTE ~.NUM>>

<DEFMAC WRITE-WORD ('DCHAN 'NUM) 
   `<BIND ((DCHAN ~.DCHAN) (NUM ~.NUM))
       #DECL ((DCHAN) <CHANNEL 'DISK> (NUM) FIX)
       <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .NUM -8>>
       <CHANNEL-OP .DCHAN WRITE-BYTE .NUM>>>

<DEFMAC WRITE-LONG ('DCHAN 'NUM) 
   `<BIND ((DCHAN ~.DCHAN) (NUM ~.NUM))
       #DECL ((DCHAN) <CHANNEL 'DISK> (NUM) FIX)
       <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .NUM -24>>
       <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .NUM -16>>
       <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .NUM -8>>
       <CHANNEL-OP .DCHAN WRITE-BYTE .NUM>>>

<DEFINE WRITE-FLOAT (DCHAN NUM "AUX" (FX <CHTYPE .NUM FIX>))
   #DECL ((DCHAN) <CHANNEL 'DISK> (NUM) FLOAT
          (FX) FIX)
   <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .FX -28>>
   <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .FX -20>>
   <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .FX -12>>
   <CHANNEL-OP .DCHAN WRITE-BYTE <LSH .FX -4>>>

<DEFMAC WRITE-BYTES ('DCHAN 'B) 
   `<CHANNEL-OP ~.DCHAN WRITE-BUFFER ~.B>>

<DEFINE WRITE-STRING (DCHAN S "OPT" LEN)
   #DECL ((DCHAN) <CHANNEL 'DISK> (S) <OR STRING BYTES> (LEN))
   <COND (<TYPE? .S BYTES>
          <COND (<NOT <ASSIGNED? LEN>> <SET LEN <LENGTH .S>>)>
          <CHANNEL-OP .DCHAN WRITE-BUFFER .S .LEN>)
         (ELSE
          <REPEAT ((I 1))
             #DECL ((I) FIX)
             <CHANNEL-OP .DCHAN WRITE-BYTE <CHTYPE <1 .S> FIX>>
             <COND (<G? <SET I <+ .I 1>> .LEN> <RETURN>)>>)>>

<DEFMAC WRITE-BCPL ('DCHAN 'S) 
   `<BIND ((DCHAN ~.DCHAN) (S ~.S))
       #DECL ((DCHAN) <CHANNEL 'DISK> (S) STRING)
       <CHANNEL-OP .DCHAN WRITE-BYTE <LENGTH .S>>
       <MAPF %<>
             <FUNCTION (C) 
                #DECL ((C) CHARACTER)
                <CHANNEL-OP .DCHAN WRITE-BYTE <ASCII .C>>>
             .S>>>

<DEFINE MAKE-BYTES ("TUPLE" T) 
   #DECL ((T) <TUPLE [REST <OR BYTE WORD LONG>]>)
   <MAPF ,BYTES
         <FUNCTION (N) 
            <COND (<TYPE? .N BYTE> <MAPRET <CHTYPE .N FIX>>)
                  (<TYPE? .N WORD>
                   <MAPRET <LSH .N -8> <CHTYPE .N FIX>>)
                  (<TYPE? .N LONG>
                   <MAPRET <LSH .N -24>
                           <LSH .N -16>
                           <LSH .N -8>
                           <CHTYPE .N FIX>>)>>
         .T>>

<DEFINE BYTE-LENGTH (L) 
   #DECL ((L) <LIST [REST <OR BYTE WORD LONG>]>)
   <MAPF ,+
         <FUNCTION (N) 
            <COND (<TYPE? .N BYTE> 1)
                  (<TYPE? .N WORD> 2)
                  (<TYPE? .N LONG> 4)>>
         .L>>

<DEFINE PARSE-FONT-NAME (STR "AUX" (SIZE 0))
   #DECL ((STR) STRING (SIZE) FIX)
   [<MAPR ,STRING
          <FUNCTION (RSTR "AUX" (C <1 .RSTR>) (N <ASCII .C>)) 
             <COND (<AND <G=? .N 48> <L=? .N 57>>
                    <SET STR .RSTR>
                    <MAPSTOP>)
                   (<AND <G=? .N 97> <L=? .N 122>>
                    <MAPRET <ASCII <+ .N -32>>>)
                   (ELSE <MAPRET .C>)>>
          .STR>
    <MAPR %<>
          <FUNCTION (RSTR "AUX" (C <1 .RSTR>) (N <ASCII .C>)) 
             <COND (<AND <G=? .N 48> <L=? .N 57>>
                    <SET STR .RSTR>
                    <SET SIZE <+ <* 10 .SIZE> <- .N 48>>>)
                   (ELSE <SET STR .RSTR> <MAPLEAVE .SIZE>)>>
          .STR>
    <MAPF ,+
          <FUNCTION (C) 
             <COND (<OR <==? .C !\B> <==? .C !\b>> 2)
                   (<OR <==? .C !\L> <==? .C !\l>> 4)
                   (<OR <==? .C !\I> <==? .C !\i>> 1)
                   (<OR <==? .C !\C> <==? .C !\c>> 6)
                   (<OR <==? .C !\E> <==? .C !\e>> 12)
                   (ELSE 0)>>
          .STR>]>

<ENDPACKAGE>
