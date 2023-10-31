import 'package:flutter/material.dart';
import 'package:frontend/screens/access_screen.dart';
import 'package:frontend/screens/main_screen.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DragonG());
}

class DragonG extends StatelessWidget {
  const DragonG({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '드래곤 불',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const AccessScreen(),
    );
  }
}
