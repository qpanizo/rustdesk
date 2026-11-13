import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common.dart';
import '../consts.dart';
import '../models/server_model.dart';
import '../models/platform_model.dart';
import '../mobile/pages/server_page.dart' show showScamWarning;
import '../utils/android_documents.dart';
import 'permission_setup.dart';

class LimaFacNativePermissionSetup extends StatefulWidget {
  const LimaFacNativePermissionSetup({
    super.key,
    this.onInstall,
    this.onSecurity,
  });
  final Future<void> Function()? onInstall;
  final VoidCallback? onSecurity;

  @override
  State<LimaFacNativePermissionSetup> createState() =>
      _LimaFacNativePermissionSetupState();
}

class _LimaFacNativePermissionSetupState
    extends State<LimaFacNativePermissionSetup>
    with WidgetsBindingObserver {
  static const _iosChannel = MethodChannel('pe.limafac.remote/permissions');
  bool _notifications = false;
  bool _overlay = false;
  Map<String, dynamic> _ios = {};
  String? _statusError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      if (isAndroid) {
        await gFFI.invokeMethod('check_service');
        await gFFI.serverModel.checkAndroidPermission();
        _notifications =
            androidVersion < 33 ||
            await AndroidPermissionManager.check(kAndroid13Notification);
        _overlay = await AndroidPermissionManager.check(kSystemAlertWindow);
      } else if (isIOS) {
        _ios =
            await _iosChannel.invokeMapMethod<String, dynamic>('status') ?? {};
      }
      if (mounted) setState(() => _statusError = null);
    } catch (_) {
      if (mounted)
        setState(
          () => _statusError = 'No se pudo consultar algún permiso. Puedes volver a comprobarlo.',
        );
    }
  }

  Future<void> _open(String uri) async {
    if (!await launchUrl(Uri.parse(uri)))
      throw StateError('Settings could not be opened');
  }

  Future<void> _androidRequest(String permission) async {
    if (!await AndroidPermissionManager.check(permission)) {
      await AndroidPermissionManager.request(permission);
    }
  }

  Future<void> _shareScreen() async {
    if (gFFI.serverModel.mediaOk) return;
    if (gFFI.userModel.userName.value.isEmpty &&
        bind.mainGetLocalOption(key: 'show-scam-warning') != 'N') {
      showScamWarning(context, gFFI.serverModel);
    } else {
      await gFFI.serverModel.toggleService();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAndroid)
      return ChangeNotifierProvider.value(
        value: gFFI.serverModel,
        child: Consumer<ServerModel>(
          builder: (_, model, __) => _android(model),
        ),
      );
    if (isMacOS) {
      final screen = bind.mainIsCanScreenRecording(prompt: false);
      final input = bind.mainIsProcessTrusted(prompt: false);
      final screenStep = LimaFacPermissionItem(
        title: 'Compartir pantalla',
        granted: screen,
        detail: 'macOS lo llama Grabación de pantalla. Permite mostrar tu pantalla durante el soporte.',
        actionLabel: 'Abrir permiso de pantalla',
        onRequest: () async {
          bind.mainIsCanScreenRecording(prompt: true);
          await _open(
            'x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture',
          );
        },
        onManage: () => _open(
          'x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture',
        ),
      );
      final control = LimaFacPermissionItem(
        title: 'Teclado y mouse',
        granted: input,
        detail: 'Accesibilidad permite recibir control remoto. Actívalo solo si quieres que la persona de soporte pueda interactuar.',
        actionLabel: 'Abrir Accesibilidad',
        onRequest: () async {
          bind.mainIsProcessTrusted(prompt: true);
          await _open(
            'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility',
          );
        },
        onManage: () => _open(
          'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility',
        ),
      );
      return LimaFacPermissionSetup(
        platformName: 'macOS',
        screenSteps: [screenStep],
        controlSteps: [screenStep, control],
        receivingSupported: !bind.isOutgoingOnly(),
        onRefresh: _refresh,
        onSecurity: widget.onSecurity,
        notice: _statusError,
        optionalSteps: [
          LimaFacPermissionItem(
            title: 'Atajos al controlar otros equipos',
            detail: 'Monitorización de entrada captura determinadas teclas. No es un requisito para que otra persona vea tu pantalla.',
            granted: bind.mainIsCanInputMonitoring(prompt: false),
            actionLabel: 'Configurar atajos',
            onRequest: () async {
              bind.mainIsCanInputMonitoring(prompt: true);
              await _open(
                'x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent',
              );
            },
            onManage: () => _open(
              'x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent',
            ),
          ),
          if (!bind.isOutgoingOnly() &&
              bind.mainIsInstalled() &&
              !bind.isDisableInstallation())
            LimaFacPermissionItem(
              title: 'Servicio en segundo plano',
              detail: 'Solo para mantener disponible el equipo sin la ventana abierta. macOS puede pedir autorización de administrador. La autenticación se configura por separado.',
              granted: bind.mainIsInstalledDaemon(prompt: false),
              actionLabel: 'Instalar servicio',
              onRequest: () async {
                bind.mainIsInstalledDaemon(prompt: true);
              },
            ),
        ],
      );
    }
    if (isWindows)
      return LimaFacPermissionSetup(
        platformName: 'Windows',
        screenSteps: const [],
        controlSteps: const [],
        receivingSupported: !bind.isOutgoingOnly(),
        onRefresh: _refresh,
        onSecurity: widget.onSecurity,
        notice: 'Puedes iniciar soporte puntual sin instalar el servicio. Para tareas de administrador, Windows puede pedir elevación UAC; el usuario decide si la autoriza.',
        optionalSteps: [
          if (!bind.isDisableInstallation())
            LimaFacPermissionItem(
              title: 'Instalación y servicio',
              detail: 'Opcional para uso permanente, inicio de sesión y ventanas elevadas. Instalar no crea una contraseña ni autoriza conexiones por sí solo.',
              granted: bind.mainIsInstalled(),
              onRequest: widget.onInstall,
              actionLabel: 'Instalar LimaFac Remote',
            ),
        ],
      );
    return LimaFacPermissionSetup(
      platformName: 'iPhone / iPad',
      receivingSupported: false,
      screenSteps: const [],
      controlSteps: const [],
      onRefresh: _refresh,
      notice: _statusError ?? 'Esta versión permite controlar otros equipos desde tu iPhone o iPad. No recibe control remoto ni comparte su pantalla.',
      optionalSteps: [
        for (final entry in {
          'camera': 'Cámara para escanear QR',
          'photos': 'Fotos para leer un QR',
        }.entries)
          LimaFacPermissionItem(
            title: entry.value,
            granted:
                _ios[entry.key] == 'authorized' || _ios[entry.key] == 'limited',
            detail: 'Se solicita al utilizar esa función. Puedes cambiarlo en los ajustes de iOS; no hace falta para conectarte por ID.',
            pendingLabel: _ios[entry.key] == 'denied'
                ? 'No permitido'
                : 'Al usar la función',
            actionLabel: 'Abrir ajustes',
            onRequest: () async {
              if (await _iosChannel.invokeMethod<bool>('open_settings') != true)
                throw StateError('Settings could not be opened');
            },
            onManage: () async {
              if (await _iosChannel.invokeMethod<bool>('open_settings') != true)
                throw StateError('Settings could not be opened');
            },
          ),
      ],
    );
  }

  Widget _android(ServerModel model) {
    final locked =
        model.clients.any((client) => !client.disconnected) &&
        !option2bool(
          kOptionEnablePermChangeInAcceptWindow,
          bind.mainGetBuildinOption(key: kOptionEnablePermChangeInAcceptWindow),
        );
    final canChange =
        !locked &&
        !bind.isDisableSettings() &&
        !bind.isOutgoingOnly() &&
        bind.mainGetBuildinOption(key: kOptionHideSecuritySetting) != 'Y';
    final screen = LimaFacPermissionItem(
      title: 'Compartir pantalla',
      granted: model.mediaOk,
      detail: 'Android mostrará su confirmación de captura para esta sesión. Puedes detenerla desde la aplicación o los controles del sistema.',
      actionLabel: 'Preparar pantalla',
      onRequest: _shareScreen,
      onManage: bind.mainGetBuildinOption(key: kOptionHideStopService) == 'Y'
          ? null
          : () async {
              await model.toggleService();
            },
      manageLabel: 'Detener pantalla',
    );
    final control = LimaFacPermissionItem(
      title: 'Control táctil y teclado',
      granted: model.inputOk,
      detail: 'Accesibilidad permite que el soporte pulse y escriba. No hace falta si solo quieres compartir la pantalla.',
      actionLabel: 'Configurar Accesibilidad',
      onRequest: canChange && !isOptionFixed(kOptionEnableKeyboard)
          ? () async {
              await model.toggleInput();
            }
          : null,
      onManage: canChange && !isOptionFixed(kOptionEnableKeyboard)
          ? () async {
              await model.toggleInput();
            }
          : null,
      manageLabel: 'Desactivar control',
      pendingLabel: canChange ? 'Pendiente' : 'Administrado',
    );
    return LimaFacPermissionSetup(
      platformName: 'Android',
      screenSteps: [screen],
      controlSteps: [screen, control],
      receivingSupported: !bind.isOutgoingOnly(),
      initialUse: LimaFacSupportUse.control,
      onRefresh: _refresh,
      onSecurity: widget.onSecurity,
      notice:
          _statusError ??
          (locked
              ? 'Hay una sesión activa. Algunas opciones están bloqueadas por la política de seguridad.'
              : null),
      optionalSteps: [
        if (androidVersion >= 33)
          LimaFacPermissionItem(
            title: 'Notificaciones de soporte',
            granted: _notifications,
            detail: 'Recomendadas para ver avisos de conexión. No necesitas concederlas para iniciar la captura.',
            onRequest: () => _androidRequest(kAndroid13Notification),
          ),
        LimaFacPermissionItem(
          title: 'Botón flotante',
          granted: _overlay,
          detail: 'Muestra un control sobre otras aplicaciones. Puedes compartir pantalla sin activarlo.',
          onRequest: () => _androidRequest(kSystemAlertWindow),
        ),
        if (androidVersion >= 30)
          LimaFacPermissionItem(
            title: 'Audio',
            granted: model.audioOk,
            detail: 'Actívalo solo si la sesión necesita sonido. Android puede pedir acceso al micrófono.',
            onRequest: canChange && !isOptionFixed(kOptionEnableAudio)
                ? () async {
                    await model.toggleAudio();
                  }
                : null,
            onManage: canChange && !isOptionFixed(kOptionEnableAudio)
                ? () async {
                    await model.toggleAudio();
                  }
                : null,
            manageLabel: 'Desactivar',
          ),
        LimaFacPermissionItem(
          title: 'Transferencia de archivos',
          granted: model.fileOk,
          detail: 'Permite el intercambio de archivos dentro de las carpetas compartidas. No se pide acceso general al almacenamiento.',
          onRequest: canChange && !isOptionFixed(kOptionEnableFileTransfer)
              ? () async {
                  await model.toggleFile();
                }
              : null,
          onManage: canChange && !isOptionFixed(kOptionEnableFileTransfer)
              ? () async {
                  await model.toggleFile();
                }
              : null,
          manageLabel: 'Desactivar',
        ),
        if (canChange && model.fileOk)
          LimaFacPermissionItem(
            title: 'Carpeta compartida',
            granted:
                bind.getLocalFlutterOption(
                  k: 'android-file-transfer-folder-setup',
                ) ==
                'Y',
            detail: 'Elige con el selector de Android la carpeta que podrá utilizar el soporte.',
            actionLabel: 'Elegir carpeta',
            onRequest: _selectFolder,
            onManage: _selectFolder,
            manageLabel: 'Cambiar carpeta',
          ),
        LimaFacPermissionItem(
          title: 'Portapapeles',
          granted: model.clipboardOk,
          detail: 'Permite compartir texto copiado. Es independiente del permiso para ver la pantalla.',
          onRequest: canChange && !isOptionFixed(kOptionEnableClipboard)
              ? () async {
                  await model.toggleClipboard();
                }
              : null,
          onManage: canChange && !isOptionFixed(kOptionEnableClipboard)
              ? () async {
                  await model.toggleClipboard();
                }
              : null,
          manageLabel: 'Desactivar',
        ),
        if (canChange)
          LimaFacPermissionItem(
            title: 'Carpeta de diagnóstico',
            granted: false,
            pendingLabel: 'Opcional',
            detail: 'Elige dónde guardar registros solo cuando necesites resolver un problema.',
            actionLabel: 'Configurar diagnóstico',
            onRequest: () async {
              await AndroidDocuments.requireLogFolder();
            },
          ),
      ],
    );
  }

  Future<void> _selectFolder() async {
    final selected = await AndroidDocuments.selectFolder(share: true);
    if (selected != null)
      await bind.setLocalFlutterOption(
        k: 'android-file-transfer-folder-setup',
        v: 'Y',
      );
  }
}
