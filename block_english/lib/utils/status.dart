import 'package:block_english/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status.g.dart';

class Status {
  StudentMode studentMode = StudentMode.NONE;
  Season season = Season.NONE;
  String name = '';
  String username = '';

  // Student's fields
  List<ReleaseStatus> releaseStatus = [];
  int? teamId;
  String? groupName;

  setStudentMode(StudentMode mode) {
    studentMode = mode;
  }

  setSeason(Season season) {
    this.season = season;
  }

  setName(String name) {
    this.name = name;
  }

  setUsername(String username) {
    this.username = username;
  }

  setGroup(int teamId, String groupName) {
    this.teamId = teamId;
    this.groupName = groupName;
  }

  setStudentStatus(List<dynamic> released, int? teamId, String? groupName) {
    for (Map<String, dynamic> data in released) {
      releaseStatus
          .add(ReleaseStatus(data['season'], data['level'], data['step']));
    }

    this.teamId = teamId;
    this.groupName = groupName;
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
