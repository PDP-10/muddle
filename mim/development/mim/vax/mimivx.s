.set	version, 73

/* UNIX version */
/* (begin long comment)

Various assembler requirements: here for reference:

RADIX CONTROL:
	leading 0 ==> octal
	no leading 0 ==> decimal
	leading 0X (0x) ==> hex
	floats, if I need them...

TEXT:
	'C ==> ascii value of C
	"string" ==> counted string (try this...)
	
LABELS:
	Lfoo labels are discarded
	n: (0 <= n <= 9) ==> local label, nb(ackwards) nf(orward) references

OPERATORS:
	+ - * /  obvious
	% modulo
	(& and) (| or) (^ xor) (> right-shift) (< left-shift) (! or-not)

OTHER:
	.ALIGN n ==> align to n-zero boundary
	.SPACE n ==> N bytes of zeros are assembled
	.BYTE (.WORD .LONG .QUAD) expr, expr, expr, expr, ....
	.ASCII (.ASCIZ) string, string, string, ...

	.SET symbol, value ==> enter SYMBOL into symbol table
	
!!!	use $ instead of #	!!!
!!!	use * instead of @	!!!

(end comment) */


/* Begin long comment about MDL

Register allocation:

	TP (r13)	;MDL stack
	FR (r12)	;MDL frame
	MS (r11)	;Current MSUBR pointer

	r0		;Type in type/value pair
	r1		;Value

Memory layout: (addresses are in hex)

P0:		=========================
0000 0000	I	dispatch	I
		I	 table		I
		=========================
0000 0200	I	  MIMI		I
		I	  code		I
		=========================
000? ????	I      Pure space	I
		=========================
000? ????	I      FBIN space	I
		=========================
000? ????	I	MDL stack	I
		I	   ||		I
		I	   ||		I
		I	  \||/		I
		I	   \/		I
3FFF FFFF	.........................

P1:		.........................
4000 0000	I			I
		I	   /\		I
		I	  /||\		I
		I	   ||		I
		I	   ||		I
7FFF FAFF:	I	GC space	I
		=========================
		I	(1 Kword)	I
7FFF FBFF:	I	SP stack	I
		=========================
		I	 system		I
		I	variables	I
7FFF FFFF	I	(1 Kword)	I
		=========================

(end long MDL comment)	*/

/* definitions of system calls */

	.set	_exit, 1
	.set	_fork, 2
	.set	_read, 3
	.set	_write, 4
	.set	_open, 5
	.set	_close, 6
/*	.set	_wait, 7	*/
	.set	_creat, 8
	.set	_link, 9
	.set	_unlink, 10
	.set	_exec, 11
	.set	_chdir, 12
/*	.set	_time, 13	*/
	.set	_mknod, 14
	.set	_chmod, 15
	.set	_chown, 16
	.set	_break, 17	/* seems to still exist */
/*	.set	_stat, 18	*/
	.set	_lseek, 19
	.set	_getpid, 20
	.set	_mount, 21
	.set	_umount, 22
/*	.set	_setuid, 23	*/
	.set	_getuid, 24
/*	.set	_stime, 25	*/
	.set	_ptrace, 26
/*	.set	_alarm, 27	*/
/*	.set	_fstat, 28	*/
/*	.set	_pause, 29	*/
/*	.set	_utime, 30	*/
/*	.set	_stty, 31	*/
/*	.set	_gtty, 32	*/
	.set	_access, 33
/*	.set	_nice, 34	*/
/*	.set	_ftime, 35	*/
	.set	_sync, 36
	.set	_kill, 37
	.set	_stat, 38
/*	.set	_setpgrp, 39	*/
	.set	_lstat, 40
	.set	_dup, 41
	.set	_pipe, 42
/*	.set	_times, 43	*/
	.set	_profil, 44
/*	.set	_setgid, 46	*/
	.set	_getgid, 47
/*	.set	_signal, 48	*/
	.set	_acct, 51
/*	.set	_phys, 52	*/
/*	.set	_lock, 53	*/
	.set	_ioctl, 54
	.set	_reboot, 55
/*	.set	_mpx, 56	*/
	.set	_symlink, 57
	.set	_readlink, 58
	.set	_execve, 59
	.set	_umask, 60
	.set	_chroot, 61
	.set	_fstat, 62
	.set	_getpagesize, 64
	.set	_mremap, 65
/*	.set	_vfork, 66	*/
/*	.set	_vread, 67	*/
/*	.set	_vwrite, 68	*/
	.set	_sbrk, 69
	.set	_sstk, 70
	.set	_mmap, 71
/*	.set	_vadvise, 72	*/
	.set	_vhangup, 76
/*	.set	_vlimit, 77	*/
	.set	_mincore, 78
	.set	_getgroups, 79
	.set	_setgroups, 80
	.set	_getpgrp, 81
	.set	_setpgrp, 82
	.set	_setitimer, 83
	.set	_wait, 84
	.set	_vswapon, 85
	.set	_getitimer, 86
	.set	_gethostname, 87
	.set	_sethostname, 88
	.set	_getdtablesize, 89
	.set	_dup2, 90
	.set	_getdopt, 91
	.set	_fcntl, 92
	.set	_select, 93
	.set	_setdopt, 94
	.set	_fsync, 95
	.set	_setpriority, 96
	.set	_socket, 97
	.set	_connect, 98
	.set	_accept, 99
	.set	_getpriority, 100
	.set	_send, 101
	.set	_recv, 102
	.set	_bind, 104
	.set	_setsockopt, 105
	.set	_listen, 106
	.set	_vtimes, 107
	.set	_sigvec, 108
	.set	_sigblock, 109
	.set	_sigsetmask, 110
	.set	_sigpause, 111
	.set	_sigstack, 112
	.set	_recvmsg, 113
	.set	_sendmsg, 114
	.set	_gettimeofday, 116
	.set	_getrusage, 117
	.set	_getsockopt, 118
	.set	_readv, 120
	.set	_writev, 121
	.set	_settimeofday, 122
	.set	_fchown, 123
	.set	_fchmod, 124
	.set	_recvfrom, 125
	.set	_setreuid, 126
	.set	_setregid, 127
	.set	_rename, 128
	.set	_truncate, 129
	.set	_ftruncate, 130
	.set	_flock, 131
	.set	_sendto, 133
	.set	_shutdown, 134
	.set	_socketpair, 135
	.set	_mkdir, 136
	.set	_rmdir, 137
	.set	_utimes, 138
	.set	_revoke, 140
	.set	_getpeername, 141
	.set	_gethostid, 142
	.set	_sethostid, 143
	.set	_getrlimit, 144
	.set	_setrlimit, 145
	.set	_killpg, 146
	.set	_setquota, 148
	.set	_quota, 149
	.set	_getsockname, 150

/* Random definitions */

	.set upages, 12
	.set ubytes, upages*512
	.set topwds, 5
	.set sysbot, 0x7FFFFFFF-ubytes-topwds*4+1
	.set intflg, 0x7FFFFFFF-ubytes-3
	.set stkbot, 0x7FFFFFFF-ubytes-7
	.set stkmax, 0x7FFFFFFF-ubytes-11
	.set bindid, 0x7FFFFFFF-ubytes-15
	.set spsto, 0x7FFFFFFF-ubytes-19
	.set L_SET, 0
	.set O_RDONLY, 0
	.set O_WRONLY, 1
	.set O_RDWR, 2
	.set O_NDELAY, 4
	.set O_APPEND, 10
	.set O_CREAT, 01000
	.set O_TRUNC, 02000
	.set O_EXCL, 04000
	.set _chmk, 0xBC
	.set EINTR, 4
	.set ENOSPC, 28
	.set sig_int, 2
	.set sig_quit, 3
	.set sig_ill, 4
	.set sig_fpe, 8
	.set sig_bus, 10
	.set sig_segv, 11
	.set sig_sys, 12
	.set sig_pipe, 13
	.set sig_alrm, 14
	.set sig_urg, 16
	.set sig_tstp, 18
	.set sig_cont, 19
	.set sig_chld, 20
	.set sig_ttou, 22
	.set sig_io, 23
	.set sig_xcpu, 24
	.set sig_xfsz, 25
	.set tiocsetn, 0x8006740a
	.set tioclset, 0x8004747d
	.set tiocsetc, 0x80067411
	.set tiocsltc, 0x80067475
	.set wds_page, 256		/* words per page */
	.set byts_page, wds_page*4	/* bytes per page */
	.set byts_page_sh, -10
	.set gcsize, 250000		/* words of gc initially */
	.set gcsizb, gcsize*4		/* bytes of gc space */
	.set gcsizp, gcsize/wds_page	/* pages of gc space */
	.set gcfoff, 12			/* offset into zone to point to gc */
	.set gcaoff, 44			/* list of areas in zone */
	.set abot, 0
	.set amin, 4
	.set amax, 8			/* offsets into area */
	.set tp_sizew, 100000		/* tp stack size (words) */
	.set tp_size, tp_sizew*4
	.set tp_buf, 6000		/* buffer above tp stack */
	.set pur_init, 52000		/* eventually enough to hold fbins */
	.set zlnt, 5			/* elements in a zone vector */
	.set rlimit_stack, 3		/* parameter to set max stack area size
					    which is gc space for us */ 
	.set rlimit_data, 2
	.set gcstart, 0x7FFFFAFF	/* start (top) of GC space */
	.set spstart, 0x7FFFFBFF	/* start (top) of system stack */
	.set hsize, 237			/* atom hash table size */
	.set lhsize, hsize*2+2		/* longwords needed for htable */

	.set minf.len, 10		/* length of minf vector */
	.set jmpa, 0x9f			/* start of JMP abs instruction */


/* Type code definitions */

	.set dope, 040		/* Dope bit for stack things */
	.set dope_bit, 02000000
	.set mark_bit, 0x8000

/* bit definitions sometimes usefull */
	.set bit0,  000000000001
	.set bit1,  000000000002
	.set bit2,  000000000004
	.set bit3,  000000000010
	.set bit4,  000000000020
	.set bit5,  000000000040
	.set bit6,  000000000100
	.set bit7,  000000000200
	.set bit8,  000000000400
	.set bit9,  000000001000
	.set bit10, 000000002000
	.set bit11, 000000004000
	.set bit12, 000000010000

	.set bit29, 004000000000
	.set bit30, 010000000000
	.set bit31, 020000000000

/* Primtypes */

	.set pt.fix,0
	.set pt.list,1
	.set pt.rec,2
	.set pt.bytes,4
	.set pt.str,5
	.set pt.uvec,6
	.set pt.vec,7
	.set pt.bits,7

/* types - coded so that rightmost 3 bits are primtype */


	.set	t.any, 0	/* not REALLY a type, but.. */

	.set	shft,0100	/* used to shift type code left */

	.set	t.unb, pt.fix+shft*0
	.set	t.fix, pt.fix+shft*1
	.set	t.char, pt.fix+shft*2
	.set	t.float, pt.fix+shft*3

	.set	t.list, pt.list+shft*4
	.set	t.false, pt.list+shft*5
	.set	t.decl, pt.list+shft*6

	.set	t.str, pt.str+shft*7
	.set	t.mcode, pt.uvec+shft*8
	.set	t.vec, pt.vec+shft*9
	.set	t.msubr, pt.vec+shft*10
	.set	t.tat, pt.vec+shft*34		/* out of order */

	.set	t.frame, pt.rec+shft*11
	.set	t.bind, pt.rec+shft*12
	.set	t.atom, pt.rec+shft*13
	.set	t.obl, pt.rec+shft*14
	.set	t.gbind, pt.rec+shft*15
	.set	t.qfram, pt.rec+shft*33		/* out of order */

	.set	t.form, pt.list+shft*16
	.set	t.typc, pt.fix+shft*17
	.set	t.term, pt.fix+shft*18
	.set	t.segm, pt.list+shft*19
	.set	t.defer, pt.list+shft*20
	.set	t.func, pt.list+shft*21
	.set	t.macro, pt.list+shft*22
	.set	t.chan, pt.vec+shft*23
	.set	t.entry, pt.vec+shft*24
	.set	t.adecls, pt.vec+shft*25
	.set	t.offs, pt.vec+shft*26
	.set	t.lval, pt.rec+shft*27
	.set	t.gval, pt.rec+shft*28
	.set	t.link, pt.rec+shft*29
	.set	t.tuple, pt.vec+shft*30
	.set	t.uvec, pt.uvec+shft*31
	.set	t.imsub, pt.vec+shft*32
	.set	t.sdtab, pt.vec+shft*35
	.set	t.diskc, pt.vec+shft*36
	.set	t.mudch, pt.vec+shft*37
	.set	t.word, pt.fix+shft*38
	.set	t.pcode, pt.uvec+shft*39
	.set	t.zone, pt.vec+shft*40
	.set	t.gcpar, pt.uvec+shft*41
	.set	t.area, pt.uvec+shft*42
	.set	t.sframe, pt.rec+shft*43
	.set	t.bytes, pt.bytes+shft*44
	.set	t.typw, pt.fix+shft*45
	.set	t.qsfra, pt.rec+shft*46
	.set	t.bits, pt.fix+shft*47
	.set	t.kentry, pt.vec+shft*48
	.set	t.fretyp, 49		/* first type for used-defined */

/* Internal structures */

  /* object:	(may be added to xx.obj to get real offset) */
	.set	o.typ, 0
	.set	o.cnt, 2
	.set	o.val, 4

	.set	ot, 0	/* shorthand alternates for object offsets */
	.set	oc, 2
	.set	ov, 4

  /* dope:	(usually added to xx.dope to find real offset) */
	.set	dp.typ, 0	/* type of this thing */
	.set	dp.len, 2	/* length */
	.set	dp.gc, 4	/* GC word */

  /* frame:	(stack offsets) */
	.set	fr.act, -4	/* relative PC stored for AGAIN */
	  .set	  fr.ffb, -1	
	  .set	  ffbit, 0200	/* 
		 note that the MSB of fr.act flags glued frames
		this is a kludge, but it works.  The bit is on
		iff the frame is NOT a glued frame. */
	.set	fr.tp, -6	/* TP to restore on AGAIN	(2 bytes) */
	.set	fr.sp, -8	/* SP pointer for frame		(2 bytes) */
	.set	fr.fra, -12	/* previous frame 		(4 bytes) */
	.set	fr.id, -14	/* unique frame ID 		(2 bytes) */
	.set	fr.arg, -16	/* number of args		(2 bytes) */
	.set	fr.pc, -20	/* return PC			(4 bytes) */
	.set	fr.msa, -24	/* current msubr		(4 bytes) */
	.set	fr.head, -28	/* header word			(4 bytes) */

	.set	fr.len, 14	/* length of frame in 16-bit words */

  /* glued frame: */

	.set	gfr.pfr, -4	/* previous frame (check it...) */
/*  defined in frame...	.set	fr.ffb, -1	*/
	.set	gfr.fra, -8	/* previous not-glued  frame (check...) */
	.set	gfr.pc, -12	/* return PC */
	.set	gfr.typ, -14	/* type		(2 bytes)	*/

	.set	gfr.len, 7	/* length of glued frame in 16-bit words */


  /* cell: */
	.set	c.ptr, 0	/* pointer to rest */
	.set	c.obj, 4	/* cell object */

  /* vector, uvector, string:
		these are arrays of [objects/ fixes/ bytes]
		followed by the dope word	*/

  /* atom: */
	.set	a.gbind, 0	/* global binding	(4 bytes) */
	.set	a.lbind, 4	/* local binding	(4 bytes) */
	.set	a.name, 8	/* name			(8 bytes) */
	.set	a.obl, 16	/* oblist		(4 bytes) */
	.set	a.dope, 20	/* dope words		(n bytes) */
	
	.set	a.len, 5	/* length in words */

  /* gbind: */
	.set	gb.obj, 0	/* object		(8 bytes) */
	.set	gb.atom, 8	/* atom			(4 bytes) */
	.set	gb.decl, 12	/* decl			(8 bytes) */
	.set	gb.dope, 20	/* dope words		(n bytes) */

  /* lbind: */
	.set	lb.hdr, -4	/* header (only when on stack) (4 bytes) */

	.set	lb.obj, 0	/* object		(8 bytes) */
	.set	lb.atom, 8	/* atom			(4 bytes) */
	.set	lb.decl, 12	/* decl			(8 bytes) */
	.set	lb.prev, 20	/* previous binding	(4 bytes) */
	.set	lb.last, 24	/* last binding for this atom (4 bytes) */
	.set	lb.bid, 28	/* bind ID		(4 bytes) */
	.set	lb.dope, 32	/* dope words		(n bytes) */

	.set	lb.head, -4	/* hdr from pointer */
	.set	ln.bind, 8	/* length of local binding (longwords) */
	.set	ln.lbind, 16	/* length in words */
	.set	ln.bindb, 32

  /* msubr: */
	.set	ms.im, 0	/* imsubr atom */
	.set	ms.name, 8	/* name atom */
	.set	ms.decl, 16	/* decl */
	.set	ms.off, 24	/* offset into msubr code */

  /* imsubr: */
	.set	im.code, 0	/* pointer to code uvector */
	.set	im.atom, 4	/* atom */
	.set	im.free, 12	/* beginning of rest of junk */

/* Ascii characters */
	.set	chtab, 011
	.set	chlf, 012
	.set	chvt, 013
	.set	chff, 014
	.set	chcr, 015
	.set	chspc, 040

/* GC definitions	*/

	.set	gcpoff, 4

	.text
/* put in jump at address 0 */
txtstr:	.word	0		/* it seems that first word is skipped */
	jmp	booter
	.align	2		/* start dispatch table at 8 */

/* dispatch table - each entry is a longword - referenced by all code */
/* nop instructions used to align longwords */
	brw	iret
	nop
	brw	iframe
	nop
	brw	mcall
	nop
	brw	icons
	nop
	brw	incall
	nop
	brw	igets
	nop
	brw	isets
	nop
	brw	ifixbn
	nop
	brw	iunbind
	nop
	brw	record
	nop
	brw	bvecto
	nop
	brw	blist
	nop
	brw	ibind
	nop
	brw	ublock
	nop
	brw	iactiv
	nop
	brw	iagain
	nop
	brw	retry
	nop
	brw	irtuple
	nop
	brw	ituple
	nop
	brw	lckint
	nop
	brw	newtype
	nop
	brw	open
	nop
	brw	close
	nop
	brw	read
	nop
	brw	print
 	nop
	brw	isave
 	nop
	brw	irestor		/* brw	irestor	*/
 	nop
	brw	illdis		/* brw	random	*/
 	nop
	brw	comper
 	nop
	brw	birec
 	nop
	brw	nthu
 	nop
	brw	restu
 	nop
	brw	putu
 	nop
	brw	nthr
 	nop
	brw	putr
 	nop
	brw	backu
 	nop
	brw	topu
 	nop
	brw	illdis		/* ireset ?? */
 	nop
	brw	iatic
 	nop
	brw	iargs
 	nop
	brw	ciemp
 	nop
	brw	cinth
 	nop
	brw	cimon
 	nop
	brw	cirst
 	nop
	brw	cigas
 	nop
	brw	cigvl
 	nop
	brw	swnxt
 	nop
	brw	nexts
 	nop
	brw	relu		/* brw	relu	*/
 	nop
	brw	relr		/* brw	relr	*/
 	nop
	brw	rell		/* brw	rell	*/
 	nop
	brw	illdis		/* brw	conten	*/
 	nop
	brw	imarkr		/* brw	imarkr	*/
 	nop
	brw	imarkrq		/* brw	imarkrq	*/
 	nop
	brw	illdis		/* brw	syscalx	*/
 	nop
	brw	quit		/* brw	quit	*/
 	nop
	brw	tmptbl
 	nop
	brw	setzon		/* brw	setzon	*/
 	nop
	brw	legal
 	nop
	brw	unwcnt
 	nop
	brw	mpages
 	nop
	brw	illdis		/* brw	iputs	*/
 	nop
	brw	iacall
	nop
	brw	syscal
	nop
	brw	rntime
	nop
	brw	sframe
	nop
	brw	mretur
	nop
	brw	typew
	nop
	brw	typewc
	nop
	brw	savtty
	nop
	brw	dfatal
	nop
	brw	gettty
	nop
	brw	dopipe
	nop
	brw	ugverr
	nop
	brw	movstk
	nop
	brw	getstk
	nop
	brw	uublock
	nop
	brw	sblock
	nop
	brw	usblock
	nop
	brw	iassq
	nop
	brw	ilval
	nop
	brw	iset
	nop
	brw	bigstk

/* Utility routines for following... */

/* Unglue a frame, returns new frame pointer in r12 */

ungfrm:	tstb	fr.ffb(r12)	/* is it already real frame? */
	blss	1f		/* yes, return */
	 movl	fr.act(r12),r12	/* otherwise, chase pointer */
	 jbr	ungfrm		/* iterate */
1:	rsb			/* return to caller */

/* Print MDEPTH spaces on terminal */

prspac:	pushl	r2		/* save a temp */
	movl	mdepth,r2	/* get indentation count */
1:	movl	$spaces,r1	/* address of spaces */
	movl	$1,r3		/* just print one */
	clrl	r5		/* print to tty */
	bsbw	print
	sobgtr	r2,1b		/* loop for all spaces to print */
	movl	(sp)+,r2	/* restore register */
	rsb


/************************************************************************
*									*
*		.subtitle Stack Operations				*
*									*
*		frame, mcall, bind, legal, args, tuple, return		*
*		unbind, retry, activation, rtuple, again		*
*									*
*************************************************************************/

/* iset - set lval.  May call SET (via I$EICC) if needs to make
   top-level binding.  Takes value in r2, r3; atom in r0 */
iset:	movl	a.lbind(r0),r1
	 jeql	isetgr			/* no lbind pointer, need top-level */
	cmpl	lb.bid(r0),bindid	/* right bindid? */
	 jneq	isetgr1			/* no, try to find a good one */
isetdn:	movq	r2,lb.obj(r1)
	movq	r2,r0
	rsb
isetgr1:
	bsbw	iassq			/* get lbind pointer in r1 */
	tstl	r1
	 jneq	isetdn			/* go do it */
isetgr:	subl3	(sp),im.code+ov(r11),(sp)
	movl	ecall,r1
	 jeql	noeicc
	bsbw	iframe
	movl	$(a.len<17+t.atom),(r13)+
	movl	r0,(r13)+
	movq	r2,(r13)+
	movl	$2,r0
	bsbw	mcallz
	subl3	(sp),im.code+ov(r11),(sp)
	rsb

/* lval - takes atom in 0, returns value in 0 and 1.  Calls
EICC if fails, lets loser erret value from that. */
ilval:	movl	a.lbind(r0),r1
	 jeql	lvalls
	cmpl	lb.bid(r1),bindid
	 jneq	lvalgr
	tstl	lb.obj(r1)
	 jeql	lvalls
	movq	lb.obj(r1),r0
	rsb
lvalgr:	bsbw	iassq		/* try to get an lbind */
	tstl	r1
	 jeql	lvalls
	movq	lb.obj(r1),r0
	rsb
lvalls:	subl3	(sp),im.code+ov(r11),(sp)
	movl	ecall,r1
	 jeql	noeicc
	bsbw	iframe
	movl	$(a.len<17+t.atom),(r13)+
	movl	r0,(r13)+
	movl	$1,r0
	bsbw	mcallz
	subl3	(sp),im.code+ov(r11),(sp)
	rsb

/* assigned? - return 0 or lbind pointer in r1, given atom in r0.
   saves all registers except 0*/
iassq:	movl	a.lbind(r0),r1		/* get lbind pointer */
	 jeql	iassfl			/* are none, lose */
	cmpl	lb.bid(r1),bindid	/* bindid OK? */
	 jneq	iassgr			/* no, grovel obscenely */
	tstl	lb.obj(r1)		/* check type */
	 jneq	iasswn			/* not unbound, so win */
iassfl:	clrl	r1
iasswn:	rsb

/* come here if bindid doesn't match.  Have to search binding chain
   for right thing. */
iassgr:	pushl	r2
	clrl	r2		/* flag */
	movl	spsto,r1	/* get binding chain */
	 jeql	iassg1		/* empty */
1:	cmpl	r0,lb.atom(r1)	/* same atom? */
	 jeql	iassex		/* see if has lval in it */
	movl	lb.prev(r1),r1	/* previous binding */
	 jneq	1b
	tstl	r2
	 jneq	iassgfl
iassg1:	incl	r2
	movl	tbind,r1
	 jneq	1b
iassgfl: clrl	r1
2:	movl	(sp)+,r2
	rsb
