object Form1: TForm1
  Left = 108
  Top = 366
  BorderStyle = bsDialog
  Caption = 'Fire FX'
  ClientHeight = 500
  ClientWidth = 500
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
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
  end
end
