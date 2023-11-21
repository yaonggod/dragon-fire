class SearchResultModel {
  String toMember, toNickname, friendStatus;
  String? fcmToken;
  int score, win, lose, friendWin, friendLose;

  SearchResultModel(
      {required this.toMember,
      required this.toNickname,
      required this.friendStatus,
      this.fcmToken,
      required this.score,
      required this.win,
      required this.lose,
      required this.friendWin,
      required this.friendLose});

  SearchResultModel.fromJson(Map<String, dynamic> json)
      : toMember = json['toMember'],
        toNickname = json['toNickname'],
        friendStatus = json['friendStatus'],
        fcmToken = json['fcmToken'],
        score = json['score'],
        win = json['win'],
        lose = json['lose'],
        friendWin = json['friendWin'],
        friendLose = json['friendLose'];
}
