library(bigrquery)
library(stringr)
project = "taxi-finance"
month = 6
for (i in 1:30 ) {
  sql <- paste('SELECT FLOAT(trip.pickup_latitude) AS plat, FLOAT(trip.pickup_longitude) AS plong, FLOAT(trip.dropoff_latitude) AS dlat, FLOAT(trip.pickup_longitude) AS dlong, trip.pickup_datetime AS ptime, trip.dropoff_datetime AS dtime, FLOAT(fare.total_amount) AS price, FLOAT(fare.tip_amount) AS tip
FROM [833682135931:nyctaxi.trip_data] AS trip
JOIN EACH [833682135931:nyctaxi.trip_fare] AS fare
ON (trip.pickup_datetime = fare.pickup_datetime) AND (trip.medallion = fare.medallion)
WHERE (FLOAT(trip.pickup_latitude) BETWEEN 40.6994 AND 40.8824)
  AND (FLOAT(trip.pickup_longitude) BETWEEN -74.0204 AND -73.9085)
  AND (FLOAT(trip.dropoff_latitude) BETWEEN 40.6994 AND 40.8824)
  AND (FLOAT(trip.dropoff_longitude) BETWEEN -74.0204 AND -73.9085)
  AND (trip.pickup_datetime) BETWEEN "2013-',str_pad(month,2,pad = "0"), '-',str_pad(i,2,pad = "0"), ' 00:00:00" AND "2013-',str_pad(month,2,pad = "0"), '-', str_pad(i+1,2,pad = "0"), ' 00:00:00"', sep='')
  data <- query_exec(sql,project, max_pages = Inf)
  write.csv( data,
             paste("data/2013-",str_pad(month,2,pad = "0"), "-", str_pad(i,2,pad = "0"), ".csv", sep=''))
  print(i)
}
