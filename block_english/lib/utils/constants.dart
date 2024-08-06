// ignore_for_file: constant_identifier_names

enum ButtonType {
  FILLED,
  OUTLINED,
}

const List<String> questionList = [
  "좋아하는 색깔은?",
  "좋아하는 음식은?",
  "제일 처음 한 게임 이름은?",
  "내 별명은?",
  "우리 집 어른 이름은?",
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

int seasonToInt(Season season) {
  switch (season) {
    case Season.NONE:
      return 0;
    case Season.SEASON1:
      return 1;
  }
}

Season intToSeason(int intSeason) {
  switch (intSeason) {
    case 1:
      return Season.SEASON1;
    default:
      return Season.NONE;
  }
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
