unit lib_run_as;

interface

uses
  WinTypes, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  ShellApi, FileCtrl, Types, StrUtils, DateUtils, Math,
  Data.DB, Datasnap.DBClient;

var
  CONFIG_FILE:String;
  DATABASE_FILE:String;

const
  LOGON_WITH_PROFILE = $00000001;

function Criptografar(const Value : string): string;
function CreateProcessWithLogon(
  lpUsername: PWideChar;
  lpDomain: PWideChar;
  lpPassword: PWideChar;
  dwLogonFlags: DWORD;
  lpApplicationName: PWideChar;
  lpCommandLine: PWideChar;
  dwCreationFlags: DWORD;
  lpEnvironment: Pointer;
  lpCurrentDirectory: PWideChar;
  var lpStartupInfo: TStartupInfo;
  var lpProcessInfo: TProcessInformation): BOOL; stdcall;
  external 'advapi32' name 'CreateProcessWithLogonW';

function CreateEnvironmentBlock(
  var lpEnvironment: Pointer;
  hToken: THandle;
  bInherit: BOOL): BOOL; stdcall; external 'userenv';
function GetDosEnv(varAmbiente : string):String;
function DestroyEnvironmentBlock(pEnvironment: Pointer): BOOL; stdcall; external 'userenv';
function LogonPasswordOK(User, Domain, Password:String):Boolean;
function RootPath(sPathFileName:String='') : String;
function SelecionarArquivoExe(ARootDir:String=''):String;
function ExtractLocation(AText:String):String;
procedure Apps_ReadList(AListControl:TWinControl; iSpaceSeparator:Integer=1);
function RunAs(AUserName, ADomainName, APassword, AApp_Location:String; AApp_Params: String=''): Integer;
function AppIcon2Bitmap(AppLocation:String; AWidth:Integer; AHeight:integer):TBitmap;
procedure SmoothResize(ABitMap:TBitmap; AWidth, AHeight:integer);
function BitmapSize(ABitmap: TBitmap): Cardinal;
function IsExecutable(AFile:String):Boolean;
function ReadRegEntry(strSubKey,strValueName: string): string;
function GetJavaPathViaRegistry: string;
function CreateDatabase(ACDS:TClientDataset):Boolean;

implementation

uses
  inifiles,
  registry,
  fRunApp_Prop,
  fRunAs_Main;

// Funcao para criptografar ou decriptografar uma string longa
// Esta funcao serve para as duas operacoes, se o texto estiver
// encriptado entao devolve decriptado.
// É apenas uma maneira de ofuscar valores que não devem ser exibidos
function Criptografar(const Value : string): string;
var i: integer;
begin
  result := Value;
  for i := 1 to length(Value) do
    case ord(Value[i]) of
    ord('A')..ord('M'),ord('a')..ord('m'): result[i] := chr(ord(Value[i])+13);
    ord('N')..ord('Z'),ord('n')..ord('z'): result[i] := chr(ord(Value[i])-13);
    ord('0')..ord('4'): result[i] := chr(ord(Value[i])+5);
    ord('5')..ord('9'): result[i] := chr(ord(Value[i])-5);
    end;
end;

// Usuario e senha validos?
function LogonPasswordOK(User, Domain, Password:String):Boolean;
var
  sUserQualy:String;
  hToken: THandle;
begin
  sUserQualy:=User;
  if (Domain<>'') and (Domain<>'.')
    then sUserQualy:=sUserQualy+'@'+Domain;
  Result:=LogonUser(PChar(sUserQualy), nil, PChar(Password), LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, hToken);
end;

function RootPath(sPathFileName:String='') : String;
var
  nLen,n,nCount,nPos:Integer;
  sPart1,sPart2:String;
