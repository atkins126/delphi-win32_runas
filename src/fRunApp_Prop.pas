unit fRunApp_Prop;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.DBCtrls, Vcl.Mask, Data.DB, Datasnap.DBClient;

type
  TfmRunApp_Prop = class(TForm)
    Painel_Saida: TPanel;
    BtnSalvar: TBitBtn;
    gb_app_opcoes: TGroupBox;
    gb_app_title: TGroupBox;
    Memo_Ajuda: TMemo;
    BtnSair: TBitBtn;
    BtnCriarTeste: TBitBtn;
    PopupMenu1: TPopupMenu;
    Menu_Find_Java: TMenuItem;
    Panel1: TPanel;
    DBCheckBox1: TDBCheckBox;
    DBCheckBox2: TDBCheckBox;
    title: TDBEdit;
    gb_app_location: TGroupBox;
    BtnProcurar: TBitBtn;
    location: TDBEdit;
    gb_app_location_params: TGroupBox;
    DBEdit2: TDBEdit;
    DBCheckBox3: TDBCheckBox;
    Label1: TLabel;
    gb_app_id: TGroupBox;
    DBEdit4: TDBEdit;
    DBImage1: TDBImage;
    procedure FormCreate(Sender: TObject);
    procedure BtnProcurarClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure BtnCriarTesteClick(Sender: TObject);
    procedure Menu_Find_JavaClick(Sender: TObject);
    procedure titleExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FAplicado:Boolean;
    FLoadedData:Boolean;
    FOperacao: String;
    procedure PreencheFormulario;
    function ExecutarOperacao:Boolean;
  public
    { Public declarations }
  published
    property Operacao:String read FOperacao write FOperacao;
    property Aplicado:Boolean read FAplicado;
  end;

var
  fmRunApp_Prop: TfmRunApp_Prop;

implementation
uses
  inifiles,
  StrUtils,
  utils_dialogs,
  lib_run_as,
  fRunAs_Main;

{$R *.dfm}

procedure TfmRunApp_Prop.PreencheFormulario;
var
  iCount:Integer;
begin
  FOperacao:=Uppercase(tRIM(FOperacao));
  if (Operacao='CADASTRAR') or (Operacao='INSERIR')
    then Operacao:='INCLUIR';
  if (Operacao='MODIFICAR') or (Operacao='EDITAR')
    then Operacao:='ALTERAR';
  if (Operacao='APAGAR') or (Operacao='ELIMINAR') or (Operacao='REMOVER')
    then Operacao:='EXCLUIR';

  if (location.CanFocus) and (Showing)
    then ActiveControl:=location;

  if FOperacao='INCLUIR' then
  begin
    iCount:=(fmRunAs_Main.appdb.RecordCount);
    fmRunAs_Main.appdb.Append;
    fmRunAs_Main.appdbid.AsInteger:=((iCount+1)*10);
    fmRunAs_Main.appdbtitle.AsString:='';
    fmRunAs_Main.appdblocation.AsString:='';
    fmRunAs_Main.appdbparams.AsString:='';
    fmRunAs_Main.appdbenabled.AsBoolean:=true;
    fmRunAs_Main.appdbadmin_only.AsBoolean:=false;
    fmRunAs_Main.appdbadmin_domain.AsString:='';
    fmRunAs_Main.appdbadmin_username.AsString:='';
    fmRunAs_Main.appdbadmin_password.AsString:='';
    fmRunAs_Main.appdbstat_run.Asinteger:=0;
    fmRunAs_Main.appdbstat_lastrun.AsDatetime:=now;
    fmRunAs_Main.appdbfolder_only.AsBoolean:=false;
  end;
  if FOperacao='ALTERAR' then
  begin
    fmRunAs_Main.appdb.Edit;
  end;

  Caption:='Editando propriedades de: ['+fmRunAs_Main.appdblocation.AsString+']';
  if title.CanFocus then
    ActiveControl:=title;
