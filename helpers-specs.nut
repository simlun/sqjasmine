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
