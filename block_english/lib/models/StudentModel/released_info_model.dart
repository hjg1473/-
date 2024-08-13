class ReleasedInfoModel {
  int season;
  int level;
  int step;
  String type;

  ReleasedInfoModel.fromJson(Map<String, dynamic> json)
      : season = json['season'],
        level = json['level'],
        step = json['step'],
        type = json['type'];
}
