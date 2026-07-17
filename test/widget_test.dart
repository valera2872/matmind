import 'package:flutter_test/flutter_test.dart';
import 'package:matmind/main.dart';

void main() {
  testWidgets('MATMIND opens the role selection screen', (tester) async {
    await tester.pumpWidget(const MatMindApp());
    expect(find.text('Тренируй не только технику'), findsOneWidget);
    expect(find.text('Я спортсмен'), findsOneWidget);
    expect(find.text('Я родитель'), findsOneWidget);
  });

  testWidgets('athlete can open the adaptive check-in', (tester) async {
    await tester.pumpWidget(const MatMindApp());

    await tester.tap(find.text('Я спортсмен'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('13–15 лет'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открыть MATMIND'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Собрать персональную практику'));
    await tester.pumpAndSettle();

    expect(find.text('Настроим тренировку под тебя сейчас'), findsOneWidget);
    expect(find.text('Энергия'), findsOneWidget);
    expect(find.text('Напряжение'), findsOneWidget);
    expect(find.text('Фокус'), findsOneWidget);
  });

  testWidgets('every parent situation opens a guide', (tester) async {
    await tester.pumpWidget(const MatMindApp());
    await tester.tap(find.text('Я родитель'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Скоро старт'));
    await tester.pumpAndSettle();
    expect(find.text('Сейчас ребёнку нужна опора, а не дополнительный тренер'), findsOneWidget);
    await tester.tap(find.text('Вернуться к ситуациям'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Не хочет ехать'));
    await tester.pumpAndSettle();
    expect(find.text('Не называйте отказ ленью, пока не поняли причину'), findsOneWidget);
    await tester.tap(find.text('Вернуться к ситуациям'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Я сам на взводе'));
    await tester.pumpAndSettle();
    expect(find.text('Сначала снизьте собственное напряжение'), findsOneWidget);
  });
}
