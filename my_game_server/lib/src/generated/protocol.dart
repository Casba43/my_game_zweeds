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
import 'package:serverpod/protocol.dart' as _i2;
import 'card_model.dart' as _i3;
import 'card_played.dart' as _i4;
import 'draw_result.dart' as _i5;
import 'game_state.dart' as _i6;
import 'player_state.dart' as _i7;
import 'package:my_game_server/src/generated/card_model.dart' as _i8;
export 'card_model.dart';
export 'card_played.dart';
export 'draw_result.dart';
export 'game_state.dart';
export 'player_state.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    ..._i2.Protocol.targetTableDefinitions
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i3.CardModel) {
      return _i3.CardModel.fromJson(data) as T;
    }
    if (t == _i4.CardPlayed) {
      return _i4.CardPlayed.fromJson(data) as T;
    }
    if (t == _i5.DrawResult) {
      return _i5.DrawResult.fromJson(data) as T;
    }
    if (t == _i6.GameState) {
      return _i6.GameState.fromJson(data) as T;
    }
    if (t == _i7.PlayerState) {
      return _i7.PlayerState.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.CardModel?>()) {
      return (data != null ? _i3.CardModel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.CardPlayed?>()) {
      return (data != null ? _i4.CardPlayed.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DrawResult?>()) {
      return (data != null ? _i5.DrawResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.GameState?>()) {
      return (data != null ? _i6.GameState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.PlayerState?>()) {
      return (data != null ? _i7.PlayerState.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i3.CardModel>) {
      return (data as List).map((e) => deserialize<_i3.CardModel>(e)).toList()
          as T;
    }
    if (t == List<_i8.CardModel>) {
      return (data as List).map((e) => deserialize<_i8.CardModel>(e)).toList()
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i3.CardModel) {
      return 'CardModel';
    }
    if (data is _i4.CardPlayed) {
      return 'CardPlayed';
    }
    if (data is _i5.DrawResult) {
      return 'DrawResult';
    }
    if (data is _i6.GameState) {
      return 'GameState';
    }
    if (data is _i7.PlayerState) {
      return 'PlayerState';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
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
      return deserialize<_i3.CardModel>(data['data']);
    }
    if (dataClassName == 'CardPlayed') {
      return deserialize<_i4.CardPlayed>(data['data']);
    }
    if (dataClassName == 'DrawResult') {
      return deserialize<_i5.DrawResult>(data['data']);
    }
    if (dataClassName == 'GameState') {
      return deserialize<_i6.GameState>(data['data']);
    }
    if (dataClassName == 'PlayerState') {
      return deserialize<_i7.PlayerState>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'my_game';
}
