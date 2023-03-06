table 50005 "GT Invoice Header"
{
    Caption = 'GT Invoice Header';
    DrillDownPageId = "GT Invoice List";
    LookupPageId = "GT Invoice List";

    fields
    {
        field(1; "System Doc No."; Code[20])  //eg. SI-22090001
        {
            Caption = 'System Doc No.';
        }
        field(2; "System Phantom No."; Code[30])   //"Navision Phantom No." -> System Phantom No., SI-22090001-001
        {
            Caption = 'System Phantom No.';
        }

        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(4; "Cust Name"; Text[100])
        {
            Caption = 'Cust Name';
        }
        field(5; "Cust VAT No."; Text[100])
        {
            Caption = 'Cust VAT No.';
        }
        field(6; "Cust Address"; Text[100])
        {
            Caption = 'Cust Address';
        }
        field(7; "Cust Bank"; Text[100])
        {
            Caption = 'Cust Name';
        }

        field(8; "Amount Exc. VAT"; Decimal)
        {
            Caption = 'Amount Exc. VAT';
            DecimalPlaces = 0 : 2;
        }
        field(9; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DecimalPlaces = 0 : 2;
        }
        field(10; "Amount Inc. VAT"; Decimal)
        {
            Caption = 'Amount Inc. VAT';
            DecimalPlaces = 0 : 2;
        }
        field(11; "Export DateTime"; DateTime)
        {
            Caption = 'Export Datetime';
        }
        field(12; "Import DateTime"; DateTime)
        {
            Caption = 'Import Datetime';
        }
        field(13; "JinSui Invoice No"; Code[20])
        {
            Caption = 'JinSui Invoice No';
        }
        field(14; "Memo"; text[100])
        {
            Caption = 'Memo';
        }
        field(15; "Remark"; text[100])
        {
            Caption = 'Remark';
        }
        field(18; "Amount Exc. VAT Calc."; Decimal)
        {
            Caption = 'Amount Exc. VAT Calc.';
            DecimalPlaces = 0 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("GT Invoice Line"."Amount Exc. VAT" where("System Phantom No." = field("System Phantom No.")));
        }
        field(19; "VAT Amount Calc."; Decimal)
        {
            Caption = 'VAT Amount Calc.';
            DecimalPlaces = 0 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("GT Invoice Line"."VAT Amount" where("System Phantom No." = field("System Phantom No.")));

        }

    }

    keys
    {
        key(Key1; "System Doc No.", "System Phantom No.")
        {
            Clustered = true;
        }
        key(Key2; "JinSui Invoice No")
        {
        }
    }

    fieldgroups
    {
    }
    trigger OnDelete()
    var
        GTInvLine: Record "GT Invoice Line";
    begin
        GTInvLine.Reset();
        GTInvLine.SetRange("System Phantom No.", Rec."System Phantom No.");
        if GTInvLine.FindFirst() then
            GTInvLine.DeleteAll();
    end;
}

