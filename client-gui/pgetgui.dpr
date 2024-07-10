program pgetgui;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {frmMain},
  UPackageManager in '..\..\Comum\UPackageManager.pas',
  UDlgWait in 'UDlgWait.pas' {dlgWait},
  UDlgInstall in 'UDlgInstall.pas' {dlgInstall};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdlgWait, dlgWait);
  Application.CreateForm(TdlgInstall, dlgInstall);
  Application.Run;

end.
