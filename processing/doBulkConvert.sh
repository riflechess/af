#!/bin/bash
#Bulk OCR PDF files
#Orig PDF -> Split in to pages (pdfbox) -> Convert to .TIF (ImageMagic) -> OCR (Tesseract)
#doBulkConvert.sh - Runs in workingDir
#
#/workingDir/				Holds original PDF's that haven't been OCR'd
#/workingDir/text/			Finished OCR'd Text Files
#/workingDir/finished/		Finished PDFs
#

for f in *.pdf ; do
	current_date_time="`date +%Y%m%d%H%M%S`";
	echo "###########NEW#FILE############";
	echo "$current_date_time Converting $f...";
	echo "$current_date_time Splitting $f...";
	#Using pdfbox to pre-split the PDF's in to pages limits RAM vs doing it in ImageMagick
	java -jar pdfbox-app-2.0.8.jar PDFSplit -split 1 "$f";
	current_date_time="`date +%Y%m%d%H%M%S`";
	echo "$current_date_time renaming $f...";
    #rename pdf being processed XXX.imp 
	mv $f "${f%.pdf}.imp"
   
	for z in $(ls ${f%.pdf}*.pdf); do
        echo "Converting $z to image format..."
		#decrement page number so it matches page 1= -0.png like other files
		#this part needs to be adjusted based on file name format
		#docid-234234-01.pdf 123-123-12333-23.pdf	
		IFS='-|.' read -a fnameArray <<< "$z"	

		#for docs like 104-10002-10084.pdf
		#		(( fnameArray[3]-- ))
		#tmp="${fnameArray[0]}-${fnameArray[1]}-${fnameArray[2]}-${fnameArray[3]}.${fnameArray[4]}"
		
		#for docs like docid-32294430.pdf
        #        (( fnameArray[2]-- ))
		#tmp="${fnameArray[0]}-${fnameArray[1]}-${fnameArray[2]}.${fnameArray[3]}"

		(( fnameArray[3]-- ))
		tmp="${fnameArray[0]}-${fnameArray[1]}-${fnameArray[2]}-${fnameArray[3]}.${fnameArray[4]}"
		echo "Decrementing file page, new name $tmp"

		convert -deskew 20 -density 300 "$z" "${tmp%.pdf}.png" ;
		rm $z
	done
    current_date_time="`date +%Y%m%d%H%M%S`";
	echo "$current_date_time Image format conversion finished..."
	
	
	echo "$current_date_time Beginning OCR/Text-Extract..."
	IFS=' ' read -r -a files <<< $(ls *.png)
	#multiple instances of tessearact since it doesn't multi-thread
	for (( i=0; i<${#files[@]} ; i+=8 )) ; do
        	echo "Text extracting ${files[i]}...";
        	tesseract -l eng "${files[i]}" "text/${files[i]%.png}" &
       		if [[ ${files[i+1]} ]]; then
			echo "Text extracting ${files[i+1]}...";
        		tesseract -l eng "${files[i+1]}" "text/${files[i+1]%.png}" &
       		fi 
       		if [[ ${files[i+2]} ]]; then
			echo "Text extracting ${files[i+2]}...";
        		tesseract -l eng "${files[i+2]}" "text/${files[i+2]%.png}" &
        	fi
       		if [[ ${files[i+3]} ]]; then
			echo "Text extracting ${files[i+3]}...";
        		tesseract -l eng "${files[i+3]}" "text/${files[i+3]%.png}" &
       		fi 
			if [[ ${files[i+4]} ]]; then
					echo "Text extracting ${files[i+4]}...";
					tesseract -l eng "${files[i+4]}" "text/${files[i+1]%.png}" &
			fi
			if [[ ${files[i+5]} ]]; then
					echo "Text extracting ${files[i+5]}...";
					tesseract -l eng "${files[i+5]}" "text/${files[i+2]%.png}" &
			fi
			if [[ ${files[i+6]} ]]; then
					echo "Text extracting ${files[i+6]}...";
					tesseract -l eng "${files[i+6]}" "text/${files[i+3]%.png}" &
			fi
			if [[ ${files[i+7]} ]]; then
					echo "Text extracting ${files[i+7]}...";
					tesseract -l eng "${files[i+7]}" "text/${files[i+3]%.png}" &
			fi
		wait

		current_date_time="`date +%Y%m%d%H%M%S`";
		echo "$current_date_time Text extract complete, removing ${files[i]} ${files[i+1]} ${files[i+2]} ${files[i+3]} ${files[i+4]} ${files[i+5]} ${files[i+6]} ${files[i+7]}..."
		rm ${files[i]} ${files[i+1]} ${files[i+2]} ${files[i+3]} ${files[i+4]} ${files[i+5]} ${files[i+6]} ${files[i+7]}
	done

current_date_time="`date +%Y%m%d%H%M%S`";
echo "$current_date_time Conversion Complete, moving $f to finished folder"
mv "${f%.pdf}.imp" $f
mv $f finished

echo "Clearing /tmp files" 
rm -f /tmp/magick*

done


