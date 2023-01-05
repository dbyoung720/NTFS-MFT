object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'NTFS-MFT ÎÄ¼þ¼ìË÷'
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
    Height = 557
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
    ExplicitWidth = 1102
    ExplicitHeight = 556
  end
  object mmoLog: TMemo
    Left = 8
    Top = 571
    Width = 1106
    Height = 107
    Anchors = [akLeft, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitTop = 570
    ExplicitWidth = 1102
  end
end
