page 50021 "GT Invoice Card"
{
    Caption = 'GT Invoice Card';
    PageType = Card;
    SourceTable = "GT Invoice Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("System Doc No."; Rec."System Doc No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("System Phantom No."; Rec."System Phantom No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Cust Name"; Rec."Cust Name")
                {
                    ApplicationArea = All;
                }
                field("Cust VAT No."; Rec."Cust VAT No.")
                {
                    ApplicationArea = All;
                }
                field("Cust Address"; Rec."Cust Address")
                {
                    ApplicationArea = All;
                }
                field("Cust Bank"; Rec."Cust Bank")
                {
                    ApplicationArea = All;
                }
                field("Export DateTime"; Rec."Export DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Import DateTime"; Rec."Import DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Invoice)
            {
                field("Amount Exc. VAT"; Rec."Amount Exc. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Exc. VAT field.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Amount field.';
                }
                field("Amount Inc. VAT"; Rec."Amount Exc. VAT" + Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Inc. VAT field.';
                }
                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remark field.';
                }
            }
        }
    }
}
