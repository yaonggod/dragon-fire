class TotalRankingModel {
  final String nickname, score, rank;

  TotalRankingModel.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'],
        score = json['score'],
        rank = json['rank'];
}
