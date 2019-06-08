library(data.table)
library(readr)

Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
options(scipen=999)

base_url <- "https://bag.basisregistraties.overheid.nl/bag/id/"

hgAddress <- paste(base_url,"nummeraanduiding/0",sep="")
hgBuilding <- paste(base_url,"pand/0",sep="")
hgPlace <- paste(base_url,"woonplaats/0",sep="")
hgStreet <- paste(base_url,"openbare-ruimte/0",sep="")

field_suff <- "bagurl"

base_dir <- "/Users/SB/Downloads/Histo/"
file_in <- paste(base_dir,"1453223668.csv",sep="")
file_out <- paste(base_dir,"out.csv",sep="")
file_diff <- paste(base_dir,"diff.csv",sep="")
file_orig <- paste(base_dir,"orig.csv",sep="")

hg_key <- ""
hg_type <- NULL
hg_type <- "type"
hg_fixed_type <- hgStreet
hg_id <- c("bagid","same_as_2")
#hg_na <- '""'
hg_na <- ""
hg_quote <- TRUE

sep <- ","
#sep <- ";"
escape_backslash <- TRUE
escape_double <- !escape_backslash
if (escape_backslash){
  qmethod <- "escape"
}else{
  qmethod <- "double"
}

col_types <- NULL
#col_types <- cols("validSince" = col_character(),"validUntil" = col_character(),"periodValidFor" = col_character())
#col_types <- cols("monumentnr" = col_integer(), "rm_lat" = col_character(),"rm_lon" = col_character())
#col_types <- cols("OBJECTID" = col_integer())
#col_types <- cols("id"=col_integer(), "start-min"=col_character(), "start-max"=col_character(), "originated"=col_character(), "lies in"=col_character())
col_types <- cols("verdwenen"=col_character(), "intersects"=col_character(), "id"=col_character())

datasetHG <- read_delim(file_in,sep, escape_backslash=escape_backslash, escape_double=escape_double, na=hg_na,
                        col_types=col_types)

if (length(problems(datasetHG)$row) > 0){
  stop("There are problems in parsing")
}

datasetHGOrig <- datasetHG

if (hg_key != ""){
  datasetHG <- data.table(datasetHG,key=hg_key)
}else{
  datasetHG <- data.table(datasetHG)  
}

datasetHG[,same_as := NULL]

if (length(grep("bag/",datasetHG)) != length(hg_id)){
  stop("Too many columns have bag elements")
}


#fix id
#datasetHG$Id <- as.numeric(1:nrow(datasetHG))

#datasetHG[hg_type == "hg:Street","hg_id"]

if (hg_type != "" ){
  
  for( i in 1:length(hg_id)){
    
    hgColName <- paste(hg_id[i],field_suff,sep="_")
    
    datasetHG$new_col <- ""
    colnames(datasetHG)[colnames(datasetHG) == "new_col"] <- hgColName
    
    datasetHG[get(hg_type) == "hg:Address",eval(hgColName) := gsub("bag/", hgAddress, get(hg_id[i]))]
    datasetHG[get(hg_type) == "hg:Building",eval(hgColName) := gsub("bag/", hgBuilding, get(hg_id[i]))]
    datasetHG[get(hg_type) == "hg:Place",eval(hgColName) := gsub("bag/", hgPlace, get(hg_id[i]))]
    datasetHG[get(hg_type) == "hg:Street",eval(hgColName) := gsub("bag/", hgStreet, get(hg_id[i]))]
    
  }
}else{
  print("WARNING type is fixed")
  datasetHG$new_col <- ""
  colnames(datasetHG)[colnames(datasetHG) == "new_col"] <- field_suff
  datasetHG[,eval(field_suff) := gsub("bag/", hg_fixed_type, get(hg_id))]
}

write.table(datasetHG,file=file_out,sep=",",quote=hg_quote,row.names = FALSE,qmethod=qmethod, na=hg_na)

if (length(hg_type) > 0 ){
  colToRem <- paste(hg_id,field_suff,sep="_")
}else{
  colToRem <- field_suff
}

write.table(datasetHG[,-which(colnames(datasetHG) %in% colToRem),with=FALSE],file=file_diff,sep=sep,quote=hg_quote,row.names = FALSE,qmethod=qmethod, na=hg_na)

write.table(datasetHGOrig,file=file_orig,sep=sep,quote=hg_quote,row.names = FALSE,qmethod=qmethod, na=hg_na)
