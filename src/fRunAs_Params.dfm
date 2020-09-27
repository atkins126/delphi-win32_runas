object fmRunAs_Params: TfmRunAs_Params
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmRunAs_Params'
  ClientHeight = 571
  ClientWidth = 794
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 19
  object Painel_Saida: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 527
    Width = 788
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
      Left = 415
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
      Left = 601
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
  end
  object Paginas: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 788
    Height = 518
    ActivePage = TabAuth
    Align = alClient
    TabOrder = 1
    object TabAuth: TTabSheet
      Caption = 'Autentica'#231#227'o'
      object GroupBox1: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 774
        Height = 53
        Align = alTop
        Caption = 
          'Nome do usu'#225'rio administrador ou com permiss'#245'es de administrador' +
          ':'
        TabOrder = 0
        object user_name: TEdit
          AlignWithMargins = True
          Left = 5
          Top = 24
          Width = 434
          Height = 24
          Hint = 
            'Normalmente '#39'administrador'#39' ou '#39'root'#39', mas pode ser qualquer out' +
            'ro desde que tenha privil'#233'gios de administrador. Se estiver num ' +
            'dominio ent'#227'o use conta@dominio.local.'
          Align = alClient
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          TextHint = 
            'Normalmente '#39'administrador'#39' ou '#39'root'#39', mas pode ser qualquer out' +
            'ro desde que tenha privil'#233'gios de administrador. Se estiver num ' +
            'dominio ent'#227'o use conta@dominio.local.'
          ExplicitHeight = 27
        end
        object domain: TEdit
          AlignWithMargins = True
          Left = 445
          Top = 24
          Width = 324
          Height = 24
          Hint = 'Dominio de rede, se existir'
          Align = alRight
          TabOrder = 1
          TextHint = 'Dominio de rede, se existir'
          ExplicitHeight = 27
        end
      end
      object GroupBox2: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 62
        Width = 774
        Height = 59
        Align = alTop
        Caption = 'Senha usada por este administrador:'
        TabOrder = 1
        object password: TEdit
          AlignWithMargins = True
          Left = 5
          Top = 24
          Width = 764
          Height = 27
          Align = alTop
          PasswordChar = '*'
          TabOrder = 0
          Text = 'user_name'
          TextHint = 'Digite a senha'
        end
      end
      object gb_via_cmd: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 127
        Width = 774
        Height = 282
        Align = alTop
        Caption = 'Executar via cmd usando '#39'runas'#39': (n'#227'o recomendado)'
        TabOrder = 2
        object RunAs_enabled: TCheckBox
          AlignWithMargins = True
          Left = 5
          Top = 24
          Width = 764
          Height = 17
          Align = alTop
          Caption = 
            'Executar programas usando apenas a linha de comando com o utilit' +
            #225'rio '#39'runas'#39
          TabOrder = 0
        end
        object Panel2: TPanel
          AlignWithMargins = True
          Left = 26
          Top = 47
          Width = 743
          Height = 230
          Margins.Left = 24
          Align = alClient
          BevelOuter = bvNone
          Caption = 'Panel2'
          ShowCaption = False
          TabOrder = 1
          object Label1: TLabel
            AlignWithMargins = True
            Left = 3
            Top = 158
            Width = 737
            Height = 38
            Align = alBottom
            Caption = 
              #201' preciso criar uma credencial, caso contr'#225'rio, o runas ficar'#225' i' +
              'nsistentemente perguntando a senha, clique no bot'#227'o abaixo para ' +
              'cri'#225'-la:'
            WordWrap = True
            ExplicitWidth = 705
          end
          object GroupBox3: TGroupBox
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 737
            Height = 78
            Align = alTop
            Caption = 'Localiza'#231#227'o do utilit'#225'rio '#39'runas'#39':'
            TabOrder = 0
            object RunAs_Location: TEdit
              AlignWithMargins = True
              Left = 5
              Top = 24
              Width = 646
              Height = 49
              Align = alClient
              TabOrder = 0
              Text = 'RunAs_Location'
              ExplicitHeight = 27
            end
            object BtnProcurar_RunAsLocation: TBitBtn
              AlignWithMargins = True
              Left = 657
              Top = 24
              Width = 75
              Height = 49
              Hint = 'Clique aqui para procurar o aplicativo '#39'runas.exe'#39
              Align = alRight
              Caption = 'Procurar'
              TabOrder = 1
              OnClick = BtnProcurar_RunAsLocationClick
            end
          end
          object GroupBox4: TGroupBox
            AlignWithMargins = True
            Left = 3
            Top = 87
            Width = 737
            Height = 62
            Align = alTop
            Caption = 'Parametros requeridos por este aplicativo ou utilit'#225'rio:'
            TabOrder = 1
            object RunAs_Params: TEdit
              AlignWithMargins = True
              Left = 5
              Top = 24
              Width = 727
              Height = 27
              Align = alTop
              TabOrder = 0
              Text = 'RunAs_Params'
            end
          end
          object BitBtn1: TBitBtn
            AlignWithMargins = True
            Left = 3
            Top = 202
            Width = 737
            Height = 25
            Align = alBottom
            Caption = 'Criar a credencial'
            TabOrder = 2
            OnClick = BitBtn1Click
          end
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Logotipo'
      ImageIndex = 2
      object GroupBox5: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 774
        Height = 78
        Align = alTop
        Caption = 'Localiza'#231#227'o do utilit'#225'rio '#39'runas'#39':'
        TabOrder = 0
        object RunAs_Logo: TEdit
          AlignWithMargins = True
          Left = 5
          Top = 24
          Width = 683
          Height = 49
          Align = alClient
          TabOrder = 0
          Text = 'RunAs_Logo'
          ExplicitHeight = 27
        end
        object BtnProcurar_Logo: TBitBtn
          AlignWithMargins = True
          Left = 694
          Top = 24
          Width = 75
          Height = 49
          Hint = 'Clique aqui para procurar o aplicativo '#39'runas.exe'#39
          Align = alRight
          Caption = 'Procurar'
          TabOrder = 1
          OnClick = BtnProcurar_LogoClick
        end
      end
    end
  end
end
