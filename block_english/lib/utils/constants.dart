// ignore_for_file: constant_identifier_names

enum ButtonType {
  FILLED,
  OUTLINED,
}

const List<String> gradelist = [
  "1학년",
  "2학년",
  "3학년",
  "4학년",
  "5학년",
  "6학년",
];

const List<String> levellist = [
  "어순과 격",
  "부정문",
  "의문문",
];

enum StudentMode {
  PRIVATE,
  GROUP,
  NONE,
}

enum Season {
  NONE,
  SEASON1,
}

String seasonToString(Season season) {
  switch (season) {
    case Season.NONE:
      return 'none';
    case Season.SEASON1:
      return 'Season 1';
  }
}

const String BASEURL = 'http://3.34.58.76';
const String ACCESSTOKEN = 'accessToken';
const String REFRESHTOKEN = 'refreshToken';
const String TOKENVALIDATE = 'tokenValidate';
