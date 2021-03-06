#GO term analysis of species DE from Transcriptome analysis June, 2011
#compare a few different GO sets

library(goseq)
library(GO.db)

#this has the DE calls for all detected genes
#change for your file
data <- read.csv("/Users/jmaloof/Documents/Lab Notebook support/2011/Tomato Annotation and GO/KoenigTranscriptome22June2011/pval.FC.csv")

head(data)

summary(data)

names(data)[1] <- "ITAG"

#need length of each ITAG, becuase goseq adjusts for this
#use Biostrings to calculate this
library(Biostrings)

#this is a fasta file of the reference used.
itagSeqs <- read.DNAStringSet("/Users/jmaloof/Documents/Lab Notebook support/2011/SlCDS_ITAG2.3_pseudoGMAP5V61passNoDif.fa")

itagLength <- nchar(itagSeqs) #length of each ITAG

#fix names from fasta file to match those in the expression file
names(itagLength) <- matrix(unlist(strsplit(names(itagSeqs),split="|",fixed=T)),ncol=3,byrow=T)[,1]

head(itagLength)

#create go term list in format needed for goseq
#this file is on smart site at Maloof/Sinha Tomato Group Resources / Data / GOannotation
GOinterpro_annex_merge <-  read.delim("/Users/jmaloof/Documents/Lab Notebook support/2011/Tomato Annotation and GO/ITAG2.3 annotation/GO Annotate ITAG2.3/0728fas.blast.map.annot.interpro.annex.GOstatMerge.txt",row.names=NULL)

#this file is on smart site at Maloof/Sinha Tomato Group Resources / Data / GOannotation
GOinterpro_annex_slim <-  read.delim("/Users/jmaloof/Documents/Lab Notebook support/2011/Tomato Annotation and GO/ITAG2.3 annotation/GO Annotate ITAG2.3/0728fas.blast.map.annot.interpro.annex.plant_slim.GOstat.txt",row.names=NULL)

#check to see if ITAG names are a problem
sum(GOinterpro_annex_merge$ITAG %in% data$ITAG) #17910

#the number from the next command should match the number from the previous command
sum(substr(GOinterpro_annex_merge$ITAG,1,14) %in% substr(data$ITAG,1,14)) #17910 OK

#wrapper function to actually do the GO evalutation
#change the default arguments to match your file 
#FC = fold change info
#pval = adjusted DE pvalues
eval.go <- function(gene.names=data$ITAG,FC=data$FC_spe,pval=data$p.adj.spe,
        FC.thresh=0,p.thresh=.05,go.terms=NULL,
        ilength=itagLength,verbose=TRUE,
				go.cutoff=.1,keep.GO="BP",type="GO") {
  
  #add GO: header if needed
  head(go.terms)
  if (type=="GO" & length(grep("GO",go.terms$GO[1]))==0) {
    go.terms$GO <- gsub("([0-9]{7})","GO:\\1",go.terms$GO)
  }
  
  #remove extra spaces
  go.terms$GO <- gsub(" +","",go.terms$GO)
  
  #get length list to match gene names
  ilength <- ilength[names(ilength) %in% gene.names]

  #filter go terms to match gene list
  go.terms <- go.terms[go.terms$ITAG %in% gene.names,]
  #head(go.terms)
  
  #convert go terms to list
  go.list <- strsplit(as.character(go.terms$GO),split=",")
  head(go.list)
  names(go.list) <- go.terms$ITAG
	
	#filter genes based on criterion
	up <- as.integer(FC > FC.thresh & pval < p.thresh) #upregulated genes
	names(up) <- gene.names
	down <- as.integer(FC < - FC.thresh & pval < p.thresh) #downregulated genes
	names(down) <- gene.names
	
	if (verbose) {
		print(summary(up))
		print(summary(down))
		}
	
	#calculate bias function
	up.pwf <- nullp(up,bias.data=ilength,plot.fit=F)
	down.pwf <- nullp(down,bias.data=ilength,plot.fit=F)
	
	#calculate p-values for over-representation
	up.go <- goseq(up.pwf,gene2cat=go.list)
	down.go <- goseq(down.pwf,gene2cat=go.list)
	
	if (type=="GO") {#add GO term description
		up.go$description <- Term(up.go$category)
		up.go$ontology <- Ontology(up.go$category)
		down.go$description <- Term(down.go$category)
		down.go$ontology <- Ontology(down.go$category)
	
		#filter for GO categories of interest
		up.go <- up.go[up.go$ontology==keep.GO,]
		down.go <- down.go[down.go$ontology==keep.GO,]
	
		#remove NAs
		up.go <- up.go[!is.na(up.go$ontology),]
		down.go <- down.go[!is.na(down.go$ontology),]
	}	
	
	if (type=="mapman") {#add mapman description
		up.go <- merge(up.go,bincodes,by.x="category",by.y="BINCODE",sort=F)
		down.go <- merge(down.go,bincodes,by.x="category",by.y="BINCODE",sort=F)
		}
		
	#adjust for multiple testing
	up.go$upval.adjust <- p.adjust(up.go$over,"fdr")
	down.go$upval.adjust <- p.adjust(down.go$over,"fdr")
		
	#truncate to go.cutoff threshold
	up.go <- up.go[up.go$upval<go.cutoff,]
	down.go <- down.go[down.go$upval<go.cutoff,]
	
	list(up=up.go,down=down.go)
	
	}


GO.sets <- ls(pattern="GO[[:alnum:]]")

#for each GO set loaded, look for enriched terms
for (g in GO.sets) {
    print(g)
    tmp <- eval.go(go.terms=get(g),p.thresh=0.05)
    print("up")
    print(tmp$up[tmp$up$upval.adjust<.1,c(4,6)])
    print("down")
    print(tmp$down[tmp$down$upval.adjust<.1,c(4,6)])
    print("################################")
  }
       


#write results to file
#path for output.
path <- "/Users/jmaloof/Documents/Lab Notebook support/2011/Tomato Annotation and GO/KoenigTranscriptome22June2011/"

FDR <- c(0.01,0.05,.1) #The FDR cutoffs to test for GO enrichment

for (g in GO.sets) {
results.up <- NULL
results.down <- NULL
  for (f in FDR) {
    tmp <- eval.go(go.terms=get(g),p.thresh=f)
    tmp.up <- tmp$up[c(1,4,5,6)]
    tmp.down <- tmp$down[c(1,4,5,6)]
    names(tmp.up)[4] <- paste("pval.adj.FDR",f,sep="")
    names(tmp.down)[4] <- paste("pval.adj.FDR",f,sep="")
    if (is.null(results.up)) {
      results.up <- tmp.up
    } else {
      results.up <- merge(results.up,tmp.up,all=T,by = c("category","description","ontology"))
    }
    if (is.null(results.down)) {
      results.down <- tmp.down
    } else {
      results.down <- merge(results.down,tmp.down,all=T,by = c("category","description","ontology"))
    }
  } #for f
  results.up <- results.up[order(results.up[,length(results.up)]),] #sort by last column of results
  results.down <- results.down[order(results.down[,length(results.down)]),] #sort by last column of results
  write.table(results.up,paste(path,g,"TranscriptomeSPE_UP_GO.tsv",sep=""),sep="\t",row.names=F)
  write.table(results.down,paste(path,g,"TranscriptromeSPE_DOWN_GO.tsv",sep=""),sep="\t",row.names=F)
} # for g
 

