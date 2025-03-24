namespace WPMemberManagementExt.WPMemberManagementExt;

tableextension 72101 "WPMM Trans. Infocode Entry" extends "LSC Trans. Infocode Entry"
{
    fields
    {
        field(72100; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(72101; "Process Date"; Date)
        {
            Caption = 'Process Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(72102; "Process Time"; Time)
        {
            Caption = 'Process Time';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(72103; "Process By"; Text[100])
        {
            Caption = 'Process By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
