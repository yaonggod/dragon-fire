import 'package:flutter/material.dart';
import 'package:frontend/screens/friend_screen.dart';
import 'package:frontend/screens/myInfo_screen.dart';
import 'package:frontend/screens/ranking_screen.dart';
import 'package:frontend/screens/report_screen.dart';
import 'package:frontend/screens/start_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String buttonsrc = 'lib/assets/icons/startButton.png';
  void _navigateToMyInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyInfoScreen(),
      ),
    );
  }

  void _navigateToStartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StartScreen(),
      ),
    );
  }

  void _navigateToRankingScreen() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: const Color.fromRGBO(0, 0, 132, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: RankingScreen(),
        );
      },
    );
  }

  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportScreen(),
      ),
    );
  }

  void _navigateToFriendScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '드래곤 불',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Text(
              //   '천하제일 쎄쎄쎄',
              //   style: TextStyle(
              //     fontSize: 16,
              //   ),
              // ),
              ElevatedButton(
                onPressed: _navigateToMyInfoScreen,
                child: const Text("내 정보"),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red[100],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.3,),
            GestureDetector(
              onTap: () {
                _navigateToStartScreen();
              },
              onTapDown: (_) {
                setState(() {
                  buttonsrc = 'lib/assets/icons/startButton2.png';
                });
              },
              onTapUp: (_) {
                setState(() {
                  buttonsrc = 'lib/assets/icons/startButton.png';
                });
              },

              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(buttonsrc),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _navigateToRankingScreen,
                  child: const Text("랭킹"),
                ),
                ElevatedButton(
                  onPressed: _navigateToReportScreen,
                  child: const Text("신고"),
                ),
                ElevatedButton(
                  onPressed: _navigateToFriendScreen,
                  child: const Text("친구"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
