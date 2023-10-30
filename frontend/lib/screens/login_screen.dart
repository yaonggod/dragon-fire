import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/regist_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggedIn = false;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    setState(() {
      _isLoggedIn = tokens.isNotEmpty;
    });
  }

  Future<void> googleLogin() async {
    _googleSignIn.disconnect();
    GoogleSignInAccount? account = await _googleSignIn.signIn();

    final accessToken =
        (await _googleSignIn.currentUser!.authentication).accessToken!;

    Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/login");
    // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/login");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"accessToken": accessToken, "socialType": "GOOGLE"}));

    if (response.statusCode != 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistScreen(accessToken: accessToken)),
      );
    }
    if (response.statusCode == 200) {
      String? accessToken1 = response.headers['authorization'];
      String? refreshToken1 = response.headers['refreshtoken'];

      if (accessToken1 != null && refreshToken1 != null) {
        print(accessToken1.substring(7));
        print(refreshToken1.substring(7));
        saveToken(accessToken1.substring(7), refreshToken1.substring(7));
        setState(() {
          _isLoggedIn = true;
        });
      }
    }
  }

  _logout() async {
    Map<String, String> list = await readToken();
    if(list.isNotEmpty) {
      _googleSignIn.signOut();
      Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/logout");
      // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/logout");
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + list["Authorization"]!,
            'refreshToken': 'Bearer ' + list['refreshToken']!
          },
         );

      if (response.statusCode == 200) {
        FlutterSecureStorage storage = new FlutterSecureStorage();
        storage.deleteAll();
        print("로그아웃 완료");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen()),
            (route) => false,
        );
      }
      setState(() {});
    }
  }
  _out() async {
    Map<String, String> list = await readToken();
    if(list.isNotEmpty) {
      _googleSignIn.signOut();
      Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/oauth/out");
      // Uri uri = Uri.parse("http://10.0.2.2:8080/oauth/out");
      final response = await http.delete(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + list["Authorization"]!,
          'refreshToken': 'Bearer ' + list['refreshToken']!
        },
      );

      if (response.statusCode == 200) {
        FlutterSecureStorage storage = new FlutterSecureStorage();
        storage.deleteAll();
        print("탈퇴 완료");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen()),
              (route) => false,
        );
      }
      setState(() {});
    }
  }

  void saveToken(String accessToken, String refreshToken) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<Map<String, String>> readToken() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> list = {};
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      list['Authorization']=accessToken;
      list['refreshToken']=refreshToken;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "로그인",
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            SizedBox(height: MediaQuery.of(context).size.height / 8),
            GestureDetector(
              onTap: googleLogin,
              child: Text("네이버 로그인"),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 8),
            _isLoggedIn == false
                ? GestureDetector(
                    onTap: googleLogin,
                    child: Text("Gmail 로그인"),
                  )
                : Container(),
            _isLoggedIn == true
                ? MaterialButton(
                    color: Colors.red,
                    child: Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _logout();
                      print('Logout button pressed.');
                    },
                  )
                : Container(),
            if(_isLoggedIn)
              MaterialButton(
                color: Colors.red,
                child: Text(
                  '회원탈퇴',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _out();
                  print('회원탈퇴.');
                },
            )
          ],
        ),
      ),
    );
  }
}
