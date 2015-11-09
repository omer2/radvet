unit Context;

interface

type
  TContextOptions = (coMergeMenu, coMergeBar);
  TContextOptionsSet = set of TContextOptions;

  TContext = class(TObject)
  protected
    FKey: Integer;
    FMergeMenu: Boolean;
    FMergeBar: Boolean;
  public
    constructor Create(AKey: Integer; Options: TContextOptionsSet); reintroduce;
    property Key: Integer read FKey write FKey;
    property MergeBar: Boolean read FMergeBar write FMergeBar;
    property MergeMenu: Boolean read FMergeMenu write FMergeMenu;
  end;

implementation

{ TContext }

constructor TContext.Create(AKey: Integer; Options: TContextOptionsSet);
begin
  Key := AKey;
  MergeMenu := coMergeMenu in Options;
  MergeBar := coMergeBar in Options;
end;

end.
