using KDTrees, TaxiSimulation, Geodesy, DataFrames, LightGraphs

m=Manhattan()
MANHATTAN_CENTER = LLA(40.782, -73.9706)

months = collect(1:12)
days = Vector{Int}[
collect(7:13), collect(2:2), collect(1:8), collect(1:10), collect(1:8), collect(1:30),
collect(1:0), collect(1:0), collect(1:0), collect(1:0), collect(1:0), collect(1:0)
]


nodesX = Float64[]
nodesY = Float64[]
nodesID = Int[]
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

for month in months, day in days[month]
    @printf("2013-%02i-%02i\n",month,day)

    df = readtable(@sprintf("data/2013-%02i-%02i.csv",month,day))

    px = Array(Float64,nrow(df))
    py = Array(Float64,nrow(df))
    dx = Array(Float64,nrow(df))
    dy = Array(Float64,nrow(df))

    for i = 1:nrow(df)
        pENU = ENU(LLA(df[i,:plat],df[i,:plong]),MANHATTAN_CENTER)
        dENU = ENU(LLA(df[i,:dlat],df[i,:dlong]),MANHATTAN_CENTER)
        px[i] = pENU.east
        py[i] = pENU.north
        dx[i] = dENU.east
        dy[i] = dENU.north
    end

    pnode = Int[nodesID[knn(tree,[px[i],py[i]],1)[1][1]] for i in 1:length(px)]
    dnode = Int[nodesID[knn(tree,[dx[i],dy[i]],1)[1][1]] for i in 1:length(dx)]

    delete!(df,:plat)
    delete!(df,:plong)
    delete!(df,:dlat)
    delete!(df,:dlong)

    df[:pnode] = pnode
    df[:dnode] = dnode
    writetable(@sprintf("data/2013-%02i-%02i-new.csv",month,day),df)
end
