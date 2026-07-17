/* =========================================================
   Program : WUW_CAMPAIGN_BG.p
   Purpose : Background process อ่านและ process Campaign file
   ========================================================= */
//   DO ON ERROR UNDO, LEAVE:
//  SESSION:SET-WAIT-STATE("WAIT").
   
DEFINE VARIABLE cFile     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPath     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFullPath AS CHARACTER NO-UNDO.
DEFINE VARIABLE lError    AS LOGICAL   NO-UNDO.

DEFINE VARIABLE nv_fileoutput AS CHAR INITIAL "".

DEFINE VAR s_campcd AS CHAR.
DEFINE VAR s_policy AS CHAR.

{WUW\WUWSMLPRM.i}
DEFINE STREAM nfile.
DEFINE STREAM lfile.
    
    
/*  Main Loop งานที่รอ process */
FOR EACH gw_safe.fcamp_fil
   WHERE gw_safe.fcamp_fil.Remark3 = "STATUS=NEW"
     AND gw_safe.fcamp_fil.Remark4 = "PROC=CAMPAIGN"   EXCLUSIVE-LOCK:    
     
    /* =========================
       Step 5.1 : Lock งาน
       ========================= */
   gw_safe.fcamp_fil.Remark3 = "STATUS=PROC".

    /* =========================
      Step 5.2 : Extract FILE / PATH
       ========================= */
    cFile = ENTRY(2, gw_safe.fcamp_fil.Remark1, "=").
    cPath = ENTRY(2, gw_safe.fcamp_fil.Remark2, "=").

    cFullPath = cPath + "\" + cFile.
    
    
     /* =========================
       Step 5.3 : Check file
       ========================= */
    IF SEARCH(cFile) = ? THEN DO:
        gw_safe.fcamp_fil.Remark3 = "STATUS=ERROR".
        gw_safe.fcamp_fil.Remark5 = "FILE NOT FOUND".
        lError = TRUE.
        RETURN.              
    END.
          
    /* =========================
       Step 5.4 : Process file
       ========================= 
    RUN ProcessCampaignFile        // #1 
        ( INPUT  gw_safe.fcamp_fil.CampCode,
          INPUT  cFile,
          OUTPUT lError ).          */
      
    /* =========================
       Step 5.5 : Update status
       ========================= */
    IF lError THEN      
        gw_safe.fcamp_fil.Remark3 = "STATUS=ERROR".
    ELSE
        gw_safe.fcamp_fil.Remark3 = "STATUS=DONE".
   
    MESSAGE cFile  SKIP 
              lError  SKIP
              gw_safe.fcamp_fil.Remark3 VIEW-AS ALERT-BOX.   
   
    // Send HOOK BACK 
    
    // gw_safe.fcamp_fil.Remark3 = "STATUS=ERROR". 
                     
END.      // End For each 
//  END.     // DO ON ERROR UNDO, LEAVE:
//   SESSION:SET-WAIT-STATE("").




PROCEDURE ProcessCampaignFile:       // #1 
    DEFINE INPUT  PARAMETER pcCampCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcFilePath AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER plError    AS LOGICAL   NO-UNDO.

    DEFINE VARIABLE cLine AS CHARACTER NO-UNDO.

    
    FOR EACH tfile:
        DELETE tfile.
    END.
    
    plError = FALSE.

    //INPUT FROM VALUE(pcFilePath).
    INPUT STREAM nfile FROM VALUE(pcFilePath).
    REPEAT:
         CREATE tfile .
         IMPORT STREAM nfile DELIMITER "|"
            tfile  .
            
         IF tFile.fletprm > 0 THEN tFile.fletprm = tFile.fletprm * (-1).
         IF tFile.ncbprm  > 0 THEN tFile.ncbprm  = tFile.ncbprm * (-1).
         IF tFile.dspcprm > 0 THEN tFile.dspcprm = tFile.dspcprm * (-1).
         IF tFile.dstfprm > 0 THEN tFile.dstfprm = tFile.dstfprm * (-1).
         IF tFile.clmprm  < 0 THEN tFile.clmprm  = tFile.clmprm * (-1).
     
         IF tFile.cstw = "C" THEN DO:
             nv_engine = tFile.maxcstw.
         END.
         ELSE IF tFile.cstw = "S" THEN DO:
             IF tFile.maxcstw = 0 THEN DO:
                 nv_seats = tFile.seat41.
             END.
             ELSE nv_seats = tFile.maxcstw.
         END.
         ELSE IF tFile.cstw = "T" THEN DO:
             nv_tons = tFile.maxcstw.
         END.
         ELSE IF tFile.cstw = "W" OR tFile.cstw = "H" THEN DO:
             nv_watts = tFile.maxcstw.
         END.  
         IF tFile.sclass = "E11" OR tFile.sclass = "E12" OR
            tFile.sclass = "E21" OR tFile.sclass = "E61" THEN DO:  /* Add A68-0044 */
             nv_watts = tFile.maxcstw.
         END.
         
         RUN PdChkDataFile.      // Check Validate Text #2 
         
         IF ERROR-STATUS:ERROR THEN DO:
             plError = TRUE.
             LEAVE.
         END.

        
         /*-
        /* ======= Premium Logic ======= */
        RUN Premium_Campaign_Process
            ( INPUT pcCampCode,
              INPUT cLine ) NO-ERROR.    

        IF ERROR-STATUS:ERROR THEN DO:
            plError = TRUE.
            LEAVE.
        END.         -*/
        
    END.              

    INPUT STREAM nfile CLOSE.

    
    IF NOT plError THEN DO:
        RUN PdUploadFile NO-ERROR.         // SAVE  #4
        IF ERROR-STATUS:ERROR THEN
            plError = TRUE.
    END.
    /*
    IF NOT plError THEN
        OS-RENAME VALUE(pcFilePath)
                  VALUE(pcFilePath + ".done").    */

RELEASE campaign_fil.
// Complete END 
                 
END PROCEDURE.  
//*----------------
PROCEDURE PdChkDataFile :     // #2 
nv_msg = "".

IF tFile.vehuse = "" THEN DO:
    nv_msg = "Vehicle Usage is not blank".
    /*RUN PdOutputErrFile.*/
END.

IF tFile.drivnam = YES THEN DO:
    IF tFile.drivno = 0 THEN DO:
        nv_msg = "(1) กรุณาตรวจสอบ Driver No.".
        /*RUN PdOutputErrFile.*/
    END.
END.
ELSE IF tFile.drivnam = NO THEN DO:
    IF tFile.drivno > 0 THEN DO:
        nv_msg = "(2) กรุณาตรวจสอบ Driver No.".
        /*RUN PdOutputErrFile.*/
    END.
END.

IF tFile.cctv = YES THEN DO:
    IF tFile.dspcper < 5 THEN DO:
        nv_msg = "%DSPC ต้องไม่ต่ำกว่า 5% (CCTV)".
        /*RUN PdOutputErrFile.*/
    END.
END.

nv_class = TRIM(tFile.pack) + TRIM(tFile.sclass).
IF nv_class = "" THEN DO:
    nv_msg = "Please, Check SClass on File upload".
    /*RUN PdOutputErrFile.*/
END.

/*-- Comment A68-0158 --
IF TRIM(tFile.sclass) = "E11" THEN DO:
    IF tFile.drivno = 0 THEN DO:
        nv_msg = "EV Tariff Driver No. > 0 ".
        /*RUN PdOutputErrFile.*/
    END.

    IF tFile.levcod < 1 OR tFile.levcod > 5 THEN DO:
        nv_msg = "Please Check Behavior Level 1 to 5 only ".
    END.
END.

IF tFile.levcod > 5 THEN DO:
    nv_msg = "Please Check Behavior Level 1 to 5 only ".    
END.
 -- End Commect A68-0158 --*/
/*-- Add A68-0044 --*/
/*---
IF tFile.prem31 = 0 AND tFile.rate31 = 0 THEN DO:
    nv_fgtariff = NO.
END.
ELSE IF tFile.prem31 <> 0 AND tFile.rate31 <> 0 THEN DO:
    nv_fgtariff = YES.
END.
ELSE DO:
    nv_fgtariff = fifgtariff.
END.
---*/

IF INDEX(tFile.sclass,"E") <> 0 THEN DO:
    nv_fgtariff = NO.    
END.
// ELSE nv_fgtariff = fifgtariff.

IF nv_fgtariff = YES THEN DO:
    IF tFile.prem31 <> 0 OR tFile.rate31 <> 0 THEN DO:
        IF tFile.garage <> "G" THEN DO:
            nv_msg = "M.V31 Apply on Garage 'G' only, Please Check Garage".
        END.
    END.
    
    /*-- Comment A68-0158 --
    IF tFile.maxyrs = 1 THEN DO:
        IF TRIM(tFile.sclass) = "110" OR TRIM(tFile.sclass) = "210" OR TRIM(tFile.sclass) = "610" THEN DO:
            IF tFile.drivno = 0 THEN DO:
                nv_msg = "EV Tariff Driver No. > 0 ".
            END.
        
            IF tFile.levcod < 1 OR tFile.levcod > 5 THEN DO:
                nv_msg = "Please Check Behavior Level 1 to 5 only ".
            END.
        END.
    END.
    -- End Add A68-0158 --*/
END.
/*-- End Add A68-0044 --*/

tFile.remark = nv_msg.
IF tFile.remark <> "" THEN RUN PdOutputErrFile.   // #3

END PROCEDURE.
//----------------
PROCEDURE PdOutputErrFile :      // #3

IF cFile <> "" THEN DO:
      IF INDEX(cFile,".") <> 0 THEN DO:
          nv_fileoutput = SUBSTR(cFile,1,INDEX(cFile,".") - 1) + "_out" +
                     SUBSTR(cFile,INDEX(cFile,".")).
      END.
      ELSE DO:
          nv_fileoutput = cFile + "_out".
      END.
END.

