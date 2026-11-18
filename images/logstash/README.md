# logstash

Logstash is an open source data collection engine with real-time pipelining capabilities.

Official documentation: https://www.elastic.co/guide/en/logstash/current/index.html

## Usage

Internal image for the NextGen analytics pipelines (Kafka → Logstash → Elasticsearch).
It is the official Logstash image plus our build of the `gzip_lines` codec, which
skips messages that are not gzip instead of crashing the pipeline. Plugins cannot be
installed at runtime by the Helm chart, hence the custom image:
https://artifacthub.io/packages/helm/elastic/logstash#how-to-install-plugins


## Build

CircleCI builds and pushes `graviteeio.azurecr.io/logstash:<version>` (linux/amd64 and
linux/arm64) on demand. Trigger a pipeline on `master` with the parameter
`{"build_logstash": true}`. The version is the `version` default of the
`build-and-push-logstash` job, which Renovate keeps up to date.

Local build:

```bash
docker build --build-arg logstash_version=9.5.5 -t logstash:9.5.5 images/logstash
```
