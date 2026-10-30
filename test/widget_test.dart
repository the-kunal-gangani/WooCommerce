import 'package:flutter_test/flutter_test.dart';
import 'package:magna_data_ai_ecommerce/features/splash/splash_screen.dart';
import 'package:magna_data_ai_ecommerce/my_app/my_app.dart';

void main() {
  testWidgets('application starts on the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp(useInitialBinding: false));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
