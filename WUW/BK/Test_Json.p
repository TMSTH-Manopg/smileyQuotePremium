/****************************************************************************
 SmileyQuote.p   : -    Program input API      SmileyQuote
                ---------------------------------------------------------
 Copyright    : Tokio Marine Safety Insurance (Thailand) Public Company Limited
                --------------------------------------------------------- 
 Method Name  :                                           
                --------------------------------------------------------- 
  CREATE BY    :   Manop G .  Outputfile to Premium Sub Program   SmileyQuote
****************************************************************************/

USING Progress.Lang.*. 
USING Progress.Json.ObjectModel.*. 
USING Progress.Json.ObjectModel.* FROM PROPATH.

DEFINE VARIABLE oParser   AS ObjectModelParser NO-UNDO.
DEFINE VARIABLE oRoot     AS JsonObject        NO-UNDO.
DEFINE VARIABLE oArray    AS JsonArray         NO-UNDO.
DEFINE VARIABLE oItem     AS JsonObject        NO-UNDO.
DEFINE VARIABLE i         AS INTEGER           NO-UNDO.

DEFINE INPUT  PARAMETER publishID   AS CHARACTER NO-UNDO.
DEFINE INPUT  PARAMETER ipJson      AS LONGCHAR  NO-UNDO.
DEFINE OUTPUT PARAMETER outFile     AS LONGCHAR NO-UNDO.  

DEFINE VARIABLE nv_CampaignCode  AS CHAR   FORMAT "X(30)".

