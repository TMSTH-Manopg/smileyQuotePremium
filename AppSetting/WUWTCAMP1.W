&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 
  Description: 
  Input Parameters:<none>
  Output Parameters:<none>
  Author: 
  Program id: WUWTCAMP2.W
 Created: Thitirat M. 
  Date: 12/01/2022 
 Assign: A65-0016
รายละเอียดโปรแกรม :โปรแกรม จะUP campaign จาก stat.campaign_fil ลง ctxstat.motcamp และ
จาก stat.pmuwd132 ลง ctxstat.pmuwd132 จากนั้น จะ Transfer ข้อมูล Campaign ไปที่ข้อ Motor / Campaign ระบบ Safe Smart (UAT)  
 -09/03/2023 Thitirat M.  เพิ่ม PDSetCampaign  
 -16/06/2023 Thitirat M.  ระบุว่าเป็นแคมเปญกลางหรือพิเสษ และเก็บค่าลง poltyp_fil
  เป็นการAuto Set parameter Campaig แทนการเข้าไปSet Manual จากข้อPackage Type Maintenance [WctxPr79.w] ที่Motor Citrix 
 -20/06/2023 Thitirat M. เปลี่ยนการ For ข้อมูลที่ Procedures:PDSetCampaign  
 -29/06/2023 Thitirat M. เพิ่มการโหลดตอนProcess   
 -10/07/2023 Thitirat M. เช็คเงื่อนไข กรณี Web Service ERROR ตอนยิงKeyid ไป Safe Smart ให้แจ้งเตือน
------
Modify By  : Thitirat M. Date 30/08/2023                                 
Assign No. : A65-0016  - แก้ไข Output File 
-------------------------------------------------------------------------
Modify By : Porntiwa T.  A65-0232  14/11/2023
          : Add new ทุนประกันภัยประเภท 2
          : Add Cover Date
------
Modify By  : Thitirat M. Date 05/02/2025                                 
Assign No. : A68-0037  - ปิด Message Box และแก้ไข Path Program      
------------------------------------------------------------------------
Mofify By  : Lukkana M. Date 24/03/2025            
Assign No. : A68-0057  เพิ่ม transfer all policy master                
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

 USING System.Net.Http.*. 
 USING System.Environment.


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/**/
DEFINE TEMP-TABLE TempFilename NO-UNDO
FIELD nv_Filename AS CHARACTER.

/*TEST*/
DEF  VAR n_User     AS CHAR INIT "pdmgr0" .
DEF  VAR n_Passwd   AS CHAR INIT "pdmgr0" .                                 
DEF  VAR nv_pwd1    AS CHAR INIT "pdmgr0" .
DEF  VAR nv_usrid1  AS CHAR INIT "pdmgr0" . 


DEF VAR n_cntcod    AS INT FORMAT ">>>,>>>,>>9" INIT 0. 
DEF VAR n_checkerr  AS LOG. 
DEF VAR nv_output   AS CHAR FORMAT "X(20)" .
DEF VAR nv_keyid    AS CHAR.

/*Thitirat M. A65-0016 09/03/2023*/
DEF  VAR n_camcod  AS CHAR INIT "" . 
DEF  VAR n_camnam  AS CHAR INIT "" . 
/*Thitirat M. A65-0016 09/03/2023*/

DEF VAR nv_datetoday AS CHAR.
 DEF VAR n_b1 AS CHAR.
 DEF VAR n_b2 AS CHAR.
 DEF VAR n_b3 AS CHAR.
 DEF VAR n_b4 AS CHAR.
 DEF VAR n_b5 AS CHAR.

DEF VAR n_cnt      AS INTEGER INIT 0 NO-UNDO.   
DEF VAR n_cntkeyid AS INTEGER INIT 0 NO-UNDO.   
DEF VAR n_num      AS INTEGER INIT 0 NO-UNDO. 
DEF VAR nv_Count   AS INTEGER INIT 0 NO-UNDO.
DEF VAR nv_ICount  AS INTEGER INIT 0 NO-UNDO.

DEF VAR nv_cam1    AS CHAR.
DEF VAR nv_cam2    AS CHAR.
DEF VAR nv_cam3    AS CHAR.
DEF VAR nv_campaig    AS CHAR.

/*Thitirat M. A65-0016 16/06/2023*/
DEF VAR nv_campaigntype AS CHAR.
DEF VAR n_effectivedate AS CHAR INIT "" . 
DEF VAR n_expirydate    AS CHAR INIT "" .
/*Thitirat M. A65-0016 16/06/2023*/

DEF VAR ERR_Service     AS CHAR INIT "".  /* Thitirat M. 10/07/2023 */

DEF VAR nv_grouppolicy  AS CHAR INIT "". /*Lukkana M. 24/03/2025 A68-0057*/
DEF VAR n_cntcod-2      AS INTE INIT 0 . /*Lukkana M. 24/03/2025 A68-0057*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fr_main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 fi_camp fi_output ra_campaigntype ~
buok nv_clear buexit budel ra_grouppolicy nv_trans_safe fi_cntcod ~
fi_process fi_cntcod-2 
&Scoped-Define DISPLAYED-OBJECTS fi_camp fi_output ra_campaigntype ~
ra_grouppolicy fi_cntcod fi_process fi_cntcod-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON budel 
     LABEL "DEL" 
     SIZE 9 BY 1.19
     BGCOLOR 12 FONT 2.

DEFINE BUTTON buexit 
     LABEL "EXIT" 
     SIZE 9 BY 1.19
     BGCOLOR 64 FONT 2.

DEFINE BUTTON buok 
     LABEL "OK" 
     SIZE 9 BY 1.19
     BGCOLOR 3 FONT 2.

DEFINE BUTTON nv_clear 
     LABEL "Clear" 
     SIZE 9 BY 1.14
     BGCOLOR 2 FONT 2.

DEFINE BUTTON nv_trans_safe 
     LABEL "Transfer Safe Smart" 
     SIZE 26.5 BY 1.14
     BGCOLOR 10 FONT 2.

DEFINE VARIABLE fi_camp AS CHARACTER FORMAT "X(50)":U 
     VIEW-AS FILL-IN 
     SIZE 36 BY 1
     FONT 2 NO-UNDO.

DEFINE VARIABLE fi_cntcod AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 8 BY .86
     BGCOLOR 8 FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE fi_cntcod-2 AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 8 BY .86
     BGCOLOR 8 FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE fi_output AS CHARACTER FORMAT "X(90)":U 
     VIEW-AS FILL-IN 
     SIZE 45.5 BY 1
     FONT 2 NO-UNDO.

DEFINE VARIABLE fi_process AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 54.5 BY 1 NO-UNDO.

DEFINE VARIABLE ra_campaigntype AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "แคมเปญกลาง", 1,
"แคมเปญพิเศษ", 2
     SIZE 31.17 BY .81
     FGCOLOR 1 FONT 6 NO-UNDO.

DEFINE VARIABLE ra_grouppolicy AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Transfer All Policy Master  ", 1,
"Group Policy Master (Smiley)", 2
     SIZE 58.5 BY .81
     FGCOLOR 1 FONT 6 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 69.17 BY 1.43
     BGCOLOR 3 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fr_main
     fi_camp AT ROW 2.86 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     fi_output AT ROW 4.05 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     ra_campaigntype AT ROW 5.29 COL 20.33 NO-LABEL WIDGET-ID 188
     buok AT ROW 8.86 COL 3.5 WIDGET-ID 4
     nv_clear AT ROW 8.86 COL 14.5 WIDGET-ID 24
     buexit AT ROW 8.86 COL 26 WIDGET-ID 6
     budel AT ROW 8.86 COL 56 WIDGET-ID 18
     ra_grouppolicy AT ROW 10.76 COL 3 NO-LABEL WIDGET-ID 200
     nv_trans_safe AT ROW 13.14 COL 3.5 WIDGET-ID 26
     fi_cntcod AT ROW 6.71 COL 32 RIGHT-ALIGNED NO-LABEL WIDGET-ID 20
     fi_process AT ROW 7.67 COL 1.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     fi_cntcod-2 AT ROW 11.95 COL 54.17 RIGHT-ALIGNED NO-LABEL WIDGET-ID 204
     "จำนวน Record ที่ Transfer Safe Smart (Group policy):" VIEW-AS TEXT
          SIZE 42.5 BY 1.19 AT ROW 11.71 COL 4 WIDGET-ID 206
          FGCOLOR 0 
     "จำนวน Record ที่นำเข้า :" VIEW-AS TEXT
          SIZE 21 BY 1.19 AT ROW 6.48 COL 3.5 WIDGET-ID 22
          FGCOLOR 0 
     "Output File:" VIEW-AS TEXT
          SIZE 16.5 BY 1 AT ROW 4.05 COL 5.33 WIDGET-ID 16
          FONT 2
     "Campaign No.:" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.86 COL 4.17 WIDGET-ID 8
          FONT 2
     "Transfer Campaign To Safe Smart [Motor / Campaign]  (UAT)" VIEW-AS TEXT
          SIZE 59 BY .91 AT ROW 1.24 COL 5.17 WIDGET-ID 36
          BGCOLOR 3 FGCOLOR 7 FONT 6
     " V.2.0" VIEW-AS TEXT
          SIZE 6 BY 1.19 AT ROW 2.38 COL 64 WIDGET-ID 198
          BGCOLOR 1 FGCOLOR 7 
     RECT-1 AT ROW 1 COL 1 WIDGET-ID 192
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 69.17 BY 14.14 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "<insert window title>"
         HEIGHT             = 14.14
         WIDTH              = 69.17
         MAX-HEIGHT         = 45.86
         MAX-WIDTH          = 213.33
         VIRTUAL-HEIGHT     = 45.86
         VIRTUAL-WIDTH      = 213.33
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME fr_main
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN fi_cntcod IN FRAME fr_main
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi_cntcod-2 IN FRAME fr_main
   ALIGN-R                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* <insert window title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* <insert window title> */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME budel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL budel C-Win
ON CHOOSE OF budel IN FRAME fr_main /* DEL */
DO:

  IF fi_camp = "" THEN DO:
     MESSAGE "Campaign No. เป็นค่าว่าง !!! " VIEW-AS ALERT-BOX.
  END.
  ELSE DO:

    ASSIGN
    n_cntcod   = 0.
    DISP n_cntcod @ fi_cntcod WITH FRAME fr_main . 

     FIND FIRST ctxstat.motcamp USE-INDEX motcamp02 WHERE /*Thitirat M. A65-0016 01/02/2023*/
                ctxstat.motcamp.camcod = fi_camp  NO-ERROR.
     IF NOT AVAIL ctxstat.motcamp THEN DO:

        MESSAGE "ไม่พบ Campaign No:" + fi_camp + " กรุณาตรวจสอบอีกครั้ง" VIEW-AS ALERT-BOX.

     END. /*IF AVAIL ctxstat.motcamp THEN DO:*/
     ELSE DO:


          MESSAGE "Delete Campaign No :" fi_camp "Confirm ?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO    
          TITLE "Delete Campaign" UPDATE lADD AS LOGICAL.  
          CASE lADD:    
                  WHEN TRUE THEN DO: /*  Yes */
          
                        FOR EACH ctxstat.motcamp WHERE ctxstat.motcamp.camcod = fi_camp :
                        
                            DELETE ctxstat.motcamp.
                          
                        END.
          
                        FOR EACH ctxstat.pmuwd132 USE-INDEX pmuwd13201 WHERE ctxstat.pmuwd132.campcd = fi_camp .  /* DELETE ctxstat.pmuwd132 เพื่อ CREATE ใหม่*/
          
                          DELETE ctxstat.pmuwd132.
                       
                        END.

                        /*Thitirat M. A65-0016 11/08/2023 
                        FOR EACH ctxstat.poltyp_fil USE-INDEX poltyp02 WHERE ctxstat.poltyp_fil.poldes = fi_camp .
                         DELETE ctxstat.poltyp_fil.
                        END. /*Thitirat M. A65-0016 09/03/2023 Delete Campaign ที่ข้อPackage Type Maintenance [WctxPr79.w] ที่Motor Citrix */
                        Thitirat M. A65-0016 11/08/2023 */

                       
                        MESSAGE "Delete Complete" SKIP
                        "- ที่ ctxstat.motcamp "  SKIP
                        "- ที่ ctxstat.pmuwd132 " 
                /* SKIP "- ที่ ctxstat.poltyp_fil ระบบ Motor Citrix ข้อ Package Type Maintenance"   Thitirat M. A65-0016 11/08/2023 */
                        VIEW-AS ALERT-BOX. 
          
                  END.  
                  WHEN FALSE THEN DO: /* No  Action */
          
                  END.   
          END CASE.


     END.          
  END.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buexit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buexit C-Win
ON CHOOSE OF buexit IN FRAME fr_main /* EXIT */
DO:
  APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buok C-Win
ON CHOOSE OF buok IN FRAME fr_main /* OK */
DO:

  nv_campaig = ''.

  IF fi_camp <> "" THEN DO:

       nv_campaig   = REPLACE(fi_camp,"/","").  
       nv_campaig   = REPLACE(nv_campaig,"-","").  
       nv_campaig   = REPLACE(nv_campaig,"+","").  
       nv_campaig   = REPLACE(nv_campaig,"_","").  

      RUN PDTransMotCamp. 

      IF n_checkerr = YES THEN DO:

            DISP fi_process
            WITH COLOR black/white NO-LABEL TITLE "Process data......"
            CENTERED FRAME fr_process2 VIEW-AS DIALOG-BOX.  /*Thitirat M. 29/06/2023*/

          RUN PDExportCamp.

            DISP fi_process
            WITH COLOR black/white NO-LABEL TITLE "Process data......"
            CENTERED FRAME fr_process3 VIEW-AS DIALOG-BOX.  /*Thitirat M. 29/06/2023*/

          RUN PDpmuwd132.
          /*เช็คว่า tranผ่านแล้ว ค่อย Tran ขึ้น Wsvint แต่ ให้ถามก่อน ว่า ต้องการ Tran เลยไหม*/

          MESSAGE "Process Complete" VIEW-AS ALERT-BOX.

          ENABLE ALL WITH FRAME fr_main.                           /*Thitirat M. A65-0016 */
          DISABLE buok fi_camp ra_campaigntype WITH FRAME fr_main. /*Thitirat M. A65-0016 */

      END.


  END.
  ELSE DO:
      MESSAGE "Campaign No. เป็นค่าว่าง !!!"
      VIEW-AS ALERT-BOX WARNING.
      APPLY "ENTRY" TO fi_camp IN FRAME fr_main.
      RETURN NO-APPLY.
  END.

  
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi_camp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi_camp C-Win
ON LEAVE OF fi_camp IN FRAME fr_main
DO:
  fi_camp = INPUT fi_camp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi_output
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi_output C-Win
ON LEAVE OF fi_output IN FRAME fr_main
DO:
 
  fi_output = INPUT fi_output .

  DISP fi_output WITH FRAM fr_main .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME nv_clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL nv_clear C-Win
ON CHOOSE OF nv_clear IN FRAME fr_main /* Clear */
DO:

  ASSIGN 
      fi_camp         =  ""
    /*fi_output       = "D:\TrnCamp" + STRING(TODAY,"99999999") + ".csv"         Thitirat M. 30/08/2023*/ 
      fi_output       = "D:\temp\TrnCamp" + STRING(TODAY,"99999999") + ".csv"  /*Thitirat M. 30/08/2023*/
      n_cntcod        = 0
      fi_process      =  ""
      n_checkerr      = YES
      n_camcod        = ""  /*Thitirat M. A65-0016 09/03/2023*/
      n_camnam        = ""  /*Thitirat M. A65-0016 09/03/2023*/
      ra_campaigntype = 1   /*Thitirat M. A65-0016 16/06/2023*/
      nv_campaigntype = "C" /*Thitirat M. A65-0016 16/06/2023*/
      . 

      
  DISP fi_camp fi_output ra_campaigntype fi_process n_cntcod @ fi_cntcod WITH FRAME fr_main . 

  ENABLE ALL WITH FRAME fr_main.             
  DISABLE nv_trans_safe  WITH FRAME fr_main. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME nv_trans_safe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL nv_trans_safe C-Win
