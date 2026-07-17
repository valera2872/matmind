import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'models.dart';
import 'personalization.dart';
import 'practice_screen.dart';
import 'pressure_lab.dart';
import 'repository.dart';
import 'theme.dart';

part 'app_pages_core.dart';
part 'app_pages_feedback.dart';
part 'app_pages_training.dart';

enum AppPage {
  loading,
  welcome,
  age,
  sport,
  athleteHome,
  quickBody,
  quickObstacle,
  timing,
  setup,
  planPreview,
  practice,
  practiceComplete,
  postBout,
  nextInsight,
  strongOpponent,
  trainingLibrary,
  trainingDetail,
  pressureLab,
  boutHistory,
  boutDetail,
  profile,
  parentHome,
}

class AppFlow extends StatefulWidget {
  const AppFlow({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  AppPage _page = AppPage.loading;
  UserProfile _profile = const UserProfile();
  List<BoutRecord> _bouts = <BoutRecord>[];

  BoutTiming? _timing;
  BodyState? _bodyState;
  MentalObstacle? _obstacle;
  StartTask? _startTask;
  PracticePlan? _plan;
  String? _selectedCue;
  bool _quickMode = false;

  BoutRecord? _feedbackTarget;
  StartOutcome? _startOutcome;
  BoutInterference? _interference;
  RecoveryOutcome? _recoveryOutcome;
  HelpfulTool? _helpfulTool;
  BoutRecord? _insightRecord;
  BoutRecord? _detailRecord;

  String _trainingTitle = '';
  List<String> _trainingSteps = const <String>[];

  final Set<String> _sportsDraft = <String>{'BJJ'};
  int? _ageDraft;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await widget.repository.loadProfile();
    final bouts = await widget.repository.loadBouts();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _bouts = bouts;
      _ageDraft = profile.ageBand;
      _sportsDraft
        ..clear()
        ..addAll(profile.sports.isEmpty ? const <String>['BJJ'] : profile.sports);
      _page = AppPage.welcome;
    });
  }

  Future<void> _saveProfile(UserProfile profile) async {
    _profile = profile;
    await widget.repository.saveProfile(profile);
    if (mounted) setState(() {});
  }

  Future<void> _saveBouts() async {
    _bouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await widget.repository.saveBouts(_bouts);
    if (mounted) setState(() {});
  }

  void _show(AppPage page) {
    setState(() => _page = page);
  }

  void _back() {
    switch (_page) {
      case AppPage.loading:
      case AppPage.welcome:
        break;
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
      case AppPage.quickBody:
      case AppPage.timing:
      case AppPage.strongOpponent:
      case AppPage.trainingLibrary:
      case AppPage.boutHistory:
      case AppPage.profile:
        _show(AppPage.athleteHome);
        break;
      case AppPage.quickObstacle:
        _show(AppPage.quickBody);
        break;
      case AppPage.setup:
        _show(AppPage.timing);
        break;
      case AppPage.planPreview:
        _show(AppPage.setup);
        break;
      case AppPage.practice:
        _show(_quickMode ? AppPage.athleteHome : AppPage.planPreview);
        break;
      case AppPage.practiceComplete:
      case AppPage.postBout:
      case AppPage.nextInsight:
        _show(AppPage.athleteHome);
        break;
      case AppPage.trainingDetail:
      case AppPage.pressureLab:
        _show(AppPage.trainingLibrary);
        break;
      case AppPage.boutDetail:
        _show(AppPage.boutHistory);
        break;
    }
  }

  BoutRecord? get _pendingBout {
    for (final record in _bouts) {
      if (!record.isCompleted) return record;
    }
    return null;
  }

  List<BoutRecord> get _completedBouts =>
      _bouts.where((record) => record.isCompleted).toList(growable: false);

  BoutRecord? get _lastSuccessfulBout {
    for (final record in _completedBouts) {
      if (record.startOutcome == StartOutcome.yes &&
          record.helpfulTool != HelpfulTool.nothing) {
        return record;
      }
    }
    return null;
  }

  void _startBoutFlow() {
    setState(() {
      _timing = null;
      _bodyState = null;
      _obstacle = null;
      _startTask = null;
      _plan = null;
      _selectedCue = null;
      _quickMode = false;
      _page = AppPage.timing;
    });
  }

  void _startQuickFlow() {
    setState(() {
      _timing = BoutTiming.fiveMinutes;
      _bodyState = null;
      _obstacle = null;
      _startTask = null;
      _plan = null;
      _selectedCue = null;
      _quickMode = true;
      _page = AppPage.quickBody;
    });
  }

  StartTask _suggestQuickTask(MentalObstacle obstacle) {
    final successful = _lastSuccessfulBout;
    if (successful != null &&
        successful.obstacle == obstacle &&
        successful.startOutcome == StartOutcome.yes) {
      return successful.startTask;
    }
    return switch (obstacle) {
      MentalObstacle.tooManyThoughts => StartTask.firstGrip,
      MentalObstacle.strongOpponent => StartTask.ownDistance,
      MentalObstacle.fearOfError => StartTask.continueAfterSurprise,
      MentalObstacle.resultPressure => StartTask.startFirst,
      MentalObstacle.longWaiting => StartTask.startFirst,
    };
  }

  void _launchQuickPractice(MentalObstacle obstacle) {
    final body = _bodyState;
    if (body == null) return;
    final task = _suggestQuickTask(obstacle);
    final plan = PersonalizationEngine.buildQuickPlan(
      profile: _profile,
      bodyState: body,
      obstacle: obstacle,
      startTask: task,
      history: _bouts,
    );
    setState(() {
      _timing = BoutTiming.fiveMinutes;
      _obstacle = obstacle;
      _startTask = task;
      _plan = plan;
      _selectedCue = _profile.preferredCue != null &&
              plan.cueOptions.contains(_profile.preferredCue)
          ? _profile.preferredCue
          : plan.cueOptions.first;
      _quickMode = true;
      _page = AppPage.practice;
    });
  }

  void _repeatSuccessfulPractice(BoutRecord record) {
    final plan = PersonalizationEngine.buildQuickPlan(
      profile: _profile,
      bodyState: record.bodyState,
      obstacle: record.obstacle,
      startTask: record.startTask,
      history: _bouts,
    );
    setState(() {
      _timing = BoutTiming.fiveMinutes;
      _bodyState = record.bodyState;
      _obstacle = record.obstacle;
      _startTask = record.startTask;
      _plan = plan;
      _selectedCue = plan.cueOptions.contains(record.cue)
          ? record.cue
          : plan.cueOptions.first;
      _quickMode = true;
      _page = AppPage.practice;
    });
  }

  void _preparePlan() {
    final timing = _timing;
    final body = _bodyState;
    final obstacle = _obstacle;
    final task = _startTask;
    if (timing == null || body == null || obstacle == null || task == null) {
      return;
    }
    final plan = PersonalizationEngine.buildPlan(
      profile: _profile,
      timing: timing,
      bodyState: body,
      obstacle: obstacle,
      startTask: task,
      history: _bouts,
    );
    setState(() {
      _quickMode = false;
      _plan = plan;
      _selectedCue = _profile.preferredCue != null &&
              plan.cueOptions.contains(_profile.preferredCue)
          ? _profile.preferredCue
          : plan.cueOptions.first;
      _page = AppPage.planPreview;
    });
  }

  Future<void> _completePractice() async {
    final plan = _plan!;
    final record = BoutRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      timing: _timing!,
      bodyState: _bodyState!,
      obstacle: _obstacle!,
      startTask: _startTask!,
      cue: _selectedCue!,
      practiceTitle: plan.title,
    );
    _bouts.insert(0, record);
    final updatedProfile = _profile.copyWith(
      practiceRuns: _profile.practiceRuns + 1,
      preferredCue: _selectedCue,
    );
    await widget.repository.saveBouts(_bouts);
    await widget.repository.saveProfile(updatedProfile);
    if (!mounted) return;
    setState(() {
      _profile = updatedProfile;
      _page = AppPage.practiceComplete;
    });
  }

  void _openFeedback([BoutRecord? target]) {
    final record = target ?? _pendingBout;
    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Сначала пройди настройку перед схваткой — появится карточка для обратной связи.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _feedbackTarget = record;
      _startOutcome = null;
      _interference = null;
      _recoveryOutcome = null;
      _helpfulTool = null;
      _page = AppPage.postBout;
    });
  }

  Future<void> _saveFeedback() async {
    final target = _feedbackTarget;
    if (target == null ||
        _startOutcome == null ||
        _interference == null ||
        _recoveryOutcome == null ||
        _helpfulTool == null) {
      return;
    }
    var updated = target.copyWith(
      completedAt: DateTime.now(),
      startOutcome: _startOutcome,
      interference: _interference,
      recoveryOutcome: _recoveryOutcome,
      helpfulTool: _helpfulTool,
    );
    updated = updated.copyWith(
      nextInsight: PersonalizationEngine.buildNextInsight(updated),
    );
    final index = _bouts.indexWhere((record) => record.id == target.id);
    if (index >= 0) {
      _bouts[index] = updated;
    } else {
      _bouts.insert(0, updated);
    }
    await _saveBouts();
    if (!mounted) return;
    setState(() {
      _insightRecord = updated;
      _page = AppPage.nextInsight;
    });
  }

  void _navigateAthlete(int index) {
    if (index == 0) {
      _show(AppPage.athleteHome);
    } else if (index == 1) {
      _show(AppPage.trainingLibrary);
    } else if (index == 2) {
      _show(AppPage.boutHistory);
    } else {
      _show(AppPage.profile);
    }
  }

  void _openTraining(String title, List<String> steps) {
    setState(() {
      _trainingTitle = title;
      _trainingSteps = steps;
      _page = AppPage.trainingDetail;
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
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(
          key: ValueKey<AppPage>(_page),
          child: _buildPage(),
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case AppPage.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AppPage.welcome:
        return _welcome();
      case AppPage.age:
        return _age();
      case AppPage.sport:
        return _sport();
      case AppPage.athleteHome:
        return _athleteHome();
      case AppPage.quickBody:
        return _quickBodyPage();
      case AppPage.quickObstacle:
        return _quickObstaclePage();
      case AppPage.timing:
        return _timingPage();
      case AppPage.setup:
        return _setupPage();
      case AppPage.planPreview:
        return _planPreview();
      case AppPage.practice:
        return PracticeScreen(
          plan: _plan!,
          cue: _selectedCue!,
          ageBand: _profile.ageBand ?? 13,
          isQuickMode: _quickMode,
          onComplete: _completePractice,
          onClose: () => _show(
            _quickMode ? AppPage.athleteHome : AppPage.planPreview,
          ),
        );
      case AppPage.practiceComplete:
        return _practiceComplete();
      case AppPage.postBout:
        return _postBout();
      case AppPage.nextInsight:
        return _nextInsight();
      case AppPage.strongOpponent:
        return _strongOpponent();
      case AppPage.trainingLibrary:
        return _trainingLibrary();
      case AppPage.trainingDetail:
        return _trainingDetail();
      case AppPage.pressureLab:
        return PressureLabScreen(onBack: _back);
      case AppPage.boutHistory:
        return _boutHistory();
      case AppPage.boutDetail:
        return _boutDetail();
      case AppPage.profile:
        return _profilePage();
      case AppPage.parentHome:
        return _parentHome();
    }
  }
}
