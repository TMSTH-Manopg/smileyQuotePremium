/****************************************************************************
 SmileyQuote.p   : -    Background process  Send WEB HOOK  Back to API PublishPremium SmileyQuote
                ---------------------------------------------------------
 Copyright    : Tokio Marine Safety Insurance (Thailand) Public Company Limited
                --------------------------------------------------------- 
 Method Name  :                                           
                --------------------------------------------------------- 
  CREATE BY    :   Manop G .  Send WEB HOOK  Back to API PublishPremium SmileyQuote
****************************************************************************/

USING System.Net.Http.*. 
USING System.Environment.
USING Progress.Lang.*. 
USING Progress.Json.ObjectModel.*. 
USING Progress.Json.ObjectModel.* FROM PROPATH.
USING Progress.IO.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.URI.*.
{WUW\WUWSMLPRM.i}

DEFINE INPUT PARAMETER pcCampCode  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pcCampRefer  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pcSourceFile AS CHARACTER NO-UNDO. /* cFile */
DEFINE INPUT PARAMETER TABLE FOR tfile.


/*--- Call GetAppConfig  ---*/
DEFINE VARIABLE hConfig AS HANDLE NO-UNDO.
RUN AppSetting\appConfig.p PERSISTENT SET hConfig.

FUNCTION GetConfig RETURNS CHARACTER (INPUT ipKey AS CHARACTER):
    RETURN DYNAMIC-FUNCTION("GetAppConfig" IN hConfig, ipKey).
END FUNCTION  .
/*--- Call GetAppConfig  ---*/

/* เรียกใช้ config   */
DEFINE VARIABLE cUrl            AS LONGCHAR NO-UNDO .
DEFINE VARIABLE cApiUrl         AS CHARACTER NO-UNDO.
DEFINE VARIABLE cApiendpoint    AS CHARACTER NO-UNDO.


DEFINE VARIABLE oRoot   AS JsonObject NO-UNDO.
DEFINE VARIABLE oArray  AS JsonArray  NO-UNDO.
DEFINE VARIABLE oItem   AS JsonObject NO-UNDO.

DEFINE VARIABLE lHasErr AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cJsonFile AS CHARACTER NO-UNDO.

DEFINE VARIABLE HttpClient   AS CLASS System.Net.WebClient. 
DEFINE VARIABLE webResponse  AS LONGCHAR NO-UNDO. 
//DEFINE VARIABLE cURL         AS LONGCHAR NO-UNDO.
DEFINE VARIABLE myParser     AS ObjectModelParser NO-UNDO. 
DEFINE VARIABLE ojson        AS JsonObject NO-UNDO. 

DEFINE VAR access_token  AS CHAR  NO-UNDO.
DEFINE VARIABLE encdmptr  AS MEMPTR   NO-UNDO.
DEFINE VARIABLE encdlngc  AS LONGCHAR NO-UNDO.
DEFINE VARIABLE encdlngc2 AS LONGCHAR NO-UNDO.
    
DEFINE VARIABLE oRequest  AS LONGCHAR NO-UNDO.
DEFINE VARIABLE oResponse AS LONGCHAR NO-UNDO.
DEFINE VARIABLE oBody     AS JsonObject NO-UNDO.
DEFINE VARIABLE lcRequest AS LONGCHAR NO-UNDO.

oRoot    = NEW JsonObject().
oArray   = NEW JsonArray().
lHasErr  = FALSE.

ASSIGN
cApiUrl         =   GetConfig("API_URL")
cApiendpoint    =   GetConfig("API_ENDPOINT")
cUrl  = cApiUrl + cApiendpoint. 

/* --- Loop temp-table --- */
FOR EACH tfile:
        oItem = NEW JsonObject().

        IF tfile.remark = "" THEN DO:
            oItem:Add("Status", "COMPLETE").
            oItem:Add("Message", "").
        END.
        ELSE DO:
            oItem:Add("Status", "ERROR").
            oItem:Add("Message", TRIM(tFile.remark)).
            lHasErr = TRUE.
        END.
        //oItem:Add("CampaignCode", TRIM(tFile.campcd)).
        oItem:Add("PolicyMaster", TRIM(tFile.polmst)).
        oArray:Add(oItem).  /* add เข้า array */