OUTPUT TO VALUE(nv_fileoutput) APPEND.
     PUT tFile.compno    "|".
     PUT tFile.campcd    "|".
     PUT tFile.polmst    "|".
     PUT tFile.pack      "|".
     PUT tFile.sclass    "|".
     PUT tFile.covcod    "|".
     PUT tFile.vehgrp    "|".
     PUT tFile.vehuse    "|".
     PUT tFile.garage    "|".
     PUT tFile.makdes    "|".
     PUT tFile.moddes    "|".
     PUT tFile.cstw      "|".
     PUT tFile.mincstw   "|".
     PUT tFile.maxcstw   "|".
     PUT tFile.minyrs    "|".
     PUT tFile.maxyrs    "|".
     PUT tFile.minsi     "|".
     PUT tFile.maxsi     "|".
     PUT tFile.drivnam   "|".
     PUT tFile.drivno    "|".
     PUT tFile.drivage1  "|".
     PUT tFile.drivage2  "|".
     PUT tFile.uom6_u    "|".
     PUT tFile.cctv      "|".
     PUT tFile.uom1_v    "|".
     PUT tFile.uom2_v    "|".
     PUT tFile.uom5_v    "|".
     PUT tFile.seat41    "|".
     PUT tFile.mv411     "|".
     PUT tFile.mv412     "|".
     PUT tFile.mv413     "|".
     PUT tFile.mv414     "|".
     PUT tFile.mv42      "|".
     PUT tFile.mv43      "|".
     PUT tFile.dedod     "|".
     PUT tFile.dedad     "|".
     PUT tFile.dedpd     "|".
     PUT tFile.fletper   "|".
     PUT tFile.ncbyrs    "|".
     PUT tFile.ncbper    "|".
     PUT tFile.dspcper   "|".
     PUT tFile.clmper    "|".
     PUT tFile.dstfper   "|".
     PUT tFile.baseprm1  "|".
     PUT tFile.mainprm   "|".
     PUT tFile.useprm    "|".
     PUT tFile.engprm    "|".
     PUT tFile.drivprm   "|".
     PUT tFile.yrsprm    "|".
     PUT tFile.othprm    "|".
     PUT tFile.siprm     "|".
     PUT tFile.grpprm    "|".
     PUT tFile.uom1vprm  "|".
     PUT tFile.uom2vprm  "|".
     PUT tFile.uom5vprm  "|".
     PUT tFile.mv411prm  "|".
     PUT tFile.mv412prm  "|".
     PUT tFile.mv413prm  "|".
     PUT tFile.mv414prm  "|".
     PUT tFile.mv42prm   "|".
     PUT tFile.mv43prm   "|".
     PUT tFile.dedodprm  "|".
     PUT tFile.dedadprm  "|".
     PUT tFile.dedpdprm  "|".
     PUT tFile.fletprm   "|".
     PUT tFile.ncbprm    "|".
     PUT tFile.dspcprm   "|".
     PUT tFile.clmprm    "|".
     PUT tFile.dstfprm   "|".
     PUT tFile.siplus    "|".
     PUT tFile.baseprm3  "|".
     PUT tFile.prem3     "|".
     PUT tFile.use3prm   "|".
     PUT tFile.eng3prm   "|".
     PUT tFile.si3prm    "|".
     PUT tFile.netprm    "|".
     PUT tFile.pdprm     "|".
     PUT tFile.adjprm    "|".
     PUT tFile.stamp     "|".
     PUT tFile.vat       "|".
     PUT tFile.totprm    "|".
     PUT tFile.days      "|".
     PUT tFile.shortrate "|".
     PUT tFile.days      "|".
     PUT tFile.newpd     "|".
     PUT tFile.newgap    "|".
     PUT tFile.remark    "|".
     PUT tFile.adjprm1   "|".
     PUT tFile.cstamp    "|".
     PUT tFile.cvat      "|".
     PUT tFile.ctotprm   "|".
     PUT tFile.levcod    "|".
     PUT tFile.levper    "|".
     PUT tFile.chargsi   "|".
     PUT tFile.chargrate "|".
     PUT tFile.chgnetprm "|".
     PUT tFile.chggapprm "|".
     PUT tFile.battyr    "|".
     PUT tFile.battprice "|".
     PUT tFile.battsi    "|".
     PUT tFile.battrate  "|".
     PUT tFile.batnetprm "|".
     PUT tFile.batgapprm "|".
     PUT tFile.drinomin  "|".
     PUT tFile.drinomax  "|".
     PUT tFile.rate31    "|".
     PUT tFile.prem31    "|".
     PUT tFile.EffectiveDDate "|".
     PUT tFile.ExpireDate     "|".
     PUT tFile.CampName       "|".
     PUT tFile.remark         "|".     
     PUT nv_count2       "|".   // Err Row 
     PUT nv_msg          SKIP.
OUTPUT CLOSE.

nv_msg = "".
END PROCEDURE.
//-------------------
PROCEDURE PdUploadFile :       // #4 
ASSIGN
    nv_class    = ""   nv_entdat = TODAY
    nv_addprm   = 0    nv_enttim = STRING(TIME,"HH:MM:SS")
    nv_totdedct = 0    nv_usrid  = USERID(LDBNAME(1))
    nv_totdisc  = 0    nv_comdat = TODAY
    nv_count1   = 0.

FOR EACH tFile WHERE tFile.polmst <> "" NO-LOCK:

    nv_count1 = nv_count1 + 1.
    
    
    nv_class  = TRIM(tFile.pack) + TRIM(tFile.sclass).
    nv_addprm = tFile.mv411prm + tFile.mv412prm + 
                tFile.mv413prm + tFile.mv414prm + 
                tFile.mv42prm  + tFile.mv43prm.

    nv_totdedct = tFile.dedodprm + tFile.dedadprm + tFile.dedpdprm.
    nv_totdisc  = tFile.fletprm + tFile.ncbprm + tFile.dspcprm + tFile.dstfprm.

    ASSIGN
        nv_riskno = 1
        nv_itemno = 1
        nv_comdat = TODAY
        nv_tariff = "X"
        nv_supeflag = NO.
         /* 
        nv_comdat   =  DATE(SUBSTRING(tFile.EffectiveDDate,5,2)  
                            SUBSTRING(tFile.EffectiveDDate,7,2)  
                            SUBSTRING(tFile.EffectiveDDate,1,4)).
                                    //  ExpireDate    
        nv_expdat   =  DATE(SUBSTRING(tFile.ExpireDate,5,2) 
                            SUBSTRING(tFile.ExpireDate,7,2) 
                            SUBSTRING(tFile.ExpireDate,1,4)).    
                           */
        nv_comdat   =   DATE(INTEGER(SUBSTRING(tFile.EffectiveDDate, 5, 2)), /* เดือน */
                             INTEGER(SUBSTRING(tFile.EffectiveDDate, 7, 2)), /* วัน */
                             INTEGER(SUBSTRING(tFile.EffectiveDDate, 1, 4))  /* ปี */
                            ) NO-ERROR.                
        nv_expdat   =   DATE(INTEGER(SUBSTRING(tFile.ExpireDate, 5, 2)), /* เดือน */
                             INTEGER(SUBSTRING(tFile.ExpireDate, 7, 2)), /* วัน */
                             INTEGER(SUBSTRING(tFile.ExpireDate, 1, 4))  /* ปี */
                            ) NO-ERROR.

    IF tFile.cstw = "C" THEN DO:
        nv_engine = tFile.maxcstw.
        nv_seats  = tFile.seat41.
    END.
    ELSE IF tFile.cstw = "S" THEN DO:
        nv_engine = 9999.
        nv_seats  = tFile.maxcstw.
    END.
    ELSE IF tFile.cstw = "T" THEN DO:
        nv_tons   = tFile.maxcstw.
        nv_seats  = tFile.seat41.
    END.
    ELSE IF tFile.cstw = "W" OR tFile.cstw = "H" THEN DO:
        nv_watts  = tFile.maxcstw.
        nv_seats  = tFile.seat41.
    END.
    
    IF SUBSTR(TRIM(tFile.sclass),1,1) = "E" THEN DO:
        nv_watts  = tFile.maxcstw.
        nv_seats  = tFile.seat41.
    END.
    
    IF nv_seats = 0 THEN nv_seats = tFile.seat41.

    IF tFile.covcod = "2.1" OR tFile.covcod = "2.2" OR
       tFile.covcod = "3.1" OR tFile.covcod = "3.2" THEN DO:
        nv_uom6_v = tFile.siplus.

        IF tFile.covcod = "2.1" OR tFile.covcod = "2.2" THEN DO:
            nv_uom7_v = tFile.maxsi.
        END.
        ELSE IF tFile.covcod = "3.1" OR tFile.covcod = "3.2" THEN DO:
            nv_uom7_v = 0.
        END.

    END.
    ELSE nv_uom6_v = tFile.maxsi.

    IF tFile.covcod = "1"   OR tFile.covcod = "5" THEN DO:
        nv_uom6_v = tFile.maxsi.
        nv_uom7_v = tFile.maxsi.
    END.
    IF tFile.covcod = "2" THEN DO:
        nv_uom6_v = 0.
        nv_uom7_v = tFile.maxsi.
    END.
    IF tFile.covcod = "3" THEN DO:
        nv_uom6_v = 0.
        nv_uom7_v = 0.
    END.

    
    IF tFile.ncbper  < 0 THEN tFile.ncbper  = tFile.ncbper  * (-1).
    IF tFile.dspcper < 0 THEN tFile.dspcper = tFile.dspcper * (-1).
    IF tFile.dstfper < 0 THEN tFile.dstfper = tFile.dstfper * (-1).
    
    /*    Update CAm 
    RUN PdAddCampaign.     //  #5  
   
    RUN PdAddCampAccount.     //  #6
   
    RUN PdAddCampModel.         //  #7
    */ 
END.

END PROCEDURE .
// ---------------------
PROCEDURE PdAddCampaign :
FIND FIRST campaign_fil USE-INDEX campfil01 WHERE
           campaign_fil.camcod = tFile.Campcd   AND 
           campaign_fil.polmst = tFile.polmst   AND 
           campaign_fil.class  = nv_class       AND 
           campaign_fil.covcod = tFIle.covcod   AND 
           campaign_fil.vehgrp = tFile.Vehgrp   AND 
           campaign_fil.vehuse = tFile.vehuse   AND 
           campaign_fil.garage = tFile.garage   AND 
           campaign_fil.mincst = tFile.mincstw  AND 
           campaign_fil.maxcst = tFile.maxcstw  AND 
           campaign_fil.minyea = tFile.minyrs   AND 
           campaign_fil.maxyea = tFile.maxyrs   AND 
           campaign_fil.simin  = tFile.minsi    AND 
           campaign_fil.simax  = tFile.maxsi    AND 
           campaign_fil.makdes = tFile.makdes   AND 
           campaign_fil.moddes = tFile.moddes   AND 
           campaign_fil.effdat = nv_comdat      NO-ERROR NO-WAIT.
IF NOT AVAIL campaign_fil THEN DO:
    CREATE campaign_fil.
    ASSIGN
        campaign_fil.camcod      = tFile.campcd  
        campaign_fil.polmst      = tFile.polmst   
        campaign_fil.class       = nv_class 
        campaign_fil.vehgrp      = tFile.vehgrp 
        campaign_fil.vehuse      = tFile.vehuse  
        campaign_fil.garage      = tFile.garage 
        campaign_fil.mincst      = tFile.mincstw               
        campaign_fil.maxcst      = tFile.maxcstw 
        campaign_fil.minyea      = tFile.minyrs                
        campaign_fil.maxyea      = tFile.maxyrs
        campaign_fil.simin       = tFile.minsi                
        campaign_fil.simax       = tFile.maxsi  
        campaign_fil.makdes      = tFile.makdes               
        campaign_fil.moddes      = tFile.moddes 
        campaign_fil.effdat      = nv_comdat  .

    IF tFile.covcod = "2+" OR tFile.covcod = "3+" THEN DO:
        campaign_fil.covcod = TRIM(SUBSTR(tFile.covcod,1,1)) + ".2".
    END.
    ELSE campaign_fil.covcod = tFile.covcod.

    RUN PdUpdCampiagn.

END.
ELSE DO:
    RUN PdUpdCampiagn.
END.
END PROCEDURE.

// -------
PROCEDURE  PdUpdCampiagn:

