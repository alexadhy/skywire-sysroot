.PHONY: configure build run

# variables
TAG:="testing"
RELEASE_DATE=$(shell echo date +%Y%m%d)
HELP_CYAN  := $(shell tput -Txterm setaf 6)
HELP_RESET  := $(shell tput -Txterm sgr0)
HELP_TARGET_MAX_CHAR_NUM := 20

compress:
	tar -czf skywire-release-${RELEASE_DATE}.tar.gz ./linux/amd64 ./linux/arm64 ./linux/armhf

## configure local directories, docker, and ssh-keys
configure:  configure-local-ssh configure-docker configure-directory

## builds multi-platform docker images
build: build-base-image

## create sysroot from multiple docker-images and compress the result
run: run-base-images rsync-base-images compress

configure-docker:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx rm builder
	docker buildx create --name builder --driver docker-container --use

configure-local-ssh:
	ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
	cat ~/.ssh/id_rsa.pub > ./authorized_keys

configure-directory:
	mkdir -p linux/{armhf,arm64,amd64}

build-base-image:
	docker buildx build \
	--platform linux/amd64,linux/arm64,linux/armhf \
	-t skycoin/sysroot-base:${TAG} . --push

run-base-images:
	docker run -d -p 2222:22 --platform armhf --name=armhf skycoin/sysroot-base:${TAG}
	docker run -d -p 2223:22 --platform arm64 --name=arm64 skycoin/sysroot-base:${TAG}
	docker run -d -p 2224:22 --platform amd64 --name=amd64 skycoin/sysroot-base:${TAG}

rsync-base-images:
	./scripts/rsync.sh root@localhost ./linux/armhf 2222
	./scripts/rsync.sh root@localhost ./linux/arm64 2223
	./scripts/rsync.sh root@localhost ./linux/amd64 2224

stop-base-images:
	docker stop armhf && docker rm armhf
	docker stop amd64 && docker rm amd64
	docker stop arm64 && docker rm arm64

inspect-base-image:
	docker buildx imagetools inspect skycoin/sysroot-base:latest

## upload the sysroot to the bucket
upload:
	echo "TODO: please upload to bucket here"


## show this help message
help:
	@echo ''
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "${HELP_CYAN}%-$(HELP_TARGET_MAX_CHAR_NUM)s${HELP_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''
