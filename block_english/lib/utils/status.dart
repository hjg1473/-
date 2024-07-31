import 'package:block_english/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status.g.dart';

class Status {
  StudentMode studentMode = StudentMode.NONE;

  setStudentMode(StudentMode mode) {
    studentMode = mode;
  }
}

@Riverpod(keepAlive: true)
Status status(StatusRef ref) {
  return Status();
}
