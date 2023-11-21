class GameLogModel {
  final String myNickname, opponentNickname, myPlay, opponentPlay;
  final bool playResult;

  GameLogModel.fromJson(Map<String, dynamic> json)
      : myNickname = json['myNickname'],
        opponentNickname = json['opponentNickname'],
        playResult = json['playResult'],
        myPlay = json['myPlay'],
        opponentPlay = json['opponentPlay'];
}
