namespace WPMemberManagementExt.WPMemberManagementExt;
codeunit 72102 CommandPos
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidAndCopyTransaction', '', false, false)]
    local procedure OnBeforeVoidAndCopyTransaction(var Transaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
        if (Transaction."Sale Is Return Sale" = true) or (Transaction."Refund Receipt No." <> '') then begin

            IsHandled := true;
        end else begin
            Transaction."Sale Is Cancel Sale" := true;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTransactionTendered2', '', false, false)]
    local procedure OnAfterTransactionTendered2(var IsHandled: Boolean);
    var
        lrecrs: Record "LSC Retail Setup";
    begin
        clear(LRecRS);
        lrecrs.get;
        if (lrecrs."Enable Copy Trans. Print" = true) then begin
            if Confirm('This action will copy the current transaction into a new transaction. Please click "Yes" to continue the process?') = false then begin
                IsHandled := true;
            end
            else begin
                IsHandled := false;
            end;
        end else begin
            IsHandled := true;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnProcessRefundSelection', '', false, false)]
    internal procedure OnProcessRefundSelection(OriginalTransaction: Record "LSC Transaction Header"; var POSTransaction: Record "LSC POS Transaction"; isPostVoid: Boolean)
    begin
        if OriginalTransaction."Sale Is Cancel Sale" = true then begin
            POSTransaction."Sale Is Cancel Sale" := true;
            POSTransaction.Modify;

            OriginalTransaction."Sale Is Cancel Sale" := false;
            OriginalTransaction.Modify;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterPostTransactionFiscalProcess', '', false, false)]
    local procedure OnAfterPostTransactionFiscalProcess(var TransactionHeader: Record "LSC Transaction Header"; var FiscalProcessActive: Boolean; var FiscalProcessOk: Boolean; var POSTransaction: Record "LSC POS Transaction")
    var
        tbTransH: Record "LSC Transaction Header";
    begin
        if POSTransaction."Sale Is Cancel Sale" = true then begin
            Clear(tbTransH);
            tbTransH.SetRange("Receipt No.", TransactionHeader."Receipt No.");
            tbTransH.SetRange("Store No.", TransactionHeader."Store No.");
            tbTransH.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
            if tbTransH.FindFirst() then begin
                tbTransH."Sale Is Cancel Sale" := true;
                tbTransH.Modify(true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintToWindowsPrinter', '', false, false)]
    local procedure OnBeforePrintToWindowsPrinter(var PrinterName: Text; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        tbTransH: Record "LSC Transaction Header";
    begin
        IsHandled := true;
    end;


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintSalesSlip', '', false, false)]
    // local procedure OnBeforePrintSalesSlip(var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean; var ReturnValue: Boolean)
    // var
    //     GenPosFunc: Record "LSC POS Func. Profile";
    //     Store: Record "LSC Store";
    //     Count: Decimal;
    //     i: Integer;
    // begin
    //     IsHandled := true;

    //     IF Transaction."Transaction No." = 0 THEN
    //         ReturnValue := TRUE;

    //     Store.Get(Transaction."Store No.");
    //     GenPosFunc.Get('#TKV');

    //     // WindowInitialize();
    //     IF GenPosFunc."Sales Slip Report ID" <> 0 THEN BEGIN
    //         //LS-7622-
    //         IF Transaction."Sale Is Return Sale" THEN BEGIN
    //             COMMIT;
    //             ReturnValue := TRUE;
    //         END;
    //         Transaction.SETRANGE("Store No.", Transaction."Store No.");
    //         Transaction.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
    //         Transaction.SETRANGE("Transaction No.", Transaction."Transaction No.");
    //         //NWV-WAT1.0 FIX01 +
    //         // IF CheckPrintCopyTenderType(Transaction) THEN
    //         // Count := GenPosFunc."No. Of Print Copy";
    //         Count := 1;

    //         FOR i := 0 TO Count DO BEGIN
    //             if i = 0 then
    //                 Transaction."Is Print of Copy" := false;

    //             REPORT.RUN(GenPosFunc."Sales Slip Report ID", FALSE, TRUE, Transaction);
    //             // Transaction."No. of Invoices" += 1;  // NWV-WAT1.0 - FIX1.0
    //             // Transaction.MODIFY;  // NWV-WAT1.0 - FIX1.0
    //         END;
    //     end;
    // end;

    // LOCAL procedure CheckPrintCopyTenderType(pTransactionHeader: Record "Transaction Header"): Boolean
    // begin
    //     lRec_TransPaymentEntry.SETRANGE("Store No.", pTransactionHeader."Store No.");
    //     lRec_TransPaymentEntry.SETRANGE("POS Terminal No.", pTransactionHeader."POS Terminal No.");
    //     lRec_TransPaymentEntry.SETRANGE("Transaction No.", pTransactionHeader."Transaction No.");
    //     IF lRec_TransPaymentEntry.FINDSET THEN
    //         REPEAT
    //             IF lRec_TenderType.GET(lRec_TransPaymentEntry."Store No.", lRec_TransPaymentEntry."Tender Type") THEN
    //                 IF lRec_TenderType."Is Print Copy" THEN
    //                     EXIT(TRUE);
    //         UNTIL lRec_TransPaymentEntry.NEXT = 0;
    //     EXIT(FALSE);
    // end;

}
