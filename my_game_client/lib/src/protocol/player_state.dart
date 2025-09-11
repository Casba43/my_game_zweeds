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

abstract class PlayerState implements _i1.SerializableModel {
  PlayerState._({
    required this.playerId,
    required this.inHand,
    required this.reserve,
    required this.hiddenCount,
  });

  factory PlayerState({
    required String playerId,
    required List<_i2.CardModel> inHand,
    required List<_i2.CardModel> reserve,
    required int hiddenCount,
  }) = _PlayerStateImpl;

  factory PlayerState.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlayerState(
      playerId: jsonSerialization['playerId'] as String,
      inHand: (jsonSerialization['inHand'] as List)
          .map((e) => _i2.CardModel.fromJson((e as Map<String, dynamic>)))
          .toList(),
      reserve: (jsonSerialization['reserve'] as List)
          .map((e) => _i2.CardModel.fromJson((e as Map<String, dynamic>)))
          .toList(),
      hiddenCount: jsonSerialization['hiddenCount'] as int,
    );
  }

  String playerId;

  List<_i2.CardModel> inHand;

  List<_i2.CardModel> reserve;

  int hiddenCount;

  /// Returns a shallow copy of this [PlayerState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PlayerState copyWith({
    String? playerId,
    List<_i2.CardModel>? inHand,
    List<_i2.CardModel>? reserve,
    int? hiddenCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'inHand': inHand.toJson(valueToJson: (v) => v.toJson()),
      'reserve': reserve.toJson(valueToJson: (v) => v.toJson()),
      'hiddenCount': hiddenCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PlayerStateImpl extends PlayerState {
  _PlayerStateImpl({
    required String playerId,
    required List<_i2.CardModel> inHand,
    required List<_i2.CardModel> reserve,
    required int hiddenCount,
  }) : super._(
          playerId: playerId,
          inHand: inHand,
          reserve: reserve,
          hiddenCount: hiddenCount,
        );

  /// Returns a shallow copy of this [PlayerState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PlayerState copyWith({
    String? playerId,
    List<_i2.CardModel>? inHand,
    List<_i2.CardModel>? reserve,
    int? hiddenCount,
  }) {
    return PlayerState(
      playerId: playerId ?? this.playerId,
      inHand: inHand ?? this.inHand.map((e0) => e0.copyWith()).toList(),
      reserve: reserve ?? this.reserve.map((e0) => e0.copyWith()).toList(),
      hiddenCount: hiddenCount ?? this.hiddenCount,
    );
  }
}
