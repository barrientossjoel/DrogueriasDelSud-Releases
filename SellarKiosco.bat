@echo off
REM ============================================================================
REM  SELLAR EL TOTEM (extra opcional) - Drogueria del Sud / Digital Impulso
REM
REM  Corre SellarKioscoWindows.ps1, que ADEMAS del swipe/widgets bloquea el
REM  teclado (Alt, Tab, Ctrl izq, teclas Windows) a nivel driver.
REM
REM  Este .bat existe para no pelear con la politica de ejecucion de PowerShell
REM  ni con la marca de "archivo descargado de internet" que Windows le pone a
REM  los .ps1 bajados de GitHub. El .ps1 se autoeleva y pide permiso de admin.
REM
REM  IMPORTANTE: los DOS archivos tienen que estar en la MISMA carpeta.
REM  Despues de correrlo hay que REINICIAR la PC.
REM  Para volver todo a la normalidad: RestaurarNormal.bat
REM ============================================================================
setlocal

set "PS1=%~dp0SellarKioscoWindows.ps1"

if not exist "%PS1%" (
  echo No se encontro SellarKioscoWindows.ps1 en esta carpeta:
  echo   %~dp0
  echo.
  echo Baja los DOS archivos de la release a la misma carpeta y volve a intentar.
  pause
  exit /b 1
)

REM Unblock-File saca la marca de "descargado de internet"; -ExecutionPolicy
REM Bypass evita que la politica del equipo frene el script.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path '%PS1%' -ErrorAction SilentlyContinue; & '%PS1%'"

endlocal
