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
      for (int i = 0; i < 100 && i < totalRankings.length; i++) {
        totalRankingInstances.add(TotalRankingModel.fromJson(totalRankings[i]));
      }
      return totalRankingInstances;
    }
    throw Error();
  }

  // 내 랭킹 정보 가져오기
  // static Future<Map<String, dynamic>> getMyRanking() async {
  //   Map<String, dynamic> myRankingInstance = {};
  //   final url = Uri.parse('$baseUrl/rank/my');
  //   final response = await http.get(url, headers: {});
  //   throw Error();
  // }
}
