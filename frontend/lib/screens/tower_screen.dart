import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class TowerScreen extends StatefulWidget {
  const TowerScreen({
    super.key,
  });

  @override
  State<TowerScreen> createState() => _TowerScreenState();
}

class _TowerScreenState extends State<TowerScreen> {

  String? nickname;
  String? accessToken;
  String? refreshToken;
  @override
  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    accessToken = tokens['Authorization'];
    refreshToken = tokens['refreshToken'];
    print(refreshToken);
  }

  Future<Map<String, String>> readToken() async {
    const storage = FlutterSecureStorage();
    Map<String, String> list = {};
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');
    String? socialType = await storage.read(key: 'socialType');

    if (accessToken != null && refreshToken != null && socialType != null) {
      list['Authorization'] = accessToken;
      list['refreshToken'] = refreshToken;
      list['socialType'] = socialType;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  }

