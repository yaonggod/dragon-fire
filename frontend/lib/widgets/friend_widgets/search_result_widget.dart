import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/friend_models/search_result_model.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchResultWidget extends StatefulWidget {
  final SearchResultModel searchResult;
  final VoidCallback onEvent;

  const SearchResultWidget({super.key, required this.searchResult, required this.onEvent});

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  // String baseUrl = "http://10.0.2.2:8080";
  String baseUrl = "${dotenv.env["BASE_URL"]!}/api";

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

  Widget showButton(context) {
    if (widget.searchResult.friendStatus == "NONE" || widget.searchResult.friendStatus == "DISCONNECTED") {
      return GestureDetector(
          onTap: () async {

            bool result = await requestFriend();
            widget.onEvent();
            _requestResultDialog(context, result);
          },

          child: Text("친구 신청하기"));
    } else if (widget.searchResult.friendStatus == "WAITING") {
      return Text("수락 대기중");
    }

    return Container();
  }

  Future<void> _requestResultDialog(BuildContext context, bool result) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            result ?
            '${widget.searchResult.toNickname}님께 친구 신청을 보냈습니다.' :
            "친구 요청에 실패했습니다.",
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);

              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> requestFriend() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/request");
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        },
        body: jsonEncode(
            {"toMember": widget.searchResult.toMember}));

    const storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');
    if (response.statusCode == 200) {
      // firebase AT
      print(response.headers["firebase"] != null ? response.headers["firebase"] : "null");

      final response2 = await http.post(Uri.parse("https://fcm.googleapis.com/v1/projects/dragon-fire-829f8/messages:send"),
        headers: {
          'Authorization': response.headers["firebase"]!
        },
        body: jsonEncode(
            {
              "message": {
                "notification": {
                  "title": "dragon-fire",
                  "body": "멍멍123님이 당신을 그룹에 초대하려 합니다."
                },
                "data": {
                  "do": "group"
                },
                "token": "cERGr2e3RVCtBwgzD12PR7:APA91bEnIevNJCmdFG78vlIg6EeIfCbjFgK66TuByuM0EZh3zPtiOQA2sgkKjfZyhinL_VgxaZ15iQoHgR0-cznxXx7LawEbFyx8GCJaTlM1zcqBK4-aQE53KyS2BxgOcaFH6YPco3dd"
              }
            }
        )
      );
      print(response2.statusCode);

      return true;
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(0, 0, 0, 0.5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage:
                  AssetImage("lib/assets/icons/appIcon.png"),
                  radius: 30,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.searchResult.toNickname, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${widget.searchResult.score.toString()}점 ${widget.searchResult.win.toString()}승 ${widget.searchResult.lose.toString()}패"),
                    widget.searchResult.friendStatus == "FRIEND" ? Text("상대 전적 ${widget.searchResult.friendWin}승 ${widget.searchResult.friendLose}패") : Container(),
                  ],
                ),

              ],
            ),
            showButton(context),
          ],
        ),
      ),
    );
  }
}