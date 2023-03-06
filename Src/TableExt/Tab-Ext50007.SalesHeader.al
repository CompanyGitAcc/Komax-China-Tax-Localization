tableextension 50007 "GT Sales Header" extends "Sales Header"
{
    fields
    {
        field(58000; "Golden Tax Status"; Option)
        {
            Caption = 'Golden Tax Status';
            DataClassification = ToBeClassified;

            OptionMembers = " ",Outputed,Imported;
        }
        field(58001; "GT Invoice No."; Text[100])
        {
            Caption = 'GT Invoice No.';
            DataClassification = ToBeClassified;
        }
        field(58002; Remarks; Text[200])
        {
            Caption = 'Remarks';
            DataClassification = ToBeClassified;

        }
        field(58003; "Invoice Category"; Text[50])
        {
            Caption = 'Invoice Category';
            DataClassification = ToBeClassified;

            Editable = false;
        }
        field(58004; "Original Golden Invoice No."; Text[50])
        {
            Caption = 'Original Golden Invoice No.';
            DataClassification = ToBeClassified;

        }
        field(58005; "Original Invoice Category No."; Text[50])
        {
            Caption = 'Original Invoice Category No.';
            DataClassification = ToBeClassified;

        }
        field(58006; "Sales Credit Note No."; Text[50])
        {
            Caption = 'Sales Credit Note No.';
            DataClassification = ToBeClassified;
        }

        field(58007; "Golden Tax Lines"; Integer)
        {
            Caption = 'Golden Tax Lines';
            FieldClass = FlowField;
            CalcFormula = Count("GT Invoice Header" where("System Doc No." = field("No.")));
            Editable = false;
        }

        field(58008; "GT Exported"; Boolean)
        {
            Caption = 'GT Exported';
            DataClassification = ToBeClassified;
        }

        field(58009; "GT Invoice Remark"; Text[50])
        {
            Caption = 'JS Invoice Remark';
            DataClassification = ToBeClassified;
        }
        field(58010; "GT Amount Exc. VAT"; Decimal)
        {
            Caption = 'GT Amount Exc. VAT';
            DecimalPlaces = 0 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("GT Invoice Line"."Amount Exc. VAT" where("System Doc No." = field("No.")));
        }
        field(58011; "GT VAT Amount"; Decimal)
        {
            Caption = 'GT VAT Amount';
            DecimalPlaces = 0 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("GT Invoice Line"."VAT Amount" where("System Doc No." = field("No.")));
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
