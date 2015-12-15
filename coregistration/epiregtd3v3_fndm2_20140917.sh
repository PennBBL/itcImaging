. /import/monstrum/Users/sattertt/.bashrc

#!/bin/sh
#   Copyright (C) 2012 University of Oxford
#
#   Part of FSL - FMRIB's Software Library
#   http://www.fmrib.ox.ac.uk/fsl
#   fsl@fmrib.ox.ac.uk
#   
#   Developed at FMRIB (Oxford Centre for Functional Magnetic Resonance
#   Imaging of the Brain), Department of Clinical Neurology, Oxford
#   University, Oxford, UK
#   
#   
#   LICENCE
#   
#   FMRIB Software Library, Release 5.0 (c) 2012, The University of
#   Oxford (the "Software")
#   
#   The Software remains the property of the University of Oxford ("the
#   University").
#   
#   The Software is distributed "AS IS" under this Licence solely for
#   non-commercial use in the hope that it will be useful, but in order
#   that the University as a charitable foundation protects its assets for
#   the benefit of its educational and research purposes, the University
#   makes clear that no condition is made or to be implied, nor is any
#   warranty given or to be implied, as to the accuracy of the Software,
#   or that it will be suitable for any particular purpose or for use
#   under any specific conditions. Furthermore, the University disclaims
#   all responsibility for the use which is made of the Software. It
#   further disclaims any liability for the outcomes arising from using
#   the Software.
#   
#   The Licensee agrees to indemnify the University and hold the
#   University harmless from and against any and all claims, damages and
#   liabilities asserted by third parties (including claims for
#   negligence) which arise directly or indirectly from the use of the
#   Software or the sale of any products based on the Software.
#   
#   No part of the Software may be reproduced, modified, transmitted or
#   transferred in any form or by any means, electronic or mechanical,
#   without the express permission of the University. The permission of
#   the University is not required if the said reproduction, modification,
#   transmission or transference is done without financial return, the
#   conditions of this Licence are imposed upon the receiver of the
#   product, and all original and amended source code is included in any
#   transmitted product. You may be held legally responsible for any
#   copyright infringement that is caused or encouraged by your failure to
#   abide by these terms and conditions.
#   
#   You are not permitted under this Licence to use this Software
#   commercially. Use for which any financial return is received shall be
#   defined as commercial use, and includes (1) integration of all or part
#   of the source code or the Software into a product for sale or license
#   by or on behalf of Licensee to third parties or (2) use of the
#   Software or any derivative of it for research with the final aim of
#   developing software products for sale or license to a third party or
#   (3) use of the Software or any derivative of it for research with the
#   final aim of developing non-software products for sale or license to a
#   third party, or (4) use of the Software to provide any service to an
#   external organisation for which payment is received. If you are
#   interested in using the Software commercially, please contact Isis
#   Innovation Limited ("Isis"), the technology transfer company of the
#   University, to negotiate a licence. Contact details are:
#   innovation@isis.ox.ac.uk quoting reference DE/9564.

#####Modification notes
#11/7/12 TDS added flags for working directory and specification of T1 white matter image (for when segmentation has already been performed)

Usage() {
    echo ""
    echo "Usage: `basename $0` [options] --epi=<EPI image> --t1=<wholehead T1 image> --t1brain=<brain extracted T1 image> --t1wm=<WM segement of T1 image> --out=<output name>"
    echo " "
    echo "Optional arguments"
    echo "  --fmap=<image>         : fieldmap image (in rad/s)"
    echo "  --fmapmag=<image>      : fieldmap magnitude image - wholehead extracted"
    echo "  --fmapmagbrain=<image> : fieldmap magnitude image - brain extracted"
    echo "  --echospacing=<val>    : Effective EPI echo spacing (sometimes called dwell time) - in seconds"
    echo "  --pedir=<dir>          : phase encoding direction, dir = x/y/z/-x/-y/-z"
    echo "  --weight=<image>       : weighting image (in T1 space)"
    echo "  --=<wd>                : working directory-- necessary to make this script work on sge effectively-- TDS modification"	
    echo "  --noclean              : do not clean up intermediate files"
    echo "  -v                     : verbose output"
    echo "  -h                     : display this help message"
    echo " "
    echo "e.g.:  `basename $0` --epi=example_func --t1=struct --t1brain=struct_brain --t1wm=struct_wm --out=epi2struct --fmap=fmap_rads --fmapmag=fmap_mag --fmapmagbrain=fmap_mag_brain --echospacing=0.0005 --pedir=-y"
    echo " "
    echo "Note that if parallel acceleration is used in the EPI acquisition then the *effective* echo spacing is the actual echo spacing between acquired lines in k-space divided by the acceleration factor."
    echo " "
    exit 1
}



