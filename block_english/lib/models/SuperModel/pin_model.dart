class PinModel {
  final String? groupPinNumber;
  final String? parentPinNumber;

  PinModel.fromJson(Map<String, dynamic> json)
      : groupPinNumber = json['group_pinNumber'],
        parentPinNumber = json['parent_pinNumber'];
}
