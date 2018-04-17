<USE "NEWSTRUC">

; "Bits for argument descriptors"
<MSETG TTY-X-POS *200*>
<MSETG TTY-Y-POS *300*>
<MSETG TTY-X/Y *100*>	; "0-->X, 1-->Y"

<MSETG TTY-ARG-BIT *40*>	; "If 1, use arg rather than cur val"
<MSETG TTY-BCD-ARG *20*>	; "Output BCD of arg, according to desc"
<MSETG TTY-INC-ARG *10*>	; "Output arg+1, according to desc"

<MSETG TTY-ARG-DESC *7*>
<MSETG TTY-LITERAL 0>
<MSETG TTY-DECIMAL 1>
<MSETG TTY-RJD2 2>
<MSETG TTY-RJD3 3>
<MSETG TTY-LIT+ 4>
<MSETG TTY-UNKNOWN 5>

; "Offsets for unix terminal descriptions" 
<MSETG TTY-FWD 1>	; "Cursor right"
<MSETG TTY-BCK 2>	; "Cursor left"
<MSETG TTY-UP 3>	; "Cursor up"
<MSETG TTY-DWN 4>	; "Cursor down"
<MSETG TTY-HRZ 5>	; "Horizontal move"
<MSETG TTY-VRT 6>	; "Vertical move"
<MSETG TTY-MOV 7>	; "Move"
<MSETG TTY-HOM 8>	; "Home up"
<MSETG TTY-HMD 9>	; "Home down"
<MSETG TTY-CLR 10>	; "Clear screen"
<MSETG TTY-CEW 11>	; "Clear to EOS"
<MSETG TTY-CEL 12>	; "Clear to EOL"
<MSETG TTY-ERA 13>	; "Erase char"
<MSETG TTY-BEC 14>	; "Backspace and erase char"
<MSETG TTY-IL 15>	; "Insert line[s]"
<MSETG TTY-DL 16>	; "Delete line[s]"
<MSETG TTY-IC 17>	; "Insert char[s]"
<MSETG TTY-DC 18>	; "Delete char[s]"
<MSETG TTY-DS 19>	; "Define scrolling region"
<MSETG TTY-SU 20>	; "Scroll up"
<MSETG TTY-SD 21>	; "Scroll down"

<MSETG MAX-TTY-OP 21>