ON CHOOSE OF nv_trans_safe IN FRAME fr_main /* Transfer Safe Smart */
DO:

      

      MESSAGE "ต้องการ Transfer Campaign No :" fi_camp "ขึ้น Safe Smart หรือไม่? " SKIP
              "(กรุณา ตรวจสอบ จำนวน Record ที่นำเข้า ว่าตรงกันหรือไม่ก่อนการยืนยัน)" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO /*Thitirat M. A65-0016*/
      TITLE "Transfer Campaign" UPDATE lADD AS LOGICAL.  
      CASE lADD:    
              WHEN TRUE THEN DO: /*  Yes */

                    /*Lukkana M. 24/03/2025 A68-0057*/
                    IF nv_grouppolicy = 'All' THEN DO:
                        
                        RUN PDTransWsvint. 
                    END.
                    ELSE DO:
                        
                        RUN PDTransWsvint3.
                    END.
                    /*Lukkana M. 24/03/2025 A68-0057*/
                    
                    RUN PDSetCampaign .  /*เพิ่มAuto Set parameter Campaig Thitirat M. A65-0016 09/03/2023 */ 
                    
                    
                    /*MESSAGE "nv_datetoday :"nv_datetoday "//n_num:" n_num "//n_cntkeyid:" n_cntkeyid VIEW-AS ALERT-BOX.*/
                    
                    DISP n_cntcod-2 @ fi_cntcod-2  WITH FRAME fr_main. /*Lukkana M. 04/04/2025*/

                    nv_ICount  = n_cntkeyid . /*จำนวน keyid ที่จะยิง*/
                    nv_Count = 0. 
                    ERR_Service = "" . /*Thitirat M. 10/07/2023*/
                    
                    DO WHILE nv_Count < nv_ICount : /* วน ยิง key id ขึ้นไป Up safe Smart*/
                    
                        nv_Count = nv_Count + 1.
                      /*nv_keyid = fi_camp + nv_datetoday + STRING(nv_Count). /* today + 1,2,3,4.... */ Lukkana M 30/03/2023*/
                        nv_keyid =  nv_campaig + nv_datetoday + string(nv_Count)   .
                      
                      /*  MESSAGE "nv_Count :" nv_Count "// nv_keyid :" nv_keyid VIEW-AS ALERT-BOX.*/

                        DISP nv_campaig ":" nv_keyid  FORMAT "x(30)" 
                        WITH COLOR black/white NO-LABEL TITLE "Process data......"
                        CENTERED FRAME fr_process4 VIEW-AS DIALOG-BOX.  /*Thitirat M. 29/06/2023*/

                        RUN PDTransSafeSmart . 
                    
                    END.
                    IF ERR_Service <> "error" THEN DO:   /* Thitirat M. 10/07/2023 */

                      MESSAGE "Pocess Campaign On Safe Smart เรียบร้อย" SKIP
                              "รบกวนตรวจสอบว่า Transfer ครบหรือไม่  " SKIP 
                            /*"ที่=> D:\PostCamp_log.TXT"       Thitirat M. 30/08/2023*/
                            /*"ที่=> D:\temp\PostCamp_log.TXT"  Thitirat M. 30/08/2023*//*A68-0037*/
                              "โดยดูจากLogFile ที่=> PostCamp_log.TXT"  /*A68-0037*/
                              VIEW-AS ALERT-BOX.
                    END.
                    ELSE DO: /*A68-0037*/
                      MESSAGE "Pocess Campaign On Safe Smart เรียบร้อย"   SKIP                           
                              "รบกวนตรวจสอบว่า Transfer ครบหรือไม่ " SKIP  
                              " " SKIP
                              "(เนื่องจากระหว่างProcess เกิด Web Service ERROR) " SKIP   
                              "โดยดูจากLogFileที่=> PostCamp_log.TXT และ log_eAnyError_PostCamp.TXT"          
                              VIEW-AS ALERT-BOX. 
                    END.    


                    
              END.  
              WHEN FALSE THEN DO: /* No Action */

              END.   
      END CASE.
 


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ra_campaigntype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ra_campaigntype C-Win
ON VALUE-CHANGED OF ra_campaigntype IN FRAME fr_main
DO:
  ra_campaigntype = INPUT ra_campaigntype.
           
    IF ra_campaigntype = 1 THEN DO: /*แคมเปญกลาง*/
       nv_campaigntype = "C" .
 
    END.
    ELSE IF ra_campaigntype = 2 THEN DO: /*แคมเปญกลางพิเศษ*/
            nv_campaigntype = "S" .

    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ra_grouppolicy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ra_grouppolicy C-Win
ON VALUE-CHANGED OF ra_grouppolicy IN FRAME fr_main
DO:
  /*Lukkana M. 24/03/2025 A68-0057*/
  ra_grouppolicy = INPUT ra_grouppolicy.
           
    IF ra_grouppolicy = 1 THEN DO: /*แคมเปญกลาง*/
       nv_grouppolicy = "All" .
 
    END.
    ELSE IF ra_grouppolicy = 2 THEN DO: /*แคมเปญกลางพิเศษ*/
            nv_grouppolicy = "Group" .

    END.
    /*Lukkana M. 24/03/2025 A68-0057*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  SESSION:DATA-ENTRY-RETURN = YES.  /*Thitirat M. A65-0016 16/06/2023*/ 

 ASSIGN
/*fi_output       = "D:\TrnCamp" + STRING(TODAY,"99999999") + ".csv"         Thitirat M. 30/08/2023*/
  fi_output       = "D:\temp\TrnCamp" + STRING(TODAY,"99999999") + ".csv"  /*Thitirat M. 30/08/2023*/

  /*Thitirat M. A65-0016 16/06/2023*/
  ra_campaigntype = 1
  nv_campaigntype = "C" 
   
  /*Thitirat M. A65-0016 16/06/2023*/
  /*Lukkana M. 09/04/2025 A68-0057*/
  ra_grouppolicy = 1     
  nv_grouppolicy = 'All'.
  /*Lukkana M. 09/04/2025 A68-0057*/
 


  DISP fi_output  WITH FRAME fr_main.
  DISABLE ALL EXCEPT fi_camp fi_output ra_campaigntype  buok nv_clear buexit budel  WITH FRAME fr_main. /*Thitirat M. A65-0016*/

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY fi_camp fi_output ra_campaigntype ra_grouppolicy fi_cntcod fi_process 
          fi_cntcod-2 
      WITH FRAME fr_main IN WINDOW C-Win.
  ENABLE RECT-1 fi_camp fi_output ra_campaigntype buok nv_clear buexit budel 
         ra_grouppolicy nv_trans_safe fi_cntcod fi_process fi_cntcod-2 
      WITH FRAME fr_main IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-fr_main}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDExportCamp C-Win 
PROCEDURE PDExportCamp :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF fi_output <> "" THEN DO:
    RUN PDHeaderCamp.

    OUTPUT TO VALUE(fi_output) APPEND.
    FOR EACH ctxstat.motcamp WHERE motcamp.camcod = fi_camp  /* AND upddate = TODAY*/ NO-LOCK:
        PUT trim(motcamp.camcod) FORMAT "x(15)"      "|" .       
        PUT trim(motcamp.camnam) FORMAT "x(60)"      "|" .       
        PUT motcamp.paccod       "|" .       
        PUT motcamp.class        "|" .       
        PUT motcamp.sclass       "|" .       
        PUT motcamp.covcod       "|" .       
        PUT motcamp.vehgrp       "|" .       
        PUT motcamp.vehuse       "|" .       
        PUT motcamp.garage       "|" .       
        PUT motcamp.mincst       "|" .       
        PUT motcamp.maxcst       "|" .       
        PUT motcamp.makeyr       "|" .       
        PUT motcamp.makedes      "|" .       
        PUT motcamp.modeldes     "|" .       
        PUT motcamp.bodydes      "|" .       
        PUT motcamp.doorno       "|" .       
        PUT motcamp.engine       "|" .       
        PUT motcamp.seats        "|" .       
        PUT motcamp.tons         "|" .       
        PUT motcamp.simin        "|" .       
        PUT motcamp.simax        "|" .       
        PUT motcamp.access       "|" .       
        PUT motcamp.accsi        "|" .       
        PUT motcamp.accprm       "|" .       
        PUT motcamp.drivnam      "|" .       
        PUT motcamp.drivno       "|" .       
        PUT motcamp.drivage1min  "|" .       
        PUT motcamp.drivage1max  "|" .       
        PUT motcamp.drivage2min  "|" .       
        PUT motcamp.drivage2max  "|" .       
        PUT motcamp.drivprm      "|" .       
        PUT motcamp.baseprm      "|" .       
        PUT motcamp.baseprm3     "|" .       
        PUT motcamp.dedod        "|" .       
        PUT motcamp.dedad        "|" .       
        PUT motcamp.dedpd        "|" .       
        PUT motcamp.dedprm       "|" .       
        PUT motcamp.dadprm       "|" .       
        PUT motcamp.dpdprm       "|" .       
        PUT motcamp.fletper      "|" .       
        PUT motcamp.ncbyrs       "|" .       
        PUT motcamp.ncbper       "|" .       
        PUT motcamp.dspcper      "|" .       
        PUT motcamp.dspcamt      "|" .       
        PUT motcamp.stfper       "|" .       
        PUT motcamp.stfamt       "|" .       
        PUT motcamp.clmper       "|" .       
        PUT motcamp.polmst       "|" .       
        PUT motcamp.cctv         "|" .       
        PUT motcamp.cctvcd       "|" .       
        PUT motcamp.cctvper      "|" .       
        PUT motcamp.cctvamt      "|" .       
        PUT motcamp.cctvdes      "|" .       
        PUT motcamp.promcod      "|" .       
        PUT motcamp.promnam      "|" .       
        PUT motcamp.plancod      "|" .       
        PUT motcamp.planno       "|" .       
        PUT motcamp.plannam      "|" .       
        PUT motcamp.effdat       "|" .       
        PUT motcamp.expdat       "|" .       
        PUT motcamp.entdat       "|" .       
        PUT motcamp.enttim       "|" .       
        PUT motcamp.usrid        "|" .       
        PUT motcamp.remark       "|" .       
        PUT motcamp.spflag       "|" .       
        PUT motcamp.TransDate    "|" .       
        PUT motcamp.TransTime    "|" .       
        PUT motcamp.TransId      "|" .       
        PUT motcamp.TransFlag    "|" .       
        PUT motcamp.ctxt1        "|" .       
        PUT motcamp.ctxt2        "|" .       
        PUT motcamp.ctxt3        "|" .       
        PUT motcamp.cdate1       "|" .       
        PUT motcamp.cdate2       "|" .       
        PUT motcamp.cdate3       "|" .       
        PUT motcamp.cdec1        "|" .       
        PUT motcamp.cdec2        "|" .       
        PUT motcamp.cdec3        "|" .       
        PUT motcamp.clog1        "|" .       
        PUT motcamp.clog2        "|" .       
        PUT motcamp.tpbips       "|" .       
        PUT motcamp.tpbiacc      "|" .       
        PUT motcamp.tppdacc      "|" .       
        PUT motcamp.DeductPd     "|" .       
        PUT motcamp.SumInsOd     "|" .       
        PUT motcamp.DeductOd     "|" .       
        PUT motcamp.SumInsFt     "|" .       
        PUT motcamp.PALifeDriv   "|" .       
        PUT motcamp.PALifePass   "|" .       
        PUT motcamp.Seat411      "|" .       
        PUT motcamp.Seat412      "|" .       
        PUT motcamp.PATempDriv   "|" .       
        PUT motcamp.PATempPass   "|" .       
        PUT motcamp.Seat413      "|" .       
        PUT motcamp.Seat414      "|" .       
        PUT motcamp.MedicalExp   "|" .       
        PUT motcamp.BailBond     "|" .       
        PUT motcamp.Premium1     "|" .       
        PUT motcamp.Premium2     "|" .       
        PUT motcamp.Premium3     "|" .       
        PUT motcamp.AddPrem      "|" .       
        PUT motcamp.DedPrem      "|" .       
        PUT motcamp.FleetPrem    "|" .       
        PUT motcamp.NcbPrem      "|" .       
        PUT motcamp.DiscPrem     "|" .       
        PUT motcamp.TotDiscPrem  "|" .       
        PUT motcamp.ClaimPrem    "|" .       
        PUT motcamp.NetPrem      "|" .       
        PUT motcamp.Stamp        "|" .       
        PUT motcamp.Tax          "|" .       
        PUT motcamp.GrossPrem    "|" .       
        PUT motcamp.AttachText   "|" .       
        PUT motcamp.UseText      "|" .       
        PUT motcamp.OtherText    "|" .       
        PUT motcamp.DayCover     "|" .       
        PUT motcamp.TPCover1     "|" .       
        PUT motcamp.TPCover2     "|" .       
        PUT motcamp.TPCover3     "|" .       
        PUT motcamp.DeductOd1    "|" .       
        PUT motcamp.DeductOd2    "|" .       
        PUT motcamp.DeductPd1    "|" .       
        PUT motcamp.DeductPd2    "|" .       
        PUT motcamp.SumIns1      "|" .       
        PUT motcamp.SumIns2      "|" .       
        PUT motcamp.SumIns3      "|" .       
        PUT motcamp.PACover1     "|" .       
        PUT motcamp.PACover2     "|" .       
        PUT motcamp.PACover3     "|" .       
        PUT motcamp.PACover4     "|" .       
        PUT motcamp.PACover5     "|" .       
        PUT motcamp.Premium4     "|" .       
        PUT motcamp.Premium5     "|" .       
        PUT motcamp.Premium6     "|" .       
        PUT motcamp.OthDisc1     "|" .       
        PUT motcamp.OthDisc2     "|" .       
        PUT motcamp.OthDisc3     "|" .       
        PUT motcamp.OthSurc1     "|" .       
        PUT motcamp.OthSurc2     "|" .       
        PUT motcamp.OthText1     "|" .       
        PUT motcamp.OthText2     "|" .       
        PUT motcamp.OthText3     "|" .       
        PUT motcamp.StatusFlg1   "|" .       
        PUT motcamp.StatusFlg2   "|" .       
        PUT motcamp.UpdDate      "|" .       
        PUT motcamp.UpdTime      "|" .       
        PUT motcamp.UpdUsrID     "|" .       
        PUT motcamp.UpdFlag      "|" .       
        PUT motcamp.UseEn        "|" .       
        PUT motcamp.UseTh        "|" .       
        PUT motcamp.AttachEn     "|" .       
        PUT motcamp.AttachTh     "|" .       
        PUT motcamp.codedet      "|" .       
        PUT motcamp.codedes      "|" .       
        PUT motcamp.modelflg     "|" SKIP.
    END.
    OUTPUT CLOSE.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDHeaderCamp C-Win 
PROCEDURE PDHeaderCamp :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

OUTPUT TO VALUE(fi_output) APPEND.
PUT "camcod       |" .       
PUT "camnam       |" .       
PUT "paccod       |" .       
PUT "class        |" .       
PUT "sclass       |" .       
PUT "covcod       |" .       
PUT "vehgrp       |" .       
PUT "vehuse       |" .       
PUT "garage       |" .       
PUT "mincst       |" .       
PUT "maxcst       |" .       
PUT "makeyr       |" .       
PUT "makedes      |" .       
PUT "modeldes     |" .       
PUT "bodydes      |" .       
PUT "doorno       |" .       
PUT "engine       |" .       
PUT "seats        |" .       
PUT "tons         |" .       
PUT "simin        |" .       
PUT "simax        |" .       
PUT "access       |" .       
PUT "accsi        |" .       
PUT "accprm       |" .       
PUT "drivnam      |" .       
PUT "drivno       |" .       
PUT "drivage1min  |" .       
PUT "drivage1max  |" .       
PUT "drivage2min  |" .       
PUT "drivage2max  |" .       
PUT "drivprm      |" .       
PUT "baseprm      |" .       
PUT "baseprm3     |" .       
PUT "dedod        |" .       
PUT "dedad        |" .       
PUT "dedpd        |" .       
PUT "dedprm       |" .       
PUT "dadprm       |" .       
PUT "dpdprm       |" .       
PUT "fletper      |" .       
PUT "ncbyrs       |" .       
PUT "ncbper       |" .       
PUT "dspcper      |" .       
PUT "dspcamt      |" .       
PUT "stfper       |" .       
PUT "stfamt       |" .       
PUT "clmper       |" .       
PUT "polmst       |" .       
PUT "cctv         |" .       
PUT "cctvcd       |" .       
PUT "cctvper      |" .       
PUT "cctvamt      |" .       
PUT "cctvdes      |" .       
PUT "promcod      |" .       
PUT "promnam      |" .       
PUT "plancod      |" .       
PUT "planno       |" .       
PUT "plannam      |" .       
PUT "effdat       |" .       
PUT "expdat       |" .       
PUT "entdat       |" .       
PUT "enttim       |" .       
PUT "usrid        |" .       
PUT "remark       |" .       
PUT "spflag       |" .       
PUT "TransDate    |" .       
PUT "TransTime    |" .       
PUT "TransId      |" .       
PUT "TransFlag    |" .       
PUT "ctxt1        |" .       
PUT "ctxt2        |" .       
PUT "ctxt3        |" .       
PUT "cdate1       |" .       
PUT "cdate2       |" .       
PUT "cdate3       |" .       
PUT "cdec1        |" .       
PUT "cdec2        |" .       
PUT "cdec3        |" .       
PUT "clog1        |" .       
PUT "clog2        |" .       
PUT "tpbips       |" .       
PUT "tpbiacc      |" .       
PUT "tppdacc      |" .       
PUT "DeductPd     |" .       
PUT "SumInsOd     |" .       
PUT "DeductOd     |" .       
PUT "SumInsFt     |" .       
PUT "PALifeDriv   |" .       
PUT "PALifePass   |" .       
PUT "Seat411      |" .       
PUT "Seat412      |" .       
PUT "PATempDriv   |" .       
PUT "PATempPass   |" .       
PUT "Seat413      |" .       
PUT "Seat414      |" .       
PUT "MedicalExp   |" .       
PUT "BailBond     |" .       
PUT "Premium1     |" .       
PUT "Premium2     |" .       
PUT "Premium3     |" .       
PUT "AddPrem      |" .       
PUT "DedPrem      |" .       
PUT "FleetPrem    |" .       
PUT "NcbPrem      |" .       
PUT "DiscPrem     |" .       
PUT "TotDiscPrem  |" .       
PUT "ClaimPrem    |" .       
PUT "NetPrem      |" .       
PUT "Stamp        |" .       
PUT "Tax          |" .       
PUT "GrossPrem    |" .       
PUT "AttachText   |" .       
PUT "UseText      |" .       
PUT "OtherText    |" .       
PUT "DayCover     |" .       
PUT "TPCover1     |" .       
PUT "TPCover2     |" .       
PUT "TPCover3     |" .       
PUT "DeductOd1    |" .       
PUT "DeductOd2    |" .       
PUT "DeductPd1    |" .       
PUT "DeductPd2    |" .       
PUT "SumIns1      |" .       
PUT "SumIns2      |" .       
PUT "SumIns3      |" .       
PUT "PACover1     |" .       
PUT "PACover2     |" .       
PUT "PACover3     |" .       
PUT "PACover4     |" .       
PUT "PACover5     |" .       
PUT "Premium4     |" .       
PUT "Premium5     |" .       
PUT "Premium6     |" .       
PUT "OthDisc1     |" .       
PUT "OthDisc2     |" .       
PUT "OthDisc3     |" .       
PUT "OthSurc1     |" .       
PUT "OthSurc2     |" .       
PUT "OthText1     |" .       
PUT "OthText2     |" .       
PUT "OthText3     |" .       
PUT "StatusFlg1   |" .       
PUT "StatusFlg2   |" .       
PUT "UpdDate      |" .       
PUT "UpdTime      |" .       
PUT "UpdUsrID     |" .       
PUT "UpdFlag      |" .       
PUT "UseEn        |" .       
PUT "UseTh        |" .       
PUT "AttachEn     |" .       
PUT "AttachTh     |" .       
PUT "codedet      |" .       
PUT "codedes      |" .       
PUT "modelflg     |" SKIP.

