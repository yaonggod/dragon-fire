import 'package:flutter/material.dart';
import 'package:frontend/models/game_log_model.dart';

class GameLogDetailScreen extends StatelessWidget {
  const GameLogDetailScreen({
    super.key,
    required this.detailGameLog,
  });
  final GameLogModel detailGameLog;
  @override
  Widget build(BuildContext context) {
    var myPlay = detailGameLog.myPlay.split('_');
    var opponentPlay = detailGameLog.opponentPlay.split('_');

    var myRound1 = myPlay[0].split(':');
    var myRound2 = myPlay[1].split(':');
    var myRound3 = myPlay[2].split(':');

    var optRound1 = opponentPlay[0].split(':');
    var optRound2 = opponentPlay[1].split(':');
    var optRound3 = opponentPlay[2].split(':');

    Widget myHistoryImg({
      required String skillName,
      required bool winLose,
    }) {
      if (skillName == '기') {
        return Image.asset(
          'lib/assets/skills/charging.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '파') {
        return Image.asset(
          'lib/assets/skills/newFireBallPlayer.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '막기') {
        return Image.asset(
          'lib/assets/skills/fireShield.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '순간이동') {
        return Image.asset(
          'lib/assets/skills/blink.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '원기옥') {
        return Image.asset(
          'lib/assets/skills/meteorPlayer.gif',
          width: 64,
          height: 64,
        );
      } else {
        return winLose
            ? Image.asset(
                'lib/assets/icons/winIcon.png',
                width: 64,
                height: 64,
              )
            : Image.asset(
                'lib/assets/icons/loseIcon.png',
                width: 64,
                height: 64,
              );
      }
    }

    Widget optHistoryImg({
      required String skillName,
      required bool winLose,
    }) {
      if (skillName == '기') {
        return Image.asset(
          'lib/assets/skills/charging.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '파') {
        return Image.asset(
          'lib/assets/skills/newFireBallRival.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '막기') {
        return Image.asset(
          'lib/assets/skills/fireShield.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '순간이동') {
        return Image.asset(
          'lib/assets/skills/blink.gif',
          width: 64,
          height: 64,
        );
      } else if (skillName == '원기옥') {
        return Image.asset(
          'lib/assets/skills/meteorRival.gif',
          width: 64,
          height: 64,
        );
      } else {
        return winLose
            ? Image.asset(
                'lib/assets/icons/winIcon.png',
                width: 64,
                height: 64,
              )
            : Image.asset(
                'lib/assets/icons/loseIcon.png',
                width: 64,
                height: 64,
              );
      }
    }

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
            child: Column(
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Round 1',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 15,
                              ),
                              child: Text(
                                detailGameLog.opponentNickname,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 150,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            optHistoryImg(
                                              skillName: optRound1[index],
                                              winLose:
                                                  !detailGameLog.playResult,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            myHistoryImg(
                                              skillName: myRound1[index],
                                              winLose: detailGameLog.playResult,
                                            ),
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 30),
                                      itemCount: myRound1.length,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              child: Text(
                                detailGameLog.myNickname,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Round 2',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15,
                            ),
                            child: Text(
                              detailGameLog.opponentNickname,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            child: Expanded(
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      optHistoryImg(
                                        skillName: optRound2[index],
                                        winLose: !detailGameLog.playResult,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      myHistoryImg(
                                        skillName: myRound2[index],
                                        winLose: detailGameLog.playResult,
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 30),
                                itemCount: myRound2.length,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: Text(
                              detailGameLog.myNickname,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Round 3',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      myPlay[2].isNotEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    detailGameLog.opponentNickname,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 150,
                                  child: Expanded(
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            optHistoryImg(
                                              skillName: optRound3[index],
                                              winLose:
                                                  !detailGameLog.playResult,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            myHistoryImg(
                                              skillName: myRound3[index],
                                              winLose: detailGameLog.playResult,
                                            ),
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 30),
                                      itemCount: myRound3.length,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    detailGameLog.myNickname,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                child: Text(
                                  '해당 라운드 정보가 없습니다!',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
