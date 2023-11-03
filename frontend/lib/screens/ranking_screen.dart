import 'package:flutter/material.dart';
import 'package:frontend/models/ranking_models/my_ranking_model.dart';
import 'package:frontend/models/ranking_models/total_ranking_model.dart';
import 'package:frontend/services/ranking_api_services.dart';

class RankingScreen extends StatelessWidget {
  RankingScreen({super.key});

  final Future<List<TotalRankingModel>?> allRankings =
      RankingApiServices.getCurrentSeasonTotalRanking();

  final Future<MyRankingModel?> myRanking = RankingApiServices.getMyRanking();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: FutureBuilder(
                future: myRanking,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    var userInfo = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    bottom: 15,
                                  ),
                                  child: Text(
                                    userInfo.nickname,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    userRankingScore(
                                      rankInfo: userInfo.rank,
                                      scoreInfo: userInfo.score,
                                    ),
                                    userWinLose(
                                      winInfo: userInfo.win,
                                      loseInfo: userInfo.lose,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                '비무대회 등록증',
                                style: TextStyle(
                                  color: Color.fromRGBO(238, 58, 58, 1),
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      width: MediaQuery.of(context).size.width - 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '[등록 정보 없음]',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: FutureBuilder(
              future: allRankings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        itemBuilder: (context, index) {
                          var userInfo = snapshot.data![index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: Text(
                                '${userInfo.rank}등',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(238, 58, 58, 1),
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 3.0,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(
                                userInfo.nickname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              subtitle: Text(
                                '${userInfo.score}점  win: ${userInfo.win}  lose: ${userInfo.lose}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemCount: snapshot.data!.length,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '정보가 없습니다!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget userRankingScore({
    required String rankInfo,
    required String scoreInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: SizedBox(
                width: double
                    .infinity, // 두 번째 Flexible 위젯이 왼쪽부터 시작하도록 너비를 최대한으로 설정합니다.
                child: Text(
                  '순위: $rankInfo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: SizedBox(
                width: double
                    .infinity, // 두 번째 Flexible 위젯이 왼쪽부터 시작하도록 너비를 최대한으로 설정합니다.
                child: Text(
                  '점수: $scoreInfo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userWinLose({
    required String winInfo,
    required String loseInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: SizedBox(
                width: double
                    .infinity, // 두 번째 Flexible 위젯이 왼쪽부터 시작하도록 너비를 최대한으로 설정합니다.
                child: Text(
                  '승: $winInfo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: SizedBox(
                width: double
                    .infinity, // 두 번째 Flexible 위젯이 왼쪽부터 시작하도록 너비를 최대한으로 설정합니다.
                child: Text(
                  '패: $loseInfo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