iassex:	tstl	lb.obj(r1)	/* see if not an unbound */
	 jeql	iassgfl		/* lose */
	brb	2b		/* win */

/* ibind - push a binding
* call:
*	r1/ lbind
* return:
*	r1/ new binding
*	(binding pushed on stack)
*	(saves all registers)		*/

ibind:	movl	$(ln.lbind+2)<16+dope+t.bind,(r13)+ /* push bind header > */
	movl	r13,r1		/* save tp now */
	clrq	(r13)+
	clrq	(r13)+		/* push a bunch of 0's (4 long words)*/
	clrq	(r13)+
	clrq	(r13)+		/* 4 more word, sigh */
	movl	spsto,-12(r13)	/* store current binding */
	movl	r1,spsto	/* this is current binding now */
	rsb			/* return */

/* sframe - generate a segment frame (same as frame...) */

sframe:	movl	$fr.len<16+dope+t.sframe, (r13)+   /* push frame header */
	brb	1f

/* iframe - generate an empty frame
* call:
* 	(no arguments)
* return:
* 	<empty frame has been pushed on TP stack>	*/

iframe: movl	$fr.len<16+dope+t.frame, (r13)+	/* push frame header */
1:	clrq	(r13)+
	clrq	(r13)+		/* zero rest of frame */
	clrq	(r13)+		/* zero rest of frame */
	bisb2	$ffbit,fr.ffb(r13)	/* light full-frame bit */
	rsb

/* mcall - call an msubr
* call:
*	r0/ # args
*	r1/ MSUBR being called
*
* returns: (from msubr, eventually)
* 	r0/ type
*	r1/ value		*/

mcallz:	movl	(sp)+,r2	/* get absolute return PC */
	jmp	mcallx		/* and go for it */

mcall:	tstl	mtrace		/* waste a whole word */
	 beql	1f		/* don't want a trace, skip it */

	pushr	$bit0+bit1+bit3+bit5 /* save registers used for print */
	incl	mdepth		/* nest count for printing spaces */
	pushl	r1		/* save atom pointer */
	bsbw	prspac		/* print many spaces */
	movl	$gtrt,r1	/* print greter-than on call */
	movl	$1,r3		/* single character */
	clrl	r5		/* to tty */
	bsbw	print
	movl	(sp)+,r1	/* restore atom pointer */
	movzwl	10(r1),r3	/* get character count */
	movq	8(r1),r0	/* string pointer */
	clrl	r5		/* channel 0 */
	bsbw	print		/* print MSUBR name */
	movl	$crlf,r1
	movl	$2,r3		/* 2 characters */
	clrl	r5		/* to terminal */
	bsbw	print		/* print crlf */
	popr	$bit0+bit1+bit3+bit5 /* restore dem registers */

1:	subl3	(sp)+,im.code+ov(r11),r2	 /* get return PC from sp
						    and relativize it */
mcallx:	movl	a.gbind(r1),r3	/* get global binding of atom */
	 jneq	1f
gongs:	  jmp	calngs		/*  none, complain */

1:	cmpw	ot+gb.obj(r3),$t.msubr /* is it an msubr? */
	 jneq	gongs		/*  no, complain */
	movl	ov+gb.obj(r3),r4 /* get value (msubr) into r4 */
				/* drop through into ICRET */

icret:	movl	ov+ms.im(r4),r5	/* get imsubr atom from msubr */
	movl	a.gbind(r5),r10	/* its global binding */
	 jneq	1f
comgo:	  bsbw	comper		/*  none - compiler error */
1:	cmpw	ot+gb.obj(r10),$t.imsub /* is it an IMSUBR? */
	 jneq	comgo		/*  NO, compiler blew it */
	movl	ov+gb.obj(r10),r11 /* mvector to MS */
	movl	r12,r7		/* save frame in case it we change it */
icret1:
	bsbw	ungfrm		/* chase down real frame */

	movl	spsto,r3	/* check spsto */
	 beql	1f		/* if zero, dont relativize */
	subl2	r12,r3		/* relative to frame */
1:	movw	r3,fr.sp(r12)	/* save current SP */
	movl	r2,fr.pc(r12)	/* save return PC */
	ashl	$3,r0,r3	/* number of bytes needed for arguments */
				/* CHANGE TO NEW FRAME */
	subl3	r3,r13,r12	/* new fr ptr now in FR */
	movl	r4,fr.msa(r12)	/* store pointer to new MSUBR in NEW frame */
	movl	r7,fr.fra(r12)	/* pointer to previous frame */
	incl	framid		/* bump frame id */
	movw	framid,fr.id(r12) /* and store in new frame */
	movw	r0,fr.arg(r12)	/* store number of args */

	addl3	ms.off+ov(r4),im.code+ov(r11),r8	/* add offset */
	tstl	intflg		/* any interrupts */
	 jneq	1f		/* yes, handle them instead */
2:	jmp	(r8)		/* and jump to code... finally! */

1:	tstl	ingc		/* dont int if in gc */
	 jneq	2b
	movl	$t.fix,(r13)+
	movl	r0,(r13)+	/* save number of args */
	movl	$t.fix,(r13)+
	subl3	r8,im.code+ov(r11),(r13)+	/* save pc */
intlop:	ffs	$0,$32,intflg,r8
	 jeql	noincl		/* seems unlikely */
	pushr	$bit0+bit1
	locc	r8,intlen,intb1
	 jneq	4f
	popr	$bit0+bit1
	brw	noincl		/* muddle doesn't know about it */
4:	bsbw	iframe
	movl	$t.fix,(r13)+	/* call with correct args */
	movzbl	intb2(r0),(r13)+ /* pick up muddle interrupt number */
	popr	$bit0+bit1
	movl	icall,r1	/* get pointer to int routine */
	 jeql	losint		/* loser */
	
	ashl	r8,$1,r8
	bicl2	r8,intflg	/* clear intflg */
	movl	$1,r0
	bsbw	mcallz		/* call interrupt handler */
	tstl	intflg
	 jneq	intlop		/* more to come */
	subl3	-(r13),im.code+ov(r11),r8
	subl2	$4,r13
	movl	-(r13),r0
	subl2	$4,r13
	jmp	(r8)

noincl:	ashl	r8,$1,r8
	bicl2	r8,intflg
	 jneq	intlop
	subl3	-(r13),im.code+ov(r11),r8
	subl2	$4,r13
	movl	-(r13),r0
	subl2	$4,r13
	jmp	(r8)

losint:	movl	$intlos,r1
	movl	lintlos,r3
	clrl	r5
	bsbw	print
	brw	die

/* ifixbn - fix binding
* call:
* 
* return:
*	(must save ALL registers)	*/

ifixbn:	pushl	r0		/* save registers r0,r1 */
	pushl	r1
	movl	spsto,r0	/* current binding pointer to r0 */
1:	cmpl	r0,r12		/* compare to current frame */
	 blss	2f
	movl	lb.atom(r0),r1	/* get atom */
	movl	r0,a.lbind(r1)	/* rebind it */
	movl	lb.prev(r0),r0	/* and chain */
	brb	1b

2:	movl	(sp)+,r1		/* restore work registers */
	movl	(sp)+,r0
	rsb


/* ilegal - determine legality of object
* call:
*	r0/ count,,type
*	r1/ value
* return:
*	r0/ type (fix=true) (false=false)
*	(must save registers) */

legal:	cmpw	r0,$t.frame	/* frame? */
	 jeql	lglfrm		/*  yes, test it */
	cmpw	r0,$t.bind	/* binding? */
	 jeql	lglbnd		/*  ok, test that */
	pushr	$bit2+bit3
	bicl3	$0xFFFFFFF8,r0,r2
	caseb	r2,$0,$7
lgltab:	.word	lgltru-lgltab
	.word	lgltru-lgltab
	.word	lgltru-lgltab
	.word	lgltru-lgltab
	.word	lglstr-lgltab
	.word	lglstr-lgltab
	.word	lgluvc-lgltab
	.word	lgltup-lgltab
lgltru:	popr	$bit2+bit3
	movl	$t.fix,r0	/* all else is legal */
	rsb			/* so report that */

lglstr:	ashl	$-16,r0,r2	/* get length of string */
	addl2	r2,r1
	cmpl	r1,tpmax
	 jgtr	lgltru
	cmpl	r1,r13
	 jgtr	lgllos
	cmpl	r1,tpstart
	 jlss	lgltru
/* frob is on stack */
	bbc	$0,r1,1f
	incl	r1		/* point to halfword */
1:	tstw	(r1)
	 jneq	lgltst
	addl2	$2,r1		/* now we're at the dope word */
lgltst:	bitl	$dope,(r1)	/* is dope bit set? */
	 jeql	lgllos		/* no, lose */
	movzwl	2(r1),r2
	ashl	$2,r2,r2
	subl3	r2,r1,r2
	cmpl	(r1),4(r2)	/* compare the dope words */
	 jeql	lgltru
lgllos:	popr	$bit2+bit3
	movzwl	$t.false,r0
	clrl	r1
	rsb
lgluvc:	ashl	$-14,r0,r2	/* length in bytes */
	addl2	r2,r1		/* go to dope word */
	cmpl	r1,tpmax	/* check stack stuff */
	 jgtr	lgltru
	cmpl	r1,tpstart
	 jlss	lgltru
	cmpl	r1,r13
	 jgtr	lgllos
	brb	lgltst		/* hit common code */

lglfrm:	cmpl	r1,r13		/* check for inbounds */
	 jgtr	lglfls		/* return false */
	cmpl	r1,tpstart
	 jlss	lglfls
	cmpl	fr.head(r1),$fr.len<16+dope+t.frame   /* check frame header */
	 jeql	lglwin		/* lose return false */
	cmpl	fr.head(r1),$fr.len<16+dope+t.sframe
	 jneq	lglfls
lglwin:	movl	$t.fix,r0
	clrl	r1
	rsb

lglbnd:	cmpl	r1,tpmax
	 jgtr	lglwin		/* case of top-level lbind */
	cmpl	r1,r13		
	 jgtr	lglfls
	cmpl	r1,tpstart
	 jlss	lglfls
	cmpl	lb.head(r1),$(ln.lbind+2)<16+dope+t.bind	/* bind hdr? */
	 jeql	lglwin

lglfls:	movl	$t.false,r0
	clrl	r1
	rsb
lgltup:	cmpl	r1,tpmax
	 jgtr	lgltru
	cmpl	r1,r13
	 jgtr	lgllos
	cmpl	r1,tpstart
	 jlss	lgltru
/* Now know it points to valid stack area */
	cmpl	fr.head(r1),$fr.len<16+dope+t.frame	/* args of frame */
	 jeql	lgltru		/* this wins */
	cmpl	fr.head(r1),$fr.len<16+dope+t.sframe
	 jeql	lgltru
	bicl2	$0xFFFF,r0	/* kill type */
	ashl	$2-16,r0,r0	/* word index */
	cmpw	(r1)[r0],$t.tuple+dope
	 jeql	lgltru
	cmpw	(r1)[r0],$t.tuple
	 jeql	lgltru
	cmpw	(r1)[r0],$t.vec+dope
	 jeql	lgltru

/* here to see if rested args of frame */

	movl	r12,r2		/* point to current frame */

lgltu1:	tstb	fr.ffb(r2)	/* is this glued? */
	 blss	1f
	  movl	fr.act(r2),r2	/* loop back */
	   jbr	lgltu1

1:	cmpl	r1,r2		/* if tuple pntr is above frame,
				    this could be it */
	 jgtr	lgltu2
	movl	fr.fra(r2),r2	/* previous frame */
	jbr	lgltu1

lgltu2:	movaw	(r1)[r0],r1	/* rest given tuple to its end */
	movzwl	fr.arg(r2),r0	/* get # of args from frame */
	ashl	$3,r0,r0	/* change from objs to bytes */
	addl2	r0,r2		/* rest it to its end */
	cmpl	r2,r1		/* same end, therefore same legal tuple */
	 jeql	lgltru
	brw	lgllos

/* iargs - return argument tuple for a frame
* call:
*	r1/ frame
* return:
*	r0/ type
*	r1/ value
*	(may mung all registers)
*		(but doesn't) */

iargs:	movl	fr.arg-2(r1),r0 /* get count of args to LEFT HALF (kludge) */
	movw	$t.tuple,r0	/* new type word */
	rsb		/* r1 (frame pointer) points to tuple already */


/* igets - codes:	(1 args) (2 oblist) (3 bind) (4 ecall) (5 ncall)
*		(6 uwatm) (7 pagptr) (8 minf) (9 icall) (10 mapper)
*		(11 envir) (12 argv) (13 homstr)
* call:
* 	r1/ code (see above)
* return:
*	r0/ type
*	r1/ value
*	(saves all registers) */

igets:	caseb	r1,$1,$16	/* dispatch on type */
getab:	.word	getarg-getab
	.word	getobl-getab
	.word	getbnd-getab
	.word	gecall-getab
	.word	gncall-getab
	.word	guwatm-getab
	.word	gpgptr-getab
	.word	getmnf-getab
	.word	gicall-getab
	.word	gmappe-getab
	.word	genvir-getab
	.word	gargv-getab
	.word	ghomst-getab
	.word	grunin-getab
	.word	gtbind-getab
	.word	gtingc-getab
	bsbw	comper		/* should never reach this */

gtingc:	movzwl	$t.fix,r0
	movl	ingc,r1
	rsb

gtbind:	movq	tbindt,r0
	rsb

getarg:	movzwl	fr.arg(r12),r1	/* get number of args */
	movzbl	$t.fix,r0	/* and type */
	rsb

grunin:	movzwl	$t.fix,r0
	movl	runint,r1
	rsb

getobl:	movq	topobl,r0	/* type, value */
	rsb

getbnd:	movl	spsto,r1	/* current binding */
	movl	$(ln.lbind<16+t.bind),r0 /* > type word */
	rsb

gecall:	movl	ecall,r1	/* get current ecall */
	brb	retatm		/* and return atom */

gncall:	movl	ncall,r1	/* current ncall */
	brb	retatm

gicall:	movl	icall,r1	/* current icall */
	brb	retatm

guwatm:	movl	uwatm,r1	/* current uwatom */
retatm:	movl	$(a.len<17+t.atom),r0 /* > type word */
	rsb

gpgptr:	movq	pagptr,r0	/* current page pointer */
	rsb

getmnf:	movl	minf,r1		/* current minf */
	movl	$(minf.len<16+t.uvec),r0 /* > type */
	rsb

gmappe:	movl	mapper,r1	/* current mapper */
	brb	retatm

/* Can clobber r0,r1 */
genvir:	movl	envbeg,r0	/* Start of environment vec (set up by booter) */
	clrl	r1
	pushr	$bit2+bit3
3:	tstl	(r0)		/* Is it zero? */
	beql	6f		/* Yes, done */
	movl	(r0),r2		/* Get string pointer */
	clrl	r3		/* for length */
4:	tstb	(r2)		/* Found 0? */
	beql	5f		/* Yes, push a string pointer */
	incl	r2		/* No, point to next byte */
	aobleq	$1024,r3,4b	/* Aos count, try again */
5:	movw	$t.str,(r13)+	/* Push a type */
	movw	r3,(r13)+	/* Push a length */
	movl	(r0),(r13)+	/* Push a value */
	addl2	$4,r0
	aobleq	$1024,r1,3b	/* aos count, loop back */
6:	movw	$t.vec,r0
	bsbw	ublock		/* Make the vector */
	popr	$bit2+bit3
	rsb

/* return argument vector for process.  numarg and argbeg set up by
   startup code; returns false if no arguments */
gargv:	movl	numarg,r1
	 jleq	gargn		/* No arguments */
	pushr	$bit2+bit3
	movl	argbeg,r0
3:	clrl	r3
	movl	(r0),r2		/* point to a string */
1:	tstb	(r2)
	 beql	2f
	incl	r2
	aobleq	$1024,r3,1b
2:	movw	$t.str,(r13)+
	movw	r3,(r13)+
	movl	(r0),(r13)+	/* Push the string */
	addl2	$4,r0
	sobgtr	r1,3b
	movl	numarg,r1
	movw	$t.vec,r0
	bsbw	ublock
	popr	$bit2+bit3
	rsb
gargn:	movw	$t.false,r0
	clrl	r1
	rsb

ghomst:	movw	$homlen,r0
	ashl	$16,r0,r0
	movw	$t.str,r0
	moval	homstr,r1
	rsb

/* sets - codes as in gets above
* call:
*	r0/ type (not checked)
*	r1/ value to store
*	r3/ code
* returns:
*	r0/ type
*	r1/ value */

isets:	caseb	r3,$1,$16 	/* dispatch on type */
setab:	.word	seter-setab	/* args - error */
	.word	setobl-setab
	.word	setbnd-setab	/* binding - error */
	.word	secall-setab
	.word	sncall-setab
	.word	suwatm-setab
	.word	spgptr-setab
	.word	setmnf-setab
	.word	sicall-setab
	.word	smappe-setab
	.word	senvir-setab	/* a no-op */
	.word	senvir-setab	/* for argv--does nothing */
	.word	senvir-setab	/* for homstr--does nothing */
	.word	srunin-setab
	.word	stbind-setab
	.word	stingc-setab
seter:	bsbw	comper		/* should never reach this */

stingc:	movl	r1,ingc
	rsb

stbind:	movq	r0,tbindt
	rsb

srunin:	movl	$t.fix,(r13)+	/* push relative PC */
	subl3	(sp)+,im.code+ov(r11),(r13)+
	movl	$t.fix,(r13)+
	movl	r1,(r13)+
	bsbw	kerint		/* handle pending interrupts */
	movl	-(r13),runint	/* set up flag */
	subl2	$4,r13
	subl3	-(r13),im.code+ov(r11),-(sp)	/* restore PC */
	subl2	$4,r13
	rsb

setobl:	movq	r0,topobl
	rsb
setbnd:	movl	r1,spsto
	rsb
secall:	movl	r1,ecall
	rsb
sicall:	movl	r1,icall
	rsb
sncall:	movl	r1,ncall
	rsb
suwatm:	movl	r1,uwatm
	rsb
spgptr:	movq	r0,pagptr
	rsb
setmnf:	movl	r1,minf
	rsb
smappe:	movl	r1,mapper
senvir:	rsb

/* incall - internal call
* call:	bsb	ncall
* 	jmp	msubr
* return:
* 	frame set up, with
*	return address 3 bytes after bsb (after brw)
*	new frame has same MS, otherwise new	*/

incall:	subl3	(sp),im.code+ov(r11),r6		/* get return address 
						    and relativize */
	subl2	$3,r6		/* make frame return after jmp */
	bsbw	iframe		/* push an empty frame */
	movl	r12,r3		/* save old fr in case we change it */
	bsbw	ungfrm		/* chase last unglued frame */
	movl	spsto,r0	/* check for relativize needed */
	 beql	1f
	subl2	r12,r0
1:	movw	r0,fr.sp(r12)	/* save current SP */
	movl	r6,fr.pc(r12)	/* save return PC */
	movl	fr.msa(r12),r0	/* get msubr pointer for new guy */
				/* change to NEW frame */
	movl	r13,r12
	movl	r3,fr.fra(r12)	/* and previous frame	 */
	incl	framid		/* bump frame id */
	movw	framid,fr.id(r12) /* and store it in frame */
	movl	r0,fr.msa(r12)	/* for incall, msa is carried over */
	rsb


/* iret - MSUBR return code */


iret:	bsbw	frmfix		/* unravel the frame */
1:	subl3	r7,im.code+ov(r11),r7	/* unrelativize PC */
	jmp	(r7)		/* PC returned here */


/* frmfix - unravel frame, leaving return PC in r7 */

frmfix:	tstb	fr.ffb(r12)	/* is it a glued frame? */
	 blss	fixrel		/* no, fix real frame */
				/* GLUED FRAME */
	subl3	$(gfr.len<1),r12,r13	/* < flush glued frame from tp */
	mnegl	gfr.pc(r12),r7	/* get return PC out, negated */
	movl	gfr.fra(r12),r12 /* restore old FR */
	rsb

				/* REAL FRAME */
fixrel:	subl3	$fr.len*2,r12,r13 /* < flushing frame */
9:	movl	fr.fra(r12),r12	/* restore FR */
	movl	r12,r3		/* save FR in case we change it */
	bsbw	ungfrm		/* back up to unglued frame */
	pushl	r12		/* save unwound frame */
	cvtwl	fr.sp(r12),r8	/* get saved SP */
	 beql	1f
	addl2	r12,r8		/* unrelativize */
1:	cmpl	spsto,r8	/* need to unbind? */
	 jeql	2f		/* not if current binding same as this frame */
	  movl	r3,r12		/* get the right frame back */
	  bsbw	iunbnx		/*  unbind */
2:	movl	(sp)+,r12	/* get the unglued frame back */
	movl	fr.msa(r12),r2	/* find the MSUBR */
	movl	ms.im+ov(r2),r2	/*  IMSUBR atom */
	movl	a.gbind(r2),r2	/* its GBIND */
	movl	ov+gb.obj(r2),r11 /* its IMSUBR to MS */
	movl	fr.pc(r12),r7	/* return PC in known place */
	 jleq	1f
	subl3	r7,im.code+ov(r11),r7
1:	movl	r3,r12		/* and restore possible changed frame */
/* Do tracing here, so don't get 69 things from glued calls */
	tstl	mtrace		/* looking for trace? */
	 beql	2f		/* no, skip it */
	decl	mdepth		/* reduce depth of nesting */

	pushr	$bit0+bit1+bit3+bit5+bit12 /* save registers used for print */
	bsbw	prspac		/* print many spaces */
	movl	$lesst,r1	/* print a less-than at return */
	movl	$1,r3		/* that's just 1 character */
	clrl	r5		/* to tty */
	bsbw	print		/* print the sucker */

	bsbw	ungfrm
	movl	fr.msa(r12),r1	/* point to msubr */
	movl	ms.name+ov(r1),r1 /* point to atom */
	movzwl	10(r1),r3	/* get character count */
	movq	8(r1),r0	/* string pointer */
	clrl	r5		/* channel 0 */
	bsbw	print		/* print MSUBR name */
	movl	$crlf,r1
	movl	$2,r3		/* 2 characters */
	clrl	r5		/* to terminal */
	bsbw	print		/* print crlf */
	popr	$bit0+bit1+bit3+bit5+bit12 /* restore dem registers */
	
2:	rsb

/* iunbind - unbind entry from external world
*
* call:	r1/ saved SP pointing to binding
*	(may mung all registers except r0-r1 pair)
* return:
*	(unbinding done) */

iunbind: movl	r1,r8		/* put SP in known place */
				/* drop through into internal routine */
iunbnx:	movl	spsto,r6	/* get current SP */
	clrl	r2		/* clear "last binding" slot */
iunbnl:	cmpl	r6,r8		/* are we done? */
	 bleq	iunbnd
	movl	lb.atom(r6),r9	/* point to atom */
	 jeql	un.1		/*  none */
	cmpl	r9,uwatm	/* unwinder? */
	 jeql	dounwi		/*  yes - unwind */

unjoin:	movl	lb.last(r6),a.lbind(r9)	/* get last binding */
un.1:	movl	r6,r2
	movl	lb.prev(r6),r6	/* next binding */
	brb	iunbnl		/* loop */

iunbnd:	movl	r6,spsto	/* store current binding */
	rsb
/* this used to fixup tp, but clr claims it don't have to no more */

dounwi:	movl	lb.obj+4(r6),r7		/* get object out of binding (frame) */
	 jeql	unjoin			/* isn't one */
	movl	fr.msa(r7),r9		/* setup pointer to msubr */
	movl	ov+ms.im(r9),r9		/*  IMSUBR atom */
	movl	a.gbind(r9),r9		/* its GBIND */
	movl	ov+gb.obj(r9),r11	/* its IMSUBR to MS */
	addl3	ov+ms.im(r11),16(r6),r9	/* point to code  and offset*/
		/* the offset is stored in the DECL word by the compiler */
	addl3	$ln.bindb,r6,r13	/* keep room for binding */
	cmpw	(r13),$t.frame		/* is it followed by a frame pointer */
	 jneq	1f			/* no */
	movl	4(r13),r7		/* then that's the real McCoy */
	addl2	$8,r13			/* preserve it */
1:	movq	r0,(r13)+	/* push r0 & r1 to save return over unwinder */
	movl	$(fr.len<17+t.frame),(r13)+ /* > don't ask me... */
	movl	r12,(r13)+
	movl	$(ln.bind<16+t.bind),(r13)+ /* > */
	movl	r8,(r13)+
	movl	r7,r12
	movl	r6,spsto
	jmp	0(r9)			/* call unwinder */

