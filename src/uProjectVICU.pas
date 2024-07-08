unit uProjectVICU;

interface

uses
  System.Messaging,
  System.Classes,
  System.Generics.Collections;

const
  CProjectFileVersion = 20240708;

type
  TVICUProject = class;

  TVICUProjectHasChangedMessage = class(TMessage<TVICUProject>)
  end;

  TMark = class
  private const
    CVersion = 1;

  var
    FProject: TVICUProject;
    FTime: int64;
    procedure SetTime(const Value: int64);
  protected
  public
    property Time: int64 read FTime write SetTime;
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
    function GetNextMark(const ATime: int64): TMark;
    function GetPreviousMark(const ATime: int64): TMark;
    function GetMark(const ATime: int64;
      const CreateIfNotExists: boolean = false): TMark;
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    constructor Create(const AProject: TVICUProject);
    destructor Destroy; override;
    function Add(const Value: TMark): Integer; inline;
    procedure Delete(Index: Integer); inline;
    function Remove(const Value: TMark): Integer; inline;
    procedure Clear; inline;
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
    function Add(const Value: TVideoPart): Integer; inline;
    procedure Delete(Index: Integer); inline;
    function Remove(const Value: TVideoPart): Integer; inline;
    procedure Clear; inline;
  end;

  TVICUProject = class
  private const
    CVersion = 1;

  var
    FHasChanged: boolean;
    FIsLoading: boolean;
    FFilePath: string;
    FSourceVideoFilePath: string;
    FExportedVideoFilePath: string;
    FVideoParts: TVideoPartList;
    FMarks: TMarkList;
    function GetFileName: string;
    procedure SetMarks(const Value: TMarkList);
    procedure SetVideoParts(const Value: TVideoPartList);
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
    property VideoParts: TVideoPartList read FVideoParts write SetVideoParts;
    property Marks: TMarkList read FMarks write SetMarks;
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
  System.IOUtils,
  System.SysUtils,
  Olf.RTL.Streams;

{ TMark }

constructor TMark.Create(const AProject: TVICUProject);
begin
  inherited Create;
  FProject := AProject;
  FTime := 0;
end;

destructor TMark.Destroy;
begin
  inherited;
end;

procedure TMark.LoadFromStream(const AStream: TStream);
var
  Version: byte;
begin
  if (AStream.Read(Version, sizeof(Version)) <> sizeof(Version)) then
    raise exception.Create('Wrong file format (undefined mark record).');

  if (Version > CVersion) then
    raise exception.Create
      ('This project file is too recent. Please upgrade this program if you wish to load it.');

  if (AStream.Read(FTime, sizeof(FTime)) <> sizeof(FTime)) then
    raise exception.Create('Wrong file format (undefined Mark Time).');
end;

procedure TMark.SaveToStream(const AStream: TStream);
var
  Version: byte;
begin
  Version := CVersion;
  AStream.Write(Version, sizeof(Version));
  AStream.Write(FTime, sizeof(FTime));
end;

procedure TMark.SetTime(const Value: int64);
begin
  if FTime <> Value then
  begin
    FTime := Value;
    if assigned(FProject) then
      FProject.HasChanged := true;
  end;
end;

{ TMarkList }

function TMarkList.Add(const Value: TMark): Integer;
begin
  result := inherited Add(Value);
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

procedure TMarkList.Clear;
begin
  inherited Clear;
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

constructor TMarkList.Create(const AProject: TVICUProject);
begin
  inherited Create;
  FProject := AProject;
end;

procedure TMarkList.Delete(Index: Integer);
begin
  inherited Delete(index);
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

destructor TMarkList.Destroy;
begin
  inherited;
end;

function TMarkList.GetMark(const ATime: int64;
  const CreateIfNotExists: boolean): TMark;
var
  Mark: TMark;
begin
  result := nil;
  for Mark in self do
    if Mark.Time = ATime then
    begin
      result := Mark;
      break;
    end;
  if (not assigned(result)) and CreateIfNotExists then
  begin
    Mark := TMark.Create(FProject);
    Mark.FTime := ATime;
    Add(Mark);
  end;
end;

function TMarkList.GetNextMark(const ATime: int64): TMark;
var
  Mark: TMark;
begin
  result := nil;
  for Mark in self do
    if (Mark.Time > ATime) and ((assigned(result) and (result.FTime > Mark.Time)
      ) or (not assigned(result))) then
      result := Mark;
end;

function TMarkList.GetPreviousMark(const ATime: int64): TMark;
var
  Mark: TMark;
