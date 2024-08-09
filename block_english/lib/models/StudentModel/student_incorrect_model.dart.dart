import 'package:block_english/models/StudentModel/student_weak_part_model.dart';

class IncorrectModel {
  List<WeakPartModel> weakParts = [];
  String weakest = '';
  String? recentProblem;
  String? recentAnswer;
  String recentDetail;

  IncorrectModel.fromJson(Map<String, dynamic> json)
      : weakParts = List<WeakPartModel>.from(
            json['weak_parts'].map((x) => WeakPartModel.fromJson(x))),
        weakest = json['weakest'],
        recentProblem = json['recent_problem'],
        recentAnswer = json['recent_answer'],
        recentDetail = json['recent_detail'];
}