get_opt1() {
    arg=`echo $1 | sed 's/=.*//'`
    echo $arg
}


get_arg1() {
    if [ X`echo $1 | grep '='` == X ] ; then 
	echo "Option $1 requires an argument" 1>&2
	exit 1
    else 
	arg=`echo $1 | sed 's/.*=//'`
	if [ X$arg == X ] ; then
	    echo "Option $1 requires an argument" 1>&2
	    exit 1
	fi
	echo $arg
    fi
}

get_imarg1() {
    arg=`get_arg1 $1`;
    arg=`$FSLDIR/bin/remove_ext $arg`;
    echo $arg
}

get_arg2() {
    if [ X$2 == X ] ; then
	echo "Option $1 requires an argument" 1>&2
	exit 1
    fi
    echo $2
}


# list of variables to be set via the options
vepi="";
vrefhead="";
vrefbrain="";
vwm="";
vwkdir="";
vout="";
use_fmap=no;
use_weighting=no;
verbose=no
cleanup=yes;
fmaprads="";
fmapmaghead="";
fmapmagbrain="";
dwell="";
pe_dir="";
fdir="y";


# Parse them baby

if [ $# -lt 4 ] ; then Usage; exit 0; fi
while [ $# -ge 1 ] ; do
    iarg=`get_opt1 $1`;
    case "$iarg"
	in
	--wd)
	    vwkdir=`get_imarg1 $1`;
	    shift;;
	--epi)
	    vepi=`get_imarg1 $1`;
	    shift;;
	--t1)
	    vrefhead=`get_imarg1 $1`;
	    shift;;
	--t1brain)
	    vrefbrain=`get_imarg1 $1`;
	    shift;;
	--t1wm)
	    vwm=`get_imarg1 $1`;
            shift;;
	--fmap)
	    fmaprads=`get_imarg1 $1`;
	    use_fmap=yes; 
	    shift;;
	--fmapmag)
	    fmapmaghead=`get_imarg1 $1`;
	    shift;;
	--fmapmagbrain)
	    fmapmagbrain=`get_imarg1 $1`;
	    shift;;
	--out)
	    vout=`get_imarg1 $1`;
	    shift;;
	--echospacing)
	    dwell=`get_arg1 $1`;
	    if [ `echo "if ( $dwell > 0.2 ) {1}; if ( $dwell <= 0.2 ) {0}" | bc -l` == 1 ] ; then 
		msdwell=`echo "scale=6; $dwell / 1000.0" | bc -l`;
		echo "Echo spacing should be specified in seconds, not milliseconds.  Value of $dwell appears to be incorrectly specified in milliseconds.  Try using the value $msdwell instead."; 
		exit 1; 
	    fi
	    shift;;
	--pedir)
	    pearg=`get_arg1 $1`;
            # These are consistent with the ones used in FUGUE (this has been checked)
	    if [ $pearg == "x" ] ; then pe_dir=1; fdir="x"; fi
	    if [ $pearg == "y" ] ; then pe_dir=2; fdir="y"; fi
	    if [ $pearg == "z" ] ; then pe_dir=3; fdir="z"; fi
	    if [ $pearg == "-x" ] ; then pe_dir=-1; fdir="x-"; fi
	    if [ $pearg == "-y" ] ; then pe_dir=-2; fdir="y-"; fi
	    if [ $pearg == "-z" ] ; then pe_dir=-3; fdir="z-"; fi
	    if [ $pearg == "x-" ] ; then pe_dir=-1; fdir="x-"; fi
	    if [ $pearg == "y-" ] ; then pe_dir=-2; fdir="y-"; fi
	    if [ $pearg == "z-" ] ; then pe_dir=-3; fdir="z-"; fi
	    if [ X${pe_dir} == X ] ; then
		echo "Error: invalid phase encode direction specified";
		exit 2;
	    fi
	    shift;;
	--weight)
	    refweight=`get_imarg1 $1`;
	    use_weighting=yes; 
	    echo REFWEIGHT = $refweight;
	    shift;;
	--noclean)
	    cleanup=no; 
	    shift;;
	-v)
	    verbose=yes; 
	    shift;;
	-h)
	    Usage;
	    exit 0;;
	*)
	    #if [ `echo $1 | sed 's/^\(.\).*/\1/'` = "-" ] ; then 
	    echo "Unrecognised option $1" 1>&2
	    exit 1
	    #fi
	    #shift;;
    esac
