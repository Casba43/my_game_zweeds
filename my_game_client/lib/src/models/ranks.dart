// lib/src/models/ranks.dart (both sides can mirror this)
const ranksOrder = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker', 'S', 'F'];

// normalize "1" -> "10" and uppercase specials
String normRank(String r) {
  r = r.trim().toUpperCase();
  if (r == '1') return '10';
  if (r == 'T') return '10';
  if (r == 'JOKER') return 'Joker';
  return r;
}

// Your matrix (fixed 10 vs "1")
final Map<String, List<String>> ruleSetStandard = {
  '2': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '3': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '4': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '5': ['2', '3', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '6': ['2', '3', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '7': ['2', '3', '4', '5', '6', '7', 'S'],
  '8': ['3', '2', '8', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '9': ['3', '2', '9', '10', 'J', 'Q', 'K', 'A', 'S'],
  '10': ['3', '2', '10', 'J', 'Q', 'K', 'A', 'S'],
  'J': ['3', '2', 'J', 'Q', 'K', 'A', 'S'],
  'Q': ['3', '2', 'Q', 'K', 'A', 'S'],
  'K': ['3', '2', 'K', 'A', 'S'],
  'A': ['3', '2', 'A', 'S'],
  'Joker': ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', 'Joker'],
  // 'F': define later; by default treat like 'S' or a wild. For now we omit.
};

bool canPlayOn({required String top, required String candidate}) {
  final t = normRank(top);
  final c = normRank(candidate);
  if (t == 'Joker') return true; // or keep matrix
  final allowed = ruleSetStandard[t];
  if (allowed == null) return false;
  return allowed.contains(c);
}
