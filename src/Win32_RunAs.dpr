program Win32_RunAs;

{.$R 'uac.res' 'uac.rc'} // UAC only







uses
  Vcl.Forms,
  fRunAs_Main in 'fRunAs_Main.pas' {fmRunAs_Main},
  fRunAs_Params in 'fRunAs_Params.pas' {fmRunAs_Params},
  lib_run_as in 'lib_run_as.pas',
  fRunApp_Prop in 'fRunApp_Prop.pas' {fmRunApp_Prop};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmRunAs_Main, fmRunAs_Main);
  Application.Run;
end.
