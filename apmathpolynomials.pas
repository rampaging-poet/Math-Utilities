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
  private
    //The ith value is the coefficient of the ith-order term of the polynomial.
    FCoefficients: TExtendedArray;

    procedure TrimCoefficients;

    function  GetCoefficient(const Index: Integer): Extended;
    procedure SetCoefficient(const Index: Integer; const Value: Extended);
  public
    //Evaluation
    function Order: Integer;
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
  public
    property Coefficients[const Index: Integer]: Extended read GetCoefficient
      write SetCoefficient;
  end;

  //Set all coefficients from an open array - allows assigning constants.
  //Using an out parameter prevents "not initialized" warnings.
  procedure SetCoefficients(out a: TPolynomial; const Values: array of Extended);

implementation
uses
  Math;

resourcestring
  FSInvalidIndex = 'Invalid polynomial index %d';

procedure TPolynomial.TrimCoefficients;
var
  I: Integer;
begin
  //Do nothing if no coefficients are assigned.
  if FCoefficients = nil then Exit;

  //Do nothing if there are no trailing zeros.
  if FCoefficients[High(FCoefficients)] <> 0 then Exit;

  //Trim trailing zeroes to ensure length and order are related.
  for I := Pred(Pred(Length(FCoefficients))) downto 0 do
  begin
    if FCoefficients[I] <> 0 then
    begin
      //At least one non-zero coefficient exists. Set Coefficients and exit.
      FCoefficients := Copy(FCoefficients,0,Succ(I));
      Exit;
    end;
  end;

  //If we get here, then the array was entirely composed of zeroes.
  FCoefficients := nil; //Remove any existing reference.
  SetLength(FCoefficients,1);
  FCoefficients[0] := 0;
end;

function TPolynomial.GetCoefficient(const Index: Integer): Extended;
begin
  Result := 0;

  if (Index < 0) then
    raise EInvalidArgument.CreateFmt(FSInvalidIndex,[Index]);

  if (FCoefficients = nil) then Exit;
  if Length(FCoefficients) <= Index then Exit;

  Result := FCoefficients[Index];
end;

procedure TPolynomial.SetCoefficient(const Index: Integer; const Value: Extended);
var
  Len: Integer;
  I: Integer;
begin
  if (Index < 0) then
    raise EInvalidArgument.CreateFmt(FSInvalidIndex,[Index]);

  if (FCoefficients = nil) then
    Len := 0
  else
    Len := Length(FCoefficients);

  if Index >= Len then
  begin
    //Attempt to write coefficient past end of array. Extend array.
    SetLength(FCoefficients,Succ(Index));
    for I := Len to Pred(Index) do
      FCoefficients[I] := 0;
  end;

  FCoefficients[Index] := Value; //Assign given value.
  TrimCoefficients;
end;

function TPolynomial.Order: Integer;
begin
  if FCoefficients = nil then
    Result := 0
  else
    Result := Pred(Length(FCoefficients));
end;

function TPolynomial.Value(x: Extended): Extended;
var
  I: Integer;
begin
  Result := 0;

  for I := Pred(Length(FCoefficients)) downto 0 do
    Result := Result * x + FCoefficients[I];
end;

function TPolynomial.Derivative: TPolynomial;
var
  Len: Integer;
  I: Integer;
begin
  if FCoefficients = nil then
  begin
    Result.FCoefficients := nil;
    Exit;
  end;

  Len := Length(FCoefficients);
  //Catch the base case - f(x) is a constant.
  if Len < 2 then
  begin
    SetLength(Result.FCoefficients, 1);
    Result.FCoefficients[0] := 0;
    Exit;
  end;

  //The result is a polynomial of degree n-1.
  SetLength(Result.FCoefficients, Pred(Len));

  for I := 1 to Pred(Len) do
    Result.FCoefficients[Pred(I)] := FCoefficients[I] * I;
end;

function TPolynomial.Integral: TPolynomial;
var
  Len: Integer;
  I: Integer;
begin
  if FCoefficients = nil then
  begin
    Result.FCoefficients := nil;
    Exit;
  end;

  Len := Length(FCoefficients);

  //Polynomial is of degree n+1, constant of integration assumed to be zero.
  SetLength(Result.FCoefficients,Succ(Len));
  Result.FCoefficients[0] := 0;

  //Integral of ith term is ith term divided by i+1.
  for I := 1 to Pred(Len) do
    Result.FCoefficients[I+1] := FCoefficients[I] / (I + 1);
end;

class operator TPolynomial.Implicit(a: TExtendedArray): TPolynomial;
begin
  Result.FCoefficients := Copy(a,0,MaxInt);
  Result.TrimCoefficients;
end;

class operator TPolynomial.Negative(a: TPolynomial): TPolynomial;
var
  I: Integer;
