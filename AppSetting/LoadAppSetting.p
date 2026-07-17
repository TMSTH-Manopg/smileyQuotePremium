DEFINE TEMP-TABLE ttConfig NO-UNDO
    FIELD cfgKey   AS CHARACTER
    FIELD cfgValue AS CHARACTER.
    
    
RUN LoadAppConfig ("D:\smileyquote\AppSetting\AppSetting.txt"). 
    
    /*---    เก็บลง Temp    ----*/
PROCEDURE LoadAppConfig:
    
    DEFINE INPUT PARAMETER ipFilePath AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cLine      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cKey       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cValue     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iPos       AS INTEGER   NO-UNDO.

    INPUT FROM VALUE(ipFilePath) NO-ECHO.

    REPEAT:
        IMPORT UNFORMATTED cLine.

        /* Skip empty line or comment */
        IF TRIM(cLine) = "" OR cLine BEGINS "#" THEN
            NEXT.

        iPos = INDEX(cLine, "=").

        IF iPos > 0 THEN DO:
            cKey = TRIM(SUBSTRING(cLine, 1, iPos - 1)).
            cValue = TRIM(SUBSTRING(cLine, iPos + 1)).

            CREATE ttConfig.
            ASSIGN
                ttConfig.cfgKey   = cKey
                ttConfig.cfgValue = cValue.
        END.
    END.

    INPUT CLOSE.

END PROCEDURE.    


FUNCTION GetConfig RETURNS CHARACTER
    (INPUT ipKey AS CHARACTER):

    FIND FIRST ttConfig 
        WHERE ttConfig.cfgKey = ipKey 
        NO-ERROR.

    IF AVAILABLE ttConfig THEN
        RETURN ttConfig.cfgValue.
    ELSE
        RETURN "".

END FUNCTION.
