import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:my_game_client/my_game_client.dart';

late final Client client;

Future<void> initServerpod() async {
  // Use your Render URL here:
  client = Client('https://serverpod-zweeds-pesten.onrender.com/')..connectivityMonitor = FlutterConnectivityMonitor();
  // If you add auth later, set up SessionManager.
}
