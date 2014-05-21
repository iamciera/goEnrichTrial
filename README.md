#Why Can't I get GO enrich to work 

So I have looked at three different GO enrich scripts.  All of them require subsequent scripts to get the data in the right format, but not included. Or they are using the older ITAG2.3 cds files, which causes file merging errors. 

I promise I will put a detailed tutorial together of how to do GO enrichment for our labs when I finish, but at the moment I am stuck and very sad. 

The was the script I got the furthest with is `goEnrich_tfcmbr_wtcmbr.Rmd` modified from `TomatoTranscriptomeGoJune2011.R`.

Everything works till the last bit, which is pretty confusing. Maybe you wrote it?  Maybe you know how to finish?  Check it out by forking this repo, **all the files you need to run the script are here**. 

##Files 

`0728fas.blast.map.annot.interpro.annex.GOstatMerge.txt` : Long GO categories -Given to me by Aashish

`0728fas.blast.map.annot.interpro.annex.plant_slim.GOstat` : Larger encompassing GO categories. 

`goEnrich_tfcmbr_wtcmbr.Rmd` : The script I am working on.  It is formatted for knitted.  All the code is in these boxes.

    /```{r}
    code
    /```

`tf2cmbr_wtcmbr_DE.pdf`  :  This is the history of my Differential Expression analysis (DE), basically how I generated the output files that contain the list of genes from DE.

`tf2cmbr_wtcmbr_DE1_full.csv` : This file contains a list of all tomato genes from DE analysis, regardless of p-value. 

`tf2cmbr_wtcmbr_DE1_sigonly.csv` : This file contains a list of only significant (.05 cutoff) genes from DE analysis.

`TomatoTranscriptomeGoJune2011.R` : This was the original file I based my script on. 


