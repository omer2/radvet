unit BODataParamsDBISAM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Db,
  BODataParams, ComObj, IBDatabase, IBCustomDataSet, IBQuery, DBClient, DBLocal,
  DBLocalI, IBSQL;

type
  TBODBISAMQuery = class(TBOQuery)
  private
    function VarTypeToDataType(TheVarType: Integer): TFieldType;
  public
    procedure SetServerMethod(Query: TDataset; const Method: string); override;
    procedure CommitAll(Trans: TComponent); override;
    procedure Rollback(Trans: TComponent); override;
    procedure StartTransaction(Trans: TComponent); override;
    procedure ClearParams(Query: TDataset); override;
    procedure ExecSQL(Query: TDataset; Transaction: TComponent = nil); override;
    function ParamCount(Query: TDataset): Integer; override;
    function ParamName(Query: TDataset; Index: Integer): string; override;
    procedure SetConnection(Query: TDataset; Connection: TComponent; Transaction: TComponent); override;
    procedure SetSQL(Query: TDataset; const SQL: string); override;
    procedure SetParam(Query: TDataset; const ParamName: string; Value: Variant;
      ACreate: Boolean = False); override;
    function GetParam(Query: TDataset; const ParamName: string): Variant; override;
    function SQL(Query: TDataset): string; override;
    procedure SetOtherStuff(Query: TDataset; ABOData: TComponent); override;
    procedure SaveBlob(Query: TDataset; KeyValue: Integer; const ATableName, KeyField, FieldName: string; Stream: TStream); override;
    procedure LoadBlob(Query: TDataset; KeyValue: Integer; const ATableName, KeyField, FieldName: string; var Stream: TStream); override;
    procedure AfterOpen(Query: TDataset); override;
  end;

implementation

uses
  Variants, TEDialogs, BOData, TECompress, DmCommon;

function TBODBISAMQuery.VarTypeToDataType(TheVarType: Integer): TFieldType;
begin
  case TheVarType of
    varSmallint, varInteger:
      Result := ftInteger;
    varSingle, varDouble:
      Result := ftFloat;
    varCurrency:
      Result := ftCurrency;
    varDate:
      Result := ftDate;
    varBoolean:
      Result := ftBoolean;
    varString:
      Result := ftString;
  else
    Result := ftUnknown;
  end;
end;

procedure TBODBISAMQuery.SetSQL(Query: TDataset; const SQL: string);
begin
  if SQL = '' then
    Exit;

  Query.Close;

  if Query.ClassName = 'TIBQuery' then
    TIBQuery(Query).SQL.Text := SQL
  else
    TIBClientDataset(Query).CommandText := SQL;
end;

procedure TBODBISAMQuery.SetParam(Query: TDataset; const ParamName: string;
  Value: Variant; ACreate: Boolean);

  function CheckNull(AValue: Variant): Variant;
  begin
    if (VarType(AValue) = varDate) and (AValue <= 0) then
    begin
      if Query.ClassName = 'TIBQuery' then
        TIBQuery(Query).Params.ParamByName(ParamName).DataType := VarTypeToDataType(varDate)
      else
        TIBClientDataset(Query).Params.ParamByName(ParamName).DataType := VarTypeToDataType(varDate);
      Result := Null;
    end else
      Result := AValue;
  end;

begin
  if Query.ClassName = 'TIBQuery' then
  begin
    if TIBQuery(Query).Params.Count > 0 then
      if TIBQuery(Query).Params.FindParam(ParamName) <> nil then
        TIBQuery(Query).Params.ParamByName(ParamName).Value := CheckNull(Value);
  end else
  begin
    if TIBClientDataset(Query).Params.Count > 0 then
      if TIBClientDataset(Query).Params.FindParam(ParamName) <> nil then
        TIBClientDataset(Query).Params.ParamByName(ParamName).Value := CheckNull(Value);
  end;
end;

procedure TBODBISAMQuery.ExecSQL(Query: TDataset; Transaction: TComponent);
var
  Qry: TIBSQL;
  Trans: TIBTransaction;
  TransIdx: Integer;
  Idx: Integer;