/* here to exit from unwinder */

unwcnt:	movl	-4(r13),r8		/* restore saved registers */
	movl	-12(r13),r12
	subl2	$16,r13			/* fix stack */
	movq	-(r13),r0		/* restore real return values */
	movl	spsto,r6
	movl	r12,r3			/* for FRMFIX */
	movl	uwatm,r9
	brw	unjoin			/* rejoin common code */

/* iactiv - setup activation 

	(saves all registers)	*/

iactiv:	pushl	r0			/* save callers r0 */
	subl3	im.code+ov(r11),4(sp),r0	/* relativize calling pc */
	pushl	r12			/* save in case it changes */
	bsbw	ungfrm			/* find real frame */
	movl	r0,fr.act(r12)		/* smash PC into frame */
	subl3	r12,r13,r0
	addw3	$8,r0,fr.tp(r12)		/* and TP */	
	bisb2	$ffbit,fr.ffb(r12)	/* make sure still a full frame */
	movl	$fr.len<16+t.frame, (r13)+ /* push (possible glued) frame */
	movl	(sp)+,r12			/* restore FR */
	movl	r12,(r13)+
	movl	(sp)+,r0			/* and r0 */
	rsb

/* iretry - retry a frame 
call:
	r1/ frame to retry	*/

retry:	movl	r1,r12			/* new frame pointer */
	pushl	fr.msa(r12)
	pushl	r1			/* save for TP computation */
	movw	fr.arg(r12),-(sp)		/* save some stuff */
	bsbw	frmfix			/* fixup */
	bsbw	iframe			/* create a frame */
	clrl	r0
	movzwl	(sp)+,r1		/* get back fr.arg count */
	ashl	$3,r1,r0		/* times 8 for byte count */
	addl3	r0,(sp)+,r13			/* correctly */
	pushl	r12			/* save in case clobbered */
	bsbw	ungfrm			/* get real frame */
	movl	fr.pc(r12),r2		/* get PC */
	movl	(sp)+,r12		/* restore FR */
	movl	(sp)+,r4		/* get saved msubr to r4 for icret */
	movl	r1,r0			/* put number of arguments in r0 */
	brw	icret			/* r0 has number of args still... */

/* sblock - ublock for stack
* call:
*	r0/ type of structure
*	r1/ # of frobs on stack (not same as size)
* return:
*	r0/ count,,type
*	r1/ pointer to structure
On return, the structure will be on the top of stack, with the arguments
popped, and appropriate dope words surrounding it.  For the vector case,
this just calls ituple.
This must preserve all acs except 0 and 1.

Stack objects other than tuples have two identical dope words, one at the
beginning and one at the end.  The dope words are in the usual form of
length,,type+dopebit
nexts (of the GC) presumably will see the first one and skip the whole
structure; things like top need the second one.  The length field is, as
usual, the number of words in the whole structure, including dope words. */

sblock:	pushr	$bit2+bit3+bit4+bit5+bit6	/* save some acs */
	bicb3	$0374,r0,r2	/* isolate primtype */
	caseb	r2,$0,$3	/* dispatch to special code */
sbd:	.word	sblb-sbd	/* bytes */
	.word	sbls-sbd	/* string */
	.word	sblu-sbd	/* uvector */
	.word	sblv-sbd	/* vector */
	bsbw	comper

sblv:	bsbw	ituple		/* just like tuple */
	movw	$t.vec,r0	/* except really a vector */
sbret:	popr	$bit2+bit3+bit4+bit5+bit6	/* restore acs */
	rsb

/* for uvectors, we know that the returned structure will fit in the
   space used by the pushed args (unless there aren't any), since each
   arg takes two words on the stack and will only take one in the
   uvector.  This isn't true for strings and bytes */
sblu:	pushl	r1		/* save count */
	ashl	$3,r1,r0	/* # bytes used by args */
	subl3	r0,r13,r0	/* point to first arg */
	movl	r0,r2		/* save pointer */
	addl2	$2,r1		/* add space for dope words */
	ashl	$16,r1,r1
	movw	$t.uvec+dope,r1	/* here's the dope word */
	movl	r1,(r0)+	/* stuff it out */
	pushl	r0		/* this will be the return pointer */
	movl	4(sp),r3
	 jeql	3f		/* empty structure */
2:	movl	4(r2),(r0)+	/* move an element */
	addl2	$8,r2
	sobgtr	r3,2b		/* done? */
3:	movl	r1,(r0)+	/* push bottom dope word */
	movl	r0,r13		/* update stack pointer */
	movl	(sp)+,r1	/* pick up pointer */
	movl	(sp)+,r0
	ashl	$16,r0,r0
	movw	$t.uvec,r0
	brw	sbret		/* all done */

sblb:	movl	$t.bytes,r5	/* type word */
	brb	sbls1
sbls:	movl	$t.str,r5
sbls1:	pushl	r1		/* save count */
	ashl	$3,r1,r0	/* # bytes */
	subl3	r0,r13,r0	/* pointer to arg block */
	pushl	r0		/* save pointer for second pass */
	clrl	r2		/* count */
	tstl	r1
	 jeql	4f		/* nothing to look at? */
1:	bitb	$7,(r0)		/* check SAT of first arg */
	 jneq	3f		/* structured */
	incl	r2		/* character, just add one */
2:	addl2	$8,r0
	sobgtr	r1,1b
	brb	4f
3:	addw2	2(r0),r2	/* add length of frob */
	brb	2b
/* r2 has number of elements in new structure; 4(sp) is number of arguments;
   (sp) is pointer to beginning of arg block on stack.  r0 points just past
   end of arg block on stack.  r5 is type code */
4:	addl3	$11,r2,r3
	bicb2	$3,r3		/* number of bytes needed */
	ashl	$14,r3,r4	/* number of words in LH */
	movw	r5,r4
	bisl2	$dope,r4	/* r4 is dope word */
	tstl	r2
	 jeql	5f		/* empty string */
	addl2	(sp),r3		/* get pointer to new home for args */
	ashl	$3,4(sp),r0	/* number of bytes in arg block */
	pushr	$bit2+bit3+bit4	/* save registers */
	movc3	r0,*12(sp),(r3)	/* move args up stack */
	movl	r1,r13		/* update tp */
	popr	$bit2+bit3+bit4	/* restore registers */
5:	movl	(sp),r1
	movl	r4,(r1)+	/* first dope word */
	movl	r1,(sp)		/* pointer to new structure */
	tstl	r2
	 jeql	8f		/* empty string, so nothing to copy */
/* r3 is pointer to arg block, 4(sp) is number of args, r1 is pointer to
   structure, r4 is dope word */
	movl	4(sp),r5	/* get number of args back */
6:	bitb	$7,(r3)		/* see if arg is structured */
	 jneq	8f		/* yes */
	movb	4(r3),(r1)+	/* no, just copy a byte */
7:	addl2	$8,r3		/* update arg pointer */
	sobgtr	r5,6b		/* done? */
	bicl3	$-4,r2,r3	/* get number of bytes mod 4 */
	 jeql	1f		/* even, no padding needed */
	subl2	$4,r3
2:	clrb	(r1)+		/* padding byte */
	aoblss	$0,r3,2b
1:	movl	r4,(r1)+	/* stuff out dope word */
	movl	r1,r13		/* update tp */
	movl	(sp)+,r1	/* pop pointer */
	ashl	$16,r2,r0
	bicw3	$dope,r4,r0	/* make up pointer */
	addl2	$4,sp		/* clean up stack */
	brw	sbret	
8:	movzwl	2(r3),r0	/* get length of string to copy */
	 jeql	7b		/* empty, so skip it */
	movl	4(r3),r6	/* get pointer */
9:	movb	(r6)+,(r1)+	/* copy a byte */
	sobgtr	r0,9b		/* decrement count */
	brw	7b		/* done with this string */

/* uninitialized stack objects.  r0 is type, r1 is # of elements in
   returned object. */

usblock:
	pushl	r2
	bicb3	$0374,r0,r2	/* isolate primtype */
	caseb	r2,$0,$3	/* dispatch */
usbd:	.word	usblb-usbd
	.word	usbls-usbd
	.word	usblu-usbd
	.word	usblv-usbd

usblb:	movl	$t.bytes,r0	/* type */
	brb	usbls1
usbls:	movl	$t.str,r0
usbls1:	addl3	$3,r1,r2
	bicb2	$3,r2		/* number of bytes, exclusive of dope words */
usblg:	pushl	r3		/* protect previous contents */
	addl3	$8,r2,r3	/* allow for dope words */
	ashl	$14,r3,r3	/* number of words in LH */
	movw	r0,r3
	bisl2	$dope,r3	/* turn on dope bit */
	movl	r3,(r13)+	/* push first dope word */
	pushl	r13		/* pointer */
	addl2	r2,r13
	tstl	r2
	 jeql	1f		/* don't clobber if empty structure */
	clrl	-4(r13)		/* zero last word, so topus can work */
1:	movl	r3,(r13)+	/* second dope word */
	ashl	$16,r1,r1
	movw	r0,r1
	movl	r1,r0		/* make type word */
	movl	(sp)+,r1	/* restore pointer */
	movl	(sp)+,r3	/* restore saved acs */
	movl	(sp)+,r2
	rsb

usblu:	movl	$t.uvec,r0
	ashl	$2,r1,r2	/* number of bytes needed */
	brw	usblg		/* go build it */

usblv:	ashl	$16,r1,r2
	movw	$t.vec,r2	/* type word */
	pushl	r1		/* save length */
	movl	r2,r0
	movl	r13,r1
	pushr	$bit3+bit4+bit5
	bsbw	vecclr		/* zero the vector */
	ashl	$3,12(sp),r2	/* get number of bytes */
	addl2	r1,r2		/* point to dope words */
	addl3	$1,12(sp),r3
	ashl	$17,r3,r3
	movw	$t.vec+dope,r3
	movl	r3,(r2)
	popr	$bit3+bit4+bit5	/* first dope word */
	addl2	$4,sp
	clrl	4(r2)
	moval	8(r2),r13	/* update tp pointer */
	movl	(sp)+,r2
	rsb

/* ituple 
* call:
*	r1/ size of tuple
* return:
*	r0/ count,,type
*	r1/ pointer to tuple	*/

ituple:	pushl	r1
	ashl	$3,r1,r0	/* get byte count of tuple into r0 */
	subl3	r0,r13,r1	/* point to tuple */
	addl2	$8,r0
	ashl	$14,r0,r0	/* dope word has total # words */
	movw	$t.tuple+dope,r0 /* make it a doped tuple for stack */
	movl	r0,(r13)+	/* push on TP stack */
	clrl	(r13)+		/* dope words up */
	movl	(sp)+,r0
	ashl	$16,r0,r0
	movw	$t.tuple,r0
	rsb			/* and return */

/* irtuple - return a tuple to a frame
*  mretur  - same thing for special multi-return case
* call:
*	r1/ number of args
*	r2/ frame
*	r7/ still has return address from someplace
* return:
*	r0/ cnt,, type (=tuple)
*	r1/ pointer to tuple		*/

mretur:	pushl	$1		/* flag saying this mreturn */
	brb	mret2
irtuple:
	clrl	-(sp)		/* flag saying rtuple */
mret2:	tstl	r2		/* get target frame */
	 jneq	1f		/* is frame arg 0?*/
	movl	r12,r2		/* use current frame */
1:	movl	r2,r3		/* save orig frame */
2:  	tstb	fr.ffb(r2)	/* is it a glued frame? */
	 jgeq	grtupl		/* yes, special handling */
	tstl	(sp)		/* jump if rtuple */
	 jeql	mret3
	cmpl	fr.head(r2),$fr.len<16+dope+t.sframe
	 jeql	mret3		/* if this is a seg call, go return */
	movl	fr.fra(r2),r2
6:	tstb	fr.ffb(r2)
	 blss	5f
	movl	fr.act(r2),r2
	brb	6b

5:	movl	fr.msa(r2),r4	/* point to msubr */
	movl	ms.im+ov(r4),r4	/* IMSUBR atom */
	movl	a.gbind(r4),r4	/* GBIND */
	movl	gb.obj+ov(r4),r4	/* IMSUBR */
	movl	fr.pc(r2),r7	/* get this frames ret PC */
	subl3	r7,im.code+ov(r4),r7 /* get PC back */
	cmpw	$jmpa,(r7)	/* next ins absolute jump? */
	 jneq	4f
	cmpl	$8,2(r7)	/* to a return */
	 jneq	4f		/* nope, just return first value */
	movl	fr.fra(r2),r2	/* step back a frame */
	brb	2b		/* and try this guy */

/* here to do a comperr that eventually call interpreters MRETURN */

4:	ashl	$3,r1,r4
	subl3	r4,r13,r4	/* r4 now points to 1st elemet to return */
	bsbw	iframe		/* build a frame */

	movl	$ln.frame<16+t.frame,(r13)+	/* pass the frame */
	movl	r2,(r13)+

	movl	r1,r0		
	jeql	1f		/* if no args, go */

2:	movq	(r4)+,(r13)+
	sobgtr	r1,2b

1:	addl2	$1,r0		/* one more arg */
	movl	ecall,r1
	bsbw	mcallz		/* call it */
	brw	comper

mret3:	pushl	r1		/* save args */
	pushl	r13		/* and stack top */
	movl	r2,r12		/* now make it be current frame */
	bsbw	frmfix		/* fix frame */
	subl3	r7,im.code+ov(r11),r7
	movl	(sp)+,r8	/* restore stack top to r8 */
	movl	r13,r1		/* will be tuple pointer */
	movl	(sp)+,r0	/* and number of args */
	ashl	$3,r0,r3	/* make byte count */
5:	tstl	r0		/* see if no args */
	 jeql	1f		/* none? */
	subl2	r3,r8		/* make room for tuple */
2:	movq	(r8)+,(r13)+	/* push stuff */
	sobgtr	r0,2b		/* and iterate */
1:	tstl	(sp)+
	 jneq	2f
  	ashl	$13,r3,r0	/* shift count to left half */
	movw	$t.tuple,r0	/* bash type code in */
	jmp	(r7)		/* go to return address */

2:	ashl	$-3,r3,r1	/* num elements to r1 */
	movl	$t.fix,r0
	jmp	3(r7)

/* here to rtuple/mreturn from a glued frame */
grtupl:	subl3	$(gfr.len<1),r2,r3	/* < flush glued frame from tp */
	movw	gfr.typ(r2),r5		/* type of frame */
	addl3	gfr.pc(r2),im.code+ov(r11),r7		/* and un relativize */
	movl	gfr.fra(r2),r12		/* restore old FR */
	ashl	$3,r1,r0		/* # bytes to r0 */
	subl3	r0,r13,r0		/* point to first element */
	movl	r3,r4			/* copy of base */
	movl	(sp)+,r6		/* rtuple or mreturn */
	 jeql	igrtp3			/* its rtuple, don't fudge around */
	cmpw	$t.qsfra,r5		/* is this a seg call ? */
	 jneq	mret2			/* no check back */
igrtp4:	addl2	$3,r7			/* skip return */
igrtp3:	movl	r1,r8
	 jeql	1f
2:	movq	(r0)+,(r3)+
	sobgtr	r8,2b			/* and iterate */
	movl	r3,r13			/* fix tp */
  	tstl	r6			/* rtuple or mreturn */
	 jeql	3f
	movl	$t.fix,r0
	jmp	(r7)
3:	ashl	$16,r1,r0
	movw	$t.tuple,r0
	movl	r4,r1
	jmp	(r7)	

/* lckint - who knows ?? */

kerint:	tstl	ingc
	 jeql	2f
	rsb
2:	tstl	intflg
	 jneq	3f
	rsb
3:	movl	$t.word,(r13)+
	movl	(sp)+,(r13)+
	brw	rlckint
	
lckint:	tstl	ingc
	 jeql	2f	
	rsb
2:	movl	$t.fix,(r13)+
	subl3	(sp)+,im.code+ov(r11),(r13)+	/* save pc */
rlckint: pushl	r2
	clrl	cgnois
	clrl	cgct
lcklop:	ffs	$0,$32,intflg,r2
	pushr	$bit0+bit1
	locc	r2,intlen,intb1
	 jneq	3f
	popr	$bit0+bit1
	brw	noint
3:	bsbw	iframe
	movl	$t.fix,(r13)+
	movzbl	intb2(r0),(r13)+
	popr	$bit0+bit1
	movl	icall,r1	/* get frob */
	 jeql	losint
	movl	$1,r0
	ashl	r2,$1,r2
	bicl2	r2,intflg
	bsbw	mcallz
	tstl	intflg
	 jneq	lcklop
	movl	(sp)+,r2
	pushl	-(r13)
	cmpw	-4(r13),$t.fix	/* maybe relativize return pC*/
	 bneq	1f
	subl3	(sp),im.code+ov(r11),(sp)
1:	subl2	$4,r13
	rsb
noint:	ashl	r2,$1,r2
	bicl2	r2,intflg
	 jneq	lcklop
      	movl	(sp)+,r2
	pushl	-(r13)
	cmpw	-4(r13),$t.fix
	 bneq	2f
	subl3	(sp),im.code+ov(r11),(sp)
2:	subl2	$4,r13
      	rsb			/* return */

/* iagain 
* call:
*	r1/ frame pointer
* return:
				*/

iagain:	cmpl	r1,r12		/* same as current frame? */
	 jeql	again1		/* yes, skip unbinding */
	movl	r1,r12		/* new frame */
	bsbw	ungfrm		/* unglue */
	movzwl	fr.tp(r12),r8	/* get stack top */
	addl2	r12,r8		/* unrelativize */
	bsbw	iunbnx		/* unbind */
	movl	fr.msa(r12),r2	/* find the MSUBR */
	movl	ov+ms.im(r2),r2	/*  IMSUBR atom */
	movl	a.gbind(r2),r2	/* its GBIND */
	movl	ov+gb.obj(r2),r11 /* its IMSUBR to MS */
again1:	movl	fr.act(r12),r0	/* relative PC */
	bicl2	$bit31,r0	/* ffb bit in case it is set */
	addl2	ov+im.code(r11),r0
	movzwl	fr.tp(r12),r13	/* restore saved Tp */
	addl2	r12,r13
	movl	-4(r13),r12	/* pop the possible glued frame */
	jmp	(r0)		/* jump into code */

/* newtype - create a new type code
* call:
*	r1/ arg
* return:
*	r1/ new type code	*/

newtype: movl	type_count,r2	/* get current type count */
	incl	type_count	/* bump it */
	ashl	$6,r2,r2	/* put it into position */
	bicl2	$0xFFFFFFC0,r1	/* isolate primtype */
	bisl2	r2,r1		/* bash it in */
	rsb

/* typewc - return type code of type word
* call: r1/ type-w
* return: r1/ type-c
*/
typewc:	bicl2	$0xFFFF0000,r1	/* kill any length info */
	movl	$t.typc,r0
	rsb

/* typew - return type word
* call: r0/ type-c of frob; r1/ type-c of primtype
* return: r0, r1 type-w, value
*/
typew:	cmpzv	$0,$3,r1,$pt.rec	/* is primtype a record? */
	 jneq	1f
	ashl	$-3,r1,r1		/* get offset into table */
	movl	rectbl+4(r1),r1		/* get primtype's entry */
	movl	(r1),r1			/* pick up length */
	movw	r0,r1			/* stuff type code in rh */
	movl	$t.typw,r0
	rsb
1:	movl	r0,r1			/* Otherwise, just type-c */
	movl	$t.typw,r0		/* with a different type word */
	rsb

/********************************************************
*							*
*							*	
*		Storage Allocators			*
*							*	
*							*	
********************************************************/
		
/* blist - build list
* call:
*	r1/ number of elements
*	(tp) elements have been pushed on stack
* return:
*	r1/ pointer to list	*/

blist:	subl2	im.code+ov(r11),(sp)
	pushl	r1		/* save element count */
	jeql	2f		/* if none, done */

	clrl	r3		/* list to cons to */
1:	movl	-(r13),r1	/* pop an element */
	movl	-(r13),r0	/* from TP stack */
	bsbw	cons		/* cons it to list */
	movl	r1,r3		/* re-cons to same list */
	sobgtr	(sp),1b		/* and count down elements */

2:	movw	$t.list,r0
	addl2	$4,sp		/* discard element count on stack */
	addl2	im.code+ov(r11),(sp)
	rsb

/* bvector */

bvecto:	halt			/* not implemented */

/* birec - build record or string (zeroed) 
* call:
*	r1/ type
*	r3/ # words
*	r5/ # elements
* return:
*	r0/ type
*	r1/ pointer		*/

birec:	subl2	im.code+ov(r11),(sp)	/* relativize pc in case gc */
	bsbb	birecr			/* internal entry */
	addl2	im.code+ov(r11),(sp)
	rsb

birecr:	movl	r1,r8		/* save type code */
	movl	r3,r0		/* so we can setup arg to block */
	ashl	$2,r0,r7	/* make a pointer past allocated words */
	addl2	$2,r0		/* allocate n + 2 for dope words */
	bsbw	iblock		/* allocate storage (return in r6) */
	addl2	r6,r7		/* r7 now points to dope */
	movw	r0,2(r7)	/* block size in lh of dope word */
	movw	r8,(r7)		/* type in right half */
	bisw2	$dope,(r7)	/* with dope turned on */
	movl	r6,r1		/* put pointer to block in r1 for return */
	rotl	$16,r5,r0	/* count of elements in lh of r0 */
	movw	r8,r0		/* type in right half */
	rsb

/* uublock - allocate an unitialized user object (string, vector, uvector)
   called like ublock, except nothing on stack */

uublock:
	subl2	im.code+ov(r11),(sp)
	bicb3	$0374,r0,r2	/* primtype */
	movl	r1,r9		/* save length */
	caseb	r2,$0,$3
uubd:	.word	uublb-uubd	/* bytes */
	.word	uubls-uubd
	.word	uublu-uubd
	.word	uublv-uubd
	bsbw	comper

uublb:	movl	$t.bytes,r4
	brb	uubls1
uubls:	movl	$t.str,r4
uubls1:	movl	r1,r5		/* # elements */
	movl	r4,r1		/* type */
	addl3	r5,$3,r3	/* round up to next word */
	ashl	$-2,r3,r3
	bsbw	birecr		/* call record-builder */
uubret:	addl2	im.code+ov(r11),(sp)
	rsb

uublu:	movl	r1,r5		/* # elements */
	movl	r1,r3		/* # words */
	movl	$t.uvec,r1	/* type */
	bsbw	birecr		/* do it */
	brb	uubret		/* return */

/* vector has to be zeroed before return, to keep GC happy */
uublv:	movl	r1,r5
	ashl	$1,r1,r3	/* # words */
	movl	$t.vec,r1
	bsbw	birecr
	bsbb	vecclr		/* clear the vector */
	brb	uubret

/* clear a vector.  pointer is r0,r1; all other acs go away */
vecclr:	pushr	$bit0+bit1	/* save pointer */
	ashl	$-13,r0,r0	/* get # of bytes */
	movc5	$0,(r1),$0,r0,(r1)	/* zero the block */
	popr	$bit0+bit1	/* restore pointer */
	rsb

/* ublock - allocate a user object (string, vector, uvector)
* call:
*	r0/ type
*	r1/ length
*	(TP) elements are on stack
* return:
*	r0/ type
* 	r1/ pointer to object
*	(stack popped)		*/


ublock:	subl2	im.code+ov(r11),(sp)
	bicb3	$0374,r0,r2	/* isolate primtype */
	mnegl	r1,r7		/* negate count and copy to r7 */
	ashl	$3,r7,r7	/* double it and make byte count */
	addl2	r13,r7		/* r7 now points to first element */
	movl	r7,r9		/* save for restoring Tp */
	caseb	r2,$0,$3	/* dispatch on type */
ubd:	.word	ublb-ubd	/* byte string (same as string) */
	.word	ubls-ubd	/* string */
	.word	ublu-ubd	/* uvector */
	.word	ublv-ubd	/* vector */
	bsbw	comper		/* foo */

ublb:	movl	$t.bytes,r5
	brb	ubls1

/* string */

ubls:	movl	$t.str,r5	/* type */
ubls1:	clrl	r0
	pushl	r1		/* save # frobs on stack */
	tstl	r1
	jeql	4f		/* empty string */
1:	bitb	$3,(r7)
	jneq	3f
	incl	r0
2:	addl2	$8,r7
	sobgtr	r1,1b
	brb	4f
3:	addw2	2(r7),r0
	brb	2b
