import 'package:block_english/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status.g.dart';

class Status {
  StudentMode studentMode = StudentMode.NONE;
  Season season = Season.NONE;
  String name = '';

  // Student's fields
  List<ReleaseStatus> releaseStatus = [];
  int? teamId;

  setStudentMode(StudentMode mode) {
    studentMode = mode;
  }

  setSeason(Season season) {
    this.season = season;
  }

  setName(String name) {
    this.name = name;
  }

  setStudentStatus(List<Map<String, dynamic>> released, int? teamId) {
    for (Map<String, dynamic> data in released) {
      releaseStatus
          .add(ReleaseStatus(data['season'], data['level'], data['step']));
    }

    teamId = teamId;
  }
}

class ReleaseStatus {
  final int currentSeason;
  final int currentLevel;
  final int currentStep;

  ReleaseStatus(this.currentSeason, this.currentLevel, this.currentStep);
}

@Riverpod(keepAlive: true)
Status status(StatusRef ref) {
  return Status();
}
