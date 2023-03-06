pageextension 58032 "GT Posted Sales Invoices" extends "Posted Sales Invoices"
{

    layout
    {
        addafter("No.")
        {
            field("Pre-Assigned No."; Rec."Pre-Assigned No.")
            {
                ApplicationArea = all;
            }
            field("GT Invoice Nos"; Rec."GT Invoice Nos")
            {
                ApplicationArea = all;
            }
            field("Order Nos"; Rec."Order Nos")
            {
                ApplicationArea = all;
            }
        }
        modify("Salesperson Code")
        {
            Visible = true;
        }
        modify(Amount)
        {
            Visible = true;
        }
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = all;
            }
            field("Sell-to Address 2"; Rec."Sell-to Address 2")
            {
                ApplicationArea = all;
                Visible = false;
            }
        }
    }
    trigger OnOpenPage()
    begin
        GTMGt.UpdateGTNo(false);
        GTMGt.UpdateOrderNos(false);
    end;

    var
        GTMGt: Codeunit "GT Management";

}
