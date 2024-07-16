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
  System.IOUtils,
  UPackageManager in '..\..\Comum\UPackageManager.pas';

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

procedure SetColorConsole(AColor: TColor);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED or
    FOREGROUND_GREEN or FOREGROUND_BLUE);
  case AColor of
    clWhite:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED or
        FOREGROUND_GREEN or FOREGROUND_BLUE);
    clRed:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED or
        FOREGROUND_INTENSITY);
    clGreen:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
        FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    clBlue:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
        FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    clMaroon:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
        FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY);
    clPurple:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED or
        FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    clAqua:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
        FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  end;
end;

function GetAppVersionStr(szFile: String): string;
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
    Result := Format('%d.%d.%d.%d', [LongRec(FixedPtr.dwFileVersionMS).Hi,
      // major
      LongRec(FixedPtr.dwFileVersionMS).Lo, // minor
      LongRec(FixedPtr.dwFileVersionLS).Hi, // release
      LongRec(FixedPtr.dwFileVersionLS).Lo]) // build
  except
    on E: Exception do
      Result := 'N/A';
  end;
end;

var
  PackageManager: TPackageManager;
  PackageMetaData: PPackageMetadata;
  PackageList: TStringList;
  PackageListString, CommandOutput,tmp: String;
  I: Integer;

