import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Fixed 24px geometry keeps navigation and action strokes consistent.
class LimaFacIcon extends StatelessWidget {
  const LimaFacIcon(this.icon, {super.key, this.size = 20, this.color});
  final IconData icon;
  final double size;
  final Color? color;

  static final _paths = <IconData, String>{
    Icons.sync_alt_rounded:
        '<path d="M4 8h16m-4-4 4 4-4 4M20 16H4m4-4-4 4 4 4"/>',
    Icons.devices_outlined: '<rect x="3" y="4" width="14" height="12" rx="1.5"/><path d="M7 20h6m-3-4v4"/><rect x="16" y="10" width="5" height="10" rx="1"/>',
    Icons.connected_tv_rounded: '<rect x="3" y="4" width="18" height="13" rx="2"/><path d="M8 21h8m-4-4v4"/>',
    Icons.settings_outlined: '<path d="m9 3-.5 2-2 1.2-2-.5-2 3.6L4 11v2l-1.5 1.7 2 3.6 2-.5 2 1.2.5 2h4l.5-2 2-1.2 2 .5 2-3.6L20 13v-2l1.5-1.7-2-3.6-2 .5-2-1.2-.5-2Z"/><circle cx="12" cy="12" r="3"/>',
    Icons.help_outline_rounded: '<circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 0 1 5 0c0 2-2.5 2-2.5 4m0 3h.01"/>',
    Icons.search_rounded:
        '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 4.5 4.5"/>',
    Icons.arrow_forward_rounded: '<path d="M4 12h16m-6-6 6 6-6 6"/>',
    Icons.light_mode_outlined: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1.5 1.5m11 11L19 19M5 19l1.5-1.5m11-11L19 5"/>',
    Icons.dark_mode_outlined:
        '<path d="M20.5 13A9 9 0 0 1 11 3.5 9 9 0 1 0 20.5 13Z"/>',
    Icons.tune_rounded: '<path d="M3 6h6m4 0h8M3 12h12m4 0h2M3 18h2m4 0h12M9 3v6m6 0v6M5 15v6"/>',
    Icons.palette_outlined: '<path d="M12 3a9 9 0 1 0 0 18h1a2 2 0 0 0 1-3.7 1.5 1.5 0 0 1 1-2.8h2a4 4 0 0 0 4-4A8.5 8.5 0 0 0 12 3Z"/><circle cx="7.5" cy="10" r=".7"/><circle cx="11" cy="6.8" r=".7"/><circle cx="15.5" cy="8" r=".7"/>',
    Icons.enhanced_encryption_outlined: '<rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3m-4 4v3"/>',
    Icons.link_outlined: '<path d="m10 14 4-4m-6 6-1 1a4.2 4.2 0 0 1-6-6l4-4a4.2 4.2 0 0 1 6 0m2 10a4.2 4.2 0 0 0 6 0l4-4a4.2 4.2 0 0 0-6-6l-1 1"/>',
    Icons.desktop_windows_outlined: '<rect x="3" y="4" width="18" height="13" rx="1.5"/><path d="M8 21h8m-4-4v4"/>',
    Icons.person_outline:
        '<circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2Z"/>',
    Icons.print_outlined: '<path d="M7 8V3h10v5M7 17H4V9h16v8h-3"/><path d="M7 14h10v7H7Zm10-3h.01"/>',
    Icons.policy_outlined: '<path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6Z"/><path d="M9 10h6m-6 4h4"/>',
    Icons.history_rounded: '<path d="M3 11a9 9 0 1 1 2 7M3 5v6h6m3-4v6l4 2"/>',
    Icons.star_outline_rounded: '<path d="m12 3 2.8 5.7 6.2.9-4.5 4.4 1.1 6.2-5.6-3-5.6 3 1.1-6.2L3 9.6l6.2-.9Z"/>',
    Icons.lan_outlined: '<rect x="9" y="3" width="6" height="5" rx="1"/><path d="M12 8v5M5 17v-4h14v4"/><rect x="2" y="17" width="6" height="4" rx="1"/><rect x="16" y="17" width="6" height="4" rx="1"/>',
    Icons.contacts_outlined: '<rect x="5" y="3" width="15" height="18" rx="2"/><path d="M3 7h4m-4 5h4m-4 5h4"/><circle cx="12.5" cy="9" r="2.5"/><path d="M9 17a3.5 3.5 0 0 1 7 0"/>',
    Icons.copy_outlined: '<rect x="8" y="7" width="12" height="14" rx="1.5"/><path d="M15 3H4v14"/>',
    Icons.refresh_rounded: '<path d="M20 11a8 8 0 1 0-2 6M20 4v7h-7"/>',
    Icons.close: '<path d="m6 6 12 12M6 18 18 6"/>',
    Icons.expand_less_rounded: '<path d="m6 15 6-6 6 6"/>',
    Icons.favorite_border: '<path d="M20.4 5.6a5.5 5.5 0 0 0-7.8 0l-.6.6-.6-.6a5.5 5.5 0 0 0-7.8 7.8L12 22l8.4-8.6a5.5 5.5 0 0 0 0-7.8Z"/>',
  };

  @override
  Widget build(BuildContext context) {
    final paths = _paths[icon];
    if (paths == null) return Icon(icon, size: size, color: color);
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: SvgPicture.string(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
          'fill="none" stroke="black" stroke-width="1.65" '
          'stroke-linecap="round" stroke-linejoin="round">$paths</svg>',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(
            color ??
                IconTheme.of(context).color ??
                Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
