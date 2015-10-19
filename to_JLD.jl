using Geodesy, DataFrames, JLD, Base.Dates


#To select the ride that we keep, given nodes and times (do not have to modify the rest)

# function good_ride(pT::DateTime, dT::DateTime, pN::Int, dN::Int)
#   #return (dayofweek(pT) <= 5) && (12 <= hour(dT) <= 14) &&
#   #       (dayofweek(dT) <= 5) && (12 <= hour(dT) <= 14)
#   return true
# end
#
# #
#
MANHATTAN_CENTER = LLA(40.782, -73.9706)

PTIME,DTIME,PLONG,PLAT,DLONG,DLAT,FARE,TIP = 1,2,3,4,5,6,7,8
for j in 1:12
  df = DataFrame(pTime= DateTime[], dTime= DateTime[],pX=Float32[], pY=Float32[], dX=Float32[], dY=Float32[], fare=Float32[], tip=Float32[])
  println("Opening data/reduced_trip_$j.csv")
  f = open("data/reduced_trip_$j.csv")
  for (i, ln) in enumerate(eachline(f))
    if i == 1
      continue
    end
    if i%1000000 == 0
      println(i)
    end
    s = split(ln,",")
    pENU = ENU(LLA(parse(Float64,s[PLAT]),parse(Float64,s[PLONG])),MANHATTAN_CENTER)
    dENU = ENU(LLA(parse(Float64,s[DLAT]),parse(Float64,s[DLONG])),MANHATTAN_CENTER)


    pT = DateTime(s[PTIME], "y-m-d H:M:S")
    dT = DateTime(s[DTIME], "y-m-d H:M:S")

    push!(df,[pT,dT,pENU.east, pENU.north, dENU.east, dENU.north, parse(Float32, s[FARE]), parse(Float32, s[TIP])])
  end
  save("data/reduced_trip_$j.jld","df",df)
end
