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

abstract class DrawResult implements _i1.SerializableModel {
  DrawResult._({
    required this.changed,
    required this.needsBlindPick,
    required this.handSize,
    required this.stackCount,
    required this.reserveCount,
    required this.blindCount,
  });

  factory DrawResult({
    required bool changed,
    required bool needsBlindPick,
    required int handSize,
    required int stackCount,
    required int reserveCount,
    required int blindCount,
  }) = _DrawResultImpl;

  factory DrawResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return DrawResult(
      changed: jsonSerialization['changed'] as bool,
      needsBlindPick: jsonSerialization['needsBlindPick'] as bool,
      handSize: jsonSerialization['handSize'] as int,
      stackCount: jsonSerialization['stackCount'] as int,
      reserveCount: jsonSerialization['reserveCount'] as int,
      blindCount: jsonSerialization['blindCount'] as int,
    );
  }

  bool changed;

  bool needsBlindPick;

  int handSize;

  int stackCount;

  int reserveCount;

  int blindCount;

  /// Returns a shallow copy of this [DrawResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DrawResult copyWith({
    bool? changed,
    bool? needsBlindPick,
    int? handSize,
    int? stackCount,
    int? reserveCount,
    int? blindCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'changed': changed,
      'needsBlindPick': needsBlindPick,
      'handSize': handSize,
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

class _DrawResultImpl extends DrawResult {
  _DrawResultImpl({
    required bool changed,
    required bool needsBlindPick,
    required int handSize,
    required int stackCount,
    required int reserveCount,
    required int blindCount,
  }) : super._(
          changed: changed,
          needsBlindPick: needsBlindPick,
          handSize: handSize,
          stackCount: stackCount,
          reserveCount: reserveCount,
          blindCount: blindCount,
        );

  /// Returns a shallow copy of this [DrawResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DrawResult copyWith({
    bool? changed,
    bool? needsBlindPick,
    int? handSize,
    int? stackCount,
    int? reserveCount,
    int? blindCount,
  }) {
    return DrawResult(
      changed: changed ?? this.changed,
      needsBlindPick: needsBlindPick ?? this.needsBlindPick,
      handSize: handSize ?? this.handSize,
      stackCount: stackCount ?? this.stackCount,
      reserveCount: reserveCount ?? this.reserveCount,
      blindCount: blindCount ?? this.blindCount,
    );
  }
}
