class GameStudentSolveModel {
  bool ocrResult;

  GameStudentSolveModel.fromJson(Map<String, dynamic> json)
      : ocrResult = json['ocr_result'];
}
