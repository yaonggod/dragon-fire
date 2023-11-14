class FriendModel {
  String toMember, toNickname;
  int score, win, lose, friendWin, friendLose;
  String? fcmToken;
  bool isConnect;

  FriendModel(
      {required this.toMember,
      required this.toNickname,
      required this.score,
      required this.win,
      required this.lose,
        required this.friendWin,
        required this.friendLose,
      this.fcmToken,
      required this.isConnect});

  FriendModel.fromJson(Map<String, dynamic> json)
      : toMember = json['toMember'],
        toNickname = json['toNickname'],
        score = json['score'],
        win = json['win'],
        lose = json['lose'],
        friendWin = json['friendWin'],
        friendLose = json['friendLose'],
        fcmToken = json['fcmToken'],
        isConnect = json['isConnect'];
}
