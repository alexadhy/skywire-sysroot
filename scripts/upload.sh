#!/usr/bin/env bash

file="$1"
bucket=skywire-bucket
contentType="application/x-compressed-tar"
dateValue=$(date -R)
curl -X PUT -T "${file}" \
  -H "Host: ${bucket}.ap-south-1.linodeobjects.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: ${PAT}" \
  https://${bucket}.ap-south-1.linodeobjects.com/"${file}"
