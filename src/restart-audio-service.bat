@echo off
chcp 65001>nul
setlocal EnableDelayedExpansion

set "arg=%1"
if "!arg!" == "admin" (
    echo Restarted with admin rights
) else (
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"\"%~f0\" admin\"' -Verb RunAs"
    rem -WindowStyle Minimized
    exit
)
echo.

echo [ Restarting the Audio Service ]

echo.&echo Stopping service
:asrv_stop
powershell Stop-Service -name AudioSrv -force

echo.&echo Checking the service status
:asrv_launch
sc query AudioSrv | findstr "RUNNING">nul || (
  echo.&echo Trying to start service
  powershell Start-Service -name AudioSrv
)

echo.&echo Making sure that the service is running
:asrv_check_status
sc query AudioSrv | findstr "RUNNING">nul && (set hasASRV=1)
if !hasASRV!==1 (
    endlocal
    echo.&echo [92mAudio service was restarted successfully![0m
) else (
  echo [93mAudio service not running. Trying to launch again . . .[0m
  >nul timeout /t 2 /nobreak
  powershell Start-Service -name AudioSrv
  goto :asrv_check_status
)

>nul timeout /t 2
endlocal&exit

:: Source: https://github.com/N3M1X10