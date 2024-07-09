library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)

Data <- read_excel("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCL/Input/ASCL_12670DO0001_201703.xls", sheet = "Table 1.3", skip = 4)

colnames(Data) <- c("Broad_Group", "Narrow_Group_2","Narrow_Group_3","Narrow_Group_3_Description", "Language_Code", "Language_Description")

Broad_Group <- Data %>% select(Broad_Group,Narrow_Group_2) %>% filter(!is.na(Broad_Group) & !is.na(Narrow_Group_2))
Narrow_Group_2 <- Data %>% select(Narrow_Group_2, Narrow_Group_3) %>% filter(!is.na(Narrow_Group_2) & !is.na(Narrow_Group_3))
Narrow_Group_3 <- Data %>% select(Narrow_Group_3, Narrow_Group_3_Description) %>% filter(!is.na(Narrow_Group_3) & !is.na(Narrow_Group_3_Description))
Language <- Data %>% select(Language_Code, Language_Description) %>% filter(!is.na(Language_Code) & !is.na(Language_Description))

Broad_Group$Broad_Group_Date <- today()
Narrow_Group_2$Narrow_Group_2_Date <- today()
Narrow_Group_3$Narrow_Group_3_Date <- today()
Language$Language_Date <- today()

Broad_Group$Broad_Group_Key <- openssl::md5(as.character(Broad_Group$Broad_Group))
Narrow_Group_2$Narrow_Group_2_Key <- openssl::md5(as.character(Narrow_Group_2$Narrow_Group_2))
Narrow_Group_3$Narrow_Group_3_Key <- openssl::md5(as.character(Narrow_Group_3$Narrow_Group_3))
Language$Language_Key <- openssl::md5(as.character(Language$Language_Code))

Broad_Group <- Broad_Group %>% select(Broad_Group_Key, everything())
Narrow_Group_2 <- Narrow_Group_2 %>% select(Narrow_Group_2_Key, everything())
Narrow_Group_3 <- Narrow_Group_3 %>% select(Narrow_Group_3_Key, everything())
Language <- Language %>% select(Language_Key, everything())

write.csv(Broad_Group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCL/Output/Broad_Group.csv", row.names = FALSE)
write.csv(Narrow_Group_2, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCL/Output/Narrow_Group_2.csv", row.names = FALSE)
write.csv(Narrow_Group_3, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCL/Output/Narrow_Group_3.csv", row.names = FALSE)
write.csv(Language, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCL/Output/Language.csv", row.names = FALSE)



