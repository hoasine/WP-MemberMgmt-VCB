namespace WPMemberManagementExt.WPMemberManagementExt;

codeunit 72101 WPEFTUtils
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertLineInsertPaymentLine', '', false, false)]
    internal procedure OnBeforeInsertLineInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        LRecTT: Record "LSC Tender Type";
        LRecPOSTerm: Record "LSC POS Terminal";
        LRecCE: record "LSC POS Card Entry";
        URL: text;
        TranType: text;
        ResponseMsg: text;
        nextEntryNo: Integer;
    begin

        clear(LRecPOSTerm);
        LRecPOSTerm.setrange("Store No.", POSTransaction."Store No.");
        LRecPOSTerm.setrange("No.", POSTransaction."POS Terminal No.");
        if LRecPOSTerm.FindFirst() then begin
            if LRecPOSTerm."Enable VCB Integration" = false then exit;
        end;

        clear(LRecTT);
        lrectt.setrange("Code", TenderTypeCode);
        lrectt.setrange("Store No.", POSTransaction."Store No.");
        if lrectt.FindFirst() then begin
            if lrectt."EFT Type" = lrectt."EFT Type"::"VCB Cards" then begin

            end else begin
                exit;
            end;
        end;

        //debug
        // SendToEFT('http://localhost:5000/api/DoTest?HostName=localhost&PortNo=5000&TimeOut=60', ResponseMsg);
        // exit;
        //debug

        if POSTransaction."Sale Is Return Sale" then begin
            cleaR(LRecCE);
            LRecCE.setrange("Store No.", POSTransaction."Retrieved from Store No.");
            LRecCE.setrange("Pos Terminal No.", POSTransaction."Retrieved from POS Term. No.");
            lrecce.setrange("Transaction No.", POSTransaction."Retrieved from Trans. No.");
            LRecCE.setrange("Authorisation Ok", true);
            if LRecCE.FindFirst() then begin
                TranType := StrSubstNo('DoVoid?HostName=%1&PortNo=%2&TimeOut=%3&TerminalID=%4&InvoiceID=%5&Amount=%6&MaxRetries=%7', LRecPOSTerm."VCB Host Name", LRecPOSTerm."VCB Port No", LRecPOSTerm."VCB Time Out", LRecPOSTerm."VCB Terminal ID", LRecCE."EFT Transaction ID", Format(PaymentAmount, 0, '<Integer>'), LRecPOSTerm."VCB Max Retries");
            end else begin
                exit;
            end;
        end else begin
            TranType := StrSubstNo('DoSales?HostName=%1&PortNo=%2&TimeOut=%3&TerminalID=%4&ReceiptNo=%5&Amount=%6&CurrencyCode=%7&MaxRetries=%8', LRecPOSTerm."VCB Host Name", LRecPOSTerm."VCB Port No", LRecPOSTerm."VCB Time Out", LRecPOSTerm."VCB Terminal ID", POSTransaction."Receipt No.", Format(PaymentAmount, 0, '<Integer>'), POSTransLine."Currency Code", LRecPOSTerm."VCB Max Retries");
        end;
        // Build the URL with parameters
        Url := StrSubstNo(LRecPOSTerm."VCB Payment Service URL", TranType);
        LogText(POSTransaction."Receipt No.", 'EFT Request', Url);
        if SendToEFT(url, ResponseMsg) = true then begin
            Message('Response return: ' + ResponseMsg);
            LogText(POSTransaction."Receipt No.", 'EFT Response', ResponseMsg);
            ParseRespMsg(ResponseMsg);
            if gAMOUNT = '' then begin
                // Handle error
                POSGUI.PosMessage(StrSubstNo('Error: Invalid Auth. Amount "%1"\Expected Amount "%2"', gAMOUNT, format(PaymentAmount, 0, '<Integer>')));
                error('');
            end;
            if gerror = '' then begin
                clear(LRecCE);
                LRecCE.setrange("Store No.", POSTransaction."Store No.");
                LRecCE.setrange("Pos Terminal No.", POSTransaction."POS Terminal No.");
                if LRecCE.FindLast() then
                    nextEntryNo := LRecCE."Entry No." + 1
                else
                    nextEntryNo := 1;

                clear(LRecCE);
                LRecCE."Store No." := POSTransaction."Store No.";
                lrecce."POS Terminal No." := POSTransaction."POS Terminal No.";
                LRecCE."Entry No." := nextEntryNo;
                lrecce."Line No." := POSTransLine."Line No.";
                LRecCE."Receipt No." := POSTransaction."Receipt No.";
                lrecce."Tender Type" := TenderTypeCode;
                if POSTransaction."Sale Is Return Sale" then
                    LRecCE."Transaction Type" := LRecCE."Transaction Type"::"Void Sale"
                else
                    LRecCE."Transaction Type" := LRecCE."Transaction Type"::Sale;
                LRecCE.Date := today;
                lrecce.Time := time;
                if gRESPONSE_CODE = '00' then
                    LRecCE."Authorisation Ok" := true;
                LRecCE."Card Number" := gPAN;
                lrecce."Card Type" := gCARD_TYPE;
                LRecCE."Res.code" := gRESPONSE_CODE;
                lrecce."EFT Auth.code" := gAPPV_CODE;
                lrecce."EFT Merchant No." := gMERCHANT_CODE;
                lrecce."EFT Trans. Date" := gDATE;
                lrecce."EFT Trans. Time" := gTIME;
                if gAMOUNT <> '' then
                    Evaluate(LRecCE.Amount, gamount);
                lrecce."EFT Transaction ID" := gINVOICE;
                lrecce."EFT Currency" := gCURRENCY_CODE;
                lrecce."EFT Terminal ID" := gTERMINAL_ID;
                lrecce."EFT Trans. No." := gREF_NO;
                lrecce."EFT Batch No." := gREF_ID;
                lrecce."EFT Additional ID" := gSERIAL_NUMBER;
                lrecce."Auth. Source Code" := gPROC_CODE;
                lrecce."Extra Data" := gNAME;
                LRecCE.INSERT(true);
            end else begin
                // Handle error
                POSGUI.PosMessage(StrSubstNo('Error: %1', gERROR));
                error('');
            end;
        end else begin
            POSGUI.PosMessage(StrSubstNo('SendToEFT Error: %1', gERROR));
            error('');
        end;
    end;

    internal procedure LogText(pheader: code[20]; ptitle: text[50]; pText: Text[2048]);
    var
        lreccom: Record "LSC Comment";
        nextlineno: Integer;
    begin
        clear(lreccom);
        lreccom.setrange("Linked Record Id Text", pheader);
        if lreccom.FindLast() then
            nextlineno := lreccom."Line No." + 1
        else
            nextlineno := 1;
        clear(lreccom);
        lreccom."Line No." := nextlineno;
        lreccom."Linked Record Id Text" := pheader;
        lreccom.Comment := pText;
        lreccom."Comment Category Description" := ptitle;
        lreccom.insert;
    end;

    internal procedure SendToEFT(Url: Text; var ResponseText: text): Boolean;
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
    begin
        // //debug
        // ResponseText := '/APP:PAYMENT_STD;PROC_CODE:000000;DATE:1206;TIME:102158;REF_NO:192320389537;APPV_CODE:440100;RESPONSE_CODE:00;TERMINAL_ID:66666666;CARD_TYPE:VISA;MERCHANT_CODE:666666666666666;REF_ID:00001999;CURRENCY_CODE:704;SERIAL_NUMBER:1851575784;PAN:4835-****-****-3666;NAME: /;INVOICE:000067;AMOUNT:300000;SEND:OK;';//SALE
        // exit(true);
        // //debug

        // Send the GET request
        if HttpClient.Get(Url, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode then begin
                //Gán giá trị sau khi thanh toán thành công
                HttpResponseMessage.Content().ReadAs(ResponseText);
                exit(true);
            end else begin
                POSGUI.PosMessage(StrSubstNo('Failed to send request. Status code: %1', HttpResponseMessage.HttpStatusCode()));
                exit(false);
            end;
        end else begin
            POSGUI.PosMessage('Failed to send request.');
            exit(false);
        end;
    end;

    procedure ParseRespMsg(responeMsg: Text);
    var
        ResponseArray: list of [Text];
        i: Integer;
        RespField: Text;
        FieldArray: list of [Text];
        Field: text;

    begin
        //responeMsg := '#APP:PAYMENT_STD;ERROR:0200;SEND:OK;';//ERROR
        //responeMsg := '/APP:PAYMENT_STD;PROC_CODE:000000;DATE:1206;TIME:102158;REF_NO:192320389537;APPV_CODE:440100;RESPONSE_CODE:00;TERMINAL_ID:66666666;CARD_TYPE:VISA;MERCHANT_CODE:666666666666666;REF_ID:00001999;CURRENCY_CODE:704;SERIAL_NUMBER:1851575784;PAN:4835-****-****-3666;NAME: /;INVOICE:000067;AMOUNT:300000;SEND:OK;';//SALE
        //responeMsg := '/APP:PAYMENT_STD;PROC_CODE:020000;DATE:1206;TIME:102526;REF_NO:737670050806;APPV_CODE:440100;RESPONSE_CODE:00;TERMINAL_ID:66666666;CARD_TYPE:VISA;MERCHANT_CODE:666666666666666;REF_ID:00001999;CURRENCY_CODE:704;SERIAL_NUMBER:1851575784;PAN:4835-****-****-3666;NAME: /;INVOICE:000067;AMOUNT:300000;SEND:OK;';//void
        responeMsg := copystr(responeMsg, 2);

        Message('Content 3:' + responeMsg);

        ResponseArray := responeMsg.Split(';');
        foreach respfield in responsearray do begin
            FieldArray := RespField.Split(':');
            case FieldArray.Get(1) of
                'APP':
                    BEGIN
                        gapp := FieldArray.Get(2);
                    END;
                'ERROR':
                    BEGIN
                        gERROR := FieldArray.Get(2);
                    END;
                'SEND':
                    BEGIN
                        gsend := FieldArray.Get(2);
                    END;
                'PROC_CODE':
                    BEGIN
                        gPROC_CODE := FieldArray.Get(2);
                    END;
                'DATE':
                    BEGIN
                        gDATE := FieldArray.Get(2);
                    END;
                'TIME':
                    BEGIN
                        gTIME := FieldArray.Get(2);
                    END;
                'REF_NO':
                    BEGIN
                        gREF_NO := FieldArray.Get(2);
                    END;
                'APPV_CODE':
                    BEGIN
                        gAPPV_CODE := FieldArray.Get(2);
                    END;
                'RESPONSE_CODE':
                    BEGIN
                        gRESPONSE_CODE := FieldArray.Get(2);
                    END;
                'TERMINAL_ID':
                    BEGIN
                        gTERMINAL_ID := FieldArray.Get(2);
                    END;
                'CARD_TYPE':
                    BEGIN
                        gCARD_TYPE := FieldArray.Get(2);
                    END;
                'MERCHANT_CODE':
                    BEGIN
                        gMERCHANT_CODE := FieldArray.Get(2);
                    END;
                'REF_ID':
                    BEGIN
                        gREF_ID := FieldArray.Get(2);
                    END;
                'CURRENCY_CODE':
                    BEGIN
                        gCURRENCY_CODE := FieldArray.Get(2);
                    END;
                'SERIAL_NUMBER':
                    BEGIN
                        gSERIAL_NUMBER := FieldArray.Get(2);
                    END;
                'PAN':
                    BEGIN
                        gPAN := FieldArray.Get(2);
                    END;
                'NAME':
                    BEGIN
                        gNAME := FieldArray.Get(2);
                    END;
                'INVOICE':
                    BEGIN
                        gINVOICE := FieldArray.Get(2);
                    END;
                'AMOUNT':
                    BEGIN
                        gAMOUNT := FieldArray.Get(2);
                    END;
            end;
        end;
    end;


    var
        POSGUI: Codeunit "LSC POS GUI";
        Session: Codeunit "LSC POS Session";
        gAPP: Text;
        gERROR: Text;
        gSEND: Text;
        gPROC_CODE: Text;
        gDATE: Text;
        gTIME: Text;
        gREF_NO: Text;
        gAPPV_CODE: Text;
        gRESPONSE_CODE: Text;
        gTERMINAL_ID: Text;
        gCARD_TYPE: Text;
        gMERCHANT_CODE: Text;
        gREF_ID: Text;
        gCURRENCY_CODE: Text;
        gSERIAL_NUMBER: Text;
        gPAN: Text;
        gNAME: Text;
        gINVOICE: Text;
        gAMOUNT: Text;
}
