class PinModel {
  final String groupPinNumber;

  PinModel.fromJson(Map<String, dynamic> json)
      : groupPinNumber = json['group_pinNumber'];
}
