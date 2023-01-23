program pgetgui;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {Form1},
  UPackageManager in '..\comum\UPackageManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
