import 'package:block_english/utils/constants.dart';

class ProblemOcrModel {
  final String userInput;
  final List<BlockColor> blockColors;

  ProblemOcrModel({required this.userInput, required this.blockColors});

  static ProblemOcrModel fromJson(Map<String, dynamic> json) {
    final colors = json['colors'] as List;
    return ProblemOcrModel(
      userInput: json['user_input'],
      blockColors: colors.map((color) => stringToBlockColor(color)).toList(),
    );
  }
}