OUTPUT CLOSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDpmuwd132 C-Win 
PROCEDURE PDpmuwd132 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


FIND FIRST ctxstat.pmuwd132 USE-INDEX pmuwd13201 WHERE
           ctxstat.pmuwd132.campcd = fi_camp  NO-ERROR.
IF NOT AVAIL ctxstat.pmuwd132 THEN DO:

  FOR EACH stat.pmuwd132 USE-INDEX pmuwd13201 WHERE
           stat.pmuwd132.campcd =  fi_camp. /*
           stat.pmuwd132.policy = wk_uwd132.policy  AND
           stat.pmuwd132.itemno = wk_uwd132.itemno */

       CREATE ctxstat.pmuwd132 .
       ASSIGN
        ctxstat.pmuwd132.policy = stat.pmuwd132.policy
        ctxstat.pmuwd132.campcd = stat.pmuwd132.campcd /*"SABAI3_MT"*/
        ctxstat.pmuwd132.itemno = stat.pmuwd132.itemno   
    
        ctxstat.pmuwd132.bencod = stat.pmuwd132.bencod
        ctxstat.pmuwd132.benvar = stat.pmuwd132.benvar
        ctxstat.pmuwd132.rate   = stat.pmuwd132.rate
        ctxstat.pmuwd132.gap_ae = stat.pmuwd132.gap_ae
        ctxstat.pmuwd132.gap_c  = stat.pmuwd132.gap_c 
        ctxstat.pmuwd132.pd_aep = stat.pmuwd132.pd_aep
        ctxstat.pmuwd132.prem_c = stat.pmuwd132.prem_c
        
        /*pmuwd132.policy = campaign_fil.polmst*/
        ctxstat.pmuwd132.rencnt = stat.pmuwd132.rencnt
        ctxstat.pmuwd132.endcnt = stat.pmuwd132.endcnt
        ctxstat.pmuwd132.riskgp = stat.pmuwd132.riskgp
        ctxstat.pmuwd132.riskno = stat.pmuwd132.riskno
        /*pmuwd132.itemno = wk_uwd132.itemno*/
        ctxstat.pmuwd132.rateae = stat.pmuwd132.rateae
        /**/
        /*pmuwd132.campcd = wk_uwd132.campcd*/
        ctxstat.pmuwd132.uom_c  = stat.pmuwd132.uom_c 
        ctxstat.pmuwd132.uom_v  = stat.pmuwd132.uom_v 
        /**/
        ctxstat.pmuwd132.trndat = stat.pmuwd132.trndat 
        ctxstat.pmuwd132.trntim = stat.pmuwd132.trntim
        ctxstat.pmuwd132.usrid  = stat.pmuwd132.usrid 
        /**/
        ctxstat.pmuwd132.effdat = TODAY /*stat.pmuwd132.effdat*/
        ctxstat.pmuwd132.expdat = stat.pmuwd132.expdat
        .
  END.
   
END.  
ELSE DO: /*กรณีมีข้อมูลที่ ctxstat.pmuwd132*/

  FOR EACH ctxstat.pmuwd132 USE-INDEX pmuwd13201 WHERE 
      ctxstat.pmuwd132.campcd = fi_camp .  /* DELETE ctxstat.pmuwd132 เพื่อ CREATE ใหม่*/

      DELETE ctxstat.pmuwd132.

  END.


  FOR EACH stat.pmuwd132 USE-INDEX pmuwd13201 WHERE
           stat.pmuwd132.campcd =  fi_camp.

       CREATE ctxstat.pmuwd132 .
       ASSIGN
        ctxstat.pmuwd132.policy = stat.pmuwd132.policy
        ctxstat.pmuwd132.campcd = stat.pmuwd132.campcd /*"SABAI3_MT"*/
        ctxstat.pmuwd132.itemno = stat.pmuwd132.itemno   
    
        ctxstat.pmuwd132.bencod = stat.pmuwd132.bencod
        ctxstat.pmuwd132.benvar = stat.pmuwd132.benvar
        ctxstat.pmuwd132.rate   = stat.pmuwd132.rate
        ctxstat.pmuwd132.gap_ae = stat.pmuwd132.gap_ae
        ctxstat.pmuwd132.gap_c  = stat.pmuwd132.gap_c 
        ctxstat.pmuwd132.pd_aep = stat.pmuwd132.pd_aep
        ctxstat.pmuwd132.prem_c = stat.pmuwd132.prem_c
        
        /*pmuwd132.policy = campaign_fil.polmst*/
        ctxstat.pmuwd132.rencnt = stat.pmuwd132.rencnt
        ctxstat.pmuwd132.endcnt = stat.pmuwd132.endcnt
        ctxstat.pmuwd132.riskgp = stat.pmuwd132.riskgp
        ctxstat.pmuwd132.riskno = stat.pmuwd132.riskno
        /*pmuwd132.itemno = wk_uwd132.itemno*/
        ctxstat.pmuwd132.rateae = stat.pmuwd132.rateae
        /**/
        /*pmuwd132.campcd = wk_uwd132.campcd*/
        ctxstat.pmuwd132.uom_c  = stat.pmuwd132.uom_c 
        ctxstat.pmuwd132.uom_v  = stat.pmuwd132.uom_v 
        /**/
        ctxstat.pmuwd132.trndat = stat.pmuwd132.trndat 
        ctxstat.pmuwd132.trntim = stat.pmuwd132.trntim
        ctxstat.pmuwd132.usrid  = stat.pmuwd132.usrid 
        /**/
        ctxstat.pmuwd132.effdat = TODAY /*stat.pmuwd132.effdat*/
        ctxstat.pmuwd132.expdat = stat.pmuwd132.expdat
        .
  END.

  
END. 

fi_process = ctxstat.pmuwd132.campcd + " " + ctxstat.pmuwd132.policy .
/* DISP  fi_process WITH FRAME fr_main. Thitirat M. 29/06/2023*/




/*

FOR EACH stat.pmuwd132 USE-INDEX pmuwd13201 WHERE
         stat.pmuwd132.campcd =  fi_camp. /*wk_uwd132.campcd  AND
         stat.pmuwd132.policy = wk_uwd132.policy  AND
         stat.pmuwd132.itemno = wk_uwd132.itemno */

        
    FIND FIRST ctxstat.pmuwd132 USE-INDEX pmuwd13201 WHERE
               ctxstat.pmuwd132.campcd = stat.pmuwd132.campcd  NO-ERROR.
    IF NOT AVAIL ctxstat.pmuwd132 THEN DO:

       CREATE ctxstat.pmuwd132.

    END.  
    ELSE DO:

      
    END. /*IF NOT AVAIL ctxstat.pmuwd132 THEN DO:*/

 
       ASSIGN
        ctxstat.pmuwd132.policy = stat.pmuwd132.policy
        ctxstat.pmuwd132.campcd = stat.pmuwd132.campcd /*"SABAI3_MT"*/
        ctxstat.pmuwd132.itemno = stat.pmuwd132.itemno   
    
        ctxstat.pmuwd132.bencod = stat.pmuwd132.bencod
        ctxstat.pmuwd132.benvar = stat.pmuwd132.benvar
        ctxstat.pmuwd132.rate   = stat.pmuwd132.rate
        ctxstat.pmuwd132.gap_ae = stat.pmuwd132.gap_ae
        ctxstat.pmuwd132.gap_c  = stat.pmuwd132.gap_c 
        ctxstat.pmuwd132.pd_aep = stat.pmuwd132.pd_aep
        ctxstat.pmuwd132.prem_c = stat.pmuwd132.prem_c
        
        /*pmuwd132.policy = campaign_fil.polmst*/
        ctxstat.pmuwd132.rencnt = stat.pmuwd132.rencnt
        ctxstat.pmuwd132.endcnt = stat.pmuwd132.endcnt
        ctxstat.pmuwd132.riskgp = stat.pmuwd132.riskgp
        ctxstat.pmuwd132.riskno = stat.pmuwd132.riskno
        /*pmuwd132.itemno = wk_uwd132.itemno*/
        ctxstat.pmuwd132.rateae = stat.pmuwd132.rateae
        /**/
        /*pmuwd132.campcd = wk_uwd132.campcd*/
        ctxstat.pmuwd132.uom_c  = stat.pmuwd132.uom_c 
        ctxstat.pmuwd132.uom_v  = stat.pmuwd132.uom_v 
        /**/
        ctxstat.pmuwd132.trndat = stat.pmuwd132.trndat 
        ctxstat.pmuwd132.trntim = stat.pmuwd132.trntim
        ctxstat.pmuwd132.usrid  = stat.pmuwd132.usrid 
        /**/
        ctxstat.pmuwd132.effdat = TODAY /*stat.pmuwd132.effdat*/
        ctxstat.pmuwd132.expdat = stat.pmuwd132.expdat
        .




fi_process = ctxstat.pmuwd132.campcd + " " + ctxstat.pmuwd132.policy .
DISP fi_process WITH FRAME fr_main.

END.
*/



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDSetCampaign C-Win 
PROCEDURE PDSetCampaign :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: PDSetCampaign /*Thitirat M. A65-0016 09/03/2023*/  
เป็นการAuto Set parameter Campaig แทนการเข้าไปSet Manual จากข้อPackage Type Maintenance [WctxPr79.w] ที่Motor Citrix 
(หลังจากนี้โปรแกรม WctxPr79.w จะเก็บ Paramter Campaign ที่ใช้บน safe smart เพื่อให้เอาไว้เรียกใช้ข้อมูล)
------------------------------------------------------------------------------*/
DEFINE VAR  nv_nocampaign1    AS INT.  
DEFINE VAR  nv_nocampaign0    AS CHAR. /*Thitirat M. A65-0016 20/06/2023 */
nv_nocampaign1  = 0.

   /*Thitirat M. A65-0016 20/06/2023
   FIND LAST ctxstat.poltyp_fil WHERE /* ไม่ใส่USE-INDEX เพราะลำดับ poltyp ที่ต้องการอาจคลาดเคลื่อน เนื่องจากสามารถSet parameter Package 
   ตรงได้จากโปรแกรม WctxPr79.w หาก โปรแกรมนั้น SetCampaign code ไม่ได้เรียงตามปี จะทำให้ข้อมูลคลาดเคลื่อนได้  */   
   substr(ctxstat.poltyp_fil.poldes,1,1) = "C"   AND                             
          ctxstat.poltyp_fil.poltyp     <> "102" AND /*CTPL [Parameter Web Speed]  */      
          ctxstat.poltyp_fil.poltyp     <> "C93" AND /*Carrier Liability Policy  */        
          ctxstat.poltyp_fil.poltyp     <> "M16" AND /*Catastrophe Insurance Policy  */    
          ctxstat.poltyp_fil.poltyp     <> "M19" AND /*CONTINGENCY INS.  */                
          ctxstat.poltyp_fil.poltyp     <> "M41" AND /*COMPREHENSIVE PERSONAL LIABILITY */ 
          ctxstat.poltyp_fil.poltyp     <> "M51" AND /*CROP */                             
          ctxstat.poltyp_fil.poltyp     <> "M80" AND /*CONTRACTORS ALL RISKS */            
          ctxstat.poltyp_fil.poltyp     <> "M83" AND /*CONTRACTOR'S PLANT & EQUIPMENT */   
          ctxstat.poltyp_fil.poltyp     <> "V72" AND /*Compulsory  */                      
          ctxstat.poltyp_fil.poltyp     <> "V73" AND /*Compulsory Project  */              
          ctxstat.poltyp_fil.poltyp     <> "V74"     /*Compulsory Project */               
          NO-LOCK NO-ERROR.
   
   IF AVAIL ctxstat.poltyp_fil THEN DO:
        nv_nocampaign1 = INTEGER(ctxstat.poltyp_fil.poltyp) + 1 . 
   END.
  Thitirat M. A65-0016 20/06/2023*/

   /*Thitirat M. A65-0016 20/06/2023 */
   FOR EACH ctxstat.poltyp_fil WHERE 
            ctxstat.poltyp_fil.poltyp >= "0"          AND 
            ctxstat.poltyp_fil.poltyp <= "9999999999" BY INTE(poltyp_fil.poltyp).
   
     nv_nocampaign0 = ctxstat.poltyp_fil.poltyp.
     nv_nocampaign1 = INTEGER(nv_nocampaign0) + 1 . 
   
   END. 
   /*Thitirat M. A65-0016 20/06/2023 */


    FIND FIRST ctxstat.poltyp_fil USE-INDEX poltyp01 
         WHERE ctxstat.poltyp_fil.poltyp = string(nv_nocampaign1) NO-ERROR.
    IF AVAIL ctxstat.poltyp_fil THEN DO:
    
       MESSAGE "Set Parameter Campaig :" fi_camp "ที่Motor Citrix ไม่สำเร็จ !!!" SKIP
               "เข้าไป Set Manual ที่Motor Citrix ข้อ Parameter Setup / ข้อ Package Type Maintenance"  VIEW-AS ALERT-BOX.         
    END.
    ELSE DO:
    
    /*MESSAGE "เข้า PDSetCampaign  n_camcod :" n_camcod ", n_camnam " n_camnam  "nv_nocampaign1: " nv_nocampaign1 VIEW-AS ALERT-BOX. */
    
       FIND FIRST ctxstat.poltyp_fil USE-INDEX poltyp02 
            WHERE ctxstat.poltyp_fil.poldes = fi_camp NO-ERROR.
       IF NOT AVAIL ctxstat.poltyp_fil THEN DO:
        
        CREATE poltyp_fil.
        ASSIGN
              poltyp_fil.poltyp  =  string(nv_nocampaign1)
              poltyp_fil.poldes  =  n_camcod
              poltyp_fil.pode_t  =  n_camnam

              /*Thitirat M. A65-0016 16/06/2023 เก็บเพื่อนำไปใช้เช็คในโปรแกรม WUWTPACK1.W ต่อ*/
              poltyp_fil.ptsoft  =  nv_campaigntype  /* s=special/แคมเปญพิเศษ , c=center/แคมเปญกลาง */
              poltyp_fil.cdmon   =  n_effectivedate  /*วันที่ใช้งาน*/
              poltyp_fil.dept    =  n_expirydate     /*วันที่สิ้นสุด*/
              .
              /*Thitirat M. A65-0016 16/06/2023*/
              
    
        MESSAGE "Auto Set [CREATE] Parameter Campaig :" fi_camp "ที่Motor Citrix สำเร็จ" SKIP
                "ที่ข้อ Parameter Setup / ข้อ Package Type Maintenance"  VIEW-AS ALERT-BOX. 
       
       END.
       ELSE DO: /*Thitirat M. A65-0016 16/06/2023 กรณีมีแคมเปญเก็บอยู่แล้วที่ ctxstat.poltyp_fil จะ Update ข้อมูลลงไป
                กรณีนี้จะเกิดขึ้นได้ก็ต่อเมื่อมีการไป add Parameter ตรงๆที่โปรแกรม[WctxPr79.w] ไว้แล้ว  โดยที่ยังไม่เคยเอาแคมเปญขึ้น Safe Smart
                หรือ กดปุ่ม DEL แล้ว Process ขึ้น Safe Smart ซ้ำอีกที */

        ASSIGN
              poltyp_fil.poldes  =  n_camcod
              poltyp_fil.pode_t  =  n_camnam

              poltyp_fil.ptsoft  =  nv_campaigntype  
              poltyp_fil.cdmon   =  n_effectivedate  
              poltyp_fil.dept    =  n_expirydate     
              .

        MESSAGE "Auto Set [UPDATE] Parameter Campaig :" fi_camp "ที่Motor Citrix สำเร็จ" SKIP
                "ที่ข้อ Parameter Setup / ข้อ Package Type Maintenance"  VIEW-AS ALERT-BOX. 


       END. /*Thitirat M. A65-0016 16/06/2023*/
    
    
    
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDTransMotCamp C-Win 
PROCEDURE PDTransMotCamp :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*Thitirat M. A65-0016*/
n_cnt = 0. 
n_cntkeyid = 1. 
n_num = 1.

 ASSIGN 
   n_b1         =   string(TODAY,"99999999")  
   n_b2         =  SUBSTRING(TRIM(n_b1),1,2) /* เดือน  */
   n_b3         =  SUBSTRING(TRIM(n_b1),3,2) /* วัน  */
   n_b4         =  SUBSTRING(TRIM(n_b1),5,4) /* ปี */
   /*nv_datetoday =  n_b4 +  n_b2 +   n_b3 .  /*ป ด ว TODAY */  */
   nv_datetoday =  n_b4 +  n_b3 +   n_b2 .  /*ป ด ว TODAY */  /*Lukkana M.25/05/2022*/

ASSIGN
fi_cntcod  = n_cntcod 
n_cntcod   = 0 
n_checkerr = YES .
/*Thitirat M. A65-0016*/

