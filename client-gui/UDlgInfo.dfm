object dlgInfo: TdlgInfo
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Detalhes do Pacote'
  ClientHeight = 213
  ClientWidth = 362
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object edtPackageName: TLabeledEdit
    Left = 8
    Top = 32
    Width = 241
    Height = 21
    EditLabel.Width = 27
    EditLabel.Height = 13
    EditLabel.Caption = 'Nome'
    ReadOnly = True
    TabOrder = 0
  end
  object edtPackageVersion: TLabeledEdit
    Left = 255
    Top = 32
    Width = 97
    Height = 21
    EditLabel.Width = 33
    EditLabel.Height = 13
    EditLabel.Caption = 'Vers'#227'o'
    ReadOnly = True
    TabOrder = 1
  end
  object edtPackageDescription: TLabeledEdit
    Left = 8
    Top = 80
    Width = 344
    Height = 21
    EditLabel.Width = 46
    EditLabel.Height = 13
    EditLabel.Caption = 'Descri'#231#227'o'
    ReadOnly = True
    TabOrder = 2
  end
  object edtPackageHash: TLabeledEdit
    Left = 8
    Top = 128
    Width = 344
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = 'Hash'
    ReadOnly = True
    TabOrder = 3
  end
  object edtPackageDependencies: TLabeledEdit
    Left = 8
    Top = 176
    Width = 344
    Height = 21
    EditLabel.Width = 67
    EditLabel.Height = 13
    EditLabel.Caption = 'Depend'#234'ncias'
    ReadOnly = True
    TabOrder = 4
  end
end
