report 58026 "CN GoldenTax Generation Bak"
{
    Caption = 'Generate GT Data';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "Document Type", "No.", "Bill-to Customer No.";
            dataitem(Integer; Integer) //1..n, 一个系统发票可能会被拆成多个金税发票（按照金额限制）
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                //"Sales Lines"
                dataitem("Sales Line"; "Sales Line")
                {
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                    DataItemLinkReference = "Sales Header";
                    DataItemLink = "Document No." = FIELD("No.");
                    trigger OnAfterGetRecord()
                    begin
                        IF ("Sales Header"."Document Type" = "Sales Header"."Document Type"::Order) AND ("Qty. Shipped Not Invoiced" = 0) THEN
                            CurrReport.SKIP;
                        IF ("Sales Header"."Document Type" = "Sales Header"."Document Type"::Invoice) AND ("Sales Line".Quantity = 0) THEN
                            CurrReport.SKIP;
                        IF "Sales Line".Type = "Sales Line".Type::"Charge (Item)" THEN
                            CurrReport.SKIP;
                        InsGTInvLine("Sales Line", true); //生成金税发票行
                    end;
                }
                //Integer:1..n
                trigger OnPreDataItem()
                begin
                    FILTERGROUP(2);
                    IF IsCancelled = false THEN
                        SETRANGE(Number, 1, GTInvoiceCount)
                    ELSE
                        SETRANGE(Number, 1);
                    FILTERGROUP(0);
                    //init
                    LastSysPhantomNo := '';
                    AmtforEachInvExcVAT := 0;
                    LeftAmtforEachInvIncVAT := 0;
                end;

                trigger OnAfterGetRecord()
                var
                    GTInvHeader: Record "GT Invoice Header";
                    MaxInvAmount: Decimal;
                    SalesLine: Record "Sales Line";
                begin
                    MaxInvAmount := GLSetup."Max Invoice Amount";
                    IF Number < GTInvoiceCount THEN
                        LeftAmtforEachInvIncVAT := MaxInvAmount
                    ELSE
                        LeftAmtforEachInvIncVAT := TotalAmountIncVAT - MaxInvAmount * (GTInvoiceCount - 1);
                    AmtforEachInvExcVAT := LeftAmtforEachInvIncVAT / (1 + VatRate / 100);
                    LastSysPhantomNo := InsGTInvHeader("Sales Header", AmtforEachInvExcVAT, LeftAmtforEachInvIncVAT); //插入发票头

                    //定位最后一行
                    SalesLine.Reset();
                    SalesLine.SETRANGE(SalesLine."Document Type", "Sales Header"."Document Type");
                    SalesLine.SETRANGE(SalesLine."Document No.", "Sales Header"."No.");
                    IF SalesLine.FindLast() THEN
                        LastSalesLineNo := SalesLine."Line No."
                    ELSE
                        LastSalesLineNo := -1;
                end;
            }

            //"Sales Header"
            trigger OnAfterGetRecord()
            var
                SalesLine: Record "Sales Line";
                GTInvHeader: Record "GT Invoice Header";
                GTInvLine: Record "GT Invoice Line";
                NoFilter: Text[50];
                ItemChargeQty: Decimal;
                ItemChargeAmountIncVAT: Decimal;
                ItemChargeAmountExlVAT: Decimal;
                ItemChargeAssignment: Record "Item Charge Assignment (Sales)";
                CurrSubInvNum1: Code[10];
            begin
                TestField(Status, Status::Released);
                TestField("GT Exported", false);
                GTInvoiceCount := 0;
                TotalAmountExcVAT := 0;
                TotalAmountIncVAT := 0;
                VatRate := 0;
                GTInvHeader.Reset();
                GTInvHeader.SetRange("System Doc No.", "Sales Header"."No.");
                if GTInvHeader.FindFirst() then
                    GTInvHeader.DeleteAll(true);

                SalesLine.Reset();
                SalesLine.SETRANGE(SalesLine."Document Type", "Document Type");
                SalesLine.SETRANGE(SalesLine."Document No.", "No.");
                SalesLine.SETRANGE(SalesLine.Type, SalesLine.Type::Item);
                IF SalesLine.FIND('-') THEN
                    REPEAT
                        ItemChargeQty := 0;
                        ItemChargeAmountIncVAT := 0;
                        ItemChargeAmountExlVAT := 0;
                        ItemChargeAssignment.RESET;
                        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Type", "Sales Header"."Document Type");
                        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. No.", "Sales Header"."No.");
                        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Line No.", SalesLine."Line No.");
                        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Item No.", SalesLine."No.");
                        ItemChargeAssignment.SETFILTER(ItemChargeAssignment."Qty. to Assign", '>0');
                        IF ItemChargeAssignment.FINDFIRST THEN
                            REPEAT
                                IF "Sales Header"."Prices Including VAT" THEN BEGIN
                                    ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                                    ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + SalesLine."VAT %" * 0.01);
                                    ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                                END ELSE BEGIN
                                    ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                                    ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + SalesLine."VAT %" * 0.01);
                                    ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                                END;

                            UNTIL ItemChargeAssignment.NEXT = 0;

                        IF "Document Type" = "Document Type"::Order THEN
                            SalesLine."Line Amount" := SalesLine."Unit Price" * SalesLine."Qty. Shipped Not Invoiced" * (1 - SalesLine."Line Discount %" * 0.01);

                        IF NOT "Sales Header"."Prices Including VAT" THEN BEGIN
                            TotalAmountIncVAT += SalesLine."Line Amount" * (1 + SalesLine."VAT %" / 100) + ItemChargeAmountIncVAT;
                            VatRate := SalesLine."VAT %";
                            TotalAmountExcVAT += SalesLine."Line Amount" + ItemChargeAmountExlVAT;
                        END ELSE BEGIN
                            TotalAmountIncVAT += SalesLine."Line Amount" + ItemChargeAmountIncVAT;
                            VatRate := SalesLine."VAT %";
                            TotalAmountExcVAT += SalesLine."Line Amount" / (1 + SalesLine."VAT %" / 100) + ItemChargeAmountExlVAT;
                        END;
                    UNTIL SalesLine.NEXT = 0;

                //计算发票张数
                GTInvoiceCount := ROUND(TotalAmountIncVAT / GLSetup."Max Invoice Amount", 1, '>');
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
                        field(Description; Description)
                        {
                            Caption = 'Description';
                            ApplicationArea = all;
                        }
                        field(Specification; Specification)
                        {
                            Caption = 'Specification';
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

    trigger OnInitReport()
    begin
        GLSetup.GET;
    end;

    trigger OnPostReport()
    begin

    end;

    trigger OnPreReport()
    begin
        IF GLSetup."Max Invoice Lines" <= 0 THEN ERROR(Err001);

        IF GLSetup."Max Invoice Amount" <= 0 THEN ERROR(Err003);
        IF GLSetup."Commodity Tax No." = '' THEN ERROR(ERR004);
    end;

    procedure InsGTInvHeader(SalesHeader: Record "Sales Header"; AmtExcVAT: Decimal; AmtIncVAT: Decimal): Code[30]
    var
        l_NoFilter: Code[20];
        l_CurrSubInvNum: Code[20];
        Customer: Record Customer;
        CustomerBank: Record "Customer Bank Account";
        ReturnKey: Text[100];
        DocHeader: Text[1024];
        charReturnKey: Char;
        BilltoDept: text[50];
        SONo: Code[20];
        GTInvHeader: Record "GT Invoice Header";
        GTInvHeader2: Record "GT Invoice Header";
    begin
        DocHeader := '';
        charReturnKey := 13;
        ReturnKey := FORMAT(charReturnKey);
        l_CurrSubInvNum := '000';
        l_NoFilter := SalesHeader."No." + '-' + '???';
        GTInvHeader2.Reset();
        GTInvHeader2.SETFILTER("System Phantom No.", l_NoFilter);
        IF GTInvHeader2.FindLast() THEN
            l_CurrSubInvNum := COPYSTR(GTInvHeader2."System Phantom No.", STRLEN(GTInvHeader2."System Phantom No.") - 2, 3);

        SalesHeader.TestField("No.");
        SalesHeader.TestField("Bill-to Name 2");
        SalesHeader.TestField("Bill-to Address 2");
        Customer.GET(SalesHeader."Bill-to Customer No.");
        Customer.TestField("VAT Registration No.");
        Customer.TestField("Phone No.");
        Customer.TestField("Preferred Bank Account Code");
        CustomerBank.Get(Customer."No.", Customer."Preferred Bank Account Code");
        CustomerBank.TestField(Name);
        CustomerBank.TestField("Bank Account No.");

        GTInvHeader.Init();
        GTInvHeader."System Doc No." := "Sales header"."No.";
        GTInvHeader."System Phantom No." := "Sales header"."No." + '-' + IncStr(l_CurrSubInvNum);
        GTInvHeader."Customer No." := "Sales Header"."Bill-to Customer No.";
        GTInvHeader."Cust Name" := "Sales Header"."Bill-to Name 2";
        GTInvHeader."Cust VAT No." := Customer."VAT Registration No.";
        GTInvHeader."Cust Address" := Customer."Address 2" + ' ' + Customer."Phone No.";
        GTInvHeader."Cust Bank" := CustomerBank.name + ' ' + CustomerBank."Bank Account No.";
        // GTInvHeader."Amount Exc. VAT" := AmtExcVAT;
        // GTInvHeader."Amount Inc. VAT" := AmtIncVAT;
        // GTInvHeader."VAT Amount" := AmtIncVAT - AmtExcVAT;

        GTInvHeader.Insert();
        exit(GTInvHeader."System Phantom No.");
    end;

    procedure InsGTInvLine(l_Salesline: Record "Sales Line"; bPriceIncVAT: Boolean)
    var
        JSInvoiceLine: Record "GT Invoice Line";
        JSInvoiceLine2: Record "GT Invoice Line";
        lrecItem: Record Item;
        lItemReference: Record "Item Reference";
        LastLineNo: Integer;
        ItemTranslation: Record "Item Translation";
        UOMTranslation: Record "Unit of Measure Translation";
        ItemChargeQty: Decimal;
        ItemChargeAmountIncVAT: Decimal;
        ItemChargeAmountExlVAT: Decimal;
        ItemChargeAssignment: Record "Item Charge Assignment (Sales)";
    begin
        JSInvoiceLine2.Reset();
        JSInvoiceLine2.SetRange("System Phantom No.", LastSysPhantomNo);
        if JSInvoiceLine2.FindLast() then
            LastLineNo := JSInvoiceLine2."Line No." + 1
        else
            LastLineNo := 1;
        //计算单据行上的分摊金额
        ItemChargeQty := 0;
        ItemChargeAmountIncVAT := 0;
        ItemChargeAmountExlVAT := 0;
        ItemChargeAssignment.RESET;
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Type", "Sales Line"."Document Type");
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. No.", "Sales Line"."Document No.");
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Line No.", "Sales Line"."Line No.");
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Item No.", "Sales Line"."No.");
        ItemChargeAssignment.SETFILTER(ItemChargeAssignment."Qty. to Assign", '>0');
        IF ItemChargeAssignment.FINDFIRST THEN
            REPEAT
                IF bPriceIncVAT THEN BEGIN
                    ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                    ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + l_Salesline."VAT %" * 0.01);
                    ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                END ELSE BEGIN
                    ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                    ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + l_Salesline."VAT %" * 0.01);
                    ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                END;
            UNTIL ItemChargeAssignment.NEXT = 0;

        //生成发票行
        JSInvoiceLine.INIT;
        JSInvoiceLine."System Doc No." := l_Salesline."Document No.";
        JSInvoiceLine."System Phantom No." := LastSysPhantomNo;
        JSInvoiceLine."Line No." := LastLineNo;
        JSInvoiceLine."Item No." := l_Salesline."No.";
        JSInvoiceLine."Unit of Measure" := GetUOM(l_Salesline."Unit of Measure Code");
        JSInvoiceLine."Quantity" := l_Salesline.Quantity / GTInvoiceCount;  //根据发票张数平摊数量
        JSInvoiceLine."VAT%" := l_Salesline."VAT %";
        lrecItem.GET(l_Salesline."No.");

        //计算开票金额（考虑行折扣和分摊）
        IF l_Salesline."Document Type" = l_Salesline."Document Type"::Invoice THEN BEGIN
            IF not bPriceIncVAT THEN
                JSInvoiceLine."Amount Exc. VAT" := l_Salesline."Unit Price" * l_Salesline.Quantity * (1 - l_Salesline."Line Discount %" * 0.01) + ItemChargeAmountExlVAT
            ELSE BEGIN
                JSInvoiceLine."Amount Exc. VAT" := ROUND(l_Salesline."Unit Price" * l_Salesline.Quantity / (1 + l_Salesline."VAT %" / 100), 0.01, '=') -
                  Round(l_Salesline."Line Discount Amount" / (1 + l_Salesline."VAT %" / 100), 0.01, '=');
            END;
        END;

        //拆分发票时，计算行金额
        IF l_Salesline."Line No." <> LastSalesLineNo THEN BEGIN
            IF GTInvoiceCount <> 1 THEN BEGIN
                JSInvoiceLine."Amount Exc. VAT" := ROUND(AmtforEachInvExcVAT * (l_Salesline."Line Amount" / TotalAmountExcVAT), 0.01);
                LeftAmtforEachInvIncVAT -= JSInvoiceLine."Amount Exc. VAT" * (1 + VatRate / 100);
            END;
        END ELSE BEGIN //For the LAST line, we need some special treatment
            IF GTInvoiceCount <> 1 THEN
                JSInvoiceLine."Amount Exc. VAT" := ROUND(LeftAmtforEachInvIncVAT / (1 + VatRate / 100), 0.01);
        END;

        JSInvoiceLine."VAT Amount" := ROUND(JSInvoiceLine."Amount Exc. VAT" * VatRate / 100, 0.01);

        //计算物料描述
        // IF UOMTranslation.GET("Sales Line"."Unit of Measure Code", 'CHS')
        //    AND (UOMTranslation.Description <> '') THEN
        //     JSInvoiceLine."Unit of Measure" := UOMTranslation.Description;
        // IF ItemTranslation.GET("Sales Line"."No.", '', 'CHS') AND (ItemTranslation.Description <> '') THEN
        //     l_Salesline.Description := ItemTranslation.Description;

        case Description of
            Description::"Description":
                JSInvoiceLine.Description := l_Salesline.Description;
            Description::"Description 2":
                JSInvoiceLine.Description := l_Salesline."Description 2";
            Description::Remark:
                JSInvoiceLine.Description := l_Salesline.Remark;
        end;

        case Specification of
            Specification::"Description":
                JSInvoiceLine."Item No." := l_Salesline.Description;
            Specification::"Description 2":
                JSInvoiceLine."Item No." := l_Salesline."Description 2";
            Specification::Remark:
                JSInvoiceLine."Item No." := l_Salesline.Remark;
        end;

        JSInvoiceLine."Unit Price" := Round(JSInvoiceLine."Amount Exc. VAT" / JSInvoiceLine.Quantity, 8);
        JSInvoiceLine.INSERT(TRUE);
    end;

    procedure GetSONo(InvNo: Code[20]): Code[20]
    var
        SalesLine: Record "Sales Line";
        SalesShptLine: Record "Sales Shipment Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", InvNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindFirst() Then begin
            if SalesShptLine.Get(SalesLine."Shipment No.", SalesLine."Shipment Line No.") then begin
                exit(SalesShptLine."Order No.");
            end;
        end;
        exit('');
    end;

    procedure GetUOM(UOMCode: Code[20]): Text[10]
    var
        UOM: Record "Unit of Measure";
    begin
        if (uom.get(UOMCode)) AND (UOM."Short Description" <> '') then
            exit(UOM."Short Description")
        else
            exit(UOMCode);
    end;

    procedure SetPara(IsProcessP: Boolean; IsExportP: Boolean)
    begin
        IsProcess := IsProcessP;
        IsExport := IsExportP;
    end;

    var
        Description: Enum "Commodity Description";
        LastSysPhantomNo: Code[30];
        GTInvoiceCount: Integer;
        outFile: File;
        LastSalesLineNo: Integer;
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
        TotalAmountIncVAT: Decimal;
        TotalAmountExcVAT: Decimal;
        AmtforEachInvExcVAT: Decimal;
        LeftAmtforEachInvIncVAT: Decimal;
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
        ERR005: Label 'Document %1: Bill-to Customer''s VAT Registration No. shall not be empty.';
        ERR006: Label 'Document %1: Bill-to Address or Customer Phone Number shall not be empty.';
        ERR007: Label 'Check Custemer Bank Account %1';

        IsProcess: Boolean;
        IsExport: Boolean;
        IsCancelled: Boolean;
        VatRate: Decimal;
        Specification: Enum "Commodity Description";
}

