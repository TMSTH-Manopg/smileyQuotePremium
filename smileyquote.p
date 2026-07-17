/****************************************************************************
 SmileyQuote.p   : -    Program input API      SmileyQuote
                ---------------------------------------------------------
 Copyright    : Tokio Marine Safety Insurance (Thailand) Public Company Limited
                --------------------------------------------------------- 
 Database     :                                      
                ---------------------------------------------------------
 CREATE BY    :   Manop G .
                 Main Program  รับค่าจาก API SmileyQuote 
                 เก็บข้อมูล Json  ลง ไฟล์ .txt  และ บีนทึก log_Name ลง gw_safe
                 และให้ส่งตอบกลับทันที 
                 หลังจากนั้น Run Bat file  ให้ทำ Background Process
****************************************************************************/

USING Progress.Lang.*. 
USING Progress.Json.ObjectModel.*. 
USING Progress.Json.ObjectModel.* FROM PROPATH.

DEFINE INPUT  PARAMETER  json              AS LONGCHAR NO-UNDO.
DEFINE OUTPUT PARAMETER  jsonRS            AS LONGCHAR NO-UNDO.     


DEFINE VARIABLE oParser   AS ObjectModelParser NO-UNDO.
DEFINE VARIABLE oRoot     AS JsonObject        NO-UNDO.
DEFINE VARIABLE oArray    AS JsonArray         NO-UNDO.
DEFINE VARIABLE oItem     AS JsonObject        NO-UNDO.
DEFINE VARIABLE i         AS INTEGER           NO-UNDO.

// DEFINE INPUT  PARAMETER nv_class     AS CHARACTER NO-UNDO.
DEFINE VARIABLE  RsStatus          AS CHARACTER NO-UNDO.   
DEFINE VARIABLE  RsMessage     AS CHARACTER NO-UNDO.

DEFINE VARIABLE nv_NewInput          AS CHARACTER NO-UNDO.
DEFINE VARIABLE nv_CheckData         AS INTEGER   INITIAL 0 NO-UNDO.
DEFINE VARIABLE nv_msgstatus         AS CHARACTER NO-UNDO.

DEFINE VARIABLE nv_DB              AS CHARACTER NO-UNDO.
DEFINE VARIABLE nv_host            AS CHARACTER NO-UNDO.
DEFINE VARIABLE nv_service         AS CHARACTER NO-UNDO.
DEFINE VARIABLE myLongchar         AS LONGCHAR NO-UNDO.
DEFINE VARIABLE myLongcharRes      AS LONGCHAR NO-UNDO.

DEFINE VARIABLE  DateRs          AS CHARACTER NO-UNDO.   
DEFINE VARIABLE  TimeRs          AS CHARACTER NO-UNDO.
DEFINE VARIABLE  fileout         AS CHARACTER NO-UNDO .
DEFINE VARIABLE  fileref         AS CHARACTER NO-UNDO .
DEFINE VARIABLE  publishID      AS CHARACTER NO-UNDO .
DEFINE VARIABLE  publishRefer    AS CHARACTER NO-UNDO.
 
DEFINE VARIABLE  filejsondate     AS CHARACTER NO-UNDO .
DEFINE VARIABLE  filejson         AS CHARACTER NO-UNDO .


/* ------------------------------------------------------------------------*/
nv_NewInput = STRING(YEAR(TODAY),"9999")
            + STRING(MONTH(TODAY),"99")
            + STRING(DAY(TODAY),"99")
            + SUBSTR(STRING(DATETIME(TODAY, MTIME)),12,12).
nv_NewInput = REPLACE(nv_NewInput,":","").
nv_NewInput = REPLACE(nv_NewInput,".","").

DateRs  =    STRING(YEAR(TODAY),"9999") + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99")    .
TimeRs  =    SUBSTR(STRING(DATETIME(TODAY, MTIME)),12,12). 

RsStatus  = "เข้า".
RsMessage = "ส่งเข้าระบบ นำส่งเข้าระบบ ".

// Read Json & create  ค่า Campaign ID 
oParser = NEW ObjectModelParser().
oRoot   = CAST(oParser:Parse(json), JsonObject).
publishID    =  STRING(oRoot:GetCharacter("publishCampaignID")).
publishRefer  =  STRING(oRoot:GetCharacter("publishCampaignRefer")).


FIX-CODEPAGE(myLongchar) = 'UTF-8'.
myLongchar = json.

filejsondate    =  STRING(YEAR(TODAY),"9999") + 
                   STRING(MONTH(TODAY),"99") +
                   STRING(DAY(TODAY),"99")  + 
                   STRING(TIME) + SUBSTR(STRING(MTIME,">>>>99999999"),10,3) .
               
filejson    =  "D:\smileyquote\Json\JsonID_" + publishID + "_" + filejsondate + ".json". 
OUTPUT TO VALUE(filejson) APPEND.
EXPORT myLongchar.
PUT SKIP .
OUTPUT CLOSE.

