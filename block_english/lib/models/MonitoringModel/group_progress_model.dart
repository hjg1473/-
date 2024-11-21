class GroupProgressModel {
  int releasedLevel = 0;
  int releasedSeason = 0;
  int releasedStep = 0;

  GroupProgressModel() {
    releasedLevel = 0;
    releasedSeason = 0;
    releasedStep = 0;
  }
  GroupProgressModel.fromJson(Map<String, dynamic> json)
      : releasedLevel = json['released_level'],
        releasedSeason = json['released_season'],
        releasedStep = json['released_step'];
}
