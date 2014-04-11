{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit APMath;

interface

uses
  APMathIntegration, apmathpolynomials, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('APMath', @Register);
end.
