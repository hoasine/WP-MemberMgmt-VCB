table 72101 "WP Trans. Infocode Status"
{
    Caption = 'WP Trans. Infocode Status';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
            DataClassification = CustomerContent;
        }
        field(5; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            TableRelation = "LSC Transaction Header"."Transaction No." Where("Store No." = field("Store No."),
                                                                          "POS Terminal No." = field("POS Terminal No."));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(10; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            Description = '';
            OptionCaption = 'Header,Sales Entry,Payment Entry,Income/Expense Entry,Order Entry,Periodic Discount Info';
            OptionMembers = Header,"Sales Entry","Payment Entry","Income/Expense Entry","Order Entry","Periodic Discount Info";
            DataClassification = CustomerContent;
        }
        field(15; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; Infocode; Code[20])
        {
            Caption = 'Infocode';
            NotBlank = true;
            TableRelation = "LSC Infocode".Code;
            DataClassification = CustomerContent;
        }
        field(45; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal"."No.";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(71; "Entry Line No."; Integer)
        {
            Caption = 'Entry Line No.';
            DataClassification = CustomerContent;
        }
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

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Transaction Type", "Line No.", Infocode, "Entry Line No.")
        {
            Clustered = true;
        }
    }
}
