import 'package:flutter/material.dart';

import 'brand.dart';

class LimaFacHomeShell extends StatelessWidget {
  const LimaFacHomeShell({
    super.key,
    required this.receive,
    required this.connection,
    required this.onSettings,
  });

  final Widget receive;
  final Widget connection;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LimaFacBrand.theme(Theme.of(context)),
      child: Builder(
        builder: (context) {
          return ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      const LimaFacLogo(),
                      const Spacer(),
                      if (onSettings != null)
                        IconButton(
                          tooltip: 'Ajustes',
                          onPressed: onSettings,
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      IconButton(
                        tooltip: 'Cómo comenzar',
                        onPressed: () => _showHelp(context),
                        icon: const Icon(Icons.help_outline_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 760;
                      final receiveCard = _Panel(
                        title: 'Recibir ayuda',
                        subtitle:
                            'Comparte tu ID con la persona que te ayudará.',
                        icon: Icons.support_agent_outlined,
                        child: receive,
                      );
                      final connectionCard = _Panel(
                        title: 'Conectarse a un equipo',
                        subtitle:
                            'Ingresa el ID del equipo al que darás soporte.',
                        icon: Icons.desktop_windows_outlined,
                        child: connection,
                      );
                      if (compact) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SizedBox(
                                height: constraints.maxHeight * .40,
                                child: receiveCard,
                              ),
                              const SizedBox(height: 12),
                              Expanded(child: connectionCard),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth < 1000 ? 260 : 300,
                              child: receiveCard,
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: connectionCard),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'LimaFac Remote · Basado en RustDesk',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comienza en pocos pasos'),
        content: const SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Text(
              'Para recibir ayuda, comparte tu ID y sigue las indicaciones de acceso. '
              'Para dar soporte, ingresa el ID del otro equipo y pulsa Conectar.\n\n'
              'En Mac, permite ver la pantalla y controlar el teclado y el mouse '
              'cuando lo solicites desde el asistente. El micrófono y otras funciones '
              'tienen permisos independientes.\n\n'
              'En Windows puedes usar el modo sin instalación cuando esté disponible. '
              'El sistema puede pedir autorización de administrador para instalar '
              'o controlar ventanas elevadas.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
