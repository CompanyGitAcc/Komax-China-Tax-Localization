report 50026 "CN GoldenTax Generation"
{
    Caption = 'Generate GT Data';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "Document Type", "No.", "Bill-to Customer No.";

            trigger OnAfterGetRecord()
            var

            begin
                GTMgt.GenerateGTInvoice("Sales Header", GTDescription, GTSpecification);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group(Option)
                    {
                        Caption = 'Option';
                        field(Description; GTDescription)
                        {
                            Caption = 'Description';
                            ApplicationArea = all;
                        }
                        field(Specification; GTSpecification)
                        {
                            Caption = 'Specification';
                            ApplicationArea = all;
                        }
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.GET;
        GTDescription := GTDescription::Description;
        GTSpecification := GTSpecification::"Item No.";
    end;

    trigger OnPostReport()
    begin

    end;

    trigger OnPreReport()
    begin
        IF GLSetup."Max Invoice Lines" <= 0 THEN ERROR(Err001);

        IF GLSetup."Max Invoice Amount" <= 0 THEN ERROR(Err003);
        IF GLSetup."Commodity Tax No." = '' THEN ERROR(ERR004);
    end;

    var
        GTDescription: Enum "Commodity Description";
        GTSpecification: Enum "Commodity Description";

        Err001: Label 'Please input the Max Line Number.';
        Err002: Label 'Can''t Create the %1.';
        Err003: Label 'Please input the Limited Amount.';
        Err004: Label 'Please input Commodity Tax No.';
        txt003: Label 'Exported to %1 successfully.';
        GLSetup: Record "General Ledger Setup";
        GTMgt: Codeunit "GT Management";

}

