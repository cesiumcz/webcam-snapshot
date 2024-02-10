#!/bin/bash

CAMERA_LIST="$(dirname "$0")/cameras.txt"
TMPDIR="/tmp/webcam-snapshot"
SNAPDIR="/var/www/data/webcam-snapshot"

# Get current date and time
DATETIME=$(date '+%Y%m%d%H%M%S')

# Foreach webcam entry
while read line; do
	# Skip empty lines
	if [ -z "$line" ]; then
		continue
	fi

	# Skip commented-out lines
	firstchar=$(printf %.1s "$line")
	if [ "$firstchar" = '#' ]; then
		continue
	fi

	read -a wcparam <<< "$line"

	# $wcparam[0] = camera name
	# $wcparam[1] = JPG URL

	CAMTMP="$TMPDIR/${wcparam[0]}"
	CAMSNAP="$SNAPDIR/${wcparam[0]}"
	mkdir -p "$CAMTMP"
	mkdir -p "$CAMSNAP"

	OLD=$(find "$CAMTMP" -name "*.jpg" -exec basename {} ';' | head -1)

	HTTP_CODE=$(curl -s -o "$CAMTMP/$DATETIME.jpg" -w "%{http_code}" "${wcparam[1]}?t=$DATETIME")
	CURL_RETURN=$?

	# Download the latest
	if [ $CURL_RETURN -ne 0 ]; then
		continue
	fi

	if [ $HTTP_CODE -ne 200 ]; then
		rm "$CAMTMP/$DATETIME.jpg"
		continue
	fi

	# If there is no old image, skip check
	if [ -z "$OLD" ]; then
		continue
	fi

	if cmp -s "$CAMTMP/$OLD" "$CAMTMP/$DATETIME.jpg"; then
		# Same image => delete
		rm "$CAMTMP/$DATETIME.jpg"
	else
		# New image => move the old to
		mv "$CAMTMP/$OLD" "$CAMSNAP/"
	fi

done < "$CAMERA_LIST"

exit 0
