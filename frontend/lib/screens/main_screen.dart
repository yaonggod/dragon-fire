import 'package:flutter/material.dart';
import 'package:frontend/screens/friend_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/ranking_screen.dart';
import 'package:frontend/screens/report_screen.dart';
import 'package:frontend/screens/start_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RankingScreen(),
      ),
    );
  }

  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(),
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
                onPressed: _navigateToLoginScreen,
                child: const Text("로그인"),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red[100],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.5,),
            InkWell(
              onTap: _navigateToStartScreen,
              child: Image.asset(
                'lib/assets/icons/startButton.png',
                width: 100,
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
