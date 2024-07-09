unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  uDMLogo,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Controls.Presentation,
  Olf.FMX.AboutDialog,
  FMX.Menus,
  System.Actions,
  FMX.ActnList,
  FMX.Layouts,
  FMX.Media,
  uProjectVICU,
  FMX.Objects;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    OlfAboutDialog1: TOlfAboutDialog;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    lblStatus: TLabel;
    ActionList1: TActionList;
    mnuMacOS: TMenuItem;
    mnuFile: TMenuItem;
    mnuProject: TMenuItem;
    mnuTools: TMenuItem;
    mnuHelp: TMenuItem;
    mnuFileNew: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSave: TMenuItem;
    mnuFileClose: TMenuItem;
    mnuFileQuit: TMenuItem;
    mnuProjectOptions: TMenuItem;
    mnuToolsOptions: TMenuItem;
    mnuHelpAbout: TMenuItem;
    btnProjectOpen: TButton;
    btnProjectClose: TButton;
    btnProjectOptions: TButton;
    btnToolsOptions: TButton;
    btnQuit: TButton;
    btnAbout: TButton;
    actQuit: TAction;
    actProjectOpen: TAction;
    actProjectNew: TAction;
    actProjectSave: TAction;
    actProjectClose: TAction;
    actProjectOptions: TAction;
    actAbout: TAction;
    actOptions: TAction;
    MediaPlayer1: TMediaPlayer;
    odVICUProject: TOpenDialog;
    scExportedVideo: TSaveDialog;
    svVICUProject: TSaveDialog;
    odVideoFile: TOpenDialog;
    btnProjectNew: TButton;
    lProject: TLayout;
    FlowLayout1: TFlowLayout;
    btnGotoStart: TButton;
    pGotoStart: TPath;
    btnPrevSeconde: TButton;
    pPrevSeconde: TPath;
    btnPrevFrame: TButton;
    pPrevFrame: TPath;
    btnPlayPause: TButton;
    pPlay: TPath;
    pPause: TPath;
    btnNextFrame: TButton;
    pNextFrame: TPath;
    btnNextSeconde: TButton;
    pNextSeconde: TPath;
    btnGotoEnd: TButton;
    pGotoEnd: TPath;
    MediaPlayerControl1: TMediaPlayerControl;
    lblSourceFile: TLabel;
    tbVideo: TTrackBar;
    CheckVideoPositionTimer: TTimer;
    procedure actQuitExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actProjectOpenExecute(Sender: TObject);
    procedure actProjectNewExecute(Sender: TObject);
    procedure actProjectSaveExecute(Sender: TObject);
    procedure actProjectCloseExecute(Sender: TObject);
    procedure actProjectOptionsExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnPlayPauseClick(Sender: TObject);
    procedure btnGotoStartClick(Sender: TObject);
    procedure btnGotoEndClick(Sender: TObject);
    procedure btnNextSecondeClick(Sender: TObject);
    procedure btnPrevSecondeClick(Sender: TObject);
    procedure btnPrevFrameClick(Sender: TObject);
    procedure btnNextFrameClick(Sender: TObject);
    procedure CheckVideoPositionTimerTimer(Sender: TObject);
  private
    FCurrentProject: TVICUProject;
    procedure SetCurrentProject(const Value: TVICUProject);
  protected
    procedure InitMainFormCaption;
    procedure InitAboutDialogDescriptionAndLicense;
    procedure InitMainMenuForMacOS;
    procedure SubscribeToProjectChangedMessage;
  public
    property CurrentProject: TVICUProject read FCurrentProject
      write SetCurrentProject;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  System.Messaging,
  System.IOUtils,
  Olf.FMX.AboutDialogForm,
  u_urlOpen,
  fOptions;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  OlfAboutDialog1.Execute;
end;

procedure TfrmMain.actOptionsExecute(Sender: TObject);
var
  f: TfrmOptions;
begin
  f := TfrmOptions.Create(self);
  try
    f.showmodal;
  finally
    f.free;
  end;
end;

procedure TfrmMain.actProjectCloseExecute(Sender: TObject);
begin
  if assigned(CurrentProject) and CurrentProject.HasChanged then
  begin
    TDialogService.MessageDialog
      ('Current project has been changed. Do you want to save it ?',
      tmsgdlgtype.mtConfirmation, mbyesno, tmsgdlgbtn.mbYes, 0,
      procedure(const AModalResult: TModalResult)
      begin
        if AModalResult = mryes then
          if not CurrentProject.FilePath.IsEmpty then
            CurrentProject.SaveToFile
          else
          begin
            tthread.ForceQueue(nil,
              procedure
              begin
                actProjectSaveExecute(Sender);
              end);
            abort;
          end;
        CurrentProject.free;
        CurrentProject := nil;
      end);
  end
  else
  begin
    CurrentProject.free;
    CurrentProject := nil;
  end;
