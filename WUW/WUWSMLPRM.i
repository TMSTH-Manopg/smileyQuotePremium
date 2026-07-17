

DEFINE TEMP-TABLE tFile
    FIELD compno    AS CHAR   FORMAT "X(20)"
    FIELD campcd    AS CHAR   FORMAT "X(30)"
    FIELD polmst    AS CHAR   FORMAT "X(20)"
    FIELD pack      AS CHAR   FORMAT "X(2)"
    FIELD sclass    AS CHAR   FORMAT "X(5)"
    FIELD covcod    AS CHAR   FORMAT "X(4)"
    FIELD vehgrp    AS CHAR   FORMAT "X(2)"
    FIELD vehuse    AS CHAR   FORMAT "X(2)"
    FIELD garage    AS CHAR   FORMAT "X(2)"
    FIELD makdes    AS CHAR   FORMAT "X(40)"
    FIELD moddes    AS CHAR   FORMAT "X(100)"
    FIELD cstw      AS CHAR   FORMAT "X(2)"
    FIELD minyrs    AS DECI   FORMAT "->>9.99"
    FIELD maxyrs    AS DECI   FORMAT "->>9.99"
    FIELD mincstw   AS DECI   FORMAT "->>>,>>9.99"
    FIELD maxcstw   AS DECI   FORMAT "->>>,>>9.99"
    FIELD minsi     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD maxsi     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD drivnam   AS LOGICAL
    FIELD drivno    AS INTE   FORMAT ">>9"
    FIELD drivage1  AS INTE   FORMAT ">>9"
    FIELD drivage2  AS INTE   FORMAT ">>9"
    FIELD uom6_u    AS CHAR   FORMAT "X(4)"
    FIELD cctv      AS LOGICAL
    FIELD uom1_v    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD uom2_v    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD uom5_v    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD seat41    AS INTE   FORMAT ">>9"
    FIELD mv411     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD mv412     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD mv413     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD mv414     AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD mv42      AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD mv43      AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD dedod     AS DECI   FORMAT "->>>,>>9.99"
    FIELD dedad     AS DECI   FORMAT "->>>,>>9.99"
    FIELD dedpd     AS DECI   FORMAT "->>>,>>9.99"
    FIELD fletper   AS DECI   FORMAT "->>9.99"
    FIELD ncbyrs    AS DECI   FORMAT "->>9.99"
    FIELD ncbper    AS DECI   FORMAT "->>9.99"
    FIELD dspcper   AS DECI   FORMAT "->>9.99"
    FIELD clmper    AS DECI   FORMAT "->>>9.99"
    FIELD dstfper   AS DECI   FORMAT "->>9.99"
    FIELD baseprm1  AS DECI   FORMAT "->>>,>>9.99"
    FIELD mainprm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD useprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD engprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD drivprm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD yrsprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD othprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD siprm     AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD grpprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD uom1vprm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD uom2vprm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD uom5vprm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD mv411prm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD mv412prm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD mv413prm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD mv414prm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD mv42prm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD mv43prm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD dedodprm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD dedadprm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD dedpdprm  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD fletprm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD ncbprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD dspcprm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD clmprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD dstfprm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD siplus    AS DECI   FORMAT "->>>,>>>,>>9.99"
    FIELD baseprm3  AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD prem3     AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD use3prm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD eng3prm   AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD si3prm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD netprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD pdprm     AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD adjprm    AS DECI   FORMAT "->>,>>9.99"
    FIELD stamp     AS DECI   FORMAT "->>,>>9.99"
    FIELD vat       AS DECI   FORMAT "->>>,>>9.99"
    FIELD totprm    AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD shortrate AS LOGICAL
    FIELD days      AS INTE   FORMAT "->>9"
    FIELD newpd     AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD newgap    AS DECI   FORMAT "->,>>>,>>9.99"     
    FIELD levcod    AS INTE
    FIELD levper    AS DECI   FORMAT "->>>9.99"
    FIELD chargsi   AS INTE   FORMAT "->>>>>>>9"
    FIELD chargrate AS DECI   FORMAT "->>>9.99999"
    FIELD chgnetprm AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD chggapprm AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD battyr    AS INTE   FORMAT "9999"
    FIELD battprice AS INTE   FORMAT "->>>>>>>9"
    FIELD battsi    AS INTE   FORMAT "->>>>>>>9"
    FIELD battrate  AS DECI   FORMAT "->>>9.99999"
    FIELD batnetprm AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD batgapprm AS DECI   FORMAT "->,>>>,>>9.99"
    FIELD drinomin  AS INTE   FORMAT ">9"
    FIELD drinomax  AS INTE   FORMAT ">9"
    FIELD rate31    AS DECI   FORMAT "->>9.9999"
    FIELD prem31    AS DECI   FORMAT "->,>>>,>>9.99" 
    FIELD EffectiveDDate   AS CHAR   FORMAT "X(20)"
    FIELD ExpireDate       AS CHAR   FORMAT "X(20)"
    FIELD CampName         AS CHAR   FORMAT "X(60)"
    FIELD remark    AS CHAR
    FIELD adjprm1   AS DECI
    FIELD cstamp    AS DECI   FORMAT "->>,>>9.99"
    FIELD cvat      AS DECI   FORMAT "->>>,>>9.99"
    FIELD ctotprm   AS DECI   FORMAT "->,>>>,>>9.99"    .

