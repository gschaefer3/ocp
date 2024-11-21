#!/bin/bash

# Define variables
VERSION="4.16"
OUTPUT_CSV="operator_summary.csv"
TEMP_PACKAGE_OUT="package.out"

# Log in to OperatorHub catalogs
echo "Logging into OperatorHub catalogs..."
podman login registry.redhat.io || { echo "Login failed. Exiting."; exit 1; }

# Find available catalogs for the target version
echo "Finding available catalogs for OpenShift version $VERSION..."
CATALOGS=$(oc-mirror list operators --catalogs --version=$VERSION | grep "registry.redhat.io" | awk '{print $1}')

# Initialize the CSV file
echo "catalog,package,channel" > $OUTPUT_CSV

# Loop through each catalog
for CATALOG in $CATALOGS; do
  echo "Processing catalog: $CATALOG"

  # List packages in the catalog
  oc-mirror list operators --catalog=$CATALOG > $TEMP_PACKAGE_OUT
  PACKAGES=$(awk '{if (NR>1) print $1}' $TEMP_PACKAGE_OUT) # Skip header line

  # Loop through each package
  for PACKAGE in $PACKAGES; do
    echo "  Processing package: $PACKAGE"

    # List channels for the package
    CHANNELS=$(oc-mirror list operators --catalog=$CATALOG --package=$PACKAGE | awk '{if ($1 == "cluster-logging" || NR > 3) print $2}')
    
    # Add to CSV
    for CHANNEL in $CHANNELS; do
      echo "$CATALOG,$PACKAGE,$CHANNEL" >> $OUTPUT_CSV
    done
  done
done

# Cleanup
rm -f $TEMP_PACKAGE_OUT

echo "CSV summary created: $OUTPUT_CSV"
