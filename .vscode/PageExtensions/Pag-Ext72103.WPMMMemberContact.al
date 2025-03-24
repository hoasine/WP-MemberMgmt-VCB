namespace WPMemberManagementExt.WPMemberManagementExt;

pageextension 72103 WPMMMemberContact extends "LSC Member Contact"
{
    layout
    {
        //UAT-008: Add SMS field (flag) in LSBC member contact table
        addlast("General")
        {
            field("SMS"; Rec.SMS)
            {
                ApplicationArea = All;
            }
        }
        //UAT-008: Add SMS field (flag) in LSBC member contact table
    }
}
