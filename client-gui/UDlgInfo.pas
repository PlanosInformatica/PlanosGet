unit UDlgInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TdlgInfo = class(TForm)
    edtPackageName: TLabeledEdit;
    edtPackageVersion: TLabeledEdit;
    edtPackageDescription: TLabeledEdit;
    edtPackageHash: TLabeledEdit;
    edtPackageDependencies: TLabeledEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgInfo: TdlgInfo;

implementation

{$R *.dfm}

end.
