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
| `AbrirTotemKiosco.bat` | Abrir en una **PC/notebook Windows** el navegador en modo kiosco. Ya incluye el bloqueo de swipe/widgets. **Este es el único imprescindible.** |
| `RestaurarNormal.bat` | Salir del kiosco y devolver la PC a modo normal. |
| `SellarKiosco.bat` + `SellarKioscoWindows.ps1` | Opcional: bloquear ADEMÁS el teclado (Alt+Tab, tecla Windows). Los dos archivos van en la **misma carpeta**. |

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

### Salir del kiosco — `RestaurarNormal.bat`

El `.bat` del tótem **no se registra en el arranque de Windows**, así que reiniciar la PC ya
te saca del kiosco. Pero el sellado del registro sobrevive al reinicio (esa es la idea): la
barra de tareas queda oculta y los atajos bloqueados.

Para devolver la PC a modo normal del todo, correr `RestaurarNormal.bat` (pide permiso de
administrador) y **reiniciar**. Cierra el vigilante y el navegador, y revierte todo el
sellado: gestos, widgets, notificaciones, Administrador de tareas, teclas Windows, barra de
tareas y el bloqueo de teclado.

### Extra opcional: bloquear también el teclado — `SellarKiosco.bat`

`AbrirTotemKiosco.bat` ya resuelve el swipe/widgets. Esto es un paso EXTRA solo si además
querés bloquear Alt+Tab, Alt+F4, Ctrl+Esc y la tecla Windows a nivel driver de teclado:

1. Bajar `SellarKiosco.bat` **y** `SellarKioscoWindows.ps1` a la **misma carpeta**.
2. Doble clic en `SellarKiosco.bat` → aceptar el permiso de administrador.
3. **Reiniciar la PC.**

> El `.bat` existe justamente para no pelear con la política de ejecución de PowerShell ni
> con la marca de "archivo descargado de internet" que Windows le pone a los `.ps1` bajados
> de GitHub. Si el `.ps1` "no arranca" en una PC y en otra sí, es por eso: usá el `.bat`.

Ojo: mientras está aplicado, el teclado de esa PC queda mutilado a propósito (Alt, Tab,
Ctrl izquierdo y las teclas Windows no responden). Para administrarla de nuevo, correr
`RestaurarNormal.bat` y reiniciar.

## Código fuente

El código completo (backend + panel admin + este tótem) vive en un repositorio privado de
Digital Impulso.
