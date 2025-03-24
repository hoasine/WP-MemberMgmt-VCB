namespace WPMemberManagementExt.WPMemberManagementExt;

tableextension 72102 WPMMPOSTerminal extends "LSC POS Terminal"
{
    fields
    {
        field(72100; "Enable VCB Integration"; Boolean)
        {
            Caption = 'Enable VCB Integration';
            DataClassification = ToBeClassified;
        }
        field(72101; "VCB Payment Service URL"; Text[30])
        {
            Caption = 'VCB Payment Service URL';
            DataClassification = ToBeClassified;
        }
        field(72102; "VCB Host Name"; Text[16])
        {
            Caption = 'VCB Host Name';
            DataClassification = ToBeClassified;
        }
        field(72103; "VCB Port No"; Integer)
        {
            Caption = 'VCB Port No';
            DataClassification = ToBeClassified;
        }
        field(72104; "VCB Time Out"; Integer)
        {
            Caption = 'VCB Time Out';
            DataClassification = ToBeClassified;
        }
        field(72105; "VCB Terminal ID"; Text[30])
        {
            Caption = 'VCB Terminal ID';
            DataClassification = ToBeClassified;
        }
        field(72106; "VCB Max Retries"; Integer)
        {
            Caption = 'VCB Max Retries';
            DataClassification = ToBeClassified;
        }
    }
}
