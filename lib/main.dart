import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const MatMindApp());

class MatMindApp extends StatelessWidget {
  const MatMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF102B3A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MATMIND',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF357F91),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F5),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: ink,
            fontSize: 30,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.45),
          bodyMedium: TextStyle(
            color: Color(0xFF627883),
            fontSize: 14,
            height: 1.42,
          ),
        ),
      ),
      home: const MatMindFlow(),
    );
  }
}

enum AppPage {
  welcome,
  age,
  sport,
  athleteHome,
  checkIn,
  practice,
  goal,
  complete,
  parentHome,
  parentLoss,
}

enum ActivationState { high, working, low }

class MatMindFlow extends StatefulWidget {
  const MatMindFlow({super.key});

  @override
  State<MatMindFlow> createState() => _MatMindFlowState();
}

class _MatMindFlowState extends State<MatMindFlow> {
  static const ink = Color(0xFF102B3A);
  static const blue = Color(0xFF357F91);
  static const mint = Color(0xFFDCEEE9);
  static const sand = Color(0xFFF4EAD9);
  static const rose = Color(0xFFF3E3E1);

  AppPage _page = AppPage.welcome;
  int? _ageBand;
  final Set<String> _sports = {'BJJ'};
  ActivationState? _activation;
  String? _goal;
  Timer? _timer;
  int _seconds = 0;
  bool _playing = false;

  static const Map<int, List<String>> scripts = {
    10: [
      'Поставь обе стопы на пол. Почувствуй, что он держит тебя.',
      'Сделай обычный вдох и чуть более длинный выдох.',
      'Волнение — не знак, что ты проиграешь. Тело готовится.',
      'Представь только начало: стойка, дистанция, первый контакт.',
      'Тебе не нужно выиграть схватку в голове. Выбери первое действие.',
    ],
    13: [
      'Почувствуй стопы и вес тела. Не меняй всё — просто найди опору.',
      'Вдохни обычно. Выдох сделай немного длиннее.',
      'Тебе не обязательно стать спокойным. Нужен рабочий уровень энергии.',
      'Не прокручивай всю схватку. Увидь стойку, дистанцию и первый контакт.',
      'Результат пока не нужен. Сейчас выбери одно действие на начало.',
    ],
    16: [
      'Верни внимание в опору: стопы, положение корпуса, свободные плечи.',
      'Один спокойный вдох. Выдох немного длиннее — без попытки выключить возбуждение.',
      'Активация перед стартом нормальна. Задача — направить её в действие.',
      'Мысленно пройди только старт: дистанция, контакт, твоя позиция.',
      'Не предсказывай результат. Определи один контролируемый шаг.',
    ],
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(AppPage page) {
    if (page != AppPage.practice) _stopTimer();
    setState(() => _page = page);
  }

  void _startTimer() {
    if (_playing) return;
    setState(() => _playing = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds >= 24) {
        _stopTimer();
        _show(AppPage.goal);
        return;
      }
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _playing = false);
  }

