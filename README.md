# TaxiDataExtraction
To extract relevant taxi data for NYC Yellow Cabs databases in Julia

- **google_query.R** : Extract one day of data from the dataset, linking the two datasets (rides and fares). Origin and destinations of rides are in a rough Rectangle around Manhattan
- **insideManhattan.jl** : Transform CSV outputs of the last file, using a much finer polygonal approximation of Manhattan to remove the rides that are outside.
- **gpsToNode.jl** : Project the GPS locations onto Manhattan nodes. Currently needs the TaxiSimulation package


Rem: All the data files have to be put into a "data" folder.
