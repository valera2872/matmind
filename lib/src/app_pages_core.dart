part of 'app_flow.dart';

extension _CorePages on _AppFlowState {
  Widget _welcome() {
    return AppShell(
      label: 'АЛЬФА 0.8.0',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 26),
          const Tag(text: 'ДЛЯ ЮНЫХ БОРЦОВ И ИХ РОДИТЕЛЕЙ'),
          const SizedBox(height: 16),
          Text(
            'Помогает собраться перед схваткой — и учится на том, что произошло после неё',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'Каждая настройка создаёт одну задачу на ковёр. После схватки короткая отметка делает следующую практику точнее.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          ActionCard(
            icon: Icons.sports_martial_arts,
            title: 'Я спортсмен',
            subtitle:
                'Настройка перед схваткой, reset после ошибки и личная история навыков',
            color: AppColors.tealSoft,
            onTap: () => _show(
              _profile.ageBand == null ? AppPage.age : AppPage.athleteHome,
            ),
          ),
          ActionCard(
            icon: Icons.handshake_outlined,
            title: 'Я родитель',
            subtitle:
                'Как поддержать ребёнка без давления до и после результата',
            color: AppColors.sand,
            onTap: () => _show(AppPage.parentHome),
          ),
          const Notice(
            text:
                'Приложение не обещает победу и не оценивает характер. Оно помогает сохранить доступ к тому, что спортсмен уже умеет.',
          ),
        ],
      ),
    );
  }

  Widget _age() {
    return AppShell(
      back: _back,
      label: '1 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Сколько тебе лет?',
            subtitle:
                'Возраст нужен, чтобы инструкции звучали понятно. Точная дата рождения не сохраняется.',
          ),
          for (final entry in const <int, String>{
            10: '10–12 лет',
            13: '13–15 лет',
            16: '16–17 лет',
          }.entries)
            SelectTile(
              text: entry.value,
              selected: _ageDraft == entry.key,
              onTap: () => setState(() => _ageDraft = entry.key),
            ),
          const SizedBox(height: 10),
          PrimaryButton(
            text: 'Продолжить',
            onPressed: _ageDraft == null ? null : () => _show(AppPage.sport),
          ),
        ],
      ),
    );
  }

  Widget _sport() {
    const sports = <String>[
      'BJJ',
      'Грэпплинг',
      'Дзюдо',
      'Самбо',
      'Вольная борьба',
      'Греко-римская',
    ];
    return AppShell(
      back: _back,
      label: '2 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Какая у тебя борьба?',
            subtitle:
                'Можно выбрать несколько вариантов. Они меняют примеры действий и язык практик.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final sport in sports)
                FilterChip(
                  label: Text(sport),
                  selected: _sportsDraft.contains(sport),
                  selectedColor: AppColors.ink,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _sportsDraft.contains(sport)
                        ? Colors.white
                        : AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) {
                    setState(() {
                      if (_sportsDraft.contains(sport)) {
                        if (_sportsDraft.length > 1) {
                          _sportsDraft.remove(sport);
                        }
                      } else {
                        _sportsDraft.add(sport);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Открыть приложение',
            onPressed: () async {
              await _saveProfile(
                _profile.copyWith(
                  ageBand: _ageDraft,
                  sports: _sportsDraft.toList(),
                ),
              );
              if (mounted) _show(AppPage.athleteHome);
            },
          ),
        ],
      ),
    );
  }

  Widget _athleteHome() {
    final pending = _pendingBout;
    final latestCompleted =
        _completedBouts.isEmpty ? null : _completedBouts.first;
    final successful = _lastSuccessfulBout;

    return AppShell(
      label: 'ТУРНИРНЫЙ ЭКРАН',
      bottomNavigation: AthleteNavigation(
        selected: 0,
        onSelected: _navigateAthlete,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Что нужно прямо сейчас?',
            subtitle:
                'Главное действие вынесено наверх. Быстрый режим запускает персональную голосовую настройку за три нажатия.',
          ),
          if (pending != null)
            TournamentChoiceCard(
              icon: Icons.flag_outlined,
              title: 'Схватка закончилась?',
              subtitle:
                  'Отметь, что произошло, чтобы следующая настройка стала точнее.',
              color: AppColors.rose,
              onTap: () => _openFeedback(pending),
            ),
          TournamentChoiceCard(
            icon: Icons.bolt,
            title: 'Помочь за 20 секунд',
            subtitle:
                'Два коротких выбора — затем голосовая практика начнётся сама.',
            color: AppColors.tealSoft,
            onTap: _startQuickFlow,
          ),
          if (successful != null)
            TournamentChoiceCard(
              icon: Icons.replay_circle_filled,
              title: 'Повторить удачную настройку',
              subtitle:
                  'Сразу запустить протокол, после которого начало получилось.',
              color: AppColors.blueSoft,
              onTap: () => _repeatSuccessfulPractice(successful),
            ),
          ActionCard(
            icon: Icons.tune,
            title: 'Сейчас всё по-другому',
            subtitle:
                'Полная настройка: время, состояние, помеха, задача и короткая команда',
            color: AppColors.surface,
            onTap: _startBoutFlow,
          ),
          const SectionTitle('Другие ситуации'),
          ActionCard(
            icon: Icons.visibility_outlined,
            title: 'Соперник кажется сильнее',
            subtitle:
                'Отделить факты от прогноза, стать неудобным и навязать свою борьбу',
            color: AppColors.sand,
            onTap: () => _show(AppPage.strongOpponent),
          ),
          ActionCard(
            icon: Icons.replay_outlined,
            title: 'Меня выбило после ошибки',
            subtitle:
                'Короткий reset: факт → положение тела → следующее действие',
            color: AppColors.blueSoft,
            onTap: () => _openTraining(
              'Reset после ошибки',
              const <String>[
                'Назови без оценки: «ошибка была».',
                'Верни подбородок, опору и свободные плечи.',
                'Выбери один глагол на две секунды: защитить, встать, вернуть, продолжить.',
                'Потренируй reset три раза в обычном раунде после условной ошибки.',
              ],
            ),
          ),
          const SectionTitle('Тренировать заранее'),
          ActionCard(
            icon: Icons.psychology_outlined,
            title: 'Решения под давлением',
            subtitle:
                'Три борцовские ситуации с ограничением времени и объяснением',
            color: AppColors.lavender,
            onTap: () => _show(AppPage.pressureLab),
          ),
          ActionCard(
            icon: Icons.fitness_center_outlined,
            title: 'Библиотека навыков',
            subtitle:
                'Начало, reset, ожидание, сильный соперник и внимание к одной команде',
            color: AppColors.blueSoft,
            onTap: () => _show(AppPage.trainingLibrary),
          ),
          if (latestCompleted?.nextInsight != null)
            Notice(text: 'Последний вывод: ${latestCompleted!.nextInsight}'),
        ],
      ),
    );
  }

  Widget _quickBodyPage() {
    return AppShell(
      back: _back,
      label: 'БЫСТРЫЙ СТАРТ · 1 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Tag(text: 'МЕНЬШЕ 15 МИНУТ ДО ВЫХОДА'),
          const SizedBox(height: 14),
          const PageHeading(
            title: 'Как ты сейчас чувствуешь себя в теле?',
            subtitle:
                'Нажми один вариант. Не нужно долго проверять себя — выбери ближайшее описание.',
          ),
          TournamentChoiceCard(
            icon: Icons.flash_on,
            title: BodyState.overactivated.label,
            subtitle: 'Слишком много напряжения, суеты или лишней энергии',
            color: AppColors.rose,
            onTap: () {
              setState(() {
                _bodyState = BodyState.overactivated;
                _page = AppPage.quickObstacle;
              });
            },
          ),
          TournamentChoiceCard(
            icon: Icons.adjust,
            title: BodyState.ready.label,
            subtitle: 'Состояние рабочее — его не нужно исправлять',
            color: AppColors.tealSoft,
            onTap: () {
              setState(() {
                _bodyState = BodyState.ready;
                _page = AppPage.quickObstacle;
              });
            },
          ),
          TournamentChoiceCard(
            icon: Icons.battery_std,
            title: BodyState.lowEnergy.label,
            subtitle: 'Мало энергии, тяжело включиться и начать движение',
            color: AppColors.blueSoft,
            onTap: () {
              setState(() {
                _bodyState = BodyState.lowEnergy;
                _page = AppPage.quickObstacle;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _quickObstaclePage() {
    return AppShell(
      back: _back,
      label: 'БЫСТРЫЙ СТАРТ · 2 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Что сильнее всего мешает?',
            subtitle:
                'После нажатия приложение само выберет задачу и сразу запустит голосовую настройку.',
          ),
          TournamentChoiceCard(
            icon: Icons.blur_on,
            title: MentalObstacle.tooManyThoughts.label,
            subtitle: 'В голове слишком много вариантов и команд',
            onTap: () => _launchQuickPractice(
              MentalObstacle.tooManyThoughts,
            ),
          ),
          TournamentChoiceCard(
            icon: Icons.visibility_outlined,
            title: MentalObstacle.strongOpponent.label,
            subtitle: 'Слишком много внимания ушло на его силу и репутацию',
            color: AppColors.sand,
            onTap: () => _launchQuickPractice(
              MentalObstacle.strongOpponent,
            ),
          ),
          TournamentChoiceCard(
            icon: Icons.warning_amber,
            title: MentalObstacle.fearOfError.label,
            subtitle: 'Хочется начать идеально и не допустить ошибку',
            color: AppColors.rose,
            onTap: () => _launchQuickPractice(
              MentalObstacle.fearOfError,
            ),
          ),
          TournamentChoiceCard(
            icon: Icons.emoji_events_outlined,
            title: MentalObstacle.resultPressure.label,
            subtitle: 'Мысли всё время возвращаются к победе или поражению',
            color: AppColors.lavender,
            onTap: () => _launchQuickPractice(
              MentalObstacle.resultPressure,
            ),
          ),
          TournamentChoiceCard(
            icon: Icons.hourglass_bottom,
            title: MentalObstacle.longWaiting.label,
            subtitle: 'Вызов задержался, и прежний настрой уже пропал',
            color: AppColors.blueSoft,
            onTap: () => _launchQuickPractice(
              MentalObstacle.longWaiting,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timingPage() {
    return AppShell(
      back: _back,
      label: 'ШАГ 1 ИЗ 2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Сколько времени до схватки?',
            subtitle:
                'За пять минут нужна короткая настройка. За час полезнее подготовить план и перестать бороться в голове заранее.',
          ),
          _timingTile(
            BoutTiming.fiveMinutes,
            'Вернуть тело, сузить внимание и выбрать одно действие',
          ),
          _timingTile(
            BoutTiming.fifteenMinutes,
            'Отрегулировать состояние и собрать простой план',
          ),
          _timingTile(
            BoutTiming.thirtyToSixty,
            'Короткая мысленная репетиция и переключение',
          ),
          _timingTile(
            BoutTiming.moreThanHour,
            'Подготовить начало, проверить организацию и сохранить силы',
          ),
        ],
      ),
    );
  }

  Widget _timingTile(BoutTiming timing, String subtitle) {
    return SelectTile(
      text: timing.label,
      subtitle: subtitle,
      selected: _timing == timing,
      onTap: () {
        setState(() {
          _timing = timing;
          _page = AppPage.setup;
        });
      },
    );
  }

  Widget _setupPage() {
    return AppShell(
      back: _back,
      label: 'ШАГ 2 ИЗ 2 · ${_timing!.shortLabel}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Соберём настройку под тебя',
            subtitle:
                'Выбери по одному варианту в трёх разделах. Здесь нет правильных или неправильных состояний.',
          ),
          const SectionTitle('Как ты чувствуешь себя в теле?'),
          for (final state in BodyState.values)
            SelectTile(
              text: state.label,
              selected: _bodyState == state,
              onTap: () => setState(() => _bodyState = state),
            ),
          const SectionTitle('Что сильнее всего мешает?'),
          for (final obstacle in MentalObstacle.values)
            SelectTile(
              text: obstacle.label,
              selected: _obstacle == obstacle,
              onTap: () => setState(() => _obstacle = obstacle),
            ),
          const SectionTitle('Что ты хочешь сделать в начале?'),
          for (final task in StartTask.values)
            SelectTile(
              text: task.label,
              selected: _startTask == task,
              onTap: () => setState(() => _startTask = task),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Подобрать персональную настройку',
            onPressed:
                _bodyState != null && _obstacle != null && _startTask != null
                    ? _preparePlan
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _planPreview() {
    final plan = _plan!;
    return AppShell(
      back: _back,
      label: 'ТВОЙ ПЛАН',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Tag(text: _timing!.shortLabel),
          const SizedBox(height: 14),
          Text(plan.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(plan.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          InfoPanel(
            icon: Icons.tune,
            title: 'Почему выбран этот вариант',
            text: plan.personalReason,
            color: AppColors.tealSoft,
          ),
          const SectionTitle('Выбери короткую команду'),
          for (final cue in plan.cueOptions)
            SelectTile(
              text: cue,
              selected: _selectedCue == cue,
              onTap: () => setState(() => _selectedCue = cue),
            ),
          InfoPanel(
            icon: Icons.sports_martial_arts,
            title: 'Одна задача на ковёр',
            text: plan.matTask,
            color: AppColors.sand,
          ),
          PrimaryButton(
            text: 'Начать голосовую настройку',
            onPressed: _selectedCue == null
                ? null
                : () => _show(AppPage.practice),
          ),
          const Notice(
            text:
                'После завершения появится карточка этой схватки. Обратная связь после результата изменит следующую практику.',
          ),
        ],
      ),
    );
  }

  Widget _practiceComplete() {
    return AppShell(
      back: _back,
      label: 'НАСТРОЙКА ГОТОВА',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Tag(text: 'ТЕЛЕФОН МОЖНО УБРАТЬ'),
          const SizedBox(height: 14),
          Text(
            _selectedCue!,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          InfoPanel(
            icon: Icons.sports_martial_arts,
            title: 'Твоя задача',
            text: _plan!.matTask,
            color: AppColors.tealSoft,
          ),
          const InfoPanel(
            icon: Icons.flag_outlined,
            title: 'После схватки',
            text:
                'Вернись и ответь на четыре коротких вопроса. Следующая настройка учтёт не результат, а то, что реально произошло.',
            color: AppColors.rose,
          ),
          PrimaryButton(
            text: 'Я готов',
            onPressed: () => _show(AppPage.athleteHome),
          ),
        ],
      ),
    );
  }
}