END.   

oRoot:Add("publishKeyID", Int(pcCampCode)).
oRoot:Add("CampaignRefer", TRIM(pcCampRefer)).
oRoot:Add("Status", IF lHasErr THEN "FAILED" ELSE "COMPLETED").
oRoot:Add("items", oArray).    /* add เข้า root */

lcRequest = oRoot:ToString().   
oRoot:Write(lcRequest, TRUE).


// FIX-CODEPAGE(cJsonFile) = "UTF-8".    ออก .Json File 
cJsonFile = REPLACE(pcSourceFile, ".txt", ".json").
oRoot:WriteFile(cJsonFile, TRUE). 

/* --- Optional log --- */
OUTPUT TO "D:\smileyquote\Log\json.log" APPEND.
PUT TODAY  FORMAT "99/99/9999"  "   "  STRING(TIME,"HH:MM:SS")
    " SAVE JSON = " cJsonFile FORMAT "X(200)" SKIP.
OUTPUT CLOSE.

DELETE OBJECT oRoot.
DELETE OBJECT oArray.

// Response 
RUN publishpremium_Response. 
// --------------------------------------------------------

PROCEDURE publishpremium_Response :

DEFINE VAR iRetry   AS INT      INIT 0 .
DEFINE VAR lSuccess AS LOGICAL  . 

ASSIGN
System.Net.ServicePointManager:SecurityProtocol = System.Net.SecurityProtocolType:Tls12. 


/* สร้าง HTTP Request ไปยัง WebHook URL */
FIX-CODEPAGE(webResponse) = "UTF-8".
HttpClient = NEW System.Net.WebClient().
httpClient:Headers:Remove("Content-Type").
httpClient:headers:ADD("Content-type:application/json;charset=utf-8").
httpClient:Headers:Add("Content-Type", "application/json").
httpClient:Headers:Add("Accept", "application/json").
    
/* 3. ส่งข้อมูล (Execute) */
//oResponse = ClientBuilder:Build():Client:Execute(oRequest).
DO iRetry = 1 TO 3:

    DO ON ERROR UNDO, THROW:

        webResponse = httpClient:UploadString(curl, "POST", lcRequest).
        lSuccess = TRUE.

        LEAVE.

        CATCH e AS Progress.Lang.Error:
    
            /* ? log error */
            OUTPUT TO "D:\smileyquote\log\webhook_error.log" APPEND.
            PUT UNFORMATTED
                STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS")
                + " ERROR (Retry " + STRING(iRetry) + "): "
                + e:GetMessage(1) SKIP.
            OUTPUT CLOSE.
    
            PAUSE 2.
    
        END CATCH.

    END.

END.

/* ============================== */
/* ถ้ายังไม่สำเร็จ */
/* ============================== */
IF NOT lSuccess THEN DO:
    RETURN. /* หรือ mark fail */
END.

/* ============================== */
/* Log Request + Response */
/* ============================== */
OUTPUT TO "D:\smileyquote\log\webhook.log" APPEND.

PUT UNFORMATTED
    STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS")
    + " ----------------------------------------" SKIP.

PUT UNFORMATTED "REQUEST:" SKIP.
PUT UNFORMATTED STRING(lcRequest) SKIP.

PUT UNFORMATTED "RESPONSE:" SKIP.
PUT UNFORMATTED STRING(webResponse) SKIP(1).

OUTPUT CLOSE.
// Clean
HttpClient:Dispose().
DELETE OBJECT HttpClient.


myParser = NEW ObjectModelParser(). 
ojson    = CAST(myParser:Parse((webResponse)),JsonObject) NO-ERROR. 
oResponse  = string(ojson:GetJsonText("Response"))  NO-ERROR.      
      
     
/* ตรวจสอบ Status Code (เช่น 200 OK) 
IF webResponse <> 200 THEN DO:
    /* เขียน Log เก็บไว้หากส่งไม่สำเร็จ */
END.  */
RETURN. 
END PROCEDURE . 


