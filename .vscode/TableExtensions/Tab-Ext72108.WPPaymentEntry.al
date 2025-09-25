tableextension 72108 wpPaymentEntry extends "LSC Trans. Payment Entry"
{
    fields
    {
        field(6023; "Card Number"; text[200])
        {
            Caption = 'Card Number';
            DataClassification = ToBeClassified;
        }
    }
}
