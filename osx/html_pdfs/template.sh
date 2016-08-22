#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "./template.sh SNIPPET OUTPUT_NAME PDF_TITLE PDF_LOCATION"
    exit
fi

mkdir $2
cp $4 $2/$2.pdf
pandoc -f markdown $1 > $1_out.html

python produce_page.py $1_out.html $2/index.html $3 $2.pdf



rm -rf $1_out.html


#./template.sh pandoc_test/sample.md improving_datacenter.html Improving_Datacenter_Performance_and_Robustness_with_Multipath_TCP /Users/lucasch/Dropbox/Lass/mptcp/multipath_pdfs/p266-raiciu.pdf
