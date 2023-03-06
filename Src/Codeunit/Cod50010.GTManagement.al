codeunit 50010 "GT Management"
{

    //==================================================================================================
    //发票过账时检查金税金额
    //==================================================================================================
    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterCheckSalesDoc', '', false, false)]
    procedure CheckGTInvoice(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean)
    var
        GTInvLine: Record "GT Invoice Line";
        SalesLine: Record "Sales Line";
        InvAmount: Decimal;
        GTInvAmount: Decimal;
        Txt01: Label 'Invoice Amount %1 is not equal jinshui invoice %2';
        Customer: Record Customer;
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then
            exit;
        Customer.get(SalesHeader."Bill-to Customer No.");
        if Customer."VAT Registration No." = '' then
            exit;
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then
            repeat
                if SalesHeader."Prices Including VAT" then
                    InvAmount := InvAmount + SalesLine."Line Amount"
                else
                    InvAmount := InvAmount + Round(SalesLine."Line Amount" * (100 + SalesLine."VAT %") / 100, 0.01);
            until SalesLine.Next() = 0;

        GTInvLine.Reset();
        GTInvLine.SetRange("System Doc No.", SalesHeader."No.");
        if GTInvLine.FindFirst() then
            repeat
                GTInvAmount := GTInvAmount + GTInvLine."Amount Exc. VAT" + GTInvLine."VAT Amount";
            until GTInvLine.Next() = 0;
        if Customer."None GoldenTax" = false then
            if GTInvAmount <> InvAmount then
                Error(Txt01, Format(InvAmount), Format(GTInvAmount));
    end;

    //==================================================================================================
    //Released Sales Invoice的时候生成发票
    //==================================================================================================
    [EventSubscriber(ObjectType::Codeunit, 414, 'OnAfterReleaseSalesDoc', '', false, false)]
    procedure ReleaseSIandGenerateGT(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        Customer: Record Customer;
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then
            exit;
        Customer.get(SalesHeader."Bill-to Customer No.");
        if Customer."None GoldenTax" then
            exit;
        if Customer."VAT Registration No." = '' then
            exit;
        GLSetup.Get();
        GenerateGTInvoice(SalesHeader, GLSetup."GT Description", GLSetup."GT Specification");
    end;

    procedure GenerateGTInvoice(SalesHeader: Record "Sales Header"; DescriptionType: Enum "Commodity Description"; SpecType: Enum "Commodity Description");
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

        GTInvoiceCount: Integer;
        TotalAmountIncVAT: Decimal;
        TotalAmountExcVAT: Decimal;
        VatRate: Decimal;
        GLSetup: Record "General Ledger Setup";
        i: Integer;

        SalesLine2: Record "Sales Line";
        MaxInvAmount: Decimal;
        AmtforEachInvExcVAT: Decimal;
        RemainAmtforEachInvIncVAT: Decimal;
        LastSysPhantomNo: Code[30];
        LastSalesLineNo: Integer;

        JSInvoiceLine: Record "GT Invoice Line";
        JSInvoiceLine2: Record "GT Invoice Line";
        LastLineNo: Integer;
        Item: Record Item;
    begin
        GLSetup.Get();
        SalesHeader.TestField(SalesHeader."Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.TestField(Status, SalesHeader.Status::Released);
        SalesHeader.TestField("GT Exported", false);
        GTInvoiceCount := 0;
        TotalAmountExcVAT := 0;
        TotalAmountIncVAT := 0;
        VatRate := 0;
        GTInvHeader.Reset();
        GTInvHeader.SetRange("System Doc No.", SalesHeader."No.");
        if GTInvHeader.FindFirst() then
            GTInvHeader.DeleteAll(true);

        //根据系统发票行计算系统发票的总的含税金额（TotalAmountIncVAT）与不含税金额(TotalAmountExcVAT)
        SalesLine.Reset();
        SalesLine.SETRANGE(SalesLine."Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SETRANGE(SalesLine.Type, SalesLine.Type::Item);
        IF SalesLine.FIND('-') THEN
            REPEAT
                ItemChargeQty := 0;
                ItemChargeAmountIncVAT := 0;
                ItemChargeAmountExlVAT := 0;
                ItemChargeAssignment.RESET;
                ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Type", SalesHeader."Document Type");
                ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. No.", SalesHeader."No.");
                ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Line No.", SalesLine."Line No.");
                ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Item No.", SalesLine."No.");
                ItemChargeAssignment.SETFILTER(ItemChargeAssignment."Qty. to Assign", '>0');
                IF ItemChargeAssignment.FINDFIRST THEN
                    REPEAT
                        IF SalesHeader."Prices Including VAT" THEN BEGIN
                            ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                            ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + SalesLine."VAT %" * 0.01);
                            ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                        END ELSE BEGIN
                            ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                            ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + SalesLine."VAT %" * 0.01);
                            ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                        END;

                    UNTIL ItemChargeAssignment.NEXT = 0;

                IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
                    SalesLine."Line Amount" := SalesLine."Unit Price" * SalesLine."Qty. Shipped Not Invoiced" * (1 - SalesLine."Line Discount %" * 0.01);

                IF NOT SalesHeader."Prices Including VAT" THEN BEGIN
                    TotalAmountIncVAT += SalesLine."Line Amount" * (1 + SalesLine."VAT %" / 100) + ItemChargeAmountIncVAT;
                    VatRate := SalesLine."VAT %";
                    TotalAmountExcVAT += SalesLine."Line Amount" + ItemChargeAmountExlVAT;
                END ELSE BEGIN
                    TotalAmountIncVAT += SalesLine."Line Amount" + ItemChargeAmountIncVAT;
                    VatRate := SalesLine."VAT %";
                    TotalAmountExcVAT += SalesLine."Line Amount" / (1 + SalesLine."VAT %" / 100) + ItemChargeAmountExlVAT;
                END;
            UNTIL SalesLine.NEXT = 0;

        //计算要生成的金税发票的张数
        GTInvoiceCount := ROUND(TotalAmountIncVAT / GLSetup."Max Invoice Amount", 1, '>');

        for i := 1 to GTInvoiceCount do begin
            MaxInvAmount := GLSetup."Max Invoice Amount";
            IF i < GTInvoiceCount THEN
                RemainAmtforEachInvIncVAT := MaxInvAmount
            ELSE
                RemainAmtforEachInvIncVAT := TotalAmountIncVAT - MaxInvAmount * (GTInvoiceCount - 1);
            AmtforEachInvExcVAT := RemainAmtforEachInvIncVAT / (1 + VatRate / 100);
            //插入金税发票头
            LastSysPhantomNo := InsGTInvHeader(SalesHeader, AmtforEachInvExcVAT, RemainAmtforEachInvIncVAT);

            //计算最后一行的行号
            SalesLine2.Reset();
            SalesLine2.SETRANGE("Document Type", SalesHeader."Document Type");
            SalesLine2.SETRANGE("Document No.", SalesHeader."No.");
            IF SalesLine2.FindLast() THEN
                LastSalesLineNo := SalesLine2."Line No."
            ELSE
                LastSalesLineNo := -1;

            //插入金税发票行
            if SalesLine.FindFirst() then
                repeat
                    JSInvoiceLine2.Reset();
                    JSInvoiceLine2.SetRange("System Phantom No.", LastSysPhantomNo);
                    if JSInvoiceLine2.FindLast() then
                        LastLineNo := JSInvoiceLine2."Line No." + 1
                    else
                        LastLineNo := 1;

                    ItemChargeAmountExlVAT := GetItemChargeAmount(SalesLine);

                    JSInvoiceLine.INIT;
                    JSInvoiceLine."System Doc No." := SalesLine."Document No.";
                    JSInvoiceLine."System Phantom No." := LastSysPhantomNo;
                    JSInvoiceLine."Line No." := LastLineNo;
                    JSInvoiceLine."Item No." := SalesLine."No.";
                    JSInvoiceLine."Unit of Measure" := GetUOMDesc(SalesLine."Unit of Measure Code");
                    JSInvoiceLine."Quantity" := SalesLine.Quantity / GTInvoiceCount;  //根据发票张数平摊数量
                    JSInvoiceLine."VAT%" := SalesLine."VAT %";
                    Item.GET(SalesLine."No.");

                    //calc amount
                    IF SalesLine."Document Type" = SalesLine."Document Type"::Invoice THEN BEGIN
                        IF not SalesHeader."Prices Including VAT" THEN
                            JSInvoiceLine."Amount Exc. VAT" := ROUND(SalesLine."Unit Price" * SalesLine.Quantity * (1 - SalesLine."Line Discount %" * 0.01), 0.01, '=') + ItemChargeAmountExlVAT
                        ELSE BEGIN
                            JSInvoiceLine."Amount Exc. VAT" := ROUND(SalesLine."Unit Price" * SalesLine.Quantity / (1 + SalesLine."VAT %" / 100), 0.01, '=') -
                              Round(SalesLine."Line Discount Amount" / (1 + SalesLine."VAT %" / 100), 0.01, '=');
                        END;
                    END;

                    //calc amount for split line
                    IF SalesLine."Line No." <> LastSalesLineNo THEN BEGIN
                        IF GTInvoiceCount <> 1 THEN BEGIN
                            JSInvoiceLine."Amount Exc. VAT" := ROUND(AmtforEachInvExcVAT * (SalesLine."Line Amount" / TotalAmountExcVAT), 0.01);
                            RemainAmtforEachInvIncVAT -= JSInvoiceLine."Amount Exc. VAT" * (1 + VatRate / 100);
                        END;
                    END ELSE BEGIN //For the LAST line, we need some special treatment
                        IF GTInvoiceCount <> 1 THEN
                            JSInvoiceLine."Amount Exc. VAT" := ROUND(RemainAmtforEachInvIncVAT / (1 + VatRate / 100), 0.01);
                    END;

                    JSInvoiceLine."VAT Amount" := ROUND(JSInvoiceLine."Amount Exc. VAT" * VatRate / 100, 0.01);

                    case DescriptionType of
                        DescriptionType::"Description":
                            JSInvoiceLine.Description := SalesLine.Description;
                        DescriptionType::"Description 2":
                            JSInvoiceLine.Description := SalesLine."Description 2";
                        DescriptionType::Remark:
                            JSInvoiceLine.Description := SalesLine.Remark;
                        DescriptionType::"Item No.":
                            JSInvoiceLine.Description := SalesLine."No.";
                    end;

                    case SpecType of
                        SpecType::"Description":
                            JSInvoiceLine."Item No." := SalesLine.Description;
                        SpecType::"Description 2":
                            JSInvoiceLine."Item No." := SalesLine."Description 2";
                        SpecType::Remark:
                            JSInvoiceLine."Item No." := SalesLine.Remark;
                        SpecType::"Item No.":
                            JSInvoiceLine."Item No." := SalesLine."No.";
                    end;

                    JSInvoiceLine."Unit Price" := Round(JSInvoiceLine."Amount Exc. VAT" / JSInvoiceLine.Quantity, 8);
                    JSInvoiceLine.INSERT(TRUE);
                until SalesLine.Next() = 0;
        end;
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
        GTInvHeader."System Doc No." := SalesHeader."No.";
        GTInvHeader."System Phantom No." := SalesHeader."No." + '-' + IncStr(l_CurrSubInvNum);
        GTInvHeader."Customer No." := SalesHeader."Bill-to Customer No.";
        GTInvHeader."Cust Name" := SalesHeader."Bill-to Name 2";
        GTInvHeader."Cust VAT No." := Customer."VAT Registration No.";
        GTInvHeader."Cust Address" := Customer."Address 2" + ' ' + Customer."Phone No.";
        GTInvHeader."Cust Bank" := CustomerBank.name + ' ' + CustomerBank."Bank Account No.";
        GTInvHeader."Amount Exc. VAT" := AmtExcVAT;
        GTInvHeader."Amount Inc. VAT" := AmtIncVAT;
        GTInvHeader."VAT Amount" := AmtIncVAT - AmtExcVAT;

        GTInvHeader.Insert();
        exit(GTInvHeader."System Phantom No.");
    end;

    procedure GetUOMDesc(UOMCode: Code[20]): Text[10]
    var
        UOM: Record "Unit of Measure";
    begin
        if (uom.get(UOMCode)) AND (UOM."Short Description" <> '') then
            exit(UOM."Short Description")
        else
            exit(UOMCode);
    end;

    procedure GetItemChargeAmount(SalesLine: Record "Sales Line"): Decimal;
    var
        ItemChargeAssignment: Record "Item Charge Assignment (Sales)";
        ItemChargeQty: Decimal;
        ItemChargeAmountIncVAT: Decimal;
        ItemChargeAmountExlVAT: Decimal;
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");
        ItemChargeAssignment.RESET;
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Type", SalesLine."Document Type");
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. No.", SalesLine."Document No.");
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Applies-to Doc. Line No.", SalesLine."Line No.");
        ItemChargeAssignment.SETRANGE(ItemChargeAssignment."Item No.", SalesLine."No.");
        ItemChargeAssignment.SETFILTER(ItemChargeAssignment."Qty. to Assign", '>0');
        IF ItemChargeAssignment.FINDFIRST THEN
            REPEAT
                IF SalesHeader."Prices Including VAT" THEN BEGIN
                    ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                    ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + SalesLine."VAT %" * 0.01);
                    ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                END ELSE BEGIN
                    ItemChargeQty += ItemChargeAssignment."Qty. to Assign";
                    ItemChargeAmountIncVAT := ItemChargeAssignment."Amount to Assign" * (1 + SalesLine."VAT %" * 0.01);
                    ItemChargeAmountExlVAT := ItemChargeAssignment."Amount to Assign";
                END;
            UNTIL ItemChargeAssignment.NEXT = 0;

        exit(ItemChargeAmountExlVAT);
    end;

    procedure GetGTInvNo(DocNo: Code[20]): Text[100]
    var
        SalesInvHeader: Record "Sales Invoice Header";
        GTHeader: Record "GT Invoice Header";
        JSInvNo: Text[100];
    begin
        JSInvNo := '';
        SalesInvHeader.SetRange("No.", DocNo);
        if SalesInvHeader.FindFirst() then begin
            GTHeader.Reset();
            GTHeader.SetRange("System Doc No.", SalesInvHeader."Pre-Assigned No.");
            if GTHeader.FindFirst() then
                repeat
                    if JSInvNo = '' then
                        JSInvNo := JSInvNo + GTHeader."JinSui Invoice No"
                    else
                        JSInvNo := JSInvNo + ';' + GTHeader."JinSui Invoice No";
                until GTHeader.Next() = 0;
        end;
        exit('');
    end;

    procedure UpdateGTNo(UpdateAll: Boolean)
    var
        window: Dialog;
        SalesInvHeader: Record "Sales Invoice Header";
        GTMgt: Codeunit "GT Management";
    begin
        window.Open('Update GT #1#########');
        SalesInvHeader.Reset();
        If not UpdateAll then
            SalesInvHeader.setrange("GT Invoice Nos", '');
        if SalesInvHeader.FindFirst() then
            repeat
                window.Update(1, SalesInvHeader."No.");
                SalesInvHeader."GT Invoice Nos" := GTMgt.GetGTInvNo(SalesInvHeader."No.");
                SalesInvHeader.Modify();
            until SalesInvHeader.Next() = 0;
        window.Close();
    end;

    procedure UpdateCustomerLedgerEntryGTNo(UpdateAll: Boolean)
    var
        window: Dialog;
        // SalesInvHeader: Record "Sales Invoice Header";
        GTMgt: Codeunit "GT Management";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        window.Open('Update GT #1#########');
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        If not UpdateAll then
            CustLedgerEntry.setrange("GT Invoice Nos", '');
        if CustLedgerEntry.FindFirst() then
            repeat
                window.Update(1, CustLedgerEntry."Document No.");
                CustLedgerEntry."GT Invoice Nos" := GTMgt.GetGTInvNo(CustLedgerEntry."Document No.");
                CustLedgerEntry.Modify();
            until CustLedgerEntry.Next() = 0;
        window.Close();
    end;

    procedure UpdateOrderNos(UpdateAll: Boolean)
    var
        window: Dialog;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TmpItem: Record Item temporary;
        Nos: Text;
    begin
        window.Open('Update Order #1#########');
        SalesInvHeader.Reset();
        If not UpdateAll then
            SalesInvHeader.setrange("Order Nos", '');
        if SalesInvHeader.FindFirst() then
            repeat
                Nos := '';
                TmpItem.Reset();
                if TmpItem.FindFirst() then
                    TmpItem.DeleteAll();
                window.Update(1, SalesInvHeader."No.");
                SalesInvLine.Reset();
                SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                if SalesInvLine.FindFirst() then
                    repeat
                        TmpItem.Init();
                        TmpItem."No." := SalesInvLine."Order No.";
                        if TmpItem.Insert() then;
                    until SalesInvLine.Next() = 0;
                TmpItem.Reset();
                if TmpItem.FindFirst() then
                    repeat
                        if nos = '' then
                            nos := TmpItem."No."
                        else
                            nos := nos + ';' + TmpItem."No.";
                    until TmpItem.Next() = 0;
                SalesInvHeader."Order Nos" := Nos;
                SalesInvHeader.Modify();
            until SalesInvHeader.Next() = 0;
        window.Close();
    end;


    procedure UpdateCustomerLedgerEntryOrderNos(UpdateAll: Boolean)
    var
        window: Dialog;
        // SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TmpItem: Record Item temporary;
        Nos: Text;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        window.Open('Update Order #1#########');
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        If not UpdateAll then
            CustLedgerEntry.setrange("Order No.", '');
        if CustLedgerEntry.FindFirst() then
            repeat
                Nos := '';
                TmpItem.Reset();
                if TmpItem.FindFirst() then
                    TmpItem.DeleteAll();
                window.Update(1, CustLedgerEntry."Document No.");
                SalesInvLine.Reset();
                SalesInvLine.SetRange("Document No.", CustLedgerEntry."Document No.");
                if SalesInvLine.FindFirst() then
                    repeat
                        TmpItem.Init();
                        TmpItem."No." := SalesInvLine."Order No.";
                        if TmpItem.Insert() then;
                    until SalesInvLine.Next() = 0;
                TmpItem.Reset();
                if TmpItem.FindFirst() then
                    repeat
                        if nos = '' then
                            nos := TmpItem."No."
                        else
                            nos := nos + '|' + TmpItem."No.";
                    until TmpItem.Next() = 0;
                CustLedgerEntry."Order No." := Nos;
                CustLedgerEntry.Modify();
            until CustLedgerEntry.Next() = 0;
        window.Close();
    end;

}