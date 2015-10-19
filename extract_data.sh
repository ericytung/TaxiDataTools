echo "Unzipping..."
for f in data/*.zip; do
  echo "$f"
  unzip $f -d data
done
rm data/*.zip

echo "Converting to unix format"
for f in data/*.csv; do
  echo "$f"
  dos2unix $f
done

echo "Merging datasets"

for i in {1..12}; do
  echo "$i"
  paste -d, "data/trip_data_$i.csv" <(cut -d',' -f5-11 "data/trip_fare_$i.csv") > "data/trip_$i.csv"
done


rm data/trip_data*
rm data/trip_fare*

julia data_transform.jl
julia to_JLD.jl
