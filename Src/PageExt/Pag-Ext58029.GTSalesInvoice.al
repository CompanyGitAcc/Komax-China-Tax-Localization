pageextension 58029 "GT Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = all;
            }
        }
        addafter("Work Description")
        {
            field("GT Invoice Remark"; Rec."GT Invoice Remark")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        // addlast("F&unctions")
        // {
        //     action("Export GoldenTax")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         Caption = 'Export GoldenTax Files';
        //         Image = Export;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedOnly = true;
        //         trigger OnAction()
        //         var
        //             SalesHeader: Record "Sales Header";
        //             l_recGTSetup: Record "General Ledger Setup";
        //         begin
        //             SalesHeader.SETRANGE("Document Type", Rec."Document Type");
        //             SalesHeader.SETRANGE("No.", Rec."No.");
        //             l_recGTSetup.GET;
        //             CASE l_recGTSetup."File Format" OF
        //                 l_recGTSetup."File Format"::TXT:
        //                     REPORT.RUN(REPORT::"CN GoldenTax Export files", TRUE, FALSE, SalesHeader);
        //                 l_recGTSetup."File Format"::XML:
        //                     REPORT.RUN(Xmlport::"CN GoldenTax Export XML files", TRUE, FALSE, SalesHeader);
        //             END;
        //         end;
        //     }
        //     action("Import GoldenTax")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         Caption = 'Import GoldenTax Files';
        //         Image = Import;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedOnly = true;
        //         trigger OnAction()
        //         var
        //             SalesHeader: Record "Sales Header";
        //             l_recGTSetup: Record "General Ledger Setup";
        //         begin
        //             l_recGTSetup.GET;
        //             CASE l_recGTSetup."File Format" OF
        //                 l_recGTSetup."File Format"::XML:
        //                     REPORT.RUN(REPORT::"Import GoldTax XML File");
        //                 l_recGTSetup."File Format"::TXT:
        //                     REPORT.RUN(REPORT::"CN GoldenTax Import Files");
        //             END;
        //         end;
        //     }
        // }
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
