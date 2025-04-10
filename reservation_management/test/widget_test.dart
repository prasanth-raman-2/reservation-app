import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_management/main.dart';

void main() {
  testWidgets('Reservation app renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    
    expect(find.text('Reservations'), findsOneWidget);
  });
}