FOR EACH stat.campaign_fil USE-INDEX campfil14 WHERE stat.campaign_fil.camcod = fi_camp NO-LOCK: /*Lukkana M. add index 25/05/2022*/

    FIND FIRST ctxstat.motcamp USE-INDEX motcamp02 WHERE  
               ctxstat.motcamp.polmst   =  campaign_fil.polmst         AND
               ctxstat.motcamp.camcod   = TRIM(campaign_fil.camcod)    AND   
               ctxstat.motcamp.camnam   = TRIM(campaign_fil.camnam)    NO-ERROR.
    IF NOT AVAIL ctxstat.motcamp THEN DO: /*การUp campaign ลง ctxstat.motcamp จะไม่ให้ Update ซ้ำ หากต้องการ จะต้อง กดปุ่ม del หรือ ใช้ campaign ใหม่แทน เท่านั้น*/

    n_cntcod = n_cntcod + 1. /*Thitirat M. A65-0016*/
    n_cnt    = n_cnt + 1 .

    CREATE ctxstat.motcamp.
    ASSIGN
        ctxstat.motcamp.camcod        =  TRIM(campaign_fil.camcod)   /*x(15)    */
        ctxstat.motcamp.camnam        =  TRIM(campaign_fil.camnam)   /*"ประเภท1 แคมแปญกลุ่มรถ 3-5 High Coverage (HYBRID)"*/ /*"ประเภท 2+ (UP2+)"*/ /*"ประเภท 3"*/ /*TRIM(campaign_fil.camnam)*/       /*x(40)           */
        ctxstat.motcamp.paccod        =  TRIM(campaign_fil.paccod)   /*x(2)     */
        ctxstat.motcamp.class         =  TRIM(campaign_fil.CLASS)    /*x(4)     */
        ctxstat.motcamp.sclass        =  TRIM(campaign_fil.sclass)   /*x(4)     */
        ctxstat.motcamp.covcod        =  TRIM(campaign_fil.covcod)   /*x(4)     */
        ctxstat.motcamp.vehgrp        =  TRIM(campaign_fil.vehgrp)   /*x(2)     */
        ctxstat.motcamp.vehuse        =  TRIM(campaign_fil.vehuse)   /*x(1)     */
        ctxstat.motcamp.garage        =  TRIM(campaign_fil.garage)   /*x        */
        ctxstat.motcamp.mincst        =  campaign_fil.mincst         /*->>>>9.99*/
        ctxstat.motcamp.maxcst        =  campaign_fil.maxcst         /*->>>>9.99*/
        ctxstat.motcamp.makeyr        =  campaign_fil.maxyea         /*>>>9     */
        ctxstat.motcamp.makedes       =  TRIM(campaign_fil.makdes)   /*x(30)    */
        ctxstat.motcamp.modeldes      =  TRIM(campaign_fil.moddes)   /*x(50)    */
        ctxstat.motcamp.bodydes       =  ""                          /*x(50)    */ 

        ctxstat.motcamp.doorno       =  campaign_fil.doorno         /*x(40) */  
        ctxstat.motcamp.engine       =  campaign_fil.engine         /*>>>>9 */  
        ctxstat.motcamp.seats        =  campaign_fil.seats          /*>>9   */  
        ctxstat.motcamp.tons         =  campaign_fil.tons           /*>>>9.99     */
        ctxstat.motcamp.simin        =  campaign_fil.simin          /*>>>,>>>,>>9 */
        ctxstat.motcamp.simax        =  campaign_fil.simax          /*>>>,>>>,>>9 */
        ctxstat.motcamp.access       =  campaign_fil.access         /*x           */
        ctxstat.motcamp.accsi        =  campaign_fil.accsi          /*>>>,>>>,>>9 */
        ctxstat.motcamp.accprm       =  0                           /*->,>>>,>>9.99*/
        ctxstat.motcamp.drivnam      =  STRING(campaign_fil.drinam) /*Y/N */
        ctxstat.motcamp.drivno       =  campaign_fil.drino        /*>9 */
        ctxstat.motcamp.drivage1min  =  campaign_fil.drivage1min  /*>9 */
        ctxstat.motcamp.drivage1max  =  campaign_fil.drivage1max  /*>9 */
        ctxstat.motcamp.drivage2min  =  campaign_fil.drivage2min  /*>9 */
        ctxstat.motcamp.drivage2max  =  campaign_fil.drivage2max  /*>9 */
        
        ctxstat.motcamp.drivprm      =  0                         /*->,>>>,>>9.99 */
        ctxstat.motcamp.baseprm      =  campaign_fil.baseprm      /*>>>,>>9.99  */
        ctxstat.motcamp.baseprm3     =  campaign_fil.baseprm3     /*>>>,>>9.99  */
        ctxstat.motcamp.dedod        =  campaign_fil.dedod        /*->>,>>>,>>>9*/
        ctxstat.motcamp.dedad        =  campaign_fil.addod        /*->>,>>>,>>>9*/
        ctxstat.motcamp.dedpd        =  campaign_fil.dedpd        /*->>,>>>,>>>9*/
        ctxstat.motcamp.dedprm       =  campaign_fil.dedprm       /*->>,>>>,>>>9*/
        ctxstat.motcamp.dadprm       =  campaign_fil.addprm       /*->>,>>>,>>>9*/
        ctxstat.motcamp.dpdprm       =  campaign_fil.dpdprm       /*->>,>>>,>>>9*/
        ctxstat.motcamp.fletper      =  campaign_fil.fletper      /*->>9.99     */
        ctxstat.motcamp.ncbyrs       =  campaign_fil.ncbyrs       /*>9          */
        ctxstat.motcamp.ncbper       =  campaign_fil.ncbper       /*->>9.99     */
        ctxstat.motcamp.dspcper      =  campaign_fil.dspcper      /*->>9.99     */
        ctxstat.motcamp.dspcamt      =  campaign_fil.dspcamt      /*->,>>>,>>9.99 */
        ctxstat.motcamp.stfper       =  campaign_fil.stfper       /*->>9.99       */
        ctxstat.motcamp.stfamt       =  campaign_fil.stfamt       /*->,>>>,>>9.99 */
        ctxstat.motcamp.clmper       =  campaign_fil.clmper       /*->>9.99 */  
        ctxstat.motcamp.polmst       =  TRIM(campaign_fil.polmst) /*x(40)   */ /*เพิ่ม TRIM ตามที่พี่ฝนแจ้ง*/
        ctxstat.motcamp.cctv         =  STRING(campaign_fil.cctv) /*Y/N     */  
        ctxstat.motcamp.cctvcd       =  campaign_fil.cctvcd       /*X(10)   */  
        ctxstat.motcamp.cctvper      =  campaign_fil.cctvper      /*->>9.99 */  
        ctxstat.motcamp.cctvamt      =  campaign_fil.cctvamt      /*->,>>>,>>9.99 */
        ctxstat.motcamp.cctvdes      =  ""                        /*X(10)  */
        
        ctxstat.motcamp.promcod[1]   =  campaign_fil.promcod[1]   /*x(10) */ 
        ctxstat.motcamp.promnam[1]   =  campaign_fil.promnam[1]   /*x(50) */ 
        ctxstat.motcamp.plancod      =  campaign_fil.plancod      /*x(10) */ 
        ctxstat.motcamp.planno       =  campaign_fil.planno       /*x(5)  */ 
        ctxstat.motcamp.plannam      =  campaign_fil.plannam      /*x(40) */ 
        ctxstat.motcamp.effdat       =  campaign_fil.effdat       /*99/99/9999 */
        ctxstat.motcamp.expdat       =  campaign_fil.expdat       /*99/99/9999 */
        ctxstat.motcamp.entdat       =  campaign_fil.entdat       /*99/99/9999 */
        ctxstat.motcamp.enttim       =  campaign_fil.enttim       /*x(8)  */
        ctxstat.motcamp.usrid        =  USERID(LDBNAME(1))        /*x(8)  */
        ctxstat.motcamp.remark       =  campaign_fil.remark       /*x(50) */
        ctxstat.motcamp.spflag       =  campaign_fil.spflag       /*X(10) */
        ctxstat.motcamp.TransDate    =  TODAY                     /*99/99/9999 */
        ctxstat.motcamp.TransTime    =  STRING(TIME,"HH:MM:SS")   /*x(8)  */
        ctxstat.motcamp.TransId      =  USERID(LDBNAME(1))        /*x(8)  */
        ctxstat.motcamp.TransFlag    =  ""  /*X(10) */
        ctxstat.motcamp.ctxt1        =  ""  /*x(50) */
        ctxstat.motcamp.ctxt2        =  ""  /*x(50) */
        ctxstat.motcamp.ctxt3        =  ""  /*x(50) */
        ctxstat.motcamp.cdate1       =  ?   /*99/99/9999 */
        ctxstat.motcamp.cdate2       =  ?   /*99/99/9999 */
        ctxstat.motcamp.cdate3       =  ?   /*99/99/9999 */
        ctxstat.motcamp.cdec1        =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.cdec2        =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.cdec3        =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.clog1        =  NO  /*Yes/No */
        ctxstat.motcamp.clog2        =  NO  /*Yes/No */
        
        ctxstat.motcamp.tpbips       =  IF campaign_fil.uom1_v <> 0 THEN TRIM(STRING(campaign_fil.uom1_v)) ELSE "ไม่คุ้มครอง"  /*X(30) */
        ctxstat.motcamp.tpbiacc      =  IF campaign_fil.uom2_v <> 0 THEN TRIM(STRING(campaign_fil.uom2_v)) ELSE "ไม่คุ้มครอง"  /*X(30) */
        ctxstat.motcamp.tppdacc      =  IF campaign_fil.uom5_v <> 0 THEN TRIM(STRING(campaign_fil.uom5_v)) ELSE "ไม่คุ้มครอง"  /*X(30) */
        ctxstat.motcamp.DeductPd     =  IF ctxstat.motcamp.dedpd <> 0 THEN TRIM(STRING(ctxstat.motcamp.dedpd)) ELSE "-"                                      /*X(15)           */
        ctxstat.motcamp.SumInsOd     =  IF ctxstat.motcamp.simax <> 0 THEN TRIM(STRING(ctxstat.motcamp.simax)) ELSE "-"                                      /*X(30)           */
        ctxstat.motcamp.DeductOd     =  IF (ctxstat.motcamp.dedod + ctxstat.motcamp.dedad) <> 0 THEN TRIM(STRING(ctxstat.motcamp.dedod + ctxstat.motcamp.dedad)) ELSE "-"    /*X(15)           */
      /*ctxstat.motcamp.SumInsFt     =  IF ctxstat.motcamp.simax <> 0 THEN TRIM(STRING(ctxstat.motcamp.simax)) ELSE "-"      */                                /*X(30)           */
        ctxstat.motcamp.PALifeDriv   =  IF campaign_fil.mv411 <> 0 THEN STRING(campaign_fil.mv411) ELSE "ไม่คุ้มครอง"  /*X(15) */  
        ctxstat.motcamp.PALifePass   =  IF campaign_fil.mv412 <> 0 THEN STRING(campaign_fil.mv412) ELSE "ไม่คุ้มครอง"  /*X(15) */  
        ctxstat.motcamp.Seat411      =  "1"                                                                            /*X(3)  */  
        ctxstat.motcamp.Seat412      =  TRIM(STRING(campaign_fil.seat41 - 1))                                          /*X(3)  */  
        ctxstat.motcamp.PATempDriv   =  IF campaign_fil.mv44 <> 0 THEN STRING(campaign_fil.mv44) ELSE "ไม่คุ้มครอง"    /*X(15) */  
        ctxstat.motcamp.PATempPass   =  IF campaign_fil.mv44 <> 0 THEN STRING(campaign_fil.mv44) ELSE "ไม่คุ้มครอง"    /*X(15) */  
        ctxstat.motcamp.Seat413      =  IF ctxstat.motcamp.PATempDriv = "ไม่คุ้มครอง" THEN "-" ELSE "1"                                                                                                  /*X(3)            */
        ctxstat.motcamp.Seat414      =  IF ctxstat.motcamp.PATempPass = "ไม่คุ้มครอง" THEN "-" ELSE TRIM(STRING(campaign_fil.seat41 - 1))                                                                        /*X(3)            */
        ctxstat.motcamp.MedicalExp   =  IF campaign_fil.mv42 <> 0 THEN STRING(campaign_fil.mv42) ELSE "ไม่คุ้มครอง"    /*X(15) */
        ctxstat.motcamp.BailBond     =  IF campaign_fil.mv43 <> 0 THEN STRING(campaign_fil.mv43) ELSE "ไม่คุ้มครอง"    /*X(15) */
        ctxstat.motcamp.Premium1     =  campaign_fil.netprm1  /*->,>>>,>>9.99   */

        ctxstat.motcamp.Premium2     =  campaign_fil.netprm3  /*->,>>>,>>9.99   */
        ctxstat.motcamp.Premium3     =  campaign_fil.netdriv  /*เบี้ย ส่วนต่างระบุชื่อผู้ขับขี่*/                   /*->,>>>,>>9.99   */
        ctxstat.motcamp.AddPrem      =  campaign_fil.netprm2  /*->,>>>,>>9.99   */
        ctxstat.motcamp.DedPrem      =  (ctxstat.motcamp.dedprm + ctxstat.motcamp.dadprm  + ctxstat.motcamp.dpdprm) * (-1)                  /*->,>>>,>>9.99   */
        ctxstat.motcamp.FleetPrem    =  campaign_fil.fletamt                                                        /*->,>>>,>>9.99   */
        ctxstat.motcamp.NcbPrem      =  campaign_fil.ncbamt                                                         /*->,>>>,>>9.99   */
        ctxstat.motcamp.DiscPrem     =  campaign_fil.dspcamt + campaign_fil.stfamt                                  /*->,>>>,>>9.99   */
        ctxstat.motcamp.TotDiscPrem  =  ctxstat.motcamp.DedPrem + ctxstat.motcamp.FleetPrem + ctxstat.motcamp.NcbPrem + ctxstat.motcamp.DiscPrem    /*->,>>>,>>9.99   */
        ctxstat.motcamp.ClaimPrem    =  campaign_fil.clmamt                                                         /*->,>>>,>>9.99   */
        ctxstat.motcamp.NetPrem      =  campaign_fil.netprm                                                         /*->,>>>,>>9.99   */
        ctxstat.motcamp.Stamp        =  campaign_fil.stamp                                                          /*->>>,>>9.99     */
        ctxstat.motcamp.Tax          =  campaign_fil.tax                                                            /*->>>,>>9.99     */
            
        ctxstat.motcamp.GrossPrem    =  campaign_fil.grossprm    /*->>,>>>,>>9.99  */
        ctxstat.motcamp.AttachText   =  ""  /*X(100) */ 
        ctxstat.motcamp.UseText      =  ""  /*X(100) */ 
        ctxstat.motcamp.OtherText    =  ""  /*X(100) */ 
        /*ctxstat.motcamp.DayCover     =  STRING(365) /*X(15)  */ *//*Comment A65-0232*/
        ctxstat.motcamp.DayCover     =  STRING(campaign_fil.cdays)
        ctxstat.motcamp.TPCover1     =  ""  /*X(30)  */ 
        ctxstat.motcamp.TPCover2     =  ""  /*X(30)  */ 
        ctxstat.motcamp.TPCover3     =  ""  /*X(30)  */ 
        ctxstat.motcamp.DeductOd1    =  ""  /*X(30)  */ 
        ctxstat.motcamp.DeductOd2    =  ""  /*X(30)  */ 
        ctxstat.motcamp.DeductPd1    =  ""  /*X(30)  */ 
        ctxstat.motcamp.DeductPd2    =  ""  /*X(30)  */ 
        ctxstat.motcamp.SumIns1      =  ""  /*X(30)  */ 
        ctxstat.motcamp.SumIns2      =  ""  /*X(30)  */ 
        ctxstat.motcamp.SumIns3      =  ""  /*X(30)  */ 
        ctxstat.motcamp.PACover1     =  ""  /*X(30)  */ 

        ctxstat.motcamp.PACover2     =  ""  /*X(30)  */ 
        ctxstat.motcamp.PACover3     =  ""  /*X(30)  */ 
        ctxstat.motcamp.PACover4     =  ""  /*X(30)  */ 
        ctxstat.motcamp.PACover5     =  ""  /*X(30)  */ 
        ctxstat.motcamp.Premium4     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.Premium5     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.Premium6     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.OthDisc1     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.OthDisc2     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.OthDisc3     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.OthSurc1     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.OthSurc2     =  0   /*->,>>>,>>9.99 */
        ctxstat.motcamp.OthText1     =  ""  /*X(100) */  
        ctxstat.motcamp.OthText2     =  ""  /*X(100) */  
        ctxstat.motcamp.OthText3     =  ""  /*X(100) */  
        ctxstat.motcamp.StatusFlg1   =  NO  /*Y/N    */  
        ctxstat.motcamp.StatusFlg2   =  NO  /*Y/N    */  
        ctxstat.motcamp.UpdDate      =  TODAY       /*99/99/9999*/
        ctxstat.motcamp.UpdTime      =  STRING(TIME,"HH:MM:SS") /*x(8) */
        ctxstat.motcamp.UpdUsrID     =  USERID(LDBNAME(1))      /*x(8) */
        ctxstat.motcamp.UpdFlag      =  ""  /*X(10)  */  
        ctxstat.motcamp.UseEn        =  ""  /*X(100) */  
        ctxstat.motcamp.UseTh        =  ""  /*x(100) */  
        ctxstat.motcamp.AttachEn     =  ""  /*x(100) */  
        ctxstat.motcamp.AttachTh     =  ""  /*x(100) */  
        ctxstat.motcamp.codedet      =  ""  /*x(50)  */  
        ctxstat.motcamp.codedes      =  ""  /*x(50)  */  
        ctxstat.motcamp.modelflg     =  ""  /*x(10)  */  

        /*เพิ่มตามที่พี่ฝนแจ้ง*/ 
        ctxstat.motcamp.effectivedate = nv_datetoday /*'20220121'  TODAY*/
        ctxstat.motcamp.expirydate    = "99990101" /* ( fix ) */
        /*ctxstat.motcamp.keyid         = fi_camp + nv_datetoday + string(n_num)   /*(Key ที่จะใช้ยิง web service) */   /*เพิ่มตามที่พี่ฝนแจ้ง*/*/
        ctxstat.motcamp.keyid         =  nv_campaig + nv_datetoday + STRING(n_num)   /*(Key ที่จะใช้ยิง web service) */   /*เพิ่มตามที่พี่ฝนแจ้ง*/
       /*เพิ่มตามที่พี่ฝนแจ้ง*/
        .
         
     //    MESSAGE " nv_datetoday:" nv_datetoday "//ctxstat.motcamp.keyid :" ctxstat.motcamp.keyid  "//n_num:" n_num VIEW-AS ALERT-BOX.
     

            IF ctxstat.motcamp.covcod = '3.2' THEN ctxstat.motcamp.SumInsFt  = "-".
            ELSE ctxstat.motcamp.SumInsFt     =  IF ctxstat.motcamp.simax <> 0 THEN TRIM(STRING(ctxstat.motcamp.simax)) ELSE "-"  .

            /*-- Add A65-0232 --*/
            IF campaign_fil.covcod = "2" THEN DO: 
                ctxstat.motcamp.SumInsOd = "-".
            END.
            /*-- End Add A65-0232 --*/
            
            ctxstat.motcamp.garage = TRIM(ctxstat.motcamp.garage).
            
            FIND FIRST sicsyac.xtu001 USE-INDEX xtu001 WHERE
                       sicsyac.xtu001.uset = ctxstat.motcamp.sclass NO-LOCK NO-ERROR NO-WAIT.
            IF AVAIL xtu001 THEN DO:
                ctxstat.motcamp.UseTh = sicsyac.xtu001.usett1 + sicsyac.xtu001.usett2.
                ctxstat.motcamp.UseEn = sicsyac.xtu001.usete1 + sicsyac.xtu001.usete2.
                ctxstat.motcamp.useth = TRIM(useth).
                ctxstat.motcamp.useen = TRIM(useen).
            END.
            IF ctxstat.motcamp.useth = "ใช้ส่วนบุคคล ไม่ใช้รับจ้างหรือให้เช่า /ทดสอบ" THEN ctxstat.motcamp.useth = "ใช้ส่วนบุคคล ไม่ใช้รับจ้างหรือให้เช่า". /*เพิ่มตามพี่ฝนแจ้ง*/
            
            IF ctxstat.motcamp.AttachText = "NO-MN30" THEN DO:
                ctxstat.motcamp.AttachEn = "Electronic Data & Internet Endorsement".
                ctxstat.motcamp.AttachTh = "ข้อยกเว้นภัยก่อการร้าย(ร.ย.30)".
            END.
            ELSE DO:
                ctxstat.motcamp.AttachEn = "Terrorism Exclusion Endorsement(M.N.30)/Electronic Data & Internet Endorsement".
                ctxstat.motcamp.AttachTh = "ข้อยกเว้นภัยก่อการร้าย(ร.ย.30)/ข้อมูลอิเล็กทรอนิกส์ และอินเตอร์เน็ต".
            END.
            
            IF ctxstat.motcamp.cctv = "YES" THEN DO:
                FIND FIRST xcpara49 USE-INDEX xcpara4901 WHERE
                           xcpara49.CLASS   = "DISC"   AND
                           xcpara49.TYPE[1] = ctxstat.motcamp.cctvcd  NO-LOCK NO-ERROR.
                IF AVAIL xcpara49 THEN DO:
                    ctxstat.motcamp.cctvdes = xcpara49.TYPE[7]. 
                END.
                ELSE ctxstat.motcamp.cctvdes = "".
            END.
            ELSE ctxstat.motcamp.cctvdes = "".
            
            IF ctxstat.motcamp.ncbper <> 0 THEN DO:
                ctxstat.motcamp.OtherText = TRIM("N" + STRING(ctxstat.motcamp.ncbper)).
            END.
            IF ctxstat.motcamp.dspcper <> 0 THEN DO:
                ctxstat.motcamp.OtherText = TRIM(ctxstat.motcamp.OtherText + "D" + STRING(ctxstat.motcamp.dspcper)).
            END.
            
            fi_process = ctxstat.motcamp.camcod + " " + ctxstat.motcamp.polmst .
            DISP n_cntcod @ fi_cntcod /* fi_process Thitirat M. 29/06/2023*/ WITH FRAME fr_main. /*Thitirat M. A65-0016*/

            DISP fi_process
            WITH COLOR black/white NO-LABEL TITLE "Process data......"
            CENTERED FRAME fr_process1 VIEW-AS DIALOG-BOX.  /*Thitirat M. 29/06/2023*/



            IF n_cnt > 500 THEN do: /*มากกว่า 500 ให้ keyid +1 */  /*Thitirat M. 29/06/2023*/
                
              n_cntkeyid = n_cntkeyid + 1 .
              n_num = n_num + 1.
              n_cnt = 0.
             /* MESSAGE "ถ้าn_cnt > 2 : //n_cnt:" n_cnt "//n_num:" n_num "//n_cntkeyid:" n_cntkeyid VIEW-AS ALERT-BOX. */
            END.


    END.
    ELSE DO: /*Thitirat M. A65-0016*/

        n_checkerr = NO.
        
    END.

