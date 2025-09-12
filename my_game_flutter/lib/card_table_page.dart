import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_game_client/my_game_client.dart';
import 'serverpod_client.dart';

// lib/src/models/ranks.dart (both sides can mirror this)
const ranksOrder = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'];

// Your matrix (fixed 10 vs "1")
// Single source of truth: what may be played ON TOP of the given top-rank.
final Map<String, List<String>> ruleSetStandard = {
  '2': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '3': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '4': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '5': ['2', '3', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '6': ['2', '3', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  // <- Your explicit example: on 7 you can play 2,3,4,5,6,7 or Joker
  '7': ['2', '3', '4', '5', '6', '7', 'Joker'],
  // Your example for Q says 3,2,J,Q,K,A,Joker (order doesn't matter)
  '8': ['2', '3', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '9': ['2', '3', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  '10': ['2', '3', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  'J': ['2', '3', 'J', 'Q', 'K', 'A', 'Joker'],
  'Q': ['2', '3', 'J', 'Q', 'K', 'A', 'Joker'],
  'K': ['2', '3', 'K', 'A', 'Joker'],
  'A': ['2', '3', 'A', 'Joker'],
  // On top of Joker you can play anything (handled in canPlayOn)
  'Joker': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
};

String normRank(String r) {
  r = r.trim().toUpperCase();
  if (r == '1' || r == 'T') return '10';
  if (r == 'JOKER') return 'Joker';
  return r;
}

bool canPlayOnWithPile({
  required List<CardModel> pile,
  required String candidate,
}) {
  final c = normRank(candidate);

  // Wild cards can always be played; they don't change the effective top for next turn.
  if (c == '3' || c == 'Joker') return true;

  final tEff = effectiveTopRank(pile);
  if (tEff == null) return true; // no visible requirement

  final allowed = ruleSetStandard[tEff];
  return allowed?.contains(c) ?? false;
}

String? effectiveTopRank(List<CardModel> pile) {
  if (pile.isEmpty) return null;
  for (int i = pile.length - 1; i >= 0; i--) {
    final r = normRank(pile[i].rank);
    if (r != '3' && r != 'Joker') return r; // first non-invisible from top down
  }
  return null; // pile contains only 3/Joker => treat as no requirement
}

class CardTablePage extends StatefulWidget {
  const CardTablePage({super.key});
  @override
  State<CardTablePage> createState() => _CardTablePageState();
}

class _CardTablePageState extends State<CardTablePage> {
  final _gameIdCtrl = TextEditingController(text: 'table-1');
  final _playerIdCtrl = TextEditingController();
  StreamSubscription? _sub;
  List<CardModel> _myHand = [];
  List<CardModel> _myVisibleSix = [];
  List<CardModel> _myReserve = [];
  bool _reserveConfirmed = false; // set this to true after confirmReserve()
  bool _blindMode = false; // true when both stack & reserve are drained
  CardModel? _selectedCard;

  final List<int> _blindSlots = [0, 1, 2]; // purely UI; server owns truth
// --- DRAW HELPERS ---
// return true if a card was drawn, false if that source is empty
  Future<bool> _tryDrawFromStack() async {
    try {
      await client.game.drawFromStack(gameId: _state!.gameId, playerId: _playerIdCtrl.text.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

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

// Blind draw: user picks one of the three face-down cards (top-down)
  Future<bool> _drawBlind(int index) async {
    try {
      await client.game.drawBlindTopDown(
        gameId: _state!.gameId,
        playerId: _playerIdCtrl.text.trim(),
        index: index, // 0,1,2 where 0 is “topmost”
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  bool sameCard(CardModel a, CardModel b) => a.rank == b.rank && a.suit == b.suit;
  bool get _isMyTurn {
    final me = _playerIdCtrl.text.trim();
    return _state?.currentPlayerId == me;
  }

  bool _isLegal(CardModel c) {
    if (_state == null) return false;
    return canPlayOnWithPile(pile: _state!.pile, candidate: c.rank);
  }

  bool _loading = false;
  Future<void> _refreshMyState() async {
    if (_state == null) return;
    final gameId = _state!.gameId;
    final me = _playerIdCtrl.text.trim();
    try {
      final ps = await client.game.myState(gameId: gameId, playerId: me);
      final six = _reserveConfirmed
          ? const <CardModel>[] // ✅ don’t re-show once done
          : await client.game.myVisibleSix(gameId: gameId, playerId: me);
      setState(() {
        _myHand = List<CardModel>.from(ps.inHand);
        _myVisibleSix = List<CardModel>.from(six);
        // _myReserve kept client-side
      });
    } catch (_) {}
  }

  Future<void> _waitForVisibleSixAndChooseReserve({int retries = 15}) async {
    final gameId = _gameIdCtrl.text.trim();
    final me = _playerIdCtrl.text.trim();
    for (var i = 0; i < retries; i++) {
      try {
        final six = await client.game.myVisibleSix(gameId: gameId, playerId: me);
        if (six.length == 6) {
          setState(() => _myVisibleSix = six);
          await client.game.chooseReserve(
            gameId: gameId,
            playerId: me,
            reserve: six.take(3).toList(),
          );
          await _refreshMyState();
          return;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200)); // small backoff
    }
    setState(() => _error = 'Could not fetch the six visible cards (timed out).');
  }

  GameState? _state;
  final List<CardModel> _pile = [];

  final _ranks = ['A', 'K', 'Q', 'J', '10', '9'];
  final _suits = ['♣', '♦', '♥', '♠'];
  bool _joined = false;
  String? _error;

  @override
  void dispose() {
    _sub?.cancel();
    _gameIdCtrl.dispose();
    _playerIdCtrl.dispose();
    super.dispose();
  }

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
        _joined = true;
        _reserveConfirmed = false;
        _myReserve.clear();
        _myVisibleSix = [];
      });
      await _refreshMyState();
      await _autoReplenishHand();
      // Subscribe to public events, and refresh private state on each
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
        } else if (evt is CardPlayed) {
          setState(() {
            _pile.add(evt.card);
          });
          await _refreshMyState();
        }
      });

      // Kick off deal/reserve only once per table (or guard by phase on server).
      _dealAndChooseReserve();

      // // Subscribe to server events (GameState or CardPlayed)
      // _sub?.cancel();
      // _sub = client.game.events(gameId: gameId).listen((evt) {
      //   if (evt is GameState) {
      //     setState(() {
      //       _state = evt;
      //       _pile
      //         ..clear()
      //         ..addAll(evt.pile);
      //     });
      //   } else if (evt is CardPlayed) {
      //     setState(() {
      //       _pile.add(evt.card);
      //     });
      //   }
      // });
    } catch (e) {
      setState(() => _error = 'Join failed: $e');
    }
  }

  Future<void> _playSelected() async {
    if (_state == null || _selectedCard == null) return;
    final me = _playerIdCtrl.text.trim();
    final selected = _selectedCard!;
    try {
      // always refresh hand first to reduce stale clicks
      final ps = await client.game.myState(gameId: _state!.gameId, playerId: me);
      final inHand = ps.inHand;
      final exists = inHand.any((c) => c.rank == selected.rank && c.suit == selected.suit);
      if (!exists) {
        setState(() => _error = 'Selected card is no longer in your hand.');
        await _refreshMyState();
        return;
      }
      if (!_isLegal(selected)) {
        setState(() => _error = 'That card cannot be played on the current top card.');
        return;
      }

      await client.game.playCard(
        gameId: _state!.gameId,
        playerId: me,
        card: selected,
      );
      setState(() => _selectedCard = null); // clear selection after a successful play

      await _refreshMyState();
      await _autoReplenishHand();
    } catch (e) {
      setState(() => _error = 'Play failed: $e');
    }
  }

  Future<void> _dealAndChooseReserve() async {
    if (_state == null || _loading) return;
    setState(() => _loading = true);
    try {
      await client.game.deal(gameId: _state!.gameId);
      // Now wait for server to populate the 6 visible; UI will show them.
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
      _reserveConfirmed = true; // ✅ mark done
      setState(() {
        _myVisibleSix = []; // ✅ hide the 6 visible
      });
      await _refreshMyState(); //
      await _autoReplenishHand();
      // remaining 3 should appear in _myHand
    } catch (e) {
      setState(() => _error = 'Reserve failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

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
            if (!_joined) ...[
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
              ElevatedButton(
                onPressed: _join,
                child: const Text('Join Table'),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Game: ${_state?.gameId}'),
                  Text('Players: ${_state?.players.join(", ") ?? ""}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Current turn: ${turn ?? "-"}'),
              const Divider(),
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
              const SizedBox(height: 8),
              if (_loading) const LinearProgressIndicator(),
              Text('You: $me'),
              const SizedBox(height: 6),
              if (_myVisibleSix.isNotEmpty) ...[
                const Text('Your 6 visible (pre-reserve):'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _myVisibleSix.map((c) => Chip(label: Text('${c.rank}${c.suit}'))).toList(),
                ),
                const SizedBox(height: 6),
              ],
              if (_blindMode) ...[
                const SizedBox(height: 8),
                const Text('Blind draw: pick one of your facedown cards'),
                Wrap(
                  spacing: 8,
                  children: _blindSlots.map((i) {
                    return ElevatedButton(
                      onPressed: () async {
                        setState(() => _loading = true);
                        final ok = await _drawBlind(i);
                        setState(() => _loading = false);
                        await _refreshMyState();
                        if (ok) await _autoReplenishHand(); // try to keep filling to 3
                      },
                      child: Text('Blind ${i + 1}'),
                    );
                  }).toList(),
                ),
              ],
              if (_myVisibleSix.isNotEmpty) ...[
                const Text('Choose 3 to reserve:'),
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
                const SizedBox(height: 6),
              ],
              const Text('Your hand:'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _myHand.map((c) {
                  final selected = _selectedCard != null && sameCard(_selectedCard!, c);
                  final legal = _isLegal(c);
                  // Slightly dim illegal cards on your turn; normal brightness otherwise.
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
                    // simple styling feedback
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
              ElevatedButton.icon(
                onPressed: (_isMyTurn &&
                        _reserveConfirmed &&
                        _selectedCard != null &&
                        _isLegal(_selectedCard!) &&
                        _myHand.isNotEmpty)
                    ? _playSelected
                    : null,
                icon: const Icon(Icons.play_arrow),
                label:
                    Text(_selectedCard == null ? 'Select a card' : 'Play ${_selectedCard!.rank}${_selectedCard!.suit}'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