end;

function TfmRunApp_Prop.ExecutarOperacao: Boolean;
begin
  Result:=false;
  if (FOperacao='')
    then Exit;
  if ((FOperacao='INCLUIR') or (FOperacao='ALTERAR')) then
  begin
    if (fmRunAs_Main.appdb.DataSource.State in [dsInsert, dsEdit]) then
    begin
      try
        fmRunAs_Main.appdb.Post;
        FAplicado:=true;
      except
      on e:exception do
         begin
           Memo_Ajuda.Text:=e.Message;
         end;
      end;
    end;
  end;
  if FOperacao='EXCLUIR' then
  begin
      try
        fmRunAs_Main.appdb.Delete;
        FAplicado:=true;
      except
      on e:exception do
         begin
           Memo_Ajuda.Text:=e.Message;
         end;
      end;
  end;
end;

procedure TfmRunApp_Prop.BtnCriarTesteClick(Sender: TObject);
var
  L:TStringlist;
  SaveDialog1:TSaveDialog;
  sSaveToFile:String;
begin
  sSaveToFile:='';
  SaveDialog1:=TSaveDialog.Create(nil);
  SaveDialog1.Title:='Criar um arquivo de teste';
  SaveDialog1.DefaultExt:='*.cmd';
  SaveDialog1.Filter:='Batfile para teste|*.cmd';
  SaveDialog1.InitialDir:=fmRunAs_Main.InitialDir;
  if SaveDialog1.Execute then
  begin
    sSaveToFile:=SaveDialog1.FileName;
    L:=TStringList.Create;
    L.Add('@echo off');
    L.Add('rem Arquivo criado em '+FormatDateTime('ddddd', now));
    L.Add('echo Eu sou == %USERNAME% ==');
    L.Add('pause');
    L.SaveToFile(sSaveToFile);
    //if Apps_Incluir(sSaveToFile,'','Teste Quem sou eu') then
    //begin
    //  Apps_ReadList(cbox_app_list);
    //end;
    fmRunAs_Main.appdblocation.AsString:=SaveDialog1.FileName;
    fmRunAs_Main.appdbadmin_only.AsBoolean:=true;
    fmRunAs_Main.appdbparams.AsString:='';
    fmRunAs_Main.appdbtitle.Text:='Teste para identificar quem sou eu';
  end;
  if Assigned(SaveDialog1) then
    SaveDialog1.Free;

end;

procedure TfmRunApp_Prop.BtnProcurarClick(Sender: TObject);
var
  OpenDialog1:TOpenDialog;
  sNew_app_tittle, sApp_location:String;
begin
  OpenDialog1:=TOpenDialog.Create(Self);
  OpenDialog1.Title:='Utilitário ou aplicativo:';
  OpenDialog1.DefaultExt:='*.exe';
  OpenDialog1.Filter:='Utilitário ou aplicativo|*.exe;*.cmd;*.bat;';
  if OpenDialog1.Execute then
  begin
    sApp_location:=OpenDialog1.FileName;
    sNew_app_tittle:=ChangeFileExt(ExtractFileName(fmRunAs_Main.appdblocation.Text),'');
  end;
  OpenDialog1.Free;
end;

procedure TfmRunApp_Prop.BtnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfmRunApp_Prop.BtnSalvarClick(Sender: TObject);
var
  sMsg_Error:String;
  bApp_Admin, bApp_Enabled:Boolean;
  iApp_Order:Integer;
