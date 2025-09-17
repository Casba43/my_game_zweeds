// import 'dart:convert';
// import 'dart:math';
// import 'package:crypto/crypto.dart';
// import 'package:serverpod/serverpod.dart';
// import '../generated/protocol.dart';
//
// class AuthEndpoint extends Endpoint {
//   // ---- Utilities ----
//   String _randomSalt([int bytes = 16]) {
//     final r = Random.secure();
//     final b = List<int>.generate(bytes, (_) => r.nextInt(256));
//     return base64UrlEncode(b);
//   }
//
//   String _pbkdf2(String password, String salt, {int iterations = 100000, int dkLen = 32}) {
//     // Minimal PBKDF2-HMAC-SHA256
//     final key = pbkdf2(
//       password: utf8.encode(password),
//       salt: utf8.encode(salt),
//       iterations: iterations,
//       bits: dkLen * 8,
//       hash: sha256,
//     );
//     return base64UrlEncode(key);
//   }
//
//   Future<UserAccount?> _getByEmail(Session s, String email) =>
//       UserAccount.db.findFirstRow(s, where: (t) => t.email.equals(email));
//
//   Future<UserAccount> _getById(Session s, int id) async => (await UserAccount.db.findById(s, id))!;
//
//   Future<Rank> _getRank(Session s) async {
//     final userId = await s.auth.authenticatedUserId;
//     if (userId == null) return Rank.player; // guests default (or throw)
//     final ua = await _getById(s, userId);
//     return ua.rank;
//   }
//
//   // ---- RPCs ----
//
//   Future<PublicUser> register(Session s, {required String email, required String password}) async {
//     email = email.trim().toLowerCase();
//     if (email.isEmpty || password.length < 8) {
//       throw Exception('Invalid email or password too short');
//     }
//     if (await _getByEmail(s, email) != null) {
//       throw Exception('Email already registered');
//     }
//
//     final salt = _randomSalt();
//     final hash = _pbkdf2(password, salt);
//
//     final ua = UserAccount(
//       email: email,
//       passwordHash: hash,
//       salt: salt,
//       rank: Rank.player, // default rank
//       createdAt: DateTime.now().toUtc(),
//     );
//
//     final inserted = await UserAccount.db.insertRow(s, ua);
//
//     // mark this session as the user
//     await s.auth.signInUser(inserted.id!);
//
//     return PublicUser(
//       id: inserted.id!,
//       email: inserted.email,
//       rank: inserted.rank,
//       createdAt: inserted.createdAt,
//     );
//   }
//
//   Future<PublicUser> login(Session s, {required String email, required String password}) async {
//     email = email.trim().toLowerCase();
//     final ua = await _getByEmail(s, email);
//     if (ua == null) throw Exception('No account for that email');
//
//     final cmp = _pbkdf2(password, ua.salt);
//     if (cmp != ua.passwordHash) throw Exception('Wrong password');
//
//     await s.auth.signInUser(ua.id!);
//
//     return PublicUser(
//       id: ua.id!,
//       email: ua.email,
//       rank: ua.rank,
//       createdAt: ua.createdAt,
//     );
//   }
//
//   Future<void> logout(Session s) async {
//     await s.auth.signOutUser();
//   }
//
//   Future<PublicUser?> me(Session s) async {
//     final userId = await s.auth.authenticatedUserId;
//     if (userId == null) return null;
//     final ua = await _getById(s, userId);
//     return PublicUser(
//       id: ua.id!,
//       email: ua.email,
//       rank: ua.rank,
//       createdAt: ua.createdAt,
//     );
//   }
// }