4:	movl	r0,r10		/* copy count for return */
	addl2	$11,r0		/* dope words, and round up to words */
	ashl	$-2,r0,r0	/* divide by 4 for words */
	bsbw	iblock		/* allocate that many words */
	movl	r6,r8
	movl	(sp)+,r1	/* get # elts on stack back */
	jeql	ublsdn		/* test for 0-length string */
	movl	r9,r7
1:	bitb	$3,(r7)
	jneq	3f
	movb	4(r7),(r8)+	/* dump a byte */
2:	addl2	$8,r7		/* next stack element */
	sobgtr	r1,1b		/* iterate for all chars in string */
	brb	ublsdn
3:	movzwl	2(r7),r2
	 jeql	2b
	movl	4(r7),r3
4:	movb	(r3)+,(r8)+
	sobgtr	r2,4b
	brb	2b
ublsdn:	ashl	$16,r0,r4	/* copy number of words to left half */
	movw	r5,r4		/* put right type in dope word */
	bisw2	$dope,r4
	addl2	$3,r8		/* put it on a longword boundary */
	bicl3	$3,r8,r0	/* by clearing low order bits */	
	movl	r4,(r0)		/* throw dopeword on stack */
	movl	r6,r1		/* pointer to block to return */
	brb	ubret		/* uniform place to return from */


/* uvector creation */
ublu:	movl	r1,r0		/* copy count */	
	addl2	$2,r0		/* dope words allocation */
	movl	r0,r4		/* arg for iblock */
	bsbw	iblock		/* allocate storage */

	movl	r6,r8		/* copy returned pointer */
	movl	r1,r10		/* copy count for return */
	jeql	2f		/* test for 0-length string */
1:	movl	4(r7),(r8)+	/* dump a word */
	addl2	$8,r7		/* next stack element */
	sobgtr	r1,1b		/* iterate for all chars in string */
2:	ashl	$16,r0,r4	/* copy number of words to left half */
	movw	$t.uvec+dope,r4	/* set type and dope bit */
	movl	r4,(r8)		/* throw dopeword on stack */
	movl	$t.uvec,r5	/* save type for return */	
	movl	r6,r1		/* pointer to block to return */
	brb	ubret		/* uniform place to return from */


/* vector generation */

ublv:	ashl	$1,r1,r1	/* number of words */
	movl	r1,r0		/* copy count */	
	addl2	$2,r0		/* dope words allocation */
	movl	r0,r4		/* arg for iblock */
	bsbw	iblock		/* allocate storage */

	movl	r6,r8		/* copy returned pointer */
	ashl	$-1,r1,r10	/* shift back and copy for return */
	jeql	2f		/* test for 0-length string */
1:	movl	(r7)+,(r8)+	/* dump a word */
	sobgtr	r1,1b		/* iterate for all chars in string */
2:	ashl	$16,r0,r4	/* copy number of words to left half */
	movw	$t.vec+dope,r4	/* set type and dope bit */
	movl	r4,(r8)		/* throw dopeword on stack */
	movl	$t.vec,r5	/* save type for return */	
	movl	r6,r1		/* pointer to block to return */
/* drop through to ubret */

ubret:	ashl	$16,r10,r0	/* copy count to left half */
	movw	r5,r0		/* and type to right */
	movl	r9,r13		/* restore TP */
	addl2	im.code+ov(r11),(sp)
	rsb

/* tmptbl - add a record description to table */

tmptbl:	ashl	$3,r0,r0	/* make long index */
	addl2	$rectbl,r0	/* pointer to table */
	movq	r1,(r0)		/* store info */
	rsb

/* record - build a record
* call:
*	r0/ type
* 	r1/ number of elements
*	(tp) elements on stack
* return:
*	(tp) popped
*	(record is built)	*/

record:	subl2	im.code+ov(r11),(sp)
	ashl	$-3,r0,r4	/* shift and copy type */
	bicl2	$037777360007,r4 /* mask uninteresting bits */
	movl	rectbl+4(r4),r8	/* table entry to r8 */
	movl	r0,r4		/* get type back again */
	pushl	r0		/* save r0 */
	movzwl	2(r8),r0	/* clear left half */
	ashl	$-1,r0,r0	/* div by 2 for storage allocation */
	movl	r0,r2		/* copy */
	addl2	$2,r0		/* dope words */
	bsbw	iblock		/* allocate storage */
	movl	(sp)+,r0	/* restore register */
	pushl	r11		/* save msubr pointer (being used as a temp) */
	pushl	r8		/* save another one */
	movl	r6,r11		/* save returned pointer */
	ashl	$16,r2,r3	/* count to left of r3 */
	movw	r4,r3		/* get type to right half */
	pushl	r3		/* and save for return */
	ashl	$2,r2,r2	/* make word index */
	addl2	r2,r11		/* point to dopewords */
	addl2	$0400000,r3	/* add 2 to left half (count) */
	movl	r3,(r11)	/* smash dope word to stack */
	bisl2	$dope,(r11)	/* dope it up */
	movl	r1,r9		/* save number of elements for loop */
	ashl	$3,r1,r1	/* word count */
	mnegl	r1,r1		/* negate it */
	addl3	r13,r1,r0	/* compute stack pointer */
	movl	r0,r11		/* and save it here */
	movl	r0,r5		/* save for stack fixup */
	movl	$4,r1		/* element number (word # for indexing mode) */

/* loop to move elements:
*	r6/ record
*	r7/ stack
*	r11/ tbl	*/

recorl:	movzwl	2(r8)[r1],r5	/* get dispatch code for put */	
	movzwl	(r8)[r1],r10
/*	ashl	$1,r5,r5	 and shift it */
	ashl	$1,r10,r10	/* both of its */
	movl	(r11),r3	/* value */
	movl	4(r11),r4
	bsbw	prcas		/* call appropriate move routine */
	addl2	$8,r11		/* step elements */
	addl2	$4,r1
	sobgtr	r9,recorl	/* loop */
	movl	r0,r13		/* reset TP */
	movl	(sp),r0		/* restore count and type */
	ashl	$1,r0,r0	/* make it number of words in left half */
	movw	(sp),r0		/* but don't shift type as well! */
	addl2	$4,sp		/* fix SP */
	movl	(sp)+,r8		/* restore registers */
	movl	r6,r1
	movl	(sp)+,r11		/* restore MS */
	addl2	im.code+ov(r11),(sp)	/* unrelativize */
	rsb

/* cons - build a list element
* call:
*	r3/ list to cons to
*	r0-r1/ value
* return:
*	r1/ result	*/

icons:	subl2	im.code+ov(r11),(sp)
	bsbb	cons
	addl2	im.code+ov(r11),(sp)
	rsb

cons:	movl	czone,r9	/* a zone set up? */
	 jeql	1f		/* no */
	  movl	gcpoff(r9),r4	/* yes, use it */
	  brb	consa
1:	 moval	rcl,r4 /* no zone */
consa:	movl	rcloff(r4),r9
	 jeql	cons1		/* get from iblock */
	movl	r9,r6
	movl	-4(r9),rcloff(r4) /* pull off chain */
	subl2	$4,r6		/* of free cons cells */
	brb	cons2

cons1:	movl	gcstopo(r4),r6
	addl2	$12,gcstopo(r4)	/* 12 bytes in list cell */
	cmpl	gcstopo(r4),gcsmaxo(r4)	/* GC needed? */
	 jleq	cons2		/* no, flush */
listgc:	movl	r6,gcstopo(r4)	/* restore used pointer */
	movq	r0,(r13)+	/* push thing being consed */
	movl	$t.list,(r13)+	/* push list */
	movl	r3,(r13)+
	movl	$3,r0
	bsbw	rungc		/* garbage collect */
	movl	-(r13),r3	/* get list back */
	subl2	$4,r13		/* flush list type word */
	movq	-(r13),r0	/* get object back */
	movl	czone,r9	/* has to be a zone after GC */
	movl	gcpoff(r9),r4
	brw	consa		/* try again */	
	
cons2:	movl	r3,0(r6)
	movq	r0,4(r6)	/* stuff object into list cell */
	movl	$t.list,r0	/* return type list */
	addl3	$4,r6,r1	/* return list */
	rsb

/* iblock - interface to storage allocation
* call:
*	r0/ number of words needed
* return:
*	r6/ pointer to block
*	(saves all other registers used)	*/

iblock:	bitl	r0,$0xffff0000
	 jeql	1f
	brw	comper
1:	pushr	$bit0+bit1+bit2+bit3+bit4+bit7	/* save a few registers */
iblokk:	movl	czone,r4	/* zone setup? */
	 beql	1f		/* not yet.. */
	  movl	gcpoff(r4),r4	/* yes, use it */
	  brb	2f
1:	movl	$gcpar,r4
2:	casel	r0,$2,$max_rcl-2	/* go to the right place */
ibtab:	.word	iblokl-ibtab
	.word	iblokl-ibtab
	.word	iblokl-ibtab
	.word	iblokb-ibtab
	.word	iblokb-ibtab
	.word	iblokl-ibtab
	.word	iblokl-ibtab
	.word	iblokb-ibtab
	.word	iblokl-ibtab
	jmp	iblokb
iblokl:	moval	rclvoff(r4),r7
	movl	(r7)[r0],r6	/* test to see if stuff is there */
	 jeql	iblokn		/* nope */
	movl	(r6),(r7)[r0]	/* splice out of chain */
	ashl	$2,r0,r0	/* convert to bytes */
	subl2	r0,r6		/* point above first word */
/*	ashl	$-2,r0,r0	pushed, so don't convert back */
	addl2	$4,r6		/* compensate for dope words */
				/* drop through... */
/* common return point */

iblokr:	popr	$bit0+bit1+bit2+bit3+bit4+bit7	/* restore a few registers */
	rsb


/* r0 has # words wanted, r4 has gc-params.  Return in r6 */

iblokb:	movl	rclvoff(r4),r2	/* anything in rclb? */
	 jeql	iblokn		/* no, allocate new */
	moval	rclvoff(r4),r6	/* previous pointer */
ibbnxt:	movzwl	-2(r2),r3	/* get first dope word */
	subl2	r0,r3		/* amount left */
	 blss	ibblos		/* not enough */
	 jeql	ibbeq		/* exactly right */
	subl2	$2,r3		/* must be 2 or more words left */
	 bgeq	ibbne		/* ok, win but with slop overflow */
ibblos:	movl	r2,r6		/* copy to previous slot */
	movl	(r6),r2		/* get next slot */
	jeql	iblokn		/* no more, allocate from free */
	brb	ibbnxt		/* try next slot */

/* exact match (we should be so lucky) */

ibbeq:	movl	(r2),(r6)	/* splice out of chain */
	decl	r0		/* fudge */
	ashl	$2,r0,r0	/* words--> bytes */
	subl2	r0,r2		/* point to beginning of block */
	
ibbret:	movl	r2,r6
	brb	iblokr		/* and go home winner */

/* inexact match, leave tailings */

ibbne:	movl	(r2),(r6)	/* splice out */
	addl2	$2,r3		/* compute new length of block */
	movw	r3,-2(r2)	/* new length of block */
	addl2	r0,r3
	pushl	r0		/* rclb expects pointer here, so save */
	movl	r2,r0		/* set up arg */
	bsbw	rclb		/* recycle the block */
	movl	(sp)+,r0		/* and restore reg */
	decl	r3
	ashl	$2,r3,r3
	subl2	r3,r2		/* point to beg of block */
	brb	ibbret

/* no recycling */

iblokn:	ashl	$2,r0,r0	/* turn into bytes */
	movl	gcstopo(r4),r6	/* return pointer */
	addl2	r0,gcstopo(r4)	/* bump up used marker */
	jvs	iblogc		/* if pointing into p2, need GC */
/*	ashl	$-2,r0,r0	no need to convert back, iblokr pops it */
	cmpl	gcstopo(r4),gcsmaxo(r4)	/* need to run GC? */
	 jleq	iblokr		/* no, return */
/*	brb	iblog1		need to convert length to words here */
iblogc:	ashl	$-2,r0,r0
iblog1:	movl	r6,gcstopo(r4)	/* restore used marker--not used yet */
	pushr	$bit1+bit5+bit8+bit9+bit10
	bsbb	rungc
	popr	$bit1+bit5+bit8+bit9+bit10
	brw	iblokk

/* rung - run users GC */

rungc:	pushl	r0
      	movl	czone,r1	/* must have a zone */
	 jeql	die
	bsbw	iframe
	movl	$t.fix,(r13)+
	movl	r0,(r13)+
	movl	$1,r0
	movl	gcfoff(r1),r1	/* pointer to gc function */
	bsbw	mcallz
	movl	(sp)+,r0
	rsb

/* EPA */

/* recycle a list cell (in r0, r1) */
rell:	pushl	r0
	movl	czone,r0
	 jneq	1f
	moval	-gcpoff+rcl,r0
1:	movl	gcpoff(r0),r0	/* gc-params */
	movl	rcloff(r0),-4(r1)	/* cdr pointer of new cell */
	clrq	(r1)		/* car pointer of new cell */
	movl	r1,rcloff(r0)
	movl	(sp)+,r0	/* don't step on any acs */
	rsb

/* recycle a record, in r0, r1 */
relr:	movq	r0,-(sp)	/* save acs */
	ashl	$-16,r0,r0	/* # halfwords in record */
	movaw	4(r1)[r0],r0	/* point to first dope word */
	bsbw	rclb		/* stuff it on the chain */
	movq	(sp)+,r0
	rsb

relu:	movq	r0,-(sp)
	bicb2	$0x0F8,r0	/* get primtype */
	caseb	r0,$4,$3	/* off we go */
relutb:	.word	reluby-relutb	/* bytes */
	.word	reluby-relutb	/* string */
	.word	reluuv-relutb	/* uv */
	.word	reluvc-relutb	/* vector */

reluby:	movzwl	2(sp),r0	/* get # bytes */
	addl2	$3,r0
	ashl	$-2,r0,r0	/* # longwords */
	jmp	reluc

reluuv:	movzwl	2(sp),r0
	jmp	reluc

reluvc:	movzwl	2(sp),r0
	ashl	$1,r0,r0
reluc:	moval	4(r1)[r0],r0	/* point to second dope word */
	bsbb	rclb		/* go do it */
	movq	(sp)+,r0
	rsb

/* call with pointer to second dope word of structure in r0 */
rclb:	movzwl	-2(r0),r1	/* block length */
	movw	$t.uvec+dope,-4(r0)	/* make sure a uv so msgc wins */
	subl2	$2,r1		/* # data words */
	 jleq	1f		/* nothing to zero */
	pushr	$bit0+bit1+bit2+bit3+bit4+bit5
	ashl	$2,r1,r1	/* # of bytes */
	subl2	r1,r0		/* points to 2nd word in block */
	movc5	$0,(r0),$0,r1,-4(r0)	/* zero the block */
	popr	$bit0+bit1+bit2+bit3+bit4+bit5
1:	addl2	$2,r1		/* actual # words in block */
	pushr	$bit2+bit3+bit4+bit5
	movl	czone,r2
	 jneq	2f
	moval	-gcpoff+rcl,r2
2:	movl	gcpoff(r2),r2	/* pick up gc-params */
	addl2	$rclvoff,r2
	clrl	r3
	cmpw	r1,$max_rcl
	 jgtr	3f
	addl2	rcltab[r1],r2	/* point at right slot */
	tstl	rcltab[r1]	/* are we a `long' block? */
	 jeql	3f		/* yes */
	mcoml	$0,r3		/* no, set the flag */
/* r0 points to 2nd dope word, r1 is block length, r2 is slot for recycle */
/* r3 is -1 if short block */
3:	tstl	(r2)		/* test chain for emptiness */
	 jneq	4f		/* not an empty chain */
	movl	r0,(r2)
	clrl	(r0)
rcldon:	popr	$bit2+bit3+bit4+bit5
	rsb
4:	movl	r2,r1		/* r1 is now something else */

/* r1 is pointer to current block of chain; r0 is pointer to block
being freed.  r2 becomes pointer to next block of chain. */

rclbl:	movl	(r1),r2
	 jeql	rclin1		/* at end of chain, just splice in */
	cmpl	r0,r2
	 blss	rclin		/* keep chain in ascending order */
	movl	r2,r1
	jmp	rclbl

rclin:	tstl	r3
	 jneq	rclin1		/* fixed-length block, just splice it */
	movzwl	-2(r2),r3	/* word length of next block */
/*	addl2	$2,r3		already have dope words included */
	ashl	$2,r3,r3
	subl3	r3,r2,r3	/* beginning of next block */		
	cmpl	r0,r3		/* adjacent blocks? */
	 jeql	1f
rclin1:	movl	r0,(r1)		/* no, splice into chain */
	movl	r2,(r0)
	jmp	rcldon
1:	addw2	-2(r0),-2(r2)	 /* adjacent, just update length */
	clrq	-4(r0)		/* zero the dope words */
	jmp	rcldon

rcltab:	.long	0
	.long	0
	.long	8	/* two-word blocks */
	.long	12
	.long	16
	.long	0	/* five-word */
	.long	0
	.long	28
	.long	32
	.long	0
	.long	40

/* setzon -- set current free storage zone 
   call:
	r1/	new zone or 0 to return the current
		if r1 is 0 and no zone, return UVECTOR of gcparams
*/
setzon:	tstl	r1		/* new one supplied? */
	jneq	1f		/* yes, set it up */

	movl	czone,r1	/* is there one to return? */
	jeql	2f		/* no return gcparams */

	movl	$(zlnt<16+t.zone),r0
	rsb

1:	movl	r1,czone
	tstl	ingc		/* were we in a GC? */
	 jeql	3f		/* no */
	tstl	cgnois		/* waiting for ctrl-G? */
	 jeql	3f		/* no */
	clrl	cgnois		/* clear the flag */
	pushr	$bit0+bit1+bit2+bit3+bit4+bit5
	moval	cgmsg2,r1
	movl	cgms2l,r3
	clrl	r5
	bsbw	print		/* print a message */
	popr	$bit0+bit1+bit2+bit3+bit4+bit5
3:	rsb

2:	movl	$gcpar,r1
	movl	$(gclnt<16+t.uvec),r0
	rsb

/****************************************************************
*								*
*								*
*			GC Stuff				*
*								*
*								*
****************************************************************/

/* swnxt -- sweep next
	call:	r0,r1 --> current object, and returned next object
	r2--> gc-params to use
*/

swnxt:	pushr	$bit2+bit3		/* save temp reg */
	tstl	r1		/* is this first time */
	bneq	1f		/* no, not first, time to sweep */

	movl	gcstopo(r2),r1	/* start at top */
1:	cmpl	gcsmino(r2),r1	/* see if done */
	blss	2f

	movl	$t.fix,r0	/* return 0 */
	clrl	r1
swret:	popr	$bit2+bit3
	rsb

2:	bicl2	$0xFFFFFFC0,r0	/* isolate primtype */
	cmpw	r0,$pt.list
	bneq	1f

	subl2	$4,r1		/* point to start of list */
1:	bitl	$dope,-8(r1)	/* dope word? */
	 bneq	1f		/* yes, more hair */
	movl	$t.list,r0	/* list, say so */
	subl2	$8,r1
	brb	swret

1:	movzwl	-6(r1),r0	/* get dw length */
	ashl	$2,r0,r2	/* to bytes */
	subl2	$2,r0		/* fixup count */
	ashl	$16,r0,r0
	bicw3	$dope+mark_bit,-8(r1),r3	/* get type */
	subl2	r2,r1		/* r1 point to start */
	bicl3	$0xFFFFFFC0,r3,r2
	caseb	r2,$0,$7
swtab:	.word	comper-swtab
	.word	comper-swtab
	.word	swrec-swtab
	.word	comper-swtab
	.word	swbyt-swtab
	.word	swbyt-swtab
	.word	swdone-swtab
	.word	swvec-swtab
	brw	comper
swbyt:	ashl	$2,r0,r0
	brb	swdone
swrec:	ashl	$1,r0,r0
	brb	swdone
swvec:	ashl	$-1,r0,r0
swdone:	bisw2	r3,r0		/* turn on type in return word */
	brb	swret

/* nexts -- sweep stack to find things to mark 
	call:	r1/ arg and return
		   if r1 --> 0 on call, return start of stack
		   if r1 --> 0 on return, sweep of stack done
*/

nexts:	pushl	r0		/* save extra register */
	tstl	r1		/* first time? */
	jneq	1f		/* no sweep */

	movl	czone,r0	/* get current zone */
	movl	gcpoff(r0),r0	/* point gc params */
	movl	$max_rcl,r1
2:	clrl	(r0)+
	sobgtr	r1,2b
	movl	tpstart,r1
	mcoml	$0,ingc		/* prevent ints for a while */

1:	movl	(r1),r0		/* examine last thing */
	bitl	$dope,r0	/* does last thing returned have dope word? */
	 jneq	7f		/* nope, no need to adjust */
	addl2	$8,r1		/* move to next guy */
	brb	4f		/* and check him out */

7:	cmpw	$dope+t.tuple,r0 /* just skip tuple dope words */
	 jeql	2f
	cmpw	$dope+t.vec,r0	/* in whatever form they come */
	 jeql	2f
	bicw2	$0xFFFF,r0	/* isolate length */
	rotl	$17,r0,r0	/* position and double length */
	addl2	r0,r1		/* point to end */
4:	movw	(r1),r0		/* get type code */
	bbsc	$5,r0,nxtdop	/* got a dope word */
	bitw	$7,r0		/* don't return words */
	 jeql	2f
nodop:	cmpw	$t.tuple,r0	/* tuple? */
	 jeql	2f		/* marked when encountered */
	cmpw	$t.qfram,r0	/* quick frame */
	 jneq	3f
	addl2	$gfr.len*2,r1	/* skip it */
	brb	4b
2:	addl2	$8,r1
	brb	4b
3:	cmpl	r13,r1		/* see if end of stack */
	 jgeq	nextrt
	clrl	r1
nextrt:	movl	(sp)+,r0
1:	rsb
nxtdop:	cmpw	$t.tuple,r0
	 jeql	2b		/* skip tuple dope words */
	cmpw	$t.vec,r0
	 jeql	2b
	cmpw	$t.qfram,r0	/* and glued frames */
	 jneq	9f
	addl2	$gfr.len*2,r1
	brw	4b
9:	cmpzv	$0,$3,r0,$pt.rec	/* other records get returned */
	 jeql	3b
	movzwl	2(r1),r0		/* get word length */
	ashl	$2,r0,r0		/* turn into bytes */
	addl2	r0,r1			/* move past this */
	brw	4b

/* get stack parameters.  Called with UV in r0/r1, returns it there. */
/* parameters are:  bottom of stack, top of stack, current max top of
   stack, absolute max top of stack (top of data space), top of buffer
   space, bottom of buffer space */
getstk:	movq	r0,(r13)+
	decw	-6(r13)
	 jlss	getskd
	movl	tpstart,(r1)+		/* get beginning of stack */
	decw	-6(r13)
	 jlss	getskd
	moval	-8(r13),(r1)+		/* current top of stack */
	decw	-6(r13)
	 jlss	getskd
	addl3	$tp_buf,tptop,(r1)+	/* max top of stack */
	decw	-6(r13)
	 jlss	getskd
	movl	tpmax,(r1)+
	decw	-6(r13)
	 jlss	getskd
	addl3	$pur_init,$prstart,(r1)+	/* top of buffer space */
	decw	-6(r13)
	 jlss	getskd
	moval	prstart,(r1)+		/* bottom of buffer space */
getskd:	movl	-(r13),r1
	subl2	$4,r13
	rsb

bigstk:	tstl	r1
	 jeql	1f			/* return current state */
	movl	stkok,r1
	movl	$1,stkok
	rsb
1:	movl	stkok,r1
	rsb

/* move stack.  Called with relocation in r0, assumes that all pointers
   except within frames/lbinds or at top level on stack (tuple pointers)
   will be updated by subsequent GC (which
   had better be pretty clever). */
movstk:	movl	tpstart,r1		/* bottom of stack */
movlop:	cmpl	r1,r13
	 jgeq	movdon
	bitl	$dope,(r1)		/* are we looking at a dope word? */
	 jneq	movdop			/* yes */
	cmpw	$t.qfram,(r1)
	 jeql	movqfr
	bitl	$7,(r1)			/* are we looking at a pointer? */
	 jeql	movldn			/* no, skip it */
	movl	4(r1),r2
	cmpl	r2,r13			/* pointer above top of stack? */
	 jgtr	movldn
	cmpl	r2,tpstart		/* below bottom? */
	 jlss	movldn
	addl2	r0,4(r1)		/* update the frob */
