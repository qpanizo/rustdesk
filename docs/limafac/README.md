# LimaFac Remote

LimaFac Remote personaliza la interfaz del fork `qpanizo/rustdesk`. RustDesk
continúa siendo el motor de escritorio remoto. La interfaz actual es Flutter;
Rust implementa las sesiones, captura, entrada, red y servicios nativos.

## Organización del fork

| Elemento | Función |
| --- | --- |
| `origin` | `https://github.com/qpanizo/rustdesk.git`: repositorio de LimaFac |
| `upstream` | `https://github.com/rustdesk/rustdesk.git`: proyecto original |
| `master` | Referencia del código original; mantener sin personalizaciones |
| `limafac/ui` | Rama con la interfaz LimaFac y sus pruebas |
| `flutter/lib/limafac/` | Componentes visuales, tema, logo y orientación al usuario |
| `flutter/assets/limafac-logo.png` | Logo existente de LimaFac, copiado del proyecto web local |
| `src/` y `libs/` | Motor original, sin cambios en esta implementación |

El fork conserva la historia Git, `LICENCE`, los créditos y el submódulo
`libs/hbb_common` en el commit que selecciona RustDesk. No se ha copiado código
propietario de TeamViewer ni de AnyDesk: las referencias son sus patrones
públicos de uso y la organización de sus interfaces.

## Interfaz implementada

- Pantalla principal con logo y colores LimaFac, paneles «Recibir ayuda» y
  «Conectarse a un equipo», ajustes y ayuda breve.
- Se reutilizan los controles originales de ID, contraseña, conexión,
  historial y agenda. No hay identificadores ni conexiones simulados.
- Tarjetas de configuración sobrias con instrucciones para cada permiso.
- Instalador de Windows con opciones avanzadas plegadas. Reutiliza la
  validación del directorio, las opciones de instalación, confirmaciones,
  progreso y acciones nativas originales.
- Los clientes restringidos a entrada o salida conservan su interfaz original.
- `--dart-define=LIMAFAC_UI=false` restaura las rutas visuales originales.
  En este fork la personalización está activada por defecto.

Los textos propios de LimaFac están en español y no alteran los catálogos de
traducción del motor. Los controles reutilizados siguen el idioma configurado
en RustDesk. Los nombres nativos, servicios, identificadores y firma del
instalador todavía son los originales: este cambio es de interfaz y no es un
paquete de distribución firmado de LimaFac.

## Permisos e instalación

La interfaz cambia la explicación, no concede permisos por el usuario ni evita
las comprobaciones del sistema. Grabación de pantalla y Accesibilidad siguen
siendo necesarios en macOS para recibir control remoto. Monitorización de
entrada corresponde a la captura de determinadas teclas; el servicio permite
acceso en segundo plano. Se conservan las comprobaciones y callbacks originales.

El instalador conserva las elecciones originales, incluido el modo sin instalar
cuando la configuración lo permite. Plegar las opciones no cambia sus valores.
Los permisos de administrador, los avisos de macOS/Windows y la firma de código
son asuntos distintos del diseño del instalador.

El aviso de actualización del cliente original se omite en la pantalla LimaFac
para evitar que su botón reemplace esta variante por un binario de RustDesk.
Las comprobaciones globales originales no se modifican. Antes de distribuir,
hay que configurar las versiones, identidad nativa y actualizaciones propias.

## Incorporar mejoras del original

No se reciben automáticamente como una dependencia: son integraciones Git que
deben revisarse y probarse. Si upstream cambia una pantalla donde se engancha
LimaFac, puede haber conflictos aunque los componentes estén separados.

Primero consulta los cambios sin modificar tu rama:

```sh
./scripts/limafac/check-upstream.sh
```

Para probar una integración, parte de un árbol limpio y guarda primero los
cambios locales de LimaFac en un commit:

```sh
git switch limafac/ui
git status --short
git fetch upstream --tags
git switch -c integration/rustdesk-update
git merge --no-commit --no-ff upstream/master
```

Resuelve conflictos conservando los componentes de `flutter/lib/limafac/` y
revisando los puntos de integración de abajo. Si descartas la actualización
antes de crear el commit, utiliza `git merge --abort`. Cuando esté revisada:

```sh
git submodule update --init --recursive
# Compilar y probar con el toolchain que declara el CI de esta revisión.
git commit
git switch limafac/ui
git merge --ff-only integration/rustdesk-update
```

Para versiones distribuidas, conviene partir de una versión estable validada
del original, registrar su commit y probar la actualización antes de publicarla.
No hacer un reset de `limafac/ui` contra upstream: descartaría la personalización.

## Compilación y comprobaciones

Se conservan los flujos originales de compilación. La revisión base inicial es
`b84058e07`; `.github/workflows/flutter-build.yml` declara Flutter 3.24.5 para
la mayoría de destinos y 3.44.9 para macOS/Windows arm64, con sus parches
respectivos. Usar las versiones y pasos de ese workflow, no asumir que el Flutter
global de la máquina es compatible. Los puentes nativos ignorados por Git y las
dependencias C/C++ deben estar preparados según el flujo original.

Las pruebas visuales funcionales nuevas están en `flutter/test/limafac_ui_test.dart`:

```sh
cd flutter
flutter test test/limafac_ui_test.dart
```

Comprobar también una conexión real entre dos equipos, solicitud y rechazo de
acceso, ID/contraseña, ajuste de ventana, instalador Windows y permisos en un
Mac limpio. Las pruebas de widgets por sí solas no validan estos flujos nativos.

Validación realizada en esta entrega: cuatro pruebas de los componentes nuevos
en un proyecto de comprobación aislado con Flutter 3.47.8; todas pasaron. Se
comprobaron tamaños compacto/escritorio, ambos temas, ayuda, apertura de opciones
del instalador y activación de callbacks únicamente después de pulsar sus
botones. No se ha compilado ni instalado el cliente nativo completo: faltan
preparar el puente nativo y las dependencias de compilación del motor. No se ha
validado una conexión remota real.

## Superficie de regresión

| Archivo existente | Ruta afectada y motivo |
| --- | --- |
| `flutter/lib/desktop/pages/desktop_home_page.dart` | Selecciona la pantalla LimaFac en el cliente completo, cambia la representación de tarjetas y omite el botón de actualización upstream en esa variante. Los controles de sesión y callbacks de permisos se reutilizan. |
| `flutter/lib/desktop/pages/install_page.dart` | Selecciona el formulario simplificado de instalación y conserva sus métodos de instalación, validación y permisos. |

No se modifican el motor Rust, protocolos, modelos, puente FFI ni submódulos.
La ruta original sigue disponible con `LIMAFAC_UI=false` y en los modos
restringidos de entrada/salida de la pantalla principal.

## Referencias de diseño

- [TeamViewer: conexión por ID](https://www.teamviewer.com/it/global/support/knowledge-base/teamviewer-remote/remote-control/connect-via-id-and-password/)
- [TeamViewer: soporte asistido](https://www.teamviewer.com/es/global/support/knowledge-base/teamviewer-remote/remote-control/provide-attended-remote-support/)
- [AnyDesk: permisos macOS](https://support.anydesk.com/docs/security-permissions-on-macos/)
- [RustDesk: compilación macOS](https://rustdesk.com/docs/en/dev/build/osx/)
