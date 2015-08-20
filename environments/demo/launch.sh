set -e

mkdir ~/docker-demo
cd ~/docker-demo
curl -L https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/environments/demo/docker-compose.yml -o "docker-compose.yml"
sudo docker-compose up
