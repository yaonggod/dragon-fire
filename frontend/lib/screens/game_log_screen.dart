import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/models/game_log_model.dart';
import 'package:frontend/screens/game_log_detail_screen.dart';
import 'package:frontend/services/game_log_service.dart';

class GameLogScreen extends StatelessWidget {
  const GameLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<List<GameLogModel>?> gameLogs =
        GameLogService.getGameLogList();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "대전이력",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'lib/assets/icons/background.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          SafeArea(
            child: Center(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SingleChildScrollView(
                        child: Center(
                          child: Text(
                            '최근 다섯개의 대전 이력 조회가 가능합니다.',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder(
                        future: gameLogs,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            var logInfo = snapshot.data!;
                            int indexCnt = logInfo.length;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  fightHistoryBox(
                                    context: context,
                                    indexCnt: indexCnt,
                                    logInfo: logInfo,
                                    curIdx: 0,
                                  ),
                                  const SizedBox(height: 20),
                                  fightHistoryBox(
                                    context: context,
                                    indexCnt: indexCnt,
                                    logInfo: logInfo,
                                    curIdx: 1,
                                  ),
                                  const SizedBox(height: 20),
                                  fightHistoryBox(
                                    context: context,
                                    indexCnt: indexCnt,
                                    logInfo: logInfo,
                                    curIdx: 2,
                                  ),
                                  const SizedBox(height: 20),
                                  fightHistoryBox(
                                    context: context,
                                    indexCnt: indexCnt,
                                    logInfo: logInfo,
                                    curIdx: 3,
                                  ),
                                  const SizedBox(height: 20),
                                  fightHistoryBox(
                                    context: context,
                                    indexCnt: indexCnt,
                                    logInfo: logInfo,
                                    curIdx: 4,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                '최근 대전 이력이 없습니다!',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget fightHistoryBox({
    required BuildContext context,
    required int indexCnt,
    required List<GameLogModel> logInfo,
    required int curIdx,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.15,
      child: indexCnt > curIdx
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameLogDetailScreen(detailGameLog: logInfo[curIdx]),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: logInfo[curIdx].playResult
                        ? Image.asset(
                            'lib/assets/icons/winIcon.png',
                            width: 32,
                            height: 32,
                          )
                        : Image.asset('lib/assets/icons/loseIcon.png'),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              logInfo[curIdx].myNickname,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              logInfo[curIdx].opponentNickname,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: logInfo[curIdx].playResult
                        ? Image.asset(
                            'lib/assets/icons/loseIcon.png',
                            width: 32,
                            height: 32,
                          )
                        : Image.asset('lib/assets/icons/winIcon.png'),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                '대전 이력이 없습니다',
                style: TextStyle(fontSize: 25),
              ),
            ),
    );
  }
}
