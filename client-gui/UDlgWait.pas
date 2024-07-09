unit UDlgWait;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TdlgWait = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    lblTask: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgWait: TdlgWait;

implementation

{$R *.dfm}

end.
