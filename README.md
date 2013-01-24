languor
=======

An LPEG parser for a hierarchical set logic query language embedded inside Redis

INSTALL
-------
```
$ git clone https://github.com/robert-chiniquy/languor
$ cd languor/
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ make
$ bin/languor <—————————————————— to start redis, load the parser, and run a repl
$ bin/lr <range expression> <———— to evaluate a single expression (doesn't start Redis)
```

USAGE
-----
Populate the fixture data with `$ tests/load-fixtures.sh`. To load your own data currently, you can write a fixture lua script using `insert(setname, member, ...)` and add it to l`load-fixtures.sh`. The current fixture data is the `order -> family -> genus -> species -> subspecies` hierarchy from http://www.worldbirdnames.org/ioc-lists/master-list/ — this isn't perfect as species are non-overlapping, I may add "breeding region" or something to the birds to make the data more interesting.

### Any string evaluates to itself
That Wren is a set name does not matter.
```
$ lr Wrens
"Wrens"
```

### List every type of wren
```
$ lr %Wrens
 1) "Campylorhynchus"
 2) "Cantorchilus"
 3) "Catherpes"
 4) "Cinnycerthia"
 5) "Cistothorus"
 6) "Cyphorhinus"
 7) "Ferminia"
 8) "Henicorhina"
 9) "Hylorchilus"
10) "Microcerculus"
11) "Odontorchilus"
12) "Pheugopedius"
13) "Salpinctes"
14) "Thryomanes"
15) "Thryophilus"
16) "Thryorchilus"
17) "Thryothorus"
18) "Troglodytes"
19) "Uropsila"
```

### What order does wren belong to?
```
$ lr ?Wrens
1) "Passeriformes"
```

### Passeriformes belongs to a top-level list of orders
```
$ lr ?Passeriformes
1) "orders"
```

### List everything under Passeriformes (nested operators)
```
$ lr %?Wrens
  1) "Accentors"
  2) "Antbirds"
  3) "Antpittas"
  4) "Antthrushes"
  5) "Australasian Babblers"
  6) "Australasian Robins"
  7) "Australasian Treecreepers"
  8) "Australasian Warblers"
  9) "Australasian Wrens"
 10) "Australian Mudnesters"
 11) "Babblers"
 12) "Bananaquit"
[...]
111) "Wagtails, Pipits"
112) "Wallcreeper"
113) "Wattle-Eyes, Batises"
114) "Waxbills, Munias And Allies"
115) "Waxwings"
116) "Weavers, Widowbirds"
117) "Whipbirds, Jewel-Babblers And Quail-Thrushes"
118) "Whistlers And Allies"
119) "White-Eyes"
120) "Woodshrikes And Allies"
121) "Woodswallows"
122) "Wren-Babblers"
123) "Wrens"
124) "Yellow Flycatchers"
```

### List every subspecies in the Wren family (flatten)
```
$ lr '_Wrens'
  1) "Abbotti"
  2) "Acaciarum"
  3) "Aedon"
  4) "Aenigmaticus"
  5) "Aequatorialis"
  6) "Aestuarinus"
  7) "Affinis"
  8) "Africana"
  9) "Alascensis"
 10) "Albicans"
 11) "Albicilius"
 39) "Barrowcloughianus"
 40) "Beani"
 41) "Beicki"
 42) "Berlandieri"
[...]
406) "Xerophilus"
407) "Yananchae"
408) "Yavii"
409) "Yucatan Wren"
410) "Zagrossiensis"
411) "Zapata Wren"
412) "Zeledoni"
413) "Zetlandicus"
414) "Zimmeri"
415) "Zonatus"
416) "Zuliensis"
```

### List every subspecies in the Wren family except for those under Troglodytes and Campylorhynchus
```
$ lr '_Wrens - _Troglodytes - _Campylorhynchus'
  1) "Abbotti"
  2) "Acaciarum"
  3) "Aequatorialis"
[...]
275) "Wickhami"
276) "Yananchae"
277) "Yucatan Wren"
278) "Zapata Wren"
279) "Zeledoni"
280) "Zuliensis"
```

SYNTAX
------

### Implemented
* `%<set>` List members of a set (Change to `*`?)
* `<set>&<set>` Set intersection
* `<set>+<set>` Set union
* `<set>-<set>` Set difference
* `{}` Indicate precedence
* `_` Flatten
* `?<member>` List sets containing a member

### Unimplemented 
* `^` Flatten up
* `<num>..<num>` Generate a range of consecutive integers
* `<expr>, <expr>` Set literal
* `<set>:<property>` Get a property of a set's metadata (to be represented by a Redis hash)
* `/<regex>/` Filter a set by regex
* `<function>()` Lua function call


TODO
----
* fix bugs, this parser is full of bugs, especially for unary ops
* improve temp set handling
* Syntax fix so you can nest safely without {}
* Expose as a service
* Almost everything else
