class MessageModel {
  String toMember, toNickname, friendStatus;
  String? fcmToken;
  int score, win, lose;

  MessageModel(
      {required this.toMember,
      required this.toNickname,
      required this.friendStatus,
      this.fcmToken,
      required this.score,
      required this.win,
      required this.lose});

  MessageModel.fromJson(Map<String, dynamic> json)
      : toMember = json['toMember'],
        toNickname = json['toNickname'],
        friendStatus = json['friendStauts'],
        fcmToken = json['fcmToken'],
        score = json['score'],
        win = json['win'],
        lose = json['lose'];
}
