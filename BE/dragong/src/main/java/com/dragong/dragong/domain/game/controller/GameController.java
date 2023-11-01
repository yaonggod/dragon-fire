package com.dragong.dragong.domain.game.controller;

import com.dragong.dragong.domain.game.service.GameService;
import com.dragong.dragong.domain.game.service.ResultUpdateService;
import com.dragong.dragong.domain.playResult.service.PlayResultService;
import lombok.extern.slf4j.Slf4j;
import org.apache.catalina.util.ToStringUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.util.HashMap;
import java.util.Map;


@RestController
@Slf4j
public class GameController {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    @Autowired
    private GameService gameService;
    @Autowired
    private ResultUpdateService resultUpdateService;

    @GetMapping("/wait")
    public ResponseEntity<Map<String, Integer>> assignRoom(@RequestHeader("Authorization") String authorizationHeader, @RequestHeader("X-Nickname") String nickname) {
        String accessToken = authorizationHeader.substring(7); // accessToken을 받아온다.
        log.info("받아온 accessToken : " + accessToken);
        log.info("받아온 nickname : " + nickname);
        log.info("대기방에 입장합니다.");
        int nowNumber = gameService.enter(); // 몇 번째로 들어온 사람인지 확인한다.
        // 내가 반환해야 하는 숫자는 nowNumber + 1 / 2를 반환해야합니다.
        int roomId = (nowNumber + 1) / 2;
        // roomId를 JSON 형식으로 반환

        gameService.accessTokenUpdate(roomId, accessToken, nickname);
        Map<String, Integer> response = new HashMap<>();
        response.put("roomId", roomId);
        return ResponseEntity.ok(response);
    }

    @MessageMapping("/{roomId}/pickwhat")
    public void handleChatMessage(@DestinationVariable String roomId, String message) {
        // 무엇을 선택했는지 저장하기 위해서
        log.info("선택한 값 저장을 위해 controller 입장");
        log.info("받아온 값 출력: " + message);
        String[] parts = message.split(":");
        if (parts.length == 2) {
            String nickname = parts[0].trim();
            String picked = parts[1].trim();
            gameService.gameStack(roomId, nickname, picked);
        } else {
            log.info("올바른 메시지 형식이 아닙니다");
        }
    }


    @MessageMapping("/{roomId}/checkNum")
    @SendTo("/sub/{roomId}/numCheck")
    public String checkNum(@DestinationVariable String roomId, String nickname) {
        // 게임 시작 여부를 정하기 위해서
        // 이건 socket 연결이 되자마자 자동적으로 보내는 것이다.
        log.info("현재 몇명이 접속했는지 확인하기 위해 실행합니다");
        log.info("받아온 닉네임은? " + nickname);

        int standard = gameService.giInit(roomId, nickname) % 2;
        // return 하는 값이 1 이라면 아직 방에 1명만 들어가 있다는 말
        // return 하는 값이 0 이라면 방에 2명이 들어간 상황이라는 말
        if (standard == 0) {
            // 0 일때 게임이 시작하니까
            // gi가 몇개인지 보내줘야겠지?
            gameService.gameStart();
            String giMessage = gameService.giReturn(roomId);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi", String.valueOf(giMessage));
        }
        return String.valueOf(standard); // 처리된 메시지 다시 클라이언트로 전송
    }