  void _preparePractice() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _playing = false;
      _page = AppPage.practice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _page == AppPage.welcome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_page),
          child: _buildPage(),
        ),
      ),
    );
  }

  Widget _buildPage() => switch (_page) {
        AppPage.welcome => _welcome(),
        AppPage.age => _age(),
        AppPage.sport => _sport(),
        AppPage.athleteHome => _athleteHome(),
        AppPage.checkIn => _checkIn(),
        AppPage.practice => _practice(),
        AppPage.goal => _goalPage(),
        AppPage.complete => _complete(),
        AppPage.parentHome => _parentHome(),
        AppPage.parentLoss => _parentLoss(),
      };

  void _back() {
    switch (_page) {
      case AppPage.age:
      case AppPage.parentHome:
        _show(AppPage.welcome);
        break;
      case AppPage.sport:
        _show(AppPage.age);
        break;
      case AppPage.athleteHome:
        _show(AppPage.welcome);
        break;
      case AppPage.checkIn:
        _show(AppPage.athleteHome);
        break;
      case AppPage.practice:
        _show(AppPage.checkIn);
        break;
      case AppPage.goal:
        _show(AppPage.practice);
        break;
      case AppPage.complete:
        _show(AppPage.goal);
        break;
      case AppPage.parentLoss:
        _show(AppPage.parentHome);
        break;
      case AppPage.welcome:
        break;
    }
  }

  Widget _shell({
    required Widget child,
    String? eyebrow,
    bool back = false,
    bool dark = false,
    Widget? bottom,
  }) {
    final foreground = dark ? Colors.white : ink;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF173B4A) : null,
      bottomNavigationBar: bottom,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  if (back)
                    TextButton.icon(
                      onPressed: _back,
                      icon: Icon(Icons.arrow_back, color: foreground, size: 19),
                      label: Text('Назад', style: TextStyle(color: foreground)),
                    )
                  else
                    Text(
                      'MATMIND',
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  const Spacer(),
                  if (eyebrow != null)
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: dark ? Colors.white70 : const Color(0xFF627883),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle, {bool dark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: dark ? Colors.white : ink,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? Colors.white70 : null,
              ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _welcome() {
    return _shell(
      eyebrow: 'АЛЬФА 0.1.0',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 42),
          _pill('Психологическая тренировка для борьбы'),
          const SizedBox(height: 12),
          _heading(
            'Тренируй не только технику',
            'Подготовься к давлению, вернись после ошибки и переживи результат без потери уверенности.',
          ),
          _choiceCard(
            icon: Icons.sports_martial_arts,
            title: 'Я спортсмен',
            subtitle: 'Подготовка, reset и дневник',
            color: mint,
            onTap: () => _show(AppPage.age),
          ),
          _choiceCard(
            icon: Icons.handshake_outlined,
            title: 'Я родитель',
            subtitle: 'Как поддержать и не давить',
            color: sand,
            onTap: () => _show(AppPage.parentHome),
          ),
          _notice(
            'MATMIND не оценивает, насколько ты сильный, и не заменяет тренера, врача или психолога.',
          ),
        ],
      ),
    );
  }

  Widget _age() {
    return _shell(
      back: true,
      eyebrow: '1 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Сколько тебе лет?',
            'Это нужно только для того, чтобы приложение говорило нормально и по возрасту.',
          ),
          for (final entry in {10: '10–12 лет', 13: '13–15 лет', 16: '16–17 лет'}.entries)
            _selectTile(
              text: entry.value,
              selected: _ageBand == entry.key,
              onTap: () => setState(() => _ageBand = entry.key),
            ),
          const SizedBox(height: 10),
          _primaryButton(
            'Продолжить',
            _ageBand == null ? null : () => _show(AppPage.sport),
          ),
          _notice('Точная дата рождения не нужна. Сохраняется только возрастной диапазон.'),
        ],
      ),
    );
  }

  Widget _sport() {
    const sports = ['BJJ', 'Грэпплинг', 'Дзюдо', 'Самбо', 'Вольная', 'Греко-римская'];
    return _shell(
      back: true,
      eyebrow: '2 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Какая у тебя борьба?',
            'Можно выбрать несколько. Это изменит примеры целей, но не ограничит практики.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sport in sports)
                FilterChip(
                  label: Text(sport),
                  selected: _sports.contains(sport),
                  selectedColor: ink,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _sports.contains(sport) ? Colors.white : ink,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() {
                    if (_sports.contains(sport)) {
                      if (_sports.length > 1) _sports.remove(sport);
                    } else {
                      _sports.add(sport);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 28),
          _primaryButton('Открыть MATMIND', () => _show(AppPage.athleteHome)),
        ],
      ),
    );
  }

  Widget _athleteHome() {
    final age = switch (_ageBand) { 10 => '10–12', 16 => '16–17', _ => '13–15' };
    return _shell(
      eyebrow: '$age лет · ${_sports.first}',
      bottom: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.adjust), label: 'Сейчас'),
          NavigationDestination(icon: Icon(Icons.psychology_outlined), label: 'Тренировки'),
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Дневник'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Что происходит сейчас?',
            'Выбери ситуацию. Долгий тест проходить не придётся.',
          ),
          _choiceCard(
            icon: Icons.timer_outlined,
            title: 'Я выхожу через пять минут',
            subtitle: 'Быстрая настройка на первые секунды',
            color: const Color(0xFF2A6D7D),
            dark: true,
            onTap: () => _show(AppPage.checkIn),
          ),
          _choiceCard(
            icon: Icons.person_search_outlined,
            title: 'Соперник кажется сильнее',
            subtitle: 'Вернуть внимание к своей задаче',
            color: sand,
          ),
          _choiceCard(
            icon: Icons.replay,
            title: 'Я ошибся и замер',
            subtitle: 'Короткий reset и следующее действие',
            color: mint,
          ),
          _choiceCard(
            icon: Icons.circle_outlined,
            title: 'Я проиграл',
            subtitle: 'Сейчас или спокойный разбор позже',
            color: rose,
          ),
          _choiceCard(
            icon: Icons.south_east,
            title: 'Я не хочу ехать',
            subtitle: 'Понять причину без стыда и давления',
            color: sand,
          ),
        ],
      ),
    );
  }

  Widget _checkIn() {
    return _shell(
      back: true,
      eyebrow: 'БЫСТРЫЙ ЧЕК-ИН',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Как сейчас работает твоё тело?',
            'Нет правильного ответа. Выберем нужную настройку.',
          ),
          _activationTile(ActivationState.high, Icons.bolt, 'Слишком заведено'),
          _activationTile(ActivationState.working, Icons.adjust, 'Рабочее состояние'),
          _activationTile(ActivationState.low, Icons.south, 'Как будто выключилось'),
          const SizedBox(height: 12),
          _primaryButton(
            'Практика «Первые 30 секунд»',
            _activation == null ? null : _preparePractice,
          ),
          TextButton(
            onPressed: () {
              _activation = ActivationState.working;
              _preparePractice();
            },
            child: const Text('Пропустить вопрос'),
          ),
        ],
      ),
    );
  }

  Widget _practice() {
    final age = _ageBand ?? 13;
    final script = scripts[age]!;
    final lineIndex = (_seconds ~/ 5).clamp(0, script.length - 1).toInt();
    final mode = switch (_activation) {
      ActivationState.high => 'Снизить лишнее напряжение',
      ActivationState.low => 'Добавить включённость',
      _ => 'Сохранить рабочее состояние',
    };
    return _shell(
      back: true,
      dark: true,
      eyebrow: mode,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _heading(
              'Первые 30 секунд',
              'Демо длится 25 секунд. Полная практика будет занимать 60–90 секунд.',
              dark: true,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedScale(
            scale: _playing && _seconds.isEven ? 1.08 : 1,
            duration: const Duration(milliseconds: 950),
            child: Container(
              width: 174,
              height: 174,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.35, -0.35),
                  colors: [Color(0xFF8BC3C5), Color(0xFF407F8A), Color(0xFF1B4F60)],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.white.withValues(alpha: 0.06), spreadRadius: 28),
                ],
              ),
              child: const Icon(Icons.adjust, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '0:${_seconds.toString().padLeft(2, '0')} / 0:25',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _seconds / 25,
            minHeight: 5,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: Colors.white12,
            color: const Color(0xFFB7E2D8),
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              script[lineIndex],
              key: ValueKey(lineIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roundButton(Icons.replay_5, () => setState(() => _seconds = (_seconds - 5).clamp(0, 25).toInt())),
              const SizedBox(width: 14),
              _roundButton(
                _playing ? Icons.pause : Icons.play_arrow,
                _playing ? _stopTimer : _startTimer,
                primary: true,
              ),
              const SizedBox(width: 14),
              _roundButton(Icons.forward_5, () => setState(() => _seconds = (_seconds + 5).clamp(0, 24).toInt())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalPage() {
    const goals = [
      ('Шея защищена', 'Подбородок, стойка и внимание к первому контакту'),
      ('Первым установить контакт', 'Не ждать, пока соперник полностью навяжет своё начало'),
      ('Продолжать после ошибки', 'Ошибка — сигнал к следующему действию, а не конец схватки'),
      ('Дышать в позиции', 'Не задерживать дыхание под давлением'),
    ];
    return _shell(
      back: true,
      eyebrow: 'ОДНО ДЕЙСТВИЕ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Что будет твоей задачей в начале?',
            'Не вся победа. Только одно действие, которое зависит от тебя.',
          ),
          for (final item in goals)
            _selectTile(
              text: item.$1,
              subtitle: item.$2,
              selected: _goal == item.$1,
              onTap: () => setState(() => _goal = item.$1),
            ),
          const SizedBox(height: 10),
          _primaryButton(
            'Я выбрал',
            _goal == null ? null : () => _show(AppPage.complete),
          ),
        ],
      ),
    );
  }

  Widget _complete() {
    return _shell(
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: mint),
              child: const Icon(Icons.check, size: 52, color: Color(0xFF2F6B58)),
            ),
            const SizedBox(height: 24),
            _pill('Практика завершена'),
            const SizedBox(height: 12),
            Text(
              'Первое действие выбрано',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Твоя задача: $_goal.\nОстальное — по ситуации.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            _primaryButton('Готово. Телефон можно убрать', () => _show(AppPage.athleteHome)),
            TextButton(onPressed: () => _show(AppPage.goal), child: const Text('Изменить действие')),
          ],
        ),
      ),
    );
  }

  Widget _parentHome() {
    return _shell(
      back: true,
      eyebrow: 'ДЛЯ РОДИТЕЛЯ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Что произошло?',
            'Сначала выберите ситуацию. Дневник ребёнка здесь не показывается.',
          ),
          _choiceCard(
            icon: Icons.circle_outlined,
            title: 'Ребёнок проиграл',
            subtitle: 'Что сказать сейчас',
            color: rose,
            onTap: () => _show(AppPage.parentLoss),
          ),
          _choiceCard(icon: Icons.timer_outlined, title: 'Скоро старт', subtitle: 'Не передать собственную тревогу', color: sand),
          _choiceCard(icon: Icons.south_east, title: 'Не хочет ехать', subtitle: 'Различить страх, усталость, конфликт и боль', color: mint),
          _choiceCard(icon: Icons.waves, title: 'Я сам на взводе', subtitle: 'Пауза перед разговором', color: mint),
          _notice('Личные записи спортсмена не открываются родителю автоматически — даже в семейном режиме.'),
        ],
      ),
    );
  }

  Widget _parentLoss() {
    return _shell(
      back: true,
      eyebrow: 'ПОСЛЕ ПОРАЖЕНИЯ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Сначала — не разбор',
            'Ребёнок может быть зол, подавлен, молчать или плакать. Не нужно немедленно исправлять это состояние.',
          ),
          _sectionLabel('МОЖНО СКАЗАТЬ'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(20)),
            child: const Text(
              '«Я рядом. Тебе сейчас лучше, чтобы я побыл рядом, помолчал или мы поговорили позже?»',
              style: TextStyle(color: ink, fontSize: 18, height: 1.45, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel('СЕЙЧАС НЕ СТОИТ'),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: rose, borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'Разбирать ошибки в коридоре, сравнивать с соперником, требовать перестать плакать или напоминать, сколько семья вложила в подготовку.',
              style: TextStyle(color: Color(0xFF744947), height: 1.5),
            ),
          ),
          const SizedBox(height: 26),
          _primaryButton('Понятно', () => _show(AppPage.welcome)),
        ],
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFE4F0F2), borderRadius: BorderRadius.circular(30)),
        child: Text(
          text,
          style: const TextStyle(color: blue, fontSize: 12, fontWeight: FontWeight.w800),
        ),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF627883), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .7),
        ),
      );

  Widget _notice(String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 18),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF6F5),
          border: Border.all(color: const Color(0xFFC9DFDA)),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF42625B), height: 1.4)),
      );

  Widget _choiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool dark = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      elevation: dark ? 4 : 0,
      color: dark ? color : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
        side: dark ? BorderSide.none : const BorderSide(color: Color(0xFFD4DFE2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: dark ? Colors.white.withValues(alpha: .14) : color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: dark ? Colors.white : ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: dark ? Colors.white : ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: dark ? Colors.white70 : const Color(0xFF627883),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right, color: dark ? Colors.white70 : blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectTile({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      color: selected ? mint : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? const Color(0xFF77AA9B) : const Color(0xFFD4DFE2), width: selected ? 1.7 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: const TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activationTile(ActivationState value, IconData icon, String text) {
    final selected = _activation == value;
    return Card(
      color: selected ? mint : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? const Color(0xFF77AA9B) : const Color(0xFFD4DFE2)),
      ),
      child: ListTile(
        onTap: () => setState(() => _activation = value),
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
        leading: Icon(icon, color: ink),
        title: Text(text, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
        trailing: selected ? const Icon(Icons.check_circle, color: blue) : null,
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback? onPressed) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: ink,
            disabledBackgroundColor: const Color(0xFFB7C2C6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          ),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      );

  Widget _roundButton(IconData icon, VoidCallback onPressed, {bool primary = false}) => SizedBox(
        width: primary ? 66 : 54,
        height: primary ? 66 : 54,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: primary ? ink : Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: primary ? Colors.white : Colors.white.withValues(alpha: .10),
            side: BorderSide(color: Colors.white.withValues(alpha: .22)),
          ),
        ),
      );
}
