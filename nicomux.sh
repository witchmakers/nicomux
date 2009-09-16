#!/bin/sh

TEMPDIR='./__temp'

while getopts a:v:r:o: OPT
do
    case $OPT in
	"a" ) AUDIOFILE=$OPTARG ;;
	"v" ) IMAGEFILE=$OPTARG ;;
	"r" ) FPS=$OPTARG ;;
	"o" ) OUTFILE=$OPTARG ;;
	*   ) echo "Usage mux -a AUDIOFILE -v IMAGEFILE -r FPS [-o OUTFILENAME]" ; exit 1 ;;
    esac
done

if test -n $AUDIOFILE && test -n $IMAGEFILE && test $FPS -gt 0
then
    D=`mdls -name kMDItemDurationSeconds -raw $AUDIOFILE`
    DURATION=`echo "$D + 1" | bc`
    mkdir $TEMPDIR
    ffmpeg -y -f image2 -r $FPS -loop_input -t $DURATION -vcodec 'copy' -i $IMAGEFILE $TEMPDIR/image.avi && \
    ffmpeg -y -i $TEMPDIR/image.avi -vcodec 'copy' -i $AUDIOFILE -acodec 'copy' $TEMPDIR/movie.avi && \
    
    if test -n $OUTFILE
    then
	ffmpeg -y -i $TEMPDIR/movie.avi -f mp4 -acodec 'copy' -vcodec libx264 -vpre hq $OUTFILE
    else
	ffmpeg -y -i $TEMPDIR/movie.avi -f mp4 -acodec 'copy' -vcodec libx264 -vpre hq ./music.mp4
    fi
    
    rm -rf $TEMPDIR
else
    if test -z $AUDIOFILE
    then
	echo "Error : Audio file is not specified"
    fi

    if test -z $IMAGEFILE
    then
	echo "Error : Image file is not specified"
    fi

    if test -z $FPS
    then
	echo "Error : Framerate is not specified"
    elif test $FPS -le 0
	echo "Erro : Framerat must be larger than zero"
    fi

    exit 1
fi