DEFINE TEMP-TABLE ttSmileyRequestList NO-UNDO    
    FIELD ListNo                   AS INT 
    FIELD CampaignKeyId            AS CHAR   FORMAT "X(5)"
    FIELD CompanyCode              AS CHAR   FORMAT "X(20)"
    FIELD CampaignCode             AS CHAR   FORMAT "X(30)"
    FIELD Polmst                   AS CHAR   FORMAT "X(20)"
    FIELD Pack                     AS CHAR   FORMAT "X(2)"
    FIELD Sclass                   AS CHAR   FORMAT "X(5)"
    FIELD Covcod                   AS CHAR   FORMAT "X(4)"
    FIELD Vehgrp                   AS CHAR   FORMAT "X(2)"
    FIELD Vehuse                   AS CHAR   FORMAT "X(2)"
    FIELD GarageCd                 AS CHAR   FORMAT "X(2)"
    FIELD Makdes                   AS CHAR   FORMAT "X(40)"
    FIELD Moddes                   AS CHAR   FORMAT "X(100)"
    FIELD CSTFlag                  AS CHAR   FORMAT "X(2)"
    FIELD MinYear                  AS DECI   FORMAT "->>>,>>9.99"
    FIELD MaxYear                  AS DECI   FORMAT "->>>,>>9.99"
    FIELD MinCst                   AS DECI   FORMAT "->>9.99"
    FIELD MaxCst                   AS DECI   FORMAT "->>9.99"
    FIELD MinSi                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD MaxSi                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD DriverName               AS LOGICAL
    FIELD DrivNo                   AS INTE   FORMAT ">>9"
    FIELD DrivAge1                 AS INTE   FORMAT ">>9"
    FIELD DrivAge2                 AS INTE   FORMAT ">>9"
    FIELD Uom6U                    AS CHAR   FORMAT "X(4)"
    FIELD Cctv                     AS LOGICAL
    FIELD Uom1V                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Uom2V                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Uom5V                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Seats41                  AS INTE   FORMAT ">>9"
    FIELD Mv411                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Mv412                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Mv413                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Mv414                    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Mv42                     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Mv43                     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Dedod                    AS DECI   FORMAT "->>>,>>9.99"
    FIELD AdDod                    AS DECI   FORMAT "->>>,>>9.99"
    FIELD DedPd                    AS DECI   FORMAT "->>>,>>9.99"
    FIELD FleetPer                 AS DECI   FORMAT "->>9.99"
    FIELD Ncbyrs                   AS DECI   FORMAT "->>9.99"
    FIELD NcbPer                   AS DECI   FORMAT "->>9.99"
    FIELD DspcPer                  AS DECI   FORMAT "->>9.99"
    FIELD LoadclmPer               AS DECI   FORMAT "->>>9.99"
    FIELD Dstfper                  AS DECI   FORMAT "->>9.99"
    FIELD Baseprm1                 AS DECI   FORMAT "->>>,>>9.99"
    FIELD MainPrem                 AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD VehicleUsePrem           AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD EnginePrem               AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD DriverPrem               AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD VehicleAgePrem           AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD AccessoryPrem            AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD SiPrem                   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD VehicleGroupPrem         AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD TpbiPersonPrem           AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD TpbiAccPrem              AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD TppdPersonPrem           AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Driver411Prem            AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Passenger412Prem         AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Driver413Prem            AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Passenger414Prem         AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD MedicalExp42Prem         AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Bailbond43Prem           AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD DeductODPrem             AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD DeductADPrem             AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD DeductPDPrem             AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD FleetAmt                 AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD NcbAmt                   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD DspcAmt                  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD LoadclmAmt               AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Dstfprm                  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Si22                     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD Baseprm3                 AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Prem3new                 AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD VehicleUse3Prem          AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Engine3Prem              AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD Si3Prem                  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD PrmTnew                  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD PremNetPd                AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD AdjustAll                AS DECI   FORMAT "->>,>>9.99"
    FIELD PrmGapnew                AS DECI   FORMAT "->>,>>9.99"
    FIELD PrmStpnew                AS DECI   FORMAT "->>>,>>9.99"
    FIELD PrmVatnew                AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD ShortRate                AS LOGICAL
    FIELD Days                     AS INTE   FORMAT "->>9"
    FIELD NetInputGap              AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD GrossInputGap            AS DECI   FORMAT "->,>>>,>>9.99"   
    FIELD BehaviorLV               AS INTE
    FIELD BehaviorPercent          AS DECI   FORMAT "->>>9.99"
    FIELD WallChargeSI             AS INTE   FORMAT "->>>>>>>9"
    FIELD RateWallCharge           AS DECI   FORMAT "->>>9.99999"
    FIELD NetPremiumWallCharge     AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD GrossPremiumWallCharge   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD BatteryYear              AS INTE   FORMAT "9999"
    FIELD BatteryPrice             AS INTE   FORMAT "->>>>>>>9"
    FIELD BatterySI                AS INTE   FORMAT "->>>>>>>9"
    FIELD RateBattery              AS DECI   FORMAT "->>>9.99999"
    FIELD NetPremiumBattery        AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD GrossPremiumBattery      AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD MinEVDrivNo              AS INTE   FORMAT ">9"
    FIELD MaxEVDrivNo              AS INTE   FORMAT ">9"
    FIELD DealerGarageRate         AS DECI   FORMAT "->>9.9999"
    FIELD DealerGarageAmount       AS DECI   FORMAT "->,>>>,>>9.99" 
    FIELD CampaignRefer            AS CHAR   FORMAT "X(50)"
    FIELD publishDate              AS CHAR   FORMAT "X(50)"
    FIELD EffectivePeriod          AS CHAR   FORMAT "X(10)"
    FIELD ExpiredPeriod            AS CHAR   FORMAT "X(10)"
    FIELD CampaignName             AS CHAR   FORMAT "X(60)"
    .
    
// Read Json & create Temp-table   
oParser = NEW ObjectModelParser().
oRoot   = CAST(oParser:Parse(ipJson), JsonObject).
oArray  = oRoot:GetJsonArray("CampaignDetail").

