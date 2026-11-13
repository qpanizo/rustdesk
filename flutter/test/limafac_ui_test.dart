import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/limafac/home_shell.dart';
import '../lib/limafac/credentials_card.dart';
import '../lib/limafac/installer_shell.dart';
import '../lib/limafac/setup_card.dart';

void main() {
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
            ? find.byIcon(Icons.connected_tv_rounded)
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
