# Icono LimaFac Remote

Propuesta 1 aprobada: dos pantallas enlazadas, fondo turquesa `#16A99E`,
pantalla posterior blanca y pantalla frontal petróleo `#103B40`. Sin texto,
gradientes ni fotografías. Se conserva el logo de LimaFac dentro de la interfaz;
este símbolo identifica la aplicación en el sistema operativo.

## Tamaños y peso

| Uso | Recursos | Peso de los recursos |
| --- | --- | --- |
| Maestro | `res/icon.png`, 1024×1024, opaco | 8.640 bytes |
| Interfaz Flutter | `flutter/assets/icon.png`, 128×128 | 1.208 bytes |
| Android | 48, 72, 96, 144 y 192 px; variantes redondas, notificación y dos vectores adaptables | 24.600 bytes en total |
| iPhone/iPad | 15 PNG para 19 slots existentes de 20 a 1024 px, incluidos Ajustes, Spotlight y tienda | 21.692 bytes en total |
| macOS | ICNS con resoluciones Retina hasta 1024 px | 25.308 bytes |
| Windows | ICO con frames 16, 24, 32, 48, 64, 128 y 256 px | 9.287 bytes |

Los pesos son los archivos exportados, antes del empaquetado de cada plataforma;
no representan el tamaño final de una descarga de tienda. El SVG maestro y la
imagen de Google Play están en `res/limafac/`, fuera de los assets de Flutter.
No se añaden paquetes ni procesos en ejecución: la exportación se hace durante
desarrollo y los sistemas cargan la resolución que necesitan.

PNG de paleta optimizada y sin metadatos innecesarios. Las capas de Android
adaptable son vectores: no se repite un bitmap grande por cada densidad. Los
recursos de iOS son opacos y cuadrados; el sistema aplica su máscara. Mac usa
un margen óptico para su ICNS clásico. La variante monocromática de Android
mantiene transparencia y formas; no reutiliza el fondo como silueta sólida.
Los ICO de Windows y de bandeja conservan color para tener contraste en fondos
claros y oscuros.

## Regeneración

Desde la raíz del repositorio, con Python y Pillow disponibles:

```sh
python3 scripts/limafac/generate-icons.py
```

El script genera todos los recursos, incluidos ICNS y los frames PNG comprimidos
de ICO. El dibujo se define mediante las mismas dos geometrías redondeadas para
los tamaños raster y para los vectores. `res/limafac/icon.svg` se regenera también.
El script y las fuentes de alta resolución no forman parte del runtime.

No ejecutar encima el generador genérico de launchers upstream: puede reemplazar
las capas vectoriales/monocromáticas y el margen de Mac por otros valores.

## Validación

- Se comprobaron todos los slots iOS contra `Contents.json`, tamaño y opacidad.
- Se comprobaron las cinco densidades Android y el margen de la geometría del
  vector: cabe dentro de la zona segura central de 66/108.
- Se decodificaron los contenedores ICNS/ICO, incluidos frames de 16 y 256 px de
  Windows y la resolución de 1024 px de Mac.
- Se revisaron vistas previas con máscaras circular y redondeada, y los tamaños
  pequeños de 16 a 64 px.
- Mac arm64 compiló en release y abrió correctamente. Se verificó que los
  bytes del ICNS y los assets Flutter de la app coinciden con los exportados.
- Las variantes móviles están aplicadas al proyecto; no se afirma instalación
  ni prueba en un móvil físico en esta entrega.

## Superficie de regresión

Solo recursos gráficos y referencias de iconos; sin cambios en Dart, Rust,
permisos, identificadores, servicios o comportamiento de acceso remoto.
La identidad gráfica nativa de este fork se aplica también al usar el diseño
clásico; `LIMAFAC_UI=false` sigue seleccionando las rutas visuales originales.

| Ruta existente | Cambio necesario |
| --- | --- |
| `flutter/android/app/src/main/res/mipmap-*/ic_launcher.png`, `ic_launcher_round.png`, `ic_stat_logo.png` | Sustituye launchers y notificaciones para las cinco densidades. |
| `flutter/android/app/src/main/res/mipmap-*/ic_launcher_foreground.png` | Se eliminan los cinco bitmaps antiguos; los XML adaptables ahora usan vector. |
| `flutter/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`, `ic_launcher_round.xml` | Apuntan al foreground y a la silueta monocromática nuevos. |
| `flutter/android/app/src/main/res/values/ic_launcher_background.xml` | Fondo turquesa de la propuesta elegida. |
| `flutter/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` | Sustituye los tamaños de iPhone/iPad conservando el catálogo y sus nombres. |
| `flutter/macos/Runner/AppIcon.icns` | Identidad de la aplicación en Finder/Dock. |
| `flutter/windows/runner/resources/app_icon.ico`, `res/icon.ico`, `res/tray-icon.ico` | Iconos del runner, ejecutable nativo y bandeja. |
| `res/icon.png`, `res/mac-icon.png` | Maestros utilizados por las herramientas de empaquetado existentes. |
| `flutter/assets/icon.png`, `flutter/assets/icon.ico` (nuevos) | La carga `loadIcon` existente y la ruta nativa del icono Windows encuentran la identidad LimaFac. No se modifica ese código. |

## Referencias

- https://developer.android.com/develop/ui/compose/system/icon_design_adaptive
- https://developer.apple.com/design/human-interface-guidelines/app-icons/
- https://developer.apple.com/documentation/xcode/configuring-your-app-icon
