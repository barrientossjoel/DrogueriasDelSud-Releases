@echo off
REM ============================================================================
REM  DISENA TU TOTEM - Drogueria del Sud / Digital Impulso
REM  Abre Chrome (o Edge) en modo kiosco contra la web publicada en la nube.
REM  Archivo unico y autocontenido: no necesita nada mas del proyecto.
REM
REM  Se autoeleva (pide permiso de administrador) para SELLAR WINDOWS antes de
REM  abrir el navegador. Mismo enfoque probado en el totem de Abuelo Julio:
REM  el --kiosk de Chrome tapa la ventana, pero el escape real en una pantalla
REM  tactil son los GESTOS DE BORDE del sistema operativo.
REM
REM  OJO: el bloqueo de gestos de borde (AllowEdgeSwipe) necesita CERRAR SESION
REM  o REINICIAR la PC para tomar efecto del todo. La primera vez que se corre
REM  este archivo hay que reiniciar una vez; despues ya queda sellado.
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

REM --- Ya estaba sellado? Si AllowEdgeSwipe ya es 0, no hace falta reiniciar ---
set "YA_SELLADO="
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe 2>nul | find "0x0" >nul && set "YA_SELLADO=1"

echo Sellando Windows (gestos de borde, notificaciones, widgets)...

REM Gestos tactiles de borde: el escape real en una pantalla tactil (Task View,
REM Centro de actividades, Widgets, cambio de app). Vive en HKLM.
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe /t REG_DWORD /d 0 /f >nul
REM Centro de notificaciones.
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 1 /f >nul
REM Administrador de tareas (long-press / Ctrl+Alt+Supr).
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul
REM Combinaciones con la tecla Windows.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /t REG_DWORD /d 1 /f >nul
REM Widgets / "Noticias e intereses" de Windows 11 (Dsh es la politica nueva;
REM Windows Feeds es la vieja de Windows 10 - se ponen las dos).
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul

REM Barra de tareas oculta automaticamente (byte 8 de StuckRects3: 3=on).
powershell -NoProfile -Command "$sr='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; if (Test-Path $sr) { $b=(Get-ItemProperty -Path $sr).Settings; $b[8]=3; Set-ItemProperty -Path $sr -Name Settings -Value $b }"

REM Reiniciar Explorer: aplica barra de tareas, notificaciones y widgets al toque.
taskkill /f /im Widgets.exe >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
ping -n 4 127.0.0.1 >nul

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

if not defined YA_SELLADO (
  echo.
  echo ============================================================
  echo   FALTA UN PASO: REINICIAR LA PC UNA VEZ
  echo.
  echo   El bloqueo de los gestos de borde ^(el swipe que trae las
  echo   noticias y el menu de Windows^) no toma efecto hasta cerrar
  echo   sesion o reiniciar. Reinicia la PC y volve a correr este
  echo   archivo: a partir de ahi el swipe ya no hace nada.
  echo ============================================================
  echo.
  pause
)

endlocal
