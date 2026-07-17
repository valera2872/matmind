part of 'app_flow.dart';

extension _FeedbackPages on _AppFlowState {
  Widget _postBout() {
    final target = _feedbackTarget!;
    return AppShell(
      back: _back,
      label: 'ПОСЛЕ СХВАТКИ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PageHeading(
            title: 'Что произошло на ковре?',
            subtitle:
                'Ты планировал: ${target.startTask.label.toLowerCase()}. Отметь факты без оценки себя.',
          ),
          const SectionTitle('Удалось выполнить начало?'),
          for (final outcome in StartOutcome.values)
            SelectTile(
              text: outcome.label,
              selected: _startOutcome == outcome,
              onTap: () => setState(() => _startOutcome = outcome),
            ),
          const SectionTitle('Что сильнее всего повлияло?'),
          for (final item in BoutInterference.values)
            SelectTile(
              text: item.label,
              selected: _interference == item,
              onTap: () => setState(() => _interference = item),
            ),
          const SectionTitle('Удалось вернуться после ошибки?'),
          for (final item in RecoveryOutcome.values)
            SelectTile(
              text: item.label,
              selected: _recoveryOutcome == item,
              onTap: () => setState(() => _recoveryOutcome = item),
            ),
          const SectionTitle('Что помогло лучше всего?'),
          for (final item in HelpfulTool.values)
            SelectTile(
              text: item.label,
              selected: _helpfulTool == item,
              onTap: () => setState(() => _helpfulTool = item),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Сохранить и подготовить следующий вывод',
            onPressed: _startOutcome != null &&
                    _interference != null &&
                    _recoveryOutcome != null &&
                    _helpfulTool != null
                ? _saveFeedback
                : null,
          ),
          const Notice(
            text:
                'Победа или поражение здесь не оцениваются. Технический разбор проводится позже с тренером.',
          ),
        ],
      ),
    );
  }

  Widget _nextInsight() {
    final record = _insightRecord!;
    return AppShell(
      back: _back,
      label: 'СЛЕДУЮЩАЯ НАСТРОЙКА',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Tag(text: 'СХВАТКА СОХРАНЕНА'),
          const SizedBox(height: 14),
          Text(
            'Что изменится в следующий раз',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          InfoPanel(
            icon: Icons.auto_awesome_outlined,
            title: 'Персональный вывод',
            text: record.nextInsight!,
            color: AppColors.tealSoft,
          ),
          InfoPanel(
            icon: Icons.bookmark_outline,
            title: 'Команда, которую ты использовал',
            text: record.cue,
            color: AppColors.sand,
          ),
          PrimaryButton(
            text: 'Вернуться на главный экран',
            onPressed: () => _show(AppPage.athleteHome),
          ),
          TextButton(
            onPressed: () {
              _detailRecord = record;
              _show(AppPage.boutDetail);
            },
            child: const Text('Открыть полную карточку схватки'),
          ),
        ],
      ),
    );
  }

  Widget _boutHistory() {
    return AppShell(
      back: _back,
      label: 'СХВАТКИ',
      bottomNavigation: AthleteNavigation(
        selected: 2,
        onSelected: _navigateAthlete,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'История настроек и схваток',
            subtitle:
                'Здесь хранится не победа или поражение, а задача, выполненное начало, помеха и вывод для следующего старта.',
          ),
          if (_bouts.isEmpty)
            const InfoPanel(
              icon: Icons.history,
              title: 'Пока нет карточек',
              text:
                  'Первая карточка появится после завершённой настройки перед схваткой.',
              color: AppColors.tealSoft,
            )
          else
            for (final record in _bouts)
              ActionCard(
                icon: record.isCompleted
                    ? Icons.check_circle_outline
                    : Icons.schedule,
                title: record.isCompleted
                    ? record.startTask.label
                    : 'Ожидает обратной связи',
                subtitle:
                    '${formatBoutDate(record.createdAt)} · ${record.cue}',
                color: record.isCompleted
                    ? AppColors.tealSoft
                    : AppColors.rose,
                onTap: () {
                  _detailRecord = record;
                  _show(AppPage.boutDetail);
                },
              ),
        ],
      ),
    );
  }

  Widget _boutDetail() {
    final record = _detailRecord!;
    return AppShell(
      back: _back,
      label: record.isCompleted ? 'КАРТОЧКА СХВАТКИ' : 'ПЛАН НА СХВАТКУ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            record.practiceTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(formatBoutDate(record.createdAt)),
          const SizedBox(height: 18),
          InfoPanel(
            icon: Icons.timer_outlined,
            title: 'До выхода',
            text: record.timing.label,
            color: AppColors.sand,
          ),
          InfoPanel(
            icon: Icons.adjust,
            title: 'Состояние и помеха',
            text: '${record.bodyState.label}. ${record.obstacle.label}.',
            color: AppColors.blueSoft,
          ),
          InfoPanel(
            icon: Icons.sports_martial_arts,
            title: 'Задача на начало',
            text: record.startTask.label,
            color: AppColors.tealSoft,
          ),
          InfoPanel(
            icon: Icons.record_voice_over_outlined,
            title: 'Короткая команда',
            text: record.cue,
            color: AppColors.lavender,
          ),
          if (record.isCompleted) ...<Widget>[
            InfoPanel(
              icon: Icons.flag_outlined,
              title: 'Что произошло',
              text:
                  'Начало: ${record.startOutcome!.label}. Помеха: ${record.interference!.label}. Возврат: ${record.recoveryOutcome!.label}.',
              color: AppColors.rose,
            ),
            InfoPanel(
              icon: Icons.auto_awesome_outlined,
              title: 'Вывод для следующей настройки',
              text: record.nextInsight!,
              color: AppColors.tealSoft,
            ),
          ] else
            PrimaryButton(
              text: 'Схватка закончилась — оставить обратную связь',
              onPressed: () => _openFeedback(record),
            ),
        ],
      ),
    );
  }

  Widget _profilePage() {
    final skills = PersonalizationEngine.buildSkillProfile(_bouts);
    return AppShell(
      back: _back,
      label: 'ПРОФИЛЬ НАВЫКОВ',
      bottomNavigation: AthleteNavigation(
        selected: 3,
        onSelected: _navigateAthlete,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Что становится доступнее на ковре',
            subtitle:
                'Здесь нет рейтинга «ментальной силы». Статусы показывают только опыт применения конкретных навыков.',
          ),
          for (final skill in skills)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD9E1E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    skill.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Tag(text: skill.status.toUpperCase()),
                  const SizedBox(height: 10),
                  Text(skill.evidence),
                  const SizedBox(height: 8),
                  Text(
                    'Следующий шаг: ${skill.nextStep}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          InfoPanel(
            icon: Icons.headphones_outlined,
            title: 'Настроек пройдено',
            text: '${_profile.practiceRuns}',
            color: AppColors.blueSoft,
          ),
          InfoPanel(
            icon: Icons.sports_martial_arts,
            title: 'Виды борьбы',
            text: _profile.sports.join(', '),
            color: AppColors.sand,
          ),
        ],
      ),
    );
  }
}
