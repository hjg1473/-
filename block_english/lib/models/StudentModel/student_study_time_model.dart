class StudyTimeModel {
  int totalStudyTime;
  int streamStudyDay;

  StudyTimeModel.fromJson(Map<String, dynamic> json)
      : totalStudyTime = json['totalStudyTime'],
        streamStudyDay = json['streamStudyDay'];
}
