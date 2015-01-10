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


/*
 * SqJasmine
 */

function describe(title, suite) {
  println(title)
  suite()
}


function it(title, spec) {
  println("  " + title)
  spec()
}


class expect {
  a = null
  not = null

  constructor(_a) {
    a = _a
    not = negatedExpect(_a)
  }

  function toBe(b) {
    if (!_shouldPass(a, b)) {
      _fail(a, b)
    }
  }

  function _fail(a, b) {
    throw "FAIL: expected " + a + " to be " + b
  }

  function _shouldPass(a, b) {
    return a == b
  }
}


class negatedExpect extends expect {
  constructor(_a) {
    a = _a
    not = null // Not implemented, double negations are silly.
  }

  function _fail(a, b) {
    throw "FAIL: expected " + a + " not to be " + b
  }

  function _shouldPass(a, b) {
    return a != b
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
 * Self-testing code based on the original Jasmine documentation
 */

describe("A suite", function() {
  it("contains spec with an expectation", function() {
    expect(true).toBe(true)
  })
})


expectException("FAIL: expected true to be false", function() {
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
})
