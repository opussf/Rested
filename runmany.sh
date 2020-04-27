#!/bin/bash

for n in {001..100}; do
	echo "Running run ${n}"
	ant test > /dev/null
	mv target/reports/testOut.xml target/reports/testOut${n}.xml
done

