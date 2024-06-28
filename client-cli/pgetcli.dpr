program pgetcli;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows,
  ShellApi,
  Classes,
  Zip,
  Vcl.Graphics,
  Registry,
  JclSecurity,
  StrUtils,
  System.SysUtils,
  UPackageManager in '..\Comum\UPackageManager.pas';

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
  PackageName;architecture;os;package-version;hash
  File structure
  arch/os/PackageName-package-version.zip

}

procedure SetColorConsole(AColor:TColor);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE);
  case AColor of
    clWhite:  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE);
    clRed:    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_INTENSITY);
    clGreen:  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    clBlue:   SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    clMaroon: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY);
    clPurple: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    clAqua: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  end;
end;

function GetAppVersionStr(szFile:String): string;
var
  Exe: string;
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  try
    Exe := szFile;
    Size := GetFileVersionInfoSize(PChar(Exe), Handle);
    if Size = 0 then
      RaiseLastOSError;
    SetLength(Buffer, Size);
    if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
      begin
        Result := 'N/A';
        Exit;
      end;
    if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
      begin
        Result := 'N/A';
        Exit;
      end;
    Result := Format('%d.%d.%d.%d',
      [LongRec(FixedPtr.dwFileVersionMS).Hi,  //major
      LongRec(FixedPtr.dwFileVersionMS).Lo,  //minor
      LongRec(FixedPtr.dwFileVersionLS).Hi,  //release
      LongRec(FixedPtr.dwFileVersionLS).Lo]) //build
  except on E:Exception do
    Result := 'N/A';
  end;
end;

var
  PackageManager : TPackageManager;
  PackageList : TStringList;
  PackageListString : String;
  I : Integer;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    PackageManager := TPackageManager.Create;
    if (ParamCount < 2) then
      begin
        WriteLn('Modo de uso: '+ExtractFileName(ParamStr(0))+' operação <pacote>');
        WriteLn('Exemplo: '+ExtractFileName(ParamStr(0))+' install mgr');
        WriteLn('Operações: '+#13+#10+
          'install: Instala o(s) pacote(s) especificado(s)'+#13+#10+
          'update: Atualiza o indice de pacotes'+#13+#10+
          'search: Busca um pacote pelo nome'+#13+#10+
          'list: Lista todos os pacotes disponiveis'+#13+#10+
          'installed: Lista todos os pacotes instalados'+#13+#10+
          'upgrade: Atualiza todos os pacotes instalados'+#13+#10+
          'uninstall: Desinstala pacote específicado');
        Exit
      end;
    if MatchStr(lowercase(ParamStr(1)) , ['ajuda','h','help','-h','-help','--help','-?'
      ,'/?']) then
      begin
        WriteLn('Modo de uso: '+ExtractFileName(ParamStr(0))+' operação <pacote>');
        WriteLn('Exemplo: '+ExtractFileName(ParamStr(0))+' install mgr');
        WriteLn('Operações: '+#13+#10+
          'install: Instala o(s) pacote(s) especificado(s)'+#13+#10+
          'update: Atualiza o indice de pacotes'+#13+#10+
          'search: Busca um pacote pelo nome'+#13+#10+
          'list: Lista todos os pacotes disponiveis'+#13+#10+
          'installed: Lista todos os pacotes instalados'+#13+#10+
          'upgrade: Atualiza todos os pacotes instalados'+#13+#10+
          'uninstall: Desinstala pacote específicado');
        Exit;
      end;
    PackageList := TStringList.Create;
    if ParamCount >= 2 then
      begin
        for I := 2 to ParamCount-2 do
          begin
            PackageList.Add(lowercase(ParamStr(i)));
            PackageListString := PackageListString + lowercase(ParamStr(i)) +' '
          end;
      end;
    case IndexStr(lowercase(ParamStr(1)),['install','update',
      'upgrade','uninstall', 'list','installed', 'search']) of
      0: begin
        if PackageList.Count = 0  then
          begin
            WriteLn('Nenhum pacote especificado');
            PackageList.Destroy;
            Exit;
          end;
        WriteLn('Os seguintes pacotes serão INSTALADOS:'+PackageListString);
        for I := 0 to PackageList.Count -1 do
          begin
            WriteLn('Instalando pacote'+PackageList.Strings[i]);
            PackageManager.Install(PackageList.Strings[i]);
          end;
      end;
      1: begin
        WriteLn('Atualizando lista de pacotes');
        PackageManager.Update;
      end;
      2: begin
        WriteLn('Atualizando todos os pacotes');
        PackageManager.Upgrade;
      end;
      3: begin
        if PackageList.Count = 0  then
          begin
            WriteLn('Nenhum pacote especificado');
            PackageList.Destroy;
            Exit;
          end;
        WriteLn('Os seguintes pacotes serão REMOVIDOS:'+PackageListString);
        for I := 0 to PackageList.Count -1 do
          begin
            WriteLn('Desinstalando pacote'+PackageList.Strings[i]);
            PackageManager.Uninstall(PackageList.Strings[i]);
          end;
      end;
      4: begin
        WriteLn(PackageManager.PackageList);
      end;
      5:begin
        WriteLn(PackageManager.InstalledList);
      end;
      6: begin
        if ParamCount >= 2 then
          WriteLn(PackageManager.PackageSearch(ParamStr(2)))
        else
          WriteLn('Especifique o nome do pacote a ser pesquisado');
      end;
    end;

  except
    on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
        if Assigned(PackageList) then
          PackageList.Destroy;
      end;
  end;
end.
