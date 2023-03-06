tableextension 50009 "GT Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(58001; "GT Invoice Nos"; Text[1000])
        {
            Caption = 'GT Invoice Nos';
            DataClassification = ToBeClassified;
        }
        field(58003; "Order Nos"; Text[1000])
        {
            Caption = 'Order Nos';
            DataClassification = ToBeClassified;
        }

        field(58002; Remarks; Text[200])
        {
            Caption = 'Remarks';
            DataClassification = ToBeClassified;
        }

    }
    trigger OnDelete()
    var
        GTSalesheader: Record "GT Invoice Header";
    begin
        GTSalesheader.Reset();
        GTSalesheader.SetRange("System Doc No.", Rec."No.");
        if GTSalesheader.FindFirst() then
            repeat
                GTSalesheader.Delete(true);
            until GTSalesheader.Next() = 0;
    end;
}
