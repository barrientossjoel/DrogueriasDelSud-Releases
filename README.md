# Diseñá tu Tótem — Droguería del Sud (Releases)

Este repo **no tiene código fuente navegable**: es solo un contenedor de las
[Releases](../../releases) con los archivos para instalar el tótem "Diseñá tu Tótem" de
Droguería del Sud (Digital Impulso).

Ambos artefactos hablan directo con el central publicado
(`https://drogueriadelsud.digitalimpulso.com`) — no necesitan backend local ni instalar
dependencias de desarrollo.

## Descargas (última release)

| Archivo | Para qué |
|---|---|
| `DelSudTotem.apk` | Instalar en una **tablet Android** como app de kiosco. |
| `AbrirTotemKiosco.bat` | Abrir en una **PC/notebook Windows** el navegador en modo kiosco apuntando al tótem. Ya incluye el bloqueo de swipe/widgets. |
| `SellarKioscoWindows.ps1` | Opcional, solo para bloquear ADEMÁS el teclado (Alt+Tab, tecla Windows) a nivel driver — ver abajo. |

## Android — `DelSudTotem.apk`

1. Copiar el `.apk` a la tablet (por USB, WhatsApp, Drive o pendrive) y abrirlo.
2. Aceptar "instalar apps de origen desconocido" si Android lo pide.
3. Al abrir por primera vez, Android pregunta si querés **anclar la pantalla** (screen
   pinning): aceptar. Con eso no se sale con Atrás ni con Recientes.
4. Para salir: 5 toques rápidos en la esquina superior izquierda → confirmar.

La app corre sin red una vez instalada; los leads que se generen sin WiFi quedan en cola y
suben solos al volver la conexión.

## Windows — `AbrirTotemKiosco.bat`

1. Descargar `AbrirTotemKiosco.bat` a cualquier carpeta de la PC.
2. Doble clic para abrirlo. Va a pedir **permiso de administrador** (UAC) — aceptar.
   Lo necesita para bloquear, antes de abrir el navegador, el swipe desde el borde y el
   panel de *Widgets / Noticias e intereses* de Windows: en una pantalla táctil eso se
   cuela por encima del kiosco aunque Chrome esté en `--kiosk`, sin tocar el teclado.
3. El escritorio va a parpadear un instante (reinicia el Explorador de Windows para que
   el bloqueo aplique al toque, sin reiniciar la PC) y después abre Chrome (o Edge si no
   hay Chrome) en modo kiosco de pantalla completa contra la web del tótem, con un
   vigilante en segundo plano que reabre el navegador si alguien lo cierra.
4. Para salir: 5 toques rápidos en la esquina superior izquierda, o Alt+F4.

Requiere tener **Google Chrome** (o Microsoft Edge) instalado en la PC — el `.bat` no
instala nada más, solo bloquea esos gestos y abre el navegador.

Si la pantalla es muy grande y la interfaz se ve chica, editar el archivo con el Bloc de
notas y ajustar el número en `--force-device-scale-factor=1.5` (subir a 1.75, 2, 2.5...).

Es reversible (por si hay que volver a usar esa PC para otra cosa):
```
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v AllowEdgeSwipe /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 1 /f
```
(desde una consola como administrador, y reiniciar Explorador o la PC).

### Extra opcional: bloquear también el teclado con `SellarKioscoWindows.ps1`

`AbrirTotemKiosco.bat` ya resuelve el swipe/widgets. `SellarKioscoWindows.ps1` es un paso
EXTRA solo si además querés bloquear Alt+Tab, Alt+F4, Ctrl+Esc y la tecla Windows a nivel
driver de teclado — a diferencia de lo anterior, **esto sí necesita reiniciar la PC** para
aplicarse:

1. Clic derecho sobre `SellarKioscoWindows.ps1` → **Ejecutar con PowerShell** (o
   `powershell -ExecutionPolicy Bypass -File SellarKioscoWindows.ps1` como administrador).
2. Reiniciar la PC.
3. Correr `AbrirTotemKiosco.bat` normalmente.

Es reversible: `powershell -ExecutionPolicy Bypass -File SellarKioscoWindows.ps1 -Revertir`
y reiniciar de nuevo. Ojo: mientras está aplicado, el teclado de esa PC queda mutilado a
propósito — usar `-Revertir` antes de necesitar administrar el equipo normalmente.

## Código fuente

El código completo (backend + panel admin + este tótem) vive en un repositorio privado de
Digital Impulso.
