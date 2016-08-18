# HTML PDF Generator

This script allows you to generate html pages to host your pdfs. This is used on my website for each of my publications.



# Running

./template.sh pandoc_test/sample.md improving_datacenter.html Improving_Datacenter_Performance_and_Robustness_with_Multipath_TCP /Users/lucasch/Dropbox/Lass/mptcp/multipath_pdfs/p266-raiciu.pdf


`./template.sh SNIPPET OUTPUT_NAME PDF_TITLE PDF_LOCATION`

Key:
- SNIPPET ==> Markdown file name for abstract or summary
- OUTPUT_NAME ==>the name to use for the folder where the html is stored. Must not exist already
- PDF_TITLE ==> Title of the pdf to display on the html. Use  underscores to separate words in the title. If the title is "Improving Datacenter Performance" then you would use: Improving_Datacenter_Performance 
- PDF_LOCATION ==> Location where the pdf is currently stored 
