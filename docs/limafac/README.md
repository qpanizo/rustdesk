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

- Distribución basada en la captura de TeamViewer proporcionada: menú lateral,
  buscador superior y un único panel central con credenciales a la izquierda
  y conexión a la derecha. La marca y los colores son de LimaFac.
- Fondo claro por defecto y switch con iconos de sol/luna, sin texto visible,
  para alternar la apariencia.
  El modo oscuro usa lateral casi negro, paneles gris neutro y acentos turquesa;
  textos, iconos, bordes y campos se adaptan al tema.
- «Dispositivos» usa navegación secundaria para últimas conexiones, favoritos,
  red, libreta y equipos accesibles, según las funciones habilitadas en RustDesk.
  Conserva las búsquedas, selección, ordenación y listas originales; el estado
  vacío se presenta dentro del nuevo marco. La búsqueda superior conecta mediante
  la misma función de RustDesk que el campo principal.
- «Ajustes» se integra en el mismo marco, sin abrir la pestaña antigua. Incluye
  Personalización y las categorías nativas disponibles. Las opciones y sus
  comprobaciones originales se presentan en grupos planos y adaptables al tema.
- Tipografía de sistema consistente (Helvetica Neue en Mac, Segoe UI en Windows),
  cuerpo de 13–14, títulos de 15–19 y pesos 400/500. Los iconos de navegación y
  acciones LimaFac usan trazos SVG de 1.65 en una cuadrícula de 24, sin dependencias nuevas.
  Botones, selección de texto y estados de hover usan colores propios para evitar
  heredar el gris y la negrita de los controles upstream.
- La firma visible es «LimaFac Remote · Hecho con» y un corazón. En la interfaz
  LimaFac, «Acerca de» se reemplaza por «Políticas y seguridad». Sus detalles de
  créditos conservan la atribución a RustDesk/Purslane, el enlace al código fuente,
  la privacidad original y las licencias de componentes. La licencia AGPL completa
  se incluye sin cambios en `flutter/assets/limafac-LICENCE.txt` y se puede leer sin conexión.
- Tarjeta propia de ID/contraseña enlazada a los controladores originales, con
  copia y renovación de contraseña temporal mediante los callbacks existentes.
  Se respetan los modos de aprobación y de contraseña permanente.
- Configuración del equipo plegable e indicador inferior de permisos pendientes.
  Los avisos de seguridad por contraseña preconfigurada permanecen visibles.
  El indicador «Listo» utiliza el estado real del servicio.
- Instalador de Windows con opciones avanzadas plegadas. Reutiliza la
  validación del directorio, las opciones de instalación, confirmaciones,
  progreso y acciones nativas originales.
- Los clientes restringidos a entrada o salida conservan su interfaz original.
- `--dart-define=LIMAFAC_UI=false` restaura las rutas visuales originales.
  En este fork la personalización está activada por defecto.

Los textos propios de LimaFac están en español y no alteran los catálogos de
traducción del motor. Los controles reutilizados siguen el idioma configurado
en RustDesk. El título principal es «LimaFac Remote». Los servicios y el motor
conservan su identidad original. La copia local de desarrollo para Mac usa el
identificador `pe.limafac.remote.dev` y firma local; no es un instalador de
producción firmado y notarizado.

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

Validación actual: nueve pruebas de componentes con Flutter 3.47.8; todas
pasaron. Cubren tamaños compacto/escritorio, temas claro/oscuro, navegación,
búsqueda, credenciales, contraste de botones, detalle de créditos/licencia y
acciones de configuración/instalación.

El cliente nativo macOS arm64 se compiló y abrió con el motor oficial del
commit `3ccb4c4b5b5a8422276dd5f6f211b42e05ec9534`. La única diferencia nativa
respecto a nuestra base `b84058e07` está en `src/server/uinput.rs` (Linux).
Se verificaron 318 símbolos del puente contra la biblioteca original, sin
símbolos faltantes. Se reutilizó el puente generado por el CI oficial; no se
regeneró localmente. La compilación local aplica en una copia de trabajo los
ajustes de compatibilidad para Flutter reciente, conservando las fuentes del
fork para el toolchain original.

