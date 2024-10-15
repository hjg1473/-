import 'package:block_english/models/model.dart';

class UserSummaryModel {
  WeakParts weakParts;
  StudyInfoModel rates;
  int totalStudyTime;
  int streamStudyDay;

  UserSummaryModel.fromJson(Map<String, dynamic> json)
      : weakParts = WeakParts.fromJson(json['weak_parts']),
        rates = StudyInfoModel.fromJson(json['rates'][0]),
        totalStudyTime = json['totalStudyTime'] ?? 0,
        streamStudyDay = json['streamStudyDay'] ?? 0;
}

class WeakParts {
  List<String> wrong = [
    'wrong_block',
    'wrong_punctuation',
    'wrong_word',
    'wrong_order',
    'wrong_letter',
  ];

  List<double> rates = [];
  late List<MapEntry<String, double>> top3Rates;

  WeakParts.fromJson(Map<String, dynamic> json) {
    rates.add(double.parse(json['wrong_block']));
    rates.add(double.parse(json['wrong_punctuation']));
    rates.add(double.parse(json['wrong_word']));
    rates.add(double.parse(json['wrong_order']));
    rates.add(double.parse(json['wrong_letter']));
  }

  List<MapEntry<String, double>> getTopNRates(int n) {
    // Create a list of pairs (name, rate)
    List<MapEntry<String, double>> nameRatePairs = List.generate(
      wrong.length,
      (index) => MapEntry(wrong[index], rates[index]),
    );

    // Sort the pairs based on the rate in descending order
    nameRatePairs.sort((a, b) => b.value.compareTo(a.value));

    // Return the top n pairs
    return nameRatePairs.take(n).toList();
  }
}
