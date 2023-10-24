import 'package:flutter/material.dart';
import 'package:frontend/widgets/button_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Column(
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
        backgroundColor: Colors.red[100],
      ),
      body: const Center(
        child: StartBattleButton(),
      ),
    );
  }
}
