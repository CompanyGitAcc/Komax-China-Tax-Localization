table 50006 "GT Invoice Line"
{
    Caption = 'GT Invoice Line';
    DrillDownPageId = "GT Invoice Lines";
    LookupPageId = "GT Invoice Lines";

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
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Item No."; Text[100])
        {
            Caption = 'Specification';
            //TableRelation = Item;
        }
        field(6; "Unit of Measure"; Text[10])
        {
            Caption = 'Unit of Measure';
        }
        field(7; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 8;
        }
        field(8; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 8;
        }
        field(9; "VAT%"; Decimal)
        {
            Caption = 'VAT%';
            DecimalPlaces = 0 : 2;
        }
        field(10; "Amount Exc. VAT"; Decimal)
        {
            Caption = 'Amount Exc. VAT';
            DecimalPlaces = 0 : 2;
        }
        field(11; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DecimalPlaces = 0 : 2;
        }
    }

    keys
    {
        key(Key1; "System Doc No.", "System Phantom No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "System Doc No.", "System Phantom No.")
        {
            SumIndexFields = "Amount Exc. VAT";
        }
    }

    fieldgroups
    {
    }
}

