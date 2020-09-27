unit fRunAs_Params;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TfmRunAs_Params = class(TForm)
    Painel_Saida: TPanel;
    BtnSalvar: TBitBtn;
    BtnSair: TBitBtn;
    Paginas: TPageControl;
    TabAuth: TTabSheet;
    GroupBox1: TGroupBox;
    user_name: TEdit;
    GroupBox2: TGroupBox;
    password: TEdit;
    gb_via_cmd: TGroupBox;
    RunAs_enabled: TCheckBox;
    Panel2: TPanel;
    GroupBox3: TGroupBox;
    RunAs_Location: TEdit;
    BtnProcurar_RunAsLocation: TBitBtn;
    GroupBox4: TGroupBox;
    RunAs_Params: TEdit;
    domain: TEdit;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    TabSheet1: TTabSheet;
    GroupBox5: TGroupBox;
    RunAs_Logo: TEdit;
    BtnProcurar_Logo: TBitBtn;
    procedure BtnSairClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnProcurar_RunAsLocationClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BtnProcurar_LogoClick(Sender: TObject);
  private
    { Private declarations }
    FAplicado:Boolean;
  public
    { Public declarations }
  published
    property Aplicado:Boolean read FAplicado;
  end;

var
  fmRunAs_Params: TfmRunAs_Params;

implementation
uses
  inifiles,
  StrUtils,
  ShellApi,
  lib_run_as, fRunAs_Main;

{$R *.dfm}






procedure TfmRunAs_Params.BitBtn1Click(Sender: TObject);
var
  L:TStringlist;
  sRunAs_me, sRunAs_Admin:String;
  S:String;
  sWinUser:String;
  iRet:Integer;
begin
  sWinUser:=GetDosEnv('USERNAME');
  sRunAs_me:=GetDosEnv('TEMP')+'\runas_'+sWinUser+'.cmd';
  sRunAs_Admin:=GetDosEnv('WINDIR')+'\system32\msinfo32.exe';
  L:=TStringList.Create;
  try
    // Arquivo com o teste de runas
    L.Clear;
    L.Add('@echo off');
    L.Add('echo criando uma credencial para o runas.');
    L.Add('echo A seguir digite a senha para o usuário ***'+user_name.text+'*** e pressione enter');
    L.Add('echo Atenção: Você não verá a senha sendo digitada, ela ficará invisivel.');
    L.Add('echo Se a senha estiver correta, a pressionar ENTER, você verá as informações do sistema.');
    S:=' /savecred';
    if domain.text<>'' then
      S:=S+' /user:"'+domain.text+'\'+user_name.text+'"'
    else
      S:=S+' /user:"'+user_name.text+'"';
    S:=RunAs_Location.text+' '+S+' '+RunAs_Params.text+' "'+sRunAs_Admin+'"';
    L.Add('echo O comando a ser disparado é:');
    L.Add('echo '+S);
    L.Add(S);
    L.Add('Se foii executando o programa MSINFO corretamente então parabens deu sucesso.');
    L.Add('echo Pressione [ENTER] para finalizar');
    L.Add('pause');
    L.SaveToFile(sRunAs_me);

    if FileExists(sRunAs_me) and FileExists(sRunAs_Admin) then
    begin
      iRet:=ShellExecute(handle,'open',PChar(sRunAs_me), '','',SW_SHOWNORMAL);
      if (iRet=0) or (iRet>32) then
      begin
        if FileExists(sRunAs_me)
          then DeleteFile(sRunAs_me);
        if FileExists(sRunAs_Admin)
          then DeleteFile(sRunAs_Admin);
      end;
    end;

  finally


  end;






end;

procedure TfmRunAs_Params.BtnProcurar_LogoClick(Sender: TObject);
var
  OpenDialog1:TOpenDialog;
  sFile:String;
begin
  OpenDialog1:=TOpenDialog.Create(nil);
  OpenDialog1.Title:='Imagem para logotipo(dimensões larg=440px, alt=100px):';
  OpenDialog1.DefaultExt:='*.png';
  OpenDialog1.Filter:='Imagens|*.png;*.jpg;*.bmp';
  if OpenDialog1.Execute then
  begin
    sFile:=OpenDialog1.FileName;
    if FileExists(sFile) then
    begin
      RunAs_Logo.Enabled:=false;
      RunAs_Logo.Text:=sFile;
    end;
  end;
  OpenDialog1.Free;
end;

procedure TfmRunAs_Params.BtnProcurar_RunAsLocationClick(Sender: TObject);
var
  OpenDialog1:TOpenDialog;
  sApp_location_runas, sApp_location_runas_params:String;
begin
  sApp_location_runas:=ChangeFileExt(ExtractFileName(RunAs_Location.Text),'');
  OpenDialog1:=TOpenDialog.Create(nil);
  OpenDialog1.Title:='Utilitário runas:';
  OpenDialog1.DefaultExt:='runas*.exe';
  OpenDialog1.Filter:='Utilitário runas|*.exe';
  if OpenDialog1.Execute then
  begin
    sApp_location_runas:=OpenDialog1.FileName;
    if FileExists(sApp_location_runas) then
    begin
      RunAs_Enabled.Checked:=true;
      RunAs_Location.Text:=sApp_location_runas;
      fmRunAs_Main.RunAs_Enabled:=RunAs_Enabled.Checked;
      fmRunAs_Main.RunAs_Location:=sApp_location_runas;
    end;
  end;
  OpenDialog1.Free;

end;

procedure TfmRunAs_Params.BtnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfmRunAs_Params.BtnSalvarClick(Sender: TObject);
var
  MyIni:TInifile;
  S:String;
  i, iPos:Integer;
begin
  if not LogonPasswordOK(user_name.Text, domain.text, password.text) then
  begin
    if not MessageDlg('Essa senha parece não estar correta, deseja prosseguir assim mesmo?', mtconfirmation,[mbYes,mbNo],0)=mrNo then
      Exit;
  end;

  try
    MyIni:=TInifile.Create(CONFIG_FILE);
    MyIni.WriteString('Autenticacao','RunAs_user_name', Criptografar(user_name.text));
    MyIni.WriteString('Autenticacao','RunAs_domain', domain.text);
    MyIni.WriteString('Autenticacao','RunAs_password', Criptografar(password.Text));
    MyIni.WriteString('Autenticacao','InitialDir', fmRunAs_Main.InitialDir);
    MyIni.WriteBool  ('Autenticacao','RunAs_Enabled', RunAs_Enabled.Checked);
    MyIni.WriteString('Autenticacao','RunAs_Location', RunAs_Location.Text);
    MyIni.WriteString('Autenticacao','RunAs_Params', RunAs_Params.Text);
    MyIni.WriteString('Autenticacao','RunAs_Logo', RunAs_Logo.Text);

    FAplicado:=true;
  finally
    if Assigned(MyIni) then
      FreeAndNil(MyIni);
  end;

  Close;
end;

procedure TfmRunAs_Params.FormCreate(Sender: TObject);
begin
  Caption:='Parametros de execução:';
  user_name.text:='administrador';
  domain.Clear;
  password.Clear;
  RunAs_Enabled.Checked:=false;
  RunAs_Location.text:='c:\windows\system32\runas.exe';
  RunAs_Params.Clear;
  RunAs_Logo.Clear;
  RunAs_Logo.Enabled:=false;
  FAplicado:=false;
  Paginas.ActivePageIndex:=0;
end;

end.
