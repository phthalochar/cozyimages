#! /bin/bash

# cozyimages.sh - started on Sat 05 Jun 2021 10:07:55 AM PDT
# Original version by Genevieve Mercury

# shell script to process images to create standaridzed cropped and
# sized icons for the Cozy Grove game documentation wiki

HME=$PWD
SRCIMGS=${1:-$HME/source-images}
DSTIMGS=${2:-$HME/converted-images}
NEWIMGS=${3:-$HME/new-images}

if [[ $1 == '-h' || $1 == '--help' || $1 == 'help' ]]; then
    cat <<EOF
$0: icon extraction utility for Cozy Grove.  
Created by Genevieve Mercury in June of 2021

Usage: $0 <source directory> <target directory> <new images directory>
       If <source directory> is omitted, use
          $HME/source-images
       If <target directory> is omitted, use 
       	  $HME/converted-images
       If <new images directory> is omitted, use
       	  $HME/new-images

This script relies on Imagemagick, and will not run without the
standard Imagemagick identify and convert tools in the bash path.

The script keys off of the resolution of the source image to apply a
cropping and scaling recipe, with the goal of producing a 200x200
"icon."  In some cases, game UI variants mean that the recipe can't be
determined from source image resolution. In this case, more than one
version of the output image is produced, but only one will be
correct.  It is up to a human reviewer to determine which is correct.

Currently supported resolutions: 
	  2560x1440, 2732x2048, 1280x720, 2224x1668, 2880x1800, 
	  1920x1080, 1792x828, 1334x750, 1085x610, 873x609

The script relies on unique file names, and names the converted file
the same as the source file name, possibly with an -A or -B variant
label attached.  If a file exists in the destination directory that
appears to correspond to a file name in the source directory, no
conversion is performed.

The expectation is that this script may be run multiple times for a
batch of immages, with changes or additions. Images actually converted
on each run will be symbolically linked in the <new images directory>,
so that if you only want to grab the newly converted images you can look
there. That directory will be cleared at the beginning of each run.

If there are any questions, please contact geneva.quicksilver@gmail.com

SEE ALSO: snarf.sh -- a script to find cozy grove images tucked away in 
complex folder/directory structures with odd naming conventions and drop
them in one place with naming conventions that are more compatible with
bash scripting

EOF
    exit
fi

pushd .
# list of image extensions that we will try to convertbad
IMTYPE="PNG png jpg"

echo "processing $IMTYPE images"