begin
  if sPathFileName=''
    then sPathFileName:=ExtractFilePath(sPathFileName);

  sPart1:='';
  sPart2:=sPathFileName;
  nLen:=Length(sPathFileName);
  nPos:=Pos('\\',sPathFileName);
  if nPos=0 then  nPos:=Pos('//',sPathFileName);
  if (nPos>0) then
  begin
    sPart1:=Copy(sPathFileName,1,nPos+1);
    sPart2:=Copy(sPathFileName,nPos+2,nLen);
  end;
  if Pos('\\',sPart2)>0
    then sPart2:=StringReplace(sPart2,'\\','\',[rfIgnoreCase,rfReplaceAll]);
  if Pos('//',sPart2)>0
    then sPart2:=StringReplace(sPart2,'//','/',[rfIgnoreCase,rfReplaceAll]);
  nPos:=0;
  nCount:=0;
  nLen:=Length(sPart2);
  for n:=1 to nLen do
  begin
    if (Copy(sPart2,n,1)='\') or (Copy(sPart2,n,1)='/')
      then Inc(nCount);
    if nCount=2 then
    begin
      nPos:=n;
      break;
    end;
  end;
  if nPos > 0 then
  begin
    Result:=sPart1+Copy(sPart2,1,nPos-1);
    if (RightStr(Result,1)='\') or (RightStr(Result,1)='/')
      then Result:=Copy(Result,1,Length(Result)-1);
  end;
  Result:=Trim(Result);
end;

// SelecionarArquivo : Permite seleciona um arquivo no disco
function SelecionarArquivoExe(ARootDir:String=''):String;
var
  OpenDialog1:TOpenDialog;
begin
  Result:='';
  OpenDialog1:=TOpenDialog.Create(nil);
  OpenDialog1.Title:='Selecione um utilitário ou aplicativo:';
  OpenDialog1.DefaultExt:='*.exe';
  OpenDialog1.Filter:='Utilitário ou aplicativo|*.exe;*.cmd;*.bat';
  if FileExists(ARootDir)
    then ARootDir:=ExtractFilePath(ARootDir);
  OpenDialog1.InitialDir:=ARootDir;
  if OpenDialog1.Execute then
  begin
    if SameText(ExtractFilePath(OpenDialog1.FileName), ARootDir) then
    begin
      Result:=OpenDialog1.FileName;
    end;
  end;
  OpenDialog1.Free;

end;

function ExtractLocation(AText:String):String;
var
  S:String;
  iRet:LongWord;
  sMsg_Error:String;
  iPos:Integer;
begin
  // Executar http://edn.embarcadero.com/article/33942
  Result:='';
  iPos:=Pos('(', AText);
  if iPos>0 then
  begin
    Result:=Copy(AText, iPos+1, Length(AText)-iPos);
    iPos:=Pos(')', Result);
    if iPos>0 then
    begin
      Result:=LeftStr(Result, iPos-1);
    end;
  end
  else
  begin
    if FileExists(AText) then
      Result:=AText;
  end;
end;

procedure Apps_ReadList(AListControl:TWinControl; iSpaceSeparator:Integer=1);
var
  MyIni:TInifile;
  sSectionName:String;
  sApp_location, sApp_Params, sApp_Title:String;
  bApp_Enabled:Boolean;
  i:Integer;
  lSections:TStringList;
begin
  try
    MyIni:=TInifile.Create(CONFIG_FILE);
    // populando lista de apps
    if (AListControl is TListBox) then
    begin
      with (AListControl as TListBox) do
      begin
        Items.Clear;
      end;
    end;
    if (AListControl is TComboBox) then
    begin
      with (AListControl as TComboBox) do
      begin
        Items.Clear;
      end;
    end;
    lSections:=TStringList.Create;
    Myini.ReadSections(lSections);
    lSections.Sort;
    //ShowMessage(lSections.Text);
    for i := 0 to Pred(lSections.Count) do
    begin
      sSectionName:=Trim(lSections[i]);
      if (LeftStr(sSectionName,4)='app_') then
      begin
        sApp_location:=MyIni.ReadString(sSectionName,'app_location','');
        sApp_Params:=MyIni.ReadString(sSectionName,'app_params','');
        sApp_Title:=MyIni.ReadString(sSectionName,'app_title','');
        bApp_Enabled:=MyIni.ReadBool(sSectionName,'app_enabled',false);
        if (sApp_location<>'') and (bApp_Enabled) then
        begin
          if (sApp_Title<>'') then
          begin
            // listbox
            if (AListControl is TListBox) then
            begin
              with (AListControl as TListBox) do
              begin
                Items.Add(sApp_Title+StringOfChar(' ', iSpaceSeparator)+'('+sApp_location+')');
              end;
            end;
            // combobox
            if (AListControl is TComboBox) then
            begin
              with (AListControl as TComboBox) do
              begin
                Items.Add(sApp_Title+StringOfChar(' ', iSpaceSeparator)+'('+sApp_location+')');
              end;
            end;

          end;
        end;
      end;
    end;
  finally
    if Assigned(lSections) then
      FreeAndNil(lSections);
    if Assigned(MyIni) then
      FreeAndNil(MyIni);
  end;
end;

// GetDosEnv: Permite coletar o conteudo de uma variavel ambiente
function GetDosEnv(varAmbiente : string):String;
var
  P : PChar;
  S : String;
  E : String;
  sResult:String;
begin
  try
    Result:='';
    sResult := '';
    if Length(varAmbiente) > 0 then
     begin
       P := GetEnvironmentStrings;
       while P[0] <> #0 do
         begin
            S := StrPas(P);
            E := S;
            S := Copy(UpperCase(S), 1, Length(varAmbiente) + 1);
            if S = UpperCase(varAmbiente) + '=' then
              begin
                sResult := Copy(E, Length(varAmbiente) + 2, Length (E));
              end;
            P := StrEnd(P) + 1;
         end;
     end
    else
     sResult := '';
    Result:=sResult;
  finally

  end;
end;

//Emulate the RunAs function
function RunAs(AUserName, ADomainName, APassword, AApp_Location:String; AApp_Params: String=''): Integer;
var
  dwSize: DWORD;
  hToken: THandle;
  lpvEnv: Pointer;
  pi: TProcessInformation;
  si: TStartupInfo;
  szPath: Array [0..MAX_PATH] of WideChar;
  sUserQualy:String;
begin
  ZeroMemory(@szPath, SizeOf(szPath));
  ZeroMemory(@pi, SizeOf(pi));
  ZeroMemory(@si, SizeOf(si));
  si.cb:=SizeOf(TStartupInfo);
  sUserQualy:= AUserName;

  if (ADomainName<>'') and (ADomainName<>'.')
    then sUserQualy:=sUserQualy+'@'+ADomainName;
  if LogonUser(PChar(sUserQualy), nil, PChar(APassword), LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, hToken) then
  begin
    ShowMessage(
      'Debug:'+sLineBreak+
      'UserName='+AUserName+sLineBreak+
      'DomainName='+ADomainName+sLineBreak+
      'Password='+APassword+sLineBreak+
      'App Location='+AApp_Location+sLineBreak+
      'App Params='+AApp_Params);

    if CreateEnvironmentBlock(lpvEnv, hToken, True) then
    begin
      dwSize:=SizeOf(szPath) div SizeOf(WCHAR);
      if (GetCurrentDirectoryW(dwSize, @szPath) > 0) then
      begin
        if (CreateProcessWithLogon(
             PWideChar(WideString(sUserQualy)),
             nil,
             PWideChar(WideString(APassword)),
             LOGON_WITH_PROFILE,
             PWideChar(WideString(AApp_Location)),
             PWideChar(WideString(AApp_Params)),
             CREATE_UNICODE_ENVIRONMENT,
             lpvEnv, szPath, si, pi)) then
        begin
          result:=ERROR_SUCCESS;
          CloseHandle(pi.hProcess);
          CloseHandle(pi.hThread);
        end
        else
        begin
          result:=GetLastError;
        end;
      end
      else
      begin
        result:=GetLastError;
      end;
      DestroyEnvironmentBlock(lpvEnv);

    end
    else
    begin
      result:=GetLastError;
    end;
    CloseHandle(hToken);
  end
  else
  begin
    result:=GetLastError;
  end;
end;


function AppIcon2Bitmap(AppLocation:String; AWidth:Integer; AHeight:integer):TBitmap;
var
  MyIcon:   TIcon;
begin
  Result:=nil;
  if FileExists(AppLocation) then
  begin
    MyIcon := TIcon.Create;
    try
      // Cria um MyBitMap temporario
      Result := TBitmap.Create;
      try
        // Extrai o icone do app.exe
        MyIcon.Handle:=ExtractIcon(Application.handle, PChar(AppLocation), 0);

        // Transfere o icone para o MyBitMap com stretch 16x16 para que
        // caiba no menu popup
        Result.Height := MyIcon.Height;
        Result.Width  := MyIcon.Width;
        //Result.PixelFormat := pf1bit;
        Result.TransparentMode := tmAuto;
        Result.Canvas.Draw(0, 0, MyIcon);
        if (AWidth>0) and (AHeight>0) then
        begin
          SmoothResize(Result, AWidth, AHeight);
        end;
      finally

      end;
    finally
      // Libera memoria do icone
      //MyIcon.Free;
      if Assigned(MyIcon) then
        FreeAndNil(MyIcon);
    end;
  end;
end;

procedure SmoothResize(ABitMap:TBitmap; AWidth,AHeight:integer);
type
  TRGBArray = ARRAY[0..32767] OF TRGBTriple;
  pRGBArray = ^TRGBArray;
var
  xscale, yscale         : Single;
  sfrom_y, sfrom_x       : Single;
  ifrom_y, ifrom_x       : Integer;
  to_y, to_x             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue               : Integer;
  total_red, total_green : Single;
  total_blue             : Single;
  ix, iy                 : Integer;
  bTmp : TBitmap;
  sli, slo : pRGBArray;
begin
  ABitMap.PixelFormat := pf24bit;
  bTmp := TBitmap.Create;
  bTmp.PixelFormat := pf24bit;
  bTmp.Width := AWidth;
  bTmp.Height := AHeight;
  xscale := bTmp.Width / (ABitMap.Width-1);
  yscale := bTmp.Height / (ABitMap.Height-1);
  for to_y := 0 to bTmp.Height-1 do begin
    sfrom_y := to_y / yscale;
    ifrom_y := Trunc(sfrom_y);
    weight_y[1] := sfrom_y - ifrom_y;
    weight_y[0] := 1 - weight_y[1];
    for to_x := 0 to bTmp.Width-1 do begin
      sfrom_x := to_x / xscale;
      ifrom_x := Trunc(sfrom_x);
      weight_x[1] := sfrom_x - ifrom_x;
      weight_x[0] := 1 - weight_x[1];
      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          sli := ABitMap.Scanline[ifrom_y + iy];
          new_red := sli[ifrom_x + ix].rgbtRed;
          new_green := sli[ifrom_x + ix].rgbtGreen;
          new_blue := sli[ifrom_x + ix].rgbtBlue;
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
        end;
      end;
      slo := bTmp.ScanLine[to_y];
      slo[to_x].rgbtRed := Round(total_red);
      slo[to_x].rgbtGreen := Round(total_green);
      slo[to_x].rgbtBlue := Round(total_blue);
    end;
  end;
  ABitMap.Width := bTmp.Width;
  ABitMap.Height := bTmp.Height;
  ABitMap.Canvas.Draw(0,0,bTmp);
  bTmp.Free;
end;

function BitmapSize(ABitmap: TBitmap): Cardinal;
var
  ms : TMemoryStream;
begin
  try
    ms := TMemoryStream.Create;
    ABitmap.savetostream(ms);
  finally
    result := ms.size;
    FreeAndNil(ms);
  end;

end;

function IsExecutable(AFile:String):Boolean;
var
  sExt:String;
begin
  Result:=false;
  sExt:=ExtractFileExt(AFile);
  if LeftStr(sExt,1)='.' then
    sExt:=RightStr(sExt, Length(sExt)-1);
  if (sExt<>'') then
  begin
    if Pos(sExt,'|exe|com|bat|cmd|vbs|')>0 then
      Result:=true;
  end;
end;

function ReadRegEntry(strSubKey,strValueName: string): string;
var
 Key: HKey;
 Buffer: array[0..255] of char;
 Size: cardinal;
begin
 Result := 'ERROR';
 Size := SizeOf(Buffer);
 if RegOpenKeyEx(HKEY_LOCAL_MACHINE,
    PChar(strSubKey), 0, KEY_READ, Key) = ERROR_SUCCESS then
  if RegQueryValueEx(Key,PChar(strValueName),nil,nil,
      @Buffer,@Size) = ERROR_SUCCESS then
    Result := Buffer;
 RegCloseKey(Key);
end;

function GetJavaPathViaRegistry: string;
const
  JAVA_KEY: string = '\SOFTWARE\JavaSoft\Java Runtime Environment\';
  Wow64Flags: array[0..2] of DWORD = (0, KEY_WOW64_32KEY, KEY_WOW64_64KEY);
var
  reg: TRegistry;
  s: string;
  i: integer;
begin
  Result := '';
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    for i := Low(Wow64Flags) to High(Wow64Flags) do
    begin
      reg.Access := (reg.Access and KEY_WOW64_RES) or Wow64Flags[i];
      if reg.OpenKeyReadOnly(JAVA_KEY) then
      begin
        s := reg.ReadString('CurrentVersion');
        if s <> '' then
        begin
          if reg.OpenKeyReadOnly(s) then
          begin
            s := reg.ReadString('JavaHome');
            if s <> '' then
            begin
              Result := IncludeTrailingPathDelimiter(s) + 'bin' + PathDelim + 'java.exe';
              // if not FileExists(Result) then Result := '' else
              Exit;
            end;
          end;
        end;
        reg.CloseKey;
      end;
    end;
  finally
    reg.Free;
  end;
end;

function CreateDatabase(ACDS:TClientDataset):Boolean;
begin
  Result:=false;
  if FileExists(DATABASE_FILE) then
  begin
    Result:=true;
    Exit;
  end;
  try
    ACDS.Close;
    ACDS.FieldDefs.Clear;
    ACDS.FieldDefs.Add('id', ftInteger, 0, False);
    ACDS.FieldDefs.Add('title', ftString, 4096, False);
    ACDS.FieldDefs.Add('location', ftString, 4096, False);
    ACDS.FieldDefs.Add('params', ftString, 4096, False);
    ACDS.FieldDefs.Add('enabled', ftBoolean, 0, False);
    ACDS.FieldDefs.Add('admin_only', ftBoolean, 0, False);
    ACDS.FieldDefs.Add('admin_domain', ftString, 255, False);
    ACDS.FieldDefs.Add('admin_username', ftString, 255, False);
    ACDS.FieldDefs.Add('admin_password', ftString, 255, False);
    ACDS.FieldDefs.Add('stat_run', ftLargeInt, 0, False);
    ACDS.FieldDefs.Add('stat_lastrun', ftDateTime, 0, False);
    ACDS.FieldDefs.Add('icon', ftGraphic, 0, False);
    ACDS.FieldDefs.Add('folder_only', ftBoolean, 0, False);

    ACDS.CreateDataSet;
    //ACDS.Open;

    // Definicao de titulos
    ACDS.FieldbyName('id').DisplayLabel:='-';
    ACDS.FieldbyName('title').DisplayLabel:='Titulo';
    ACDS.FieldbyName('location').DisplayLabel:='Localização';
    ACDS.FieldbyName('params').DisplayLabel:='Parametros';
    ACDS.FieldbyName('enabled').DisplayLabel:='Habilitado';
    ACDS.FieldbyName('admin_only').DisplayLabel:='Req. Admin';
    ACDS.FieldbyName('admin_domain').DisplayLabel:='Admin Dominio';
    ACDS.FieldbyName('admin_username').DisplayLabel:='Admin Usuario';
    ACDS.FieldbyName('admin_password').DisplayLabel:='Admin Senha';
    ACDS.FieldbyName('stat_run').DisplayLabel:='Qtde';
    ACDS.FieldbyName('stat_lastrun').DisplayLabel:='Ult.Exec';
    ACDS.FieldbyName('icon').DisplayLabel:='Icone';
    ACDS.FieldbyName('folder_only').DisplayLabel:='Somente Pasta';

    // definição de tamanho de campos
    ACDS.FieldbyName('id').DisplayWidth:=3;
    ACDS.FieldbyName('title').DisplayWidth:=30;
    ACDS.FieldbyName('location').DisplayWidth:=30;
    ACDS.FieldbyName('params').DisplayWidth:=30;
    ACDS.FieldbyName('enabled').DisplayWidth:=3;
    ACDS.FieldbyName('admin_only').DisplayWidth:=10;
    ACDS.FieldbyName('admin_domain').DisplayWidth:=30;
    ACDS.FieldbyName('admin_username').DisplayWidth:=30;
    ACDS.FieldbyName('admin_password').DisplayWidth:=30;
    ACDS.FieldbyName('stat_run').DisplayWidth:=10;
    ACDS.FieldbyName('stat_lastrun').DisplayWidth:=30;
    ACDS.FieldbyName('icon').DisplayWidth:=3;
    ACDS.FieldbyName('folder_only').DisplayWidth:=10;

    // definição dos campos que serão invisiveis
    ACDS.FieldbyName('id').Visible:=false;
    ACDS.FieldbyName('title').Visible:=true;
    ACDS.FieldbyName('location').Visible:=true;
    ACDS.FieldbyName('params').Visible:=false;
    ACDS.FieldbyName('enabled').Visible:=true;
    ACDS.FieldbyName('admin_only').Visible:=true;
    ACDS.FieldbyName('admin_domain').Visible:=false;
    ACDS.FieldbyName('admin_username').Visible:=false;
    ACDS.FieldbyName('admin_password').Visible:=false;
    ACDS.FieldbyName('stat_run').Visible:=true;
    ACDS.FieldbyName('stat_lastrun').Visible:=true;
    ACDS.FieldbyName('icon').Visible:=false;
    ACDS.FieldbyName('folder_only').Visible:=true;

    // Alinhamento (taLeftJustify, taRightJustify, taCenter);
    ACDS.FieldbyName('id').Alignment:=taCenter;
    ACDS.FieldbyName('title').Alignment:=taLeftJustify;
    ACDS.FieldbyName('location').Alignment:=taLeftJustify;
    ACDS.FieldbyName('params').Alignment:=taLeftJustify;
    ACDS.FieldbyName('enabled').Alignment:=taCenter;
    ACDS.FieldbyName('admin_only').Alignment:=taCenter;
    ACDS.FieldbyName('admin_domain').Alignment:=taLeftJustify;
    ACDS.FieldbyName('admin_username').Alignment:=taLeftJustify;
    ACDS.FieldbyName('admin_password').Alignment:=taLeftJustify;
    ACDS.FieldbyName('stat_run').Alignment:=taCenter;
    ACDS.FieldbyName('stat_lastrun').Alignment:=taCenter;
    ACDS.FieldbyName('icon').Alignment:=taLeftJustify;
    ACDS.FieldbyName('folder_only').Alignment:=taCenter;

    try
      if (not ACDS.Active) then
        ACDS.Open;
      ACDS.SaveToFile(DATABASE_FILE);
      Result:=FileExists(DATABASE_FILE);
      if (ACDS.Active) then
        ACDS.Close;
    except
    on e:exception do
       begin
         ShowMessage(e.Message);
       end;
    end;
  except
  on e:exception do
     begin
       ShowMessage(e.Message);
     end;
  end;
end;

initialization
  CONFIG_FILE:='';
  DATABASE_FILE:='';


end.
