/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'card_model.dart' as _i2;

abstract class CardPlayed implements _i1.SerializableModel {
  CardPlayed._({
    required this.gameId,
    required this.playerId,
    required this.card,
  });

  factory CardPlayed({
    required String gameId,
    required String playerId,
    required _i2.CardModel card,
  }) = _CardPlayedImpl;

  factory CardPlayed.fromJson(Map<String, dynamic> jsonSerialization) {
    return CardPlayed(
      gameId: jsonSerialization['gameId'] as String,
      playerId: jsonSerialization['playerId'] as String,
      card: _i2.CardModel.fromJson(
          (jsonSerialization['card'] as Map<String, dynamic>)),
    );
  }

  String gameId;

  String playerId;

  _i2.CardModel card;

  /// Returns a shallow copy of this [CardPlayed]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CardPlayed copyWith({
    String? gameId,
    String? playerId,
    _i2.CardModel? card,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'playerId': playerId,
      'card': card.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CardPlayedImpl extends CardPlayed {
  _CardPlayedImpl({
    required String gameId,
    required String playerId,
    required _i2.CardModel card,
  }) : super._(
          gameId: gameId,
          playerId: playerId,
          card: card,
        );

  /// Returns a shallow copy of this [CardPlayed]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CardPlayed copyWith({
    String? gameId,
    String? playerId,
    _i2.CardModel? card,
  }) {
    return CardPlayed(
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      card: card ?? this.card.copyWith(),
    );
  }
}