ASSIGN
    campaign_fil.camnam      = tFile.CampName       
    campaign_fil.paccod      = tFile.pack                         
    campaign_fil.sclass      = tFile.sclass                             
    campaign_fil.engine      = nv_engine               
    campaign_fil.seats       = nv_seats               
    campaign_fil.tons        = nv_tons                               
    campaign_fil.drinam      = tFile.drivnam               
    campaign_fil.drino       = tFile.drivno                
    campaign_fil.access      = tFile.uom6_u                
    campaign_fil.accsi       = 0                
    campaign_fil.dedod       = tFile.dedod                
    campaign_fil.addod       = tFile.dedad                
    campaign_fil.dedpd       = tFile.dedpd                
    campaign_fil.dedprm      = tFile.dedodprm                
    campaign_fil.addprm      = tFile.dedadprm               
    campaign_fil.dpdprm      = tFile.dedpdprm                
    campaign_fil.fletper     = tFile.fletper                
    campaign_fil.fletamt     = IF tFile.fletprm <= 0 THEN tFile.fletprm ELSE tFile.fletprm * (-1)              
    campaign_fil.ncbper      = tFile.ncbper                
    campaign_fil.ncbamt      = IF tFile.ncbprm <= 0 THEN tFile.ncbprm ELSE tFile.ncbprm * (-1)               
    campaign_fil.dspcper     = tFile.dspcper                
    campaign_fil.dspcamt     = IF tFile.dspcprm <= 0 THEN tFile.dspcprm ELSE tFile.dspcprm * (-1)               
    campaign_fil.clmper      = tFile.clmper                
    campaign_fil.clmamt      = IF tFile.clmprm >= 0 THEN tFile.clmprm ELSE tFile.clmprm * (-1)               
    campaign_fil.baseprm     = tFile.baseprm1                
    campaign_fil.baseprm3    = tFile.baseprm3                
    campaign_fil.mv411       = tFile.mv411                 
    campaign_fil.mv412       = tFile.mv412               
    campaign_fil.mv42        = tFile.mv42                
    campaign_fil.mv43        = tFile.mv43                
    campaign_fil.mv44        = tFile.mv413               
    campaign_fil.netprm      = tFile.netprm                
    campaign_fil.tax         = tFile.vat                
    campaign_fil.stamp       = tFile.stamp                
    campaign_fil.grossprm    = tFile.totprm                       
    campaign_fil.expdat      = nv_expdat              
    campaign_fil.entdat      = nv_entdat               
    campaign_fil.enttim      = nv_enttim               
    campaign_fil.usrid       = nv_usrid               
    campaign_fil.remark      = ""                
    campaign_fil.camdet      = ""                
    campaign_fil.camkey      = ""                
    campaign_fil.promcod     = ""  // fiPromCod                
    campaign_fil.promnam     = ""  // fiPromNam               
    campaign_fil.plancod     = ""                
    campaign_fil.planno      = ""                
    campaign_fil.plannam     = ""                
    campaign_fil.ctxt1       = ""                
    campaign_fil.ctxt2       = ""                
    campaign_fil.ctxt3       = ""                
    campaign_fil.ctxt4       = ""                
    campaign_fil.ctxt5       = ""                
    campaign_fil.cdate1      = ?                
    campaign_fil.cdate2      = ?                
    campaign_fil.cdate3      = ?                
    campaign_fil.cdec1       = tFile.netprm                 
    campaign_fil.cdec2       = tFile.totprm             
    campaign_fil.cdec3       = tFile.days              
    campaign_fil.cdec4       = 0                
    campaign_fil.cdec5       = 0                
    campaign_fil.clog1       = NO               
    campaign_fil.clog2       = NO                             
    campaign_fil.doorno      = ""                
    campaign_fil.driage1     = STRING(tFile.drivage1)                
    campaign_fil.driage2     = STRING(tFile.drivage2)                
    campaign_fil.netprm3     = tFile.prem3                
    campaign_fil.cctv        = tFile.cctv                
    campaign_fil.cctvcd      = IF tFile.cctv = YES THEN "0001" ELSE ""                
    campaign_fil.spflag      = STRING(nv_supeflag)              
    campaign_fil.ncbyrs      = tFile.ncbyrs                
    campaign_fil.cctvper     = IF tFile.cctv = YES THEN 5 ELSE 0             
    campaign_fil.cctvamt     = 0                
    campaign_fil.codedet     = ""                
    campaign_fil.codedes     = ""                
    campaign_fil.modelflg    = ""                
    campaign_fil.netprm1     = tFile.mainprm              
    campaign_fil.netprm2     = nv_addprm                
    campaign_fil.netdriv     = tFile.drivprm               
    campaign_fil.stfper      = tFile.dstfper                
    campaign_fil.stfamt      = tFile.dstfprm                
    campaign_fil.uom1_v      = tFile.uom1_v                
    campaign_fil.uom2_v      = tFile.uom2_v                 
    campaign_fil.uom5_v      = tFile.uom5_v                 
    campaign_fil.seat41      = tFile.seat41                
    campaign_fil.drivage1min = 0                
    campaign_fil.drivage1max = 0                
    campaign_fil.drivage2min = 0                
    campaign_fil.drivage2max = 0.

ASSIGN
    campaign_fil.useprm      = tFile.useprm
    campaign_fil.engprm      = tFile.engprm
    campaign_fil.drivprm     = tFile.drivprm
    campaign_fil.yrsprm      = tFile.yrsprm
    campaign_fil.othprm      = tFile.othprm
    campaign_fil.siprm       = tFile.siprm
    campaign_fil.grpprm      = tFile.grpprm
    campaign_fil.tpbipprm    = tFile.uom1vprm
    campaign_fil.tpbiaprm    = tFile.uom2vprm
    campaign_fil.tppdpprm    = tFile.uom5vprm
    campaign_fil.mv411prm    = tFile.mv411prm
    campaign_fil.mv412prm    = tFile.mv412prm
    campaign_fil.mv413prm    = tFile.mv413prm
    campaign_fil.mv414prm    = tFile.mv414prm
    campaign_fil.mv42prm     = tFile.mv42prm
    campaign_fil.mv43prm     = tFile.mv43prm
    campaign_fil.dedod1prm   = tFile.dedodprm
    campaign_fil.dedod2prm   = tFile.dedadprm 
    campaign_fil.dedpdprm    = tFile.dedpdprm
    campaign_fil.use3prm     = tFile.use3prm
    campaign_fil.eng3prm     = tFile.eng3prm
    campaign_fil.si3prm      = tFile.si3prm
    campaign_fil.totlprm     = 0
    campaign_fil.supeprm     = 0
    campaign_fil.dgsiprm     = 0
    campaign_fil.dgfletprm   = 0
    campaign_fil.dgncbprm    = 0
    campaign_fil.dgdspcprm   = 0
    campaign_fil.dggapcprm   = 0
    campaign_fil.dgpdcprm    = 0
    campaign_fil.dgstamp     = 0
    campaign_fil.dgvat       = 0
    campaign_fil.dgtotprm    = 0
    campaign_fil.dgsumins    = 0
    campaign_fil.dgrate      = 0
    campaign_fil.dgflet      = 0
    campaign_fil.dgncb       = 0
    campaign_fil.dgdspc      = 0
    campaign_fil.pdprm       = tFile.pdprm
    campaign_fil.adjprm      = tFile.adjprm
    campaign_fil.shortrate   = tFile.shortrate
    campaign_fil.cdays       = tFile.days.

ASSIGN
    campaign_fil.compcd      = tFile.compno
    campaign_fil.cstflag     = tFile.cstw
    campaign_fil.mv413       = tFile.mv413
    campaign_fil.mv414       = tFile.mv414
    campaign_fil.siplus      = tFile.siplus.

/*-- Add A67-0029 --*/
ASSIGN
    campaign_fil.levcod        = tFile.levcod   
    campaign_fil.levper        = tFile.levper   
    campaign_fil.chargsi       = tFile.chargsi  
    campaign_fil.chargrate     = tFile.chargrate
    campaign_fil.chargnetprm   = tFile.chgnetprm
    campaign_fil.charggrossprm = tFile.chggapprm
    campaign_fil.battyr        = tFile.battyr   
    campaign_fil.battprice     = tFile.battprice
    campaign_fil.battsi        = tFile.battsi   
    campaign_fil.battrate      = tFile.battrate 
    campaign_fil.battnetprm    = tFile.batnetprm
    campaign_fil.battgrossprm  = tFile.batgapprm
    .

/*Add A68-0044*/
ASSIGN
    campaign_fil.si31     = tFile.maxsi
    campaign_fil.rate31   = tFile.rate31
    campaign_fil.pdprm31  = tFile.prem31
    campaign_fil.gapprm31 = tFile.prem31
    campaign_fil.fgtariff = nv_fgtariff.
/*End Add A68-0044*/

nv_ckbatyr = (YEAR(nv_comdat) - campaign_fil.battyr) + 1.
FIND FIRST sicsyac.xmm106 USE-INDEX xmm10601 WHERE 
           xmm106.tariff  = "X"        AND
           xmm106.bencod  = "CBAT"     AND
           xmm106.CLASS   = ""         AND
           xmm106.covcod  = ""         AND
           xmm106.KEY_a   = 0          AND
           xmm106.KEY_b  >= nv_ckbatyr AND
           xmm106.effdat <= nv_comdat  NO-LOCK NO-ERROR NO-WAIT.
IF AVAIL xmm106 THEN DO:
    campaign_fil.battper = xmm106.appinc.
END.

ASSIGN
    campaign_fil.drinam = tFile.drivnam
    campaign_fil.drino  = tFile.drivno.
    
IF nv_fgtariff = NO THEN DO:
    IF Campaign_fil.drino = 1 THEN DO:
        IF Campaign_fil.driAge1 = "24" THEN DO:
            campaign_fil.drivage1min = 18.
            campaign_fil.drivage1max = 24.
        END.
        ELSE IF Campaign_fil.driAge1 = "35" THEN DO:
            campaign_fil.drivage1min = 19.
            campaign_fil.drivage1max = 35.
        END.
        ELSE IF Campaign_fil.driAge1 = "50" THEN DO:
            campaign_fil.drivage1min = 36.
            campaign_fil.drivage1max = 50.
        END.
        ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
            campaign_fil.drivage1min = 51.
            campaign_fil.drivage1max = 99.
        END.
    END.
    ELSE IF Campaign_fil.drino = 2 THEN DO:
        /*-- Driver No. = 1 --*/
        IF Campaign_fil.driAge1 = "24" THEN DO:
            campaign_fil.drivage1min = 18.
            campaign_fil.drivage1max = 24.
        END.
        ELSE IF Campaign_fil.driAge1 = "35" THEN DO:
            campaign_fil.drivage1min = 25.
            campaign_fil.drivage1max = 35.
        END.
        ELSE IF Campaign_fil.driAge1 = "50" THEN DO:
            campaign_fil.drivage1min = 36.
            campaign_fil.drivage1max = 50.
        END.
        ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
            campaign_fil.drivage1min = 51.
            campaign_fil.drivage1max = 99.
        END.
    
        /*-- Driver No. = 2 --*/
        IF Campaign_fil.driAge2 = "24" THEN DO:
            campaign_fil.drivage2min = 18.
            campaign_fil.drivage2max = 24.
        END.
        ELSE IF Campaign_fil.driAge2 = "35" THEN DO:
            campaign_fil.drivage2min = 19.
            campaign_fil.drivage2max = 35.
        END.
        ELSE IF Campaign_fil.driAge2 = "50" THEN DO:
            campaign_fil.drivage2min = 36.
            campaign_fil.drivage2max = 50.
        END.
        ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
            campaign_fil.drivage2min = 51.
            campaign_fil.drivage2max = 99.
        END.
    END.
END.

/*-- Comment A68-0158 08/01/2026 --
/*-- Add A68-0044 --*/
IF campaign_fil.sclass = "E11" OR
   campaign_fil.sclass = "E21" OR           
   campaign_fil.sclass = "E61" THEN DO:     
    IF campaign_fil.drino = 0 THEN DO:
        campaign_fil.drino = tFile.drinomax.
    END.
END.
ELSE DO: 
    IF nv_fgtariff = YES THEN DO:
        IF campaign_fil.drino = 0 THEN DO:
            campaign_fil.drino = tFile.drinomax.
        END.
    END.
END.

