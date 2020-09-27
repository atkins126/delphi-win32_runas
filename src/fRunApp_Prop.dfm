object fmRunApp_Prop: TfmRunApp_Prop
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmRunApp_Prop'
  ClientHeight = 451
  ClientWidth = 634
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Painel_Saida: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 407
    Width = 628
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = ' '
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ShowCaption = False
    TabOrder = 0
    object BtnSalvar: TBitBtn
      AlignWithMargins = True
      Left = 255
      Top = 7
      Width = 180
      Height = 27
      Align = alRight
      Caption = 'Salvar'
      Default = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888808888888
        88888880A088888888888880AA0888888888880AAAA088888888880AAAA08888
        888800AAAAAA088888880AAA00AA0888888880AA080AA088888888000880AA08
        888888888880AA088888888888800AA088888888888880AA088888888888880A
        A0888888888888800A0888888888888880A08888888888888808}
      TabOrder = 0
      OnClick = BtnSalvarClick
    end
    object BtnSair: TBitBtn
      AlignWithMargins = True
      Left = 441
      Top = 7
      Width = 180
      Height = 27
      Align = alRight
      Caption = 'Sair'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000120B0000120B00001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777007
        77777777777770A077777777777770AA07770000007770AAA0007777770000AA
        A0777777070BB0AAA0777777000BB0A0A07777770E0BB000A07700000EE0B0AA
        A0770EEEEEEE00AAA07700000EE0B0AAA07777770E0BB0AAA0777777000BBB0A
        A0777777770BBBB0A0777777770BBBBB00777777770000000077}
      TabOrder = 1
      OnClick = BtnSairClick
    end
    object BtnCriarTeste: TBitBtn
      AlignWithMargins = True
      Left = 7
      Top = 7
      Width = 114
      Height = 27
      Hint = 'Clique aqui para procurar o aplicativo '#39'runas.exe'#39
      Align = alLeft
      Caption = 'Criar teste'
      TabOrder = 2
      OnClick = BtnCriarTesteClick
    end
  end
  object gb_app_opcoes: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 212
    Width = 628
    Height = 92
    Align = alTop
    Caption = 'Op'#231#245'es'
    TabOrder = 1
    ExplicitTop = 164
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 618
      Height = 69
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      ExplicitHeight = 77
      object DBCheckBox1: TDBCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 612
        Height = 17
        Align = alTop
        Caption = 'Requer uso de permiss'#227'o de administrador'
        DataField = 'admin_only'
        DataSource = fmRunAs_Main.ds_app
        TabOrder = 0
        ExplicitLeft = 6
        ExplicitTop = 51
        ExplicitWidth = 531
      end
      object DBCheckBox2: TDBCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 26
        Width = 612
        Height = 17
        Align = alTop
        Caption = 'Permitir qualquer outro programa nesta mesma pasta.'
        DataField = 'folder_only'
        DataSource = fmRunAs_Main.ds_app
        TabOrder = 1
        ExplicitLeft = 347
        ExplicitTop = 51
        ExplicitWidth = 97
      end
      object DBCheckBox3: TDBCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 49
        Width = 612
        Height = 17
        Align = alTop
        Caption = 'Habilitado'
        DataField = 'enabled'
        DataSource = fmRunAs_Main.ds_app
        TabOrder = 2
        ExplicitTop = 60
        ExplicitWidth = 97
      end
    end
  end
  object gb_app_title: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 167
    Width = 628
    Height = 39
    Align = alTop
    Caption = 
      'Titulo desej'#225'vel para este aplicativo ou utilit'#225'rio e tamb'#233'm sua' +
      ' ordem:'
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 106
    object Label1: TLabel
      Left = 516
      Top = 20
      Width = 8
      Height = 13
      Caption = 'id'
    end
    object title: TDBEdit
      Left = 2
      Top = 15
      Width = 624
      Height = 22
      Align = alClient
      DataField = 'title'
      DataSource = fmRunAs_Main.ds_app
      TabOrder = 0
      OnExit = titleExit
      ExplicitLeft = 20
      ExplicitTop = 36
      ExplicitWidth = 53252
      ExplicitHeight = 21
    end
  end
  object Memo_Ajuda: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 310
    Width = 628
    Height = 91
    Align = alClient
    BorderStyle = bsNone
    Color = clInfoBk
    Lines.Strings = (
      'Memo_Ajuda')
    ReadOnly = True
    TabOrder = 3
    ExplicitTop = 211
    ExplicitHeight = 190
  end
  object gb_app_location: TGroupBox
    Left = 0
    Top = 56
    Width = 634
    Height = 57
    Align = alTop
    Caption = 'Localiza'#231#227'o do utilit'#225'rio ou aplicativo:'
    TabOrder = 4
    ExplicitLeft = 8
    ExplicitTop = -16
    object BtnProcurar: TBitBtn
      AlignWithMargins = True
      Left = 554
      Top = 18
      Width = 75
      Height = 32
      Hint = 'Clique aqui para procurar o aplicativo '#39'runas.exe'#39
      Align = alRight
      Caption = 'Procurar'
      Constraints.MaxHeight = 32
      PopupMenu = PopupMenu1
      TabOrder = 0
      OnClick = BtnProcurarClick
      ExplicitLeft = 548
      ExplicitHeight = 24
    end
    object location: TDBEdit
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 543
      Height = 34
      Align = alClient
      DataField = 'location'
      DataSource = fmRunAs_Main.ds_app
      TabOrder = 1
      ExplicitLeft = 9
      ExplicitTop = 22
      ExplicitWidth = 175
      ExplicitHeight = 27
    end
  end
  object gb_app_location_params: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 116
    Width = 628
    Height = 45
    Align = alTop
    Caption = 'Parametros requeridos por este aplicativo ou utilit'#225'rio:'
    TabOrder = 5
    ExplicitLeft = 11
    ExplicitTop = 11
    ExplicitWidth = 612
    object DBEdit2: TDBEdit
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 618
      Height = 22
      Align = alClient
      DataField = 'params'
      DataSource = fmRunAs_Main.ds_app
      TabOrder = 0
      ExplicitWidth = 602
      ExplicitHeight = 21
    end
  end
  object gb_app_id: TGroupBox
    Left = 0
    Top = 0
    Width = 634
    Height = 56
    Align = alTop
    Caption = 'Ordem ou ID'
    TabOrder = 6
    object DBEdit4: TDBEdit
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 75
      Height = 33
      Align = alLeft
      DataField = 'id'
      DataSource = fmRunAs_Main.ds_app
      TabOrder = 0
      ExplicitLeft = 551
      ExplicitTop = 15
      ExplicitHeight = 22
    end
    object DBImage1: TDBImage
      Left = 568
      Top = 15
      Width = 64
      Height = 39
      Align = alRight
      DataField = 'icon'
      DataSource = fmRunAs_Main.ds_app
      TabOrder = 1
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 376
    Top = 224
    object Menu_Find_Java: TMenuItem
      Caption = 'Procure pelo Java'
      OnClick = Menu_Find_JavaClick
    end
  end
end
