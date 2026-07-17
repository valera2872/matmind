import 'models.dart';

class PersonalizationEngine {
  static PracticePlan buildQuickPlan({
    required UserProfile profile,
    required BodyState bodyState,
    required MentalObstacle obstacle,
    required StartTask startTask,
    required List<BoutRecord> history,
  }) {
    final completed =
        history.where((record) => record.isCompleted).toList(growable: false);
    final last = completed.isEmpty ? null : completed.first;
    final age = profile.ageBand ?? 13;
    final matTask = _matTask(startTask, obstacle);
    final historyStep = _quickHistoryStep(last);

    return PracticePlan(
      title: 'Быстрый вход в свою борьбу',
      subtitle:
          'Не нужно полностью менять состояние. Верни тело, сузь внимание и начни с одного действия.',
      durationSeconds: 48,
      steps: <String>[
        _bodyStep(bodyState, age),
        _obstacleStep(obstacle, age),
        if (historyStep != null) historyStep,
        'Первые десять секунд: $matTask',
      ],
      cueOptions: _cueOptions(bodyState, obstacle, startTask),
      matTask: matTask,
      personalReason:
          'Быстрый режим: состояние «${bodyState.label.toLowerCase()}», '
          'помеха «${obstacle.label.toLowerCase()}».',
    );
  }

  static PracticePlan buildPlan({
    required UserProfile profile,
    required BoutTiming timing,
    required BodyState bodyState,
    required MentalObstacle obstacle,
    required StartTask startTask,
    required List<BoutRecord> history,
  }) {
    final completed =
        history.where((record) => record.isCompleted).toList(growable: false);
    final last = completed.isEmpty ? null : completed.first;
    final variant = profile.practiceRuns % 3;
    final age = profile.ageBand ?? 13;

    return PracticePlan(
      title: _title(timing, variant),
      subtitle: _subtitle(timing),
      durationSeconds: switch (timing) {
        BoutTiming.fiveMinutes => 65,
        BoutTiming.fifteenMinutes => 90,
        BoutTiming.thirtyToSixty => 115,
        BoutTiming.moreThanHour => 125,
      },
      steps: <String>[
        _bodyStep(bodyState, age),
        _obstacleStep(obstacle, age),
        ..._timingSteps(timing, startTask),
        if (last?.nextInsight != null)
          'Учти прошлую схватку: ${last!.nextInsight}',
        'Заверши настройку одной задачей: ${startTask.label.toLowerCase()}.',
      ],
      cueOptions: _cueOptions(bodyState, obstacle, startTask),
      matTask: _matTask(startTask, obstacle),
      personalReason: _personalReason(bodyState, obstacle, last),
    );
  }

  static String? _quickHistoryStep(BoutRecord? last) {
    if (last == null) return null;
    if (last.startOutcome == StartOutcome.no) {
      return 'В прошлый раз соперник забрал начало. Сегодня не жди — раньше ищи своё первое действие.';
    }
    if (last.interference == BoutInterference.error &&
        last.recoveryOutcome == RecoveryOutcome.didNotReturn) {
      return 'Если случится ошибка: назови факт, верни положение тела и сразу продолжи.';
    }
    if (last.interference == BoutInterference.strongOpponent) {
      return 'В прошлый раз внимание ушло на соперника. Сегодня первым создай знакомую тебе задачу.';
    }
    if (last.startOutcome == StartOutcome.yes) {
      return 'Прошлое начало получилось. Сохрани тот же принцип и будь готов продолжить после неожиданности.';
    }
    return null;
  }

