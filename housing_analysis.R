################################################################################
# More questions based on New Haven property data. We were not required
# to scrape the database here; instead our professor provided a cleaned
# csv file and some homework questions. I'll provide the csv in the repo.
# setwd("~/Desktop/housing_analysis")

x <- read.csv("housing_challenge.csv", as.is=TRUE)
dim(x)
head(x)
tail(x)

## Q2: The variable bathhalf is really two possibly interesting variables:
# the number of full bathrooms and an indicator for whether there is a 
# half bathroom. Create two new numeric variables, with names fullbaths
# and hashalf, by processing the information in bathhalf.

# Q5: Remove the original raw variable bathhalf from the data frame, x.

h <- gsub(".*:1", TRUE, x$bathhalf) 
x$hashalf <- as.numeric(h==TRUE)
x$fullbath <- as.numeric(gsub(":.*", "\\1", x$bathhalf))
x <- x[,-c(8)]

# For the next questions, the variable zone.f is a factor variable indicating the
# property's location in New Haven; totalcurrval is the property value assessment; 
# bedrms is # of bedrooms; livingarea is the total living area in sq feet; actype is 
# an indicator for central air conditioning units; size is amount of land in acres; 
# type is basic architectural style; dep is the percent of depreciation, so 0 would be
# a completely new house.

# Q7: Consider the following model:
# log(totalcurrval) ~ zone.f + sqrt(livingarea) + bedrms
# How much above average (in log(dollars)) does the model 
# predict for values of homes in zone RS3? Provide the "above average"
# number, associated t-statistic, p-value, and whether or not the difference
# is significant.

x$zone.f <- factor(x$zone)
lm.7 <- lm(log(totalcurrval) ~ zone.f + sqrt(livingarea) + bedrms, data=x)
summary(lm.7)

lm.7a <- lm(log(totalcurrval) ~ zone.f + sqrt(livingarea) + bedrms, data=x,
            contrasts=list(zone.f="contr.sum"))
summary(lm.7a)
levels(x$zone.f)

x$zone.f.RS3 <- relevel(x$zone.f, 7)
levels(x$zone.f.RS3)
lm.q7 <- lm(formula = log(totalcurrval) ~ zone.f.RS3 + sqrt(livingarea) +
              bedrms, data = x, contrasts = list(zone.f.RS3 = "contr.sum"))
levels(x$zone.f.RS3)
summary(lm.q7)

# i) -0.006616 below in log dollars for RS3, not statistically sig
# from average, though.
# ii) t-statistic = -0.307
# iii) p-value = 0.759085
# iv) no, not at any of the specified levels
#
#  Q8: write your best model for predicting log(totalcurrval). Do not use "contrast
# sum" for any of the variables. Provide A) the formula, B) the table of coefficients, 
# and then C) save the output in csv with specific naming convention requirements.
#
x$actype.f <- factor(x$actype) # this line provided by professor

lm.best <- lm(log(totalcurrval) ~ sqrt(livingarea) + zone.f + hashalf +
                actype.f + bedrms + dep + log(size) + fullbath, data=x)
lm.best$call  # Part A

lm(formula = log(totalcurrval) ~ sqrt(livingarea) + zone.f + hashalf +
     actype.f + bedrms + dep + log(size) + fullbath, data=x)

round(summary(lm.best)$coefficients, 4)  # Part B

z <- data.frame(TCV = x$totalcurrval,
                predlogTCV = predict(lm.best, newdata=x))
dim(z)
NETID <- "kmd76"
write.table(z, paste("Sep23_", NETID, ".csv", sep=""),
            row.names=FALSE, col.names=TRUE, sep=",")  #Part C

