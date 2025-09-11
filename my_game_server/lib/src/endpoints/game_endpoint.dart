import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class GameEndpoint extends Endpoint {
  // In-memory rooms (fine for prototype; use DB for production)
  static final Map<String, GameState> _rooms = {};

  static String _channel(String gameId) => 'game-$gameId';

  Future<GameState> join(Session session, {required String gameId, required String playerId}) async {
    var state = _rooms[gameId];
    if (state == null) {
      state = GameState(
        gameId: gameId,
        players: [playerId],
        currentPlayerId: playerId,
        pile: [],
      );
      _rooms[gameId] = state;
    } else {
      if (!state.players.contains(playerId)) {
        state.players = [...state.players, playerId];
      }
    }

    // Broadcast full state so everyone syncs
    session.messages.postMessage(_channel(gameId), state);
    return state;
  }

  Future<void> playCard(Session session,
      {required String gameId, required String playerId, required CardModel card}) async {
    final state = _rooms[gameId];
    if (state == null) throw Exception('Game not found');

    // turn check
    if (state.currentPlayerId != playerId) {
      throw Exception('Not your turn');
    }

    // (Rule checks could go here)

    // Apply move
    state.pile = [...state.pile, card];

    // Advance turn
    final idx = state.players.indexOf(playerId);
    final next = (idx + 1) % state.players.length;
    state.currentPlayerId = state.players[next];

    // Broadcast the event and the new state
    session.messages.postMessage(
      _channel(gameId),
      CardPlayed(gameId: gameId, playerId: playerId, card: card),
    );
    session.messages.postMessage(_channel(gameId), state);
  }

  // Clients subscribe here to receive GameState *and* CardPlayed events
  Stream<dynamic> events(Session session, {required String gameId}) async* {
    // Send current snapshot first
    final state = _rooms[gameId];
    if (state != null) yield state;

    final stream = session.messages.createStream<dynamic>(_channel(gameId));
    await for (final evt in stream) {
      yield evt;
    }
  }
}