fileout  =   "D:\smileyquote\00LogIn_Smiley_" + STRING(YEAR(TODAY),"9999") + STRING(MONTH(TODAY),"99") + ".TXT" .
OUTPUT TO VALUE(fileout) APPEND.
PUT             TODAY    FORMAT "99/99/9999"  " " STRING(TIME,"HH:MM:SS") "." SUBSTR(STRING(MTIME,">>>>99999999"),10,3)      .
                PUT "CampaignID : " publishID 
                    "CampaignIDReference : " publishRefer .
PUT SKIP .
OUTPUT CLOSE.

IF NOT CONNECTED ("gw_safe")   THEN CONNECT gw_safe  -H DEVSERVER -S 10020 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.


IF CONNECTED("gw_safe") THEN   DO:
    DO ON ERROR UNDO, LEAVE:        
        RUN    WUW\WUWSMLCAM (INPUT publishID ,  myLongchar , OUTPUT fileRef ).
    END.
    jsonRs   = '~{"publishCampaignID":" ' + publishID + '","Refer":"' + publishRefer + '","DateRs":"' + DateRs + '","TimeRs":"' + TimeRs + ' ","ErrorRs":"","Status":"INPROGRESS","FileRef":"' + fileref + '" }'. 
      
    FIX-CODEPAGE(myLongcharRes) = 'UTF-8'.
       myLongcharRes = jsonRs.
       
    OUTPUT TO VALUE(fileout) APPEND.
    PUT             TODAY    FORMAT "99/99/9999"  " " STRING(TIME,"HH:MM:SS") "." SUBSTR(STRING(MTIME,">>>>99999999"),10,3)      .
                    EXPORT myLongcharRes .
    PUT SKIP .
    OUTPUT CLOSE.    
     
END.
ELSE DO:  
   // Connect Database Fail
   jsonRs   = '~{"publishID":" ' + publishID + '","Refer":" ' + publishRefer + '","DateRs":" ' + DateRs + '","TimeRs":" ' + TimeRs + ' ","ErrorRs":" Cannot Connect Datebase Premium ","Status":"ERROR"}'. 
   OUTPUT TO VALUE(fileout) APPEND.
   PUT             TODAY    FORMAT "99/99/9999"  " " STRING(TIME,"HH:MM:SS") "." SUBSTR(STRING(MTIME,">>>>99999999"),10,3)      .
                   EXPORT myLongcharRes .
   PUT SKIP .
   OUTPUT CLOSE.    
END.
   
IF CONNECTED("gw_safe")    THEN DISCONNECT VALUE("gw_safe") .
DELETE OBJECT   oParser  NO-ERROR.
DELETE OBJECT   oRoot    NO-ERROR.
DELETE OBJECT   oArray   NO-ERROR.
DELETE OBJECT   oItem    NO-ERROR.

 
/* =======================================================
   Step 3 : Trigger Background AFTER response
   ======================================================= */
DEFINE VARIABLE cBat AS CHARACTER NO-UNDO.

/* แนะนำให้ quote path เสมอ */
cBat = '"D:\smileyquote\Batch\runBG_Progress.bat"'.

/* เรียก BAT แบบไม่บล็อก API */
OS-COMMAND NO-WAIT VALUE(cBat).

/* =======================================================
   Optional : Log ว่าได้ trigger background แล้ว
   ======================================================= */
OUTPUT TO "D:\smileyquote\Log\01SmileyQuote.log" APPEND.
PUT STRING(TODAY,"99/99/9999")  STRING(TIME,"HH:MM:SS")
    "IN Trigger BG ID : " publishID   SKIP.
OUTPUT CLOSE.

RETURN.
     /*-
/*--- DB TEST --- */
IF NOT CONNECTED ("expiry")    THEN CONNECT expiry   -H 10.35.176.37  -S 9060  -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.
IF NOT CONNECTED ("gw_safe")   THEN CONNECT gw_safe  -H 10.35.176.37  -S 10020 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.
IF NOT CONNECTED ("gwctx")     THEN CONNECT gwctx    -H 10.35.176.37  -S 10011 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.
IF NOT CONNECTED ("sicsyac")   THEN CONNECT sicsyac  -H 10.35.176.37  -S 9010  -N tcp -U pdmgr0 -P pdmgr0 NO-ERROR.  
IF NOT CONNECTED ("sic_bran ") THEN CONNECT sic_bran -H 10.35.176.37  -S 3092  -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR. 


IF NOT CONNECTED ("expiry")    THEN CONNECT expiry   -H 10.35.1.97   -S 9060  -N TCP -U hotms0 -P AppTeam01  NO-ERROR.
IF NOT CONNECTED ("gw_safe")   THEN CONNECT gw_safe  -H 10.35.1.97   -S 10020 -N TCP -U hotms0 -P AppTeam01  NO-ERROR.
//IF NOT CONNECTED ("gwctx")     THEN CONNECT gwctx    -H 10.35.1.180  -S 10011 -N TCP -U hotms0 -P AppTeam01  NO-ERROR.
IF NOT CONNECTED ("sicsyac")   THEN CONNECT sicsyac  -H 10.35.1.97   -S 9010  -N tcp -U hotms0 -P AppTeam01  NO-ERROR.
IF NOT CONNECTED ("sic_bran")  THEN CONNECT sic_bran -H 10.35.1.180  -S 3002  -N tcp -U hotms0 -P AppTeam01  NO-ERROR.
 */

