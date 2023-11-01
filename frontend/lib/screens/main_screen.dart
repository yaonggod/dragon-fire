import 'package:flutter/material.dart';
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
        builder: (context) => const LoginScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Column(
            children: [
              Text(
                '드래곤 불',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '천하제일 쎄쎄쎄',
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.red[100],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _navigateToLoginScreen,
            child: const Text("로그인"),
          ),
          ElevatedButton(
            onPressed: _navigateToStartScreen,
            child: const Text("게임"),
          ),
          ElevatedButton(
            onPressed: _navigateToRankingScreen,
            child: const Text("랭킹"),
          ),
          ElevatedButton(
            onPressed: _navigateToReportScreen,
            child: const Text("신고"),
          ),
        ],
      ),
    );
  }
}
