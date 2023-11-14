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
                    return Container(
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
                              right: 30,
                              bottom: 15,
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                setMyTierImg(userInfo),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  userInfo.nickname,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                              ],
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
                              leading: topRanking(userInfo),
                              title: Text(
                                userInfo.nickname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Text(
                                '${userInfo.score}점\nwin: ${userInfo.win}  lose: ${userInfo.lose}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              trailing: setTierImg(userInfo),
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
          const Flexible(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, top: 0),
              child: Text(
                "(랭킹은 1분마다 업데이트 됩니다)",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setMyTierImg(MyRankingModel userInfo) {
    int score = int.parse(userInfo.score);
    if (score < 1000) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierBronze.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (1000 <= score && score < 1100) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierSilver.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (1100 <= score && score < 1200) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierGold.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (1200 <= score && score < 1300) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierPlatinum.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierDiamond.png',
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget setTierImg(TotalRankingModel userInfo) {
    int score = int.parse(userInfo.score);
    if (score < 1000) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierBronze.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (1000 <= score && score < 1100) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierSilver.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (1100 <= score && score < 1200) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierGold.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (1200 <= score && score < 1300) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierPlatinum.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          'lib/assets/icons/tierDiamond.png',
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget topRanking(TotalRankingModel userInfo) {
    if (userInfo.rank == '1') {
      return Image.asset(
        'lib/assets/icons/rankFirst.png',
        width: 27,
        height: 27,
      );
    } else if (userInfo.rank == '2') {
      return Image.asset(
        'lib/assets/icons/rankSecond.png',
        width: 27,
        height: 27,
      );
    } else if (userInfo.rank == '3') {
      return Image.asset(
        'lib/assets/icons/rankThird.png',
        width: 27,
        height: 27,
      );
    }
    return Text(
      userInfo.rank,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: Offset(0.5, 0.5),
            blurRadius: 3.0,
            color: Colors.red,
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
