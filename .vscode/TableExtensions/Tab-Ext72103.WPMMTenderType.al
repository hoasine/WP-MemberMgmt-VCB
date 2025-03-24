namespace WPMemberManagementExt.WPMemberManagementExt;

tableextension 72103 WPMMTenderType extends "LSC Tender Type"
{
    fields
    {
        field(72100; "EFT Type"; Option)
        {
            Caption = 'EFT Type';
            DataClassification = ToBeClassified;
            OptionMembers = " ","VCB Cards";
        }
    }
}
