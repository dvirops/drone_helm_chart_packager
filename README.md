

``` bash
docker run --rm \
  -e PLUGIN_REPO_NAME=chartmuseum \
  -e PLUGIN_REPO_URL=https://charts.chartmuseum.com \
  -e PLUGIN_CHART_NAME=charty \
  -e PLUGIN_CHART_USERNAME=xxxx\
  -e PLUGIN_CHART_PASSWORD=xxxx\
  -e PLUGIN_VALUES_FILE_PATH=drone_branch\
  -e PLUGIN_TAG=0.1.0 \
  joshdvir/drone_helm_chart_packager
```