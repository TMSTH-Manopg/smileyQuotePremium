USING System.Net.Http.*. 
USING System.Environment.
USING Progress.Lang.*. 
USING Progress.Json.ObjectModel.*. 
USING Progress.Json.ObjectModel.* FROM PROPATH.
USING Progress.IO.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.URI.*.
{WUW\WUWSMLPRM.i}

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
DEFINE VARIABLE lcRequest AS LONGCHAR NO-UNDO.

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
    
oRoot    = NEW JsonObject().
oArray   = NEW JsonArray().
lHasErr  = FALSE.

ASSIGN
cApiUrl         =   GetConfig("API_URL")
cApiendpoint    =   GetConfig("API_ENDPOINT")
cUrl  = cApiUrl + cApiendpoint. 

lcRequest = oRoot:ToString().   
ASSIGN
System.Net.ServicePointManager:SecurityProtocol = System.Net.SecurityProtocolType:Tls12. 


/* สร้าง HTTP Request ไปยัง WebHook URL */
FIX-CODEPAGE(webResponse) = "UTF-8".
HttpClient = NEW System.Net.WebClient().
httpClient:headers:ADD("content-type:application/json;charset=utf-8").

    
/* 3. ส่งข้อมูล (Execute) */
//oResponse = ClientBuilder:Build():Client:Execute(oRequest).
webResponse = HttpClient:UploadString(curl, "POST", lcRequest) NO-ERROR.  

/* Handle Error  ========================= */
  
IF ERROR-STATUS:ERROR THEN DO:
    OUTPUT TO "D:\smileyquote\WUW\BK\webhook_error.log" APPEND.
    PUT UNFORMATTED
        STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS")
        + " ERROR: " ERROR-STATUS:GET-MESSAGE(1) SKIP.
    OUTPUT CLOSE.      
END.     
ELSE DO:  
    /* ========================= */
    /* Log Request + Response */
    /* ========================= */
    OUTPUT TO "D:\smileyquote\WUW\BK\webhook.log" APPEND.
    PUT          //"REQUEST: " lcRequest SKIP
        "RESPONSE: "  .
        EXPORT   STRING(webResponse) SKIP(1).
    OUTPUT CLOSE.

END.           
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