begin
  Qry := TIBSQL.Create(Self);
  try
    if Query.ClassName = 'TIBQuery' then
      Qry.Database := TIBQuery(Query).Database
    else
      Qry.Database := TIBClientDataset(Query).DBConnection;

    Trans := TIBTransaction.Create(Self);
    try
      TransIdx := Qry.Database.AddTransaction(Trans);
      Trans.DefaultDatabase := Qry.Database;

      Qry.Transaction := Trans;
      Qry.Transaction.StartTransaction;

      if Query.ClassName = 'TIBQuery' then
        Qry.SQL.Text := TIBQuery(Query).SQL.Text
      else
        Qry.SQL.Text := TIBClientDataset(Query).CommandText;

      for Idx := 0 to Qry.Params.Count-1 do
        if Query.ClassName = 'TIBQuery' then
          Qry.Params[Idx].Value := TIBQuery(Query).Params[Idx].Value
        else
          Qry.Params[Idx].Value := TIBClientDataset(Query).Params[Idx].Value;

//      for Idx := 0 to TIBClientDataset(Query).Params.Count-1 do
//        Qry.Params[Idx].Value := TIBClientDataset(Query).Params[Idx].Value;

      try
        Qry.ExecQuery;
        Qry.Transaction.Commit;
      except
        Qry.Transaction.Rollback;
        raise;
      end;

      Qry.Database.RemoveTransaction(TransIdx);
    finally
      Trans.Free;
    end;

  finally
    Qry.Free;
  end;

{var
  Trans: TIBTransaction;
  TransIdx: Integer;
begin
  Trans := TIBTransaction.Create(Self);
  try
    TransIdx := TIBQuery(Query).Database.AddTransaction(Trans);
    Trans.DefaultDatabase := TIBQuery(Query).Database;

    TIBQuery(Query).Transaction := Trans;
    Trans.StartTransaction;
    try
      // if there are no params them delete all params
      if Pos(':', TIBQuery(Query).SQL.Text) = 0 then
        TIBQuery(Query).Params.Clear;

      TIBQuery(Query).ExecSQL;
      Trans.Commit;
    except
      on E:Exception do
      begin
        Trans.Rollback;
        MessageError(E.Message);
        raise;
      end;
    end;

    TIBQuery(Query).Database.RemoveTransaction(TransIdx);
  finally
    Trans.Free;
  end;}
end;

procedure TBODBISAMQuery.SetConnection(Query: TDataset;
  Connection: TComponent; Transaction: TComponent);
begin
  if Connection <> nil then
  begin
    if not TIBDatabase(Connection).Connected then
      TIBDatabase(Connection).Connected := True;
  end else
    ShowMessage('Connection not set');

  if Query.ClassName = 'TIBQuery' then
    TIBQuery(Query).Transaction := TIBTransaction(Transaction)
  else
    TIBClientDataset(Query).DBConnection := TIBDatabase(Connection);
end;

function TBODBISAMQuery.ParamCount(Query: TDataset): Integer;
begin
  if Query.ClassNAme = 'TIBQuery' then
    Result := TIBQuery(Query).Params.Count
  else
    Result := TIBClientDataset(Query).Params.Count;
end;

function TBODBISAMQuery.ParamName(Query: TDataset; Index: Integer): string;
begin
  if Query.ClassName = 'TIBQuery' then
    Result := TIBQuery(Query).Params[Index].Name
  else
    Result := TIBClientDataset(Query).Params[Index].Name;
end;

procedure TBODBISAMQuery.ClearParams(Query: TDataset);
begin
  if Query.ClassName = 'TIBQuery' then
    TIBQuery(Query).Params.Clear
  else
    TIBClientDataset(Query).Params.Clear;
end;

function TBODBISAMQuery.SQL(Query: TDataset): string;
begin
  if Query.ClassName = 'TIBQuery' then
    Result := TIBQuery(Query).SQL.Text
  else
    Result := TIBClientDataset(Query).CommandText
end;

procedure TBODBISAMQuery.SaveBlob(Query: TDataset; KeyValue: Integer;
  const ATableName, KeyField, FieldName: string; Stream: TStream);
var
  Qry: TIBSQL;
  Trans: TIBTransaction;
  TransIdx: Integer;
begin
  Qry := TIBSQL.Create(Self);
  try
    if Query.ClassName = 'TIBQuery' then
      Qry.Database := TIBQuery(Query).Database
    else
      Qry.Transaction := TIBClientDataSet(Query).DBTransaction;

    Trans := TIBTransaction.Create(Self);
    try
      TransIdx := Qry.Database.AddTransaction(Trans);
      Trans.DefaultDatabase := Qry.Database;

      Qry.Transaction := Trans;
      Qry.Transaction.StartTransaction;

      Stream.Position := 0;
      Stream := CompressStream(Stream, 9);
      with Qry do
      begin
        SQL.Text := Format('UPDATE %s SET %s = :%s WHERE %s = %d',
          [ATableName, FieldName, FieldName, KeyField, KeyValue]);
        ParamByName(FieldName).LoadFromStream(Stream);
        try
          ExecQuery;
          Qry.Transaction.Commit;
        except
          Qry.Transaction.Rollback;
          raise;
        end;
      end;

      Qry.Database.RemoveTransaction(TransIdx);
    finally
      Trans.Free;
    end;

  finally
    Qry.Free;
  end;
