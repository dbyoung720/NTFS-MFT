unit Unit2;
{ ���߳� MFT �ļ����� }

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Types, System.Classes;

const
  BUF_LEN                    = 500 * 1024;
  USN_DELETE_FLAG_DELETE     = $00000001;
  c_UInt64Root               = 1407374883553285;
  WM_SEARCHDRIVEFILEFINISHED = WM_USER + $1000;

type
  CREATE_USN_JOURNAL_DATA = record
    MaximumSize: UInt64;
    AllocationDelta: UInt64;
  end;

  USN_JOURNAL_DATA = record
    UsnJournalID: UInt64;
    FirstUsn: Int64;
    NextUsn: Int64;
    LowestValidUsn: Int64;
    MaxUsn: Int64;
    MaximumSize: UInt64;
    AllocationDelta: UInt64;
  end;

  MFT_ENUM_DATA = record
    StartFileReferenceNumber: UInt64;
    LowUsn: Int64;
    HighUsn: Int64;
  end;

  PUSN = ^USN;

  USN = record
    RecordLength: Cardinal;
    MajorVersion: Word;
    MinorVersion: Word;
    FileReferenceNumber: UInt64;       // Int64Rec;
    ParentFileReferenceNumber: UInt64; // Int64Rec;
    USN: Int64;
    TimeStamp: LARGE_INTEGER;
    Reason: Cardinal;
    SourceInfo: Cardinal;
    SecurityId: Cardinal;
    FileAttributes: Cardinal;
    FileNameLength: Word;
    FileNameOffset: Word;
    FileName: PWideChar;
  end;

  DELETE_USN_JOURNAL_DATA = record
    UsnJournalID: UInt64;
    DeleteFlags: Cardinal;
  end;

  PFileInfo = ^TFileInfo;

  TFileInfo = record
    intFileID: UInt64;
  end;

type
  TSearchMFT = class(TThread)
  private
    FchrDrive : Char;
    FlstFiles : TList;
    FhMainForm: THandle;
    FhVol     : THandle;
    procedure GetUSNFileInfo(UsnInfo: PUSN);
  protected
    procedure Execute; override;
  public
    constructor Create(const chrDriver: Char; hWnd: THandle; lstFiles: TList; hVol: THandle);
    destructor Destroy; override;
  end;

implementation

{ TSearchMFT }

constructor TSearchMFT.Create(const chrDriver: Char; hWnd: THandle; lstFiles: TList; hVol: THandle);
begin
  inherited Create(False);
  FreeOnTerminate := True;

  FchrDrive  := chrDriver;
  FlstFiles  := lstFiles;
  FhMainForm := hWnd;
  FhVol      := hVol;
end;

destructor TSearchMFT.Destroy;
begin

  inherited;
end;

procedure TSearchMFT.Execute;
  procedure MyMove(const Source; var Dest; Count: NativeInt); assembler;
  asm
    FILD    QWORD PTR [EAX]
    FISTP   QWORD PTR [EDX]
  end;
var
  cjd         : CREATE_USN_JOURNAL_DATA;
  ujd         : USN_JOURNAL_DATA;
  djd         : DELETE_USN_JOURNAL_DATA;
  dwRet       : DWORD;
  int64Size   : Integer;
  BufferOut   : array [0 .. BUF_LEN - 1] of Char;
  BufferIn    : MFT_ENUM_DATA;
  UsnInfo     : PUSN;
  intST, intET: Cardinal;
  strTip      : String;
  intCount    : Integer;
begin
  strTip   := '';
  intST    := GetTickCount;
  intCount := 0;
  try
    { ��ʼ��USN��־�ļ� }
    if not DeviceIoControl(FhVol, FSCTL_CREATE_USN_JOURNAL, @cjd, SizeOf(cjd), nil, 0, dwRet, nil) then
    begin
      strTip := '��ʼ�� ' + FchrDrive + ':\ USNʧ��';
      Exit;
    end;

    { ��ȡUSN��־������Ϣ }
    if not DeviceIoControl(FhVol, FSCTL_QUERY_USN_JOURNAL, nil, 0, @ujd, SizeOf(ujd), dwRet, nil) then
    begin
      strTip := '��ȡ ' + FchrDrive + ':\ USNʧ��';
      Exit;
    end;

    { ö��USN��־�ļ��е����м�¼ }
    int64Size                         := SizeOf(Int64);
    BufferIn.StartFileReferenceNumber := 0;
    BufferIn.LowUsn                   := 0;
    BufferIn.HighUsn                  := ujd.NextUsn;
    while DeviceIoControl(FhVol, FSCTL_ENUM_USN_DATA, @BufferIn, SizeOf(BufferIn), @BufferOut, BUF_LEN, dwRet, nil) do
    begin
      { �ҵ���һ�� USN ��¼ }
      dwRet   := dwRet - Cardinal(int64Size);
      UsnInfo := PUSN(Integer(@(BufferOut)) + int64Size);
      while dwRet > 0 do
      begin
        { ��ȡ�ļ���Ϣ }
        Inc(intCount);
        GetUSNFileInfo(UsnInfo);

        { ��ȡ��һ�� USN ��¼ }
        Dec(dwRet, UsnInfo^.RecordLength);
        UsnInfo := PUSN(Cardinal(UsnInfo) + UsnInfo^.RecordLength);
      end;
      MyMove(BufferOut, BufferIn, int64Size);
    end;

    { ɾ��USN��־�ļ���Ϣ }
    djd.UsnJournalID := ujd.UsnJournalID;
    djd.DeleteFlags  := USN_DELETE_FLAG_DELETE;
    DeviceIoControl(FhVol, FSCTL_DELETE_USN_JOURNAL, @djd, SizeOf(djd), nil, 0, dwRet, nil);
  finally
    intET  := GetTickCount;
    strTip := Format('%s:\���ļ�������%0.8d��������ʱ��%0.3d �롣', [FchrDrive, intCount, (intET - intST) div 1000]) + '  ' + strTip;
    SendMessage(FhMainForm, WM_SEARCHDRIVEFILEFINISHED, 0, Integer(PChar(strTip)));
  end;
end;

procedure TSearchMFT.GetUSNFileInfo(UsnInfo: PUSN);
var
  FileInfo: PFileInfo;
begin
  FileInfo            := AllocMem(SizeOf(TFileInfo));
  FileInfo^.intFileID := UsnInfo^.FileReferenceNumber;
  FlstFiles.Add(FileInfo);
end;

end.
