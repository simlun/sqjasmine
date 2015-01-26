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
 * Helper Specs
 ******************************************************************************/

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


describe("The pretty formatter", function() {
  it("formats values and their type", function() {
    expect(_prettyFormat(0)).toEqual("(integer : 0)")
    expect(_prettyFormat("foo")).toEqual("(string : foo)")
  })
  it("formats null", function() {
    expect(_prettyFormat(null)).toEqual("(null)")
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
  it("formats arrays", function() {
    expect(_prettyFormat([])).toEqual("(array : [])")
    expect(_prettyFormat([123])).toEqual("(array : [(integer : 123)])")
  })
  it("comma separates multiple elements in arrays", function() {
    expect(_prettyFormat([123, "baz"])).toEqual("(array : [(integer : 123), (string : baz)])")
  })
})


describe("The floatAbs function", function() {
  it("calculates the absolute value of floating points numbers", function() {
    expect(floatAbs(-17.4711)).toEqual(17.4711)
    expect(floatAbs(0.0)).toEqual(0.0)
    expect(floatAbs(17.1234)).toEqual(17.1234)
  })
})


describe("The round function", function() {
  it("rounds to 0 decimal points", function() {
    expect(round(0.0, 0)).toEqual(0)
    expect(round(17.0, 0)).toEqual(17)
    expect(round(17.0, 0)).toEqual(17)
    expect(round(-4711.0, 0)).toEqual(-4711)
  })
  it("rounds arbitrary fractions", function() {
    expect(round(17.4712, 0)).toEqual(17)
    expect(round(17.4712, 1)).toEqual(17.5)
    expect(round(17.4712, 2)).toEqual(17.47)
    expect(round(17.4712, 3)).toEqual(17.471)
    it("has a limit to what precision it can handle", function() {
      expectException("FAIL: expected (float : 17.471199) to equal (float : 17.471201)", function() {
        expect(round(17.4712, 4)).toEqual(17.4712)
      })
    })
  })
  it("can provide unexpected results because floats, well.. are just floats", function() {
    expect(round(1.0, 1)).toEqual(1.0)
    expect(round(1.1, 1)).toEqual(1.1)
    expect(round(1.5, 1)).toEqual(1.5)
    expect(round(1.9, 1)).toEqual(1.9)
    expect(round(1.09, 2)).toEqual(1.09)
    expect(round(1.19, 2)).toEqual(1.19)
    it("is floatey. And that's why we have the toBeCloseTo matcher!", function() {
      expectException("FAIL: expected (float : 1.590000) to equal (float : 1.590000)", function() {
        expect(round(1.590, 2)).toEqual(1.59)
      })
    })
  })
  it("rounds down small fractions", function() {
    expect(round(17.1, 0)).toEqual(17)
    expect(round(-17.1, 0)).toEqual(-17)
  })
  it("rounds up large fractions", function() {
    expect(round(17.9, 0)).toEqual(18)
    expect(round(-17.9, 0)).toEqual(-18)
  })
  it("rounds half away from zero", function() {
    expect(round(4711.5, 0)).toEqual(4712)
    expect(round(-4711.5, 0)).toEqual(-4712)
  })
})

println("All tests succeeded")
