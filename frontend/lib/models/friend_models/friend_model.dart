class FriendModel {
  String toMember, toNickname;
  int score, win, lose;

  FriendModel(
      {required this.toMember,
      required this.toNickname,
      required this.score,
      required this.win,
      required this.lose});

  FriendModel.fromJson(Map<String, dynamic> json)
      : toMember = json['toMember'],
        toNickname = json['toNickname'],
        score = json['score'],
        win = json['win'],
        lose = json['lose'];
}
