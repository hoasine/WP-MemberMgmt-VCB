namespace WPMemberManagementExt.WPMemberManagementExt;

xmlport 72100 "WP Member Info Imp"
{
    Caption = 'WP Member Info Imp';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '<NewLine>';
    FieldSeparator = ',';
    FileName = 'memberinfo.csv';

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(WPMemberInformationTKV; "WP Member Information TKV")
            {
                fieldelement(membership_card_no; WPMemberInformationTKV.membership_card_no)
                {
                }
                fieldelement(phone_no; WPMemberInformationTKV.phone_no)
                {
                }
                fieldelement(date_of_birth; WPMemberInformationTKV.date_of_birth)
                {
                }
                fieldelement(name; WPMemberInformationTKV.name)
                {
                }
                fieldelement(email; WPMemberInformationTKV.email)
                {
                }
                fieldelement(address; WPMemberInformationTKV.address)
                {
                }
                fieldelement(gender; WPMemberInformationTKV.gender)
                {
                }
                fieldelement(AgreedadvertiseSMS; WPMemberInformationTKV."Agreed advertise SMS")
                {
                }
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        IF IsFirstLine then begin
            IsFirstLine := false;
            currXMLport.skip();
        end;
    end;

    VAR
        IsFirstLine: boolean;
}
