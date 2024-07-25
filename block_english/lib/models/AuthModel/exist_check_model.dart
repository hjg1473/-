class ExistCheckModel {
  final bool usernameExist;
  final bool phonenumberExist;

  ExistCheckModel.fromJson(Map<String, dynamic> json)
      : usernameExist = json['username_exist'],
        phonenumberExist = json['phone_number_exist'];
}
