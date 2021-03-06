docker_organisation=canelrom1
docker_project=docker-backup
docker_tag=$(shell date +%Y%m%d.%H%M%S)

all: build

build:
	docker build \
		-t $(docker_organisation)/$(docker_project):$(docker_tag) \
		src
	docker tag $(docker_organisation)/$(docker_project):$(docker_tag) \
		$(docker_organisation)/$(docker_project):latest
