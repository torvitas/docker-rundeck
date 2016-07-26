up:
	docker-compose up -d
down:
	docker-compose down --remove-orphans
log:
	docker-compose logs -f --tail=1000 rundeck
stop:
	docker-compose stop
pull:
	docker-compose pull
build:
	docker-compose build
hash:
	docker-compose run --rm --no-deps --entrypoint bash rundeck -c "java -cp /var/lib/rundeck/bootstrap/jetty-all-7.6.0.v20120127.jar org.eclipse.jetty.util.security.Password $${user} $${password}"