    @MessageMapping("/{roomId}/Count")
    public void Count(@DestinationVariable String roomId, String nicknameRound) {
        // 카운트 다운을 해준다.
        int errorCnt = 0;
        log.info("Count를 시작합니다.");
        String[] parts = nicknameRound.split(":");
        log.info("닉네임 부분:" + parts[0]);
        log.info("몇번째 라운드인가?:" + parts[1]);
        gameService.messageInsert(roomId, parts[0]);
        int localCnt = gameService.evenReturn(roomId);
        boolean gameStart = false;
        int standard = 0;
        if (Integer.parseInt(parts[1]) == 0) {
            // 처음 들어오는 경우
            log.info("첫 게임인 경우");
            if (localCnt % 2 == 0) {
                log.info("한 방에 두 명이 들어온 경우");
                gameStart = true;
            }
        } else {
            //이건 이제 처음들어온게 아니라 그 이후에 들어온 경우를 생각
            log.info("두 번째 이후의 게임인 경우");
            int cnt = 0;
            while (cnt < 3 && localCnt % 2 != 0) {
                try {
                    Thread.sleep(700);
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
            gameService.cleanList(roomId);
            for (int i = 3; i >= 0; i--) {

                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }

                if (i == 0) {
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown", String.valueOf(i)); // 0초도 한번 보내준다.
                    // 보내주는 이유는 한 명이라도 선택을 하지 않았을 경우, 해당 유저의 닉네임을 처리해야하기 때문(이건 선택을 하지 않을 상황이지, 튕긴 상황이 아니다)
                    errorCnt = 0;
                    while (gameService.evenReturn(roomId) != 2) {
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        log.info("현재 문제가 발생하는 곳의 roomId는: " + roomId);
                        log.info("0초인데 아직 양쪽으로부터 값을 받지 못했습니다");
                        errorCnt += 1;

                        if (errorCnt >= 3) {
                            //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                            if (gameService.evenReturn(roomId) == 0) {
                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..
                                log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                return;
                            } else {
                                // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
                                log.info("현재 연결이 끊긴 상황이고, 한쪽만 연결이 끊긴 상황입니다.");
                                String remainName = gameService.returnName(roomId);
                                messagingTemplate.convertAndSend("/sub/" + roomId + "/error", "승자는" + " " + remainName);
                                gameService.cleanList(roomId); // 값을 정리해준다.
                                return;
                            }
                        }
                    }
                    String answer = gameService.gameResult(roomId);
                    // 이건 이제 0초가 되는 순간을 생각하는건데. => 지금은 그냥 바로 재 경기를 실시하거나, 게임 결과가 나왔다.
                    // 하지만 이 사이에 gif를 추가해줄 계획이다. gif를 보여주는 시간은 일단 3초라고 생각하자.
                    log.info("반환할 결과값은: " + answer);
                    gameService.cleanList(roomId); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
                    for (int j = 3; j >= 0; j--) {
                        try {
                            Thread.sleep(1000);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/selected", String.valueOf(j) + " " + answer);
                    }
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);

                } else {
                    errorCnt = 0;
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown", String.valueOf(i));

                    while (gameService.evenReturn(roomId) != 2) {
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        log.info("0초가 아닌데 아직 양쪽으로부터 값을 받지 못했습니다");
                        errorCnt += 1;

                        if (errorCnt >= 3) {
                            //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                            if (gameService.evenReturn(roomId) == 0) {
                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..

                                log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                return;
                            } else {
                                // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
                                log.info("현재 연결이 끊긴 상황이고, 한쪽만 연결이 끊긴 상황입니다.");
                                String remainName = gameService.returnName(roomId);
                                messagingTemplate.convertAndSend("/sub/" + roomId + "/error", "승자는" + " " + remainName);
                                gameService.cleanList(roomId); // 값을 정리해준다.
                                return;
                            }
                        }
                    }
                    gameService.cleanList(roomId); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.

                }
            }
            String giMessage = gameService.giReturn(roomId);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi", String.valueOf(giMessage));
        }
    }

    @MessageMapping("/{roomId}/dispose")
    public void disposeHandle(@DestinationVariable String roomId, String message) {
        // 방을 폭파시켜야 한다.
        log.info("방 폭파 명령을 받았습니다");
        //두명일 때는 false를 return 하고 혼자 있는 방을 나올 때는 true를 return 한다
        if (message.equals("true")) {
            // 혼자 일 때
            log.info("혼자인데 방 폭파 명령을 받았습니다.");
            gameService.giClear(roomId); // 기 정보 초기화
            gameService.gameStop(); // 대기 queue에서 한 명 빼기
            // accessToken 정보 빼기
            gameService.deleteAccessToken(roomId);
        }

    }

    @MessageMapping("/{roomId}/timereturn")
    public void gotTime(@DestinationVariable String roomId, String nickname) {
        // 이게 뭐냐? 5,4,3,2,1 이런식으로 카운트 다운을 할 때 제대로 시간을 각 클라이언트에서 받아오고 있는지 확인하기 위한 것.
        log.info("현재 카운트 다운 정보를 받아오고 있습니다.+ " + nickname);
        gameService.messageInsert(roomId, nickname);
    }

    @MessageMapping("/{roomId}/updateRecord")
    public void updateRecord(@DestinationVariable String roomId, String winner) {
        // 이제 결과를 받아올건데
        System.out.println("마지막 결과를 반환합니다: " + winner);
        String result = gameService.winnerAndLoserToken(roomId, winner);
        String[] parts = result.split(":");

        resultUpdateService.updateWinner(parts[0]);
        resultUpdateService.updateWinner(parts[1]);
    }

//    @GetMapping("/test")
//    public String testing() {
//        resultUpdateService.testing();
//        log.info("테스트합니다");
//        System.out.println("테스트합니당");
//        return "하윙";
//    }
}