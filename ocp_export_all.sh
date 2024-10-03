#!/bin/bash

# Set the output directory
OUTPUT_DIR="openshift_exports"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if the NAME parameter is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a name for the tar file (e.g. do316)"
  exit 1
fi

# Set the NAME parameter
NAME="$1"

# Export all resources
echo "Exporting resources..."
echo "---------------------"
echo " 1/12: Exporting all resources..."
oc get all -A -o yaml > "$OUTPUT_DIR/all.yaml"
echo " 2/12: Exporting pods..."
oc get pods -A -o yaml > "$OUTPUT_DIR/pods.yaml"
echo " 3/12: Exporting services..."
oc get svc -A -o yaml > "$OUTPUT_DIR/services.yaml"
echo " 4/12: Exporting deployments..."
oc get deployments -A -o yaml > "$OUTPUT_DIR/deployments.yaml"
echo " 5/12: Exporting replicasets..."
oc get replicasets -A -o yaml > "$OUTPUT_DIR/replicasets.yaml"
echo " 6/12: Exporting statefulsets..."
oc get statefulsets -A -o yaml > "$OUTPUT_DIR/statefulsets.yaml"
echo " 7/12: Exporting daemonsets..."
oc get daemonsets -A -o yaml > "$OUTPUT_DIR/daemonsets.yaml"
echo " 8/12: Exporting cronjobs..."
oc get cronjobs -A -o yaml > "$OUTPUT_DIR/cronjobs.yaml"
echo " 9/12: Exporting jobs..."
oc get jobs -A -o yaml > "$OUTPUT_DIR/jobs.yaml"
echo "10/12: Exporting configmaps..."
oc get configmaps -A -o yaml > "$OUTPUT_DIR/configmaps.yaml"
echo "11/12: Exporting secrets..."
oc get secrets -A -o yaml > "$OUTPUT_DIR/secrets.yaml"
echo "12/12: Exporting namespace-specific resources..."
for namespace in $(oc get namespaces -o jsonpath='{.items[*].metadata.name}'); do
  echo "  Exporting resources for namespace $namespace"
  oc get all -n "$namespace" -o yaml > "$OUTPUT_DIR/$namespace.yaml"
done

echo "Compressing resources..."
DATE_TIME=$(date +"%Y%m%d_%H%M%S")
tar -czf "${NAME}-${DATE_TIME}.tar.gz" "$OUTPUT_DIR" DO316

echo "Removing output directory..."
if [ "$(ls -A "$OUTPUT_DIR" | wc -l)" -eq 0 ]; then
  rm -rf "$OUTPUT_DIR"
fi

echo "Done!"