IF tFile.sclass <> "E11" AND
   tFile.sclass <> "E21" AND
   tFile.sclass <> "E61" AND
   tFile.sclass <> "110" AND
   tFile.sclass <> "210" AND
   tFile.sclass <> "610" THEN DO:
    IF nv_fgtariff = NO THEN DO:
        IF Campaign_fil.drino = 1 THEN DO:
            IF Campaign_fil.driAge1 = "24" THEN DO:
                campaign_fil.drivage1min = 18.
                campaign_fil.drivage1max = 24.
            END.
            ELSE IF Campaign_fil.driAge1 = "35" THEN DO:
                campaign_fil.drivage1min = 19.
                campaign_fil.drivage1max = 35.
            END.
            ELSE IF Campaign_fil.driAge1 = "50" THEN DO:
                campaign_fil.drivage1min = 36.
                campaign_fil.drivage1max = 50.
            END.
            ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
                campaign_fil.drivage1min = 51.
                campaign_fil.drivage1max = 99.
            END.
        END.
        ELSE IF Campaign_fil.drino = 2 THEN DO:
            /*-- Driver No. = 1 --*/
            IF Campaign_fil.driAge1 = "24" THEN DO:
                campaign_fil.drivage1min = 18.
                campaign_fil.drivage1max = 24.
            END.
            ELSE IF Campaign_fil.driAge1 = "35" THEN DO:
                campaign_fil.drivage1min = 25.
                campaign_fil.drivage1max = 35.
            END.
            ELSE IF Campaign_fil.driAge1 = "50" THEN DO:
                campaign_fil.drivage1min = 36.
                campaign_fil.drivage1max = 50.
            END.
            ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
                campaign_fil.drivage1min = 51.
                campaign_fil.drivage1max = 99.
            END.
        
            /*-- Driver No. = 2 --*/
            IF Campaign_fil.driAge2 = "24" THEN DO:
                campaign_fil.drivage2min = 18.
                campaign_fil.drivage2max = 24.
            END.
            ELSE IF Campaign_fil.driAge2 = "35" THEN DO:
                campaign_fil.drivage2min = 19.
                campaign_fil.drivage2max = 35.
            END.
            ELSE IF Campaign_fil.driAge2 = "50" THEN DO:
                campaign_fil.drivage2min = 36.
                campaign_fil.drivage2max = 50.
            END.
            ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
                campaign_fil.drivage2min = 51.
                campaign_fil.drivage2max = 99.
            END.
        END.
    END.
    ELSE DO:
        IF campaign_fil.drinam = NO THEN campaign_fil.drinam = YES.  
        IF campaign_fil.drino  = 0  THEN campaign_fil.drino  = 5. 
    END.
END.
-- End Comment A68-0158 08/01/026 --*/
/*-- Comment A68-0158 --
ELSE DO:
    IF campaign_fil.drinam = NO THEN campaign_fil.drinam = YES.  
    IF campaign_fil.drino  = 0  THEN campaign_fil.drino  = 5. 
END.
- Comment A68-0158 --*/
/*-- End Add A68-0044 --*/

/*-- Comment A68-0044 --
IF campaign_fil.sclass = "E11" THEN DO:
    IF campaign_fil.drino = 0 THEN DO:
        campaign_fil.drino = tFile.drinomax.
    END.
END.

/*-- End Add A67-0029 --*/

IF tFile.sclass <> "E11" THEN DO:  /*-- Add A67-0029 --*/
    IF Campaign_fil.drino = 1 THEN DO:
        IF Campaign_fil.driAge1 = "24" THEN DO:
            campaign_fil.drivage1min = 18.
            campaign_fil.drivage1max = 24.
        END.
        ELSE IF Campaign_fil.driAge1 = "35" THEN DO:
            campaign_fil.drivage1min = 19.
            campaign_fil.drivage1max = 35.
        END.
        ELSE IF Campaign_fil.driAge1 = "50" THEN DO:
            campaign_fil.drivage1min = 36.
            campaign_fil.drivage1max = 50.
        END.
        ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
            campaign_fil.drivage1min = 51.
            campaign_fil.drivage1max = 99.
        END.
    END.
    ELSE IF Campaign_fil.drino = 2 THEN DO:
        /*-- Driver No. = 1 --*/
        IF Campaign_fil.driAge1 = "24" THEN DO:
            campaign_fil.drivage1min = 18.
            campaign_fil.drivage1max = 24.
        END.
        ELSE IF Campaign_fil.driAge1 = "35" THEN DO:
            campaign_fil.drivage1min = 25.
            campaign_fil.drivage1max = 35.
        END.
        ELSE IF Campaign_fil.driAge1 = "50" THEN DO:
            campaign_fil.drivage1min = 36.
            campaign_fil.drivage1max = 50.
        END.
        ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
            campaign_fil.drivage1min = 51.
            campaign_fil.drivage1max = 99.
        END.
    
        /*-- Driver No. = 2 --*/
        IF Campaign_fil.driAge2 = "24" THEN DO:
            campaign_fil.drivage2min = 18.
            campaign_fil.drivage2max = 24.
        END.
        ELSE IF Campaign_fil.driAge2 = "35" THEN DO:
            campaign_fil.drivage2min = 19.
            campaign_fil.drivage2max = 35.
        END.
        ELSE IF Campaign_fil.driAge2 = "50" THEN DO:
            campaign_fil.drivage2min = 36.
            campaign_fil.drivage2max = 50.
        END.
        ELSE IF INTE(Campaign_fil.driAge1) > 50 THEN DO:
            campaign_fil.drivage2min = 51.
            campaign_fil.drivage2max = 99.
        END.
    END.
END.
ELSE DO:
    IF campaign_fil.drinam = NO THEN campaign_fil.drinam = YES.  
    IF campaign_fil.drino  = 0  THEN campaign_fil.drino  = 5. 
END.
-- End Comment A68-0044 --*/

/*-- Add Check Main Premium --*/
nv_mainprm = 0.
IF Campaign_fil.covcod = "2.1" OR Campaign_fil.covcod = "2.2" OR 
   Campaign_fil.covcod = "3.1" OR Campaign_fil.covcod = "3.2" THEN DO:
    ASSIGN
        nv_mainprm = tFile.baseprm1 + tFile.useprm + tFile.engprm + 
                     tFile.drivprm  + tFile.yrsprm + tFile.othprm + 
                     tFile.siprm    + tFile.grpprm + tFile.uom1vprm + 
                     tFile.uom2vprm + tFile.uom5vprm +
                     tFile.mv411prm + tFile.mv412prm +
                     tFile.mv413prm + tFile.mv414prm +
                     tFile.mv42prm  + tFile.mv43prm.
END.
ELSE DO:
    ASSIGN
        nv_mainprm = tFile.baseprm1 + tFile.useprm + tFile.engprm + 
                     tFile.drivprm  + tFile.yrsprm + tFile.othprm + 
                     tFile.siprm    + tFile.grpprm + tFile.uom1vprm + 
                     tFile.uom2vprm + tFile.uom5vprm.
END.

IF tFile.mainprm <> nv_mainprm THEN DO:
    campaign_fil.netprm1 = nv_mainprm.
END.

RUN PdAddPmuwd132.

/*--
nv_mainprm = 0.
FOR EACH stat.pmuwd132 USE-INDEX pmuwd13201 WHERE
         stat.pmuwd132.campcd = campaign_fil.camcod AND
         stat.pmuwd132.policy = campaign_fil.polmst NO-LOCK:
    FIND FIRST xmm105 WHERE 
               xmm105.tariff = "X" AND
               xmm105.bencod = stat.pmuwd132.bencod NO-LOCK NO-ERROR NO-WAIT.
    IF AVAIL xmm105 THEN DO:
        IF xmm105.areano = 1 THEN DO:
            nv_mainprm = nv_mainprm + stat.pmuwd132.prem_c.
        END.
    END.      
END.

IF tFile.mainprm <> nv_mainprm THEN DO:
    campaign_fil.netprm1 = nv_mainprm.
END.
--*/


/*--
IF toChkCal = YES THEN DO: 
    nv_calflg = YES.
    RUN PdCalculateCamp.
END.
ELSE DO: 
    nv_calflg = NO.
    RUN PdAddPmuwd132.
END.                   -*/

END PROCEDURE.   

// ---------------
PROCEDURE PdAddCampAccount :   //6 

    nv_accname = "".
    nv_branch  = "".
        nv_AccountCd = "ALL".
        nv_accname  = "ALL".
        nv_branch   = "ALL".
    
        FIND FIRST sicsyac.xmm600 USE-INDEX xmm60001 WHERE
                   sicsyac.xmm600.acno = nv_AccountCd NO-LOCK NO-ERROR NO-WAIT.
        IF AVAIL sicsyac.xmm600 THEN DO:
            nv_accname = sicsyac.xmm600.NAME.
        END.
    END.
    
    FIND FIRST caccount USE-INDEX caccount01 WHERE
               caccount.acno   = nv_AccountCd         AND
               caccount.branch = nv_branch            AND
               caccount.compno = tFile.compno        AND
               caccount.camcod = campaign_fil.camcod NO-ERROR.
    IF NOT AVAIL caccount THEN DO:
        CREATE caccount.
        ASSIGN
            caccount.acno   = nv_AccountCd
            caccount.acnam  = nv_accname
            caccount.compno = tFile.compno
            caccount.comnam = ""
            caccount.branch = CAPS(TRIM(nv_branch))
            caccount.camcod = campaign_fil.camcod
            caccount.camnam = campaign_fil.camnam
            caccount.effdat = nv_comdat 
            caccount.expdat = campaign_fil.expdat     
            caccount.acctxt = ""
            caccount.remark = ""
            caccount.entdat = TODAY     
            caccount.enttim = STRING(TIME,"HH:MM:SS")
            caccount.usrid  = USERID(LDBNAME(1)).
    END.
    ELSE DO:
        ASSIGN
            caccount.camnam = campaign_fil.camnam   
            caccount.expdat = campaign_fil.expdat     
            caccount.acctxt = ""
            caccount.remark = ""
            caccount.entdat = TODAY     
            caccount.enttim = STRING(TIME,"HH:MM:SS")
            caccount.usrid  = USERID(LDBNAME(1)).
    END.
    
// END PROCEDURE.
// ----------------

PROCEDURE PdAddCampModel :   // #7

IF tFile.makdes <> "" THEN DO:
    FIND FIRST cmodel_fil USE-INDEX cmodel01 WHERE
               cmodel_fil.camcod = tFile.campcd AND
               cmodel_fil.CLASS  = nv_class     AND
               cmodel_fil.makdes = tFile.makdes AND
               cmodel_fil.moddes = tFile.moddes NO-ERROR.
    IF NOT AVAIL cModel_fil THEN DO:
        CREATE cmodel_fil.
        ASSIGN
            cmodel_fil.camcod = tFile.campcd
            cmodel_fil.makdes = tFile.makdes
            cmodel_fil.moddes = tFile.moddes
            cmodel_fil.class  = nv_class
            cmodel_fil.remark = ""
            cmodel_fil.effdat = nv_comdat   
            cmodel_fil.entdat = nv_entdat  
            cmodel_fil.enttim = nv_enttim
            cmodel_fil.usrid  = nv_usrid. 
    END.
END.
END PROCEDURE.