end;

procedure TBODBISAMQuery.LoadBlob(Query: TDataset; KeyValue: Integer;
  const ATableName, KeyField, FieldName: string; var Stream: TStream);
var
  Trans: TIBTransaction;
  TransIdx: Integer;
  Qry: TIBQuery;
begin
  Qry := TIBQuery.Create(Self);
  try
    if Query.ClassName = 'TIBQuery' then
      Qry.Database := TIBQuery(Query).Database
    else
      Qry.Database := TIBClientDataset(Query).DBConnection;

    Trans := TIBTransaction.Create(Self);
    try
      TransIdx := Qry.Database.AddTransaction(Trans);
      Trans.DefaultDatabase := Qry.Database;
      Qry.Transaction := Trans;
      Qry.Transaction.StartTransaction;

      SetOtherStuff(Qry, nil);
      with Qry do
      begin
        Close;
        SQL.Text := Format('SELECT %s FROM %s WHERE %s = %d',
          [FieldName, ATableName, KeyField, KeyValue]);
        Open;
        TBlobField(FieldByName(FieldName)).SaveToStream(Stream);
        Close;
      end;
      Stream.Position := 0;
      Stream := ExpandStream(Stream);

      Qry.Database.RemoveTransaction(TransIdx);
    finally
      Trans.Free;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TBODBISAMQuery.SetOtherStuff(Query: TDataset; ABOData: TComponent);
begin
//  TIBOQuery(Query).IB_Transaction := DtmCommon.IB_Transaction;
end;

procedure TBODBISAMQuery.CommitAll(Trans: TComponent);
begin
  if not Assigned(TIBClientDataset(Trans).DBTransaction) then
    Exit;

  if (TIBClientDataset(Trans).DBTransaction.InTransaction) then
    TIBClientDataset(Trans).DBTransaction.CommitRetaining;
end;

procedure TBODBISAMQuery.Rollback(Trans: TComponent);
begin
  if not Assigned(TIBClientDataset(Trans).DBTransaction) then
    Exit;

  if (TIBClientDataset(Trans).DBTransaction.InTransaction) then
    TIBClientDataset(Trans).DBTransaction.Rollback;
end;

procedure TBODBISAMQuery.StartTransaction(Trans: TComponent);
begin
  if not Assigned(TIBClientDataset(Trans).DBTransaction) then
    Exit;

  if (TIBClientDataset(Trans).DBTransaction.InTransaction) then
    TIBClientDataset(Trans).DBTransaction.CommitRetaining
  else
    TIBClientDataset(Trans).DBTransaction.StartTransaction;

{  if not Assigned(TIBQuery(Trans).Transaction) then
    Exit;

  if (TIBQuery(Trans).Transaction.InTransaction) then
    TIBQuery(Trans).Transaction.CommitRetaining
  else
    TIBQuery(Trans).Transaction.StartTransaction;}
end;

procedure TBODBISAMQuery.SetServerMethod(Query: TDataset; const Method: string);
begin

end;

function TBODBISAMQuery.GetParam(Query: TDataset;
  const ParamName: string): Variant;
begin
//  Result := TIBQuery(Query).Params.ParamByName(ParamName).Value
  Result := TIBClientDataset(Query).Params.ParamByName(ParamName).Value
end;

procedure TBODBISAMQuery.AfterOpen(Query: TDataset);
begin
//  TIBClientDataset(Query).FetchAll;
end;

initialization
  RegisterClass(TBODBISAMQuery);
  RegisterClass(TIBDatabase);
  RegisterClass(TIBTransaction);
  RegisterClass(TIBQuery);
  RegisterClass(TIBSQL);
  RegisterClass(TIBClientDataSet);

finalization
  UnRegisterClass(TBODBISAMQuery);
  UnRegisterClass(TIBDatabase);
  UnRegisterClass(TIBTransaction);
  UnRegisterClass(TIBQuery);
  UnRegisterClass(TIBSQL);
  UnRegisterClass(TIBClientDataSet);

end.


