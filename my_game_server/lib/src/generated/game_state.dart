/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'card_model.dart' as _i2;

abstract class GameState
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  GameState._({
    required this.gameId,
    required this.players,
    required this.currentPlayerId,
    required this.pile,
    required this.phase,
  });

  factory GameState({
    required String gameId,
    required List<String> players,
    required String currentPlayerId,
    required List<_i2.CardModel> pile,
    required String phase,
  }) = _GameStateImpl;

  factory GameState.fromJson(Map<String, dynamic> jsonSerialization) {
    return GameState(
      gameId: jsonSerialization['gameId'] as String,
      players: (jsonSerialization['players'] as List)
          .map((e) => e as String)
          .toList(),
      currentPlayerId: jsonSerialization['currentPlayerId'] as String,
      pile: (jsonSerialization['pile'] as List)
          .map((e) => _i2.CardModel.fromJson((e as Map<String, dynamic>)))
          .toList(),
      phase: jsonSerialization['phase'] as String,
    );
  }

  String gameId;

  List<String> players;

  String currentPlayerId;

  List<_i2.CardModel> pile;

  String phase;

  /// Returns a shallow copy of this [GameState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GameState copyWith({
    String? gameId,
    List<String>? players,
    String? currentPlayerId,
    List<_i2.CardModel>? pile,
    String? phase,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'players': players.toJson(),
      'currentPlayerId': currentPlayerId,
      'pile': pile.toJson(valueToJson: (v) => v.toJson()),
      'phase': phase,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'gameId': gameId,
      'players': players.toJson(),
      'currentPlayerId': currentPlayerId,
      'pile': pile.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'phase': phase,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _GameStateImpl extends GameState {
  _GameStateImpl({
    required String gameId,
    required List<String> players,
    required String currentPlayerId,
    required List<_i2.CardModel> pile,
    required String phase,
  }) : super._(
          gameId: gameId,
          players: players,
          currentPlayerId: currentPlayerId,
          pile: pile,
          phase: phase,
        );

  /// Returns a shallow copy of this [GameState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GameState copyWith({
    String? gameId,
    List<String>? players,
    String? currentPlayerId,
    List<_i2.CardModel>? pile,
    String? phase,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      players: players ?? this.players.map((e0) => e0).toList(),
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      pile: pile ?? this.pile.map((e0) => e0.copyWith()).toList(),
      phase: phase ?? this.phase,
    );
  }
}
