unit BOData;

//------------------------------------------------------------------------------
//
// Notes on the framework.
//
// - The EditQuery and SelectQuery in TBOData should not be touched in code as
//   this will remove the ability to have database independence
//
// - The EditQuery and SelectQuery should be implemented with a factory pattern
//
//------------------------------------------------------------------------------


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Db,
  TypInfo, BODataParams, IBDatabase, IBCustomDataSet, IBQuery;

//------------------------------------------------------------------------------

type
  TBOData = class;

  TBOFieldValidation = set of (fvMax, fvMin, fvRequired);

  TBODataField = class(TCollectionItem)
  private
    FValue: OleVariant;
    FFieldName: string;
    FDisplayName: string;
    FDisplayInGrid: Boolean;
    FName: string;
    FRequired: Boolean;
    FDisplayInSearch: Boolean;
    FValidate: Boolean;
    FMaxValue: Integer;
    FMinValue: Integer;
    FDisplayWidth: Integer;
    FLookupSQL: string;
    FLookupDataset: TDataset;
    FDatasetController: TBOQuery;
    FLookupDisplayField: string;
    FLookupField: string;
    FValidation: TBOFieldValidation;
    FDefaultValue: string;
    FDisplayCurrency: Boolean;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Extended;
    function GetAsInteger: Integer;
    function GetAsString: string;
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsFloat(const AValue: Extended);
    procedure SetAsInteger(const AValue: Integer);
    procedure SetAsString(const AValue: string);
    function GetLookupDataset: TDataset;
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(const AValue: Boolean);
    function GetAsVariant: Variant;
    procedure SetAsVariant(const AValue: Variant);
    function GetFieldType: TFieldType;
    procedure SetValue(const Value: OleVariant);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Initialize;
    procedure FillLookup(AList: TStrings);
    function GetValue: OleVariant;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Picture: TPicture);
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Extended read GetAsFloat write SetAsFloat;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property LookupDataset: TDataset read GetLookupDataset;
    property AsVariant: Variant read GetAsVariant write SetAsVariant;
    property FieldType: TFieldType read GetFieldType;
    property Value: OleVariant read GetValue write SetValue;
  published
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property DisplayName: string read FDisplayName write FDisplayName;
    property DisplayCurrency: Boolean read FDisplayCurrency write FDisplayCurrency;
    property DisplayInGrid: Boolean read FDisplayInGrid write FDisplayInGrid;
    property DisplayInSearch: Boolean read FDisplayInSearch write FDisplayInSearch;
    property DisplayWidth: Integer read FDisplayWidth write FDisplayWidth;
    property FieldName: string read FFieldName write FFieldName;
    property LookupDisplayField: string read FLookupDisplayField write FLookupDisplayField;
    property LookupField: string read FLookupField write FLookupField;
    property LookupSQL: string read FLookupSQL write FLookupSQL;
    property Name: string read FName write FName;
    property MaxValue: Integer read FMaxValue write FMaxValue;
    property MinValue: Integer read FMinValue write FMinValue;
    property Required: Boolean read FRequired write FRequired;
    property Validate: Boolean read FValidate write FValidate;
    property Validation: TBOFieldValidation read FValidation write FValidation;
  end;

  TBODataFields = class(TCollection)
  private
    function GetItem(Index: Integer): TBODataField;
    procedure SetItem(Index: Integer; Value: TBODataField);
  protected
    function GetOwner: TPersistent; override;
  public
    FMyComponent: TBOData;  // This is a pretty bad hack
    constructor Create(MyComponent: TBOData);
    function Add: TBODataField;
    function FieldByName(const FFieldName: string): TBODataField;
    function FindField(const FFieldName: string): Boolean;
    property Items[Index: Integer]: TBODataField read GetItem write SetItem; default;
  end;

  TDatasetClass = class of TDataset;

  TDefaultValueEvent = procedure(Sender: TObject; const FieldName: string; var Value: Variant) of object;
  TInsertAuditEvent = procedure(Sender: TObject; const Operation, Data: string; KeyValue: Integer) of object;
  TGetNextKeyEvent = procedure(Sender: TObject; const TableName: string; var KeyValue: Integer) of object;
  TInTransactionEvent = procedure(Sender: TObject; var InTransaction: Boolean) of object;
  TCommitEvent = procedure(Sender: TObject; Retaining: Boolean) of object;
  TLogEvent = procedure(Sender: TObject; const Msg: string) of object;

  TBOData = class(TComponent)
  private
    { Private declarations }
    FQueryControl: TBOQuery;
    FInsertSQL: TStrings;
    FKeyValue: Integer;
    FKeyField: string;
    FSelectSQL: TStrings;
    FUpdateSQL: TStrings;
    FEditQuery: TDataset;
    FFields: TBODataFields;
    FDeleteSQL: TStrings;
    FQueryClassName: string;
    FQueryControllerClassName: string;
    FConnection: TComponent;
    FBaseTable: string;
    FCompanyKey: string;
    FAliasCompanyKey: Boolean;
    FMaxRows: Integer;
    FOnGetDefaultValue: TDefaultValueEvent;
    FOnInsertAudit: TInsertAuditEvent;
    FTransaction: TComponent;
    FOnGetNextKey: TGetNextKeyEvent;
    FOnCommit: TCommitEvent;
    FOnStartTransaction: TNotifyEvent;
    FOnRollback: TCommitEvent;
    FOnInTransaction: TInTransactionEvent;
    FOnLogMessage: TLogEvent;
    function GetDataSet: TDataset;
    procedure GetKeyValue(const Value: Integer);
    procedure InitQuery;
    procedure InsertAudit(const Operation, Data: string; KeyValue: Integer);
    procedure SetConnection(Query: TDataset);
    procedure SetDeleteSQL(const Value: TStrings);
    procedure SetFields(const Value: TBODataFields);
    procedure SetInsertSQL(const Value: TStrings);
    procedure SetParam(Query: TDataset; const ParamName: string; Value: Variant);
    procedure SetQueryClassName(const Value: string);
    procedure SetQueryControllerClassName(const Value: string);
    procedure SetSelectSQL(const Value: TStrings);
    procedure SetSQL(Query: TDataset; SQL: TStrings); overload;
    procedure SetSQL(Query: TDataset; const SQL: string); overload;
    procedure SetUpdateSQL(const Value: TStrings);
    function GetLastKey: Integer;
    function GetWhereClause: string;
    procedure AfterClose(Dataset: TDataset);
  protected
    { Protected declarations }
    FAuditQuery: TDataset;
    FLastKey: Integer;
    FSelectQuery: TDataset;
    FWhereClause: string;
    FErrorRetry: Integer;
    FTrans: TIBTransaction;
    procedure ValidateRecord;
    function GetFieldsList: string;
    procedure LogMessage(const Msg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetNextKey: Integer;
    function GetModified(AKey: Integer): Integer;
    procedure BuildSQL;
    procedure BuildUpdateSQL;
    procedure BuildInsertSQL;
    procedure Cancel;
    procedure Close;
    procedure Delete(const Where: string = '');
    procedure Update;
    function Eof: Boolean;
    procedure ExecSQL(const SQL: string);
//    function FieldByName(const AFieldName: string): TBODataField;
    procedure First;
    procedure Initialize;
    procedure Insert;
    function IsEmpty: Boolean;
    procedure Last;
    procedure LoadDefaults;
    procedure LoadFields;
    procedure Next;
    procedure Open(const Condition: string = ''; const OrderBy: string = '');
    procedure OpenSQL(const SQL: string);
    procedure Post;
    procedure Refresh;
    procedure RefreshFields;
    procedure SetParameter(const ParamName: string; Value: Variant);
    function InTransaction: Boolean;
    procedure StartTransaction;
    procedure Commit(Retaining: Boolean = False);
    procedure Rollback(Retaining: Boolean = False);

    procedure LoadBlob(KeyValue: Integer; const BlobField: string; var Stream: TStream);
    procedure SaveBlob(KeyValue: Integer; const BlobField: string; Stream: TStream);

    property Dataset: TDataset read GetDataSet;
    property LastKey: Integer read GetLastKey write FLastKey;
    property WhereClause: string read GetWhereClause;
  published
    { Published declarations }
    property AliasCompanyKey: Boolean read FAliasCompanyKey write FAliasCompanyKey;
    property BaseTable: string read FBaseTable write FBaseTable;
    property Connection: TComponent read FConnection write FConnection;
    property Transaction: TComponent read FTransaction write FTransaction;
    property DeleteSQL: TStrings read FDeleteSQL write SetDeleteSQL;
    property Fields: TBODataFields read FFields write SetFields;
    property InsertSQL: TStrings read FInsertSQL write SetInsertSQL;
    property KeyField: string read FKeyField write FKeyField;
    property KeyValue: Integer read FKeyValue write GetKeyValue;
    property QueryClassName: string read FQueryClassName write SetQueryClassName;
    property QueryControllerClassName: string read FQueryControllerClassName write SetQueryControllerClassName;
    property SelectSQL: TStrings read FSelectSQL write SetSelectSQL;
    property UpdateSQL: TStrings read FUpdateSQL write SetUpdateSQL;
    property CompanyKey: string read FCompanyKey write FCompanyKey;
    property MaxRows: Integer read FMaxRows write FMaxRows;
    property OnGetDefaultValue: TDefaultValueEvent read FOnGetDefaultValue write FOnGetDefaultValue;
    property OnInsertAudit: TInsertAuditEvent read FOnInsertAudit write FOnInsertAudit;
    property OnGetNextKey: TGetNextKeyEvent read FOnGetNextKey write FOnGetNextKey;
    property OnStartTransaction: TNotifyEvent read FOnStartTransaction write FOnStartTransaction;
    property OnCommit: TCommitEvent read FOnCommit write FOnCommit;
    property OnRollback: TCommitEvent read FOnRollback write FOnRollback;
    property OnInTransaction: TInTransactionEvent read FOnInTransaction write FOnInTransaction;
    property OnLogMessage: TLogEvent read FOnLogMessage write FOnLogMessage;
  end;

//------------------------------------------------------------------------------

const
  NullDate: TDateTime = 0; //-700000;
  MaxListRows: Integer = 100;

var
  TransactionCount: Integer;

function ReadableIBError(const ErrorMsg: string): string;

implementation

uses
  VPGlobals, Variants, FMTBcd, TEDialogs, DmCommon, JclDebug, JclStrings;

resourcestring
  SMaxField = '%s is above the maximum allowed value.';
  SMinField = '%s is below the minimum allowed value.';
  SRequiredField = '%s is a required field. Please enter a value.';

function CallStack: string;
var
  List: TJclStackInfoList;
  Strings: TStringList;
begin
  List := JclCreateStackList(True, 7, nil);
  if Assigned(List) then
  begin
    Strings := TStringList.Create;
    try
      List.AddToStrings(Strings, True, True, True, True);
      Result := AnsiCrLf + Strings.Text;
    finally
      Strings.Free;
    end;
    List.Free;
  end;
end;

  
function ReadableIBError(const ErrorMsg: string): string;
begin
  if Pos('ISC ERROR CODE:335544345', Uppercase(ErrorMsg)) > 0 then
    // Deadlock
    MessageError('Someone else is currently changing this record. Your changes have not been saved.')
  else
    MessageError(ErrorMsg);

//  raise Exception.Create(ErrorMsg);
end;

{ TBOData }

//------------------------------------------------------------------------------
procedure TBOData.BuildUpdateSQL;
var
  Idx: Integer;
begin
  FUpdateSQL.Text := Format('UPDATE %s SET ', [FBaseTable]);

  for Idx := 0 to Fields.Count-1 do
    if CompareText(Fields[Idx].FieldName, FKeyField) <> 0 then
      FUpdateSQL.Text := FUpdateSQL.Text + Format(' %0:s = :%0:s,', [Fields[Idx].FieldName]);

  FUpdateSQL.Text := FUpdateSQL.Text + Format(' WHERE %0:s = :%0:s', [FKeyField]);
end;

//------------------------------------------------------------------------------

procedure TBOData.BuildInsertSQL;
var
  Idx: Integer;
begin
  FInsertSQL.Text := Format('INSERT INTO %s VALUES (', [FBaseTable]);

  for Idx := 0 to Fields.Count-1 do
    if CompareText(Fields[Idx].FieldName, FKeyField) <> 0 then
      FInsertSQL.Text := FInsertSQL.Text + Format(' :%s,', [Fields[Idx].FieldName]);

end;

//------------------------------------------------------------------------------

procedure TBOData.BuildSQL;
var
  Idx: Integer;
  Field: TBODataField;
begin
  if FKeyField <> '' then
    Open(FKeyField + ' = -1 ')
  else
    Open;

  FFields.Clear;
  for Idx := 0 to FSelectQuery.FieldCount-1 do
  begin
    Field := FFields.Add;
    Field.FieldName := FSelectQuery.Fields[Idx].FieldName;
    Field.DisplayName := FSelectQuery.Fields[Idx].FieldName;
    Field.DisplayInGrid := True;
    Field.Name := Self.Name + FSelectQuery.Fields[Idx].FieldName;
    Field.DisplayWidth := FSelectQuery.Fields[Idx].DisplayWidth;
  end;
end;

//------------------------------------------------------------------------------

procedure TBOData.Cancel;
begin
end;

//------------------------------------------------------------------------------

procedure TBOData.Close;
begin
  FSelectQuery.Close;
end;

//------------------------------------------------------------------------------

constructor TBOData.Create(AOwner: TComponent);
begin
  inherited;
  FDeleteSQL := TStringList.Create;
  FSelectSQL := TStringList.Create;
  FUpdateSQL := TStringList.Create;
  FInsertSQL := TStringList.Create;

  FFields := TBODataFields.Create(Self);
  FQueryClassName := 'TIBQuery';
  FMaxRows := MaxListRows;
  FErrorRetry := 0;

  FTrans := TIBTransaction.Create(Self);

  //FQueryClassName := 'TDBISAMQuery';
  //FQueryClassName := 'TADOQuery';

  //if FQueryClassName = '' then
  //  FQueryClassName := 'TIBQuery';

  FQueryControllerClassName := 'TBODBISAMQuery';
  FWhereClause := '';
  FAliasCompanyKey := True;
end;

//------------------------------------------------------------------------------

procedure TBOData.Delete(const Where: string);
begin
  SetConnection(FEditQuery);
  FQueryControl.SetOtherStuff(FEditQuery, Self);

  if FDeleteSQL.Text = '' then
    FDeleteSQL.Text := 'delete from ' + BaseTable;

  if Where <> '' then
  begin
    if Pos('where', FDeleteSQL.Text) = 0 then
      SetSQL(FEditQuery, FDeleteSQL.Text + ' where ' + Where) // No Where
    else
      SetSQL(FEditQuery, FDeleteSQL.Text + ' ' + Where); // Already have a Where clause
  end;

  SetParam(FEditQuery, FKeyField, FKeyValue);

  try
    FQueryControl.ExecSQL(FEditQuery, FTransaction);
  except
    raise;
  end;

  Inc(TransactionCount);

  InsertAudit('DELETE', '', FKeyValue);
end;

//------------------------------------------------------------------------------

destructor TBOData.Destroy;
begin
  FTrans.Free;
  
  FDeleteSQL.Free;
  FSelectSQL.Free;
  FUpdateSQL.Free;
  FInsertSQL.Free;
  FFields.Free;

  if Assigned(FSelectQuery) then
    FSelectQuery.Free;

  if Assigned(FEditQuery) then
    FEditQuery.Free;

  if Assigned(FAuditQuery) then
    FAuditQuery.Free;

  if Assigned(FQueryControl) then
    FQueryControl.Free;

  inherited;
end;

//------------------------------------------------------------------------------

procedure TBOData.Update;
var
  Idx: Integer;
  Value: OleVariant;
  ParamName: string;
  FldLst: string;
begin
  SetConnection(FEditQuery);

  SetSQL(FEditQuery, UpdateSQL.Text);
  FQueryControl.SetOtherStuff(FEditQuery, Self);

  ValidateRecord;

//  FLastKey := FFields.FieldByName(FKeyField).AsInteger;

  try
    for Idx := 0 to FQueryControl.ParamCount(FEditQuery)-1 do
    begin
      //ShowMessage(FQueryControl.ParamName(FEditQuery, Idx) + ' ' + FFields.FieldByName(FQueryControl.ParamName(FEditQuery, Idx)).AsString);
      Value := FFields.FieldByName(FQueryControl.ParamName(FEditQuery, Idx)).Value;
      ParamName := FQueryControl.ParamName(FEditQuery, Idx);
      SetParam(FEditQuery, ParamName, Value);
      Value := Null;

      try
        FldLst := FldLst + Format('%s=%s, ', [ParamName,
          VarToStr(FFields.FieldByName(FQueryControl.ParamName(FEditQuery, Idx)).Value)]);
      except
        // If error occurs building audit field list ignore it :-O
      end;

    end
  except
    ShowMessage('Error setting param: ' + ParamName);
    raise;
  end;

//  SetParam(FEditQuery, FKeyField, FKeyValue);

  try
    FQueryControl.ExecSQL(FEditQuery, FTransaction);
  except
    raise;
  end;

  Commit;

  Inc(TransactionCount);

  InsertAudit('UPDATE', FldLst, FKeyValue);
end;

//------------------------------------------------------------------------------

function TBOData.Eof: Boolean;
begin
  Result := FSelectQuery.Eof;
end;

//------------------------------------------------------------------------------

function TBOData.IsEmpty: Boolean;
begin
//  Result := FSelectQuery.Eof = FSelectQuery.Bof;
  Result := FSelectQuery.IsEmpty;
end;

//------------------------------------------------------------------------------

procedure TBOData.First;
begin
  FSelectQuery.First;
end;

//------------------------------------------------------------------------------

function TBOData.GetDataSet: TDataset;
begin
  // Should only be used to hook up a TClientDataSet
  Result := FSelectQuery;
end;

//------------------------------------------------------------------------------

procedure TBOData.GetKeyValue(const Value: Integer);
begin
  FKeyValue := Value;
end;

//------------------------------------------------------------------------------

procedure TBOData.Insert;
var
  Idx: Integer;
  FldLst: string;
begin
  SetConnection(FEditQuery);
  SetSQL(FEditQuery, InsertSQL.Text);
  FQueryControl.SetOtherStuff(FEditQuery, Self);

  ValidateRecord;

  FldLst := '';

  for Idx := 0 to FQueryControl.ParamCount(FEditQuery)-1 do
  begin
    SetParam(FEditQuery, FQueryControl.ParamName(FEditQuery, Idx),
      FFields.FieldByName(FQueryControl.ParamName(FEditQuery, Idx)).Value);

    try
      FldLst := FldLst + Format('%s=%s, ', [FQueryControl.ParamName(FEditQuery, Idx),
        VarToStr(FFields.FieldByName(FQueryControl.ParamName(FEditQuery, Idx)).Value)]);
    except
      // If error occurs building audit field list ignore it :-O
    end;
  end;

  // Set the key field param
  if FKeyField <> '' then
  begin
    FLastKey := GetNextKey;
    SetParam(FEditQuery, FKeyField, FLastKey);
  end;

  // Set the company key param
  if FCompanyKey <> '' then
    SetParam(FEditQuery, 'CompanyKey', FCompanyKey);

  try
    FQueryControl.ExecSQL(FEditQuery, FTransaction);
  except
    raise;
  end;
  Commit;

  InsertAudit('INSERT', FldLst, FLastKey);
end;

//------------------------------------------------------------------------------

procedure TBOData.Last;
begin
  FSelectQuery.Last;
end;

//------------------------------------------------------------------------------

procedure TBOData.LoadFields;
var
  Idx: Integer;
begin
  InitQuery;

  for Idx := 0 to Fields.Count-1 do
    if Fields.FindField(Fields[Idx].FieldName) then
    case Fields.FieldByName(Fields[Idx].FieldName).FieldType of
      ftString, ftWideString:
        Fields.FieldByName(Fields[Idx].FieldName).AsString := Fields.FieldByName(Fields[Idx].FieldName).AsString;

      ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
        Fields.FieldByName(Fields[Idx].FieldName).AsInteger := Fields.FieldByName(Fields[Idx].FieldName).AsInteger;

      ftBoolean:
        Fields.FieldByName(Fields[Idx].FieldName).AsBoolean := Fields.FieldByName(Fields[Idx].FieldName).AsBoolean;

      ftFloat, ftCurrency, ftBCD:
        Fields.FieldByName(Fields[Idx].FieldName).AsFloat := Fields.FieldByName(Fields[Idx].FieldName).AsFloat;

      ftDate, ftTime, ftDateTime:
        Fields.FieldByName(Fields[Idx].FieldName).AsDateTime := Fields.FieldByName(Fields[Idx].FieldName).AsDateTime;
    else
      Fields.FieldByName(Fields[Idx].FieldName).AsVariant := Fields.FieldByName(Fields[Idx].FieldName).AsVariant;
    end;
end;

//------------------------------------------------------------------------------

procedure TBOData.Next;
begin
  FSelectQuery.Next;
end;

//------------------------------------------------------------------------------

procedure TBOData.Open(const Condition: string; const OrderBy: string);
var
  Extra: string;
  Timer: DWord;
begin
  Commit;

  SetConnection(FSelectQuery);

  Extra := '';

  if Condition <> '' then
    Extra := ' WHERE ' + Condition;

  if FCompanyKey <> '' then
  begin
    if AliasCompanyKey then
    begin
      if Extra = '' then
        Extra := ' WHERE ' + BaseTable + '.CompanyKey = ''' + FCompanyKey + ''''
      else
        Extra := Extra + ' AND ' + BaseTable + '.CompanyKey = ''' + FCompanyKey + '''';
    end else
    begin
      if Extra = '' then
        Extra := ' WHERE CompanyKey = ''' + FCompanyKey + ''''
      else
        Extra := Extra + ' AND CompanyKey = ''' + FCompanyKey + '''';
    end;
  end;

  FWhereClause := Condition;

  if OrderBy <> '' then
    Extra := Extra + ' ORDER BY ' + OrderBy;

  if Extra = '' then
    SetSQL(FSelectQuery, SelectSQL)
  else
    SetSQL(FSelectQuery, Format('%s %s', [SelectSQL.Text, Extra]));

  try
    FQueryControl.SetOtherStuff(FSelectQuery, Self);
    Timer := GetTickCount;
    FSelectQuery.AfterClose := AfterClose;
    FSelectQuery.Close;
    FSelectQuery.Open;
    if (GetTickCount-Timer > 2000) then
    begin
      LogMessage(Format('Open SQL: %d ms %s %s', [GetTickCount-Timer, FQueryControl.SQL(FSelectQuery), CallStack]));
    end;
    FQueryControl.AfterOpen(FSelectQuery);
  except
    on E:Exception do
    begin
      Application.ProcessMessages;
//      FQueryControl.Rollback(Dataset);
      ReadableIBError('Open:' + E.Message + #10#13#10#13 + FQueryControl.SQL(FSelectQuery))
    end;
  end;

  Inc(TransactionCount);
end;

//------------------------------------------------------------------------------

procedure TBOData.Post;
begin
  if IsEmpty then
    Insert
  else
    Update;

  Commit;
end;

//------------------------------------------------------------------------------

procedure TBOData.Refresh;
begin
  FSelectQuery.Close;
  FSelectQuery.Open;
end;

//------------------------------------------------------------------------------

procedure TBOData.RefreshFields;
begin
  ShowMessage('Refresh Fields');
end;

//------------------------------------------------------------------------------

procedure TBOData.SetConnection(Query: TDataset);
begin
  FQueryControl.SetConnection(Query, FConnection, FTransaction);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetDeleteSQL(const Value: TStrings);
begin
  FDeleteSQL.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetFields(const Value: TBODataFields);
begin
  FFields.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetInsertSQL(const Value: TStrings);
begin
  FInsertSQL.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetParam(Query: TDataset; const ParamName: string;
  Value: Variant);
begin
  FQueryControl.SetParam(Query, ParamName, Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetQueryControllerClassName(const Value: string);
var
  ControllerClass: TBOQueryClass;
begin
  FQueryControllerClassName := Value;

  ControllerClass := TBOQueryClass(FindClass(Value));
  if ControllerClass <> nil then
  begin
    if Assigned(FQueryControl) then
      FQueryControl.Free;

    FQueryControl := ControllerClass.Create(nil);
  end;
end;

//------------------------------------------------------------------------------

procedure TBOData.SetQueryClassName(const Value: string);
var
  QueryClass: TDatasetClass;
begin
  FQueryClassName := Value;

  QueryClass := TDatasetClass(FindClass(Value));
  if QueryClass <> nil then
  begin
    if Assigned(FSelectQuery) then
      FSelectQuery.Free;

    if Assigned(FAuditQuery) then
      FAuditQuery.Free;

    if Assigned(FEditQuery) then
      FEditQuery.Free;

//    FEditQuery := QueryClass.Create(nil);
    FEditQuery := TIBQuery.Create(nil);
    FSelectQuery := QueryClass.Create(nil);
    FAuditQuery := QueryClass.Create(nil);
  end;
end;

//------------------------------------------------------------------------------

procedure TBOData.SetSelectSQL(const Value: TStrings);
begin
  FSelectSQL.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetSQL(Query: TDataset; SQL: TStrings);
begin
  SetSQL(Query, SQL.Text);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetSQL(Query: TDataset; const SQL: string);
begin
  FQueryControl.SetSQL(Query, SQL);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetUpdateSQL(const Value: TStrings);
begin
  FUpdateSQL.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.SetParameter(const ParamName: string; Value: Variant);
begin
  SetParam(FSelectQuery, ParamName, Value);
end;

//------------------------------------------------------------------------------

procedure TBOData.Initialize;
var
  x: Integer;
begin
  for x := 0 to Fields.Count-1 do
    Fields[x].Initialize;

end;

//------------------------------------------------------------------------------

function TBOData.GetLastKey: Integer;
begin
  // Returns the last inserted key
  Result := FLastKey;
end;

//------------------------------------------------------------------------------

procedure TBOData.InitQuery;
begin
  if not FSelectQuery.Active then
    Open(FKeyField + ' = -1 ');
end;

//------------------------------------------------------------------------------

procedure TBOData.ValidateRecord;
//var
//  Idx: Integer;
begin
 {TODO: This needs more testing}

{  for Idx := 0 to Fields.Count-1 do
  begin
    // Validate Fields
      case Fields[Idx].FieldType of
        ftString, ftWideString:
          if ((Fields[Idx].Required) and (Fields[Idx].AsString = '')) then
            raise Exception.Create(Format(SRequiredField, [Fields[Idx].DisplayName]));

        ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
        begin
          if ((Fields[Idx].Required) and (Fields[Idx].AsInteger = 0)) then
            raise Exception.Create(Format(SRequiredField, [Fields[Idx].DisplayName]));

          if (fvMax in Fields[Idx].Validation) and (Fields[Idx].AsInteger > Fields[Idx].MaxValue) then
            raise Exception.Create(Format(SMaxField, [Fields[Idx].DisplayName]));

          if (fvMin in Fields[Idx].Validation) and (Fields[Idx].AsInteger < Fields[Idx].MinValue) then
            raise Exception.Create(Format(SMinField, [Fields[Idx].DisplayName]));
        end;

        ftBoolean:
          if ((Fields[Idx].Required) and (Fields[Idx].AsString = '')) then
            raise Exception.Create(Format(SRequiredField, [Fields[Idx].DisplayName]));

        ftFloat, ftCurrency, ftBCD:
        begin
          if (Fields[Idx].AsString = '') then
            raise Exception.Create(Format(SRequiredField, [Fields[Idx].DisplayName]));
          if (fvMax in Fields[Idx].Validation) and (Fields[Idx].AsFloat > Fields[Idx].MaxValue) then
            raise Exception.Create(Format(SMaxField, [Fields[Idx].DisplayName]));

          if (fvMin in Fields[Idx].Validation) and (Fields[Idx].AsFloat < Fields[Idx].MinValue) then
            raise Exception.Create(Format(SMinField, [Fields[Idx].DisplayName]));
        end;

        ftDate, ftTime, ftDateTime:
        begin
          if (Fields[Idx].Required) and (Fields[Idx].AsDateTime = 0) then
            raise Exception.Create(Format(SRequiredField, [Fields[Idx].DisplayName]));

          if (fvMax in Fields[Idx].Validation) and (Fields[Idx].AsDateTime > Fields[Idx].MaxValue) then
            raise Exception.Create(Format(SMaxField, [Fields[Idx].DisplayName]));

          if (fvMin in Fields[Idx].Validation) and (Fields[Idx].AsDateTime < Fields[Idx].MinValue) then
            raise Exception.Create(Format(SMinField, [Fields[Idx].DisplayName]));
        end;
      end;
  end;}
end;

//------------------------------------------------------------------------------

//function TBOData.FieldByName(const AFieldName: string): TBODataField;
//begin
//  Result := Fields.FieldByName(AFieldName);
//end;

//------------------------------------------------------------------------------

procedure TBOData.LoadDefaults;
var
  Idx: Integer;
begin
  InitQuery;

    for Idx := 0 to Fields.Count-1 do
      try

        case Fields.FieldByName(Fields[Idx].FieldName).FieldType of
          ftString, ftWideString:
            Fields.FieldByName(Fields[Idx].FieldName).AsString := '';

          ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
            Fields.FieldByName(Fields[Idx].FieldName).AsInteger := 0;

          ftBoolean:
            Fields.FieldByName(Fields[Idx].FieldName).AsBoolean := False;

          ftFloat, ftCurrency, ftBCD:
            Fields.FieldByName(Fields[Idx].FieldName).AsFloat := 0.00;

          ftDate, ftTime, ftDateTime:
            Fields.FieldByName(Fields[Idx].FieldName).AsDateTime := Date;
        else
          Fields.FieldByName(Fields[Idx].FieldName).AsVariant := VarNull;
        end;

      except
        ShowMessage('Error loading field: ' + Fields[Idx].FieldName);
        raise;
      end;
end;

//------------------------------------------------------------------------------

procedure TBOData.ExecSQL(const SQL: string);
begin
  Screen.Cursor := crHourGlass;
  try
    SetConnection(FEditQuery);
    SetSQL(FEditQuery, SQL);
    FQueryControl.SetOtherStuff(FEditQuery, Self);
    try
      FQueryControl.ExecSQL(FEditQuery, FTransaction);
    except
      raise;
    end;
    Inc(TransactionCount);
  finally
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TBOData.InsertAudit(const Operation, Data: string; KeyValue: Integer);
begin
  if Assigned(FOnInsertAudit) then
    FOnInsertAudit(Self, Operation, Data, KeyValue);
end;

//------------------------------------------------------------------------------

procedure TBOData.OpenSQL(const SQL: string);
var
  Timer: DWord;
begin
  Commit;

  SetConnection(FSelectQuery);

  SetSQL(FSelectQuery, SQL);

  FQueryControl.SetOtherStuff(FSelectQuery, Self);
  try
    Timer := GetTickCount;
    FSelectQuery.AfterClose := AfterClose;
    FSelectQuery.Close;
    FSelectQuery.Open;
    if (GetTickCount-Timer > 2000) then
      LogMessage(Format('Open SQL: %d ms %s %s',[GetTickCount-Timer, FQueryControl.SQL(FSelectQuery), CallStack]));
    FQueryControl.AfterOpen(FSelectQuery);
  except
    on E:Exception do
    begin
      Application.ProcessMessages;
//      FQueryControl.Rollback(FSelectQuery);
      ReadableIBError('OpenSQL:' + E.Message + #10#13#10#13 + FQueryControl.SQL(FSelectQuery))
    end;
  end;
  Inc(TransactionCount);

  FErrorRetry := 0;
end;

//------------------------------------------------------------------------------


{ TBODataField }

//------------------------------------------------------------------------------

constructor TBODataField.Create(Collection: TCollection);
var
  ControllerClass: TBOQueryClass;
  QueryClass: TDatasetClass;
begin
  inherited;
  // Create the dataset controller
  ControllerClass := TBOQueryClass(FindClass(TBODataFields(Collection).FMyComponent.FQueryControllerClassName));
  if ControllerClass <> nil then
    FDatasetController := ControllerClass.Create(nil);

  // Create the lookup dataset
  QueryClass := TDatasetClass(FindClass(TBODataFields(Collection).FMyComponent.FQueryClassName));
  if QueryClass <> nil then
    FLookupDataset := QueryClass.Create(nil);

end;

//------------------------------------------------------------------------------

destructor TBODataField.Destroy;
begin
  FLookupDataset.Free;
  FDatasetController.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TBODataField.FillLookup(AList: TStrings);
begin

end;

//------------------------------------------------------------------------------

function TBODataField.GetAsBoolean: Boolean;
var
  Dflt: Variant;

  function StrToBool(const Value: string): Boolean;
  begin
    try
      Result := (CompareText(Value, 'Y') = 0) or (CompareText(Value, 'True') = 0) or
        (CompareText(Value, 'T') = 0) or (CompareText(Value, 'Yes') = 0);
    except
      Result := False;
    end;
  end;

begin
  with (Collection as TBODataFields).FMyComponent.FSelectQuery do
    if RecordCount = 0 then
    begin

      Dflt := False;
      if FDefaultValue <> '' then
      begin
        Result := StrToBool(FDefaultValue);
      end
      else if Assigned((Collection as TBODataFields).FMyComponent.OnGetDefaultValue) then
      begin
        (Collection as TBODataFields).FMyComponent.OnGetDefaultValue(Self, FFieldName, Dflt);
        Result := Dflt;
      end else
        Result := False;

    end else
      Result := StrToBool(FieldByName(FFieldName).AsString);

  Value := Result;
end;

//------------------------------------------------------------------------------

function TBODataField.GetAsDateTime: TDateTime;
var
  Dflt: Variant;
begin
//  if FSelectQuery.Active then
//    (Collection as TBODataFields).FMyComponent.Open;

  with (Collection as TBODataFields).FMyComponent.FSelectQuery do
    if RecordCount = 0 then
    begin
      Dflt := 0.0;
      if FDefaultValue <> '' then
      begin
        Result := StrToDate(FDefaultValue);
      end
      else if Assigned((Collection as TBODataFields).FMyComponent.OnGetDefaultValue) then
      begin
        (Collection as TBODataFields).FMyComponent.OnGetDefaultValue(Self, FFieldName, Dflt);
        Result := VarToDateTime(Dflt);
      end else
        Result := 0;
    end else
    begin
      //WriteLn('Date: ' + FloatToStr(FieldByName(FFieldName).AsFloat));
      try
        if (FieldByName(FFieldName).IsNull) or (FieldByName(FFieldName).AsString = '') or (FieldByName(FFieldName).Value <= 0) then
          Result := NullDate
        else
          Result := FieldByName(FFieldName).AsDateTime;
      except
        on E:EConvertError do
          Result := NullDate;
      end;
    end;

 //WriteLn('DateResult: ' + FloatToStr(Result));
  if Result = NullDate then
    Result := -700000;

  Value := Result;
end;

//------------------------------------------------------------------------------

function TBODataField.GetAsFloat: Extended;
var
  Dflt: Variant;
begin
//  if FSelectQuery.Active then
//    (Collection as TBODataFields).FMyComponent.Open;

  with (Collection as TBODataFields).FMyComponent.FSelectQuery do
    if RecordCount = 0 then
    begin
      Dflt := 0.00;
      if FDefaultValue <> '' then
      begin
        Result := StrToFloat(FDefaultValue);
      end
      else if Assigned((Collection as TBODataFields).FMyComponent.OnGetDefaultValue) then
      begin
        (Collection as TBODataFields).FMyComponent.OnGetDefaultValue(Self, FFieldName, Dflt);
        Result := Dflt;
      end else
        Result := 0.00;
    end else
    begin
      //if FieldByName(FFieldName).DataType in [ftBCD, ftCurrency] then
      //  Result := BCDToDouble(FieldByName(FFieldName).AsBCD)
      //else
        Result := FieldByName(FFieldName).AsFloat;
    end;

  Value := Result;
end;

//------------------------------------------------------------------------------

function TBODataField.GetAsInteger: Integer;
var
  Dflt: Variant;
begin
//  if FSelectQuery.Active then
//    (Collection as TBODataFields).FMyComponent.Open;

  with (Collection as TBODataFields).FMyComponent.FSelectQuery do
    if RecordCount = 0 then
    begin
      Dflt := Integer(0);
      if FDefaultValue <> '' then
      begin
        Result := StrToInt(FDefaultValue);
      end
      else if Assigned((Collection as TBODataFields).FMyComponent.OnGetDefaultValue) then
      begin
        (Collection as TBODataFields).FMyComponent.OnGetDefaultValue(Self, FFieldName, Dflt);
        Result := Dflt;
      end else
        Result := 0;
    end else
      Result := FieldByName(FFieldName).AsInteger;

  Value := Result;
end;

//------------------------------------------------------------------------------

function TBODataField.GetAsString: string;
var
  Dflt: Variant;
begin
//  if FSelectQuery.Active then
//    (Collection as TBODataFields).FMyComponent.Open;

  with (Self.Collection as TBODataFields).FMyComponent.FSelectQuery do
    if RecordCount = 0 then
    begin
      Dflt := '';
      if Assigned((Collection as TBODataFields).FMyComponent.OnGetDefaultValue) then
      begin
        (Collection as TBODataFields).FMyComponent.OnGetDefaultValue(Self, FFieldName, Dflt);
      end;
      Result := Dflt;
    end else
    begin
      try
        Result := FieldByName(FFieldName).AsString;
      except
        on E:EConvertError do
          Result := '';
      end;
    end;

  Value := Result;
end;

//------------------------------------------------------------------------------

function TBODataField.GetDisplayName: string;
begin
  if FFieldName <> '' then
    Result := FFieldName
  else
    Result := inherited GetDisplayName;
end;

//------------------------------------------------------------------------------

function TBODataField.GetLookupDataset: TDataset;
begin
  Result := FLookupDataset;
end;

//------------------------------------------------------------------------------

function TBODataField.GetAsVariant: Variant;
begin
  with (Collection as TBODataFields).FMyComponent.FSelectQuery do
    if RecordCount = 0 then
      Result := Value
    else
      Result := FieldByName(FFieldName).AsVariant;

  Value := Result;
end;

//------------------------------------------------------------------------------

procedure TBODataField.Initialize;
begin
  if not FLookupDataset.Active then
    FDatasetController.SetConnection(FLookupDataset,
      TBODataFields(Collection).FMyComponent.Connection,
      TBODataFields(Collection).FMyComponent.Transaction);

  FDatasetController.SetSQL(FLookupDataset, LookupSQL);
end;

//------------------------------------------------------------------------------

procedure TBODataField.SaveToStream(Stream: TStream);
begin
end;

//------------------------------------------------------------------------------

procedure TBODataField.LoadFromStream(Picture: TPicture);
begin
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetAsVariant(const AValue: Variant);
begin
  Value := AValue;
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetAsBoolean(const AValue: Boolean);
begin
  if AValue then
    Value := 'Y'
  else
    Value := 'N';
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetAsDateTime(const AValue: TDateTime);
begin
{  if AValue <= NullDate then
    Value := Null
  else}

  if AValue = -700000 then
    Value := BOData.NullDate
  else
    Value := AValue;
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetAsFloat(const AValue: Extended);
begin
  Value := AValue;
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetAsInteger(const AValue: Integer);
begin
  Value := AValue;

  if CompareText(Self.FieldName, TBODataFields(Collection).FMyComponent.KeyField) = 0 then
    TBODataFields(Collection).FMyComponent.KeyValue := AValue;
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetAsString(const AValue: string);
begin
  Value := AValue;
end;

//------------------------------------------------------------------------------

function TBODataField.GetFieldType: TFieldType;
begin
  Result := (Collection as TBODataFields).FMyComponent.Dataset.FieldByName(FFieldName).DataType;
end;

//------------------------------------------------------------------------------

{ TBODataFields }

function TBODataFields.Add: TBODataField;
begin
  Result := TBODataField(inherited Add);
end;

//------------------------------------------------------------------------------

constructor TBODataFields.Create(MyComponent: TBOData);
begin
  inherited Create(TBODataField);
  FMyComponent := MyComponent;
end;

//------------------------------------------------------------------------------

function TBODataFields.FieldByName(const FFieldName: string): TBODataField;
var
  Idx: Integer;
begin
  for Idx := 0 to Count-1 do
  begin
    if CompareText(FFieldName, Items[Idx].FieldName) = 0 then
    begin
      Result := Items[Idx];
      Exit;
    end;
  end;
  // If we get here then the field was not found :-(
  raise Exception.Create('Field "' + FFieldName + '" not found in BOData fields collection.');
end;

//------------------------------------------------------------------------------

function TBODataFields.FindField(const FFieldName: string): Boolean;
var
  Idx: Integer;
begin
  Result := False;
  for Idx := 0 to Count-1 do
  begin
    if CompareText(FFieldName, Items[Idx].FieldName) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TBODataFields.GetItem(Index: Integer): TBODataField;
begin
  Result := TBODataField(inherited GetItem(Index));
end;

//------------------------------------------------------------------------------

function TBODataFields.GetOwner: TPersistent;
begin
  Result := FMyComponent;
end;

//------------------------------------------------------------------------------

procedure TBODataFields.SetItem(Index: Integer; Value: TBODataField);
begin
  inherited SetItem(Index, Value);
end;

//------------------------------------------------------------------------------

function TBODataField.GetValue: OleVariant;
begin
  Result := FValue;
end;

//------------------------------------------------------------------------------

procedure TBODataField.SetValue(const Value: OleVariant);
begin
  FValue := Value;
  FValue := FValue;
end;

//------------------------------------------------------------------------------

function TBOData.GetWhereClause: string;
begin
  Result := FWhereClause;
end;

//------------------------------------------------------------------------------

function TBOData.GetNextKey: Integer;
var
  KeyValue: Integer;
begin
  Result := 0;
  if Assigned(FOnGetNextKey) then
  begin
    FOnGetNextKey(Self, BaseTable, KeyValue);
    Result := KeyValue;
  end;
end;

//------------------------------------------------------------------------------

function TBOData.GetModified(AKey: Integer): Integer;
//var
//  Qry: TDataset;
//  QueryClass: TDatasetClass;
begin
{  QueryClass := TDatasetClass(FindClass(FQueryClassName));
  Qry := QueryClass.Create(nil);
  try
    FQueryControl.SetOtherStuff(Qry, Self);
    SetSQL(Qry, Format('SELECT Modified FROM %s WHERE %s = %d', [BaseTable, KeyField, AKey]));
    SetConnection(Qry);
    Qry.Open;
    Result := Qry.Fields[0].AsInteger;
    Qry.Close;
  finally
    Qry.Free;
  end;}

  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TBOData.LoadBlob(KeyValue: Integer; const BlobField: string; var Stream: TStream);
var
  Qry: TDataset;
  QueryClass: TDatasetClass;
begin
  QueryClass := TDatasetClass(FindClass(FQueryClassName));
  Qry := QueryClass.Create(nil);
  try
    FQueryControl.SetConnection(Qry, FConnection, FTransaction);
    FQueryControl.LoadBlob(Qry, KeyValue, BaseTable, KeyField, BlobField, Stream);
  finally
    Qry.Free;
  end;
  Inc(TransactionCount);
end;

//------------------------------------------------------------------------------

procedure TBOData.SaveBlob(KeyValue: Integer; const BlobField: string; Stream: TStream);
var
  Qry: TDataset;
  QueryClass: TDatasetClass;
begin
  QueryClass := TDatasetClass(FindClass(FQueryClassName));
  Qry := QueryClass.Create(nil);
  try
    FQueryControl.SetConnection(Qry, FConnection, FTransaction);
    FQueryControl.SaveBlob(Qry, KeyValue, BaseTable, KeyField, BlobField, Stream);
  finally
    Qry.Free;
  end;
  Inc(TransactionCount);
end;

//------------------------------------------------------------------------------

function TBOData.GetFieldsList: string;
var
  Idx: Integer;
begin
  Result := '';
  for Idx := 0 to Fields.Count-1 do
  begin
    try
      Result := Result + Format('%s=%s, ', [Fields[Idx].FieldName, Fields[Idx].AsString]);
    except
      // Problem
    end;
  end;

end;

procedure TBOData.Commit(Retaining: Boolean);
var
  Idx: Integer;
begin
  try

  for Idx := 0 to TIBDatabase(FConnection).TransactionCount-1 do
    if TIBDatabase(FConnection).Transactions[Idx].InTransaction then
      TIBDatabase(FConnection).Transactions[Idx].Commit;

  except
    on E:Exception do
    begin
      MessageError(Format('TBOData.Commit: %s', [E.Message]));
      raise;
    end;
  end;

//  if FTrans.InTransaction then
//    FTrans.Commit;

//  FQueryControl.CommitAll(Dataset);
//  if Assigned(FOnCommit) then
//    FOnCommit(Self, Retaining);
end;

procedure TBOData.Rollback(Retaining: Boolean);
begin
  if FTrans.InTransaction then
    FTrans.Rollback;
//  FQueryControl.Rollback(Dataset);
//  if Assigned(FOnRollback) then
//    FOnRollback(Self, Retaining);
end;

procedure TBOData.StartTransaction;
begin
  FTrans.StartTransaction;
//  FQueryControl.StartTransaction(Dataset);
//  if Assigned(FOnStartTransaction) then
//    FOnStartTransaction(Self);
end;

function TBOData.InTransaction: Boolean;
begin
  Result := FTrans.InTransaction;
//  if Assigned(FOnInTransaction) then
//    FOnInTransaction(Self, Result);
end;

procedure TBOData.LogMessage(const Msg: string);
begin
  // Added cvn 11/5/2006
  if Assigned(FOnLogMessage) then
    FOnLogMessage(Self, Msg);
end;

procedure TBOData.AfterClose(Dataset: TDataset);
begin
  Commit;
//  FQueryControl.CommitAll(Dataset);
end;

initialization
  TransactionCount := 0;

end.
