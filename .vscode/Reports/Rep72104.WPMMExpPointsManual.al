namespace WPMemberManagementExt.WPMemberManagementExt;

report 72104 "WPMM Exp. Member Points Cus"
{
    ApplicationArea = All;
    Caption = 'TKVN Exp. Member Points Manual';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Option)
                {
                    field("Date"; DateFilter)
                    {

                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        MemberPointEntry: Record "LSC Member Point Entry";
    begin
        MemberPointEntry.SetRange("Date", DateFilter);
        XmlPort.Run(72101, false, false, MemberPointEntry);
    end;

    var
        DateFilter: Date;
}