movldn:	addl2	$8,r1			/* and move on */
	brw	movlop
movdop:	bicl3	$dope,(r1),r2		/* turn off dope bit */
	cmpzv	$0,$3,r2,$pt.vec	/* tuples, vectors, etc. */
	 jeql	movldn
	cmpzv	$0,$3,r2,$pt.rec	/* see if a record */
	 jneq	movstr			/* no, just random structure */
	cmpw	$t.bind,r2		/* lbind */
	 jeql	movlbn
	addl2	$fr.len*2,r1		/* move to end of frame */
	addl2	r0,fr.fra(r1)		/* update frame pointer */
	brw	movlop
movstr:	ashl	$-14,r2,r2		/* get bytes in structure */
	addl2	r2,r1			/* update pointer */
	brw	movlop			/* and move on */
movlbn:	addl2	$4,r1
	movl	lb.prev(r1),r2
	cmpl	r2,r13
	 jgtr	1f
	cmpl	r2,tpstart
	 jlss	1f
	addl2	r0,lb.prev(r1)
1:	movl	lb.last(r1),r2
	cmpl	r2,r13
	 jgtr	2f
	cmpl	r2,tpstart
	 jlss	2f
	addl2	r0,lb.last(r1)
2:	addl2	$ln.bindb,r1		/* move to end */
	brw	movlop
movqfr:	addl2	$gfr.len*2,r1		/* move to end of glued frame */
	addl2	r0,gfr.pfr(r1)
	addl2	r0,gfr.fra(r1)		/* update pointers */
	brw	movlop
movdon:	addl2	r0,spsto	/* update binding chain start */
/* now blt the stack */
movagn:
2:	addl3	r0,tptop,arg1
	movl	$1,argn
	pushl	r0
	pushl	ap
	moval	argn,ap
	chmk	$_break
	movl	(sp)+,ap	/* get memory */
	movl	(sp)+,r0
	 jcs	movflt		/* frob failed */
	movl	tpstart,r1
	subl3	r1,r13,r2	/* current stack length */
	addl2	r0,tpstart
	movl	tpstart,stkbot
	movl	tpstart,r3
	addl2	r0,tptop	/* update kernel's stack pointers */
	movl	tptop,stkmax	/* save for compiled code to look at */
	addl2	r0,r13
	addl2	r0,r12
	movc3	r2,(r1),(r3)	/* blt the stack */
	rsb			/* all done */

movflt:	bsbw	nomem
	brw	movagn

nomem:	pushr	$bit0+bit1+bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit9+bit10+bit11+bit12
	moval	restlos,r1
	ashl	$16,restlol,r0
	mcoml	$1,r2		/* keep the loser from dying */
	bsbw	rfatal
	popr	$bit0+bit1+bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit9+bit10+bit11+bit12
	rsb

imarkr:	cmpl	r1,r13		/* anything on the stack is not marked */
	 jgtr	9f
	cmpl	r1,tpstart
	 jlss	9f
	rsb
9:	bicw2	$0xFFFF,r0
	rotl	$17,r0,r0	/* get length  times 2 from pntr */
	addl2	r0,r1		/* point to d.w. */
	tstl	r3		/* if unmark, jump */
	 jeql	1f
	bisw2	$0x8000,(r1)	/* mark it */
	clrl	4(r1)
	cmpl	$1,r3
	 jeql	2f		/* just mark it */
	movl	r3,4(r1)	/* store relocation */
2:	rsb
1:	bicw2	$0x8000,(r1)	/* kill bit */
3:	rsb

imarkrq:
	tstl	r0		/* check type ac */
	 jeql	3b		/* leave on zero type word */
	cmpl	r1,r13		/* anything on the stack is marked */
	 jgtr	1f
	cmpl	r1,tpstart
	 jgtr	4f
1:	pushl	r0
	bicw2	$0xFFFF,r0
	rotl	$17,r0,r0
	addl2	r0,r1
	movl	(sp)+,r0
	tstb	1(r1)		/* marked? */
	 jgeq	2f
	movl	4(r1),r1	/* any reloc pointer */
	 jneq	3f
4:	movl	$1,r1
1:	movl	$t.fix,r0
3:	rsb
2:	clrl	r1
	brb	1b
	

/****************************************************************
*								*
*								*
*			Structure manipulators			*
*								*
*								*
****************************************************************/

/* nthu - nth of string/ vector/ uvector
* call:
*	r0/ type
*	r1/ pointer
*	r2/ number
* return:
*	r0-r1/ type-value	*/

nthu:	bicl2	$0xFFFFFFFC,r0	/* isolate primtype */
	caseb	r0,$0,$3	/* dispatch on type */
nutab:	.word	nthub-nutab
	.word	nthus-nutab
	.word	nthuu-nutab
	.word	nthuv-nutab
	bsbw	comper		/* any other type is fatal */

nthub:	addl2	r2,r1
	movzbl	(r1),r1
	movl	t.fix,r0
	rsb

nthus:	addl2	r2,r1		/* point to byte */
	movzbl	(r1),r1		/* get byte */
	movl	t.char,r0	/* type char */
	rsb

nthuu:	ashl	$2,r2,r2	/* make index */
	movl	(r2)[r1],r1	/* get thing */
	movl	t.fix,r0	/* type fix */
	ashl	$-2,r2,r2	/* restore number (why?) */
	rsb

nthuv:	ashl	$3,r2,r2	/* make index */
	movl	-8(r2)[r1],r0	/* get type */
	movl	-4(r2)[r1],r1	/* get thing */
	ashl	$-3,r2,r2	/* restore number */
	rsb

/* nthr - nth of a record
* call:
*	r0/ type
*	r1/ pointer to record
*	r2/ element number
* return:
*	r0,r1/ type,value	*/

nthr:	pushr	$bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit10
	movzwl	r0,r0		/* clear left-half junk */
	ashl	$-3,r0,r0	/* and flush prim-type part */
	moval	rectbl+4(r0),r7	/* point to table entry */
	ashl	$3,r2,r2	/* index for element number */
	movzwl	0(r7)[r2],r3	/* get word offset */
	movzwl	2(r7)[r2],r4	/* code for appropriate field */
	ashl	$1,r3,r3	/* shift left */
	movl	r1,r6		/* object address */
	caseb	r4,$1,$12		/* dispatch */
nrtab:	.word	nthrbb-nrtab		/* bool */
	.word	nthrer-nrtab		/* error */
	.word	nthrbb-nrtab		/* enumeration */
	.word	nthrbb-nrtab		/* subrange */
	.word	nthrbb-nrtab		/* subrange sbool */
	.word	nthrlf-nrtab		/* list/ fix */
	.word	nthrlf-nrtab		/* list/ fix (sbool) */
	.word	nthrs3-nrtab		/* struc with count */
	.word	nthrs3-nrtab		/* struc with count (sbool) */
	.word	nthrs2-nrtab		/* struc with fixed length */
	.word	nthrs2-nrtab		/* same (sbool) */
	.word	nthra-nrtab		/* any */
	.word	nthrhw-nrtab

/* out of range drops through to error */

nthrer:	bsbw	cmperr		/* die horrible death */

/* boolean, etc */

nthrbb:
/*	*** how to extract boolean? *** */
	bsbw	unimpl

				/* drop through to common return */

nthrts:	popr	$bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit10
	rsb


/* list, fix */

nthrlf:	movl	(r7)[r2],r0
	movl	(r6)[r3],r1
	brb	nthrts

/* 3 1/2 word structure */

nthrs3:	ashl	$16,(r6)[r3],r0		/* length to left half */
	movw	(r7)[r2],r0		/* type to right */
	movl	2(r6)[r3],r1		/* value */
	 jneq	nthrts			/* false? */
nthrfl:	movl	$t.false,r0		/* yes, store falst type */
	brb	nthrts

/* structure of known length */

nthrs2:	movl	(r7)[r2],r0		/* type */
	movl	(r6)[r3],r1		/* pointer */
	 jeql	nthrfl			/* return false? */
	brb	nthrts			/* no, just return */

/* any case */

nthra:	movl	(r6)[r3],r0		/* type */
	movl	4(r6)[r3],r1		/* value */
	brb	nthrts

/* special type-c case */

nthrhw:	ashl	$1,r3,r1
	cvtwl	(r6)[r1],r1		/* get type code or -1 */
	 jlss	1f			/* jump if false */
	movl	$t.typc,r0
	brb	nthrts

1:	clrl	r1
	movl	$t.false,r0
	brb	nthrts

/* restu - rest uv, v, str 
* call:
*	r0/ type
*	r1/ pointer
*	r3/ number 	*/

restu:	movl	r3,(r13)+		/* save count for return */
	movl	r0,(r13)+		/* save cnt, type */
	subw2	r3,-2(r13)		/* fix count for return */
	bicb2	$0x0FC,r0		/* isolate 2-bit primtype */
	caseb	r0,$0,$3		/* dispatch */
rstab:	.word	rstub-rstab	/* bytes */
	.word	rstus-rstab	/* string */
	.word	rstuu-rstab	/* uvec */
	.word	rstuv-rstab	/* vector */

	bsbw	cmperr			/* others lose */

/* vector */

rstuv:	ashl	$3,r3,r3		/* adjust count for vector thing */
	cmpl	r1,r13
	 bgtr	1f			/* above top of stack */
	cmpl	r1,tpstart
	 blss	1f			/* in pure space */
	movw	$t.tuple,-4(r13)	/* tuple - fix saved type */
	brb	rstdon			/* and done */
1:	movw	$t.vec,-4(r13)		/* vector - fix saved type */
	brb	rstdon			/* and done */

/* uvector */

rstuu:	ashl	$2,r3,r3		/* adjust count for uvec thing */
	movw	$t.uvec,-4(r13)		/* fix saved type */
	brb	rstdon

rstub:	movw	$t.bytes,-4(r13)
	brb	rstdon
/* string */

rstus:	movw	$t.str,-4(r13)		/* fix saved type */
					/* and drop through */
rstdon:	addl2	r3,r1			/* fix pointer by right amount */
	movl	-(r13),r0		/* restore fixed type word */
	movl	-(r13),r3		/* and restore count */
	rsb

/* back */

backu:	mnegl	r3,r3			/* its like a negative */
	bsbw	restu			/* rest */
	mnegl	r3,r3			/* restore r3 */
	rsb


/* top things */

topu:	pushl	r0			/* save type word for return */
	bicb2	$0x0FC,r0			/* isolate primtype */
	caseb	r0,$0,$3		/* dispatch */
toptab:	.word	topub-toptab
	.word	topus-toptab	/* string */
	.word	topuu-toptab	/* uvec */
	.word	topuv-toptab	/* vector */
				/* any others drop through */
	bsbw	cmperr		/* oops */

/* bytes */
topub:	pushl	r2
	movw	$t.bytes,r2
	brb	topus1

/* string */

topus:	pushl	r2
	movw	$t.str,r2
topus1:	movzwl	6(sp),r0	/* get length */
	addl2	r0,r1		/* point to dope word */
	cmpl	r1,tpstart
	 jlss	1f
	cmpl	r1,tpmax
	 jgtr	1f
	brw	topust		/* stack case */
1:	bicl3	$0xFFFFFFFC,r1,-(sp)	/* extra chars */
	addl2	$3,r1		/* round to full word boundary */
	bicb2	$3,r1
topsdn:	movzwl	2(r1),r0	/* total length to r0 */
	subl2	$2,r0		/* not counting dope words */
	ashl	$2,r0,r0
	subl2	r0,r1		/* point to top */
	tstl	(sp)
	 jeql	1f
	subl3	(sp),$4,(sp)
	subl2	(sp),r0
1:	addl2	$4,sp
	ashl	$16,r0,r0
	movw	r2,r0		/* string primtype */
	movl	(sp)+,r2
	addl2	$4,sp		/* fix stack */
	rsb
topust:	bbc	$0,r1,1f	/* jump if on halfword boundary already */
	addl2	$1,r1		/* otherwise, move to one */
	movl	$1,-(sp)	/* at least one byte in last word */
	brb	3f
1:	movl	$2,-(sp)	/* at least two bytes in last word */
3:	tstw	(r1)		/* if zero, haven't hit dopeword yet */
	 jneq	2f
	addl2	$2,r1		/* advance pointer to dope word */
	brw	topsdn
2:	addl2	$2,(sp)		/* already at dopeword, 2 more in last word */
	bicl2	$0xFFFFFFFC,(sp)	/* but never more than 3 */
	brw	topsdn

/* uvec */

topuu:	movzwl	2(sp),r0	/* get length */
	ashl	$2,r0,r0
	addl2	r0,r1
	movzwl	2(r1),r0
	subl2	$2,r0		/* don't count dope words */
	ashl	$2,r0,r0
	subl2	r0,r1
	ashl	$14,r0,r0
	bisw2	$t.uvec,r0
	addl2	$4,sp
	rsb

/* vector */

topuv:	movzwl	2(sp),r0
	ashl	$3,r0,r0
	addl2	r0,r1			/* get to dope words */
	movzwl	2(r1),r0		/* get count from dw */
1:	subl2	$2,r0
	ashl	$2,r0,r0
	subl2	r0,r1
	ashl	$13,r0,r0
	bisw2	$t.vec,r0		/* get type */
	addl2	$4,sp
	rsb

/* putu - put vector, etc 
* call:
*	r0/ type
*	r1/ pointer
*	r2/ element number
*	r3,r4/ new value
* return:
*	(new value in place)		*/

putu:	pushl	r0			/* save type for return */
	bicb2	$0x0FC,r0		/* isolate primtype */
	caseb	r0,$0,$3		/* dispatch */
putab:	.word	putus-putab
	.word	putus-putab
	.word	putuu-putab
	.word	putuv-putab

	bsbw	cmperr

/* string case */

putus:	movb	r4,(r1)[r2]		/* store byte */
	movl	(sp)+,r0
	rsb

putuu:	movl	r4,(r1)[r2]		/* index does right thing */
	movl	(sp)+,r0
	rsb

putuv:	movq	r3,(r1)[r2]		/* magic index mode */
	movl	(sp)+,r0
	rsb

/* put record type
* call:
*	(args as in PUTU)	*/

putr:	

	pushr	$bit0+bit1+bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit10
	movzwl	r0,r0		/* clear left-half junk */
	ashl	$-3,r0,r0	/* and flush prim-type part */
	moval	rectbl+4(r0),r8	/* point to table entry */
	ashl	$3,r2,r2	/* index for element number */
	movzwl	0(r7)[r2],r10	/* get word offset */
	movzwl	2(r7)[r2],r5	/* code for appropriate field */
	ashl	$1,r10,10	/* shift left */
	movl	r1,r6		/* object address */
	brb	1f
prcas:	pushr	$bit0+bit1+bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit10
1:	caseb	r5,$1,$12	/* dispatch */
prtab:	.word	putrbb-prtab		/* bool */
	.word	putrer-prtab		/* error */
	.word	putrbb-prtab		/* enumeration */
	.word	putrbb-prtab		/* subrange */
	.word	putrbb-prtab		/* subrange sbool */
	.word	putrlf-prtab		/* list/ fix */
	.word	putrlf-prtab		/* list/ fix (sbool) */
	.word	putrs3-prtab		/* struc with count */
	.word	putrs3-prtab		/* struc with count (sbool) */
	.word	putrs2-prtab		/* struc with fixed length */
	.word	putrs2-prtab		/* same (sbool) */
	.word	putra-prtab		/* any */
	.word	putrhw-prtab		/* special type-c hack */

/* out of range drops through to error */

putrer:	bsbw	cmperr		/* die horrible death */

/* boolean, etc */

putrbb:
	bsbw	unimpl

				/* drop through to common return */

putrts:	popr	$bit0+bit1+bit2+bit3+bit4+bit5+bit6+bit7+bit8+bit10
	rsb


/* list, fix */

putrlf:	addl2	r6,r10			/* calc address */
	movl	r4,(r10)		/* store value */
	brb	putrts

/* 3 1/2 word structure */

putrs3:	addl2	r6,r10			/* calculate address */
	cmpw	$t.false,r3		/* false? */
	 jeql	putrsx			/* naw */
	rotl	$16,r3,r3
	movw	r3,0(r10)
	movl	r4,2(r10)
	brb	putrts
putrsx:	clrw	(r10)
putrsy:	clrl	2(r10)
	brb	putrts

/* fixed length item */

putrs2:	cmpw	$t.false,r2		/* false? */
	jneq	putrlf			/* no */
	addl2	r6,r10
	brb	putrsy

/* any */

putra:	addl2	r6,r10
	movq	r3,(r10)
	brb	putrts

/* special type-c hack */

putrhw:	addl2	r6,r10			/* calculate address */
	cmpw	$t.false,r3
	 jeql	1f
	movw	r4,0(r10)		/* store type-c */
	brb	putrts

1:	mcomw	$0,0(r10)		/* indicate false */
	brb	putrts	

/* cinth */

cinth:	bicb2	$0x0F8,r0		/* isolate 3 bits */
	caseb	r0,$1,$6		/* dispatch */
cintab:	.word	cindbl-cintab
	.word	ciner-cintab
	.word	ciner-cintab
	.word	cinfby-cintab
	.word	cinbyt-cintab
	.word	cinuvc-cintab
	.word	cindbl-cintab
					/* errors drop through */
ciner:	bsbw	cmperr

cindbl:	movq	(r1),r0
	rsb

cinfby:	movzbl	(r1),r1
	movl	$t.fix,r0
	rsb

cinbyt:	movzbl	(r1),r1
	movl	$t.char,r0
	rsb

cinuvc:	movl	(r1),r1
	movl	$t.fix,r0
	rsb

/* cirst */

cirst:	pushl	r9
	extzv	$0,$3,r0,r9		/* get rightmost 3 bits */
	caseb	r9,$1,$6		/* dispatch */
cirtab:	.word	cirlst-cirtab
	.word	cirer-cirtab
	.word	cirer-cirtab
	.word	cirbyt-cirtab
	.word	cirstr-cirtab
	.word	ciruvc-cirtab
	.word	cirvec-cirtab
				/* errors */
cirer:	bsbw	cmperr

cirlst:	movl	$t.list,r0
	movl	-4(r1),r1
	movl	(sp)+,r9
	rsb

cirbyt:	incl	r1
	pushl	r0
	decw	2(sp)
	movl	(sp)+,r0
	movw	 $t.bytes,r0
	movl	(sp)+,r9
	rsb

cirstr:	incl	r1
	pushl	r0
	decw	2(sp)		/* fix count */
	movl	(sp)+,r0		/* is this a kludge? */
	movw	$t.str,r0
	movl	(sp)+,r9
	rsb

ciruvc:	addl2	$4,r1
	pushl	r0
	decw	2(sp)
	movl	(sp)+,r0
	movw	$t.uvec,r0
	movl	(sp)+,r9
	rsb

cirvec:	addl2	$8,r1
	pushl	r0
	decw	2(sp)
	movl	(sp)+,r0
	movw	$t.vec,r0
	movl	(sp)+,r9
	rsb

/* cigas */

cigas:	tstl	(r1)		/* test gval slot */
	jeql	1f		/* anything? */
	 rsb			/* yes, gassigned */
1:	movl	$t.false,r0	/* nope, return false */
	clrl	r1
	rsb

/* cigvl */

cigvl:	movl	(r1),r1		/* get gval */
	 jneq	1f
	  bsbw	cmperr
1:	movq	(r1),r0		/* get type and all */
	rsb

/* ciemp */

ciemp:	pushl	r0
	bicb2	$0x0F8,r0	/* isolate 3 bits */
	caseb	r0,$1,$6
cietab:	.word	cielst-cietab
	.word	cier-cietab
	.word	cier-cietab
	.word	cielen-cietab
	.word	cielen-cietab
	.word	cielen-cietab
	.word	cielen-cietab

cier:	bsbw	cmperr

cielst:	movl	(sp)+,r0
	tstl	r1
	 jneq	cieln1		/* non-skip return */
cieln2:	addl2	$3,(sp)		/* skip return (must skip a brw ins) */
cieln1:	rsb

cielen:	movl	(sp)+,r0
	cmpl	r0,$0xFFFF
	 jlequ	cieln2		/* skip */
	rsb			/* non-skip */

/* cimon */

cimon:	pushl	r0
	bicb2	$0x0F8,r0	/* isolate 3 bits */
	caseb	r0,$0,$7
cimtbl:	.word	cimtru-cimtbl
	.word	cielst-cimtbl	
	.word	cimtru-cimtbl
	.word	cimtru-cimtbl
	.word	cielen-cimtbl
	.word	cielen-cimtbl
	.word	cielen-cimtbl
	.word	cielen-cimtbl

cimtru:	movl	(sp)+,r0
	brb	cieln2		/* skip return */


/* fatal -- complain, then depart from mim */

efatal:	movl	$1,r2		/* this one will kill the process */
	bsbb	rfatal
	jmp	comper

dfatal:	mcoml	$1,r2
	bsbb	rfatal
	jmp	comper

rfatal:	pushr	$bit0+bit1+bit2+bit3+bit4+bit5
	moval	oldtty,r1
	bsbw	fixtty		/* get the tty back into shape */
	moval	fatmsg,r1
	movl	fatmsl,r3
	clrl	r5
	bsbw	print
	movl	4(sp),r1	/* get the string pointer back */
	clrl	r3
	movw	2(sp),r3
	bsbw	print
	popr	$bit0+bit1+bit2+bit3+bit4+bit5
	tstl	r2
	 jgeq	rfatex
	bsbw	leave
	moval	newtty,r1
	bsbw	fixtty
	rsb
rfatex:	movl	r2,arg1
	movl	$1,argn
	moval	argn,ap
	chmk	$_exit
	rsb

leave:	pushl	ap
	clrl	argn
	moval	argn,ap
	chmk	$_getpid
	movl	r0,arg1		/* only poke this process */
	movl	$17,arg2
	movl	$2,argn
	movl	$argn,ap
	chmk	$_kill
	movl	(sp)+,ap
	rsb

/* quit -- depart from mim.  Arg in r1; if >= 0, do exit */

quit:	pushl	r1
	moval	oldtty,r1
	bsbw	fixtty		/* fix up tty */
	movl	(sp)+,r1
	 jgeq	1f		/* jump if doing exit */
	bsbw	leave
2:	pushl	r1
	moval	newtty,r1
	bsbw	fixtty
	movl	(sp)+,r1
	rsb
1:	movl	$1,argn
	movl	r1,arg1
	pushl	ap
	movl	$argn,ap
	chmk	$_exit
	movl	(sp)+,ap
	brb	2b

/* Call with address in r1 of block for fixing/breaking tty */
fixtty:	tstl	(r1)
	 jneq	1f			/* jump if stuff is there */
	rsb
1:     	pushl	ap
	clrl	arg1
	movl	$tiocsetn,arg2
	addl3	$12,r1,arg3
	movl	$3,argn
	movl	$argn,ap
	chmk	$_ioctl			/* set sgttyb stuff */
	movl	$tioclset,arg2
	addl3	$8,r1,arg3
	movl	$3,argn
	movl	$argn,ap
	chmk	$_ioctl			/* local modes */
	movl	$tiocsetc,arg2
	movl	r1,arg3
	movl	$3,argn
	movl	$argn,ap
	chmk	$_ioctl			/* other characters */
	movl	$tiocsltc,arg2
	addl3	$18,r1,arg3
	chmk	$_ioctl			/* local characters */
	movl	(sp)+,ap
	rsb

/* Call with state structure in r0,r1; copy stuff out of oldtty if there,
   else return false */
gettty:	tstl	oldtty
	 jneq	1f
	movl	$t.false,r0
	clrl	r1
	rsb
1:	pushr	$bit0+bit1+bit2+bit3+bit4+bit5
	movc3	$6,oldtty,*4(r1)
	moval	oldtty,r0
	movl	4(sp),r1
	movl	8(r0),*12(r1)
	movc3	$6,12(r0),*20(r1)
	moval	oldtty,r0
	movl	4(sp),r1
	movc3	$6,18(r0),*28(r1)
	popr	$bit0+bit1+bit2+bit3+bit4+bit5
	rsb

/* Call with old state in r0, new in r1.  Structure pointed to is
   assumed to be TTSTATE, as defined in TTY package.  0-->nothing saved. */
savtty:	pushl	r1
	moval	oldtty,r1
	bsbw	dottys
	movl	(sp)+,r0
	moval	newtty,r1
	bsbw	dottys
	rsb

dottys:	tstl	r0
	 jneq	1f
	clrl	(r1)
	rsb
