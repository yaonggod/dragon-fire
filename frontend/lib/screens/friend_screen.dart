import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/friend_models/friend_model.dart';
import 'package:frontend/models/friend_models/message_model.dart';
import 'package:frontend/models/friend_models/search_result_model.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/friend_widgets/friend_widget.dart';
import 'package:frontend/widgets/friend_widgets/message_widget.dart';
import 'package:frontend/widgets/friend_widgets/search_result_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendScreen extends StatefulWidget {
  final friendSelected;

  const FriendScreen({super.key, required this.friendSelected});

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  // String baseUrl = "http://10.0.2.2:8080";
  String baseUrl = "${dotenv.env["BASE_URL"]!}/api";

  String buttonSrc = 'lib/assets/icons/search.png';

  // 검색할 닉네임
  String searchNickname = "";

  // 검색 결과 상태: 검색 안함(NONE), 검색 결과 없음(FAIL), 검색 결과 있음(SUCCESS)
  String searched = "NONE";

  void showSearch() {
    setState(() {
      searched = "NONE";
    });
    print(searched);
  }

  // 검색 결과
  SearchResultModel? searchResult;

  // 검색해서 SearchResult setState하기
  Future<void> search() async {
    Map<String, String> list = await readToken();
    if (searchNickname.trim() != "") {
      Uri uri = Uri.parse("$baseUrl/friend/search/$searchNickname");
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${list["Authorization"]!}',
        'refreshToken': 'Bearer ${list['refreshToken']!}'
      });
      if (response.statusCode == 200) {
        var jsonString = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        SearchResultModel result = SearchResultModel.fromJson(jsonMap);
        setState(() {
          searchResult = result;
          searched = "SUCCESS";
        });
      } else {
        setState(() {
          searched = "FAIL";
        });
      }
    }
  }

  bool friendSelected = true;

  // 내 친구
  List<FriendModel> friendList = [];

  // 친구 불러오기
  Future<void> getMyFriends() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/friends");
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${list["Authorization"]!}',
      'refreshToken': 'Bearer ${list['refreshToken']!}'
    });

    if (response.statusCode == 200) {
      var jsonString = utf8.decode(response.bodyBytes);
      List<dynamic> jsonMap = jsonDecode(jsonString);
      List<FriendModel> friends = [];
      for (var f in jsonMap) {
        final friend = FriendModel.fromJson(f);
        friends.add(friend);
      }
      setState(() {
        friendList = friends;
      });
    }
  }

  // 내 메시지
  List<MessageModel> messageList = [];
  int messageCount = 0;

  // 메시지 불러오기
  Future<void> getMyMessages() async {
    Map<String, String> list = await readToken();
    Uri uri = Uri.parse("$baseUrl/friend/messages");
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${list["Authorization"]!}',
      'refreshToken': 'Bearer ${list['refreshToken']!}'
    });
    if (response.statusCode == 200) {
      var jsonString = utf8.decode(response.bodyBytes);
      List<dynamic> jsonMap = jsonDecode(jsonString);
      List<MessageModel> messages = [];
      for (var m in jsonMap) {
        final message = MessageModel.fromJson(m);
        messages.add(message);
      }
      setState(() {
        messageList = messages;
        messageCount = messageList.length;
      });
    }
  }

  late ScrollController scrollController;
  bool isMaxHeightReached = false;

  /*
  * 대전전적의 각 전적의 신고버튼으로 이 화면으로 올 수 있음
  *
  * 해당 전적에 대한 신고
  *
  * 신고 상세 정보 적고 제출
   */

  Future<void> _checkLoginStatus() async {
    // await tokenCheck();
    Map<String, String> tokens = await readToken();
    if (tokens.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    // storage에 토큰을 확인하고 로그인 여부 불러오기
    _checkLoginStatus();

    scrollController = ScrollController();
    scrollController.addListener(() {
      // maxheight에 도달했으면
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        setState(() {
          isMaxHeightReached = true;
        });
      } else {
        setState(() {
          isMaxHeightReached = false;
        });
      }
    });
    getMyFriends();
    getMyMessages();
    setState(() {
      friendSelected = widget.friendSelected;
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text("호 적 수", style: TextStyle(fontWeight: FontWeight.w900),),
          centerTitle: true,
        ),
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                child: Image.asset(
                  'lib/assets/icons/background.png',
                  fit: BoxFit.fitHeight,
                ),
              )),
          SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchNickname = value;
                                });
                              },
                              maxLength: 12,
                              style: TextStyle(fontSize: 20, color: Colors.white),
                              decoration: const InputDecoration(
                                fillColor: Colors.white24,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 1),
                                hintText: "닉네임으로 검색하기",
                                hintStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(255,255,255,0.6)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.red),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 3, color: Colors.amber),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: search,
                            onTapUp: (details) {
                              setState(() {
                                buttonSrc = 'lib/assets/icons/search.png';
                              });
                            },
                            onTapDown: (details) {
                              setState(() {
                                buttonSrc = 'lib/assets/icons/searchPressed.png';
                              });
                            },
                            onTapCancel: () => setState(() {
                              buttonSrc = 'lib/assets/icons/search.png';
                            }),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(buttonSrc),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      searched == "FAIL"
                          ? const Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 20),
                          child: Text(
                              "존재하지 않는 유저입니다.",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 18),
                            )
                      )
                          : Container(),
                      searched == "SUCCESS"
                          ? SearchResultWidget(
                              searchResult: searchResult!, onEvent: showSearch)
                          : Container(),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  // 친구 불러오는 api 쏘기
                                  getMyFriends();
                                  friendSelected = true;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: !friendSelected
                                        ? Colors.white
                                        : Colors.red,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: const Text(
                                  "나의 호적수",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  getMyMessages();
                                  friendSelected = false;
                                });
                              },
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      color: !friendSelected
                                          ? Colors.red
                                          : Colors.white,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10))),
                                  child: const Text(
                                    "메시지",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20),
                                  )),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: friendSelected
                                  ? friendList.length
                                  : messageList.length,
                              itemBuilder: (context, index) {
                                if (friendSelected) {
                                  return FriendWidget(
                                      friend: friendList[index]);
                                }
                                return MessageWidget(
                                    message: messageList[index]);
                              }),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
