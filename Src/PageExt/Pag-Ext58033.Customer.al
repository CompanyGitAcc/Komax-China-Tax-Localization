pageextension 58033 "GT Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            group("Golden Tax")
            {
                Caption = 'Golden Tax';
                field("None GoldenTax"; Rec."None GoldenTax")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
