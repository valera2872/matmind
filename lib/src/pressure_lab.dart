import 'dart:async';

import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'theme.dart';

class PressureLabScreen extends StatefulWidget {
  const PressureLabScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<PressureLabScreen> createState() => _PressureLabScreenState();
}

class _PressureLabScreenState extends State<PressureLabScreen> {
  static const scenarios = <Map<String, Object>>[
    <String, Object>{
      'title': 'Соперник сразу пошёл вперёд',
      'situation':
          'Сигнал судьи. Соперник сокращает дистанцию, зал шумит, тело на секунду зажалось.',
      'options': <String>[
        'Ждать нескольких подсказок тренера',
        'Выдох → стойка → первый контакт',
        'Срочно пытаться перестать волноваться',
      ],
      'answer': 1,
      'cue': 'Выдох. Стойка. Контакт.',
    },
    <String, Object>{
      'title': 'Ты пропустил первый балл',
      'situation':
          'В голове появилась мысль: «Опять всё испортил», но схватка продолжается.',
      'options': <String>[
        'Разобрать ошибку прямо сейчас',
        'Резко броситься отыгрываться',
        'Назвать факт и выбрать следующее действие',
      ],
      'answer': 2,
      'cue': 'Ошибка была. Действую дальше.',
    },
    <String, Object>{
      'title': 'Фаворит ждёт привычного ответа',
      'situation':
          'Соперник рассчитывает, что ты будешь двигаться в его ритме и отдашь удобный захват.',
      'options': <String>[
        'Сменить темп и первым искать свой захват',
        'Полностью копировать его движения',
        'Отступать и ждать случайной ошибки',
      ],
      'answer': 0,
      'cue': 'Стань неудобным. Навяжи своё.',
    },
  ];

  int _index = 0;
  int? _choice;
  int _score = 0;
  int _seconds = 8;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _timer?.cancel();
    _seconds = 8;
    _choice = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _choice != null) return;
      if (_seconds <= 1) {
        _timer?.cancel();
        setState(() {
          _seconds = 0;
          _choice = -1;
        });
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  void _answer(int choice) {
    if (_choice != null) return;
    _timer?.cancel();
    final answer = scenarios[_index]['answer']! as int;
    setState(() {
      _choice = choice;
      if (choice == answer) _score += 1;
    });
  }

  void _next() {
    if (_index == scenarios.length - 1) {
      setState(() => _index += 1);
      return;
    }
    setState(() => _index += 1);
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= scenarios.length) {
      return AppShell(
        back: widget.onBack,
        label: 'ЛАБОРАТОРИЯ',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Tag(text: 'ТРЕНИРОВКА ЗАВЕРШЕНА'),
            const SizedBox(height: 14),
            Text(
              '$_score из ${scenarios.length}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            const Text(
              'Это не оценка характера. Результат показывает только знакомство с конкретными алгоритмами.',
            ),
            const SizedBox(height: 20),
            const InfoPanel(
              icon: Icons.psychology_outlined,
              title: 'Общий алгоритм',
              text:
                  'Заметь факт → верни тело → сузь внимание → выбери одно действие.',
              color: AppColors.tealSoft,
            ),
            PrimaryButton(
              text: 'Вернуться к тренировкам',
              onPressed: widget.onBack,
            ),
          ],
        ),
      );
    }

    final scenario = scenarios[_index];
    final options = scenario['options']! as List<String>;
    final answer = scenario['answer']! as int;

    return AppShell(
      back: widget.onBack,
      label: '${_index + 1}/${scenarios.length} · $_seconds СЕК.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            scenario['title']! as String,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            scenario['situation']! as String,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          for (var index = 0; index < options.length; index += 1)
            SelectTile(
              text: options[index],
              selected: _choice == index,
              onTap: () => _answer(index),
            ),
          if (_choice != null) ...<Widget>[
            const SizedBox(height: 12),
            InfoPanel(
              icon: _choice == answer ? Icons.check_circle : Icons.replay,
              title: _choice == answer
                  ? 'Рабочее решение'
                  : 'Запомни более короткий путь',
              text:
                  '${scenario['cue']} Под давлением полезнее вернуть ближайшее управляемое действие, а не оценивать себя.',
              color:
                  _choice == answer ? AppColors.tealSoft : AppColors.sand,
            ),
            PrimaryButton(
              text: _index == scenarios.length - 1
                  ? 'Показать результат'
                  : 'Следующая ситуация',
              onPressed: _next,
            ),
          ],
        ],
      ),
    );
  }
}