DEFINE VAR nv_usrid   AS CHAR FORMAT "X(10)".
    
DEFINE NEW  SHARED VAR nv_engine LIKE sicsyac.xmm102.engine FORMAT ">>>9".   
DEFINE NEW  SHARED VAR nv_seats  LIKE sicsyac.xmm102.seats.
DEFINE NEW  SHARED VAR nv_tons   LIKE sicsyac.xmm102.tons.
DEFINE NEW  SHARED VAR nv_watts  AS DECI.   

DEFINE NEW  SHARED VAR nv_class  AS CHAR FORMAT "X(4)".

DEFINE VAR nv_evflg    AS LOGICAL INIT NO.
DEFINE VAR nv_battflg  AS LOGICAL INIT NO.
DEFINE VAR nv_chargflg AS LOGICAL INIT NO.
DEFINE VAR nv_fgtariff AS LOGICAL INIT NO.

DEFINE VAR nv_entdat   AS DATE FORMAT 99/99/9999.
DEFINE VAR nv_enttim   AS CHAR FORMAT "X(10)".
DEFINE VAR nv_totdedct AS INTEGER   FORMAT ">>,>>>,>>9-"   INITIAL 0  NO-UNDO.
DEFINE VAR nv_totdisc  AS INTEGER   FORMAT ">>,>>>,>>9-"   INITIAL 0  NO-UNDO.
DEFINE NEW  SHARED VAR nv_comdat LIKE sicuw.uwm100.comdat.
DEFINE NEW  SHARED VAR nv_expdat LIKE sicuw.uwm100.expdat.

DEFINE NEW  SHARED VAR nv_tariff LIKE sicuw.uwm301.tariff.
DEFINE VAR nv_supeflag AS LOGICAL.
DEFINE VAR nv_riskno   AS INTE.
DEFINE VAR nv_itemno   AS INTE.
DEFINE VAR nv_accname  AS CHAR FORMAT "X(60)".
DEFINE VAR nv_AccountCd AS CHAR FORMAT "X(60)".
DEFINE VAR nv_branch    AS CHAR FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_count1  AS INTE INITIAL 0.   // Total
DEFINE NEW SHARED VAR nv_count2  AS INTE INITIAL 0.   // Err
DEFINE NEW SHARED VAR nv_count3  AS INTE INITIAL 0.   // Complete
DEFINE NEW  SHARED VAR nv_addprm     AS INTEGER   FORMAT ">>>,>>>,>>9"    INITIAL 0  NO-UNDO.    /*--- A59-0095 ---*/

