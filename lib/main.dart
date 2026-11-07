import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/router/app_router.dart';
import 'features/feed/data/repositories/local_storage_repository.dart';
import 'features/feed/presentation/controllers/feed_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a persistência local Hive CE (tipos simples)
  final storageRepository = LocalStorageRepository();
  await storageRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storageRepository),
      ],
      child: const UrbanAdventureApp(),
    ),
  );
}

class UrbanAdventureApp extends StatelessWidget {
  const UrbanAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Urban Adventure Music',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: 600, name: MOBILE),
          Breakpoint(start: 601, end: 1024, name: TABLET),
          Breakpoint(start: 1025, end: double.infinity, name: DESKTOP),
        ],
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111115),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2A55),
          secondary: Color(0xFFFFB300),
          surface: Color(0xFF18181F),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF18181C),
        ),
      ),
    );
  }
}
