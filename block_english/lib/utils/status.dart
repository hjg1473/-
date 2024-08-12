import 'package:block_english/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status.g.dart';

class Status {
  StudentMode studentMode = StudentMode.NONE;
  Season season = Season.NONE;
  String name = '';
  String username = '';

  // Student's fields
  Map<Season, ReleaseStatus> releaseStatus = {};
  Map<Season, ReleaseStatus> releaseGroupStatus = {};
  int? teamId;
  String? groupName;
  String? role;

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

  setRole(String role) {
    this.role = role;
  }

  setGroup(int? teamId, String? groupName) {
    this.teamId = teamId;
    this.groupName = groupName;
  }

  setGroupStatus(Season season, ReleaseStatus released) {
    releaseGroupStatus[season] = released;
  }

  setStudentStatus(Season season, ReleaseStatus released) {
    releaseStatus[season] = released;
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
