unit uProjectVICU;

interface

uses
{$IF defined(FRAMEWORK_FMX)}
  FMX.Media,
{$ENDIF}
  System.Messaging,
  System.Classes,
  System.Generics.Collections;

const
  CProjectFileVersion = 20240704;

type
{$IF defined(FRAMEWORK_VCL)}
  TMediaTime = longint;
{$ENDIF}
  TVICUProject = class;

  TVICUProjectHasChangedMessage = class(TMessage<TVICUProject>)
  end;

  TMark = class
  private const
    CVersion = 1;

  var
    FProject: TVICUProject;
    FTime: TMediaTime;
    procedure SetTime(const Value: TMediaTime);
  protected
  public
    property Time: TMediaTime read FTime write SetTime;
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    constructor Create(const AProject: TVICUProject);
    destructor Destroy; override;
  end;

  TMarkList = class(TObjectList<TMark>)
  private const
    CVersion = 1;

  var
    FProject: TVICUProject;
  protected
  public
    function GetNextMark(const ATime: TMediaTime): TMark;
    function GetPreviousMark(const ATime: TMediaTime): TMark;
    function GetMark(const ATime: TMediaTime;
      const CreateIfNotExists: boolean = false): TMark;
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    constructor Create(const AProject: TVICUProject);
    destructor Destroy; override;
  end;

  TVideoPart = class
  private const
    CVersion = 1;

  var
    FProject: TVICUProject;
    FEndMark: TMark;
    FStartMark: TMark;
    FIsCut: boolean;
    procedure SetEndMark(const Value: TMark);
    procedure SetIsCut(const Value: boolean);
    procedure SetStartMark(const Value: TMark);
  protected
  public
    property StartMark: TMark read FStartMark write SetStartMark;
    property EndMark: TMark read FEndMark write SetEndMark;
    property IsCut: boolean read FIsCut write SetIsCut;
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    constructor Create(const AProject: TVICUProject);
    destructor Destroy; override;
  end;

  TVideoPartList = class(TObjectList<TVideoPart>)
  private const
    CVersion = 1;

  var
    FProject: TVICUProject;
  protected
  public
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    constructor Create(const AProject: TVICUProject);
    destructor Destroy; override;
  end;

  TVICUProject = class
  private const
    CVersion = 1;
    function GetFileName: string;

  var
    FHasChanged: boolean;
    FIsLoading: boolean;
    FFilePath: string;
    FSourceVideoFilePath: string;
    FExportedVideoFilePath: string;
    procedure SetExportedVideoFilePath(const Value: string);
    procedure SetHasChanged(const Value: boolean);
    procedure SetSourceVideoFilePath(const Value: string);
  protected
  public
    property HasChanged: boolean read FHasChanged write SetHasChanged;
    property FilePath: string read FFilePath;
    property FileName: string read GetFileName;
    property SourceVideoFilePath: string read FSourceVideoFilePath
      write SetSourceVideoFilePath;
    property ExportedVideoFilePath: string read FExportedVideoFilePath
      write SetExportedVideoFilePath;
    procedure LoadFromFile(const AFilePath: string = '');
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToFile(const AFilePath: string = '');
    constructor Create; overload;
    constructor Create(const AFilePath: string); overload;
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUTils,
  System.SysUtils;

{ TMark }

constructor TMark.Create(const AProject: TVICUProject);
begin
  // TODO : à compléter
end;

destructor TMark.Destroy;
begin
  // TODO : à compléter
  inherited;
end;

procedure TMark.LoadFromStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TMark.SaveToStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TMark.SetTime(const Value: TMediaTime);
begin
  FTime := Value;
  // TODO : à compléter
end;

{ TMarkList }

constructor TMarkList.Create(const AProject: TVICUProject);
begin
  // TODO : à compléter
end;

destructor TMarkList.Destroy;
begin
  // TODO : à compléter
  inherited;
end;

function TMarkList.GetMark(const ATime: TMediaTime;
  const CreateIfNotExists: boolean): TMark;
begin
  // TODO : à compléter
end;

function TMarkList.GetNextMark(const ATime: TMediaTime): TMark;
begin
  // TODO : à compléter
end;

function TMarkList.GetPreviousMark(const ATime: TMediaTime): TMark;
begin
  // TODO : à compléter
end;

procedure TMarkList.LoadFromStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TMarkList.SaveToStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

{ TVideoPart }

constructor TVideoPart.Create(const AProject: TVICUProject);
begin
  // TODO : à compléter
end;

destructor TVideoPart.Destroy;
begin

  inherited; // TODO : à compléter
end;

procedure TVideoPart.LoadFromStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TVideoPart.SaveToStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TVideoPart.SetEndMark(const Value: TMark);
begin
  FEndMark := Value; // TODO : à compléter
end;

procedure TVideoPart.SetIsCut(const Value: boolean);
begin
  FIsCut := Value; // TODO : à compléter
end;

procedure TVideoPart.SetStartMark(const Value: TMark);
begin
  FStartMark := Value;
end; // TODO : à compléter

{ TVideoPartList }

constructor TVideoPartList.Create(const AProject: TVICUProject);
begin
  // TODO : à compléter
end;

destructor TVideoPartList.Destroy;
begin
  // TODO : à compléter
  inherited;
end;

procedure TVideoPartList.LoadFromStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TVideoPartList.SaveToStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

{ TVICUProject }

constructor TVICUProject.Create;
begin
  inherited;
  FHasChanged := false;
  FIsLoading := false;
  FFilePath := '';
  FSourceVideoFilePath := '';
  FExportedVideoFilePath := '';
end;

constructor TVICUProject.Create(const AFilePath: string);
begin
  Create;
  LoadFromFile(AFilePath);
end;

destructor TVICUProject.Destroy;
begin
  // TODO : à compléter
  inherited;
end;

function TVICUProject.GetFileName: string;
begin
  if FFilePath.isempty then
    result := 'noname'
  else
    result := tpath.GetFileNameWithoutExtension(FFilePath);
end;

procedure TVICUProject.LoadFromFile(const AFilePath: string);
begin
  // TODO : à compléter
end;

procedure TVICUProject.LoadFromStream(const AStream: TStream);
begin
  FIsLoading := true;
  try
    // TODO : à compléter
  finally
    FIsLoading := false;
  end;
  HasChanged := false;
end;

procedure TVICUProject.SaveToFile(const AFilePath: string);
begin
  // TODO : à compléter
end;

procedure TVICUProject.SaveToStream(const AStream: TStream);
begin
  // TODO : à compléter
end;

procedure TVICUProject.SetExportedVideoFilePath(const Value: string);
begin
  if FExportedVideoFilePath <> Value then
  begin
    FExportedVideoFilePath := Value;
    HasChanged := true;
  end;
end;

procedure TVICUProject.SetHasChanged(const Value: boolean);
begin
  if (FHasChanged <> Value) then
  begin
    FHasChanged := Value;

    if FIsLoading then
      exit;

    tthread.ForceQueue(nil,
      procedure
      begin
        TMessageManager.DefaultManager.SendMessage(self,
          TVICUProjectHasChangedMessage.Create(self));
      end);
  end;
end;

procedure TVICUProject.SetSourceVideoFilePath(const Value: string);
begin
  if FSourceVideoFilePath <> Value then
  begin
    FSourceVideoFilePath := Value;
    HasChanged := true;
  end;
end;

end.