La aplicación de desarrollo está en `build/macos/LimaFacRemote.app`. Se comprobó
el arranque, la presentación de ID real y estado del servicio, Dispositivos,
Personalización y los controles de General y Pantalla. La revisión más reciente
comprobó la tipografía, iconos, firma y Políticas y seguridad en ambos temas. El selector de tema
comparte su estado entre la cabecera y Personalización; se revisaron ambos
temas en la aplicación nativa. Se conservan las extensiones de tema de
RustDesk para que sus controles internos se representen correctamente. No se ha
validado una sesión remota entre dos equipos ni un instalador de Windows.

## Superficie de regresión

| Archivo existente | Ruta afectada y motivo |
| --- | --- |
| `flutter/lib/desktop/pages/desktop_home_page.dart` | Selecciona la pantalla LimaFac en el cliente completo, integra Dispositivos/Ajustes, conserva las extensiones del tema nativo, cambia la representación de tarjetas y omite el botón de actualización upstream en esa variante. Los controles de sesión y callbacks de permisos se reutilizan. |
| `flutter/lib/desktop/pages/connection_page.dart` | Añade una presentación opcional del formulario de conexión, con título de tamaño/peso reducido, y un estado compacto para el pie. El autocompletado, validación, menús y acciones de conexión siguen siendo originales. Los valores por defecto conservan el diseño upstream. |
| `flutter/lib/common/widgets/peer_tab_page.dart` | Añade navegación secundaria opcional y presentación del estado vacío, reutilizando modelos, carga de listas, selección, acciones y filtros existentes. El constructor mantiene el diseño original por defecto. |
| `flutter/lib/desktop/pages/desktop_setting_page.dart` | Añade presentación integrada opcional, reutiliza las categorías y controles nativos, mantiene el bloqueo durante sesiones y adapta los grupos visuales únicamente dentro de su ámbito LimaFac. En esta variante, el índice de Acerca de muestra Políticas y seguridad con datos de versión/licencia originales; la ruta clásica conserva Acerca de. |
| `flutter/lib/desktop/pages/desktop_tab_page.dart` | Dirige los accesos a Ajustes hacia el marco LimaFac cuando está disponible; conserva la ruta original como alternativa. |
| `flutter/lib/main.dart` | Cambia el título de la ventana principal del cliente completo cuando la interfaz LimaFac está activa. |
| `flutter/lib/desktop/pages/install_page.dart` | Selecciona el formulario simplificado de instalación y conserva sus métodos de instalación, validación y permisos. |

No se modifican el motor Rust, protocolos, modelos, puente FFI ni submódulos.
La ruta original sigue disponible con `LIMAFAC_UI=false` y en los modos
restringidos de entrada/salida de la pantalla principal.

La corrección del selector de tema afecta a `flutter/lib/limafac/home_shell.dart`
(switch y colores adaptativos de navegación) y `flutter/lib/limafac/brand.dart`
(superficies, campos, bordes y textos neutros del tema oscuro). Se verificó que
el lateral cambie de color al activar el switch y vuelva a su color original
al desactivarlo, también en ventanas compactas.

La revisión tipográfica afecta a los componentes existentes `brand.dart`,
`home_shell.dart`, `credentials_card.dart`, `sectioned_page.dart`,
`settings_widgets.dart`, `setup_card.dart` e `installer_shell.dart` dentro de
`flutter/lib/limafac/`: solo estilos, iconos y firma. Son los puntos necesarios
para unificar las vistas, sin alterar sus callbacks ni opciones de seguridad.

## Referencias de diseño

- [TeamViewer: conexión por ID](https://www.teamviewer.com/it/global/support/knowledge-base/teamviewer-remote/remote-control/connect-via-id-and-password/)
- [TeamViewer: soporte asistido](https://www.teamviewer.com/es/global/support/knowledge-base/teamviewer-remote/remote-control/provide-attended-remote-support/)
- [AnyDesk: permisos macOS](https://support.anydesk.com/docs/security-permissions-on-macos/)
- [RustDesk: compilación macOS](https://rustdesk.com/docs/en/dev/build/osx/)
