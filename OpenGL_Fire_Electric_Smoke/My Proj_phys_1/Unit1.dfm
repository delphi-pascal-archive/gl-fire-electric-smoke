object Form1: TForm1
  Left = 141
  Top = 238
  BorderStyle = bsToolWindow
  Caption = 'Newton_test'
  ClientHeight = 700
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 624
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 624
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
  end
end
