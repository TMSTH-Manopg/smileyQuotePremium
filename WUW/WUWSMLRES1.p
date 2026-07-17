USING System.Net.Http.*. 
USING System.Environment.
USING Progress.Lang.*. 
USING Progress.Json.ObjectModel.*. 
USING Progress.Json.ObjectModel.* FROM PROPATH.
USING Progress.IO.*.

DEFINE VARIABLE HttpClient   AS CLASS System.Net.WebClient. 
DEFINE VARIABLE webResponse  AS LONGCHAR NO-UNDO. 
DEFINE VARIABLE cURL         AS LONGCHAR NO-UNDO.
DEFINE VARIABLE myParser     AS ObjectModelParser NO-UNDO. 
DEFINE VARIABLE ojson        AS JsonObject NO-UNDO. 

DEFINE VAR access_token  AS CHAR  NO-UNDO.
DEFINE VARIABLE encdmptr  AS MEMPTR   NO-UNDO.
DEFINE VARIABLE encdlngc  AS LONGCHAR NO-UNDO.
DEFINE VARIABLE encdlngc2 AS LONGCHAR NO-UNDO.
    
DEFINE VARIABLE oRequest  AS LONGCHAR NO-UNDO.
DEFINE VARIABLE oResponse AS LONGCHAR NO-UNDO.
DEFINE VARIABLE oBody     AS JsonObject NO-UNDO.

/* 1. เตรียมข้อมูล JSON ที่ต้องการส่งกลับ */
oBody = NEW JsonObject().
oBody:Add("status", "success").
oBody:Add("transactionId", "12345").

ASSIGN
///  curl  =   "https://coreapis-aiu.tmsth.net/EPRT/api/PolicyPATAApi/Pol64" .    // UAT ---Path URL  PATA
curl  =   "https://coreapis-aiu.tmsth.net/EPRT/api/PolicyPROPAPI/pol64" .        
System.Net.ServicePointManager:SecurityProtocol = System.Net.SecurityProtocolType:Tls12. 


/* 2. สร้าง HTTP Request ไปยัง WebHook URL */
FIX-CODEPAGE(webResponse) = "UTF-8".
HttpClient = NEW System.Net.WebClient().
httpClient:headers:ADD("content-type:application/json;charset=utf-8").

    
/* 3. ส่งข้อมูล (Execute) */
//oResponse = ClientBuilder:Build():Client:Execute(oRequest).
webResponse = HttpClient:UploadString(curl,oRequest) NO-ERROR.  
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
