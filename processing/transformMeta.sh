#!/bin/bash
#Use File manifest from national archives (cleaned up and converted to .csv) 
#to build SOLR import files with content/metadata.

#Metadata format:
#"File Name","Record Num","NARA Release Date","Formerly Withheld","Agency","Doc Date","Doc Type","File Num","To Name","From Name","Title","Num Pages","Ori
#ginator","Record Series","Review Date","Comments","Pages Released"

declare -i totalCt
IFS="|"
totalCt=0
relDir='./released-text2/'
while read f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16
do
	#make file name lower case
	f1="${f1,,}"
	find $relDir -type f -name "${f1%.pdf}*.txt" | while read fname; do
		echo "Processing $fname...";
		#remove path when storing resource name
		resourceName=$(basename $fname)	
		echo "<add><doc>" >> "${fname%.txt}.xml" 
		echo "<field name=\"resourcename\">$resourceName</field>" >> "${fname%.txt}.xml" 
		echo "<field name=\"filename\">$f1</field>" >> "${fname%.txt}.xml" 
		echo "<field name=\"recordnum\">$f2</field>" >> "${fname%.txt}.xml" 
		echo "<field name=\"narareleasedate\">$f3</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"formerlywithheld\">$f4</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"agency\">$f5</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"docdate\">$f6</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"doctype\">$f7</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"filenum\">$f8</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"toname\">$f9</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"fromname\">$f10</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"title\">$f11</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"numpages\">$f12</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"originator\">$f13</field>" >> "${fname%.txt}.xml"
		echo "<field name=\"recordseries\">$f14</field>" >> "${fname%.txt}.xml" 
		echo "<field name=\"reviewdate\">$f15</field>" >> "${fname%.txt}.xml" 
		#comments are problematic
		#echo "<comments>$f16</comments>" >> "${fname%.txt}.xml" 
		echo "<field name=\"content\">" >> "${fname%.txt}.xml" 	
		cat $fname >> "${fname%.txt}.xml"
		echo "</field></doc></add>" >> "${fname%.txt}.xml"
	 
		totalCt+=1;
	done

done < JFK_2018_no_dupe_xml_esc_final.csv
echo "total Count is $totalCt"
