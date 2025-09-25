table 72106 "WP Member Point Summary Report"
{
    Caption = 'WP Member Point Summary Report';
    DataClassification = ToBeClassified;
    fields
    {
        //UAT-001: Outgoing file to Teko: to check with Teko if can add Member Point Balance
        field(1; "ID"; Text[500])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(12; "Card No."; Text[100])
        {
            Caption = 'Card No.';
            DataClassification = CustomerContent;
        }
        field(2; "Account No_"; Text[100])
        {
            Caption = 'Account No_';
            DataClassification = CustomerContent;
        }
        field(3; "Phone No"; Text[50])
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
        field(13; "DateCreate"; DateTime)
        {
            Caption = 'DateCreate';
            DataClassification = CustomerContent;
        }
        field(14; "DateTxt"; Text[500])
        {
            Caption = 'DateTxt';
            DataClassification = CustomerContent;
        }
        field(15; "SystemCreatedAtTxt"; Text[500])
        {
            Caption = 'SystemCreatedAtTxt';
            DataClassification = CustomerContent;
        }
        field(16; "SMS"; Boolean)
        {
            Caption = 'SMS';
            DataClassification = CustomerContent;
        }
        field(17; "Total Point Txt"; Text[500])
        {
            Caption = 'TotalPointTxt';
            DataClassification = CustomerContent;
        }
        field(18; "Vip Processing Txt"; Text[500])
        {
            Caption = 'VipProcessingTxt';
            DataClassification = CustomerContent;
        }
        field(19; "Vip Processing Decimal"; Decimal)
        {
            Caption = 'Vip Processing Decimal';
            DataClassification = CustomerContent;
        }
        // field(17; "DateFilter"; Date)
        // {
        //     Caption = 'DateFilter';
        //     DataClassification = CustomerContent;
        // }
    }

    keys
    {
        key(Key1; "ID", DateCreate)
        {
            Clustered = true;
        }
    }
}
