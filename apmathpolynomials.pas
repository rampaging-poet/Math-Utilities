unit apmathpolynomials;
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

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils;

type
  TExtendedArray = array of Extended;

  TPolynomial = record
    //The ith value is the coefficient of the ith-order term of the polynomial.
    Coefficients: TExtendedArray;

    procedure TrimCoefficients;

    //Evaluation
    function Value(x: Extended): Extended;
    function Derivative: TPolynomial;
    function Integral:   TPolynomial;

    //Operators
    class operator Implicit(a: TExtendedArray): TPolynomial;
    class operator Negative(a: TPolynomial): TPolynomial;
    class operator Equal(a, b: TPolynomial): Boolean;
    class operator NotEqual(a, b: TPolynomial): Boolean;
    class operator Add(a, b: TPolynomial): TPolynomial;
    class operator Subtract(a, b: TPolynomial): TPolynomial;
    class operator Multiply(a, b: TPolynomial): TPolynomial;           overload;
    class operator Multiply(a: Extended; b: TPolynomial): TPolynomial; overload;
    class operator Multiply(a: TPolynomial; b: Extended): TPolynomial; overload;
  end;

implementation
uses
  Math;

procedure TPolynomial.TrimCoefficients;
var
  I: Integer;
begin
  //Do nothing if no coefficients are assigned.
  if Coefficients = nil then Exit;

  //Do nothing if there are no trailing zeros.
  if Coefficients[Pred(Length(Coefficients))] <> 0 then Exit;

  //Trim trailing zeroes to ensure length and order are related.
  for I := Pred(Pred(Length(Coefficients))) downto 0 do
  begin
    if Coefficients[I] <> 0 then
    begin
      //At least one non-zero coefficient exists. Set Coefficients and exit.
      Coefficients := Copy(Coefficients,0,Succ(I));
      Exit;
    end;
  end;

  //If we get here, then the array was entirely composed of zeroes.
  Coefficients := nil; //Remove any existing reference.
  SetLength(Coefficients,1);
  Coefficients[0] := 0;
end;

function TPolynomial.Value(x: Extended): Extended;
var
  I: Integer;
begin
  Result := 0;

  for I := Pred(Length(Coefficients)) downto 0 do
    Result := Result * x + Coefficients[I];
end;

function TPolynomial.Derivative: TPolynomial;
var
  Len: Integer;
  I: Integer;
begin
  if Coefficients = nil then
  begin
    Result.Coefficients := nil;
    Exit;
  end;

  Len := Length(Coefficients);
  //Catch the base case - f(x) is a constant.
  if Len < 2 then
  begin
    SetLength(Result.Coefficients, 1);
    Result.Coefficients[0] := 0;
    Exit;
  end;

  //The result is a polynomial of degree n-1.
  SetLength(Result.Coefficients, Pred(Len));

  for I := 1 to Pred(Len) do
    Result.Coefficients[Pred(I)] := Coefficients[I] * I;
end;

function TPolynomial.Integral: TPolynomial;
var
  Len: Integer;
  I: Integer;
begin
  if Coefficients = nil then
  begin
    Result.Coefficients := nil;
    Exit;
  end;

  Len := Length(Coefficients);

  //Polynomial is of degree n+1, constant of integration assumed to be zero.
  SetLength(Result.Coefficients,Succ(Len));
  Result.Coefficients[0] := 0;

  //Integral of ith term is ith term divided by i+1.
  for I := 1 to Pred(Len) do
    Result.Coefficients[I+1] := Coefficients[I] / (I + 1);
end;

class operator TPolynomial.Implicit(a: TExtendedArray): TPolynomial;
begin
  Result.Coefficients := Copy(a,0,MaxInt);
  Result.TrimCoefficients;
end;

class operator TPolynomial.Negative(a: TPolynomial): TPolynomial;
var
  I: Integer;
begin
  Result.Coefficients := a.Coefficients;

  for I := 0 to Pred(Length(Result.Coefficients)) do
    Result.Coefficients[I] := -Result.Coefficients[I];
end;

class operator TPolynomial.Equal(a, b: TPolynomial): Boolean;
var
  Len: Integer;
  I: Integer;
  LongArray: TExtendedArray;