1:	pushr	$bit2+bit3+bit4+bit5
	pushl	r0
	pushl	r1
	movc3	$6,*4(r0),(r1)		/* copy chars */
	movl	(sp),r1
	movl	4(sp),r0
	movl	*12(r0),8(r1)
	movl	(sp),r1
	movl	4(sp),r0
	movc3	$6,*20(r0),12(r1)
	movl	(sp)+,r1
	movl	(sp)+,r0
	movc3	$6,*28(r0),18(r1)
	popr	$bit2+bit3+bit4+bit5
	rsb

/* save  r1 --> channel upon which to do save
   r2-->0 or frozen space
   r3-->0 or pure space */

isave:	movl	(sp),r0			/* return PC */
	bsbb	dosave
	cmpw	r0,$t.false
	 beql	isavou
	movl	$t.fix,r0
	clrl	r1
isavou:	rsb

/* This assumes that the current zone is set up and that the gc-params
   and areas are consistent. */
dosave:	movl	bindid,sbindid		/* save bindid */
	movl	spsto,sspsto		/* and spsto */
	movl	r0,(r13)+		/* push return PC */
	movl	r12,(r13)+		/* save frame */
	movl	czone,r4
	 jeql	nozone
	brb	csave
nozone:	bsbw	comper

/* routine to save a zone's vital statistics on the tp stack.  Increments
   r0 for each area saved */
zonect:	movl	gcaoff(r4),r4		/* pick up area list */
	 jeql	sloopd
sloop:	movl	4(r4),r5		/* pick up area */
	movl	amin(r5),r3		/* maybe empty zone */
	 jeql	sloopd
	movl	r3,(r13)+
	movl	abot(r5),(r13)+
	movl	amax(r5),(r13)+
	incl	r0
	movl	-4(r4),r4
	 jneq	sloop
sloopd:	rsb

csave:	clrl	r0
	pushl	r4
	pushl	r3
	pushl	r2
	movl	(sp),r4
	 jeql	1f
	bsbb	zonect			/* save params for atom zone */
1:	movl	4(sp),r4
	 jeql	2f
	bsbb	zonect			/* save params for pure zone */
2:	movl	8(sp),r4
	bsbb	zonect			/* main zone */
/* r0 has total count of areas */
	
	movl	r0,(r13)+		/* save count of areas */
	movl	r13,stktop		/* save TP */
	movl	$version,versav		/* save kernel version # */
	pushl	r1			/* save channel */
	movl	r1,r5			/* and pass to print */
	moval	savstrt,r1		/* start at savstrt */
	subl3	r1,$savend,r3		/* compute number of bytes */
	bsbw	print			/* write kernel vars out */
	cmpw	r0,$t.false
	 jeql	savlost
	movl	tpstart,r1		/* beginning of tp stack */
	subl3	r1,r13,r3		/* size of tp stack */
	movl	(sp),r5
	bsbw	print			/* write out tp stack */
	cmpw	r0,$t.false
	 jeql	savlost
	movl	(sp),r5			/* channel back */
	movl	4(sp),r4
	 jeql	1f
	bsbb	zonesv		/* save atom zone */
	cmpw	r0,$t.false
	 jeql	savlost
1:	movl	8(sp),r4
	 jeql	2f
	bsbb	zonesv
	cmpw	r0,$t.false
	 jeql	savlost
2:	movl	12(sp),r4
	bsbb	zonesv
	cmpw	r0,$t.false
	 jeql	savlost
	movl	(sp)+,r1
	bsbw	close		/* close channel */
	addl2	$12,sp		/* flush zones from stack */
4:	mull3	$12,-(r13),r2
	subl2	r2,r13		/* flush areas from tp stack */
	subl2	$8,r13		/* other stuff on tp */
	rsb
savlost:
	addl2	$16,sp		/* flush garbage from sp */
	brb	4b		/* clean up tp, return */

zonesv:	movl	gcaoff(r4),r4	/* list of areas */
	 jeql	zonesd		/* empty? */
2:	movl	4(r4),r3	/* get an area */
	movl	amin(r3),r1	/* bottom of area */
	 jeql	zonesd
	subl3	r1,abot(r3),r3	/* size of area */
	pushl	r4		/* save list */
	bsbw	print
	movl	(sp)+,r4	/* get list back */
	cmpw	r0,$t.false	/* print lost */
	 beql	zonesd
	movl	-4(r4),r4	/* rest it */
	 jneq	2b		/* loop if more */
zonesd:	rsb
	movl	(sp)+,r4	/* fix up sp */

/* irestor -- r1/ --> channel  */

irestor:
	bsbb	dorest
	tstl	r0
	 jeql	1f
	movl	r0,(sp)			/* dorest returns PC in r0 */
1:	movl	$t.fix,r0
	movl	$1,r1
	rsb

dorest:	pushl	r1			/* save channel */
	clrl	p1cur

	movl	$savstrt,r1
	movl	$8,r3
	movl	(sp),r5
	bsbw	read			/* read version number */
	cmpl	versav,$version
	 jneq	verlost			/* different version, lose immediate */

	movl	$savstrt+8,r1		/* point to first chunk */
	movl	$savend-savstrt-8,r3	/* kernel vars only */
	movl	(sp),r5			/* channel for read */
	bsbw	read			/* should now know size of stack etc */
	movl	sbindid,bindid		/* restore bindid */
	movl	sspsto,spsto		/* and spsto */

stkagn:	pushl	ap
	movl	tptop,arg1
	movl	$1,argn
	moval	argn,ap
	chmk	$_break			/* make sure have space for stack */
	movl	(sp)+,ap
	 jcc	2f
	bsbw	nomem
	brb	stkagn

2:	movl	tpstart,r1		/* now read TP stack */
	movl	r1,stkbot		/* save in user area */
	movl	tptop,stkmax		/* save stack limit in user area */
	subl3	r1,stktop,r3		/* compute length */	
	movl	(sp),r5
	bsbw	read			/* read in TP stack */

	movl	stktop,r13		/* get TP back */
	movl	-(r13),r0		/* number of areas */
	mull3	$12,r0,r1		/* number of bytes */
	subl3	r1,r13,r1		/* point to first */
	movl	r1,stktop		/* save, to flush this */
reslop:	pushr	$bit0+bit1		/* save acs */
	subl3	abot(r1),amax(r1),r5		/* length of area */
	movl	abot(r1),r3			/* beginning of area */
	cmpl	r3,$0x40000000		/* part of p1? */
	 jlss	1f
	subl3	r3,$0x7FFFFFFF,r1	/* yes, get distance from top of p1 */
	cmpl	r1,p1cur		/* already have that much? */
	 jleq	1f
vagain:	movl	p1lim,limits+4		/* No, grow p1 */
	movl	r1,p1cur		/* say we grew it */
	movl	r1,limits
	movl	$2,argn
	movl	$rlimit_stack,arg1
	moval	limits,arg2
	pushl	ap
	moval	argn,ap
	chmk	$_setrlimit		/* do system call */
	movl	(sp)+,ap
	 jcs	novirt			/* jump if failed */
1:	movc5	$0,(r3),$0,r5,(r3)	/* zero core */
	movq	(sp),r0			/* get acs back */
	subl3	abot(r1),amin(r1),r3		/* get length */
	movl	abot(r1),r1			/* bottom of area */
	movl	8(sp),r5		/* get channel back */
	bsbw	read
	popr	$bit0+bit1
	addl2	$12,r1
	decl	r0
	 jgtr	reslop			/* jump if more areas */

	movl	(sp)+,r1		/* get channel back */
	bsbw	close
	movl	stktop,r13		/* get the correct tp back */
	movl	-(r13),r12		/* restore frame */
	pushl	ap
	movl	$rlimit_data,arg1
	moval	limits,arg2
	movl	$2,argn
	moval	argn,ap
	chmk	$_getrlimit
	movl	limits+4,tpmax		/* absolute top of stack */
	movl	$rlimit_stack,arg1
	moval	limits,arg2		/* store structure */
	movl	$2,argn
	moval	argn,ap
	chmk	$_getrlimit		/* read stack limit */
	subl3	limits+4,$0x80000000,r0	/* to lowest address */
	ashl	$byts_page_sh,r0,r0	/* to page number */
/*	addl2	$1000,r0		what was this, anyway? */
	movl	pagpt1,r1
	pushl	r2
	movl	16(r1),r2		/* bot of GC space */
	movl	r0,(r1)	/* new "top of P0" */
	movl	r0,16(r1)	/* and start of "free" space" */
	subl2	r2,r0		/* new-old:  neg of diff in # pages  */
	subl2	r0,12(r1)	/* new page count */
	movl	(sp)+,r2
	movl	(sp)+,ap
	movl	-(r13),r0		/* get return PC back */
	clrl	noboot
	rsb

novirt:	bsbw	nomem
	brw	vagain

verlost:
	tstl	noboot			/* see if mudsub during startup */
	 bneq	vermud
	movl	(sp),arg1
	clrl	arg2
	movl	$L_SET,arg3
	movl	$3,argn
	pushl	ap
	moval	argn,ap
	chmk	$_lseek
	movl	(sp)+,ap
	brw	verlo1

vermud:	movl	$1,argn
	movl	(sp),arg1
	pushl	ap
	moval	argn,ap
	chmk	$_close			/* close save file */
	movl	(sp)+,ap

verlo1:	movl	versav,r0
	clrl	r1			/* make sure will work as quad */
	moval	verptr,r2
	movl	$1000,r3
1:	ediv	r3,r0,r4,r0		/* quotient to r1, remainder to r0 */
	 bneq	verls1
	divl2	$10,r3
	brb	1b
verls1:	addb3	r4,$48,(r2)+		/* deposit the byte */
2:	divl2	$10,r3
	 beql	verdon
	ediv	r3,r0,r4,r0
	addb3	r4,$48,(r2)+
	brb	2b
verdon:	clrb	(r2)
	moval	newker,r1
	movl	newkln,r3
	clrl	r5
	bsbw	print
	movl	argbeg,r2
	subl2	$4,r2
	tstl	noboot
	 beql	3f
	movl	argone,(r2)		/* if mudsub, get org jcl */
	brb	4f
3:	clrl	argone
	movb	(sp),argone
	moval	argone,(r2)		/* save file descriptor (funny str)*/
4:	movl	r2,arg2
	moval	kernam,arg1
	movl	envbeg,arg3
	movl	$3,argn
	pushl	ap
	moval	argn,ap
	chmk	$_execve		/* try to load the right kernel */
	moval	savver,r1		/* failed if get here */
	ashl	$16,savvel,r0
	bsbw	efatal
 
/* allocate pages */

mpages:	bsbw	cmperr			/* unimplemented */


/****************************************************************
*								*
*								*
*			Input/ Output				*
*								*
*								*
****************************************************************/

/* open - open a channel to a file
* call:
*	r0/ type (need string count for syscall)	
*	r1/ string pointer to file spec
*	r3/ fix (mode) 0=read, 1=write, 2=read/write
* return:
*	r0/ type (channel)
*	r1/ file-descriptor
*	(the file is positioned at byte 0)
*	(all registers saved)	*/

/* openz is just like open, except the string is already null-terminated */
openz:	pushr	$bit2+bit3+bit4+bit5
	movl	r1,arg1			/* dont copy file name */
	brw	open1

open:	pushr	$bit2+bit3+bit4+bit5	/* save a few scratch registers */
	ashl	$-16,r0,r0	/* get left halfword (count) */
	movc3	r0,(r1),(r13)	/* copy the string to the TP stack */
	clrb	(r3)		/* null terminate it */
	movl	r13,arg1	/* pointer to asciz string */
open1:	movl	$3,argn		/* set up number of args */
	pushl	ap		/* save register */
	moval	argn,ap	/* arg block */
	clrl	arg3
	movl	8(sp),arg2	/* get former r3 off stack */
	 jneq	1f		/* jump if write--this may not work, but isn't */
				/* used anyway */
	chmk	$_open		/* open the file */
	brb	2f
1:	movl	$0x1FF,arg3
	movl	$O_RDWR+O_CREAT,arg2
	chmk	$_open		/* create file */
/* note potential bug of leaving file open when shouldn't if chmod fails */
2:	movl	(sp)+,ap	/* restore linkage register */
	 bcs	1f		/* system call sets carry bit on failure */
	movl	r0,r1		/* return the file descriptor */
	movl	$t.chan,r0	/* type channel */
opnret:	popr	$bit2+bit3+bit4+bit5	/* restore registers bombed by movc3 */
	rsb

1:	movl	r0,r1		/* error code to r1 */
	movl	$t.fix,r0
	clrl	r3
	bsbw	cons
	movl	$t.false,r0	/* return false with reason */
	brb	opnret		/* common return */


/* close - close a channel
* call:
*	r1/ channel
* return:
*	r1/ 0 or false() if failed strangely */

close:	movl	$1,argn		/* count arguemtns to system */
	movl	r1,arg1		/* only arg is channel */
	pushl	ap		/* save register */
	movl	$argn,ap	/* arg block */
	chmk	$_close		/* close the file */
	movl	(sp)+,ap		/* restore linkage */
	 bcs	1f
	movl	r0,r1		/* move returned value */
	movl	$t.fix,r0	/* type fix means win */
	rsb
1:	movl	r0,r1		/* cons up a false */
	movl	$t.fix,r0
	clrl	r3
	bsbw	cons
	movl	$t.false,r0	/* type false loses */
	rsb

/* print - print string on file
* call:
*	r0,r1/ string
*	r3/ char count
*	r5/ channel
* return:
*	r0,r1/ number of bytes written, -1 for error */

print:	movl	$3,argn		/* count args */
	movl	r5,arg1		/* channel to arg block */
	movl	r1,arg2		/* string address */
	movl	r3,arg3		/* count of bytes */
	pushl	ap		/* save register */
	movl	$argn,ap	/* arg block */
	chmk	$_write
	movl	(sp)+,ap		/* restore linkage */
	bcs	prterr
	movl	r0,r1		/* number of bytes written */
	movl	$t.fix,r0	/* ok, return fix */
	rsb
prterr:	movl	r0,r1
	movl	$t.fix,r0
	clrl	r3
	bsbw	cons
	movl	$t.false,r0
	rsb

/* read - read a string
* call:
*	r0,r1/ string
*	r3/ number of characters
*	r5/ channel
* return:
*	r0,r1/ number of bytes read, -1 for error */

read:	movl	$3,argn		/* count of arguments */
	movl	r5,arg1		/* store channel */
	movl	r1,arg2		/* where to read to */
	movl	r3,arg3		/* how much to read */
	pushl	ap		/* save register */
	movl	$argn,ap	/* arg block */
	chmk	$_read
	movl	(sp)+,ap		/* restore linkage */
	movl	r0,r1		/* save count of bytes read */
	movl	$t.fix,r0	/* to return as fix */
	rsb

/* pipe- funny handler, because returns two values.  Call with
   2-element UV in r0,r1, returns false with reason or uv. */

dopipe:	movq	r0,(r13)+
	pushl	ap
	moval	argn,ap
	clrl	argn
	chmk	$_pipe
	movl	(sp)+,ap
	bcs	nopipe
	movl	r0,*-4(r13)
	movl	-(r13),r0
	movl	r1,4(r0)
	movl	r0,r1
	movl	-(r13),r0
	rsb
nopipe:	movl	r0,r1
	movl	$t.fix,r0
	brw	syser

/* syscal -- general MIM interface to system calls in UNIX
* call:	args on tp stack,r1 ==> arg to chmk
*			 r0 ==> # of args
*		return value as a fix
*		       or false with reason
*	pops tp stack
*/
syscal:	movl	sp,r3			/* use stack for args */

	movl	r0,r4			/* catch degenerate case */
	 jleq	1f
2:	pushl	-(r13)			/* pop them from tp onto sp */
	subl2	$4,r13			/* flush type word */
	sobgtr	r0,2b

1:	pushl	r4
	pushl	ap			/* save arg pointer */
	moval	4(sp),ap 
	movl	ap,lstarg
	movl	r1,lstcal		/* save last call for funny stuff */
	cmpl	r1,$_wait		/* is this a wait call? */
	 jneq	2f			/* no, all's well */
	cmpl	r4,$1
	 jgtr	syswait			/* alas! */
2:	chmk	r1			/* execute sys call */
syser1:	movl	(sp)+,ap		/* restore arg pointer */
	movl	r3,sp			/* and pop stack */
	movl	r0,r1			/* return value */
	movl	$t.fix,r0
	 bcs	syser			/* was there really an error */
	rsb
syswait:
	movl	8(ap),r0
	movl	12(ap),r1
	bispsw	$0xf			/* this whole thing really sucks */
	chmk	$_wait			/* do it */
	jcs	syser1			/* lost */
	tstl	4(ap)
	 jeql	syser1
	movl	r1,*4(ap)		/* store status */
	brw	syser1	

syser:	clrl	r3
	bsbw	cons			/* cons it up */
	movl	$t.false,r0
	rsb

rntime:	pushl	ap
	movl	$2,argn
	moval	argn,ap
	moval	ruse,arg2
	clrl	arg1
	chmk	$_getrusage
	addl3	utime,stime,r0	/* number of seconds */
	addl3	utime+4,stime+4,r1	/* microseconds */
	cvtlf	r0,r0
	cvtlf	r1,r1
	divf2	$603998836,r1	/* F floating 1000000 */
	addf2	r0,r1
	movl	$t.float,r0
	movl	(sp)+,ap
	rsb	

/* interrupt interface to UNIX
   this routine is called by system when an interrupt occurs */

/* WARNING:  The following code contains violence and adult situations.
   Parental discretion is advised. */

.align	2				/* align start of int routine */

hndlr:	.word	0			/* register mask? */
	pushl	r0
	clrl	interr
	ashl	4(ap),$1,r0
	cmpl	4(ap),$sig_ttou
	 jeql	hndttou			/* do some funny stuff */
	mcoml	$1,interr		/* --> return error */
	movl	$EINTR,intval		/* with this error code */
	cmpl	4(ap),$sig_cont
	 jneq	1f
	tstl	icall
	 jeql	hdexit
1:	bisl2	r0,intflg
	tstl	runint
	 beql	2f			/* interruptable? */
	brw	3f
2:	cmpl	4(ap),$sig_int		/* was this ctrl-G? */
	 jneq	hdexit			/* no, nothing special */
	tstl	ingc			/* are we in a GC? */
	 jneq	hdcggc			/* yes */
	aoblss	$3,cgct,hdexit		/* not in GC, see if panic stop */
	movl	12(ap),r0		/* pick up sigcontext */
	movl	12(r0),intgpc		/* save return pc */
	moval	panic1,12(r0)		/* return to our code */
	movl	4(r0),intmsk
	moval	panic1,16(r13)		/* really return to our code */
	brw	hdexit
hdcggc:	tstl	cgnois
	 jneq	hdexit			/* already gave message */
	incl	cgnois			/* say we gave a message */
	pushr	$bit0+bit1+bit2+bit3+bit4+bit5
	moval	cgmsg1,r1
	movl	cgmsgl,r3
	clrl	r5
	bsbw	print
	popr	$bit0+bit1+bit2+bit3+bit4+bit5
hdexit:	movl	(sp)+,r0
  	ret
/* handle a panic stop--pc to return to is in intgpc */
/* get here by changing return PC in handler */
panic1:	moval	panic2,16(r13)		/* just get to next section */
	ret
panic2:	movl	$1,argn
	movl	intmsk,arg1
	pushl	ap
	moval	argn,ap
	chmk	$_sigsetmask		/* change the mask */
	movl	(sp)+,ap
	addl2	$16,sp
	moval	panic3,(sp)		/* return to final place */
	rei
panic3:	pushl	intgpc			/* save real return pc */
	cmpl	intgpc,$savstrt
	 jleq	panic4
	brw	lckint			/* and go cause an interrupt */
panic4:	brw	kerint			/* interrupted from kernel */

3:	pushr	$bit1+bit2+bit3
	movl	12(ap),r1		/* pick up sigcontext */
	movl	12(r1),r2		/* pick up PC */
	cmpb	(r2)+,$_chmk		/* is it a chmk? */
	 beql	intint
	brw	noskip			/* not a chmk */
intint:	movzbl	(r2)+,r3		/* pick up address byte */
					/* can be register, literal, immediate */
	cmpb	$0x8F,r3		/* immediate? */
	 jneq	4f
	movzwl	(r2)+,r3		/* pick up the frob */
	brb	6f
4:	cmpb	$0x40,r3		/* literal? */
	 jgtr	6f			/* yes, have value */
	bicl2	$0xF0,r3		/* isolate register number */
	 jeql	intfoo			/* R0 not on stack */
	cmpl	r3,$3
	 jleq	5f			/* not on stack */
intfoo:	ashl	r3,$1,r3		/* generate mask */
	pushr	r3			/* chomp */
	movl	(sp)+,r3		/* now have right AC in ac3 */
	brb	6f
5:	decl	r3
	movl	(sp)[r3],r3		/* pick up ac off stack */
6:	pushl	r4
	movl	intcml,r4
ckloop: decl	r4
	 jlss	9f
	cmpl	r3,intcmk[r4]
	 jeql	7f
	brb	ckloop
9:	movl	(sp)+,r4
noskip:	popr	$bit1+bit2+bit3		/* no, tough luck */
	movl	(sp)+,r0
	ret
7:	movl	(sp)+,r4
	movl	r2,12(r1)		/* update PC */
	movl	r2,(r13)+
	popr	$bit1+bit2+bit3
	addl2	$4,sp
	movl	-(r13),intpcs		/* pass new PC back down */
	movl	12(ap),r1
	movl	4(r1),intmsk		/* pass old mask back down */
	moval	intr1,16(r13)		/* return to our code */
	ret

intr1:	moval	intr2,16(r13)		/* again */
	ret

intr2:	movl	$1,argn
	movl	intmsk,arg1		/* restore old mask */
	pushl	ap
	moval	argn,ap
	chmk	$_sigsetmask
	movl	(sp)+,ap
	movl	intval,r0		/* return error code */
	addl2	$16,sp			/* clear crap off sp */
	movl	intpcs,(sp)		/* update PC */
	tstl	interr
	 jgtr	1f			/* only set error flag if interr -1 */
	bispsw	$1
	bisl2	$1,4(sp)
1:	rei				/* and done */

/* special code to handle sigttou, allowing writes to slip through,
   but ignoring everything else */
hndttou:
	mcoml	$1,interr
	movl	$EINTR,intval
	cmpl	lstcal,$_write		/* were we trying a write? */
	 jneq	3b			/* no, just interrupt out of call */
	pushl	ap
	movl	lstarg,ap
	chmk	$_write			/* should work this time */
	movl	r0,intval
	 jcs	1f
	movl	$1,interr		/* say no error on write */
1:	movl	(sp)+,ap
	brw	3b			/* now fall into skip code */

.set	itmsl, 0			/* length of message */
.set	itmsg, 4			/* pointer to message */
.set	itfat, 8			/* 1 if error is fatal */
.set	itesiz, 12
inttbl:	.long	0
	.long	0
	.long	0
	.long	intmsl
	.long	intmsg
	.long	0
	.long	qutmsl
	.long	qutmsg
	.long	0
	.long	ilomsl
	.long	ilomsg
	.long	1
	.space	itesiz	/* trace trap */
	.space	itesiz	/* IOT */
	.space	itesiz	/* EMT */
	.long	fpemsl
	.long	fpemsg
	.long	1
	.space	itesiz	/* kill */
	.long	busmsl
	.long	busmsg
	.long	1
	.long	segmsl
	.long	segmsg
	.long	1
	.long	sysmsl
	.long	sysmsg
	.long	1
	.space	itesiz	/* pipe */
	.space	itesiz	/* alarm clock */
	.space	itesiz	/* stop */
	.space	itesiz	/* tstop */
	.space	itesiz	/* continue */
	.space	itesiz	/* child */
	.space	itesiz	/* ttin */
	.space	itesiz	/* ttout */
	.space	itesiz	/* io possible */
	.long	cpumsl
	.long	cpumsg
	.long	1
	.long	fszmsl
	.long	fszmsg
	.long	1
	.space	itesiz	/* vtalarm */
	.space	itesiz	/* profiling timer alarm */

.align	2
hndseg:	.word	bit0+bit1+bit2+bit3+bit4+bit5
	pushl	ap
hndsg1:	movl	12(r13),r0
	cmpl	12(r0),8(r0)		/* want bigger of fr and tp */
	 jgtr	1f
	movl	8(r0),r0
	brb	2f
