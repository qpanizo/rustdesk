import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/limafac/brand.dart';
import '../lib/limafac/permission_setup.dart';

void main() {
  testWidgets(
    'Configuration requests one native permission at a time and verifies the result',
    (tester) async {
      var screen = false;
      var requestedScreen = 0;
      var requestedInput = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: LimaFacBrand.theme(ThemeData()),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  final screenStep = LimaFacPermissionItem(
                    title: 'Pantalla',
                    detail: 'Comparte la pantalla',
                    granted: screen,
                    actionLabel: 'Permitir pantalla',
                    onRequest: () async {
                      requestedScreen++;
                    },
                  );
                  return LimaFacPermissionSetup(
                    platformName: 'macOS',
                    screenSteps: [screenStep],
                    controlSteps: [
                      screenStep,
                      LimaFacPermissionItem(
                        title: 'Control',
                        detail: 'Teclado y mouse',
                        granted: false,
                        actionLabel: 'Permitir control',
                        onRequest: () async {
                          requestedInput++;
                        },
                      ),
                    ],
                    optionalSteps: const [],
                    onRefresh: () async {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(requestedScreen, 0);
      expect(find.text('Permitir control'), findsNothing);
      await tester.tap(find.text('Permitir pantalla'));
      await tester.pumpAndSettle();
      expect(requestedScreen, 1);
      expect(requestedInput, 0);
      expect(find.text('Permitir control'), findsNothing);
      update(() => screen = true);
      await tester.pumpAndSettle();
      expect(find.text('Paso 2 de 2'), findsOneWidget);
      await tester.tap(find.text('Permitir control'));
      await tester.pumpAndSettle();
      expect(requestedInput, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Outgoing support and optional functions do not trigger permission prompts',
    (tester) async {
      var prompts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LimaFacPermissionSetup(
                platformName: 'Windows',
                initialUse: LimaFacSupportUse.outgoing,
                screenSteps: const [],
                controlSteps: const [],
                onRefresh: () async {},
                optionalSteps: [
                  LimaFacPermissionItem(
                    title: 'Servicio',
                    detail: 'Acceso permanente',
                    granted: false,
                    actionLabel: 'Instalar servicio',
                    onRequest: () async {
                      prompts++;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(find.text('Instalar servicio').hitTestable(), findsNothing);
      await tester.tap(find.text('Funciones opcionales'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Instalar servicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Instalar servicio'));
      await tester.pumpAndSettle();
      expect(prompts, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Controller-only platforms never offer unsupported incoming access',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LimaFacPermissionSetup(
                platformName: 'iPhone / iPad',
                receivingSupported: false,
                screenSteps: const [],
                controlSteps: const [],
                optionalSteps: const [],
                onRefresh: () async {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<LimaFacSupportUse>));
      await tester.pumpAndSettle();
      expect(find.text('Recibir control remoto'), findsNothing);
      expect(find.text('Compartir mi pantalla'), findsNothing);
      expect(find.text('Dar soporte a otro equipo'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
