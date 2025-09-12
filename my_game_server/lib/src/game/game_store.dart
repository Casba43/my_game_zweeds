// lib/src/game/game_store.dart

import '../generated/protocol.dart';

class GameTable {
  final String id;
  final List<CardModel> stack = []; // face-down draw stack (table-wide)
  final List<CardModel> pile = []; // played cards (top is last)
  final Map<String, PlayerState> players = {}; // by playerId

  String? currentPlayerId;

  GameTable(this.id);

  PlayerState playerById(String pid) {
    final p = players[pid];
    if (p == null) {
      throw StateError('Unknown player $pid in game $id');
    }
    return p;
  }

  // Broadcast your GameState to listeners (implement with your server’s stream)
  void broadcastState() {
    // TODO: push GameState over your existing events stream
  }
}

class GameStore {
  GameStore._();
  static final GameStore _instance = GameStore._();
  static GameStore get I => _instance;

  final Map<String, GameTable> _tables = {};

  GameTable getOrCreate(String gameId) {
    return _tables.putIfAbsent(gameId, () => GameTable(gameId));
  }

  GameTable get(String gameId) {
    final t = _tables[gameId];
    if (t == null) throw StateError('Game not found: $gameId');
    return t;
  }
}
