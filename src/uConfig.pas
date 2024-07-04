unit uConfig;

interface

type
  TConfig = class
  private
    class procedure SetFFmpegPath(const Value: string); static;
    class function GetFFmpegPath: string; static;
  protected
  public
    class property FFmpegPath: string read GetFFmpegPath write SetFFmpegPath;
    class procedure Save;
    class procedure Cancel;
    // TODO : add default "project folder"
    // TODO : add default "source video folder"
    // TODO : add default "export video folder"
  end;

implementation

uses
  System.Classes,
  System.Types,
  System.SysUtils,
  Olf.RTL.Params,
  Olf.RTL.CryptDecrypt;

procedure InitConfig;
begin
  tparams.InitDefaultFileNameV2('OlfSoftware', 'VideoCutter', false);
{$IFDEF RELEASE }
  tparams.onCryptProc := function(Const AParams: string): TStream
    var
      Keys: TByteDynArray;
      ParStream: TStringStream;
    begin
      ParStream := TStringStream.Create(AParams);
      try
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}
        result := TOlfCryptDecrypt.XORCrypt(ParStream, Keys);
      finally
        ParStream.free;
      end;
    end;
  tparams.onDecryptProc := function(Const AStream: TStream): string
    var
      Keys: TByteDynArray;
      Stream: TStream;
      StringStream: TStringStream;
    begin
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}
      result := '';
      Stream := TOlfCryptDecrypt.XORdeCrypt(AStream, Keys);
      try
        if assigned(Stream) and (Stream.Size > 0) then
        begin
          StringStream := TStringStream.Create;
          try
            Stream.Position := 0;
            StringStream.CopyFrom(Stream);
            result := StringStream.DataString;
          finally
            StringStream.free;
          end;
        end;
      finally
        Stream.free;
      end;
    end;
{$ENDIF}
  tparams.Load;
end;

{ TConfig }

class procedure TConfig.Cancel;
begin
  tparams.Cancel;
end;

class function TConfig.GetFFmpegPath: string;
begin
  result := tparams.getValue('FFmpeg', '');
end;

class procedure TConfig.Save;
begin
  tparams.Save;
end;

class procedure TConfig.SetFFmpegPath(const Value: string);
begin
  tparams.setValue('FFmpeg', Value);
end;

initialization

InitConfig;

finalization

end.