begin
  result := nil;
  for Mark in self do
    if (Mark.Time < ATime) and ((assigned(result) and (result.FTime < Mark.Time)
      ) or (not assigned(result))) then
      result := Mark;
end;

procedure TMarkList.LoadFromStream(const AStream: TStream);
var
  Version: byte;
  I, Nb: int64;
  Mark: TMark;
begin
  if (AStream.Read(Version, sizeof(Version)) <> sizeof(Version)) then
    raise exception.Create('Wrong file format (undefined mark record).');

  if (Version > CVersion) then
    raise exception.Create
      ('This project file is too recent. Please upgrade this program if you wish to load it.');

  if (AStream.Read(Nb, sizeof(Nb)) <> sizeof(Nb)) then
    raise exception.Create('Wrong file format (no mark list).');

  for I := 1 to Nb do
  begin
    Mark := TMark.Create(FProject);
    Mark.LoadFromStream(AStream);
    Add(Mark);
  end;
end;

function TMarkList.Remove(const Value: TMark): Integer;
begin
  result := inherited Remove(Value);
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

procedure TMarkList.SaveToStream(const AStream: TStream);
var
  Version: byte;
  Nb: int64;
  Mark: TMark;
begin
  Version := CVersion;
  AStream.Write(Version, sizeof(Version));
  Nb := count;
  AStream.Write(Nb, sizeof(Nb));
  for Mark in self do
    Mark.SaveToStream(AStream);
end;

{ TVideoPart }

constructor TVideoPart.Create(const AProject: TVICUProject);
begin
  inherited Create;
  FProject := AProject;
  FEndMark := nil;
  FStartMark := nil;
  FIsCut := false;
end;

destructor TVideoPart.Destroy;
begin
  inherited;
end;

procedure TVideoPart.LoadFromStream(const AStream: TStream);
var
  Version: byte;
  Time: int64;
begin
  if not assigned(FProject) then
    raise exception.Create('Did you lost the project ?');

  if (AStream.Read(Version, sizeof(Version)) <> sizeof(Version)) then
    raise exception.Create('Wrong file format (undefined video part record).');

  if (Version > CVersion) then
    raise exception.Create
      ('This project file is too recent. Please upgrade this program if you wish to load it.');

  if (AStream.Read(Time, sizeof(Time)) <> sizeof(Time)) then
    raise exception.Create('Wrong file format (undefined start time).');
  FStartMark := FProject.Marks.GetMark(Time, true);

  if (AStream.Read(Time, sizeof(Time)) <> sizeof(Time)) then
    raise exception.Create('Wrong file format (undefined end time).');
  FEndMark := FProject.Marks.GetMark(Time, true);

  if (AStream.Read(FIsCut, sizeof(FIsCut)) <> sizeof(FIsCut)) then
    raise exception.Create('Wrong file format (undefined cut status).');
end;

procedure TVideoPart.SaveToStream(const AStream: TStream);
var
  Version: byte;
begin
  Version := CVersion;
  AStream.Write(Version, sizeof(Version));
  AStream.Write(FStartMark.Time, sizeof(FStartMark.Time));
  AStream.Write(FEndMark.Time, sizeof(FEndMark.Time));
  AStream.Write(FIsCut, sizeof(FIsCut));
end;

procedure TVideoPart.SetEndMark(const Value: TMark);
begin
  if FEndMark <> Value then
  begin
    FEndMark := Value;
    if assigned(FProject) then
      FProject.HasChanged := true;
  end;
end;

procedure TVideoPart.SetIsCut(const Value: boolean);
begin
  if FIsCut <> Value then
  begin
    FIsCut := Value;
    if assigned(FProject) then
      FProject.HasChanged := true;
  end;
end;

procedure TVideoPart.SetStartMark(const Value: TMark);
begin
  if FStartMark <> Value then
  begin
    FStartMark := Value;
    if assigned(FProject) then
      FProject.HasChanged := true;
  end;
end;

{ TVideoPartList }

function TVideoPartList.Add(const Value: TVideoPart): Integer;
begin
  result := inherited Add(Value);
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

procedure TVideoPartList.Clear;
begin
  inherited Clear;
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

constructor TVideoPartList.Create(const AProject: TVICUProject);
begin
  inherited Create;
  FProject := AProject;
end;

procedure TVideoPartList.Delete(Index: Integer);
begin
  inherited Delete(index);
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

destructor TVideoPartList.Destroy;
begin
  inherited;
end;

procedure TVideoPartList.LoadFromStream(const AStream: TStream);
var
  Version: byte;
  I, Nb: int64;
  VideoPart: TVideoPart;
