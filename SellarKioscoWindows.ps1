<#
.SYNOPSIS
  Sella Windows para que el tótem no se pueda abandonar.

.DESCRIPTION
  El modo --kiosk de Chrome tapa la ventana, pero NO impide salir: Alt+Tab, la
  tecla Windows, Ctrl+Shift+Esc y Ctrl+Alt+Supr siguen funcionando y dejan el
  escritorio a la vista en pleno stand. Eso se cierra desde el sistema operativo.

  Este script aplica el sellado sobre el USUARIO ACTUAL (el que corre el tótem):

    - Administrador de tareas deshabilitado.
    - Teclas Windows anuladas (política de Explorer).
    - Alt+Tab, Alt+F4, Ctrl+Esc y teclas Windows anuladas a nivel DRIVER de
      teclado (Scancode Map). Es lo único que las bloquea de verdad.
    - Barra de tareas oculta y bloqueada.
    - Edge-swipe táctil (deslizar desde el borde) deshabilitado: en pantallas
      táctiles eso es lo que saca el widget de "Noticias e intereses" y otros
      paneles del sistema por encima del kiosco, sin pasar por el teclado.
    - Feed de "Noticias e intereses" / Widgets deshabilitado y su ícono
      sacado de la barra de tareas.

  Todo es REVERSIBLE con -Revertir. El Scancode Map necesita reiniciar para
  aplicarse (y para revertirse).

.PARAMETER Revertir
  Deshace todos los cambios.

.EXAMPLE
  # Aplicar (clic derecho > Ejecutar con PowerShell como administrador)
  powershell -ExecutionPolicy Bypass -File scripts\kiosco-windows.ps1

.EXAMPLE
  # Volver todo atrás
  powershell -ExecutionPolicy Bypass -File scripts\kiosco-windows.ps1 -Revertir

.NOTES
  Para un sellado total (que ni siquiera arranque el explorador de Windows) usar
  ADEMÁS Assigned Access: Configuración > Cuentas > Acceso asignado, eligiendo
  Chrome/Edge como única aplicación del usuario del tótem.
#>
param([switch]$Revertir)

$ErrorActionPreference = 'Stop'

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
  Write-Warning 'Hay que ejecutarlo COMO ADMINISTRADOR (el Scancode Map es de máquina).'
  exit 1
}

$polSystem   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
$polExplorer = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
$teclado     = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$avanzado    = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$polEdgeUi   = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI'
$polFeeds    = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'

function Ensure-Key($ruta) { if (-not (Test-Path $ruta)) { New-Item -Path $ruta -Force | Out-Null } }

if ($Revertir) {
  Write-Host '[kiosco] Revirtiendo...' -ForegroundColor Yellow
  $props = @(
    @($polSystem,'DisableTaskMgr'), @($polExplorer,'NoWinKeys'),
    @($avanzado,'TaskbarAutoHideInTabletMode'), @($avanzado,'TaskbarDa'),
    @($polEdgeUi,'AllowEdgeSwipe'), @($polFeeds,'EnableFeeds')
  )
  foreach ($r in $props) {
    Remove-ItemProperty -Path $r[0] -Name $r[1] -ErrorAction SilentlyContinue
  }
  Remove-ItemProperty -Path $teclado -Name 'Scancode Map' -ErrorAction SilentlyContinue
  Write-Host '[kiosco] Revertido. REINICIAR para que el teclado y el swipe vuelvan a la normalidad.' -ForegroundColor Green
  exit 0
}

Write-Host '[kiosco] Sellando el equipo...' -ForegroundColor Cyan

# --- Administrador de tareas y tecla Windows (políticas de usuario) ---
Ensure-Key $polSystem
Set-ItemProperty -Path $polSystem -Name 'DisableTaskMgr' -Value 1 -Type DWord
Ensure-Key $polExplorer
Set-ItemProperty -Path $polExplorer -Name 'NoWinKeys' -Value 1 -Type DWord
Write-Host '  - Administrador de tareas y teclas Windows: bloqueados'

# --- Scancode Map: anula físicamente las teclas de escape ---
# Formato: cabecera (8 bytes) + cantidad de entradas + pares destino/origen + fin.
# 0x0000 como destino = tecla anulada.
#   E0 5B / E0 5C  Win izq / der      38 / E0 38  Alt izq / der (mata Alt+Tab y Alt+F4)
#   0F  Tab        1D  Ctrl izq (mata Ctrl+Esc)   01  Esc
$mapa = [byte[]](
  0,0,0,0, 0,0,0,0,
  7,0,0,0,
  0,0, 0x5B,0xE0,   # Win izquierda
  0,0, 0x5C,0xE0,   # Win derecha
  0,0, 0x38,0x00,   # Alt izquierda
  0,0, 0x38,0xE0,   # Alt derecha
  0,0, 0x0F,0x00,   # Tab
  0,0, 0x1D,0x00,   # Ctrl izquierda
  0,0,0,0
)
Set-ItemProperty -Path $teclado -Name 'Scancode Map' -Value $mapa -Type Binary
Write-Host '  - Alt, Tab, Ctrl izq y Windows: anuladas a nivel driver'

# --- Barra de tareas siempre oculta ---
Ensure-Key $avanzado
Set-ItemProperty -Path $avanzado -Name 'TaskbarAutoHideInTabletMode' -Value 1 -Type DWord
Write-Host '  - Barra de tareas: oculta'

# --- Edge-swipe táctil y Widgets/"Noticias e intereses" ---
# En touch, deslizar desde el borde saca paneles del sistema por encima del
# kiosco sin pasar por el teclado (por eso el Scancode Map de arriba no alcanza).
Ensure-Key $polEdgeUi
Set-ItemProperty -Path $polEdgeUi -Name 'AllowEdgeSwipe' -Value 0 -Type DWord
Ensure-Key $polFeeds
Set-ItemProperty -Path $polFeeds -Name 'EnableFeeds' -Value 0 -Type DWord
Set-ItemProperty -Path $avanzado -Name 'TaskbarDa' -Value 0 -Type DWord
Write-Host '  - Edge-swipe tactil y Widgets/Noticias e intereses: bloqueados'

Write-Host ''
Write-Host '[kiosco] Listo. HAY QUE REINICIAR para que el bloqueo de teclado tome efecto.' -ForegroundColor Green
Write-Host '[kiosco] Ojo: con esto el teclado del equipo queda mutilado a propósito.' -ForegroundColor Yellow
Write-Host '        Para administrarlo, revertir con -Revertir y reiniciar.' -ForegroundColor Yellow
Write-Host '        El sellado definitivo es Assigned Access (ver el encabezado del script).' -ForegroundColor Yellow
