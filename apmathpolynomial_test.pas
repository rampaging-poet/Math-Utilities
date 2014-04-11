unit apmathpolynomial_test;
{
  Copyright (c) 2014 Andrew R. Perkins

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  apmathpolynomials;

type

  TTestPolynomials= class(TTestCase)
  published
    procedure TestArrayAssignment;
    procedure TestIndividualAssignment;
    procedure TestValue;
    procedure TestEqual;
    procedure TestAdd;
    procedure TestSubtract;
    procedure TestMultiply;
  end;

implementation

procedure TTestPolynomials.TestArrayAssignment;
var
  a: TPolynomial;
  TestArray: TExtendedArray;
  I: Integer;
begin
  //Test trimming when assigning a dynamic array.
  TestArray := nil;
  SetLength(TestArray,5);
  TestArray[0] := 1;
  for I := 1 to 4 do
    TestArray[I] := 0;

  a := TestArray;

  Assert(a.Order = 0,           'Failed to trim array on assignment.');
  Assert(a.Coefficients[0] = 1, 'Trimmed array does not have correct values.');

  //Non-trim test.
  TestArray := nil;
  SetLength(TestArray,5);
  for I := 0 to 4 do
    TestArray[I] := I;

  a := TestArray;
  Assert(a.Order = 4, 'Trimmed array when array did not have trailing zeroes.');

  //Check values
  for I := 0 to 4 do
    Assert(a.Coefficients[I] = I, 'Unexpected value after dynamic array assignment.');

  //Test assignment by SetCoefficients
  SetCoefficients(a, [1,2,3]);
  Assert(a.Coefficients[0] = 1, 'Unexpected value after open array assignment.');
  Assert(a.Coefficients[1] = 2, 'Unexpected value after open array assignment.');
  Assert(a.Coefficients[2] = 3, 'Unexpected value after open array assignment.');
end;

procedure TTestPolynomials.TestIndividualAssignment;
var
  a: TPolynomial;
begin
  //Assign a value past the end of the array.
  a := nil;
  a.Coefficients[2] := 1;

  Assert(a.Order = 2, 'Unexpected order after assigning coefficient.');
  Assert(a.Coefficients[0] = 0, 'Unexpected value at index 0 after assigning coefficient.');
  Assert(a.Coefficients[1] = 0, 'Unexpected value at index 1 after assigning coefficient.');
  Assert(a.Coefficients[2] = 1, 'Unexpected value at index 2 after assigning coefficient.');

  //Ensure we trim correctly after assigning 0.
  a.Coefficients[2] := 0;
  Assert(a.Order = 0, 'Failed to reduce order after assigning 0 to highest-order term.');
end;

procedure TTestPolynomials.TestValue;
var
  a: TPolynomial;
begin
  a := nil;

  //Ensure value of nil is zero for some arbitrary value of x.
  Assert(a.Value(137) = 0, 'Value of nil polynomial is not zero.');

  //Ensure value of 0th-order polynomials is a constant.
  a.Coefficients[0] := 1;

  Assert(a.Value(0)   = 1, 'Value of constant polynomial is not constant.');
  Assert(a.Value(7)   = 1, 'Value of constant polynomial is not constant.');
  Assert(a.Value(137) = 1, 'Value of constant polynomial is not constant.');

  //Ensure value of higher-order polynomials is correctly calculated.
  SetCoefficients(a, [1,2,3]);

  Assert(a.Value(0) = 1,       'Unexpected value of polynomial 3x^2 + 2x + 1');
  Assert(a.Value(7) = 162,     'Unexpected value of polynomial 3x^2 + 2x + 1');
  Assert(a.Value(137) = 56582, 'Unexpected value of polynomial 3x^2 + 2x + 1');
end;

procedure TTestPolynomials.TestEqual;
var
  a, b: TPolynomial;
begin
  //Ensure equals works for nil arrays.
  a := nil;
  b := nil;
  Assert(a = b, 'Nil polynomials not considered equal.');

  //Ensure nil is not equal to a real polynomial.
  SetCoefficients(a, [1,2,3]);
  if b = a then Assert(false, 'Nil = a real polynomial.');
  if a = b then Assert(false, 'A real polynomial = nil.');

  //Ensure equals command works between identical arrays.
  SetCoefficients(b, [1,2,3]);

  Assert(a = b, 'Identical arrays not considered equal.');
end;

procedure TTestPolynomials.TestAdd;
var
  a, b, c: TPolynomial;
begin
  a := nil;
  b := nil;
  c := nil;
  //Check addition between nil = nil.
  Assert(a + b = c, 'Nil + Nil <> Nil.');

  //Check addition between nil and real.
  SetCoefficients(a, [1,2,3]);
  SetCoefficients(c, [1,2,3]);

  Assert(a + b = c, 'Real polynomial + nil <> original polynomial.');
  Assert(b + a = c, 'Nil + real polynomial <> original polynomial.');

  //Check addition between two real polynomials.
  SetCoefficients(b, [1,2,3]);
  SetCoefficients(c, [2,4,6]);

  Assert(a + a = c,     'Unexpected sum of polynomials - same order.');

  //Check that addition commutes.
  Assert(a + b = b + a, 'Addition did not commute - same order.');

  //Check addition with non-equal orders.
  a.Coefficients[4] := 5;
  a.Coefficients[3] := 4;

  c.Coefficients[4] := 5;
  c.Coefficients[3] := 4;

  Assert(a + b = b + a, 'Addition did not commute - different order.');
  Assert(a + b = c, 'Unexpected sum of polynomials - different order.');
end;

procedure TTestPolynomials.TestSubtract;
var
  a, b, c: TPolynomial;
begin
  a := nil;
  b := nil;
  c := nil;

  //Ensure -nil = nil
  Assert(a = -a, 'Negative nil was not equal to nil.');

  //Ensure nil - nil = nil
  Assert(a - b = c, 'Nil minus nil was not equal to nil.');

  //Ensure negative works properly for real polynomials.
  SetCoefficients(a, [1,2,3]);
  SetCoefficients(c, [-1,-2,-3]);

  Assert(-a = c, 'Unexpected value of unary subtraction operator.');
  Assert(-c = a, 'Unexpected value of unary subtraction operator.');

  //Ensure real polynomial less nil is original polynomial.
  Assert(a - b = a,  'Subtracting nil not equivalent to subtracting zero.');
  Assert(b - a = -a, 'Subtracting from nil not equivalent to subtracting from zero.');

  //Check subtraction of real polynomials.
  SetCoefficients(b, [2, 4, 6]);
  Assert(a - b = c, 'Unexpected value of binary subtraction.');
end;

procedure TTestPolynomials.TestMultiply;
var
  a, b, c: TPolynomial;
begin
  //Check multipliaction with nil.
  SetCoefficients(a, [1,2,3]);
  b := nil;
  c := nil;

  Assert(a * b = c, 'Multiplying by nil does not equal nil.');
  Assert(b * a = c, 'Multiplying by nil does not equal nil.');

  //Check multiplication of two real coefficients.
  SetCoefficients(b, [1,2,3]);
  SetCoefficients(c, [1,4,10,12,9]);

  Assert(a * b = c, 'Unexpected result of multiplication.');

  //Check multiplication by a constant.
  SetCoefficients(c, [2,4,6]);

  Assert(2 * a = c, 'Unexpected result of multiplication by a real number.');
  Assert(a * 2 = c, 'Unexpected result of multiplication by a real number.');
end;

initialization

  RegisterTest(TTestPolynomials);
end.