begin
  if (AStream.Read(Version, sizeof(Version)) <> sizeof(Version)) then
    raise exception.Create('Wrong file format (undefined mark record).');

  if (Version > CVersion) then
    raise exception.Create
      ('This project file is too recent. Please upgrade this program if you wish to load it.');

  if (AStream.Read(Nb, sizeof(Nb)) <> sizeof(Nb)) then
    raise exception.Create('Wrong file format (no mark list).');

  for I := 1 to Nb do
  begin
    VideoPart := TVideoPart.Create(FProject);
    VideoPart.LoadFromStream(AStream);
    Add(VideoPart);
  end;
end;

function TVideoPartList.Remove(const Value: TVideoPart): Integer;
begin
  result := inherited Remove(Value);
  if assigned(FProject) then
    FProject.HasChanged := true;
end;

procedure TVideoPartList.SaveToStream(const AStream: TStream);
var
  Version: byte;
  Nb: int64;
  VideoPart: TVideoPart;
begin
  Version := CVersion;
  AStream.Write(Version, sizeof(Version));
  Nb := count;
  AStream.Write(Nb, sizeof(Nb));
  for VideoPart in self do
    VideoPart.SaveToStream(AStream);
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
  FVideoParts := TVideoPartList.Create(self);
  FMarks := TMarkList.Create(self);
end;

constructor TVICUProject.Create(const AFilePath: string);
begin
  Create;
  LoadFromFile(AFilePath);
end;

destructor TVICUProject.Destroy;
begin
  FVideoParts.free;
  FMarks.free;
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
var
  FilePath: string;
  fs: TFileStream;
begin
  if AFilePath.isempty then
    FilePath := FFilePath
  else
    FilePath := AFilePath;

  if FilePath.isempty then
    raise exception.Create('No filename, what do you want to load ?');

  if not tfile.Exists(FilePath) then
    raise exception.Create('This file doesn''t exist !');

  fs := TFileStream.Create(FilePath, fmOpenRead);
  try
    LoadFromStream(fs);
  finally
    fs.free;
  end;
end;

procedure TVICUProject.LoadFromStream(const AStream: TStream);
var
  ProjectVersion: uint64;
  Version: byte;
begin
  FIsLoading := true;
  try
    if (AStream.Read(ProjectVersion, sizeof(ProjectVersion)) <>
      sizeof(ProjectVersion)) then
      raise exception.Create('Wrong file format.');

    if (ProjectVersion > CProjectFileVersion) then
      raise exception.Create
        ('This project file is too recent. Please upgrade this program if you wish to load it.');

    if (AStream.Read(Version, sizeof(Version)) <> sizeof(Version)) then
      raise exception.Create('Wrong file format (undefined project record).');

    if (Version > CVersion) then
      raise exception.Create
        ('This project file is too recent. Please upgrade this program if you wish to load it.');

    FSourceVideoFilePath := LoadStringFromStream(AStream);
    FExportedVideoFilePath := LoadStringFromStream(AStream);
    FMarks.LoadFromStream(AStream);
    FVideoParts.LoadFromStream(AStream);
  finally
    FIsLoading := false;
  end;
  HasChanged := false;
end;

procedure TVICUProject.SaveToFile(const AFilePath: string);
var
  FilePath: string;
  fs: TFileStream;
begin
  if AFilePath.isempty then
    FilePath := FFilePath
  else
    FilePath := AFilePath;

  if FilePath.isempty then
    raise exception.Create
      ('No filename, where do you want to save your project ?');

  fs := TFileStream.Create(FilePath, fmOpenWrite + fmCreate);
  try
    SaveToStream(fs);
  finally
    fs.free;
  end;
end;

procedure TVICUProject.SaveToStream(const AStream: TStream);
var
  ProjectVersion: uint64;
  Version: byte;
begin
  ProjectVersion := CProjectFileVersion;
  AStream.Write(ProjectVersion, sizeof(ProjectVersion));
  Version := CVersion;
  AStream.Write(Version, sizeof(Version));
  SaveStringToStream(FSourceVideoFilePath, AStream);
  SaveStringToStream(FExportedVideoFilePath, AStream);
  FMarks.SaveToStream(AStream);
  FVideoParts.SaveToStream(AStream);
  HasChanged := false;
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

procedure TVICUProject.SetMarks(const Value: TMarkList);
begin
  FMarks := Value;
end;

procedure TVICUProject.SetSourceVideoFilePath(const Value: string);
begin
  if FSourceVideoFilePath <> Value then
  begin
    FSourceVideoFilePath := Value;
    HasChanged := true;
  end;
end;

procedure TVICUProject.SetVideoParts(const Value: TVideoPartList);
begin
  FVideoParts := Value;
end;

end.