END.

IF n_checkerr = NO THEN DO:

MESSAGE "ไม่สามารถ Transfer Campaign No:" fi_camp "ได้ เคยมีการ Transfer ไปแล้ว " skip
           "วิธีแก้ไข 2 วิธีคือ" skip
           "  1.กด DEL Campaign ก่อน แล้ว Transfer Campaign ใหม่อีกครั้ง " skip
           "  2.ตั้งชื่อ Campaign No ขึ้นมาใหม่ แล้ว Transfer " VIEW-AS ALERT-BOX.
           /**/
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDTransSafeSmart C-Win 
PROCEDURE PDTransSafeSmart :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: PDTransSafeSmart      
------------------------------------------------------------------------------*/

DEFINE VARIABLE HttpClient  AS CLASS System.Net.WebClient. 
DEFINE VARIABLE webResponse AS LONGCHAR NO-UNDO. 
DEFINE VARIABLE Response    AS CHARACTER EXTENT NO-UNDO. 
DEFINE VARIABLE PostKeyid   AS CHARACTER NO-UNDO.

/*FIX-CODEPAGE (webResponse) = "UTF-8".*/ 
/*MESSAGE "nv_Count :" nv_Count "// nv_keyid :" nv_keyid  "__เข้า PDTransSafeSmart " VIEW-AS ALERT-BOX. */

PostKeyid = nv_keyid . /*"202111180001"*/

DO ON ERROR UNDO, THROW: /*Thitirat M. 10/07/2023 เพิ่ม DO ON ERROR UNDO, THROW: */

HttpClient = NEW System.Net.WebClient(). 
HttpClient:Proxy:Credentials = System.Net.CredentialCache:DefaultNetworkCredentials. 
System.AppContext:SetSwitch("Switch.System.Net.DontEnableSchUseStrongCrypto", false).


 /*webResponse = HttpClient:DownloadString("http://10.35.1.155:8080/styweb-online/tranmotcamp/?keyid=" + PostKeyid). */   /*Production */ 
   webResponse = HttpClient:DownloadString("http://10.35.1.155:8080/styweb-online-test/tranmotcamp/?keyid=" + PostKeyid). /*UAT */ 


HttpClient:Dispose(). 
DELETE OBJECT HttpClient. 

/*MESSAGE STRING(webResponse) VIEW-AS ALERT-BOX.  Thitirat M. A65-0016*/
/*OUTPUT TO "d:\PostCamp_Status.txt".      Thitirat M. 30/08/2023*/
/*OUTPUT TO "D:\temp\PostCamp_Status.txt". Thitirat M. 30/08/2023*//*A68-0037*/
  OUTPUT TO "PostCamp_Status.txt". /*A68-0037*/ 
  EXPORT webResponse.
  OUTPUT CLOSE.
  
/*output to d:\PostCamp_log.TXT append.      Thitirat M. 30/08/2023*/
/*output to D:\temp\PostCamp_log.TXT append. Thitirat M. 30/08/2023*//*A68-0037*/
  output to PostCamp_log.TXT append. /*A68-0037*/
  PUT TODAY FORMAT "99/99/9999" " " STRING(TIME,"HH:MM:SS") SKIP
       "  Campaign => " fi_camp   FORMAT "x(20)"              
       "  Total : " n_cntcod                                  
       "  camp_type : " nv_campaigntype                       
       "  Keyid UAT : " nv_keyid   FORMAT "x(30)"           SKIP
       "Message : " string(webResponse) FORMAT "X(150)"     SKIP
       " --------------------------------------" SKIP .                    
  output close.


END. /*Thitirat M. 10/07/2023 เพิ่ม DO ON ERROR UNDO, THROW: */

/*Thitirat M. 10/07/2023 ถ้าเกิด ERROR ให้แสดงใน LOG นี้*/
CATCH eAnyError AS Progress.Lang.Error:

ERR_Service = "error" . /*ถ้าเข้ามาที่Loopนี้ ไม่ว่ากี่ครั้ง ไม่ให้แสดงผลว่า Process Complete ต้องแจ้งเตือนUSerให้ยิงอีกที*/

 /*MESSAGE "ERROR =>" eAnyError:GetMessage(1) SKIP
       "กรุณา กดปุ่ม Transfer Safe Smart ใหม่อีกครั้ง เนื่องจาก Web Service ERROR " VIEW-AS ALERT-BOX. *//*A68-0037 ไม่ต้องขึ้นแจ้งเตือน ให้ไปดู Log แทน*/

 /*output to D:\log_eAnyError_PostCamp.TXT append.      Thitirat M. 30/08/2023*/
 /*output to D:\temp\log_eAnyError_PostCamp.TXT append. Thitirat M. 30/08/2023*//*A68-0037*/
   output to log_eAnyError_PostCamp.TXT append. /*A68-0037*/ 
   PUT TODAY FORMAT "99/99/9999" " " STRING(TIME,"HH:MM:SS")        SKIP
        "Campaign => " fi_camp FORMAT "x(20)"                       SKIP
        "Total  : " n_cntcod                      
        "   Keyid UAT : " nv_keyid   FORMAT "X(30)" 
        "Message: " string(eAnyError:GetMessage(1)) FORMAT "X(150)" SKIP
        " ------------" SKIP .                    
   output close.

END CATCH.
/*Thitirat M. 10/07/2023*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDTransWsvint C-Win 
PROCEDURE PDTransWsvint :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:  PDTransWsvint     
------------------------------------------------------------------------------*/
DEF VAR a AS INTE.
DEF VAR b AS INTE.

n_camcod   = ""  . /*Thitirat M. A65-0016 09/03/2023*/   
n_camnam   = ""  . /*Thitirat M. A65-0016 09/03/2023*/ 

n_effectivedate  = ""  . /*Thitirat M. A65-0016 16/06/2023*/  
n_expirydate     = ""  . /*Thitirat M. A65-0016 16/06/2023*/ 

FIND FIRST wsvint.motcamp  USE-INDEX motcam01 WHERE /* ไม่มี USE-INDEX */ /*Lukkana M. A68-0057 27/03/2025*/
           wsvint.motcamp.camcod    = fi_camp NO-ERROR.
IF NOT AVAIL wsvint.motcamp THEN DO:

  FOR EACH ctxstat.motcamp USE-INDEX motcamp02  WHERE   
           ctxstat.motcamp.camcod   = fi_camp   .
  
  a = a + 1.
  CREATE wsvint.motcamp.
  ASSIGN
      wsvint.motcamp.camcod       =  ctxstat.motcamp.camcod   
      wsvint.motcamp.camnam       =  ctxstat.motcamp.camnam   
      wsvint.motcamp.paccod       =  ctxstat.motcamp.paccod   
      wsvint.motcamp.class        =  ctxstat.motcamp.class    
      wsvint.motcamp.sclass       =  ctxstat.motcamp.sclass   
      wsvint.motcamp.covcod       =  ctxstat.motcamp.covcod   
      wsvint.motcamp.vehgrp       =  ctxstat.motcamp.vehgrp   
      wsvint.motcamp.vehuse       =  ctxstat.motcamp.vehuse   
      wsvint.motcamp.garage       =  ctxstat.motcamp.garage   
      wsvint.motcamp.mincst       =  ctxstat.motcamp.mincst   
      wsvint.motcamp.maxcst       =  ctxstat.motcamp.maxcst   
      wsvint.motcamp.makeyr       =  ctxstat.motcamp.makeyr   
      wsvint.motcamp.makedes      =  ctxstat.motcamp.makedes  
      wsvint.motcamp.modeldes     =  ctxstat.motcamp.modeldes 
      wsvint.motcamp.bodydes      =  ctxstat.motcamp.bodydes 
      wsvint.motcamp.doorno       =  ctxstat.motcamp.doorno     
      wsvint.motcamp.engine       =  ctxstat.motcamp.engine     
      wsvint.motcamp.seats        =  ctxstat.motcamp.seats      
      wsvint.motcamp.tons         =  ctxstat.motcamp.tons       
      wsvint.motcamp.simin        =  ctxstat.motcamp.simin      
      wsvint.motcamp.simax        =  ctxstat.motcamp.simax      
      wsvint.motcamp.access       =  ctxstat.motcamp.access     
      wsvint.motcamp.accsi        =  ctxstat.motcamp.accsi      
      wsvint.motcamp.accprm       =  ctxstat.motcamp.accprm     
      wsvint.motcamp.drivnam      =  ctxstat.motcamp.drivnam    
      wsvint.motcamp.drivno       =  ctxstat.motcamp.drivno     
      wsvint.motcamp.drivage1min  =  ctxstat.motcamp.drivage1min
      wsvint.motcamp.drivage1max  =  ctxstat.motcamp.drivage1max
      wsvint.motcamp.drivage2min  =  ctxstat.motcamp.drivage2min
      wsvint.motcamp.drivage2max  =  ctxstat.motcamp.drivage2max
                                    
      wsvint.motcamp.drivprm      =  ctxstat.motcamp.drivprm    
      wsvint.motcamp.baseprm      =  ctxstat.motcamp.baseprm    
      wsvint.motcamp.baseprm3     =  ctxstat.motcamp.baseprm3   
      wsvint.motcamp.dedod        =  ctxstat.motcamp.dedod      
      wsvint.motcamp.dedad        =  ctxstat.motcamp.dedad      
      wsvint.motcamp.dedpd        =  ctxstat.motcamp.dedpd      
      wsvint.motcamp.dedprm       =  ctxstat.motcamp.dedprm     
      wsvint.motcamp.dadprm       =  ctxstat.motcamp.dadprm     
      wsvint.motcamp.dpdprm       =  ctxstat.motcamp.dpdprm     
      wsvint.motcamp.fletper      =  ctxstat.motcamp.fletper    
      wsvint.motcamp.ncbyrs       =  ctxstat.motcamp.ncbyrs     
      wsvint.motcamp.ncbper       =  ctxstat.motcamp.ncbper     
      wsvint.motcamp.dspcper      =  ctxstat.motcamp.dspcper    
      wsvint.motcamp.dspcamt      =  ctxstat.motcamp.dspcamt    
      wsvint.motcamp.stfper       =  ctxstat.motcamp.stfper      
      wsvint.motcamp.stfamt       =  ctxstat.motcamp.stfamt      
      wsvint.motcamp.clmper       =  ctxstat.motcamp.clmper     
      wsvint.motcamp.polmst       =  ctxstat.motcamp.polmst     
      wsvint.motcamp.cctv         =  ctxstat.motcamp.cctv       
      wsvint.motcamp.cctvcd       =  ctxstat.motcamp.cctvcd     
      wsvint.motcamp.cctvper      =  ctxstat.motcamp.cctvper    
      wsvint.motcamp.cctvamt      =  ctxstat.motcamp.cctvamt    
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes 
      wsvint.motcamp.promcod[1]   =  ctxstat.motcamp.promcod[1] 
      wsvint.motcamp.promnam[1]   =  ctxstat.motcamp.promnam[1] 
      wsvint.motcamp.plancod      =  ctxstat.motcamp.plancod    
      wsvint.motcamp.planno       =  ctxstat.motcamp.planno     
      wsvint.motcamp.plannam      =  ctxstat.motcamp.plannam    
      wsvint.motcamp.effdat       =  ctxstat.motcamp.effdat     
      wsvint.motcamp.expdat       =  ctxstat.motcamp.expdat     
      wsvint.motcamp.entdat       =  ctxstat.motcamp.entdat     
      wsvint.motcamp.enttim       =  ctxstat.motcamp.enttim     
      wsvint.motcamp.usrid        =  ctxstat.motcamp.usrid      
      wsvint.motcamp.remark       =  ctxstat.motcamp.remark     
      wsvint.motcamp.spflag       =  ctxstat.motcamp.spflag     
      wsvint.motcamp.TransDate    =  ctxstat.motcamp.TransDate  
      wsvint.motcamp.TransTime    =  ctxstat.motcamp.TransTime  
      wsvint.motcamp.TransId      =  ctxstat.motcamp.TransId    
      wsvint.motcamp.TransFlag    =  ctxstat.motcamp.TransFlag  
      wsvint.motcamp.ctxt1        =  ctxstat.motcamp.ctxt1      
      wsvint.motcamp.ctxt2        =  ctxstat.motcamp.ctxt2      
      wsvint.motcamp.ctxt3        =  ctxstat.motcamp.ctxt3      
      wsvint.motcamp.cdate1       =  ctxstat.motcamp.cdate1     
      wsvint.motcamp.cdate2       =  ctxstat.motcamp.cdate2     
      wsvint.motcamp.cdate3       =  ctxstat.motcamp.cdate3     
      wsvint.motcamp.cdec1        =  ctxstat.motcamp.cdec1      
      wsvint.motcamp.cdec2        =  ctxstat.motcamp.cdec2      
      wsvint.motcamp.cdec3        =  ctxstat.motcamp.cdec3      
      wsvint.motcamp.clog1        =  ctxstat.motcamp.clog1      
      wsvint.motcamp.clog2        =  ctxstat.motcamp.clog2      
                                    
      wsvint.motcamp.tpbips       =  ctxstat.motcamp.tpbips    
      wsvint.motcamp.tpbiacc      =  ctxstat.motcamp.tpbiacc   
      wsvint.motcamp.tppdacc      =  ctxstat.motcamp.tppdacc   
      wsvint.motcamp.DeductPd     =  ctxstat.motcamp.DeductPd  
      wsvint.motcamp.SumInsOd     =  ctxstat.motcamp.SumInsOd  
      wsvint.motcamp.DeductOd     =  ctxstat.motcamp.DeductOd  
      wsvint.motcamp.SumInsFt     =  ctxstat.motcamp.SumInsFt  
      wsvint.motcamp.PALifeDriv   =  ctxstat.motcamp.PALifeDriv
      wsvint.motcamp.PALifePass   =  ctxstat.motcamp.PALifePass
      wsvint.motcamp.Seat411      =  ctxstat.motcamp.Seat411
      wsvint.motcamp.Seat412      =  ctxstat.motcamp.Seat412
      wsvint.motcamp.PATempDriv   =  ctxstat.motcamp.PATempDriv  
      wsvint.motcamp.PATempPass   =  ctxstat.motcamp.PATempPass  
      wsvint.motcamp.Seat413      =  ctxstat.motcamp.Seat413                                 
      wsvint.motcamp.Seat414      =  ctxstat.motcamp.Seat414                                          
      wsvint.motcamp.MedicalExp   =  ctxstat.motcamp.MedicalExp  
      wsvint.motcamp.BailBond     =  ctxstat.motcamp.BailBond    
      wsvint.motcamp.Premium1     =  ctxstat.motcamp.Premium1    
                                    
      wsvint.motcamp.Premium2     =  ctxstat.motcamp.Premium2    
      wsvint.motcamp.Premium3     =  ctxstat.motcamp.Premium3    
      wsvint.motcamp.AddPrem      =  ctxstat.motcamp.AddPrem         
      wsvint.motcamp.DedPrem      =  ctxstat.motcamp.DedPrem       * -1      
      wsvint.motcamp.FleetPrem    =  ctxstat.motcamp.FleetPrem     * -1    
      wsvint.motcamp.NcbPrem      =  ctxstat.motcamp.NcbPrem       * -1     
      wsvint.motcamp.DiscPrem     =  ctxstat.motcamp.DiscPrem      * -1    
      wsvint.motcamp.TotDiscPrem  =  ctxstat.motcamp.TotDiscPrem   * -1  
      wsvint.motcamp.ClaimPrem    =  ctxstat.motcamp.ClaimPrem     * -1  
      wsvint.motcamp.NetPrem      =  ctxstat.motcamp.NetPrem     
      wsvint.motcamp.Stamp        =  ctxstat.motcamp.Stamp       
      wsvint.motcamp.Tax          =  ctxstat.motcamp.Tax         
                                    
      wsvint.motcamp.GrossPrem    =  ctxstat.motcamp.GrossPrem 
      wsvint.motcamp.AttachText   =  ctxstat.motcamp.AttachText
      wsvint.motcamp.UseText      =  ctxstat.motcamp.UseText   
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText 
      wsvint.motcamp.DayCover     =  ctxstat.motcamp.DayCover  
      wsvint.motcamp.TPCover1     =  ctxstat.motcamp.TPCover1  
      wsvint.motcamp.TPCover2     =  ctxstat.motcamp.TPCover2  
      wsvint.motcamp.TPCover3     =  ctxstat.motcamp.TPCover3  
      wsvint.motcamp.DeductOd1    =  ctxstat.motcamp.DeductOd1 
      wsvint.motcamp.DeductOd2    =  ctxstat.motcamp.DeductOd2 
      wsvint.motcamp.DeductPd1    =  ctxstat.motcamp.DeductPd1 
      wsvint.motcamp.DeductPd2    =  ctxstat.motcamp.DeductPd2 
      wsvint.motcamp.SumIns1      =  ctxstat.motcamp.SumIns1   
      wsvint.motcamp.SumIns2      =  ctxstat.motcamp.SumIns2   
      wsvint.motcamp.SumIns3      =  ctxstat.motcamp.SumIns3   
      wsvint.motcamp.PACover1     =  ctxstat.motcamp.PACover1  
                                    
      wsvint.motcamp.PACover2     =  ctxstat.motcamp.PACover2  
      wsvint.motcamp.PACover3     =  ctxstat.motcamp.PACover3  
      wsvint.motcamp.PACover4     =  ctxstat.motcamp.PACover4  
      wsvint.motcamp.PACover5     =  ctxstat.motcamp.PACover5  
      wsvint.motcamp.Premium4     =  ctxstat.motcamp.Premium4  
      wsvint.motcamp.Premium5     =  ctxstat.motcamp.Premium5  
      wsvint.motcamp.Premium6     =  ctxstat.motcamp.Premium6  
      wsvint.motcamp.OthDisc1     =  ctxstat.motcamp.OthDisc1  
      wsvint.motcamp.OthDisc2     =  ctxstat.motcamp.OthDisc2  
      wsvint.motcamp.OthDisc3     =  ctxstat.motcamp.OthDisc3  
      wsvint.motcamp.OthSurc1     =  ctxstat.motcamp.OthSurc1  
      wsvint.motcamp.OthSurc2     =  ctxstat.motcamp.OthSurc2  
      wsvint.motcamp.OthText1     =  ctxstat.motcamp.OthText1  
      wsvint.motcamp.OthText2     =  ctxstat.motcamp.OthText2  
      wsvint.motcamp.OthText3     =  ctxstat.motcamp.OthText3  
      wsvint.motcamp.StatusFlg1   =  ctxstat.motcamp.StatusFlg1
      wsvint.motcamp.StatusFlg2   =  ctxstat.motcamp.StatusFlg2
      wsvint.motcamp.UpdDate      =  ctxstat.motcamp.UpdDate   
      wsvint.motcamp.UpdTime      =  ctxstat.motcamp.UpdTime   
      wsvint.motcamp.UpdUsrID     =  ctxstat.motcamp.UpdUsrID  
      wsvint.motcamp.UpdFlag      =  ctxstat.motcamp.UpdFlag   
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn     
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh     
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn  
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh  
      wsvint.motcamp.codedet      =  ctxstat.motcamp.codedet   
      wsvint.motcamp.codedes      =  ctxstat.motcamp.codedes   
      wsvint.motcamp.modelflg     =  ctxstat.motcamp.modelflg 
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh    
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn    
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn 
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh 
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes  
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText
      wsvint.motcamp.effectivedate = ctxstat.motcamp.effectivedate
      wsvint.motcamp.expirydate    = ctxstat.motcamp.expirydate   
      wsvint.motcamp.keyid         = ctxstat.motcamp.keyid .

      n_camcod                     = ctxstat.motcamp.camcod  . /*Thitirat M. A65-0016 09/03/2023*/
      n_camnam                     = ctxstat.motcamp.camnam  . /*Thitirat M. A65-0016 09/03/2023*/
      n_effectivedate              = ctxstat.motcamp.effectivedate   . /*Thitirat M. A65-0016 16/06/2023*/  
      n_expirydate                 = ctxstat.motcamp.expirydate      . /*Thitirat M. A65-0016 16/06/2023*/ 

  
  END.
  /*MESSAGE "PDTransWsvint1 OK " a "," b VIEW-AS ALERT-BOX.*/

