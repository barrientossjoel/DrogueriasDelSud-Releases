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
| `AbrirTotemKiosco.bat` | Abrir en una **PC/notebook Windows** el navegador en modo kiosco apuntando al tótem. |
| `SellarKioscoWindows.ps1` | Opcional pero recomendado en **pantallas táctiles Windows**: sella el sistema operativo (ver abajo). |

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
2. Doble clic para abrirlo.
3. Abre Chrome (o Edge si no hay Chrome) en modo kiosco de pantalla completa contra la
   web del tótem, y deja un vigilante en segundo plano que reabre el navegador si alguien
   lo cierra.
4. Para salir: 5 toques rápidos en la esquina superior izquierda, o Alt+F4.

Requiere tener **Google Chrome** (o Microsoft Edge) instalado en la PC — el `.bat` no
instala nada, solo abre el navegador.

Si la pantalla es muy grande y la interfaz se ve chica, editar el archivo con el Bloc de
notas y ajustar el número en `--force-device-scale-factor=1.5` (subir a 1.75, 2, 2.5...).

### ⚠️ Pantallas táctiles: sellar Windows con `SellarKioscoWindows.ps1`

El modo `--kiosk` de Chrome tapa la ventana pero **no bloquea el sistema operativo**: en
una pantalla táctil, deslizar desde el borde saca el panel de *Widgets / Noticias e
intereses* de Windows por encima del kiosco sin tocar el teclado. Para tapar eso (y
Alt+Tab, la tecla Windows, el Administrador de tareas):

1. Clic derecho sobre `SellarKioscoWindows.ps1` → **Ejecutar con PowerShell** (tiene que
   pedir permisos de administrador; si no, abrir PowerShell como administrador y correr
   `powershell -ExecutionPolicy Bypass -File SellarKioscoWindows.ps1`).
2. **Reiniciar la PC** (el bloqueo de teclado no se aplica hasta reiniciar).
3. Después del reinicio, correr `AbrirTotemKiosco.bat` normalmente.

Es reversible: `powershell -ExecutionPolicy Bypass -File SellarKioscoWindows.ps1 -Revertir`
y reiniciar de nuevo. Ojo: mientras está aplicado, el teclado de esa PC queda mutilado a
propósito (Alt+Tab, Alt+F4, Ctrl+Esc y las teclas Windows no responden) — usar el modo
`-Revertir` antes de necesitar administrar el equipo normalmente.

## Código fuente

El código completo (backend + panel admin + este tótem) vive en un repositorio privado de
Digital Impulso.
