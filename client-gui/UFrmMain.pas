unit UFrmMain;

{
  Installed Packages
  installed.csv
  PackageName;architecture;os;package-version
  Package Spec
  Zip +-- PreInstall.ps1
  |
  +-- PostInstall.ps1
  |
  +-- pkgutils/
  |       |
  |       +-- (package install utilities)
  |
  +-- pkgfiles/
  |
  +-- (package files)

  Repository spec
  packageindex.csv:
  PackageName;architecture;os;package-version;hash;Desc;Deps
  File structure
  arch/os/PackageName-package-version.zip

}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, System.ImageList,
  Vcl.ImgList, Vcl.ToolWin, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, Zip, JvComponentBase, JvComputerInfoEx, ShellApi;

type
  TfrmMain = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    PageControl1: TPageControl;
    btnAtualizaIdx: TToolButton;
    ToolButton2: TToolButton;
    btnInstalarPacote: TToolButton;
    btnDesinstalarPacote: TToolButton;
    ToolButton5: TToolButton;
    btnSair: TToolButton;
    ilToolbar24: TImageList;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    edtBusca: TButtonedEdit;
    il16: TImageList;
    lvwBuscar: TListView;
    Panel1: TPanel;
    btnAtualizaPkg: TBitBtn;
    ListView1: TListView;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    cdsPackageIndex: TClientDataSet;
    cdsPackageIndexName: TStringField;
    cdsPackageIndexVersion: TStringField;
    cdsPackageIndexOS: TStringField;
    cdsPackageIndexArch: TStringField;
    cdsPackageIndexDesc: TStringField;
    cdsPackageIndexDeps: TStringField;
    cdsPackageIndexhash: TStringField;
    JvComputerInfoEx1: TJvComputerInfoEx;
    function ParsePackageIndex(filename: String): Boolean;
    procedure InstallPackage(packageName: String; Version: String);
    procedure InstallUpdates;
  private
    { Private declarations }
  public
    { Public declarations }
    BaseURL: String = 'https://www.planosinformatica.com.br/repo';
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function TfrmMain.ParsePackageIndex(filename: string): Boolean;
var
  SL: TStringList;
  tmp, packageName, architecture, os, packageversion, hash, Desc, Deps: String;
  I: Integer;
begin
  try
    Result := False;
    SL := TStringList.Create;
    if FileExists(filename) then
    begin
      SL.LoadFromFile(filename);
      for I := 0 to SL.Count - 1 do
      begin
        tmp := SL.Strings[I];
        packageName := Copy(tmp, 1, Pos(';', tmp) - 1);
        Delete(tmp, 1, Pos(';', tmp));
        architecture := Copy(tmp, 1, Pos(';', tmp) - 1);
        Delete(tmp, 1, Pos(';', tmp));
        os := Copy(tmp, 1, Pos(';', tmp) - 1);
        Delete(tmp, 1, Pos(';', tmp));
        packageversion := Copy(tmp, 1, Pos(';', tmp) - 1);
        Delete(tmp, 1, Pos(';', tmp));
        hash := Copy(tmp, 1, Pos(';', tmp) - 1);
        Delete(tmp, 1, Pos(';', tmp));
        Desc := Copy(tmp, 1, Pos(';', tmp) - 1);
        Delete(tmp, 1, Pos(';', tmp));
        Deps := tmp;
        cdsPackageIndex.AppendRecord([packageName, packageversion, os,
          architecture, Desc, Deps, hash]);
      end;
      Result := True;
    end;
    SL.Destroy;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PWideChar(E.Message), 'Erro',
        MB_OK + MB_APPLMODAL + MB_ICONINFORMATION);
      if Assigned(SL) then
        FreeAndNil(SL);
    end;
  end;
end;

procedure TfrmMain.InstallPackage(packageName: String; Version: String);
var
  Package: TZipFile;
  PackageStream: TFileStream;
begin
  try
    PackageStream := TFileStream.Create(ExtractFilePath(Application.ExeName) +
      '\cache\' + packageName + '-' + Version + '.zip', fmOpenWrite);
    IdHTTP1.Get(BaseURL + '/x86-32/windows/' + packageName + '-' + Version +
      '.zip', PackageStream);
    if PackageStream.Size = 0 then
      raise Exception.Create('Arquivo baixado com tamanho zero.');
    FreeAndNil(PackageStream);
    Package := TZipFile.Create;
    Package.Open(ExtractFilePath(Application.ExeName) + '\cache\' + packageName
      + '-' + Version + '.zip', zmRead);
    Package.ExtractAll(GetEnvironmentVariable('TEMP'));
    ShellExecute(Self.Handle, 'open',
      PWideChar(GetEnvironmentVariable('TEMP') + '\preinstall.ps1'), '',
      PWideChar(GetEnvironmentVariable('TEMP')), SW_HIDE);
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PWideChar(E.Message), 'Erro',
        MB_OK + MB_APPLMODAL + MB_ICONINFORMATION);
      if Assigned(PackageStream) then
        FreeAndNil(PackageStream);
      if Assigned(Package) then
        FreeAndNil(Package);
    end;
  end;

end;

end.
