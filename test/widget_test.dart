import 'package:flutter_test/flutter_test.dart';
import 'package:matmind/main.dart';

void main() {
  testWidgets('MATMIND opens the role selection screen', (tester) async {
    await tester.pumpWidget(const MatMindApp());
    expect(find.text('Тренируй не только технику'), findsOneWidget);
    expect(find.text('Я спортсмен'), findsOneWidget);
    expect(find.text('Я родитель'), findsOneWidget);
  });
}
