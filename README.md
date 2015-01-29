SqJasmine
=========

A Squirrel Testing Framework
----------------------------

SqJasmine is a [Behavior-Driven Development][6] testing framework for [Squirrel][1].

This is a partial [Squirrel][1] port of [Jasmine][2] by [Simon Lundmark][3] written for behavior-driven development on the [Electric Imp][4] platform.

[![Build status of master branch](https://travis-ci.org/simlun/sqjasmine.svg?branch=master)](https://travis-ci.org/simlun/sqjasmine)


Documentation
-------------

It's all in `documentation-spec.nut`. There you will find the ported version of the [Jasmine Documentation][5]. That file also doubles as the test suite of SqJasmine.

To use SqJasmine in your [Electric Imp][4] project, simply copy and paste the contents of `sqjasmine.nut` to the top the model in the [Electric Imp IDE][7]. Happy testing!


Development
-----------

SqJasmine's development is test-driven by basically copying and pasting the JavaScript code examples from the [Jasmine Documentation][5], translating them to [Squirrel][1] code (not much to change at all), running it then finally implementing enough of the Jasmine API until it runs without runtime errors :) Lots of fun!

Local development works like a charm, for example this will run the self-testing suite on a Mac:

```
$ brew install squirrel
/.../
$ sq documentation-spec.nut
A suite
  contains spec with one or more expectations
A failing suite
  contains spec with a failing expectation
A suite is just a function
  and so is a spec
The 'toBe' matcher compares
  and has a positive case
  and can have a negative case
Included matchers:
  The 'toBe' matcher compares with ==
  The 'toEqual' matcher
    works for simple literals and variables
    works for negative testing simple literals and variables
    can fail for simple literals and variables
    can fail for negatively tested simple literals and variables
    handles tables:
      can be empty
      requires tables to be of the same sizes
      needs to contain the same data
      needs to contain the same keys
      can be negated:
        can detect different values of the same slot
        can detect different number of slots
        can detect same number of slots but with different keys
      can contain more simple data
      can contain nested tables
        can be equal
        can negatively test nested tables
        can fail for nested tables
A spec
  is just a function, so it can contain any code
  can have more than one expectation
```

Automatically running the tests on source code file save is an incredible productivity boost. Here's how it can be done using [entr][8] on a Mac:

```
$ brew install entr
$ find . -name '*.nut' | entr -c bash -c 'sq helper-specs.nut && sq documentation-specs.nut'
```


[1]: http://www.squirrel-lang.org/
[2]: http://jasmine.github.io/
[3]: https://github.com/simlun
[4]: https://www.electricimp.com/
[5]: http://jasmine.github.io/2.1/introduction.html
[6]: http://dannorth.net/introducing-bdd/
[7]: https://ide.electricimp.com/
[8]: http://entrproject.org/
