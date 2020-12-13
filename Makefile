build:
	docker-compose -f test/compose.test.yml build

down:
	docker-compose -f test/compose.test.yml down

up:
	docker-compose -f test/compose.test.yml up

clean:
	docker-compose -f test/compose.test.yml down --rmi local -v
