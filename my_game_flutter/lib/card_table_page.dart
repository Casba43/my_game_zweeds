import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_game_client/my_game_client.dart';
import 'serverpod_client.dart';

/// ===================== RULES =====================
/// Single source of truth: allowed ranks that may be played ON TOP of a given (effective) top rank.
const Map<String, List<String>> _ruleSetStandard = {
  '2': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '3': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '4': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '5': ['2', '3', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '6': ['2', '3', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  // On 7 you can play 2..7 or Joker
  '7': ['2', '3', '4', '5', '6', '7', 'Joker'],
  '8': ['2', '3', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '9': ['2', '3', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '10': ['2', '3', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  'J': ['2', '3', 'J', 'Q', 'K', 'A', 'Joker'],
  // On Q you can play 2,3,J,Q,K,A or Joker
  'Q': ['2', '3', 'J', 'Q', 'K', 'A', 'Joker'],
  'K': ['2', '3', 'K', 'A', 'Joker'],
  'A': ['2', '3', 'A', 'Joker'],
  // If the effective top is Joker (shouldn't happen with invisibility), allow anything.
  'Joker': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
};

String normRank(String r) {
  r = r.trim().toUpperCase();
  if (r == '1' || r == 'T') return '10';
  if (r == 'JOKER') return 'Joker';
  return r;
}

/// Effective top rank ignores trailing 3/Joker on the pile.
String? effectiveTopRank(List<CardModel> pile) {
  for (int i = pile.length - 1; i >= 0; i--) {
    final r = normRank(pile[i].rank);
    if (r != '3' && r != 'Joker') return r;
  }
  return null; // pile empty or only invisibles
}

/// Pile-aware legality: 3/Joker are always allowed (wild & invisible).
bool canPlayOnWithPile({
  required List<CardModel> pile,
  required String candidate,
}) {
  final c = normRank(candidate);
  if (c == '3' || c == 'Joker') return true;

  final eff = effectiveTopRank(pile);
  if (eff == null) return true; // no visible requirement yet

  final allowed = _ruleSetStandard[eff];
  return allowed?.contains(c) ?? false;
}

/// ===================== UI PAGE =====================
class CardTablePage extends StatefulWidget {
  const CardTablePage({super.key});
  @override
  State<CardTablePage> createState() => _CardTablePageState();
}

class _CardTablePageState extends State<CardTablePage> {
  final _gameIdCtrl = TextEditingController(text: 'table-1');
  final _playerIdCtrl = TextEditingController();
  StreamSubscription? _sub;

  GameState? _state;
  final List<CardModel> _pile = [];

  List<CardModel> _myHand = [];
  List<CardModel> _myVisibleSix = [];
  final List<CardModel> _myReserve = [];

  bool _reserveConfirmed = false; // set true after confirmReserve()
  bool _blindMode = false; // true when stack & reserve are empty
  bool _loading = false;
  String? _error;

  CardModel? _selectedCard;
  bool sameCard(CardModel a, CardModel b) => a.rank == b.rank && a.suit == b.suit;

  bool get _isMyTurn {
    final me = _playerIdCtrl.text.trim();
    return _state?.currentPlayerId == me;
  }

  bool _isLegal(CardModel c) {
    if (_state == null) return false;
    return canPlayOnWithPile(pile: _state!.pile, candidate: c.rank);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _gameIdCtrl.dispose();
    _playerIdCtrl.dispose();
    super.dispose();
  }

  /// ======== CLIENT HELPERS ========
  Future<void> _refreshMyState() async {
    if (_state == null) return;
    final gameId = _state!.gameId;
    final me = _playerIdCtrl.text.trim();
    try {
      final ps = await client.game.myState(gameId: gameId, playerId: me);
      final six =
          _reserveConfirmed ? const <CardModel>[] : await client.game.myVisibleSix(gameId: gameId, playerId: me);
      setState(() {
        _myHand = List<CardModel>.from(ps.inHand);
        _myVisibleSix = List<CardModel>.from(six);
      });
    } catch (_) {/* ignore transient */}
  }

  /// Ask server to keep our hand at 3 (stack -> reserve -> blind).
  Future<void> _autoReplenishHand() async {
    if (_state == null) return;
    try {
      final res = await client.game.drawUpToThree(
        gameId: _state!.gameId,
        playerId: _playerIdCtrl.text.trim(),
      );
      await _refreshMyState();
      setState(() {
        _blindMode = res.needsBlindPick;
      });
    } catch (_) {/* ignore transient */}
  }

  Future<bool> _drawBlind(int index) async {
    try {
      await client.game.drawBlindTopDown(
        gameId: _state!.gameId,
        playerId: _playerIdCtrl.text.trim(),
        index: index, // 0..2 top-down
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ======== FLOWS ========
  Future<void> _join() async {
    setState(() {
      _error = null;
      _pile.clear();
    });
    final gameId = _gameIdCtrl.text.trim();
    final playerId = _playerIdCtrl.text.trim();
    if (gameId.isEmpty || playerId.isEmpty) {
      setState(() => _error = 'Enter gameId and playerId');
      return;
    }

    try {
      final state = await client.game.join(gameId: gameId, playerId: playerId);
      setState(() {
        _state = state;
        _pile
          ..clear()
          ..addAll(state.pile);
        _reserveConfirmed = false;
        _myReserve.clear();
        _myVisibleSix = [];
      });

      await _refreshMyState();
      await _autoReplenishHand();

      // Subscribe to server events
      _sub?.cancel();
      _sub = client.game.events(gameId: gameId).listen((evt) async {
        if (evt is GameState) {
          setState(() {
            _state = evt;
            _pile
              ..clear()
              ..addAll(evt.pile);
          });
          await _refreshMyState();
          // Optional: keep topped up even on others' turns (safe & idempotent)
          await _autoReplenishHand();
        } else if (evt is CardPlayed) {
          setState(() => _pile.add(evt.card));
          await _refreshMyState();
          await _autoReplenishHand();
        }
      });

      // Start a deal (any player may trigger; server should guard phase)
      await _deal();
    } catch (e) {
      setState(() => _error = 'Join failed: $e');
    }
  }

  Future<void> _deal() async {
    if (_state == null || _loading) return;
    setState(() => _loading = true);
    try {
      await client.game.deal(gameId: _state!.gameId);
      _reserveConfirmed = false;
      _myReserve.clear();
      _myVisibleSix = [];
      await _refreshMyState();
    } catch (e) {
      setState(() => _error = 'Deal failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmReserve() async {
    final gameId = _gameIdCtrl.text.trim();
    final me = _playerIdCtrl.text.trim();
    if (_myReserve.length != 3) {
      setState(() => _error = 'Pick exactly 3 cards to reserve.');
      return;
    }
    setState(() => _loading = true);
    try {
      await client.game.chooseReserve(gameId: gameId, playerId: me, reserve: _myReserve);
      _reserveConfirmed = true;
      setState(() => _myVisibleSix = []);
      await _refreshMyState();
      await _autoReplenishHand();
    } catch (e) {
      setState(() => _error = 'Reserve failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _playSelected() async {
    if (_state == null || _selectedCard == null) return;
    final me = _playerIdCtrl.text.trim();
    final selected = _selectedCard!;
    try {
      // Re-validate ownership & legality
      final ps = await client.game.myState(gameId: _state!.gameId, playerId: me);
      if (!ps.inHand.any((c) => c.rank == selected.rank && c.suit == selected.suit)) {
        setState(() => _error = 'Selected card is no longer in your hand.');
        await _refreshMyState();
        return;
      }
      if (!_isLegal(selected)) {
        setState(() => _error = 'That card cannot be played on the current top card.');
        return;
      }

      await client.game.playCard(gameId: _state!.gameId, playerId: me, card: selected);
      setState(() => _selectedCard = null);

      await _refreshMyState();
      await _autoReplenishHand();
    } catch (e) {
      setState(() => _error = 'Play failed: $e');
    }
  }

  /// ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    final turn = _state?.currentPlayerId;
    final me = _playerIdCtrl.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Card Table')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Not joined: login fields =====
            if (_state == null) ...[
              TextField(
                controller: _gameIdCtrl,
                decoration: const InputDecoration(labelText: 'Game ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _playerIdCtrl,
                decoration: const InputDecoration(labelText: 'Player ID'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _join, child: const Text('Join Table')),
            ] else ...[
              // ===== Joined: table header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Game: ${_state?.gameId}'),
                  Text('Players: ${_state?.players.join(", ") ?? ""}'),
                ],
              ),
              const SizedBox(height: 6),
              Text('Current turn: ${turn ?? "-"}'),
              const Divider(),

              // ===== Pile =====
              const Text('Pile (latest last):'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _pile.length,
                  itemBuilder: (_, i) {
                    final c = _pile[i];
                    return ListTile(
                      dense: true,
                      title: Text('${c.rank}${c.suit}'),
                    );
                  },
                ),
              ),
              if (_loading) const LinearProgressIndicator(),

              // ===== Player area =====
              const SizedBox(height: 8),
              Text('You: $me'),
              const SizedBox(height: 6),

              // Visible six + reserve chooser (only when needed)
              if (!_reserveConfirmed && _myVisibleSix.isNotEmpty && _myHand.isEmpty) ...[
                const Text('Your 6 visible (pre-reserve):'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _myVisibleSix.map((c) => Chip(label: Text('${c.rank}${c.suit}'))).toList(),
                ),
                const SizedBox(height: 8),
                const Text('Choose 3 to reserve:'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _myVisibleSix.map((c) {
                    final selected = _myReserve.any((r) => r.rank == c.rank && r.suit == c.suit);
                    return FilterChip(
                      label: Text('${c.rank}${c.suit}'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          if (selected) {
                            _myReserve.removeWhere((r) => r.rank == c.rank && r.suit == c.suit);
                          } else {
                            if (_myReserve.length < 3) _myReserve.add(c);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _myReserve.length == 3 && !_loading ? _confirmReserve : null,
                  child: const Text('Confirm reserve (3)'),
                ),
                const SizedBox(height: 8),
              ],

              // Blind draw UI (only when stack & reserve are empty)
              if (_blindMode) ...[
                const SizedBox(height: 8),
                const Text('Blind draw: pick one of your facedown cards'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: List.generate(3, (i) {
                    return ElevatedButton(
                      onPressed: () async {
                        setState(() => _loading = true);
                        final ok = await _drawBlind(i);
                        setState(() => _loading = false);
                        await _refreshMyState();
                        if (ok) await _autoReplenishHand();
                      },
                      child: Text('Blind ${i + 1}'),
                    );
                  }),
                ),
                const SizedBox(height: 8),
              ],

              // Hand + selection
              const Text('Your hand:'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _myHand.map((c) {
                  final selected = _selectedCard != null && sameCard(_selectedCard!, c);
                  final legal = _isLegal(c);
                  final dim = _isMyTurn && !legal;
                  return ChoiceChip(
                    label: Text('${c.rank}${c.suit}'),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCard = c;
                        _error = null;
                      });
                    },
                    avatar: _isMyTurn
                        ? (legal ? const Icon(Icons.check_circle_outline, size: 18) : const Icon(Icons.block, size: 18))
                        : null,
                    labelStyle: TextStyle(
                      color: dim ? Colors.black54 : null,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const Divider(),

              // Play button
              ElevatedButton.icon(
                onPressed: (_isMyTurn &&
                        _reserveConfirmed &&
                        _selectedCard != null &&
                        _isLegal(_selectedCard!) &&
                        _myHand.isNotEmpty)
                    ? _playSelected
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  _selectedCard == null ? 'Select a card' : 'Play ${_selectedCard!.rank}${_selectedCard!.suit}',
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
