unit fRunAs_Main;

{ Crie o arquivo uac.manifest:
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity
    type="win32"
    name="<your description>"
    version="2.0.0.2552"
    processorArchitecture="*"/>
  <dependency>
    <dependentAssembly>
      <assemblyIdentity
        type="win32"
        name="Microsoft.Windows.Common-Controls"
        version="6.0.0.0"
        publicKeyToken="6595b64144ccf1df"
        language="*"
        processorArchitecture="*"/>
    </dependentAssembly>
  </dependency>
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel
          level="requireAdministrator"
          uiAccess="false"/>
        </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>
Depois crie um arquivo UAC.RC com o seguinte conteúdo:
  1 24 "uac.manifest"
Depois compile com a seguinte instrução que pode ser inserida em um arquivo bat se quiser
  brcc32 UAC.RC
Dentro do seu projeto, vá em Project > Options > Application e desmarque o checkbox
  "Enable runtime themes" . Isso desabilitará o manifesto Default do Delphi com o qual
  habilita ComCtl v6 Visual Styles (which is why you need to enable styles manually in a custom manifest).
Agora vá em Projet|Resource and Images|adicione o uac.res compilado ao seu projeto e faça o build.
IMPORTANTE: Com o Manifest você deve perceber que ao pressionar F9 para rodar sua aplicação em modo debug
o Delphi não conseguirá executar sua aplicação com o usuário normal, a solução para isso é fechar a IDE do Delphi
e abri-la novamente com a opção Executar como administrador ou entao rodar o programa no modo release

}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.Imaging.pngimage, Vcl.Menus,
  Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids;

type
  TfmRunAs_Main = class(TForm)
    Memo_Ajuda: TMemo;
    logo: TImage;
    ActionList1: TActionList;
    DoConfig: TAction;
    ImageList1: TImageList;
    SoSair: TAction;
    DoExecutar: TAction;
    DoLocalizar: TAction;
    appdb: TClientDataSet;
    ds_app: TDataSource;
    DBGrid1: TDBGrid;
    PopupMenu1: TPopupMenu;
    Executar1: TMenuItem;
    N1: TMenuItem;
    Inserir1: TMenuItem;
    Editar1: TMenuItem;
    Excluir1: TMenuItem;
    N2: TMenuItem;
    Configurar1: TMenuItem;
    DoNovo: TAction;
    DoEditar: TAction;
    DoExcluir: TAction;
    appdbid: TIntegerField;
    appdbtitle: TStringField;
    appdblocation: TStringField;
    appdbparams: TStringField;
    appdbenabled: TBooleanField;
    appdbadmin_only: TBooleanField;
    appdbadmin_domain: TStringField;
    appdbadmin_username: TStringField;
    appdbadmin_password: TStringField;
    appdbstat_run: TLargeintField;
    appdbstat_lastrun: TDateTimeField;
    appdbicon: TGraphicField;
    appdbfolder_only: TBooleanField;
    procedure FormCreate(Sender: TObject);
    procedure DoConfigExecute(Sender: TObject);
    procedure DoExecutarExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DoLocalizarExecute(Sender: TObject);
    procedure DoNovoExecute(Sender: TObject);
  private
    { Private declarations }
    FInitialDir:String;
    FRunAs_UserName:String;
    FRunAs_Domain:String;
    FRunAs_Password:String;
    FApp_LastRun:String;
    FRunAs_Enabled:Boolean;
    FRunAs_Location:String;
    FRunAs_Params:String;
    FRunAs_Logo:String;
    FLicenciado:Boolean;
    FLic_User: String;
    FLic_Domain: String;
    FLic_Password: String;
    FLic_EMail: String;
    procedure WriteConfig;
  public
    { Public declarations }
    procedure ReadConfig;
    function RunAs_GetBitmap(AFileOrLocation:String; AWidth, AHeight:Integer):TBitmap;
  published
    property Lic_User:String      read FLic_User      write FLic_User;
    property Lic_Domain:String    read FLic_Domain    write FLic_Domain;
    property Lic_Password:String  read FLic_Password  write FLic_Password;
    property Lic_EMail:String     read FLic_EMail     write FLic_EMail;
    property Licenciado:Boolean   read FLicenciado    write FLicenciado;
    property InitialDir:String    read FInitialDir    write FInitialDir;
    property RunAs_UserName:String      read FRunAs_UserName      write FRunAs_UserName;
    property RunAs_Domain:String        read FRunAs_Domain        write FRunAs_Domain;
    property RunAs_Password:String      read FRunAs_Password      write FRunAs_Password;
    property RunAs_Enabled:Boolean      read FRunAs_Enabled       write FRunAs_Enabled;
    property RunAs_Location:String      read FRunAs_Location      write FRunAs_Location;
    property RunAs_Params:String        read FRunAs_Params        write FRunAs_Params;
    property RunAs_Logo:String          read FRunAs_Logo          write FRunAs_Logo;
    property App_LastRun:String         read FApp_LastRun;
  end;

