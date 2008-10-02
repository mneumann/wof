run:
	thin start -R counter.ru

benchmark:
	ab -c 100 -n 10000 "http://localhost:3000/3.inc?/3.value=-6&/1.value=16&/2.value=18"
