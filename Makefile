all: images


images: image-latest


image-latest: Dockerfile
	docker build -f Dockerfile -t bbaovanc/dotfiles:latest .


.PHONY: images image-latest
