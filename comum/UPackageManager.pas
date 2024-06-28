unit UPackageManager;

interface

uses
  SysUtils, Windows, ShellApi, Classes, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Zip, JvComponentBase, JvComputerInfoEx;

type
  TPackageMetadata = record
    Name: String;
    Arch: String;
    OS: String;
    VersionString: String;
    VersionMaj: Integer;
    VersionMin: Integer;
    VersionRel: Integer;
    VersionBuild: Integer;
    Hash: String;
    Description: String;
    Dependencies: String;
  end;

type
  PPackageMetadata = ^TPackageMetadata;

type
  TPackageManager = class(TObject)
  private
    FCurrentPackageIndex: TStringList;
    FNewPackageIndex: TStringList;
    FInstalledPackages: TStringList;
    Http: TIdHttp;
    SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    FBasePath: String;
    FInstallPath: String;
    FTempPath: String;
    FRepository: String;
    function GetPackageFileName(PackageMetadata: PPackageMetadata): String;
    function ParseVersionString(version: String; var Major: Integer;
      var Minor: Integer; var Release: Integer; var Build: Integer): Boolean;
    function ParsePackageMetadata(PackageName: String): PPackageMetadata;
    function MetadataToString(Package:PPackageMetadata):String;
    function DownloadFile(url: String;Destination:String): Boolean;
    function IsInstalled(PackageName: String): Boolean;
    function InstalledList: TStringList;
    function PackageList: TStringList;
    function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
  public
    property BasePath: String read FBasePath write FBasePath;
    property InstallPath: String read FInstallPath write FInstallPath;
    property TempPath: String read FTempPath write FTempPath;
    property Repository: String read FRepository write FRepository;
    property CurrentPackageIndex: TStringList read FCurrentPackageIndex
      write FCurrentPackageIndex;
    property InstalledPackages: TStringList read FInstalledPackages
      write FInstalledPackages;
    constructor Create(BasePath: String; InstallPath: String; TempPath: String;
      Repo: String); override;
    function Install(PackageName: String;var Output:String): Boolean;
    function Update(var Output:String): Boolean;
    function Upgrade(var Output:String): Boolean;
    function Uninstall(PackageName: String;var Output:String): Boolean;
    function SearchPackage(PackageName: String): PPackageMetadata;
  end;

implementation

constructor TPackageManager.Create(BasePath: string; InstallPath: string;
  TempPath: string; Repo: String);
begin
  inherited Create;
  FCurrentPackageIndex := TStringList.Create;
  FNewPackageIndex := TStringList.Create;
  FInstalledPackages := TStringList.Create;
  Http := TIdHttp.Create(nil);
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Http.IOHandler := SSLIOHandler;
  Self.FBasePath := BasePath;
  Self.FInstallPath := InstallPath;
  Self.FTempPath := TempPath;
  Self.FRepository := Repo;
  if FileExists(Self.FBasePath+'\packageindex.csv') then
    begin
      Self.FCurrentPackageIndex.LoadFromFile(Self.FBasePath+'\packageindex.csv');
    end;
  if FileExists(Self.FBasePath+'\installed.csv') then
    Self.FInstalledPackages.LoadFromFile(Self.FBasePath+'\installed.csv')
  else
    Self.FInstalledPackages.SaveToFile(Self.FBasePath+'\installed.csv');
end;

function TPackageManager.DownloadFile(url: String;destination:String): String;
var
  fs: TFileStream;
