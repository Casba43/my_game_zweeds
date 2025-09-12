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
    required this.inHand,
    required this.reserve,
    required this.facedown,
    required this.stackCount,
    required this.reserveCount,
    required this.blindCount,
  });

  factory PlayerState({
    required List<_i2.CardModel> inHand,
    required List<_i2.CardModel> reserve,
    required List<_i2.CardModel> facedown,
    required int stackCount,
    required int reserveCount,
    required int blindCount,
  }) = _PlayerStateImpl;

  factory PlayerState.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlayerState(
      inHand: (jsonSerialization['inHand'] as List)
          .map((e) => _i2.CardModel.fromJson((e as Map<String, dynamic>)))
          .toList(),
      reserve: (jsonSerialization['reserve'] as List)
          .map((e) => _i2.CardModel.fromJson((e as Map<String, dynamic>)))
          .toList(),
      facedown: (jsonSerialization['facedown'] as List)
          .map((e) => _i2.CardModel.fromJson((e as Map<String, dynamic>)))
          .toList(),
      stackCount: jsonSerialization['stackCount'] as int,
      reserveCount: jsonSerialization['reserveCount'] as int,
      blindCount: jsonSerialization['blindCount'] as int,
    );
  }

  List<_i2.CardModel> inHand;

  List<_i2.CardModel> reserve;

  List<_i2.CardModel> facedown;

  int stackCount;

  int reserveCount;

  int blindCount;

  /// Returns a shallow copy of this [PlayerState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PlayerState copyWith({
    List<_i2.CardModel>? inHand,
    List<_i2.CardModel>? reserve,
    List<_i2.CardModel>? facedown,
    int? stackCount,
    int? reserveCount,
    int? blindCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'inHand': inHand.toJson(valueToJson: (v) => v.toJson()),
      'reserve': reserve.toJson(valueToJson: (v) => v.toJson()),
      'facedown': facedown.toJson(valueToJson: (v) => v.toJson()),
      'stackCount': stackCount,
      'reserveCount': reserveCount,
      'blindCount': blindCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PlayerStateImpl extends PlayerState {
  _PlayerStateImpl({
    required List<_i2.CardModel> inHand,
    required List<_i2.CardModel> reserve,
    required List<_i2.CardModel> facedown,
    required int stackCount,
    required int reserveCount,
    required int blindCount,
  }) : super._(
          inHand: inHand,
          reserve: reserve,
          facedown: facedown,
          stackCount: stackCount,
          reserveCount: reserveCount,
          blindCount: blindCount,
        );

  /// Returns a shallow copy of this [PlayerState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PlayerState copyWith({
    List<_i2.CardModel>? inHand,
    List<_i2.CardModel>? reserve,
    List<_i2.CardModel>? facedown,
    int? stackCount,
    int? reserveCount,
    int? blindCount,
  }) {
    return PlayerState(
      inHand: inHand ?? this.inHand.map((e0) => e0.copyWith()).toList(),
      reserve: reserve ?? this.reserve.map((e0) => e0.copyWith()).toList(),
      facedown: facedown ?? this.facedown.map((e0) => e0.copyWith()).toList(),
      stackCount: stackCount ?? this.stackCount,
      reserveCount: reserveCount ?? this.reserveCount,
      blindCount: blindCount ?? this.blindCount,
    );
  }
}
