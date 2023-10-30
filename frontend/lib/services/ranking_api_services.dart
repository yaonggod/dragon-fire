import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/models/ranking_models/total_ranking_model.dart';

class RankingApiServices {
  static const String baseUrl = 'https://k9a209.p.ssafy.io/api';

  // 현재 주차 전체 랭킹, token 불필요
  static Future<List<TotalRankingModel>> getCurrentSeasonTotalRanking() async {
    List<TotalRankingModel> totalRankingInstances = [];
    final url = Uri.parse('$baseUrl/rank');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonString = utf8.decode(response.bodyBytes);
      final totalRankings = jsonDecode(jsonString);
      for (var totalRanking in totalRankings) {
        totalRankingInstances.add(TotalRankingModel.fromJson(totalRanking));
      }
      return totalRankingInstances;
    }
    throw Error();
  }
}
