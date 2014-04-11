unit APMathIntegration;
{
  (c) 2014 Andrew Perkins

  Numerical integration by several methods.
  These methods assume that f(x) is a continuous function.
}

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils;

type
  TContinuousFunction = function(x: Extended): Extended;
  TObjectContinuousFunction = function(x: Extended): Extended of object;

//Numerical integration using the left-hand value of each step.
function NumIntegrateLeftRect(MinX, MaxX: Extended; NSteps: Integer;
                              f: TContinuousFunction): Extended; overload;

function NumIntegrateLeftRect(MinX, MaxX: Extended; NSteps: Integer;
                              f: TObjectContinuousFunction): Extended; overload;

//Numerical integration using the right-hand value of each step.
function NumIntegrateRightRect(MinX, MaxX: Extended; NSteps: Integer;
                               f: TContinuousFunction): Extended; overload;

function NumIntegrateRightRect(MinX, MaxX: Extended; NSteps: Integer;
                               f: TObjectContinuousFunction): Extended; overload;

//Numerical integration using the midpoint value of each step.
function NumIntegrateMidRect(MinX, MaxX: Extended; NSteps: Integer;
                             f: TContinuousFunction): Extended; overload;

function NumIntegrateMidRect(MinX, MaxX: Extended; NSteps: Integer;
                             f: TObjectContinuousFunction): Extended; overload;

//Numerical integration using a trapezoidal approximation.
function NumIntegrateTrapezoid(MinX, MaxX: Extended; NSteps: Integer;
                               f: TContinuousFunction): Extended; overload;

function NumIntegrateTrapezoid(MinX, MaxX: Extended; NSteps: Integer;
                               f: TObjectContinuousFunction): Extended; overload;

//Numerical integration using Simpson's approximation.
function NumIntegrateSimpson(MinX, MaxX: Extended; NSteps: Integer;
                             f: TContinuousFunction): Extended; overload;

function NumIntegrateSimpson(MinX, MaxX: Extended; NSteps: Integer;
                             f: TObjectContinuousFunction): Extended; overload;

implementation

function NumIntegrateLeftRect(MinX, MaxX: Extended; NSteps: Integer;
                              f: TContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Evaluate f(x) and integrate over stepsize.
    Result := Result + (f(x) * StepSize);
    //Increment x.
    x := x + StepSize;
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  Result := Result + (f(x) * (MaxX - x));
end;

function NumIntegrateLeftRect(MinX, MaxX: Extended; NSteps: Integer;
                              f: TObjectContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Evaluate f(x) and integrate over stepsize.
    Result := Result + (f(x) * StepSize);
    //Increment x.
    x := x + StepSize;
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  Result := Result + (f(x) * (MaxX - x));
end;

function NumIntegrateRightRect(MinX, MaxX: Extended; NSteps: Integer;
                               f: TContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Increment x.
    x := x + StepSize;
    //Evaluate f(x) and integrate over stepsize.
    Result := Result + (f(x) * StepSize);
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  Result := Result + (f(MaxX) * (MaxX - x));
end;

function NumIntegrateRightRect(MinX, MaxX: Extended; NSteps: Integer;
                               f: TObjectContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Increment x.
    x := x + StepSize;
    //Evaluate f(x) and integrate over stepsize.
    Result := Result + (f(x) * StepSize);
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  Result := Result + (f(MaxX) * (MaxX - x));
end;

function NumIntegrateMidRect(MinX, MaxX: Extended; NSteps: Integer;
                             f: TContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Evaluate f(x+ 0.5*StepSize) and integrate over stepsize.
    Result := Result + (f(x+ StepSize/2) * StepSize);
    //Increment x.
    x := x + StepSize;
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  StepSize := MaxX - x;
  Result := Result + (f(x+ StepSize/2) * StepSize);
end;

function NumIntegrateMidRect(MinX, MaxX: Extended; NSteps: Integer;
                             f: TObjectContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Evaluate f(x+ 0.5*StepSize) and integrate over stepsize.
    Result := Result + (f(x+ StepSize/2) * StepSize);
    //Increment x.
    x := x + StepSize;
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  StepSize := MaxX - x;
  Result := Result + (f(x+ StepSize/2) * StepSize);
end;

function NumIntegrateTrapezoid(MinX, MaxX: Extended; NSteps: Integer;
                               f: TContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
  LeftY, RightY: Extended;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);
  RightY   := f(MinX);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Increment x.
    x := x + StepSize;
    //Evaluate f(x) at the new value, integrate (LeftY + RightY) / 2.
    LeftY  := RightY;
    RightY := f(x);
    Result := Result + ((LeftY + RightY) * StepSize) / 2;
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  Result := Result + ((RightY + f(MaxX)) * StepSize) / 2;
end;

function NumIntegrateTrapezoid(MinX, MaxX: Extended; NSteps: Integer;
                               f: TObjectContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
  LeftY, RightY: Extended;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);
  RightY   := f(MinX);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Increment x.
    x := x + StepSize;
    //Evaluate f(x) at the new value, integrate (LeftY + RightY) / 2.
    LeftY  := RightY;
    RightY := f(x);
    Result := Result + ((LeftY + RightY) * StepSize) / 2;
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  Result := Result + ((RightY + f(MaxX)) * StepSize) / 2;
end;

function NumIntegrateSimpson(MinX, MaxX: Extended; NSteps: Integer;
                             f: TContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
  LeftY, MidY, RightY: Extended;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);
  RightY   := f(MinX);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Get left and midpoint values of f(x)
    LeftY := RightY;
    MidY  := f(x + StepSize/2);

    //Increment x.
    x := x + StepSize;

    //Evaluate f(x) at the new value, integrate by Simpson's rule
    RightY := f(x);
    Result := Result + (StepSize / 6) * (LeftY + 4*MidY + RightY);
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  StepSize := MaxX - x;
  LeftY    := RightY;
  MidY     := f(x + StepSize / 2);
  RightY   := f(MaxX);
  Result := Result + (StepSize / 6) * (LeftY + 4*MidY + RightY);
end;

function NumIntegrateSimpson(MinX, MaxX: Extended; NSteps: Integer;
                             f: TObjectContinuousFunction): Extended;
var
  x: Extended;
  StepSize: Extended;
  Step: Integer;
  LeftY, MidY, RightY: Extended;
begin
  //Initialize result and step information.
  Result   := 0;
  x        := MinX;
  StepSize := (MaxX - MinX / NSteps);
  RightY   := f(MinX);

  //Perform steps 1 to N-1 in a loop.
  for Step := 1 to Pred(NSteps) do
  begin
    //Get left and midpoint values of f(x)
    LeftY := RightY;
    MidY  := f(x + StepSize/2);

    //Increment x.
    x := x + StepSize;

    //Evaluate f(x) at the new value, integrate by Simpson's rule
    RightY := f(x);
    Result := Result + (StepSize / 6) * (LeftY + 4*MidY + RightY);
  end;

  //Integrate from step n-1 to MaxX in case of floating point errors in x.
  StepSize := MaxX - x;
  LeftY    := RightY;
  MidY     := f(x + StepSize / 2);
  RightY   := f(MaxX);
  Result := Result + (StepSize / 6) * (LeftY + 4*MidY + RightY);
end;

end.