// -------------
PROCEDURE PdAddPmuwd132 :
nv_calflg = YES.
ASSIGN
    s_campcd  = campaign_fil.camcod  /*Add A68-0158*/
    s_policy  = campaign_fil.polmst  /*Add A68-0158*/
    n_policy  = campaign_fil.polmst
    nv_campcd = campaign_fil.camcod
    nv_covcod = campaign_fil.covcod
    nv_sclass = campaign_fil.sclass
    nv_tons   = campaign_fil.tons
    nv_seats  = campaign_fil.seats
    nv_engine = campaign_fil.engine
    nv_class  = TRIM(campaign_fil.paccod) + TRIM(campaign_fil.sclass).

IF campaign_fil.covcod = "1" OR
   campaign_fil.covcod = "5" THEN DO:
    ASSIGN
        nv_uom6_v = campaign_fil.simax.
        nv_uom7_v = campaign_fil.simax.    
END.
ELSE IF campaign_fil.covcod = "2" THEN DO:
    ASSIGN
        nv_uom6_v = 0.
        nv_uom7_v = campaign_fil.simax. 
END.
ELSE IF campaign_fil.covcod = "3" THEN DO:
    ASSIGN
        nv_uom6_v = 0.
        nv_uom7_v = 0. 
END.
ELSE IF campaign_fil.covcod = "2.1" OR
        campaign_fil.covcod = "2.2" THEN DO:
    ASSIGN
        nv_uom6_v = campaign_fil.siplus.
        nv_uom7_v = campaign_fil.simax.
END.
ELSE IF campaign_fil.covcod = "3.1" OR
        campaign_fil.covcod = "3.2" THEN DO:
    ASSIGN
        nv_uom6_v = campaign_fil.siplus.
        nv_uom7_v = 0. 
END.

ASSIGN                                          /*-- Add A67-0029 --*/
    nv_gapprm     = campaign_fil.netprm         nv_levcod    = campaign_fil.levcod       
    nv_pdprm      = campaign_fil.pdprm          nv_levper    = campaign_fil.levper       
    nv_compprm    = 0                           nv_chargsi   = campaign_fil.chargsi      
    nv_baseprm    = campaign_fil.baseprm        nv_chargrate = campaign_fil.chargrate    
    nv_useprm     = campaign_fil.useprm         nv_chgnetprm = campaign_fil.chargnetprm  
    nv_grprm      = campaign_fil.grpprm         nv_chggapprm = campaign_fil.charggrossprm
    nv_yrprm      = campaign_fil.yrsprm         nv_battyr    = campaign_fil.battyr       
    nv_siprm      = campaign_fil.siprm          nv_battprice = campaign_fil.battprice    
    nv_totlprm    = 0                           nv_battsi    = campaign_fil.battsi       
    nv_othprm     = campaign_fil.othprm         nv_battrate  = campaign_fil.battrate     
    nv_engprm     = campaign_fil.engprm         nv_batnetprm = campaign_fil.battnetprm   
    nv_drivprm    = campaign_fil.drivprm        nv_batgapprm = campaign_fil.battgrossprm 
    nv_bipprm     = campaign_fil.tpbipprm       nv_cl_per    = campaign_fil.clmper
    nv_biaprm     = campaign_fil.tpbiaprm       nv_age1      = INTE(campaign_fil.driage1)
    nv_pdaprm     = campaign_fil.tppdpprm       nv_age2      = INTE(campaign_fil.driage2)
    nv_411prm     = campaign_fil.mv411prm       /*-- End Add A67-0029 --*/
    nv_412prm     = campaign_fil.mv412prm       /*-- Add A68-0044 --*/
    nv_413prm     = campaign_fil.mv413prm       nv_pdprm31   = campaign_fil.pdprm31
    nv_414prm     = campaign_fil.mv414prm       nv_gapprm31  = campaign_fil.gapprm31
    nv_42prm      = campaign_fil.mv42prm        nv_rate31    = campaign_fil.rate31
    nv_43prm      = campaign_fil.mv43prm        /*-- End Add A68-0044 --*/
    nv_dedod1_prm = campaign_fil.dedod1prm 
    nv_dedod2_prm = campaign_fil.dedod2prm 
    nv_dedpd_prm  = campaign_fil.dedpdprm  
    nv_flet       = campaign_fil.fletamt
    nv_ncb        = campaign_fil.ncbamt
    nv_dsspc      = campaign_fil.dspcamt
    nv_stf_amt    = campaign_fil.stfamt
    nv_lodclm     = campaign_fil.clmamt
    nv_camprem    = 0
    nv_baseprm3   = campaign_fil.baseprm3
    nv_engprm3    = campaign_fil.eng3prm
    nv_siprm3     = campaign_fil.si3prm
    nv_supeprm    = 0.

RUN PdCParaUwd132.
RUN PdCGenpmUwd132.
END PROCEDURE.
// --- -- - - - - - - 

PROCEDURE PdCParaUwd132 :
          /*-- Base Premium --*/
    ASSIGN
        nv_basevar  = ""
        nv_basevar1 = ""
        nv_basevar2 = ""
        nv_basecod = "BASE"
        nv_basevar1 = "     Base Premium = "
        nv_basevar2 = STRING(campaign_fil.baseprm)
        SUBSTRING(nv_basevar,1,30)   = nv_basevar1
        SUBSTRING(nv_basevar,31,30)  = nv_basevar2.

    /*-- USE Premium --*/
    ASSIGN
        nv_usevar  = ""
        nv_usevar1 = ""
        nv_usevar2 = ""
        nv_usecod  = "USE" + TRIM(campaign_fil.vehuse)
        nv_usevar1 = "     Vehicle Use = "
        nv_usevar2 = campaign_fil.vehuse
        SUBSTRING(nv_usevar,1,30)  = nv_usevar1
        SUBSTRING(nv_usevar,31,30) = nv_usevar2.

    IF nv_covcod = "2.1" OR nv_covcod = "2.2" OR
       nv_covcod = "3.1" OR nv_covcod = "3.2" THEN DO:
        IF      nv_covcod = "2.1" THEN nv_usecod3 = "U" + TRIM(campaign_fil.vehuse) + "21". 
        ELSE IF nv_covcod = "2.2" THEN nv_usecod3 = "U" + TRIM(campaign_fil.vehuse) + "22".
        ELSE IF nv_covcod = "3.1" THEN nv_usecod3 = "U" + TRIM(campaign_fil.vehuse) + "31". 
        ELSE IF nv_covcod = "3.2" THEN nv_usecod3 = "U" + TRIM(campaign_fil.vehuse) + "32".

        ASSIGN  
            nv_usevar3 = ""
            nv_usevar4 = ""
            nv_usevar5 = ""
            nv_usevar4 = "     Vehicle Use = "
            nv_usevar5 =  campaign_fil.vehuse
            SUBSTRING(nv_usevar3,1,30)  = nv_usevar4
            SUBSTRING(nv_usevar3,31,30) = nv_usevar5.
    END.

    /*-- Group Premium --*/
    ASSIGN
        nv_grpvar      = ""
        nv_grpvar1     = ""
        nv_grpvar2     = ""
        nv_grpcod      = "GRP" + campaign_fil.vehgrp
        nv_grpvar1     = "     Vehicle Group = "
        nv_grpvar2     = campaign_fil.vehgrp
        SUBSTRING(nv_grpvar,1,30)  = nv_grpvar1
        SUBSTRING(nv_grpvar,31,30) = nv_grpvar2.

    /*-- Engine --*/
    /*-- Add A67-0029 --*/
    FIND FIRST sicsyac.xmm016 USE-INDEX xmm01601 WHERE
               xmm016.CLASS = nv_class NO-LOCK NO-ERROR NO-WAIT.
    IF AVAIL xmm016 THEN DO:
        nv_engcod = "ENG" + TRIM(xmm016.capuom).
    END.
    ELSE DO:
        FIND FIRST clastab_fil USE-INDEX clastab01 WHERE
                   clastab_fil.CLASS  = nv_class   AND
                   clastab_fil.covcod = nv_covcod  NO-LOCK NO-ERROR NO-WAIT.
        IF AVAIL clastab_fil THEN DO:
            nv_engcod = "ENG" + TRIM(clastab_fil.unit).
        END.
    
        IF nv_engcod = "ENG" THEN nv_engcod = "ENGC". /* กรณีรหัสไม่ใช้ Engine มาคำนวน */
    END.
    /*-- End Add A67-0029 --*/

    /*-- Add A68-0044 --*/
    IF nv_engcod <> "" THEN DO:
        IF nv_engcod = "ENGC" THEN DO:
            IF INDEX(nv_sclass,"E") <> 0 THEN DO:
                ASSIGN  
                    nv_engvar   = " "
                    nv_engvar1  = " "
                    nv_engvar2  = ""
                    nv_engvar1  = "     Vehicle KW. = "
                    nv_engvar2  = STRING(nv_watts)    
                    SUBSTRING(nv_engvar,1,30)   = nv_engvar1
                    SUBSTRING(nv_engvar,31,30)  = nv_engvar2.
            END.
            ELSE DO:
                ASSIGN  
                    nv_engvar   = " "
                    nv_engvar1  = " "
                    nv_engvar2  = ""
                    nv_engvar1  = "     Vehicle CC. = "
                    nv_engvar2  = STRING(nv_engine) 
                    SUBSTRING(nv_engvar,1,30)   = nv_engvar1
                    SUBSTRING(nv_engvar,31,30)  = nv_engvar2.
            END.
        END.
        ELSE IF nv_engcod = "ENGH" THEN DO:
            ASSIGN  
                nv_engvar   = " "
                nv_engvar1  = " "
                nv_engvar2  = ""
                nv_engvar1  = "     Vehicle HP. = "
                nv_engvar2  = STRING(nv_watts) 
                SUBSTRING(nv_engvar,1,30)   = nv_engvar1
                SUBSTRING(nv_engvar,31,30)  = nv_engvar2.
        END.
        ELSE IF nv_engcod = "ENGS" THEN DO:
            ASSIGN  
                nv_engvar   = " "
                nv_engvar1  = " "
                nv_engvar2  = ""
                nv_engvar1  = "     Vehicle Seats = "
                nv_engvar2  = STRING(nv_seats)
                SUBSTRING(nv_engvar,1,30)  = nv_engvar1
                SUBSTRING(nv_engvar,31,30) = nv_engvar2.
        END.
        ELSE IF nv_engcod = "ENGT" THEN DO:
            ASSIGN  
                nv_engvar  = " "
                nv_engvar1  = " "
                nv_engvar2  = ""
                nv_engvar1 = IF nv_tons > 100 THEN "     Vehicle Kilograms = " ELSE "     Vehicle Tons. = "
                nv_engvar2 =  STRING(nv_tons)
                SUBSTRING(nv_engvar,1,30)  = nv_engvar1
                SUBSTRING(nv_engvar,31,30) = nv_engvar2.
    
            IF nv_covcod = "2.1" OR nv_covcod = "2.2" OR
               nv_covcod = "3.1" OR nv_covcod = "3.2" THEN DO:
                IF SUBSTRING(TRIM(nv_sclass),1,1) = "3" OR
                   SUBSTRING(TRIM(nv_sclass),1,1) = "4" OR
                   SUBSTRING(TRIM(nv_sclass),1,1) = "5" THEN DO:
                    ASSIGN
                        nv_engcod3 = "ENPT"
                        nv_engvar3 = ""
                        nv_engvar4 = ""
                        nv_engvar5 = ""
                        nv_engvar4 = IF nv_tons > 100 THEN "     Veh. Plus Kilograms = " ELSE "     Veh. Plus Tons. = "
                        nv_engvar5 = STRING(nv_tons)
                        SUBSTRING(nv_engvar3,1,30)  = nv_engvar4
                        SUBSTRING(nv_engvar3,31,30) = nv_engvar5.
                END.
            END.
        END.
    END.
    /*-- End Add A68-0044 --*/

    /*-- Year Premium --*/
    ASSIGN
        nv_yrcod   = IF campaign_fil.maxyea <= 10 THEN "YR" + STRING(campaign_fil.maxyea)
                                                  ELSE "YR99"
        nv_yrvar   = "" 
        nv_yrvar1  = ""
        nv_yrvar2  = ""
        nv_yrvar1  = "      Vehicle Year = "
        nv_yrvar2  = STRING(campaign_fil.maxyea)
        SUBSTRING(nv_yrvar,1,30)    = nv_yrvar1
        SUBSTRING(nv_yrvar,31,30)   = nv_yrvar2.
        
    RUN PDGenCodeDriver.    


    RUN PdC01ParaUwd132.
