#!/bin/bash
#requeue items if they do not have associated .txt extract OCR file
#run in finished directory
#
#/workingDir/
#/workingDir/text/
#/workingDir/finished/

for f in *.pdf ; do
	echo "###NEW DOC###"
	echo "checking if $f has been processed..."

	ct=$(find ../text/ -name "${f%.pdf}*" | wc -l)	
	find ../text/ -name "${f%.pdf}*" 
	echo "Count for $f is $ct"
	if [[ $ct -eq $zero ]]; then
		echo "No Text Match Found for $f, moving...";
		mv $f ..
	fi
done
