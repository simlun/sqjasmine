/*******************************************************************************
 * SqJasmine
 *
 * A partial Squirrel [1] port of Jasmine [2]
 *
 * [1]: http://www.squirrel-lang.org/
 * [2]: http://jasmine.github.io/
 *
/******************************************************************************/
/*
 * This port is, as the original, published under the MIT license:
 *
 * Copyright (c) 2015 Simon Lundmark <simon.lundmark@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

/* Original Jasmine license:
Copyright (c) 2008-2014 Pivotal Labs

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// Use Electric Imp's logging
println <- @(line) server.log(line)


class Indentation {
  level = null

  constructor() {
    level = 0
  }

  function increase() {
    level += 1
  }

  function decrease() {
    level -= 1
  }

  function getIndentation() {
    local indentation = ""
    for (local i = 0; i < level; i += 1) {
      indentation += "  "
    }
    return indentation
  }

  function println(line) {
    ::println(getIndentation() + line)
  }
}


indent <- Indentation()


function _tryFinally(_try, _finally) {
  try {
    _try()
  } catch (e) {
    _finally()
    throw e
  }
  _finally()
}


function _isTable(x) {
  return typeof x == typeof {}
}


function _prettyFormat(x) {
  if (_isTable(x)) {
    local table = "(table : {"
    local separator = ""
    foreach (k, v in x) {
      table += separator + k + "=" + _prettyFormat(v)
      separator = ", "
    }
    return table + "})"
  } else {
    return "(" + typeof x + " : " + x + ")"
  }
}


/*
 * SqJasmine
 */

function describe(title, suite) {
  indent.println(title)
  indent.increase()
  _tryFinally(suite, function() {
    indent.decrease()
  })
}

// TODO Hm.. These two are kinda similar..!

function it(title, spec) {
  indent.println(title)
  indent.increase()
  _tryFinally(spec, function() {
    indent.decrease()
  })
}



class expect {
  a = null
  not = null

  constructor(_a) {
    a = _a
    not = negatedExpect(_a)
  }

  function toBe(b) {
    if (!_are(a, b)) {
      _failedToBe(a, b)
    }
  }

  function _are(a, b) {
    return a == b
  }

  function _failedToBe(a, b) {
    throw "FAIL: expected " + _prettyFormat(a) + " to be " + _prettyFormat(b)
  }

  function toEqual(b) {
    if (!_equal(a, b)) {
      _failedToEqual(a, b)
    }
  }

  function _areTablesEqual(a, b) {
    if (a.len() == b.len()) {
      foreach (key, value in a) {
        if (!(key in b)) {
          return false
        } else if (!_equal(value, b[key])) {
          return false
        }
      }
      return true
    } else {
      return false
    }
  }

  function _equal(a, b) {
    if (_isTable(a) && _isTable(b)) {
      return _areTablesEqual(a, b)
    } else {
      return _are(a, b)
    }
  }

  function _failedToEqual(a, b) {
    throw "FAIL: expected " + _prettyFormat(a) + " to equal " + _prettyFormat(b)
  }
}


class negatedExpect extends expect {
  constructor(_a) {
    a = _a
    not = null // Not implemented, double negations are silly.
  }

  function _failedToBe(a, b) {
    throw "FAIL: expected " + _prettyFormat(a) + " not to be " + _prettyFormat(b)
  }

  function _are(a, b) {
    return !base._are(a, b)
  }

  function _failedToEqual(a, b) {
    throw "FAIL: expected " + _prettyFormat(a) + " not to equal " + _prettyFormat(b)
  }

  function _areTablesEqual(a, b) {
    // Return true if they are NOT equal
    if (a.len() == b.len()) {
      foreach (key, value in a) {
        if (!(key in b)) {
          return true
        } else if (_equal(value, b[key])) {
          // The _equal method is effectively already
          // negated in this negatedExpect class
          return true
        } else {
          return false
        }
      }
    } else {
      return true
    }
  }
}


/*
 * Utilities
 */

function expectException(expectedException, fn) {
  try {
    fn()
  } catch (e) {
    if (e == expectedException) {
      return
    } else {
      throw "Expected this exception: " + expectedException + " but caught: " + e
    }
  }
  throw "Expected an exception to have been thrown"
}


/*
 * Test indentation levels in the spec verification output
 */

describe("The indentation level has a start value", function() {
  expect(indent.level).toEqual(1)

  it("then it increases for each it statement", function() {
    expect(indent.level).toEqual(2)
  })

  it("and stays", function() {
    expect(indent.level).toEqual(2)
  })

  it("unless the it statements are nested", function() {
    expect(indent.level).toEqual(2)
    it("then it has increased", function() {
      expect(indent.level).toEqual(3)
    })
  })

  it("then decreases", function() {
    expect(indent.level).toEqual(2)
  })

  describe("nested describe statements will also increase indentation level", function() {
    expect(indent.level).toEqual(2)
    it("and of course their it statements do too", function() {
      expect(indent.level).toEqual(3)
    })
  })
})

