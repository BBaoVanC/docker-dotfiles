build:
	docker compose build

run: build
	docker compose run --rm dotfiles

.PHONY: build run