END PROCEDURE.

// --- -- - - - - - - 
PROCEDURE PDGenCodeDriver :
   IF campaign_fil.drinam = NO THEN DO:
    IF nv_fgtariff = YES THEN DO:
        IF campaign_fil.sclass = "110" OR campaign_fil.sclass = "210" OR campaign_fil.sclass = "610" THEN DO:
            nv_drivcod = "AL00".
        END.
        ELSE DO:
            nv_drivcod = "A000".
        END.
    END.
    ELSE DO:
        IF campaign_fil.sclass = "E11" OR campaign_fil.sclass = "E21" OR campaign_fil.sclass = "E61" THEN DO:
            nv_drivcod = "AL00".
        END.
        ELSE DO:
            nv_drivcod = "A000".
        END.
    END.
    
    ASSIGN
        nv_drivvar   = " "
        nv_drivvar1  = ""
        nv_drivvar2  = ""
        nv_drivvar1  =  "     Unname Driver"
        nv_drivvar2  = STRING(campaign_fil.drino)
        SUBSTRING(nv_drivvar,1,30)   = nv_drivvar1
        SUBSTRING(nv_drivvar,31,30)  = nv_drivvar2.
END.
ELSE DO:
    IF campaign_fil.sclass = "E11" OR 
       campaign_fil.sclass = "E21" OR 
       campaign_fil.sclass = "E61" THEN DO:
       nv_drivcod = "AL0" + TRIM(STRING(nv_levcod,"9")).
    END.
    ELSE DO:
        IF nv_fgtariff = YES THEN DO:
            IF campaign_fil.sclass = "110" OR 
               campaign_fil.sclass = "210" OR 
               campaign_fil.sclass = "610" THEN
            DO:
                nv_drivcod = "AL0" + TRIM(STRING(nv_levcod,"9")).    
            END.
            ELSE nv_drivcod = "AL0" + TRIM(STRING(nv_levcod,"9")).    
        END.
        ELSE DO:
            IF SUBSTR(campaign_fil.sclass,1,1) = "E" THEN DO:
                nv_drivcod = "AL0" + TRIM(STRING(nv_levcod,"9")).
            END.
            ELSE DO:
                IF campaign_fil.drino = 1 THEN DO:
                    IF nv_age1 LE 50 THEN DO:
                      IF nv_age1 LE 35 THEN DO:
                        IF nv_age1 LE 24 THEN DO:
                          nv_drivcod = nv_drivcod + "24".
                        END.
                        ELSE nv_drivcod = nv_drivcod + "35".
                      END.
                      ELSE nv_drivcod = nv_drivcod + "50".
                    END.
                    ELSE nv_drivcod = nv_drivcod + "99".
                END.
                ELSE IF campaign_fil.drino = 2 THEN DO:
                    IF nv_age1 LE 50 THEN DO:
                      IF nv_age1 LE 35 THEN DO:
                        IF nv_age1 LE 24 THEN DO:
                          nv_drivcod1 = nv_drivcod + "24".
                        END.
                        ELSE nv_drivcod1 = nv_drivcod + "35".
                      END.
                      ELSE nv_drivcod1 = nv_drivcod + "50".
                    END.
                    ELSE nv_drivcod1 = nv_drivcod + "99".

                    FIND FIRST sicsyac.xmm106 USE-INDEX xmm10601 WHERE
                           xmm106.tariff = nv_tariff   AND
                           xmm106.bencod = nv_drivcod1 AND
                           xmm106.class  = nv_class    AND
                           xmm106.covcod = nv_covcod   AND
                           xmm106.key_b  GE 0          AND
                           xmm106.effdat LE nv_comdat
                           NO-LOCK NO-ERROR.
                    IF AVAIL xmm106 THEN
                       nv_age1rate = xmm106.appinc.
                
                    IF nv_age2 LE 50 THEN DO:
                      IF nv_age2 LE 35 THEN DO:
                        IF nv_age2 LE 24 THEN DO:
                          nv_drivcod2 = nv_drivcod + "24".
                        END.
                        ELSE nv_drivcod2 = nv_drivcod + "35".
                      END.
                      ELSE nv_drivcod2 = nv_drivcod + "50".
                    END.
                    ELSE nv_drivcod2 = nv_drivcod + "99".
                
                    FIND FIRST xmm106 USE-INDEX xmm10601 WHERE
                           xmm106.tariff = nv_tariff   AND
                           xmm106.bencod = nv_drivcod2 AND
                           xmm106.class  = nv_class    AND
                           xmm106.covcod = nv_covcod   AND
                           xmm106.key_b  GE 0          AND
                           xmm106.effdat LE nv_comdat
                           NO-LOCK NO-ERROR.
                    IF AVAIL xmm106 THEN
                       nv_age2rate = xmm106.appinc.
                
                    IF   nv_age2rate > nv_age1rate  THEN
                         nv_drivcod  = nv_drivcod2.
                    ELSE nv_drivcod  = nv_drivcod1.
                END.
            END.    
        END.
    END.
    
    ASSIGN
        nv_drivvar     = " "
        nv_drivvar1    = ""
        nv_drivvar2    = ""
        nv_drivvar1    = "     Driver name person = "
        nv_drivvar2    = STRING(campaign_fil.drino)
        SUBSTRING(nv_drivvar,1,30)  = nv_drivvar1
        SUBSTRING(nv_drivvar,31,30) = nv_drivvar2. 
    
