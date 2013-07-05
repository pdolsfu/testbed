#/bin/bash
a=`ls *.p.xml`
for line in $a; do
	if [ "`grep '% [oO]ptimum' $line`" ]; then
		v=`grep '% [oO]ptimum' $line | sed 's/^.*[oO]ptimum is\(.*\)(.*$/\1/'`
		x=`grep '% [oO]ptimum' $line | sed 's/^.*=\(.*\)<.*$/\1/'`
		sed -i "8i<min_value> $v </min_value>" $line
		sed -i "8i<min_point> $x </min_point>" $line
	fi
done
