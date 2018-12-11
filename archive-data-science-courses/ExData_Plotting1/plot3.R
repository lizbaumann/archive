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
png(file = "plot3.png", width = 480, height = 480)

# construct plot:
with(dat, plot(DateTime, Sub_metering_1, type="n", xlab = "", ylab="Energy sub metering"))
with(dat,lines(DateTime,Sub_metering_1, col="black"))
with(dat,lines(DateTime,Sub_metering_2, col="red"))
with(dat,lines(DateTime,Sub_metering_3, col="blue"))
legend("topright", lty = 1, lwd = 2, col = c("black", "red", "blue"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

# close device
dev.off()
