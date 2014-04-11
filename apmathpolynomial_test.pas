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
    procedure TestValue;
    procedure TestEqual;
    procedure TestAdd;
    procedure TestMultiply;
  end;

implementation

procedure TTestPolynomials.TestArrayAssignment;
var
  a: TPolynomial;
  TestArray: TExtendedArray;
  I: Integer;
begin
  //Tests of implicit assignment of dynamic arrays to polynomials.
  TestArray := nil;
  a := TestArray;
  Assert(a.Coefficients = nil,'Non-nil coefficients after assigning nil array.');

  //All-zero trim test.
  SetLength(TestArray,5);
  for I := 0 to 4 do
    TestArray[I] := 0;

  a := TestArray;
  Assert((Length(a.Coefficients) = 1) and (a.Coefficients[0] = 0),
         'Failed to trim all-zero array.');

  TestArray := nil;
  SetLength(TestArray,5);
  TestArray[0] := 1;
  for I := 1 to 4 do
    TestArray[I] := 0;

  a := TestArray;

  Assert(Length(a.Coefficients) = 1, 'Failed to trim array on assignment.');
  Assert(a.Coefficients[0] = 1,      'Trimmed array does not have correct values.');

  //Non-trim test.
  TestArray := nil;
  SetLength(TestArray,5);
  for I := 0 to 4 do
    TestArray[I] := I;

  a := TestArray;
  Assert(Length(a.Coefficients) = 5,
         'Trimmed array when array did not have trailing zeroes.');

  //Ensure copy-on-write semantics
  Assert(a.Coefficients <> TestArray, 'Polynomial contains a direct reference to TestArray.');
end;

procedure TTestPolynomials.TestValue;
var
  a: TPolynomial;
begin
  //Ensure value of nil is zero for some arbitrary value of x.
  a.Coefficients := nil;
  Assert(a.Value(137) = 0, 'Value of nil polynomial is not zero.');

  //Ensure value of 0th-order polynomials is a constant.
  SetLength(a.Coefficients,1);
  a.Coefficients[0] := 1;

  Assert(a.Value(0)   = 1, 'Value of constant polynomial is not constant.');
  Assert(a.Value(7)   = 1, 'Value of constant polynomial is not constant.');
  Assert(a.Value(137) = 1, 'Value of constant polynomial is not constant.');

  //Ensure value of higher-order polynomials is correctly calculated.
  SetLength(a.Coefficients,3);
  a.Coefficients[0] := 1;
  a.Coefficients[1] := 2;
  a.Coefficients[2] := 3;

  Assert(a.Value(0) = 1,       'Unexpected value of polynomial 3x^2 + 2x + 1');
  Assert(a.Value(7) = 162,     'Unexpected value of polynomial 3x^2 + 2x + 1');
  Assert(a.Value(137) = 56582, 'Unexpected value of polynomial 3x^2 + 2x + 1');
end;

procedure TTestPolynomials.TestEqual;
var
  a, b: TPolynomial;
begin
  //Ensure equals works for nil arrays.
  a.Coefficients := nil;
  b.Coefficients := nil;

  Assert(a = b, 'Nil polynomials not considered equal.');

  //Ensure equals command works between identical arrays.
  SetLength(a.Coefficients, 3);
  a.Coefficients[0] := 1;
  a.Coefficients[1] := 2;
  a.Coefficients[2] := 3;
  b.Coefficients := a.Coefficients;

  Assert(a = b, 'Identical arrays not considered equal.');

  //Ensure equals command works between copied arrays.
  b.Coefficients := Copy(a.Coefficients,0,MaxInt);
  Assert(a = b, 'Copy of identical array not considered equal to original');

  //Ensure trailing zeroes don't affect equality.
  SetLength(a.Coefficients,5);
  a.Coefficients[3] := 0;
  a.Coefficients[4] := 0;

  Assert(a = b, 'Trailing zeroes prevented equality - a > b.');
  Assert(b = a, 'Trailing zeroes prevented equality - a < b.');

  //Ensure nil is not equal to a real polynomial.
  a.Coefficients := nil;
  if a = b then Assert(false, 'Nil = a real polynomial.');
  if b = a then Assert(false, 'A real polynomial = nil.');
end;

procedure TTestPolynomials.TestAdd;
var
  a, b, c: TPolynomial;
begin
  //Check addition between nil = nil.
  a.Coefficients := nil;
  b.Coefficients := nil;
  c.Coefficients := nil;

  Assert(a + b = c, 'Nil + Nil <> Nil.');

  //Check addition between nil and real.
  SetLength(a.Coefficients,3);
  a.Coefficients[0] := 1;
  a.Coefficients[1] := 2;
  a.Coefficients[2] := 3;

  c.Coefficients := a.Coefficients;
  Assert(a + b = c, 'Real polynomial + nil <> original polynomial.');
  Assert(b + a = c, 'Nil + real polynomial <> original polynomial.');

  //Check addition between two real polynomials.
  b.Coefficients := a.Coefficients;

  c.Coefficients := nil;
  SetLength(c.Coefficients,3);
  c.Coefficients[0] := 2;
  c.Coefficients[1] := 4;
  c.Coefficients[2] := 6;

  Assert(a + a = c,     'Unexpected sum of polynomials - same order.');

  //Check that addition commutes.
  Assert(a + b = b + a, 'Addition did not commute - same order.');

  //Check addition with non-equal orders.
  a.Coefficients := Copy(a.Coefficients,0,MaxInt);
  SetLength(a.Coefficients,5);
  a.Coefficients[3] := 4;
  a.Coefficients[4] := 5;

  SetLength(c.Coefficients,5);
  c.Coefficients[3] := 4;
  c.Coefficients[4] := 5;

  Assert(a + b = b + a, 'Addition did not commute - different order.');
  Assert(a + b = c, 'Unexpected sum of polynomials - different order.');
end;

procedure TTestPolynomials.TestMultiply;
var
  a, b, c: TPolynomial;
begin
  b.Coefficients := nil;
  c.Coefficients := nil;

  //Check multipliaction with nil.
  SetLength(a.Coefficients, 3);
  a.Coefficients[0] := 1;
  a.Coefficients[1] := 2;
  a.Coefficients[2] := 3;

  Assert(a * b = c, 'Multiplying by nil does not equal nil.');
  Assert(b * a = c, 'Multiplying by nil does not equal nil.');

  //Check multiplication of two real coefficients.
  b.Coefficients := a.Coefficients;

  SetLength(c.Coefficients,5);
  c.Coefficients[0] := 1;
  c.Coefficients[1] := 4;
  c.Coefficients[2] := 10;
  c.Coefficients[3] := 12;
  c.Coefficients[4] := 9;

  Assert(a * b = c, 'Unexpected result of multiplication.');

  //Check multiplication by a constant.
  SetLength(c.Coefficients,3);
  c.Coefficients[0] := 2;
  c.Coefficients[1] := 4;
  c.Coefficients[2] := 6;

  Assert(2 * a = c, 'Unexpected result of multiplication by a real number.');
  Assert(a * 2 = c, 'Unexpected result of multiplication by a real number.');
end;

initialization

  RegisterTest(TTestPolynomials);
end.

