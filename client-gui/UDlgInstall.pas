unit UDlgInstall;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TdlgInstall = class(TForm)
    memLog: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgInstall: TdlgInstall;

implementation

{$R *.dfm}

end.