end;

procedure TfrmMain.actProjectNewExecute(Sender: TObject);
var
  Project: TVICUProject;
begin
  if assigned(CurrentProject) then
    actProjectCloseExecute(Sender);

  if odVideoFile.InitialDir.IsEmpty then
    odVideoFile.InitialDir := TPath.GetMoviesPath;

  if odVideoFile.Execute and (odVideoFile.FileName <> '') and
    tfile.Exists(odVideoFile.FileName) and
    (TPath.GetExtension(odVideoFile.FileName).ToLower = '.mp4') then
  begin
    Project := TVICUProject.Create;
    Project.SourceVideoFilePath := odVideoFile.FileName;
    CurrentProject := Project;
  end;
end;

procedure TfrmMain.actProjectOpenExecute(Sender: TObject);
var
  Project: TVICUProject;
begin
  if assigned(CurrentProject) then
    actProjectCloseExecute(Sender);

  if odVICUProject.InitialDir.IsEmpty then
    odVICUProject.InitialDir := TPath.GetMoviesPath;

  if odVICUProject.Execute and (odVICUProject.FileName <> '') and
    tfile.Exists(odVICUProject.FileName) and
    (TPath.GetExtension(odVICUProject.FileName).ToLower = '.vicu') then
  begin
    Project := TVICUProject.Create(odVICUProject.FileName);
    if tfile.Exists(Project.SourceVideoFilePath) then
      CurrentProject := Project
    else
      TDialogService.ShowMessage
        ('Can''t find the video source file. Please select it.',
        procedure(const AModalResult: TModalResult)
        var
          fld: string;
        begin
          fld := TPath.GetDirectoryName(Project.SourceVideoFilePath);
          if odVideoFile.InitialDir.IsEmpty then
            if (not fld.IsEmpty) and TDirectory.Exists(fld) then
              odVideoFile.InitialDir := fld
            else
              odVideoFile.InitialDir := TPath.GetMoviesPath;

          if odVideoFile.Execute and (odVideoFile.FileName <> '') and
            tfile.Exists(odVideoFile.FileName) and
            (TPath.GetExtension(odVideoFile.FileName).ToLower = '.mp4') then
          begin
            Project.SourceVideoFilePath := odVideoFile.FileName;
            CurrentProject := Project;
          end
          else
            Project.free;
        end);
  end;
end;

procedure TfrmMain.actProjectOptionsExecute(Sender: TObject);
begin
  // TODO : à compléter
end;

procedure TfrmMain.actProjectSaveExecute(Sender: TObject);
begin
  if not assigned(CurrentProject) then
    exit;

  if not CurrentProject.FilePath.IsEmpty then
    CurrentProject.SaveToFile
  else
  begin
    if svVICUProject.InitialDir.IsEmpty then
      svVICUProject.InitialDir := TPath.GetMoviesPath;

    if svVICUProject.Execute and (svVICUProject.FileName <> '') then
      CurrentProject.SaveToFile(svVICUProject.FileName);
  end;
end;

