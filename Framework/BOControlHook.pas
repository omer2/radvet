unit BOControlHook;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  BOData, BusinessObject, TypInfo;

type
  TBOControlHook = class;

  TPropType = (ptString, ptInteger, ptFloat, ptStringList, ptDateTime, ptCustom);

  TOnLoadData = procedure(Sender: TObject; AFieldName: string) of object;

  TBOControlHookItem = class(TCollectionItem)
  private
    FControl: TWinControl;
    FFieldName: string;
    FValueProp: string;
    FOnGetValue: TOnLoadData;
    FOnSetValue: TOnLoadData;
    FPropType: TPropType;
    procedure SetControl(const Value: TWinControl);
  protected
   function GetDisplayName: string; override;
  published
    property Control: TWinControl read FControl write SetControl;
    property FieldName: string read FFieldName write FFieldName;
    property PropType: TPropType read FPropType write FPropType;
    property ValueProp: string read FValueProp write FValueProp;

    property OnGetValue: TOnLoadData read FOnGetValue write FOnGetValue;
    property OnSetValue: TOnLoadData read FOnSetValue write FOnSetValue;
  end;

  TBOControlHookItems = class(TCollection)
  private
    FBOControlHook: TBOControlHook;
    function GetItem(Index: Integer): TBOControlHookItem;
    procedure SetItem(Index: Integer; Value: TBOControlHookItem); 
  protected 
    function GetOwner: TPersistent; override; 
  public 
    constructor Create(MyComponent: TBOControlHook);
    function Add: TBOControlHookItem;
    property Items[Index: Integer]: TBOControlHookItem read GetItem write SetItem; default;
  end;

  TBOControlHook = class(TComponent)
  private
    { Private declarations }
    FBusinessObject: TBusinessObject;
    FItems: TBOControlHookItems;
    procedure SetItems(const Value: TBOControlHookItems);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Insert;
    procedure Load;
    procedure Update;
  published
    { Published declarations }
    property BusinessObject: TBusinessObject read FBusinessObject write FBusinessObject;
    property Items: TBOControlHookItems read FItems write SetItems;
  end;

implementation

{ TBOControlHookItem }

function TBOControlHookItem.GetDisplayName: string;
begin
  if FControl <> nil then
    Result := FControl.Name
  else
    Result := inherited GetDisplayName;
end;

procedure TBOControlHookItem.SetControl(const Value: TWinControl);
begin
  FControl := Value;
end;

{ TBOControlHookItems }

function TBOControlHookItems.Add: TBOControlHookItem;
begin
  Result := TBOControlHookItem(inherited Add);
end;

constructor TBOControlHookItems.Create(MyComponent: TBOControlHook);
begin
  inherited Create(TBOControlHookItem); 
  FBOControlHook := MyComponent; 
end;

function TBOControlHookItems.GetItem(Index: Integer): TBOControlHookItem;
begin
  Result := TBOControlHookItem(inherited GetItem(Index));
end;

function TBOControlHookItems.GetOwner: TPersistent;
begin
  Result := FBOControlHook;
end;

procedure TBOControlHookItems.SetItem(Index: Integer;
  Value: TBOControlHookItem);
begin
  inherited SetItem(Index, Value);
end;

{ TBOControlHook }

constructor TBOControlHook.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TBOControlHookItems.Create(Self);
end;

destructor TBOControlHook.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TBOControlHook.Insert;
begin

end;

procedure TBOControlHook.Load;
var
  Idx: Integer;
  PropInfo: PPropInfo;
begin
  if (not Assigned(FBusinessObject)) or (not Assigned(FBusinessObject.DataObject)) then
    Exit;
    
  for Idx := 0 to FItems.Count-1 do
  begin
    case FItems[Idx].PropType of
      ptString:
      begin
        PropInfo := GetPropInfo(FItems[Idx].Control.ClassInfo, FItems[Idx].ValueProp);
        if PropInfo <> nil then
        begin
          SetStrProp(FItems[Idx].Control, FItems[Idx].ValueProp,
            FBusinessObject.DataObject.Fields.FieldByName(FItems[Idx].FieldName).AsString);
        end else
        begin
          ShowMessage(Format('Unable to set property %s for control %s',
            [FItems[Idx].ValueProp, FItems[Idx].Control.Name]));
        end;
      end;
    end;
  end;
end;

procedure TBOControlHook.SetItems(const Value: TBOControlHookItems);
begin
  FItems := Value;
end;

procedure TBOControlHook.Update;
begin

end;

end.
 
