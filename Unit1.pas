unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.IniFiles, System.SysUtils, System.StrUtils, System.Types, System.Classes, System.IOUtils, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls,
  Unit2, Unit3;

type
  TForm1 = class(TForm)
    lvFiles: TListView;
    mmoLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure lvFilesData(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FintThreadCount    : Integer;
    FlstFiles          : array of TList;
    FLogicalDriveHandle: THashedStringList;
    { �����������б� }
    procedure FreeDriveList;
    { �����ļ��б� }
    procedure FreeFileList;
    { ��ʼȫ�������ļ� }
    procedure SearchMFT;
    { ��ȡȫ·���ļ����� }
    function GetFileFullName(const intFileID: UInt64; const intIndex: Integer; var intFileLength: UInt64): string;
  protected
    { ���������̽��� }
    procedure WMSEARCHDRIVEFILEFINISHED(var msg: TMessage); message WM_SEARCHDRIVEFILEFINISHED;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FintThreadCount := 0;
  SearchMFT;
end;

{ �����������б� }
procedure TForm1.FreeDriveList;
var
  I: Integer;
begin
  for I := 0 to FLogicalDriveHandle.Count - 1 do
  begin
    CloseHandle(StrToInt(FLogicalDriveHandle.ValueFromIndex[I]));
  end;
  FLogicalDriveHandle.Free;
end;

{ �����ļ��б� }
procedure TForm1.FreeFileList;
var
  I      : Integer;
  lstData: TList;
  J      : Integer;
begin
  { �������ڴ� }
  for I := Low(FlstFiles) to High(FlstFiles) do
  begin
    lstData := FlstFiles[I];
    for J   := lstData.Count - 1 downto 0 do
    begin
      FreeMem(lstData.Items[J]);
      lstData.Delete(J);
    end;
  end;

  { ���ͷű��� }
  for I := Low(FlstFiles) to High(FlstFiles) do
  begin
    lstData := FlstFiles[I];
    lstData.Free;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  lvFiles.Items.Count := 0;     // ֹͣ�������
  lvFiles.OwnerData   := False; // ֹͣ�������
  FreeDriveList;                // �����������б�
  FreeFileList;                 // �����ļ��б�
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  lvFiles.Columns[1].Width := Width - 240;
end;

{ ��ʼȫ�������ļ� }
procedure TForm1.SearchMFT;
var
  lstDrivers  : TStringList;
  arrlist     : TStringDynArray;
  strDriver   : String;
  intLen      : DWORD;
  sysFlags    : DWORD;
  strNTFS     : array [0 .. 255] of Char;
  I           : Integer;
  hRootHandle : THandle;
  chrDriveName: Char;
  strTip      : String;
begin
  lstDrivers := TStringList.Create;
  try
    arrlist := TDirectory.GetLogicalDrives;
    for strDriver in arrlist do
    begin
      { �ж��Ƿ��� NTFS ��ʽ�Ĵ��� }
      if not GetVolumeInformation(PChar(strDriver), nil, 0, nil, intLen, sysFlags, strNTFS, 256) then
        Continue;

      if not SameText(strNTFS, 'NTFS') then
        Continue;

      { ���뵽�������б� }
      lstDrivers.Add(strDriver[1]);
    end;

    if lstDrivers.Count = 0 then
      Exit;

    { ��Ϣ��ʾ }
    strTip := '';
    for I  := 0 to lstDrivers.Count - 1 do
    begin
      strTip := strTip + ',' + lstDrivers.Strings[I][1];
    end;
    mmoLog.Lines.Add(Format('%s ���� %d ���߼��̴�����', [RightStr(strTip, Length(strTip) - 1), lstDrivers.Count]));

    { ���߳��������� NTFS ���������ļ� }
    FintThreadCount := lstDrivers.Count;
    SetLength(FlstFiles, FintThreadCount);
    FLogicalDriveHandle := THashedStringList.Create;
    for I               := 0 to lstDrivers.Count - 1 do
    begin
      FlstFiles[I] := TList.Create;
      chrDriveName := lstDrivers.Strings[I][1];
      hRootHandle  := CreateFile(PChar('\\.\' + chrDriveName + ':'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
      FLogicalDriveHandle.Add(Format('%s=%d', [chrDriveName, hRootHandle]));
      TSearchMFT.Create(chrDriveName, Handle, FlstFiles[I], hRootHandle);
    end;
  finally
    lstDrivers.Free;
  end;
end;

{ ���������̽��� }
procedure TForm1.WMSEARCHDRIVEFILEFINISHED(var msg: TMessage);
var
  I    : Integer;
  Count: Integer;
begin
  Dec(FintThreadCount);
  mmoLog.Lines.Add(string(PChar(msg.LParam)));

  if FintThreadCount = 0 then
  begin
    mmoLog.Lines.Add('ȫ���������');

    Count := 0;
    for I := Low(FlstFiles) to High(FlstFiles) do
    begin
      Count := Count + FlstFiles[I].Count;
    end;
    lvFiles.Items.Count := Count;
  end;
end;

procedure TForm1.lvFilesData(Sender: TObject; Item: TListItem);
var
  I, intIndex, Count: Integer;
  FileInfo          : pFileInfo;
  intFileID         : UInt64;
  intFileLength     : UInt64;
begin
  intIndex     := Item.Index;
  Count        := 0;
  Item.Caption := IntToStr(intIndex + 1);

  for I := Low(FlstFiles) to High(FlstFiles) do
  begin
    Count := Count + FlstFiles[I].Count;
    if intIndex <= Count then
    begin
      FileInfo  := pFileInfo(FlstFiles[I].Items[intIndex - (Count - FlstFiles[I].Count)]);
      intFileID := FileInfo^.intFileID;
      Item.SubItems.Add(GetFileFullName(intFileID, I, intFileLength));
      Item.SubItems.Add(UIntToStr(intFileLength));
      Break;
    end;
  end;
end;

{ ��ȡȫ·���ļ����� }
function TForm1.GetFileFullName(const intFileID: UInt64; const intIndex: Integer; var intFileLength: UInt64): string;
var
  hRootHandle : THandle;
  strDriveName: String;
begin
  strDriveName := FLogicalDriveHandle.Names[intIndex];
  hRootHandle  := StrToInt(FLogicalDriveHandle.ValueFromIndex[intIndex]);
  Result       := GetFilelNameByID(hRootHandle, intFileID, intFileLength, strDriveName);
end;

end.
