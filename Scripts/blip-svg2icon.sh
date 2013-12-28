#!/bin/sh
set -e
size="$1"
file="$2"
suffix="$3"

if [ -z "$size" ]; then
    size="-h"
fi

if [ "$size" == "-h" ]; then
    echo "usage: blip-svg2icon.sh size svgfile {suffix}"
    echo "size=square pixel size of resulting png file"
fi

inkscape="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
dir=$(dirname $file)
basename=$(basename $file)
base="${basename%.[^.]*}" 
fileWidth=`$inkscape -W $file`
fileHeight=`$inkscape -H $file`
tempFile="${dir}/${base}.temp.png"
outFile="${dir}/${base}${suffix}.png"
widthGreaterThanHeight=`echo "$fileWidth > $fileHeight" | bc`
echo "file=$file"
echo "size=$size"
echo "dir=$dir"
echo "suffix=$suffix"
echo "base=$base"
echo "fileWidth=$fileWidth"
echo "fileHeight=$fileHeight"
echo "tempFile=$tempFile"
echo "outFile=$outFile"
echo "widthGreaterThanHeight=$widthGreaterThanHeight"
if [ "$widthGreaterThanHeight" == "1" ]; then
    echo "Width > Height"
    echo $inkscape -z -D -w $size -y 0 -e "$tempFile" "$file"
    $inkscape -z -D -w "$size" -y 0 -e "$tempFile" "$file"
    borderPixels=`echo "($fileWidth - $fileHeight)/2 * $size/$fileWidth" | bc`
    echo "convert -bordercolor transparent -border 0x${borderPixels} $tempFile $outFile"
    echo "border=$borderPixels"
    convert -bordercolor transparent -border "0x${borderPixels}" -negate "$tempFile" "$outFile"
else
    echo $inkscape -z -D -h "$size" -y 0 -e "$tempFile" "$file" 
    $inkscape -z -D -h "$size" -y 0 -e "$tempFile" "$file" 
    borderPixels=`echo "($fileHeight - $fileWidth)/2 * $size/$fileHeight" | bc`
    echo "border=$borderPixels"
    convert -bordercolor transparent -border "${borderPixels}x0" -negate "$tempFile" "$outFile"
fi

rm "$tempFile"
echo "Wrote $outFile"

    