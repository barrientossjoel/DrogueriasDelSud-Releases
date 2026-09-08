@echo off
setlocal EnableExtensions
REM ============================================================================
REM  DISENA TU TOTEM - Drogueria del Sud / Digital Impulso
REM  Sella Windows y abre Chrome (o Edge) en modo kiosco contra la web publicada.
REM  Archivo unico y autocontenido: no necesita nada mas del proyecto.
REM
REM  El --kiosk de Chrome tapa la ventana, pero el escape real en una pantalla
REM  tactil son los GESTOS DE BORDE del sistema operativo. Mismo enfoque probado
REM  en el totem de Abuelo Julio (scripts/lockdown-kiosko.ps1).
REM
REM  OJO: el bloqueo de gestos de borde (AllowEdgeSwipe) necesita CERRAR SESION
REM  o REINICIAR para tomar efecto. La primera vez hay que reiniciar una vez.
REM
REM  SALIR: RestaurarNormal.bat, o reiniciar (esto no se auto-arranca).
REM  ESCALA: ajusta --force-device-scale-factor segun la pulgada del panel.
REM ============================================================================

REM ---------------------------------------------------------------------------
REM  1. Permisos de administrador
REM  Chequeo confiable: solo un proceso elevado puede leer el perfil de
REM  LocalService. No usamos `net session`, que falla si el servicio "Servidor"
REM  esta deshabilitado (habitual en equipos capados) aunque seas admin.
REM ---------------------------------------------------------------------------
reg query "HKU\S-1-5-19" >nul 2>&1
if not errorlevel 1 goto es_admin

REM No somos admin. Relanzarse elevado UNA sola vez (el argumento evita el bucle).
if /i "%~1"=="elevado" goto sin_permisos
echo Pidiendo permiso de administrador para sellar el kiosco...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList 'elevado' -Verb RunAs" 2>nul
if errorlevel 1 goto sin_permisos
exit /b 0

:sin_permisos
echo.
echo ============================================================
echo   NO SE PUDO SELLAR: FALTA PERMISO DE ADMINISTRADOR
echo.
echo   El bloqueo del swipe de Windows se escribe en el registro
echo   del equipo, y eso exige administrador.
echo.
echo   Que hacer:
echo    - Si aparecio un cartel de Windows pidiendo permiso,
echo      hay que aceptarlo ^(boton "Si"^).
echo    - Si pide usuario y contrasena, esta PC inicia sesion con
echo      una cuenta sin permisos: entra con una de administrador
echo      o pedile la clave a quien administre el equipo.
echo    - Tambien podes hacer clic derecho sobre este archivo y
echo      elegir "Ejecutar como administrador".
echo ============================================================
echo.
pause
exit /b 1

:es_admin

REM ---------------------------------------------------------------------------
REM  2. Sellado de Windows
REM ---------------------------------------------------------------------------
REM Si ya estaba sellado de antes, no hace falta pedir otro reinicio.
set "YA_SELLADO="
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe 2>nul | find "0x0" >nul && set "YA_SELLADO=1"

echo Sellando Windows ^(gestos de borde, notificaciones, widgets^)...

REM Gestos tactiles de borde: el escape real en una pantalla tactil.
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe /t REG_DWORD /d 0 /f >nul
REM Centro de notificaciones.
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 1 /f >nul
REM Administrador de tareas.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul
REM Combinaciones con la tecla Windows.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /t REG_DWORD /d 1 /f >nul
REM Widgets de Windows 11 (Dsh es la politica nueva; Windows Feeds la de Win10).
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul
REM Icono de Widgets en la barra de tareas.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul

REM Barra de tareas oculta automaticamente (byte 8 de StuckRects3: 3=on).
powershell -NoProfile -Command "$sr='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; if (Test-Path $sr) { $b=(Get-ItemProperty -Path $sr).Settings; $b[8]=3; Set-ItemProperty -Path $sr -Name Settings -Value $b }"

REM ---------------------------------------------------------------------------
REM  3. Verificar que el sellado quedo aplicado de verdad
REM ---------------------------------------------------------------------------
echo.
echo Verificando...
set "FALLOS=0"
call :verificar "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" AllowEdgeSwipe "Gestos de borde - el swipe"
call :verificar "HKLM\SOFTWARE\Policies\Microsoft\Dsh" AllowNewsAndInterests "Widgets - Noticias e intereses"
call :verificar "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" DisableNotificationCenter "Centro de notificaciones"
call :verificar "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" DisableTaskMgr "Administrador de tareas"
call :verificar "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" NoWinKeys "Teclas Windows"

if not "%FALLOS%"=="0" (
  echo.
  echo ============================================================
  echo   ATENCION: %FALLOS% bloqueo^(s^) NO se pudieron aplicar.
  echo   Fijate cuales dicen FALLO arriba y avisa antes de usar
  echo   este equipo como totem en el stand.
  echo ============================================================
  echo.
  pause
)

REM Aplicar lo que se puede sin reiniciar.
taskkill /f /im Widgets.exe >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
ping -n 4 127.0.0.1 >nul

REM ---------------------------------------------------------------------------
REM  4. Abrir el navegador en modo kiosco
REM ---------------------------------------------------------------------------
set "URL=https://drogueriadelsud.digitalimpulso.com/"
set "FLAGS=--kiosk --user-data-dir=%LocalAppData%\DelSudTotemWebKiosk --force-device-scale-factor=1.5 --start-fullscreen --noerrdialogs --no-first-run --no-default-browser-check --disable-session-crashed-bubble --disable-translate --disable-features=TranslateUI --disable-pinch --overscroll-history-navigation=0 --autoplay-policy=no-user-gesture-required"

set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LocalAppData%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

if not defined BROWSER (
  echo.
  echo No se encontro Google Chrome ni Microsoft Edge instalado.
  echo Instala Chrome ^(https://www.google.com/chrome/^) y volve a correr esto.
  pause
  exit /b 1
)

echo.
echo Abriendo %BROWSER%
echo URL: %URL%
start "" "%BROWSER%" %FLAGS% "%URL%"

REM Watchdog: si cierran el navegador, lo reabre. Ultima red del kiosco.
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
exit /b 0

REM ===========================================================================
REM  Subrutina: verificar que un valor quedo escrito en el registro.
REM  %1=clave  %2=valor  %3=descripcion
REM ===========================================================================
:verificar
reg query %1 /v %2 >nul 2>&1
if errorlevel 1 (
  echo   [FALLO] %~3
  set /a FALLOS+=1
) else (
  echo   [ OK  ] %~3
)
goto :eof
