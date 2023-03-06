pageextension 58025 "GT Accountant Role Center" extends "Accountant Role Center"
{

    actions
    {
        //#Add - Reports, CHN Localizations #
        addafter(tasks)
        {

            group("China Golden Tax")
            {
                Caption = 'Golden Tax Interface';
                Image = Report;

                action("CN Tax Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Golden Tax Setup';
                    Image = "Setup";
                    RunObject = Page "General Ledger Setup";
                }
                // action("Sales Order List")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Sales Order List';
                //     Image = Order;
                //     RunObject = page "Sales Order List";
                // }
                action("Sales Invoice List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Invoice List';
                    Image = SalesInvoice;
                    RunObject = page "Sales Invoice List";
                }
                action("Sales Credit Memo List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Credit Memo List';
                    Image = SalesCreditMemo;
                    RunObject = page "Sales Credit Memos";
                }
                // action("Golden Tax Export")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Golden Tax Export';
                //     Image = Export;
                //     RunObject = report "CN GoldenTax Export files";
                // }
                // action("Golden Tax Import")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Golden Tax Import';
                //     Image = Import;
                //     RunObject = report "CN GoldenTax Import files";
                // }
                group("GTHistory")
                {
                    Caption = 'History';
                    Image = Report;
                    action("Invoice Details")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Invoice Details';
                        Image = Order;
                        RunObject = page "GT Invoice Lines";
                    }
                }
            }
        }


    }
}
