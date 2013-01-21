languor
=======

A fresh take on ![the venerable YST range](https://github.com/ytoolshed/range): LPEG is compiled into Redis and a Lua parser for range queries runs inside Redis. Redis provides the set logic, Lua handles the range semantics.

INSTALL
-------
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

Populate some data with `tests/load-fixtures.sh` or just `SADD` something.

SYNTAX
------

### Implemented
* `%` List members of a set (Change to `*`?)
* `&` Set intersection
* `+` Set union
* `-` Set difference
* `{}` Indicate precedence
### Unimplemented 
* `..` Generate a range of consecutive integers
* `,` Set literal
* `_` Flatten
* `//` Filter a set by regex
* `()` Lua function call
* `?` List sets containing a member
* `:` Get a property of a set (to be represented by a Redis hash)


TODO
----
* Syntax fix so you can nest without {}
* Expose as a service
* Almost everything else, this is a proof-of-concept.
