DEFINE VARIABLE hConfig AS HANDLE NO-UNDO.
DEFINE VARIABLE cApiUrl AS CHARACTER NO-UNDO.

RUN AppSetting\appConfig.p PERSISTENT SET hConfig.




cApiUrl = GetConfig("API_URL").


MESSAGE   cApiUrl  VIEW-AS ALERT-BOX. 

FUNCTION GetConfig RETURNS CHARACTER (INPUT ipKey AS CHARACTER):
    RETURN DYNAMIC-FUNCTION("GetAppConfig" IN hConfig, ipKey).
END FUNCTION  .

/* ? เรียก function 
cApiUrl = DYNAMIC-FUNCTION("GetAppConfig" IN hConfig, "API_URL").

MESSAGE cApiUrl VIEW-AS ALERT-BOX.
*/