if [[ -d ${NEWIMGS} ]]; then
    echo "clearing ${NEWIMAGES} of previous conversions"
    for i in ${IMTYPE}; do
	rm ${NEWIMGS}/*.${i}
    done
else
	mkdir ${NEWIMGS}
fi

if [[ ! -d ${DSTIMGS} ]]; then
	mkdir ${DSTIMGS}
fi
    
cd $SRCIMGS
rm NOTDONE-*

badres=()
goodres=()
declare -gA rezzes
badfiles=0

CNVSTR1='convert -size 200x200 -composite -gravity Center xc:#f5f0d6'
CNVSTR2='-scale 200x200'

array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
	if [[ $element == "$seeking" ]]; then
	    in=0
	    break
	fi
    done
    return $in
    }

for TPE in $IMTYPE; do
    if [[ "foo" == "foo" ]]; then # FIXME - test if there are any images of this type
	for img in *.${TPE}; do
	    CNVTD='false'
	    nn1=`echo $img | sed "s/\.${TPE}/-KIT.${TPE}/"`
	    nn2=`echo $img | sed "s/\.${TPE}/-VAL.${TPE}/"`
	    echo "processing $img"
	    if [[ -f "${DSTIMGS}/${img}" || \
		      -f "${DSTIMGS}/${nn1}" || \
		      -f "${DSTIMGS}/${nn2}" ]]; then
		goodfiles=$(($goodfiles + 1))
		echo "file ${img} exists in ${DSTIMGS} -- skipping"
	    else
		info=`identify $img`
		#echo "image info: ${info}"
		res=`echo "$info" | awk '{ print $3 }'`
		echo "$img resolution $res"
		rvar="RES${res}"
		echo "resolution counter: ${rezzes[$rvar]}"
		rezzes[$rvar]=$(( ${rezzes[$rvar]} + 1 ))
		if [[ $res == '2560x1440' ]]; then
		    echo "converting 2560x1440 resolution..."
		    #${CNVSTR1} \( $img -crop '331x377+1685+335' ${CNVSTR2} \) ${DSTIMGS}/${img}
		    convert $img -crop '366x362+1670+342' ${DSTIMGS}/XX${img}
		    convert -extent 375x375 -gravity Center -background "#f5f0d6" -scale '200x200' ${DSTIMGS}/XX${img} ${DSTIMGS}/${img}
		    rm ${DSTIMGS}/XX${img}
		    CNVTD='true'
		    NWIMGS="$img"
		    echo "done"
		fi
		if [[ $res == '2732x2048' ]]; then
		    echo "converting 2732x2048 resolution..."
		    convert $img -crop '477x514+1925+475' -scale '200x200' ${DSTIMGS}/XX${img}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${img} ${DSTIMGS}/${img}
		    rm ${DSTIMGS}/XX${img}

		    CNVTD='true'
		    NWIMGS="$img"
		    echo "done"
		fi
		if [[ $res == '1280x720' ]]; then
		    echo "converting 1280x720 resolution..."
		    echo "Doing multiple conversion to reflect UI differences"
		    convert $img -crop '200x200+839+147' -scale '200x200' ${DSTIMGS}/XX${nn1}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn1} ${DSTIMGS}/${nn1}
		    rm ${DSTIMGS}/XX${nn1}

		    convert $img -crop '200x200+905+147' -scale '200x200' ${DSTIMGS}/XX${nn2}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn2} ${DSTIMGS}/${nn2}
		    rm ${DSTIMGS}/XX${nn2}
		    
		    CNVTD='true'
		    NWIMGS="$nn1 $nn2"
		    echo "done"
		fi
		if [[ $res == '2224x1668' ]]; then
		    echo "converting 2224x1668 resolution..."
		    convert $img -crop '400x400+1542+411' -scale '200x200' ${DSTIMGS}/XX${img}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${img} ${DSTIMGS}/${img}
		    rm ${DSTIMGS}/XX${img}

		    CNVTD='true'
		    NWIMGS="$img"
		    echo "done"
		fi
		if [[ $res == '2880x1800' ]]; then
		    echo "converting 2880x1800 resolution..."
		    convert $img -crop '408x446+1929+443' -scale '200x200' ${DSTIMGS}/XX${img}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${img} ${DSTIMGS}/${img}
		    rm ${DSTIMGS}/XX${img}

		    CNVTD='true'
		    NWIMGS="$img"
		    echo "done"
		fi
		if [[ $res == '1920x1080' ]]; then
		    echo "converting 1920x1080 resolution..."
		    echo "Doing multiple conversion to reflect UI differences"
		    convert $img -crop '263x283+1244+251' -scale '200x200' ${DSTIMGS}/XX${nn1}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn1} ${DSTIMGS}/${nn1}
		    rm ${DSTIMGS}/XX${nn1}

		    convert $img -crop '278x261+1320+262' -scale '200x200' ${DSTIMGS}/XX${nn2}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn2} ${DSTIMGS}/${nn2}
		    rm ${DSTIMGS}/XX${nn2}

		    CNVTD='true'
		    NWIMGS="$nn1 $nn2"
		    echo "done"
		fi
		if [[ $res == '1792x828' ]]; then
		    echo "converting 1792x828 resolution..."
		    convert $img -crop '309x328+1156+52' -scale '200x200' ${DSTIMGS}/XX${img}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${img} ${DSTIMGS}/${img}
		    rm ${DSTIMGS}/XX${img}

		    CNVTD='true'
		    NWIMGS="$img"
		    echo "done"
		fi
		if [[ $res == '1334x750' ]]; then
		    echo "converting 1334x750 resolution..."
		    echo "Doing multiple conversion to reflect UI differences"
		    convert $img -crop '244x275+937+94' -scale '200x200' ${DSTIMGS}/XX${nn1}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn1} ${DSTIMGS}/${nn1}
		    rm ${DSTIMGS}/XX${nn1}

		    convert $img -crop '247x271+874+96' -scale '200x200' ${DSTIMGS}/XX${nn2}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn2} ${DSTIMGS}/${nn2}
		    rm ${DSTIMGS}/XX${nn2}

		    CNVTD='true'
		    NWIMGS="$nn1 $nn2"
		    echo "done"
		fi
		if [[ $res == '1085x610' ]]; then
		    echo "converting 1085x610 resolution..."			
		    echo "Doing multiple conversion to reflect UI differences"
		    convert $img -crop '172x172+759+123' -scale '195x195' ${DSTIMGS}/XX${nn1}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn1} ${DSTIMGS}/${nn1}
		    rm ${DSTIMGS}/XX${nn1}

		    convert $img -crop '172x172+709+123' -scale '195x195' ${DSTIMGS}/XX${nn2}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${nn2} ${DSTIMGS}/${nn2}
		    rm ${DSTIMGS}/XX${nn2}

		    CNVTD='true'
		    NWIMGS="$nn1 $nn2"
		    echo "done"
		fi
		if [[ $res == '873x609' ]]; then
		    echo "converting 873x609 resolution..."
		    convert $img -crop '155x155+647+135' -scale '200x200' ${DSTIMGS}/XX${img}
		    convert -size 200x200 -gravity Center -composite xc:"#f5f0d6" ${DSTIMGS}/XX${img} ${DSTIMGS}/${img}
		    rm ${DSTIMGS}/XX${img}
		    CNVTD='true'
		    NWIMGS="$img"
		    echo "done"
		fi
		if [[ $CNVTD == 'true' ]]; then
		    goodfiles=$(($goodfiles + 1))
		    echo "total good files seen: $goodfiles"
		    if [[ -d ${NEWIMGS} ]]; then 
			for i in $NWIMGS; do
				ln -s ${DSTIMGS}/$i ${NEWIMGS}/$i
			done
		    fi
		    if array_contains goodres $res; then
			echo "seen $res before"
		    else
			echo "first time seeing $res"
			goodres+=("$res")
		    fi
		else
		    echo "=========> unable to convert $img with resolution $res"
		    badfiles=$(($badfiles + 1))
		    echo "total bad files seen: $badfiles"
		    touch ${DSTIMGS}/NOTDONE-${img}
 		    if array_contains badres $res; then
			echo "seen $res before"
		    else
			echo "first time seeing $res"
			badres+=("$res")
		    fi
		fi
	    fi
	done
    fi
done

popd

echo "CONVERTED FILES"
echo "total number of files converted: $goodfiles"
for i in ${goodres[@]}; do
    rvar="RES${i}"
    echo "total files converted for resolution $i: ${rezzes[$rvar]}"
done

echo "BAD FILES"
echo "total number of files not converted: $badfiles"
echo "unknown resolutions: ${badres[@]}"

for i in ${badres[@]}; do
    rvar="RES${i}"
    echo "total files seen for $i: ${rezzes[$rvar]}"
done

echo "$0 script run done"
