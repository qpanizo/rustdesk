import 'package:flutter/material.dart';

const limaFacUi = bool.fromEnvironment('LIMAFAC_UI', defaultValue: true);

class LimaFacBrand {
  static const accent = Color(0xFF21B2A7);
  static const ink = Color(0xFF152F35);

  static ThemeData theme(ThemeData base) {
    final dark = base.brightness == Brightness.dark;
    final primary = dark ? const Color(0xFF65D8CD) : const Color(0xFF087C74);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: base.dividerColor),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: primary),
      scaffoldBackgroundColor: dark
          ? const Color(0xFF142126)
          : const Color(0xFFF4F7F8),
      cardColor: dark ? const Color(0xFF1C2D33) : Colors.white,
      dividerColor: dark ? const Color(0xFF34474C) : const Color(0xFFE1E9EB),
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
