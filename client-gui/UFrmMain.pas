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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, System.ImageList,
  Vcl.ImgList, Vcl.ToolWin, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