  static String buildNextInsight(BoutRecord record) {
    if (record.startOutcome == StartOutcome.no) {
      return 'В следующий раз не ставь общую цель «быть увереннее». '
          'Заранее выбери момент входа и начни с задачи «${record.startTask.compact}» '
          'до того, как соперник полностью задаст свой ритм.';
    }
    if (record.interference == BoutInterference.error &&
        record.recoveryOutcome == RecoveryOutcome.didNotReturn) {
      return 'Следующая тренировка должна быть про reset после ошибки: '
          'назвать факт, вернуть положение тела и выполнить одно действие за две секунды.';
    }
    if (record.interference == BoutInterference.overactivation) {
      return 'Перед следующей схваткой приложение сократит возбуждающую часть и раньше даст '
          'телесную задачу: свободные плечи, обычный вдох и более длинный мягкий выдох.';
    }
    if (record.interference == BoutInterference.lowEnergy) {
      return 'Следующую настройку начнём с короткой активации: корпус, два активных шага '
          'и первое движение без ожидания полной готовности.';
    }
    if (record.interference == BoutInterference.strongOpponent) {
      return 'Следующий протокол будет строиться вокруг инициативы: не оценивать соперника, '
          'а стать неудобным, менять темп и первым искать свою дистанцию.';
    }
    if (record.helpfulTool == HelpfulTool.coach) {
      return 'Одна команда тренера сработала. Перед следующим стартом заранее выбери только '
          'одну команду и не пытайся удержать весь технический план.';
    }
    if (record.helpfulTool == HelpfulTool.cue) {
      return 'Короткая команда помогла. Сохрани её как якорь, но привязывай '
          'не к уверенности, а к конкретному действию на ковре.';
    }
    if (record.startOutcome == StartOutcome.yes) {
      return 'Начало получилось. Сохрани тот же принцип, но заранее подготовь ответ '
          'на первую неожиданность, чтобы хороший старт не превратился в жёсткий сценарий.';
    }
    return 'На следующую схватку перенеси только одно изменение. Чем конкретнее действие, '
        'тем легче проверить, сработала ли настройка.';
  }

  static List<SkillSummary> buildSkillProfile(List<BoutRecord> history) {
    final completed =
        history.where((record) => record.isCompleted).toList(growable: false);

    int countWhere(bool Function(BoutRecord record) test) =>
        completed.where(test).length;

    final startAttempts =
        completed.where((record) => record.startOutcome != null).length;
    final startSuccess =
        countWhere((record) => record.startOutcome == StartOutcome.yes);

    final recoveryAttempts = completed
        .where(
          (record) =>
              record.recoveryOutcome != null &&
              record.recoveryOutcome != RecoveryOutcome.noError,
        )
        .length;
    final recoverySuccess = countWhere(
      (record) => record.recoveryOutcome == RecoveryOutcome.returnedFast,
    );

    final pressureAttempts = completed
        .where(
          (record) =>
              record.interference == BoutInterference.overactivation ||
              record.obstacle == MentalObstacle.resultPressure,
        )
        .length;
    final pressureSuccess = countWhere(
      (record) =>
          record.interference != BoutInterference.overactivation &&
          record.startOutcome != StartOutcome.no,
    );

    final initiativeAttempts = completed.length;
    final initiativeSuccess = countWhere(
      (record) =>
          record.startOutcome == StartOutcome.yes &&
          record.interference != BoutInterference.strongOpponent,
    );

    return <SkillSummary>[
      _summary(
        title: 'Начало схватки',
        attempts: startAttempts,
        successes: startSuccess,
        nextStep: 'Выбирать одно проверяемое действие на первые десять секунд.',
      ),
      _summary(
        title: 'Возврат после ошибки',
        attempts: recoveryAttempts,
        successes: recoverySuccess,
        nextStep: 'Тренировать связку «факт → тело → действие» в обычных раундах.',
      ),
      _summary(
        title: 'Управление возбуждением',
        attempts: pressureAttempts,
        successes: pressureSuccess,
        nextStep: 'Не стремиться стать полностью спокойным — искать рабочее состояние.',
      ),
      _summary(
        title: 'Своя инициатива',
        attempts: initiativeAttempts,
        successes: initiativeSuccess,
        nextStep: 'Первым искать дистанцию, темп или захват, не угадывая результат.',
      ),
    ];
  }

