import 'package:flutter/material.dart';

import 'icons.dart';

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
    final font =
        base.platform == TargetPlatform.macOS ||
            base.platform == TargetPlatform.iOS
        ? 'Helvetica Neue'
        : base.platform == TargetPlatform.windows
        ? 'Segoe UI'
        : 'Noto Sans';
    final textTheme = base.textTheme
        .apply(
          fontFamily: font,
          bodyColor: foreground,
          displayColor: foreground,
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
          displayMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          displaySmall: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
          headlineLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
          headlineMedium: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          headlineSmall: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          titleMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          titleSmall: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
          bodyMedium: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          labelLarge: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          labelMedium: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          labelSmall: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        )
        .apply(
          fontFamily: font,
          bodyColor: foreground,
          displayColor: foreground,
        );
    Color controlColor(Set<MaterialState> states) =>
        states.contains(MaterialState.disabled)
        ? muted.withAlpha(100)
        : states.contains(MaterialState.selected)
        ? primary
        : muted;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: dark ? const Color(0xFF606169) : const Color(0xFFB8BBC3),
      ),
    );
    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(size: 20, color: foreground, opacity: 1),
      hoverColor: primary.withAlpha(18),
      highlightColor: primary.withAlpha(24),
      splashColor: primary.withAlpha(24),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withAlpha(dark ? 80 : 55),
        selectionHandleColor: primary,
      ),
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          disabledForegroundColor: muted.withAlpha(130),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: muted.withAlpha(130),
          side: BorderSide(color: primary.withAlpha(110)),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      checkboxTheme: base.checkboxTheme.copyWith(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? controlColor(states)
              : Colors.transparent,
        ),
        checkColor: MaterialStateProperty.all(dark ? ink : Colors.white),
      ),
      radioTheme: base.radioTheme.copyWith(
        fillColor: MaterialStateProperty.resolveWith(controlColor),
      ),
      switchTheme: base.switchTheme.copyWith(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primary
              : (dark ? const Color(0xFFB8BBC3) : Colors.white),
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? primary.withAlpha(95)
              : muted.withAlpha(100),
        ),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark ? ink : Colors.white,
          disabledForegroundColor: muted.withAlpha(130),
          disabledBackgroundColor: muted.withAlpha(22),
          textStyle: textTheme.labelLarge,
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class LimaFacSignature extends StatelessWidget {
  const LimaFacSignature({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'LimaFac Remote · Hecho con',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(width: 5),
        Semantics(
          label: 'amor',
          child: const LimaFacIcon(
            Icons.favorite_border,
            size: 14,
            color: Color(0xFFD75A6A),
          ),
        ),
      ],
    );
  }
}
