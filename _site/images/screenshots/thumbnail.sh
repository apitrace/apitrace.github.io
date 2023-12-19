#!/bin/bash
FILES="$@"
for i in $FILES 
do
echo "Prcoessing image $i ..."
/usr/bin/convert -thumbnail x150 $i thumb/$i
done
