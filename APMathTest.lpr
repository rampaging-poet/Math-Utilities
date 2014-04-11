program APMathTest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, apmathpolynomial_test, apmathpolynomials;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

