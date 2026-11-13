# Permisos y acceso remoto

LimaFac Remote conserva las sesiones, control de teclado/mouse/táctil,
transferencia de archivos, portapapeles, audio y autenticación de RustDesk.
El asistente prepara las autorizaciones del sistema; no sustituye la seguridad
de las sesiones ni implementa roles empresariales de un servidor.

## Flujo implementado

El usuario elige el objetivo: dar soporte, compartir su pantalla o recibir
control remoto. Los permisos se comprueban sin solicitarlos al abrir el
asistente. Solo el botón de un paso abre una solicitud o ajustes nativos. El
paso siguiente se habilita cuando la comprobación real confirma el anterior.
Volver de Ajustes actualiza los estados; existe también comprobación manual.
Rechazar o cancelar no marca un permiso como concedido.

La elección del objetivo guía la preparación: no cambia contraseñas,
autenticación ni las capacidades concedidas a sesiones existentes. Se conservan
los controles originales de seguridad y las restricciones administrativas.

| Plataforma | Preparación básica | Opciones separadas |
| --- | --- | --- |
| Windows | Uso puntual con el token del usuario. El manifiesto declara `asInvoker`, sin UIAccess. UAC y las elevaciones existentes siguen intactos. | Instalación del servicio para disponibilidad permanente y tareas elevadas. La contraseña/aprobación se configura por separado. |
| macOS | Compartir pantalla: Grabación de pantalla. Recibir control: además Accesibilidad. Los enlaces abren los paneles nativos correspondientes. | Monitorización de entrada para ciertos atajos al controlar otro equipo. Servicio en segundo plano, si la app está instalada. Micrófono a demanda, con texto de propósito claro. |
| Android | MediaProjection para la pantalla y Accesibilidad si se requiere control táctil/teclado. Se mantienen los avisos antifraude y el consentimiento nativo. | Notificaciones, ventana flotante, audio, transferencia de archivos, carpeta compartida, portapapeles y carpeta de diagnóstico. Respeta opciones fijas y bloqueos durante sesiones. Se conserva la posibilidad de detener captura/control. |
| iPhone/iPad | Esta base es un cliente que controla otros equipos. No ofrece recepción de control ni captura de su propia pantalla. | Consulta nativa de estado de cámara/fotos y enlace a Ajustes. Estos permisos se solicitan al usar QR, no al preparar acceso por ID. No se añade un permiso ni una capacidad inexistente. |

## Cambios nativos

- Android comunica concesión y denegación mediante `OnPermissionCallback` de
  XXPermissions 18.5. Dart prepara el `Completer` antes de enviar la solicitud,
  evita reemplazar una solicitud activa, ignora respuestas de otro permiso y
  tolera respuestas duplicadas. Se conserva el límite de espera como respaldo.
- El arranque de pantalla de LimaFac en Android ya no abre antes selectores de
  carpetas de logs/archivos, notificaciones, superposición y una segunda alerta
  genérica. MediaProjection sigue solicitando consentimiento y la notificación
  del servicio sigue siendo responsabilidad del componente nativo original.
  La ruta sin `LIMAFAC_UI` conserva su secuencia original.
- El canal nativo iOS `pe.limafac.remote/permissions` solo consulta estados y
  abre `UIApplication.openSettingsURLString`; no concede acceso ni solicita
  permisos al consultar. La concesión sigue en cámara/selector del sistema.
- Los textos nativos de propósito usan LimaFac Remote. El servicio de entrada
  Android explica su capacidad de tocar/escribir y cómo desactivarla.
- No se usan root, ADB, modificaciones de TCC, permisos globales de almacenamiento,
  UIAccess ni desactivación de UAC. No se cambia el motor Rust o el puente FFI.

## Validación y límites

- 12 pruebas de widgets: navegación y tema, credenciales, asistente secuencial,
  ausencia de solicitudes automáticas, funciones opcionales y capacidades iOS.
- Análisis Dart de los adaptadores y puntos de integración: sin errores.
- Swift: comprobación de sintaxis. Plist y manifiestos XML: válidos.
- El código de callbacks Android se contrastó con la interfaz original de
  XXPermissions 18.5.
