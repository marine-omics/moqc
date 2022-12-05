args = commandArgs(trailingOnly=TRUE)

report_dir=args[1]

library(tidyverse)


report_files <- list.files(report_dir,pattern = "*.report",full.names = TRUE)

read_report <- function(path){
  s <- basename(path) %>% str_extract("[^\\.]+")
  sample_group <- s %>% str_extract("[^\\-]+")
  read_tsv(path,show_col_types = FALSE,skip=2) %>% 
    add_column(sample=s)
}

report_data <- do.call(rbind,lapply(report_files,read_report))

symbiont_report_data <- report_data %>% 
  filter(taxName %in% c("Symbiodinium microadriaticum","Breviolum minutum","Cladocopium goreaui","Durusdinium trenchii","Fugacium kawagutii")) %>% 
  extract(taxName,into = "Genus",regex = "([^ ]*)")

symbiont_report_data %>% 
  ggplot(aes(x=sample)) + geom_col(aes(y=taxReads,fill=Genus)) + xlab("") + ylab("Number of Classified Reads") + theme(axis.text.x = element_text(angle=90), legend.position = "bottom")


ggsave("symbiont_proportions.png",width=12)

