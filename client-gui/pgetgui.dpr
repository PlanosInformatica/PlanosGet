program pgetgui;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {frmMain} ,
  UPackageManager in '..\comum\UPackageManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

end.
