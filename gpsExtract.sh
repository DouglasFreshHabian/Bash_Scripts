#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 IMG_0011.HEIC"
  exit 1
fi

LAT=$(exiftool -c "%.8f" -GPSLatitude "$1" | awk -F: '{print $2}' | xargs)
LON=$(exiftool -c "%.8f" -GPSLongitude "$1" | awk -F: '{print $2}' | xargs)

echo "Latitude:  $LAT"
echo "Longitude: $LON"
echo "Google Maps URL:"
echo "https://www.google.com/maps/search/?api=1&query=${LAT},${LON}"
