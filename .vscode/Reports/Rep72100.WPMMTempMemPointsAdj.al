namespace WPMemberManagementExt.WPMemberManagementExt;

report 72100 "WPMM Temp. Mem. Points Adj."
{
    ApplicationArea = All;
    Caption = 'TKVN Temp Member Points Adj.';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        cu: Codeunit "WPMemberMgtUtils";
    begin
        cu.UpdateMemberPoints();
    end;
}
