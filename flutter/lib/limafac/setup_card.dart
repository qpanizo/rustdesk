import 'package:flutter/material.dart';

const limaFacSetupInstructions = {
  'config_screen': (
    '1. Compartir pantalla',
    'Permite ver tu pantalla durante el soporte. Abre los ajustes de macOS y habilita la grabación de pantalla para esta aplicación.',
  ),
  'config_acc': (
    '2. Controlar tu equipo',
    'Permite usar el teclado y el mouse durante el soporte. Habilita Accesibilidad para esta aplicación en los ajustes de macOS.',
  ),
  'config_input': (
    'Atajos del teclado',
    'macOS pide este permiso para capturar determinadas teclas al controlar otro equipo. Actívalo si necesitas esa función.',
  ),
  'install_daemon_tip': (
    'Acceso en segundo plano',
    'Instala el servicio si necesitas que el equipo siga disponible después de cerrar la aplicación o reiniciar. macOS solicitará autorización de administrador.',
  ),
  'install_tip': (
    'Instalación opcional',
    'Puedes continuar con el soporte sin instalar. Instala la aplicación si necesitas acceso permanente o trabajar con ventanas de administrador.',
  ),
};

class LimaFacSetupCard extends StatelessWidget {
  const LimaFacSetupCard({
    super.key,
    required this.title,
    required this.content,
    required this.actionLabel,
    required this.onAction,
    this.onHelp,
    this.helpLabel,
    this.onClose,
  });

  final String title;
  final String content;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onHelp;
  final String? helpLabel;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(15),
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (onClose != null)
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(height: 1.5)),
          if (actionLabel.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
          if (onHelp != null)
            TextButton(onPressed: onHelp, child: Text(helpLabel ?? 'Ayuda')),
        ],
      ),
    );
  }
}
