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
$ bin/lr <range expression> <———— to evaluate a single expression (doesn't start Redis)
```

Populate some data with `tests/load-fixtures.sh` or just `SADD` something.

SYNTAX
------

### Implemented
* `%<set>` List members of a set (Change to `*`?)
* `<set>&<set>` Set intersection
* `<set>+<set>` Set union
* `<set>-<set>` Set difference
* `{}` Indicate precedence
* `_` Flatten
### Unimplemented 
* `<num>..<num>` Generate a range of consecutive integers
* `<expr>, <expr>` Set literal
# `^` Flatten up
* `?<member>` List sets containing a member
* `<set>:<property>` Get a property of a set's metadata (to be represented by a Redis hash)
* `/<regex>/` Filter a set by regex
* `<function>()` Lua function call


TODO
----
* parser fixes, especially for unary ops
* improve temp set handling
* Syntax fix so you can nest without {}
* Expose as a service
* Almost everything else, this is a proof-of-concept.
