#!/bin/bash
a=`ls *.p.xml`
for f in $a; do
	./signp.sh $f
done
