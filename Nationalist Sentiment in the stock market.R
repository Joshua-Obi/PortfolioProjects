#Working with strictly domestic stocks

#Reducing the dataset to just the 9 countries we're interested in.
DomesticListings <- CrossListings1[CrossListings1$exchangecountry %in% c("england", "france", "spain", "italy", "netherlands", "germany"), ]
DomesticListings <- DomesticListings[DomesticListings$domicilecountry %in% c("england", "france", "spain", "italy", "netherlands", "germany"), ]

#Making sure we have no cross listed firms.
DomesticListings <- subset(DomesticListings, domicilecountry == exchangecountry)

#Specify the dataset and Date
colnames(DomesticListings)[1] <- "Date"
class(DomesticListings$Date)
DomesticListings$Date2 <- as.Date( as.character(DomesticListings$Date), "%Y-%m-%d")
class(DomesticListings$Date2)

#Subset the data so that it includes the last 10 years of data
DomesticListings <- subset(DomesticListings, Date2 > as.Date("2008-01-01"))
DomesticListings <- select(DomesticListings, c(1,2,6))

#Remove the repeated terms
DomesticListings <- DomesticListings[ grep("COREM PROPERTY GROUP", DomesticListings$companyname, invert = TRUE) , ]
DomesticListings <- DomesticListings[ grep("OSCAR", DomesticListings$companyname, invert = TRUE) , ]



#Pivotting data
DomesticListings2 <- spread(DomesticListings, companyname, openingprice)
DomesticListings2$exchangecountry <- NULL
DomesticListings2$domicilecountry <- NULL
DomesticListings2$Date2 <- NULL
DomesticListings2$currency <- NULL
CrossListings$numshares <- NULL

#######
#This is code to remove the comapnies that have less than 97% of NA free data.
# Use 97% is an arbitrage value but it is used as it still gives a good amount of data
DomesticListings2 <- DomesticListings2[, which(colMeans(!is.na(DomesticListings2)) > 0.97)]


#So now we have only firms where 97% of their prices are NA free.
#Going to remove the remaining NAs by hand, then start the returns process as specified by mack.
DomesticListings2 <- DomesticListings2[which(rowMeans(!is.na(DomesticListings2)) > 0.97), ]


class(DomesticListings2$Date)

#Use this code to export the headings for the dataframes
DomCol <- as.data.frame(colnames(DomListings))
write_xlsx(DomCol,"/Users/joshuaobi/Desktop/King's College/Dissertation/Methodology/DomCol.xlsx")

DecCol <- as.data.frame(colnames(DecListings))
write_xlsx(DecCol,"/Users/joshuaobi/Desktop/King's College/Dissertation/Methodology/DecCol.xlsx")



#Interpolate, so there are no NAs.
DomesticListings2 <- na_interpolation(DomesticListings2)

#Find out the number of NAs
sum(is.na(DomesticListings2))

#Now have 0 NAs

#Create a date function
DomDates <- tail(DomesticListings2$Date,-1)


#Make all company values stationary 
#Check the stationarity of the opening prices 
adf.test(DomesticListings2$A2A)
adf.test(DomesticListings2$`ACANTHE DVPPT.`)

#ADF said they are non stationary, so we need to loop the prices into returns
#First create a date function, and remove the dates from the original dataset
#This is so I can run a loop on the remaining numeric values to compute returns
DomesticListings2$Date <- NULL

#Now loop the prices to form returns and re-add the date function
DomesticListings2 <- log(DomesticListings2[2:nrow(DomesticListings2),]/DomesticListings2[1:nrow(DomesticListings2)-1,])
DomesticListings2$Date <- c(as_date(DomDates))


MDomDate <- as.data.frame(DomesticListings2$Date)
colnames(MDomDate)[1] <- "Date"


DomListings <- merge(DomesticListings2, MDecDate, by = "Date")
DateVariable <- DomListings$Date
class(DateVariable)
MMDate <- as.data.frame(Premium$Date)



CLC <- read.csv("CLC Info1.csv")




#########
# Now start from the code Mack gave
colnames(CLC)[1] <- "companyname"
Premium$Date <- as.Date(Premium$Date)
colnames(Premium)[1] <- "Date"
Premium$Date <- NULL


