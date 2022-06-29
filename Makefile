build:
	docker compose build

run: build
	docker compose run dotfiles

.PHONY: build run
