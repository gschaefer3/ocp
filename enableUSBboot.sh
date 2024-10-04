#!/bin/bash

# Set the iLO hostname and credentials
ILO_HOST=$1
ILO_USERNAME="your_username"
ILO_PASSWORD="your_password"

# Set the URL for the iLO REST API
ILO_URL="https://${ILO_HOST}/rest/v1"

# Log in and get a token
TOKEN=$(curl -k -X POST -H "Content-Type: application/json" -d '{"username": "'${ILO_USERNAME}'", "password": "'${ILO_PASSWORD}'"}' ${ILO_URL}/SessionService/Sessions | jq -r '.token')

# Set the header with the token
HEADER="X-Auth-Token: ${TOKEN}"

# Get the current boot settings
BOOT_SETTINGS=$(curl -k -X GET -H "${HEADER}" ${ILO_URL}/Systems/1/Boot)

# Check if the USB boot option is already enabled
if echo "${BOOT_SETTINGS}" | jq -e '.BootSettings.BootOrder[] | select(.== "USB")' > /dev/null; then
  echo "USB boot option is already enabled"
else
  # Update the boot settings to enable USB boot
  NEW_BOOT_SETTINGS=$(echo "${BOOT_SETTINGS}" | jq '.BootSettings.BootOrder += ["USB"]')
  curl -k -X PATCH -H "${HEADER}" -H "Content-Type: application/json" -d "${NEW_BOOT_SETTINGS}" ${ILO_URL}/Systems/1/Boot
  echo "USB boot option enabled"
fi

# Log out
curl -k -X DELETE -H "${HEADER}" ${ILO_URL}/SessionService/Sessions/${TOKEN}