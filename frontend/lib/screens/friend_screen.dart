import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/models/friend_models/search_result_model.dart';
import 'package:frontend/widgets/friend_widgets/friend_widget.dart';
import 'package:frontend/widgets/friend_widgets/message_widget.dart';
import 'package:frontend/widgets/friend_widgets/search_result_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  // String baseUrl = dotenv.get("base_url");

  // 검색할 닉네임
  String searchNickname = "";
  // 검색 결과 상태: 검색 안함(NONE), 검색 결과 없음(FAIL), 검색 결과 있음(SUCCESS)
  String searched = "NONE";
  // 검색 결과
  SearchResultModel? searchResult;

  // 검색해서 SearchResult setState하기
  Future<void> search() async {
    Map<String, String> list = await readToken();
    if (searchNickname.trim() != "") {
      Uri uri = Uri.parse("https://k9a209.p.ssafy.io/api/friend/search/$searchNickname");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${list["Authorization"]!}',
          'refreshToken': 'Bearer ${list['refreshToken']!}'
        }
      );
      print(response.statusCode);
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

  Widget searchResultWidget() {
    if (searched == "NONE") {
      return Container();
    } else if (searched == "FAIL") {
      return const Text(
        "존재하지 않는 유저입니다.",
        style: TextStyle(color: Colors.red),
      );
    } else {
      // 검색 결과 카드
      return SearchResultWidget(searchResult: searchResult!,);
    }
  }

  bool friendSelected = true;

  // 친구 불러오기
  Future<void> getMyFriends() async {}

  late ScrollController scrollController;
  bool isMaxHeightReached = false;
  List<String> friendList = [
    'Alice1',
    'Bob2',
    'Charlie3',
    'David4',
    'Eve5',
    'Alice6',
    'Bob7',
    'Charlie8',
    'David9',
    'Eve10',
    'Alice11',
    'Bob12',
    'Charlie13',
    'David14',
    'Eve15',
    'Alice16',
    'Bob17',
    'Charlie18',
    'David19',
    'Eve20',
    'Alice21',
    'Bob22',
    'Charlie23',
    'David24',
    'Eve25',
    'Alice26',
    'Bob27',
    'Charlie28',
    'David29',
    'Eve30',
  ];

  List<String> messageList = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
  ];

  // 구글
  // 구글 로그인 여부
  bool _googleLoggedIn = false;

  // 구글 로그인 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 네이버
  // 네이버 로그인 결과 객체: loggedIn, cancelledByUser, error
  bool _naverLoginStatus = false;

  // 네이버 로그인 객체
  NaverLoginResult? _naverLoginResult;

  /*
  * 대전전적의 각 전적의 신고버튼으로 이 화면으로 올 수 있음
  *
  * 해당 전적에 대한 신고
  *
  * 신고 상세 정보 적고 제출
   */
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
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // initState할때 토큰 존재 여부 확인해서 로그인 status 상태 저장하기
  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    print(tokens.toString());
    print(tokens.isNotEmpty);
    print(tokens);
    if (tokens.isNotEmpty && tokens['socialType'] == "GOOGLE") {
      print(1);
      setState(() {
        // 토큰이 있을 경우에 로그인한 서비스에 따라서 상태 설정하기
        _googleLoggedIn = true;
      });
    } else if (tokens.isNotEmpty && tokens['socialType'] == "NAVER") {
      print(2);
      setState(() {
        // 토큰이 있을 경우에 로그인한 서비스에 따라서 상태 설정하기
        _naverLoginStatus = true;
      });
    }

    print(_googleLoggedIn);
    print(_naverLoginStatus);
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

  Future<void> _onDeleteCourse() async {}

  Future<void> deleteFriend() async {
    // final response = await http.get(Uri.parse('https://k9a209.p.ssafy.io/api/friend/disconnect'));
    // if (response.statusCode == 200) {

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('호적수',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchNickname = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "닉네임으로 검색하기",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: search,
                  child: const Icon(
                    Icons.search,
                    size: 40,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            searchResultWidget(),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // 친구 불러오는 api 쏘기
                        friendSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: !friendSelected ? Colors.white : Colors.red,
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
                        friendSelected = false;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: !friendSelected ? Colors.red : Colors.white,
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
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.red)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        friendSelected ? friendList.length : messageList.length,
                    itemBuilder: (context, index) {
                      if (friendSelected) {
                        return FriendWidget(nickname: friendList[index]);
                      }
                      return MessageWidget(nickname: messageList[index]);
                    }),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