/*
 * Test pretty formatting
 */

describe("The pretty formatter", function() {
  it("formats values and their type", function() {
    expect(_prettyFormat(0)).toEqual("(integer : 0)")
    expect(_prettyFormat("foo")).toEqual("(string : foo)")
  })
  it("formats tables", function() {
    expect(_prettyFormat({})).toEqual("(table : {})")
    expect(_prettyFormat({a=123})).toEqual("(table : {a=(integer : 123)})")
  })
  it("comma separates multiple slots in tables", function() {
    expect(_prettyFormat({a=123, b="baz"})).toEqual("(table : {a=(integer : 123), b=(string : baz)})")
  })
  it("formats nested tables", function() {
    expect(_prettyFormat({a=123, b={c=4711}})).toEqual("(table : {a=(integer : 123), b=(table : {c=(integer : 4711)})})")
  })
})


/*
 * Self-testing code based on the original Jasmine documentation
 */

describe("A suite", function() {
  it("contains spec with one or more expectations", function() {
    expect(true).toBe(true)
    expect(false).toBe(false)
  })
})


expectException("FAIL: expected (bool : true) to be (bool : false)", function() {
  describe("A failing suite", function() {
    it("contains spec with a failing expectation", function() {
      expect(true).toBe(false)
    })
  })
})


describe("A suite is just a function", function() {
  local a = null

  it("and so is a spec", function() {
    a = true

    expect(a).toBe(true)
  })
})


describe("The 'toBe' matcher compares", function() {
  it("and has a positive case", function() {
    expect(true).toBe(true)
  })
  it("and can have a negative case", function() {
    expect(false).not.toBe(true)
  })
})


describe("Included matchers:", function() {

  it("The 'toBe' matcher compares with ==", function() {
    local a = 12
    local b = a

    expect(a).toBe(b)
    expect(a).not.toBe(null)
  })

  describe("The 'toEqual' matcher", function() {
    it("works for simple literals and variables", function() {
      local a = 12
      expect(a).toEqual(12)
    })

    it("works for negative testing simple literals and variables", function() {
      local a = 12
      expect(a).not.toEqual(4711)
    })

    expectException("FAIL: expected (integer : 12) to equal (integer : 4711)", function() {
      it("can fail for simple literals and variables", function() {
        local a = 12
        expect(a).toEqual(4711)
      })
    })

    expectException("FAIL: expected (integer : 17) not to equal (integer : 17)", function() {
      it("can fail for negatively tested simple literals and variables", function() {
        local a = 17
        expect(a).not.toEqual(17)
      })
    })

    it("handles tables:", function() {
      it("can be empty", function() {
        expect({}).toEqual({})
      })
      expectException("FAIL: expected (table : {}) to equal (table : {a=(integer : 4711)})", function() {  
        it("requires tables to be of the same sizes", function() {
          expect({}).toEqual({a=4711})
          expect({a=4711}).toEqual({})
        })
      })

      it("needs to contain the same data", function() {
        expect({a=4711}).toEqual({a=4711})
      })

      it("needs to contain the same keys", function() {
        expectException("FAIL: expected (table : {a=(integer : 4711)}) to equal (table : {a2=(integer : 4711)})", function() {  
          expect({a=4711}).toEqual({a2=4711})
        })
        expectException("FAIL: expected (table : {a2=(integer : 4711)}) to equal (table : {a=(integer : 4711)})", function() {  
          expect({a2=4711}).toEqual({a=4711})
        })
      })

      it("can be negated:", function() {
        it("can detect different values of the same slot", function() {
          expect({af=17}).not.toEqual({af=4711})
          expect({bf=4711}).not.toEqual({bf=17})
        })
        it("can detect different number of slots", function() {
          expect({a=17}).not.toEqual({})
          expect({}).not.toEqual({a=17})
          expect({}).not.toEqual({a=17, arst="foo"})
        })
        it("can detect same number of slots but with different keys", function() {
          expect({az=4711}).not.toEqual({foo=4711})
          expect({aq=4711}).not.toEqual({foo=17})
        })
      })

      it("can contain more simple data", function() {
        local foo = {
          a=12,
          b="foo"
        }
        local bar = {
          a=12,
          b="foo"
        }
        expect(foo).toEqual(bar)
      })

      it("can contain nested tables", function() {
        it("can be equal", function() {
          local foo = {
            a=12,
            b={c=4711}
          }
          local bar = {
            a=12,
            b={c=4711}
          }
          expect(foo).toEqual(bar)
        })

        it("can negatively test nested tables", function() {
          local foo = {
            a=12,
            b={c=4711}
          }
          local bar = {
            a=123456789,
            b={c=4711}
          }
          expect(foo).not.toEqual(bar)
        })

        expectException("FAIL: expected (table : {}) to equal (table : {a=(table : {b=(integer : 4711)})})", function() {  
          it("can fail for nested tables", function() {
            expect({}).toEqual({a={b=4711}})
          })
        })
      })
    })
  })
})
