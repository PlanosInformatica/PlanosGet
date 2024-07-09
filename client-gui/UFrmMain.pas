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
  Vcl.ImgList, Vcl.ToolWin, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, IOUtils,
  UPackageManager;

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
    lvwPacotes: TListView;
    Panel1: TPanel;
    btnAtualizaPkg: TBitBtn;
    lvwAtualizacoes: TListView;
    procedure FormCreate(Sender: TObject);
    procedure btnAtualizaIdxClick(Sender: TObject);
    procedure CarregaAtualiza;
    procedure CarregaPacotes;
  private
    { Private declarations }
  public
    { Public declarations }
    PackageManager : TPackageManager;

  end;

var
  frmMain: TfrmMain;

const
  BaseURL: String = 'https://www.planosinformatica.com.br/repo';
implementation

uses UDlgWait;

{$R *.dfm}


procedure TfrmMain.btnAtualizaIdxClick(Sender: TObject);
var
  Output : String;
begin
  dlgWait.lblTask.Caption := 'Verificando atualizações';
  dlgWait.Show;
  Application.ProcessMessages;
  if PackageManager.Update(Output) then
    MessageBox(Self.Handle,PWideChar(Output),PWideChar(Self.Caption),MB_OK+MB_ICONINFORMATION+MB_APPLMODAL);
  CarregaAtualiza;
  CarregaPacotes;
  dlgWait.Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  PackageManager := TPackageManager.Create(
    ExtractFilePath(Application.ExeName),
    ExtractFilePath(Application.ExeName),TPath.GetTempPath,BaseURL);
  CarregaPacotes;
  CarregaAtualiza;
end;

procedure TfrmMain.CarregaAtualiza;
var
  L : TListItem;
  I: Integer;
  InstalledName,InstalledVersion, tmp : String;
  Metadata : PPackageMetadata;
begin
  lvwAtualizacoes.Clear;
  for I := 0 to PackageManager.InstalledPackages.Count -1 do
    begin
      tmp := PackageManager.InstalledPackages.Strings[I];
      InstalledName := Copy(tmp,1,Pos(';',tmp)-1);
      Delete(tmp,1,Pos(';',tmp));
      Delete(tmp,1,Pos(';',tmp));
      Delete(tmp,1,Pos(';',tmp));
      InstalledVersion := Copy(tmp,1,Pos(';',tmp)-1);
      Metadata := PackageManager.SearchPackage(InstalledName);
      if Assigned(Metadata) then
        begin
          if Metadata.VersionString <> InstalledVersion then
            begin
              L := lvwAtualizacoes.Items.Add;
              L.Caption := Metadata.Name;
              L.SubItems.Add(Metadata.Description);
              L.SubItems.Add(InstalledVersion);
              L.SubItems.Add(Metadata.VersionString);
            end;
        end;
      Dispose(Metadata);
      Metadata := nil;
    end;
end;

procedure TfrmMain.CarregaPacotes;
var
  L : TListItem;
  I : Integer;
  Metadata : PPackageMetadata;
  tmp : String;
begin
  lvwPacotes.Clear;
  for I := 0 to PackageManager.CurrentPackageIndex.Count -1 do
    begin
      tmp := Copy(PackageManager.CurrentPackageIndex.Strings[I],1,Pos(';',PackageManager.CurrentPackageIndex.Strings[I])-1);
      Metadata := PackageManager.SearchPackage(tmp);
      if Assigned(Metadata) then
        begin
          L := lvwPacotes.Items.Add;
          if PackageManager.IsInstalled(Metadata.Name) then
            L.Caption := 'Instalado';
          L.SubItems.Add(Metadata.Name);
          L.SubItems.Add(Metadata.VersionString);
          L.SubItems.Add(Metadata.Description);
          Dispose(Metadata);
          Metadata := nil;
        end;
    end;
end;

end.
