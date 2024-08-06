import 'package:block_english/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status.g.dart';

class Status {
  StudentMode studentMode = StudentMode.NONE;
  Season season = Season.NONE;
  String name = '';

  // Student's fields
  Map<Season, ReleaseStatus> releaseStatus = {};
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

  setStudentStatus(Season season, ReleaseStatus released) {
    releaseStatus[season] = released;
  }

  setTeamId(int? teamId) {
    teamId = teamId;
  }
}

class ReleaseStatus {
  final int currentLevel;
  final int currentStep;

  ReleaseStatus(this.currentLevel, this.currentStep);
}

@Riverpod(keepAlive: true)
Status status(StatusRef ref) {
  return Status();
}
