xmlport 72101 "WP Member Points Export"
{
    Caption = 'Member Points Export';
    Format = VariableText;
    Direction = Export;
    TextEncoding = UTF8;
    TableSeparator = '<NewLine>';
    FieldSeparator = ',';
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
                // AutoSave = true;
                // AutoUpdate = true;
                // XmlName = 'LSCMemberPointEntry';
                // SourceTableView = sorting("Account No.", "Entry Type", "Point Type", Date);
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
                fieldelement(Points; LSCMemberPointEntry.Points)
                {
                }
                textelement(DateTxt)
                {
                }
                textelement(SystemCreatedAtTxt)
                {
                }
                textelement(DescriptionTxt)
                {
                }
                trigger OnAfterGetRecord()
                var
                    LRecTSE: record "LSC Trans. Sales Entry";
                begin
                    clear(LRecTSE);
                    lrecTSE.setrange("Store No.", LSCMemberPointEntry."Store No.");
                    lrectse.setrange("POS Terminal No.", LSCMemberPointEntry."POS Terminal No.");
                    lrectse.setrange("Transaction No.", LSCMemberPointEntry."Transaction No.");
                    if lrectse.findfirst then begin
                        lrectse.CalcFields("Item Description");
                        DescriptionTxt := lrectse."Item Description";
                    end;

                    if LSCMemberPointEntry.Points < 0 then
                        txnType := 'SPEND'
                    else
                        txnType := 'GRANT';

                    DateTxt := FORMAT(LSCMemberPointEntry."Date", 0, '<Year4><Month,2><Day,2>');
                    SystemCreatedAtTxt := format(LSCMemberPointEntry.SystemCreatedAt, 0, '<Month,2>/<Day,2>/<Year4> <Hour,2>:<Minute,2>');

                    if (LSCMemberPointEntry.Date <> today()) or (LSCMemberPointEntry.Points = 0) then
                        currXMLport.Skip();

                end;
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

        Clear(LSCMemberPointEntry);
        LSCMemberPointEntry.setrange("Date", today());
        LSCMemberPointEntry.setrange("Entry No.", grecrs."Last Point Entry No.", LastEntryNo);
        currXMLport.Filename := format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hour,2><Minute,2><Second,2>') + '_txn-history-point-list.csv';
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
}
