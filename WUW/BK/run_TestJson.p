DEFINE VARIABLE hWebService     AS HANDLE NO-UNDO.
DEFINE VARIABLE hWCZGENRC0Obj   AS HANDLE NO-UNDO.
DEFINE VARIABLE result          AS CHARACTER NO-UNDO.

DEFINE VARIABLE SendWRSMt001      AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE json              AS LONGCHAR  NO-UNDO. 
DEFINE VARIABLE jsonRS            AS LONGCHAR  NO-UNDO.

DEFINE VARIABLE IStatus1              AS LOGICAL NO-UNDO.
DEFINE VARIABLE nv_FileName           AS CHARACTER NO-UNDO.


nv_FileName = "D:\smileyquote\WUW\BK\JsonID_123_2026061239248416.json".          /* PDF */
COPY-LOB FROM FILE nv_FileName TO SendWRSMt001 CONVERT TARGET CODEPAGE 'UTF-8'.

    json    =   SendWRSMt001 .
                                                     

RUN "D:\smileyquote\WUW\BK\Test_Json.p" (INPUT "123", INPUT json, OUTPUT jsonRS).
                                        
              
