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

            tableelement(TempSummary; "WP Member Point Summary Report")
            {
                textelement(Blandtxt)
                {
                }
                fieldelement(CardNo; TempSummary."Account No_")
                {
                    Description = 'membership_card_no';
                }
                fieldelement(CardNoDisplay; TempSummary."Card No.")
                {
                    Description = 'membership_card_display';
                }
                fieldelement(PhoneNo; TempSummary."Phone No")
                {
                    Description = 'phone_no';
                }
                fieldelement(Name; TempSummary.Name)
                {
                    Description = 'name';
                }
                fieldelement(Email; TempSummary.Email)
                {
                    Description = 'email';
                }
                fieldelement(Address; TempSummary.Address)
                {
                    Description = 'address';
                }
                fieldelement(TierCode; TempSummary."Tier Code")
                {
                    Description = 'tier_code';
                }
                fieldelement(TotalPointtxt; TempSummary."Total Point Txt")
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
                fieldelement(VipProcessing; TempSummary."Vip Processing")
                {
                    Description = 'vip_processing';
                }
                fieldelement(SMS; TempSummary."SMS")
                {
                    Description = 'sms';
                }
                trigger OnAfterGetRecord()
                begin
                    ExpirePointDatetxt := FORMAT(TempSummary."Expire Point Date", 0, '<Year4><Month,2><Day,2>');
                    ExpireVipDatetxt := FORMAT(TempSummary."Expire Vip Date", 0, '<Year4><Month,2><Day,2>');
                end;
            }
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Option)
                {
                    field("Date"; DateFilter)
                    {

                    }
                }
            }
        }
    }

    var
        LRecMemberConact: Record "LSC Member Contact";
        LRecMemberPoints: Record "LSC Member Point Entry";
        LRecMemberPointsTotal: Record "LSC Member Point Entry";
        LRecMemberSaleEntry: Record "LSC Member Sales Entry";
        MemberAttributesRec: Record "LSC Member Attribute Value";

    trigger OnPreXmlPort()
    var
        begindate: Date;
        enddate: Date;
        ConvertedDate: Date;
        check: Decimal;
        tbMembeShipCard: Record "LSC Membership Card";

        CurrentDateY: Date;
        StartDateY: Date;
        EndDateY: Date;
        YearOfInputY: Integer;
        DateYFilter: text;
    begin
        if DateFilter = 0D then begin
            DateFilter := Today()
        end;

        currXMLport.Filename := format(DateFilter, 0, '<Year4><Month,2><Day,2>') + '_member-list.csv';

        TempSummary.Reset();
        TempSummary.DeleteAll();

        Clear(LRecMemberPoints);
        LRecMemberPoints.setrange("Date", DateFilter);
        LRecMemberPoints.SETFILTER("Remaining Points", '>%1', 0);
        LRecMemberPoints.SetFilter("Card No.", '<>1000010101020099');

        // LRecMemberPoints.setrange("Account No.", '0327390810');

        // if (TempSummary."DateCreate" = 0DT) then begin
        //     LRecMemberPoints.setrange("Date", 0D);
        // end;

        // if (TempSummary."Card No." <> '') then begin
        //     LRecMemberPoints.setrange("Card No.", TempSummary."Card No.");
        // end;

        // if (TempSummary."Account No_" <> '') then begin
        //     LRecMemberPoints.setrange("Account No.", TempSummary."Account No_");
        // end;

        if LRecMemberPoints.FindSet() then begin
            repeat
                TempSummary.SetRange("Account No_", LRecMemberPoints."Account No.");
                if not TempSummary.FindFirst() then begin
                    TempSummary.Init();
                    clear(LRecMemberConact);
                    LRecMemberConact.setrange("Account No.", LRecMemberPoints."Account No.");
                    LRecMemberConact.FindFirst();

                    CurrentDateY := Today; // hoặc WorkDate nếu bạn muốn theo ngày làm việc
                    YearOfInputY := DATE2DMY(CurrentDateY, 3); // lấy năm

                    StartDateY := DMY2DATE(1, 1, YearOfInputY);
                    EndDateY := DMY2DATE(31, 12, YearOfInputY);

                    DateYFilter := Format(StartDateY, 0, '<Day,2>/<Month,2>/<Year4>') + '..' +
                         Format(EndDateY, 0, '<Day,2>/<Month,2>/<Year4>');

                    clear(LRecMemberSaleEntry);
                    LRecMemberSaleEntry.SetFilter(Date, DateYFilter);
                    LRecMemberSaleEntry.setrange("Member Account No.", LRecMemberPoints."Account No.");
                    LRecMemberSaleEntry.CalcSums("Gross Amount");

                    TempSummary.DateCreate := CurrentDateTime();
                    TempSummary.ID := CreateGuid();

                    if LRecMemberPoints."Card No." = '' then begin
                        Clear(tbMembeShipCard);
                        tbMembeShipCard.SetRange("Account No.", LRecMemberPoints."Account No.");
                        if tbMembeShipCard.FindFirst() then begin
                            TempSummary."Card No." := tbMembeShipCard."Card No.";
                        end;
                    end else begin
                        TempSummary."Card No." := LRecMemberPoints."Card No.";

                        Clear(tbMembeShipCard);
                        tbMembeShipCard.SetRange("Card No.", TempSummary."Card No.");
                        if tbMembeShipCard.FindFirst() then begin
                            // TempSummary."Card No." := tbMembeShipCard."Card No.";
                        end;
                    end;

                    TempSummary."Account No_" := LRecMemberPoints."Account No.";
                    TempSummary."Phone No" := LRecMemberConact."Mobile Phone No.";
                    TempSummary.Name := LRecMemberConact.Name;
                    TempSummary.Address := LRecMemberConact.Address;
                    TempSummary."Tier Code" := tbMembeShipCard."Scheme Code";
                    TempSummary."Total Point" := '0';
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
                    TempSummary."Total Point Txt" := Format(ABS(LRecMemberPointsTotal."Remaining Points"), 0, '<Integer>');
                    TempSummary.Insert();
                end;
            until LRecMemberPoints.Next() = 0;
        end;

        TempSummary.Reset();
        check := TempSummary.Count();
    end;

    var
        DateFilter: Date;
        DateFilterTxt: text[250];

}
