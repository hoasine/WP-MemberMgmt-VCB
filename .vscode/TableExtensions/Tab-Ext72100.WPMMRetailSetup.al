namespace WPMemberManagementExt.WPMemberManagementExt;

tableextension 72100 "WPMM Retail Setup" extends "LSC Retail Setup"
{
    fields
    {
        field(72100; "Temp. Member Infocode"; Code[20])
        {
            Caption = 'Temp. Member Infocode';
            DataClassification = ToBeClassified;
            TableRelation = "LSC Infocode";
        }
        field(72101; "Temp. Member Def. Card No."; Text[100])
        {
            Caption = 'Temp. Member Def. Card No.';
            DataClassification = ToBeClassified;
        }
        field(72102; "Def. Member Club"; code[20])
        {
            Caption = 'Def. Member Club';
            DataClassification = ToBeClassified;
            TableRelation = "LSC Member Club";
        }
        field(72103; "Def. Member Scheme"; code[20])
        {
            Caption = 'Def. Member Scheme';
            DataClassification = ToBeClassified;
            TableRelation = "LSC Member Scheme";
        }
        field(72104; "Last Point Entry No."; Integer)
        {
            Caption = 'Last Point Entry No.';
            DataClassification = ToBeClassified;
        }
        field(72105; "Auto Post MP on Calc."; Boolean)
        {
            Caption = 'Auto Post MP on Calc.';
            DataClassification = ToBeClassified;
        }
    }
}
