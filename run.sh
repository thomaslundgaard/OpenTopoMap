#!/bin/sh
#
# 1. Download splitter and mkgmap
# 2. Download sea and bounds files (unzip to specified folders)
# 3. brew install osmium-tool
# 4. Download map files (.osm.pbf)
#    Currently using europe and north-america from download.geofabrik.de
#    GeoJSON editor at geojson.io
# 5. Run this script
#
# Tag viewer: https://www.openstreetmap.org/#map=12/30.5354/102.7140&layers=D
#
# Changes from upstream:
#    - Remove labels
#    - Remove buildings
#    - Trail: double width, shorter breaks, visible at 2-3 higher zoom levels
#    - remove everything but public toilet icons
#    - icons at higher level
#    - no railroads
#    - no sidewalks
#
# To merge several maps:
# osmium merge file1.osm.ppb file2.osm.pbf -o merged.osm
#
# On Watch:
# (Some maps from custom extracts, contours from opentopomap.org)
# ----------------------------------------------------------------
#   Map                                Contours
# ----------------------------------------------------------------
# na-east						us-northeast + us-south
# na-west						us-west
# denmark						denmark
# eu-mountains					alps
# ----------------------------------------------------------------

INDEX=$1 # may not be larger than 9

if [[ $INDEX -eq 1 ]]; then
	MAPFILE="data/na-east.osm.pbf"
	if [ ! -f "$MAPFILE" ]; then
		osmium extract -p areas/na-east.geojson data/north-america-latest.osm.pbf -o "$MAPFILE"
	fi
	MAPNAME="744${INDEX}0001" # beginning must be unique for each map on device
	MAPDESCRIPTION="otm-na-east-tlh"
elif [[ $INDEX -eq 2 ]]; then
	MAPFILE="data/na-west.osm.pbf"
	if [ ! -f "$MAPFILE" ]; then
		osmium extract -p areas/na-west.geojson data/north-america-latest.osm.pbf -o "$MAPFILE"
	fi
	MAPNAME="744${INDEX}0001" # beginning must be unique for each map on device
	MAPDESCRIPTION="otm-na-west-tlh"
elif [[ $INDEX -eq 3 ]]; then
	MAPFILE="data/denmark-latest.osm.pbf"
	MAPNAME="744${INDEX}0001" # beginning must be unique for each map on device
	MAPDESCRIPTION="otm-denmark-tlh"
elif [[ $INDEX -eq 4 ]]; then
	MAPFILE="data/eu-mountains.osm.pbf"
	if [ ! -f "$MAPFILE" ]; then
		osmium extract -p areas/eu-mountains.geojson data/europe-latest.osm.pbf -o "$MAPFILE"
	fi
	MAPNAME="744${INDEX}0001" # beginning must be unique for each map on device
	MAPDESCRIPTION="otm-eu-mountains-tlh"

# Temporary maps
elif [[ $INDEX -eq 8 ]]; then
	MAPFILE="data/us-northeast.osm.pbf"
	MAPNAME="744${INDEX}0001" # beginning must be unique for each map on device
	MAPDESCRIPTION="otm-us-northeast-tlh"
elif [[ $INDEX -eq 9 ]]; then
	MAPFILE="data/greenland.osm.pbf"
	MAPNAME="744${INDEX}0001" # beginning must be unique for each map on device
	MAPDESCRIPTION="otm-greenland-tlh"
else
	echo "Invalid INDEX"
	exit
fi

SPLITTERJAR="software/splitter-r653/splitter.jar"
MKGMAPJAR="software/mkgmap-r4907/mkgmap.jar"
SEA="data/sea"
BOUNDS="data/bounds"

TYPFILE="garmin/style/typ/opentopomap.txt"
OPTIONS="garmin/opentopomap_options"
STYLEFILE="garmin/style/opentopomap"

OUTPUTDIR="output"
OUTPUTFILE="maps/$MAPDESCRIPTION.img"


rm -rf $OUTPUTDIR
java -jar $SPLITTERJAR --precomp-sea=$SEA --output-dir=$OUTPUTDIR $MAPFILE
DATA="$OUTPUTDIR/6324*.pbf"

java -Xmx10g -jar $MKGMAPJAR \
	-c $OPTIONS --style-file=$STYLEFILE \
    --precomp-sea=$SEA --bounds=$BOUNDS \
	--description="$MAPDESCRIPTION" --mapname="$MAPNAME" \
	--family-name="" --series-name="" \
	--max-jobs=5 \
    --output-dir=$OUTPUTDIR $TYPFILE $DATA

echo "Moving result to $OUTPUTFILE"
rm "$OUTPUTFILE"
mv "$OUTPUTDIR/gmapsupp.img" "$OUTPUTFILE"

