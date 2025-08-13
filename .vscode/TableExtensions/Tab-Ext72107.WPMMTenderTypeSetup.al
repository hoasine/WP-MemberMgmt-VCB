namespace WPMemberManagementExt.WPMemberManagementExt;

tableextension 72107 WPMMTenderTypeSetup extends "LSC Tender Type Card Setup"
{
    fields
    {
        field(72101; "Tender Point"; Code[20])
        {
            Caption = 'Tender Point';
            DataClassification = ToBeClassified;
            TableRelation = "LSC Tender Type".Code;
        }
    }
}