DO i = 1 TO oArray:Length:
    oItem = oArray:GetJsonObject(i).
    CREATE ttSmileyRequestList.
    
    ASSIGN 
        ttSmileyRequestList.CampaignGUID            =  oRoot:GetCharacter("publishCampaignRefer")
        ttSmileyRequestList.publishDate             =  oRoot:GetCharacter("publishCampaignDate")
        ttSmileyRequestList.EffectivePeriod         =  oRoot:GetCharacter("EffectivePeriod")
        ttSmileyRequestList.ExpiredPeriod           =  oRoot:GetCharacter("ExpiredPeriod")
        ttSmileyRequestList.CampaignName            =  oRoot:GetCharacter("CampaignName") .
        
    ASSIGN
        ttSmileyRequestList.ListNo               = INT(oItem)
        ttSmileyRequestList.CampaignKeyId        = STRING(oItem:GetDecimal("CampaignKeyId"))
        ttSmileyRequestList.CompanyCode          = oItem:GetCharacter("CompanyCode")
        ttSmileyRequestList.CampaignCode         = oItem:GetCharacter("CampaignCode")
        ttSmileyRequestList.Polmst               = oItem:GetCharacter("Polmst")
        ttSmileyRequestList.Pack                 = oItem:GetCharacter("Pack")
        ttSmileyRequestList.Sclass               = oItem:GetCharacter("Sclass")
        ttSmileyRequestList.Covcod               = oItem:GetCharacter("Covcod")
        ttSmileyRequestList.Vehgrp               = oItem:GetCharacter("Vehgrp")
        ttSmileyRequestList.Vehuse               = IF oItem:IsNull("Vehuse") THEN "" ELSE oItem:GetCharacter("Vehuse")
        ttSmileyRequestList.GarageCd             = oItem:GetCharacter("GarageCd")
        ttSmileyRequestList.Makdes               = oItem:GetCharacter("Makdes")
        ttSmileyRequestList.Moddes               = oItem:GetCharacter("Moddes")
        ttSmileyRequestList.CSTFlag              = oItem:GetCharacter("CSTFlag")
        ttSmileyRequestList.MinYear              = INT(oItem:GetDecimal("MinYear"))
        ttSmileyRequestList.MaxYear              = INT(oItem:GetDecimal("MaxYear"))
        ttSmileyRequestList.MinCst               = INT(oItem:GetDecimal("MinCst"))
        ttSmileyRequestList.MaxCst               = INT(oItem:GetDecimal("MaxCst"))
        ttSmileyRequestList.MinSi                = oItem:GetDecimal("MinSi")
        ttSmileyRequestList.MaxSi                = oItem:GetDecimal("MaxSi")
        ttSmileyRequestList.DriverName           = LOGICAL(oItem:GetCharacter("DriverName"))
        ttSmileyRequestList.DrivNo               = INT(oItem:GetCharacter("DrivNo"))
        ttSmileyRequestList.DrivAge1             = INT(oItem:GetCharacter("DrivAge1"))
        ttSmileyRequestList.DrivAge2             = INT(oItem:GetCharacter("DrivAge2"))
        ttSmileyRequestList.Uom6U                = oItem:GetCharacter("Uom6U")
        ttSmileyRequestList.Cctv                 = LOGICAL(oItem:GetCharacter("Cctv"))
        ttSmileyRequestList.Uom1V                = oItem:GetDecimal("Uom1V")
        ttSmileyRequestList.Uom2V                = oItem:GetDecimal("Uom2V")
        ttSmileyRequestList.Uom5V                = oItem:GetDecimal("Uom5V")
        ttSmileyRequestList.Seats41              = INT(oItem:GetDecimal("Seats41"))
        ttSmileyRequestList.Mv411                = oItem:GetDecimal("Mv411")
        ttSmileyRequestList.Mv412                = oItem:GetDecimal("Mv412")
        ttSmileyRequestList.Mv413                = oItem:GetDecimal("Mv413")
        ttSmileyRequestList.Mv414                = oItem:GetDecimal("Mv414")
        ttSmileyRequestList.Mv42                 = oItem:GetDecimal("Mv42")
        ttSmileyRequestList.Mv43                 = oItem:GetDecimal("Mv43")
        ttSmileyRequestList.Dedod                = oItem:GetDecimal("Dedod")
        ttSmileyRequestList.AdDod                = oItem:GetDecimal("AdDod")
        ttSmileyRequestList.DedPd                = oItem:GetDecimal("DedPd")
        ttSmileyRequestList.FleetPer             = DECIMAL(oItem:GetCharacter("FleetPer"))
        ttSmileyRequestList.Ncbyrs               = DECIMAL(oItem:GetCharacter("Ncbyrs"))
        ttSmileyRequestList.NcbPer               = DECIMAL(oItem:GetCharacter("NcbPer"))
        ttSmileyRequestList.DspcPer              = DECIMAL(oItem:GetCharacter("DspcPer"))
        ttSmileyRequestList.LoadclmPer           = DECIMAL(oItem:GetCharacter("LoadclmPer"))
        ttSmileyRequestList.Dstfper              = DECIMAL(oItem:GetCharacter("Dstfper"))
        ttSmileyRequestList.Baseprm1             = DECIMAL(oItem:GetCharacter("Baseprm1"))
        ttSmileyRequestList.MainPrem             = DECIMAL(oItem:GetCharacter("MainPrem"))
        ttSmileyRequestList.VehicleUsePrem       = DECIMAL(oItem:GetCharacter("VehicleUsePrem"))
        ttSmileyRequestList.EnginePrem           = DECIMAL(oItem:GetCharacter("EnginePrem"))
        ttSmileyRequestList.DriverPrem           = DECIMAL(oItem:GetCharacter("DriverPrem"))
        ttSmileyRequestList.VehicleAgePrem       = DECIMAL(oItem:GetCharacter("VehicleAgePrem"))
        ttSmileyRequestList.AccessoryPrem        = DECIMAL(oItem:GetCharacter("AccessoryPrem"))
        ttSmileyRequestList.SiPrem               = DECIMAL(oItem:GetCharacter("SiPrem"))
        ttSmileyRequestList.VehicleGroupPrem     = DECIMAL(oItem:GetCharacter("VehicleGroupPrem"))
        ttSmileyRequestList.TpbiPersonPrem       = DECIMAL(oItem:GetCharacter("TpbiPersonPrem"))
        ttSmileyRequestList.TpbiAccPrem          = DECIMAL(oItem:GetCharacter("TpbiAccPrem"))
        ttSmileyRequestList.TppdPersonPrem       = DECIMAL(oItem:GetCharacter("TppdPersonPrem"))
        ttSmileyRequestList.Driver411Prem        = DECIMAL(oItem:GetCharacter("Driver411Prem"))
        ttSmileyRequestList.Passenger412Prem     = DECIMAL(oItem:GetCharacter("Passenger412Prem"))
        ttSmileyRequestList.Driver413Prem        = DECIMAL(oItem:GetCharacter("Driver413Prem"))
        ttSmileyRequestList.Passenger414Prem     = DECIMAL(oItem:GetCharacter("Passenger414Prem"))
        ttSmileyRequestList.MedicalExp42Prem     = DECIMAL(oItem:GetCharacter("MedicalExp42Prem"))
        ttSmileyRequestList.Bailbond43Prem       = DECIMAL(oItem:GetCharacter("Bailbond43Prem"))
        ttSmileyRequestList.DeductODPrem         = DECIMAL(oItem:GetCharacter("DeductODPrem"))
        ttSmileyRequestList.DeductADPrem         = DECIMAL(oItem:GetCharacter("DeductADPrem"))
        ttSmileyRequestList.DeductPDPrem         = DECIMAL(oItem:GetCharacter("DeductPDPrem"))
        ttSmileyRequestList.FleetAmt             = DECIMAL(oItem:GetCharacter("FleetAmt"))
        ttSmileyRequestList.NcbAmt               = DECIMAL(oItem:GetCharacter("NcbAmt"))
        ttSmileyRequestList.DspcAmt              = DECIMAL(oItem:GetCharacter("DspcAmt"))
        ttSmileyRequestList.LoadclmAmt           = DECIMAL(oItem:GetCharacter("LoadclmAmt"))
        ttSmileyRequestList.Dstfprm              = DECIMAL(oItem:GetCharacter("Dstfprm"))
        ttSmileyRequestList.Si22                 = INT(oItem:GetDecimal("Si22"))
        ttSmileyRequestList.Baseprm3             = DECIMAL(oItem:GetCharacter("Baseprm3"))
        ttSmileyRequestList.Prem3new             = DECIMAL(oItem:GetCharacter("Prem3new"))
        ttSmileyRequestList.VehicleUse3Prem      = DECIMAL(oItem:GetCharacter("VehicleUse3Prem"))
        ttSmileyRequestList.Engine3Prem          = DECIMAL(oItem:GetCharacter("Engine3Prem"))
        ttSmileyRequestList.Si3Prem              = DECIMAL(oItem:GetCharacter("Si3Prem"))
        ttSmileyRequestList.PrmTnew              = DECIMAL(oItem:GetCharacter("PrmTnew"))
        ttSmileyRequestList.PremNetPd            = DECIMAL(oItem:GetCharacter("PremNetPd"))
        ttSmileyRequestList.AdjustAll            = DECIMAL(oItem:GetCharacter("AdjustAll"))
        ttSmileyRequestList.PrmGapnew            = DECIMAL(oItem:GetCharacter("PrmGapnew"))
        ttSmileyRequestList.PrmStpnew            = DECIMAL(oItem:GetCharacter("PrmStpnew"))
        ttSmileyRequestList.PrmVatnew            = DECIMAL(oItem:GetCharacter("PrmVatnew"))
        ttSmileyRequestList.ShortRate            = LOGICAL(oItem:GetCharacter("ShortRate"))
        ttSmileyRequestList.Days                 = INT(oItem:GetDecimal("Day"))
        ttSmileyRequestList.NetInputGap          = DECIMAL(oItem:GetCharacter("NetInputGap"))
        ttSmileyRequestList.GrossInputGap        = DECIMAL(oItem:GetCharacter("GrossInputGap"))
        ttSmileyRequestList.BehaviorLV           = INT(oItem:GetCharacter("BehaviorLV"))
        ttSmileyRequestList.BehaviorPercent      = DECIMAL(oItem:GetCharacter("BehaviorPercent"))
        ttSmileyRequestList.WallChargeSI         = DECIMAL(oItem:GetCharacter("WallChargeSI"))
        ttSmileyRequestList.RateWallCharge       = DECIMAL(oItem:GetCharacter("RateWallCharge"))
        ttSmileyRequestList.NetPremiumWallCharge = DECIMAL(oItem:GetCharacter("NetPremiumWallCharge"))
        ttSmileyRequestList.GrossPremiumWallCharge = DECIMAL(oItem:GetCharacter("GrossPremiumWallCharge"))
        ttSmileyRequestList.BatteryYear          = INT(oItem:GetCharacter("BatteryYear"))
        ttSmileyRequestList.BatteryPrice         = INT(oItem:GetCharacter("BatteryPrice"))
        ttSmileyRequestList.BatterySI            = INT(oItem:GetCharacter("BatterySI"))
        ttSmileyRequestList.RateBattery          = DECIMAL(oItem:GetCharacter("RateBattery"))
        ttSmileyRequestList.NetPremiumBattery    = DECIMAL(oItem:GetCharacter("NetPremiumBattery"))
        ttSmileyRequestList.GrossPremiumBattery  = DECIMAL(oItem:GetCharacter("GrossPremiumBattery"))
        ttSmileyRequestList.MinEVDrivNo          = INT(oItem:GetCharacter("MinEVDrivNo"))
        ttSmileyRequestList.MaxEVDrivNo          = INT(oItem:GetCharacter("MaxEVDrivNo"))
        ttSmileyRequestList.DealerGarageRate     = DECIMAL(oItem:GetCharacter("DealerGarageRate"))
        ttSmileyRequestList.DealerGarageAmount   = DECIMAL(oItem:GetCharacter("DealerGarageAmount"))
        
        nv_CampaignCode     =   ttSmileyRequestList.CampaignCode  
        .
        

