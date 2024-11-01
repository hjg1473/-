import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game.g.dart';

class Game {
  Map<int, String> problems = {};
}

@Riverpod(keepAlive: true)
Game game(GameRef ref) {
  return Game();
}
