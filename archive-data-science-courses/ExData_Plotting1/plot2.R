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

# convert the Date and Time variables to one DateTime variable:
dat[, 10] <- as.POSIXct(paste(dat$Date, dat$Time), format="%d/%m/%Y %H:%M:%S")
colnames(dat) <- c(colnames(fulldat),"DateTime")

## convert these columns to numeric
numeric.cols <- 3:9
for (colnum in numeric.cols) {
        dat[, colnum] <- as.numeric(dat[, colnum])
}


##############################################
##  This assignment:
##############################################
# open file device to plot to png:
png(file = "plot2.png", width = 480, height = 480)

# construct plot:
with(dat, plot(DateTime, Global_active_power, type="n", xlab = "", ylab="Global Active Power (kilowatts)"))
with(dat,lines(DateTime,Global_active_power))

# close device
dev.off()
