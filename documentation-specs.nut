# vi: set ft=JavaScript et sw=2 sts=2 :
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

dofile("sqjasmine.nut", true)

/*******************************************************************************
 * Documentation based on the original Jasmine documentation
 ******************************************************************************/

/**
 * SqJasmine is a behavior-driven development framework for testing Squirrel
 * code. It does not depend on any other Squirrel frameworks. And it has a
 * clean, obvious syntax so that you can easily write tests. This guide was
 * based on Jasmine version 2.1.0.
 *
 * Suites: describe Your Tests
 * A test suite begins with a call to the global SqJasmine function describe
 * with two parameters: a string and a function. The string is a name or title
 * for a spec suite – usually what is being tested. The function is a block of
 * code that implements the suite.
 *
 * Specs
 * Specs are defined by calling the global SqJasmine function `it`, which, like
 * `describe` takes a string and a function. The string is the title of the spec
 * and the function is the spec, or test. A spec contains one or more
 * expectations that test the state of the code. An expectation in SqJasmine is
 * an assertion that is either true or false. A spec with all true expectations
 * is a passing spec. A spec with one or more false expectations is a failing
 * spec.
 **/

describe("A suite", function() {
  it("contains spec with one or more expectations", function() {
    expect(true).toBe(true)
    expect(false).toBe(false)
  })
})

describe("A failing suite", function() {
  it("contains spec with a failing expectation", function() {
    expectException("FAIL: expected (bool : true) to be (bool : false)", function() {
      expect(true).toBe(false)
    })
  })
})


/**
 * It’s Just Functions
 * Since `describe` and `it` blocks are functions, they can contain any
 * executable code necessary to implement the test. Squirrel scoping rules
 * apply, so variables declared in a describe are available to any it block
 * inside the suite.
 **/

describe("A suite is just a function", function() {
  local a = null

  it("and so is a spec", function() {
    a = true
    expect(a).toBe(true)
  })
})


/**
 * Expectations
 * Expectations are built with the function `expect` which takes a value, called
 * the actual. It is chained with a Matcher function, which takes the expected
 * value.
 *
 * Matchers
 * Each matcher implements a boolean comparison between the actual value and the
 * expected value. It is responsible for reporting to SqJasmine if the
 * expectation is true or false. SqJasmine will then pass or fail the spec.
 *
 * Any matcher can evaluate to a negative assertion by chaining the call to
 * `expect` with a `not` before calling the matcher.
 **/

describe("The 'toBe' matcher compares", function() {
  it("and has a positive case", function() {
    expect(true).toBe(true)
  })
  it("and can have a negative case", function() {
    expect(false).not.toBe(true)
  })
})

/**
 * Included Matchers
 * SqJasmine has a rich set of matchers included. Each is used here – all
 * expectations and specs pass.
 *
 * TODO: There is also the ability to write custom matchers for when a project’s
 * domain calls for specific assertions that are not included below.
 **/

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

    it("can fail for simple literals and variables", function() {
      expectException("FAIL: expected (integer : 12) to equal (integer : 4711)", function() {
        local a = 12
        expect(a).toEqual(4711)
      })
    })

    it("can fail for negatively tested simple literals and variables", function() {
      expectException("FAIL: expected (integer : 17) not to equal (integer : 17)", function() {
        local a = 17
        expect(a).not.toEqual(17)
      })
    })

    it("handles arrays:", function() {
      it("can be empty", function() {
        expect([]).toEqual([])
      })
      it("requires arrays to be of the same sizes", function() {
        expectException("FAIL: expected (array : []) to equal (array : [(integer : 4711)])", function() {
          expect([]).toEqual([4711])
          expect([4711]).toEqual([])
        })
      })

      it("needs to contain the same data", function() {
        expect([4711, 17]).toEqual([4711, 17])
      })

      it("can be negated:", function() {
        expect([]).not.toEqual([17])
        expect([17]).not.toEqual([4711])
        expect([4711]).not.toEqual([17])
        expectException("FAIL: expected (array : [(integer : 4711)]) not to equal (array : [(integer : 4711)])", function() {
          expect([4711]).not.toEqual([4711])
        })
      })
    })

    it("handles tables:", function() {
      it("can be empty", function() {
        expect({}).toEqual({})
      })
      it("requires tables to be of the same sizes", function() {
        expectException("FAIL: expected (table : {}) to equal (table : {a=(integer : 4711)})", function() {
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

        it("can fail for nested tables", function() {
          expectException("FAIL: expected (table : {}) to equal (table : {a=(table : {b=(integer : 4711)})})", function() {
            expect({}).toEqual({a={b=4711}})
          })
        })
      })
    })
  })

  it("The 'toMatch' matcher is for regular expressions", function() {
    local message = "foo bar baz"

    it("can match", function() {
      expect(message).toMatch(@".*bar.*")
    })

    it("can negatively match", function() {
      expect(message).not.toMatch(@"quux")
    })

    it("can fail to match", function() {
      expectException("FAIL: expected (string : foo bar baz) to match the regex biz", function() {
        expect(message).toMatch(@"biz")
      })
    })
  })

