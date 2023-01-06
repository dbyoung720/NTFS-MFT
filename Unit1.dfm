object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'NTFS-MFT '#25991#20214#26816#32034
  ClientHeight = 686
  ClientWidth = 1122
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    1122
    686)
  TextHeight = 13
  object lvFiles: TListView
    Left = 8
    Top = 8
    Width = 1106
    Height = 541
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #24207#21015
        Width = 80
      end
      item
        Caption = #25991#20214#21517
        Width = 900
      end
      item
        Caption = #25991#20214#22823#23567
        Width = 100
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    GridLines = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnData = lvFilesData
  end
  object mmoLog: TMemo
    Left = 8
    Top = 560
    Width = 1106
    Height = 118
    Anchors = [akLeft, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