begin
  Result := False;

  //Nil checks.
  if (a.Coefficients = nil) then
  begin
    if (b.Coefficients = nil) then
      Result := True
    else
      Result := (Length(b.Coefficients) = 1) and (b.Coefficients[0] = 0);

    Exit;
  end;

  if (b.Coefficients = nil) then
  begin
    Result := (Length(a.Coefficients) = 1) and (a.Coefficients[0] = 0);
    Exit;
  end;

  //Check order of polynomials.
  Len := Length(a.Coefficients);

  case CompareValue(Len, Length(b.Coefficients)) of
    -1: LongArray := b.Coefficients; //a is shorter than b
    0:  LongArray := nil;            //They are the same length
    1:                               //a is longer than b
      begin
        LongArray := a.Coefficients;
        Len       := Length(b.Coefficients);
      end;
  end;

  //Iterate over polynomials to find first nonmatching coefficients.
  for I := 0 to Pred(Len) do
    if a.Coefficients[I] <> b.Coefficients[I] then Exit;

  //All coefficients match.  Check for additional terms in longer array.
  if Assigned(LongArray) then
  begin
    for I := Len to Pred(Length(LongArray)) do
      if LongArray[I] <> 0 then Exit;
  end;

  //All coefficients match. These polynomials are equal.
  Result := True;
  Exit;
end;

class operator TPolynomial.NotEqual(a, b: TPolynomial): Boolean;
begin
  Result := not (a = b);
end;

class operator TPolynomial.Add(a, b: TPolynomial): TPolynomial;
var
  SourceArray: TExtendedArray;
  ResultArray: TExtendedArray;
  MinLen: Integer;
  I: Integer;
begin
  //Nil checks
  if a.Coefficients = nil then
  begin
    Result.Coefficients := b.Coefficients;
    Exit;
  end;

  if b.Coefficients = nil then
  begin
    Result.Coefficients := a.Coefficients;
    Exit;
  end;

  //Determine which polynomial is of higher degree.
  MinLen := Length(a.Coefficients);

  if Length(b.Coefficients) >= MinLen then
  begin
    SourceArray := a.Coefficients;
    ResultArray := Copy(b.Coefficients,0,MaxInt);
  end else
  begin
    MinLen := Length(b.Coefficients);
    SourceArray := b.Coefficients;
    ResultArray := Copy(a.Coefficients);
  end;

  //Add lower degree polynomial to higher higher degree ResultArray.
  for I := 0 to Pred(MinLen) do
    ResultArray[I] := ResultArray[I] + SourceArray[I];

  //Assign result array to result polynomial.
  Result.Coefficients := ResultArray;
  Result.TrimCoefficients;
end;

class operator TPolynomial.Subtract(a, b: TPolynomial): TPolynomial;
begin
  //Negate the second polynomial and add.
  Result := a + (-b);
end;

class operator TPolynomial.Multiply(a, b: TPolynomial): TPolynomial;
var
  ResultArray: TExtendedArray;
  Len: Integer;
  I, J: Integer;
begin
  //Check for unassigned coefficients.
  if (a.Coefficients = nil) or (b.Coefficients = nil) then
  begin
    Result.Coefficients := nil;
    Exit;
  end;

  //Length = Degree + 1.
  //Degree(a*b) = Degree(a) + Degree(b)
  //Therefore Length(a*b) = Length(a) + Length(b) - 1;
  Len := Length(a.coefficients) + Length(b.coefficients) - 1;
  SetLength(ResultArray,Len);
  for I := 0 to Pred(Len) do
    ResultArray[I] := 0;

  //Results have been initialized to zero. Iterate over both source arrays.
  for I := 0 to Pred(Length(a.Coefficients)) do
  begin
    for J := 0 to Pred(Length(b.Coefficients)) do
      ResultArray[I+J] := ResultArray[I+J] + a.Coefficients[I]*b.Coefficients[J];
  end;

  Result.Coefficients := ResultArray;
end;

class operator TPolynomial.Multiply(a: Extended; b:TPolynomial): TPolynomial;
var
  I: Integer;
begin
  if a = 0 then
  begin
    Result.Coefficients := nil;
    SetLength(Result.Coefficients, 1);
    Result.Coefficients[0] := 0;
  end;

  SetLength(Result.Coefficients, Length(b.Coefficients));
  for I := 0 to Pred(Length(Result.Coefficients)) do
    Result.Coefficients[I] := a * b.Coefficients[I];
end;

class operator TPolynomial.Multiply(a: TPolynomial; b:Extended): TPolynomial;
begin
  Result := b*a; //Polynomials and real numbers commute.
end;

end.

