import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class GameScreen extends StatefulWidget {
  final int roomId;
  final String nickname;
  const GameScreen({
    super.key,
    required this.roomId,
    required this.nickname,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final StompClient stompClient;
  String countdown = '';
  String winner = '';

  String youPick = '';
  String mePick = '';
  bool isWaiting = false; // 대기 화면 보여주기
  bool isGameStart = false;
  bool isResult = false; // 순간 순간의 결과창을 보여주는 페이지
  bool isGameOver = false; // 게임이 끝났는지를 확인하는 변수

  bool isGi = false; // 기
  bool isPa = false; // 파
  bool isBlock = false; // 막기
  bool isTel = false; // 텔레포트
  bool isBomb = false; // 원기옥

  bool showResult = false; // 결과 페이지 창
  bool showTemp = false;

  bool isTie = false; // 무효를 표현하기 위한 창
  String solo = 'true';

  int giCnt = 0;
  int round = 0; // 몇번 째 라운드인지를 판단해야한다.



  void onConnect(StompFrame frame) {
    setState(() {
      isWaiting = true; // 연결이 성공하면 상태 변수를 true로 설정
      // 한 명이 접속했을 때 상대방을 기다려야 하는 상황이기에 isWaiting을 true로 해서
      // 대기화면을 보여준다. => 즉 2명이 들어오는 순간 isWaiting은 false가 될 것이다.
    });

    stompClient.subscribe(
      // 방에 있는 사람의 수가 홀수 인지, 짝수인지 판단하기 위한 subscriber
      // 만약에 방에 있는 사람의 수가 짝수가 된다면 서버에서 0을 반환할 것이고
      //그 값을 바탕으로 게임을 시작하면 된다.
      destination: '/sub/${widget.roomId}/numCheck',
      callback: (frame) {
        // 원하는 작업 수행
        if (frame.body == '0') {
          solo = 'false';
          startGame();
          round += 1;
        }
      },
    );

    stompClient.subscribe(
      // 카운트 다운 부분을 위한 subscriber
      destination: '/sub/${widget.roomId}/countdown',
      callback: (frame) {
        // 원하는 작업 수행
        setState(() {
          countdown = frame.body ?? '0'; // frame.body가 null이면 '0'을 할당
          if (countdown == '3') {
            setState(() {
              youPick = '';
              mePick = '';
              showTemp = false;
              isWaiting = false;
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
      destination: '/sub/${widget.roomId}/error',
      callback: (frame) {
        // 원하는 작업 수행
        if (frame.body == '승자는 ${widget.nickname}') {
          // 3,2,1 을 받을 때
          winner = widget.nickname;
          setState(() {
            showTemp = false;
            isGameStart = false;
            showResult = true;
            isGi = false; // 기
            isPa = false; // 파
            isBlock = false; // 막기
            isTel = false; // 텔레포트
            isBomb = false; // 원기옥
          });
          sendResult(winner);
        }
      },
    );
    // 무엇을 선택했는지 보여주는 창
    stompClient.subscribe(
      // 서버에서 카운트 다운이 0이 되는 순간! String을 반환해서
      // 각자 무엇을 선택했는지를 확인하여 gif를 보여준다.
      destination: '/sub/${widget.roomId}/selected',
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
            mePick = 'bottomfist';
            if (picked2 == '기') {
              youPick = 'upfist';
            } else if (picked2 == '파') {
              youPick = 'upPa';
            } else if (picked2 == '막기') {
              youPick = 'upBlock';
            } else if (picked2 == '순간이동') {
              youPick = 'upTel';
            } else if (picked2 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '파') {
            mePick = 'bottomPa';
            if (picked2 == '기') {
              youPick = 'upfist';
            } else if (picked2 == '파') {
              youPick = 'upPa';
            } else if (picked2 == '막기') {
              youPick = 'upBlock';
            } else if (picked2 == '순간이동') {
              youPick = 'upTel';
            } else if (picked2 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '막기') {
            mePick = 'bottomBlock';
            if (picked2 == '기') {
              youPick = 'upfist';
            } else if (picked2 == '파') {
              youPick = 'upPa';
            } else if (picked2 == '막기') {
              youPick = 'upBlock';
            } else if (picked2 == '순간이동') {
              youPick = 'upTel';
            } else if (picked2 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '순간이동') {
            mePick = 'bottomTel';
            if (picked2 == '기') {
              youPick = 'upfist';
            } else if (picked2 == '파') {
              youPick = 'upPa';
            } else if (picked2 == '막기') {
              youPick = 'upBlock';
            } else if (picked2 == '순간이동') {
              youPick = 'upTel';
            } else if (picked2 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked1 == '원기옥') {
            mePick = 'bottomPower';
            if (picked2 == '기') {
              youPick = 'upfist';
            } else if (picked2 == '파') {
              youPick = 'upPa';
            } else if (picked2 == '막기') {
              youPick = 'upBlock';
            } else if (picked2 == '순간이동') {
              youPick = 'upTel';
            } else if (picked2 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else {
            mePick = '미처리';
            if (picked2 == '기') {
              youPick = 'upfist';
            } else if (picked2 == '파') {
              youPick = 'upPa';
            } else if (picked2 == '막기') {
              youPick = 'upBlock';
            } else if (picked2 == '순간이동') {
              youPick = 'upTel';
            } else if (picked2 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          }
        } else if (widget.nickname == user2) {
          if (picked2 == '기') {
            mePick = 'bottomfist';
            if (picked1 == '기') {
              youPick = 'upfist';
            } else if (picked1 == '파') {
              youPick = 'upPa';
            } else if (picked1 == '막기') {
              youPick = 'upBlock';
            } else if (picked1 == '순간이동') {
              youPick = 'upTel';
            } else if (picked1 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '파') {
            mePick = 'bottomPa';
            if (picked1 == '기') {
              youPick = 'upfist';
            } else if (picked1 == '파') {
              youPick = 'upPa';
            } else if (picked1 == '막기') {
              youPick = 'upBlock';
            } else if (picked1 == '순간이동') {
              youPick = 'upTel';
            } else if (picked1 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '막기') {
            mePick = 'bottomBlock';
            if (picked1 == '기') {
              youPick = 'upfist';
            } else if (picked1 == '파') {
              youPick = 'upPa';
            } else if (picked1 == '막기') {
              youPick = 'upBlock';
            } else if (picked1 == '순간이동') {
              youPick = 'upTel';
            } else if (picked1 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '순간이동') {
            mePick = 'bottomTel';
            if (picked1 == '기') {
              youPick = 'upfist';
            } else if (picked1 == '파') {
              youPick = 'upPa';
            } else if (picked1 == '막기') {
              youPick = 'upBlock';
            } else if (picked1 == '순간이동') {
              youPick = 'upTel';
            } else if (picked1 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else if (picked2 == '원기옥') {
            mePick = 'bottomPower';
            if (picked1 == '기') {
              youPick = 'upfist';
            } else if (picked1 == '파') {
              youPick = 'upPa';
            } else if (picked1 == '막기') {
              youPick = 'upBlock';
            } else if (picked1 == '순간이동') {
              youPick = 'upTel';
            } else if (picked1 == '원기옥') {
              youPick = 'upPower';
            } else {
              youPick = '미처리';
            }
          } else {
            mePick = '미처리';
            if (picked1 == '기') {
              youPick = 'upfist';
            } else if (picked1 == '파') {
              youPick = 'upPa';
            } else if (picked1 == '막기') {
              youPick = 'upBlock';
            } else if (picked1 == '순간이동') {
              youPick = 'upTel';
            } else if (picked1 == '원기옥') {
              youPick = 'upPower';
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
      destination: '/sub/${widget.roomId}/result',
      callback: (frame) {
        print('result가 현재 실행되고 있습니다');
        String frameBody = ' ${frame.body}';
        List<String> parts = frameBody.split(' ');
        String comparing = parts[3];
        List<String> section1 = parts[1].split(':');
        String user1 = section1[0];
        if (comparing == '비겼습니다') {
          // 비겼으니까 다시 게임을 진행해야함
          // 이 때 기를 가져온다.
          startGame();
          print('재경기를 실시합니다');
        } else if (comparing == '무효입니다') {
          // 둘 다 선택을 하지 않은 경우
          winner = "무효입니다";

          // winner = frame.body ?? '0';
          setState(() {
            showTemp = false;
            isGameStart = false;
            showResult = true;
            isGi = false; // 기
            isPa = false; // 파
            isBlock = false; // 막기
            isTel = false; // 텔레포트
            isBomb = false; // 원기옥
            isTie = true;
          });

          // dispose();
        } else {
          // 승자를 표시하고 게임을 끝내야함
          winner = comparing;

          setState(() {
            showTemp = false;
            isGameStart = false;
            showResult = true;
            isGi = false; // 기
            isPa = false; // 파
            isBlock = false; // 막기
            isTel = false; // 텔레포트
            isBomb = false; // 원기옥
          });
          // dispose();
          sendResult(winner);
        }
      },
    );

    stompClient.subscribe(
      // 현재 각자의 기가 몇 개 인지 확인하기 위해서
      destination: '/sub/${widget.roomId}/countGi',
      callback: (frame) {
        print('현재 받아온 기 정보는 다음과 같습니다: ${frame.body}');
        String frameBody = ' ${frame.body}';
        List<String> parts = frameBody.split(' ');

        String part1 = parts[1];
        String part2 = parts[2];
        String part3 = parts[3];
        String part4 = parts[4];

        if (widget.nickname == part1) {
          giCnt = int.parse(part2);
        } else if (widget.nickname == part3) {
          giCnt = int.parse(part4);
        }
      },
    );

    stompClient.send(
        destination: '/pub/${widget.roomId}/checkNum',
        body: widget.nickname,
        headers: {});

    Timer.periodic(Duration(seconds: 10), (timer) {
      if (isWaiting) {
        stompClient.send(
            destination: '/pub/${widget.roomId}/stillConnect',
            body: '',
            headers: {});
      } else {
        // isWaiting이 false인 경우 타이머 중지
        timer.cancel();
      }
    });

  }

  void sendMessage(String message, String nickname) {
    // STOMP 프레임을 메시지로 전송
    stompClient.send(
        destination: '/pub/${widget.roomId}/pickwhat',
        body: '$nickname:$message',
        headers: {});
  }

  void sendTime(String time) {
    // 현재의 카운트다운을 보내주는 함수
    stompClient.send(
        destination: '/pub/${widget.roomId}/timereturn',
        body: widget.nickname,
        headers: {});
  }

  void sendResult(String message) {
    // 최종적으로 게임이 끝이 났을 때, 결과를 DB에 저장하기 위해 호출
    stompClient.send(
        destination: '/pub/${widget.roomId}/updateRecord',
        body: message,
        headers: {});
  }

  void startGame() {
    // setState(() {
    //   print('setstate 실행');
    //   youPick='';
    //   mePick='';
    //   showTemp = false;
    //   isWaiting= false;
    //   isGameStart= true;
    //   isGi = true;
    //   isPa = true;
    //   isBlock= true;
    //   isTel = true;
    //   isBomb =true;
    // });
    stompClient.send(
        destination: '/pub/${widget.roomId}/Count',
        body: '${widget.nickname}:$round',
        headers: {});
  }

  @override
  void initState() {
    super.initState();
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://k9a209.p.ssafy.io/ws', // STOMP 서버 URL로 변경
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
    stompClient.send(
        destination: '/pub/${widget.roomId}/dispose', body: solo, headers: {});
    stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Room ID: ${widget.roomId}'), // roomId를 화면에 표시
            if (showTemp)
              Column(
                children: [
                  SizedBox(
                    width: 200, // 원하는 너비 값으로 설정
                    height: 200, // 원하는 높이 값으로 설정
                    child: Lottie.asset(
                      'lib/assets/lottie/$youPick.json',
                      repeat: true,
                      onLoaded: (composition) {
                        Timer(const Duration(milliseconds: 1200), () {
                          // 여기에 콜백 코드를 넣으세요
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200, // 원하는 너비 값으로 설정
                    height: 200, // 원하는 높이 값으로 설정
                    child: Lottie.asset(
                      'lib/assets/lottie/$mePick.json',
                      repeat: true,
                      onLoaded: (composition) {
                        Timer(const Duration(milliseconds: 2000), () {
                          // 여기에 콜백 코드를 넣으세요
                        });
                      },
                    ),
                  ),
                ],
              ),
            if (isWaiting)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      sendMessage('대기 화면 입니다', widget.nickname);
                    },
                    child: const Text('이건 연결 테스트용 버튼'),
                  ),
                  const Text('대기 화면 입니다'), // 조건이 참일 때 추가
                ],
              ),
            if (showResult)
              Column(
                children: [
                  if (!isTie) const Text('승자는!!'), // 조건이 참일 때 추가
                  Text(winner)
                ],
              ),
            if (isGameStart)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Countdown: $countdown',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            if (isGi || isPa || isBlock || isTel || isBomb)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 가위를 선택한 경우
                      sendMessage('기', widget.nickname);
                      isGi = false;
                      isPa = false;
                      isBlock = false;
                      isTel = false;
                      isBomb = false;
                    },
                    child: const Text('기'),
                  ),
                  if (giCnt >= 1)
                    ElevatedButton(
                      onPressed: () {
                        // 바위를 선택한 경우
                        sendMessage('파', widget.nickname);
                        isGi = false;
                        isPa = false;
                        isBlock = false;
                        isTel = false;
                        isBomb = false;
                      },
                      child: const Text('파'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      //막기를 선택 하는 경우
                      sendMessage('막기', widget.nickname);
                      isGi = false;
                      isPa = false;
                      isBlock = false;
                      isTel = false;
                      isBomb = false;
                    },
                    child: const Text('막기'),
                  ),
                  if (giCnt >= 1)
                    ElevatedButton(
                      onPressed: () {
                        // 순간이동을 하는 경우
                        sendMessage('순간이동', widget.nickname);
                        isGi = false;
                        isPa = false;
                        isBlock = false;
                        isTel = false;
                        isBomb = false;
                      },
                      child: const Text('순간이동'),
                    ),
                  if (giCnt >= 3)
                    ElevatedButton(
                      onPressed: () {
                        // 원기옥을 선택하는 경우
                        sendMessage('원기옥', widget.nickname);
                        isGi = false;
                        isPa = false;
                        isBlock = false;
                        isTel = false;
                        isBomb = false;
                      },
                      child: const Text('원기옥'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
