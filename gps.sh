#!/bin/bash

# Usage check
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/folder"
    exit 1
fi

FOLDER="$1"
OUTPUT="gps_coordinates.csv"

# CSV header
echo "Filename,Latitude,Longitude,GoogleMapsURL" > "$OUTPUT"

# Loop through all HEIC/JPEG images in the folder
for FILE in "$FOLDER"/*.{HEIC,heic,JPG,jpg,JPEG,jpeg}; do
    # Skip if no files match
    [ -e "$FILE" ] || continue

    # Extract decimal GPS coordinates using exiftool
    LAT=$(exiftool -c "%.8f" -GPSLatitude "$FILE" | awk -F: '{print $2}' | xargs)
    LON=$(exiftool -c "%.8f" -GPSLongitude "$FILE" | awk -F: '{print $2}' | xargs)

    # Skip files without GPS data
    if [ -z "$LAT" ] || [ -z "$LON" ]; then
        continue
    fi

    # Build Google Maps URL
    URL="https://www.google.com/maps/search/?api=1&query=${LAT},${LON}"

    # Append to CSV
    echo "$(basename "$FILE"),$LAT,$LON,$URL" >> "$OUTPUT"
done

echo "Done! Coordinates saved to $OUTPUT"
