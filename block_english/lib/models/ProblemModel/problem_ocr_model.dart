import 'package:block_english/utils/constants.dart';

class ProblemOcrModel {
  final List<String> userInput;
  final List<BlockColor> blockColors;

  ProblemOcrModel({required this.userInput, required this.blockColors});

  static ProblemOcrModel fromJson(Map<String, dynamic> json) {
    final colors = json['colors'] as List;
    final inputs = json['user_input'] as List;
    return ProblemOcrModel(
      userInput: inputs.map((input) => input.toString()).toList(),
      blockColors: colors.map((color) => stringToBlockColor(color)).toList(),
    );
  }
}
