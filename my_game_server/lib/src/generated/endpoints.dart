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
import '../endpoints/game_endpoint.dart' as _i2;
import '../greeting_endpoint.dart' as _i3;
import 'package:my_game_server/src/generated/card_model.dart' as _i4;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'game': _i2.GameEndpoint()
        ..initialize(
          server,
          'game',
        ),
      'greeting': _i3.GreetingEndpoint()
        ..
          server,
          'greeting',
        ),
    };
    connectors['game'] = _i1.EndpointConnector(
      name: 'game',
      endpoint: endpoints['game']!,
      methodConnectors: {
        'join': _i1.MethodConnector(
          name: 'join',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).join(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
          ),
        ),
        'drawUpToThree': _i1.MethodConnector(
          name: 'drawUpToThree',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).drawUpToThree(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
          ),
        ),
        'drawBlindTopDown': _i1.MethodConnector(
          name: 'drawBlindTopDown',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'index': _i1.ParameterDescription(
              name: 'index',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).drawBlindTopDown(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
            index: params['index'],
          ),
        ),
        'deal': _i1.MethodConnector(
          name: 'deal',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).deal(
            session,
            gameId: params['gameId'],
          ),
        ),
        'myVisibleSix': _i1.MethodConnector(
          name: 'myVisibleSix',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).myVisibleSix(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
          ),
        ),
        'chooseReserve': _i1.MethodConnector(
          name: 'chooseReserve',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reserve': _i1.ParameterDescription(
              name: 'reserve',
              type: _i1.getType<List<_i4.CardModel>>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).chooseReserve(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
            reserve: params['reserve'],
          ),
        ),
        'myState': _i1.MethodConnector(
          name: 'myState',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).myState(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
          ),
        ),
        'playCard': _i1.MethodConnector(
          name: 'playCard',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'playerId': _i1.ParameterDescription(
              name: 'playerId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'card': _i1.ParameterDescription(
              name: 'card',
              type: _i1.getType<_i4.CardModel>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['game'] as _i2.GameEndpoint).playCard(
            session,
            gameId: params['gameId'],
            playerId: params['playerId'],
            card: params['card'],
          ),
        ),
        'events': _i1.MethodStreamConnector(
          name: 'events',
          params: {
            'gameId': _i1.ParameterDescription(
              name: 'gameId',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
            Map<String, Stream> streamParams,
          ) =>
              (endpoints['game'] as _i2.GameEndpoint).events(
            session,
            gameId: params['gameId'],
          ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['greeting'] as _i3.GreetingEndpoint).hello(
            session,
            params['name'],
          ),
        )
      },
    );
  }
}
