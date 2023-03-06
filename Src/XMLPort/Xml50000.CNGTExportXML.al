xmlport 50000 "CN GoldenTax Export XML files"
{
    //     schema
    //     {
    //         textelement(Kp)
    //         {
    //             textelement(Version)
    //             {

    //                 trigger OnBeforePassVariable()
    //                 begin
    //                     Version := '2.0';
    //                 end;
    //             }
    //             textelement(Fpxx)
    //             {
    //                 textelement(Zsl)
    //                 {
    //                 }
    //                 tableelement("Sales Header"; "Sales Header")
    //                 {
    //                     XmlName = 'Fpsj';
    //                     tableelement("GT Invoice Line"; "GT Invoice Line")
    //                     {
    //                         LinkFields = "Navision Doc No." = FIELD("No.");
    //                         LinkTable = "Sales Header";
    //                         XmlName = 'Fp';
    //                         fieldelement(Djh; "GT Invoice Line"."Navision Phantom No.")
    //                         {
    //                         }
    //                         fieldelement(Gfmc; "Sales Header"."Bill-to Name")
    //                         {
    //                         }
    //                         fieldelement(Gfsh; "Sales Header"."VAT Registration No.")
    //                         {
    //                         }
    //                         textelement(Gfyhzh)
    //                         {
    //                         }
    //                         textelement(Gfdzdh)
    //                         {
    //                         }
    //                         textelement(Bz)
    //                         {
    //                         }
    //                         textelement(Fhr)
    //                         {

    //                             trigger OnBeforePassVariable()
    //                             begin
    //                                 Fhr := g_recGTSetup.Checker;
    //                             end;
    //                         }
    //                         textelement(Skr)
    //                         {

    //                             trigger OnBeforePassVariable()
    //                             begin
    //                                 Skr := g_recGTSetup.Payee;
    //                             end;
    //                         }
    //                         fieldelement(Spbmbbh; "Sales Header"."No.")
    //                         {
    //                         }
    //                         textelement(Hsbz)
    //                         {

    //                             trigger OnBeforePassVariable()
    //                             begin
    //                                 Hsbz := '2';
    //                             end;
    //                         }
    //                         textelement(Spxx)
    //                         {
    //                             tableelement(Integer; Integer)
    //                             {
    //                                 XmlName = 'Sph';
    //                                 textelement(Xh)
    //                                 {

    //                                     trigger OnBeforePassVariable()
    //                                     begin
    //                                         Xh := FORMAT(g_intXh);
    //                                     end;
    //                                 }
    //                                 fieldelement(Spmc; "GT Invoice Line".Description)
    //                                 {
    //                                 }
    //                                 textelement(Ggxh)
    //                                 {
    //                                 }
    //                                 fieldelement(Jldw; "GT Invoice Line"."Unit of Measure")
    //                                 {
    //                                 }
    //                                 fieldelement(Spbm; "GT Invoice Line".GST)
    //                                 {
    //                                 }
    //                                 fieldelement(Qyspbm; "GT Invoice Line"."SalesLine No.")
    //                                 {
    //                                 }
    //                                 textelement(Syyhzcbz)
    //                                 {

    //                                     trigger OnBeforePassVariable()
    //                                     begin
    //                                         Syyhzcbz := '0';
    //                                     end;
    //                                 }
    //                                 textelement(Lslbz)
    //                                 {
    //                                 }
    //                                 textelement(Yhzcsm)
    //                                 {
    //                                 }
    //                                 fieldelement(Dj; "GT Invoice Line"."Unit Price")
    //                                 {
    //                                 }
    //                                 fieldelement(Sl; "GT Invoice Line"."Line Quantity")
    //                                 {
    //                                 }
    //                                 fieldelement(Je; "GT Invoice Line"."Amount Exc. VAT")
    //                                 {
    //                                 }
    //                                 fieldelement(Slv; "GT Invoice Line"."VAT%")
    //                                 {
    //                                 }
    //                                 fieldelement(Kce; "GT Invoice Line"."Discount Amount")
    //                                 {
    //                                 }

    //                                 trigger OnAfterGetRecord()
    //                                 begin
    //                                     IF Integer.Number > 1 THEN
    //                                         "GT Invoice Line".NEXT;
    //                                     g_intXh := g_intXh + 1;
    //                                 end;

    //                                 trigger OnPreXmlItem()
    //                                 begin
    //                                     Integer.SETRANGE(Number, 1, g_decInvLineNumber);
    //                                 end;
    //                             }
    //                         }

    //                         trigger OnAfterGetRecord()
    //                         begin
    //                             g_decInvLineNumber := CountOutputJSLine("GT Invoice Line", "Sales Header", g_recGTSetup."Max Invoice Lines", g_recGTSetup."Max Invoice Amount");
    //                             g_intDjh := g_intDjh + 1;
    //                             g_intXh := 0;
    //                         end;
    //                     }

    //                     trigger OnAfterGetRecord()
    //                     var
    //                         l_recCustomerBank: Record "Customer Bank Account";
    //                         l_recCustomer: Record Customer;
    //                     begin
    //                         g_intDjh := 0;

    //                         l_recCustomerBank.SETRANGE("Customer No.", "Sales Header"."Bill-to Customer No.");
    //                         IF (l_recCustomerBank.FIND('-')) AND ((l_recCustomerBank.Name + l_recCustomerBank."Bank Account No.") <> '') THEN BEGIN
    //                             Gfyhzh := l_recCustomerBank."Bank Account No.";
    //                         END;

    //                         l_recCustomer.GET("Sales Header"."Bill-to Customer No.");
    //                         Gfdzdh := "Sales Header"."Bill-to Address" + l_recCustomer."Phone No.";
    //                     end;
    //                 }
    //             }
    //         }
    //     }

    //     requestpage
    //     {

    //         layout
    //         {
    //         }

    //         actions
    //         {
    //         }
    //     }

    //     trigger OnPreXmlPort()
    //     begin
    //         g_recGTSetup.GET;
    //     end;

    //     var
    //         g_recGTSetup: Record "General Ledger Setup";
    //         g_decInvLineNumber: Integer;
    //         g_intDjh: Integer;
    //         g_intXh: Integer;

    //     procedure CountOutputJSLine(l_JSInvLine: Record "GT Invoice Line"; l_SalesHeader: Record "Sales Header"; l_maxInvLine: Integer; l_maxInvAmount: Decimal): Integer
    //     var
    //         l_AmountIncVAT: Decimal;
    //         l_OutputLine: Integer;
    //     begin

    //         l_JSInvLine.SETRANGE("Document Type", l_SalesHeader."Document Type");
    //         l_JSInvLine.SETRANGE("Navision Doc No.", l_SalesHeader."No.");
    //         l_JSInvLine.SETRANGE("JinSui Invoice No", l_JSInvLine."JinSui Invoice No");
    //         EXIT(l_JSInvLine.COUNT);
    //     end;

    //     procedure SalesOrderFilter(InvoiceNumber: Integer)
    //     begin
    //         Zsl := FORMAT(InvoiceNumber);
    //     end;
}

