import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  adaptiveCheckIn,
  adaptivePlan,
  adaptiveReview,
  checkIn,
  practice,
  goal,
  complete,
  strongOpponent,
  resetAfterError,
  afterLoss,
  avoidCompetition,
  trainingHome,
  trainingDetail,
  pressureIntro,
  pressureRound,
  pressureResult,
  journalHome,
  journalNew,
  profile,
  parentHome,
  parentLoss,
  parentBeforeStart,
  parentAvoidCompetition,
  parentSelfReset,
}

enum ActivationState { high, working, low }

enum TrainingMoment { ordinary, beforeTraining, beforeCompetition, afterError }

class AdaptiveProtocol {
  const AdaptiveProtocol({
    required this.title,
    required this.why,
    required this.duration,
    required this.steps,
    required this.cue,
    required this.transferTask,
  });

  final String title;
  final String why;
  final String duration;
  final List<(String, String)> steps;
  final String cue;
  final String transferTask;
}

class PressureScenario {
  const PressureScenario({
    required this.title,
    required this.situation,
    required this.options,
    required this.bestOption,
    required this.feedback,
    required this.cue,
  });

  final String title;
  final String situation;
  final List<String> options;
  final int bestOption;
  final String feedback;
  final String cue;
}

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
  Timer? _pressureTimer;
  int _seconds = 0;
  bool _playing = false;
  String? _trainingTitle;
  String? _avoidReason;
  TrainingMoment? _trainingMoment;
  double _energy = 3;
  double _tension = 3;
  double _focus = 3;
  int? _beforeControl;
  int? _afterControl;
  int _adaptiveSessions = 0;
  int _helpfulSessions = 0;
  int _pressureRoundIndex = 0;
  int _pressureSeconds = 8;
  int _pressureScore = 0;
  int _pressureRuns = 0;
  int? _pressureChoice;
  bool _pressureAnswered = false;
  final Set<String> _completedTrainings = {};
  final List<String> _journalNotes = [];
  final TextEditingController _journalController = TextEditingController();

  static const pressureScenarios = [
    PressureScenario(
      title: 'Соперник захватил инициативу',
      situation: 'Сигнал к началу. Соперник сразу идёт вперёд, зал шумит, и ты чувствуешь, что тело зажалось.',
      options: [
        'Попытаться срочно перестать волноваться',
        'Один выдох → опора → первый контакт',
        'Посмотреть на тренера и ждать указания',
      ],
      bestOption: 1,
      feedback: 'Под давлением полезнее короткая связка из тела и действия. Попытка полностью убрать волнение часто только отнимает внимание.',
      cue: 'Выдох. Опора. Контакт.',
    ),
    PressureScenario(
      title: 'Первая ошибка',
      situation: 'Ты пропустил первый балл. В голове появляется: «Опять всё испортил». Схватка продолжается.',
      options: [
        'Разобрать ошибку прямо сейчас',
        'Резко броситься отыгрываться любой ценой',
        'Назвать факт и выбрать действие на две секунды',
      ],
      bestOption: 2,
      feedback: 'Разбор нужен позже. Во время схватки задача reset — вернуть доступ к ближайшему контролируемому действию.',
      cue: 'Ошибка была. Следующее действие.',
    ),
    PressureScenario(
      title: 'Слишком много команд',
      situation: 'Тренер кричит два указания, соперник меняет позицию, а ты уже не понимаешь, за чем следить.',
      options: [
        'Выбрать один внешний сигнал и одно действие',
        'Стараться удержать в голове все команды',
        'Перестать слышать и действовать наугад',
      ],
      bestOption: 0,
      feedback: 'При перегрузке внимание нужно сузить. Один наблюдаемый сигнал помогает снова связать восприятие с действием.',
      cue: 'Один сигнал. Одно действие.',
    ),
  ];

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
    _pressureTimer?.cancel();
    _journalController.dispose();
    super.dispose();
  }

  void _show(AppPage page) {
    if (page != AppPage.practice) _stopTimer();
    if (page != AppPage.pressureRound) _stopPressureTimer();
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

  void _stopPressureTimer() {
    _pressureTimer?.cancel();
    _pressureTimer = null;
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
        AppPage.adaptiveCheckIn => _adaptiveCheckIn(),
        AppPage.adaptivePlan => _adaptivePlan(),
        AppPage.adaptiveReview => _adaptiveReview(),
        AppPage.checkIn => _checkIn(),
        AppPage.practice => _practice(),
        AppPage.goal => _goalPage(),
        AppPage.complete => _complete(),
        AppPage.strongOpponent => _strongOpponent(),
        AppPage.resetAfterError => _resetAfterError(),
        AppPage.afterLoss => _afterLoss(),
        AppPage.avoidCompetition => _avoidCompetition(),
        AppPage.trainingHome => _trainingHome(),
        AppPage.trainingDetail => _trainingDetail(),
        AppPage.pressureIntro => _pressureIntro(),
        AppPage.pressureRound => _pressureRound(),
        AppPage.pressureResult => _pressureResult(),
        AppPage.journalHome => _journalHome(),
        AppPage.journalNew => _journalNew(),
        AppPage.profile => _profile(),
        AppPage.parentHome => _parentHome(),
        AppPage.parentLoss => _parentLoss(),
        AppPage.parentBeforeStart => _parentBeforeStart(),
        AppPage.parentAvoidCompetition => _parentAvoidCompetition(),
        AppPage.parentSelfReset => _parentSelfReset(),
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
      case AppPage.adaptiveCheckIn:
        _show(AppPage.athleteHome);
        break;
      case AppPage.adaptivePlan:
        _show(AppPage.adaptiveCheckIn);
        break;
      case AppPage.adaptiveReview:
        _show(AppPage.adaptivePlan);
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
      case AppPage.strongOpponent:
      case AppPage.resetAfterError:
      case AppPage.afterLoss:
      case AppPage.avoidCompetition:
        _show(AppPage.athleteHome);
        break;
      case AppPage.trainingHome:
      case AppPage.journalHome:
      case AppPage.profile:
        _show(AppPage.athleteHome);
        break;
      case AppPage.trainingDetail:
        _show(AppPage.trainingHome);
        break;
      case AppPage.pressureIntro:
      case AppPage.pressureResult:
        _show(AppPage.trainingHome);
        break;
      case AppPage.pressureRound:
        _show(AppPage.pressureIntro);
        break;
      case AppPage.journalNew:
        _show(AppPage.journalHome);
        break;
      case AppPage.parentLoss:
      case AppPage.parentBeforeStart:
      case AppPage.parentAvoidCompetition:
      case AppPage.parentSelfReset:
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
      eyebrow: 'АЛЬФА 0.5.0',
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

  AdaptiveProtocol get _adaptiveProtocol {
    if (_trainingMoment == TrainingMoment.afterError) {
      return const AdaptiveProtocol(
        title: 'Reset: вернуться за 10 секунд',
        why: 'Ты выбрал момент после ошибки. Сейчас важнее восстановить действие, а не разбирать прошлый эпизод.',
        duration: '60–90 секунд',
        steps: [
          ('Отметь факт', 'Скажи без оценки: «ошибка была». Не добавляй «я слабый» или «всё кончено».'),
          ('Верни тело', 'Один длинный выдох. Почувствуй опору. Освободи плечи и верни подбородок.'),
          ('Назови действие', 'Выбери один глагол на ближайшие две секунды: защитить, встать, вернуть, продолжить.'),
        ],
        cue: 'Ошибка была. Следующее действие — сейчас.',
        transferTask: 'На тренировке попроси партнёра начать из неудобной позиции и трижды отработай reset после условной ошибки.',
      );
    }
    if (_tension >= 4) {
      return const AdaptiveProtocol(
        title: 'Снять лишнее, сохранить силу',
        why: 'Напряжение сейчас выше рабочего уровня. Не нужно становиться полностью спокойным — достаточно вернуть управление телом.',
        duration: '2 минуты',
        steps: [
          ('Опора', 'На пять секунд перенеси внимание в стопы и давление пола.'),
          ('Выдох', 'Сделай четыре обычных вдоха и немного более длинных выдоха. Без глубокого форсированного дыхания.'),
          ('Первый эпизод', 'Представь только стойку, дистанцию и первый контакт — без результата всей схватки.'),
        ],
        cue: 'Не убрать волнение. Направить его в первый контакт.',
        transferTask: 'Перед ближайшим раундом оцени напряжение ещё раз и войди только с одной процессуальной задачей.',
      );
    }
    if (_energy <= 2) {
      return const AdaptiveProtocol(
        title: 'Включить тело без паники',
        why: 'Энергии мало. Вместо мотивационных лозунгов добавим короткое движение и ясную атакующую задачу.',
        duration: '90 секунд',
        steps: [
          ('Разбуди тело', 'Десять секунд пружинь на стопах, разомни кисти и сделай два резких, но контролируемых выдоха.'),
          ('Вспомни удачный вход', 'На десять секунд восстанови один эпизод, где ты действовал решительно.'),
          ('Команда', 'Скажи вслух один конкретный глагол: «сблизиться», «взять захват» или «двигаться».'),
        ],
        cue: 'Не ждать настроения. Начать движение.',
        transferTask: 'Первую минуту тренировки отслеживай только активные стопы и инициативу первого контакта.',
      );
    }
    if (_focus <= 2) {
      return const AdaptiveProtocol(
        title: 'Сузить внимание до одного сигнала',
        why: 'Внимание рассыпается. Сейчас полезнее один внешний ориентир, чем попытка контролировать всё сразу.',
        duration: '90 секунд',
        steps: [
          ('Назови лишнее', 'Одной фразой назови, куда уходит внимание: соперник, зрители, результат или прошлые ошибки.'),
          ('Выбери сигнал', 'Оставь один наблюдаемый ориентир: дистанция, положение рук или давление соперника.'),
          ('Репетиция', 'Три раза представь: замечаю сигнал → сразу выполняю выбранное действие.'),
        ],
        cue: 'Один сигнал. Одно действие.',
        transferTask: 'В следующем раунде после каждой остановки возвращайся к выбранному внешнему сигналу.',
      );
    }
    return const AdaptiveProtocol(
      title: 'Репетиция первого эпизода',
      why: 'Состояние близко к рабочему. Его не нужно чинить — закрепим ясное начало и устойчивость после помехи.',
      duration: '2 минуты',
      steps: [
        ('Первый проход', 'Представь начало от первого лица: стойка, дистанция, первый контакт и своё действие.'),
        ('Добавь помеху', 'Теперь представь, что соперник первым навязал захват. Увидь свой спокойный ответ.'),
        ('Ключ', 'Сожми и расслабь кулак, затем произнеси короткую рабочую команду.'),
      ],
      cue: 'Я готов не к идеальному сценарию, а к следующему действию.',
      transferTask: 'Перед ближайшим раундом повтори ключ и после раунда отметь, вспомнил ли ты процессуальную задачу.',
    );
  }

  void _startAdaptiveCheckIn() {
    setState(() {
      _trainingMoment = null;
      _energy = 3;
      _tension = 3;
      _focus = 3;
      _beforeControl = null;
      _afterControl = null;
      _page = AppPage.adaptiveCheckIn;
    });
  }

  Widget _adaptiveCheckIn() {
    const moments = {
      TrainingMoment.ordinary: ('Обычный день', Icons.calendar_today_outlined),
      TrainingMoment.beforeTraining: ('Перед тренировкой', Icons.sports_martial_arts),
      TrainingMoment.beforeCompetition: ('Перед стартом', Icons.timer_outlined),
      TrainingMoment.afterError: ('После ошибки', Icons.replay),
    };
    return _shell(
      back: true,
      eyebrow: 'АДАПТИВНЫЙ ЧЕК-ИН',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Настроим тренировку под тебя сейчас',
            'Это не тест характера и не диагноз. Ответы нужны, чтобы выбрать подходящий навык и нагрузку.',
          ),
          _sectionLabel('ГДЕ ТЫ СЕЙЧАС'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in moments.entries)
                ChoiceChip(
                  avatar: Icon(item.value.$2, size: 18),
                  label: Text(item.value.$1),
                  selected: _trainingMoment == item.key,
                  onSelected: (_) => setState(() => _trainingMoment = item.key),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _metricSlider('Энергия', 'тело выключено', 'слишком много', _energy, (value) => setState(() => _energy = value)),
          _metricSlider('Напряжение', 'расслаблен', 'зажат', _tension, (value) => setState(() => _tension = value)),
          _metricSlider('Фокус', 'рассыпается', 'очень точный', _focus, (value) => setState(() => _focus = value)),
          const SizedBox(height: 6),
          _sectionLabel('НАСКОЛЬКО ТЫ СЕЙЧАС УПРАВЛЯЕШЬ СВОИМ СОСТОЯНИЕМ?'),
          _ratingRow(_beforeControl, (value) => setState(() => _beforeControl = value)),
          const SizedBox(height: 22),
          _primaryButton(
            'Собрать мою тренировку',
            _trainingMoment == null || _beforeControl == null ? null : () => _show(AppPage.adaptivePlan),
          ),
          _notice('Алгоритм покажет, почему выбрал этот протокол. Победа или поражение не используются как оценка твоей психики.'),
        ],
      ),
    );
  }

  Widget _adaptivePlan() {
    final protocol = _adaptiveProtocol;
    return _shell(
      back: true,
      eyebrow: 'ТВОЙ ПЛАН · ${protocol.duration}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill('Подобрано по текущему состоянию'),
          const SizedBox(height: 14),
          _heading(protocol.title, protocol.why),
          for (var i = 0; i < protocol.steps.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD4DFE2)),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: mint,
                    foregroundColor: ink,
                    child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(protocol.steps[i].$1, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(protocol.steps[i].$2, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('РАБОЧАЯ ФРАЗА'),
                Text(protocol.cue, style: const TextStyle(color: ink, fontSize: 18, height: 1.4, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _primaryButton('Выполнил — проверить эффект', () => _show(AppPage.adaptiveReview)),
        ],
      ),
    );
  }

  Widget _adaptiveReview() {
    final protocol = _adaptiveProtocol;
    return _shell(
      back: true,
      eyebrow: 'ПРОВЕРКА ЭФФЕКТА',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Стало легче управлять состоянием?',
            'Нам не нужна похвала приложению. Честный ответ помогает понять, что работает именно для тебя.',
          ),
          _sectionLabel('ДО ПРАКТИКИ'),
          Text('${_beforeControl ?? 0} из 5', style: const TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          _sectionLabel('СЕЙЧАС'),
          _ratingRow(_afterControl, (value) => setState(() => _afterControl = value)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('ПЕРЕНОС НА КОВЁР'),
                Text(protocol.transferTask, style: const TextStyle(color: ink, height: 1.45, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _primaryButton(
            'Сохранить результат',
            _afterControl == null
                ? null
                : () {
                    final before = _beforeControl ?? 0;
                    final after = _afterControl!;
                    setState(() {
                      _adaptiveSessions++;
                      if (after > before) _helpfulSessions++;
                      _journalNotes.add('${protocol.title}: управление состоянием $before/5 → $after/5. Перенос: ${protocol.transferTask}');
                      _page = AppPage.athleteHome;
                    });
                  },
          ),
          _notice('Если несколько попыток подряд не помогают или состояние ухудшается, приложение не должно усиливать нагрузку: нужен разговор с доверенным взрослым, тренером или специалистом.'),
        ],
      ),
    );
  }

  Widget _metricSlider(
    String title,
    String lowLabel,
    String highLabel,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4DFE2)),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${value.round()}/5', style: const TextStyle(color: blue, fontWeight: FontWeight.w900)),
            ],
          ),
          Slider(value: value, min: 1, max: 5, divisions: 4, onChanged: onChanged),
          Row(
            children: [
              Text(lowLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              const Spacer(),
              Text(highLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(int? selected, ValueChanged<int> onChanged) {
    return Row(
      children: [
        for (var value = 1; value <= 5; value++) ...[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: value == 5 ? 0 : 7),
              child: OutlinedButton(
                onPressed: () => onChanged(value),
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected == value ? ink : Colors.white,
                  foregroundColor: selected == value ? Colors.white : ink,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _athleteHome() {
    final age = switch (_ageBand) { 10 => '10–12', 16 => '16–17', _ => '13–15' };
    return _shell(
      eyebrow: '$age лет · ${_sports.first}',
      bottom: _athleteNav(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Твоя тренировка сегодня',
            'Сначала короткая настройка под текущее состояние. Ниже — помощь в конкретной ситуации.',
          ),
          _choiceCard(
            icon: Icons.auto_awesome_outlined,
            title: _adaptiveSessions == 0 ? 'Собрать персональную практику' : 'Обновить персональную практику',
            subtitle: _adaptiveSessions == 0
                ? 'Чек-ин 45 секунд → протокол → проверка эффекта'
                : 'Выполнено: $_adaptiveSessions · помогло: $_helpfulSessions',
            color: const Color(0xFF2A6D7D),
            dark: true,
            onTap: _startAdaptiveCheckIn,
          ),
          const SizedBox(height: 10),
          _sectionLabel('ПОМОЩЬ ПРЯМО СЕЙЧАС'),
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
            onTap: () => _show(AppPage.strongOpponent),
          ),
          _choiceCard(
            icon: Icons.replay,
            title: 'Я ошибся и замер',
            subtitle: 'Короткий reset и следующее действие',
            color: mint,
            onTap: () => _show(AppPage.resetAfterError),
          ),
          _choiceCard(
            icon: Icons.circle_outlined,
            title: 'Я проиграл',
            subtitle: 'Сейчас или спокойный разбор позже',
            color: rose,
            onTap: () => _show(AppPage.afterLoss),
          ),
          _choiceCard(
            icon: Icons.south_east,
            title: 'Я не хочу ехать',
            subtitle: 'Понять причину без стыда и давления',
            color: sand,
            onTap: () => _show(AppPage.avoidCompetition),
          ),
        ],
      ),
    );
  }

  Widget _athleteNav(int selected) {
    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) {
        final page = switch (index) {
          1 => AppPage.trainingHome,
          2 => AppPage.journalHome,
          3 => AppPage.profile,
          _ => AppPage.athleteHome,
        };
        _show(page);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.adjust), label: 'Сейчас'),
        NavigationDestination(icon: Icon(Icons.psychology_outlined), label: 'Тренировки'),
        NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Дневник'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профиль'),
      ],
    );
  }

  Widget _strongOpponent() {
    return _toolScreen(
      eyebrow: 'СИЛЬНЫЙ СОПЕРНИК',
      title: 'Ты увидел соперника — и уже начал проигрывать в голове',
      subtitle: 'Внешность, пояс, клуб или прошлые победы соперника не определяют следующий эпизод.',
      color: sand,
      icon: Icons.person_search_outlined,
      steps: const [
        ('Отдели факт от прогноза', 'Факт: соперник кажется сильным. Прогноз: «у меня нет шансов». Это не одно и то же.'),
        ('Верни контроль', 'Назови три вещи, которые зависят от тебя: стойка, первый контакт и продолжение после ошибки.'),
        ('Сузь задачу', 'Не побеждай его заранее. Представь только первые 10 секунд и своё первое действие.'),
      ],
      phrase: 'Мне не нужно знать, кто сильнее. Мне нужно войти в первый эпизод.',
      button: 'Вернуться к своей задаче',
    );
  }

  Widget _resetAfterError() {
    return _toolScreen(
      eyebrow: 'RESET ПОСЛЕ ОШИБКИ',
      title: 'Ошибка уже произошла. Схватка ещё продолжается',
      subtitle: 'Reset нужен не для того, чтобы забыть ошибку, а чтобы снова получить доступ к следующему действию.',
      color: mint,
      icon: Icons.replay,
      steps: const [
        ('Заметь', 'Коротко назови: «ошибка была». Не спорь с ней и не разбирай её прямо сейчас.'),
        ('Верни тело', 'Один выдох, опора стопами или ладонями, подбородок и позиция корпуса.'),
        ('Следующее действие', 'Спроси себя: что нужно сделать в ближайшие две секунды? Защититься, вернуть позицию или продолжить движение.'),
      ],
      phrase: 'Не исправить прошлое. Сделать следующее действие.',
      button: 'Я снова в схватке',
    );
  }

  Widget _afterLoss() {
    return _toolScreen(
      eyebrow: 'ПОСЛЕ ПОРАЖЕНИЯ',
      title: 'Сейчас не обязательно всё разбирать',
      subtitle: 'Первые минуты после поражения — не экзамен на силу характера. Сначала нужно вернуть устойчивость.',
      color: rose,
      icon: Icons.circle_outlined,
      steps: const [
        ('Вернись в настоящее', 'Почувствуй опору, оглянись вокруг и сделай спокойный выдох.'),
        ('Отдели себя от результата', 'Ты проиграл одну схватку. Это событие, а не определение тебя как спортсмена.'),
        ('Выбери, что нужно сейчас', 'Побыть одному, позвать взрослого, поддержать товарища или отложить разговор.'),
        ('Разбор — позже', 'Когда напряжение снизится: один полезный момент и одно изменение на тренировку. Не список обвинений.'),
      ],
      phrase: 'Результат уже случился. Моё развитие продолжается.',
      button: 'Вернуться на главный экран',
    );
  }

  Widget _avoidCompetition() {
    const reasons = [
      'Боюсь соперника или проигрыша',
      'Боюсь разочаровать взрослых',
      'Сильно устал или не восстановился',
      'Есть конфликт в клубе или команде',
      'Есть боль или возможная травма',
      'Сам не понимаю причину',
    ];
    final injury = _avoidReason == 'Есть боль или возможная травма';
    return _shell(
      back: true,
      eyebrow: 'НЕ ХОЧУ ЕХАТЬ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Отказ — это сигнал, а не доказательство слабости',
            'Сначала попробуем понять причину. После этого будет легче выбрать следующий шаг.',
          ),
          for (final reason in reasons)
            _selectTile(
              text: reason,
              selected: _avoidReason == reason,
              onTap: () => setState(() => _avoidReason = reason),
            ),
          if (_avoidReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: injury ? rose : mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                injury
                    ? 'Не нужно заставлять себя выступать через боль. Скажи родителю, тренеру или другому взрослому и попроси оценить травму.'
                    : 'Следующий шаг — не заставить себя замолчать. Скажи доверенному взрослому: «Я не просто ленюсь. Мне трудно, и я хочу объяснить почему».',
                style: TextStyle(
                  color: injury ? const Color(0xFF744947) : const Color(0xFF42625B),
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _primaryButton('Я понял следующий шаг', () => _show(AppPage.athleteHome)),
          ],
        ],
      ),
    );
  }

  Widget _toolScreen({
    required String eyebrow,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required List<(String, String)> steps,
    required String phrase,
    required String button,
  }) {
    return _shell(
      back: true,
      eyebrow: eyebrow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: ink, size: 29),
          ),
          _heading(title, subtitle),
          for (var i = 0; i < steps.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD4DFE2)),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color,
                    foregroundColor: ink,
                    child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].$1, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(steps[i].$2, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(
              '«$phrase»',
              textAlign: TextAlign.center,
              style: const TextStyle(color: ink, fontSize: 17, height: 1.4, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          _primaryButton(button, () => _show(AppPage.athleteHome)),
        ],
      ),
    );
  }

  void _startPressureLab() {
    _pressureTimer?.cancel();
    setState(() {
      _pressureRoundIndex = 0;
      _pressureScore = 0;
      _pressureChoice = null;
      _pressureAnswered = false;
    });
    _beginPressureRound();
  }

  void _beginPressureRound() {
    _pressureTimer?.cancel();
    setState(() {
      _pressureSeconds = 8;
      _pressureChoice = null;
      _pressureAnswered = false;
      _page = AppPage.pressureRound;
    });
    HapticFeedback.mediumImpact();
    _pressureTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _pressureAnswered) return;
      if (_pressureSeconds <= 1) {
        _pressureTimer?.cancel();
        setState(() {
          _pressureSeconds = 0;
          _pressureAnswered = true;
          _pressureChoice = -1;
        });
        HapticFeedback.heavyImpact();
      } else {
        setState(() => _pressureSeconds--);
      }
    });
  }

  void _answerPressure(int choice) {
    if (_pressureAnswered) return;
    _pressureTimer?.cancel();
    final scenario = pressureScenarios[_pressureRoundIndex];
    setState(() {
      _pressureChoice = choice;
      _pressureAnswered = true;
      if (choice == scenario.bestOption) _pressureScore++;
    });
    choice == scenario.bestOption ? HapticFeedback.lightImpact() : HapticFeedback.selectionClick();
  }

  void _advancePressureLab() {
    if (_pressureRoundIndex >= pressureScenarios.length - 1) {
      _show(AppPage.pressureResult);
      return;
    }
    setState(() => _pressureRoundIndex++);
    _beginPressureRound();
  }

  Widget _pressureIntro() {
    return _shell(
      back: true,
      eyebrow: 'ЛАБОРАТОРИЯ ДАВЛЕНИЯ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill('3 раунда · около 2 минут'),
          const SizedBox(height: 14),
          _heading(
            'Тренируй решение, пока время идёт',
            'Ты увидишь три борцовские ситуации. На ответ будет восемь секунд. Цель — не угадать красивую фразу, а быстрее возвращаться к следующему действию.',
          ),
          _parentGuideBlock(
            Icons.timer_outlined,
            'Ограничение времени',
            'Таймер создаёт небольшую, безопасную нагрузку на внимание. Если время закончится — это часть тренировки, а не провал.',
            sand,
          ),
          _parentGuideBlock(
            Icons.psychology_outlined,
            'Без оценки личности',
            'Результат показывает только знакомство с конкретным алгоритмом. Он не измеряет характер, смелость или «ментальную силу».',
            mint,
          ),
          const SizedBox(height: 12),
          _primaryButton('Начать первый раунд', _startPressureLab),
        ],
      ),
    );
  }

  Widget _pressureRound() {
    final scenario = pressureScenarios[_pressureRoundIndex];
    final timedOut = _pressureChoice == -1;
    return _shell(
      back: true,
      dark: !_pressureAnswered,
      eyebrow: 'РАУНД ${_pressureRoundIndex + 1} ИЗ ${pressureScenarios.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _pressureAnswered ? 1 : _pressureSeconds / 8,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(20),
                  backgroundColor: _pressureAnswered ? const Color(0xFFD4DFE2) : Colors.white12,
                  color: _pressureAnswered ? blue : const Color(0xFFB7E2D8),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                _pressureAnswered ? 'СТОП' : '$_pressureSeconds',
                style: TextStyle(
                  color: _pressureAnswered ? ink : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            scenario.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _pressureAnswered ? ink : Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            scenario.situation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _pressureAnswered ? ink : Colors.white70),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < scenario.options.length; i++)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: _pressureAnswered ? null : () => _answerPressure(i),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  backgroundColor: _pressureAnswered
                      ? i == scenario.bestOption
                          ? mint
                          : _pressureChoice == i
                              ? rose
                              : Colors.white
                      : Colors.white.withValues(alpha: .09),
                  foregroundColor: _pressureAnswered ? ink : Colors.white,
                  disabledForegroundColor: ink,
                  side: BorderSide(
                    color: _pressureAnswered
                        ? i == scenario.bestOption
                            ? const Color(0xFF77AA9B)
                            : const Color(0xFFD4DFE2)
                        : Colors.white30,
                  ),
                  padding: const EdgeInsets.all(17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(scenario.options[i], style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35))),
                    if (_pressureAnswered && i == scenario.bestOption) const Icon(Icons.check_circle, color: Color(0xFF2F6B58)),
                  ],
                ),
              ),
            ),
          if (_pressureAnswered) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: timedOut ? sand : mint, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timedOut
                        ? 'Время закончилось — алгоритм можно натренировать'
                        : _pressureChoice == scenario.bestOption
                            ? 'Рабочее решение'
                            : 'Полезная коррекция',
                    style: const TextStyle(color: ink, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(scenario.feedback, style: const TextStyle(color: ink, height: 1.45)),
                  const SizedBox(height: 10),
                  Text('Ключ: «${scenario.cue}»', style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _primaryButton(
              _pressureRoundIndex == pressureScenarios.length - 1 ? 'Посмотреть результат' : 'Следующий раунд',
              _advancePressureLab,
            ),
          ],
        ],
      ),
    );
  }

  Widget _pressureResult() {
    final message = switch (_pressureScore) {
      3 => 'Алгоритмы уже хорошо узнаются под ограничением времени.',
      2 => 'Основа есть. Один из алгоритмов стоит повторить ещё раз.',
      _ => 'Сейчас важнее знакомство, а не счёт. Повтор сделает решения доступнее под давлением.',
    };
    return _shell(
      back: true,
      eyebrow: 'РАЗБОР ТРЕНИРОВКИ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('$_pressureScore из ${pressureScenarios.length} рабочих решений', message),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(22)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Три ключа', style: TextStyle(color: ink, fontWeight: FontWeight.w900)),
                SizedBox(height: 10),
                Text('1. Выдох → опора → контакт\n2. Ошибка была → следующее действие\n3. Один сигнал → одно действие', style: TextStyle(color: ink, height: 1.65, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _notice('Перенос на ковёр: попроси тренера или партнёра три раза неожиданно дать сигнал «reset» во время лёгкого раунда. На сигнал выполни один из трёх алгоритмов.'),
          const SizedBox(height: 20),
          _primaryButton('Сохранить тренировку', () {
            setState(() {
              _pressureRuns++;
              _completedTrainings.add('Лаборатория давления');
              _journalNotes.add('Лаборатория давления: $_pressureScore из ${pressureScenarios.length} рабочих решений. Следующий шаг: повторить reset с неожиданным сигналом на ковре.');
            });
            _show(AppPage.trainingHome);
          }),
          TextButton(onPressed: _startPressureLab, child: const Text('Повторить три раунда')),
        ],
      ),
    );
  }

  Widget _trainingHome() {
    const trainings = [
      ('Фокус под давлением', '3 минуты', Icons.center_focus_strong, 'Сужаем внимание до контролируемой задачи.'),
      ('Reset после ошибки', '2 минуты', Icons.replay, 'Тренируем быстрый возврат к следующему действию.'),
      ('Уверенность без гарантий', '4 минуты', Icons.shield_outlined, 'Опора на подготовку, а не на обещание победы.'),
      ('Рабочее возбуждение', '3 минуты', Icons.bolt, 'Учимся немного снижать или поднимать энергию.'),
      ('Репетиция первого эпизода', '5 минут', Icons.visibility_outlined, 'Представляем начало схватки без фантазии о результате.'),
    ];
    return _shell(
      eyebrow: '${_completedTrainings.length} ОСВОЕНО',
      bottom: _athleteNav(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Психологические тренировки', 'Короткие упражнения между обычными тренировками — не только перед соревнованием.'),
          _choiceCard(
            icon: Icons.speed,
            title: 'Лаборатория давления',
            subtitle: _pressureRuns == 0 ? '3 раунда · таймер · решение под помехой' : 'Пройдено: $_pressureRuns · повторить под нагрузкой',
            color: const Color(0xFF2A6D7D),
            dark: true,
            onTap: () => _show(AppPage.pressureIntro),
          ),
          const SizedBox(height: 8),
          _sectionLabel('СПОКОЙНАЯ ОТРАБОТКА'),
          for (final item in trainings)
            _choiceCard(
              icon: item.$3,
              title: item.$1,
              subtitle: '${item.$2} · ${item.$4}',
              color: _completedTrainings.contains(item.$1) ? mint : sand,
              onTap: () {
                setState(() => _trainingTitle = item.$1);
                _show(AppPage.trainingDetail);
              },
            ),
          _notice('Здесь нет серии, которая обнулится за пропуск. Важно возвращаться к инструментам тогда, когда они нужны.'),
        ],
      ),
    );
  }

  Widget _trainingDetail() {
    final title = _trainingTitle ?? 'Фокус под давлением';
    const content = {
      'Фокус под давлением': ('Выбери один внешний ориентир, один телесный сигнал и одну задачу. Удерживай их по очереди по 20 секунд.', 'Моё внимание возвращается к задаче.'),
      'Reset после ошибки': ('Пять раз мысленно пройди связку: заметил ошибку — выдохнул — нашёл опору — выбрал следующее действие.', 'Следующий эпизод важнее прошлого.'),
      'Уверенность без гарантий': ('Назови три вещи, которые ты уже делал на тренировках, и одно действие, которое готов выполнить под давлением.', 'Мне не нужна гарантия, чтобы начать действовать.'),
      'Рабочее возбуждение': ('Оцени энергию от 1 до 5. Если выше рабочей — удлини выдох и расслабь плечи. Если ниже — выпрямись, ускорь шаг и назови задачу вслух.', 'Я могу немного менять своё состояние.'),
      'Репетиция первого эпизода': ('Представь только выход, стойку, дистанцию, первый контакт и своё безопасное продолжение. Останови образ до результата.', 'Я репетирую действие, а не медаль.'),
    };
    final item = content[title]!;
    final done = _completedTrainings.contains(title);
    return _shell(
      back: true,
      eyebrow: 'ЕЖЕДНЕВНАЯ ПРАКТИКА',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(done ? 'Уже выполнено' : '3–5 минут'),
          const SizedBox(height: 14),
          _heading(title, 'Выполняй спокойно. Цель — не идеальное состояние, а повторяемый навык.'),
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFD4DFE2))),
            child: Text(item.$1, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(20)),
            child: Text('«${item.$2}»', textAlign: TextAlign.center, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 17)),
          ),
          const SizedBox(height: 24),
          _primaryButton(done ? 'Вернуться к тренировкам' : 'Отметить как выполненное', () {
            setState(() => _completedTrainings.add(title));
            _show(AppPage.trainingHome);
          }),
        ],
      ),
    );
  }

  Widget _journalHome() {
    return _shell(
      eyebrow: 'ЛИЧНОЕ ПРОСТРАНСТВО',
      bottom: _athleteNav(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Дневник спортсмена', 'Сохраняй не только результат, а то, что поможет на следующем турнире.'),
          _notice('Эти записи не показываются родителю или тренеру автоматически.'),
          const SizedBox(height: 18),
          if (_journalNotes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFD4DFE2))),
              child: Column(
                children: [
                  const Icon(Icons.edit_note, size: 46, color: blue),
                  const SizedBox(height: 10),
                  const Text('Пока нет записей', style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text('Первая запись может состоять всего из одного полезного момента.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          else
            for (var i = _journalNotes.length - 1; i >= 0; i--)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: mint, child: Icon(Icons.article_outlined, color: ink)),
                  title: Text(_journalNotes[i], maxLines: 3, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Запись ${i + 1} · только на этом устройстве'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _journalNotes.removeAt(i))),
                ),
              ),
          const SizedBox(height: 18),
          _primaryButton('Добавить запись', () {
            _journalController.clear();
            _show(AppPage.journalNew);
          }),
        ],
      ),
    );
  }

  Widget _journalNew() {
    return _shell(
      back: true,
      eyebrow: 'НОВАЯ ЗАПИСЬ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Что стоит сохранить?', 'Не нужно описывать весь турнир. Достаточно одного момента и одного следующего шага.'),
          TextField(
            controller: _journalController,
            minLines: 6,
            maxLines: 10,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Например: после первой ошибки я остановился. На тренировке хочу пять раз отработать быстрый reset…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          _primaryButton(
            'Сохранить запись',
            _journalController.text.trim().isEmpty
                ? null
                : () {
                    setState(() => _journalNotes.add(_journalController.text.trim()));
                    _show(AppPage.journalHome);
                  },
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    final age = switch (_ageBand) { 10 => '10–12 лет', 16 => '16–17 лет', _ => '13–15 лет' };
    return _shell(
      eyebrow: 'АЛЬФА 0.5.0',
      bottom: _athleteNav(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Профиль', 'Настройки спортсмена и понятные границы приватности.'),
          _profileRow(Icons.cake_outlined, 'Возрастная версия', age),
          _profileRow(Icons.sports_martial_arts, 'Виды спорта', _sports.join(', ')),
          _profileRow(Icons.psychology_outlined, 'Освоено тренировок', '${_completedTrainings.length}'),
          _profileRow(Icons.auto_awesome_outlined, 'Адаптивных практик', '$_adaptiveSessions · помогло $_helpfulSessions'),
          _profileRow(Icons.speed, 'Тренировок под давлением', '$_pressureRuns'),
          _profileRow(Icons.article_outlined, 'Записей в дневнике', '${_journalNotes.length}'),
          const SizedBox(height: 12),
          _notice('Дневник пока хранится только в памяти текущей alpha-сессии. В следующей версии добавим защищённое локальное сохранение.'),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _ageBand = null;
                _sports
                  ..clear()
                  ..add('BJJ');
                _activation = null;
                _goal = null;
              });
              _show(AppPage.welcome);
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Пройти настройку заново'),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: mint, child: Icon(icon, color: ink)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(value),
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
          _choiceCard(
            icon: Icons.timer_outlined,
            title: 'Скоро старт',
            subtitle: 'Не передать собственную тревогу',
            color: sand,
            onTap: () => _show(AppPage.parentBeforeStart),
          ),
          _choiceCard(
            icon: Icons.south_east,
            title: 'Не хочет ехать',
            subtitle: 'Различить страх, усталость, конфликт и боль',
            color: mint,
            onTap: () => _show(AppPage.parentAvoidCompetition),
          ),
          _choiceCard(
            icon: Icons.waves,
            title: 'Я сам на взводе',
            subtitle: 'Пауза перед разговором',
            color: mint,
            onTap: () => _show(AppPage.parentSelfReset),
          ),
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
          _primaryButton('Вернуться к ситуациям', () => _show(AppPage.parentHome)),
        ],
      ),
    );
  }

  Widget _parentBeforeStart() {
    return _parentGuide(
      eyebrow: 'ПЕРЕД СТАРТОМ',
      title: 'Сейчас ребёнку нужна опора, а не дополнительный тренер',
      subtitle: 'Даже полезный технический совет перед выходом может перегрузить внимание. Оставьте одну спокойную фразу и пространство для собственного плана.',
      doTitle: 'Скажите коротко',
      doText: '«Я рядом. Тебе сейчас нужна помощь или лучше дать тебе спокойно настроиться?»',
      avoidTitle: 'Не добавляйте ставки',
      avoidText: 'Не обещайте награду за победу, не напоминайте о затратах и не говорите «ты обязан», «не подведи» или «этого соперника ты должен проходить».',
      actionTitle: 'Проверка родителя',
      actionText: 'Опустите плечи, сделайте один обычный вдох и более длинный выдох. Говорите немного медленнее, чем хочется. Ребёнок считывает не только слова.',
    );
  }

  Widget _parentAvoidCompetition() {
    return _parentGuide(
      eyebrow: 'НЕ ХОЧЕТ ЕХАТЬ',
      title: 'Не называйте отказ ленью, пока не поняли причину',
      subtitle: 'Избегание может означать страх поражения, давление, усталость, конфликт, травлю или физическую боль. Для разных причин нужны разные действия.',
      doTitle: 'Начните с вопроса без ловушки',
      doText: '«Я не буду сейчас уговаривать или ругать. Помоги понять: страшно, больно, устал, что-то произошло в клубе или причина пока непонятна?»',
      avoidTitle: 'Не торгуйтесь сразу',
      avoidText: 'Не обещайте подарок за участие и не угрожайте забрать спорт. Сначала выслушайте ответ. При боли или возможной травме участие нельзя использовать как проверку характера.',
      actionTitle: 'Следующий шаг',
      actionText: 'Если причина — страх, договоритесь об одном небольшом действии и разговоре с тренером. Если есть боль, травля, паника или устойчивый отказ — подключите подходящего взрослого или специалиста.',
    );
  }

  Widget _parentSelfReset() {
    return _parentGuide(
      eyebrow: 'ПАУЗА ДЛЯ РОДИТЕЛЯ',
      title: 'Сначала снизьте собственное напряжение',
      subtitle: 'Поддержка становится трудной, когда вы сами мысленно уже проживаете поражение, несправедливое судейство или разговор с тренером.',
      doTitle: 'Пауза на 30 секунд',
      doText: 'Почувствуйте стопы. Расслабьте челюсть. Сделайте три обычных вдоха с немного более длинным выдохом. Назовите про себя: «Это моя тревога, ребёнку не нужно её нести».',
      avoidTitle: 'Не разговаривайте на пике',
      avoidText: 'Не выясняйте отношения с тренером, судьёй или ребёнком, пока хочется говорить громко, доказывать и немедленно исправлять ситуацию.',
      actionTitle: 'Одна родительская задача',
      actionText: 'На ближайшие десять минут выберите только одну роль: быть рядом, помочь с водой и экипировкой или дать пространство. Анализ можно провести позже.',
    );
  }

  Widget _parentGuide({
    required String eyebrow,
    required String title,
    required String subtitle,
    required String doTitle,
    required String doText,
    required String avoidTitle,
    required String avoidText,
    required String actionTitle,
    required String actionText,
  }) {
    return _shell(
      back: true,
      eyebrow: eyebrow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(title, subtitle),
          _parentGuideBlock(Icons.chat_bubble_outline, doTitle, doText, mint),
          _parentGuideBlock(Icons.do_not_disturb_alt_outlined, avoidTitle, avoidText, rose),
          _parentGuideBlock(Icons.arrow_forward, actionTitle, actionText, sand),
          const SizedBox(height: 12),
          _primaryButton('Вернуться к ситуациям', () => _show(AppPage.parentHome)),
        ],
      ),
    );
  }

  Widget _parentGuideBlock(IconData icon, String title, String text, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ink),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(color: ink, height: 1.45)),
              ],
            ),
          ),
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
    required VoidCallback onTap,
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
              Icon(Icons.chevron_right, color: dark ? Colors.white70 : blue),
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
