class GameStudentSolveModel {
  String ocrResult;

  GameStudentSolveModel.fromJson(Map<String, dynamic> json)
      : ocrResult = json['ocr_result'];
}
