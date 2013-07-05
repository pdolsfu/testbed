#/bin/bash
a=`ls *.p.xml`
for line in $a; do
	if [ "`grep 'moo' $line`" ]; then
		sed -i "8i<min_value> </min_value>" $line
		sed -i "8i<min_point> </min_point>" $line
	fi
done