1:	movl	12(r0),r0
2:	subl3	r0,tptop,r0		/* how close are we to blowing stack? */
	cmpl	r0,$16
	 jgtr	hsreal			/* not close enough...*/
	cmpl	tptop,tpmax
	 jgeq	stkflt			/* sorry, stack's gonzo */
	addl3	$tp_buf,tptop,r1
	subl3	r1,tpmax,r3		/* max we can grow, allowing for buffer */
	cmpl	r3,$tp_buf
	 jgtr	1f			/* all OK */
	movl	$1,stkok		/* stack is at limit, basically */
	movl	tpmax,r2		/* so get a buffer, and ...*/
	movl	$1,r3			/* cause interrupt */
grostk:	movl	$1,argn			/* r2 has new tptop, r3 is non-zero */
	movl	r2,arg1			/* if interrupt should occur */
	moval	argn,ap
	chmk	$_break
	 jcs	stkflt			/* growth failed */
	movl	(sp)+,ap
	movl	r2,tptop
	tstl	r3
	 jeql	grosto			/* all done */
	tstl	icall
	 jeql	grosto			/* can't interrupt if no handler */
	ashl	4(ap),$1,r0
	bisl2	r0,intflg		/* cause an interrupt */
grosto:	ret
stkflt:	moval	stklos,r1
	ashl	$16,stklol,r0
	mcoml	$1,r2
	bsbw	rfatal
	brw	hndsg1			/* try again, may work */
/* come here if room to grow stack */
1:	tstl	stkok
	 jneq	2f			/* grow arbitrarily */
	addl3	$tp_buf,tptop,r2	/* get a buffer, and interrupt */
	movl	$1,r3
	brw	grostk
2:	addl3	$tp_buf,tptop,r2	/* grow some */
	clrl	r3			/* silently */
	brw	grostk
hsreal:	movl	$2,argn
	moval	limits,arg2
	movl	$rlimit_stack,arg1
	moval	argn,ap
	chmk	$_getrlimit		/* read stack limit */
	subl3	limits,$0x7fffffff,r3	/* get bottom of stack area */
	movl	$sig_segv,arg1
	moval	hndseg1,sgvec
	clrl	sgvec+4
	clrl	sgvec+8
	moval	sgvec,arg2
	chmk	$_sigvec		/* change segmentation handler */
	movl	(sp)+,ap
	movl	12(sp),r1
	movl	4(r1),arg1
	pushl	ap
	movl	$1,argn
	moval	argn,ap
	chmk	$_sigsetmask		/* re-enable segmentation int */
	movl	(sp)+,ap
	clrl	segerr
	movl	(r3),(r3)		/* try writing the location */
	pushl	ap
	movl	$sig_segv,arg1
	moval	hndseg,sgvec
	clrl	sgvec+4
	clrl	sgvec+8
	moval	sgvec,arg2
	movl	$2,argn
	moval	argn,ap
	chmk	$_sigvec		/* re-install old handler */
	movl	(sp)+,ap
	tstl	segerr
	 jeql	hndrn1			/* other segmentation error */
	bsbw	nomem			/* complain */
	ret				/* and done */

.align	2
hndseg1:
	.word	0
	movl	$1,segerr		/* got error we were looking for */
	movl	12(ap),r1
	addl2	$3,12(r1)		/* skip losing instruction */
	movl	12(r1),intpcs		/* new pc, pass back down */
	moval	hndseg2,16(r13)		/* return to our code */
	ret

hndseg2:
	moval	hndseg3,16(r13)		/* keep returning to our code */
	ret
hndseg3:
	addl2	$16,sp			/* clear stuff off sp */
	movl	intpcs,(sp)		/* new PC */
	rei				/* done */

.align	2
hndrnd:	.word	bit0+bit1+bit2+bit3+bit4+bit5
hndrn1:	subl3	$1,4(ap),r2
	mull2	$itesiz,r2		/* offset in inttbl */
	addl2	$inttbl,r2
	movl	itmsg(r2),r1
	movl	itmsl(r2),r3
	movl	(r3),r3
	clrl	r5
	tstl	itfat(r2)
	 jneq	hndfat			/* fatal error, sometimes */
	bsbw	print			/* print the message */
	mcoml	$1,r1
	bsbw	quit
hnddon:	ret				/* done */
hndfat:	ashl	$16,r3,r0
	tstl	ingc
	 jneq	ifatal			/* fatal in GC */
	tstl	ecall
	 jeql	ifatal			/* fatal if no error atom */
	movl	12(ap),r4		/* pick up sigcontext */
	movl	12(r4),intold		/* PC */
	movl	4(ap),intflt		/* interrupt code */
	moval	hndft1,16(r13)		/* return to our code */
	movl	4(r4),intmsk		/* pass old mask back down */
	ret
ifatal:	bsbw	rfatal
	jmp	comper

hndft1:	moval	hndft2,16(r13)		/* clobber next return address */
	ret				/* and return again */

hndft2:	movl	$1,argn
	movl	intmsk,arg1
	pushl	ap
	moval	argn,ap
	chmk	$_sigsetmask
	movl	(sp)+,ap
	addl2	$16,sp
	moval	hndft3,(sp)		/* return from interrupt to our code */
	rei

hndft3:	bsbw	iframe				/* make a frame */
	movl	$t.word,(r13)+
	movl	intold,(r13)+
	movl	$t.word,(r13)+
	movl	intflt,(r13)+
	movl	$2,r0
	movl	ecall,r1
	bsbw	mcallz			/* call error */
1:	clrl	r1
	bsbw	quit			/* what a chomper */
	brb	1b

.align	2
hndstp:	.word	bit1
	tstl	oldtty
	 beql	1f
	pushl	ap
	mcoml	$1,r1
	bsbw	quit
	movl	(sp)+,ap
1:	ret

/****************************************************************
*								*
*								*
*			Record tables				*
*								*
*								*
****************************************************************/
	
/* first, a few definitions */

	.set	ln.any,0
	.set	ln.atom,10
	.set	ln.frame,12
	.set	ln.gbind,10
	.set	ln.lbind,16

/* atom record table */

/* table format:

  # elements,, type
  type,, length				| one entry for each element
  offset in record,, code for set/get	| in the record
*/


atmtbl:	.word	4, ln.atom, t.gbind, ln.gbind, 0, 11, t.bind, ln.lbind
	.word	2, 11, t.str, ln.any, 5, 8, t.obl, ln.atom, 8, 11
	.word	t.typc, 0, 4, 13

frmtbl:	.word	-8, ln.frame, t.msubr, 4, 0, 10, t.fix, 0, 2, 6, t.fix
	.word	16, 4, 3, t.fix, 0x912, 4, 3, t.frame, 8, 6, 10
	.word	t.fix, 18, 8, 3, t.bind, 0x812, 8, 3, t.fix, 0, 10, 6

bndtbl:	.word	-6, ln.lbind, t.any, ln.any, 0, 12, t.atom, ln.atom
	.word	4, 11, t.any, ln.any, 6, 12, t.bind, ln.bind, 10, 11
	.word	t.bind, ln.bind, 12, 11, t.fix, 0, 14, 6

gbntbl:	.word	3, ln.gbind, t.any, ln.any, 0, 12, t.atom, ln.atom, 4, 11
	.word	t.any, ln.any, 6, 12


/****************************************************************
*								*
*								*
*			Boot loader				*
*								*
*								*
****************************************************************/

.set	gcbase,sysbot-2000
.set	gcs_addr, (((gcbase-byts_page+1)/byts_page)+1)*byts_page
.set	lgcs_addr, gcs_addr-gcsizb
.set	gcs_pg, gcs_addr/byts_page
.set	lgcs_pg, lgcs_addr/byts_page

strlen:	movl	(r8),r1
	 jeql	stlndn
1:	incl	r7
	tstb	(r1)
	 jeql	stlndn
	incl	r1
	brb	1b
stlndn:	rsb

booter:	movl	(sp),r6
	clrl	r7
	moval	4(sp),r8
barglp:	bsbw	strlen			/* add len to r7 */
	addl2	$4,r8			/* advance pointer */
	sobgtr	r6,barglp
	clrl	r9
	addl2	$4,r8			/* move past 0 word */
benvlp:	tstl	(r8)
	 beql	bblt			/* all done */
	bsbw	strlen
	addl2	$4,r8
	acbl	$1024,$1,r9,benvlp	/* loop back */
bblt:	addl2	$4,r9
	addl2	(sp),r9			/* # of words needed for ptrs and 0s */
	ashl	$2,r9,r9		/* --> bytes */
	addl2	$3,r7
	bicl2	$3,r7			/* actual number of bytes for strings */
	addl2	r7,r9			/* total bytes needed */
	subl3	r9,$sysbot,r8		/* new top of stack */
	movc3	r9,(sp),(r8)		/* move everything */
	subl3	sp,r8,r9		/* get pointer update into r9 */
	movl	r8,sp
	moval	4(sp),r7
	movl	(sp),r8
bargup:	tstl	(r7)
	 beql	bargud
	addl2	r9,(r7)
	addl2	$4,r7
	sobgtr	r8,bargup		/* loop for rest of args */
bargud:	addl2	$4,r7
benvup:	tstl	(r7)
	 beql	benvud
	addl2	r9,(r7)
	addl2	$4,r7
	brb	benvup
benvud:	movl	(sp),numarg
	moval	4(sp),argbeg		/* save arg stuff */
	ashl	$2,(sp),r0
	addl2	argbeg,r0
	moval	4(r0),envbeg		/* beginning of environment vector? */
	tstl	(sp)			/* check # args */
	 jneq	newarg			/* some */
	brw	noargs
newarg:	movl	4(sp),r0		/* pick up first arg */
	clrl	r1
	cmpb	(r0),$32		/* file descriptor */
	 bgeq	cloop
	movl	(r0),filnam		/* pick it up */
	subl3	$1,(sp)+,(sp)		/* flush first arg */
	brw	noargs
cloop:	tstb	(r0)
	 jeql	2f
	incl	r0
	incl	r1
	brb	cloop
2:	pushl	r1			/* length of arg string */
	matchc	mudsnl,mudsnm,(sp),*8(sp)
	 jeql	mudsub
	matchc	muds1l,mudsn1,(sp),*8(sp)
	 jneq	noarg1			/* go to noarg1 when not mudsub */
mudsub:	movl	(sp)+,r1
	cmpl	(sp),$1
	 bleq	noargs			/* no args to mudsub */
	mcoml	$1,noboot
	movl	4(sp),argone
	subl3	$1,(sp)+,(sp)		/* flush first arg */
	movl	(sp),numarg
	moval	4(sp),argbeg
	movl	4(sp),r0
	clrl	r1
9:	tstb	(r0)+
	 jeql	8f
	aobleq	$1024,r1,9b
8:	pushl	r1
	locc	$46,(sp),*8(sp)		/* look for dot in name */
	 jeql	3f			/* not found */
	movl	8(sp),filnam		/* yes, no need to default */
	brw	noarg1
3:	movc3	(sp),*8(sp),savf	/* copy the first part */
	movc3	$5,svname,(r3)		/* copy .save */
	clrb	(r3)			/* make sure asciz */
	moval	savf,filnam		/* save pointer away */
noarg1:	movl	(sp)+,r1
	
					/* initialize assorted things */
noargs:	movl	$lgcs_addr,gcsmin	/* leave 2000 words for system stack */
					/* (empirically, sp is left */
					/* at approximately 0x7fffee2c) */
	clrl	intflg			/* clear the intflg at startup */
	clrl	spsto			/* make sure spsto starts null */
	movl	tpstart,stkbot		/* put it where user code can see it */
	movl	tptop,stkmax
/*	subl3	$02000,sp,gcsmin	*/
	movl	gcsmin,gcstop
	addl3	$gcsizb,gcsmin,gcsmax	/* no limit for now */

/* make max size of stack area infinite */

setstk:	
	movl	$rlimit_data,arg1
	moval	limits,arg2
	movl	$2,argn
	movl	$argn,ap
	chmk	$_getrlimit
	movl	limits+4,tpmax
	movl	$rlimit_stack,arg1
	moval	limits,arg2
	movl	$2,argn			/* 2 args to vlimit */
	movl	$argn,ap
	chmk	$_getrlimit
	movl	limits+4,p1lim
	brw	cnstrt

/* first check to see if save file exists */

cnstrt:	movl	filnam,r1		/* setup args for open */
	cmpl	r1,$100			/* too small to be string pointer? */
	 blss	1f
	pushl	ap
	moval	argn,ap
	movl	$2,argn
	movl	r1,arg1
	clrl	arg2
	chmk	$_open			/* can't call openz 'cause */
	movl	(sp)+,ap		/* don't have memory yet */
	 jcs	nosave
	movl	r0,r1
1:	pushl	ap
	moval	argn,ap
	clrl	arg3
	movl	$3,argn
	clrl	sgvec+4
	clrl	sgvec+8
	moval	sgvec,arg2
	movl	$sig_cont,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec		/* enable continue */
	movl	$sig_ttou,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec
	movl	$sig_int,arg1		/* enable for some fatal interrupts */
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_quit,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_ill,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_fpe,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_bus,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_segv,arg1
	moval	hndseg,sgvec
	chmk	$_sigvec
	movl	$sig_alrm,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec		/* alarm-clock */
	movl	$sig_sys,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_chld,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec		/* inferior interrupts */
	movl	$sig_urg,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec
	movl	$sig_io,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec
	movl	$sig_pipe,arg1
	moval	hndlr,sgvec
	chmk	$_sigvec
	movl	$sig_tstp,arg1
	moval	hndstp,sgvec
	chmk	$_sigvec
	movl	$sig_xcpu,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	movl	$sig_xfsz,arg1
	moval	hndrnd,sgvec
	chmk	$_sigvec
	bsbw	irestor
	clrl	r0			/* no args */
	movl	-(r13),r1
	bsbw	mcall
	bsbw	die

/* here to enable signals */

iatic:	pushl	ap
	pushl	r1
	movl	$sig_int,arg1		/* lets set up signals */
	cmpb	$1,r1			/* is it control-A */
	 jneq	1f
	movl	$sig_quit,arg1
1:	moval	hndlr,sgvec
	clrq	sgvec+4
	movl	$3,argn
	clrl	arg3
	moval	sgvec,arg2
	moval	argn,ap
	chmk	$_sigvec
	 bcs	sigdie
	movl	(sp)+,r1
	movl	(sp)+,ap
	movl	$t.fix,r0
	rsb

sigdie:	movl	$siglos,r1
	movl	lsiglo,r3
	clrl	r5
	bsbw	print
	bsbw	die

/* initialize random variables */

nosave:	tstl	noboot
	 jeql	1f
	moval	nofile,r1
	movl	nofill,r0
	ashl	$16,r0,r0
	bsbw	efatal
1:	pushl	ap
	movl	$2,argn
	movl	$rlimit_stack,arg1
	moval 	limits,arg2
	movl	p1lim,limits
	movl	p1lim,limits+4
	chmk	$_setrlimit	/* get all you can */
	moval	prstart,r1	/* beginning of pure area */
	addl2	$pur_init,r1	/* initial size of pure area */
	movl	r1,tpstart	/* beginning of stack */
	movl	r1,r13		/* stack pointer */
	addl3	$tp_size,r1,tptop	/* top of stack before buffer */
	pushl	ap
	movl	$1,argn
	movl	tptop,arg1
	moval	argn,ap
	chmk	$_break			/* get space for stack */
	movl	(sp)+,ap
	movl	$boomsg,r1
	movl	lbooms,r3
	clrl	r5
	bsbw	print
	movl	$boobuf,r1
	movl	$4,r3
	clrl	r5
	clrl	boobuf
	bsbw	read
	movzbl	boobuf,r1
	cmpb	r1,$'-
	 jeql	bmone
	cmpb	r1,$'0
	 jneq	bone
	clrl	bootyp
	jmp	doboot
bmone:	mcoml	$0,bootyp
	jmp	doboot
bone:	movl	$1,bootyp
doboot:	clrl	mdepth			/* no nesting yet on mcalls */
	clrl	mtrace			/* non-zero means trace mcalls */

/*	** initialize page table **	*/

	movl	$0x40000000/byts_page,p0tbl	/* all of p0 space for now */
	clrl	p0tbl+4		/* starts at 0 */
	mcoml	$0,p0tbl+8		/* neg val means unusable */
	movl	$(lgcs_addr-0x40000000)/byts_page,p1tbl  /* most of p1 */
	movl	$0x40000000/byts_page,p1tbl+4
	clrl	p1tbl+8
	movl	$(gcs_pg-lgcs_pg),gctbl
	movl	$lgcs_pg,gctbl+4
	movl	$1,gctbl+8		/* zone 1 has gc space */
	movl	$(0x7fffffff-gcs_addr)/byts_page,stktbl
	movl	$gcs_addr/byts_page,stktbl+4
        mcoml	$0,stktbl+8
	clrl	endtbl
			
/* initialize record table */

	movl	$t.frame,r0
	movl	$frmtbl,r1
	bsbw	brectb
	movl	$t.bind,r0
	movl	$bndtbl,r1
	bsbw	brectb
	movl	$t.atom,r0
	movl	$atmtbl,r1
	bsbw	brectb
	movl	$t.obl,r0
	movl	$atmtbl,r1
	bsbw	brectb
	movl	$t.gbind,r0
	movl	$gbntbl,r1
	bsbw	brectb
	movl	$t.lval,r0
	movl	$atmtbl,r1
	bsbw	brectb
	movl	$t.gval,r0
	movl	$atmtbl,r1
	bsbw	brectb
	movl	$t.link,r0
	movl	$atmtbl,r1
	bsbw	brectb

/* build atom hash table */

	movl	$lhsize,r0		/* allocate space */
	bsbw	iblock			/* for hash table */
	movl	r6,topobl+4		/* store in known place */
	movl	$hsize<16+t.vec,topobl	/* > size and type of table */
	movl	$lhsize<16+t.vec+dope,hsize*8(r6) /* dope vector for tobl */

/* make each bucket be a list */

	movl	$hsize,r0		/* number of buckets */
	movl	$t.list,r1		/* list type */
1:	movl	r1,(r6)			/* load type word */
	addl2	$8,r6			/* step through hash table */
	sobgtr	r0,1b			/* loop until done */

/* open a channel to boot file */

	clrl	bsendf			/* not eof */
	movl	lbootf-2,r0		/* setup length */
	movl	$bootf,r1		/* address of name */
	clrl	r3			/* mode 0 is read only */
	bsbw	open			/* open the file */
	cmpl	r0,$t.false		/* failed? */
	 jneq	1f
godie:	  bsbw	die
1:	movl	r1,bschan		/* save boot channel */
	movl	$dum4,r11		/* point to dummy msubr vect */

bloop:	bsbw	bsread			/* read an object */
	tstb	bsendf			/* EOF? */
	 jeql	bloop			/* no, keep trying */

	movl	bschan,r1		/* arg for close */
	bsbw	close			/* close the channel */

	movl	$s.boot,r6		/* get address of BOOT atom name */
	bsbw	bslkp			/* search */
	tstl	r0			/* found boot atom? */
	 jeql	godie			/* nope */

/* enter MDL environment (after all, that's what a bootstrap does) */

	pushl	r6			/* save boot atom pointer */
	bsbw	iframe			/* make a frame */
	movl	r13,r12			/* setup frame pointer */
	movl	$dummy,fr.msa(r12)	/* bs dummy frame */
	bsbw	iframe			/* another frame */

/* proclaim winnage */

	movl	$ldmsg,r1		/* message address */
	movl	lldmsg,r3		/* it's length */
	clrl	r5			/* this means tty */
	bsbw	print			/* print it */

	movl	(sp)+,r1		/* get back boot atom */
	movl	$1,r0			/* No arguments */
	movl	$dum4,r11		/* setup a dummy msubr */
	movl	$t.fix,(r13)+
	movl	bootyp,(r13)+
	bsbw	mcall			/* do the call */

/* should return pointer to routine to call in r1 */

	movl	r1,(r13)+		/* save pointer to routine */

/* before actually calling it, lets try to save this crud */

	movl	filnam,r1		/* pointer to name */
	movl	$1,r3			/* open for output */
	bsbw	openz			/* try to open file */
	cmpw	r0,$t.false		/* failure? */
	 jneq	1f			/* no, try to write */

	movl	$savlos,r1		/* say save loss */
	movl	lsavlos,r3
	clrl	r5
	bsbw	print
	bsbw	die			/* die in this case */

1:	clrl	r0			/* Nothing fancy on return PC */
	clrl	r2			/* no extra zones yet */
	clrl	r3
	bsbw	dosave

/* now get back routine to call etc */

	movl	-(r13),r1		/* and get back pointer to routine */
	clrl	r0
	bsbw	mcall			/* try to call it (ha ha ha) */
	bsbw	die			/* not yet implemented */
	

/* utility subroutines for booting */

/* brectb - add record table
* call:
*	r0/ type
*	r1/ record table address	*/

brectb:	ashl	$-6,r0,r0	/* isolate type */
	bicl2	$0xFFFFFFC0,r0	/* 6 bits */
	ashl	$3,r0,r0	/* make table index */
	movl	r1,rectbl+4(r0)	/* store address */
	movl	$t.fix,rectbl(r0) /* legal type */
	rsb

/* bin - read a byte 
* call:
*	bsbw	bin
* return:
*	r0/ byte read
*	bsendf/ -1 if EOF read	*/

bin:	movl	$3,argn		/* setup for call */
	movl	bschan,arg1	/* boot channel */
	movl	$bsinch,arg2	/* where to read to */
	movl	$1,arg3		/* just one byte */
	pushl	ap		/* save linkage */
	movl	$argn,ap	/* setup linkage for sys call */
	chmk	$_read		/* read in */
	movl	(sp)+,ap	/* restore linkage */
	tstl	r0		/* any errors? */
	 jlss	bsioer		/* yes, die */
	 jneq	1f		/* EOF? */
	movb	$0xFF,bsendf	/* yes, flag it */
1:	movl	bsinch,r0	/* store byte read */
	rsb

/* bsread - read an object from boot file
* call:
*	bsbw	bsread
* return:
*	(eof read)	*/

bsread:	tstb	bsendf		/* EOF yet? */
	jeql	1f		/* no, keep reading */
	 rsb			/*  yes, return */
1:	movzbl	bsbrk,r0	/* already a break character? */
	 jneq	2f		/* no */
	bsbw	bin		/* bin a byte */
2:	clrb	bsbrk		/* not a break character, we assume */
	cmpb	r0,$'|		/* vbar? */
	 jeql	bscod		/* read code */
	cmpb	r0,$'#		/* sharp? */
	 jeql	bstyp		/* type */
	cmpb	r0,$'[		/* ] bracket? */
	 jeql	bsvec		/* vector */
	cmpb	r0,$'(		/* ) open paren? */
	 jeql	bslst		/* list */
	cmpb	r0,$'"		/* " dbl-quote? */
	 jeql	bsstr		/* string ( */
	cmpb	r0,$')		/* right paren? */
	 jeql	retunb		/* oops [ */
	cmpb	r0,$']		/* right bracket? */
	 jneq	chexc		/* no, try for excl */
retunb:	movl	r0,r6		/* return bad character */
	movl	$t.unb,r0
	rsb

chexc:	cmpb	r0,$'!		/* excl? */
	 jeql	bschar		/* character */
	bsbw	bssep		/* seperator? */
	 jeql	bsread		/* yes, keep reading */
	cmpb	r0,$'0		/* is it a number? */
	 jlss	bsatm		/* not if less than 0 */
	cmpb	r0,$'9		/* or */
	 jgtr	bsatm		/* greater than 9 */
				/* drop through to read fix */
bsfix:	clrl	r1		/* indicates fix/ float */
	subl3	$'0,r0,r2	/* accumulate in r2 */
	clrl	r4		/* no fractional part yet */
	movl	$1,r4		/* number of digits read */
bsfixl:	bsbw	bin		/* read next byte */
	bsbw	bssep		/* seperator? */
	jeql	bsfixe		/* yes, tie it off */
	tstl	r1		/* reading fraction? */
	jneq	bsfix2		/* yes, go read it */
	cmpb	r0,$'.		/* is it a dot? */
	 jneq	1f		/* no, add to fix */
	  movl	$1,r1		/*  start fractoin */
	  brb	bsfixl		/*  and continue */
1:	mull2	$10,r2		/* multiply sum */
	subl2	$'0,r0		/* make numeric */
	addl2	r0,r2		/* accumulate */
	brb	bsfixl		/* and continue */

bsfix2:	mull2	$10,r3		/* multiply fraction */
	subl2	$'0,r0		/* accumulate */
	addl2	r0,r3
	mull2	$10,r1		/* and step fractional mantissa */
	brb	bsfixl		/* and continue */