var
  fmRunAs_Main: TfmRunAs_Main;

implementation
uses
  fRunAs_Params,
  fRunApp_Prop,
  Clipbrd,
  Shellapi,
  StrUtils,
  lib_run_as,
  inifiles;

{$R *.dfm}

procedure TfmRunAs_Main.ReadConfig;
var
  MyIni:TInifile;
  bOk:Boolean;
begin
  try
    MyIni:=TInifile.Create(CONFIG_FILE);
    DATABASE_FILE:=ChangeFileExt(CONFIG_FILE,'.xml');
    FRunAs_UserName             :=Criptografar(MyIni.ReadString('Autenticacao','RunAs_user_name', FRunAs_UserName));
    FRunAs_Domain               :=MyIni.ReadString('Autenticacao','RunAs_Domain', FRunAs_Domain);
    FRunAs_Password             :=Criptografar(MyIni.ReadString('Autenticacao','RunAs_Password', FRunAs_Password));
    FInitialDir                 :=MyIni.ReadString('Autenticacao','InitialDir', FInitialDir);
    FRunAs_Enabled              :=MyIni.ReadBool('Autenticacao','RunAs_Enabled', false);
    FRunAs_Location             :=MyIni.ReadString('Autenticacao','RunAs_Location', 'c:\windows\system32\runas.exe');
    FRunAs_Params               :=MyIni.ReadString('Autenticacao','RunAs_Params', '');
    FRunAs_Logo                 :=MyIni.ReadString('Autenticacao','RunAs_Logo', '');
    if FileExists(FRunAs_Logo) then
    begin
      logo.Picture.LoadFromFile(FRunAs_Logo);
    end;
    bOk:=FileExists(DATABASE_FILE);
    if (not bOk) then
    begin
      bOk:=CreateDatabase(appdb);
    end;
    if bOk then
    begin
      try
        if appdb.Active then
          appdb.Close;
        appdb.LoadFromFile(DATABASE_FILE);
        if not appdb.Active then
          appdb.Open;
      except
        bOk:=false;
      end;
      if bOK then
      begin
        appdb.IndexDefs.Clear;
        appdb.Addindex('ById', 'id', []);
        appdb.Addindex('ByTitle', 'title', []);
        appdb.IndexName := 'ById';
        appdb.IndexDefs.Update;
        appdb.LogChanges := false;
      end;
    end;
  finally
    if Assigned(MyIni) then
      FreeAndNil(MyIni);
  end;


end;

function TfmRunas_Main.RunAs_GetBitmap(AFileOrLocation:String; AWidth, AHeight:Integer):TBitmap;
var
  iBmp_Size:Cardinal;