begin
  try
    SetColorConsole(clWhite);
    PackageManager := TPackageManager.Create(ExtractFilePath(ParamStr(0)),
      ExtractFilePath(ParamStr(0)), System.IOUtils.TPath.GetTempPath(),
      'https://www.planosinformatica.com.br/repo');
    if (ParamCount < 1) then
    begin
      WriteLn('Modo de uso: ' + ExtractFileName(ParamStr(0)) +
        ' operação <pacote>');
      WriteLn('Exemplo: ' + ExtractFileName(ParamStr(0)) + ' install mgr');
      WriteLn('Operações: ' + #13 + #10 +
        'install: Instala o(s) pacote(s) especificado(s)' + #13 + #10 +
        'update: Atualiza o indice de pacotes' + #13 + #10 +
        'search: Busca um pacote pelo nome' + #13 + #10 +
        'list: Lista todos os pacotes disponiveis' + #13 + #10 +
        'installed: Lista todos os pacotes instalados' + #13 + #10 +
        'upgrade: Atualiza todos os pacotes instalados' + #13 + #10 +
        'uninstall: Desinstala pacote específicado');
      Exit
    end;
    if MatchStr(lowercase(ParamStr(1)), ['ajuda', 'h', 'help', '-h', '-help',
      '--help', '-?', '/?']) then
    begin
      WriteLn('Modo de uso: ' + ExtractFileName(ParamStr(0)) +
        ' operação <pacote>');
      WriteLn('Exemplo: ' + ExtractFileName(ParamStr(0)) + ' install mgr');
      WriteLn('Operações: ' + #13 + #10 +
        'install: Instala o(s) pacote(s) especificado(s)' + #13 + #10 +
        'update: Atualiza o indice de pacotes' + #13 + #10 +
        'search: Busca um pacote pelo nome' + #13 + #10 +
        'list: Lista todos os pacotes disponiveis' + #13 + #10 +
        'installed: Lista todos os pacotes instalados' + #13 + #10 +
        'upgrade: Atualiza todos os pacotes instalados' + #13 + #10 +
        'uninstall: Desinstala pacote específicado');
      Exit;
    end;
    PackageList := TStringList.Create;
    for I := 2 to ParamCount -1 do
      begin
        PackageList.Add(lowercase(ParamStr(I)));
        PackageListString := PackageListString + lowercase(ParamStr(I)) + ' '
      end;

    case IndexStr(lowercase(ParamStr(1)), ['install', 'update', 'upgrade',
      'uninstall', 'list', 'installed', 'search']) of
      0:
        begin
          if PackageList.Count = 0 then
          begin
            WriteLn('Nenhum pacote especificado');
            PackageList.Destroy;
            Exit;
          end;
          SetColorConsole(clGreen);
          WriteLn('Os seguintes pacotes serão INSTALADOS:' + PackageListString);
          SetColorConsole(clWhite);
          for I := 0 to PackageList.Count - 1 do
          begin
            WriteLn('Instalando pacote ' + PackageList.Strings[I]);
            PackageManager.Install(PackageList.Strings[I], CommandOutput);
            WriteLn(CommandOutput);
          end;
        end;
      1:
        begin
          WriteLn('Atualizando lista de pacotes');
          PackageManager.Update(CommandOutput);
          WriteLn(CommandOutput);
        end;
      2:
        begin
          WriteLn('Atualizando todos os pacotes');
          PackageManager.Upgrade(CommandOutput);
          WriteLn(CommandOutput);
        end;
      3:
        begin
          if PackageList.Count = 0 then
          begin
            SetColorConsole(clYellow);
            WriteLn('Nenhum pacote especificado');
            SetColorConsole(clWhite);
            PackageList.Destroy;
            Exit;
          end;
          SetColorConsole(clRed);
          WriteLn('Os seguintes pacotes serão REMOVIDOS:' + PackageListString);
          SetColorConsole(clYellow);
          for I := 0 to PackageList.Count - 1 do
          begin
            WriteLn('Desinstalando pacote ' + PackageList.Strings[I]);
            PackageManager.Uninstall(PackageList.Strings[I], CommandOutput);
            WriteLn(CommandOutput);
          end;
          SetColorConsole(clWhite);
        end;
      4:
        begin
          for I := 0 to PackageManager.CurrentPackageIndex.Count - 1 do
          begin
            tmp := Copy(PackageManager.CurrentPackageIndex.Strings[I], 1,
              Pos(';', PackageManager.CurrentPackageIndex.Strings[I]) - 1);
            PackageMetaData := PackageManager.SearchPackage(tmp);
              if Assigned(PackageMetaData) then
                begin
                  SetColorConsole(clGreen);
                  Write(PackageMetadata.Name);
                  SetColorConsole(clWhite);
                  Write('[');
                  SetColorConsole(clAqua);
                  Write(PackageMetadata.Arch+'/'+PackageMetadata.OS);
                  SetColorConsole(clWhite);
                  Write(']('+PackageMetadata.VersionString+'):'+PackageMetadata.Description);
                  WriteLn('');
                  Dispose(PackageMetaData);
                  PackageMetaData := nil;
                end;
          end;
        end;
      5:
        begin
          for I := 0 to PackageManager.InstalledPackages.Count - 1 do
          begin
            tmp := Copy(PackageManager.InstalledPackages.Strings[I], 1,
              Pos(';', PackageManager.InstalledPackages.Strings[I]) - 1);
              PackageMetaData := PackageManager.SearchPackage(tmp);
              if Assigned(PackageMetaData) then
                begin
                  SetColorConsole(clGreen);
                  Write(PackageMetadata.Name);
                  SetColorConsole(clWhite);
                  Write('[');
                  SetColorConsole(clAqua);
                  Write(PackageMetadata.Arch+'/'+PackageMetadata.OS);
                  SetColorConsole(clWhite);
                  Write(']('+PackageMetadata.VersionString+'):'+PackageMetadata.Description);
                  WriteLn('');
                  Dispose(PackageMetaData);
                  PackageMetaData := nil;
                end;
            WriteLn('');
          end;
        end;
      6:
        begin
          if ParamCount >= 2 then
          begin
            PackageMetaData := PackageManager.SearchPackage(ParamStr(2));
            if Assigned(PackageMetaData) then
                begin
                  WriteLn('--------------------------------------');
                  SetColorConsole(clGreen);
                  Write(PackageMetadata.Name);
                  SetColorConsole(clWhite);
                  Write('[');
                  SetColorConsole(clAqua);
                  Write(PackageMetadata.Arch+'/'+PackageMetadata.OS);
                  SetColorConsole(clWhite);
                  Write(']('+PackageMetadata.VersionString+'):'+PackageMetadata.Description);
                  WriteLn('');
                  WriteLn('Depende de:'+PackageMetaData.Dependencies);
                  WriteLn('--------------------------------------');
                  Dispose(PackageMetaData);
                  PackageMetaData := nil;

                end;
            WriteLn('');
          end
          else
            SetColorConsole(clYellow);
            WriteLn('Especifique o nome do pacote a ser pesquisado');
            SetColorConsole(clWhite);
        end;
    end;

  except
    on E: Exception do
    begin
      WriteLn(E.ClassName, ': ', E.Message);
      if Assigned(PackageList) then
        PackageList.Destroy;
    end;
  end;

end.