  static SkillSummary _summary({
    required String title,
    required int attempts,
    required int successes,
    required String nextStep,
  }) {
    if (attempts == 0) {
      return SkillSummary(
        title: title,
        status: 'Ещё не проверялось',
        evidence: 'Нужна хотя бы одна отметка после схватки.',
        nextStep: nextStep,
      );
    }
    final ratio = successes / attempts;
    final status = attempts >= 3 && ratio >= 0.66
        ? 'Получается чаще'
        : successes > 0
            ? 'Пробовал на ковре'
            : 'Начал тренировать';
    return SkillSummary(
      title: title,
      status: status,
      evidence: '$successes из $attempts отмеченных ситуаций прошли по плану.',
      nextStep: nextStep,
    );
  }

  static String _title(BoutTiming timing, int variant) {
    final titles = switch (timing) {
      BoutTiming.fiveMinutes => <String>[
          'Последняя настройка перед ковром',
          'Собраться, не успокаиваться',
          'Вернуть доступ к своей борьбе',
        ],
      BoutTiming.fifteenMinutes => <String>[
          'Один план вместо десяти мыслей',
          'Собери внимание перед вызовом',
          'Подготовь тело и освободи голову',
        ],
      BoutTiming.thirtyToSixty => <String>[
          'Твои первые десять секунд',
          'Репетиция начала без предсказания результата',
          'Сначала свой ритм, потом всё остальное',
        ],
      BoutTiming.moreThanHour => <String>[
          'Подготовь план и отпусти его',
          'Сохрани энергию до выхода',
          'Не держи схватку в голове весь час',
        ],
    };
    return titles[variant % titles.length];
  }

  static String _subtitle(BoutTiming timing) => switch (timing) {
        BoutTiming.fiveMinutes =>
          'Сейчас нельзя перестроить себя полностью. Можно вернуть тело, сузить внимание и выбрать первое действие.',
        BoutTiming.fifteenMinutes =>
          'Есть время отрегулировать возбуждение и собрать один простой план.',
        BoutTiming.thirtyToSixty =>
          'Коротко отрепетируй начало, затем снова переключись на обычное ожидание.',
        BoutTiming.moreThanHour =>
          'Подготовь проверяемый план, проверь организационные вещи и перестань бороться в голове заранее.',
      };

  static String _bodyStep(BodyState state, int age) => switch (state) {
        BodyState.overactivated => age <= 10
            ? 'Почувствуй стопы. Сделай обычный вдох и мягкий более длинный выдох. Плечи оставь свободными.'
            : 'Верни внимание в стопы, освободи челюсть и плечи. Сделай обычный вдох и более длинный мягкий выдох.',
        BodyState.ready =>
          'Не исправляй рабочее состояние. Проверь только опору, свободное дыхание и положение головы.',
        BodyState.lowEnergy =>
          'Добавь короткую активацию: расправь корпус, дважды сожми и отпусти кисти, сделай два активных шага.',
      };

  static String _obstacleStep(MentalObstacle obstacle, int age) =>
      switch (obstacle) {
        MentalObstacle.tooManyThoughts =>
          'Не удерживай весь план. Назови один внешний сигнал и одно действие после него.',
        MentalObstacle.strongOpponent =>
          'Пояс, клуб и прошлые победы — информация, но не итог. Стань неудобным и первым навяжи знакомый ритм.',
        MentalObstacle.fearOfError =>
          'Ошибка не требует остановки. Подготовь переход: «ошибка была — положение тела — следующее действие».',
        MentalObstacle.resultPressure => age <= 10
            ? 'Не нужно выигрывать схватку в голове. Выполни только первое выбранное действие.'
            : 'Перенеси внимание с результата на то, что можно проверить в первые десять секунд.',
        MentalObstacle.longWaiting =>
          'Ожидание уже забрало внимание. Не возвращай прежний настрой — начни заново с тела и одной задачи.',
      };

