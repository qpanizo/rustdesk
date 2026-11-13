import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'settings_widgets.dart';

class LimaFacPoliciesPage extends StatelessWidget {
  const LimaFacPoliciesPage({
    super.key,
    this.version = '',
    this.buildDate = '',
    this.license = '',
    required this.onSource,
    required this.onUpstreamPrivacy,
  });
  final String version;
  final String buildDate;
  final String license;
  final VoidCallback onSource;
  final VoidCallback onUpstreamPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectionArea(
      child: ListView(
        children: [
          const LimaFacSettingsGroup(
            title: 'Acceso y permisos',
            children: [
              Text(
                'Comparte tu ID y tu contraseña temporal solo con la persona que te dará soporte. '
                'Revisa las solicitudes de conexión antes de aceptarlas.',
              ),
              Text(
                'Los permisos de pantalla, teclado y mouse se gestionan en los ajustes del sistema operativo. '
                'El acceso en segundo plano y las opciones de autenticación se administran desde la configuración de seguridad.',
              ),
            ],
          ),
          const LimaFacSettingsGroup(
            title: 'Conexiones y datos',
            children: [
              Text(
                'Las conexiones utilizan los servidores configurados en esta instalación. '
                'Puedes revisar esa configuración en Red y los permisos de acceso en Seguridad.',
              ),
              Text(
                'La transferencia de archivos, el portapapeles, el audio y la grabación de sesiones dependen '
                'de las funciones y permisos habilitados. Revisa las opciones antes de compartir información.',
              ),
            ],
          ),
          LimaFacSettingsGroup(
            title: 'LimaFac Remote',
            children: [
              if (version.isNotEmpty) Text('Versión del motor: $version'),
              if (buildDate.isNotEmpty) Text('Compilación: $buildDate'),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: const Text('Créditos y licencias de código abierto'),
                children: [
                  const Text(
                    'LimaFac Remote está desarrollado en base a RustDesk. '
                    'La personalización de LimaFac adapta la interfaz y reutiliza su motor de conexión remota.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'RustDesk · Copyright © 2026 Purslane Tech Pte. Ltd.',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (license.isNotEmpty)
                    Text(license, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  const Text(
                    'El código de esta base se distribuye bajo GNU Affero General Public License, versión 3 (AGPL-3.0).',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => _showLicense(context),
                        child: const Text('Ver licencia AGPL-3.0'),
                      ),
                      TextButton(
                        onPressed: onSource,
                        child: const Text('Código fuente'),
                      ),
                      TextButton(
                        onPressed: onUpstreamPrivacy,
                        child: const Text('Privacidad de RustDesk'),
                      ),
                      TextButton(
                        onPressed: () => showLicensePage(
                          context: context,
                          applicationName: 'LimaFac Remote',
                        ),
                        child: const Text('Licencias de componentes'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLicense(BuildContext context) async {
    final text = await rootBundle.loadString('assets/limafac-LICENCE.txt');
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GNU AGPL · versión 3'),
        content: SizedBox(
          width: 680,
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
