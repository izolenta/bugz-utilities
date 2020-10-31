import 'package:bugz_common/bugz_common.dart';

/// Generating genomes using genetic algorithm (random start + mutations)
Future main(List<String> arguments) async {
  final _service = BugzService();
  _service.initRandomConfig(4, 16, 48, false);
  var score = 0;
  var isWorking = true;
  while(isWorking) {
    _service.processGeneticSimulation();
    final result = _service.processStats();
    if (result.third > score) {
      score = result.third;
      print('generation ${result.first}, new max ${score}');
      print(result.second.first.toJson());
    }
    if (score > 100000) {
      isWorking = false;
      print(result.second.first.toJson());
    }
    else {
      _service.initGeneticStepConfig(4, 16, 48, result.second, result.first, false);
    }
  }
}
