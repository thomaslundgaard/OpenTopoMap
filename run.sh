#!/bin/sh
#
# 1. Download splitter and mkgmap
# 2. Download sea and bounds files (unzip to specified folders)
# 3. Download map files (.osm.pbf)
# 4. Run this script
#
# Changes from upstream:
#    - Remove labels
#    - Remove buildings
#    - Trail: double width, shorter breaks, visible at 2-3 higher zoom levels
#    - remove everything but public toilet icons
#    - icons at higher level

if false; then
	MAPFILE="$(pwd)/data/us-northeast.osm.pbf"
	MAPNAME="74380001" # must be unique for each map on device
	MAPDESCRIPTION="otm-tlh-us-northeast"
elif false; then
	MAPFILE="$(pwd)/data/denmark.osm.pbf"
	MAPNAME="74380002" # must be unique for each map on device
	MAPDESCRIPTION="otm-tlh-denmark"
elif true; then
	MAPFILE="$(pwd)/data/greenland.osm.pbf"
	MAPNAME="74380003" # must be unique for each map on device
	MAPDESCRIPTION="otm-tlh-greenland"
elif false; then
	MAPFILE="$(pwd)/data/alps.osm.pbf"
	MAPNAME="74380004" # must be unique for each map on device
	MAPDESCRIPTION="otm-tlh-alps"
else
	return
fi

SPLITTERJAR="$(pwd)/software/splitter-r653/splitter.jar"
MKGMAPJAR="$(pwd)/software/mkgmap-r4907/mkgmap.jar"
SEA="$(pwd)/data/sea"
BOUNDS="$(pwd)/data/bounds"

TYPFILE="$(pwd)/garmin/style/typ/opentopomap.txt"
OPTIONS="$(pwd)/garmin/opentopomap_options"
STYLEFILE="$(pwd)/garmin/style/opentopomap"

OUTPUTDIR="$(pwd)/output"


rm $OUTPUTDIR/6324*.{pbf,img}
java -jar $SPLITTERJAR --precomp-sea=$SEA --output-dir=$OUTPUTDIR $MAPFILE
DATA="$OUTPUTDIR/6324*.pbf"

java -Xmx10g -jar $MKGMAPJAR \
	-c $OPTIONS --style-file=$STYLEFILE \
    --precomp-sea=$SEA --bounds=$BOUNDS \
	--transparent \
	--description="$MAPDESCRIPTION" --mapname=$MAPNAME \
    --output-dir=$OUTPUTDIR $TYPFILE $DATA

echo "If successful, result is available at $OUTPUTDIR/gmapsupp.img"

