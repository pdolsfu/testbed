#!/bin/bash

filename=testFun.txt
catename=cate.txt
dlm1="====="
dlm2='\-\-\-\-\-'

# function name
name=
# file name
fname=
# number of variables
nvar=
# bounds
lb=
ub=
# function string
func=
# constraint
cons=

# directory for xmls
mkdir -p problems

# strip DOS line ending
sed -i 's/$//' $filename

function write_xml
{
    if [ ! "$fname" ]; then
        return
    fi

    # display
    echo name: "$name"
    echo file: "$fname"
    echo nvar: "$nvar"
    echo lb  : "$lb"
    echo ub  : "$ub"
    echo cate: "$cate"
    echo func:
    echo "$func"
    echo cons:
    echo "$cons"
    echo -e "\n-----------------------------------------------------------\n"

    # start writing
    f=problems/$fname.p.xml
    echo "<problem>" > $f
    echo "<name>" $name "</name>" >> $f
    echo "<description>" "</description>" >> $f
    echo "<n_variables>" $nvar "</n_variables>" >> $f
    echo "<n_objectives>" "</n_objectives>" >> $f
    echo "<lower_bound>" $lb "</lower_bound>" >> $f
    echo "<upper_bound>" $ub "</upper_bound>" >> $f

    default_IFS=$IFS
    IFS=$'\n'
    for line in $cons; do
        echo "<constraint>" $line "</constraint>" >> $f
    done
    for line in $cate; do
        echo "<category>" $line "</category>" >> $f
    done
    for line in $func; do
        echo "<function>" $line "</function>" >> $f
    done
    IFS=$default_IFS

    echo "</problem>" >> $f
}

while read line
do
    # stage determination
    if [ "$(echo $line | grep $dlm1)" ]; then
        stage=name

        # get category names and write xml file
        cate=$(grep ^$fname: $catename | sed 's/^.*://' | sed 's/,$//' | tr ',' '\n')
        write_xml

        # clear previous content
        nvar=
        lb=
        ub=
        func=
        cons=
        continue
    fi
    if [ "$(echo $line | grep $dlm2)" ]; then
        if [ $stage = name ]; then
            stage=bound
        elif [ $stage = bound ]; then
            stage=func
        elif [ $stage = func ]; then
            stage=cons
        fi
        continue
    fi

    # for differnt stages
    case "$stage" in
    name)
        name=$(echo $line)
        fname=$(echo $name | tr ' ' '_' | tr [A-Z] [a-z])
        ;;
    bound)
        if [ "$(echo "$line" | grep 'nob.*=')" ] || [ "$(echo "$line" | grep 'nv.*=')" ]; then
            nvar=$(echo $line | sed 's/^.*=\(.*\);.*$/\1/')
        elif [ "$(echo $line | grep xlv)" ]; then
            lb=$(echo "$line" | sed 's/^.*=\(.*\);.*$/\1/' | sed s/nv/$nvar/g )
            if [ "$lb" = "[]" ]; then
                lb=
            fi
        elif [ "$(echo "$line" | grep xuv)" ]; then
            ub=$(echo "$line" | sed 's/^.*=\(.*\);.*$/\1/' | sed s/nv/$nvar/g )
            if [ "$ub" = "[]" ]; then
                ub=
            fi
        fi
        ;;
    func)
        func=$func$'\n'$line
        ;;
    cons)
        cons=$cons$'\n'$line
        ;;
    *)
        ;;
    esac
done < $filename

