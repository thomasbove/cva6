#!/bin/bash

#path of the the file where tests will be merged
dest=run.log

rm -rf $dest
touch $dest

for FILE in $(ls log) 
do 

	#check that the litmus test terminated correctly
	if grep -q Time log/$FILE; then 
		cat log/$FILE >> $dest
		echo "" >> $dest
		i=$((i+1))
	else
		echo "'Time' not found in $FILE"
	fi

done 
echo "Num of tests = $i"