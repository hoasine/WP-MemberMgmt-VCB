xmlport 72102 "WP Member P Balance Export"
{
    Caption = 'Member Points Balance Export';
    Format = VariableText;
    Direction = Export;
    TextEncoding = UTF8;
    TableSeparator = '<NewLine>';
    FieldSeparator = ';';
    FileName = 'member-list.csv';
    //UAT-001: Outgoing file to Teko: to check with Teko if can add Member Point Balance

    schema
    {
        textelement(RootNodeName)
        {

            tableelement(Integer; Integer)
            {
                XmlName = 'ContactHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(BlandTitle)
                {
                    trigger OnBeforePassVariable()
                    begin
                        BlandTitle := '';
                    end;
                }
                textelement(membership_card_no)
                {
                    trigger OnBeforePassVariable()
                    begin
                        membership_card_no := 'membership_card_no';
                    end;
                }
                textelement(membership_card_display)
                {
                    trigger OnBeforePassVariable()
                    begin
                        membership_card_display := 'membership_card_display';
                    end;
                }
                textelement(phone_no)
                {
                    trigger OnBeforePassVariable()
                    begin
                        phone_no := 'phone_no';
                    end;
                }
                textelement(name)
                {
                    trigger OnBeforePassVariable()
                    begin
                        name := 'name';
                    end;
                }
                textelement(email)
                {
                    trigger OnBeforePassVariable()
                    begin
                        email := 'email';
                    end;
                }
                textelement(address)
                {
                    trigger OnBeforePassVariable()
                    begin
                        address := 'address';
                    end;
                }
                textelement(tier_code)
                {
                    trigger OnBeforePassVariable()
                    begin
                        tier_code := 'tier_code';
                    end;
                }
                textelement(current_point)
                {
                    trigger OnBeforePassVariable()
                    begin
                        current_point := 'current_point';
                    end;
                }
                textelement(expire_point_date)
                {
                    trigger OnBeforePassVariable()
                    begin
                        expire_point_date := 'expire_point_date';
                    end;
                }
                textelement(expire_vip_date)
                {
                    trigger OnBeforePassVariable()
                    begin
                        expire_vip_date := 'expire_vip_date';
                    end;
                }
                textelement(vip_processing)
                {
                    trigger OnBeforePassVariable()
                    begin
                        vip_processing := 'vip_processing';
                    end;
                }

                textelement(sms)
                {
                    trigger OnBeforePassVariable()
                    begin
                        sms := 'sms';
                    end;
                }
            }

            tableelement(TempSummaryRec; "WP Member Point Summary Report")
            {
                textelement(Blandtxt)
                {
                }
                fieldelement(CardNo; TempSummaryRec."Card No.")
                {
                    Description = 'membership_card_no';
                }
                fieldelement(CardNoDisplay; TempSummaryRec."Card No.")
                {
                    Description = 'membership_card_display';
                }
                fieldelement(PhoneNo; TempSummaryRec."Phone No")
                {
                    Description = 'phone_no';
                }
                fieldelement(Name; TempSummaryRec.Name)
                {
                    Description = 'name';
                }
                fieldelement(Email; TempSummaryRec.Email)
                {
                    Description = 'email';
                }
                fieldelement(Address; TempSummaryRec.Address)
                {
                    Description = 'address';
                }
                fieldelement(TierCode; TempSummaryRec."Tier Code")
                {
                    Description = 'tier_code';
                }
                fieldelement(TotalPoint; TempSummaryRec."Total Point")
                {
                    Description = 'current_point';
                }
                textelement(ExpirePointDatetxt)
                {
                    Description = 'expire_point_date';
                }
                textelement(ExpireVipDatetxt)
                {
                    Description = 'expire_vip_date';
                }
                fieldelement(VipProcessing; TempSummaryRec."Vip Processing")
                {
                    Description = 'vip_processing';
                }

                fieldelement(SMS; TempSummaryRec."SMS")
                {
                    Description = 'sms';
                }

                trigger OnAfterGetRecord()
                begin
                    ExpirePointDatetxt := FORMAT(TempSummaryRec."Expire Point Date", 0, '<Year4><Month,2><Day,2>');
                    ExpireVipDatetxt := FORMAT(TempSummaryRec."Expire Vip Date", 0, '<Year4><Month,2><Day,2>');
                end;
            }
        }
    }

    var
        LRecMemberConact: Record "LSC Member Contact";
        LRecMemberPoints: Record "LSC Member Point Entry";
        LRecMemberPointsTotal: Record "LSC Member Point Entry";

        TempSummary: Record "WP Member Point Summary Report";
        LRecMemberSaleEntry: Record "LSC Member Sales Entry";
        MemberAttributesRec: Record "LSC Member Attribute Value";

    trigger OnPreXmlPort()
    var
        begindate: Date;
        enddate: Date;

    begin
        currXMLport.Filename := format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hour,2><Minute,2><Second,2>') + '_member-list.csv';

        // Clear temporary summary table
        TempSummary.Reset();
        TempSummary.DeleteAll();
        Commit();

        Clear(LRecMemberPoints);

        LRecMemberPoints.setrange("Date", today());
        LRecMemberPoints.SETFILTER("Remaining Points", '>%1', 0);
        // LRecMemberPoints.setrange("Account No.", '0327390810');

        if (TempSummaryRec."Card No." <> '') then begin
            LRecMemberPoints.setrange("Card No.", TempSummaryRec."Card No.");
        end;

        if (TempSummaryRec."Account No_" <> '') then begin
            LRecMemberPoints.setrange("Account No.", TempSummaryRec."Account No_");
        end;

        if LRecMemberPoints.FindSet() then begin
            repeat
                TempSummary.SetRange("Account No_", LRecMemberPoints."Account No.");
                if not TempSummary.FindFirst() then begin
                    TempSummary.Init();
                    clear(LRecMemberConact);
                    LRecMemberConact.setrange("Account No.", LRecMemberPoints."Account No.");
                    LRecMemberConact.FindFirst();

                    clear(LRecMemberSaleEntry);
                    LRecMemberSaleEntry.setrange("Member Account No.", LRecMemberPoints."Account No.");
                    LRecMemberSaleEntry.CalcSums("Gross Amount");

                    TempSummary.DateCreate := CurrentDateTime();
                    TempSummary.ID := CreateGuid();
                    TempSummary."Card No." := LRecMemberPoints."Card No.";
                    TempSummary."Account No_" := LRecMemberPoints."Account No.";
                    TempSummary."Phone No" := LRecMemberConact."Phone No.";
                    TempSummary.Name := LRecMemberConact.Name;
                    TempSummary.Address := LRecMemberConact.Address;
                    TempSummary."Tier Code" := LRecMemberConact."Scheme Code";
                    TempSummary."Total Point" := 0;
                    TempSummary.SMS := LRecMemberConact.SMS;

                    clear(MemberAttributesRec);
                    MemberAttributesRec.setrange("Account No.", LRecMemberPoints."Account No.");
                    if MemberAttributesRec.FindSet() then begin
                        repeat
                            // Check if the attribute is related to the current customer
                            if MemberAttributesRec."Attribute Code" = 'BEGINDATE' then begin
                                EVALUATE(begindate, MemberAttributesRec."Attribute Value");
                            end;

                            if MemberAttributesRec."Attribute Code" = 'ENDDATE' then begin
                                EVALUATE(enddate, MemberAttributesRec."Attribute Value");
                            end;

                        until MemberAttributesRec.Next() = 0;
                    end;

                    if (LRecMemberConact."Scheme Code" = 'VIP') then begin
                        TempSummary."Expire Vip Date" := enddate;
                    end else
                        ;

                    TempSummary."Expire Point Date" := LRecMemberPoints."Expiration Date";
                    TempSummary."Vip Processing" := -LRecMemberSaleEntry."Gross Amount";
                    TempSummary."Email" := LRecMemberConact."E-Mail";
                    TempSummary."DateTxt" := FORMAT(today(), 0, '<Year4><Month,2><Day,2>');
                    TempSummary."SystemCreatedAtTxt" := format(CurrentDateTime(), 0, '<Month,2>/<Day,2>/<Year4> <Hour,2>:<Minute,2>');

                    clear(LRecMemberPointsTotal);
                    LRecMemberPointsTotal.setrange("Account No.", LRecMemberPoints."Account No.");
                    LRecMemberPointsTotal.CalcSums("Remaining Points");
                    TempSummary."Total Point" := LRecMemberPointsTotal."Remaining Points";

                    TempSummary.Insert();
                    Commit();
                end;

                // TempSummary."Total Point" += LRecMemberPoints."Remaining Points";
                // TempSummary.Modify();
                Commit();
            until LRecMemberPoints.Next() = 0;
        end;
    end;
}
