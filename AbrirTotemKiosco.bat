@echo off
REM ============================================================================
REM  DISENA TU TOTEM - Drogueria del Sud / Digital Impulso
REM  Abre Chrome (o Edge) en modo kiosco contra la web publicada en la nube.
REM  Archivo unico y autocontenido: no necesita nada mas del proyecto.
REM
REM  Se autoeleva UNA vez (pide permiso de administrador) para bloquear, antes
REM  de abrir el navegador, los gestos tactiles de Windows que se cuelan por
REM  encima del kiosco: swipe desde el borde y el panel de Widgets/Noticias e
REM  intereses. Sin esto, deslizar el dedo desde el borde saca el escritorio
REM  aunque Chrome este en --kiosk.
REM
REM  SALIR: Alt+F4, o 5 toques rapidos en la esquina superior izquierda.
REM
REM  ESCALA: --force-device-scale-factor escala toda la interfaz de forma
REM  uniforme. Ajusta el numero segun la pulgada del panel: 1.5, 1.75, 2, 2.5.
REM ============================================================================
setlocal

REM --- Autoelevar: si no somos administrador, relanzarse con UAC y salir ---
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo Pidiendo permiso de administrador para sellar el kiosco...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

REM --- Bloquear gestos/paneles de Windows que se cuelan sobre el kiosco ---
echo Sellando gestos de Windows (swipe / widgets / noticias)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAutoHideInTabletMode /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul

REM Reiniciar Explorer para que los cambios de arriba apliquen YA (sin reiniciar
REM la PC). El escritorio parpadea un instante, es esperable.
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
timeout /t 2 /nobreak >nul

set "URL=https://drogueriadelsud.digitalimpulso.com/"
set "FLAGS=--kiosk --user-data-dir=%LocalAppData%\DelSudTotemWebKiosk --force-device-scale-factor=1.5 --start-fullscreen --noerrdialogs --no-first-run --no-default-browser-check --disable-session-crashed-bubble --disable-translate --disable-features=TranslateUI --disable-pinch --overscroll-history-navigation=0 --autoplay-policy=no-user-gesture-required"

set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LocalAppData%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

if not defined BROWSER (
  echo No se encontro Google Chrome ni Microsoft Edge instalado.
  echo Instala Chrome ^(https://www.google.com/chrome/^) y volve a correr este archivo.
  pause
  exit /b 1
)

echo Abriendo %BROWSER%
echo URL: %URL%
start "" "%BROWSER%" %FLAGS% "%URL%"

REM Watchdog en segundo plano: si cierran el navegador, lo reabre. Ultima red
REM de contencion del kiosco (un Alt+F4 que se escape, un cuelgue, etc).
start "DelSud Totem - Watchdog" /min powershell -NoProfile -WindowStyle Hidden -Command ^
  "$browser = '%BROWSER%'; $flags = '%FLAGS%'.Split(' ') | Where-Object { $_ -ne '' }; $url = '%URL%'; $name = [System.IO.Path]::GetFileNameWithoutExtension($browser); while ($true) { $vivo = Get-Process -Name $name -ErrorAction SilentlyContinue; if (-not $vivo) { Start-Process -FilePath $browser -ArgumentList ($flags + $url) } ; Start-Sleep -Seconds 5 }"

endlocal
