import 'package:flutter/material.dart';

import 'theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.back,
    this.label,
    this.bottomNavigation,
  });

  final Widget child;
  final VoidCallback? back;
  final String? label;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigation,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  if (back != null)
                    TextButton.icon(
                      onPressed: back,
                      icon: const Icon(Icons.arrow_back, size: 19),
                      label: const Text('Назад'),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Своя борьба',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (label != null)
                    Text(
                      label!,
                      style: const TextStyle(
                        color: AppColors.muted,
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
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.ink),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              trailing ??
                  const Padding(
                    padding: EdgeInsets.only(top: 9),
                    child: Icon(Icons.chevron_right, color: AppColors.muted),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectTile extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String text;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      color: selected ? AppColors.ink : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      text,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: selected ? Colors.white70 : AppColors.muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Notice extends StatelessWidget {
  const Notice({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD9E1E1)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class AthleteNavigation extends StatelessWidget {
  const AthleteNavigation({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: onSelected,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Сейчас',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Навыки',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Схватки',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
    );
  }
}

class TournamentChoiceCard extends StatelessWidget {
  const TournamentChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.surface,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 108),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 30, color: AppColors.ink),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
