
# Load libraries ----------------------------------------------------------
library(tidyverse)
library(here)
library(data.table)


# Load the text files -----------------------------------------------------

# Data downloaded from surf drive:https://surfdrive.surf.nl/files/index.php/s/ZMtLtITQmE1bvYf#

data_path <- here('data', 'IDE')
file_list <- dir(path=data_path)  # list of text files to be read
file_list_noext <-sub(".txt",'', file_list)

text_list<-list() # List to store the files

# Loop to load the files into a list
for (filename in file_list ) {
  
  text_list[filename] <- read_file(here(data_path, filename) )
}

text_data<-as.data.table(do.call(rbind, text_list))# Convert to data.table 
names(text_data) <- 'full_text'

# Add some metadata ------------------------------------------------------------

text_data[,`:=`(full_text_lower = tolower(full_text), 
                filename = file_list,
                filename_noext = file_list_noext,
                file_number = sub('[^0-9]+','',file_list ) %>% as.numeric(),
                author_name_file = sub('[^a-zA-Z]+','', file_list_noext ),
                copyright = str_detect( full_text, '[cC]opyright|©'  )
                )]

# Read the metadata file
text_meta <- readODS::read_ods(here('data', 'metadata', 'theses_IDE_metadata.ods')) %>% as.data.table()

# Join the external metadata file to the main text 
setkey(text_meta, ID)
setkey(text_data, file_number)

text_data <- text_meta[text_data]


# Save the data -----------------------------------------------------------
saveRDS(text_data, here('data_output','text_data.RDS'))