bsfixe:	movb	r0,bsbrk	/* remember terminating byte */
	tstl	r1		/* are we floating? */
	 jneq	bsflt		/*  yes */
	movl	r2,r6		/* no, fix value here */
	movl	$t.fix,r0	/* type */
	rsb

bsflt:	bsbw	die		/* haven't decided this yet... */

	movl	$t.float,r0	/* but eventually, */
	rsb			/* return a float */

/* here to read # format type */

	.set	pnam, 8

bstyp:	bsbw	bsread		/* recurse to read atom */
	movl	pnam+4(r6),r7	/* pname **** depends on format ***** */
	movl	(r7),r0		/* get first 4 characters */
	movl	$t.msubr,r1	/* guess at msubr */
	cmpl	r0,s.msub	/* right? */
	 jeql	1f		/* yes */
	movl	$t.imsub,r1
	cmpl	r0,s.imsub
	 jeql	1f
	movl	$t.decl,r1
	cmpl	r0,s.decl
	 jeql	1f
	movl	$t.unb,r1
	cmpl	r0,s.unbo
	 jeql	1f
	movl	$t.false,r1
	cmpl	r0,s.fals
	 jeql	1f
	bsbw	die		/* none of the above, we lose */
1:	movw	r1,-(sp)	/* push type */
	bsbw	bsread		/* read next item */
	movw	(sp)+,r0	/* restore type */
	cmpw	$t.msubr,r0	/* is it msubr? */
	 jeql	bsty_sg		/* yes, do SETG */
	cmpw	$t.imsub,r0	/* or imsubr */
	 jeql	bsty_sg		/* ditto */
	rsb

	.set	msb.name, 12
	.set	gb.atm, 0

bsty_sg: movl	msb.name(r6),r8	/* r8 is the atom now */
	movl	gb.atm(r8),r8	/* gbind now */
	movl	r0,ot(r8)	/* save type */
	movl	r6,ov(r8)	/* and value */
	rsb

/* here to read a character */

bschar:	bsbw	bin		/* read the backslash */
	cmpb	$'/,r0		/* is it? */
	 jneq	die		/* oh no */
	bsbw	bin		/* now read char */
	movl	t.char,r0	/* but throw it away? */
	rsb

/* read a string */

bsstr:	clrl	r1		/* r1 will count charcters */
	clrb	r2		/* indicates \ seen */
bsstrl:	bsbw	bin		/* read */
	tstb	r2		/* quoted? */
	 jneq	bsinstr		/* yes, it stays */
	cmpb	r0,$'\		/* is this the quote character? */
	 jneq	1f		/* naw */
	incb	r2		/* yes, flag we saw one */
	brb	bsstrl		/* and read next */
1:	cmpb	r0,$'"		/* " end of string? */
	 jeql	bsmaks		/* yes, make it a real string */
bsinstr: movl	$t.char,(r13)+
	movl	r0,(r13)+	/* push the byte */
	incl	r1		/* count chars */
	clrb	r2		/* not quoted anymore */
	brb	bsstrl		/* and keep reading */

/* here to actually make a string */

bsmaks:	movl	$t.str,r0	/* string type */
	bsbw	ublock		/* make a string */
	movl	r1,r6		/* return pointer where we need it */
	rsb			/* and return */

/* read an atom */

bsatm:	clrl	r1		/* prepare count of characters */
	brb	bsatm1		/* and push first character */

bsatml:	bsbw	bin		/* read next */
	cmpb	r0,$'\		/* quote character? */
	 jneq	1f		/* no */
	 bsbw	bin		/* yes, read next character */
	 bsbw	bsatm1		/* and push it */
1:	bsbw	bssep		/* separator? */
	 jeql	bsatm3		/* yes... */
bsatm1:	movl	$t.char,(r13)+
	movl	r0,(r13)+	/* push chars on TP stack */
	incl	r1		/* and count them */
	brb	bsatml		/* keep reading */

bsatm3:	movb	r0,bsbrk	/* save break character */
	movl	$t.str,r0	/* we want to make a string */
	bsbw	ublock		/* out of the atom name on TP stack */

	pushl	(r1)		/* save word of chars */
	movq	r0,-(sp)	/* save string */
	bsbw	bslkp		/* lookup the atom */
	tstl	r6		/* was there one? */
	 jeql	1f		/* no, add it */
 
	addl2	$12,sp		/* remove string */
	rsb			/* if exists, return it */

/* push gbind, lbind, pname, obl onto TP stack, then call record: */

1:	movl	$t.unb,(r13)+	/* make an unbound gbind */
	clrl	(r13)+
	clrl	(r13)+
	clrl	(r13)+
	clrl	(r13)+
	clrl	(r13)+
	movl	$t.gbind,r0	/* type */
	movl	$3,r1		/* number of elements */
	bsbw	record		/* build a gbind */
	movl	r0,(r13)+	/* push gbind */
	movl	r1,(r13)+	/* rest of gbind (value) */
	movl	$t.fix,(r13)+	/* lbind */
	clrl	(r13)+		/* to stack */
	movq	(sp)+,(r13)+	/* zap it onto tp stack */
	movl	$t.atom,r0
	movl	$3,r1		/* 4 elements */
	bsbw	record		/* build an atom */
	movl	r1,r6		/* return pointer where it belongs */
	movl	bsaptr,r2	/* put in table */
	movl	(sp)+,(r2)+	/* name */
	movl	r6,(r2)+	/* atom */
	movl	r2,bsaptr	/* update table pointer */
	rsb

/* lookup atom in boot table */

bslkp:	movl	(r6),r0		/* name to r0 */
	moval	bsatbl,r7	/* pointer to table */
bslkpl:	movl	(r7),r1		/* get name */
	bneq	1f		/* branch if not done yet */
	 clrl	r6		/* done, return not found */
	 rsb
1:	cmpl	r0,r1		/* is it this one? */
	bneq	2f		/* nope, loop */
	movl	4(r7),r6	/* GOT IT - return atom pointer */
	movl	$t.atom,r0	/* type atom if we care */
	rsb
2:	addl2	$8,r7		/* next entry */
	brb	bslkpl		/* and loop */
	

/* read code */
bsfoo:	brb	bscodl
bscod:	clrl	r1		/* count */
bscodl:	bsbw	bin		/* read a byte */
	cmpb	r0,$'|		/* vbar? */
	 jeql	bscod2		/* yes, end */
	cmpb	r0,$'0		/* is it between 0 */
	 jlss	bsfoo
	 jlss	bscodl		/* and 9? */
	cmpb	r0,$'9		/* maybe... */
	 jleq	bscod1		/* yes, ok */
	cmpb	r0,$'A		/* how abouf A-F? */
	 jlss	die
	cmpb	r0,$'F
	 jgtr	die		/* no, die */
	subl2	$'A-'0-10,r0	/* normalize */
bscod1:	subl2	$'0,r0		/* make it a byte */
	movb	r0,(r13)+	/* push it */
	incl	r1		/* keep counting */
	brb	bscodl		/* and loop */

bscod2:	ashl	$-1,r1,r1	/* number of bytes */
	movl	r1,r0		/* make spare copy */
	movl	r1,r9		/* save another copy */
	addl2	$11,r0		/* to words */
	ashl	$-2,r0,r0	/* round it */
	bsbw	iblock		/* allocate */
	movl	r9,r1		/* restore number of bytes */
	ashl	$14,r1,r0	/* count to left half (lwords) */
	movw	$t.mcode,r0	/* type in right */
	addl3	r6,r1,r7	/* point to dope words */
	movl	r7,r10		/* make a spare copy */
bsclp:	movb	-(r13),r2	/* get a nibble from stack */
	movb	-(r13),r3	/* and another one */
	ashl	$4,r3,r3	/* shift left */
	bisb2	r2,r3		/* two nibbles / byte */
	movb	r3,-(r7)	/* put the code where it belongs */
	sobgtr	r1,bsclp	/* and loop for all bytes */

	addl3	$3,r10,r1	/* round to long word */
	bicb2	$3,r1		/* make long address */
	movl	r1,r7		/* copy */
	addl2	$11,r9		/* round bytes to lword, plus dope */
	ashl	$14,r9,r9	/* shift to left half */
	movw	$dope+t.msubr,r9 /* set type in right half */
	movl	r9,(r7)		/* dope word */
	rsb

/* read a vector */

bsvec:	clrl	r1		/* count of elements */
bsvecl:	pushl	r1		/* save count */
	bsbw	bsread		/* read an element */
	movl	(sp)+,r1		/* restore count */
	cmpw	$t.unb,r0
	 jneq	bsvecx
	cmpw	$'],r6		/* end of vector? */
	 jeql	bsvec2		/* yes */
bsvecx:	movl	r0,(r13)+	/* save type */
	movl	r6,(r13)+	/* and value */
	incl	r1		/* ount elements */
	brb	bsvecl		/* and keep reading */

bsvec2:	movl	$t.vec,r0	/* type to r0 */
	bsbw	ublock		/* build the thing */
	movl	r1,r6		/* return pointer in r6 */
	rsb

/* read a list */

bslst:	clrl	r1		/* count */
bslstl:	pushl	r1		/* save count */
	bsbw	bsread		/* read an element */
	movl	(sp)+,r1		/* restore count */
	cmpw	$t.unb,r0
	 jneq	bslstx		/* ( */
	cmpb	$'),r6		/* end of list? */
	 jeql	bslst2		/* yes, ... */
bslstx:	movl	r0,(r13)+	/* push type */
	movl	r6,(r13)+	/* and value */
	incl	r1		/* count */
	brb	bslstl		/* and looop */

bslst2:	bsbw	blist		/* build a list */
	movl	r1,r6		/* save pointer */
	rsb


/* check if character in r0 is a separator 
* call:
*	r0/ character
* return:
*	Z condition set if separator
*	(preserves all registers)	*/

bssep:	cmpb	r0,$'"		/* quote? */
	 jeql	1f		/* yes */
	cmpb	r0,$')
	 jeql	1f
	cmpb	r0,$']
	 jeql	1f
	cmpb	r0,$040		/* space */
	 jeql	1f
	cmpb	r0,$012		/* lf */
	 jeql	1f
	cmpb	r0,$015		/* cr */
	 jeql	1f
	cmpb	r0,$014		/* ff */
	 jeql	1f
	cmpb	r0,$26		/* ^Z */
	 jeql	2f		/* is eof */
	tstb	r0		/* as is */
	 jeql	2f		/* nul */
	rsb			/* return NEQL (cuz r0 isn't 0) */

2:	movb	$1,bsendf	/* flag eof */
1:	tstb	$0		/* be sure EQL (Z set) */
	rsb

/* death and destruxtion */

/* calngs -- come from mcall to here if thing being mcalled is not an atom

	r0/	# args
	r1/	atom pointer
	r2/	pc where mcall happened (relative)
*/

calngs:	tstl	ncall		/* is there an ncall atom? */
	 jeql	ngsdie		/* no, die */
	
	movl	r13,r3		/* copy TP stack pointer */
	addl2	$8,r13		/* room for atom to call with */
	movl	r0,r4		/* copy arg count */
	jeql	1f

2:	movq	-(r3),8(r3)	/* cute (I think) */
	sobgtr	r4,2b

1:	movl	$ln.atom<16+t.atom,(r3)	/* make it an arg */
	movl	r1,4(r3)
	incl	r0		/* one more arg */
	movl	ncall,r1
	brw	mcallx		/* now do MCALL again*/
	
/* iacall -- here to apply aribtrary thing from user code 

	r0,r1/	thing to apply
	r3/	# of args
*/

iacall:	cmpw	r0,$t.msubr
	 jneq	iacal1		/* not calling an msubr */
	subl3	(sp)+,im.code+ov(r11),r2	/* relative return pc */
	movl	r1,r4		/* msubr into r4 */
	movl	r3,r0		/* number of args to r0 */
	jmp	icret		/* go for it */
iacal1:	tstl	ncall
	 jeql	ngsdie
	movl	r13,r5
	addl2	$8,r13		/* room on tp stack */
	movl	r3,r4		/* copy count */
	jeql	1f

2:	movq	-(r5),8(r5)
	sobgtr	r3,2b

1:	movq	r0,(r5)
	movl	ncall,r1
	addl3	$1,r4,r0
	brw	mcall

discom:	movl	$dismsg,r1	/* message */
	movl	ldisms,r3	/* length */
	brw	msgdie

ugverr:	subl3	(sp),im.code+ov(r11),(sp)	/* relative return pc */
	movl	ecall,r1
	 jneq	1f
noeicc:	movl	$commsg,r1
	movl	lcomms,r3
	brw	msgdie
1:	bsbw	iframe		/* make frame */
	movl	$1,r0		/* one argument */
	movl	4(sp),r2
	cmpw	-4(r2),$t.atom	/* did we get atom instead of gbind? */
	 jneq	2f
	movl	$(a.len<17+t.gval),(r13)+
	movl	(r2),(r13)+
	brb	3f 
2:	movq	-4(r2),(r13)+	/* push it */
3:	bsbw	mcallz
	subl3	(sp)+,im.code+ov(r11),(sp)	/* flush argument */
	rsb			/* return */

cmperr:
comper:	movl	ecall,r1	/* does error atom exist... */
	 jneq	1f
	movl	$commsg,r1	/* get message */
	movl	lcomms,r3	/* length */
	brb	msgdie		/* say it and die */

1:	tstl	ingc
	 jeql	2f
	moval	gcerr,r1	/* don't call error in GC */
	movl	lgcerr,r3
	brb	msgdie
2:  	bsbw	iframe		/* create frame for call to error */
	clrl	r0		/* no args to error in compiled code */
	brw	mcall

unimpl:	movl	$unimsg,r1
	movl	lunims,r3
	brb	msgdie

bsioer:	movl	$biomsg,r1
	movl	lbioms,r3
	bsbw	die

illdis:	movl	$illmsg,r1	/* illegal dispatch address specified */
	movl	lillms,r3
	brb	msgdie

ngsdie:	movl	$ngsmsg,r1
	movl	lngsms,r3
	brb	msgdie

die:	movl	$diemsg,r1
	movl	ldiems,r3
	brb	msgdie

msgdie:	clrl	r5		/* clear channel means tty */
	bsbw	print		/* print message */
jstdie:	mcoml	$1,r1
	bsbw	quit
	jmp	comper

/* storage */
	.data

/* fun things */

spaces:	.ascii	"    "			/* 4 spaces */
lesst:	.ascii	"<"
gtrt:	.ascii	">"
crlf:	.byte	015			/* CR */
	.byte	012			/* LF */

ldmsg:	.ascii "MimiVAX loaded
"
lldmsg:	.long	lldmsg-ldmsg

bootf:	.ascii "boot.msubr"
lbootf: .long	lbootf-bootf

intmsg:	.ascii	"Interrupt character typed"
intmsl:	.long	intmsl-intmsg
qutmsg:	.ascii	"Quit character typed"
qutmsl:	.long	qutmsl-qutmsg
ilomsg:	.ascii	"Illegal instruction"
ilomsl:	.long	ilomsl-ilomsg
fpemsg:	.ascii	"Floating point exception"
fpemsl:	.long	fpemsl-fpemsg
busmsg:	.ascii	"Bus error"
busmsl:	.long	busmsl-busmsg
segmsg:	.ascii	"Segmentation error"
segmsl:	.long	segmsl-segmsg
sysmsg:	.ascii	"Bad arg to system call"
sysmsl:	.long	sysmsl-sysmsg

cpumsg:	.ascii	"CPU time limit exceeded"
cpumsl:	.long	cpumsl-cpumsg
fszmsg:	.ascii	"File size limit exceeded"
fszmsl:	.long	fszmsl-fszmsg

fatmsg:	.ascii 	"Fatal error -- "
fatmsl:	.long	fatmsl-fatmsg

dismsg:	.ascii "Dispatch compiler error"
ldisms:	.long	ldisms-dismsg

commsg:	.ascii "Comper death"
lcomms:	.long	lcomms-commsg

gcerr:	.ascii	"Error in GC"
lgcerr:	.long	lgcerr-gcerr

cgmsg1:	.ascii	"GC running--please wait..."
cgmsgl:	.long	cgmsgl-cgmsg1

cgmsg2:	.ascii	"GC done.
"
cgms2l:	.long	cgms2l-cgmsg2

biomsg:	.ascii	"IO error reading bootstrap"
lbioms:	.long	lbioms-biomsg

illmsg:	.ascii "Illegal dispatch entry encountered"
lillms:	.long	lillms-illmsg

siglos:	.ascii	"Error from signal set"
lsiglo:	.long	lsiglo-siglos

intlos:	.ascii	"No interrupt handler yet"
lintlos:	.long	lintlos-intlos

diemsg:	.ascii "Die death"
ldiems:	.long	ldiems-diemsg

ngsmsg:	.ascii "Calngs death"
lngsms:	.long	lngsms-ngsmsg

unimsg:	.ascii "Unimplemented death"
lunims:	.long	lunims-unimsg

boomsg:	.ascii "How to boot (1 big, 0 mbins, -1 msubrs):  "
lbooms:	.long	lbooms-boomsg

mudsnm:	.ascii	"mudsub"
mudsnl:	.long	6
mudsn1:	.ascii	"MUDSUB"
muds1l:	.long	6
period:	.ascii	"."
svname:	.ascii	".save"

newker:	.ascii	"Loading kernel to match save file version
"
newkln:	.long	newkln-newker
savver:	.ascii	"Save file uses wrong kernel version"
savvel:	.long	savvel-savver

nofile:	.ascii	"Save file not found"
nofill:	.long	nofill-nofile

/* chmks that can be interrupted out of */
intcmk:	.long	_wait
	.long	_sigpause
	.long	_read
	.long	_readv
	.long	_write
	.long	_writev
	.long	_ioctl
	.long	_connect
	.long	_select
	.long	_send
	.long	_recv
	.long	_recvmsg
	.long	_sendmsg
	.long	_sendto
	.long	_recvfrom
intcml:	.long	(intcml-intcmk)/4

/* interrupts that muddle knows how to handle */
intb1:	.byte	sig_int
	.byte	sig_chld
	.byte	sig_quit
	.byte	sig_cont
	.byte	sig_pipe
	.byte	sig_urg
	.byte	sig_io
	.byte	sig_segv	/* only set when we get a stack overflow */
intlen:	.long	intlen-intb1

/* translation of interrupt for muddle system (reverse order of previous
   table) */
intb2:	.byte	0	/* never used */
	.byte	31
	.byte	32
	.byte	33
	.byte	34
	.byte	35
	.byte	1
	.byte	19
	.byte	7

kernam:	.ascii	"/usr/mim/xmdl."
verptr:	.space	10		/* will be clobbered at appropriate time */
homstr:	.ascii	"/USR"
hextr:	.byte	0
	.set	homlen, 4
	.space	15
savf:	.ascii	"mim.saved"
extr:	.byte	0		/* null-termminated */
	.set	savlen, extr-savf
	.space	40-savlen
filnam:	.long	savf		/* pointer to save file name */
noboot:	.long	0		/* set if running as mudsub */

stklos:	.ascii	"Stack overflow"
stklol:	.long	stklol-stklos

restlos:
	.ascii	"Ran out of virtual pages"
restlol:	.long	restlol-restlos

savlos:	.ascii	"Save failed"
lsavlos:	.long	lsavlos-savlos

/* boot string definitions */

s.msub:	.ascii "MSUB"
s.imsub: .ascii "IMSU"
s.decl:	.ascii "DECL"
s.unbo:	.ascii "UNBO"
s.fals: .ascii "FALS"
s.boot: .ascii "BOOT"

bootyp:	.long	0		/* flag for boot */

boobuf:	.long	0

interr:	.long	0
intval:	.long	0
lstcal:	.long	0
lstarg:	.long	0

segerr:	.long	0

argn:	.long	0		/* sys call interface block */
arg1:	.long	1
arg2:	.long	1
arg3:	.long	1

intflt:	.long	0
intold:	.long	0
intpcs:	.long	0
intgpc:	.long	0		/* saved pc for use by control-G code */
intmsk:	.long	0

ruse:
utime:	.long	0		/* block for rntime call */
	.long	0
stime:	.long	0
	.long	0
	.space	56

bschan:	.long	0		/* bootstrap channel */
bsbrk:	.long	0		/* break character to reread for boot */
bsendf:	.long	0		/* bs eof flag */
bsinch:	.long	0		/* character input buffer for boot */

dummy:	.long	0		/* dummy initial frame */
	.long	dum2
	.space	6
dum2:	.long	dum3
dum3:	.long	0
	.long	dum4
dum4:	.long	0
	.long	0

	.set	bsatlnt, 400
bsatbl:	.space	4*bsatlnt
bsaptr:	.long	bsatbl

oldtty:	.space	7*4
newtty:	.space	7*4

argone:	.long	0
numarg:	.long	0
argbeg:	.long	0
envbeg:	.long	0

p1cur:	.long	0
p1lim:	.long	0

stkok:	.long	0			/* set if user has OK'ed growing stack */

cgnois:	.long	0			/* set if ctrl-G during GC */
cgct:	.long	0			/* use to force error when in tight loop */

savstrt: .ascii	"MIMS"			/* used to check save file */
versav:	.long	0
	.set	pagtlen, 256
pagptr:	.word	t.uvec
	.word	pagtlen
pagpt1:	.long	pagtbl			/* address of page table */
pagtbl:					/* 256 longwords */	
p0tbl:	.long	0
	.long	0
	.long	0
p1tbl:	.long	0
	.long	0
	.long	0
gctbl:	.long	0
	.long	0
	.long	0
stktbl:	.long	0
	.long	0
	.long	0
endtbl:	.long	0
	.space	(4*256)-52

minf:	.long	minfv			/* pointer to minf vector */
minfv:	.long	2		/* input stream */
	.long	1		/* output stream */
	.long	32		/* bits/ word */
	.long	8		/* bits/ byte */
	.long	wds_page	/* words/ page */
	.long	4		/* bytes/ word */
	.long	2		/* shift for byte --> word */
	.long	4		/* bytes (not chars)/word */
	.long	4294934527	/* largest possible float */
	.long	4294967295	/* smallest */
minfve:	.set	lminf, minfve-minfv	/* set length of minf vector */
rectbl:	.space	256*2*4		/* 256 types, 2 words each */

type_count: .long t.fretyp	/* free type for user-defined */

ecall:	.long	0
ncall:	.long	0
icall:	.long	0		/* why isn't this defined in MIMIAP? */
uwatm:	.long	0		/* points to unwinder atom */
topobl:	.long	0		/* will be loaded as type vector */
	.long	0		/* will be address of top oblist */
framid:	.long	0		/* global unique frame id */
tbindt:	.long	0		/* type word of top-lev binding chain */
tbind:	.long	0		/* top-level binding chain */
sspsto:	.long	0
sbindid:	.long	0	/* copy of bindid over save/restore */
mtrace:	.long	0		/* non-zero to trace mcalls */
mdepth:	.long	0		/* current depth of mcall trace */
ingc:	.long	0		/* flag saying whether we are in GC */
mapper:	.long	0		/* points to pure-map atom */
runint:	.long	0		/* if non-zero, run interrupts immediately */

sgvec:	.long	0
	.long	0
	.long	0

limits:	.long	0
	.long	0
/* GC storage and definitions */

gcparx:	
rcl:	
gcpar:	.long	0
	.set	rcloff, 0	/* offset from gcparx */
rclvb:	.long	0
	.set	rclvoff, 4	/* offset from gcparx */
rclv1:	.long	0		/* recycle lists for various size blocks */
rclv2:	.long	0
rclv3:	.long	0
rclv4:	.long	0
rclv5:	.long	0
rclv6:	.long	0
rclv7:	.long	0
rclv8:	.long	0
rclv9:	.long	0
rclv10:	.long	0
	.set	max_rcl, 10
gcstop:	.long	0
	.set	gcstopo, gcstop-gcparx
gcsmin:	.long	0
	.set	gcsmino, gcsmin-gcparx
gcsmax:	.long	0
	.set	gcsmaxo, gcsmax-gcparx
	.set	gclnt, ((gcsmaxo+1)/4)+1
czone:	.long	0		/* current zone for GC */

stktop:	.long	0		/* save the top of the stack for save */
tpstart: .long	0		/* pointer to beginning of tp stack */
tptop:	.long	0		/* top of tp stack */
tpmax:	.long	0		/* largest size for data space */
savend:	.long	0
codend:	.align	2		/* this is where MDL stack starts */
				/* put it on a longword boundary */
prstart: .long	0
