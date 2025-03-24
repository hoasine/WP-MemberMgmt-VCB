namespace WPMemberManagementExt.WPMemberManagementExt;

pageextension 72101 WPMMPOSTerminalCard extends "LSC POS Terminal Card"
{
    layout
    {
        addafter(EFT)
        {
            group("VCB Integration Setup")
            {
                field("Enable VCB Integration"; Rec."Enable VCB Integration")
                {
                    ApplicationArea = All;
                }
                field("VCB Payment Service URL"; Rec."VCB Payment Service URL")
                {
                    ApplicationArea = All;
                }
                field("VCB Host Name"; Rec."VCB Host Name")
                {
                    ApplicationArea = All;
                }
                field("VCB Port No"; Rec."VCB Port No")
                {
                    ApplicationArea = All;
                }
                field("VCB Time Out"; Rec."VCB Time Out")
                {
                    ApplicationArea = All;
                }
                field("VCB Terminal ID"; Rec."VCB Terminal ID")
                {
                    ApplicationArea = All;
                }
                field("VCB Max Retries"; Rec."VCB Max Retries")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}