- macOS arm64: compilación release correcta, firma local verificada y aplicación
  abierta. Se revisaron los pasos de recepción de control y el objetivo de dar
  soporte sin solicitudes automáticas. No se concedieron permisos durante la
  comprobación ni se probó una sesión remota entre dos equipos.
- Falta validar en equipos Windows, Android e iOS: no hay SDK Android/JDK ni
  entorno de compilación Windows preparado en esta máquina, y no se compiló
  aquí el motor iOS. No se afirma que esas plataformas estén instaladas o
  verificadas en dispositivos físicos.
- macOS de desarrollo usa firma local. Distribución estable requiere identidad
  nativa, certificados y notarización de producción; reemplazar binarios de
  desarrollo puede provocar que macOS revise de nuevo los permisos.
- Renombrar la app Android puede requerir volver a elegir su carpeta de logs
  si se venía usando la variante original. No se migran ni eliminan archivos.
- El acceso desatendido en móviles no equivale al de un PC: Android conserva
  sus autorizaciones de captura y restricciones de segundo plano. iOS no
  recibe control en esta base; requiere una implementación de hosting aparte
  para cualquier función adicional que la plataforma permita.

## Superficie de regresión de esta entrega

| Archivo existente | Ruta modificada y necesidad |
| --- | --- |
| `flutter/lib/desktop/pages/desktop_home_page.dart` | Conecta el asistente en la configuración LimaFac de Mac/Windows y refresca el indicador al volver. Conserva avisos de errores/actualización y las rutas clásicas/restringidas. |
| `flutter/lib/mobile/pages/server_page.dart` | Cambia el panel de permisos de Android por el asistente solo con LimaFac activo. Las conexiones y avisos antifraude se reutilizan. |
| `flutter/lib/mobile/pages/settings_page.dart` | Añade acceso al asistente en móvil si Ajustes está habilitado. No cambia el resto de opciones. |
| `flutter/lib/models/server_model.dart` | Solo LimaFac/Android inicia MediaProjection sin encadenar opciones no necesarias. No cambia autenticación ni el flujo de parada. |
| `flutter/lib/common.dart` | Corrige el ciclo de resolución de solicitudes Android para manejar denegaciones, solicitudes repetidas y respuestas duplicadas del callback nativo. |
| `flutter/android/app/src/main/kotlin/com/carriez/flutter_hbb/common.kt` | Entrega también denegaciones al Dart existente, evitando la espera de 120 segundos tras rechazar. |
| `flutter/android/app/src/main/AndroidManifest.xml` | Usa recursos de nombre de app y servicio de entrada. No amplía permisos ni exportaciones. |
| `flutter/android/app/src/main/res/values/strings.xml` | Identidad LimaFac y explicación clara del servicio de entrada. Se añade traducción española en un recurso nuevo. |
| `flutter/ios/Runner/AppDelegate.swift` | Registra el canal de consulta/apertura de ajustes en el motor que ya inicializa los plugins. No solicita autorizaciones. |
| `flutter/ios/Runner/Info.plist` | Nombre LimaFac y textos comprensibles para cámara/fotos; sin nuevos permisos. |
| `flutter/macos/Runner/Info.plist` | Explica la finalidad del micrófono. No cambia entitlements. |
| `flutter/windows/runner/runner.exe.manifest` | Declara explícitamente ejecución estándar. La instalación/elevación original continúa separada. |

## Referencias primarias

- https://developer.android.com/media/grow/media-projection
- https://developer.android.com/develop/ui/compose/notifications/notification-permission
- https://support.apple.com/guide/mac-help/control-access-screen-system-audio-recording-mchld6aa7d23/mac
- https://support.apple.com/en-ie/guide/mac-help/mh43185/27/mac/27
- https://developer.apple.com/documentation/replaykit/rpsystembroadcastpickerview
- https://learn.microsoft.com/en-us/windows/security/application-security/application-control/user-account-control/how-it-works
- https://github.com/getActivity/XXPermissions/blob/18.5/library/src/main/java/com/hjq/permissions/OnPermissionCallback.java
