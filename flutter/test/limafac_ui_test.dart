import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/limafac/home_shell.dart';
import '../lib/limafac/installer_shell.dart';
import '../lib/limafac/setup_card.dart';

void main() {
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
    for (final size in [const Size(1000, 760), const Size(600, 760)]) {
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
                connection: const Center(child: Text('Conectar')),
                onSettings: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Recibir ayuda'), findsOneWidget);
        expect(find.text('Conectarse a un equipo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('Help opens without triggering settings or remote actions', (
    tester,
  ) async {
    var settingsOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LimaFacHomeShell(
            receive: const SizedBox(),
            connection: const SizedBox(),
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
    await tester.tap(find.byTooltip('Ajustes'));
    expect(settingsOpened, isTrue);
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
