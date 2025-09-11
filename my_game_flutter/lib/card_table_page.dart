import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_game_client/my_game_client.dart';
import 'serverpod_client.dart';

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
      setState(() {
        _state = state;
        _pile.clear();
        _pile.addAll(state.pile);
        _joined = true;
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
    final rnd = Random();
    final card = CardModel(
      suit: _suits[rnd.nextInt(_suits.length)],
      rank: _ranks[rnd.nextInt(_ranks.length)],
    );

    try {
      await client.game.playCard(
        gameId: _state!.gameId,
        playerId: _playerIdCtrl.text.trim(),
        card: card,
      );
    } catch (e) {
      setState(() => _error = 'Play failed: $e');
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
