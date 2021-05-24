import 'dart:math';

import 'package:bugz_common/bugz_common.dart';

import 'match.dart';

final rand = Random();

/// Generating genomes using a sort of genetic algorithm
/// Starts with random genomes, then runs the simulation, performs mutations on some bots and finds the most stable ones
/// which can win 10+ tours in a row. Repeats 1000 times. Finally, performs round-robin matches inside all found bots and picks
/// best three of them
Future main(List<String> arguments) async {
  final _service = BugzService();
  final genomes = <List<int>>[];
  final stables = <StableGenome>[];
  var winGenome = '';
  var stableSteps = 0;
  var generationNumber = 0;
  for (var i=0; i<4; i++) {
    genomes.add(_service.getRandomGenome());
  }

  print('Now running 1000 generations to find stable bots');

  var isWorking = true;
  while (isWorking) {
    final teams = <TeamDescription>[];
    for (var i=0; i<4; i++) {
      teams.add(TeamDescription((t) => t
          ..id = '$i'
          ..name = 'bot $i'
          ..genome = genomes[i]
          ..rating = 1200
          ..ownerName = 'owner'
          ..ownerId = 'owner $i'
      ));
    }
    final counters = [0, 0, 0, 0];
    for (var i=0; i<10; i++) {
      bool simulation = true;
      while (simulation) {
        _service.initPredefinedConfig(teams, 8, 32, true);
        _service.processGeneticSimulation(true);
        final colorSet = _service.getBots.where((b) => b.isAlive).map((e) => e.color).toSet();
        if (colorSet.length == 1) {
          simulation = false;
          counters[colorSet.first]++;
        }
      }
    }
    final maximum = counters.reduce(max);
    var newGenome = genomes[0];
    if (maximum >= 9) {
      final index = counters.indexWhere((element) => element == maximum);
      newGenome = genomes[index];
      generationNumber++;
      if (generationNumber % 10 == 0) {
        print('Generation $generationNumber');
        if (generationNumber == 1000) {
          isWorking = false;
        }
      }
      final winString = newGenome.join(',');
      if (winString != winGenome) {
        if (stableSteps > 15) {
          print('Stable bot: won last $stableSteps matches, generation $generationNumber');
          print(winGenome);
          stables.add(StableGenome(newGenome));
        }
        winGenome = winString;
        stableSteps = 0;
      }
      else {
        stableSteps ++;
      }
      genomes[0] = newGenome;
      genomes[1] = _mutate(newGenome);
      genomes[2] = _mutate(newGenome);
      genomes[3] = _mutate(newGenome);
    }
    else {
      genomes[0] = newGenome;
      genomes[1] = _mutate(genomes[1]);
      genomes[2] = _mutate(genomes[2]);
      genomes[3] = rand.nextInt(100) == 0? _service.getRandomGenome() : _mutate(genomes[3]);
    }
  }
  if (stables.length == 0) {
    print('Nothing found, sorry');
    return;
  }
  print('Checking found bots...');
  for (var i=0; i<stables.length; i++) {
    for (var j=0; j<stables.length; j++) {
      if (i==j) {
        continue;
      }
      var result = processMatch(stables[i].genome, stables[j].genome, stables[i].rating, stables[j].rating);
      stables[i].rating = result.teamToRating[bot1_id];
      stables[j].rating = result.teamToRating[bot2_id];
      result = processMatch(stables[j].genome, stables[i].genome, stables[j].rating, stables[i].rating);
      stables[j].rating = result.teamToRating[bot1_id];
      stables[i].rating = result.teamToRating[bot2_id];
    }
  }
  stables.sort((a, b) => b.rating.compareTo(a.rating));
  print('\nBest bots found:');
  for (var i=0; i<min(10, stables.length); i++) {
    print('${stables[i].genome.join(',')}, [${stables[i].rating}]');
  }
}

List<int> _mutate(List<int> source) {
  final result = source.toList();
  final mutations = rand.nextInt(2) + 1;
  for (var i=0; i<mutations; i++) {
    result[rand.nextInt(64)] = rand.nextInt(64);
  }
  return result;
}

class StableGenome {

  int _rating = 1200;

  int get rating => _rating;
  set rating(int value) {
    _rating = value;
  }

  final List<int> genome;

  StableGenome(this.genome);

}
