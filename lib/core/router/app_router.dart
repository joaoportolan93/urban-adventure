import 'package:go_router/go_router.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/genre_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FeedPage(),
      routes: [
        GoRoute(
          path: 'genre/:genre',
          builder: (context, state) {
            final genre = state.pathParameters['genre'] ?? '';
            return GenrePage(genre: Uri.decodeComponent(genre));
          },
        ),
      ],
    ),
  ],
);

