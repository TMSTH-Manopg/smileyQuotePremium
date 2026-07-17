/* appConfig.p */

DEFINE VARIABLE gcConfigPath AS CHARACTER NO-UNDO 
    INITIAL "D:\smileyquote\AppSetting\AppSetting.txt".

DEFINE TEMP-TABLE ttConfig NO-UNDO
    FIELD cfgKey   AS CHARACTER
    FIELD cfgValue AS CHARACTER.

/* =======================
   AUTO RUN ตอน start ?
======================= */
RUN InitializeConfig.

PROCEDURE InitializeConfig:

    RUN LoadConfig (gcConfigPath).

END PROCEDURE.

/* =======================
   LOAD CONFIG
======================= */
PROCEDURE LoadConfig:
    DEFINE INPUT PARAMETER ipFile AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cLine AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iPos  AS INTEGER   NO-UNDO.

    INPUT FROM VALUE(ipFile) NO-ECHO.

    REPEAT:
        IMPORT UNFORMATTED cLine.

        IF TRIM(cLine) = "" OR cLine BEGINS "#" THEN NEXT.

        iPos = INDEX(cLine, "=").

        IF iPos > 0 THEN DO:
            CREATE ttConfig.
            ASSIGN
                ttConfig.cfgKey   = TRIM(SUBSTRING(cLine,1,iPos - 1))
                ttConfig.cfgValue = TRIM(SUBSTRING(cLine,iPos + 1)).
        END.
    END.

    INPUT CLOSE.
END PROCEDURE.

/* =======================
   GET
======================= */
FUNCTION GetAppConfig RETURNS CHARACTER (INPUT ipKey AS CHARACTER):

    FIND FIRST ttConfig 
        WHERE ttConfig.cfgKey = ipKey 
        NO-ERROR.

    IF AVAILABLE ttConfig THEN
        RETURN ttConfig.cfgValue.

    RETURN "".
END FUNCTION.