DEFINE NEW  SHARED VAR nv_uom1_v LIKE sicuw.uwm130.uom1_v.
DEFINE NEW  SHARED VAR nv_uom2_v LIKE sicuw.uwm130.uom2_v.
DEFINE NEW  SHARED VAR nv_uom5_v LIKE sicuw.uwm130.uom5_v.
DEFINE NEW  SHARED VAR nv_uom6_v LIKE sicuw.uwm130.uom6_v.
DEFINE NEW  SHARED VAR nv_uom7_v LIKE sicuw.uwm130.uom7_v.
DEFINE NEW  SHARED VAR nv_uom8_v LIKE sicuw.uwm130.uom8_v.
DEFINE NEW  SHARED VAR nv_uom9_v LIKE sicuw.uwm130.uom9_v.

DEFINE VAR nv_ckbatyr  AS INTE. /*A67-0029*/

DEFINE VAR nv_calflg   AS LOGICAL INIT NO.

DEFINE VAR nv_mainprm  AS DECI FORMAT ">>>,>>>,>>9.99-". 
DEFINE VAR nv_msg  AS CHAR FORMAT "X(60)".
DEFINE             VAR n_comdat   LIKE sicuw.uwm100.comdat.
DEFINE NEW  SHARED VAR n_policy   LIKE sicuw.uwm100.policy.
DEFINE NEW  SHARED VAR n_rencnt   LIKE sicuw.uwm100.rencnt.
DEFINE NEW  SHARED VAR n_endcnt   LIKE sicuw.uwm100.endcnt.
DEFINE NEW  SHARED VAR nv_prmpac AS CHAR FORMAT "X(1)".
DEFINE NEW  SHARED VAR nv_campcd AS CHAR FORMAT "X(40)".
DEFINE NEW  SHARED VAR nv_covcod LIKE sicuw.uwm301.covcod.
DEFINE NEW  SHARED VAR nv_sclass   AS CHAR FORMAT "X(3)".
DEFINE NEW SHARED VAR nv_pdprm31  AS DECI FORMAT "->,>>>,>>9.99". 
DEFINE NEW SHARED VAR nv_gapprm31 AS DECI FORMAT "->,>>>,>>9.99". 
DEFINE NEW SHARED VAR nv_31cod    AS CHAR FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_31var1   AS CHAR FORMAT "X(30)".
DEFINE NEW SHARED VAR nv_31var2   AS CHAR FORMAT "X(30)".
DEFINE NEW SHARED VAR nv_31var    AS CHAR FORMAT "X(60)".
/*--Add A68-0158 --*/
DEFINE NEW SHARED VAR nv_engcod3   AS CHAR  FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_engprm3   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW SHARED VAR nv_engvar3   AS CHAR  FORMAT "X(30)".
DEFINE NEW SHARED VAR nv_engvar4   AS CHAR  FORMAT "X(30)".
DEFINE NEW SHARED VAR nv_engvar5   AS CHAR  FORMAT "X(60)".

DEFINE NEW  SHARED VAR nv_gapprm   AS DECI  FORMAT ">>,>>>,>>9.99-"  INITIAL 0  NO-UNDO.
DEFINE NEW  SHARED VAR nv_pdprm    AS DECI  FORMAT ">>,>>>,>>9.99-"  INITIAL 0  NO-UNDO  .
DEFINE NEW  SHARED VAR nv_prvprm   AS DECI  FORMAT ">>,>>>,>>9.99-".