END.
ELSE DO:  /*กรณีมีข้อมูลที่ wsvint.motcamp */
    
    RUN PDTransWsvint2. 

END.
RELEASE wsvint.motcamp.
/**/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDTransWsvint2 C-Win 
PROCEDURE PDTransWsvint2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: PDTransWsvint2      
------------------------------------------------------------------------------*/
DEF VAR c AS INTE.
DEF VAR d AS INTE.

n_camcod   = ""  . /*Thitirat M. A65-0016 09/03/2023*/   
n_camnam   = ""  . /*Thitirat M. A65-0016 09/03/2023*/

n_effectivedate  = ""  . /*Thitirat M. A65-0016 16/06/2023*/  
n_expirydate     = ""  . /*Thitirat M. A65-0016 16/06/2023*/ 



  FOR EACH wsvint.motcamp USE-INDEX motcam01 WHERE wsvint.motcamp.camcod  = fi_camp .  /* DELETE wsvint.motcamp เพื่อ CREATE ใหม่*/

    DELETE wsvint.motcamp.

  END.

  FOR EACH ctxstat.motcamp USE-INDEX motcamp02  WHERE   
           ctxstat.motcamp.camcod   = fi_camp   .

  
  c = c + 1.
  CREATE wsvint.motcamp.
  ASSIGN
      wsvint.motcamp.camcod       =  ctxstat.motcamp.camcod   
      wsvint.motcamp.camnam       =  ctxstat.motcamp.camnam   
      wsvint.motcamp.paccod       =  ctxstat.motcamp.paccod   
      wsvint.motcamp.class        =  ctxstat.motcamp.class    
      wsvint.motcamp.sclass       =  ctxstat.motcamp.sclass   
      wsvint.motcamp.covcod       =  ctxstat.motcamp.covcod   
      wsvint.motcamp.vehgrp       =  ctxstat.motcamp.vehgrp   
      wsvint.motcamp.vehuse       =  ctxstat.motcamp.vehuse   
      wsvint.motcamp.garage       =  ctxstat.motcamp.garage   
      wsvint.motcamp.mincst       =  ctxstat.motcamp.mincst   
      wsvint.motcamp.maxcst       =  ctxstat.motcamp.maxcst   
      wsvint.motcamp.makeyr       =  ctxstat.motcamp.makeyr   
      wsvint.motcamp.makedes      =  ctxstat.motcamp.makedes  
      wsvint.motcamp.modeldes     =  ctxstat.motcamp.modeldes 
      wsvint.motcamp.bodydes      =  ctxstat.motcamp.bodydes 
      wsvint.motcamp.doorno       =  ctxstat.motcamp.doorno     
      wsvint.motcamp.engine       =  ctxstat.motcamp.engine     
      wsvint.motcamp.seats        =  ctxstat.motcamp.seats      
      wsvint.motcamp.tons         =  ctxstat.motcamp.tons       
      wsvint.motcamp.simin        =  ctxstat.motcamp.simin      
      wsvint.motcamp.simax        =  ctxstat.motcamp.simax      
      wsvint.motcamp.access       =  ctxstat.motcamp.access     
      wsvint.motcamp.accsi        =  ctxstat.motcamp.accsi      
      wsvint.motcamp.accprm       =  ctxstat.motcamp.accprm     
      wsvint.motcamp.drivnam      =  ctxstat.motcamp.drivnam    
      wsvint.motcamp.drivno       =  ctxstat.motcamp.drivno     
      wsvint.motcamp.drivage1min  =  ctxstat.motcamp.drivage1min
      wsvint.motcamp.drivage1max  =  ctxstat.motcamp.drivage1max
      wsvint.motcamp.drivage2min  =  ctxstat.motcamp.drivage2min
      wsvint.motcamp.drivage2max  =  ctxstat.motcamp.drivage2max
                                    
      wsvint.motcamp.drivprm      =  ctxstat.motcamp.drivprm    
      wsvint.motcamp.baseprm      =  ctxstat.motcamp.baseprm    
      wsvint.motcamp.baseprm3     =  ctxstat.motcamp.baseprm3   
      wsvint.motcamp.dedod        =  ctxstat.motcamp.dedod      
      wsvint.motcamp.dedad        =  ctxstat.motcamp.dedad      
      wsvint.motcamp.dedpd        =  ctxstat.motcamp.dedpd      
      wsvint.motcamp.dedprm       =  ctxstat.motcamp.dedprm     
      wsvint.motcamp.dadprm       =  ctxstat.motcamp.dadprm     
      wsvint.motcamp.dpdprm       =  ctxstat.motcamp.dpdprm     
      wsvint.motcamp.fletper      =  ctxstat.motcamp.fletper    
      wsvint.motcamp.ncbyrs       =  ctxstat.motcamp.ncbyrs     
      wsvint.motcamp.ncbper       =  ctxstat.motcamp.ncbper     
      wsvint.motcamp.dspcper      =  ctxstat.motcamp.dspcper    
      wsvint.motcamp.dspcamt      =  ctxstat.motcamp.dspcamt    
      wsvint.motcamp.stfper       =  ctxstat.motcamp.stfper      
      wsvint.motcamp.stfamt       =  ctxstat.motcamp.stfamt      
      wsvint.motcamp.clmper       =  ctxstat.motcamp.clmper     
      wsvint.motcamp.polmst       =  ctxstat.motcamp.polmst     
      wsvint.motcamp.cctv         =  ctxstat.motcamp.cctv       
      wsvint.motcamp.cctvcd       =  ctxstat.motcamp.cctvcd     
      wsvint.motcamp.cctvper      =  ctxstat.motcamp.cctvper    
      wsvint.motcamp.cctvamt      =  ctxstat.motcamp.cctvamt    
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes 
      wsvint.motcamp.promcod[1]   =  ctxstat.motcamp.promcod[1] 
      wsvint.motcamp.promnam[1]   =  ctxstat.motcamp.promnam[1] 
      wsvint.motcamp.plancod      =  ctxstat.motcamp.plancod    
      wsvint.motcamp.planno       =  ctxstat.motcamp.planno     
      wsvint.motcamp.plannam      =  ctxstat.motcamp.plannam    
      wsvint.motcamp.effdat       =  ctxstat.motcamp.effdat     
      wsvint.motcamp.expdat       =  ctxstat.motcamp.expdat     
      wsvint.motcamp.entdat       =  ctxstat.motcamp.entdat     
      wsvint.motcamp.enttim       =  ctxstat.motcamp.enttim     
      wsvint.motcamp.usrid        =  ctxstat.motcamp.usrid      
      wsvint.motcamp.remark       =  ctxstat.motcamp.remark     
      wsvint.motcamp.spflag       =  ctxstat.motcamp.spflag     
      wsvint.motcamp.TransDate    =  ctxstat.motcamp.TransDate  
      wsvint.motcamp.TransTime    =  ctxstat.motcamp.TransTime  
      wsvint.motcamp.TransId      =  ctxstat.motcamp.TransId    
      wsvint.motcamp.TransFlag    =  ctxstat.motcamp.TransFlag  
      wsvint.motcamp.ctxt1        =  ctxstat.motcamp.ctxt1      
      wsvint.motcamp.ctxt2        =  ctxstat.motcamp.ctxt2      
      wsvint.motcamp.ctxt3        =  ctxstat.motcamp.ctxt3      
      wsvint.motcamp.cdate1       =  ctxstat.motcamp.cdate1     
      wsvint.motcamp.cdate2       =  ctxstat.motcamp.cdate2     
      wsvint.motcamp.cdate3       =  ctxstat.motcamp.cdate3     
      wsvint.motcamp.cdec1        =  ctxstat.motcamp.cdec1      
      wsvint.motcamp.cdec2        =  ctxstat.motcamp.cdec2      
      wsvint.motcamp.cdec3        =  ctxstat.motcamp.cdec3      
      wsvint.motcamp.clog1        =  ctxstat.motcamp.clog1      
      wsvint.motcamp.clog2        =  ctxstat.motcamp.clog2      
                                    
      wsvint.motcamp.tpbips       =  ctxstat.motcamp.tpbips    
      wsvint.motcamp.tpbiacc      =  ctxstat.motcamp.tpbiacc   
      wsvint.motcamp.tppdacc      =  ctxstat.motcamp.tppdacc   
      wsvint.motcamp.DeductPd     =  ctxstat.motcamp.DeductPd  
      wsvint.motcamp.SumInsOd     =  ctxstat.motcamp.SumInsOd  
      wsvint.motcamp.DeductOd     =  ctxstat.motcamp.DeductOd  
      wsvint.motcamp.SumInsFt     =  ctxstat.motcamp.SumInsFt  
      wsvint.motcamp.PALifeDriv   =  ctxstat.motcamp.PALifeDriv
      wsvint.motcamp.PALifePass   =  ctxstat.motcamp.PALifePass
      wsvint.motcamp.Seat411      =  ctxstat.motcamp.Seat411
      wsvint.motcamp.Seat412      =  ctxstat.motcamp.Seat412
      wsvint.motcamp.PATempDriv   =  ctxstat.motcamp.PATempDriv  
      wsvint.motcamp.PATempPass   =  ctxstat.motcamp.PATempPass  
      wsvint.motcamp.Seat413      =  ctxstat.motcamp.Seat413                                 
      wsvint.motcamp.Seat414      =  ctxstat.motcamp.Seat414                                          
      wsvint.motcamp.MedicalExp   =  ctxstat.motcamp.MedicalExp  
      wsvint.motcamp.BailBond     =  ctxstat.motcamp.BailBond    
      wsvint.motcamp.Premium1     =  ctxstat.motcamp.Premium1    
                                    
      wsvint.motcamp.Premium2     =  ctxstat.motcamp.Premium2    
      wsvint.motcamp.Premium3     =  ctxstat.motcamp.Premium3    
      wsvint.motcamp.AddPrem      =  ctxstat.motcamp.AddPrem         
      wsvint.motcamp.DedPrem      =  ctxstat.motcamp.DedPrem       * -1      
      wsvint.motcamp.FleetPrem    =  ctxstat.motcamp.FleetPrem     * -1    
      wsvint.motcamp.NcbPrem      =  ctxstat.motcamp.NcbPrem       * -1     
      wsvint.motcamp.DiscPrem     =  ctxstat.motcamp.DiscPrem      * -1    
      wsvint.motcamp.TotDiscPrem  =  ctxstat.motcamp.TotDiscPrem   * -1  
      wsvint.motcamp.ClaimPrem    =  ctxstat.motcamp.ClaimPrem     * -1  
      wsvint.motcamp.NetPrem      =  ctxstat.motcamp.NetPrem     
      wsvint.motcamp.Stamp        =  ctxstat.motcamp.Stamp       
      wsvint.motcamp.Tax          =  ctxstat.motcamp.Tax         
                                    
      wsvint.motcamp.GrossPrem    =  ctxstat.motcamp.GrossPrem 
      wsvint.motcamp.AttachText   =  ctxstat.motcamp.AttachText
      wsvint.motcamp.UseText      =  ctxstat.motcamp.UseText   
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText 
      wsvint.motcamp.DayCover     =  ctxstat.motcamp.DayCover  
      wsvint.motcamp.TPCover1     =  ctxstat.motcamp.TPCover1  
      wsvint.motcamp.TPCover2     =  ctxstat.motcamp.TPCover2  
      wsvint.motcamp.TPCover3     =  ctxstat.motcamp.TPCover3  
      wsvint.motcamp.DeductOd1    =  ctxstat.motcamp.DeductOd1 
      wsvint.motcamp.DeductOd2    =  ctxstat.motcamp.DeductOd2 
      wsvint.motcamp.DeductPd1    =  ctxstat.motcamp.DeductPd1 
      wsvint.motcamp.DeductPd2    =  ctxstat.motcamp.DeductPd2 
      wsvint.motcamp.SumIns1      =  ctxstat.motcamp.SumIns1   
      wsvint.motcamp.SumIns2      =  ctxstat.motcamp.SumIns2   
      wsvint.motcamp.SumIns3      =  ctxstat.motcamp.SumIns3   
      wsvint.motcamp.PACover1     =  ctxstat.motcamp.PACover1  
                                    
      wsvint.motcamp.PACover2     =  ctxstat.motcamp.PACover2  
      wsvint.motcamp.PACover3     =  ctxstat.motcamp.PACover3  
      wsvint.motcamp.PACover4     =  ctxstat.motcamp.PACover4  
      wsvint.motcamp.PACover5     =  ctxstat.motcamp.PACover5  
      wsvint.motcamp.Premium4     =  ctxstat.motcamp.Premium4  
      wsvint.motcamp.Premium5     =  ctxstat.motcamp.Premium5  
      wsvint.motcamp.Premium6     =  ctxstat.motcamp.Premium6  
      wsvint.motcamp.OthDisc1     =  ctxstat.motcamp.OthDisc1  
      wsvint.motcamp.OthDisc2     =  ctxstat.motcamp.OthDisc2  
      wsvint.motcamp.OthDisc3     =  ctxstat.motcamp.OthDisc3  
      wsvint.motcamp.OthSurc1     =  ctxstat.motcamp.OthSurc1  
      wsvint.motcamp.OthSurc2     =  ctxstat.motcamp.OthSurc2  
      wsvint.motcamp.OthText1     =  ctxstat.motcamp.OthText1  
      wsvint.motcamp.OthText2     =  ctxstat.motcamp.OthText2  
      wsvint.motcamp.OthText3     =  ctxstat.motcamp.OthText3  
      wsvint.motcamp.StatusFlg1   =  ctxstat.motcamp.StatusFlg1
      wsvint.motcamp.StatusFlg2   =  ctxstat.motcamp.StatusFlg2
      wsvint.motcamp.UpdDate      =  ctxstat.motcamp.UpdDate   
      wsvint.motcamp.UpdTime      =  ctxstat.motcamp.UpdTime   
      wsvint.motcamp.UpdUsrID     =  ctxstat.motcamp.UpdUsrID  
      wsvint.motcamp.UpdFlag      =  ctxstat.motcamp.UpdFlag   
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn     
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh     
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn  
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh  
      wsvint.motcamp.codedet      =  ctxstat.motcamp.codedet   
      wsvint.motcamp.codedes      =  ctxstat.motcamp.codedes   
      wsvint.motcamp.modelflg     =  ctxstat.motcamp.modelflg 
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh    
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn    
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn 
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh 
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes  
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText
      wsvint.motcamp.effectivedate = ctxstat.motcamp.effectivedate
      wsvint.motcamp.expirydate    = ctxstat.motcamp.expirydate   
      wsvint.motcamp.keyid         = ctxstat.motcamp.keyid .

      n_camcod                     = ctxstat.motcamp.camcod  . /*Thitirat M. A65-0016 09/03/2023*/                             
      n_camnam                     = ctxstat.motcamp.camnam  . /*Thitirat M. A65-0016 09/03/2023*/ 
      n_effectivedate              = ctxstat.motcamp.effectivedate   . /*Thitirat M. A65-0016 16/06/2023*/  
      n_expirydate                 = ctxstat.motcamp.expirydate      . /*Thitirat M. A65-0016 16/06/2023*/ 




  
  END.
  /*MESSAGE "PDTransWsvint2 OK " c "," d VIEW-AS ALERT-BOX.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDTransWsvint3 C-Win 
PROCEDURE PDTransWsvint3 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:  PDTransWsvint     
------------------------------------------------------------------------------*/
DEF VAR a AS INTE.
DEF VAR b AS INTE.

