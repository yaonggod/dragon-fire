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
    Widget myHistoryImg({
      required String skillName,
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
      } else {
        return Image.asset(
          'lib/assets/skills/meteorPlayer.gif',
          width: 64,
          height: 64,
        );
      }
    }

    Widget optHistoryImg({
      required String skillName,
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
      } else {
        return Image.asset(
          'lib/assets/skills/meteorRival.gif',
          width: 64,
          height: 64,
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: divideRound(
                              optHistoryImg,
                              myHistoryImg,
                              detailGameLog,
                              index,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemCount: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget divideRound(
    Widget Function({
      required String skillName,
    }) optHistoryImg,
    Widget Function({
      required String skillName,
    }) myHistoryImg,
    GameLogModel detailGameLog,
    int roundNum,
  ) {
    var myPlay = detailGameLog.myPlay.split('_');
    var opponentPlay = detailGameLog.opponentPlay.split('_');

    var curMyRound = myPlay[roundNum].split(':');
    var curOptRound = opponentPlay[roundNum].split(':');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Round ${roundNum + 1}',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontStyle: FontStyle.italic,
          ),
        ),
        myPlay[roundNum].isNotEmpty
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
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  optHistoryImg(
                                    skillName: curOptRound[index],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  myHistoryImg(
                                    skillName: curMyRound[index],
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 30),
                            itemCount: curMyRound.length - 1,
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
            : const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  '대전 이력이 없습니다!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
      ],
    );
  }
}
