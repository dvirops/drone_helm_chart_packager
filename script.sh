#!/bin/bash
set -e

if [ -z "$PLUGIN_REPO_NAME" ]; then
  echo "Missing repo_name, can't continue, exiting."
  exit 1
fi

if [ -z "$PLUGIN_REPO_URL" ]; then
  echo "Missing repo_url, can't continue, exiting."
  exit 1
fi

if [ -z "$PLUGIN_CHART_NAME" ]; then
  echo "Missing chart_name, can't continue, exiting."
  exit 1
fi

if [ -z "$PLUGIN_CHART_USERNAME" ]; then
  echo "Missing chart_username, can't continue, exiting."
  exit 1
fi

if [ -z "$PLUGIN_CHART_PASSWORD" ]; then
  echo "Missing chart_password, can't continue, exiting."
  exit 1
fi

if [ -z "$PLUGIN_DOCKER_TAG" ]; then
  echo "Missing docker tag, can't continue, exiting."
  exit 1
fi

if [ -z "$PLUGIN_CHART_VERSION" ]; then
  echo "Missing chart version, can't continue, exiting."
  exit 1
fi

LOWER_CHART_NAME=$(echo "$PLUGIN_CHART_NAME" | tr '[:upper:]' '[:lower:]')
SOURCE_CHART=${PLUGIN_SOURCE_CHART:-generic-name}
PATH_TO_VALUES_FILE=${PLUGIN_PATH_TO_VALUES_FILE:-values.yaml}
CHART_ICON_URL=${PLUGIN_CHART_ICON_URL:-"https://cdn3.iconfinder.com/data/icons/UltimateGnome/256x256/emblems/emblem-generic.png"}

update_chart_name() {
  if [ -f "$LOWER_CHART_NAME"/Chart.yaml ]; then
    sed -i s/generic-name/"$LOWER_CHART_NAME"/g "$LOWER_CHART_NAME"/Chart.yaml
  else
    echo "Chart.yaml file not found" && exit 1
  fi
}

# Replace default values file in the source chart.
move_new_values() {
  if [ -f "$PATH_TO_VALUES_FILE" ]; then
    cp "$PATH_TO_VALUES_FILE" "$LOWER_CHART_NAME"/values.yaml
  else
    echo "$PATH_TO_VALUES_FILE file not found" && exit 1
  fi
}

# Upadte app version in the chart file.
update_app_version() {
  sed -i "s/^appVersion: .*/appVersion: ${PLUGIN_CHART_VERSION}/g" "$LOWER_CHART_NAME"/Chart.yaml
}

# Update app icon in the chart file.
update_icon_url() {
  sed -i "s~^icon: .*~icon: ${CHART_ICON_URL}~g" "$LOWER_CHART_NAME"/Chart.yaml
}

# Update docker tag in values file.
update_docker_tag() {
  sed -i s/do-not-change/"$PLUGIN_DOCKER_TAG"/g "$LOWER_CHART_NAME"/values.yaml
}

# Check if the chart is validate.
check_chart() {
  echo "Checking if chart is OK:"
  helm lint "$LOWER_CHART_NAME"
  echo ' '
}

# Push the chart if not production chart is needed, the push will be to chartmuseum repo.
push_chart() {
  helm push "$LOWER_CHART_NAME"/ --version="$PLUGIN_CHART_VERSION" "$PLUGIN_REPO_NAME"
  echo ' '
}

# Add chartmuseum repo.
helm repo add "$PLUGIN_REPO_NAME" "$PLUGIN_REPO_URL" --username="$PLUGIN_CHART_USERNAME" --password="$PLUGIN_CHART_PASSWORD" >/dev/null
# Update the new repo.
helm repo update >/dev/null

# Fetch the dynamic repo and extract it.
helm fetch "$PLUGIN_REPO_NAME"/"$SOURCE_CHART"
for file in ./"$SOURCE_CHART"-*.tgz; do
  if [ -e "$file" ]; then
    tar -xzf "$SOURCE_CHART"-*.tgz
    rm "$SOURCE_CHART"-*.tgz
    mv "$SOURCE_CHART" "$LOWER_CHART_NAME"
    break
  else
    exit 1
  fi
done

update_chart_name
move_new_values
update_app_version
update_icon_url
update_docker_tag
check_chart
push_chart
