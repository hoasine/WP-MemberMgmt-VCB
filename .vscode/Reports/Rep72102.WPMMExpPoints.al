namespace WPMemberManagementExt.WPMemberManagementExt;

report 72102 "WPMM Exp. Member Points"
{
    ApplicationArea = All;
    Caption = 'TKVN Exp. Member Points';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    trigger OnPreReport()

    begin
        XmlPort.Run(72101);
    end;
}