#Make the columns names conform to the same format 
cols <- colnames(Premium)
cols <- gsub('\\(.*?\\)','', cols) 
cols <- gsub(" ","",cols, fixed = TRUE)


#Renaming 
oldcols <- colnames(Premium)
names <- as.data.frame(cbind(cols, oldcols))
mm <- match(names(Premium), names$oldcols)
names(Premium)[!is.na(mm)] <- as.character(names$cols[na.omit(mm)])

Premium <- as.data.frame(cbind(MMDate,Premium))
colnames(dfnew)[2] <- "companyname1"


#Make a new dataframe of the repeated premiums
dfnew <- gather(Premium, key = "companyname", value = "return", `3IGROUP`:WOLTERSKLUWER)


#Introduce a second data frame of the countries that the firms operate in
df <- CLC
df <-df[rep(seq_len(nrow(CLC)), each = 2575), ]
df <- df[ grep("WPP", df$companyname, invert = TRUE) , ]
dfnew <- dfnew[ grep("WPP", df$companyname, invert = TRUE) , ]



#Combine the 2 dataframes to produce a single 1
Fdf <- cbind(dfnew, df)
Fdf$Foreign.Market.Name <- NULL
Fdf$Domestic.Market.Name <- NULL

Ndf <- Fdf[Fdf$Date %in% c("2009-05-28","2009-06-04"),]


  
DFN1 <- subset(Fdf, Date == ("2008-06-18"))
DFN2 <- subset(Fdf, Date == ("2010-09-06"))
DFN3 <- subset(Fdf, Date == ("2012-06-29"))
DFN4 <- subset(Fdf, Date == ("2014-07-07"))
DFN5 <- subset(Fdf, Date == ("2016-07-04"))
DFN6 <- subset(Fdf, Date == ("2016-07-08"))
DFN7 <- subset(Fdf, Date == ("2017-11-13"))

NDF <- rbind(DFN1, DFN2, DFN3, DFN4, DFN5, DFN6, DFN7)

write_xlsx(NDF,"/Users/joshuaobi/Desktop/King's College/Dissertation/Methodology/NDF.xlsx")


#Create individual dataframes for each home nation
ENGDF <- Fdf[-grep("England", Fdf$Domestic.Country, invert = TRUE) ,]
SWEDF <- Fdf[-grep("Sweden", Fdf$Domestic.Country, invert = TRUE) ,]
BELDF <- Fdf[-grep("Belgium", Fdf$Domestic.Country, invert = TRUE) ,]
AUSDF <- Fdf[-grep("Austria", Fdf$Domestic.Country, invert = TRUE) ,]
FRADF <- Fdf[-grep("France", Fdf$Domestic.Country, invert = TRUE) ,]
ITADF <- Fdf[-grep("Italy", Fdf$Domestic.Country, invert = TRUE) ,]
NEDDF <- Fdf[-grep("Netherlands", Fdf$Domestic.Country, invert = TRUE) ,]
SPADF <- Fdf[-grep("Spain", Fdf$Domestic.Country, invert = TRUE) ,]
SWIDF <- Fdf[-grep("Switzerland", Fdf$Domestic.Country, invert = TRUE) ,]
GERDF <- Fdf[-grep("Germany", Fdf$Domestic.Country, invert = TRUE) ,]

NDF1 <- read.csv("NDF1.csv")

Win.Dummy <- NDF1$Win.Dummy
Loss.Dummy <- NDF1$Loss.Dummy
return <- NDF1$return

linearMod1 <- lm(return ~ Win.Dummy + Loss.Dummy)
summary(linearMod1)

linearMod <- lm(Win.Dummy + Loss.Dummy ~ return, data=NDF1)
summary(linearMod)
stargazer(linearMod1, type = "html", out = "Prelim.html")


#Export dataframes to have the same column names
#colPrem <- colnames(Premium)
#colPrem <- as.data.frame(colPrem)
#write_xlsx(colPrem,"/Users/joshuaobi/Desktop/King's College/Dissertation/Methodology/premium.xlsx")