n_camcod   = ""  . /*Thitirat M. A65-0016 09/03/2023*/   
n_camnam   = ""  . /*Thitirat M. A65-0016 09/03/2023*/ 

n_effectivedate  = ""  . /*Thitirat M. A65-0016 16/06/2023*/  
n_expirydate     = ""  . /*Thitirat M. A65-0016 16/06/2023*/ 
n_cntcod-2 = 0. /*Lukkana M. 24/03/2025 A68-00057*/ 

FIND FIRST wsvint.motcamp  USE-INDEX motcam01 WHERE /* Lukkana M. 26/03/2025 A68-0057*/
           wsvint.motcamp.camcod    = fi_camp NO-ERROR.
IF NOT AVAIL wsvint.motcamp THEN DO:

  FOR EACH ctxstat.motcamp USE-INDEX motcamp02  WHERE   
           ctxstat.motcamp.camcod   = fi_camp   .

  /*Lukkana M. 24/03/2025*/
  FIND FIRST wsvint.motcamp USE-INDEX motcam02 WHERE 
             wsvint.motcamp.camcod    =  ctxstat.motcamp.camcod  AND
             wsvint.motcamp.sclass    =  ctxstat.motcamp.sclass  AND 
             wsvint.motcamp.makeyr    =  ctxstat.motcamp.makeyr  AND
             wsvint.motcamp.simin     =  ctxstat.motcamp.simin   AND     
             wsvint.motcamp.simax     =  ctxstat.motcamp.simax   AND  
             wsvint.motcamp.mincst    =  ctxstat.motcamp.mincst  AND   
             wsvint.motcamp.maxcst    =  ctxstat.motcamp.maxcst  /*AND
             wsvint.motcamp.engine    =  ctxstat.motcamp.engine  AND     
             wsvint.motcamp.seats     =  ctxstat.motcamp.seats   AND     
             wsvint.motcamp.tons      =  ctxstat.motcamp.tons  */  NO-ERROR.
  IF NOT AVAIL wsvint.motcamp THEN DO: 
  /*Lukkana M. 24/03/2025*/ 

  n_cntcod-2 = n_cntcod-2 + 1. 
  /*Lukkana M. 24/03/2025*/ 

  a = a + 1.
  CREATE wsvint.motcamp.
  ASSIGN
      wsvint.motcamp.camcod       =  ctxstat.motcamp.camcod   
      wsvint.motcamp.camnam       =  ctxstat.motcamp.camnam   
      wsvint.motcamp.paccod       =  ctxstat.motcamp.paccod   
      wsvint.motcamp.class        =  ctxstat.motcamp.class    
      wsvint.motcamp.sclass       =  ctxstat.motcamp.sclass   
      wsvint.motcamp.covcod       =  ctxstat.motcamp.covcod   
      wsvint.motcamp.vehgrp       =  ctxstat.motcamp.vehgrp   
      wsvint.motcamp.vehuse       =  ctxstat.motcamp.vehuse   
      wsvint.motcamp.garage       =  ctxstat.motcamp.garage   
      wsvint.motcamp.mincst       =  ctxstat.motcamp.mincst   
      wsvint.motcamp.maxcst       =  ctxstat.motcamp.maxcst   
      wsvint.motcamp.makeyr       =  ctxstat.motcamp.makeyr   
      /*wsvint.motcamp.makedes      =  ctxstat.motcamp.makedes  
      wsvint.motcamp.modeldes     =  ctxstat.motcamp.modeldes */
      wsvint.motcamp.makedes      =  ""
      wsvint.motcamp.modeldes     =  ""
      wsvint.motcamp.bodydes      =  ctxstat.motcamp.bodydes 
      wsvint.motcamp.doorno       =  ctxstat.motcamp.doorno     
      wsvint.motcamp.engine       =  ctxstat.motcamp.engine     
      wsvint.motcamp.seats        =  ctxstat.motcamp.seats      
      wsvint.motcamp.tons         =  ctxstat.motcamp.tons       
      wsvint.motcamp.simin        =  ctxstat.motcamp.simin      
      wsvint.motcamp.simax        =  ctxstat.motcamp.simax      
      wsvint.motcamp.access       =  ctxstat.motcamp.access     
      wsvint.motcamp.accsi        =  ctxstat.motcamp.accsi      
      wsvint.motcamp.accprm       =  ctxstat.motcamp.accprm     
      wsvint.motcamp.drivnam      =  ctxstat.motcamp.drivnam    
      wsvint.motcamp.drivno       =  ctxstat.motcamp.drivno     
      wsvint.motcamp.drivage1min  =  ctxstat.motcamp.drivage1min
      wsvint.motcamp.drivage1max  =  ctxstat.motcamp.drivage1max
      wsvint.motcamp.drivage2min  =  ctxstat.motcamp.drivage2min
      wsvint.motcamp.drivage2max  =  ctxstat.motcamp.drivage2max
                                    
      wsvint.motcamp.drivprm      =  ctxstat.motcamp.drivprm    
      wsvint.motcamp.baseprm      =  ctxstat.motcamp.baseprm    
      wsvint.motcamp.baseprm3     =  ctxstat.motcamp.baseprm3   
      wsvint.motcamp.dedod        =  ctxstat.motcamp.dedod      
      wsvint.motcamp.dedad        =  ctxstat.motcamp.dedad      
      wsvint.motcamp.dedpd        =  ctxstat.motcamp.dedpd      
      wsvint.motcamp.dedprm       =  ctxstat.motcamp.dedprm     
      wsvint.motcamp.dadprm       =  ctxstat.motcamp.dadprm     
      wsvint.motcamp.dpdprm       =  ctxstat.motcamp.dpdprm     
      wsvint.motcamp.fletper      =  ctxstat.motcamp.fletper    
      wsvint.motcamp.ncbyrs       =  ctxstat.motcamp.ncbyrs     
      wsvint.motcamp.ncbper       =  ctxstat.motcamp.ncbper     
      wsvint.motcamp.dspcper      =  ctxstat.motcamp.dspcper    
      wsvint.motcamp.dspcamt      =  ctxstat.motcamp.dspcamt    
      wsvint.motcamp.stfper       =  ctxstat.motcamp.stfper      
      wsvint.motcamp.stfamt       =  ctxstat.motcamp.stfamt      
      wsvint.motcamp.clmper       =  ctxstat.motcamp.clmper     
      wsvint.motcamp.polmst       =  ctxstat.motcamp.polmst     
      wsvint.motcamp.cctv         =  ctxstat.motcamp.cctv       
      wsvint.motcamp.cctvcd       =  ctxstat.motcamp.cctvcd     
      wsvint.motcamp.cctvper      =  ctxstat.motcamp.cctvper    
      wsvint.motcamp.cctvamt      =  ctxstat.motcamp.cctvamt    
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes 
      wsvint.motcamp.promcod[1]   =  ctxstat.motcamp.promcod[1] 
      wsvint.motcamp.promnam[1]   =  ctxstat.motcamp.promnam[1] 
      wsvint.motcamp.plancod      =  ctxstat.motcamp.plancod    
      wsvint.motcamp.planno       =  ctxstat.motcamp.planno     
      wsvint.motcamp.plannam      =  ctxstat.motcamp.plannam    
      wsvint.motcamp.effdat       =  ctxstat.motcamp.effdat     
      wsvint.motcamp.expdat       =  ctxstat.motcamp.expdat     
      wsvint.motcamp.entdat       =  ctxstat.motcamp.entdat     
      wsvint.motcamp.enttim       =  ctxstat.motcamp.enttim     
      wsvint.motcamp.usrid        =  ctxstat.motcamp.usrid      
      wsvint.motcamp.remark       =  ctxstat.motcamp.remark     
      wsvint.motcamp.spflag       =  ctxstat.motcamp.spflag     
      wsvint.motcamp.TransDate    =  ctxstat.motcamp.TransDate  
      wsvint.motcamp.TransTime    =  ctxstat.motcamp.TransTime  
      wsvint.motcamp.TransId      =  ctxstat.motcamp.TransId    
      wsvint.motcamp.TransFlag    =  ctxstat.motcamp.TransFlag  
      wsvint.motcamp.ctxt1        =  ctxstat.motcamp.ctxt1      
      wsvint.motcamp.ctxt2        =  ctxstat.motcamp.ctxt2      
      wsvint.motcamp.ctxt3        =  ctxstat.motcamp.ctxt3      
      wsvint.motcamp.cdate1       =  ctxstat.motcamp.cdate1     
      wsvint.motcamp.cdate2       =  ctxstat.motcamp.cdate2     
      wsvint.motcamp.cdate3       =  ctxstat.motcamp.cdate3     
      wsvint.motcamp.cdec1        =  ctxstat.motcamp.cdec1      
      wsvint.motcamp.cdec2        =  ctxstat.motcamp.cdec2      
      wsvint.motcamp.cdec3        =  ctxstat.motcamp.cdec3      
      wsvint.motcamp.clog1        =  ctxstat.motcamp.clog1      
      wsvint.motcamp.clog2        =  ctxstat.motcamp.clog2      
                                    
      wsvint.motcamp.tpbips       =  ctxstat.motcamp.tpbips    
      wsvint.motcamp.tpbiacc      =  ctxstat.motcamp.tpbiacc   
      wsvint.motcamp.tppdacc      =  ctxstat.motcamp.tppdacc   
      wsvint.motcamp.DeductPd     =  ctxstat.motcamp.DeductPd  
      wsvint.motcamp.SumInsOd     =  ctxstat.motcamp.SumInsOd  
      wsvint.motcamp.DeductOd     =  ctxstat.motcamp.DeductOd  
      wsvint.motcamp.SumInsFt     =  ctxstat.motcamp.SumInsFt  
      wsvint.motcamp.PALifeDriv   =  ctxstat.motcamp.PALifeDriv
      wsvint.motcamp.PALifePass   =  ctxstat.motcamp.PALifePass
      wsvint.motcamp.Seat411      =  ctxstat.motcamp.Seat411
      wsvint.motcamp.Seat412      =  ctxstat.motcamp.Seat412
      wsvint.motcamp.PATempDriv   =  ctxstat.motcamp.PATempDriv  
      wsvint.motcamp.PATempPass   =  ctxstat.motcamp.PATempPass  
      wsvint.motcamp.Seat413      =  ctxstat.motcamp.Seat413                                 
      wsvint.motcamp.Seat414      =  ctxstat.motcamp.Seat414                                          
      wsvint.motcamp.MedicalExp   =  ctxstat.motcamp.MedicalExp  
      wsvint.motcamp.BailBond     =  ctxstat.motcamp.BailBond    
      wsvint.motcamp.Premium1     =  ctxstat.motcamp.Premium1    
                                    
      wsvint.motcamp.Premium2     =  ctxstat.motcamp.Premium2    
      wsvint.motcamp.Premium3     =  ctxstat.motcamp.Premium3    
      wsvint.motcamp.AddPrem      =  ctxstat.motcamp.AddPrem         
      wsvint.motcamp.DedPrem      =  ctxstat.motcamp.DedPrem       * -1      
      wsvint.motcamp.FleetPrem    =  ctxstat.motcamp.FleetPrem     * -1    
      wsvint.motcamp.NcbPrem      =  ctxstat.motcamp.NcbPrem       * -1     
      wsvint.motcamp.DiscPrem     =  ctxstat.motcamp.DiscPrem      * -1    
      wsvint.motcamp.TotDiscPrem  =  ctxstat.motcamp.TotDiscPrem   * -1  
      wsvint.motcamp.ClaimPrem    =  ctxstat.motcamp.ClaimPrem     * -1  
      wsvint.motcamp.NetPrem      =  ctxstat.motcamp.NetPrem     
      wsvint.motcamp.Stamp        =  ctxstat.motcamp.Stamp       
      wsvint.motcamp.Tax          =  ctxstat.motcamp.Tax         
                                    
      wsvint.motcamp.GrossPrem    =  ctxstat.motcamp.GrossPrem 
      wsvint.motcamp.AttachText   =  ctxstat.motcamp.AttachText
      wsvint.motcamp.UseText      =  ctxstat.motcamp.UseText   
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText 
      wsvint.motcamp.DayCover     =  ctxstat.motcamp.DayCover  
      wsvint.motcamp.TPCover1     =  ctxstat.motcamp.TPCover1  
      wsvint.motcamp.TPCover2     =  ctxstat.motcamp.TPCover2  
      wsvint.motcamp.TPCover3     =  ctxstat.motcamp.TPCover3  
      wsvint.motcamp.DeductOd1    =  ctxstat.motcamp.DeductOd1 
      wsvint.motcamp.DeductOd2    =  ctxstat.motcamp.DeductOd2 
      wsvint.motcamp.DeductPd1    =  ctxstat.motcamp.DeductPd1 
      wsvint.motcamp.DeductPd2    =  ctxstat.motcamp.DeductPd2 
      wsvint.motcamp.SumIns1      =  ctxstat.motcamp.SumIns1   
      wsvint.motcamp.SumIns2      =  ctxstat.motcamp.SumIns2   
      wsvint.motcamp.SumIns3      =  ctxstat.motcamp.SumIns3   
      wsvint.motcamp.PACover1     =  ctxstat.motcamp.PACover1  
                                    
      wsvint.motcamp.PACover2     =  ctxstat.motcamp.PACover2  
      wsvint.motcamp.PACover3     =  ctxstat.motcamp.PACover3  
      wsvint.motcamp.PACover4     =  ctxstat.motcamp.PACover4  
      wsvint.motcamp.PACover5     =  ctxstat.motcamp.PACover5  
      wsvint.motcamp.Premium4     =  ctxstat.motcamp.Premium4  
      wsvint.motcamp.Premium5     =  ctxstat.motcamp.Premium5  
      wsvint.motcamp.Premium6     =  ctxstat.motcamp.Premium6  
      wsvint.motcamp.OthDisc1     =  ctxstat.motcamp.OthDisc1  
      wsvint.motcamp.OthDisc2     =  ctxstat.motcamp.OthDisc2  
      wsvint.motcamp.OthDisc3     =  ctxstat.motcamp.OthDisc3  
      wsvint.motcamp.OthSurc1     =  ctxstat.motcamp.OthSurc1  
      wsvint.motcamp.OthSurc2     =  ctxstat.motcamp.OthSurc2  
      wsvint.motcamp.OthText1     =  ctxstat.motcamp.OthText1  
      wsvint.motcamp.OthText2     =  ctxstat.motcamp.OthText2  
      wsvint.motcamp.OthText3     =  ctxstat.motcamp.OthText3  
      wsvint.motcamp.StatusFlg1   =  ctxstat.motcamp.StatusFlg1
      wsvint.motcamp.StatusFlg2   =  ctxstat.motcamp.StatusFlg2
      wsvint.motcamp.UpdDate      =  ctxstat.motcamp.UpdDate   
      wsvint.motcamp.UpdTime      =  ctxstat.motcamp.UpdTime   
      wsvint.motcamp.UpdUsrID     =  ctxstat.motcamp.UpdUsrID  
      wsvint.motcamp.UpdFlag      =  ctxstat.motcamp.UpdFlag   
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn     
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh     
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn  
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh  
      wsvint.motcamp.codedet      =  ctxstat.motcamp.codedet   
      wsvint.motcamp.codedes      =  ctxstat.motcamp.codedes   
      wsvint.motcamp.modelflg     =  ctxstat.motcamp.modelflg 
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh    
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn    
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn 
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh 
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes  
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText
      wsvint.motcamp.effectivedate = ctxstat.motcamp.effectivedate
      wsvint.motcamp.expirydate    = ctxstat.motcamp.expirydate   
      wsvint.motcamp.keyid         = ctxstat.motcamp.keyid .

      n_camcod                     = ctxstat.motcamp.camcod  . /*Thitirat M. A65-0016 09/03/2023*/
      n_camnam                     = ctxstat.motcamp.camnam  . /*Thitirat M. A65-0016 09/03/2023*/
      n_effectivedate              = ctxstat.motcamp.effectivedate   . /*Thitirat M. A65-0016 16/06/2023*/  
      n_expirydate                 = ctxstat.motcamp.expirydate      . /*Thitirat M. A65-0016 16/06/2023*/ 


  END.
  
  END.
  /*MESSAGE "PDTransWsvint1 OK " a "," b VIEW-AS ALERT-BOX.*/

