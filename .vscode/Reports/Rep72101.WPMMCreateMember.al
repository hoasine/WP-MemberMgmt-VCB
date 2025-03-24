namespace WPMemberManagementExt.WPMemberManagementExt;

report 72101 "WPMM Create Member"
{
    ApplicationArea = All;
    Caption = 'TKVN Create Members';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        cu: Codeunit "WPMemberMgtUtils";
    begin
        cu.CreateNewMemberCard();
    end;
}
