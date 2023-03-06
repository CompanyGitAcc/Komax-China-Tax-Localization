pageextension 58030 "GT General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(content)
        {
            group("Golden Tax")
            {
                Caption = 'Golden Tax';
                field("Max Invoice Lines"; Rec."Max Invoice Lines")
                {
                    ApplicationArea = all;
                }
                field("Max Invoice Amount"; Rec."Max Invoice Amount")
                {
                    ApplicationArea = all;
                }
                field("Commodity Tax No."; Rec."Commodity Tax No.")
                {
                    ApplicationArea = all;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = all;
                }
                field("GT Description"; Rec."GT Description")
                {
                    ApplicationArea = all;
                }
                field("GT Specification"; Rec."GT Specification")
                {
                    ApplicationArea = all;
                }
                field(Checker; Rec.Checker)
                {
                    ApplicationArea = all;
                }
                field(Drawer; Rec.Drawer)
                {
                    ApplicationArea = all;
                }
                field("File Format"; Rec."File Format")
                {
                    ApplicationArea = all;
                }
                field("File Path"; Rec."File Path")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
