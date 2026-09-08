@echo off
REM ============================================================================
REM  SALIR DEL KIOSCO / DEVOLVER LA PC A MODO NORMAL
REM  Drogueria del Sud / Digital Impulso
REM
REM  1. Cierra el vigilante (watchdog) y el navegador en modo kiosco.
REM  2. Revierte TODO el sellado de Windows: gestos de borde, widgets, centro de
REM     notificaciones, Administrador de tareas, teclas Windows, barra de tareas
REM     y el bloqueo de teclado a nivel driver.
REM
REM  IMPORTANTE: hay que REINICIAR la PC despues para que vuelvan el teclado y
REM  los gestos de borde.
REM ============================================================================
setlocal

REM --- Autoelevar: si no somos administrador, relanzarse con UAC y salir ---
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo Pidiendo permiso de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo Cerrando el vigilante y el navegador del kiosco...
REM El watchdog corre oculto como powershell.exe; no aparece en la barra de tareas.
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='powershell.exe'\" | Where-Object { $_.CommandLine -like '*DelSudTotemWebKiosk*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1

echo Revirtiendo el sellado de Windows...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /f >nul 2>&1
REM Bloqueo de teclado a nivel driver (lo pone SellarKioscoWindows.ps1).
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /f >nul 2>&1

REM Barra de tareas visible de nuevo (byte 8 de StuckRects3: 2=off).
powershell -NoProfile -Command "$sr='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; if (Test-Path $sr) { $b=(Get-ItemProperty -Path $sr).Settings; $b[8]=2; Set-ItemProperty -Path $sr -Name Settings -Value $b }"

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo ============================================================
echo   PC EN MODO NORMAL
echo.
echo   REINICIA LA PC para que vuelvan el teclado (Alt, Tab,
echo   tecla Windows) y los gestos de borde.
echo ============================================================
echo.
pause

endlocal
