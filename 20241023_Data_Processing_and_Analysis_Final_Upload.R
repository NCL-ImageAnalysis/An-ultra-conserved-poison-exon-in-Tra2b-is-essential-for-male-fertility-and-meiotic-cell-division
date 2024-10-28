##All the packages that will be necessary for the running of this graphing and analysis macro
library(ggplot2)
library(dplyr)
library(readr)
library(FSA)
library(tidyr)


##Define the Location of the csv File for Assessment, make sure this matches perfectly (including capitalisation)
d <- read.csv("Y:/Bioimaging_Staff/George/20240911_Caroline/Macro_Test/Collated_Data_V6.csv")

##Creates three sets of data, one for each channel, but matched in rows
dChan1 <- subset(d, Channel == "Channel 1")
dChan2 <- subset(d, Channel == "Channel 2")
dChan3 <- subset(d, Channel == "Channel 3")

##Creates a fourth set of data just containing the image name and cell number for each row in the three new datasets
dCombinedr <- d %>%
  group_by(Image_Name, Cell_Number, X, Y) %>%
  summarise()

##Combines the datasets together so each cell represents a single row
dCombinedr$Chan1_Mean = (as.numeric(dChan1$Mean))
dCombinedr$Chan2_Mean = (as.numeric(dChan2$Mean))
dCombinedr$Chan3_Mean = (as.numeric(dChan3$Mean))
dCombinedr$Chan1_Std = (as.numeric(dChan1$StdDev))
dCombinedr$Chan2_Std = (as.numeric(dChan2$StdDev))
dCombinedr$Chan3_Std = (as.numeric(dChan3$StdDev))

##Defines the treatment group based on the title of the image
dCombinedr$Treatment <- ""
dCombinedr$Treatment <- ifelse(grepl("WT", dCombinedr$Image_Name), "WT", dCombinedr$Treatment)
dCombinedr$Treatment <- ifelse(grepl("het", dCombinedr$Image_Name), "WT", dCombinedr$Treatment)
dCombinedr$Treatment <- ifelse(grepl("KO", dCombinedr$Image_Name), "KO", dCombinedr$Treatment)

##Defines the age of the specimen based on the title of the image
dCombinedr$Age <- ""
dCombinedr$Age <- ifelse(grepl("p12", dCombinedr$Image_Name), "p12", dCombinedr$Age)
dCombinedr$Age <- ifelse(grepl("p23", dCombinedr$Image_Name), "p23", dCombinedr$Age)
dCombinedr$Age <- ifelse(grepl("adult", dCombinedr$Image_Name), "Adult", dCombinedr$Age)

##Subsets the data to only look at the "p12" age group
dCombinedr <- subset(dCombinedr, Age == "p12")

##Creates a jitter plot with violin plot for all the data with channel 1 intensity of each nucleus
dCombinedr %>%
  ggplot(aes(x = Treatment, y = as.numeric(Chan1_Mean), color = Treatment)) +
  xlab("Treatment") + ylab("Mean Nuclear Intensity channel 1") +
  theme_classic() +
  ##ylim(0, 3) +
  ##xlim(0, 3000) +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ##scale_color_gradient(low="#648FFF", high="#FFB000") +
  theme(legend.position = "none") +
  geom_violin(alpha = 0.5, linewidth = 1) +
  geom_jitter(position=position_jitterdodge(jitter.width = 0.5), alpha = 0.1, size = 0.5)


##Creates a jitter plot with violin plot for all the data with channel 2 intensity of each nucleus
dCombinedr %>%
  ggplot(aes(x = Treatment, y = as.numeric(Chan2_Mean), color = Treatment)) +
  xlab("Treatment") + ylab("Mean Nuclear Intensity channel  2") +
  theme_classic() +
  ##ylim(0, 3) +
  ##xlim(0, 3000) +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ##scale_color_gradient(low="#648FFF", high="#FFB000") +
  theme(legend.position = "none") +
  geom_violin(alpha = 0.5, linewidth = 1) +
  geom_jitter(position=position_jitterdodge(jitter.width = 0.5), alpha = 0.1, size = 0.5)


##Creates a jitter plot with violin plot for all the data with channel 3 intensity of each nucleus
dCombinedr %>%
  ggplot(aes(x = Treatment, y = as.numeric(Chan3_Mean), color = Treatment)) +
  xlab("Treatment") + ylab("Mean Nuclear Intensity channel  3") +
  theme_classic() +
  ##ylim(0, 3) +
  ##xlim(0, 3000) +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ##scale_color_gradient(low="#648FFF", high="#FFB000") +
  theme(legend.position = "none") +
  geom_violin(alpha = 0.5, linewidth = 1) +
  geom_jitter(position=position_jitterdodge(jitter.width = 0.5), alpha = 0.1, size = 0.5)


##Generate summary information for the datasets, and perform statistical analysis
dCombinedrwt <- subset(dCombinedr, Treatment == "WT")
dCombinedrtest <- subset(dCombinedr, Treatment == "KO")


dCombinedrwt %>%
  group_by(Image_Name,Treatment) %>%
    summary()


dCombinedrtest %>%
  group_by(Image_Name,Treatment) %>%
  summary()


wilcox.test(as.numeric(Chan1_Mean) ~ Treatment, data = dCombinedr, paired=FALSE)
wilcox.test(as.numeric(Chan2_Mean) ~ Treatment, data = dCombinedr, paired=FALSE)
wilcox.test(as.numeric(Chan3_Mean) ~ Treatment, data = dCombinedr, paired=FALSE)


##Additional Graphs

##Creates a scatter plot for channel 2 intensity vs channel 3 intensity for both treatment groups
dCombinedr %>%
  ggplot(aes(x = as.numeric(Chan2_Mean), y = as.numeric(Chan3_Mean), color = Treatment)) +
  xlab("Nuclear Intensity Channel 2") + ylab("Nuclear Intensity Channel 3") +
  theme_classic() +
  ##ylim(0, 3) +
  ##xlim(0, 3000) +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ##scale_color_gradient(low="#648FFF", high="#FFB000") +
  ##theme(legend.position = "none") +
  geom_point(alpha = 0.05, size = 0.05)

##Creates a scatter plot for channel 2 intensity vs channel 2 standard deviation for both treatment groups
dCombinedr %>%
  ggplot(aes(x = as.numeric(Chan2_Mean), y = as.numeric(Chan2_Std), color = Treatment)) +
  xlab("Chan2_Mean") + ylab("Chan2_Std") +
  theme_classic() +
  ##ylim(0, 3) +
  ##xlim(0, 3000) +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ##scale_color_gradient(low="#648FFF", high="#FFB000") +
  theme(legend.position = "none") +
  geom_point(alpha = 0.1, size = 0.5)

##Creates a scatter plot for channel 3 intensity vs channel 3 standard deviation for both treatment groups
dCombinedr %>%
  ggplot(aes(x = as.numeric(Chan3_Mean), y = as.numeric(Chan3_Std), color = Treatment)) +
  xlab("Chan3_Mean") + ylab("Chan3_Std") +
  theme_classic() +
  ##ylim(0, 3) +
  ##xlim(0, 3000) +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ##scale_color_gradient(low="#648FFF", high="#FFB000") +
  theme(legend.position = "none") +
  geom_point(alpha = 0.1, size = 0.5)