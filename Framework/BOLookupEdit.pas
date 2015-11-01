unit BOLookupEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dxCntner, dxEditor, dxExEdtr, dxDBEdtr, dxDBELib, BOData, Db;

type
  TBOLookupEdit = class(TCustomdxLookupEdit)
  private
    { Private declarations }
    FDataObject: TBOData;
    FDataField: string;
    FDatasource: TDatasource;
    procedure SetDataField(const Value: string);
    procedure SetLookup;
    function GetKeyValue: Variant;
  protected
    { Protected declarations }
    procedure SetKeyValue(const Value: Variant); reintroduce;
    procedure ClearField; override;
    procedure DropDown; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;

    property KeyValue: Variant read GetKeyValue write SetKeyValue;
    property LookupMode;
    property LookupKeyValue;
  published
    { Published declarations }
    property DataField: string read FDataField write SetDataField;
    property DataObject: TBOData read FDataObject write FDataObject;

    property Anchors;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    // original
    property Alignment;
    property AutoSelect;
    property AutoSize;
    property ReadOnly;
    property StyleController;
    property OnChange;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnSelectionChange;
    property OnValidate;
    property OnCloseUp;
    // drop down
    property ButtonGlyph;
    property DropDownRows;
    property DropDownWidth;
    property ImmediateDropDown;
    property PopupAlignment;
    property PopupBorder;
    // lookup
    property ClearKey;
    property CanDeleteText;
    property Revertable;
  end;

  // Listsource, ListFieldName, KeyFieldName

procedure Register;

implementation

uses
  Variants;

procedure Register;
begin
  RegisterComponents('Craigs', [TBOLookupEdit]);
end;

{ TBOLookupEdit }

procedure TBOLookupEdit.ClearField;
begin
  inherited ClearField;
  KeyValue := 0;
end;

constructor TBOLookupEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDatasource := TDatasource.Create(Self);
  ListSource := FDatasource;
  ClearKey := 46;
end;

destructor TBOLookupEdit.Destroy;
begin
  ListSource := nil;
  ListFieldName := '';

  FDatasource.Free;
  inherited Destroy;
end;

procedure TBOLookupEdit.DropDown;
begin
  inherited;
  if Assigned(FDataObject) and Assigned(FDataObject.Fields.FieldByName(FDataField)) then
    if not FDataObject.Dataset.Active then
      Open;
end;

function TBOLookupEdit.GetKeyValue: Variant;
begin
  if LookupKeyValue = Null then
    Result := 0
  else
    Result := LookupKeyValue;
end;

procedure TBOLookupEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TBOLookupEdit.Open;
begin
  if Assigned(FDataObject) and Assigned(FDataObject.Fields.FieldByName(FDataField)) then
  begin
    try
      SetLookup;
      FDataObject.Fields.FieldByName(FDataField).Initialize;
      FDatasource.DataSet := FDataObject.Fields.FieldByName(FDataField).LookupDataset;
      FDatasource.DataSet.Open;
    except
      on E:Exception do
        ShowMessage(E.Message + #10#13 + FDataObject.Fields.FieldByName(FDataField).LookupSQL);
    end;
  end;
end;

procedure TBOLookupEdit.SetDataField(const Value: string);
begin
  FDataField := Value;
  SetLookup;
end;

procedure TBOLookupEdit.SetKeyValue(const Value: Variant);
begin
  Open;
  LookupKeyValue := Value;
end;

procedure TBOLookupEdit.SetLookup;
begin
  if Assigned(FDataObject) and Assigned(FDataObject.Fields.FieldByName(FDataField)) then
  begin
    ListFieldName := FDataObject.Fields.FieldByName(FDataField).LookupDisplayField;
    KeyFieldName := FDataObject.Fields.FieldByName(FDataField).LookupField;
  end;
end;

end.
