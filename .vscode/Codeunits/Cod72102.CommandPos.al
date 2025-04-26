namespace WPMemberManagementExt.WPMemberManagementExt;
codeunit 72102 CommandPos
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidAndCopyTransaction', '', false, false)]
    local procedure OnBeforeVoidAndCopyTransaction(var Transaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    begin
        if (Transaction."Sale Is Return Sale" = true) then begin
            Error(StrSubstNo('No lines were eligible for refund from Receipt %1', Transaction."Receipt No."));
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
}
