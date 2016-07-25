up:
	docker-compose up -d
pull:
	docker-compose pull
down:
	docker-compose down --remove-orphans
stop:
	docker-compose stop
log:
	docker-compose logs -f --tail=1000
build:
	docker-compose build
