unit Unit3;
{$WARN SYMBOL_PLATFORM OFF}
{ 获取全路径文件名称 }

interface

uses Winapi.Windows, System.StrUtils, System.Math;

{ 根据文件 ID 获取文件全路径文件名称、文件大小 }
function GetFilelNameByID(hRootHandle: THandle; const FileID: UInt64; var intFileLength: UInt64; const strDriveName: String = ''): String;

implementation

type
  FILE_ID_128 = record
    Identifier: array [0 .. 15] of Byte;
  end;

  FILE_ID_DESCRIPTOR = record
    dwSize: DWORD;
    _type: Integer;
    case Integer of
      0:
        (FileID: LARGE_INTEGER);
      1:
        (ObjectId: TGUID);
      2:
        (ExtendedFileId: FILE_ID_128)
  end;

  TFILE_ID_DESCRIPTOR = FILE_ID_DESCRIPTOR;
  PFILE_ID_DESCRIPTOR = ^TFILE_ID_DESCRIPTOR;

function OpenFileById(hVoluemHint: THandle; lpFileID: PFILE_ID_DESCRIPTOR; dwDesiredAccess: DWORD; dwShareMode: DWORD; lpSecurityAttributes: PSecurityAttributes; dwFlagsAndAttributes: DWORD): THandle; stdcall; external kernel32;

{ 根据文件 ID 获取文件全路径文件名称、文件大小 }
function GetFilelNameByID(hRootHandle: THandle; const FileID: UInt64; var intFileLength: UInt64; const strDriveName: String = ''): String;
var
  uFileName: array [0 .. 2555] of Char;
  fid      : TFILE_ID_DESCRIPTOR;
  hFile    : THandle;
  FileInfo : TByHandleFileInformation;
begin;
  Result        := '';
  intFileLength := 0;

  fid.dwSize          := SizeOf(TFILE_ID_DESCRIPTOR);
  fid._type           := 0;
  fid.FileID.QuadPart := FileID;
  hFile               := OpenFileById(hRootHandle, @fid, 0, 0, nil, 0);
  if hFile = INVALID_HANDLE_VALUE then
  begin
    Result := '文件打开失败';
    Exit;
  end;

  { 获取文件全路径名称 }
  if GetFinalPathNameByHandle(hFile, uFileName, 256, Ifthen(strDriveName = '', 0, 4)) > 0 then
  begin
    Result := string(uFileName);
    Result := Ifthen(strDriveName = '', RightStr(Result, Length(Result) - 4), strDriveName + ':' + Result);
  end;

  try
    { 获取文件大小 }
    if GetFileInformationByHandle(hFile, FileInfo) then
    begin
      intFileLength := UInt64(FileInfo.nFileSizeHigh) shl 32 + FileInfo.nFileSizeLow;
    end;
  finally
    CloseHandle(hFile);
  end;
end;

end.
