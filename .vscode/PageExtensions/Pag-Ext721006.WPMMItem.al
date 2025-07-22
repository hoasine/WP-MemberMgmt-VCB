pageextension 72106 "WPMMItem" extends "LSC Retail Item Card"
{
    layout
    {
        addlast(General)
        {
            field("Tax Rate"; TaxRate)
            {
                ApplicationArea = All;
            }
        }
    }

    var
        TaxRate: Decimal;

    trigger OnAfterGetRecord()
    var
        tbVatPosting: Record "VAT Posting Setup";

    begin
        Clear(tbVatPosting);
        tbVatPosting.SetRange("VAT Prod. Posting Group", Rec."VAT Prod. Posting Group");
        tbVatPosting.SetRange("VAT Bus. Posting Group", 'DOMESTIC_OUT');
        if tbVatPosting.FindFirst() then begin
            TaxRate := tbVatPosting."VAT %";
        end else
            TaxRate := 0;
    end;
}

pageextension 72107 "WPMMItemList" extends "LSC Retail Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("Tax Rate"; TaxRate)
            {
                ApplicationArea = All;
            }
        }
    }

    var
        TaxRate: Decimal;

    trigger OnAfterGetRecord()
    var
        tbVatPosting: Record "VAT Posting Setup";

    begin
        Clear(tbVatPosting);
        tbVatPosting.SetRange("VAT Prod. Posting Group", Rec."VAT Prod. Posting Group");
        tbVatPosting.SetRange("VAT Bus. Posting Group", 'DOMESTIC_OUT');
        if tbVatPosting.FindFirst() then begin
            TaxRate := tbVatPosting."VAT %";
        end else
            TaxRate := 0;
    end;
}