NAME = graviteeio/am-gateway
VERSION = 1.3.0


all: build

build:
	docker build -t $(NAME):$(VERSION) --rm --build-arg GRAVITEEAM_VERSION=$(VERSION) .

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm --build-arg GRAVITEEAM_VERSION=$(VERSION) .

tag_latest: build
	docker tag $(NAME):$(VERSION) $(NAME):latest

run:
		docker run -ti  -p 8092:8092 $(NAME):$(VERSION)
