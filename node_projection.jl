using KDTrees, TaxiSimulation, JLD, Base.Dates

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
println(tree)
