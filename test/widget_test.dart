import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matmind/main.dart';
import 'package:matmind/src/repository.dart';

void main() {
  testWidgets('welcome screen explains adaptive bout cycle', (tester) async {
    await tester.pumpWidget(
      SvoyaBorbaApp(repository: MemoryAppRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Своя борьба'), findsWidgets);
    expect(
      find.textContaining('учится на том, что произошло после неё'),
      findsOneWidget,
    );
    expect(find.text('Я спортсмен'), findsOneWidget);
    expect(find.text('Я родитель'), findsOneWidget);
  });

  testWidgets('quick start launches practice after three taps', (tester) async {
    await tester.pumpWidget(
      SvoyaBorbaApp(repository: MemoryAppRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Я спортсмен'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10–12 лет'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Открыть приложение'));
    await tester.tap(find.text('Открыть приложение'));
    await tester.pumpAndSettle();

    expect(find.text('Помочь за 20 секунд'), findsOneWidget);
    await tester.tap(find.text('Помочь за 20 секунд'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Собран и готов'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Слишком много мыслей'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Быстрый вход в свою борьбу'), findsOneWidget);
    expect(find.text('БЫСТРЫЙ РЕЖИМ · 3-Е НАЖАТИЕ'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