END.
END PROCEDURE.
//---------------
PROCEDURE PdC01ParaUwd132 :
    ASSIGN
        nv_bipvar      = ""
        nv_bipvar1     = ""
        nv_bipvar2     = ""
        nv_bipcod      = "BI1"
        nv_bipvar1     = "     BI per Person = "
        nv_bipvar2     = STRING(campaign_fil.uom1_v)
        SUBSTRING(nv_bipvar,1,30)   = nv_bipvar1
        SUBSTRING(nv_bipvar,31,30)  = nv_bipvar2.
    
    ASSIGN
        nv_biavar      = ""
        nv_biavar1     = ""
        nv_biavar2     = ""
        nv_biacod      = "BI2"
        nv_biavar1     = "     BI per Accident = "
        nv_biavar2     = STRING(campaign_fil.uom2_v)
        SUBSTRING(nv_biavar,1,30)  = nv_biavar1
        SUBSTRING(nv_biavar,31,30) = nv_biavar2.
    
    ASSIGN
        nv_pdavar      = ""
        nv_pdavar1     = ""
        nv_pdavar2     = ""
        nv_pdacod      = "PD"
        nv_pdavar1     = "     PD per Accident = "
        nv_pdavar2     = STRING(campaign_fil.uom5_v)
        SUBSTRING(nv_pdavar,1,30)  = nv_pdavar1
        SUBSTRING(nv_pdavar,31,30) = nv_pdavar2.

    IF campaign_fil.mv411 <> 0 THEN DO:
        ASSIGN
            nv_411var   = ""
            nv_411var1  = ""
            nv_411var2  = ""
            nv_41cod1   = "411"
            nv_411var1  = "     PA Driver = "
            nv_411var2  =  STRING(campaign_fil.mv411)
            SUBSTRING(nv_411var,1,30)    = nv_411var1
            SUBSTRING(nv_411var,31,30)   = nv_411var2.
    END.
    IF campaign_fil.mv412 <> 0 THEN DO:
        ASSIGN
            nv_412var   = ""
            nv_412var1  = ""
            nv_412var2  = ""
            nv_41cod2   = "412"
            nv_412var1  = "     PA Passengers = "
            nv_412var2  =  STRING(campaign_fil.mv412)
            SUBSTRING(nv_412var,1,30)   = nv_412var1
            SUBSTRING(nv_412var,31,30)  = nv_412var2.
    END.
    IF campaign_fil.mv413 <> 0 THEN DO:
        ASSIGN
            nv_413var   = ""
            nv_413var1  = ""
            nv_413var2  = ""
            nv_44cod1   = "413"
            nv_413var1  = "     PA Temp. Driver = "
            nv_413var2  = STRING(campaign_fil.mv44)
            SUBSTRING(nv_413var,1,30)  = nv_413var1
            SUBSTRING(nv_413var,31,30) = nv_413var2.
    END.
    IF campaign_fil.mv414 <> 0 THEN DO:
        ASSIGN
            nv_414var   = ""
            nv_414var1  = ""
            nv_414var2  = ""
            nv_44cod2   = "414"
            nv_414var1  = "     PA Temp. Passengers = "
            nv_414var2  = STRING(campaign_fil.mv44)
            SUBSTRING(nv_414var,1,30)  = nv_414var1
            SUBSTRING(nv_414var,31,30) = nv_414var2.
    END.
    IF campaign_fil.mv42 <> 0 THEN DO:
        ASSIGN
            nv_42var   = ""
            nv_42var1  = ""
            nv_42var2  = ""
            nv_42cod   = "42"
            nv_42var1  = "     Medical Expense = "
            nv_42var2  = STRING(campaign_fil.mv42)
            SUBSTRING(nv_42var,1,30)   = nv_42var1
            SUBSTRING(nv_42var,31,30)  = nv_42var2.
    END.
    IF campaign_fil.mv43 <> 0 THEN DO:
        ASSIGN
            nv_43var   = ""
            nv_43var1  = ""
            nv_43var2  = ""
            nv_43cod   = "43"
            nv_43var1  = "     Airfrieght = "
            nv_43var2  =  STRING(campaign_fil.mv43)
            SUBSTRING(nv_43var,1,30)   = nv_43var1
            SUBSTRING(nv_43var,31,30)  = nv_43var2.
    END.

    /*-- Add A68-0044 --*/
    IF campaign_fil.pdprm31 <> 0 THEN DO:
        ASSIGN
            nv_31var   = ""
            nv_31var1  = ""
            nv_31var2  = ""
            nv_31cod   = "31"
            nv_31var1  = "     Dealer Garage % = "
            nv_31var2  =  STRING(nv_rate31)
            SUBSTRING(nv_31var,1,30)   = nv_31var1
            SUBSTRING(nv_31var,31,30)  = nv_31var2.
    END.
    ELSE DO:
        ASSIGN
            nv_31cod   = ""
            nv_31var1  = ""
            nv_31var2  = ""
            nv_31var   = "".
    END.
    /*-- End Add A68-0044 --*/

    IF campaign_fil.dedod <> 0 THEN DO:
        ASSIGN
            nv_dedod1var      = ""
            nv_dedod1var1     = ""
            nv_dedod1var2     = ""
            nv_dedod1_cod     = "DOD"
            nv_dedod1var1     = "     Deduct OD = "
            nv_dedod1var2     = STRING(campaign_fil.dedod)
            SUBSTRING(nv_dedod1var,1,30)  = nv_dedod1var1
            SUBSTRING(nv_dedod1var,31,30) = nv_dedod1var2.
    END.
    IF campaign_fil.addod <> 0 THEN DO:
        ASSIGN
            nv_dedod2var    = "" 
            nv_dedod2var1   = ""
            nv_dedod2var2   = ""
            nv_dedod2_cod   = "DOD2" 
            nv_dedod2var1   = "     Add Ded.OD = "
            nv_dedod2var2   =  STRING(campaign_fil.addod)
            SUBSTRING(nv_dedod2var,1,30)  = nv_dedod2var1
            SUBSTRING(nv_dedod2var,31,30) = nv_dedod2var2.
    END.
    IF campaign_fil.dedpd <> 0 THEN DO:
        ASSIGN
            nv_dedpdvar    = ""
            nv_dedpdvar1   = ""
            nv_dedpdvar2   = ""
            nv_dedpd_cod   = "DPD"
            nv_dedpdvar1   = "     Deduct PD = "
            nv_dedpdvar2   =  STRING(campaign_fil.dedpd)
            SUBSTRING(nv_dedpdvar,1,30)    = nv_dedpdvar1
            SUBSTRING(nv_dedpdvar,31,30)   = nv_dedpdvar2.
    END.

    ASSIGN
        nv_sivar     = ""
        nv_sivar1    = ""
        nv_sivar2    = ""
        nv_sicod     = "SI"
        nv_sivar1    = "     Own Damage = "
        nv_sivar2    =  STRING(nv_uom6_v)
        SUBSTRING(nv_sivar,1,30)  = nv_sivar1
        SUBSTRING(nv_sivar,31,30) = nv_sivar2.
        /*nv_totsi     = nv_uom6_v.*/

    IF nv_covcod = "5" THEN DO:
        ASSIGN
             nv_totlvar     = ""
             nv_totlvar1    = "" 
             nv_totlvar2    = ""
             nv_totlcod     = "TOTL"
             nv_totlvar1    = "     Total Loss = " 
             nv_totlvar2    =  STRING(nv_uom6_v)
             SUBSTRING(nv_totlvar,1,30)  = nv_totlvar1
             SUBSTRING(nv_totlvar,31,30) = nv_totlvar2.
             /*nv_totsi     = nv_uom6_v.*/
    END.
    
    IF nv_covcod = "9" THEN DO:
        ASSIGN
            nv_sivar     = ""
            nv_sivar1    = ""
            nv_sivar2    = ""
            nv_sicod     = "SI"
            nv_sivar1    = "     Own Damage = "
            nv_sivar2    =  STRING(nv_uom6_v)
            SUBSTRING(nv_sivar,1,30)  = nv_sivar1
            SUBSTRING(nv_sivar,31,30) = nv_sivar2.
            /*nv_totsi     = nv_uom6_v.*/
    END.

    IF nv_covcod = "2.1" OR nv_covcod = "2.2" OR
       nv_covcod = "3.1" OR nv_covcod = "3.2" THEN DO:
    
        IF      nv_covcod = "2.1" THEN nv_sicod3 = "SI21". 
        ELSE IF nv_covcod = "2.2" THEN nv_sicod3 = "SI22".
        ELSE IF nv_covcod = "3.1" THEN nv_sicod3 = "SI31". 
        ELSE IF nv_covcod = "3.2" THEN nv_sicod3 = "SI32".
    
        ASSIGN
            nv_sivar3    = ""
            nv_sivar4    = ""
            nv_sivar5    = ""
            nv_sivar4    = "     Own Damage = "
            nv_sivar5    =  STRING(nv_uom6_v)
            SUBSTRING(nv_sivar3,1,30)  = nv_sivar4
            SUBSTRING(nv_sivar3,31,30) = nv_sivar5 .

    END.

    IF campaign_fil.access = "A" THEN DO:
        ASSIGN  
            nv_othvar     = ""
            nv_othvar1    = ""
            nv_othvar2    = ""
            nv_othcod     = "OTH"
            nv_othvar1    = "     Accessory  = "
            nv_othvar2    =  STRING(campaign_fil.access)
            SUBSTRING(nv_othvar,1,30)  = nv_othvar1
            SUBSTRING(nv_othvar,31,30) = nv_othvar2.
    END.
    ELSE DO:
        ASSIGN 
            nv_othvar     = ""
            nv_othcod     = ""
            nv_othvar1    = ""
            nv_othvar2    = ""
            SUBSTRING(nv_othvar,1,30)  = nv_othvar1
            SUBSTRING(nv_othvar,31,30) = nv_othvar2.
    END.

    IF campaign_fil.covcod = "2.1" OR campaign_fil.covcod = "2.2" OR
       campaign_fil.covcod = "3.1" OR campaign_fil.covcod = "3.2" THEN DO:
        /*nv_prem3 = campaign_fil.baseprm3.*/
    
        IF      campaign_fil.covcod = "2.1" THEN nv_basecod3 = "BA21". 
        ELSE IF campaign_fil.covcod = "2.2" THEN nv_basecod3 = "BA22".
        ELSE IF campaign_fil.covcod = "3.1" THEN nv_basecod3 = "BA31". 
        ELSE IF campaign_fil.covcod = "3.2" THEN nv_basecod3 = "BA32".
    
        ASSIGN
            nv_basevar3 = ""
            nv_basevar4 = ""
            nv_basevar5 = ""
            nv_basevar4 = "     Base Premium3 = "
            nv_basevar5 = STRING(campaign_fil.baseprm3)
            SUBSTRING(nv_basevar3,1,30)   = nv_basevar4
            SUBSTRING(nv_basevar3,31,30)  = nv_basevar5.

        /*IF nv_covcod = "2.1" OR nv_covcod = "3.1" THEN nv_dedod = 2000. */
    END.
    ELSE DO:
        ASSIGN
            /*nv_prem3    = 0*/
            nv_basecod3 = ""
            nv_basevar3 = ""
            nv_basevar4 = ""
            nv_basevar5 = "".
    END.
    
    IF campaign_fil.fletper <> 0 THEN DO:
        ASSIGN
            nv_fletvar     = " "
            nv_fletvar1    = ""
            nv_fletvar2    = ""
            nv_fletvar1    = "     Fleet % = "
            nv_fletvar2    =  STRING(campaign_fil.fletper)
            SUBSTRING(nv_fletvar,1,30)     = nv_fletvar1
            SUBSTRING(nv_fletvar,31,30)    = nv_fletvar2.
    END.
    
    IF campaign_fil.ncbper <> 0 THEN DO:
        ASSIGN
            nv_ncbvar    = ""
            nv_ncbvar1   = ""
            nv_ncbvar2   = ""
            nv_ncbvar1   = "     NCB % = "
            nv_ncbvar2   =  STRING(campaign_fil.ncbper)
            SUBSTRING(nv_ncbvar,1,30)    = nv_ncbvar1
            SUBSTRING(nv_ncbvar,31,30)   = nv_ncbvar2.
    END.
    
    IF campaign_fil.dspcper <> 0 THEN DO:
        ASSIGN
            nv_dsspcvar    = ""
            nv_dsspcvar1   = ""
            nv_dsspcvar2   = ""
            nv_dsspcvar1   = "     Discount Special % = "
            nv_dsspcvar2   =  STRING(campaign_fil.dspcper)
            SUBSTRING(nv_dsspcvar,1,30)    = nv_dsspcvar1
            SUBSTRING(nv_dsspcvar,31,30)   = nv_dsspcvar2.
    END.
    
    IF campaign_fil.stfper <> 0 THEN DO:
        ASSIGN
            nv_stfvar      = ""
            nv_stfvar1     = ""
            nv_stfvar2     = ""
            nv_stfvar1     = "     Discount Staff % = "
            nv_stfvar2     =  STRING(campaign_fil.stfper)
            SUBSTRING(nv_stfvar,1,30)    = nv_stfvar1
            SUBSTRING(nv_stfvar,31,30)   = nv_stfvar2.
    END.
    
    IF campaign_fil.clmper <> 0 THEN DO:
        ASSIGN
            nv_clmvar    = ""
            nv_clmvar1   = ""
            nv_clmvar2   = ""
            nv_clmvar1   = "     Load Claim % = "
            nv_clmvar2   =  STRING(campaign_fil.clmper)
            SUBSTRING(nv_clmvar,1,30)    = nv_clmvar1
            SUBSTRING(nv_clmvar,31,30)   = nv_clmvar2.
    END.
END PROCEDURE.
// ---==============
PROCEDURE PdCGenpmUwd132 :
    
nv_line = 0.

/* COMPULSORY  Premium   */
IF nv_compprm <> 0  THEN DO:
    ASSIGN
        nv_gap     = 0   nv_bencod = ""  n_uom_c = "" 
        nv_prem_c  = 0   nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_compprm  
        nv_prem_c = nv_compprm  
        nv_bencod = nv_compcod  
        nv_benvar = nv_compvar. 

   nv_line = nv_line + 1.
   RUN PdCpmUwd13202.
END.

/* BASE  : Basic Premium   */
ASSIGN 
    nv_gap    = 0   nv_bencod = ""  n_uom_c = "" 
    nv_prem_c = 0   nv_benvar = ""  n_uom_v = 0. 

ASSIGN
    nv_gap    = nv_baseprm
    nv_prem_c = nv_baseprm
    nv_bencod = nv_basecod 
    nv_benvar = nv_basevar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

IF nv_basecod3 <> "" THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
    ASSIGN
        nv_gap    = nv_baseprm3
        nv_prem_c = nv_baseprm3
        nv_bencod = nv_basecod3  
        nv_benvar = nv_basevar3.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Vehicle use */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

ASSIGN
    nv_gap    = nv_useprm   nv_bencod = nv_usecod
    nv_prem_c = nv_useprm   nv_benvar = nv_usevar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

IF nv_usecod3  <> "" THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_useprm   nv_bencod = nv_usecod3
        nv_prem_c = nv_useprm   nv_benvar = nv_usevar3.
        
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Engine */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

ASSIGN
    nv_gap    = nv_engprm   nv_bencod = nv_engcod
    nv_prem_c = nv_engprm   nv_benvar = nv_engvar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.


IF nv_engcod3 <> "" THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""  
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0.  

    ASSIGN
        nv_gap    = nv_engprm3  nv_bencod = nv_engcod3
        nv_prem_c = nv_engprm3  nv_benvar = nv_engvar3.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Driver Age */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

ASSIGN
    nv_gap    = nv_drivprm  nv_bencod = nv_drivcod
    nv_prem_c = nv_drivprm  nv_benvar = nv_drivvar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* Vehicle Year */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = ""     
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0.       
ASSIGN
    nv_gap    = nv_yrprm   nv_bencod = nv_yrcod
    nv_prem_c = nv_yrprm   nv_benvar = nv_yrvar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* Sum Insured */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "D6"    
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = nv_uom6_v.

ASSIGN
    nv_gap    = nv_siprm  nv_bencod = nv_sicod
    nv_prem_c = nv_siprm  nv_benvar = nv_sivar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

IF nv_sicod3 <> "" THEN DO:         
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0.   

    ASSIGN
        nv_gap    = nv_siprm3  nv_bencod = nv_sicod3
        nv_prem_c = nv_siprm3  nv_benvar = nv_sivar3.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Total Loss */
IF nv_totlcod <> "" THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
    ASSIGN
        nv_gap    = nv_totlprm  nv_bencod = nv_totlcod
        nv_prem_c = nv_totlprm  nv_benvar = nv_totlvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/*-- Super Car --*/
