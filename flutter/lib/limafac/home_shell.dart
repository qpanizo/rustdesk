import 'package:flutter/material.dart';

import 'brand.dart';

class LimaFacHomeShell extends StatefulWidget {
  const LimaFacHomeShell({
    super.key,
    required this.receive,
    required this.connection,
    required this.devices,
    required this.status,
    required this.setup,
    required this.needsSetup,
    required this.onQuickConnect,
    required this.onSettings,
    this.warning = const SizedBox.shrink(),
  });

  final Widget receive;
  final Widget connection;
  final Widget devices;
  final Widget status;
  final Widget setup;
  final bool needsSetup;
  final ValueChanged<String> onQuickConnect;
  final VoidCallback? onSettings;
  final Widget warning;

  @override
  State<LimaFacHomeShell> createState() => _LimaFacHomeShellState();
}

class _LimaFacHomeShellState extends State<LimaFacHomeShell> {
  final _search = TextEditingController();
  int _section = 0;
  bool _showSetup = false;
  bool _dark = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _quickConnect() {
    final id = _search.text.trim();
    if (id.isNotEmpty) widget.onQuickConnect(id);
  }

  void _openSetup() {
    setState(() {
      _section = 0;
      _showSetup = !_showSetup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LimaFacBrand.theme(
        ThemeData(
          brightness: _dark ? Brightness.dark : Brightness.light,
          useMaterial3: false,
        ),
      ),
      child: Builder(
        builder: (context) => LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 980;
            final theme = Theme.of(context);
            return Material(
              color: LimaFacBrand.sidebar,
              child: Row(
                children: [
                  _sidebar(context, narrow),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                      child: ColoredBox(
                        color: theme.cardColor,
                        child: Column(
                          children: [
                            _header(context),
                            Container(
                              height: 38,
                              width: double.infinity,
                              alignment: Alignment.center,
                              color: theme.colorScheme.primary.withAlpha(12),
                              child: Text(
                                'LimaFac Remote · Basado en RustDesk',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.hintColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: IndexedStack(
                                index: _section,
                                children: [
                                  _supportPage(context),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Dispositivos',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Expanded(child: widget.devices),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            SizedBox(
                              height: 46,
                              child: Row(
                                children: [
                                  Expanded(child: widget.status),
                                  if (widget.needsSetup)
                                    TextButton.icon(
                                      onPressed: _openSetup,
                                      icon: const Icon(
                                        Icons.tune_rounded,
                                        size: 16,
                                      ),
                                      label: Text(
                                        narrow ? 'Configurar' : 'Configuración del equipo necesaria',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sidebar(BuildContext context, bool narrow) {
    return SizedBox(
      width: narrow ? 76 : 232,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: narrow ? 10 : 12),
        child: Column(
          children: [
            SizedBox(
              height: narrow ? 88 : 122,
              child: Center(
                child: narrow
                    ? const Icon(
                        Icons.connected_tv_rounded,
                        color: Colors.white,
                        size: 30,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/limafac-logo-white.png',
                            width: 154,
                            height: 73,
                          ),
                          const Text(
                            'REMOTE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            _navItem(
              'Soporte remoto',
              Icons.sync_alt_rounded,
              narrow,
              selected: _section == 0,
              onTap: () => setState(() => _section = 0),
            ),
            const SizedBox(height: 6),
            _navItem(
              'Dispositivos',
              Icons.devices_outlined,
              narrow,
              selected: _section == 1,
              onTap: () => setState(() => _section = 1),
            ),
            const Spacer(),
            if (widget.onSettings != null)
              _navItem(
                'Ajustes',
                Icons.settings_outlined,
                narrow,
                onTap: widget.onSettings!,
              ),
            _navItem(
              'Ayuda',
              Icons.help_outline_rounded,
              narrow,
              onTap: () => _showHelp(context),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    String label,
    IconData icon,
    bool narrow, {
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: narrow ? label : '',
        child: Material(
          color: selected ? const Color(0xFF10847C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: narrow ? 0 : 14),
                child: Row(
                  mainAxisAlignment: narrow
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    IconTheme(
                      data: const IconThemeData(opacity: 1),
                      child: Icon(
                        icon,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFBAD9D6),
                        size: 21,
                      ),
                    ),
                    if (!narrow) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFFBAD9D6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _quickConnect(),
                    decoration: InputDecoration(
                      hintText: 'Buscar y conectar',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: IconButton(
                        tooltip: 'Conectar al ID indicado',
                        onPressed: _quickConnect,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                      ),
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              tooltip: _dark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
              onPressed: () => setState(() => _dark = !_dark),
              icon: Icon(
                _dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 21,
              ),
            ),
            if (widget.onSettings != null)
              IconButton(
                tooltip: 'Ajustes',
                onPressed: widget.onSettings,
                icon: const Icon(Icons.settings_outlined, size: 21),
              ),
            IconButton(
              tooltip: 'Cómo comenzar',
              onPressed: () => _showHelp(context),
              icon: const Icon(Icons.help_outline_rounded, size: 21),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportPage(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 740;
        final padding = constraints.maxWidth < 600 ? 18.0 : 32.0;
        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID de LimaFac',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _section = 1),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Dispositivos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              widget.warning,
              Container(
                padding: EdgeInsets.all(compact ? 20 : 26),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _receivePanel(context),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(height: 1),
                          ),
                          widget.connection,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _receivePanel(context)),
                          Container(
                            width: 1,
                            height: 250,
                            margin: const EdgeInsets.symmetric(horizontal: 26),
                            color: Theme.of(context).dividerColor,
                          ),
                          Expanded(child: widget.connection),
                        ],
                      ),
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: _openSetup,
                icon: Icon(
                  _showSetup ? Icons.expand_less_rounded : Icons.tune_rounded,
                  size: 18,
                ),
                label: Text(
                  _showSetup
                      ? 'Ocultar configuración'
                      : 'Configurar este equipo',
                ),
              ),
              if (_showSetup) widget.setup,
            ],
          ),
        );
      },
    );
  }

  Widget _receivePanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Permitir el control remoto',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 22),
        widget.receive,
      ],
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
              'Para recibir ayuda, comparte tu ID con la persona que te dará soporte. '
              'Utiliza la contraseña temporal cuando corresponda.\n\n'
              'Para dar soporte, introduce el ID del otro equipo en el campo de conexión. '
              'Encontrarás los equipos recientes y guardados en Dispositivos.\n\n'
              'Los permisos de pantalla, teclado y mouse se configuran desde '
              'Configurar este equipo.',
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
