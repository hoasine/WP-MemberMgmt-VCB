table 72100 "WP Member Information TKV"
{
    Caption = 'WP Member Information TKV';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; membership_card_no; Text[20])
        {
            Caption = 'membership_card_no';
        }
        field(2; phone_no; Text[20])
        {
            Caption = 'phone_no';
        }
        field(3; date_of_birth; Text[8])
        {
            Caption = 'date_of_birth';
        }
        field(4; name; Text[100])
        {
            Caption = 'name';
        }
        field(5; email; Text[50])
        {
            Caption = 'email';
        }
        field(6; address; Text[200])
        {
            Caption = 'address';
        }
        field(7; gender; Text[10])
        {
            Caption = 'gender';
        }
        field(8; "Agreed advertise SMS"; Text[10])
        {
            Caption = 'Agreed advertise SMS';
        }
        field(100; FileName; Text[100])
        {
            Caption = 'File Name';
        }
        field(101; "BatchNo"; Integer)
        {
            Caption = 'Batch No.';
        }
        field(102; "Import Date"; Date)
        {
            Caption = 'Import Date';
        }
        field(200; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(201; "Processed By"; Text[100])
        {
            Caption = 'Processed By';
        }
        field(202; "Processed Date"; Date)
        {
            Caption = 'Processed Date';
        }
        field(203; "Processed Time"; Time)
        {
            Caption = 'Processed Time';
        }
    }

    keys
    {
        key(PK; membership_card_no, FileName, "Import Date")
        {
            Clustered = true;
        }
    }
}
