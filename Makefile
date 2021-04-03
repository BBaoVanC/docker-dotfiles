all: dockerfiles images

clean:
	rm -rf dockerfiles


dockerfiles: dockerfiles/archlinux-base dockerfiles/archlinux-base-devel
images: image-archlinux-base image-archlinux-base-devel

dockerfiles/archlinux-base: archlinux/Dockerfile_template.Dockerfile
	mkdir -p dockerfiles
	cp archlinux/Dockerfile_template.Dockerfile $@
	sed -i 's/IMAGE_TAG/base/' $@
dockerfiles/archlinux-base-devel: archlinux/Dockerfile_template.Dockerfile
	mkdir -p dockerfiles
	cp archlinux/Dockerfile_template.Dockerfile $@
	sed -i 's/IMAGE_TAG/base-devel/' $@


image-archlinux-base: dockerfiles/archlinux-base
	docker build -f dockerfiles/archlinux-base -t bbaovanc/dotfiles:archlinux-base .
image-archlinux-base-devel: dockerfiles/archlinux-base-devel
	docker build -f dockerfiles/archlinux-base-devel -t bbaovanc/dotfiles:archlinux-base-devel .


.PHONY: clean image-archlinux-base image-archlinux-base-devel
