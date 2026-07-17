DEFINE VARIABLE hWebService     AS HANDLE NO-UNDO.
DEFINE VARIABLE hWCZGENRC0Obj   AS HANDLE NO-UNDO.
DEFINE VARIABLE result          AS CHARACTER NO-UNDO.

DEFINE VARIABLE SendWRSMt001      AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE json              AS LONGCHAR  NO-UNDO. 
DEFINE VARIABLE jsonRS            AS LONGCHAR  NO-UNDO.

DEFINE VARIABLE IStatus1              AS LOGICAL NO-UNDO.
DEFINE VARIABLE nv_FileName           AS CHARACTER NO-UNDO.


nv_FileName = "D:\DriveU\W_DEV11\A670120_TypeW_WebService\recove.txt".          /* PDF */
COPY-LOB FROM FILE nv_FileName TO SendWRSMt001 NO-CONVERT.


IStatus1 = NO. 
CREATE SERVER hWebService.
IStatus1 =  hWebService:CONNECT("-WSDL 'http://tmwsliapip01:8080/wsa/wsa1/wsdl?targetURI=urn:WSA-Safety:WCZGENRC0'")           /*TEST       10.35.1.149  */
            NO-ERROR.

RUN WCZGENRC0Obj SET hWCZGENRC0Obj ON hWebService.

/*-- Connect --*/
IF ERROR-STATUS:ERROR  THEN DO:
   hWebService:DISCONNECT()     NO-ERROR.  
   DELETE OBJECT hWebService    NO-ERROR.
   RETURN.
END.
ELSE DO:

    json    =   SendWRSMt001 .

    OUTPUT TO "D:\DriveU\W_DEV11\A670120_TypeW_WebService\Log\LOG_WSTEST_WCZGENRC0.txt" APPEND.
    PUT STRING(today,"9999/99/99") FORMAT "X(10)" " Time: " STRING(TIME,"HH:MM:SS") " Input  : ".
        EXPORT json  .
    PUT  ""  SKIP .
    OUTPUT CLOSE. 
    
    /* Procedure invocation of WCZGENRC0 operation. */
    RUN WCZGENRC0 IN hWCZGENRC0Obj(INPUT json, OUTPUT result, OUTPUT jsonRS).


    OUTPUT TO "D:\DriveU\W_DEV11\A670120_TypeW_WebService\Log\LOG_WSTEST_WCZGENRC0.txt" APPEND.
    PUT STRING(today,"9999/99/99") FORMAT "X(10)" " Time: " STRING(TIME,"HH:MM:SS") " Output : ".
         EXPORT jsonRS  .
    PUT  ""  SKIP .
    OUTPUT CLOSE. 

END.