IF nv_supecod <> "" THEN DO:
   ASSIGN 
       nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
       nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

   ASSIGN
       nv_gap    = nv_supeprm  nv_bencod = nv_supecod
       nv_prem_c = nv_supeprm  nv_benvar = nv_supevar.

   nv_line = nv_line + 1.
   RUN PdCpmUwd13202.
END.

/* Accessory */
IF nv_othcod <> "" THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
    ASSIGN
        nv_gap    = nv_othprm  nv_bencod = nv_othcod
        nv_prem_c = nv_othprm  nv_benvar = nv_othvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Vehicle Group */
IF nv_grpcod <> "" AND nv_grpcod <> "GRP" THEN DO: 
     ASSIGN 
         nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
         nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

     ASSIGN
         nv_gap    = nv_grprm   nv_bencod = nv_grpcod
         nv_prem_c = nv_grprm   nv_benvar = nv_grpvar.

     nv_line = nv_line + 1.
     RUN PdCpmUwd13202.
END.

/* BI per Person   */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "D1"
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = campaign_fil.uom1_v. 

ASSIGN
    nv_gap    = nv_bipprm   nv_bencod = nv_bipcod
    nv_prem_c = nv_bipprm   nv_benvar = nv_bipvar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* BI per Accident */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "D2" 
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = campaign_fil.uom2_v.  

ASSIGN
    nv_gap    = nv_biaprm  nv_bencod = nv_biacod
    nv_prem_c = nv_biaprm  nv_benvar = nv_biavar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* PD per Accident */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "D5" 
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = campaign_fil.uom5_v. 

ASSIGN
    nv_gap    = nv_pdaprm   nv_bencod = nv_pdacod
    nv_prem_c = nv_pdaprm   nv_benvar = nv_pdavar.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* PA. 411  Driver Person */
ASSIGN 
    nv_gap    = 0  nv_bencod = ""  n_uom_c = "" 
    nv_prem_c = 0  nv_benvar = ""  n_uom_v = campaign_fil.mv411. 

ASSIGN
    nv_gap    = nv_411prm   nv_bencod = nv_41cod1
    nv_prem_c = nv_411prm   nv_benvar = nv_411var.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* PA. 412 : PASSENGER */
ASSIGN 
    nv_gap    = 0   nv_bencod = ""  n_uom_c = ""  
    nv_prem_c = 0   nv_benvar = ""  n_uom_v = campaign_fil.mv412. 

ASSIGN
    nv_gap    = nv_412prm   nv_bencod = nv_41cod2
    nv_prem_c = nv_412prm   nv_benvar = nv_412var.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* PA. 42 : Medical Expense */
ASSIGN 
    nv_gap    = 0   nv_bencod = ""  n_uom_c = ""  
    nv_prem_c = 0   nv_benvar = ""  n_uom_v = campaign_fil.mv42. 

ASSIGN
    nv_gap    = nv_42prm   nv_bencod = nv_42cod
    nv_prem_c = nv_42prm   nv_benvar = nv_42var.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* PA. 43 : Airfrieght */
ASSIGN 
    nv_gap    = 0   nv_bencod = ""  n_uom_c = "" 
    nv_prem_c = 0   nv_benvar = ""  n_uom_v = campaign_fil.mv43. 

ASSIGN
    nv_gap    = nv_43prm  nv_bencod = nv_43cod
    nv_prem_c = nv_43prm  nv_benvar = nv_43var.

nv_line = nv_line + 1.
RUN PdCpmUwd13202.

/* PA. 413 : Person */
IF campaign_fil.mv413 <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = campaign_fil.mv413. 

    ASSIGN
        nv_gap    = nv_413prm  nv_bencod = nv_44cod1
        nv_prem_c = nv_413prm  nv_benvar = nv_413var.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* PA. 414 : Passengers */
IF campaign_fil.mv414 <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = campaign_fil.mv414. 

    ASSIGN
        nv_gap    = nv_414prm  nv_bencod = nv_44cod2
        nv_prem_c = nv_414prm  nv_benvar = nv_414var.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* M.V. 31 : Dealer Garage */
IF nv_pdprm31 <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_gapprm31 nv_bencod = nv_31cod
        nv_prem_c = nv_pdprm31  nv_benvar = nv_31var.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.

END.

/* Deductible Benefit   : Deduct  OD  */
IF nv_covcod = "2.1" OR nv_covcod = "3.1" THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_dedod1_prm  nv_bencod = nv_dedod1_cod 
        nv_prem_c = nv_dedod1_prm  nv_benvar = nv_dedod1var.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.

    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_dedod2_prm  nv_bencod = nv_dedod2_cod
        nv_prem_c = nv_dedod2_prm  nv_benvar = nv_dedod2var.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.
ELSE DO:
    IF nv_dedod1_prm <> 0 THEN DO:
        ASSIGN 
            nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
            nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

        ASSIGN
            nv_gap    = nv_dedod1_prm  nv_bencod = nv_dedod1_cod
            nv_prem_c = nv_dedod1_prm  nv_benvar = nv_dedod1var.
    
        nv_line = nv_line + 1.
        RUN PdCpmUwd13202.
    END.

    IF nv_dedod2_prm <> 0 THEN DO:
        ASSIGN 
            nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
            nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

        ASSIGN
            nv_gap    = nv_dedod2_prm  nv_bencod = nv_dedod2_cod
            nv_prem_c = nv_dedod2_prm  nv_benvar = nv_dedod2var.
    
        nv_line = nv_line + 1.
        RUN PdCpmUwd13202.
    END.
END.

/* Deductible PD */
IF nv_dedpd_prm <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_dedpd_prm  nv_bencod = nv_dedpd_cod
        nv_prem_c = nv_dedpd_prm  nv_benvar = nv_dedpdvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* FLEET */
IF nv_flet  <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_flet   nv_bencod = "FLET"
        nv_prem_c = nv_flet   nv_benvar = nv_fletvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* NCB : Experience Discount */
IF nv_ncb <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_ncb   nv_bencod = "NCB"
        nv_prem_c = nv_ncb   nv_benvar = nv_ncbvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Discount Special Percent */
IF nv_dsspc <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_dsspc   nv_bencod = "DSPC"
        nv_prem_c = nv_dsspc   nv_benvar = nv_dsspcvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Discount Staff */
IF nv_stf_amt <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_stf_amt   nv_bencod = "DSTF"
        nv_prem_c = nv_stf_amt   nv_benvar = nv_stfvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* Load Claim */
IF nv_lodclm <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_lodclm   nv_bencod = "DSTF"
        nv_prem_c = nv_lodclm .

    IF nv_cl_per < 0 THEN DO: 
        IF (nv_cl_per * (-1)) >= 99 THEN DO:
            nv_bencod   = "CL99".
        END.
        ELSE DO:
            nv_bencod   = "CL" + STRING(nv_cl_per * (-1)).
        END.
    END.
    ELSE DO: 
        IF nv_cl_per >= 99 THEN DO:
            nv_bencod   = "CL99".
        END.
        ELSE nv_bencod   = "CL" + STRING(nv_cl_per).
    END.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

/* MOTOR + PA   Premium   */
IF nv_camprem <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""    
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 

    ASSIGN
        nv_gap    = nv_camprem   nv_bencod = nv_campcod
        nv_prem_c = nv_camprem   nv_benvar = nv_campvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

IF nv_attgap <> 0 THEN DO:
    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
    ASSIGN
        nv_gap    = nv_attgap   nv_bencod = "RSI"
        nv_prem_c = nv_attprm   nv_benvar = nv_siattvar.
    
    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
    
    IF nv_fltprm <> 0 THEN DO:
        ASSIGN 
            nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
            nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
        ASSIGN
            nv_gap    = nv_fltgap  nv_bencod = "RFET"
            nv_prem_c = nv_fltprm  nv_benvar = nv_fltattvar.
        
        nv_line = nv_line + 1.
        RUN PdCpmUwd13202.
    END.
    
    IF nv_ncbprm <> 0 THEN DO:
        ASSIGN 
            nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
            nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
        ASSIGN
            nv_gap    = nv_ncbgap  nv_bencod = "RNCB"
            nv_prem_c = nv_ncbprm  nv_benvar = nv_ncbattvar.
        
        nv_line = nv_line + 1.
        RUN PdCpmUwd13202.
    END.
    
    IF nv_dscprm <> 0 THEN DO:
        ASSIGN 
            nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
            nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
        ASSIGN
            nv_gap    = nv_dscgap  nv_bencod = "RDST"
            nv_prem_c = nv_dscprm  nv_benvar = nv_dscattvar.
        
        nv_line = nv_line + 1.
        RUN PdCpmUwd13202.
    END.
    
    IF nv_packatt <> "" THEN DO:
        ASSIGN 
            nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
            nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
        ASSIGN
            nv_bencod = nv_packatt  
            nv_benvar = nv_packattvar.
        
        nv_line = nv_line + 1.
        RUN PdCpmUwd13202.
    END.
END.

IF nv_chargsi <> 0 THEN DO:
    nv_chagvar = "     CHARGER RATE % = " + STRING(nv_chargrate).

    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
    ASSIGN
        nv_gap    = nv_chgnetprm  nv_bencod = "EVCG" 
        nv_prem_c = nv_chgnetprm  nv_benvar = nv_chagvar.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

IF nv_battsi <> 0 THEN DO:
    nv_battvar = "     BATTERY RATE % = " + STRING(nv_battrate).

    ASSIGN 
        nv_gap    = 0  nv_bencod = ""  n_uom_c = ""   
        nv_prem_c = 0  nv_benvar = ""  n_uom_v = 0. 
    
    ASSIGN
        nv_gap    = nv_batnetprm  nv_bencod = "EVBT"
        nv_prem_c = nv_batnetprm  nv_benvar = nv_battvar.

    nv_line = nv_line + 1.
    RUN PdCpmUwd13202.
END.

END PROCEDURE.
//-------------------------
PROCEDURE PdCpmUwd13202 :
    FIND LAST stat.pmuwd132 USE-INDEX pmuwd13201 WHERE 
          stat.pmuwd132.campcd = nv_campcd AND
          stat.pmuwd132.policy = n_policy  AND
          stat.pmuwd132.itemno = nv_line   NO-ERROR NO-WAIT.
IF NOT AVAIL stat.pmuwd132 THEN DO:
    CREATE stat.pmuwd132.
    ASSIGN
        pmuwd132.policy = n_policy
        pmuwd132.campcd = nv_campcd
        pmuwd132.rencnt = n_rencnt 
        pmuwd132.endcnt = n_endcnt 
        pmuwd132.riskno = nv_riskno
        pmuwd132.itemno = nv_line
        pmuwd132.bencod = nv_bencod
        pmuwd132.benvar = nv_benvar
        pmuwd132.gap_ae = NO  
        pmuwd132.gap_c  = nv_gap
        pmuwd132.pd_aep = "E"
        pmuwd132.prem_c = nv_prem_c
        pmuwd132.uom_c  = n_uom_c
        pmuwd132.uom_v  = n_uom_v
        pmuwd132.trndat = TODAY
        pmuwd132.trntim = STRING(TIME,"HH:MM:SS")
        pmuwd132.usrid  = USERID(LDBNAME(1))
        pmuwd132.effdat = n_comdat
        pmuwd132.expdat = n_comdat + 365
        pmuwd132.stcd   = nv_status
        pmuwd132.txt1   = string(nv_batchyr,"9999")
        pmuwd132.txt2   = nv_batchno .  
END.

RELEASE stat.pmuwd132.
END PROCEDURE.

