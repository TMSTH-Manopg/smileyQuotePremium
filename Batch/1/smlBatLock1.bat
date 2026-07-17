@echo off
setlocal enableextensions

REM ===============================
REM Configuration
REM ===============================

set LOGDIR=D:\WebOS\CampaignPublish\Log
set LOCK=%LOGDIR%\RUN1_WUWSMLPRM.lock
set LOG=%LOGDIR%\RUN1_WUWSMLPRM.log

set PROWIN=D:\DLC128\bin\prowin.exe
set INI=D:\WebWSKFK12\PROGR128.ini
set PF=D:\WebWSKFK12\WUW\WUW_SMLCAM.pf
set TMP=c:\temp

REM ===============================
REM Timestamp
REM ===============================
for /f "tokens=1-3 delims=/: " %%a in ("%date%") do set DT=%%c%%b%%a
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set TM=%%a%%b%%c
set TS=%DT%_%TM%

REM ===============================
REM Lock file
REM ===============================
if exist "%LOCK%" (
    echo [%date% %time%] SKIP: lock exists >> "%LOG%"
    exit /b
)

echo START=%date% %time% > "%LOCK%"
echo LOCK_TIMESTAMP=%TS% >> "%LOCK%"

echo ================================================== >> "%LOG%"
echo [%date% %time%] START WUWSMLPRM >> "%LOG%"

REM ===============================
REM Run Progress Background (SHOW CMD)
REM ===============================
cmd /k ^
"%PROWIN%" ^
 -basekey "INI" ^
 -ininame "%INI%" ^
 -pf "%PF%" ^
 -d dmy ^
 -T "%TMP%" ^
 >> "%LOG%" 2>&1 ^&^& exit

echo [%date% %time%] END WUWSMLPRM >> "%LOG%"
del "%LOCK%"
``
