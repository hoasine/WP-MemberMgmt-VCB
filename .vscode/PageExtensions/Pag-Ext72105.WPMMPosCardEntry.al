namespace WPMemberManagementExt.WPMemberManagementExt;

pageextension 72105 WPMMPosCardEntry extends "LSC POS Card Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Card Number"; Rec."Card Number")
            {
                ApplicationArea = All;
                ToolTip = 'Card Number of POS Card Entries.';
            }
        }
    }
}
