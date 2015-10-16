using JLD, DataFrames, Base.Dates

for j in 1:12
    f = open("data/reduced_trip_data_$j.csv")
    df2 = DataFrame(pTime = DateTime[], dTime=DateTime[], pX=Float64[], pY=Float64[], dX=Float64[], dY=Float64[],)
    for (i, ln) in enumerate(eachline(f))
        if i == 1
            continue
        end
        if i%1000000 == 0
            println(i)
        end
        s = split(ln,",")
        p = DateTime(s[1][2:end-1], "y-m-d H:M:S")
        d = DateTime(s[2][2:end-1], "y-m-d H:M:S")
        push!(df2, [p,d, float(s[3]), float(s[4]), float(s[5]), float(s[6])])

    end
    close(f)
    save("data/trip_data_$j.jld","df",df2)
end
