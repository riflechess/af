#!/bin/bash
#escape XML characters on our extracted .txt files

for f in *.txt ; do
current_date_time="`date +%Y%m%d%H%M%S`";
echo "$current_date_time processing $f...";
sed '/^\s*$/d' $f > tmp.txt
cp tmp.txt $f
sed 's/&/\&amp;/g' $f > tmp.txt
cp tmp.txt $f
sed 's/\x27/\&apos;/g' $f > tmp.txt
cp tmp.txt $f
sed 's/</\&lt;/g' $f > tmp.txt
cp tmp.txt $f
sed 's/>/\&gt;/g' $f > tmp.txt
cp tmp.txt $f
sed 's/"/\&quot;/g' $f > tmp.txt
cp tmp.txt $f

rm tmp.txt
echo "$f complete.";

done;
