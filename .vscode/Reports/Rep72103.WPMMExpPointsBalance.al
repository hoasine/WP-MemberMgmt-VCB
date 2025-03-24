namespace WPMemberManagementExt.WPMemberManagementExt;

report 72103 "WPMM Exp. Member P Balance"
{
    ApplicationArea = All;
    Caption = 'TKVN Exp. Member Points Balance';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    trigger OnPreReport()

    begin
        //UAT-001: Outgoing file to Teko: to check with Teko if can add Member Point Balance
        XmlPort.Run(72102);
    end;
}
