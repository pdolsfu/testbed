#!/bin/bash

# sign problems
fp=$1
ftmp=sign.tmp
clist1='A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9'
clist2='A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9'

f=`cat $fp | grep -v '<signature>' | grep -v '<!--signature'`
g=
for c1 in $clist1; do
	for c2 in $clist2; do
		g="<signature> $c1$c2 </signature>"
		a=`echo "$f" | sed "6i$g"`
		s=`echo "$a" | tr -d ' ' | tr -d '	' | tr -d '' | md5sum`
		if [ ${s:0:2} = 00 ]; then
			echo "$a"
			echo "$s"
			echo "$a" > $fp
			exit
		fi
	done
done
echo "UNSIGNED" >> $fp
