import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrame_designer/main.dart';

void main() {
  testWidgets('La aplicación carga correctamente', (WidgetTester tester) async {
    // Construye la aplicación
    await tester.pumpWidget(const MyApp());

    // Verifica que el título principal existe
    expect(find.text('Macrame Designer'), findsOneWidget);
    
    // Verifica que la estructura básica existe
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    
    // Puedes agregar más verificaciones según tu UI
    // Por ejemplo, si tienes un botón específico:
    // expect(find.byIcon(Icons.add), findsOneWidget);
  });

  // Test adicional para verificar interacción básica
  testWidgets('La aplicación responde a gestos', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Verifica que no hay errores al tocar
    await tester.tap(find.byType(Scaffold));
    await tester.pump(); // Procesa el frame
    
    // La aplicación debería seguir funcionando
    expect(find.text('Macrame Designer'), findsOneWidget);
  });
}