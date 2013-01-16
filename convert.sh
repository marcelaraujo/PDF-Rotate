#!/bin/bash

if [ "$#" != 2 ]; then 
	echo 'Usage convert-ipx.sh in.pdf out.pdf'
	exit 1
fi

FILE_IN="$1"
FILE_OUT="$2"
DIR="/tmp/`od -An -N8 -tx4 < /dev/urandom | sed 's/ //g'`"

mkdir -p $DIR && echo "Creating dir ${DIR}..."

PROPERTIES=`identify -format "%s:%w:%h\n" $FILE_IN | awk '{ printf $0 "\n" }'`

for p in $PROPERTIES
do
	PAGE=`echo $p | awk -F ':' '{ print $1 }'`
	ORIENTATION=`echo $p | awk -F ':' '{if ($2>$3) print "LANDSCAPE"; else print "PORTRAIT"}'`
	
	i=$(($PAGE+1))
	
	echo "Checking page orientation.."
	if [ $ORIENTATION == 'LANDSCAPE' ]; then
		echo "Convert page from LANDSCAPE to PORTRAIT..."
		pdftk $FILE_IN cat "${i}W" output `printf "$DIR/page_%06d.pdf" $i`
	else
		pdftk $FILE_IN cat "${i}" output `printf "$DIR/page_%06d.pdf" $i`
	fi
	
	echo "Page number $i created..."
done

echo "Merging PDF's into a new PDF"
pdftk $DIR/*.pdf cat output $FILE_OUT compress

echo "Done"
rm -rf $DIR