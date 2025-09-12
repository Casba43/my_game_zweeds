import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'dart:math';

// -------- Rules (server-side copy) --------
String _normRank(String r) {
  r = r.trim().toUpperCase();
  if (r == '1' || r == 'T') return '10';
  if (r == 'JOKER') return 'Joker';
  return r;
}

const _ranksOrder = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker', 'S'];

const Map<String, List<String>> _ruleSetStandard = {
  '2': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '3': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '4': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '5': ['2', '3', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '6': ['2', '3', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '7': ['2', '3', '4', '5', '6', '7', 'Joker'],
  '8': ['2', '3', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '9': ['2', '3', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '10': ['2', '3', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  'J': ['2', '3', 'J', 'Q', 'K', 'A', 'Joker'],
  'Q': ['2', '3', 'J', 'Q', 'K', 'A', 'Joker'],
  'K': ['2', '3', 'K', 'A', 'Joker'],
  'A': ['2', '3', 'A', 'Joker'],
  'Joker': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
};
String? _effectiveTopRank(List<CardModel> pile) {
  for (int i = pile.length - 1; i >= 0; i--) {
    final r = _normRank(pile[i].rank);
    if (r != '3' && r != 'Joker') return r;
  }
  return null;
}

bool _isLegalOnPile(List<CardModel> pile, String candidate) {
  final c = _normRank(candidate);
  if (c == '3' || c == 'Joker') return true; // wild & invisible
  final eff = _effectiveTopRank(pile);
  if (eff == null) return true; // pile empty or only invisibles
  final allowed = _ruleSetStandard[eff];
  return allowed?.contains(c) ?? false;
}

bool _canPlayOn({required String top, required String candidate}) {
  final t = _normRank(top);
  final c = _normRank(candidate);
  if (t == 'Joker') return true; // keep matrix if you prefer
  final allowed = _ruleSetStandard[t];
  return allowed != null && allowed.contains(c);
}

// -------- Memory model for a single table --------
class _TableMem {
  GameState publicState;
  final Map<String, PlayerState> playerStates; // per-player
  final Map<String, List<CardModel>> hiddenReal; // true hidden (server only)
  final Map<String, List<CardModel>> sixVisible; // temp visible 6 per player
  List<CardModel> deck;
  _TableMem(this.publicState, this.playerStates, this.hiddenReal, this.deck) : sixVisible = {};
}

// -------- Endpoint --------
class GameEndpoint extends Endpoint {
  static final Map<String, _TableMem> _tables = {};
  static String _chan(String gameId) => 'game-$gameId';

  // === Lobby / join ===
  Future<GameState> join(Session session, {required String gameId, required String playerId}) async {
    var T = _tables[gameId];
    if (T == null) {
      final st = GameState(
        gameId: gameId,
        players: [playerId],
        currentPlayerId: playerId,
        pile: [],
        phase: 'lobby',
        drawStackCount: 0,
      );
      T = _tables[gameId] = _TableMem(st, {}, {}, _buildDeck()..shuffle(Random()));
    } else {
      if (!T.publicState.players.contains(playerId)) {
        T.publicState.players = [...T.publicState.players, playerId];
      }
    }
    session.messages.postMessage(_chan(gameId), T.publicState);
    return T.publicState;
  }

  Future<DrawResult> drawUpToThree(
    Session s, {
    required String gameId,
    required String playerId,
  }) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));
    if (T.publicState.phase != 'playing') {
      final facedown = T.hiddenReal[playerId] ?? const <CardModel>[];
      ps
        ..stackCount = T.deck.length
        ..reserveCount = ps.reserve.length
        ..blindCount = facedown.length;
      return DrawResult(
        changed: false,
        needsBlindPick: false,
        handSize: ps.inHand.length,
        stackCount: ps.stackCount,
        reserveCount: ps.reserveCount,
        blindCount: ps.blindCount,
      );
    }

    bool changed = false;

    // Top up to 3: deck (table stack) -> player reserve
    while (ps.inHand.length < 3) {
      if (T.deck.isNotEmpty) {
        ps.inHand.add(T.deck.removeLast());
        changed = true;
        continue;
      }
      if (ps.reserve.isNotEmpty) {
        ps.inHand.add(ps.reserve.removeLast());
        changed = true;
        continue;
      }
      break; // Only facedown left -> blind pick phase
    }

    final facedown = T.hiddenReal[playerId] ?? const <CardModel>[];
    final needsBlindPick = ps.inHand.length < 3 && facedown.isNotEmpty;

    // keep counts current for myState()
    ps
      ..stackCount = T.deck.length
      ..reserveCount = ps.reserve.length
      ..blindCount = facedown.length;
    _syncCounts(T, playerId); // NEW

    if (changed) s.messages.postMessage(_chan(gameId), T.publicState);

    return DrawResult(
      changed: changed,
      needsBlindPick: needsBlindPick,
      handSize: ps.inHand.length,
      stackCount: ps.stackCount,
      reserveCount: ps.reserveCount,
      blindCount: ps.blindCount,
    );
  }

  Future<DrawResult> drawBlindTopDown(
    Session s, {
    required String gameId,
    required String playerId,
    required int index, // 0..2 top-down
  }) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));
    final facedown = T.hiddenReal[playerId] ?? (throw Exception('No facedown'));

    if (facedown.isEmpty) {
      return DrawResult(
        changed: false,
        needsBlindPick: false,
        handSize: ps.inHand.length,
        stackCount: T.deck.length,
        reserveCount: ps.reserve.length,
        blindCount: 0,
      );
    }
    if (index < 0 || index >= facedown.length) {
      throw ArgumentError('Invalid blind index');
    }

    ps.inHand.add(facedown.removeAt(index));

    // Immediately try to top-up again from deck/reserve
    while (ps.inHand.length < 3) {
      if (T.deck.isNotEmpty) {
        ps.inHand.add(T.deck.removeLast());
        continue;
      }
      if (ps.reserve.isNotEmpty) {
        ps.inHand.add(ps.reserve.removeLast());
        continue;
      }
      break;
    }

    ps
      ..stackCount = T.deck.length
      ..reserveCount = ps.reserve.length
      ..blindCount = facedown.length;
    _syncCounts(T, playerId); // NEW

    s.messages.postMessage(_chan(gameId), T.publicState);

    return DrawResult(
      changed: true,
      needsBlindPick: ps.inHand.length < 3 && facedown.isNotEmpty,
      handSize: ps.inHand.length,
      stackCount: ps.stackCount,
      reserveCount: ps.reserveCount,
      blindCount: ps.blindCount,
    );
  }

  // === Stream public state & events ===
  Stream<dynamic> events(Session s, {required String gameId}) async* {
    final T = _tables[gameId];
    if (T != null) yield T.publicState;
    final stream = s.messages.createStream<dynamic>(_chan(gameId));
    await for (final evt in stream) {
      yield evt;
    }
  }

  // === Start game & deal 9 ===
  Future<GameState> deal(Session s, {required String gameId}) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final deck = _buildDeck();
    deck.shuffle(Random());
    T.deck = deck;

    for (final p in T.publicState.players) {
      final nine = deck.take(9).toList();
      deck.removeRange(0, 9);
      final hidden = nine.take(3).toList();
      final visible = nine.skip(3).toList(); // 6 visible

      T.hiddenReal[p] = hidden;
      T.playerStates[p] = PlayerState(
        inHand: [],
        reserve: [],
        facedown: [],
        stackCount: 0,
        reserveCount: 0,
        blindCount: 0,
      );
      T.sixVisible[p] = visible;
      _syncCounts(T, p);
    }

    T.publicState.phase = 'selecting';
    s.messages.postMessage(_chan(gameId), T.publicState);
    return T.publicState;
  }

  // The 6 visible cards (one-time fetch is fine)
  Future<List<CardModel>> myVisibleSix(Session s, {required String gameId, required String playerId}) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    return List<CardModel>.from(T.sixVisible[playerId] ?? const []);
  }

  // Player chooses 3 reserve; remaining 3 become inHand
  Future<void> chooseReserve(Session s,
      {required String gameId, required String playerId, required List<CardModel> reserve}) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final six = T.sixVisible[playerId] ?? (throw Exception('No visible cards'));

    if (reserve.length != 3 || !_isSubset(reserve, six)) {
      throw Exception('Pick 3 from your 6');
    }
    final inHand = six.where((c) => !reserve.any((r) => _eq(r, c))).toList();
    final ps = T.playerStates[playerId]!;
    ps.reserve = List.of(reserve);
    ps.inHand = inHand;
    T.sixVisible.remove(playerId);
    _syncCounts(T, playerId);

    // if all players have chosen, enter "playing"
    final allReady = T.publicState.players.every((p) => (T.playerStates[p]?.inHand.isNotEmpty ?? false));
    if (allReady) {
      T.publicState.phase = 'playing';
      s.messages.postMessage(_chan(gameId), T.publicState);
    }
  }

  // Private per-player state (hand/reserve contents)
  Future<PlayerState> myState(Session s, {required String gameId, required String playerId}) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));
    _syncCounts(T, playerId);
    return ps;
  }

  void _syncCounts(_TableMem T, String playerId) {
    final ps = T.playerStates[playerId]!;
    final facedown = T.hiddenReal[playerId] ?? const <CardModel>[];
    ps
      ..stackCount = T.deck.length
      ..reserveCount = ps.reserve.length
      ..blindCount = facedown.length;
  }

  Future<void> playCards(
    Session s, {
    required String gameId,
    required String playerId,
    required List<CardModel> cards,
  }) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final st = T.publicState;
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));

    if (st.phase != 'playing') throw Exception('Not in playing phase');
    if (st.currentPlayerId != playerId) throw Exception('Not your turn');
    if (cards.isEmpty) throw Exception('No cards provided');

    // Ownership & same-rank validation (normalized)
    final want = List<CardModel>.from(cards);
    if (!_isSubset(want, ps.inHand)) throw Exception('One or more cards are not in your hand');

    final normRanks = want.map((c) => _normRank(c.rank)).toSet();
    if (normRanks.length != 1) throw Exception('All played cards must have the same rank');

    final playRank = normRanks.single;

    // Pile legality (treat as playing one of this rank; your rule set decides)
    if (!_isLegalOnPile(st.pile, playRank)) {
      final eff = _effectiveTopRank(st.pile);
      throw Exception('Illegal move on ${eff ?? 'empty pile'}');
    }

    // Apply atomically: remove all from hand, append to pile in given order
    for (final c in want) {
      ps.inHand.removeWhere((x) => _eq(x, c));
    }
    st.pile = [...st.pile, ...want];

    // Replenish like your single-card flow
    if (ps.inHand.isEmpty) {
      if (ps.reserve.isNotEmpty) {
        ps.inHand = List.of(ps.reserve);
        ps.reserve = [];
      } else {
        final hidden = T.hiddenReal[playerId] ?? [];
        if (hidden.isNotEmpty) {
          ps.inHand = List.of(hidden);
          T.hiddenReal[playerId] = [];
        }
      }
    }
    _syncCounts(T, playerId);

    // Advance turn
    _advanceTurn(T);

    // Notify: emit last card as CardPlayed (keeps client compatible) + whole state
    if (want.isNotEmpty) {
      final last = want.last;
      s.messages.postMessage(_chan(gameId), CardPlayed(gameId: gameId, playerId: playerId, card: last));
    }
    s.messages.postMessage(_chan(gameId), st);
  }

  Future<void> takePileAndEndTurn(
    Session s, {
    required String gameId,
    required String playerId,
  }) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final st = T.publicState;
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));

    if (st.phase != 'playing') throw Exception('Not in playing phase');
    if (st.currentPlayerId != playerId) throw Exception('Not your turn');

    // Server-side guard: ensure truly no legal move
    if (_hasAnyLegalMove(T, playerId)) {
      throw Exception('You still have a legal move');
    }

    // Take the pile (append to hand) and clear it
    if (st.pile.isNotEmpty) {
      ps.inHand = [...ps.inHand, ...st.pile];
      st.pile = [];
    }

    _syncCounts(T, playerId);

    // Advance turn
    _advanceTurn(T);

    // Notify (single state broadcast is enough)
    s.messages.postMessage(_chan(gameId), st);
  }

  bool _hasAnyLegalMove(_TableMem T, String playerId) {
    final st = T.publicState;
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));
    for (final c in ps.inHand) {
      if (_isLegalOnPile(st.pile, c.rank)) return true;
    }
    return false;
  }

  void _advanceTurn(_TableMem T) {
    final st = T.publicState;
    final i = st.players.indexOf(st.currentPlayerId ?? '0');
    st.currentPlayerId = st.players[(i + 1) % st.players.length];
  }

  // Play a card from your hand, validate by rules, advance turn
  Future<void> playCard(Session s, {required String gameId, required String playerId, required CardModel card}) async {
    final T = _tables[gameId] ?? (throw Exception('No such game'));
    final st = T.publicState;
    final ps = T.playerStates[playerId] ?? (throw Exception('No player'));
    if (!_isLegalOnPile(st.pile, card.rank)) {
      final eff = _effectiveTopRank(st.pile);
      throw Exception('Illegal move on ${eff ?? 'empty pile'}');
    }
    if (st.phase != 'playing') throw Exception('Not in playing phase');
    if (st.currentPlayerId != playerId) throw Exception('Not your turn');

    // ownership
    if (!ps.inHand.any((c) => _eq(c, card))) throw Exception('You don\'t have that card');

    // rules
    if (st.pile.isNotEmpty) {
      final top = st.pile.last.rank;
      if (!_canPlayOn(top: top, candidate: card.rank)) {
        throw Exception('Illegal move on $top');
      }
    }

    // apply
    ps.inHand.removeWhere((c) => _eq(c, card));
    st.pile = [...st.pile, card];

    // replenish flow: reserve -> hidden
    if (ps.inHand.isEmpty) {
      if (ps.reserve.isNotEmpty) {
        ps.inHand = List.of(ps.reserve);
        ps.reserve = [];
      } else {
        final hidden = T.hiddenReal[playerId] ?? [];
        if (hidden.isNotEmpty) {
          ps.inHand = List.of(hidden);
          T.hiddenReal[playerId] = [];
        }
      }
    }
    _syncCounts(T, playerId); // NEW

    // next turn
    final i = st.players.indexOf(playerId);
    st.currentPlayerId = st.players[(i + 1) % st.players.length];

    // notify
    s.messages.postMessage(_chan(gameId), CardPlayed(gameId: gameId, playerId: playerId, card: card));
    s.messages.postMessage(_chan(gameId), st);
  }

  // -------- helpers --------
  bool _eq(CardModel a, CardModel b) => a.rank == b.rank && a.suit == b.suit;

  bool _isSubset(List<CardModel> a, List<CardModel> b) {
    final used = List<bool>.filled(b.length, false);
    for (final x in a) {
      var found = false;
      for (var i = 0; i < b.length; i++) {
        if (!used[i] && _eq(x, b[i])) {
          used[i] = true;
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  List<CardModel> _buildDeck() {
    const suits = ['♣', '♦', '♥', '♠'];
    const ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    final deck = <CardModel>[
      for (final s in suits)
        for (final r in ranks) CardModel(suit: s, rank: r),
      // add Jokers if you want:
      CardModel(suit: '', rank: 'Joker'),
      CardModel(suit: '', rank: 'Joker'),
    ];
    return deck;
  }
}