begin
  sMsg_Error:='';
  if (FOperacao<>'EXCLUIR') then
  begin
    if (sMsg_Error='') and (Trim(fmRunAs_Main.appdblocation.Text)='') then
      sMsg_Error:='Pasta, aplicativo ou utilitário não foi definido.';
    if (sMsg_Error='') then
    begin
      if fmRunAs_Main.appdbfolder_only.AsBoolean then
      begin
        if (not DirectoryExists(fmRunAs_Main.appdblocation.Text)) then
          fmRunAs_Main.appdbfolder_only.AsBoolean:=false;
      end
      else
      begin
        if (not FileExists(fmRunAs_Main.appdblocation.AsString)) then
        begin
         if MessageDlg(
            fmRunAs_Main.appdblocation.AsString+' não foi encontrado.'+sLineBreak+
            'Prosseguir assim mesmo?',
            mtConfirmation,
            [mbYes, mbNo], 0) = mrNo then
          begin
            sMsg_Error:='Aplicativo ou utilitário não existe:'+sLineBreak+fmRunAs_Main.appdblocation.AsString;
          end;
        end;
      end;
    end;
    if (sMsg_Error='') and (Trim(fmRunAs_Main.appdbtitle.Text)='') then
      sMsg_Error:='Aplicativo ou utilitário está sem titulo.';
  end;

  if (sMsg_Error<>'') then
  begin
    Memo_Ajuda.Text:=sMsg_Error;
  end
  else
  begin
    if (ExecutarOperacao) then
    begin
      // Reabre para editar com novas propriedades
      Tag:=1;
      //if OPERACAO='incluir' then
      //begin
      //  OPERACAO:='alterar';
      //  DESCRICAO.Text:='';
      //  FormShow(Self);
      //  Exit;
      //end;
      ModalResult:=mrOK;
      Close;
    end;
  end;

end;

procedure TfmRunApp_Prop.titleExit(Sender: TObject);
var
  i:Integer;
  sChar:String;
const
  _CracteresInvalidos='()[]$%_\/<>^"''`´';
begin
  if (fmRunAs_Main.appdb.DataSource.State in [dsInsert, dsEdit]) then
  begin
    for i:=0 to Length(_CracteresInvalidos) do
    begin
      sChar:=Copy(_CracteresInvalidos, i, 1);
      if (Pos(sChar, fmRunAs_Main.appdbtitle.AsString)> 0) then
        fmRunAs_Main.appdbtitle.AsString:=StringReplace(fmRunAs_Main.appdbtitle.AsString, sChar,'', [rfReplaceAll, rfIgnoreCase]);
    end;
    if (Pos(#32#32, fmRunAs_Main.appdbtitle.AsString)> 0) then
      fmRunAs_Main.appdbtitle.AsString:=StringReplace(fmRunAs_Main.appdbtitle.AsString,#32#32,'', [rfReplaceAll]);
  end;
end;

procedure TfmRunApp_Prop.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  if (fmRunAs_Main.appdb.DataSource.State in [dsInsert, dsEdit]) then
  begin
    if MessageDlg(
      fmRunAs_Main.appdblocation.AsString+' não foi confirmado a operação de ('+FOperacao+').'+sLineBreak+
      'Se sair agora, cancelará essa operação.'+sLineBreak+
      'Você confirma a saída assim mesmo?',
      mtConfirmation,
      [mbYes, mbNo], 0) = mrNo then
    begin
       CanClose:=false;
    end;

  end;
end;

procedure TfmRunApp_Prop.FormCreate(Sender: TObject);
begin
  FAplicado:=false;
  FLoadedData:=false;
  Caption:='Parametros do aplicativo:';
  Memo_Ajuda.Clear;
end;

procedure TfmRunApp_Prop.FormShow(Sender: TObject);
begin
  if (not FLoadedData)
    then PreencheFormulario;
end;

procedure TfmRunApp_Prop.Menu_Find_JavaClick(Sender: TObject);
var
  sResult:String;
begin
  if (fmRunAs_Main.appdb.DataSource.State in [dsInsert, dsEdit]) then
  begin
    sResult:=GetJavaPathViaRegistry;
    if sResult<>'' then
      fmRunAs_Main.appdblocation.AsString:=sResult;
  end;
end;

end.
