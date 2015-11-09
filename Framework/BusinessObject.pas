unit BusinessObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  BOData;

type
  TBusinessObject = class(TComponent)
  private
    { Private declarations }
    FLongDescription: string;
    FShortDescription: string;
    FDataObject: TBOData;
    FKey: Integer;
    FWorkerData: TBOData;
    function GetWorkerData: TBOData;
  protected
    { Protected declarations }
    function DbNum(const Value: Double): string;
    procedure SetKey(const Value: Integer); virtual;
    procedure SetDataObject(const Value: TBOData); virtual;
  public
    { Public declarations }
    function FieldByName(const FieldName: string): TBODataField;
    property Key: Integer read FKey write SetKey; 
  published
    { Published declarations }
    property DataObject: TBOData read FDataObject write SetDataObject;
    property WorkerData: TBOData read GetWorkerData write FWorkerData;
    property ShortDescription: string read FShortDescription write FShortDescription;
    property LongDescription: string read FLongDescription write FLongDescription;
  end;

implementation

{ TBusinessObject }

uses
  ToolbarControl;

function TBusinessObject.DbNum(const Value: Double): string;
begin
  // Firebird requires a nums to have . seperator for floats/numeric
  Result := StringReplace(Format('%f', [Value]), ',', '.', [rfReplaceAll]);
end;

function TBusinessObject.FieldByName(const FieldName: string): TBODataField;
begin
  if Assigned(DataObject) then
    Result := DataObject.Fields.FieldByName(FieldName)
  else
    raise Exception.Create('Field not found ' + FieldName);
end;

function TBusinessObject.GetWorkerData: TBOData;
begin
  Result := nil;
  if not (csDesigning in ComponentState) then
  begin
    if Assigned(ActionDecoupler) then
    begin
      FWorkerData := ActionDecoupler.GetWorkerData;
      Result := FWorkerData;
    end else
      Result := nil;
  end;
end;

procedure TBusinessObject.SetDataObject(const Value: TBOData);
begin
  FDataObject := Value;
end;

procedure TBusinessObject.SetKey(const Value: Integer);
begin
  FKey := Value;

  if not Assigned(DataObject) then
    raise Exception.Create('DataObject is not assigned in ' + Self.Name);

  DataObject.Open(DataObject.KeyField + ' = ' + IntToStr(Value));
end;

end.
