import 'package:hive_ce/hive.dart';

part 'ml_model_state.g.dart';

@HiveType(typeId: 30)
class MLModelState extends HiveObject {
  @HiveField(0)
  String modelName;

  @HiveField(1)
  List<double> weights;

  @HiveField(2)
  DateTime trainedAt;

  @HiveField(3)
  int trainingDataCount;

  @HiveField(4)
  double validationScore;

  MLModelState({
    required this.modelName,
    required this.weights,
    required this.trainedAt,
    required this.trainingDataCount,
    required this.validationScore,
  });
}