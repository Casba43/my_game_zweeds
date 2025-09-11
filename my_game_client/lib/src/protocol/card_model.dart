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

abstract class CardModel implements _i1.SerializableModel {
  CardModel._({
    required this.suit,
    required this.rank,
  });

  factory CardModel({
    required String suit,
    required String rank,
  }) = _CardModelImpl;

  factory CardModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return CardModel(
      suit: jsonSerialization['suit'] as String,
      rank: jsonSerialization['rank'] as String,
    );
  }

  String suit;

  String rank;

  /// Returns a shallow copy of this [CardModel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CardModel copyWith({
    String? suit,
    String? rank,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'suit': suit,
      'rank': rank,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CardModelImpl extends CardModel {
  _CardModelImpl({
    required String suit,
    required String rank,
  }) : super._(
          suit: suit,
          rank: rank,
        );

  /// Returns a shallow copy of this [CardModel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CardModel copyWith({
    String? suit,
    String? rank,
  }) {
    return CardModel(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
    );
  }
}
