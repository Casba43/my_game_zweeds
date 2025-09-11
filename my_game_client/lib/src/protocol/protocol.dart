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
import 'card_played.dart' as _i3;
import 'game_state.dart' as _i4;
import 'greeting.dart' as _i5;
import 'player_state.dart' as _i6;
import 'package:my_game_client/src/protocol/card_model.dart' as _i7;
export 'card_model.dart';
export 'card_played.dart';
export 'game_state.dart';
export 'greeting.dart';
export 'player_state.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.CardModel) {
      return _i2.CardModel.fromJson(data) as T;
    }
    if (t == _i3.CardPlayed) {
      return _i3.CardPlayed.fromJson(data) as T;
    }
    if (t == _i4.GameState) {
      return _i4.GameState.fromJson(data) as T;
    }
    if (t == _i5.Greeting) {
      return _i5.Greeting.fromJson(data) as T;
    }
    if (t == _i6.PlayerState) {
      return _i6.PlayerState.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CardModel?>()) {
      return (data != null ? _i2.CardModel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CardPlayed?>()) {
      return (data != null ? _i3.CardPlayed.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.GameState?>()) {
      return (data != null ? _i4.GameState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Greeting?>()) {
      return (data != null ? _i5.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.PlayerState?>()) {
      return (data != null ? _i6.PlayerState.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i2.CardModel>) {
      return (data as List).map((e) => deserialize<_i2.CardModel>(e)).toList()
          as T;
    }
    if (t == List<_i7.CardModel>) {
      return (data as List).map((e) => deserialize<_i7.CardModel>(e)).toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.CardModel) {
      return 'CardModel';
    }
    if (data is _i3.CardPlayed) {
      return 'CardPlayed';
    }
    if (data is _i4.GameState) {
      return 'GameState';
    }
    if (data is _i5.Greeting) {
      return 'Greeting';
    }
    if (data is _i6.PlayerState) {
      return 'PlayerState';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CardModel') {
      return deserialize<_i2.CardModel>(data['data']);
    }
    if (dataClassName == 'CardPlayed') {
      return deserialize<_i3.CardPlayed>(data['data']);
    }
    if (dataClassName == 'GameState') {
      return deserialize<_i4.GameState>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i5.Greeting>(data['data']);
    }
    if (dataClassName == 'PlayerState') {
      return deserialize<_i6.PlayerState>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
