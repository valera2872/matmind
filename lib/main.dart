import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app_flow.dart';
import 'src/repository.dart';
import 'src/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    SvoyaBorbaApp(
      repository: SharedPreferencesAppRepository(preferences),
    ),
  );
}

class SvoyaBorbaApp extends StatelessWidget {
  SvoyaBorbaApp({
    super.key,
    AppRepository? repository,
  }) : repository = repository ?? MemoryAppRepository();

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Своя борьба',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AppFlow(repository: repository),
    );
  }
}
