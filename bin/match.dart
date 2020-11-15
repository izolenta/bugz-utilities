import 'package:bugz_common/bugz_common.dart';

final bot_1 = [13,61,48,1,0,48,15,34,25,37,20,1,8,60,21,8,19,19,26,48,30,31,38,2,15,46,52,12,56,36,25,21,48,7,43,24,42,31,28,26,22,42,42,34,30,57,34,14,34,47,62,30,28,31,53,5,10,52,32,54,19,15,25,21];
final bot_2 = [8,61,35,3,63,63,36,32,55,52,45,47,45,15,53,5,29,59,4,33,42,38,2,6,13,37,34,41,6,35,61,55,9,26,9,63,60,34,47,31,38,20,61,55,59,34,5,52,50,36,4,18,31,15,14,6,36,39,45,15,22,14,31,23];

const bot1_id = 'bot1';
const bot2_id = 'bot2';

void main(List<String> arguments) {
  final result = processMatch(bot_1, bot_2);
  print('The winner is ${result.winnerId}');
}

/// Playing match between two genomes
GameRecordingDto processMatch(List<int> bot1, List<int> bot2, [int rating1 = 1200, int rating2 = 1200])  {
  final _service = BugzService();
  final team1 = TeamDescription((t) => t
    ..genome = bot1
    ..id = bot1_id
    ..name = 'bot1'
    ..rating = rating1
    ..ownerId = 'user'
    ..ownerName = 'user'
    ..gamesPlayed = 0
  );
  final team2 = TeamDescription((t) => t
    ..genome = bot2
    ..id = bot2_id
    ..name = 'bot2'
    ..rating = rating2
    ..ownerId = 'user'
    ..ownerName = 'user'
    ..gamesPlayed = 0
  );
  return _service.runMatchInBackground([team1, team2]);
}
