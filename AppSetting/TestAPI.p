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
/* เรียกใช้ config   */
DEFINE VARIABLE cUrl            AS CHARACTER NO-UNDO .
DEFINE VARIABLE cApiUrl         AS CHARACTER NO-UNDO.
DEFINE VARIABLE cApiendpoint    AS CHARACTER NO-UNDO.
/*--- Call GetAppConfig  ---*/
/*- Json -*/
DEFINE VARIABLE oRoot   AS JsonObject NO-UNDO.
DEFINE VARIABLE oArray  AS JsonArray  NO-UNDO.
DEFINE VARIABLE oItem   AS JsonObject NO-UNDO.

DEFINE VARIABLE lHasErr AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cJsonFile AS CHARACTER NO-UNDO.

/*- Service API -*/
DEFINE VARIABLE HttpClient   AS CLASS System.Net.WebClient. 
DEFINE VARIABLE webResponse  AS LONGCHAR NO-UNDO. 
DEFINE VARIABLE myParser     AS ObjectModelParser NO-UNDO. 
DEFINE VARIABLE ojson        AS JsonObject NO-UNDO. 
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


// Response 
RUN premiumpublish_Response.
//----------PROCEDURE--------------------
PROCEDURE premiumpublish_Response :

/* 1. เตรียมข้อมูล JSON ที่ต้องการส่งกลับ */
oBody = NEW JsonObject().
oBody:Add("status", "success").
oBody:Add("transactionId", "12345").
 
ASSIGN
System.Net.ServicePointManager:SecurityProtocol = System.Net.SecurityProtocolType:Tls12. 

/* 2. สร้าง HTTP Request ไปยัง WebHook URL */
FIX-CODEPAGE(webResponse) = "UTF-8".
HttpClient = NEW System.Net.WebClient().
httpClient:headers:ADD("content-type:application/json;charset=utf-8").

/* 3. ส่งข้อมูล (Execute) */
//oResponse = ClientBuilder:Build():Client:Execute(oRequest).
webResponse = HttpClient:UploadString(cUrl,oRequest) NO-ERROR.  
HttpClient:Dispose().
DELETE OBJECT HttpClient.

myParser = NEW ObjectModelParser(). 
ojson    = CAST(myParser:Parse((webResponse)),JsonObject) NO-ERROR. 
oResponse  = string(ojson:GetJsonText("Response"))  NO-ERROR.      

END PROCEDURE . 
