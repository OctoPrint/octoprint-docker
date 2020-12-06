build:
	docker-compose -f compose.test.yml build .

down:
	docker-compose -f compose.test.yml down

up:
	docker-compose -f compose.test.yml up

clean:
	docker-compose -f compose.test.yml down --rmi local -v