done

### Sanity checking of arguments

if [ X$vout == X ] ; then
  echo "The compulsory argument --out MUST be used"
  exit 1;
fi

if [ X$vepi == X ] ; then
  echo "The compulsory argument --epi MUST be used"
  exit 1;
fi

if [ X$vrefhead == X ] ; then
  echo "The compulsory argument --t1 MUST be used"
  exit 1;
fi

if [ X$vrefbrain == X ] ; then
  echo "The compulsory argument --t1brain MUST be used"
  exit 1;
fi

if [ X$vwkdir == X ] ; then
  echo "The compulsory argument --working directory MUST be used in this modificatoin of the script"
  exit 1;
fi

if [ X$vwm == X ] ; then
  echo "The compulsory argument --t1wm MUST be used in this modification of the script"
  exit 1;
fi

if [ $use_fmap == yes ] ; then
    if [ X$fmaprads == X ] ; then
	echo "The argument --fmap MUST be usspecifieded if using fieldmaps"
	exit 1;
    fi
    if [ X$fmapmaghead = X ] ; then
	echo "The argument --fmapmag MUST be specified if using fieldmaps"
	exit 1;
    fi
    if [ X$fmapmagbrain == X ] ; then
	echo "The argument --fmapmagbrain MUST be specified if using fieldmaps"
	exit 1;
    fi
    if [ X$pe_dir == X ] ; then
	echo "The argument --pedir MUST be specified if using fieldmaps"
	exit 1;
    fi
    if [ X$dwell == X ] ; then
	echo "The argument --echospacing MUST be specified if using fieldmaps"
	exit 1;
    fi
fi

if [ $verbose == yes ] ; then
    echo "Arguments are:"
    echo "  vepi = $vepi"
    echo "  vrefhead = $vrefhead"
    echo "  vrefbrain = $vrefbrain"
    echo "  vwm = $vwm"
    echo "  vwkdir= $vwkdir"
    echo "  vout = $vout"
    echo "  fmaprads = $fmaprads"
    echo "  fmapmaghead = $fmapmaghead"
    echo "  fmapmagbrain = $fmapmagbrain"
    echo "  dwell = $dwell"
    echo "  pe_dir = $pe_dir"
    echo "  fdir = $fdir"
    echo "  use_fmap = $use_fmap"
    echo "  use_weighting = $use_weighting"
fi

##########################################################################################
echo "working dir is $vwkdir"
cd $vwkdir

# make a WM edge map for visualisation (good to overlay in FSLView)
if [ `$FSLDIR/bin/imtest ${vrefbrain}_wmedge` == 0 ] ; then
  $FSLDIR/bin/fslmaths ${vwm} -edge -bin -mas ${vwm} ${vout}_wmedge
else
    for file in ${vrefbrain}_wmedge*; do
	absfile=`$FSLDIR/bin/fsl_abspath $file`;
	ln -s ${vout}_wmedge${absfile/${vrefbrain}_wmedge/} #To link the correct files with extensions
    done
fi

# do a standard flirt pre-alignment
echo "FLIRT pre-alignment"
pwd
$FSLDIR/bin/flirt -ref ${vrefbrain} -in ${vepi} -dof 6 -omat ${vout}_init.mat

####################

if [ $use_fmap = no ] ; then

# NO FIELDMAP
    # now run the bbr
    echo "Running BBR"
    $FSLDIR/bin/flirt -ref ${vrefhead} -in ${vepi} -dof 6 -cost bbr -wmseg ${vwm} -init ${vout}_init.mat -omat ${vout}.mat -out ${vout} -schedule ${FSLDIR}/etc/flirtsch/bbr.sch
    $FSLDIR/bin/applywarp -i ${vepi} -r ${vrefhead} -o ${vout} --premat=${vout}.mat --interp=spline

####################

else