END.
ELSE DO:  /*กรณีมีข้อมูลที่ wsvint.motcamp */
    
    RUN PDTransWsvint4. 

END.
RELEASE wsvint.motcamp.
/**/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PDTransWsvint4 C-Win 
PROCEDURE PDTransWsvint4 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes: PDTransWsvint2      
------------------------------------------------------------------------------*/
DEF VAR c AS INTE.
DEF VAR d AS INTE.

n_camcod   = ""  . /*Thitirat M. A65-0016 09/03/2023*/   
n_camnam   = ""  . /*Thitirat M. A65-0016 09/03/2023*/

n_effectivedate  = ""  . /*Thitirat M. A65-0016 16/06/2023*/  
n_expirydate     = ""  . /*Thitirat M. A65-0016 16/06/2023*/ 

DEF VAR nv_i AS INTE INIT 0.

n_cntcod-2 = 0. /*Lukkana M. 24/03/2025 A68-00057*/ 

  FOR EACH wsvint.motcamp USE-INDEX motcam01 WHERE wsvint.motcamp.camcod  = fi_camp .  /* DELETE wsvint.motcamp เพื่อ CREATE ใหม่*/
    nv_i = nv_i + 1.
    DELETE wsvint.motcamp.
  END.

  
  FOR EACH ctxstat.motcamp USE-INDEX motcamp02  WHERE   
           ctxstat.motcamp.camcod   = fi_camp   .

  /*Lukkana M. 24/03/2025*/
  FIND FIRST wsvint.motcamp USE-INDEX motcam02 WHERE 
             wsvint.motcamp.camcod    =  ctxstat.motcamp.camcod  AND
             wsvint.motcamp.sclass    =  ctxstat.motcamp.sclass  AND 
             wsvint.motcamp.makeyr    =  ctxstat.motcamp.makeyr  AND
             wsvint.motcamp.simin     =  ctxstat.motcamp.simin   AND     
             wsvint.motcamp.simax     =  ctxstat.motcamp.simax   AND  
             wsvint.motcamp.mincst    =  ctxstat.motcamp.mincst  AND   
             wsvint.motcamp.maxcst    =  ctxstat.motcamp.maxcst /* AND
             wsvint.motcamp.engine    =  ctxstat.motcamp.engine  AND     
             wsvint.motcamp.seats     =  ctxstat.motcamp.seats   AND     
             wsvint.motcamp.tons      =  ctxstat.motcamp.tons  */  NO-ERROR.
               
  IF NOT AVAIL wsvint.motcamp THEN DO: 
     
  n_cntcod-2 = n_cntcod-2 + 1.  
  /*Lukkana M. 24/03/2025 A68-00057*/ 

  c = c + 1.
  CREATE wsvint.motcamp.
  ASSIGN
      wsvint.motcamp.camcod       =  ctxstat.motcamp.camcod   
      wsvint.motcamp.camnam       =  ctxstat.motcamp.camnam   
      wsvint.motcamp.paccod       =  ctxstat.motcamp.paccod   
      wsvint.motcamp.class        =  ctxstat.motcamp.class    
      wsvint.motcamp.sclass       =  ctxstat.motcamp.sclass   
      wsvint.motcamp.covcod       =  ctxstat.motcamp.covcod   
      wsvint.motcamp.vehgrp       =  ctxstat.motcamp.vehgrp   
      wsvint.motcamp.vehuse       =  ctxstat.motcamp.vehuse   
      wsvint.motcamp.garage       =  ctxstat.motcamp.garage   
      wsvint.motcamp.mincst       =  ctxstat.motcamp.mincst   
      wsvint.motcamp.maxcst       =  ctxstat.motcamp.maxcst   
      wsvint.motcamp.makeyr       =  ctxstat.motcamp.makeyr   
      wsvint.motcamp.makedes      =  "" 
      wsvint.motcamp.modeldes     =  ""
      wsvint.motcamp.bodydes      =  ctxstat.motcamp.bodydes 
      wsvint.motcamp.doorno       =  ctxstat.motcamp.doorno     
      wsvint.motcamp.engine       =  ctxstat.motcamp.engine     
      wsvint.motcamp.seats        =  ctxstat.motcamp.seats      
      wsvint.motcamp.tons         =  ctxstat.motcamp.tons       
      wsvint.motcamp.simin        =  ctxstat.motcamp.simin      
      wsvint.motcamp.simax        =  ctxstat.motcamp.simax      
      wsvint.motcamp.access       =  ctxstat.motcamp.access     
      wsvint.motcamp.accsi        =  ctxstat.motcamp.accsi      
      wsvint.motcamp.accprm       =  ctxstat.motcamp.accprm     
      wsvint.motcamp.drivnam      =  ctxstat.motcamp.drivnam    
      wsvint.motcamp.drivno       =  ctxstat.motcamp.drivno     
      wsvint.motcamp.drivage1min  =  ctxstat.motcamp.drivage1min
      wsvint.motcamp.drivage1max  =  ctxstat.motcamp.drivage1max
      wsvint.motcamp.drivage2min  =  ctxstat.motcamp.drivage2min
      wsvint.motcamp.drivage2max  =  ctxstat.motcamp.drivage2max
                                    
      wsvint.motcamp.drivprm      =  ctxstat.motcamp.drivprm    
      wsvint.motcamp.baseprm      =  ctxstat.motcamp.baseprm    
      wsvint.motcamp.baseprm3     =  ctxstat.motcamp.baseprm3   
      wsvint.motcamp.dedod        =  ctxstat.motcamp.dedod      
      wsvint.motcamp.dedad        =  ctxstat.motcamp.dedad      
      wsvint.motcamp.dedpd        =  ctxstat.motcamp.dedpd      
      wsvint.motcamp.dedprm       =  ctxstat.motcamp.dedprm     
      wsvint.motcamp.dadprm       =  ctxstat.motcamp.dadprm     
      wsvint.motcamp.dpdprm       =  ctxstat.motcamp.dpdprm     
      wsvint.motcamp.fletper      =  ctxstat.motcamp.fletper    
      wsvint.motcamp.ncbyrs       =  ctxstat.motcamp.ncbyrs     
      wsvint.motcamp.ncbper       =  ctxstat.motcamp.ncbper     
      wsvint.motcamp.dspcper      =  ctxstat.motcamp.dspcper    
      wsvint.motcamp.dspcamt      =  ctxstat.motcamp.dspcamt    
      wsvint.motcamp.stfper       =  ctxstat.motcamp.stfper      
      wsvint.motcamp.stfamt       =  ctxstat.motcamp.stfamt      
      wsvint.motcamp.clmper       =  ctxstat.motcamp.clmper     
      wsvint.motcamp.polmst       =  ctxstat.motcamp.polmst     
      wsvint.motcamp.cctv         =  ctxstat.motcamp.cctv       
      wsvint.motcamp.cctvcd       =  ctxstat.motcamp.cctvcd     
      wsvint.motcamp.cctvper      =  ctxstat.motcamp.cctvper    
      wsvint.motcamp.cctvamt      =  ctxstat.motcamp.cctvamt    
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes 
      wsvint.motcamp.promcod[1]   =  ctxstat.motcamp.promcod[1] 
      wsvint.motcamp.promnam[1]   =  ctxstat.motcamp.promnam[1] 
      wsvint.motcamp.plancod      =  ctxstat.motcamp.plancod    
      wsvint.motcamp.planno       =  ctxstat.motcamp.planno     
      wsvint.motcamp.plannam      =  ctxstat.motcamp.plannam    
      wsvint.motcamp.effdat       =  ctxstat.motcamp.effdat     
      wsvint.motcamp.expdat       =  ctxstat.motcamp.expdat     
      wsvint.motcamp.entdat       =  ctxstat.motcamp.entdat     
      wsvint.motcamp.enttim       =  ctxstat.motcamp.enttim     
      wsvint.motcamp.usrid        =  ctxstat.motcamp.usrid      
      wsvint.motcamp.remark       =  ctxstat.motcamp.remark     
      wsvint.motcamp.spflag       =  ctxstat.motcamp.spflag     
      wsvint.motcamp.TransDate    =  ctxstat.motcamp.TransDate  
      wsvint.motcamp.TransTime    =  ctxstat.motcamp.TransTime  
      wsvint.motcamp.TransId      =  ctxstat.motcamp.TransId    
      wsvint.motcamp.TransFlag    =  ctxstat.motcamp.TransFlag  
      wsvint.motcamp.ctxt1        =  ctxstat.motcamp.ctxt1      
      wsvint.motcamp.ctxt2        =  ctxstat.motcamp.ctxt2      
      wsvint.motcamp.ctxt3        =  ctxstat.motcamp.ctxt3      
      wsvint.motcamp.cdate1       =  ctxstat.motcamp.cdate1     
      wsvint.motcamp.cdate2       =  ctxstat.motcamp.cdate2     
      wsvint.motcamp.cdate3       =  ctxstat.motcamp.cdate3     
      wsvint.motcamp.cdec1        =  ctxstat.motcamp.cdec1      
      wsvint.motcamp.cdec2        =  ctxstat.motcamp.cdec2      
      wsvint.motcamp.cdec3        =  ctxstat.motcamp.cdec3      
      wsvint.motcamp.clog1        =  ctxstat.motcamp.clog1      
      wsvint.motcamp.clog2        =  ctxstat.motcamp.clog2      
                                    
      wsvint.motcamp.tpbips       =  ctxstat.motcamp.tpbips    
      wsvint.motcamp.tpbiacc      =  ctxstat.motcamp.tpbiacc   
      wsvint.motcamp.tppdacc      =  ctxstat.motcamp.tppdacc   
      wsvint.motcamp.DeductPd     =  ctxstat.motcamp.DeductPd  
      wsvint.motcamp.SumInsOd     =  ctxstat.motcamp.SumInsOd  
      wsvint.motcamp.DeductOd     =  ctxstat.motcamp.DeductOd  
      wsvint.motcamp.SumInsFt     =  ctxstat.motcamp.SumInsFt  
      wsvint.motcamp.PALifeDriv   =  ctxstat.motcamp.PALifeDriv
      wsvint.motcamp.PALifePass   =  ctxstat.motcamp.PALifePass
      wsvint.motcamp.Seat411      =  ctxstat.motcamp.Seat411
      wsvint.motcamp.Seat412      =  ctxstat.motcamp.Seat412
      wsvint.motcamp.PATempDriv   =  ctxstat.motcamp.PATempDriv  
      wsvint.motcamp.PATempPass   =  ctxstat.motcamp.PATempPass  
      wsvint.motcamp.Seat413      =  ctxstat.motcamp.Seat413                                 
      wsvint.motcamp.Seat414      =  ctxstat.motcamp.Seat414                                          
      wsvint.motcamp.MedicalExp   =  ctxstat.motcamp.MedicalExp  
      wsvint.motcamp.BailBond     =  ctxstat.motcamp.BailBond    
      wsvint.motcamp.Premium1     =  ctxstat.motcamp.Premium1    
                                    
      wsvint.motcamp.Premium2     =  ctxstat.motcamp.Premium2    
      wsvint.motcamp.Premium3     =  ctxstat.motcamp.Premium3    
      wsvint.motcamp.AddPrem      =  ctxstat.motcamp.AddPrem         
      wsvint.motcamp.DedPrem      =  ctxstat.motcamp.DedPrem       * -1      
      wsvint.motcamp.FleetPrem    =  ctxstat.motcamp.FleetPrem     * -1    
      wsvint.motcamp.NcbPrem      =  ctxstat.motcamp.NcbPrem       * -1     
      wsvint.motcamp.DiscPrem     =  ctxstat.motcamp.DiscPrem      * -1    
      wsvint.motcamp.TotDiscPrem  =  ctxstat.motcamp.TotDiscPrem   * -1  
      wsvint.motcamp.ClaimPrem    =  ctxstat.motcamp.ClaimPrem     * -1  
      wsvint.motcamp.NetPrem      =  ctxstat.motcamp.NetPrem     
      wsvint.motcamp.Stamp        =  ctxstat.motcamp.Stamp       
      wsvint.motcamp.Tax          =  ctxstat.motcamp.Tax         
                                    
      wsvint.motcamp.GrossPrem    =  ctxstat.motcamp.GrossPrem 
      wsvint.motcamp.AttachText   =  ctxstat.motcamp.AttachText
      wsvint.motcamp.UseText      =  ctxstat.motcamp.UseText   
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText 
      wsvint.motcamp.DayCover     =  ctxstat.motcamp.DayCover  
      wsvint.motcamp.TPCover1     =  ctxstat.motcamp.TPCover1  
      wsvint.motcamp.TPCover2     =  ctxstat.motcamp.TPCover2  
      wsvint.motcamp.TPCover3     =  ctxstat.motcamp.TPCover3  
      wsvint.motcamp.DeductOd1    =  ctxstat.motcamp.DeductOd1 
      wsvint.motcamp.DeductOd2    =  ctxstat.motcamp.DeductOd2 
      wsvint.motcamp.DeductPd1    =  ctxstat.motcamp.DeductPd1 
      wsvint.motcamp.DeductPd2    =  ctxstat.motcamp.DeductPd2 
      wsvint.motcamp.SumIns1      =  ctxstat.motcamp.SumIns1   
      wsvint.motcamp.SumIns2      =  ctxstat.motcamp.SumIns2   
      wsvint.motcamp.SumIns3      =  ctxstat.motcamp.SumIns3   
      wsvint.motcamp.PACover1     =  ctxstat.motcamp.PACover1  
                                    
      wsvint.motcamp.PACover2     =  ctxstat.motcamp.PACover2  
      wsvint.motcamp.PACover3     =  ctxstat.motcamp.PACover3  
      wsvint.motcamp.PACover4     =  ctxstat.motcamp.PACover4  
      wsvint.motcamp.PACover5     =  ctxstat.motcamp.PACover5  
      wsvint.motcamp.Premium4     =  ctxstat.motcamp.Premium4  
      wsvint.motcamp.Premium5     =  ctxstat.motcamp.Premium5  
      wsvint.motcamp.Premium6     =  ctxstat.motcamp.Premium6  
      wsvint.motcamp.OthDisc1     =  ctxstat.motcamp.OthDisc1  
      wsvint.motcamp.OthDisc2     =  ctxstat.motcamp.OthDisc2  
      wsvint.motcamp.OthDisc3     =  ctxstat.motcamp.OthDisc3  
      wsvint.motcamp.OthSurc1     =  ctxstat.motcamp.OthSurc1  
      wsvint.motcamp.OthSurc2     =  ctxstat.motcamp.OthSurc2  
      wsvint.motcamp.OthText1     =  ctxstat.motcamp.OthText1  
      wsvint.motcamp.OthText2     =  ctxstat.motcamp.OthText2  
      wsvint.motcamp.OthText3     =  ctxstat.motcamp.OthText3  
      wsvint.motcamp.StatusFlg1   =  ctxstat.motcamp.StatusFlg1
      wsvint.motcamp.StatusFlg2   =  ctxstat.motcamp.StatusFlg2
      wsvint.motcamp.UpdDate      =  ctxstat.motcamp.UpdDate   
      wsvint.motcamp.UpdTime      =  ctxstat.motcamp.UpdTime   
      wsvint.motcamp.UpdUsrID     =  ctxstat.motcamp.UpdUsrID  
      wsvint.motcamp.UpdFlag      =  ctxstat.motcamp.UpdFlag   
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn     
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh     
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn  
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh  
      wsvint.motcamp.codedet      =  ctxstat.motcamp.codedet   
      wsvint.motcamp.codedes      =  ctxstat.motcamp.codedes   
      wsvint.motcamp.modelflg     =  ctxstat.motcamp.modelflg 
      wsvint.motcamp.UseTh        =  ctxstat.motcamp.UseTh    
      wsvint.motcamp.UseEn        =  ctxstat.motcamp.UseEn    
      wsvint.motcamp.AttachEn     =  ctxstat.motcamp.AttachEn 
      wsvint.motcamp.AttachTh     =  ctxstat.motcamp.AttachTh 
      wsvint.motcamp.cctvdes      =  ctxstat.motcamp.cctvdes  
      wsvint.motcamp.OtherText    =  ctxstat.motcamp.OtherText
      wsvint.motcamp.effectivedate = ctxstat.motcamp.effectivedate
      wsvint.motcamp.expirydate    = ctxstat.motcamp.expirydate   
      wsvint.motcamp.keyid         = ctxstat.motcamp.keyid .

      n_camcod                     = ctxstat.motcamp.camcod  . /*Thitirat M. A65-0016 09/03/2023*/                             
      n_camnam                     = ctxstat.motcamp.camnam  . /*Thitirat M. A65-0016 09/03/2023*/ 
      n_effectivedate              = ctxstat.motcamp.effectivedate   . /*Thitirat M. A65-0016 16/06/2023*/  
      n_expirydate                 = ctxstat.motcamp.expirydate      . /*Thitirat M. A65-0016 16/06/2023*/ 




  END.
  END.
  /*MESSAGE "PDTransWsvint2 OK " c "," d VIEW-AS ALERT-BOX.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

