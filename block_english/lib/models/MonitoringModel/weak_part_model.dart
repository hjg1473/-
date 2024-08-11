class WeakPartModel {
  int? season;
  int? level;
  double? punctuation;
  double? word;
  double? block;
  double? order;

  WeakPartModel.fromJson(Map<String, dynamic> json)
      : season = json['season'],
        level = json['level'],
        punctuation = json['punctuation'],
        word = json['word'],
        block = json['block'],
        order = json['order'];
}
