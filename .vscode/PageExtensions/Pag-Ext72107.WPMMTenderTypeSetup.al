namespace WPMemberManagementExt.WPMemberManagementExt;

pageextension 72108 WPMMTenderTypeSetup extends "LSC Tender Type Card Setup"
{
    layout
    {
        addlast("General")
        {
            field("Tender Point"; Rec."Tender Point")
            {
                Caption = 'Tender Point';
                ApplicationArea = All;
            }
        }
    }
}
