##############################################
##  Read data and just get the 2 dates needed:
##############################################
readData <- function(path.name, file.name, column.types, missing.types) {
        read.table( paste(path.name, file.name, sep=""), 
                  colClasses=column.types,
                  header=TRUE,
                  sep=";",
                  na.strings=missing.types)
}

data.path <- "~/Liz/_DataScience/DS4_ExploratoryDataAnalysis/wk1/"
data.file <- "household_power_consumption.txt"
column.types <- "character"
missing.types <- c("NA","", "?")

fulldat <- readData(data.path, data.file, column.types, missing.types)

# only get the two dates in question:
dat <- fulldat[fulldat$Date %in% c("1/2/2007", "2/2/2007"),]

#dat[, 1] <- as.Date(strptime(dat[, 1], "%d/%m/%Y"))
#dat[, 2] <- strptime(dat[, 2], "%H:%M:%S")

## convert these columns to numeric
numeric.cols <- 3:9
for (colnum in numeric.cols) {
        dat[, colnum] <- as.numeric(dat[, colnum])
}


##############################################
##  This assignment:
##############################################
# construct plot on screen:
with(dat,hist(Global_active_power, col="red", xlab="Global Active Power (kilowatts)", main="Global Active Power"))

# write plot to png:
dev.copy(png, file = "plot1.png", width = 480, height = 480)
dev.off()