begin
  Result.FCoefficients := Copy(a.FCoefficients,0,MaxInt);

  for I := 0 to Pred(Length(Result.FCoefficients)) do
    Result.FCoefficients[I] := -Result.FCoefficients[I];
end;

class operator TPolynomial.Equal(a, b: TPolynomial): Boolean;
var
  Len: Integer;
  I: Integer;
  LongArray: TExtendedArray;
begin
  Result := False;

  //Nil checks.
  if (a.FCoefficients = nil) then
  begin
    if (b.FCoefficients = nil) then
      Result := True
    else
      Result := (Length(b.FCoefficients) = 1) and (b.FCoefficients[0] = 0);

    Exit;
  end;

  if (b.FCoefficients = nil) then
  begin
    Result := (Length(a.FCoefficients) = 1) and (a.FCoefficients[0] = 0);
    Exit;
  end;

  //Check order of polynomials.
  Len := Length(a.FCoefficients);

  case CompareValue(Len, Length(b.FCoefficients)) of
    -1: LongArray := b.FCoefficients; //a is shorter than b
    0:  LongArray := nil;             //They are the same length
    1:                                //a is longer than b
      begin
        LongArray := a.FCoefficients;
        Len       := Length(b.FCoefficients);
      end;
  end;

  //Iterate over polynomials to find first nonmatching coefficients.
  for I := 0 to Pred(Len) do
    if a.FCoefficients[I] <> b.FCoefficients[I] then Exit;

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
  if a.FCoefficients = nil then
  begin
    Result.FCoefficients := Copy(b.FCoefficients,0,MaxInt);
    Exit;
  end;

  if b.FCoefficients = nil then
  begin
    Result.FCoefficients := Copy(a.FCoefficients,0,MaxInt);
    Exit;
  end;

  //Determine which polynomial is of higher degree.
  MinLen := Length(a.FCoefficients);

  if Length(b.FCoefficients) >= MinLen then
  begin
    SourceArray := a.FCoefficients;
    ResultArray := Copy(b.FCoefficients,0,MaxInt);
  end else
  begin
    MinLen := Length(b.FCoefficients);
    SourceArray := b.FCoefficients;
    ResultArray := Copy(a.FCoefficients);
  end;

  //Add lower degree polynomial to higher higher degree ResultArray.
  for I := 0 to Pred(MinLen) do
    ResultArray[I] := ResultArray[I] + SourceArray[I];

  //Assign result array to result polynomial.
  Result.FCoefficients := ResultArray;
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
  if (a.FCoefficients = nil) or (b.FCoefficients = nil) then
  begin
    Result.FCoefficients := nil;
    Exit;
  end;

  //Length = Degree + 1.
  //Degree(a*b) = Degree(a) + Degree(b)
  //Therefore Length(a*b) = a.Order + b.Order +1;
  Len := Succ(a.Order + b.Order);
  SetLength(ResultArray,Len);
  for I := 0 to Pred(Len) do
    ResultArray[I] := 0;

  //Results have been initialized to zero. Iterate over both source arrays.
  for I := 0 to Pred(Length(a.FCoefficients)) do
  begin
    for J := 0 to Pred(Length(b.FCoefficients)) do
      ResultArray[I+J] := ResultArray[I+J] + a.FCoefficients[I]*b.FCoefficients[J];
  end;

  Result.FCoefficients := ResultArray;
end;

class operator TPolynomial.Multiply(a: Extended; b:TPolynomial): TPolynomial;
var
  I: Integer;
begin
  if a = 0 then
  begin
    Result.FCoefficients := nil;
    SetLength(Result.FCoefficients, 1);
    Result.FCoefficients[0] := 0;
  end;

  SetLength(Result.FCoefficients, Length(b.FCoefficients));
  for I := 0 to Pred(Length(Result.FCoefficients)) do
    Result.FCoefficients[I] := a * b.FCoefficients[I];
end;

class operator TPolynomial.Multiply(a: TPolynomial; b:Extended): TPolynomial;
begin
  Result := b*a; //Polynomials and real numbers commute.
end;

procedure SetCoefficients(out a: TPolynomial; const Values: array of Extended);
var
  LastIndex: Integer;
  I: Integer;
begin
  LastIndex := -1;

  //Find the last non-zero entry.
  for I := High(Values) downto Low(Values) do
  begin
    if Values[I] <> 0 then
    begin
      LastIndex := I;
      Break;
    end;
  end;

  if LastIndex < 0 then
  begin
    a.FCoefficients := nil;
    Exit;
  end;

  //Replace existing array.
  SetLength(a.FCoefficients, Succ(High(Values)));

  for I := 0 to High(Values) do
    a.FCoefficients[I] := Values[I];
end;

end.

