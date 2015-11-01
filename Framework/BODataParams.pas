unit BODataParams;

//------------------------------------------------------------------------------
//
// Because there are so many variantions on how to set sql and params etc, for
// each TQuery type supported, a class will need to be created and registered
// for each different database backend
//
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Db;

type
  TBOQuery = class(TComponent)
  public
    procedure SetServerMethod(Query: TDataset; const Method: string); virtual; abstract;
    procedure CommitAll(Trans: TComponent); virtual; abstract;
    procedure Rollback(Trans: TComponent); virtual; abstract;
    procedure StartTransaction(Trans: TComponent); virtual; abstract;
    procedure ClearParams(Query: TDataset); virtual; abstract;
    procedure ExecSQL(Query: TDataset; Transaction: TComponent = nil); virtual; abstract;
    function ParamCount(Query: TDataset): Integer; virtual; abstract;
    function ParamName(Query: TDataset; Index: Integer): string; virtual; abstract;
    procedure SetConnection(Query: TDataset; Connection: TComponent; Transaction: TComponent); virtual; abstract;
    procedure SetSQL(Query: TDataset; const SQL: string); virtual; abstract;
    procedure SetParam(Query: TDataset; const ParamName: string; Value: Variant;
      ACreate: Boolean = False); virtual; abstract;
    function GetParam(Query: TDataset; const ParamName: string): Variant; virtual; abstract;
    function SQL(Query: TDataset): string; virtual; abstract;
    procedure SetOtherStuff(Query: TDataset; ABOData: TComponent); virtual; abstract;
    procedure SaveBlob(Query: TDataset; KeyValue: Integer; const ATableName, KeyField, FieldName: string; Stream: TStream); virtual; abstract;
    procedure LoadBlob(Query: TDataset; KeyValue: Integer; const ATableName, KeyField, FieldName: string; var Stream: TStream); virtual; abstract;
    procedure AfterOpen(Query: TDataset); virtual; abstract;
  end;
  TBOQueryClass = class of TBOQuery;

implementation

end.
