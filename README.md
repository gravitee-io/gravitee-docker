#Gravitee Dockerfiles

Hosts all Dockerfiles to build GraviteeIO images.
 
  * _images_ stored Dockerfile for each GraviteeIO component
  * _environments_ stored docker-compose configuration for each environments

## How to launch demo
You must have 
  [docker](http://docs.docker.com/installation/) and
  [docker-compose](http://docs.docker.com/compose/install/)
installed on your machine:

```
$ docker --version
$ docker-compose --version
```

Install via curl
```
$ curl -L https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/environments/demo/launch.sh | sh
```
