tableextension 50011 "GT Cust. Ledger Entry" extends "Cust. Ledger Entry"
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
    }
}
