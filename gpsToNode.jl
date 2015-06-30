using KDTrees, TaxiSimulation, Geodesy, DataFrames

m=Manhattan()
MANHATTAN_CENTER = LLA(40.782, -73.9706)

month = 1
firstDay = 8
lastDay = 13

for j = firstDay:lastDay
    @printf("2013-%02i-%02i\n",month,j)
    df = readtable(@sprintf("data/2013-%02i-%02i.csv",month,j))
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


    nodes = Array(Float64, (2,length(m.positions)))
    for (i,p) in enumerate(m.positions)
        nodes[1,i] = p.x
        nodes[2,i] = p.y
    end

    tree = KDTree(nodes)
    pnode = Int[knn(tree,[px[i],py[i]],1)[1][1] for i in 1:length(px)]
    dnode = Int[knn(tree,[dx[i],dy[i]],1)[1][1] for i in 1:length(dx)]

    delete!(df,:plat)
    delete!(df,:plong)
    delete!(df,:dlat)
    delete!(df,:dlong)

    df[:px] = px
    df[:py] = py
    df[:dx] = dx
    df[:dy] = dy
    df[:pnode] = pnode
    df[:dnode] = dnode
    writetable(@sprintf("data/2013-%02i-%02i-new.csv",month,j),df)
end
