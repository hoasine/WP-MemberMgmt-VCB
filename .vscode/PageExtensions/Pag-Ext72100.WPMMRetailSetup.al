pageextension 72100 "WPMM Retail Setup" extends "LSC Retail Setup"
{
    layout
    {
        addlast(General)
        {
            field("Enable Copy Trans. Print"; Rec."Enable Copy Trans. Print")
            {
                ApplicationArea = All;
            }
            field("Url API"; Rec."Url API")
            {
                ApplicationArea = All;
            }
        }

        addbefore(Version)
        {
            group("Member Management")
            {
                field("Temp. Member Infocode"; Rec."Temp. Member Infocode")
                {
                    ApplicationArea = All;
                }
                field("Temp. Member Def. Card No."; Rec."Temp. Member Def. Card No.")
                {
                    ApplicationArea = All;
                }
                field("Def. Member Club"; Rec."Def. Member Club")
                {
                    ApplicationArea = All;
                }
                field("Def. Member Scheme"; Rec."Def. Member Scheme")
                {
                    ApplicationArea = All;
                }
                field("Last Point Entry No."; Rec."Last Point Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Auto Post MP on Calc."; Rec."Auto Post MP on Calc.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addafter("<Token Storage Setup>")
        {
            action("TKVTEST-Patch Infocode Entry Status")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPMemberMgtUtils";
                begin
                    if Confirm('This action will update the Infocode Entry Status based on Trans. Infocode Entries "Processed" field. Continue?') = false then exit;
                    cu.PatchInfocodeStatus();
                end;
            }
            action("TKVTEST-Calc. Temp. Member Points")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPMemberMgtUtils";
                begin
                    if rec."Auto Post MP on Calc." = false then
                        if Confirm('Auto POST MP on Calc. is not enabled. Journal will be created but not posted. Continue?') = false then exit;

                    cu.UpdateMemberPoints();
                end;
            }
            action("TKVTEST-Post Temp. Member Points")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPMemberMgtUtils";
                begin
                    cu.PostMemberPointsJnl();
                end;
            }
            action("TKVTEST-Import New Members")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPMemberMgtUtils";
                begin
                    cu.CreateNewMemberCard();
                end;
            }
            action("TKVTEST-Members Reset")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPMemberMgtUtils";
                begin
                    cu.ResetTest();
                end;
            }
            action("TKVTEST-Export Points")
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    XmlPort.Run(72101);
                end;
            }

            action("TKVTEST-Export Balance")
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    XmlPort.Run(72102);
                end;
            }
            action("TKVTEST-VCB DOTEST")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPEFTUtils";
                    ResponseMsg: Text;
                begin
                    if cu.SendToEFT('http://localhost:5000/api/DoTest?HostName=localhost&PortNo=5000&TimeOut=60', ResponseMsg) then
                        Message(ResponseMsg);
                end;
            }
            action("TKVTEST-VCB DOPARSE")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    cu: Codeunit "WPEFTUtils";
                    ResponseMsg: Text;
                begin
                    CU.ParseRespMsg('');

                end;
            }
        }

    }
}