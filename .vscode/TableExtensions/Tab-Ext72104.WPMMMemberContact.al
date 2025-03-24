namespace WPMemberManagementExt.WPMemberManagementExt;

tableextension 72104 WPMMMemberContact extends "LSC Member Contact"
{
    //UAT-008: Add SMS field (flag) in LSBC member contact table
    fields
    {
        field(72100; "SMS"; Boolean)
        {
            Caption = 'SMS';
            DataClassification = ToBeClassified;
        }
    }
    //UAT-008: Add SMS field (flag) in LSBC member contact table
}
