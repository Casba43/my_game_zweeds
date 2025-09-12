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
import 'dart:async' as _i2;
import 'package:my_game_client/src/protocol/game_state.dart' as _i3;
import 'package:my_game_client/src/protocol/draw_result.dart' as _i4;
import 'package:my_game_client/src/protocol/card_model.dart' as _i5;
import 'package:my_game_client/src/protocol/player_state.dart' as _i6;
import 'protocol.dart' as _i7;

/// {@category Endpoint}
class EndpointGame extends _i1.EndpointRef {
  EndpointGame(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'game';

  _i2.Future<_i3.GameState> join({
    required String gameId,
    required String playerId,
  }) =>
      caller.callServerEndpoint<_i3.GameState>(
        'game',
        'join',
        {
          'gameId': gameId,
          'playerId': playerId,
        },
      );

  _i2.Future<_i4.DrawResult> drawUpToThree({
    required String gameId,
    required String playerId,
  }) =>
      caller.callServerEndpoint<_i4.DrawResult>(
        'game',
        'drawUpToThree',
        {
          'gameId': gameId,
          'playerId': playerId,
        },
      );

  _i2.Future<_i4.DrawResult> drawBlindTopDown({
    required String gameId,
    required String playerId,
    required int index,
  }) =>
      caller.callServerEndpoint<_i4.DrawResult>(
        'game',
        'drawBlindTopDown',
        {
          'gameId': gameId,
          'playerId': playerId,
          'index': index,
        },
      );

  _i2.Stream<dynamic> events({required String gameId}) =>
      caller.callStreamingServerEndpoint<_i2.Stream<dynamic>, dynamic>(
        'game',
        'events',
        {'gameId': gameId},
        {},
      );

  _i2.Future<_i3.GameState> deal({required String gameId}) =>
      caller.callServerEndpoint<_i3.GameState>(
        'game',
        'deal',
        {'gameId': gameId},
      );

  _i2.Future<List<_i5.CardModel>> myVisibleSix({
    required String gameId,
    required String playerId,
  }) =>
      caller.callServerEndpoint<List<_i5.CardModel>>(
        'game',
        'myVisibleSix',
        {
          'gameId': gameId,
          'playerId': playerId,
        },
      );

  _i2.Future<void> chooseReserve({
    required String gameId,
    required String playerId,
    required List<_i5.CardModel> reserve,
  }) =>
      caller.callServerEndpoint<void>(
        'game',
        'chooseReserve',
        {
          'gameId': gameId,
          'playerId': playerId,
          'reserve': reserve,
        },
      );

  _i2.Future<_i6.PlayerState> myState({
    required String gameId,
    required String playerId,
  }) =>
      caller.callServerEndpoint<_i6.PlayerState>(
        'game',
        'myState',
        {
          'gameId': gameId,
          'playerId': playerId,
        },
      );

  _i2.Future<void> playCards({
    required String gameId,
    required String playerId,
    required List<_i5.CardModel> cards,
  }) =>
      caller.callServerEndpoint<void>(
        'game',
        'playCards',
        {
          'gameId': gameId,
          'playerId': playerId,
          'cards': cards,
        },
      );

  _i2.Future<void> takePileAndEndTurn({
    required String gameId,
    required String playerId,
  }) =>
      caller.callServerEndpoint<void>(
        'game',
        'takePileAndEndTurn',
        {
          'gameId': gameId,
          'playerId': playerId,
        },
      );

  _i2.Future<void> playCard({
    required String gameId,
    required String playerId,
    required _i5.CardModel card,
  }) =>
      caller.callServerEndpoint<void>(
        'game',
        'playCard',
        {
          'gameId': gameId,
          'playerId': playerId,
          'card': card,
        },
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i7.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    game = EndpointGame(this);
  }

  late final EndpointGame game;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'game': game};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