# WITH FIELDMAP
    echo "Registering fieldmap to structural"
    # register fmap to structural image
    $FSLDIR/bin/flirt -in ${fmapmagbrain} -ref ${vrefbrain} -dof 6 -omat ${vout}_fieldmap2str_init.mat
    $FSLDIR/bin/flirt -in ${fmapmaghead} -ref ${vrefhead} -dof 6 -init ${vout}_fieldmap2str_init.mat -omat ${vout}_fieldmap2str.mat -out ${vout}_fieldmap2str -nosearch
    # unmask the fieldmap (necessary to avoid edge effects)
    $FSLDIR/bin/fslmaths ${fmapmagbrain} -abs -bin ${vout}_fieldmaprads_mask
    $FSLDIR/bin/fslmaths ${fmaprads} -abs -bin -mul ${vout}_fieldmaprads_mask ${vout}_fieldmaprads_mask
    $FSLDIR/bin/fugue --loadfmap=${fmaprads} --mask=${vout}_fieldmaprads_mask --unmaskfmap --savefmap=${vout}_fieldmaprads_unmasked --unwarpdir=${fdir}   # the direction here should take into account the initial affine (it needs to be the direction in the EPI)

    # the following is a NEW HACK to fix extrapolation when fieldmap is too small
    $FSLDIR/bin/applywarp -i ${vout}_fieldmaprads_unmasked -r ${vrefhead} --premat=${vout}_fieldmap2str.mat -o ${vout}_fieldmaprads2str_pad0
    $FSLDIR/bin/fslmaths ${vout}_fieldmaprads2str_pad0 -abs -bin ${vout}_fieldmaprads2str_innermask
    $FSLDIR/bin/fugue --loadfmap=${vout}_fieldmaprads2str_pad0 --mask=${vout}_fieldmaprads2str_innermask --unmaskfmap --unwarpdir=${fdir} --savefmap=${vout}_fieldmaprads2str_dilated
    $FSLDIR/bin/fslmaths ${vout}_fieldmaprads2str_dilated ${vout}_fieldmaprads2str

    # run bbr with fieldmap
    echo "Running BBR with fieldmap"
    if [ $use_weighting = yes ] ; then wopt="-refweight $refweight"; else wopt=""; fi
    $FSLDIR/bin/flirt -ref ${vrefhead} -in ${vepi} -dof 6 -cost bbr -wmseg ${vwm} -init ${vout}_init.mat -omat ${vout}.mat -out ${vout}_1vol -schedule ${FSLDIR}/etc/flirtsch/bbr.sch -echospacing ${dwell} -pedir ${pe_dir} -fieldmap ${vout}_fieldmaprads2str $wopt

    # make equivalent warp fields
    echo "Making warp fields and applying registration to EPI series"
    $FSLDIR/bin/convert_xfm -omat ${vout}_inv.mat -inverse ${vout}.mat
    $FSLDIR/bin/convert_xfm -omat ${vout}_fieldmaprads2epi.mat -concat ${vout}_inv.mat ${vout}_fieldmap2str.mat
    $FSLDIR/bin/applywarp -i ${vout}_fieldmaprads_unmasked -r ${vepi} --premat=${vout}_fieldmaprads2epi.mat -o ${vout}_fieldmaprads2epi
    $FSLDIR/bin/fslmaths ${vout}_fieldmaprads2epi -abs -bin ${vout}_fieldmaprads2epi_mask
    $FSLDIR/bin/fugue --loadfmap=${vout}_fieldmaprads2epi --mask=${vout}_fieldmaprads2epi_mask --saveshift=${vout}_fieldmaprads2epi_shift --unmaskshift --dwell=${dwell} --unwarpdir=${fdir}
    $FSLDIR/bin/convertwarp -r ${vrefhead} -s ${vout}_fieldmaprads2epi_shift --postmat=${vout}.mat -o ${vout}_warp --shiftdir=${fdir} --absout
    $FSLDIR/bin/applywarp -i ${vepi} -r ${vrefhead} -o ${vout} -w ${vout}_warp --interp=spline --abs

fi

####################

# CLEAN UP UNNECESSARY FILES
if [ $cleanup = yes ] ; then
    $FSLDIR/bin/imrm ${vout}_fast_mixeltype ${vout}_fast_pve* ${vout}_fast_seg ${vout}_fast_wmseg 
    $FSLDIR/bin/imrm ${vout}_fieldmap*mask* ${vout}_fieldmap2str_pad0
fi


