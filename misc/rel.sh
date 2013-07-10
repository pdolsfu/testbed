#!/bin/sh
rm -rf ../testbed_release/
mkdir -p ../testbed_release
cp -r MPS templates problems misc testbed.m testbed_single.m pman.m dman.m calltest.m ctg.m pproc.m LICENSE RELEASE xmltree CalcMD5 COPYRIGHT histNorm displaytable xticklabel_rotate boxplotCsub getting_started_with_a_new_algorithm.txt description_of_problems.docx ../testbed_release
cd ../testbed_release
tar -zcf ../testbed_release_`date +%b%d.tar.gz` *
