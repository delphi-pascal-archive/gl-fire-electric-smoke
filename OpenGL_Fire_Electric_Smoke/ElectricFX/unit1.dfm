object Form1: TForm1
  Left = 308
  Top = 100
  Width = 408
  Height = 434
  Caption = 'ElectricFX'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
  end
end
