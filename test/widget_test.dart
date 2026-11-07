import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:urban_adventure/features/feed/data/repositories/local_storage_repository.dart';
import 'package:urban_adventure/features/feed/presentation/controllers/feed_providers.dart';
import 'package:urban_adventure/main.dart';

void main() {
  late Directory tempDir;
  late LocalStorageRepository storageRepository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('widget_test_hive_');
    storageRepository = LocalStorageRepository();
    await storageRepository.init(customPath: tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('UrbanAdventureApp smoke test - carrega e exibe cabeçalho', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(storageRepository),
        ],
        child: const UrbanAdventureApp(),
      ),
    );

    // Pump controlado sem aguardar animações contínuas de progresso
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('DISCOVERY'), findsOneWidget);
    expect(find.text('Descobrir'), findsOneWidget);
    expect(find.text('Salvos (Flow)'), findsOneWidget);
  });
}
