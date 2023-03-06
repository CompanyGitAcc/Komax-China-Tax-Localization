pageextension 58028 "GT Sales Invoice List" extends "Sales Invoice List"
{
    layout
    {
        modify("Salesperson Code")
        {
            Visible = true;
        }
        modify(Amount)
        {
            Visible = true;
        }
        addafter(Amount)
        {
            field("Amount Including VAT"; Rec."Amount Including VAT")
            {
                Visible = true;
            }
            field("GT Amount Exc. VAT"; Rec."GT Amount Exc. VAT")
            {
                Visible = true;
            }
            field("GT VAT Amount"; Rec."GT VAT Amount")
            {
                Visible = true;
            }
        }

        addafter("Sell-to Customer Name")
        {
            field("Golden Tax Lines"; Rec."Golden Tax Lines")
            {
                ApplicationArea = all;
            }
            field("GT Files Exported"; Rec."GT Exported")
            {
                ApplicationArea = all;
            }

            field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = all;
            }
            field("Sell-to Address 2"; Rec."Sell-to Address 2")
            {
                ApplicationArea = all;
            }

        }
    }
    actions
    {
        addlast(processing)
        {
            group(GoldenTax)
            {
                Caption = 'Golden Tax';
                action("Generate Golden Tax")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Generate Golden Tax';
                    Image = Calculate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        SalesHeader2: Record "Sales Header";
                        l_recGTSetup: Record "General Ledger Setup";
                        DocFilter: Text;
                        ExportFiles: report "CN GoldenTax Generation";
                        ExportFilesXML: report "CN GoldenTax Export XML files";
                    begin
                        SalesHeader.Reset();
                        CurrPage.SetSelectionFilter(SalesHeader);
                        if SalesHeader.FindFirst() then
                            repeat
                                if DocFilter = '' then
                                    DocFilter := SalesHeader."No."
                                else
                                    DocFilter := DocFilter + '|' + SalesHeader."No.";
                            until SalesHeader.Next() = 0;
                        SalesHeader2.Reset();
                        SalesHeader2.setrange("Document Type", Rec."Document Type");
                        SalesHeader2.SetFilter("No.", DocFilter);
                        ExportFiles.SetTableView(SalesHeader2);
                        l_recGTSetup.GET;

                        CASE l_recGTSetup."File Format" OF
                            l_recGTSetup."File Format"::TXT:
                                begin
                                    if SalesHeader.FindFirst() then begin
                                        //ExportFiles.SetPara(true, false);
                                        ExportFiles.RunModal();
                                    end;
                                end;
                            l_recGTSetup."File Format"::XML:
                                REPORT.RUN(Xmlport::"CN GoldenTax Export XML files", TRUE, FALSE, SalesHeader);
                        END;

                    end;
                }
                action("Export GoldenTax")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export GoldenTax Files';
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        SalesHeader2: Record "Sales Header";
                        l_recGTSetup: Record "General Ledger Setup";
                        DocFilter: Text;
                        ExportFiles: report "CN GoldenTax Export files";
                        ExportFilesXML: report "CN GoldenTax Export XML files";
                    begin
                        SalesHeader.Reset();
                        CurrPage.SetSelectionFilter(SalesHeader);
                        if SalesHeader.FindFirst() then
                            repeat
                                if DocFilter = '' then
                                    DocFilter := SalesHeader."No."
                                else
                                    DocFilter := DocFilter + '|' + SalesHeader."No.";
                            until SalesHeader.Next() = 0;

                        SalesHeader2.Reset();
                        SalesHeader2.setrange("Document Type", Rec."Document Type");
                        SalesHeader2.SetFilter("No.", DocFilter);
                        ExportFiles.SetTableView(SalesHeader2);
                        l_recGTSetup.GET;
                        CASE l_recGTSetup."File Format" OF
                            l_recGTSetup."File Format"::TXT:
                                begin
                                    ExportFiles.SetTableView(SalesHeader2);
                                    ExportFiles.RunModal();
                                    Clear(ExportFiles);
                                end;
                        // l_recGTSetup."File Format"::XML:
                        //     REPORT.RUN(Xmlport::"CN GoldenTax Export XML files", TRUE, FALSE, SalesHeader2);
                        END;
                    end;
                }
                action("Import GoldenTax")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import GoldenTax Files';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        l_recGTSetup: Record "General Ledger Setup";
                    begin
                        l_recGTSetup.GET;
                        CASE l_recGTSetup."File Format" OF
                            //l_recGTSetup."File Format"::XML:
                            //    REPORT.RUN(REPORT::"Import GoldTax XML File");
                            l_recGTSetup."File Format"::TXT:
                                REPORT.RUN(REPORT::"CN GoldenTax Import Files");
                        END;
                    end;
                }
                action("Clear Export Mark")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Clear Export Mark';
                    Image = ClearLog;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        SalesHeader.Reset();
                        CurrPage.SetSelectionFilter(SalesHeader);
                        if SalesHeader.FindFirst() then
                            repeat
                                SalesHeader."GT Exported" := false;
                                SalesHeader.Modify();
                            until SalesHeader.Next() = 0;

                    end;
                }
            }
        }
    }


    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            if UserSetup."GoldenTax User" then
                Rec.SetRange(Status, Rec.Status::Released);
    end;


}
