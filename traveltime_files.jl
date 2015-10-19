using KDTrees, TaxiSimulation, JLD, Base.Dates, DataFrames, LightGraphs

#Ride selector
function good_ride(df::DataFrame, i::Int)
  # testing time of day
  if dayofweek(df[i, :pTime]) <= 5 && 12 <= hour(df[i,:pTime]) <= 14 &&
  dayofweek(df[i, :dTime]) <= 5 && 12 <= hour(df[i,:dTime]) <= 14
    #removing rides too short or too long, in time or space
    if  60*1000 <= (df[i,:dTime] - df[i,:pTime]).value <= 60*60*1000 &&
    (abs(df[i,:pX] - df[i,:dX]) + abs(df[i,:pY] - df[i,:dY])) >= 200
      return true
    end
  end
  return false
end

# Create the KDTree used to project onto the nearest node.
m=Manhattan()

nodesX = Float64[]
nodesY = Float64[]
nodesID = Int[]

## NO PICKUP and DROPOFF on HIGHWAYS
for (i,p) in enumerate(m.positions)
  nodeInHighway = false
  for n in out_neighbors(m.network,i)
    nodeInHighway = nodeInHighway || m.roadType[i,n] == 8
  end
  for n in in_neighbors(m.network,i)
    nodeInHighway = nodeInHighway || m.roadType[n,i] == 8
  end
  if !nodeInHighway
    push!(nodesX, p.x)
    push!(nodesY, p.y)
    push!(nodesID, i)
  end
end
nodes = Array(Float64, (2,length(nodesX)))
nodes[1,:] = nodesX
nodes[2,:] = nodesY

tree = KDTree(nodes)

data = DataFrame(pTime = DateTime[], dTime=DateTime[], pNode=Int[], dNode=Int[])

for j in 1:12
  df = load("data/reduced_trip_$j.jld", "df")
  println("Opening reduced_trip_$j.jld ...")

  #second : adding rows to dataFrame
  for i in 1:nrow(df)
    if i%1000000 == 0
      println(i, " - ", nrow(data))
    end
    if good_ride(df,i)
      pN = nodesID[knn(tree,[Float64(df[i,:pX]),Float64(df[i,:pY])],1)[1][1]]
      dN = nodesID[knn(tree,[Float64(df[i,:dX]),Float64(df[i,:dY])],1)[1][1]]
      if pN != dN
        push!(data, [df[i,:pTime], df[i,:dTime], pN, dN])
      end
    end
  end
end
save("data/traveltimes.jld", "df", data)
println("traveltimes.jld created. $(nrow(data)) rows after filtering")
