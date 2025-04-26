namespace WPMemberManagementExt.WPMemberManagementExt;

pageextension 72104 WPMMTransactionHeader extends "LSC Transaction Card"
{
    layout
    {
        addbefore("Sale Is Return Sale")
        {
            field("Sale Is Cancel Sale"; Rec."Sale Is Cancel Sale")
            {
                ApplicationArea = All;
            }
        }
    }
}
