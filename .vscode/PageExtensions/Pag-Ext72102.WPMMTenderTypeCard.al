namespace WPMemberManagementExt.WPMemberManagementExt;

pageextension 72102 WPMMTenderTypeCard extends "lsc tender type card"
{
    layout
    {
        addafter("Ask for Card/Account")
        {
            group("VCB Integration")
            {
                field("EFT Type"; Rec."EFT Type")
                {
                    Caption = 'EFT Type';
                    ApplicationArea = All;
                }
            }
        }
    }
}
