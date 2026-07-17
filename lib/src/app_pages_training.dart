part of 'app_flow.dart';

extension _TrainingPages on _AppFlowState {
  Widget _strongOpponent() {
    return AppShell(
      back: _back,
      label: 'СИЛЬНЫЙ СОПЕРНИК',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Не выигрывай и не проигрывай ему заранее',
            subtitle:
                'Пояс, клуб, внешний вид и прошлые победы могут быть фактами. Вывод «у меня нет шансов» — это прогноз.',
          ),
          const InfoPanel(
            icon: Icons.fact_check_outlined,
            title: 'Отдели факт от прогноза',
            text:
                'Факт: соперник опытный или выглядит уверенно. Прогноз: «я точно проиграю». Прогноз не сообщает, что произойдёт в этой схватке.',
            color: AppColors.sand,
          ),
          const InfoPanel(
            icon: Icons.shuffle,
            title: 'Стань неудобным',
            text:
                'Не отдавай привычный ритм. Меняй темп, направление и момент входа в пределах тех действий, которые ты умеешь.',
            color: AppColors.tealSoft,
          ),
          const InfoPanel(
            icon: Icons.route_outlined,
            title: 'Навяжи свою борьбу',
            text:
                'Первым ищи свою дистанцию, свой захват и своё давление. Не жди, пока фаворит полностью построит удобную ему схватку.',
            color: AppColors.blueSoft,
          ),
          const InfoPanel(
            icon: Icons.timer_outlined,
            title: 'Первые десять секунд',
            text:
                'Безопасная шея → устойчивая стойка → первый контакт → продолжить после первой неожиданности.',
            color: AppColors.rose,
          ),
          PrimaryButton(
            text: 'Собрать настройку против сильного соперника',
            onPressed: () {
              _startBoutFlow();
              setState(() => _obstacle = MentalObstacle.strongOpponent);
            },
          ),
        ],
      ),
    );
  }

  Widget _trainingLibrary() {
    return AppShell(
      back: _back,
      label: 'НАВЫКИ',
      bottomNavigation: AthleteNavigation(
        selected: 1,
        onSelected: _navigateAthlete,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Тренировать заранее',
            subtitle:
                'Эти упражнения полезнее проходить дома или на обычной тренировке, а не впервые за пять минут до выхода.',
          ),
          ActionCard(
            icon: Icons.replay,
            title: 'Reset после ошибки',
            subtitle: 'Факт → тело → одно действие',
            color: AppColors.blueSoft,
            onTap: () => _openTraining(
              'Reset после ошибки',
              const <String>[
                'Партнёр создаёт условную ошибку или неудобную позицию.',
                'Ты называешь только факт: «ошибка была».',
                'Возвращаешь положение головы, опору и свободные плечи.',
                'За две секунды выбираешь одно действие и продолжаешь.',
                'Повтори три раза, затем проверь в свободном раунде.',
              ],
            ),
          ),
          ActionCard(
            icon: Icons.hourglass_bottom,
            title: 'Долгое ожидание',
            subtitle: 'Не держать схватку в голове весь турнир',
            color: AppColors.sand,
            onTap: () => _openTraining(
              'Тренировка ожидания',
              const <String>[
                'Один раз проверь время вызова и экипировку.',
                'Сформулируй одно начало и перестань репетировать его постоянно.',
                'Переключись на разговор, спокойную ходьбу или музыку.',
                'За пятнадцать минут до выхода вернись к короткой настройке.',
              ],
            ),
          ),
          ActionCard(
            icon: Icons.hearing_outlined,
            title: 'Одна команда среди шума',
            subtitle: 'Сузить внимание и не удерживать всё сразу',
            color: AppColors.tealSoft,
            onTap: () => _openTraining(
              'Одна команда',
              const <String>[
                'Попроси тренера выбрать одну короткую команду на раунд.',
                'Во время шума замечай только заранее определённый сигнал.',
                'После сигнала выполняй одно действие, а не полный технический план.',
                'После раунда отметь, услышал ли ты команду и что сделал.',
              ],
            ),
          ),
          ActionCard(
            icon: Icons.visibility_outlined,
            title: 'Сильный соперник',
            subtitle: 'Стать неудобным и первым задать знакомую задачу',
            color: AppColors.rose,
            onTap: () => _show(AppPage.strongOpponent),
          ),
          ActionCard(
            icon: Icons.psychology_outlined,
            title: 'Решения под давлением',
            subtitle: 'Три ситуации на время',
            color: AppColors.lavender,
            onTap: () => _show(AppPage.pressureLab),
          ),
        ],
      ),
    );
  }

  Widget _trainingDetail() {
    return AppShell(
      back: _back,
      label: 'ТРЕНИРОВКА НАВЫКА',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _trainingTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'Цель — повторить алгоритм несколько раз в безопасной тренировочной ситуации, чтобы он был доступнее под давлением.',
          ),
          const SizedBox(height: 20),
          for (var index = 0; index < _trainingSteps.length; index += 1)
            InfoPanel(
              icon: Icons.check_circle_outline,
              title: 'Шаг ${index + 1}',
              text: _trainingSteps[index],
              color: index.isEven ? AppColors.tealSoft : AppColors.sand,
            ),
          const Notice(
            text:
                'Это психологическая тренировка, а не техническое указание. Конкретные приёмы и допустимые действия определяет тренер.',
          ),
        ],
      ),
    );
  }

  Widget _parentHome() {
    return AppShell(
      back: _back,
      label: 'РОДИТЕЛЬ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageHeading(
            title: 'Помочь ребёнку, не добавляя давления',
            subtitle:
                'Сначала контакт и восстановление. Технический разбор, выводы и мотивационные речи — позже.',
          ),
          const InfoPanel(
            icon: Icons.favorite_outline,
            title: 'После поражения',
            text:
                '«Я рядом. Сейчас не обязательно ничего объяснять. Тебе нужна тишина, вода, объятие или чтобы я просто посидел рядом?»',
            color: AppColors.rose,
          ),
          const InfoPanel(
            icon: Icons.emoji_events_outlined,
            title: 'После победы',
            text:
                'Не превращайте победу в обязанность повторять результат. Спросите, какое действие ребёнок считает своим лучшим решением.',
            color: AppColors.tealSoft,
          ),
          const InfoPanel(
            icon: Icons.timer_outlined,
            title: 'Перед выходом',
            text:
                'Не проверяйте каждые две минуты, волнуется ли ребёнок. Помогите уточнить время, экипировку и одну задачу на начало.',
            color: AppColors.blueSoft,
          ),
          const InfoPanel(
            icon: Icons.block_outlined,
            title: 'Чего не говорить в первые минуты',
            text:
                '«Ты сам всё отдал», «я же говорил», «не плачь», «мы столько ради тебя сделали», «соберись».',
            color: AppColors.sand,
          ),
          const Notice(
            text:
                'При боли, травме, угрозах, унижении, самоповреждении или опасной сгонке веса мотивационная практика прекращается. Нужна помощь взрослого и профильного специалиста.',
          ),
        ],
      ),
    );
  }
}
