
SESSION:SET-WAIT-STATE("WAIT").

DO ON ERROR UNDO, LEAVE:

/* =========================
   Connect Databases
   ========================= */
    IF NOT CONNECTED ("sicsyac") THEN
        CONNECT sicsyac -H DEVSERVER -S 9010 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("siccl") THEN
        CONNECT siccl -H DEVSERVER -S 9020 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("sicuw") THEN
        CONNECT sicuw -H DEVSERVER -S 9030 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("stat") THEN
        CONNECT stat -H DEVSERVER -S 9040 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("gw_safe") THEN
        CONNECT gw_safe -H 10.35.176.37 -S 10020 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.
        
/* =========================
   Log connection result
   ========================= */        
   OUTPUT TO "D:\WebOS\CampaignPublish\Log\ConnectSML.txt" APPEND.
   PUT STRING(TODAY,"99/99/9999") " " STRING(TIME,"HH:MM:SS")
       " : CONNECT RESULT -> "
       "sicuw=" CONNECTED("sicuw")
       ", siccl=" CONNECTED("siccl")
       ", sicsyac=" CONNECTED("sicsyac")
       ", stat=" CONNECTED("stat")
       ", gw_safe=" CONNECTED("gw_safe")
       SKIP.
   OUTPUT CLOSE.
/* =========================
  Check all required DBs
  ========================= */
    IF CONNECTED("sicuw")      AND
       CONNECTED("siccl")       AND 
       CONNECTED("sicsyac")    AND 
       CONNECTED("stat")        AND
       CONNECTED("gw_safe")       THEN DO:    
       /* RUN background program (non-interactive) */
        RUN WUW\WUWSMLPRM.r    NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
            OUTPUT TO "D:\WebOS\CampaignPublish\Log\smlcamcon.log" APPEND.
            PUT STRING(TODAY,"99/99/9999") " " STRING(TIME,"HH:MM:SS")
                " : ERROR RUN WUWSMLPRM -> "
                ERROR-STATUS:GET-MESSAGE(1)
                SKIP.
            OUTPUT CLOSE.
            LEAVE.
        END.
    END.
    ELSE DO:
            OUTPUT TO "D:\WebOS\CampaignPublish\Log\ConnectSML.txt" APPEND.
            PUT STRING(TODAY,"99/99/9999") " " STRING(TIME,"HH:MM:SS")
                " : CONNECT FAIL (one or more DB not connected)"
                SKIP.
            OUTPUT CLOSE.
            LEAVE.
    END.    
END. /* DO ON ERROR */

/* =========================
   Disconnect (always)
   ========================= */
OUTPUT TO "D:\WebOS\CampaignPublish\Log\ConnectSML.txt" APPEND.
PUT STRING(TODAY,"99/99/9999") " " STRING(TIME,"HH:MM:SS")
    " : DISCONNECT Smiley Program"
    SKIP.
OUTPUT CLOSE.

IF CONNECTED("sicuw")   THEN DISCONNECT VALUE("sicuw").
IF CONNECTED("siccl")   THEN DISCONNECT VALUE("siccl").
IF CONNECTED("sicsyac") THEN DISCONNECT VALUE("sicsyac").
IF CONNECTED("stat")    THEN DISCONNECT VALUE("stat").
IF CONNECTED("gw_safe") THEN DISCONNECT VALUE("gw_safe").

SESSION:SET-WAIT-STATE("").
RETURN.
