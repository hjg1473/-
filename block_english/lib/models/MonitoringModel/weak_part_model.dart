class WeakPartModel {
  List<String> wrong = [
    'wrong_block',
    'wrong_punctuation',
    'wrong_word',
    'wrong_order',
    'wrong_letter',
  ];

  List<double> rates = [];
  List<MapEntry<String, double>> topRates = [];

  WeakPartModel.fromJson(Map<String, dynamic> json) {
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
