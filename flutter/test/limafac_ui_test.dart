import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/limafac/home_shell.dart';
import '../lib/limafac/brand.dart';
import '../lib/limafac/icons.dart';
import '../lib/limafac/policies_page.dart';
import '../lib/limafac/credentials_card.dart';
import '../lib/limafac/installer_shell.dart';
import '../lib/limafac/setup_card.dart';
import '../lib/limafac/sectioned_page.dart';
import '../lib/limafac/settings_widgets.dart';

void main() {
  test(
    'Active button labels retain contrast and moderate weight in both themes',
    () {
      double contrast(Color a, Color b) {
        final l1 = a.computeLuminance();
        final l2 = b.computeLuminance();
        return ((l1 > l2 ? l1 : l2) + .05) / ((l1 > l2 ? l2 : l1) + .05);
      }

      for (final brightness in Brightness.values) {
        final theme = LimaFacBrand.theme(
          ThemeData(
            brightness: brightness,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ),
        );
        final label = theme.textButtonTheme.style!.foregroundColor!.resolve({
          MaterialState.hovered,
        })!;
        expect(contrast(label, theme.cardColor), greaterThanOrEqualTo(4.5));
        expect(
          contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          theme.textTheme.labelLarge!.fontWeight!.value,
          lessThanOrEqualTo(500),
        );
      }
    },
  );

  testWidgets(
    'Policies keeps upstream credits and full license in its detail',
    (tester) async {
      var sourceOpened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: LimaFacBrand.theme(ThemeData()),
          home: Scaffold(
            body: LimaFacPoliciesPage(
              version: '1.5.3',
              onSource: () => sourceOpened = true,
              onUpstreamPrivacy: () {},
            ),
          ),
        ),
      );
      expect(find.text('Acceso y permisos'), findsOneWidget);
      expect(find.text('Acerca de'), findsNothing);
      await tester.ensureVisible(
        find.text('Créditos y licencias de código abierto'),
      );
      await tester.tap(find.text('Créditos y licencias de código abierto'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('desarrollado en base a RustDesk'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Código fuente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Código fuente'));
      expect(sourceOpened, isTrue);
      await tester.tap(find.text('Ver licencia AGPL-3.0'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('GNU AFFERO GENERAL PUBLIC LICENSE'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Settings stays inside the shared shell and changes the same theme',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LimaFacHomeShell(
              receive: const Text('ID'),
              connection: const Text('Conectar'),
              devices: const Text('Equipos'),
              status: const Text('Listo'),
              setup: const SizedBox(),
              needsSetup: false,
              onQuickConnect: (_) {},
              onSettings: () {},
              settingsBuilder: (_, dark, onChanged) =>
                  LimaFacAppearancePanel(dark: dark, onChanged: onChanged),
            ),
          ),
        ),
      );
      expect(find.text('Modo oscuro'), findsNothing);
      expect(find.textContaining('Basado en RustDesk'), findsNothing);
      expect(find.text('LimaFac Remote · Hecho con'), findsOneWidget);
      await tester.tap(find.byTooltip('Ajustes').first);
      await tester.pumpAndSettle();
      expect(find.text('Apariencia'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<Switch>(find.byType(Switch))
            .every((control) => control.value),
        isTrue,
      );
      await tester.tap(find.byTooltip('Soporte remoto'));
      await tester.pumpAndSettle();
      expect(find.text('Permitir el control remoto'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Modo oscuro'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Device navigation filters categories and works in compact windows',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 760);
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => LimaFacSectionedPage(
                navigationTitle: 'Mis dispositivos',
                searchNavigation: true,
                sections: const [
                  LimaFacSectionItem('Últimas conexiones', Icons.history),
                  LimaFacSectionItem('Favoritos', Icons.star_outline),
                ],
                selected: selected,
                onSelected: (value) => setState(() => selected = value),
                child: Center(child: Text('Contenido $selected')),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'fav');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Últimas conexiones'), findsNothing);
      await tester.tap(find.widgetWithText(ListTile, 'Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('Contenido 1'), findsOneWidget);
      tester.view.physicalSize = const Size(600, 760);
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Últimas conexiones').last);
      await tester.pumpAndSettle();
      expect(find.text('Contenido 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Credential controls show live values and dispatch the requested action',
    (tester) async {
      final id = TextEditingController(text: '123 456 789');
      final password = TextEditingController(text: 'abc123');
      addTearDown(id.dispose);
      addTearDown(password.dispose);
      var copiedId = false;
      var refreshed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 380,
              child: LimaFacCredentialsCard(
                id: id,
                password: password,
                onCopyId: () => copiedId = true,
                onCopyPassword: () {},
                onRefresh: () => refreshed = true,
              ),
            ),
          ),
        ),
      );
      expect(find.text('123 456 789'), findsOneWidget);
      await tester.tap(find.byTooltip('Copiar ID'));
      expect(copiedId, isTrue);
      await tester.tap(find.byTooltip('Renovar contraseña'));
      expect(refreshed, isTrue);
      password.text = 'new456';
      await tester.pump();
      expect(find.text('new456'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Installation options expand without starting installation', (
    tester,
  ) async {
    var installations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LimaFacInstallerShell(
          options: const [Text('Carpeta de instalación')],
          agreement: 'Revisa las condiciones antes de instalar.',
          license: const Text('Condiciones'),
          progress: const SizedBox(),
          actions: [
            ElevatedButton(
              onPressed: () => installations++,
              child: const Text('Instalar'),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Carpeta de instalación'), findsNothing);
    await tester.tap(find.text('Opciones de instalación'));
    await tester.pumpAndSettle();
    expect(find.text('Carpeta de instalación'), findsOneWidget);
    expect(installations, 0);
    await tester.ensureVisible(find.text('Instalar'));
    await tester.tap(find.text('Instalar'));
    expect(installations, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Support panels fit compact and desktop windows in both themes', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final size in [
      const Size(1440, 900),
      const Size(1000, 760),
      const Size(600, 760),
    ]) {
      tester.view.physicalSize = size;
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: LimaFacHomeShell(
                receive: const SingleChildScrollView(
                  child: Text('123 456 789'),
                ),
                connection: const Text('Conectar'),
                devices: const Text('Equipos guardados'),
                status: const Text('Listo'),
                setup: const Text('Permisos'),
                needsSetup: true,
                onQuickConnect: (_) {},
                onSettings: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final sidebarAnchor = size.width < 980
            ? find.byWidgetPredicate(
                (widget) =>
                    widget is LimaFacIcon &&
                    widget.icon == Icons.connected_tv_rounded,
              )
            : find.byType(Image).first;
        final lightSidebar = tester
            .element(sidebarAnchor)
            .findAncestorWidgetOfExactType<Material>()!
            .color;
        expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
        if (brightness == Brightness.dark) {
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();
        }
        expect(
          Theme.of(tester.element(find.text('ID de LimaFac'))).brightness,
          brightness,
        );
        expect(
          tester.widget<Switch>(find.byType(Switch)).value,
          brightness == Brightness.dark,
        );
        final currentSidebar = tester
            .element(sidebarAnchor)
            .findAncestorWidgetOfExactType<Material>()!
            .color;
        if (brightness == Brightness.dark) {
          expect(currentSidebar, isNot(lightSidebar));
          expect(
            currentSidebar!.computeLuminance(),
            lessThan(lightSidebar!.computeLuminance()),
          );
        }
        expect(find.text('Permitir el control remoto'), findsOneWidget);
        expect(find.text('ID de LimaFac'), findsOneWidget);
        await tester.tap(find.text('Dispositivos').first);
        await tester.pumpAndSettle();
        expect(find.text('Equipos guardados'), findsOneWidget);
        await tester.tap(
          size.width < 980
              ? find.byTooltip('Soporte remoto')
              : find.text('Soporte remoto').first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Permitir el control remoto'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (brightness == Brightness.dark) {
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();
          expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
          expect(
            tester
                .element(sidebarAnchor)
                .findAncestorWidgetOfExactType<Material>()!
                .color,
            lightSidebar,
          );
        }
      }
    }
  });

  testWidgets('Help opens without triggering settings or remote actions', (
    tester,
  ) async {
    var settingsOpened = false;
    String? connectedId;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LimaFacHomeShell(
            receive: const SizedBox(),
            connection: const SizedBox(),
            devices: const SizedBox(),
            status: const Text('Listo'),
            setup: const SizedBox(),
            needsSetup: false,
            onQuickConnect: (id) => connectedId = id,
            onSettings: () => settingsOpened = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Cómo comenzar'));
    await tester.pumpAndSettle();
    expect(find.text('Comienza en pocos pasos'), findsOneWidget);
    expect(settingsOpened, isFalse);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ajustes').first);
    expect(settingsOpened, isTrue);
    await tester.enterText(find.byType(TextField), '123456789');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    expect(connectedId, '123456789');
  });

  testWidgets(
    'Setup requests permission only after the user presses its button',
    (tester) async {
      var requests = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 260,
              child: LimaFacSetupCard(
                title: '1. Compartir pantalla',
                content: 'Permite ver tu pantalla durante el soporte.',
                actionLabel: 'Configurar',
                onAction: () => requests++,
              ),
            ),
          ),
        ),
      );
      expect(requests, 0);
      await tester.tap(find.text('Configurar'));
      expect(requests, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
