report 50028 "CN GoldenTax Export XML files"
{
    //     Caption = 'Export Golden Tax XML files';
    //     ProcessingOnly = true;

    //     dataset
    //     {
    //         dataitem("Sales Header"; "Sales Header")
    //         {
    //             DataItemTableView = SORTING("Document Type", "No.");
    //             RequestFilterFields = "Document Type", "No.", "Bill-to Customer No.";
    //             dataitem("Sales Line"; "Sales Line")
    //             {
    //                 DataItemLink = "Document No." = FIELD("No.");
    //                 DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

    //                 trigger OnAfterGetRecord()
    //                 var
    //                     l_recItemChargeAssignment: Record "Item Charge Assignment (Sales)";
    //                     l_recGTInvoiceLine: Record "GT Invoice Line";
    //                     l_recSalesLine: Record "Sales Line";
    //                     l_decItemChangeAmountIncVAT: Decimal;
    //                     l_decItemChargeQty: Decimal;
    //                     l_decItemChgPriceIncVat: Decimal;
    //                     l_decItemChangeAmountExlVAT: Decimal;
    //                 begin
    //                     IF (Type <> Type::Item) OR ("Unit Price" = 0) THEN CurrReport.SKIP;

    //                     //Expense Apportion
    //                     l_recItemChargeAssignment.SETRANGE(l_recItemChargeAssignment."Applies-to Doc. Type", "Document Type");
    //                     l_recItemChargeAssignment.SETRANGE(l_recItemChargeAssignment."Applies-to Doc. No.", "Document No.");
    //                     l_recItemChargeAssignment.SETRANGE(l_recItemChargeAssignment."Applies-to Doc. Line No.", "Sales Line"."Line No.");
    //                     l_recItemChargeAssignment.SETRANGE(l_recItemChargeAssignment."Item No.", "Sales Line"."No.");
    //                     l_recItemChargeAssignment.SETFILTER(l_recItemChargeAssignment."Qty. to Assign", '>0');
    //                     IF l_recItemChargeAssignment.FIND('-') THEN
    //                         REPEAT
    //                             IF "Sales Header"."Prices Including VAT" THEN BEGIN
    //                                 l_decItemChargeQty += l_recItemChargeAssignment."Qty. to Assign";
    //                                 l_decItemChangeAmountIncVAT += l_recItemChargeAssignment."Amount to Assign" * (1 + "VAT %" * 0.01);
    //                                 l_decItemChangeAmountExlVAT += l_recItemChargeAssignment."Amount to Assign";
    //                             END ELSE BEGIN
    //                                 l_decItemChargeQty += l_recItemChargeAssignment."Qty. to Assign";
    //                                 l_decItemChangeAmountExlVAT += l_recItemChargeAssignment."Amount to Assign";
    //                                 l_decItemChangeAmountIncVAT += l_recItemChargeAssignment."Amount to Assign" * (1 + "VAT %" * 0.01);
    //                             END;
    //                         UNTIL l_recItemChargeAssignment.NEXT = 0;

    //                     IF GLSetup."Expense Apportion" THEN BEGIN
    //                         "Amount Including VAT" += l_decItemChangeAmountIncVAT;
    //                         Amount += l_decItemChangeAmountExlVAT;
    //                         IF "Sales Header"."Prices Including VAT" THEN
    //                             "Unit Price" := "Amount Including VAT" / Quantity
    //                         ELSE
    //                             "Unit Price" := (("Unit Price" * Quantity) + l_decItemChangeAmountExlVAT) / Quantity;
    //                     END;

    //                     //lineAmountIncVAT := "Amount Including VAT";
    //                     //unitPriceIncVAT := lineAmountIncVAT/Quantity;
    //                     lineAmountExcVAT := Amount;
    //                     unitPriceExcVAT := lineAmountExcVAT / Quantity;

    //                     totalAmount += Amount;
    //                     totalAmountIncVAT += "Amount Including VAT";
    //                     remQuantity := Quantity;

    //                     IF (("Unit Price" > GLSetup."Max Invoice Amount") AND (NOT bSplitDec)) THEN
    //                         ERROR(ERR010, GLSetup."Max Invoice Amount");


    //                     IF lineAmountExcVAT >= GLSetup."Max Invoice Amount" THEN BEGIN
    //                         REPEAT
    //                             IF bSplitDec THEN
    //                                 splitQuantity := ROUND((GLSetup."Max Invoice Amount" / unitPriceExcVAT), 0.01, '<')
    //                             ELSE
    //                                 splitQuantity := ROUND((GLSetup."Max Invoice Amount" / unitPriceExcVAT), 1, '<');
    //                             IF splitQuantity <= 0 THEN ERROR(ERR012);
    //                             remQuantity -= splitQuantity;
    //                             InsJinSuiLine("Sales Line", splitQuantity, "Sales Header"."Prices Including VAT", 'INVOICE#' + FORMAT(g_intGTInvoiceNo));
    //                             g_intGTInvoiceNo += 1;
    //                         UNTIL remQuantity <= splitQuantity;

    //                         IF (remQuantity = splitQuantity) THEN BEGIN
    //                             InsJinSuiLine("Sales Line", splitQuantity, "Sales Header"."Prices Including VAT", 'INVOICE#' + FORMAT(g_intGTInvoiceNo));
    //                             g_intGTInvoiceNo += 1;
    //                         END ELSE BEGIN
    //                             IF remQuantity > 0 THEN InsJinSuiLine("Sales Line", remQuantity, "Sales Header"."Prices Including VAT", 'INVOICE#' + FORMAT(g_intGTInvoiceNo));
    //                             g_intGTInvoiceNo += 1;
    //                         END;
    //                     END ELSE BEGIN
    //                         InsJinSuiLine("Sales Line", Quantity, "Sales Header"."Prices Including VAT", '');
    //                     END
    //                 end;

    //                 trigger OnPostDataItem()
    //                 begin
    //                     removeRoundError("Sales Header");
    //                     g_tempGTInvoiceLine.DELETEALL;
    //                 end;

    //                 trigger OnPreDataItem()
    //                 begin
    //                     totalAmount := 0;
    //                     totalAmountIncVAT := 0;
    //                 end;
    //             }
    //             dataitem("GT Invoice Line"; "GT Invoice Line")
    //             {
    //                 DataItemLink = "Navision Doc No." = FIELD("No.");
    //                 DataItemTableView = SORTING("Navision Phantom No.");
    //                 dataitem(Integer; Integer)
    //                 {
    //                     DataItemTableView = SORTING(Number);

    //                     trigger OnAfterGetRecord()
    //                     begin
    //                         IF Number > 1 THEN
    //                             "GT Invoice Line".NEXT;
    //                     end;

    //                     trigger OnPreDataItem()
    //                     begin
    //                         SETRANGE(Number, 1, InvLineNumber);
    //                     end;
    //                 }

    //                 trigger OnAfterGetRecord()
    //                 begin
    //                     InvLineNumber := CountOutputJSLine("GT Invoice Line", "Sales Header", GLSetup."Max Invoice Lines", GLSetup."Max Invoice Amount", 'INVOICE#' + FORMAT(g_intGTInvoiceNo));
    //                     g_intInvoiceNumber := g_intInvoiceNumber + 1;
    //                 end;

    //                 trigger OnPreDataItem()
    //                 begin
    //                     "GT Invoice Line".SETCURRENTKEY("JinSui Invoice No");
    //                     "GT Invoice Line".SETASCENDING("JinSui Invoice No", FALSE);
    //                 end;
    //             }

    //             trigger OnAfterGetRecord()
    //             var
    //                 l_recCustomerBank: Record "Customer Bank Account";
    //                 l_recCustomer: Record Customer;
    //             begin
    //                 IF Status <> Status::Released THEN ERROR(ERR013, "No.");

    //                 g_recGTInvoiceLine.SETRANGE("Navision Doc No.", "No.");
    //                 SETRANGE("Document Type", "Document Type");
    //                 IF FIND('-') THEN
    //                     REPEAT
    //                         IF g_recGTInvoiceLine."Import DateTime" <> 0DT THEN ERROR(ERR011, g_recGTInvoiceLine."Navision Doc No.");
    //                         DELETE;
    //                     UNTIL NEXT = 0;
    //                 RESET;
    //                 /*
    //                 IF ("Sales Header"."VAT Registration No." = '') THEN
    //                    ERROR(ERR005, "Sales Header"."No.");

    //                 l_recCustomerBank.SETRANGE("Customer No.","Sales Header"."Bill-to Customer No.");
    //                 IF (l_recCustomerBank.FIND('-')) AND ((l_recCustomerBank.Name + l_recCustomerBank."Bank Account No.") <> '') THEN BEGIN
    //                 END
    //                 ELSE
    //                   ERROR(ERR007,"Sales Header"."Bill-to Customer No.");

    //                 l_recCustomer.GET("Sales Header"."Bill-to Customer No.");
    //                 IF ("Sales Header"."Bill-to Address" = '') AND (l_recCustomer."Phone No." = '') THEN
    //                    ERROR(ERR006, "Sales Header"."No.");
    //                 g_intGTInvoiceNo:=0;
    //                 */

    //             end;

    //             trigger OnPostDataItem()
    //             begin
    //                 MESSAGE(MSG001);
    //             end;
    //         }
    //     }

    //     requestpage
    //     {

    //         layout
    //         {
    //             area(content)
    //             {
    //                 group("选项")
    //                 {
    //                     Caption = '选项';
    //                     group(Option)
    //                     {
    //                         Caption = 'Option';
    //                         field(bSplitDec; bSplitDec)
    //                         {
    //                             Caption = 'Split Quantity into Decimal';
    //                             ApplicationArea = all;
    //                         }
    //                     }
    //                 }
    //             }
    //         }

    //         actions
    //         {
    //         }
    //     }

    //     labels
    //     {
    //     }

    //     trigger OnInitReport()
    //     begin
    //         GLSetup.GET;
    //     end;

    //     trigger OnPostReport()
    //     var
    //         OutS: OutStream;
    //     begin
    //         IF g_tempGTInvoiceLine.FINDFIRST THEN BEGIN
    //             REPEAT
    //                 g_recGTInvoiceLine.RESET;
    //                 IF g_recGTInvoiceLine.GET(g_tempGTInvoiceLine."Navision Phantom No.") THEN BEGIN
    //                     g_recGTInvoiceLine."JinSui Invoice No" := g_tempGTInvoiceLine."JinSui Invoice No";
    //                     g_recGTInvoiceLine.MODIFY;
    //                 END;
    //             UNTIL g_tempGTInvoiceLine.NEXT = 0;
    //         END;

    //         COMMIT;

    //         g_txtGFilePathAndName := GLSetup."File Path" + '\GT_' + "Sales Header".GETFILTER("No.") + '.xml';
    //         //#BC190<<
    //         //IF FILE.EXISTS(g_txtGFilePathAndName) THEN;
    //         //outFile.WRITEMODE(TRUE);
    //         //outFile.TEXTMODE(TRUE);
    //         //outFile.CREATEOUTSTREAM(OutS);
    //         //IF outFile.CREATE(g_txtGFilePathAndName) THEN;
    //         //>>

    //         g_xpExportInvoice.SETTABLEVIEW("Sales Header");
    //         g_xpExportInvoice.SalesOrderFilter(g_intInvoiceNumber);
    //         g_xpExportInvoice.SETDESTINATION(OutS);
    //         g_xpExportInvoice.EXPORT;
    //     end;

    //     trigger OnPreReport()
    //     begin
    //         IF GLSetup."Max Invoice Lines" <= 0 THEN ERROR(Err001);

    //         IF GLSetup."Max Invoice Amount" <= 0 THEN ERROR(Err003);
    //         IF GLSetup."Commodity Tax No." = '' THEN ERROR(ERR004);
    //         GLSetup.TESTFIELD("File Path");
    //         g_intInvoiceNumber := 0;
    //     end;

    //     var
    //         g_recGTInvoiceLine: Record "GT Invoice Line";
    //         bSplitDec: Boolean;
    //         lineAmountIncVAT: Decimal;
    //         unitPriceIncVAT: Decimal;
    //         remQuantity: Decimal;
    //         splitQuantity: Decimal;
    //         totalAmountIncVAT: Decimal;
    //         totalAmount: Decimal;
    //         InvLineNumber: Integer;
    //         GLSetup: Record "General Ledger Setup";
    //         Err001: Label 'Enter the Max Invoice Lines in the Golden Tax System Setup.';
    //         Err003: Label 'Enter the Max Invoice Amount in the Golden Tax System Setup.';
    //         ERR004: Label 'Goods Tax No. can not be empty.';
    //         ERR007: Label 'Check Custemer Bank Account %1';
    //         ERR010: Label 'Unit price %1 is greater than the maximum invoice amount.';
    //         ERR011: Label 'Document %1 has been imported and it can''t be exported again.';
    //         g_intInvoiceNumber: Integer;
    //         g_xpExportInvoice: XMLport "CN GoldenTax Export XML files";
    //         g_txtGFilePathAndName: Text;
    //         outFile: File;
    //         ERR013: Label 'Please release sales document %1 first.';
    //         ERR012: Label 'Data is error';
    //         ERR005: Label 'Document %1: Bill-to Customer''s VAT Registration No. shall not be empty.';
    //         ERR006: Label 'Document %1: Bill-to Address or Customer Phone Number shall not be empty.';
    //         g_intGTInvoiceNo: Integer;
    //         g_tempGTInvoiceLine: Record "GT Invoice Line" temporary;
    //         lineAmountExcVAT: Decimal;
    //         unitPriceExcVAT: Decimal;
    //         MSG001: Label 'Finished.';

    //     procedure InsJinSuiLine(l_Salesline: Record "Sales Line"; Quantity: Decimal; bIncVAT: Boolean; GTInvoiceNo: Text)
    //     var
    //         l_recGTInvoiceLine: Record "GT Invoice Line";
    //         l_NoFilter: Code[20];
    //         l_CurrSubInvNum: Code[20];
    //         lrecItem: Record Item;
    //         lItemReference: Record "Item Reference";
    //     begin
    //         l_NoFilter := l_Salesline."Document No." + '-' + '???';
    //         l_recGTInvoiceLine.SETFILTER("Navision Phantom No.", l_NoFilter);
    //         l_CurrSubInvNum := '000';
    //         IF l_recGTInvoiceLine.FIND('+') THEN
    //             l_CurrSubInvNum := COPYSTR(l_recGTInvoiceLine."Navision Phantom No.", STRLEN(l_recGTInvoiceLine."Navision Phantom No.") - 2, 3);

    //         l_recGTInvoiceLine.INIT;

    //         l_recGTInvoiceLine."SalesLine No." := l_Salesline."No.";
    //         l_recGTInvoiceLine."Navision Doc No." := l_Salesline."Document No.";
    //         l_recGTInvoiceLine."Navision Phantom No." := l_Salesline."Document No." + '-' + INCSTR(l_CurrSubInvNum);

    //         case GLSetup."Commodity Description" of
    //             GLSetup."Commodity Description"::"Line Description":
    //                 l_recGTInvoiceLine.Description := l_Salesline.Description;
    //             GLSetup."Commodity Description"::"Line Description 2":
    //                 l_recGTInvoiceLine.Description := l_Salesline."Description 2";
    //             GLSetup."Commodity Description"::"Item Description":
    //                 if lrecItem.Get(l_Salesline."No.") then
    //                     l_recGTInvoiceLine.Description := lrecItem.Description;
    //             GLSetup."Commodity Description"::"Item Description 2":
    //                 if lrecItem.Get(l_Salesline."No.") then
    //                     l_recGTInvoiceLine.Description := lrecItem."Description 2";
    //             GLSetup."Commodity Description"::"Item Reference Description":
    //                 if lItemReference.Get(l_Salesline."No.", l_Salesline."Variant Code", lItemReference."Reference Type"::Customer, l_Salesline."Bill-to Customer No.", l_Salesline."No.") then
    //                     l_recGTInvoiceLine.Description := lItemReference.Description;
    //             GLSetup."Commodity Description"::"Item Reference Description 2":
    //                 if lItemReference.Get(l_Salesline."No.", l_Salesline."Variant Code", lItemReference."Reference Type"::Customer, l_Salesline."Bill-to Customer No.", l_Salesline."No.") then
    //                     l_recGTInvoiceLine.Description := lItemReference."Description 2";
    //         end;

    //         l_recGTInvoiceLine."Unit of Measure" := l_Salesline."Unit of Measure";
    //         l_recGTInvoiceLine."Line Quantity" := Quantity;
    //         //"Unit Price" := l_Salesline."Unit Price";
    //         l_recGTInvoiceLine."VAT%" := l_Salesline."VAT %" * 0.01;
    //         l_recGTInvoiceLine.GST := GLSetup."Commodity Tax No.";
    //         l_recGTInvoiceLine."Discount %" := l_Salesline."Line Discount %";
    //         l_recGTInvoiceLine."Document Type" := l_Salesline."Document Type";

    //         l_recGTInvoiceLine."Export DateTime" := CURRENTDATETIME;
    //         l_recGTInvoiceLine."Sell-to Customer No." := l_Salesline."Sell-to Customer No.";

    //         l_recGTInvoiceLine."JinSui Invoice No" := GTInvoiceNo;

    //         IF bIncVAT THEN BEGIN
    //             l_recGTInvoiceLine."Amount Inc. VAT" := ROUND(l_Salesline."Unit Price" * l_recGTInvoiceLine."Line Quantity" * (1 - l_recGTInvoiceLine."Discount %" * 0.01), 0.01);
    //             l_recGTInvoiceLine."Amount Exc. VAT" := ROUND(l_Salesline."Unit Price" * l_recGTInvoiceLine."Line Quantity" * (1 - l_recGTInvoiceLine."Discount %" * 0.01) / (1 + l_Salesline."VAT %" * 0.01), 0.01)
    //         ;
    //             l_recGTInvoiceLine."VAT Amount" := l_recGTInvoiceLine."Amount Inc. VAT" - l_recGTInvoiceLine."Amount Exc. VAT";
    //             //"Discount Amount" :="Amount Inc. VAT" * l_Salesline."Line Discount %"*0.01;
    //             l_recGTInvoiceLine."Discount Amount" := ROUND(l_Salesline."Unit Price" * l_recGTInvoiceLine."Line Quantity" * l_recGTInvoiceLine."Discount %" * 0.01 / (1 + l_Salesline."VAT %" * 0.01), 0.01);
    //             l_recGTInvoiceLine."Unit Price" := ROUND(l_Salesline."Unit Price" / (1 + l_Salesline."VAT %" * 0.01), 0.01);
    //         END ELSE BEGIN
    //             l_recGTInvoiceLine."Amount Inc. VAT" := ROUND(l_Salesline."Unit Price" * l_recGTInvoiceLine."Line Quantity" * (1 + l_Salesline."VAT %" * 0.01) * (1 - l_recGTInvoiceLine."Discount %" * 0.01), 0.01)
    //         ;
    //             l_recGTInvoiceLine."Amount Exc. VAT" := ROUND(l_Salesline."Unit Price" * l_recGTInvoiceLine."Line Quantity" * (1 - l_recGTInvoiceLine."Discount %" * 0.01), 0.01);
    //             l_recGTInvoiceLine."VAT Amount" := l_recGTInvoiceLine."Amount Inc. VAT" - l_recGTInvoiceLine."Amount Exc. VAT";
    //             //"Discount Amount" := "Amount Exc. VAT" * l_Salesline."Line Discount %"*0.01;
    //             l_recGTInvoiceLine."Discount Amount" := ROUND(l_Salesline."Unit Price" * l_recGTInvoiceLine."Line Quantity" * l_recGTInvoiceLine."Discount %" * 0.01, 0.01);
    //             l_recGTInvoiceLine."Unit Price" := l_Salesline."Unit Price";
    //         END;
    //         IF l_recGTInvoiceLine.INSERT(TRUE) THEN;

    //     end;

    //     procedure removeRoundError(l_SalesHeader: Record "Sales Header")
    //     var
    //         l_JSInvLine: Record "GT Invoice Line";
    //         l_Amount: Decimal;
    //         l_AmountIncVAT: Decimal;
    //     begin

    //         l_JSInvLine.SETRANGE("Navision Doc No.", l_SalesHeader."No.");

    //         IF l_JSInvLine.FIND('-') THEN BEGIN
    //             REPEAT
    //                 l_Amount += l_JSInvLine."Amount Exc. VAT";
    //                 l_AmountIncVAT += l_JSInvLine."Amount Inc. VAT";
    //             UNTIL l_JSInvLine.NEXT = 0;

    //             IF ((totalAmount - l_Amount) <> 0) OR
    //                ((totalAmountIncVAT - l_AmountIncVAT) <> 0) THEN BEGIN
    //                 l_JSInvLine."Amount Exc. VAT" += totalAmount - l_Amount;
    //                 l_JSInvLine."Amount Inc. VAT" += totalAmountIncVAT - l_AmountIncVAT;
    //             END;
    //             l_JSInvLine.MODIFY;
    //         END;


    //     end;

    //     procedure CountOutputJSLine(l_JSInvLine: Record "GT Invoice Line"; l_SalesHeader: Record "Sales Header"; l_maxInvLine: Integer; l_maxInvAmount: Decimal; l_GTInvoiceNo: Text): Integer
    //     var
    //         l_AmountIncVAT: Decimal;
    //         l_OutputLine: Integer;
    //     begin

    //         IF l_JSInvLine."JinSui Invoice No" <> '' THEN
    //             EXIT(1);

    //         l_JSInvLine.SETRANGE(l_JSInvLine."Document Type", l_SalesHeader."Document Type");
    //         l_JSInvLine.SETRANGE("Navision Doc No.", l_SalesHeader."No.");
    //         l_JSInvLine.FIND;
    //         l_AmountIncVAT := 0;
    //         l_OutputLine := 0;

    //         REPEAT

    //             IF l_OutputLine = l_maxInvLine THEN EXIT(l_OutputLine);

    //             IF l_AmountIncVAT + l_JSInvLine."Amount Exc. VAT" <= l_maxInvAmount THEN BEGIN

    //                 l_AmountIncVAT += l_JSInvLine."Amount Exc. VAT";
    //                 l_OutputLine += 1;

    //             END ELSE
    //                 EXIT(l_OutputLine);
    //             g_tempGTInvoiceLine.INIT;
    //             g_tempGTInvoiceLine := l_JSInvLine;
    //             g_tempGTInvoiceLine."JinSui Invoice No" := l_GTInvoiceNo;
    //             g_tempGTInvoiceLine.INSERT;
    //         UNTIL l_JSInvLine.NEXT = 0;

    //         g_intGTInvoiceNo += 1;

    //         EXIT(l_OutputLine);

    //     end;
}