procedure TfrmMain.actQuitExecute(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.btnGotoEndClick(Sender: TObject);
begin
  if MediaPlayer1.State = TMediaState.Playing then
    btnPlayPauseClick(Sender);
  MediaPlayer1.CurrentTime := MediaPlayer1.Duration;
  // if not(MediaPlayer1.State = TMediaState.Playing) then
  // begin
  // MediaPlayer1.Play;
  // MediaPlayer1.Stop;
  // end;
end;

procedure TfrmMain.btnGotoStartClick(Sender: TObject);
begin
  if MediaPlayer1.State = TMediaState.Playing then
    btnPlayPauseClick(Sender);
  MediaPlayer1.CurrentTime := 0;
  // if not(MediaPlayer1.State = TMediaState.Playing) then
  // begin
  // MediaPlayer1.Play;
  // MediaPlayer1.Stop;
  // end;
end;

procedure TfrmMain.btnNextFrameClick(Sender: TObject);
var
  FrameDuration: int64; // we suppose the video is in 30 FPS
begin
  FrameDuration := round((1 / 30) * mediatimescale);
  if MediaPlayer1.CurrentTime + FrameDuration > MediaPlayer1.Duration then
    MediaPlayer1.CurrentTime := MediaPlayer1.Duration
  else
    MediaPlayer1.CurrentTime := MediaPlayer1.CurrentTime + FrameDuration;
  // if not(MediaPlayer1.State = TMediaState.Playing) then
  // begin
  // MediaPlayer1.Play;
  // MediaPlayer1.Stop;
  // end;
end;

procedure TfrmMain.btnNextSecondeClick(Sender: TObject);
begin
  if MediaPlayer1.CurrentTime + mediatimescale > MediaPlayer1.Duration then
    MediaPlayer1.CurrentTime := MediaPlayer1.Duration
  else
    MediaPlayer1.CurrentTime := MediaPlayer1.CurrentTime + mediatimescale;
  // if not(MediaPlayer1.State = TMediaState.Playing) then
  // begin
  // MediaPlayer1.Play;
  // MediaPlayer1.Stop;
  // end;
end;

procedure TfrmMain.btnPlayPauseClick(Sender: TObject);
begin
  if MediaPlayer1.State = TMediaState.Playing then
  begin
    MediaPlayer1.Stop;
    pPause.Visible := false;
  end
  else
  begin
    MediaPlayer1.Play;
    pPause.Visible := true;
  end;
  pPlay.Visible := not pPause.Visible;
end;

procedure TfrmMain.btnPrevFrameClick(Sender: TObject);
var
  FrameDuration: int64; // we suppose the video is in 30 FPS
begin
  FrameDuration := round((1 / 30) * mediatimescale);
  if MediaPlayer1.CurrentTime < FrameDuration then
    MediaPlayer1.CurrentTime := 0
  else
    MediaPlayer1.CurrentTime := MediaPlayer1.CurrentTime - FrameDuration;
  // if not(MediaPlayer1.State = TMediaState.Playing) then
  // begin
  // MediaPlayer1.Play;
  // MediaPlayer1.Stop;
  // end;
end;

procedure TfrmMain.btnPrevSecondeClick(Sender: TObject);
begin
  if MediaPlayer1.CurrentTime < mediatimescale then
    MediaPlayer1.CurrentTime := 0
  else
    MediaPlayer1.CurrentTime := MediaPlayer1.CurrentTime - mediatimescale;
  // if not(MediaPlayer1.State = TMediaState.Playing) then
  // begin
  // MediaPlayer1.Play;
  // MediaPlayer1.Stop;
  // end;
end;

procedure TfrmMain.CheckVideoPositionTimerTimer(Sender: TObject);
begin
  if assigned(CurrentProject) and (MediaPlayer1.State = TMediaState.Playing)
  then
  begin
    if (MediaPlayer1.CurrentTime >= MediaPlayer1.Duration) then
    begin
      btnPlayPauseClick(Sender);
      MediaPlayer1.CurrentTime := MediaPlayer1.Duration;
    end;
    // TODO : modifier position trackbar
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if assigned(CurrentProject) then
  begin
    actProjectCloseExecute(Sender);
    CanClose := not assigned(CurrentProject);
  end
  else
    CanClose := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  SubscribeToProjectChangedMessage;
  CurrentProject := nil;

  InitMainFormCaption;
  InitAboutDialogDescriptionAndLicense;
  InitMainMenuForMacOS;
end;

procedure TfrmMain.InitAboutDialogDescriptionAndLicense;
begin
  OlfAboutDialog1.Licence.Text :=
    'This program is distributed as shareware. If you use it (especially for ' +
    'commercial or income-generating purposes), please remember the author and '
    + 'contribute to its development by purchasing a license.' + slinebreak +
    slinebreak +
    'This software is supplied as is, with or without bugs. No warranty is offered '
    + 'as to its operation or the data processed. Make backups!';
  OlfAboutDialog1.Description.Text :=
    'Video Cutter allows its users to define part of a video and choose if they '
    + 'want to remove them from final video. The program is a GUI over FFmpeg '
    + 'command line interface.' + slinebreak + slinebreak + '*****************'
    + slinebreak + '* Publisher info' + slinebreak + slinebreak +
    'This application was developed by Patrick Prémartin.' + slinebreak +
    slinebreak +
    'It is published by OLF SOFTWARE, a company registered in Paris (France) under the reference 439521725.'
    + slinebreak + slinebreak + '****************' + slinebreak +
    '* Personal data' + slinebreak + slinebreak +
    'This program is autonomous in its current version. It does not depend on the Internet and communicates nothing to the outside world.'
    + slinebreak + slinebreak + 'We have no knowledge of what you do with it.' +
    slinebreak + slinebreak +
    'No information about you is transmitted to us or to any third party.' +
    slinebreak + slinebreak +
    'We use no cookies, no tracking, no stats on your use of the application.' +
    slinebreak + slinebreak + '**********************' + slinebreak +
    '* User support' + slinebreak + slinebreak +
    'If you have any questions or require additional functionality, please leave us a message on the application''s website or on its code repository.'
    + slinebreak + slinebreak + 'To find out more, visit ' +
    OlfAboutDialog1.URL;
end;

procedure TfrmMain.InitMainFormCaption;
begin
{$IFDEF DEBUG}
  caption := '[DEBUG] ';
{$ELSE}
  caption := '';
{$ENDIF}
  if assigned(CurrentProject) then
  begin
    caption := caption + CurrentProject.FileName + ' ';
    if CurrentProject.HasChanged then
      caption := caption + '(*) ';
    caption := caption + ' - ';
  end;

  caption := caption + OlfAboutDialog1.Titre + ' v' +
    OlfAboutDialog1.VersionNumero;
end;

procedure TfrmMain.InitMainMenuForMacOS;
begin
{$IFDEF MACOS}
  mnuMacOS.Visible := true;
  actQuit.shortcut := scCommand + ord('Q'); // 4177;
  mnuHelpAbout.Parent := mnuMacOS;
  mnuHelp.Visible := (mnuHelp.Children[0].ChildrenCount > 0);
  mnuToolsOptions.Parent := mnuMacOS;
  mnuTools.Visible := (mnuTools.Children[0].ChildrenCount > 0);
{$ELSE}
  mnuMacOS.Visible := false;
{$ENDIF}
  actAbout.Text := '&About ' + OlfAboutDialog1.Titre;
  btnAbout.Text := '&About';
end;

procedure TfrmMain.OlfAboutDialog1URLClick(const AURL: string);
begin
  url_Open_In_Browser(AURL);
end;

procedure TfrmMain.SetCurrentProject(const Value: TVICUProject);
begin
  FCurrentProject := Value;

  if not assigned(FCurrentProject) then
  begin
    lProject.Visible := false;
    CheckVideoPositionTimer.Enabled := false;
    TMessageManager.DefaultManager.SendMessage(self,
      TVICUProjectHasChangedMessage.Create(FCurrentProject));
  end
  else
  begin
    MediaPlayer1.FileName := FCurrentProject.SourceVideoFilePath;
    MediaPlayer1.Play;
    tthread.CreateAnonymousThread(
      procedure
      var
        i: integer;
        ok: Boolean;
      begin
        i := 0;
        ok := false;
        repeat
          sleep(100);
          tthread.Synchronize(nil,
            procedure
            begin
              if (MediaPlayer1.Duration > 0) then
              begin
                MediaPlayer1.Stop;
                MediaPlayer1.CurrentTime := 0;
                ok := true;
              end;
            end);
          inc(i);
        until tthread.CheckTerminated or ok or (i > 600); // Wait 1 minute max
        if not ok then
          tthread.queue(nil,
            procedure
            begin // the video can't be read by TMediaPlayer
              CurrentProject.free;
              CurrentProject := nil;
            end)
        else
          tthread.queue(nil,
            procedure
            begin
              lProject.Visible := true;
              pPause.Visible := false;
              pPlay.Visible := true;

              CheckVideoPositionTimer.interval := round((1 / 30) * 1000);
              // 30 FPS
              CheckVideoPositionTimer.Enabled := true;

              // TODO : adapter la taille de la trackbar à la durée du fichier
              // TODO : afficher la liste des marqueurs
              // TODO : afficher les tranches (à couper ou conserver)
              TMessageManager.DefaultManager.SendMessage(self,
                TVICUProjectHasChangedMessage.Create(FCurrentProject));
            end);
      end).start;
  end;

end;

procedure TfrmMain.SubscribeToProjectChangedMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage
    (TVICUProjectHasChangedMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TVICUProjectHasChangedMessage;
    begin
      if M is TVICUProjectHasChangedMessage then
        msg := M as TVICUProjectHasChangedMessage;
      if msg.Value = CurrentProject then
        InitMainFormCaption;

      if assigned(CurrentProject) then
        lblSourceFile.Text := TPath.GetFileName
          (CurrentProject.SourceVideoFilePath)
      else
        lblSourceFile.Text := '';

      actProjectSave.Enabled := assigned(CurrentProject);
      actProjectOptions.Enabled := assigned(CurrentProject);
      actProjectClose.Enabled := assigned(CurrentProject);

      mnuProject.Enabled := assigned(CurrentProject);

      btnProjectOpen.Visible := not assigned(CurrentProject);
      btnProjectNew.Visible := btnProjectOpen.Visible;
      btnProjectClose.Visible := not btnProjectOpen.Visible;
      btnProjectOptions.Visible := not btnProjectOpen.Visible;

      lblStatus.Text := '';

      // Since no available options for the project, we hide the menu items and buttons
      btnProjectOptions.Visible := false;
      mnuProject.Visible := false;
    end);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
TDialogService.PreferredMode := TDialogService.TPreferredMode.Sync;

end.