  static List<String> _timingSteps(
    BoutTiming timing,
    StartTask task,
  ) =>
      switch (timing) {
        BoutTiming.fiveMinutes => <String>[
            'Посмотри на один неподвижный предмет и назови про себя, где ты находишься сейчас.',
            'Представь только сигнал судьи и своё действие «${task.compact}». Не прокручивай всю схватку.',
          ],
        BoutTiming.fifteenMinutes => <String>[
            'Проверь экипировку и время вызова один раз. После проверки перестань возвращаться к этому.',
            'Мысленно пройди выход к центру, сигнал и действие «${task.compact}». После этого убери телефон.',
          ],
        BoutTiming.thirtyToSixty => <String>[
            'Представь выход, сигнал и первые десять секунд. Не представляй победу — представляй действие.',
            'Добавь неожиданность: соперник начинает иначе. Ты не замираешь, а возвращаешься к задаче «${task.compact}».',
            'После репетиции переключись на разговор, спокойную ходьбу или знакомую музыку на 8–12 минут.',
          ],
        BoutTiming.moreThanHour => <String>[
            'Проверь вызов, экипировку, воду и разминку. Затем перестань перепроверять.',
            'Один раз сформулируй начало: «${task.compact}». Всю схватку запоминать не нужно.',
            'Переключись на обычное ожидание. За пятнадцать минут до выхода вернись к короткой настройке.',
          ],
      };

  static List<String> _cueOptions(
    BodyState bodyState,
    MentalObstacle obstacle,
    StartTask startTask,
  ) {
    final bodyCue = switch (bodyState) {
      BodyState.overactivated => 'Выдох. Опора. Действие.',
      BodyState.ready => 'Вижу. Вхожу. Делаю своё.',
      BodyState.lowEnergy => 'Корпус. Шаг. Начать первым.',
    };
    final obstacleCue = switch (obstacle) {
      MentalObstacle.tooManyThoughts => 'Один сигнал. Одно действие.',
      MentalObstacle.strongOpponent => 'Стань неудобным. Навяжи своё.',
      MentalObstacle.fearOfError => 'Ошибка была. Сразу дальше.',
      MentalObstacle.resultPressure => 'Не результат. Следующее действие.',
      MentalObstacle.longWaiting => 'Начинаю заново. Здесь и сейчас.',
    };
    final taskCue = switch (startTask) {
      StartTask.firstGrip => 'Моя дистанция. Мой захват.',
      StartTask.ownDistance => 'Первым занять дистанцию.',
      StartTask.safeNeck => 'Шея закрыта. Стойка живая.',
      StartTask.startFirst => 'Не ждать. Начать движение.',
      StartTask.continueAfterSurprise => 'Увидел. Защитился. Продолжил.',
    };
    return <String>[bodyCue, obstacleCue, taskCue];
  }

  static String _matTask(StartTask task, MentalObstacle obstacle) {
    final base = switch (task) {
      StartTask.firstGrip =>
        'В первые десять секунд первым коснуться выбранного захвата или создать ситуацию для него.',
      StartTask.ownDistance =>
        'Сразу занять удобную тебе дистанцию и не позволить сопернику без сопротивления построить своё начало.',
      StartTask.safeNeck =>
        'На старте сохранить положение головы, живую стойку и не отдавать шею при первом контакте.',
      StartTask.startFirst =>
        'Не ждать полного ощущения готовности: сделать первое осмысленное движение после сигнала.',
      StartTask.continueAfterSurprise =>
        'После неожиданного действия соперника не оценивать ситуацию, а сразу перейти к защите или продолжению.',
    };
    return obstacle == MentalObstacle.strongOpponent
        ? '$base Дополнительно: один раз изменить темп, чтобы стать менее предсказуемым.'
        : base;
  }

  static String _personalReason(
    BodyState state,
    MentalObstacle obstacle,
    BoutRecord? last,
  ) {
    final history = last == null ? '' : ', учтена последняя схватка';
    return 'Состояние: «${state.label.toLowerCase()}», '
        'главная помеха: «${obstacle.label.toLowerCase()}»$history.';
  }
}
