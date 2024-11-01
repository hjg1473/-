class GameGroupInfoModel {
  final int level;
  final int season;
  final int step;
  final int ownerID;
  final int id;
  final String type;

  GameGroupInfoModel.fromJson(Map<String, dynamic> json)
      : level = json['released_level'],
        season = json['released_season'],
        step = json['released_step'],
        ownerID = json['owner_id'],
        id = json['id'],
        type = json['released_type'];
}
