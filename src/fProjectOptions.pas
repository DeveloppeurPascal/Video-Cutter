(* C2PP
  ***************************************************************************

  Video Cutter

  Copyright 2024-2025 Patrick PREMARTIN under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://videocutter.olfsoftware.fr

  Project site :
  https://github.com/DeveloppeurPascal/Video-Cutter

  ***************************************************************************
  File last update : 2025-10-16T10:43:11.772+02:00
  Signature : 621c6d91491bfdd66369ecbaebc91f50ad4e851a
  ***************************************************************************
*)

unit fProjectOptions;

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
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Controls.Presentation,
  uProjectVICU;

type
  TfrmProjectOptions = class(TForm)
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout1: TGridPanelLayout;
    btnSaveAndClose: TButton;
    btnCancel: TButton;
    lblFPS: TLabel;
    edtFPS: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveAndCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FCurrentProject: TVICUProject;
    procedure SaveConfig;
    procedure InitConfigFields;
    function HasChanged: Boolean;
    procedure SetCurrentProject(const Value: TVICUProject);
  public
    property CurrentProject: TVICUProject read FCurrentProject
      write SetCurrentProject;
    constructor Create(const AOwner: TComponent;
      const ACurrentProject: TVICUProject);
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  System.IOUtils,
  u_urlOpen,
  uconfig;

procedure TfrmProjectOptions.btnCancelClick(Sender: TObject);
begin
  InitConfigFields;
  close;
end;

procedure TfrmProjectOptions.btnSaveAndCloseClick(Sender: TObject);
begin
  SaveConfig;
  close;
end;

constructor TfrmProjectOptions.Create(const AOwner: TComponent;
  const ACurrentProject: TVICUProject);
begin
  inherited Create(AOwner);
  CurrentProject := ACurrentProject;
end;

procedure TfrmProjectOptions.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if HasChanged then
  begin
    CanClose := false;
    TDialogService.MessageDialog
      ('Do you want to save your changes before closing ?',
      tmsgdlgtype.mtConfirmation, mbyesno, tmsgdlgbtn.mbYes, 0,
      procedure(const AModalResult: TModalResult)
      begin
        case AModalResult of
          mryes:
            tthread.forcequeue(nil,
              procedure
              begin
                btnSaveAndCloseClick(Sender);
              end);
        else
          tthread.forcequeue(nil,
            procedure
            begin
              btnCancelClick(Sender);
            end);
        end;
      end);
  end
  else
    CanClose := true;
end;

procedure TfrmProjectOptions.FormCreate(Sender: TObject);
begin
  InitConfigFields;
end;

function TfrmProjectOptions.HasChanged: Boolean;
var
  i: integer;
  e: TEdit;
begin
  result := false;
  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TEdit then
    begin
      e := VertScrollBox1.Content.Children[i] as TEdit;
      result := e.TagString <> e.Text;
      if result then
        break;
    end;
end;

procedure TfrmProjectOptions.InitConfigFields;
var
  i: integer;
  e: TEdit;
begin
  edtFPS.TagString := CurrentProject.VideoFPS.ToString;

  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TEdit then
    begin
      e := VertScrollBox1.Content.Children[i] as TEdit;
      e.Text := e.TagString;
    end;
end;

procedure TfrmProjectOptions.SaveConfig;
begin
  CurrentProject.VideoFPS := edtFPS.Text.ToInteger;
  if CurrentProject.VideoFPS = tconfig.DefaultVideoFPS then
    CurrentProject.HasChanged := true;

  InitConfigFields;
end;

procedure TfrmProjectOptions.SetCurrentProject(const Value: TVICUProject);
begin
  if not assigned(Value) then
    raise Exception.Create('Project needed !');

  FCurrentProject := Value;
end;

end.
