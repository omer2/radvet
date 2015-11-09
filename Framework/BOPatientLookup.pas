unit BOPatientLookup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  cxButtonEdit, BOData;

type
  TDialogType = (dtClient, dtClientPatient);

  TBOPatientLookup = class(TcxButtonEdit)
  private
    { Private declarations }
    FDataObject: TBOData;
    FKeyValue: Integer;
    FOldText: string;
    FSrchText: string;
    FDialogType: TDialogType;
    FKeyValue2: Integer;
    FFocusPatient: Boolean;
    FShowingSearch: Boolean;

    procedure SetKeyValue(const Value: Integer);
  protected
    { Protected declarations }
    procedure DoButtonClick(AButtonVisibleIndex: Integer); override;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SetFocus; override;
    procedure Click; override;
    property KeyValue: Integer read FKeyValue write SetKeyValue;
    property KeyValue2: Integer read FKeyValue2;
  published
    { Published declarations }
    property DataObject: TBOData read FDataObject write FDataObject;
    property DialogType: TDialogType read FDialogType write FDialogType;
    property FocusPatient: Boolean read FFocusPatient write FFocusPatient;
  end;

procedure Register;

implementation

{$R 'BOPatientLookupGlyphs.res'}

uses
  FmPatientLookup, DmCommon, FmSearchBase;

procedure Register;
begin
  RegisterComponents('Business', [TBOPatientLookup]);
end;

{ TBOPatientLookup }

constructor TBOPatientLookup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKeyValue := 0;
  FOldText := '';
  FSrchText := '';
  FDialogType := dtClient;
  FFocusPatient := False;
  FShowingSearch := False;
end;

procedure TBOPatientLookup.Click;
begin
  DoButtonClick(0);
end;

procedure TBOPatientLookup.DoButtonClick(AButtonVisibleIndex: Integer);
var
  Key: Integer;
  Frm: TFrmPatientLookup;
begin
  inherited;
  FShowingSearch := True;

//  Self.Enabled := False;

  if DialogType = dtClient then
  begin
    // Client search dialog
    if TFrmSearchBase.ShowSearch(DtmCommon.PatientShortData, 'TFrmPatientEdit', FSrchText, Key) then
    begin
      KeyValue := Key;
      ChangeHandler(Self);
    end else
    begin
      if FOldText <> '' then
        Text := FOldText;
    end;

  end else
  begin
    // Client / Patient dialog
    Frm := TFrmPatientLookup.Create(Self);
    try
      if FSrchText <> '' then
        Frm.SearchText := FSrchText
      else
        Frm.SearchText := Self.Text;

//      Frm.SearchText := {FSrchText + }Self.Text;

      Frm.FocusPatient := FFocusPatient;
      if Frm.ShowModal = mrOk then
      begin
        KeyValue := Frm.KeyValue;
        FKeyValue2 := Frm.AnimalKey;
        ChangeHandler(Self);
      end;
    finally
      Frm.Free;
    end;

  end;

  FShowingSearch := False;

//  Self.Enabled := True;
end;

procedure TBOPatientLookup.DoEditKeyDown(var Key: Word; Shift: TShiftState);
begin
  if FShowingSearch then
  begin
    Key := 0;
    Exit;
  end;

  FOldText := Text;
  inherited;
  if not ((ssAlt in Shift) or (ssCtrl in Shift)) then
  begin
    FSrchText := Chr(Key);
    DoButtonClick(0);
    FOldText := '';
    FSrchText := '';
  end;
end;

procedure TBOPatientLookup.SetFocus;
begin
  inherited;
  SelectAll;
end;

procedure TBOPatientLookup.SetKeyValue(const Value: Integer);
begin
  FKeyValue := Value;
  if Assigned(FDataObject) then
  begin
    FDataObject.Open('PatientKey = ' + IntToStr(Value));
    if FDataObject.IsEmpty then
      Text := ''
    else
    begin
      if Trim(FDataObject.Fields.FieldByName('Address').AsString) = '' then
        Text := Format('%s %s',
          [FDataObject.Fields.FieldByName('FirstName').AsString,
           FDataObject.Fields.FieldByName('LastName').AsString])
      else
        Text := Format('%s %s of %s',
          [FDataObject.Fields.FieldByName('FirstName').AsString,
           FDataObject.Fields.FieldByName('LastName').AsString,
           FDataObject.Fields.FieldByName('Address').AsString]);
    end;
  end;
end;

end.
