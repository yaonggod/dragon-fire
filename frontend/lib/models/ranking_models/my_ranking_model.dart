class MyRankingModel {
  String nickname, score, rank, win, lose, seasonMaxScore;

  MyRankingModel.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'],
        score = json['score'],
        rank = json['rank'],
        win = json['win'],
        lose = json['lose'],
        seasonMaxScore = json['seasonMaxScore'];
}
