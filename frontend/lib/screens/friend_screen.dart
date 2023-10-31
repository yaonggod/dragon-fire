import 'package:flutter/material.dart';
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
  bool friendSelected = true;
  late ScrollController scrollController;
  bool isMaxHeightReached = false;
  List<String> friendList = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
  ];

  List<String> notificationList = [
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
      body: Stack(
        children: [
          if (friendSelected == true)
            Positioned(
              top: MediaQuery.of(context).size.height * 53 / 1000,
              width: MediaQuery.of(context).size.width * 10 / 20,
              right: MediaQuery.of(context).size.width * 1 / 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    friendSelected = false;
                  });
                },
                child: Image.asset(
                  'lib/assets/icons/friendState1_1.png',
                ),
              ),
            ),
          if (friendSelected == true)
            Positioned(
              top: MediaQuery.of(context).size.height * 22 / 500,
              width: MediaQuery.of(context).size.width * 10 / 20,
              left: MediaQuery.of(context).size.width * 1 / 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    friendSelected = true;
                  });
                },
                child: Image.asset(
                  'lib/assets/icons/friendState1.png',
                ),
              ),
            ),
          if (friendSelected == false)
            Positioned(
              top: MediaQuery.of(context).size.height * 53 / 1000,
              width: MediaQuery.of(context).size.width * 10 / 20,
              left: MediaQuery.of(context).size.width * 1 / 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    friendSelected = true;
                  });
                },
                child: Image.asset(
                  'lib/assets/icons/friendState2_1.png',
                ),
              ),
            ),
          if (friendSelected == false)
            Positioned(
              top: MediaQuery.of(context).size.height * 22 / 500,
              width: MediaQuery.of(context).size.width * 10 / 20,
              right: MediaQuery.of(context).size.width * 1 / 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    friendSelected = false;
                  });
                },
                child: Image.asset(
                  'lib/assets/icons/friendState2.png',
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).size.height * 46 / 500,
            width: MediaQuery.of(context).size.width * 38 / 40,
            left: MediaQuery.of(context).size.width * 1 / 40,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (friendSelected)
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(top:10.0, bottom:10.0),
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: friendList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage("lib/assets/icons/appIcon.png"),
                                    radius: 30,
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${friendList[index]}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Ranking',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          deleteFriend();
                                        },
                                        child: Text('삭제'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(top:10.0),
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: notificationList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${friendList[index]}가 친추했음',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          deleteFriend();
                                        },
                                        child: Text('삭제'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