DEFINE VAR nv_levcod      AS INTE.
DEFINE VAR nv_levper      AS DECI FORMAT "->>>9.99".
DEFINE VAR nv_chargsi     AS INTE FORMAT "->>>>>>>9".
DEFINE VAR nv_chargrate   AS DECI FORMAT "->>>9.99999".
DEFINE VAR nv_chgnetprm   AS DECI FORMAT "->,>>>,>>9.99".
DEFINE VAR nv_chggapprm   AS DECI FORMAT "->,>>>,>>9.99".
DEFINE VAR nv_battyr      AS INTE FORMAT "9999".
DEFINE VAR nv_battprice   AS INTE FORMAT "->>>>>>>9".
DEFINE VAR nv_battper     AS DECI.
DEFINE VAR nv_battsi      AS INTE FORMAT "->>>>>>>9".
DEFINE VAR nv_battrate    AS DECI FORMAT "->>>9.99999".
DEFINE VAR nv_batnetprm   AS DECI FORMAT "->,>>>,>>9.99".
DEFINE VAR nv_batgapprm   AS DECI FORMAT "->,>>>,>>9.99".
DEFINE VAR nv_drinomin    AS INTE FORMAT ">9".
DEFINE VAR nv_drinomax    AS INTE FORMAT ">9".
DEFINE VAR nv_rate31      AS DECI FORMAT "->>9.9999".
DEFINE VAR nv_prem31      AS DECI FORMAT "->,>>>,>>9.99".

DEFINE NEW  SHARED VAR nv_polday   AS INTE  FORMAT ">>9".
DEFINE NEW  SHARED VAR nv_compcod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_compprm  AS DECI  FORMAT ">>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_compvar1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_compvar2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_compvar  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_basecod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_baseprm  AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_basevar1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_basevar2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_basevar  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_usecod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_useprm   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_usevar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_usevar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_usevar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_grpcod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_grprm    AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_grpvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_grpvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_grpvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_yrcod    AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_yrprm    AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_yrvar1   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_yrvar2   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_yrvar    AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_othcod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_othprm   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_othvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_othvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_othvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_sicod    AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_siprm    AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_sivar1   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_sivar2   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_sivar    AS CHAR  FORMAT "X(60)".

DEFINE NEW  SHARED VAR nv_totlcod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_totlprm  AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_totlvar1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_totlvar2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_totlvar  AS CHAR  FORMAT "X(60)".

DEFINE NEW  SHARED VAR nv_engcod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_engprm   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_engvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_engvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_engvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_drivcod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_drivprm  AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_drivvar1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_drivvar2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_drivvar  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_bipcod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_bipprm   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_bipvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_bipvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_bipvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_biacod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_biaprm   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_biavar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_biavar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_biavar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_pdacod   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_pdaprm   AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_pdavar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_pdavar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_pdavar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_41cod1   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_41cod2   AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_41       AS INTE  FORMAT ">>>,>>>,>>9".
DEFINE NEW  SHARED VAR nv_seat41   AS INTE  FORMAT ">>9".
DEFINE NEW  SHARED VAR nv_411prm   AS DECI  FORMAT ">,>>>,>>9.99".
DEFINE NEW  SHARED VAR nv_412prm   AS DECI  FORMAT ">,>>>,>>9.99".
DEFINE NEW  SHARED VAR nv_411var1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_411var2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_411var   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_412var1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_412var2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_412var   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_42cod    AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_42       AS INTE  FORMAT ">>>,>>>,>>9".
DEFINE NEW  SHARED VAR nv_42prm    AS DECI  FORMAT ">,>>>,>>9.99".
DEFINE NEW  SHARED VAR nv_42var1   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_42var2   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_42var    AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_43cod    AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_43       AS INTE  FORMAT ">>>,>>>,>>9".
DEFINE NEW  SHARED VAR nv_43prm    AS DECI  FORMAT ">,>>>,>>9.99".
DEFINE NEW  SHARED VAR nv_43var1   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_43var2   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_43var    AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_dedod1_cod AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_dedod1_prm AS DECI  FORMAT ">,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_dedod1var1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dedod1var2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dedod1var  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_dedod2_cod AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_dedod2_prm AS DECI  FORMAT ">,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_dedod2var1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dedod2var2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dedod2var  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_dedpd_cod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_dedpd_prm  AS DECI  FORMAT ">,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_dedpdvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dedpdvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dedpdvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_flet_per   AS DECI  FORMAT ">>9".
DEFINE NEW  SHARED VAR nv_flet       AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_fletvar1   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_fletvar2   AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_fletvar    AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_ncbper     LIKE sicuw.uwm301.ncbper.
DEFINE NEW  SHARED VAR nv_ncb        AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_ncbvar1    AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_ncbvar2    AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_ncbvar     AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_dss_per    AS DECI  FORMAT ">9.99".
DEFINE NEW  SHARED VAR nv_dsspc      AS INTE  FORMAT ">>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_dsspcvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dsspcvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_dsspcvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_stf_per  AS DECI  FORMAT ">9.99".
DEFINE NEW  SHARED VAR nv_stf_amt  AS INTE  FORMAT ">>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_stfvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_stfvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_stfvar   AS CHAR  FORMAT "X(60)".

