import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/gameResult_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibration/vibration.dart';

class TowerScreen extends StatefulWidget {
  final int nowFloor;
  final String nickname;
  final int roomNumber;

  const TowerScreen({
    super.key,
    required this.nowFloor,
    required this.nickname,
    required this.roomNumber,
  });

  @override
  State<TowerScreen> createState() => TowerScreenState();
}

class TowerScreenState extends State<TowerScreen> {
  late final StompClient stompClient;
  String countdown = '';
  String winner = '';
  int pan = 0; // 몇 번 째 판인지 // round와는 다르다
  DateTime? backPressed;
  String youPick = '';
  String mePick = '';
  String myHp = '2';
  String youHp = '5';
  bool isWaiting = false; // 대기 화면 보여주기
  bool isConnected = false;
  bool isGameStart = false;
  bool isResult = false; // 순간 순간의 결과창을 보여주는 페이지
  bool isGameOver = false; // 게임이 끝났는지를 확인하는 변수
  String? contender = "동탄불주먹";
  bool isGi = false; // 기
  bool isPa = false; // 파
  bool isBlock = false; // 막기
  bool isTel = false; // 텔레포트
  bool isBomb = false; // 원기옥
  bool isPan = false; // 몇 번째 판인지를 보여주기 위해서
  String? nickname1;
  String dragon='';
  int? myWin;
  int? myLose;
  int? myScore;
  String? nickname2;
  int? contenderWin;
  int? contenderLose;
  int? contenderScore;
  bool countdownChange = true;

  bool isGiPressed = false; // 기
  bool isPaPressed = false; // 파
  bool isBlockPressed = false; // 막기
  bool isTelPressed = false; // 텔레포트
  bool isBombPressed = false; // 원기옥

  bool showResult = false; // 결과 페이지 창
  bool showTemp = false;
  bool isMiss = false;
  bool isTie = false; // 무효를 표현하기 위한 창
  String solo = 'true';

  int giCnt = 0;
  int round = 0; // 몇번 째 라운드인지를 판단해야한다.

  String? nickname;
  String? accessToken;
  String? refreshToken;

  String buttonGi = "lib/assets/icons/buttonGi.png";
  String buttonOne = "lib/assets/icons/buttonOne.png";
  String buttonPa = "lib/assets/icons/buttonPa.png";
  String buttonShield = "lib/assets/icons/buttonShield.png";
  String buttonTele = "lib/assets/icons/buttonTele.png";
  String giIcon = "lib/assets/icons/giStatus.png";

  bool? _isVibrate;
  bool _isHaptic = true;

