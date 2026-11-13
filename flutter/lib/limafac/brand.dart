import 'package:flutter/material.dart';

const limaFacUi = bool.fromEnvironment('LIMAFAC_UI', defaultValue: true);

class LimaFacBrand {
  static const accent = Color(0xFF21B2A7);
  static const ink = Color(0xFF152F35);
  static const sidebar = Color(0xFF075E59);
  static const darkSidebar = Color(0xFF141416);
  static const darkSidebarText = Color(0xFFAAABB3);

  static ThemeData theme(ThemeData base) {
    final dark = base.brightness == Brightness.dark;
    final primary = dark ? const Color(0xFF65D8CD) : const Color(0xFF087C74);
    final surface = dark ? const Color(0xFF232326) : Colors.white;
    final foreground = dark ? const Color(0xFFE7E7EC) : const Color(0xFF292A2E);
    final muted = dark ? const Color(0xFFAAABB3) : const Color(0xFF686A73);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: dark ? const Color(0xFF606169) : const Color(0xFFB8BBC3),
      ),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: primary,
        onSecondary: dark ? ink : Colors.white,
        onPrimary: dark ? ink : Colors.white,
        surface: surface,
        onSurface: foreground,
        // Upstream's Flutter 3.24 widgets still read the background roles.
        // ignore: deprecated_member_use
        background: surface,
        // ignore: deprecated_member_use
        onBackground: foreground,
      ),
      scaffoldBackgroundColor: dark
          ? const Color(0xFF151517)
          : const Color(0xFFF5F6F9),
      cardColor: surface,
      hintColor: muted,
      dividerColor: dark ? const Color(0xFF3F4046) : const Color(0xFFE1E9EB),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark ? ink : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: surface,
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: primary)),
      ),
    );
  }
}

class LimaFacLogo extends StatelessWidget {
  const LimaFacLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/limafac-logo.png', width: 110, height: 52),
        const SizedBox(width: 14),
        Container(width: 1, height: 28, color: Theme.of(context).dividerColor),
        const SizedBox(width: 14),
        const Text(
          'Remote',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
