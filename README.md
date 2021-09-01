# SKYWIRE-SYSROOT

Containing sysroot for building getlantern/systray in combination with golang-cross and goreleaser.

## Instructions (Manual Build)

1. Clone this repo 
2. Run 
```bash
$ make configure # (configures ssh key, and docker buildx for multiple platforms)
$ make build # build the docker images
$ make run # copies the header files over to the local directory, and compress it.
$ make upload # uploads it to the bucket
```


