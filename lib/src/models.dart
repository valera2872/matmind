import 'dart:convert';

enum BoutTiming { fiveMinutes, fifteenMinutes, thirtyToSixty, moreThanHour }

extension BoutTimingLabel on BoutTiming {
  String get label => switch (this) {
        BoutTiming.fiveMinutes => 'Около 5 минут',
        BoutTiming.fifteenMinutes => 'Около 15 минут',
        BoutTiming.thirtyToSixty => '30–60 минут',
        BoutTiming.moreThanHour => 'Больше часа',
      };

  String get shortLabel => switch (this) {
        BoutTiming.fiveMinutes => '5 МИНУТ',
        BoutTiming.fifteenMinutes => '15 МИНУТ',
        BoutTiming.thirtyToSixty => '30–60 МИНУТ',
        BoutTiming.moreThanHour => 'БОЛЬШЕ ЧАСА',
      };
}

enum BodyState { overactivated, ready, lowEnergy }

extension BodyStateLabel on BodyState {
  String get label => switch (this) {
        BodyState.overactivated => 'Слишком разогнался',
        BodyState.ready => 'Собран и готов',
        BodyState.lowEnergy => 'Как будто выключился',
      };
}

enum MentalObstacle {
  tooManyThoughts,
  strongOpponent,
  fearOfError,
  resultPressure,
  longWaiting,
}

extension MentalObstacleLabel on MentalObstacle {
  String get label => switch (this) {
        MentalObstacle.tooManyThoughts => 'Слишком много мыслей',
        MentalObstacle.strongOpponent => 'Соперник кажется сильнее',
        MentalObstacle.fearOfError => 'Боюсь ошибиться в начале',
        MentalObstacle.resultPressure => 'Думаю только о результате',
        MentalObstacle.longWaiting => 'Долгое ожидание сбило настрой',
      };
}

enum StartTask {
  firstGrip,
  ownDistance,
  safeNeck,
  startFirst,
  continueAfterSurprise,
}

extension StartTaskLabel on StartTask {
  String get label => switch (this) {
        StartTask.firstGrip => 'Первым найти свой захват',
        StartTask.ownDistance => 'Занять свою дистанцию',
        StartTask.safeNeck => 'Сохранить безопасную шею и стойку',
        StartTask.startFirst => 'Начать движение первым',
        StartTask.continueAfterSurprise => 'Продолжить после неожиданности',
      };

  String get compact => switch (this) {
        StartTask.firstGrip => 'свой захват',
        StartTask.ownDistance => 'своя дистанция',
        StartTask.safeNeck => 'безопасная шея',
        StartTask.startFirst => 'первое движение',
        StartTask.continueAfterSurprise => 'сразу продолжить',
      };
}

enum StartOutcome { yes, partly, no }

extension StartOutcomeLabel on StartOutcome {
  String get label => switch (this) {
        StartOutcome.yes => 'Да, получилось',
        StartOutcome.partly => 'Частично',
        StartOutcome.no => 'Нет, соперник навязал начало',
      };
}

enum BoutInterference {
  none,
  overactivation,
  lowEnergy,
  strongOpponent,
  error,
  score,
  coachNoise,
  waiting,
}

extension BoutInterferenceLabel on BoutInterference {
  String get label => switch (this) {
        BoutInterference.none => 'Ничего серьёзно не выбило',
        BoutInterference.overactivation => 'Зажался и потратил силы',
        BoutInterference.lowEnergy => 'Не хватило энергии',
        BoutInterference.strongOpponent => 'Слишком следил за соперником',
        BoutInterference.error => 'Остановился после ошибки',
        BoutInterference.score => 'Начал бороться со счётом',
        BoutInterference.coachNoise => 'Потерялся в командах и шуме',
        BoutInterference.waiting => 'Долгое ожидание сбило настрой',
      };
}

enum RecoveryOutcome { noError, returnedFast, returnedSlow, didNotReturn }

extension RecoveryOutcomeLabel on RecoveryOutcome {
  String get label => switch (this) {
        RecoveryOutcome.noError => 'Сильной ошибки не было',
        RecoveryOutcome.returnedFast => 'Вернулся почти сразу',
        RecoveryOutcome.returnedSlow => 'Вернулся, но потерял время',
        RecoveryOutcome.didNotReturn => 'Так и не смог вернуться',
      };
}

enum HelpfulTool { cue, breath, movement, coach, plan, nothing }

extension HelpfulToolLabel on HelpfulTool {
  String get label => switch (this) {
        HelpfulTool.cue => 'Короткая команда',
        HelpfulTool.breath => 'Выдох и опора',
        HelpfulTool.movement => 'Начал двигаться',
        HelpfulTool.coach => 'Одна команда тренера',
        HelpfulTool.plan => 'Заранее выбранный план',
        HelpfulTool.nothing => 'Пока ничего не помогло',
      };
}

T? enumFromName<T extends Enum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

class UserProfile {
  const UserProfile({
    this.ageBand,
    this.sports = const <String>['BJJ'],
    this.practiceRuns = 0,
    this.preferredCue,
  });

  final int? ageBand;
  final List<String> sports;
  final int practiceRuns;
  final String? preferredCue;

