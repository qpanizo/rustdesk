import 'package:flutter/material.dart';

class LimaFacCredentialsCard extends StatelessWidget {
  const LimaFacCredentialsCard({
    super.key,
    required this.id,
    required this.password,
    required this.onCopyId,
    this.onCopyPassword,
    this.onRefresh,
    this.onSecuritySettings,
  });

  final TextEditingController id;
  final TextEditingController password;
  final VoidCallback onCopyId;
  final VoidCallback? onCopyPassword;
  final VoidCallback? onRefresh;
  final VoidCallback? onSecuritySettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu ID',
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: id,
                  builder: (context, value, _) => SelectableText(
                    value.text.isEmpty ? '…' : value.text,
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copiar ID',
                onPressed: onCopyId,
                icon: const Icon(Icons.copy_outlined, size: 19),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            onCopyPassword == null ? 'Acceso' : 'Contraseña temporal',
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: password,
                  builder: (context, value, _) => SelectableText(
                    value.text,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  tooltip: 'Renovar contraseña',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 21),
                ),
              if (onCopyPassword != null)
                IconButton(
                  tooltip: 'Copiar contraseña',
                  onPressed: onCopyPassword,
                  icon: const Icon(Icons.copy_outlined, size: 19),
                )
              else if (onSecuritySettings != null)
                IconButton(
                  tooltip: 'Opciones de acceso',
                  onPressed: onSecuritySettings,
                  icon: const Icon(Icons.settings_outlined, size: 19),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
