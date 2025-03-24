table 72105 "WP Member Point Summary"
{
    Caption = 'WP Member Point Summary';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Card No."; Text[100])
        {
            Caption = 'Card No.';
            DataClassification = CustomerContent;
        }
        field(2; "Account No_"; Text[100])
        {
            Caption = 'Account No_';
            DataClassification = CustomerContent;
        }
        field(3; "Phone No"; Text[15])
        {
            Caption = 'Phone No';
            DataClassification = CustomerContent;
        }
        field(4; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(5; "Address"; Text[500])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(6; "Tier Code"; Text[200])
        {
            Caption = 'Tier Code';
            DataClassification = CustomerContent;
        }
        field(7; "Expire Point Date"; Date)
        {
            Caption = 'Expire Point Date';
            DataClassification = CustomerContent;
        }
        field(8; "Expire Vip Date"; Date)
        {
            Caption = 'Expire Vip Date';
            DataClassification = CustomerContent;
        }
        field(9; "Vip Processing"; Integer)
        {
            Caption = 'Vip Processing';
            DataClassification = CustomerContent;
        }
        field(10; "Total Point"; Decimal)
        {
            Caption = 'Total Point';
            DataClassification = CustomerContent;
        }
        field(11; "Email"; Text[100])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
    }

    // keys
    // {
    //     key(Key1; "ID")
    //     {
    //         Clustered = true;
    //     }
    // }
}
