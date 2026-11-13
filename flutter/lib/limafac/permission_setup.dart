import 'package:flutter/material.dart';

import 'icons.dart';

enum LimaFacSupportUse { outgoing, screen, control }

class LimaFacPermissionItem {
  const LimaFacPermissionItem({
    required this.title,
    required this.detail,
    required this.granted,
    this.onRequest,
    this.onManage,
    this.actionLabel = 'Permitir',
    this.manageLabel = 'Revisar',
    this.pendingLabel = 'Pendiente',
  });
  final String title;
  final String detail;
  final bool granted;
  final Future<void> Function()? onRequest;
  final Future<void> Function()? onManage;
  final String actionLabel;
  final String manageLabel;
  final String pendingLabel;
}

class LimaFacPermissionSetup extends StatefulWidget {
  const LimaFacPermissionSetup({
    super.key,
    required this.platformName,
    required this.screenSteps,
    required this.controlSteps,
    required this.optionalSteps,
    required this.onRefresh,
    this.outgoingSteps = const [],
    this.receivingSupported = true,
    this.initialUse = LimaFacSupportUse.control,
    this.onSecurity,
    this.notice,
  });
  final String platformName;
  final List<LimaFacPermissionItem> screenSteps;
  final List<LimaFacPermissionItem> controlSteps;
  final List<LimaFacPermissionItem> outgoingSteps;
  final List<LimaFacPermissionItem> optionalSteps;
  final Future<void> Function() onRefresh;
  final bool receivingSupported;
  final LimaFacSupportUse initialUse;
  final VoidCallback? onSecurity;
  final String? notice;

  @override
  State<LimaFacPermissionSetup> createState() => _LimaFacPermissionSetupState();
}

class _LimaFacPermissionSetupState extends State<LimaFacPermissionSetup> {
  late LimaFacSupportUse _use;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _use = widget.receivingSupported
        ? widget.initialUse
        : LimaFacSupportUse.outgoing;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      await widget.onRefresh();
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'No se pudo completar la acción. Vuelve a comprobar el estado o abre los ajustes del sistema.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _use == LimaFacSupportUse.outgoing
        ? widget.outgoingSteps
        : _use == LimaFacSupportUse.screen
        ? widget.screenSteps
        : widget.controlSteps;
    final next = steps.indexWhere((step) => !step.granted);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Permisos del equipo · ${widget.platformName}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configura solo lo que vas a utilizar. Cada autorización se confirma en el sistema.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<LimaFacSupportUse>(
            value: _use,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Objetivo de configuración',
            ),
            items: [
              const DropdownMenuItem(
                value: LimaFacSupportUse.outgoing,
                child: Text('Dar soporte a otro equipo'),
              ),
              if (widget.receivingSupported) ...[
                const DropdownMenuItem(
                  value: LimaFacSupportUse.screen,
                  child: Text('Compartir mi pantalla'),
                ),
                const DropdownMenuItem(
                  value: LimaFacSupportUse.control,
                  child: Text('Recibir control remoto'),
                ),
              ],
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) setState(() => _use = value);
                  },
          ),
          const SizedBox(height: 16),
          if (widget.notice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(widget.notice!),
            ),
        if (steps.isEmpty)
          Text(_use == LimaFacSupportUse.outgoing
            ? 'No necesitas conceder acceso a la pantalla ni al teclado de este equipo para controlar otro.'
            : 'No hay permisos de pantalla adicionales que configurar aquí. Las conexiones siguen sujetas a la autenticación y a las autorizaciones de Windows.'),
          if (steps.isNotEmpty) ...[
            Text(
              next < 0
                  ? 'Permisos del sistema listos para este uso'
                  : 'Paso ${next + 1} de ${steps.length}',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < steps.length; i++)
              _row(context, steps[i], canRequest: i == next),
          ],
          const SizedBox(height: 8),
          const Text(
            'Esta selección organiza la configuración. No cambia las contraseñas ni los permisos de las sesiones.',
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: _busy ? null : () => _run(widget.onRefresh),
                icon: const LimaFacIcon(Icons.refresh_rounded, size: 18),
                label: const Text('Volver a comprobar'),
              ),
              if (widget.onSecurity != null)
                TextButton(
                  onPressed: widget.onSecurity,
                  child: const Text('Acceso y seguridad de las sesiones'),
                ),
            ],
          ),
          if (widget.optionalSteps.isNotEmpty)
            ExpansionTile(
              title: const Text('Funciones opcionales'),
              subtitle: const Text('Actívalas solo si las necesitas'),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final step in widget.optionalSteps) _row(context, step),
              ],
            ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    LimaFacPermissionItem step, {
    bool canRequest = true,
  }) {
    final action = step.granted
        ? step.onManage
        : canRequest
        ? step.onRequest
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                step.granted
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 18,
                color: step.granted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).hintColor,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(step.title)),
              const SizedBox(width: 8),
              Text(
                step.granted ? 'Permitido' : step.pendingLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              step.detail,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 8),
              child: OutlinedButton(
                onPressed: _busy ? null : () => _run(action),
                child: Text(step.granted ? step.manageLabel : step.actionLabel),
              ),
            ),
        ],
      ),
    );
  }
}
