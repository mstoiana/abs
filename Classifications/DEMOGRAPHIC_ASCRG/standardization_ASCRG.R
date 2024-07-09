library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)

Data <- read_excel("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCRG/Input/ASCRG_12660DO0001_202303.xlsx", sheet = "Table 1.3", skip = 4)

colnames(Data) <- c("Broad_Group", "Narrow_Group","Group_Code","Religious_Group")

Broad_Group <- Data %>% select(Broad_Group,Narrow_Group) %>% filter(!is.na(Broad_Group) & !is.na(Narrow_Group))
Narrow_Group <- Data %>% select(Narrow_Group,Group_Code) %>% filter(!is.na(Narrow_Group) & !is.na(Group_Code))
Religious_Group <- Data %>% select(Group_Code, Religious_Group) %>% filter(!is.na(Group_Code) & !is.na(Religious_Group))

Broad_Group$Broad_Group_Date <- today()
Narrow_Group$Narrow_Group_Date <- today()
Religious_Group$Religious_Group_Date <- today()

Broad_Group$Broad_Group_Key <- openssl::md5(as.character(Broad_Group$Broad_Group))
Narrow_Group$Narrow_Group_Key <- openssl::md5(as.character(Narrow_Group$Narrow_Group))
Religious_Group$Religious_Group_Key <- openssl::md5(as.character(Religious_Group$Religious_Group))

Broad_Group <- Broad_Group %>% select(Broad_Group_Key, everything())
Narrow_Group <- Narrow_Group %>% select(Narrow_Group_Key, everything())
Religious_Group <- Religious_Group %>% select(Religious_Group_Key, everything())

write_csv(Broad_Group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCRG/Output/ASCRG_Broad_Group.csv")
write_csv(Narrow_Group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCRG/Output/ASCRG_Narrow_Group.csv")
write_csv(Religious_Group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/DEMOGRAPHIC_ASCRG/Output/ASCRG_Religious_Group.csv")



