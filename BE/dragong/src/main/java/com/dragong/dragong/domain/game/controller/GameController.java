package com.dragong.dragong.domain.game.controller;

import com.dragong.dragong.domain.game.service.GameService;
import com.dragong.dragong.domain.game.service.ResultUpdateService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;


@RestController
@Slf4j
public class GameController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    @Autowired
    private GameService gameService;
    @Autowired
    private ResultUpdateService resultUpdateService;

    @PostMapping("/wait")
    public ResponseEntity<Map<String, Integer>> assignRoom(
            @RequestHeader("Authorization") String accessToken,
            @RequestBody Map<String, String> requestBody) {
        String nickname = requestBody.get("nickname");
        log.info("받아온 nickname : " + nickname);
        log.info("받아온 accessToken : " + accessToken);
        log.info("대기방에 입장합니다.");
        int nowNumber = gameService.enter(); // 몇 번째로 들어온 사람인지 확인한다.
        // 내가 반환해야 하는 숫자는 nowNumber + 1 / 2를 반환해야합니다.
        log.info("현재 내가 들어온 순서는" + nowNumber + "입니다");
        int roomId = (nowNumber + 1) / 2;
        log.info("현재의 roomId는" + roomId + "입니다");
        // roomId를 JSON 형식으로 반환
        gameService.initWinData(roomId, nickname); // 승 정보를 처음에 초기화 해준다.
        gameService.accessTokenUpdate(roomId, accessToken, nickname);
        Map<String, Integer> response = new HashMap<>();
        response.put("roomId", roomId);
        response.put("nowNumber", nowNumber); // 내가 몇 번째인지를 전해준다.

        return ResponseEntity.ok(response);
    }

    @MessageMapping("/{roomId}/checkNum")
    @SendTo("/sub/{roomId}/numCheck")
    public String checkNum(@DestinationVariable String roomId, String nickname) {
        // 게임 시작 여부를 정하기 위해서
        // 이건 socket 연결이 되자마자 자동적으로 보내는 것이다.
        int roomID = Integer.parseInt(roomId);
        log.info("현재 몇명이 접속했는지 확인하기 위해 실행합니다");
        log.info("받아온 닉네임은? " + nickname);
        int standard = gameService.giInit(roomID, nickname) % 2;
        // return 하는 값이 1 이라면 아직 방에 1명만 들어가 있다는 말
        // return 하는 값이 0 이라면 방에 2명이 들어간 상황이라는 말
        if (standard == 0) {
            // 0 일때 게임이 시작하니까
            // gi가 몇개인지 보내줘야겠지?
            log.info("gamestart 명령이 보내짐");
            gameService.gameStart();
            String giMessage = gameService.giReturn(roomID);
            Map<String, Object> userInfo = gameService.getUserInfo(roomID);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/gameRecord", userInfo);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi",
                    String.valueOf(giMessage));
        } else {
            // 이걸로 1~2초마다 front로 신호를 주고 만약에 신호에 대한 반응이 오지 않으면 비정상적으로 방을 나갔다라고 판단하자
            // 해당 roomId는 가지고 있으니까
            int computerMeet = 0;
            while (true) {
                // 내가 들어왔는데 만약에 내가 짝수 번째 사람인데 여기서 돌고 있는 경우라면? => 바로 나가야 한다.
                int compare = gameService.savingReturn(roomID); // 보내기 전의 값
                messagingTemplate.convertAndSend("/sub/" + roomId + "/stillConnect", "still");
                int whoIam = gameService.whoisInThere(roomID); // 나는 누구인가?
                if (whoIam % 2 == 0) {
                    //내가 짝수 번째 사람인데 여기 있다?  => 바로 탈출 해야 한다.
                    log.info("짝수번째 사람인데 게임을 시작하지 못하기에 탈출합니다");
                    gameService.gameStopTemp();
                    gameService.giClear(roomID);
                    gameService.savingReset(roomID);
                    gameService.cleanWinData(roomID);
                    gameService.deleteAccessToken(roomID);// accessToken 정보 빼기
                    return "에러입니다";
                }
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                int inside = gameService.giCnt(roomID);
//                log.info("inside를 출력합니다" + inside);

                if (inside == 2) {
                    log.info("방에  2명이 들어와서 탈출합니다");
                    gameService.savingReset(roomID);
                    return "방에 2명 들어와서 탈출";
                } else if (inside == 0) {
                    // 1 명이 기다리다가 그냥 나간 상황
                    log.info("1명이 기다리다가 방을 나갑니다");
                    log.info("이거 실행이 안되는거 같은데 왜인지 잘 모르겠군여");
                    gameService.savingReset(roomID);
                    return "1명이 기다리다가 방을 나갑니다";
                }
                int value = gameService.savingReturn(roomID);
                if (compare == value) {
                    log.info("연결이 끊겼습니다");
                    //이제 여기에서 처리를 해줘야한다. => queue 비우고, gidata 뺴고 등등
                    int whoamI = gameService.whoisInThere(roomID); // 나는 누구인가?
                    if (whoamI % 2 == 0) {
                        log.info("에러가 발생해 내가 짝수번 째 사람이지만 게임이 시작되지 않았기에 탈출합니다");
                        // total 뺄 필요없음. => 꼬이기만 할 뿐
                        //que 에서는 빼줘야 한다. // 수는 그대로 유지해야한다.
                        gameService.gameStopTemp();
                        gameService.giClear(roomID);
                        gameService.savingReset(roomID);
                        gameService.cleanWinData(roomID);
                        gameService.deleteAccessToken(roomID);// accessToken 정보 빼기
                    } else {
                        // 내가 혼자 있다가 그냥 방에서 나가는 경우를 말한다.
                        log.info("혼자 있다가 그냥 방을 탈출합니다");
                        gameService.giClear(roomID); // 기 정보 초기화
                        gameService.gameStop(whoamI); // 대기 queue에서 한 명 빼기
                        gameService.savingReset(roomID); // 비교를 위한 배열 값 초기화
                        gameService.cleanWinData(roomID);
                        gameService.deleteAccessToken(roomID);// accessToken 정보 빼기
                    }

                    break;
                }
                // 여기가 컴퓨터를 넣기 위해서 추가한 코드
                computerMeet += 1;
                if (computerMeet >= 15 && inside != 2) {
                    // 이제 일정 시간 이상 기다렸을 때는 컴퓨터와 만나게 된다.
                    log.info("컴퓨터와 매칭됩니다.");
                    int computerNumber = gameService.enter(); // 컴퓨터도 사람처럼 입장하는데, 몇 번째로 입장한건지 확인한다.
                    log.info("컴퓨터를 집어넣습니다");
                    int computerRoomId = (computerNumber + 1) / 2;
                    // 여기서 어떤 컴퓨터를 선택할 것인지를 정해줘야 하겠지?

                    gameService.chooseCom(computerRoomId); // 어떤 컴퓨터를 매칭 시킬 것인지 정한다.
                    Map<String, Object> computerInfo = gameService.getCom(computerRoomId);

                    String comName = (String) computerInfo.get("comName");
                    String uuid = (String) computerInfo.get("uuid");

                    gameService.initWinData(computerRoomId, comName);
                    gameService.giInit(computerRoomId, comName);
                    gameService.accessTokenUpdate(computerRoomId, "computerToken", comName);
                    gameService.computerUpdate(computerRoomId); // 컴퓨터와의 대전인지 업데이트 해주는 것!

                    gameService.gameStart();
                    String giMessage = gameService.giReturn(roomID);
                    Map<String, Object> userInfo = gameService.getUserInfo(roomID);
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/gameRecord", userInfo);
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi",
                            String.valueOf(giMessage));

                    return String.valueOf("0");
                }
            }
        }
        return String.valueOf(standard); // 처리된 메시지 다시 클라이언트로 전송
    }

    @MessageMapping("/{roomId}/pickwhat")
    public void handleChatMessage(@DestinationVariable String roomId, String message) {
        // 무엇을 선택했는지 저장하기 위해서
        log.info("선택한 값 저장을 위해 controller 입장");
        log.info("받아온 값 출력: " + message);
        int roomID = Integer.parseInt(roomId);
        int comCheck = gameService.isComputer(roomID);

        if (comCheck == 1) {
            //컴퓨터와 하는 경우
            Map<String, Object> computerInfo = gameService.getCom(roomID);

            String comName = (String) computerInfo.get("comName");
            String[] parts = message.split(":");
            if (parts.length == 2) {
                String nickname = parts[0].trim();
                String picked = parts[1].trim();
                gameService.gameStack(roomID, nickname, picked);
                // 이제 여기서 동탄불주먹에게 기 같은 것들을 넣어줘야 한다.
                String input = "";
                input = gameService.getTop(roomID);
                gameService.gameStack(roomID, comName, input); // 여기가 컴퓨터의 픽 정보를 넣는 곳이다.
            } else {
                log.info("올바른 메시지 형식이 아닙니다");
            }
        } else {
            String[] parts = message.split(":");
            if (parts.length == 2) {
                String nickname = parts[0].trim();
                String picked = parts[1].trim();
                gameService.gameStack(roomID, nickname, picked);
            } else {
                log.info("올바른 메시지 형식이 아닙니다");
            }
        }


    }


    @MessageMapping("/{roomId}/Count")
    public void Count(@DestinationVariable String roomId, String nicknameRound) {
        // 카운트 다운을 해준다.

        int errorCnt = 0;
        int roomID = Integer.parseInt(roomId);

        int comCheck = gameService.isComputer(roomID);
        log.info("Count를 시작합니다.");
        String[] parts = nicknameRound.split(":");
        log.info("닉네임 부분:" + parts[0]);
        log.info("몇번째 라운드인가?:" + parts[1]);
        if (comCheck == 1) {
            // Computer와 하는 경우
            log.info("컴퓨터와의 게임 시작! 현재 Count 안");

            for (int i = 3; i >= 0; i--) {
                if (i != 3) {
                    try {
                        Thread.sleep(600);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
                if (i == 0) {
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown",
                            String.valueOf(i)); // 0초도 한번 보내준다.
                    // 보내주는 이유는 한 명이라도 선택을 하지 않았을 경우, 해당 유저의 닉네임을 처리해야하기 때문(이건 선택을 하지 않을 상황이지, 튕긴 상황이 아니다)
                    errorCnt = 0;
                    while (gameService.evenReturn(roomID) != 2) {
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        log.info("현재 문제가 발생하는 곳의 roomId는: " + roomID);
                        log.info("0초인데 플레이어가 pingpong 응답이 없습니다.");
                        errorCnt += 1;

                        if (errorCnt >= 7) {
                            if (gameService.evenReturn(roomID) == 0) {
                                log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                Map<String, Object> computerInfo = gameService.getCom(roomID);
                                //여기서 점수를 내려야한다.
                                resultUpdateService.updateLoser(gameService.getPlayerAccessToken(roomID,parts[0]),1);
                                String comName = (String) computerInfo.get("comName");
                                messagingTemplate.convertAndSend("/sub/" + roomId + "/error",
                                        "승자는" + " " + comName);
                                return;
                            }
                        }
                    }
                    // computer와의 게임!
                    String answer = gameService.gameResult(roomID);
                    // 여기서 만약에 answer의 가장 끝부분이 "안끝남"이 아니라면 gi 정보를 초기화 해주면 되지 않을까?
                    // 이제 승 정보를 반환해야지
                    String[] information = answer.split(" ");
                    System.out.println(information[3]); // 이게
                    if (information[3].equals("끝냅니다")) {
                        // 기 정보를 0, 0 으로 수정해줘야 한다.
                        gameService.giReset(roomID);
                        gameService.cleanStack(roomID);
                    } else if (information[3].equals("계속합니다")) {
                        // 기 정보를 0,0 으로 수정해줘야 한다.
                        gameService.giReset(roomID);
                        gameService.cleanStack(roomID);
                    }
                    // 이건 이제 0초가 되는 순간을 생각하는건데. => 지금은 그냥 바로 재 경기를 실시하거나, 게임 결과가 나왔다.
                    // 하지만 이 사이에 gif를 추가해줄 계획이다. gif를 보여주는 시간은 일단 3초라고 생각하자.
                    log.info("반환할 결과값은: " + answer);
                    gameService.cleanList(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
                    for (int j = 3; j >= 0; j--) {
                        // 이건 뭘 뽑았는지 보여주는 시간이다.
                        try {
                            Thread.sleep(600);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/selected",
                                String.valueOf(j) + " " + answer);
                    }
                    try {
                        Thread.sleep(300);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                    if(gameService.noLeaveGet(roomID)!=4){
                        // 사이에 나갔다는 의미다.
                        resultUpdateService.updateLoser(gameService.getPlayerAccessToken(roomID,parts[0]),1);
                        gameService.noLeaveClear(roomID);
                    }
                    gameService.noLeaveClear(roomID);
                    // 이게 결과값을 반환하는 것이다. //
                    if (information[3].equals("나갑니다")) {
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);
                        return;
                    } else {
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);
                    }

                } else {
                    errorCnt = 0;
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown",
                            String.valueOf(i));

                    while (gameService.evenReturn(roomID) != 2) {
                        // 값을 보내지 않은 경우
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        log.info("컴퓨터와의 대전 도중 아직 플레이어가 값을 입력하지 않았습니다");
                        errorCnt += 1;

                        if (errorCnt >= 7) {
                            if (gameService.evenReturn(roomID) == 0) {
                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..
                                Map<String, Object> computerInfo = gameService.getCom(roomID);

                                String comName = (String) computerInfo.get("comName");
                                resultUpdateService.updateLoser(gameService.getPlayerAccessToken(roomID,parts[0]),1);
                                log.info("현재 연결이 끊긴 상황입니다.");
                                messagingTemplate.convertAndSend("/sub/" + roomId + "/error",
                                        "승자는" + " " + comName);
                                return;
                            }
                        }
                    }
                    gameService.cleanList(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.

                }
            }
            String giMessage = gameService.giReturn(roomID);
            String winInformation = gameService.returnWinData(roomID);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi",
                    String.valueOf(giMessage));
            messagingTemplate.convertAndSend("/sub/" + roomId + "/winData",
                    String.valueOf(winInformation));


        } else {
            // 사람과 하는 경우
            gameService.messageInsert(roomID, parts[0]);
            int localCnt = gameService.evenReturn(roomID);
            boolean gameStart = false;
            int standard = 0;
            if (Integer.parseInt(parts[1]) == 1) {
                // 처음 들어오는 경우
                log.info("첫 게임인 경우");

                if (localCnt % 2 == 0) {
                    log.info("한 방에 두 명이 들어온 경우");
                    // 이 경우에 이제 gameService에서 winData를 초기화 해줘야 한다.
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                    gameStart = true;
                }
            } else {
                //이건 이제 처음들어온게 아니라 그 이후에 들어온 경우를 생각
                log.info("두 번째 이후의 게임인 경우");
                int cnt = 0;
                while (cnt < 3 && localCnt % 2 != 0) {
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                    cnt += 1;
                }
                if (localCnt % 2 == 1) {
                    // 2개가 전부 들어온 경우라면 명령을 하나만 보내야 한다.
                    gameStart = true;

                }
            }
            //gameService.messageInsert(roomId, nickname);

            if (gameStart) {
                log.info("gameStart 입장");
                gameService.cleanList(roomID);
                for (int i = 3; i >= 0; i--) {
                    if (i != 3) {
                        try {
                            Thread.sleep(600);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                    }
                    if (i == 0) {
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown",
                                String.valueOf(i)); // 0초도 한번 보내준다.
                        // 보내주는 이유는 한 명이라도 선택을 하지 않았을 경우, 해당 유저의 닉네임을 처리해야하기 때문(이건 선택을 하지 않을 상황이지, 튕긴 상황이 아니다)
                        errorCnt = 0;
                        while (gameService.evenReturn(roomID) != 2) {
                            //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                            try {
                                Thread.sleep(300);
                            } catch (InterruptedException e) {
                                Thread.currentThread().interrupt();
                            }
                            log.info("현재 문제가 발생하는 곳의 roomId는: " + roomID);
                            log.info("0초인데 아직 양쪽으로부터 값을 받지 못했습니다");
                            errorCnt += 1;

                            if (errorCnt >= 7) {
                                //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                                //원래는 3이었는데 7으로 바꿈 => 결국 양쪽에서 값을 0.9초 안에 보내지 않으면 한쪽의 연결이 끊겼다고 판단하게 하는거라서 너무 짧다고 판단
                                //7로 바꿔서 2.1초 동안 연결이 없으면 끊겼다고 판단하는건데, 이걸로도 문제가 발생한다면 숫자를 늘리거나 다른 문제가 있다고 판단
                                if (gameService.evenReturn(roomID) == 0) {
                                    // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..
                                    log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                    return;
                                } else {
                                    // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
                                    log.info("현재 연결이 끊긴 상황이고, 한쪽만 연결이 끊긴 상황입니다.");
                                    String remainName = gameService.returnName(roomID);
                                    messagingTemplate.convertAndSend("/sub/" + roomId + "/error",
                                            "승자는" + " " + remainName);
                                    gameService.cleanList(roomID); // 값을 정리해준다.
                                    return;
                                }
                            }
                        }
                        String answer = gameService.gameResult(roomID);
                        // 여기서 만약에 answer의 가장 끝부분이 "안끝남"이 아니라면 gi 정보를 초기화 해주면 되지 않을까?

                        // 이제 승 정보를 반환해야지
                        String[] information = answer.split(" ");
                        System.out.println(information[3]); // 이게
                        if (information[3].equals("끝냅니다")) {
                            // 기 정보를 0, 0 으로 수정해줘야 한다.
                            gameService.giReset(roomID);
                        } else if (information[3].equals("계속합니다")) {
                            // 기 정보를 0,0 으로 수정해줘야 한다.
                            gameService.giReset(roomID);
                        }
                        // 이건 이제 0초가 되는 순간을 생각하는건데. => 지금은 그냥 바로 재 경기를 실시하거나, 게임 결과가 나왔다.
                        // 하지만 이 사이에 gif를 추가해줄 계획이다. gif를 보여주는 시간은 일단 3초라고 생각하자.
                        log.info("반환할 결과값은: " + answer);
                        gameService.cleanList(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
                        for (int j = 3; j >= 0; j--) {
                            // 이건 뭘 뽑았는지 보여주는 시간이다.
                            try {
                                Thread.sleep(650);
                            } catch (InterruptedException e) {
                                Thread.currentThread().interrupt();
                            }
                            messagingTemplate.convertAndSend("/sub/" + roomId + "/selected",
                                    String.valueOf(j) + " " + answer);
                        }
                        // 이게 결과값을 반환하는 것이다. //
                        if (information[3].equals("나갑니다")) {
                            messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);
                            return;
                        } else {
                            messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);
                        }

                    } else {
                        errorCnt = 0;
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown",
                                String.valueOf(i));

                        while (gameService.evenReturn(roomID) != 2) {
                            //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                            try {
                                Thread.sleep(300);
                            } catch (InterruptedException e) {
                                Thread.currentThread().interrupt();
                            }
                            log.info("0초가 아닌데 아직 양쪽으로부터 값을 받지 못했습니다");
                            errorCnt += 1;

                            if (errorCnt >= 7) {
                                //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                                //원래는 3이었는데 7으로 바꿈 => 결국 양쪽에서 값을 0.9초 안에 보내지 않으면 한쪽의 연결이 끊겼다고 판단하게 하는거라서 너무 짧다고 판단
                                //7로 바꿔서 2.1초 동안 연결이 없으면 끊겼다고 판단하는건데, 이걸로도 문제가 발생한다면 숫자를 늘리거나 다른 문제가 있다고 판단
                                if (gameService.evenReturn(roomID) == 0) {
                                    // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..

                                    log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                    return;
                                } else {
                                    // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
                                    log.info("현재 연결이 끊긴 상황이고, 한쪽만 연결이 끊긴 상황입니다.");
                                    String remainName = gameService.returnName(roomID);
                                    messagingTemplate.convertAndSend("/sub/" + roomId + "/error",
                                            "승자는" + " " + remainName);
                                    gameService.cleanList(roomID); // 값을 정리해준다.
                                    return;
                                }
                            }
                        }
                        gameService.cleanList(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.

                    }
                }
                String giMessage = gameService.giReturn(roomID);
                String winInformation = gameService.returnWinData(roomID);
                messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi",
                        String.valueOf(giMessage));
                messagingTemplate.convertAndSend("/sub/" + roomId + "/winData",
                        String.valueOf(winInformation));
            }
        }


    }

    @MessageMapping("/{roomId}/dispose")
    public void disposeHandle() {
        // 방을 폭파시켜야 한다.
        log.info("방 폭파 명령을 받았습니다");
        log.info("하지만 아무것도 하지 않습니다");
    }

    @MessageMapping("/{roomId}/timereturn")
    public void gotTime(@DestinationVariable String roomId, String nickname) {
        int roomID = Integer.parseInt(roomId);
        int comCheck = gameService.isComputer(roomID);
        System.out.println("timereturn 입장");
        if (comCheck == 1) {
            System.out.println("컴퓨터 대전 timereturn 입장");
            // 컴퓨터와의 대전인 경우
            // 이게 뭐냐? 5,4,3,2,1 이런식으로 카운트 다운을 할 때 제대로 시간을 각 클라이언트에서 받아오고 있는지 확인하기 위한 것.
            Map<String, Object> computerInfo = gameService.getCom(roomID);

            String comName = (String) computerInfo.get("comName");

            log.info("현재 카운트 다운 정보를 받아오고 있습니다.+ " + nickname);
            gameService.messageInsert(roomID, nickname);
            gameService.messageInsert(roomID, comName);
        } else {
            // 이게 뭐냐? 5,4,3,2,1 이런식으로 카운트 다운을 할 때 제대로 시간을 각 클라이언트에서 받아오고 있는지 확인하기 위한 것.
            log.info("현재 카운트 다운 정보를 받아오고 있습니다.+ " + nickname);
            gameService.messageInsert(roomID, nickname);
        }

    }

    @MessageMapping("/{roomId}/updateRecord")
    public void updateRecord(@DestinationVariable String roomId, String winner) {
        // 이제 결과를 받아올건데
        int roomID = Integer.parseInt(roomId);
        int comCheck = gameService.isComputer(roomID);
        if (comCheck == 1) {
            //컴퓨터랑 하는 경우
            log.info("게임이 끝났습니다 어떻게 하실래연?");
            String result = gameService.winnerAndLoserToken(roomID, winner);
            String[] parts = result.split(":");

            gameService.updateLog(roomID, winner); // 컴퓨터 로그 추가
            int logLength = gameService.logLength(roomID);
            System.out.println("승자는" + winner);
//            log.info(parts[0]); // 이게 승자의 accessToken
//            log.info(parts[1]); // 이게 패자의 accessToken

            Map<String, Object> computerInfo = gameService.getCom(roomID);

//            String comName = (String) computerInfo.get("comName");
            String uuidString = (String) computerInfo.get("uuid");
            UUID uuid = UUID.fromString(uuidString);
            if (parts[0].equals("computerToken")) {
                //승자가 컴퓨터인 경우
                resultUpdateService.updateWinComputer(uuid);
                int loseScore = resultUpdateService.updateLoser(parts[1], logLength);
                String info = "";
                info += resultUpdateService.getLoserInfo(parts[1]) + ":"
                        + resultUpdateService.getComWinnerInfo(uuid) + ":20:"+Integer.toString(loseScore);
                log.info("최종 결과를 도출합니다" + info);
                messagingTemplate.convertAndSend("/sub/" + roomId + "/finalInfo",
                        String.valueOf(info));
            } else {
                // 승자가 사용자인 경우
                int winScore = resultUpdateService.updateWinner(parts[0], logLength);
                resultUpdateService.updateLoseComputer(uuid);
                String info = "";
                info += resultUpdateService.getComLoserInfo(uuid) + ":"
                        + resultUpdateService.getWinnerInfo(parts[0]) + ":"+Integer.toString(winScore)+":-20";
                log.info("최종 결과를 도출합니다" + info);
                messagingTemplate.convertAndSend("/sub/" + roomId + "/finalInfo",
                        String.valueOf(info));
            }

            log.info("컴퓨터와 게임할 때 점수 업데이트까지 완료");


        } else {
            // 사람이랑 하는 경우
            gameService.messageInsert(roomID, winner);

            if (gameService.evenReturn(roomID) % 2 == 1) {
                String result = gameService.winnerAndLoserToken(roomID, winner);
                String[] parts = result.split(":");
//                log.info(parts[0]); // 이게 승자의 accessToken
//                log.info(parts[1]); // 이게 패자의 accessToken
                gameService.updateLog(roomID, winner);
                log.info("나와 상대가 선택했던 정보들을 DB에 저장합니다");
                int logLength = gameService.logLength(roomID);
                int winScore = resultUpdateService.updateWinner(parts[0], logLength);
                int loseScore = resultUpdateService.updateLoser(parts[1], logLength);
                log.info("DB에 승자와 패자 정보를 갱신합니다");
                String info = "";
                info += resultUpdateService.getLoserInfo(parts[1]) + ":"
                        + resultUpdateService.getWinnerInfo(parts[0]) + ":" + Integer.toString(winScore) + ":" + Integer.toString(loseScore);
                log.info("최종 결과를 도출합니다" + info);

                // 이때 최종 결과를 보내는거니까 게임이 전부 끝났다는 것을 의미한다.
                messagingTemplate.convertAndSend("/sub/" + roomId + "/finalInfo",
                        String.valueOf(info));

            }
            gameService.cleanList(roomID);
        }

    }

    @MessageMapping("/{roomId}/alive")
    public void checkConnection(@DestinationVariable String roomId,
                                @RequestBody Map<String, Object> messageBody) {
        int roomID = Integer.parseInt(roomId);
        int nowNumber = (int) messageBody.get("nowNumber");
        gameService.whoIn(roomID, nowNumber);
        gameService.aliveCheck(roomID);
    }

    @MessageMapping("/{roomId}/panShow")
    public void showingPan(@DestinationVariable String roomId, @RequestBody Map<String, Object> messageBody) {
        // 1.5 초를 쉬고 명령을 보내줄 것이다. // 근데 이 명령이 2번 들어올테니 이것도 처리를 해줘야 한다.
        int roomID = Integer.parseInt(roomId);
        String nickname = (String) messageBody.get("nickname");
        int pan = (int) messageBody.get("pan");
        System.out.println("panshow 입장");
        System.out.println("nickname은" + nickname);
        System.out.println("pan은" + pan);
        int comCheck = gameService.isComputer(roomID);
        if (comCheck == 1) {
            // 컴퓨터와의 대전이다!
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            messagingTemplate.convertAndSend("/sub/" + roomId + "/startinggame", "start");
        } else {
            // 사람끼리의 대전이다
            gameService.messageInsert(roomID, nickname);
            int cnt = gameService.evenReturn(roomID);
            if (cnt == 1) {
                // 혼자 명령이 들어왔을 때 => 정상적으로 작동했을 때는 2명이 들어오는 순간 나갈 수 있을 것이다.
                // 하지만 만약에 게임이 시작한 이후 갑자기 한 명이 나가버린다면 명령을 받지 못하는 경우가 발생한다.
                int errorCnt = 0;
                while (true) {
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                    int temp = gameService.evenReturn(roomID);
                    if (temp == 2) {
                        break;
                    }
                    if (errorCnt >= 5) {
                        if(pan!=1){
                            // 처음 시작할 때가 아니고 현재 한 놈이 나간 상황이다.
                            // 그럼 나간 놈이 졌다고 해야겠지?
                            String winner = gameService.returnName(roomID); // 얘가 승자다
                            messagingTemplate.convertAndSend("/sub/" + roomId + "/error",
                                    "승자는" + " " + winner);
                            gameService.cleanList(roomID);
                        }
                        System.out.println("메시지 보냄");
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/escape", "escape");
                        break;
                    }
                    errorCnt += 1;
                }
            } else if (cnt == 2) {
                gameService.cleanList(roomID);
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                messagingTemplate.convertAndSend("/sub/" + roomId + "/startinggame", "start");
            }
        }
    }

    @MessageMapping("/{roomId}/noLeave")
    public void noLeave(@DestinationVariable String roomId) {
        int roomID = Integer.parseInt(roomId);
        gameService.noLeaveUpdate(roomID);
    }
}
