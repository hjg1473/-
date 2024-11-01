class GameRoomModel {
  final String pinNumber;

  GameRoomModel.fromjson(Map<String, dynamic> json)
      : pinNumber = json['pin_number'];
}
