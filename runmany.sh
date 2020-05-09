#!/bin/bash
ant clean
mkdir -p target/reports
for n in $(seq -f "%05g" 1 9999) ; do
	#echo "Running run $n"
	reportFile="target/reports/testOut.xml"
	ant test > target/reports/antout.txt
	if [ ! "$?" == "0" ]; then
		mv target/reports/antout.txt target/reports/antOut$n.txt
		mv $reportFile target/reports/testOut$n.xml
		ls -alt target/reports/testOut$n.xml
	else
		ls -alt $reportFile
	fi
done
