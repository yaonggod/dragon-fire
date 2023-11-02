class SearchResultModel {
  String toMember, toNickname, friendStatus;
  String? fcmToken;

  SearchResultModel(
      {required this.toMember,
      required this.toNickname,
      required this.friendStatus,
      this.fcmToken});

  SearchResultModel.fromJson(Map<String, dynamic> json)
      : toMember = json['toMember'],
        toNickname = json['toNickname'],
        friendStatus = json['friendStatus'],
        fcmToken = json['fcmToken'];
}