begin
  Result:=TBitMap.Create;
  if (Result.Empty) then
  begin
    if FileExists(AFileOrLocation) then
    begin
      if Pos('.exe',lowercase(ExtractFileExt(AFileOrLocation)))>0 then
      begin
        Result:=AppIcon2Bitmap(AFileOrLocation, 16, 16);
      end;
      if (Pos('.cmd',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.bat',lowercase(ExtractFileExt(AFileOrLocation)))>0) then
      begin
        ImageList1.GetBitmap(25, Result);   // bomba
      end;
      if (Pos('.vbs',lowercase(ExtractFileExt(AFileOrLocation)))>0) then
      begin
        ImageList1.GetBitmap(25, Result); // bomba
      end;
      if (Pos('.pdf',lowercase(ExtractFileExt(AFileOrLocation)))>0) then
      begin
        ImageList1.GetBitmap(39, Result);
      end;
      if (Pos('.dwg',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.dxf',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.svg',lowercase(ExtractFileExt(AFileOrLocation)))>0) then
      begin
        ImageList1.GetBitmap(40, Result);
      end;
      if (Pos('.xls',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.xlsx',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.ods',lowercase(ExtractFileExt(AFileOrLocation)))>0) then
      begin
        ImageList1.GetBitmap(38, Result);
      end;
      if (Pos('.doc',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.docx',lowercase(ExtractFileExt(AFileOrLocation)))>0) or
         (Pos('.odt',lowercase(ExtractFileExt(AFileOrLocation)))>0) then
      begin
        ImageList1.GetBitmap(43, Result);
      end;
    end;
  end;
  // Pasta de Downloads
  if (Result.Empty) then
  begin
    if Pos('\download',lowercase(AFileOrLocation))>0 then
      ImageList1.GetBitmap(36, Result);
  end;
  // Apenas indicação de pasta
  if Result.Empty then
  begin
    if DirectoryExists(AFileOrLocation) then
      ImageList1.GetBitmap(0, Result);
  end;

  // Se nenhum icone foi estabelecido então usa um padrão
  iBmp_Size:=BitmapSize(Result);
  if (Result.Empty) or (iBmp_Size=0) then
  begin
    ImageList1.GetBitmap(41, Result);
  end;

  Result.Transparent:=true;
  if (AWidth>0) and (AHeight>0) then
    SmoothResize(Result, AWidth, AHeight);   // ComboBox.Height

end;

procedure TfmRunas_Main.WriteConfig;
var
  MyIni:TInifile;
begin
  try
    MyIni:=TInifile.Create(CONFIG_FILE);
    MyIni.WriteString('Autenticacao','App_LastRun', FApp_LastRun);
  finally
    if Assigned(MyIni) then
      FreeAndNil(MyIni);
  end;
end;

procedure TfmRunAs_Main.DoConfigExecute(Sender: TObject);
begin
  if not Assigned(fmRunAs_Params) then
    fmRunAs_Params:=TfmRunAs_Params.Create(Self);
  fmRunAs_Params.Caption:='Parametros essenciais:';
  fmRunAs_Params.user_name.text:=FRunAs_UserName;
  fmRunAs_Params.domain.text:=FRunAs_Domain;
  fmRunAs_Params.password.text:=FRunAs_Password;
 // fmRunAs_Params.cbox_app_list.items.Clear;
  //fmRunAs_Params.cbox_app_list.Items.AddStrings(cbox_app_list.Items);
  fmRunAs_Params.RunAs_Location.text:=FRunAs_Location;
  fmRunAs_Params.RunAs_Params.text:=FRunAs_Params;
  fmRunAs_Params.RunAs_Enabled.Checked:= FRunAs_Enabled;
  fmRunAs_Params.RunAs_Logo.text:=FRunAs_Logo;
  fmRunAs_Params.ShowModal;
  if fmRunAs_Params.Aplicado then
  begin
    ReadConfig;
  end;

  if Assigned(fmRunAs_Params) then
    FreeAndNil(fmRunAs_Params);
end;

procedure TfmRunAs_Main.DoExecutarExecute(Sender: TObject);
var
  S:String;
  iRet:LongWord;
  sMsg_Error:String;
  iPos:Integer;
  sApp_Location:String;
  sApp_Params:String;
  sApp_Title:String;
  bApp_Admin:Boolean;
  bApp_Enabled:Boolean;
begin
  sMsg_Error:='';

  sApp_location:=appdb.FieldByName('location').AsString;
  sApp_Params:=appdb.FieldByName('params').AsString;

  sApp_Title:=appdb.FieldByName('title').AsString;
  bApp_Admin:=appdb.FieldByName('admin_only').AsBoolean;
  bApp_Enabled:=appdb.FieldByName('enabled').AsBoolean;

  if (not bApp_Enabled)  then
  begin
    sMsg_Error:='Este aplicativo/pasta não está habilitado.';
  end;


  // Quando se indica um diretorio então deve-se determinar qual arquivo daquele
  // diretório deverá ser executado com permissões elevadas
  if (sMsg_Error='') then
  begin
    if DirectoryExists(sApp_Location) then
    begin
      S:=SelecionarArquivoExe(sApp_Location);
      if FileExists(S) then
      begin
        sApp_Location:=S;
      end
      else
      begin
        sMsg_Error:='São permitidos apenas programas ou utilitários localizados em: '+sApp_Location;
      end;
    end;
  end;

  //if (sMsg_Error='') and (not FileExists(sApp_Location)) then
  //   sMsg_Error:='Programa não existe: '+sApp_Location;
  if (sMsg_Error='') and (FRunAs_UserName='') then
     sMsg_Error:='Faltou especificar o nome do usuário: '+FRunAs_UserName;
  if (sMsg_Error='') and (FRunAs_UserName='') then
     sMsg_Error:='Faltou especificar a senha do usuário '+FRunAs_UserName+'.';

  // Valida o uso desse aplicativo dentro da corporação que foi designado
  if (sMsg_Error='') then
  begin
    if (not FLicenciado) then
    begin
      FLicenciado:=LogonPasswordOK(FLic_User, FLic_Domain, FLic_Password);
      if (not FLicenciado) then
      begin
        sMsg_Error:='Programa não foi capaz de autenticar-se com as seguintes credenciais:'+sLineBreak+
          'Conta: '+FLic_User+sLineBreak+
          'Dominio: '+FLic_Domain+sLineBreak+
          'Senha: '+Criptografar(FLic_Password)+sLineBreak+
          'Observe se as credenciais acima não foram modificados recentemente, havendo problemas contate '+FLic_EMail+'.';
      end;
    end;
  end;

  if (sMsg_Error<>'') then
  begin
    Memo_Ajuda.Text:=sMsg_Error;
  end
  else
  begin
    Memo_Ajuda.Clear;
    if bApp_Admin then
    begin
        if FRunAs_Enabled then
        begin
          // usando o shell com runas
          S:=' /savecred';
          if FRunAs_Domain<>'' then
            S:=' /user:"'+FRunAs_Domain+'\'+FRunAs_UserName+'"'
          else
            S:=' /user:"'+FRunAs_UserName+'"';
          //S:=S+' /password:"'+FRunAs_Password+'"';
          //sHOWmESSAGE(FRunAs_Params);
          FRunAs_Params:=S+' '+FRunAs_Params+' '+sApp_Location;
          iRet:=ShellExecute(
                  handle,
                  'open',
                  PWideChar(WideString(FRunAs_Location)),
                  PWideChar(WideString(FRunAs_Params)),
                  '',
                  SW_SHOWNORMAL);
          Memo_Ajuda.Lines.Add(FRunAs_Location+' '+FRunAs_Params);
        end
        else
        begin
          //ShowMessage('Como Admin:'+sLineBreak+sApp_Location+sLineBreak+sApp_Params);
          iRet:=RunAs(FRunAs_UserName, FRunAs_Domain, FRunAs_Password, '"'+sApp_Location+'"', sApp_Params);
        end;
    end
    else
    begin
      ShowMessage('Como usuário normal:'+sLineBreak+sApp_Location+sLineBreak+sApp_Params);
      iRet:=ShellExecute(
        handle,
        'open',
        PWideChar(WideString(sApp_Location)),
        PWideChar(WideString(sApp_Params)),
        '',
        SW_SHOWNORMAL);
    end;
    Memo_Ajuda.Lines.Add(
      sApp_Location+sLineBreak+
      'O Windows retornou (OS Result)='+IntToStr(iRet));
    // alguns erros são conhecidos
    if iRet=1326 then
      Memo_Ajuda.Lines.Add('1326: Nome de usuário ou senha incorretos.');
    if iRet=1058 then
      Memo_Ajuda.Lines.Add('1058: Não foi possivel fazer o "logon secundário", este serviço talvez não esteja habilitado.');
    FApp_LastRun:=sApp_Location;
    WriteConfig;
  end;
end;

procedure TfmRunAs_Main.DoLocalizarExecute(Sender: TObject);
begin
  // Localizar
end;

procedure TfmRunAs_Main.DoNovoExecute(Sender: TObject);
begin
  try
    fmRunApp_Prop:=TfmRunApp_Prop.Create(Self);
    fmRunApp_Prop.Caption:='Novo programa no menu:';
    fmRunApp_Prop.Operacao:='INCLUIR';
    fmRunApp_Prop.ShowModal;
  finally
    if Assigned(fmRunApp_Prop) then
      FreeAndNil(fmRunApp_Prop);
  end;
end;

procedure TfmRunAs_Main.FormCreate(Sender: TObject);
var
  S:String;
begin
  S:=ParamStr(1);
  FInitialDir:='';
  if (S<>'') then
  begin
    if Pos('.ini', lowercase(S))>0 then
       CONFIG_FILE:=S;
  end
  else
  begin
    if DirectoryExists(RootPath+'\etc')
      then CONFIG_FILE:=RootPath+'\etc\'+ChangeFileExt(ExtractFileName(ParamStr(0)),'.ini')
      else CONFIG_FILE:=ChangeFileExt(ParamStr(0),'.ini');
  end;

  Caption:='Executar programa com privilégios superiores';
  if appdb.Active then
    appdb.Close;

  FRunAs_UserName :='administrador';
  FRunAs_Password :='';
  FApp_LastRun    :='';
  FRunAs_Enabled  :=false;
  FRunAs_Location :='';
  FRunAs_Params   :='';
  FRunAs_Logo     :='';
  FLicenciado:=false;

  // Jecks   W8px0e55g
  // descomente a linha abaixo para atribuir uma senha codificada para a clipboard
  //S:='asuasenhaaqui';
  //Clipboard.AsText:=Criptografar(S);
  //FLic_User:='sysadmin';
  //FLic_Domain:='';
  //FLic_Password:=Criptografar('W8px0e55g');
  //FLic_EMail:='gladiston.santana@gmail.com';

  // Vidy  nocnocvidy#
  // descomente a linha abaixo para atribuir uma senha codificada para a clipboard
  //S:='asuasenhaaqui';
  //Clipboard.AsText:=Criptografar(S);
  FLic_User:='vidyapp_auth';
  FLic_Domain:='vidy.local';
  FLic_Password:=Criptografar('abpabpivql#');
  FLic_EMail:='suporte@vidy.com.br';

end;

procedure TfmRunAs_Main.FormShow(Sender: TObject);
begin
  Memo_Ajuda.Clear;
  Memo_Ajuda.Lines.Add('O objetivo deste programa criar um menu de aplciativos podendo '+
    'até mesmo executar alguns programas com poderes de administrador.');
  Memo_Ajuda.Lines.Add(' ');
  Memo_Ajuda.Lines.Add('Corporações sérias restrigem a execução de programas com privilégios de administrador '+
    'porque se algum programa tiver algum comportamento oculto ou hostil deverá ser barrada '+
    'antes que tal programa possa causar danos ao usuário e a corporação.');
  Memo_Ajuda.Lines.Add(' ');
  Memo_Ajuda.Lines.Add('As vezes, um programa pode requerer permissões de administrador, porém '+
    'não tem um comportamento oculto ou hostil, então baseado na relação de confiança entre '+
    'o usuário e o programa, esse programa permitirá sua inclusão num menu de seleção de programas '+
    'com uma propriedade especial que lhe permite ser executado como administrador ou '+
    'outro usuario com o qual deseja fazer a execução.'+sLineBreak);
  Memo_Ajuda.Lines.Add(' ');
  Memo_Ajuda.Lines.Add('Uma outra situação que talvez requeira executar este utilitário '+
    'é quando é necessário instalar programas ou atualizações, neste caso, podemos '+
    'prederminar a pasta onde estarão estas atualizações ou o nome de seus arquivos.');

  if not FileExists(CONFIG_FILE) then
  begin
    DoConfigExecute(Sender);
  end;
  ReadConfig;

  //SendMessage(cbox_App_List.Handle, CB_SETITEMHEIGHT,-1,32)
end;


end.
