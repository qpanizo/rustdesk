import 'package:flutter/material.dart';

import 'brand.dart';

class LimaFacInstallerShell extends StatelessWidget {
  const LimaFacInstallerShell({
    super.key,
    required this.options,
    required this.agreement,
    required this.license,
    required this.progress,
    required this.actions,
  });

  final List<Widget> options;
  final String agreement;
  final Widget license;
  final Widget progress;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LimaFacBrand.theme(Theme.of(context)),
      child: Builder(
        builder: (context) => Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LimaFacLogo(),
                    const SizedBox(height: 24),
                    const Text(
                      'Todo listo para dar soporte',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Instala la aplicación para tenerla siempre disponible. '
                      'Windows puede pedir autorización de administrador.',
                    ),
                    const SizedBox(height: 20),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('Opciones de instalación'),
                      children: options,
                    ),
                    const SizedBox(height: 12),
                    Text(agreement),
                    license,
                    const SizedBox(height: 16),
                    progress,
                    const SizedBox(height: 16),
                    Wrap(spacing: 12, runSpacing: 12, children: actions),
                    const SizedBox(height: 24),
                    Text(
                      'LimaFac Remote · Basado en RustDesk',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
