report 50027 "CN GoldenTax Export files"
{
    Caption = 'Export Golden Tax files';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "Document Type", "No.", "Bill-to Customer No.";

            dataitem("GT Invoice Header"; "GT Invoice Header")
            {
                DataItemLinkReference = "Sales Header";
                DataItemLink = "System Doc No." = FIELD("No.");
                dataitem("GT Invoice Line"; "GT Invoice Line")
                {
                    DataItemLinkReference = "GT Invoice Header";
                    DataItemLink = "System Phantom No." = FIELD("system Phantom no.");
                    DataItemTableView = SORTING("System Phantom No.");

                    trigger OnAfterGetRecord()
                    begin
                        OutputLine("GT Invoice Line")
                    end;

                }
                trigger OnAfterGetRecord()
                begin
                    OutputHeader("GT Invoice Header");

                end;
            }
            trigger OnAfterGetRecord()
            var
            begin
                "Sales Header"."GT Exported" := true;
                "Sales Header".Modify();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group(Option)
                    {
                        Caption = 'Option';

                        field(bAppendFile; bAppendFile)
                        {
                            Caption = 'Append to File';
                            ApplicationArea = all;
                        }
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        IF outFileName = '' THEN
            outFileName := "Sales Header"."No." + '.txt';

        tempBlob.CreateInStream(GTInStream, TextEncoding::UTF8);
        DownloadFromStream(GTInStream, 'Export Golden Tax Files', GLSetup."File Path", 'All Files (*.*)|*.*', outFileName);

    end;

    trigger OnPreReport()
    begin
        GLSetup.GET;
        IF GLSetup."Max Invoice Lines" <= 0 THEN ERROR(Err001);
        IF GLSetup."Max Invoice Amount" <= 0 THEN ERROR(Err003);
        IF GLSetup."Commodity Tax No." = '' THEN ERROR(ERR004);

        tempBlob.CreateOutStream(GTOutStream, TextEncoding::UTF8);
        //GTOutStream.WriteText; //换行符
        GTOutStream.WriteText('SJJK0101~~output sales documents~~' + "Sales Header".GETFILTER("No."));
        GTOutStream.WriteText;//换行符
        //#BC190>>
    end;

    var
        outFile: File;
        outFileName: Text[200];
        //BC190-Upgrade<<
        GTInStream: InStream;
        GTOutStream: OutStream;
        tempBlob: Codeunit "Temp Blob";
        //BC190>>
        bSplitDec: Boolean;
        bAppendFile: Boolean;
        lineAmountIncVAT: Decimal;
        unitPriceIncVAT: Decimal;
        remQuantity: Decimal;
        splitQuantity: Decimal;
        totalAmountIncVAT: Decimal;
        totalAmount: Decimal;
        InvLineNumber: Integer;
        GLSetup: Record "General Ledger Setup";
        g_ItemChgAmountIncVAT: Decimal;
        g_ItemChgQty: Decimal;
        g_ItemChgPriceIncVat: Decimal;
        g_ItemChgAmountExlVAT: Decimal;
        MakerName: Text[100];
        Err001: Label 'Please input the Max Line Number.';
        Err002: Label 'Can''t Create the %1.';
        Err003: Label 'Please input the Limited Amount.';
        txt003: Label 'Exported to %1 successfully.';
        txt001: Label 'Document No.:#1#############\\';
        txt002: Label 'Document Line No.:  #2#############';
        ERR012: Label 'Data is error';
        ERR013: Label 'Please release document %1 first.';
        ERR004: Label 'Commodity Tax No should not be empty.';
        Text0011: Label '<Export to TXT File>';
        Text0012: Label '<TXT Files (*.txt)|*.txt|All Files (*.*)|*.*>';
        Text0013: Label '<Default.txt>';




    procedure OutputHeader(GTInvHeader: Record "GT Invoice Header")
    var
        ReturnKey: Text[100];
        DocHeader: Text[1024];
        charReturnKey: Char;
        BilltoDept: text[50];
        SONo: Code[20];
        SalesHeader: Record "Sales Header";
        GTInvLine: Record "GT Invoice Line";
        MaxLineNum: Integer;
    begin
        DocHeader := '';
        charReturnKey := 13;
        ReturnKey := FORMAT(charReturnKey);

        MaxLineNum := 0;
        GTInvLine.Reset();
        GTInvLine.SetRange("System Phantom No.", GTInvHeader."System Phantom No.");
        if GTInvLine.FindFirst() then
            repeat
                MaxLineNum := MaxLineNum + 1;
            until GTInvLine.Next() = 0;

        DocHeader := GTInvHeader."System Phantom No." + '~~' + Format(MaxLineNum) + '~~' + GTInvHeader."Cust Name" + '~~';
        DocHeader += GTInvHeader."Cust VAT No." + '~~' + GTInvHeader."Cust Address" + '~~';
        DocHeader += GTInvHeader."Cust Bank";
        //DocHeader += '~~' + "GT Invoice Header".Remark;

        SalesHeader.get("Sales Header"."Document Type"::Invoice, GTInvHeader."System Doc No.");
        DocHeader += '~~' + SalesHeader."Order No." + '\n' + SalesHeader."GT Invoice Remark" + '\n' + GetExtDocNo(SalesHeader."Order No.") + '\n' + SalesHeader."Bill-to Customer No." + '\n' + BilltoDept;
        DocHeader += '~~' + GLSetup.Checker + '~~' + GLSetup.Payee; //+ '~~~~';

        //#BC190<<
        //outFile.WRITE(' ');
        //outFile.WRITE(DocHeader);
        GTOutStream.WriteText; //换行
        GTOutStream.WriteText(DocHeader);
        //#BC190>>
    end;

    procedure GetExtDocNo(OrderNo: Code[50]): Code[50]
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.get(SalesHeader."Document Type"::Order, OrderNo) then
            exit(SalesHeader."External Document No.");
        exit('');
    end;
    // procedure GetSONo(InvNo: Code[20]): Code[20]
    // var
    //     SalesLine: Record "Sales Line";
    //     SalesShptLine: Record "Sales Shipment Line";
    // begin
    //     SalesLine.Reset();
    //     SalesLine.SetRange("Document No.", InvNo);
    //     SalesLine.SetRange(Type, SalesLine.Type::Item);
    //     if SalesLine.FindFirst() Then begin
    //         if SalesShptLine.Get(SalesLine."Shipment No.", SalesLine."Shipment Line No.") then begin
    //             exit(SalesShptLine."Order No.");
    //         end;
    //     end;
    //     exit('');
    // end;

    // procedure GetExtDocNo(OrderNo: Code[20]): Code[20]
    // var
    //     SalesHeader: Record "Sales Header";
    // begin
    //     if SalesHeader.get(SalesHeader."Document Type"::Order, OrderNo) then
    //         exit(SalesHeader."External Document No.");
    //     exit('');
    // end;

    procedure OutputLine(l_JSInvLine: Record "GT Invoice Line")
    var
        ItemTranslation: Record "Item Translation";
        UOMTranslation: Record "Unit of Measure Translation";
        ReturnKey: Text[100];
        charReturnKey: Char;
        DocLine: Text[1024];
    begin
        charReturnKey := 13;
        ReturnKey := FORMAT(charReturnKey);

        DocLine := "GT Invoice Line".Description + '~~' + "GT Invoice Line"."Unit of Measure" + '~~' + "GT Invoice Line"."Item No." + '~~';
        DocLine := DocLine + FORMAT("GT Invoice Line".Quantity, 0, 1) + '~~' + FORMAT("GT Invoice Line"."Amount Exc. VAT", 0, 1) + '~~'
        + FORMAT("GT Invoice Line"."VAT%" * 0.01, 0, 1) + '~~' + GLSetup."Commodity Tax No.";

        GTOutStream.WriteText;
        GTOutStream.WriteText(DocLine);
    end;


}