END.
//--------------------------- Save File txt.
DEFINE VARIABLE nv_filejson     AS CHAR INIT "".
DEFINE VARIABLE nv_filetxt      AS CHAR INIT "".
DEFINE VARIABLE nv_filepath     AS CHAR INIT "".

DEFINE VARIABLE nv_basepath   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDateFolder AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFullPath   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lcJson AS LONGCHAR NO-UNDO.
DEFINE VARIABLE cDateTime AS CHARACTER NO-UNDO.
DEFINE VARIABLE cYear       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cMonth      AS CHARACTER NO-UNDO.

DEFINE VARIABLE cYearPath   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cMonthPath  AS CHARACTER NO-UNDO.

/* Base path */
nv_basepath  =  "D:\smileyquote\".
/* Year / Month */
cYear  = STRING(YEAR(TODAY), "9999").
cMonth = STRING(MONTH(TODAY), "99").
/* Date Time FileName */
cDateTime    = STRING(YEAR(TODAY), "9999")
             + STRING(MONTH(TODAY), "99")
             + STRING(DAY(TODAY), "99") 
             + STRING(TRUNCATE(TIME / 3600, 0), "99")      /* ªÑèÇâÁ§ */
             + STRING(TRUNCATE((TIME MOD 3600) / 60, 0), "99") /* ¹Ò·Õ */
             + STRING(TIME MOD 60, "99").  
