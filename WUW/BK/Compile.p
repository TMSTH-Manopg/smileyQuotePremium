 /*- -*/
IF NOT CONNECTED ("sicsyac") THEN
        CONNECT sicsyac -H DEVSERVER -S 9010 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("siccl") THEN
        CONNECT siccl -H DEVSERVER -S 9020 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("sicuw") THEN
        CONNECT sicuw -H DEVSERVER -S 9030 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("stat") THEN
        CONNECT stat -H DEVSERVER -S 9040 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.

    IF NOT CONNECTED ("gw_safe") THEN
        CONNECT gw_safe -H DEVSERVER -S 10020 -N TCP -U pdmgr0 -P pdmgr0 NO-ERROR.
        

// Connect GW - 
COMPILE D:\smileyquote\smileyquote.p  SAVE  .
COMPILE D:\smileyquote\WUW\WUWSMLCAM.p SAVE. 
COMPILE D:\smileyquote\WUW\WUWSMLPRM.p SAVE. 
COMPILE D:\smileyquote\WUW\WUWSMLRES.p SAVE. 
//   
COMPILE D:\smileyquote\smileyquote.p   SAVE  INTO D:\WebWSKFK12.
// COMPILE D:\smileyquote\WUW\WUWSMLCAM.p SAVE INTO D:\WebWSKFK12\WUW. 
