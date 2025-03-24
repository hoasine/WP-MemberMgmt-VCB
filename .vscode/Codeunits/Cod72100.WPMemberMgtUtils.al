namespace WPMemberManagementExt.WPMemberManagementExt;
codeunit 72100 WPMemberMgtUtils
{
    TableNo = "LSC POS Menu Line";
    trigger OnRun()
    var
        POSTerminal: Record "LSC POS Terminal";
        PosFuncProfile: Record "LSC POS Func. Profile";
        StoreSetup: Record "LSC Store";
        PosCommandRec: Record "LSC POS Command";
        PosCommand: Enum "LSC POS Command";
    begin
        GlobalRec := Rec;

        if Rec."Registration Mode" then begin
            Register(Rec);
            exit;
        end;

        POSTerminal.Get(POSSESSION.TerminalNo);
        StoreSetup.Get(POSTerminal."Store No.");
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID);

        POSTransFound := true;
        if PosTrans.Get(Rec."Current-RECEIPT") then begin
            if POSTransLine.Get(PosTrans."Receipt No.", Rec."Current-LINE") then;
        end else
            POSTransFound := false;


        if not POSCommandRec.CommandExists(Rec.Command) then begin
            Rec := GlobalRec;
            exit;
        end else begin
            PosCommand := poscommandrec.CommandToEnum(Rec.Command);
        end;

        // case PosCommand of
        //     PosCommand::MEMBERTEMP:
        //         MemberTempPressed;
        // end;
        Rec := GlobalRec;
    end;

    internal procedure Register(var MenuLine: Record "LSC POS Menu Line")
    var
        Module: Code[20];
        Text061: Label 'TKVN POS Commands';
        PosCommand: Enum "LSC POS Command";
        ParameterType: Enum "LSC POS Command Parameter Type";
    begin
        Module := 'TKVN';
        CommandFunc.RegisterModule(Module, Text061, 72100);
        CommandFunc.RegisterExtCommand(PosCommand::MEMBERTEMP, 'TKVN Register Temp Member', 72100, ParameterType::" ", Module, false);
        MenuLine."Registration Mode" := false;
    end;

    [Obsolete('This function is obsolete.')]
    internal procedure MemberTempPressed()
    var
        TmpID: Code[20];
        Msg: Text[250];
        OkTXT1: Label 'MemberTempPressed';

    begin
        posgui.PosMessage(OkTXT1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterProcessInfoCode', '', false, false)]
    internal procedure OnAfterProcessInfoCode(var POSTransaction: Record "LSC POS Transaction"; var Infocode: Record "LSC Infocode")
    var
        MembershipCard: Record "LSC Membership Card";
        MemberCardMgt: Codeunit "LSC Member Card Management";
        cPOSTrans: Codeunit "LSC POS Transaction";
        ErrorText: Text[250];
        LRecRS: Record "LSC Retail Setup";
    begin
        if lrecrs.get then;
        lrecrs.TestField("Temp. Member Def. Card No.");
        lrecrs.TestField("Temp. Member Infocode");
        if Infocode.Code = lrecrs."Temp. Member Infocode" THEN begin
            MembershipCard.Get(lrecrs."Temp. Member Def. Card No.");
            if not MemberCardMgt.ValidateCard(MembershipCard, ErrorText) then begin
                posgui.PosMessage(ErrorText);
                exit;
            end;
            cPOSTrans.InputMemberCard(MembershipCard."Card No.");
        end;
    end;

    local procedure LineIsProcessed(PRecTIC: record "LSC Trans. Infocode Entry"): Boolean
    var
        LRecTICE: record "WP Trans. Infocode Status";
    begin
        clear(LRecTICE);
        LRecTICE.setrange("Store No.", PRecTIC."Store No.");
        LRecTICE.setrange("POS Terminal No.", PRecTIC."POS Terminal No.");
        LRecTICE.setrange("Transaction No.", PRecTIC."Transaction No.");
        LRecTICE.setrange("Transaction Type", PRecTIC."Transaction Type");
        LRecTICE.setrange("Line No.", PRecTIC."Line No.");
        LRecTICE.setrange(Infocode, PRecTIC.Infocode);
        LRecTICE.setrange("Entry Line No.", PRecTIC."Entry Line No.");
        if LRecTICE.FindFirst() then
            exit(True)
        else
            exit(false);
    end;

    local procedure InsertLineIsProcessed(PRecTIC: record "LSC Trans. Infocode Entry"): Boolean
    var
        LRecTICE: record "WP Trans. Infocode Status";
    begin
        clear(LRecTICE);
        LRecTICE.setrange("Store No.", PRecTIC."Store No.");
        LRecTICE.setrange("POS Terminal No.", PRecTIC."POS Terminal No.");
        LRecTICE.setrange("Transaction No.", PRecTIC."Transaction No.");
        LRecTICE.setrange("Transaction Type", PRecTIC."Transaction Type");
        LRecTICE.setrange("Line No.", PRecTIC."Line No.");
        LRecTICE.setrange(Infocode, PRecTIC.Infocode);
        LRecTICE.setrange("Entry Line No.", PRecTIC."Entry Line No.");
        if LRecTICE.FindFirst() then begin
            lrectice.Processed := true;
            lrectice."Process By" := UserId;
            lrectice."Process Date" := today;
            lrectice."Process Time" := time;
            lrectice.modify;
        end else begin
            LRecTICE."Store No." := PRecTIC."Store No.";
            LRecTICE."POS Terminal No." := PRecTIC."POS Terminal No.";
            LRecTICE."Transaction No." := PRecTIC."Transaction No.";
            LRecTICE."Transaction Type" := PRecTIC."Transaction Type";
            LRecTICE."Line No." := PRecTIC."Line No.";
            LRecTICE.Infocode := PRecTIC.Infocode;
            LRecTICE."Entry Line No." := PRecTIC."Entry Line No.";
            LRecTICE.Processed := true;
            LRecTICE."Process By" := UserId;
            LRecTICE."Process Date" := today;
            LRecTICE."Process Time" := time;
            LRecTICE.insert;
        end;
    end;

    procedure PatchInfocodeStatus()
    var
        LRecIC: record "LSC Trans. Infocode Entry";
        LRecRS: record "LSC Retail Setup";
    begin
        if lrecrs.get then;
        lrecrs.TestField("Temp. Member Infocode");
        lrecrs.TestField("Temp. Member Def. Card No.");
        clear(LRecIC);
        lrecic.setrange(Infocode, lrecrs."Temp. Member Infocode");
        lrecic.setrange(Processed, true);
        if lrecic.findfirst then begin
            repeat
                if LineIsProcessed(lrecic) = false then
                    InsertLineIsProcessed(LRecIC);
            until lrecic.next = 0;
        end;
    end;

    procedure UpdateMemberPoints()
    var
        LRecRS: Record "LSC Retail Setup";
        LRecIC: record "LSC Trans. Infocode Entry";
        LRecMP: Record "LSC Member Point Entry";
        LRecMC: Record "LSC Membership Card";
        LRecPJ: Record "LSC Member Point Jnl. Line";
        LineNo: Integer;
        NoOfLines: Integer;
        PointJnlPost: Codeunit "LSC Point Jnl.-Post";
    begin
        clear(NoOfLines);
        if lrecrs.get then;
        lrecrs.TestField("Temp. Member Infocode");
        lrecrs.TestField("Temp. Member Def. Card No.");
        CreateMemPtsJnlTemplate();
        clear(LRecIC);
        lrecic.setrange(Infocode, lrecrs."Temp. Member Infocode");
        lrecic.setrange(Processed, false);
        if lrecic.findfirst then begin
            repeat
                if LineIsProcessed(lrecic) = false then begin
                    clear(lrecMP);
                    lrecmp.setrange("Store No.", lrecic."Store No.");
                    lrecmp.setrange("POS Terminal No.", lrecic."POS Terminal No.");
                    lrecMP.setrange("Transaction No.", lrecic."Transaction No.");
                    lrecmp.setrange("Source Type", lrecmp."Source Type"::"POS Transaction");
                    if lrecmp.findfirst then begin
                        clear(LRecMC);
                        lrecmc.setrange("Card No.", lrecic.Information);
                        lrecmc.setrange(Status, lrecmc.Status::Active);
                        if lrecmc.findfirst then begin
                            clear(LineNo);
                            clear(LRecPJ);
                            lrecpj.setrange("Journal Template Name", 'T-ADJ');
                            lrecpj.setrange("Journal Batch Name", 'DEFAULT');
                            if lrecpj.findlast then
                                LineNo := lrecpj."Line No." + 1
                            else
                                LineNo := 1;

                            clear(LRecPJ);
                            lrecpj."Journal Batch Name" := 'DEFAULT';
                            LRecPJ."Journal Template Name" := 'T-ADJ';
                            LRecPJ."Line No." := LineNo;
                            lrecpj.Type := lrecpj.Type::"Neg. Adjustment";
                            lrecpj.Date := lrecmp.Date;
                            lrecpj."Document No." := lrecmp."Document No.";
                            lrecpj.validate("Account No.", lrecmp."Account No.");
                            lrecpj.validate("Contact No", lrecmp."Contact No.");
                            lrecpj.validate("Card No.", lrecmp."Card No.");
                            lrecpj."Store No." := lrecmp."Store No.";
                            lrecpj."POS Terminal No." := lrecmp."POS Terminal No.";
                            lrecpj."Transaction No." := lrecmp."Transaction No.";
                            lrecpj.Points := lrecmp.Points;
                            lrecpj.insert;

                            LRecPJ."Line No." := LineNo + 1;
                            lrecpj.Type := lrecpj.Type::"Pos. Adjustment";
                            lrecpj.validate("Account No.", lrecmc."Account No.");
                            lrecpj.validate("Contact No", lrecmc."Contact No.");
                            lrecpj.validate("Card No.", lrecmc."Card No.");
                            lrecpj.insert;

                            lrecic.Processed := true;
                            lrecic."Process By" := UserId;
                            lrecic."Process Date" := today;
                            lrecic."Process Time" := time;
                            lrecic.modify;

                            InsertLineIsProcessed(LRecIC);
                            NoOfLines += 1;
                        end;
                    end;
                end;
            until lrecic.next = 0;

            if lrecrs."Auto Post MP on Calc." = true then
                if NoOfLines > 0 then begin
                    clear(LRecPJ);
                    lrecpj.setrange("Journal Template Name", 'T-ADJ');
                    lrecpj.setrange("Journal Batch Name", 'DEFAULT');
                    if lrecpj.findset then
                        PointJnlPost.Run(lrecpj);
                end;

        end;
    end;

    procedure PostMemberPointsJnl()
    var
        LRecPJ: record "LSC Member Point Jnl. Line";
        PointJnlPost: Codeunit "LSC Point Jnl.-Post";
    begin
        clear(LRecPJ);
        lrecpj.setrange("Journal Template Name", 'T-ADJ');
        lrecpj.setrange("Journal Batch Name", 'DEFAULT');
        if lrecpj.findset then
            PointJnlPost.Run(lrecpj);
    end;

    local procedure CreateMemPtsJnlTemplate()
    var
        LRecJnlTemp: Record "LSC Member Point Jnl. Template";
    begin
        clear(LRecJnlTemp);
        LRecJnlTemp.setrange(name, 'T-ADJ');
        IF NOT LRecJnlTemp.FindFirst() THEN begin
            LRecJnlTemp.NAME := 'T-ADJ';
            LRecJnlTemp.Description := 'Temporary Member Point Adj. Journal';
            LRecJnlTemp."Journal Type" := LRecJnlTemp."Journal Type"::Normal;
            LRecJnlTemp."Form ID" := 99009035;
            LRecJnlTemp.insert;
        end;
    end;

    procedure CreateNewMemberCard()
    var
        LRecMem: Record "WP Member Information TKV";
    begin
        clear(LRecMem);
        LRecMem.SetRange(Processed, false);
        if lrecmem.FindFirst() then begin
            repeat
                if LRecMem."membership_card_no" <> '' then begin
                    if CreateCard(LRecMem) then begin
                        LRecMem.Processed := true;
                        LRecMem."Processed By" := UserId;
                        LRecMem."Processed Date" := today;
                        LRecMem."Processed Time" := time;
                        LRecMem.Modify;
                    end;
                end;
            until lrecmem.next = 0;
        end;
    end;

    local procedure CreateCard(Mem: Record "WP Member Information TKV"): Boolean
    var
        LRecCard: Record "LSC Membership Card";
        LRecAcc: Record "LSC Member Account";
        LRecCon: Record "LSC Member Contact";
        LRecRS: Record "LSC Retail Setup";
        LAddr: text[200];
    begin
        lrecrs.get;
        lrecrs.TestField("Def. Member Club");
        lrecrs.TestField("Def. Member Scheme");

        clear(LRecAcc);
        lrecacc.setrange("No.", mem.phone_no);
        if not lrecacc.FindFirst() then begin
            lrecacc."No." := mem.phone_no;
            LRecAcc.Description := mem.name;
            LRecAcc."Club Code" := lrecrs."Def. Member Club";
            LRecAcc."Scheme Code" := lrecrs."Def. Member Scheme";
            lrecacc."Account Type" := LRecAcc."Account Type"::Private;
            lrecacc.insert(true);
        end else begin
            LRecAcc.Description := mem.name;
            lrecacc.modify(true);
        end;

        clear(LRecCon);
        lreccon.setrange("Account No.", mem.phone_no);
        lreccon.setrange("Contact No.", mem.phone_no);
        if not lreccon.findfirst then begin
            //Create New Record
            lreccon."Account No." := mem.phone_no;
            lreccon."Contact No." := mem.phone_no;
            lreccon."Main Contact" := true;
            lreccon.Name := mem.name;
            lreccon."Phone No." := mem.phone_no;
            lreccon."E-Mail" := mem.email;
            lreccon."Club Code" := lrecrs."Def. Member Club";
            lreccon."Scheme Code" := lrecrs."Def. Member Scheme";
            case uppercase(copystr(mem.gender, 1, 1)) of
                'M':
                    lreccon.Gender := lreccon.Gender::Male;
                'F':
                    lreccon.Gender := lreccon.Gender::Female;
            end;
            LAddr := mem.address;
            case strlen(LAddr) of
                150 .. 200:
                    begin
                        lreccon.Address := copystr(LAddr, 1, 100);
                        lreccon."Address 2" := copystr(LAddr, 101, 50);
                    end;
                100 .. 149:
                    begin
                        lreccon.Address := copystr(LAddr, 1, 100);
                        lreccon."Address 2" := copystr(LAddr, 101, strlen(LAddr) - 100);
                    end;
                else
                    LRecCon.address := LAddr;
            end;
            lreccon.insert(true);
        end else begin
            //Update Record
            lreccon.Name := mem.name;
            lreccon."Phone No." := mem.phone_no;
            lreccon."E-Mail" := mem.email;
            case uppercase(copystr(mem.gender, 1, 1)) of
                'M':
                    lreccon.Gender := lreccon.Gender::Male;
                'F':
                    lreccon.Gender := lreccon.Gender::Female;
            end;
            LAddr := mem.address;
            case strlen(LAddr) of
                150 .. 200:
                    begin
                        lreccon.Address := copystr(LAddr, 1, 100);
                        lreccon."Address 2" := copystr(LAddr, 101, 50);
                    end;
                100 .. 149:
                    begin
                        lreccon.Address := copystr(LAddr, 1, 100);
                        lreccon."Address 2" := copystr(LAddr, 101, strlen(LAddr) - 100);
                    end;
                else
                    LRecCon.address := LAddr;
            end;
            lreccon.modify(true);
        end;

        clear(LRecCard);
        LRecCard.setrange("Card No.", Mem."membership_card_no");
        if not LReccard.FindFirst() then begin
            //Create New Record
            LRecCard."Card No." := Mem."membership_card_no";
            LRecCard."Club Code" := lrecrs."Def. Member Club";
            LRecCard."Scheme Code" := lrecrs."Def. Member Scheme";
            LRecCard."Account No." := Mem.phone_no;
            LRecCard."Contact No." := Mem.phone_no;
            LRecCard."Status" := LRecCard."Status"::Active;
            lreccard."Linked to Account" := true;
            lreccard."Date Created" := today;
            lreccard.insert(true);
        end else begin
            //Update Record

        end;

        exit(true);
    end;

    procedure ResetTest()
    var
        LRecMem: Record "WP Member Information TKV";
        LRecAcc: Record "LSC Member Account";
        LRecCon: Record "LSC Member Contact";
        LRecCar: record "LSC Membership Card";
        LRecRS: record "LSC Retail Setup";
        LRecPts: Record "LSC Member Point Entry";
        LRecMU: Record "LSC Member Account Upgr. Entry";
    begin
        if lrecmem.FindFirst() then begin
            repeat
                clear(lreccar);
                lreccar.setrange("Card No.", lrecmem."membership_card_no");
                lreccar.deleteall;

                clear(lreccon);
                lreccon.setrange("Account No.", lrecmem.phone_no);
                lreccon.deleteall;

                clear(lrecacc);
                lrecacc.setrange("No.", lrecmem.phone_no);
                lrecacc.deleteall;

                clear(LRecPts);
                lrecpts.setrange("Card No.", LRecMem.membership_card_no);
                lrecpts.deleteall;

                clear(LRecMU);
                lrecmu.setrange("Account No.", lrecmem.phone_no);
                lrecmu.deleteall;

                lrecmem.Processed := false;
                LRecMem.modify;
            until lrecmem.next = 0;

            clear(LRecPts);
            lrecpts.setrange("Source Type", LRecPts."Source Type"::Journal);
            lrecpts.DeleteAll();
        end;

        lrecrs.get;
        lrecpts.setrange("Card No.", lrecrs."Temp. Member Def. Card No.");
        lrecpts.deleteall;
    end;

    var
        GlobalRec: Record "LSC POS Menu Line";
        PosTrans: Record "LSC POS Transaction";
        POSTransLine: Record "LSC POS Trans. Line";
        POSSESSION: Codeunit "LSC POS Session";
        POSGUI: Codeunit "LSC POS GUI";
        CommandFunc: Codeunit "LSC POS Command Registration";
        POSTransFound: Boolean;
}