  UserProfile copyWith({
    int? ageBand,
    List<String>? sports,
    int? practiceRuns,
    String? preferredCue,
  }) {
    return UserProfile(
      ageBand: ageBand ?? this.ageBand,
      sports: sports ?? this.sports,
      practiceRuns: practiceRuns ?? this.practiceRuns,
      preferredCue: preferredCue ?? this.preferredCue,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'ageBand': ageBand,
        'sports': sports,
        'practiceRuns': practiceRuns,
        'preferredCue': preferredCue,
      };

  factory UserProfile.fromMap(Map<String, Object?> map) {
    return UserProfile(
      ageBand: map['ageBand'] as int?,
      sports: (map['sports'] as List<Object?>? ?? const <Object?>['BJJ'])
          .whereType<String>()
          .toList(),
      practiceRuns: map['practiceRuns'] as int? ?? 0,
      preferredCue: map['preferredCue'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProfile.fromJson(String source) {
    return UserProfile.fromMap(
      jsonDecode(source) as Map<String, Object?>,
    );
  }
}

class BoutRecord {
  const BoutRecord({
    required this.id,
    required this.createdAt,
    required this.timing,
    required this.bodyState,
    required this.obstacle,
    required this.startTask,
    required this.cue,
    required this.practiceTitle,
    this.completedAt,
    this.startOutcome,
    this.interference,
    this.recoveryOutcome,
    this.helpfulTool,
    this.nextInsight,
  });

  final String id;
  final DateTime createdAt;
  final BoutTiming timing;
  final BodyState bodyState;
  final MentalObstacle obstacle;
  final StartTask startTask;
  final String cue;
  final String practiceTitle;
  final DateTime? completedAt;
  final StartOutcome? startOutcome;
  final BoutInterference? interference;
  final RecoveryOutcome? recoveryOutcome;
  final HelpfulTool? helpfulTool;
  final String? nextInsight;

  bool get isCompleted => completedAt != null;

  BoutRecord copyWith({
    DateTime? completedAt,
    StartOutcome? startOutcome,
    BoutInterference? interference,
    RecoveryOutcome? recoveryOutcome,
    HelpfulTool? helpfulTool,
    String? nextInsight,
  }) {
    return BoutRecord(
      id: id,
      createdAt: createdAt,
      timing: timing,
      bodyState: bodyState,
      obstacle: obstacle,
      startTask: startTask,
      cue: cue,
      practiceTitle: practiceTitle,
      completedAt: completedAt ?? this.completedAt,
      startOutcome: startOutcome ?? this.startOutcome,
      interference: interference ?? this.interference,
      recoveryOutcome: recoveryOutcome ?? this.recoveryOutcome,
      helpfulTool: helpfulTool ?? this.helpfulTool,
      nextInsight: nextInsight ?? this.nextInsight,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'timing': timing.name,
        'bodyState': bodyState.name,
        'obstacle': obstacle.name,
        'startTask': startTask.name,
        'cue': cue,
        'practiceTitle': practiceTitle,
        'completedAt': completedAt?.toIso8601String(),
        'startOutcome': startOutcome?.name,
        'interference': interference?.name,
        'recoveryOutcome': recoveryOutcome?.name,
        'helpfulTool': helpfulTool?.name,
        'nextInsight': nextInsight,
      };

  factory BoutRecord.fromMap(Map<String, Object?> map) {
    return BoutRecord(
      id: map['id']! as String,
      createdAt: DateTime.parse(map['createdAt']! as String),
      timing: enumFromName(BoutTiming.values, map['timing']) ??
          BoutTiming.fiveMinutes,
      bodyState: enumFromName(BodyState.values, map['bodyState']) ??
          BodyState.ready,
      obstacle: enumFromName(MentalObstacle.values, map['obstacle']) ??
          MentalObstacle.tooManyThoughts,
      startTask: enumFromName(StartTask.values, map['startTask']) ??
          StartTask.firstGrip,
      cue: map['cue'] as String? ?? 'Вижу. Вхожу. Делаю своё.',
      practiceTitle: map['practiceTitle'] as String? ?? 'Настройка',
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt']! as String),
      startOutcome: enumFromName(StartOutcome.values, map['startOutcome']),
      interference:
          enumFromName(BoutInterference.values, map['interference']),
      recoveryOutcome:
          enumFromName(RecoveryOutcome.values, map['recoveryOutcome']),
      helpfulTool: enumFromName(HelpfulTool.values, map['helpfulTool']),
      nextInsight: map['nextInsight'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory BoutRecord.fromJson(String source) {
    return BoutRecord.fromMap(
      jsonDecode(source) as Map<String, Object?>,
    );
  }
}

class PracticePlan {
  const PracticePlan({
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
    required this.steps,
    required this.cueOptions,
    required this.matTask,
    required this.personalReason,
  });

  final String title;
  final String subtitle;
  final int durationSeconds;
  final List<String> steps;
  final List<String> cueOptions;
  final String matTask;
  final String personalReason;

  String spokenText(String cue) => <String>[
        title,
        subtitle,
        ...steps,
        'Твоя короткая команда: $cue',
        'Задача на ковёр: $matTask',
      ].join('. ');
}

class SkillSummary {
  const SkillSummary({
    required this.title,
    required this.status,
    required this.evidence,
    required this.nextStep,
  });

  final String title;
  final String status;
  final String evidence;
  final String nextStep;
}

String formatBoutDate(DateTime date) {
  const months = <String>[
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];
  final local = date.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${months[local.month - 1]} · ${local.hour}:$minute';
}
