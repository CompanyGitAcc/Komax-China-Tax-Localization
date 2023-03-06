page 50022 "GT Invoice Lines"
{

    Caption = 'Invoice Lines';
    PageType = ListPart;
    SourceTable = "GT Invoice Line";
    //Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("System Doc No."; Rec."System Doc No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("System Phantom No."; Rec."System Phantom No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = all;
                }
                field("Item No."; Rec."Item No.")
                { ApplicationArea = all; }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("VAT%"; Rec."VAT%")
                {
                    ApplicationArea = All;
                }
                field("Amount Exc. VAT"; Rec."Amount Exc. VAT")
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
