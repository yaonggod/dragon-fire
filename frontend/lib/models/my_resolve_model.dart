class MyResolveModel {
  final String nickname, content;

  MyResolveModel.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'],
        content = json['content'];
}
