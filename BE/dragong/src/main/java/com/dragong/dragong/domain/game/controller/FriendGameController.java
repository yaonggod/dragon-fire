package com.dragong.dragong.domain.game.controller;

import com.dragong.dragong.domain.game.dto.request.FriendAcceptGameRequestDto;
import com.dragong.dragong.domain.game.dto.response.FriendAssignRoomResponseDto;
import com.dragong.dragong.domain.game.dto.response.FriendConnectGameResponseDto;
import com.dragong.dragong.domain.game.service.FriendGameService;
import com.dragong.dragong.domain.game.service.ResultUpdateService;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
@RequiredArgsConstructor
public class FriendGameController {

    private final FriendGameService friendGameService;
    private final SimpMessagingTemplate messagingTemplate;
    private final ResultUpdateService resultUpdateService;

    @PostMapping("/friend-game/wait")
    public ResponseEntity<?> assignRoom(
            @RequestHeader("Authorization") String accessToken,
            HttpServletResponse httpServletResponse) {
//        String nickname = requestBody.get("nickname");
//        log.info("받아온 nickname : " + nickname);
//        log.info("받아온 accessToken : " + accessToken);
//        log.info("대기방에 입장합니다.");
//        int nowNumber = gameService.enter(); // 몇 번째로 들어온 사람인지 확인한다.
//        // 내가 반환해야 하는 숫자는 nowNumber + 1 / 2를 반환해야합니다.
//        log.info("현재 내가 들어온 순서는" + nowNumber + "입니다");
//        int roomId = (nowNumber + 1) / 2;
//        log.info("현재의 roomId는" + roomId + "입니다");
//        // roomId를 JSON 형식으로 반환
//        gameService.initWinData(roomId, nickname); // 승 정보를 처음에 초기화 해준다.
//        gameService.accessTokenUpdate(roomId, accessToken, nickname);
//        Map<String, Integer> response = new HashMap<>();
//        int roomId = friendGameService.enter();
//        friendGameService.initWinData(roomId, nickname);
//        response.put("roomId", roomId);
//        response.put("nowNumber", 1); // 내가 몇 번째인지를 전해준다.

        FriendAssignRoomResponseDto response = friendGameService.assignRoom(accessToken,
                httpServletResponse);

        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/friend-game/accept")
    public ResponseEntity<?> friendAcceptGame(@RequestHeader("Authorization") String accessToken,
            @RequestBody FriendAcceptGameRequestDto request) {

        friendGameService.acceptGame(accessToken, request);

        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/friend-game/reject")
    @SendTo("/sub/friend-game/{roomId}/rejectCheck")
    public ResponseEntity<?> friendRejectGame(@RequestHeader("Authorization") String accessToken,
            @RequestBody FriendAcceptGameRequestDto request) {

        friendGameService.acceptGame(accessToken, request);

        messagingTemplate.convertAndSend("/sub/friend-game/" + request.getRoomId() + "/rejectCheck",
                1);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @MessageMapping("/friend-game/{roomId}/checkNum")
    @SendTo("/sub/friend-game/{roomId}/numCheck")
    public String checkNum(@DestinationVariable String roomId, String nickname) {
        // 게임 시작 여부를 정하기 위해서
        // 이건 socket 연결이 되자마자 자동적으로 보내는 것이다.
        int friendRoomId = Integer.parseInt(roomId) - friendGameService.FRIEND_WEBSOCKET_ROOM;
        log.info("현재 몇명이 접속했는지 확인하기 위해 실행합니다");
        log.info("받아온 닉네임은? " + nickname);
        int standard = friendGameService.giInit(friendRoomId, nickname) % 2;
        // return 하는 값이 1 이라면 아직 방에 1명만 들어가 있다는 말
        // return 하는 값이 0 이라면 방에 2명이 들어간 상황이라는 말
        if (standard == 0) {
            // 0 일때 게임이 시작하니까
            // gi가 몇개인지 보내줘야겠지?
            log.info("gamestart 명령이 보내짐");

            String giMessage = friendGameService.giReturn(friendRoomId);
            FriendConnectGameResponseDto userInfo = friendGameService.getUserInfo(friendRoomId);

            messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/gameRecord", userInfo);
            messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/countGi",
                    String.valueOf(giMessage));
        } else {
            // 이걸로 1~2초마다 front로 신호를 주고 만약에 신호에 대한 반응이 오지 않으면 비정상적으로 방을 나갔다라고 판단하자
            // 해당 roomId는 가지고 있으니까
            while (true) {
                // 내가 들어왔는데 만약에 내가 짝수 번째 사람인데 여기서 돌고 있는 경우라면? => 바로 나가야 한다.
                messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/stillConnect",
                        "still");
                int compare = friendGameService.savingReturn(friendRoomId); // 보내기 전의 값

                try {
                    Thread.sleep(220);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                int inside = friendGameService.giCnt(friendRoomId);
//                log.info("inside를 출력합니다" + inside);

                // 친구랑 내가 모두 들어와서 게임을 시작한다.
                if (inside == 2) {
                    log.info("방에  2명이 들어와서 탈출합니다");
                    friendGameService.savingReset(friendRoomId);
                    return "방에 2명 들어와서 탈출";
                }

                int value = friendGameService.savingReturn(friendRoomId);
                if (compare == value) {
                    log.info("연결이 끊겼습니다");
                    friendGameService.stopGame(friendRoomId);
                    break;
                }
            }
        }
        return String.valueOf(standard); // 처리된 메시지 다시 클라이언트로 전송
    }

    @MessageMapping("/friend-game/{roomId}/pickwhat")
    public void handleChatMessage(@DestinationVariable String roomId, String message) {
        // 무엇을 선택했는지 저장하기 위해서
        int friendRoomId = Integer.parseInt(roomId) - friendGameService.FRIEND_WEBSOCKET_ROOM;
        log.info("선택한 값 저장을 위해 controller 입장");
        log.info("받아온 값 출력: " + message);
        String[] parts = message.split(":");
        if (parts.length == 2) {
            String nickname = parts[0].trim();
            String picked = parts[1].trim();
            friendGameService.gameStack(friendRoomId, nickname, picked);
        } else {
            log.info("올바른 메시지 형식이 아닙니다");
        }
    }

    @MessageMapping("/friend-game/{roomId}/Count")
    public void Count(@DestinationVariable String roomId, String nicknameRound) {
        // 카운트 다운을 해준다.

        int errorCnt = 0;
        int friendRoomId = Integer.parseInt(roomId) - friendGameService.FRIEND_WEBSOCKET_ROOM;
        log.info("Count를 시작합니다.");
        String[] parts = nicknameRound.split(":");
        log.info("닉네임 부분:" + parts[0]);
        log.info("몇번째 라운드인가?:" + parts[1]);
        friendGameService.messageInsert(friendRoomId, parts[0]);
        int localCnt = friendGameService.evenReturn(friendRoomId);
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
        //friendGameService.messageInsert(roomId, nickname);

        if (gameStart) {
            log.info("gameStart 입장");
            friendGameService.cleanList(friendRoomId);
            for (int i = 3; i >= 0; i--) {
                if (i != 3) {
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
                if (i == 0) {
                    messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/countdown",
                            String.valueOf(i)); // 0초도 한번 보내준다.
                    // 보내주는 이유는 한 명이라도 선택을 하지 않았을 경우, 해당 유저의 닉네임을 처리해야하기 때문(이건 선택을 하지 않을 상황이지, 튕긴 상황이 아니다)
                    errorCnt = 0;
                    while (friendGameService.evenReturn(friendRoomId) != 2) {
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(900);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
//                        log.info("현재 문제가 발생하는 곳의 friendRoomId는: " + friendRoomId);
//                        log.info("0초인데 아직 양쪽으로부터 값을 받지 못했습니다");
                        errorCnt += 1;

                        if (errorCnt >= 7) {
                            //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                            //원래는 3이었는데 7으로 바꿈 => 결국 양쪽에서 값을 0.9초 안에 보내지 않으면 한쪽의 연결이 끊겼다고 판단하게 하는거라서 너무 짧다고 판단
                            //7로 바꿔서 2.1초 동안 연결이 없으면 끊겼다고 판단하는건데, 이걸로도 문제가 발생한다면 숫자를 늘리거나 다른 문제가 있다고 판단
                            if (friendGameService.evenReturn(friendRoomId) == 0) {
                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..
                                log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                return;
                            } else {
                                // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
//                                System.out.println("#################");
                                log.info("현재 연결이 끊긴 상황이고, 한쪽만 연결이 끊긴 상황입니다.;;;;;;");
                                String remainName = friendGameService.returnName(friendRoomId);
                                messagingTemplate.convertAndSend(
                                        "/sub/friend-game/" + roomId + "/error",
                                        "승자는" + " " + remainName);
                                friendGameService.cleanList(friendRoomId); // 값을 정리해준다.
                                return;
                            }
                        }
                    }
                    String answer = friendGameService.gameResult(friendRoomId);
                    // 여기서 만약에 answer의 가장 끝부분이 "안끝남"이 아니라면 gi 정보를 초기화 해주면 되지 않을까?

                    // 이제 승 정보를 반환해야지
                    String[] information = answer.split(" ");
                    System.out.println(information[3]); // 이게
                    if (information[3].equals("끝냅니다")) {
                        // 기 정보를 0, 0 으로 수정해줘야 한다.
                        friendGameService.giReset(friendRoomId);
                    } else if (information[3].equals("계속합니다")) {
                        // 기 정보를 0,0 으로 수정해줘야 한다.
                        friendGameService.giReset(friendRoomId);
                    }
                    // 이건 이제 0초가 되는 순간을 생각하는건데. => 지금은 그냥 바로 재 경기를 실시하거나, 게임 결과가 나왔다.
                    // 하지만 이 사이에 gif를 추가해줄 계획이다. gif를 보여주는 시간은 일단 3초라고 생각하자.
                    log.info("반환할 결과값은: " + answer);
                    friendGameService.cleanList(friendRoomId); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
                    for (int j = 3; j >= 0; j--) {
                        // 이건 뭘 뽑았는지 보여주는 시간이다.
                        try {
                            Thread.sleep(900);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/selected",
                                String.valueOf(j) + " " + answer);
                    }
                    // 이게 결과값을 반환하는 것이다. // 이제는 단순하게 누
                    messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/result",
                            answer);

                } else {
                    errorCnt = 0;
                    messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/countdown",
                            String.valueOf(i));

                    while (friendGameService.evenReturn(friendRoomId) != 2) {
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(700);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        log.info("0초가 아닌데 아직 양쪽으로부터 값을 받지 못했습니다");
                        errorCnt += 1;

                        if (errorCnt >= 7) {
                            //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                            //원래는 3이었는데 7으로 바꿈 => 결국 양쪽에서 값을 0.9초 안에 보내지 않으면 한쪽의 연결이 끊겼다고 판단하게 하는거라서 너무 짧다고 판단
                            //7로 바꿔서 2.1초 동안 연결이 없으면 끊겼다고 판단하는건데, 이걸로도 문제가 발생한다면 숫자를 늘리거나 다른 문제가 있다고 판단
                            if (friendGameService.evenReturn(friendRoomId) == 0) {
                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..

                                log.info("현재 연결이 끊긴 상황이고, 양쪽에서 전부 연결이 끊긴 상황입니다.");
                                return;
                            } else {
                                // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
                                log.info("현재 연결이 끊긴 상황이고, 한쪽만 연결이 끊긴 상황입니다.#########");
                                log.info(friendGameService.returnName(friendRoomId));
                                String remainName = friendGameService.returnName(friendRoomId);
                                messagingTemplate.convertAndSend(
                                        "/sub/friend-game/" + roomId + "/error",
                                        "승자는" + " " + remainName);
                                friendGameService.cleanList(friendRoomId); // 값을 정리해준다.
                                return;
                            }
                        }
                    }
                    friendGameService.cleanList(friendRoomId); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.

                }
            }
            String giMessage = friendGameService.giReturn(friendRoomId);
            String winInformation = friendGameService.returnWinData(friendRoomId);
            messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/countGi",
                    String.valueOf(giMessage));
            messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/winData",
                    String.valueOf(winInformation));
        }
    }

    @MessageMapping("/friend-game/{roomId}/alive")
    public void checkConnection(@DestinationVariable String roomId,
            @RequestBody Map<String, Object> messageBody) {
        int roomID = Integer.parseInt(roomId) - friendGameService.FRIEND_WEBSOCKET_ROOM;
        int nowNumber = (int) messageBody.get("nowNumber");
        friendGameService.aliveCheck(roomID);
    }

    @MessageMapping("/friend-game/{roomId}/timereturn")
    public void gotTime(@DestinationVariable String roomId, String nickname) {
        int roomID = Integer.parseInt(roomId) - friendGameService.FRIEND_WEBSOCKET_ROOM;
        // 이게 뭐냐? 5,4,3,2,1 이런식으로 카운트 다운을 할 때 제대로 시간을 각 클라이언트에서 받아오고 있는지 확인하기 위한 것.
//        log.info("현재 카운트 다운 정보를 받아오고 있습니다.+ " + nickname);
        friendGameService.messageInsert(roomID, nickname);
    }

    @MessageMapping("/friend-game/{roomId}/updateRecord")
    public void updateRecord(@DestinationVariable String roomId, String winner) {
        // 이제 결과를 받아올건데
        int roomID = Integer.parseInt(roomId) - friendGameService.FRIEND_WEBSOCKET_ROOM;

        // 사람이랑 하는 경우
        friendGameService.messageInsert(roomID, winner);

        if (friendGameService.evenReturn(roomID) % 2 == 1) {

//            log.info("DB에 승자와 패자 정보를 갱신합니다");
            String info = "";
            info += friendGameService.updateRecord(roomID, winner);
//            log.info("최종 결과를 도출합니다" + info);

            // 이때 최종 결과를 보내는거니까 게임이 전부 끝났다는 것을 의미한다.
            messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/finalInfo",
                    String.valueOf(info));
            friendGameService.updateLog(roomID, winner);
            log.info("나와 상대가 선택했던 정보들을 DB에 저장합니다");
        }
        friendGameService.stopGame(roomID);

    }

    @MessageMapping("/friend-game/{roomId}/panShow")
    public void showingPan(@DestinationVariable String roomId, @RequestBody Map<String, Object> messageBody) {
        // 1.5 초를 쉬고 명령을 보내줄 것이다. // 근데 이 명령이 2번 들어올테니 이것도 처리를 해줘야 한다.
        int roomID = Integer.parseInt(roomId) - FriendGameService.FRIEND_WEBSOCKET_ROOM;
        String nickname = (String) messageBody.get("nickname");
        int pan = (int) messageBody.get("pan");
        // 사람끼리의 대전이다
        friendGameService.messageInsert(roomID, nickname);
        int cnt = friendGameService.evenReturn(roomID);
//        System.out.println(cnt);
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
                int temp = friendGameService.evenReturn(roomID);
                if (temp == 2) {
                    break;
                }
                if (errorCnt >= 5) {
//                    System.out.println("메시지 보냄");
                    if(pan!=1){
                        // 처음 시작할 때가 아니고 현재 한 놈이 나간 상황이다.
                        // 그럼 나간 놈이 졌다고 해야겠지?
                        String winner = friendGameService.returnName(roomID); // 얘가 승자다
                        messagingTemplate.convertAndSend("/sub/" + roomId + "/error",
                                "승자는" + " " + winner);
                        friendGameService.cleanList(roomID);
                    }
                    messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/escape", "escape");
                    break;
                }
                errorCnt += 1;
            }
        } else if (cnt == 2) {
            friendGameService.cleanList(roomID);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            messagingTemplate.convertAndSend("/sub/friend-game/" + roomId + "/startinggame", "start");
        }

    }
}