it("The 'toBeNull' matcher compares against null", function() {
  local a = null
  local foo = "foo"

  expect(null).toBeNull()
  expect(a).toBeNull()
  expect(foo).not.toBeNull()

  it("can fail", function() {
    expectException("FAIL: expected (string : foo) to be null", function() {
      expect(foo).toBeNull()
    })
    expectException("FAIL: expected (null) not to be null", function() {
      expect(null).not.toBeNull()
    })
  })
})

it("The 'toBeTruthy' matcher is for boolean casting testing", function() {
  local a = null
  local foo = "foo"

  expect(true).toBeTruthy()
  expect(foo).toBeTruthy()
  expect("").toBeTruthy()
  expect(17).toBeTruthy()
  expect(0).not.toBeTruthy()
  expect(-15).toBeTruthy()
  expect(false).not.toBeTruthy()
  expect(a).not.toBeTruthy()

  it("can fail", function() {
    expectException("FAIL: expected (bool : false) to be truthy", function() {
      expect(false).toBeTruthy()
    })
    expectException("FAIL: expected (bool : true) not to be truthy", function() {
      expect(true).not.toBeTruthy()
    })
  })
})

it("The 'toBeFalsy' matcher is for boolean casting testing", function() {
  local a = null
  local foo = "foo"

  expect(a).toBeFalsy()
  expect(foo).not.toBeFalsy()

  it("can fail", function() {
    expectException("FAIL: expected (bool : true) to be falsy", function() {
      expect(true).toBeFalsy()
    })
    expectException("FAIL: expected (bool : false) not to be falsy", function() {
      expect(false).not.toBeFalsy()
    })
  })
})

it("The 'toContain' matcher is for finding an item in an Array", function() {
  local a = ["foo", "bar", "baz"]

  expect(a).toContain("bar")
  expect(a).not.toContain("quux")

  it("can fail", function() {
    expectException("FAIL: expected (array : [(string : foo), (string : bar), (string : baz)]) to contain (string : quux)", function() {
      expect(a).toContain("quux")
    })
    expectException("FAIL: expected (array : [(string : foo), (string : bar), (string : baz)]) not to contain (string : foo)", function() {
      expect(a).not.toContain("foo")
    })
  })
})

it("The 'toBeLessThan' matcher is for mathematical comparisons", function() {
  local pi = 3.140000
  local e = 2.780000

  expect(e).toBeLessThan(pi)
  expect(pi).not.toBeLessThan(e)

  it("can fail", function() {
    expectException("FAIL: expected (integer : 4711) to be less than (float : 3.140000)", function() {
      expect(4711).toBeLessThan(pi)
    })
    expectException("FAIL: expected (integer : 0) not to be less than (float : 2.780000)", function() {
      expect(0).not.toBeLessThan(e)
    })
  })
})

it("The 'toBeGreaterThan' matcher is for mathematical comparisons", function() {
  local pi = 3.140000
  local e = 2.780000

  expect(pi).toBeGreaterThan(e)
  expect(e).not.toBeGreaterThan(pi)

  it("can fail", function() {
    expectException("FAIL: expected (integer : 0) to be greater than (float : 3.140000)", function() {
      expect(0).toBeGreaterThan(pi)
    })
    expectException("FAIL: expected (integer : 4711) not to be greater than (float : 2.780000)", function() {
      expect(4711).not.toBeGreaterThan(e)
    })
  })
})

it("The 'toBeCloseTo' matcher is for precision math comparison", function() {
  local pi = 3.140000
  local e = 2.780000

  expect(pi).toBeCloseTo(e, 0)
  expect(pi).not.toBeCloseTo(e, 1)
  expect(pi).not.toBeCloseTo(e, 2)

  it("can fail", function() {
    expectException("FAIL: expected (float : 3.140000) to be close to (float : 2.780000) within 1 decimal places", function() {
      expect(pi).toBeCloseTo(e, 1)
    })
    expectException("FAIL: expected (float : 3.140000) not to be close to (float : 2.780000) within 0 decimal places", function() {
      expect(pi).not.toBeCloseTo(e, 0)
    })
  })
})

/* TODO:
  it("The 'toThrow' matcher is for testing if a function throws an exception", function() {
    var foo = function() {
      return 1 + 2;
    };
    var bar = function() {
      return a + 1;
    };

    expect(foo).not.toThrow();
    expect(bar).toThrow();
  });
*/

})


/*
 * Grouping Related Specs with `describe`
 *
 * The `describe` function is for grouping related specs. The string parameter
 * is for naming the collection of specs, and will be concatenated with specs to
 * make a spec’s full name. This aids in finding specs in a large suite. If you
 * name them well, your specs read as full sentences in traditional BDD style.
 */

describe("A spec", function() {
  it("is just a function, so it can contain any code", function() {
    local foo = 0
    foo += 1

    expect(foo).toEqual(1)
  })

  it("can have more than one expectation", function() {
    local foo = 0
    foo += 1

    expect(foo).toEqual(1)
    expect(true).toEqual(true)
  })
})

println("All tests succeeded")
