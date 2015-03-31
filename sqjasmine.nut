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


/*******************************************************************************
 * Helper Source Code
 ******************************************************************************/

if ("imp" in getroottable()) {
  // Use Electric Imp's logging
  println <- @(line) server.log(line)
} else {
  println <- @(line) ::print(line + "\n")
}


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


function _isArray(x) {
  return typeof x == typeof []
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
  } else if (_isArray(x)) {
    local array = "(array : ["
    local separator = ""
    foreach (e in x) {
      array += separator + _prettyFormat(e)
      separator = ", "
    }
    return array + "])"
  } else if (x == null) {
    return "(null)"
  } else {
    if (typeof x == typeof 1.2)
      return "(" + typeof x + " : " + format("%f", x) + ")"
    else
      return "(" + typeof x + " : " + x + ")"

  }
}


function expectException(expectedException, fn) {
  try {
    fn()
  } catch (e) {
    if (e == expectedException) {
      return
    } else {
      throw "Expected this exception:\n" + expectedException + "\nbut caught:\n" + e
    }
  }
  throw "Expected an exception to have been thrown"
}


function sgn(x) {
  if (x < 0)
    return -1
  else if (x == 0)
    return 0
  else
    return 1
}


function floatAbs(x) {
  if (sgn(x) == -1)
    return -1.0 * x
  else if (sgn(x) == 0)
    return 0.0
  else
    return 1.0 * x
}


function round(x, decimalPlaces) {
  // Take the input number apart
  local sign = sgn(x)
  local absWhole = abs(x.tointeger())
  local absFraction = floatAbs(x) - absWhole

  // Throw away the useless digits of the fraction
  local usefulDecimalPlaces = decimalPlaces + 1
  local usefulFractionAsAWhole = floor(absFraction * pow(10, usefulDecimalPlaces))

  // Convert fraction part to integer
  local fractionAsInteger = floor(absFraction * pow(10, decimalPlaces))

  // Get last useful fraction digit
  local tieBreaker = usefulFractionAsAWhole - (floor(usefulFractionAsAWhole / 10) * 10)

  // Perhaps "round up"
  if (tieBreaker >= 5)
    fractionAsInteger = fractionAsInteger + 1

  // Convert back into fraction
  local roundedFraction = fractionAsInteger / pow(10, decimalPlaces)

  // Combine parts into a result
  local result = sign * (absWhole + roundedFraction)
  return result
}


/*******************************************************************************
 * SqJasmine Core Source Code
 ******************************************************************************/

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

  function _areArraysEqual(a, b) {
    if (a.len() == b.len()) {
      foreach (i, value in a) {
        if (!_equal(value, b[i])) {
          return false
        }
      }
      return true
    } else {
      return false
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
    if (_isArray(a) && _isArray(b)) {
      return _areArraysEqual(a, b)
    } else if (_isTable(a) && _isTable(b)) {
      return _areTablesEqual(a, b)
    } else {
      return _are(a, b)
    }
  }

  function _failedToEqual(a, b) {
    throw "FAIL: expected " + _prettyFormat(a) + " to equal " + _prettyFormat(b)
  }

  function toMatch(ex) {
    if (regexp(ex).match(a) == false) {
      throw "FAIL: expected " + _prettyFormat(a) + " to match the regex " + ex
    }
  }

  function toBeNull() {
    if (a != null) {
      throw "FAIL: expected " + _prettyFormat(a) + " to be null"
    }
  }

  function toBeTruthy() {
    if (!a) {
      throw "FAIL: expected " + _prettyFormat(a) + " to be truthy"
    }
  }

  function toBeFalsy() {
    if (a) {
      throw "FAIL: expected " + _prettyFormat(a) + " to be falsy"
    }
  }

  function toContain(b) {
    if (a.find(b) == null) {
      throw "FAIL: expected " + _prettyFormat(a) + " to contain " + _prettyFormat(b)
    }
  }

  function toBeLessThan(b) {
    if (!(a < b)) {
      throw "FAIL: expected " + _prettyFormat(a) + " to be less than " + _prettyFormat(b)
    }
  }

  function toBeGreaterThan(b) {
    if (!(a > b)) {
      throw "FAIL: expected " + _prettyFormat(a) + " to be greater than " + _prettyFormat(b)
    }
  }

  function toBeCloseTo(b, decimalPlaces) {
    local aRounded = round(a, decimalPlaces)
    local bRounded = round(b, decimalPlaces)
    if (_prettyFormat(aRounded) != _prettyFormat(bRounded)) {
      throw "FAIL: expected " + _prettyFormat(a) + " to be close to " + _prettyFormat(b) + " within " + decimalPlaces + " decimal places"
    }
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

  function _areArraysEqual(a, b) {
    // Return true if they are NOT equal
    if (a.len() != b.len()) {
      return true
    } else {
      foreach (i, value in a) {
        if (_equal(value, b[i])) {
          return true
        }
        return false
      }
    }
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

  function toMatch(ex) {
    if (regexp(ex).match(a) == true) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to match the regex " + ex
    }
  }

  function toBeNull() {
    if (a == null) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to be null"
    }
  }

  function toBeTruthy() {
    if (a) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to be truthy"
    }
  }

  function toBeFalsy() {
    if (!a) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to be falsy"
    }
  }

  function toContain(b) {
    if (a.find(b) != null) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to contain " + _prettyFormat(b)
    }
  }

  function toBeLessThan(b) {
    if (a < b) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to be less than " + _prettyFormat(b)
    }
  }

  function toBeGreaterThan(b) {
    if (a > b) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to be greater than " + _prettyFormat(b)
    }
  }

  function toBeCloseTo(b, decimalPlaces) {
    local aRounded = round(a, decimalPlaces)
    local bRounded = round(b, decimalPlaces)
    if (_prettyFormat(aRounded) == _prettyFormat(bRounded)) {
      throw "FAIL: expected " + _prettyFormat(a) + " not to be close to " + _prettyFormat(b) + " within 0 decimal places"
    }
  }
}
