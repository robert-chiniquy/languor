

all: redis

clean:
	git clean -f

init:
	[ -e build/redis/MANIFEST ] || git submodule update --init

lpeg: init
	cd build && [ -e lpeg-0.10.2 ] || ( wget http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-0.10.2.tar.gz && tar xzvf lpeg-0.10.2.tar.gz ) && cd lpeg-0.10.2 && patch makefile ../languor-lpeg.patch && make

redis: lpeg
	cd build/redis/ && git stash && git apply --ignore-space-change --ignore-whitespace ../languor-redis.patch && make


