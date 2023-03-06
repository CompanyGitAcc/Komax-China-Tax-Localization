pageextension 58031 "GT User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("GoldenTax User"; Rec."GoldenTax User")
            {
                ApplicationArea = all;
            }
        }
    }
}
