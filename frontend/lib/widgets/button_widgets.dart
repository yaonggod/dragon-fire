import 'package:flutter/material.dart';
import 'package:frontend/screens/game_screen.dart';

// 탑 스테이지 돌파 이벤트 용 버튼
class StartBattleButton extends StatelessWidget {
  const StartBattleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      },
      child: const Text('전투 시작'),
    );
  }
}
