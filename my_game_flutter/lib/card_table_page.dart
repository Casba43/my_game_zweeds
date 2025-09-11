import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_game_client/my_game_client.dart';
import 'serverpod_client.dart';

// lib/src/models/ranks.dart (both sides can mirror this)
const ranksOrder = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'];

// normalize "1" -> "10" and uppercase specials
String normRank(String r) {
  r = r.trim().toUpperCase();
  if (r == '1') return '10';
  if (r == 'T') return '10';
  if (r == 'JOKER') return 'Joker';
  return r;
}

// Your matrix (fixed 10 vs "1")
final Map<String, List<String>> ruleSetStandard = {
  '2': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '3': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '4': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '5': ['2', '3', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '6': ['2', '3', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '7': ['2', '3', '4', '5', '6', '7', 'S'],
  '8': ['3', '2', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '9': ['3', '2', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '10': ['3', '2', '10', 'J', 'Q', 'K', 'A', 'S'],
  'J': ['3', '2', 'J', 'Q', 'K', 'A', 'S'],
  'Q': ['3', '2', 'Q', 'K', 'A', 'S'],
  'K': ['3', '2', 'K', 'A', 'S'],
  'A': ['3', '2', 'A', 'S'],
  'Joker': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
};

bool canPlayOn({required String top, required String candidate}) {
  final t = normRank(top);
  final c = normRank(candidate);
  if (t == 'Joker') return true; // or keep matrix
  final allowed = ruleSetStandard[t];
  if (allowed == null) return false;
  return allowed.contains(c);
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
      setState(() async {
        _state = state;
        _pile.clear();
        _pile.addAll(state.pile);
        _joined = true;
        await _dealAndChooseReserve();
      });

      // Subscribe to server events (GameState or CardPlayed)
      _sub?.cancel();
      _sub = client.game.events(gameId: gameId).listen((evt) {
        if (evt is GameState) {
          setState(() {
            _state = evt;
            _pile
              ..clear()
              ..addAll(evt.pile);
          });
        } else if (evt is CardPlayed) {
          setState(() {
            _pile.add(evt.card);
          });
        }
      });
    } catch (e) {
      setState(() => _error = 'Join failed: $e');
    }
  }

  Future<void> _play() async {
    if (_state == null) return;
    final me = _playerIdCtrl.text.trim();

    try {
      // get my private state to know my actual cards
      final ps = await client.game.myState(gameId: _state!.gameId, playerId: me);
      if (ps.inHand.isEmpty) {
        setState(() => _error = 'No cards in hand');
        return;
      }

      // pick a legal card (or first if pile empty)
      CardModel? toPlay;
      if (_state!.pile.isEmpty) {
        toPlay = ps.inHand.first;
      } else {
        final top = _state!.pile.last.rank;
        toPlay = ps.inHand.firstWhere(
          (c) => canPlayOn(top: top, candidate: c.rank),
        );
      }

      await client.game.playCard(
        gameId: _state!.gameId,
        playerId: me,
        card: toPlay,
      );
    } catch (e) {
      setState(() => _error = 'Play failed: $e');
    }
  }

  Future<void> _dealAndChooseReserve() async {
    final gameId = _gameIdCtrl.text.trim();
    final me = _playerIdCtrl.text.trim();

    // Only call deal if phase isn't already 'selecting' or 'playing'
    // (if multiple clients, any one can press the button)
    await client.game.deal(gameId: gameId);

    // fetch my 6 visible and auto-pick first 3 as reserve (simple for now)
    final six = await client.game.myVisibleSix(gameId: gameId, playerId: me);
    if (six.length == 6) {
      await client.game.chooseReserve(
        gameId: gameId,
        playerId: me,
        reserve: six.take(3).toList(),
      );
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
              ElevatedButton(
                onPressed: turn == me ? _play : null,
                child: const Text('Play random card'),
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
