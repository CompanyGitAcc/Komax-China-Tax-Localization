pageextension 58034 "GT Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("GT Invoice Nos"; Rec."GT Invoice Nos")
            {
                ApplicationArea = all;
            }
            // field("Order Nos"; Rec."Order Nos")
            // {
            //     ApplicationArea = all;

            //     trigger OnDrillDown()
            //     var
            //         SalesOrder: page "Sales Order";
            //         SalesHeader: Record "Sales Header";
            //     begin
            //         SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            //         SalesHeader.SetFilter("No.", Rec."Order Nos");
            //         SalesOrder.SetTableView(SalesHeader);
            //         SalesOrder.Run();
            //         Clear(SalesOrder);
            //     end;
            // }
        }
        modify("Salesperson Code")
        {
            Visible = false;
        }
        moveafter("GT Invoice Nos"; "Order No.")

    }
    trigger OnOpenPage()
    begin
        GTMGt.UpdateCustomerLedgerEntryGTNo(false);
        GTMGt.UpdateCustomerLedgerEntryOrderNos(false);
    end;

    var
        GTMGt: Codeunit "GT Management";
        SONO: Code[20];

}
