## Extract Relevant Information from Raw Behavioural File ##

library("dplyr")
setwd("D:/Select")

d1 <- read.csv("unrestricted.csv")
d2 <- read.csv("restricted.csv")
d <- merge(d1,d2,by="Subject")

# Only select subjects who have the full MRI, the emotion fMRI tasks, and diffusion scans
d <- filter(d, 
            X3T_Full_MR_Compl == "true",
            fMRI_Emo_PctCompl == 100,
            X3T_dMRI_Compl == "true",
            Color_Vision == "NORMAL",
            Breathalyzer_Over_05 == "false",
            Breathalyzer_Over_08 == "false",
            Cocaine == "false",
            THC == "false",
            Opiates == "false",
            Amphetamines == "false",
            MethAmphetamine == "false",
            Oxycontin == "false"
)

write.table(d$Subject, "subjectlist.txt", row.names = FALSE, col.names = FALSE)

# Select a subset of 60 participants to be used in generating a population template
subset <- sample_n(d,60)
write.table(subset$Subject, "subsetlist.txt", row.names = FALSE, col.names = FALSE)
