DEFINE VARIABLE hConfig AS HANDLE NO-UNDO.

// แบบ 1 
/* start config manager */
RUN LoadAppSetting.p PERSISTENT SET hConfig.
/* โหลด config */
RUN LoadConfig IN hConfig ("D:\smileyquote\AppSetting\AppSetting.txt").
//*---- เรียกใช้
DEFINE INPUT PARAMETER phConfig AS HANDLE NO-UNDO.    
DEFINE VARIABLE cUrl AS CHARACTER NO-UNDO.       
cUrl = DYNAMIC-FUNCTION("GetConfig" IN phConfig, "API_URL").
/*--------------------------------------------------*/
// แบบ 2 
RUN configManager.p PERSISTENT SET SESSION:PRIVATE-DATA.
RUN LoadConfig IN SESSION:PRIVATE-DATA ("D:\config\AppSetting.txt").
//--   เรียกใช้
DEFINE VARIABLE cUrl AS CHARACTER NO-UNDO.   
cUrl = DYNAMIC-FUNCTION("GetConfig" IN SESSION:PRIVATE-DATA, "API_URL").
/*--------------------------------------------------*/
// แบบ 3 
FUNCTION GetAppConfig RETURNS CHARACTER (INPUT ipKey AS CHARACTER): 
    RETURN DYNAMIC-FUNCTION(
        "GetConfig" IN SESSION:PRIVATE-DATA,
        ipKey ).   
END FUNCTION.
// -- เรียกใช้
cUrl = GetAppConfig("API_URL").
