tableextension 50006 "GT General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {

        //Golden Tax
        field(58010; "Max Invoice Lines"; Integer)
        {
            Caption = 'Maximum Invoice Lines';
            DataClassification = ToBeClassified;
        }
        field(58011; "Max Invoice Amount"; Decimal)
        {
            Caption = 'Maximum Invoice Amount';
            DataClassification = ToBeClassified;
        }
        field(58012; "Commodity Tax No."; Code[20])
        {
            Caption = 'Commodity Tax No.';
            DataClassification = ToBeClassified;
        }
        //收款人
        field(58013; "Checker"; Text[20])
        {
            Caption = 'Checker';
            DataClassification = ToBeClassified;
        }
        field(58014; "Payee"; Text[20])
        {
            Caption = 'Payee';
            DataClassification = ToBeClassified;
        }
        field(58015; "Drawer"; Text[20])
        {
            Caption = 'Drawer';
            DataClassification = ToBeClassified;
        }

        field(58016; "Expense Apportion"; Boolean)
        {
            Caption = 'Expense Allocation';
            DataClassification = ToBeClassified;
        }
        field(58017; "GT Description"; enum "Commodity Description")
        {
            Caption = 'GT Description';
            DataClassification = ToBeClassified;
        }
        field(58018; "GT Specification"; enum "Commodity Description")
        {
            Caption = 'GT Specification';
            DataClassification = ToBeClassified;
        }
        // field(58018; "Process and Export"; Boolean)
        // {
        //     Caption = 'Process and Export';
        //     DataClassification = ToBeClassified;
        // }

        field(58019; "File Format"; Option)
        {
            Caption = 'File Format';
            OptionMembers = "TXT","XML";
            OptionCaption = 'TXT,XML';
            DataClassification = ToBeClassified;
        }
        field(58020; "File Path"; Text[100])
        {
            Caption = 'Temporary File Location';
            DataClassification = ToBeClassified;
        }
    }
}
