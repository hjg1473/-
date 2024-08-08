// ignore_for_file: constant_identifier_names

enum UserType {
  student,
  teacher,
  parent,
}

enum ButtonType {
  FILLED,
  OUTLINED,
}

const List<String> questionList = [
  "내가 좋아하는 색깔은?",
  "내가 가장 좋아하는 캐릭터는?",
  "제일 처음 한 게임 이름은?",
  "내가 좋아하는 나의 별명은?",
  "나의 보물 제 1호는?",
  "내가 제일 존경하는 인물은?"
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

enum BlockColor { skyblue, pink, green, yellow, purple, none }

BlockColor stringToBlockColor(String str) {
  switch (str) {
    case 'skyblue':
      return BlockColor.skyblue;
    case 'pink':
      return BlockColor.pink;
    case 'green':
      return BlockColor.green;
    case 'yellow':
      return BlockColor.yellow;
    case 'purple':
      return BlockColor.purple;
    default:
      return BlockColor.none;
  }
}

enum StudyMode {
  practice,
  expert,
  game,
  retry,
  none,
}

const String BASEURL = 'http://3.34.58.76';
const String ACCESSTOKEN = 'accessToken';
const String REFRESHTOKEN = 'refreshToken';
const String TOKENVALIDATE = 'tokenValidate';
