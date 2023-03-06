report 50029 "CN GoldenTax Import Files"
{
    Caption = 'Import GoldenTax Files';
    ProcessingOnly = true;
    TransactionType = Update;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = WHERE("Document Type" = FILTER(Invoice | Order));
            RequestFilterFields = "No.", "Bill-to Customer No.";
            RequestFilterHeading = 'Sales Header';

            trigger OnAfterGetRecord()
            var
                "Jinsui Invoice": Record "GT Invoice Header";
            begin
                "Jinsui Invoice".LOCKTABLE;

                //#BC190<<
                /*
                IF NOT FILE.EXISTS(FileName) THEN
                    EXIT;
                MyFile.TEXTMODE(TRUE);
                IF MyFile.OPEN(FileName) THEN BEGIN
                    WHILE MyFile.POS < MyFile.LEN DO BEGIN
                        StrArray[1] := '';
                        StrArray[5] := '';
                        StrArray[9] := '';
                        InvNum := '';
                        MyFile.READ(String);
                        "Jinsui Invoice".SETRANGE("Jinsui Invoice"."Navision Doc No.", "No.");
                        "Jinsui Invoice".SETRANGE("Jinsui Invoice"."Document Type", "Jinsui Invoice"."Document Type"::Order);
                        IF "Jinsui Invoice".FIND('-') THEN
                            REPEAT
                                IF FindSalesInvNo(String, "Jinsui Invoice"."Navision Phantom No.") = TRUE THEN BEGIN
                                    InvNum := StrArray[5];
                                    IF StrArray[1] <> '1' THEN BEGIN
                                        "Jinsui Invoice"."JinSui Invoice No" := InvNum;
                                        "Jinsui Invoice"."Import DateTime" := CURRENTDATETIME;
                                        "Jinsui Invoice".MODIFY;
                                    END
                                    ELSE BEGIN
                                    END;
                                END
                            UNTIL "Jinsui Invoice".NEXT = 0
                    END;
                END ELSE
                    MESSAGE(Text005);
                */
                //>>
                if FileName <> '' then begin
                    StrArray[1] := '';
                    StrArray[5] := '';
                    StrArray[9] := '';
                    InvNum := '';
                    tempBlob.CreateOutStream(GTOutStream, TextEncoding::UTF8);
                    CopyStream(GTOutStream, GTInStream);
                    GTOutStream.WriteText(String);
                    "Jinsui Invoice".SETRANGE("Jinsui Invoice"."System Doc No.", "No.");
                    //"Jinsui Invoice".SETRANGE("Jinsui Invoice"."Document Type", "Jinsui Invoice"."Document Type"::Order);
                    IF "Jinsui Invoice".FIND('-') THEN
                        REPEAT
                            IF FindSalesInvNo(String, "Jinsui Invoice"."System Phantom No.") = TRUE THEN BEGIN
                                InvNum := StrArray[5];
                                IF StrArray[1] <> '1' THEN BEGIN
                                    "Jinsui Invoice"."JinSui Invoice No" := InvNum;
                                    "Jinsui Invoice"."Import DateTime" := CURRENTDATETIME;
                                    "Jinsui Invoice".MODIFY;
                                END
                                ELSE BEGIN
                                END;
                            END
                        UNTIL "Jinsui Invoice".NEXT = 0
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FileName; FileName)
                    {
                        ApplicationArea = all;
                        trigger OnAssistEdit()
                        begin
                            //#BC190<<
                            //Fileto := TEMPORARYPATH + 'RTCImportGoldTax.txt';
                            //UPLOAD('DialogTitle', '', '*.txt|*.txt', '', Fileto);
                            //FileName := TEMPORARYPATH + 'RTCImportGoldTax.txt';
                            If UploadIntoStream('DialogTitle', '', '*.txt|*.txt', FileName, GTInStream) then;
                            //>>
                        end;

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

    trigger OnPostReport()
    begin
        MESSAGE(Text004);
    end;



    var
        FileName: Text[250];
        Text001: Label 'Open Jinsui Generated File';
        MyFile: File;
        //BC190-Upgrade<<
        GTInStream: InStream;
        GTOutStream: OutStream;
        tempBlob: Codeunit "Temp Blob";
        //BC190>>        
        String: Text[900];
        InvNum: Text[30];
        Text002: Label '~~';
        Text003: Label ',';
        StrArray: array[10] of Text[100];
        Text004: Label 'Import Finished.';
        Text005: Label 'Cannot open file.';
        Text006: Label 'Navision Document %1 hasn''t export Jinsui interface file yet.';
        "--Tectura JC 1.00--": Integer;
        Fileto: Text[300];


    procedure FindSalesInvNo(String: Text[900]; SalesInvNo: Code[20]): Boolean
    var
        NewString: Text[400];
        NewString2: Text[400];
    begin
        IF CopyToArray(String) = FALSE THEN
            EXIT(FALSE);

        IF (StrArray[9] = SalesInvNo) THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;


    procedure CopyToArray(Str: Text[900]): Boolean
    var
        I: Integer;
        Pos: Integer;
        "Field": array[10] of Text[30];
    begin

        FOR I := 1 TO 10 DO BEGIN
            Pos := STRPOS(Str, '~~');
            IF Pos <> 0 THEN BEGIN
                StrArray[I] := COPYSTR(Str, 1, Pos - 1);
                Str := COPYSTR(Str, Pos + 2);
            END
            ELSE
                EXIT(FALSE)
        END;

        EXIT(TRUE);
    end;
}

