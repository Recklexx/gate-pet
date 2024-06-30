#! /bin/sh
echo start my SPECT reconstruction 

#
# Options
#
MPIRUN=""
CACHEALLVIEWS2D=0
# always disable the cache for 3D PSF as we run less than 1 iteration
CACHEALLVIEWS3D=0
export CACHEALLVIEWS2D
export CACHEALLVIEWS3D

#
# Parse option arguments (--)
# Note that the -- is required to suppress interpretation of $1 as options 
# to expr
#
while test `expr -- "$1" : "--.*"` -gt 0
do

  if test "$1" = "--mpicmd"
  then
    MPIRUN="$2"
    shift 1
  elif test "$1" = "--usecache"
  then
    CACHEALLVIEWS2D=1
  elif test "$1" = "--help"
  then
    echo "Usage: `basename $0` [--mpicmd somecmd] [--usecache] [install_dir]"
    echo "(where [] means that an argument is optional)"
    echo "See README.txt for more info."
    exit 1
  else
    echo Warning: Unknown option "$1"
    echo rerun with --help for more info.
    exit 1
  fi

  shift 1

done 

if [ $# -eq 1 ]; then
  echo "Prepending $1 to your PATH for the duration of this script."
  PATH=$1:$PATH
fi


if [ ${CACHEALLVIEWS2D} -eq 1 ]; then
   echo "Keeping all views in memory for the iterative reconstruction."
else
   echo "Recomputing the matrix in every iteration for the iterative reconstruction."
   echo "If you have plenty of memory, relaunch with the option \"--usecache\""
fi

# check command 
command -v OSMAPOSL >/dev/null 2>&1 || { echo "OSMAPOSL not found or not executable. Aborting." >&2; exit 1; }
echo "Using `command -v FBP2D`"
echo "Using `command -v OSMAPOSL`"

# first need to set this to the C locale, as this is what the STIR utilities use
# otherwise, awk might interpret floating point numbers incorrectly
LC_ALL=C
export LC_ALL

rm -rf out
mkdir out

# loop over reconstruction algorithms
error_log_files=""

#for reconpar in FBP2D OSEM_2DPSF OSEM_3DPSF; do
#for reconpar in FBP2D ; do
#for reconpar in OSEM_2DPSF ; do
for reconpar in FBP2D OSEM_2DPSF; do
    # test first if analytic reconstruction and if so, run pre-correction
    isFBP=0
    if expr ${reconpar} : FBP > /dev/null; then
      isFBP=1
      recon=FBP2D
    else
      isFBP=0
      recon=OSMAPOSL
    fi

    echo "============================================="
    echo "Using `command -v ${recon}`"

    parfile=${reconpar}.par
    # run actual reconstruction
    echo "Running ${recon} ${parfile}"
    logfile=out/${parfile}.log
    ${MPIRUN} ${recon} ${parfile} > ${logfile} 2>&1
    if [ $? -ne 0 ]; then
       echo "Error running reconstruction. CHECK RECONSTRUCTION LOG ${logfile}"
       error_log_files="${error_log_files} ${logfile}"
       break
    fi

    # find filename of (last) image from ${parfile}
    output_filename=`awk -F':='  '/output[ _]*filename[ _]*prefix/ { value=$2;gsub(/[ \t]/, "", value); printf("%s", value) }' ${parfile}`
    if [ ${isFBP} -eq 0 ]; then
      # iterative algorithm, so we need to append the num_subiterations
      num_subiterations=`awk -F':='  '/number[ _]*of[ _]*subiterations/ { value=$2;gsub(/[ \t]/, "", value); printf("%s", value) }' ${parfile}`
      output_filename=${output_filename}_${num_subiterations}
    fi
    output_image=${output_filename}.hv

    # horrible way to replace "out" with "org" (as we don't want to rely on bash)
    org_output_image=out`expr substr ${output_image} 4 100`
	
done

echo "============================================="
if [ -z "${error_log_files}" ]; then
 echo "All OK!"
else
 echo "There were errors. Check ${error_log_files}"
fi

