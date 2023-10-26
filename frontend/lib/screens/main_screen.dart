import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            children: [
              Text(
                '드래곤 불',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton(
                onPressed: _navigateToLoginScreen,
                child: Text("로그인 페이지"),
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
    );
  }
}