DEFINE NEW  SHARED VAR nv_cl_per   AS DECI  FORMAT ">>>9.99".  /*A58-0096*/
DEFINE NEW  SHARED VAR nv_lodclm   AS INTE  FORMAT ">>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_clmvar1  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_clmvar2  AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_clmvar   AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_campcod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_camprem  AS DECI  FORMAT ">>>9".
DEFINE NEW  SHARED VAR nv_campvar1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_campvar2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_campvar  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_newrec   AS LOGICAL.
DEFINE NEW  SHARED VAR nv_yrold    LIKE sicuw.uwm301.yrmanu.
DEFINE             VAR nv_count    AS INTEGER INITIAL 0.
DEFINE             VAR nv_chk      AS LOGIC.
DEFINE             VAR nv_chk3     AS LOGIC.
DEFINE             VAR nv_baseap   AS DECIMAL FORMAT ">>>,>>9".
DEFINE             VAR nv_carsi    AS DECI FORMAT ">>,>>>,>>9.99-".
DEFINE             VAR nv_chkmail  AS CHARACTER FORMAT "X(30)" INITIAL "".
DEFINE             VAR nv_usridveh AS CHARACTER NO-UNDO.
DEFINE             VAR nv_function AS CHARACTER NO-UNDO.
DEFINE NEW  SHARED VAR s_type      AS CHAR FORMAT "X(4)".

DEFINE NEW  SHARED VAR nv_supecod  AS CHAR  FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_supeprm  AS DECI  FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_supevar1 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_supevar2 AS CHAR  FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_supevar  AS CHAR  FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_supe     AS LOGICAL INIT NO.
DEFINE NEW  SHARED VAR nv_supe00   AS DECI  FORMAT ">>,>>>,>>9.99-".

DEFINE NEW  SHARED VAR nv_44cod1      AS CHAR     FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_44cod2      AS CHAR     FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_44          AS INTE     FORMAT ">>>,>>>,>>9".
DEFINE NEW  SHARED VAR nv_413prm      AS DECI     FORMAT ">,>>>,>>9.99".
DEFINE NEW  SHARED VAR nv_413var1     AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_413var2     AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_413var      AS CHAR     FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_414prm      AS DECI     FORMAT ">,>>>,>>9.99".
DEFINE NEW  SHARED VAR nv_414var1     AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_414var2     AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_414var      AS CHAR     FORMAT "X(60)".

DEFINE NEW  SHARED VAR nv_inspec      AS CHAR     FORMAT "X" INITIAL "".
DEFINE NEW  SHARED VAR nv_prem3       AS DECIMAL  FORMAT ">,>>>,>>9.99-" INITIAL 0  NO-UNDO.
DEFINE NEW  SHARED VAR nv_sicod3      AS CHAR     FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_usecod3     AS CHAR     FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_siprm3      AS DECI     FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_prvprm3     AS DECI     FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_baseprm3    AS DECI     FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_useprm3     AS DECI     FORMAT ">>,>>>,>>9.99-".
DEFINE NEW  SHARED VAR nv_basecod3    AS CHAR     FORMAT "X(4)".
DEFINE NEW  SHARED VAR nv_basevar3    AS CHAR     FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_basevar4    AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_basevar5    AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_usevar3     AS CHAR     FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_usevar4     AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_usevar5     AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_sivar3      AS CHAR     FORMAT "X(60)".
DEFINE NEW  SHARED VAR nv_sivar4      AS CHAR     FORMAT "X(30)".
DEFINE NEW  SHARED VAR nv_sivar5      AS CHAR     FORMAT "X(30)".