  Future<bool?> getVibrate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibrate');
  }

  Future<bool?> getHaptic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('haptic');
  }

  Future<bool> endApp() async {
    DateTime curTime = DateTime.now();

    if (backPressed == null ||
        curTime.difference(backPressed!) > const Duration(seconds: 2)) {
      backPressed = curTime;

      bool exit = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: Colors.grey,
            titlePadding: const EdgeInsets.only(right: 5),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                padding: const EdgeInsets.all(7),
                child: const Text(
                  "드래곤 불",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            contentPadding: const EdgeInsets.only(right: 5),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                isWaiting
                    ? '게임 대기열에서 나가시겠습니까?'
                    : '게임에서 나가시겠습니까?\n(※ 퇴장시 패배 처리됩니다)',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            actionsPadding: const EdgeInsets.only(bottom: 15),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('취소', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('확인', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ],
          );
        },
      );
      if (exit == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> _checkLoginStatus() async {
    Map<String, String> tokens = await readToken();
    _isVibrate = await getVibrate();
    _isHaptic = await getHaptic() ?? true;
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

  void onConnect(StompFrame frame) {
    if(widget.nowFloor==1){
      dragon='redBoss';
    }else if(widget.nowFloor==2){
      dragon='purpleBoss';
    }else if(widget.nowFloor==3){
      dragon='greenBoss';
    }
    print(widget.nowFloor);
    setState(() {
      isWaiting = true; // 연결이 성공하면 상태 변수를 true로 설정
      // 한 명이 접속했을 때 상대방을 기다려야 하는 상황이기에 isWaiting을 true로 해서
      // 대기화면을 보여준다. => 즉 2명이 들어오는 순간 isWaiting은 false가 될 것이다.
    });

    stompClient.subscribe(
      destination: '/sub/${widget.nickname}/ready',
      callback: (frame) {
        // 원하는 작업 수행
        print("게임시작을 위한 준비가 완료되었습니다");
        if (frame.body == '0') {
          setState(() {
            isWaiting = false;
            isConnected = true;
          });
          solo = 'false';
          round += 1;
          Timer(const Duration(milliseconds: 3000), () {
            showPan();
          });
        } else if (frame.body == '에러입니다') {
          // 내가 짝수번째 사람인데 방에 혼자 남아 있는경우?
          // 즉 내가 짝수번째로 들어가는 순간 홀수 번째 사람이 나가버린 경우
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.grey,
                titlePadding: const EdgeInsets.only(right: 5),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: const Text(
                      "드래곤 불",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                contentPadding: const EdgeInsets.only(right: 5),
                content: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    "상대가 떠났습니다.",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                actionsPadding: const EdgeInsets.only(bottom: 15),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                        padding: const EdgeInsets.all(7),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                                  (route) => false,
                            );
                          },
                          child: const Text('확인', style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ],

              );
            },
          );
        }
      },
    );

    stompClient.subscribe(
      // 카운트 다운 부분을 위한 subscriber
      destination: '/sub/${widget.nickname}/countdown',
      callback: (frame) {
        // 원하는 작업 수행
        setState(() {
          countdown = frame.body ?? '0'; // frame.body가 null이면 '0'을 할당
          if (countdown == '3') {
            setState(() {
              isGiPressed = false;
              isBlockPressed = false;
              isBombPressed = false;
              isPaPressed = false;
              isTelPressed = false;
              youPick = '';
              mePick = '';
              showTemp = false;
              isWaiting = false;
              isConnected = false;
              isPan = false;
              isGameStart = true;
              isGi = true;
              isPa = true;
              isBlock = true;
              isTel = true;
              isBomb = true;
            });
          }
        });
        // if(countdown!='0'){
        // 3,2,1 을 받을 때
        sendTime(countdown);
        // }
      },
    );
    stompClient.subscribe(
      // 카운트 다운 도중 한쪽 이상에서 응답이 없는 경우
      destination: '/sub/${widget.nickname}/error',
      callback: (frame) {
        // 원하는 작업 수행

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: Colors.grey,
              titlePadding: const EdgeInsets.only(right: 5),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                  padding: const EdgeInsets.all(7),
                  child: const Text(
                    "드래곤 불",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              contentPadding: const EdgeInsets.only(right: 5),
              content: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  "아무것도 선택하지 않았습니다.",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              actionsPadding: const EdgeInsets.only(bottom: 15),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                      padding: const EdgeInsets.all(7),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainScreen()),
                                (route) => false,
                          );
                        },
                        child: const Text('확인', style: TextStyle(color: Colors.white),),
                      ),
                    )
                  ],
                ),
              ],

            );
          },
        );
      },
    );
    // 무엇을 선택했는지 보여주는 창
    stompClient.subscribe(
      // 서버에서 카운트 다운이 0이 되는 순간! String을 반환해서
      // 각자 무엇을 선택했는지를 확인하여 gif를 보여준다.
      destination: '/sub/${widget.nickname}/selected',
      callback: (frame) {
        String frameBody = ' ${frame.body}';
        List<String> parts = frameBody.split(' ');

        String part1 = parts[0];
        String part2 = parts[1];
        String part3 = parts[2];
        String part4 = parts[3];
        String part5 = parts[4];
        List<String> section1 = part3.split(':');
        String user1 = section1[0];
        String picked1 = section1[1];
        List<String> section2 = part4.split(':');
        String user2 = section2[0];
        String picked2 = section2[1];

        if (widget.nickname == user1) {
          if (picked1 == '기') {
            mePick = 'charging';
            if (picked2 == '기') {
              youPick = 'charging';
            } else if (picked2 == '파') {
              youPick = 'fireballRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            } else if (picked2 == '막기') {
              youPick = 'fireShield';
            } else if (picked2 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked2 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '파') {
            mePick = 'fireballPlayer';
            if (picked2 == '기') {
              youPick = 'charging';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            } else if (picked2 == '파') {
              youPick = 'fireballRival';
            } else if (picked2 == '막기') {
              youPick = 'fireShield';
            } else if (picked2 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked2 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else {
              youPick = '미처리';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            }
          } else if (picked1 == '막기') {
            mePick = 'fireShield';
            if (picked2 == '기') {
              youPick = 'charging';
            } else if (picked2 == '파') {
              youPick = 'fireballRival';
            } else if (picked2 == '막기') {
              youPick = 'fireShield';
            } else if (picked2 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked2 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '순간이동') {
            mePick = 'teleportation';
            if (picked2 == '기') {
              youPick = 'charging';
            } else if (picked2 == '파') {
              youPick = 'fireballRival';
            } else if (picked2 == '막기') {
              youPick = 'fireShield';
            } else if (picked2 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked2 == '원기옥') {
              youPick = 'meteorRival';
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '원기옥') {
            mePick = 'meteorPlayer';
            if (picked2 == '기') {
              youPick = 'charging';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else if (picked2 == '파') {
              youPick = 'fireballRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else if (picked2 == '막기') {
              youPick = 'fireShield';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else if (picked2 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked2 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 200);
              }
            } else {
              youPick = '미처리';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            }
          } else {
            mePick = '미처리';
            if (picked2 == '기') {
              youPick = 'charging';
            } else if (picked2 == '파') {
              youPick = 'fireballRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            } else if (picked2 == '막기') {
              youPick = 'fireShield';
            } else if (picked2 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked2 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 200);
              }
            } else {
              youPick = '미처리';
            }
          }
        } else if (widget.nickname == user2) {
          if (picked2 == '기') {
            mePick = 'charging';
            if (picked1 == '기') {
              youPick = 'charging';
            } else if (picked1 == '파') {
              youPick = 'fireballRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            } else if (picked1 == '막기') {
              youPick = 'fireShield';
            } else if (picked1 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked1 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '파') {
            mePick = 'fireballPlayer';
            if (picked1 == '기') {
              youPick = 'charging';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            } else if (picked1 == '파') {
              youPick = 'fireballRival';
            } else if (picked1 == '막기') {
              youPick = 'fireShield';
            } else if (picked1 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked1 == '원기옥') {
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
              youPick = 'meteorRival';
            } else {
              youPick = '미처리';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            }
          } else if (picked2 == '막기') {
            mePick = 'fireShield';
            if (picked1 == '기') {
              youPick = 'charging';
            } else if (picked1 == '파') {
              youPick = 'fireballRival';
            } else if (picked1 == '막기') {
              youPick = 'fireShield';
            } else if (picked1 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked1 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '순간이동') {
            mePick = 'teleportation';
            if (picked1 == '기') {
              youPick = 'charging';
            } else if (picked1 == '파') {
              youPick = 'fireballRival';
            } else if (picked1 == '막기') {
              youPick = 'fireShield';
            } else if (picked1 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked1 == '원기옥') {
              youPick = 'meteorRival';
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '원기옥') {
            mePick = 'meteorPlayer';
            if (picked1 == '기') {
              youPick = 'charging';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else if (picked1 == '파') {
              youPick = 'fireballRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else if (picked1 == '막기') {
              youPick = 'fireShield';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else if (picked1 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked1 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 200);
              }
            } else {
              youPick = '미처리';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            }
          } else {
            mePick = '미처리';
            if (picked1 == '기') {
              youPick = 'charging';
            } else if (picked1 == '파') {
              youPick = 'fireballRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 50);
              }
            } else if (picked1 == '막기') {
              youPick = 'fireShield';
            } else if (picked1 == '순간이동') {
              youPick = 'teleportation';
            } else if (picked1 == '원기옥') {
              youPick = 'meteorRival';
              if(_isVibrate != null && _isVibrate!){
                Vibration.vibrate(amplitude: 128);
              }
            } else {
              youPick = '미처리';
            }
          }
        }
        if (part2 == '3') {
          // 3초의 시간을 주는데 한 번만 3,2,1 이렇게 값이 넘어온다.
          // 그 중 한 번만 화면을 새로 고침하기 위해서
          setState(() {
            isGameStart = false;
            showResult = false;
            isPan = false;
            showTemp = true;
            isGi = false; // 기
            isPa = false; // 파
            isBlock = false; // 막기
            isTel = false; // 텔레포트
            isBomb = false; // 원기옥
            isTie = false;
          });
        }
      },
    );
    // 각 게임의 결과값 반환을 위한 subscriber
    stompClient.subscribe(
      destination: '/sub/${widget.nickname}/result',
      callback: (frame) {
        print('result가 현재 실행되고 있습니다');
        String frameBody = ' ${frame.body}';
        List<String> parts = frameBody.split(' ');
        String comparing = parts[3];
        String shouldContinue = parts[4];
        String missCheck = parts[5];
        print(missCheck);
        // 이게 명중인지 여부를 보여주는 것
        if (missCheck == '명중!') {
          isMiss = false;
        } else {
          isMiss = true;
        }
        print("제일 중요한 부분을 출력합니다.");
        print(shouldContinue); // 이게 게임을 끝낼지 여부를 선택하는 것이다.
        List<String> section1 = parts[1].split(':');
        String user1 = section1[0];
        print(comparing);
        if (comparing == '비겼습니다') {
          // 비겼으니까 다시 게임을 진행해야함
          // 이 때 기를 가져온다.
          startGame();
          print('재경기를 실시합니다');
        } else if (comparing == '무효입니다') {
          // 둘 다 선택을 하지 않은 경우
          // 몇 번 째 게임인지와 상관없이 무조건 게임을 끝냅니다.
          print("둘 다 아무것도 선택하지 않았습니다.");

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.grey,
                titlePadding: const EdgeInsets.only(right: 5),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: const Text(
                      "드래곤 불",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                contentPadding: const EdgeInsets.only(right: 5),
                content: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    "패배!!!",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                actionsPadding: const EdgeInsets.only(bottom: 15),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                        padding: const EdgeInsets.all(7),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                                  (route) => false,
                            );
                          },
                          child: const Text('확인', style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ],

              );
            },
          );
        } else {
          if (shouldContinue == '계속합니다') {
            // 아직 2승을 한 사람이 없기에 게임을 계속해야 한다는 것을 의미한다.
            // 그럼 이때는 처음부터 게임을 시작해야 한다.
            round = 0;
            showPan();
            // 새로운 게임을 시작하는데 가장 중요한 요소가 뭘까? 일단 기 정보를 초기화 해줘야 한다.
          } else if (shouldContinue == '끝냅니다') {
            // 2승을 한 유저가 있기에 해당 유저를 승자로 선언합니다.
            winner = comparing; // 그 판의 승자를 의미한다.
            setState(() {
              showTemp = false;
              isGameStart = false;
              isPan = false;
              showResult = true;
              isGi = false; // 기
              isPa = false; // 파
              isBlock = false; // 막기
              isTel = false; // 텔레포트
              isBomb = false; // 원기옥
            });
            // dispose();
            if (widget.nickname == winner) {
              print("내가 승자입니다");
              sendResult();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    backgroundColor: Colors.grey,
                    titlePadding: const EdgeInsets.only(right: 5),
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                        padding: const EdgeInsets.all(7),
                        child: const Text(
                          "드래곤 불",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    contentPadding: const EdgeInsets.only(right: 5),
                    content: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        '승리하였습니다. 다음 단계에 도전 가능!',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),

                    actionsPadding: const EdgeInsets.only(bottom: 15),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                            padding: const EdgeInsets.all(7),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainScreen()),
                                      (route) => false,
                                );
                              },
                              child: const Text('메인으로 돌아가기', style: TextStyle(color: Colors.white),),
                            ),
                          )
                        ],
                      ),
                    ],

                  );
                },
              );


            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    backgroundColor: Colors.grey,
                    titlePadding: const EdgeInsets.only(right: 5),
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                        padding: const EdgeInsets.all(7),
                        child: const Text(
                          "드래곤 불",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    contentPadding: const EdgeInsets.only(right: 5),
                    content: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        '패배하였습니다.',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),

                    actionsPadding: const EdgeInsets.only(bottom: 15),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                            padding: const EdgeInsets.all(7),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainScreen()),
                                      (route) => false,
                                );
                              },
                              child: const Text('메인으로 돌아가기', style: TextStyle(color: Colors.white),),
                            ),
                          )
                        ],
                      ),
                    ],

                  );
                },
              );
            }
          }
        }
      },
    );
    stompClient.subscribe(
      // 현재 각자의 기가 몇 개 인지 확인하기 위해서
      destination: '/sub/${widget.nickname}/gameRecord',
      callback: (frame) {
        Map<String, dynamic> gameRecord = json.decode(frame.body!);
        print('받아온 전적 정보: $gameRecord');
        nickname1 = gameRecord['nickname1'];
        nickname2 = gameRecord['nickname2'];

        if (widget.nickname == nickname1) {
          myWin = gameRecord['user1Win'];
          myLose = gameRecord['user1Lose'];
          myScore = gameRecord['user1Score'];
          contenderWin = gameRecord['user2Win'];
          contenderLose = gameRecord['user2Lose'];
          contenderScore = gameRecord['user2Score'];
        } else {
          contenderWin = gameRecord['user1Win'];
          contenderLose = gameRecord['user1Lose'];
          contenderScore = gameRecord['user1Score'];
          myWin = gameRecord['user2Win'];
          myLose = gameRecord['user2Lose'];
          myScore = gameRecord['user2Score'];
        }
        print(nickname1);
        print(myWin);
        print(myLose);
        print(myScore);
        print(nickname2);
        print(contenderWin);
        print(contenderLose);
        print(contenderScore);
      },
    );

    stompClient.subscribe(
      // 현재 각자의 기가 몇 개 인지 확인하기 위해서
      destination: '/sub/${widget.nickname}/countGi',
      callback: (frame) {
        print('현재 받아온 기 정보는 다음과 같습니다: ${frame.body}');
        String frameBody = ' ${frame.body}';
        List<String> parts = frameBody.split(' ');

        String part1 = parts[1];
        String part2 = parts[2];
        String part3 = parts[3];
        String part4 = parts[4];

        if (widget.nickname == part1) {
          contender = part3;
          giCnt = int.parse(part2);
        } else if (widget.nickname == part3) {
          contender = part1;
          giCnt = int.parse(part4);
        }
      },
    );

    stompClient.subscribe(
      // 카운트 다운 도중 한쪽 이상에서 응답이 없는 경우
      destination: '/sub/${widget.nickname}/finalInfo',
      callback: (frame) {
        // 원하는 작업 수행
        String frameBody = ' ${frame.body}';
        List<String> part = frameBody.split(' ');
        List<String> parts = part[1].split(':');
        String part1 = parts[0];
        String part2 = parts[1];
        String part3 = parts[2];
        String part4 = parts[3];
        String part5 = parts[4];
        String part6 = parts[5];
        if (frame.body != null) {
          if (winner == widget.nickname) {
            // 내가 승자인 경우
            print("승자의 승: $part4");
            print("승자의 패: $part5");
            print("승자의 점수: $part6");
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    GameResultScreen(
                        roomId: 1,
                        nickname: winner,
                        win: part4,
                        lose: part5,
                        point: int.parse(part6),
                        winScore: '1',
                        loseScore: '1'),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            // 내가 패자인 경우
            print("패자의 승: $part1");
            print("패자의 패: $part2");
            print("패자의 점수: $part3");
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    GameResultScreen(
                        roomId: 1,
                        nickname: winner,
                        win: part1,
                        lose: part2,
                        point: int.parse(part3),
                        winScore: '1',
                        loseScore: '1'),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (Route<dynamic> route) => false,
            );
          }
          print(frame.body);
          // dispose(); // 이거 다음에 다음 화면으로 넘어가면 됩니다.
        }
      },
    );
    stompClient.subscribe(
      // 여전히 방안에 남아있는지 서버에서 물어 보면 남아있다고 대답을 보내야한다.
      destination: '/sub/${widget.nickname}/stillConnect',
      callback: (frame) {
        // 원하는 작업 수행
        if (frame.body == 'still') {
          // print('still값을 받아오고 있습니다');
          sendAlive();
        }
      },
    );

    stompClient.subscribe(
      // 판을 1.5초 동안 보여준 이후 명령이 들어오면 startgame 을 실행한다.
      destination: '/sub/${widget.nickname}/letsStart',
      callback: (frame) {
        // 원하는 작업 수행
        if (frame.body == 'start') {
          startGame();
        }
      },
    );
    stompClient.subscribe(
      // 판을 1.5초 동안 보여준 이후 명령이 들어오면 startgame 을 실행한다.
      destination: '/sub/${widget.nickname}/escape',
      callback: (frame) {
        // 게임 매칭이 된 직후 한 사람이 나가버린 경우
        if (frame.body == 'escape') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.grey,
                titlePadding: const EdgeInsets.only(right: 5),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.red, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                    padding: const EdgeInsets.all(7),
                    child: const Text(
                      "드래곤 불",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                contentPadding: const EdgeInsets.only(right: 5),
                content: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    "상대가 떠났습니다.",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                actionsPadding: const EdgeInsets.only(bottom: 15),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey, boxShadow: [BoxShadow(color: Colors.black54, offset: const Offset(5, 5), blurRadius: 0)]),
                        padding: const EdgeInsets.all(7),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                                  (route) => false,
                            );
                          },
                          child: const Text('확인', style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ],

              );
            },
          );
        }
      },
    );

    stompClient.subscribe(
      // 현재 각자의 기가 몇 개 인지 확인하기 위해서
      destination: '/sub/${widget.nickname}/HpInfo',
      callback: (frame) {
        print('현재 받아온 승 정보는 다음과 같습니다: ${frame.body}');
        String frameBody = ' ${frame.body}';
        List<String> parts = frameBody.split(' ');

        String part1 = parts[1];
        print(part1);
        String part2 = parts[2];
        print(part2);
        List<String> info1 = part1.split(':');
        List<String> info2 = part2.split(':');

        String nick1 = info1[0];
        String hp1 = info1[1];
        String nick2 = info2[0];
        String hp2 = info2[1];
        print(nick1);
        print(hp1);
        print(nick2);
        print(hp2);

        if (widget.nickname == nick1) {
          // nick1이 나일 때
          int hpOfMe = int.parse(hp1) - 1;
          int hpOfYou = int.parse(hp2);
          myHp = hpOfMe.toString();
          youHp = hpOfYou.toString();
        } else {
          //nick2가 나일 때
          int hpOfMe = int.parse(hp2) - 1;
          int hpOfYou = int.parse(hp1);
          myHp = hpOfMe.toString();
          youHp = hpOfYou.toString();
        }
      },
    );

    firstMessage(); // 처음 들어오자마자 메시지를 보낸다.
  }

  void firstMessage() {
    // 아직 방에 살아있다는 것을 알리기 위해서
    final Map<String, dynamic> messageBody = {
      "nowFloor": widget.nowFloor,
      "roomNumber": widget.roomNumber,
    };
    final headers = {
      'Content-Type': 'application/json', // JSON 형식으로 보내기 위한 헤더 설정
    };
    stompClient.send(
        destination: '/pub/${widget.nickname}/whenEnter',
        body: jsonEncode(messageBody),
        headers: headers);
  }

  void sendMessage(String message, String nickname) {
    // 무엇을 선택했는지 보내는 것
    stompClient.send(
        destination: '/pub/${widget.nickname}/chooseWhat',
        body: '$nickname:$message:${widget.roomNumber}',
        headers: {});
  }

  void sendAlive() {
    // 아직 방에 살아있다는 것을 알리기 위해서
    final Map<String, dynamic> messageBody = {
      "nowNumber": 1,
    };
    final headers = {
      'Content-Type': 'application/json', // JSON 형식으로 보내기 위한 헤더 설정
    };
    stompClient.send(
        destination: '/pub/${widget.nickname}/alive',
        body: jsonEncode(messageBody),
        headers: headers);
  }

  void sendTime(String time) {
    // 현재의 카운트다운을 보내주는 함수
    stompClient.send(
        destination: '/pub/${widget.nickname}/timecheck',
        body: '${widget.roomNumber}',
        headers: {});
  }

  void sendResult() {
    // 게임이 끝났을 때 내가 보스를 무찔렀다면 나의 최종 층을 업데이트 해줘야 한다.
    print(accessToken);
    final Map<String, dynamic> messageBody = {
      "Authorization": '$accessToken',
      "nowFloor":widget.nowFloor,

    };
    final headers = {
      'Content-Type': 'application/json', // JSON 형식으로 보내기 위한 헤더 설정

    };
    stompClient.send(
        destination: '/pub/${widget.nickname}/updateMaxFloor',
        body: jsonEncode(messageBody),
        headers: headers);
  }


  void startGame() {
    setState(() {
      isPan = false;
    });
    stompClient.send(
        destination: '/pub/${widget.nickname}/showTime',
        body: '${widget.roomNumber}',
        headers: {});
  }

  void showPan() {
    // 몇 번째 판인지를 보여주는 화면 클라이언트에서 서버로 보내고 서버에서 1초 이후
    // 클라이언트로 메시지를 보낸다. => 해당 메시지를 받자마자 gamestart를 실행한다.
    print("showPan 입장");
    pan += 1;
    setState(() {
      showTemp = false;
      isConnected = false;
      isPan = true;
    });
    stompClient.send(
        destination: '/pub/${widget.nickname}/whatPan',
        body: '${widget.roomNumber}',
        headers: {});
  }

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
    String socketUrl = dotenv.env['SOCKET_URL']!;
    stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        // STOMP 서버 URL로 변경
        //url: 'ws://10.0.2.2:8080/ws',
        onConnect: onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
      ),
    );
    stompClient.activate();
  }

  @override
  void dispose() {
    stompClient
        .send(destination: '/pub/$nickname/dispose', body: '', headers: {});
    stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: endApp,
        child: Stack(
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
                  // Center(
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,

                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).size.width * 0.5 -
                            MediaQuery.of(context).size.width * 0.06,
                        child: Container(
                          child: Image.asset(
                            'lib/assets/icons/background.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ))
                        .animate()
                        .fade()
                        .scaleXY(
                        curve: Curves.linear,
                        duration: Duration(milliseconds: 800),
                        begin: 1.5),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                        bottom: 0,
                        left: 0,
                        height: MediaQuery.of(context).size.width * 0.5 +
                            MediaQuery.of(context).size.width * 0.06 +
                            MediaQuery.of(context).size.width * 0.075 * 1.2 +
                            10,
                        width: MediaQuery.of(context).size.width * 0.67,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xffCBB98A),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15))),
                        )),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).size.width * 0.5 +
                            MediaQuery.of(context).size.width * 0.06,
                        child: Container(color: Color(0xffD6CFB7))),
                  if (showTemp)
                    Positioned(
                      top: 0,
                      height: MediaQuery.of(context).size.height * 0.31,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.31,
                            child: Image.asset(
                              'lib/assets/skills/$youPick.gif',
                              fit: BoxFit.fitHeight,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                        top: MediaQuery.of(context).size.width * 0.1,
                        right: 0,
                        height: MediaQuery.of(context).size.width * 0.09,
                        width: MediaQuery.of(context).size.width * 0.47,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xffCBB98A),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15))),
                        )),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                        top: 0,
                        right: 0,
                        height: MediaQuery.of(context).size.width * 0.12,
                        width: MediaQuery.of(context).size.width * 0.68,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xffD6CFB7),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15))),
                        )),
                  if (showTemp)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.31,
                      height: MediaQuery.of(context).size.height * 0.31,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.31,
                            child: Image.asset(
                              'lib/assets/skills/$mePick.gif',
                              fit: BoxFit.fitHeight,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if ((showTemp || isGi || isPa || isBlock || isTel || isBomb) && youPick != "teleportation" )
                    Positioned(
                      top: 0,
                      height: MediaQuery.of(context).size.height * 0.31,
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Image.asset(
                            'lib/assets/icons/$dragon.gif',
                            fit: BoxFit.fitHeight,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                  if ((showTemp || isGi || isPa || isBlock || isTel || isBomb) && mePick != "teleportation")
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.31,
                      height: MediaQuery.of(context).size.height * 0.31,
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Image.asset(
                            'lib/assets/icons/myCharacter.gif',
                            fit: BoxFit.fitHeight,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                  if (isWaiting)
                    Container(
                      color: Colors.black.withOpacity(0.6),
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Dialog(
                          insetPadding: const EdgeInsets.all(10),
                          backgroundColor: const Color.fromRGBO(3, 8, 61, 0.75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '게임 대기중',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.15,
                                  ),
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isPan)
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Dialog(
                          insetPadding: const EdgeInsets.all(10),
                          backgroundColor: const Color.fromRGBO(3, 8, 61, 0.75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (pan == 1)
                                    const Text(
                                      '1st Round!!',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 35),
                                    ),
                                  if (pan == 2)
                                    const Text(
                                      '2nd Round!!',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 35),
                                    ),
                                  if (pan == 3)
                                    const Text(
                                      '3rd Round!!',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 35),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fade().slideY(curve: Curves.bounceOut),

                  if (isConnected)
                    Container(
                      color: Colors.black.withOpacity(0.6),
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Dialog(
                          insetPadding: const EdgeInsets.all(10),
                          backgroundColor: const Color.fromRGBO(3, 8, 61, 0.75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '보스 등장',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 0.41,
                                    child: Image.asset(
                                      'lib/assets/icons/connected.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                      .animate()
                                      .scaleXY(
                                          begin: 10, curve: Curves.bounceInOut)
                                      .shake(
                                          delay:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.bounceInOut),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().hide(delay: const Duration(milliseconds: 800)),
                  if (isConnected)
                    Positioned(
                        top: 0,
                        right: -50,
                        height: 100 * 2,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 100 * 1.5,
                                width: MediaQuery.of(context).size.width * 0.65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 15.0, sigmaY: 15.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      contender!,
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        //
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'lib/assets/icons/trophyIcon.PNG',
                                            height: 20,
                                            fit: BoxFit.fitHeight,
                                          ),
                                          Text(
                                            "이것도 너프해보시지",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "꺄르르르르르르르르르륵",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().slideX(
                            delay: const Duration(milliseconds: 900),
                            duration: const Duration(milliseconds: 350),
                            begin: 2,
                            end: -0.09,
                            curve: Curves.easeIn)),
                  if (isConnected)
                    Positioned(
                        top: MediaQuery.of(context).size.height * 0.5,
                        left: -50,
                        height: 100 * 2,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 100 * 1.5,
                                width: MediaQuery.of(context).size.width * 0.65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 15.0, sigmaY: 15.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.nickname,
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        //
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'lib/assets/icons/trophyIcon.PNG',
                                            height: 20,
                                            fit: BoxFit.fitHeight,
                                          ),
                                          Text(
                                            "혼돈 파괴!!!",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "도전자",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().slideX(
                            delay: const Duration(milliseconds: 900),
                            duration: const Duration(milliseconds: 350),
                            begin: -2,
                            end: 0.08,
                            curve: Curves.easeIn)),
                  if (isConnected)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.35,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                                child: const Text("VS",
                                    style: TextStyle(fontSize: 60)))
                            .animate()
                            .show(delay: const Duration(milliseconds: 1100))
                            .scaleXY(
                                delay: const Duration(milliseconds: 1150),
                                duration: const Duration(milliseconds: 400),
                                begin: 10,
                                curve: Curves.bounceInOut)
                            .shake(
                                delay: const Duration(milliseconds: 1550),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.bounceInOut)
                            .tint(
                              color: Colors.amber,
                              duration: const Duration(milliseconds: 500),
                              delay: const Duration(milliseconds: 500),
                            )
                            .tint(
                              color: Colors.blue,
                              duration: const Duration(milliseconds: 500),
                              delay: const Duration(milliseconds: 500),
                            )
                            .tint(
                                color: Colors.black,
                                delay: const Duration(milliseconds: 500)),
                      ),
                    ),
                  // Column(
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         sendMessage('대기 화면 입니다', widget.nickname);
                  //       },
                  //       child: const Text('이건 연결 테스트용 버튼'),
                  //     ),
                  //     const Text('대기 화면 입니다'), // 조건이 참일 때 추가
                  //   ],
                  // ),

                  if (isGameStart)
                    Positioned(
                        top: MediaQuery.of(context).size.height * 0.3,
                        left: 0,
                        right: 0,
                        child: Center(
                            child: Text(
                          '$countdown',
                          style: const TextStyle(
                              fontSize: 65,
                              height: 0.8,
                              fontWeight: FontWeight.bold),
                        )
                                .animate(target: countdown == '3' ? 1 : 0)
                                .scaleXY(
                                    duration: Duration(milliseconds: 100),
                                    begin: 2,
                                    end: 0.1,
                                    curve: Curves.bounceInOut)
                                .animate(target: countdown == '2' ? 2 : 0)
                                .scaleXY(
                                    duration: Duration(milliseconds: 100),
                                    begin: 2,
                                    end: 0.1,
                                    curve: Curves.bounceInOut)
                                .animate(target: countdown == '1' ? 2 : 0)
                                .scaleXY(
                                    duration: Duration(milliseconds: 100),
                                    begin: 2,
                                    end: 0.1,
                                    curve: Curves.bounceInOut)
                                .animate(target: countdown == '0' ? 2 : 0)
                                .scaleXY(
                                    duration: Duration(milliseconds: 100),
                                    begin: 2,
                                    end: 0.1,
                                    curve: Curves.bounceInOut))),

                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.38,
                      right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (giCnt == 0)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(giIcon),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          if (giCnt == 1)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'lib/assets/icons/giStatus1.png'),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          if (giCnt == 2)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'lib/assets/icons/giStatus2.png'),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          if (giCnt >= 3)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'lib/assets/icons/giStatus3.png'),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          Container(
                            child: Center(
                              child: Text(giCnt.toString(),
                                  style: const TextStyle(
                                      fontSize: 28, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                      top: MediaQuery.of(context).size.width * 0.09 + 10,
                      right: 10,
                      child: Center(
                        child: Text(contender!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                      bottom: MediaQuery.of(context).size.width * 0.5,
                      left: 10,
                      child: Center(
                        child: Text(widget.nickname,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: MediaQuery.of(context).size.width * 0.09,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                            AssetImage('lib/assets/icons/hp$youHp-5.png'),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                      bottom: MediaQuery.of(context).size.width * 0.5 +
                          MediaQuery.of(context).size.width * 0.06 +
                          10,
                      left: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.61,
                        height: MediaQuery.of(context).size.width * 0.075,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/assets/icons/hp$myHp.png'),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),

                  if (showTemp || isGi || isPa || isBlock || isTel || isBomb)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (giCnt < 1)
                                Stack(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context).size.width * 0.33,
                                      height:
                                      MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          opacity: 0.4,
                                          image: AssetImage(buttonTele),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          '순간이동',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              if (giCnt >= 1)
                                GestureDetector(
                                  onTap: () {
                                    if (!showTemp) {
                                      // 순간이동을 하는 경우
                                      sendMessage('순간이동', widget.nickname);
                                      setState(() {
                                        isBombPressed = false;
                                        isPaPressed = false;
                                        isGiPressed = false;
                                        isTelPressed = true;
                                        isBlockPressed = false;
                                      });
                                    }
                                    if (_isHaptic) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  onTapDown: (_) {
                                    setState(() {
                                      buttonTele =
                                      'lib/assets/icons/buttonTele2.png';
                                    });
                                    if (_isHaptic) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      buttonTele =
                                      'lib/assets/icons/buttonTele.png';
                                    });
                                  },
                                  onTapCancel: () => setState(() {
                                    buttonTele =
                                    'lib/assets/icons/buttonTele.png';
                                  }),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.33,
                                        height:
                                        MediaQuery.of(context).size.width *
                                            0.25,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            if (isTelPressed)
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    255, 50, 0, 0.8),
                                                offset: Offset(0, -10),
                                                blurRadius: 28,
                                                spreadRadius: -15,
                                              ),
                                          ],
                                          image: DecorationImage(
                                            image: AssetImage(buttonTele),
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            '순간이동',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (giCnt < 3)
                                Stack(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context).size.width * 0.33,
                                      height:
                                      MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          opacity: 0.4,
                                          image: AssetImage(buttonOne),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          '원기옥',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (giCnt >= 3)
                                GestureDetector(
                                  onTap: () {
                                    if (!showTemp) {
                                      sendMessage('원기옥', widget.nickname);
                                      setState(() {
                                        isBombPressed = true;
                                        isPaPressed = false;
                                        isGiPressed = false;
                                        isTelPressed = false;
                                        isBlockPressed = false;
                                      });
                                    }
                                    if (_isHaptic) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  onTapDown: (_) {
                                    setState(() {
                                      buttonOne =
                                      'lib/assets/icons/buttonOne2.png';
                                    });
                                    if (_isHaptic) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      buttonOne =
                                      'lib/assets/icons/buttonOne.png';
                                    });
                                  },
                                  onTapCancel: () => setState(() {
                                    buttonOne =
                                    'lib/assets/icons/buttonOne.png';
                                  }),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.33,
                                        height:
                                        MediaQuery.of(context).size.width *
                                            0.25,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            if (isBombPressed)
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    255, 50, 0, 0.8),
                                                offset: Offset(0, -10),
                                                blurRadius: 28,
                                                spreadRadius: -15,
                                              ),
                                          ],
                                          image: DecorationImage(
                                            image: AssetImage(buttonOne),
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            '원기옥',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (!showTemp) {
                                    sendMessage('기', widget.nickname);
                                    setState(() {
                                      isBombPressed = false;
                                      isPaPressed = false;
                                      isGiPressed = true;
                                      isTelPressed = false;
                                      isBlockPressed = false;
                                    });
                                  }
                                  if (_isHaptic) {
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                onTapDown: (_) {
                                  setState(() {
                                    buttonGi = 'lib/assets/icons/buttonGi2.png';
                                  });
                                  if (_isHaptic) {
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    buttonGi = 'lib/assets/icons/buttonGi.png';
                                  });
                                },
                                onTapCancel: () => setState(() {
                                  buttonGi = 'lib/assets/icons/buttonGi.png';
                                }),
                                child: Stack(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context).size.width *
                                          0.33,
                                      height:
                                      MediaQuery.of(context).size.width *
                                          0.25,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          if (isGiPressed)
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  255, 50, 0, 0.8),
                                              offset: Offset(0, -10),
                                              blurRadius: 28,
                                              spreadRadius: -15,
                                            ),
                                        ],
                                        image: DecorationImage(
                                          image: AssetImage(buttonGi),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          '으',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (!showTemp) {
                                    sendMessage('막기', widget.nickname);
                                    setState(() {
                                      isBombPressed = false;
                                      isPaPressed = false;
                                      isGiPressed = false;
                                      isTelPressed = false;
                                      isBlockPressed = true;
                                    });
                                  }
                                  if (_isHaptic) {
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                onTapDown: (_) {
                                  setState(() {
                                    buttonShield =
                                    'lib/assets/icons/buttonShield2.png';
                                  });
                                  if (_isHaptic) {
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    buttonShield =
                                    'lib/assets/icons/buttonShield.png';
                                  });
                                },
                                onTapCancel: () => setState(() {
                                  buttonShield =
                                  'lib/assets/icons/buttonShield.png';
                                }),
                                child: Stack(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context).size.width *
                                          0.33,
                                      height:
                                      MediaQuery.of(context).size.width *
                                          0.25,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          if (isBlockPressed)
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  255, 50, 0, 0.8),
                                              offset: Offset(0, -10),
                                              blurRadius: 28,
                                              spreadRadius: -15,
                                            ),
                                        ],
                                        image: DecorationImage(
                                          image: AssetImage(buttonShield),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          '막기',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (giCnt >= 1)
                                GestureDetector(
                                  onTap: () {
                                    if (!showTemp) {
                                      sendMessage('파', widget.nickname);
                                      setState(() {
                                        isBombPressed = false;
                                        isPaPressed = true;
                                        isGiPressed = false;
                                        isTelPressed = false;
                                        isBlockPressed = false;
                                      });
                                    }
                                    if (_isHaptic) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  onTapDown: (_) {
                                    setState(() {
                                      buttonPa =
                                      'lib/assets/icons/buttonPa2.png';
                                    });
                                    if (_isHaptic) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      buttonPa =
                                      'lib/assets/icons/buttonPa.png';
                                    });
                                  },
                                  onTapCancel: () => setState(() {
                                    buttonPa = 'lib/assets/icons/buttonPa.png';
                                  }),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.33,
                                        height:
                                        MediaQuery.of(context).size.width *
                                            0.25,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            if (isPaPressed)
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    255, 50, 0, 0.8),
                                                offset: Offset(0, -10),
                                                blurRadius: 28,
                                                spreadRadius: -15,
                                              ),
                                          ],
                                          image: DecorationImage(
                                            image: AssetImage(buttonPa),
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            '파',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (giCnt < 1)
                                Stack(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context).size.width * 0.33,
                                      height:
                                      MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          opacity: 0.4,
                                          image: AssetImage(buttonPa),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          '파',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}