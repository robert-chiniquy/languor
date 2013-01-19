languor
=======

A fresh take on the venerable YST range: https://github.com/ytoolshed/range
```
$ git clone https://github.com/robert-chiniquy/languor
$ cd languor/
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ make
$ bin/languor <————— to run the repl
$ bin/lr <range expression> <———— to evaluate a single expression on the cli
```

Initially it will have no data loaded. You can populate some with `tests/load-fixtures.sh` or just add some Redis sets yourself with redis-cli.

TODO
====
* Operators beyond &, +, -, %
* Syntax fix so you can nest without ()
* Expose as a service
* Almost everything else, this is a proof-of-concept.
