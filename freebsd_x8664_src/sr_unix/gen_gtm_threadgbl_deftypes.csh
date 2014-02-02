#################################################################
#                                                               #
#       Copyright 2010, 2011 Fidelity Information Services, Inc #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

#
# Generate gtm_threadgbl_deftypes.h from gtm_threadgbl_deftypes.c. The result is a list of
# #defines for the (real) types of the neutral-typed vars in the gtm_threadgbl structure. The
# vars are neutral so not all types have to be defined in all modules. This mechanism allows
# us to type only the vars used in the module.
#

#
# We need to build this table twice - once for pro and once for dbg because the elements in the
# table could be different sizes. So setup the necessary #ifdefs so the proper set is selected
# when the module is built. One complication is that gtm_malloc_src.h gets built both as PRO and
# DBG in the same module for a pro build. The DEBUG flag is overridden and the PRO build is
# selected is PRO_BUILD is defined (set by gtm_malloc_dbg.c).
#
# Makefile builds don't have a bunch of stuff
setenv includge ""
if ($#argv > 1) then
	setenv gtm_ver $1
	shift
	setenv gtm_src $gtm_ver/$1
	shift
	setenv gtm_obj $gtm_ver/$1
	shift
	# need -I<include dirs> for this to work correctly
	foreach dir ($*)
		setenv includge "$includge -I${gtm_ver}/${dir}"
	end
	setenv includge "$includge -I${gtm_obj}"
	# aliases are not defined in the TCSH subshell
	source $gtm_ver/sr_unix/gtm_env.csh
endif
echo "Entering gen_gtm_threadgbl_deftypes.csh to build gtm_threadgbl_deftypes.h"
pushd $gtm_obj
\rm gtm_threadgbl_deftypes.h >& /dev/null
if (-e gtm_threadgbl_deftypes.h) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: Unable to delete old $gtm_obj/gtm_threadgbl_deftypes.h - FAIL"
    exit 1
endif
if (! -w $gtm_obj) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: Unable to write to $gtm_obj/gtm_threadgbl_deftypes.h - FAIL"
    exit 1
endif

#
# Now do pro build/run. Override the optimization setting to no-optimize since we don't need to spend time
# optimizing this one time run (takes longer to optimize than to run unoptimized code).
#
gt_cc_pro -O0 $gtm_src/gtm_threadgbl_deftypes.c $includge >& gtm_threadgbl_deftypes_comp.log
if (0 != $status) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: pro build of $gtm_obj/gtm_threadgbl_deftypes failed, see $gtm_obj/gtm_threadgbl_deftypes_comp.log"
    popd
    exit 1
endif
gt_ld -o gtm_threadgbl_deftypes_pro $gt_ld_options_pro -L$gtm_obj $gt_ld_sysrtns $gt_ld_syslibs gtm_threadgbl_deftypes.o >& gtm_threadgbl_deftypes_linkmap.txt
if (0 != $status) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: pro build link of $gtm_obj/gtm_threadgbl_deftypes failed, see $gtm_obj/gtm_threadgbl_deftypes_linkmap.txt"
    popd
    exit 1
endif
#
# Do debug build
#
gt_cc_dbg $gtm_src/gtm_threadgbl_deftypes.c $includge >& gtm_threadgbl_deftypes_comp_dbg.log
if (0 != $status) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: dbg build of $gtm_obj/gtm_threadgbl_deftypes failed, see $gtm_obj/gtm_threadgbl_deftypes_comp_dbg.log"
    popd
    exit 1
endif
gt_ld -o gtm_threadgbl_deftypes_dbg $gt_ld_options_dbg -L$gtm_obj $gt_ld_sysrtns $gt_ld_syslibs gtm_threadgbl_deftypes.o >& gtm_threadgbl_deftypes_linkmap_dbg.txt
if (0 != $status) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: dbg build link of $gtm_obj/gtm_threadgbl_deftypes failed, see $gtm_obj/gtm_threadgbl_deftypes_linkmap_dbg.txt"
    popd
    exit 1
endif
#
# Create gtm_threadgbl_deftypes.h file - create in $gtm_obj first so we don't replace the $gtm_inc version
# until/unless we know it is replaceable.
#
set year = `date +%Y`
set ofile = "$gtm_obj/gtm_threadgbl_deftypes.h"
cat > $ofile <<EOF
/****************************************************************
 *								*
 *	Copyright 2010, $year Fidelity Information Services, Inc	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Generated by $gtm_tools/gen_gtm_threadgbl_deftypes.csh */

#ifndef GTM_THREADGBL_DEFTYPES_INCLUDED
#define GTM_THREADGBL_DEFTYPES_INCLUDED
/* Output selection criteria for PRO build */
#if !defined(DEBUG) || defined(PRO_BUILD)
`./gtm_threadgbl_deftypes_pro`
#else
`./gtm_threadgbl_deftypes_dbg`
#endif
#endif
EOF
#
# Make sure it is there
#
if (! -e $gtm_obj/gtm_threadgbl_deftypes.h) then
    echo "gen_gtm_threadgbl_deftypes.csh-E-: Unable to generate new $gtm_inc/gtm_threadgbl_deftypes.h"
    popd
    exit 1
endif
#
# Get rid of program stuff unless requested to keep it
#
if (! $?KEEP_THREADGBL) then
    \rm gtm_threadgbl_deftypes{_pro,_dbg,.o} >& /dev/null
endif
#
# See if it is different from the one in $gtm_inc (or if the $gtm_inc one is not there). Only move it there if
# needed to prevent unneeded re-compiles of the world.
#
set keepold = 0
if (-e $gtm_inc/gtm_threadgbl_deftypes.h) then
    \rm -f gtm_threadgbl_deftypes.h.diff
    diff $gtm_inc/gtm_threadgbl_deftypes.h gtm_threadgbl_deftypes.h >& gtm_threadgbl_deftypes.h.diff
    if (0 == $status) then
	set keepold = 1  # if no diff, keep the old file
    else
	#
	# Do some more checking to see if there is "much" of a diff. Specifically, if only the version changed
	# in the comment, we will still replace the file but reset the creation date to what it was before so
	# a runall doesn't cause a full rebuild.
	#
	set diffcnt = `grep -E "<|>" gtm_threadgbl_deftypes.h.diff | grep -v "/* Generated by" | wc -l`
	if (0 == $diffcnt) then
	    touch -r $gtm_inc/gtm_threadgbl_deftypes.h gtm_threadgbl_deftypes.h
	    set keepold = 1 # not much diff (comments only)
	endif
    endif
endif
if (! $keepold) then
    if (-e $gtm_inc/gtm_threadgbl_deftypes.h) then
	chmod 666 $gtm_inc/gtm_threadgbl_deftypes.h
	if (0 != $status) then
	    echo "gen_gtm_threadgbl_deftypes.csh-E-: Unable to reset permissions to allow us to replace $gtm_inc/gtm_threadgbl_deftypes.h"
	    popd
	    exit 1
	endif
    endif
    echo "Replacing $gtm_inc/gtm_threadgbl_deftypes.h"
    \mv -f gtm_threadgbl_deftypes.h $gtm_inc  # replace if needed
    if (0 != $status) then
	echo "gen_gtm_threadgbl_deftypes.csh-E-: Unable to replace $gtm_inc/gtm_threadgbl_deftypes.h"
	popd
	exit 1
    endif
else
    echo "$gtm_inc/gtm_threadgbl_deftypes.h is current - not replaced"
endif

popd
echo "Exiting gen_gtm_threadgbl_deftypes.csh"
exit 0
