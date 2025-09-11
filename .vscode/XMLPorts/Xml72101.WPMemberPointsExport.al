xmlport 72101 "WP Member Points Export"
{
    Caption = 'Member Points Export';
    Format = VariableText;
    Direction = Export;
    TextEncoding = UTF8;
    TableSeparator = '<NewLine>';
    FieldSeparator = ';';
    FileName = 'txn-history-point-list.csv';

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'MemberPoints';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(temp)
                {
                    trigger OnBeforePassVariable()
                    begin
                        temp := 'temp';
                    end;
                }
                textelement(txn_type)
                {
                    trigger OnBeforePassVariable()
                    begin
                        txn_type := 'txn_type';
                    end;
                }
                textelement(membership_card_no)
                {
                    trigger OnBeforePassVariable()
                    begin
                        membership_card_no := 'membership_card_no';
                    end;
                }
                textelement(order_code)
                {
                    trigger OnBeforePassVariable()
                    begin
                        order_code := 'order_code';
                    end;
                }
                textelement(point)
                {
                    trigger OnBeforePassVariable()
                    begin
                        point := 'point';
                    end;
                }
                textelement(txn_ref_id)
                {
                    trigger OnBeforePassVariable()
                    begin
                        txn_ref_id := 'txn_ref_id';
                    end;
                }
                textelement(ref_time)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ref_time := 'ref_time';
                    end;
                }
                textelement(description)
                {
                    trigger OnBeforePassVariable()
                    begin
                        description := 'description';
                    end;
                }
            }

            tableelement(LSCMemberPointEntry; "LSC Member Point Entry")
            {
                textelement(Blandtxt)
                {
                }
                textelement(txnType)
                {
                }
                fieldelement(CardNo; LSCMemberPointEntry."Card No.")
                {
                }
                fieldelement(DocumentNo; LSCMemberPointEntry."Document No.")
                {
                }
                textelement(txn_point)
                {
                }
                textelement(Ref_id)
                {
                }
                textelement(DateTxt)
                {
                }
                textelement(DescriptionTxt)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if DateFilter = 0D then begin
                        DateFilter := Today()
                    end;

                    LSCMemberPointEntry.setrange("Date", DateFilter);
                    LSCMemberPointEntry.SetFilter("Card No.", '<>1000010101020099');
                end;

                trigger OnAfterGetRecord()
                var
                    LRecTSE: record "LSC Trans. Sales Entry";
                    tbMembeShipCard: Record "LSC Membership Card";
                begin
                    Clear(txnType);
                    Clear(txn_point);
                    Clear(Ref_id);
                    Clear(DateTxt);
                    Clear(DescriptionTxt);

                    txn_point := FORMAT(ABS(LSCMemberPointEntry."Points"), 0, '<Integer>');

                    clear(LRecTSE);
                    lrecTSE.setrange("Store No.", LSCMemberPointEntry."Store No.");
                    lrectse.setrange("POS Terminal No.", LSCMemberPointEntry."POS Terminal No.");
                    lrectse.setrange("Transaction No.", LSCMemberPointEntry."Transaction No.");
                    if lrectse.FindSet() then begin
                        lrectse.CalcFields("Item Description");
                        DescriptionTxt := lrectse."Item Description";
                    end else
                        DescriptionTxt := '';

                    if LSCMemberPointEntry."Card No." = '' then begin
                        Clear(tbMembeShipCard);
                        tbMembeShipCard.SetRange("Account No.", LSCMemberPointEntry."Account No.");
                        if tbMembeShipCard.FindFirst() then begin
                            LSCMemberPointEntry."Card No." := tbMembeShipCard."Card No.";
                        end;
                    end else begin
                        LSCMemberPointEntry."Card No." := LSCMemberPointEntry."Card No.";
                    end;

                    if LSCMemberPointEntry.Points < 0 then
                        txnType := 'SPEND'
                    else
                        txnType := 'GRANT';

                    Ref_id := FORMAT(LSCMemberPointEntry."Date", 0, '<Day,2><Month,2>')
                    + LSCMemberPointEntry."POS Terminal No."
                    + Format(LSCMemberPointEntry."Transaction No.")
                    + Format(LSCMemberPointEntry."Entry No."); //ngày tháng pos tran 0408302trans store 

                    currXMLport.Filename := format(LSCMemberPointEntry."Date", 0, '<Year4><Month,2><Day,2>') + '_txn-history-point-list.csv';

                    DateTxt := format(LSCMemberPointEntry.SystemCreatedAt, 0, '<Year4>-<Month,2>-<Day,2> <Hour,2>:<Minute,2>:00');

                    if (LSCMemberPointEntry.Points = 0) then
                        // if (LSCMemberPointEntry.Date <> today()) or (LSCMemberPointEntry.Points = 0) then
                        currXMLport.Skip();

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

    trigger OnPreXmlPort()
    var
        LRecPE: Record "LSC Member Point Entry";
        RecordCount: Integer;
    begin
        cleaR(LRecPE);
        lrecpe.SetCurrentKey("Entry No.");
        if lrecpe.FindLast() then
            LastEntryNo := LRecPE."Entry No."
        else
            if GuiAllowed then
                error('No new data to export.')
            else
                error('');

        if GRecRS.get then;
        if grecrs."Last Point Entry No." = LastEntryNo then
            if GuiAllowed then
                error('No new data to export.')
            else
                error('');

        // LSCMemberPointEntry.setrange("Entry No.", grecrs."Last Point Entry No.", LastEntryNo);

    end;

    trigger OnPostXmlPort()
    begin
        if GRecRS.get then begin
            // GRecRS."Last Point Entry No." := LastEntryNo;
            GRecRS.Modify;
        end;
    end;

    var
        GRecRS: Record "LSC Retail Setup";
        LastEntryNo: Integer;
        DateFilter: Date;
}
