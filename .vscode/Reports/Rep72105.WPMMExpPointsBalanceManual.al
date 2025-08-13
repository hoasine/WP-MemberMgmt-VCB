namespace WPMemberManagementExt.WPMemberManagementExt;

report 72105 "WPMM Exp. Member PB Manual"
{
    ApplicationArea = All;
    Caption = 'TKVN Exp. Member Points Balance Manual';
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
        MemberPointEntry: Record "WP Member Point Summary Report";
    begin
        // MemberPointEntry.SetRange("DateCreate", DateFilter);
        XmlPort.Run(72102, false, false, MemberPointEntry);
    end;

    var
        DateFilter: Date;
}
