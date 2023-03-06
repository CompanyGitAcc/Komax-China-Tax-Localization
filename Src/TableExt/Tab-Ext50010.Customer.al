tableextension 50010 "GT Customer" extends Customer
{
    fields
    {

        //Golden Tax
        field(58010; "None GoldenTax"; Boolean)
        {
            Caption = 'None GoldenTax';
            DataClassification = ToBeClassified;
        }
    }
}
