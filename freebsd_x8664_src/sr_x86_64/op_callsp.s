#################################################################
#								#
#	Copyright 2007 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#	PAGE	,132
	.title	op_callsp.s

#	.386
#	.MODEL	FLAT, C

.include "linkage.si"
	.INCLUDE	"g_msf.si"

	.sbttl	op_callsp
#	PAGE	+
	.DATA
.extern	dollar_truth
.extern	frame_pointer

	.text
.extern	exfun_frame
.extern	push_tval

	.sbttl	op_callspb
# PUBLIC	op_callspb
ENTRY op_callspl
ENTRY op_callspw
ENTRY op_callspb
	movq	frame_pointer(REG_IP),REG64_SCRATCH1
	movq	(REG_SP),REG64_ACCUM                        # Return address
	movq	REG64_ACCUM,msf_mpc_off(REG64_SCRATCH1)
	addq	REG64_ARG0,msf_mpc_off(REG64_SCRATCH1)
	call	exfun_frame
	movl	dollar_truth(REG_IP),REG32_ARG0
	call	push_tval
	movq	frame_pointer(REG_IP),REG64_SCRATCH1
	movq	msf_temps_ptr_off(REG64_SCRATCH1),REG_FRAME_TMP_PTR
	ret
# op_callspb ENDP
