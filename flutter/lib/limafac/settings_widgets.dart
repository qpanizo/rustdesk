import 'package:flutter/material.dart';

class LimaFacSettingsScope extends InheritedWidget {
  const LimaFacSettingsScope({super.key, required super.child});
  static bool active(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LimaFacSettingsScope>() !=
      null;
  @override
  bool updateShouldNotify(LimaFacSettingsScope oldWidget) => false;
}

class LimaFacSettingsGroup extends StatelessWidget {
  const LimaFacSettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.titleSuffix = const [],
  });
  final String title;
  final List<Widget> children;
  final List<Widget> titleSuffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...titleSuffix,
            ],
          ),
          const SizedBox(height: 14),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class LimaFacAppearancePanel extends StatelessWidget {
  const LimaFacAppearancePanel({
    super.key,
    required this.dark,
    required this.onChanged,
  });
  final bool dark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LimaFacSettingsGroup(
          title: 'Apariencia',
          children: [
            Row(
              children: [
                Icon(
                  dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  size: 24,
                ),
                const SizedBox(width: 16),
                const Expanded(child: Text('Tema de la aplicación')),
                const Icon(Icons.light_mode_outlined, size: 18),
                Tooltip(
                  message: 'Cambiar tema',
                  child: Switch(value: dark, onChanged: onChanged),
                ),
                const Icon(Icons.dark_mode_outlined, size: 18),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
