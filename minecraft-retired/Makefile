default: help

help:
	cat Makefile

build:
	docker build --no-cache -t minecraft_server .

run:
	docker run -it --rm minecraft_server

push:
	docker tag minecraft_server rnebular/minecraft_server:latest
	docker push rnebular/minecraft_server:latest
