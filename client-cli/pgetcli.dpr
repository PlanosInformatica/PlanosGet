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
  System.SysUtils;

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

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
