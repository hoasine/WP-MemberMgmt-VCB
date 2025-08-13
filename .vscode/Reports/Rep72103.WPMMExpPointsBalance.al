report 72103 "WPMM Exp. Member P Balance"
{
    ApplicationArea = All;
    Caption = 'TKVN Exp. Member Points Balance';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    trigger OnPostReport()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        Response: HttpResponseMessage;
        FileName: Text;
        APIUrl: Text;
        Headers: HttpHeaders;
        MultipartBoundary: Text;
        MultipartContent: Text;
        TempText: Text;
        CRLF: Text[2];
        MyXmlPort: XmlPort "WP Member P Balance Export";
        lrecrs: Record "LSC Retail Setup";

        Bytes: array[1000000] of Byte; // kích thước max
        BytesRead: Integer;

        Line: Text;
    begin
        lrecrs.Get;

        // FileName := 'MemberPoints_' +
        //     Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hour,2><Minute,2><Second,2>') + '.csv';

        FileName := 'member-list.csv';

        if lrecrs."Url API" = '' then
            Error('Missing data setup field URL API(IIS) in Retail Setup.');

        APIUrl := lrecrs."Url API" + '/FileUpload/upload';

        // CRLF đúng chuẩn
        CRLF[1] := 13; // Carriage Return
        CRLF[2] := 10; // Line Feed

        // Xuất file ra TempBlob
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        MyXmlPort.SetDestination(OutStr);
        MyXmlPort.Export();

        // Đọc lại file thành text
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);

        repeat
            if not InStr.EOS() then begin
                InStr.ReadText(Line);
                TempText += Line + CRLF;
            end;
        until InStr.EOS();

        // Boundary hợp lệ
        MultipartBoundary := 'BCBoundary' + DelChr(Format(CreateGuid()), '=', '{}');

        MultipartContent :=
            '--' + MultipartBoundary + CRLF +
            StrSubstNo('Content-Disposition: form-data; name="file"; filename="%1"', FileName) + CRLF +
            'Content-Type: text/csv; charset=utf-8' + CRLF + CRLF +
            TempText + CRLF +
            '--' + MultipartBoundary + '--' + CRLF;

        // Ghi vào HttpContent
        HttpContent.WriteFrom(MultipartContent);
        HttpContent.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'multipart/form-data; boundary=' + MultipartBoundary);

        // Gửi request
        HttpClient.Post(APIUrl, HttpContent, Response);

        if not Response.IsSuccessStatusCode() then
            Error('Upload failed: %1 - %2', Response.HttpStatusCode(), Response.ReasonPhrase());
    end;
}
