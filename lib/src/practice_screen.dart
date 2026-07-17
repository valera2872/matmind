import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'models.dart';
import 'theme.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.plan,
    required this.cue,
    required this.ageBand,
    required this.onComplete,
    required this.onClose,
    this.isQuickMode = false,
  });

  final PracticePlan plan;
  final String cue;
  final int ageBand;
  final VoidCallback onComplete;
  final VoidCallback onClose;
  final bool isQuickMode;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FlutterTts _tts = FlutterTts();
  Timer? _timer;
  int _elapsed = 0;
  bool _speaking = false;
  bool _timerRunning = false;
  String? _voiceError;

  @override
  void initState() {
    super.initState();
    _configureAndSpeak();
  }

  Future<void> _configureAndSpeak() async {
    try {
      await _tts.setLanguage('ru-RU');
      await _tts.setSpeechRate(widget.ageBand <= 10 ? 0.42 : 0.47);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _speaking = false);
      });
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (mounted) await _speak();
    } catch (_) {
      if (mounted) {
        setState(() {
          _voiceError =
              'Русский голос не запустился. Пройди практику по тексту и таймеру.';
        });
        _startTimer();
      }
    }
  }

  Future<void> _speak() async {
    try {
      await _tts.stop();
      setState(() {
        _speaking = true;
        _voiceError = null;
      });
      await _tts.speak(widget.plan.spokenText(widget.cue));
      _startTimer();
    } catch (_) {
      if (mounted) {
        setState(() {
          _speaking = false;
          _voiceError =
              'Голос недоступен. Текст и таймер продолжают работать.';
        });
        _startTimer();
      }
    }
  }

  void _startTimer() {
    if (_timerRunning) return;
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_elapsed >= widget.plan.durationSeconds) {
        _finish();
      } else {
        setState(() => _elapsed += 1);
      }
    });
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _timerRunning = false;
    await _tts.stop();
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _resume() async {
    _startTimer();
    await _speak();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    _timerRunning = false;
    await _tts.stop();
    if (mounted) widget.onComplete();
  }

  Future<void> _close() async {
    _timer?.cancel();
    await _tts.stop();
    if (mounted) widget.onClose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.plan.durationSeconds == 0
        ? 0.0
        : (_elapsed / widget.plan.durationSeconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final remaining =
        (widget.plan.durationSeconds - _elapsed).clamp(0, 9999);

    return Scaffold(
      backgroundColor: const Color(0xFF173E49),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  TextButton.icon(
                    onPressed: _close,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'Закрыть',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.isQuickMode
                        ? 'БЫСТРЫЙ РЕЖИМ · 3-Е НАЖАТИЕ'
                        : 'ПЕРСОНАЛЬНАЯ НАСТРОЙКА',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.plan.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.plan.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 18),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$remaining сек.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (_voiceError != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _voiceError!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    for (var index = 0;
                        index < widget.plan.steps.length;
                        index += 1)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.plan.steps[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.42,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'КОРОТКАЯ КОМАНДА',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.cue,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Задача на ковёр: ${widget.plan.matTask}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _speaking || _timerRunning
                                ? _pause
                                : _resume,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: Icon(
                              _speaking || _timerRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              _speaking || _timerRunning
                                  ? 'Пауза'
                                  : 'Продолжить',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _finish,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.ink,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Готово'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