begin
  try
    fs := TFileStream.Create(Self.TempPath + '\' + ExtractFileName(url));
    Http.Get(url, fs);
  except
    on E: Exception do
      Result := '';
  end;
end;

function TPackageManager.ParseVersionString(version: string; var Major: Integer;
  var Minor: Integer; var Release: Integer; var Build: Integer): Boolean;
var
  tmp, maj, min, rel, bui: String;
begin
  tmp := version;
  maj := Copy(tmp, 1, Pos('.', tmp) - 1);
  Delete(tmp, 1, Pos('.', tmp));
  min := Copy(tmp, 1, Pos('.', tmp) - 1);
  Delete(tmp, 1, Pos('.', tmp));
  rel := Copy(tmp, 1, Pos('.', tmp) - 1);
  Delete(tmp, 1, Pos('.', tmp));
  bui := Copy(tmp, 1, Pos('.', tmp) - 1);
  Delete(tmp, 1, Pos('.', tmp));
  if not TryStrToInt(maj, Major) then
  begin
    Result := false;
    Exit;
  end;
  if not TryStrToInt(min, Minor) then
  begin
    Result := false;
    Exit;
  end;
  if not TryStrToInt(rel, Release) then
  begin
    Result := false;
    Exit;
  end;
  if not TryStrToInt(bui, Build) then
  begin
    Result := false;
    Exit;
  end;
end;

function TPackageManager.ParsePackageMetadata(PackageName: String)
  : PPackageMetadata;
var
  I, VersionMaj, VersionMin, VersionRel, VersionBuild: Integer;
  tmp, Name, Arch, OS, version, Hash, desc, deps: String;
  pkg: PPackageMetadata;
begin
  for I := 0 to FCurrentPackageIndex.Count - 1 do
  begin
    tmp := FCurrentPackageIndex.Strings[I];
    name := Copy(tmp, 1, Pos(';', tmp) - 1);
    Delete(tmp, 1, Pos(';', tmp));
    Arch := Copy(tmp, 1, Pos(';', tmp) - 1);
    Delete(tmp, 1, Pos(';', tmp));
    OS := Copy(tmp, 1, Pos(';', tmp) - 1);
    Delete(tmp, 1, Pos(';', tmp));
    version := Copy(tmp, 1, Pos(';', tmp) - 1);
    Delete(tmp, 1, Pos(';', tmp));
    Hash := Copy(tmp, 1, Pos(';', tmp) - 1);
    Delete(tmp, 1, Pos(';', tmp));
    desc := Copy(tmp, 1, Pos(';', tmp) - 1);
    Delete(tmp, 1, Pos(';', tmp));
    deps := tmp;
    ParseVersionString(version, VersionMaj, VersionMin, VersionRel,
      VersionBuild);
    if name = PackageName then
    begin
      New(pkg);
      pkg.Name := name;
      pkg.Arch := Arch;
      pkg.OS := OS;
      pkg.VersionString := version;
      pkg.VersionMaj := VersionMaj;
      pkg.VersionMin := VersionMin;
      pkg.VersionRel := VersionRel;
      pkg.VersionBuild := VersionBuild;
      Result := pkg;
      Exit;
    end
  end;
  Result := nil;
end;

function TPackageManager.MetadataToString(Package:PPackageMetadata):String;
begin
  Result:= Package.Name+';'+Package.Arch+';'+Package.OS+';'+
    Package.VersionString+';'+Package.Hash+';'+Package.Description+
    ';'+Package.Dependencies;
end;
function TPackageManager.IsInstalled(PackageName: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to Self.FInstalledPackages.Count - 1 do
  begin
    if Copy(FInstalledPackages.Strings[I], 1,
      Pos(';', FInstalledPackages.Strings[I]) - 1) = PackageName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TPackageManager.GetPackageFileName(PackageMetadata
  : PPackageMetadata): String;
begin
  Result := PackageMetadata.Name + '-' + PackageMetadata.VersionString + '.zip';
end;

function TPackageManager.GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := '';
  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PWideChar('powershell.exe -executionpolicy unrestricted "' + CommandLine+'"'),
                            nil, nil, True, 0, nil,
                            PWideChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

function TPackageManager.Install(PackageName: String ;var Output:String): Boolean;
var
  Package: TZipFile;
  tempFilename,ExtractSubdir: String;
  PackageMetadata: PPackageMetadata;
begin
  try
    // Verificando se o pacote existe e puxando os meta dados do pacote
    PackageMetadata := ParsePackageMetadata(PackageName);
    //Se não existir o parse retorna um ponteiro nulo
    if PackageMetadata = nil then
      begin
        //Pacote não existe, retornamos com erro
        Result := False;
        Output := 'Pacote não encontrado';
        Exit;
      end;
    //Verificamos se o pacote está instalado
    if IsInstalled(PackageName) then
      begin
        //Pacote já instalado, retornamos com erro
        Result := False;
        Output := 'Pacote já está instalado!';
        Exit;
      end;
    //Arquivo temporario para download
    tempFilename := Self.TempPath+'\'+GetPackageFileName(PackageMetadata);
    //Tentamos fazer o download do arquivo
    if not DownloadFile(FRepository + '/' + GetPackageFileName(PackageMetadata),tempFilename) then
      begin
        //Se o arquivo não existir, retornamos com erro
        Result := False;
        Output := 'Falha ao efetuar download do arquivo!';
        Exit;
      end;
    //Instanciando o objeto do pacote
    Package := TZipFile.Create;
    //Abrimos o pacote baixado
    Package.Open(tempFilename,zmRead);
    //Definimos o diretório de extração
    ExtractSubdir := Self.TempPath + PackageName;
    //Se ele não existir criamos
    if not DirectoryExists(ExtractSubDir) then
      CreateDir(ExtractSubDir);
    //Tentamos extrair o pacote para a pasta temporária
    Package.ExtractAll(ExtractSubDir);
    //Executamos o script de instalação
    Output := GetDOSOutput(ExtractSubDir+'\PreInstall.ps1',InstallPath);
    //Copiamos o script de desinstalação
    CopyFile(PWideChar(ExtractSubDir+'\'+PackageName+'-Uninstall.ps1'),PWideChar(Self.InstallPath),False);
    //Liberamos a memória que alocamos
    Package.Close;
    Package.Free;
    Dispose(PackageMetadata);
    //Retornamos com sucesso e com a mensagem do script de instalação
    Result := True;
  except on E:Exception do
    begin
      if Assigned(Package) then
        Package.Free;
      if Assigned(PackageMetadata) then
        Dispose(PackageMetadata);
      Result := False;
      Output := E.Message;
    end;
  end;
end;

function TPackageManager.SearchPackage(PackageName: String): PPackageMetadata;
begin
  Result := ParsePackageMetadata(PackageName);
end;

function TPackageManager.Uninstall(PackageName: String;var Output:String): Boolean;
begin
  try
    //Se o pacote não está instalado
    if not IsInstalled(PackageName) then
      begin
        //retornamos com erro
        Result := False;
        Output := 'Pacote não está instalado!';
        Exit;
      end;
    //Verificamos se o arquivo de desinstalação existe
    if FileExists(InstallPath+'\'+PackageName+'-Uninstall.ps1') then
      begin
        // retornamos com erro
        Result := False;
        Output := 'Script de desinstalação inexistente!';
        Exit;
      end;
    //Executamos e retornamos a saída
    Output := GetDosOutput(InstallPath+'\'+PackageName+'-Uninstall.ps1');
    Result := True;
  except
    Result := False;
  end;
end;

function TPackageManager.Update(var Output:String): Boolean;
var
  I,UpdateCount : Integer;
  PackageMeta : PPackageMetadata;
  tmp : String;
begin
  try
    if DownloadFile(Self.FRepository+'/packageindex.csv',Self.BasePath+'\packageindex.csv') then
      begin
        Self.FNewPackageIndex.LoadFromFile(Self.BasePath+'\packageindex.csv');
        for I := 0 to Self.FNewPackageIndex.Count -1 do
          begin
            tmp := Copy(Self.FNewPackageIndex.Strings[i],1,Pos(';',Self.FNewPackageIndex.Strings[i])-1);
            PackageMeta := ParsePackageMetadata(tmp);
            if PackageMeta <> nil then
              begin
                if Self.FNewPackageIndex.Strings[i] <> MetadataToString(PackageMeta) then
                  begin
                    Output := Output + tmp+' tem uma nova versão'+#13+#10;
                    Inc(UpdateCount);
                  end;
                Dispose(PackageMeta);
              end;
          end;
        Result := True;
        Output := Output + 'Quantidade de atualizações:'+IntToStr(UpdateCount);
      end;
    Result :=False;
  except on E:Exception do
    begin
      Result := False;
      Output := E.Message;
    end;
  end;
end;

function TPackageManager.Upgrade(var Output:String): Boolean;
begin
  Sleep(1);
end;

end.
