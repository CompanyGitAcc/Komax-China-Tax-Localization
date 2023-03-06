page 50020 "GT Invoice List"
{
    Caption = 'Invoice List';
    PageType = List;
    SourceTable = "GT Invoice Header";
    CardPageId = "GT Invoice Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("System Doc No."; Rec."System Doc No.")
                {
                    ApplicationArea = All;
                }
                field("System Phantom No."; Rec."System Phantom No.")
                {
                    ApplicationArea = All;
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
                    Visible = false;
                }
                field("Cust Bank"; Rec."Cust Bank")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Amount Exc. VAT"; Rec."Amount Exc. VAT")
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Inc. VAT"; Rec."Amount Inc. VAT")
                {
                    ApplicationArea = All;
                }
                field("Amount Exc. VAT Calc"; Rec."VAT Amount Calc.")
                {
                    ApplicationArea = All;
                }
                field("Amount Exc. VAT Calc."; Rec."Amount Exc. VAT Calc.")
                {
                    ApplicationArea = All;
                }
                field("JinSui Invoice No"; Rec."JinSui Invoice No")
                {
                    ApplicationArea = All;
                }
            }

            part(GTInvLines; "GT Invoice Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "System Phantom No." = FIELD("System Phantom No."), "System Doc No." = field("System Doc No.");
                UpdatePropagation = Both;
            }

        }
    }
}