DEFINE NEW SHARED VAR nv_age1     AS INTEGER   FORMAT ">9"            INITIAL 0  NO-UNDO.
DEFINE NEW SHARED VAR nv_age2     AS INTEGER   FORMAT ">9"            INITIAL 0  NO-UNDO.
DEFINE NEW SHARED VAR nv_drivcod1 AS CHAR      FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_drivcod2 AS CHAR      FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_age1rate AS DECI      FORMAT ">>9.99".
DEFINE NEW SHARED VAR nv_age2rate AS DECI      FORMAT ">>9.99".

DEFINE VAR nv_line AS INTE.
DEFINE VAR nv_gap    AS DECI FORMAT ">>>,>>>,>>9.99-".
DEFINE VAR nv_prem_c AS DECI FORMAT ">>>,>>>,>>9.99-".
DEFINE VAR nv_bencod AS CHAR.
DEFINE VAR nv_benvar AS CHAR.
DEFINE VAR n_uom_c   AS CHAR.
DEFINE VAR n_uom_v   AS INTE FORMAT ">>>>>>>>9".
DEFINE VAR nv_chagvar AS CHAR FORMAT "X(30)".
DEFINE VAR nv_battvar AS CHAR FORMAT "X(30)".
DEFINE NEW SHARED VAR nv_attprm    AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_attgap    AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_siattvar  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_siattvar1  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_siattvar2  AS CHAR      FORMAT "X(60)".

DEFINE NEW SHARED VAR nv_fltattcod AS CHARACTER FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_fltatt AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_fltprm AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_fltgap AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_fltattvar AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_fltattvar1 AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_fltattvar2 AS CHAR      FORMAT "X(60)".

DEFINE NEW SHARED VAR nv_ncbattcod  AS CHARACTER FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_ncbatt AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_ncbprm AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_ncbgap AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_ncbattvar  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_ncbattvar1  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_ncbattvar2  AS CHAR      FORMAT "X(60)".

DEFINE NEW SHARED VAR nv_dscattcod  AS CHARACTER FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_dscatt AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_dscprm AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_dscgap AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_dscattvar  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_dscattvar1  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_dscattvar2  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_packatt  AS CHARACTER FORMAT "X(4)".
DEFINE NEW SHARED VAR nv_package AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_packprm AS DECI FORMAT ">>,>>>,>>9-".
DEFINE NEW SHARED VAR nv_packattvar  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_packattvar1  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_packattvar2  AS CHAR      FORMAT "X(60)".
DEFINE NEW SHARED VAR nv_hztext AS CHAR FORMAT "X(100)".
DEFINE NEW SHARED VAR nv_packdes AS CHAR FORMAT "X(30)".

DEFINE VAR nv_fcctv   AS LOGICAL. /*Jiraphon P. A64-0330*/
DEFINE VAR nv_status  AS CHAR.    /*Jiraphon P. A64-0330*/
DEFINE VAR nv_message AS CHAR.    /*Jiraphon P. A64-0330*/
DEFINE VAR nv_flagprm AS CHAR FORMAT "X(2)". /* N=Net,G=Gross */
DEFINE VAR nv_batchyr AS INTE FORMAT "9999".     /*Ле batch */    
DEFINE VAR nv_batchno AS CHAR FORMAT "X(20)" .  /*batch number*/  
DEFINE VAR nv_batcnt  AS INTE FORMAT "99".   