/* file name */   
nv_filetxt  = "CampaignID_" + publishID  + "_" + cDateTime + ".txt". 
nv_filejson = "CampaignID_" + publishID  + "_" + cDateTime + ".json". 
outFile     = nv_filetxt .
/* === Create folder structure === */
IF SEARCH(nv_basepath) = ? THEN DO:
    OS-CREATE-DIR VALUE(nv_basepath).
    IF OS-ERROR <> 0 THEN DO:
        MESSAGE "Cannot create base path:" nv_basepath.
        RETURN.
    END.
END.

/* Year folder */
cYearPath = nv_basepath + cYear + "\".

IF SEARCH(cYearPath) = ? THEN DO:
    OS-CREATE-DIR VALUE(cYearPath).
    IF OS-ERROR <> 0 THEN DO:
        MESSAGE "Cannot create year folder:" cYearPath.
        RETURN.
    END.
END.

/* Month folder */
cMonthPath = cYearPath + cMonth + "\".

IF SEARCH(cMonthPath) = ? THEN DO:
    OS-CREATE-DIR VALUE(cMonthPath).
    IF OS-ERROR <> 0 THEN DO:
        MESSAGE "Cannot create month folder:" cMonthPath.
        RETURN.
    END.
END.

/* === Full file path === */
nv_filetxt  = cMonthPath + nv_filetxt.
nv_filejson = cMonthPath + nv_filejson.
/* === Export Txt === */  
OUTPUT TO VALUE(nv_filetxt) .  
FOR EACH ttSmileyRequestList:
     PUT ttSmileyRequestList.CompanyCode              "|"
         ttSmileyRequestList.CampaignCode             "|"
         ttSmileyRequestList.Polmst                   "|"
         ttSmileyRequestList.Pack                     "|"
         ttSmileyRequestList.Sclass                   "|"
         ttSmileyRequestList.Covcod                   "|"
         ttSmileyRequestList.Vehgrp                   "|"
         ttSmileyRequestList.Vehuse                   "|"
         ttSmileyRequestList.GarageCd                 "|"
         ttSmileyRequestList.Makdes                   "|"
         ttSmileyRequestList.Moddes                   "|"
         ttSmileyRequestList.CSTFlag                  "|"
         ttSmileyRequestList.MinYear                  "|"
         ttSmileyRequestList.MaxYear                  "|"
         ttSmileyRequestList.MinCst                   "|"
         ttSmileyRequestList.MaxCst                   "|"
         ttSmileyRequestList.MinSi                    "|"
         ttSmileyRequestList.MaxSi                    "|"
         ttSmileyRequestList.DriverName               "|"
         ttSmileyRequestList.DrivNo                   "|"
         ttSmileyRequestList.DrivAge1                 "|"
         ttSmileyRequestList.DrivAge2                 "|"
         ttSmileyRequestList.Uom6U                    "|"
         ttSmileyRequestList.Cctv                     "|"
         ttSmileyRequestList.Uom1V                    "|"
         ttSmileyRequestList.Uom2V                    "|"
         ttSmileyRequestList.Uom5V                    "|"
         ttSmileyRequestList.Seats41                  "|"
         ttSmileyRequestList.Mv411                    "|"
         ttSmileyRequestList.Mv412                    "|"
         ttSmileyRequestList.Mv413                    "|"
         ttSmileyRequestList.Mv414                    "|"
         ttSmileyRequestList.Mv42                     "|"
         ttSmileyRequestList.Mv43                     "|"
         ttSmileyRequestList.Dedod                    "|"
         ttSmileyRequestList.AdDod                    "|"
         ttSmileyRequestList.DedPd                    "|"
         ttSmileyRequestList.FleetPer                 "|"
         ttSmileyRequestList.Ncbyrs                   "|"
         ttSmileyRequestList.NcbPer                   "|"
         ttSmileyRequestList.DspcPer                  "|"
         ttSmileyRequestList.LoadclmPer               "|"
         ttSmileyRequestList.Dstfper                  "|"
         ttSmileyRequestList.Baseprm1                 "|"
         ttSmileyRequestList.MainPrem                 "|"
         ttSmileyRequestList.VehicleUsePrem           "|"
         ttSmileyRequestList.EnginePrem               "|"
         ttSmileyRequestList.DriverPrem               "|"
         ttSmileyRequestList.VehicleAgePrem           "|"
         ttSmileyRequestList.AccessoryPrem            "|"
         ttSmileyRequestList.SiPrem                   "|"
         ttSmileyRequestList.VehicleGroupPrem         "|"
         ttSmileyRequestList.TpbiPersonPrem           "|"
         ttSmileyRequestList.TpbiAccPrem              "|"
         ttSmileyRequestList.TppdPersonPrem           "|"
         ttSmileyRequestList.Driver411Prem            "|"
         ttSmileyRequestList.Passenger412Prem         "|"
         ttSmileyRequestList.Driver413Prem            "|"
         ttSmileyRequestList.Passenger414Prem         "|"
         ttSmileyRequestList.MedicalExp42Prem         "|"
         ttSmileyRequestList.Bailbond43Prem           "|"
         ttSmileyRequestList.DeductODPrem             "|"
         ttSmileyRequestList.DeductADPrem             "|"
         ttSmileyRequestList.DeductPDPrem             "|"
         ttSmileyRequestList.FleetAmt                 "|"
         ttSmileyRequestList.NcbAmt                   "|"
         ttSmileyRequestList.DspcAmt                  "|"
         ttSmileyRequestList.LoadclmAmt               "|"
         ttSmileyRequestList.Dstfprm                  "|"
         ttSmileyRequestList.Si22                     "|"
         ttSmileyRequestList.Baseprm3                 "|"
         ttSmileyRequestList.Prem3new                 "|"
         ttSmileyRequestList.VehicleUse3Prem          "|"
         ttSmileyRequestList.Engine3Prem              "|"
         ttSmileyRequestList.Si3Prem                  "|"
         ttSmileyRequestList.PrmTnew                  "|"
         ttSmileyRequestList.PremNetPd                "|"
         ttSmileyRequestList.AdjustAll                "|"
         ttSmileyRequestList.PrmGapnew                "|"
         ttSmileyRequestList.PrmStpnew                "|"
         ttSmileyRequestList.PrmVatnew                "|"
         ttSmileyRequestList.ShortRate                "|"
         ttSmileyRequestList.Days                     "|"
         ttSmileyRequestList.NetInputGap              "|"
         ttSmileyRequestList.GrossInputGap            "|"
         ttSmileyRequestList.BehaviorLV               "|"
         ttSmileyRequestList.BehaviorPercent          "|"
         ttSmileyRequestList.WallChargeSI             "|"
         ttSmileyRequestList.RateWallCharge           "|"
         ttSmileyRequestList.NetPremiumWallCharge     "|"
         ttSmileyRequestList.GrossPremiumWallCharge   "|"
         ttSmileyRequestList.BatteryYear              "|"
         ttSmileyRequestList.BatteryPrice             "|"
         ttSmileyRequestList.BatterySI                "|"
         ttSmileyRequestList.RateBattery              "|"
         ttSmileyRequestList.NetPremiumBattery        "|"
         ttSmileyRequestList.GrossPremiumBattery      "|"
         ttSmileyRequestList.MinEVDrivNo              "|"
         ttSmileyRequestList.MaxEVDrivNo              "|"
         ttSmileyRequestList.DealerGarageRate         "|"
         ttSmileyRequestList.DealerGarageAmount       "|" 
         ttSmileyRequestList.EffectivePeriod          "|" 
         ttSmileyRequestList.ExpiredPeriod            "|" 
         ttSmileyRequestList.CampaignName            SKIP . 
END.
OUTPUT CLOSE .



OUTPUT TO "D:\smileyquote\Log\ConnectSML.txt" APPEND.
PUT "============================================================" SKIP . 
PUT TODAY  STRING(TIME,"HH:MM:SS")
    " : Process GW_SAFE STATUS=NEW FILE = " + nv_filetxt   FORMAT "X(200)"    SKIP.

OUTPUT CLOSE.

