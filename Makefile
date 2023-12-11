
requirements.txt: poetry.lock
	poetry export > requirements.txt

image: requirements.txt
	docker build .
