package com.dragong.dragong.domain.game.controller;

import com.dragong.dragong.domain.game.service.GameService;
import com.dragong.dragong.domain.game.service.ResultUpdateService;
import com.dragong.dragong.domain.game.service.TowerService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@Slf4j
public class TowerController {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    @Autowired
    private GameService gameService;
    @Autowired
    private ResultUpdateService resultUpdateService;
    @Autowired
    private TowerService towerService;

    @PostMapping("/tower")
    public ResponseEntity<Map<String, Integer>> TowerRooms(@RequestHeader("Authorization") String accessToken, @RequestBody Map<String, String> requestBody) {
        // 여기 들어올 때는 내가 현재 몇 층까지 주파를 했는지, 그리고 오늘 도전 횟수가 몇번 남았는지를 확인해야한다.
        String nickname = requestBody.get("nickname");
        log.info("받아온 nickname : " + nickname);
        log.info("받아온 accessToken : " + accessToken);
        log.info("타워방에 입장합니다");

        Map<String, Integer> response = new HashMap<>();
        response.put("maxFloor", 1); // 내가 현재 들어갈 수 있는 타워의 층수
        response.put("chance", 2); // 이게 남은 타워 입장 횟수
        return ResponseEntity.ok(response);
    }

    @PostMapping("/towerEnter")
    public ResponseEntity<Map<String, Integer>> EnterTower(@RequestHeader("Authorization") String accessToken, @RequestBody Map<String, String> requestBody) {
        // 이제 타워로 입장하는 것이다.
        String nickname = requestBody.get("nickname");
        log.info("받아온 nickname : " + nickname);
        log.info("받아온 accessToken : " + accessToken);
        log.info("보스를 만나러 입장합니다.");
        int roomNumber = towerService.enter(); // roomId를 발급받는다. => 해당 roomId로 여러 데이터들을 저장
        // 이제 여기서 타워 입장 횟수를 1회 차감하고, towerScreen으로 내가 선택한 Floor를 넘기면 된다.
        Map<String, Integer> response = new HashMap<>();
        response.put("nowFloor", 1); // 일단은 1층을 선택했다고 가정하자.
        response.put("roomNumber", roomNumber);
        return ResponseEntity.ok(response);
    }

    @MessageMapping("/{nickname}/whenEnter")
    @SendTo("/sub/{nickname}/ready")
    public String checkNum(@DestinationVariable String nickname, @RequestBody Map<String, String> requestBody) {

        log.info("처음 보스맵에 입장했을 때");
        log.info("받아온 닉네임은? " + nickname);
        int nowFloor = Integer.parseInt(requestBody.get("nowFloor"));
        int roomNumber = towerService.enter(); // roomId를 발급받는다. => 해당 roomId로 여러 데이터들을 저장
        towerService.chooseBoss(roomNumber, nowFloor); // 보스의 정보를 넣어준다.
        towerService.giInit(roomNumber,nickname); // 나의 기 정보를 초기화해주고
        String bossName = (String) towerService.getBoss(roomNumber).get("bossName");
        towerService.giInit(roomNumber,bossName); // 보스의 기 정보를 초기화해준다.
        log.info("게임 시작할 준비가 완료되었습니다");

        String giMessage = towerService.giReturn(roomNumber);

        messagingTemplate.convertAndSend("/sub/" + nickname + "/countGi", String.valueOf(giMessage));
        return String.valueOf("0");

    }

    @MessageMapping("/{nickname}/whatPan")
    public void showingPan(@DestinationVariable String nickname, String nowFloor) {
        System.out.println(nickname);
        System.out.println(nowFloor); // 몇 층을 공략중인지
        messagingTemplate.convertAndSend("/sub/" + nickname + "/letsStart", "start");
    }

    @MessageMapping("/{nickname}/showTime")
    public void Count(@DestinationVariable String nickname, String nowFloor) {
        // 카운트 다운을 해준다.
        log.info("시간을 보여줍니다");
        int errorCnt = 0;
//        if (comCheck == 1) {
//            // Computer와 하는 경우
//            log.info("컴퓨터와의 게임 시작! 현재 Count 안");
//
//            for (int i = 3; i >= 0; i--) {
//                if (i != 3) {
//                    try {
//                        Thread.sleep(1000);
//                    } catch (InterruptedException e) {
//                        Thread.currentThread().interrupt();
//                    }
//                }
//                if (i == 0) {
//                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown", String.valueOf(i)); // 0초도 한번 보내준다.
//                    // 보내주는 이유는 한 명이라도 선택을 하지 않았을 경우, 해당 유저의 닉네임을 처리해야하기 때문(이건 선택을 하지 않을 상황이지, 튕긴 상황이 아니다)
//                    // computer와의 게임!
//                    String answer = gameService.gameResult(roomID);
//                    // 여기서 만약에 answer의 가장 끝부분이 "안끝남"이 아니라면 gi 정보를 초기화 해주면 되지 않을까?
//                    // 이제 승 정보를 반환해야지
//                    String[] information = answer.split(" ");
//                    System.out.println(information[3]); // 이게
//                    if (information[3].equals("끝냅니다")) {
//                        // 기 정보를 0, 0 으로 수정해줘야 한다.
//                        gameService.giReset(roomID);
//                        gameService.cleanStack(roomID);
//                    } else if (information[3].equals("계속합니다")) {
//                        // 기 정보를 0,0 으로 수정해줘야 한다.
//                        gameService.giReset(roomID);
//                        gameService.cleanStack(roomID);
//                    }
//                    // 이건 이제 0초가 되는 순간을 생각하는건데. => 지금은 그냥 바로 재 경기를 실시하거나, 게임 결과가 나왔다.
//                    // 하지만 이 사이에 gif를 추가해줄 계획이다. gif를 보여주는 시간은 일단 3초라고 생각하자.
//                    log.info("반환할 결과값은: " + answer);
//                    gameService.cleanList(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
//                    for (int j = 3; j >= 0; j--) {
//                        // 이건 뭘 뽑았는지 보여주는 시간이다.
//                        try {
//                            Thread.sleep(700);
//                        } catch (InterruptedException e) {
//                            Thread.currentThread().interrupt();
//                        }
//                        messagingTemplate.convertAndSend("/sub/" + roomId + "/selected", String.valueOf(j) + " " + answer);
//                    }
//                    // 이게 결과값을 반환하는 것이다. //
//                    if (information[3].equals("나갑니다")) {
//                        messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);
//                        return;
//                    } else {
//                        messagingTemplate.convertAndSend("/sub/" + roomId + "/result", answer);
//                    }
//
//                } else {
//                    errorCnt = 0;
//                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown", String.valueOf(i));
//
//                    while (gameService.evenReturn(roomID) != 2) {
//                        // 값을 보내지 않은 경우
//                        try {
//                            Thread.sleep(300);
//                        } catch (InterruptedException e) {
//                            Thread.currentThread().interrupt();
//                        }
//                        log.info("컴퓨터와의 대전 도중 아직 플레이어가 값을 입력하지 않았습니다");
//                        errorCnt += 1;
//
//                        if (errorCnt >= 7) {
//                            if (gameService.evenReturn(roomID) == 0) {
//                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..
//                                Map<String,Object>computerInfo = gameService.getCom(roomID);
//
//                                String comName = (String) computerInfo.get("comName");
//
//                                log.info("현재 연결이 끊긴 상황입니다.");
//                                messagingTemplate.convertAndSend("/sub/" + roomId + "/error", "승자는" + " " + comName);
//                                return;
//                            }
//                        }
//                    }
//                    gameService.cleanList(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
//
//                }
//            }
//            String giMessage = gameService.giReturn(roomID);
//            String winInformation = gameService.returnWinData(roomID);
//            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi", String.valueOf(giMessage));
//            messagingTemplate.convertAndSend("/sub/" + roomId + "/winData", String.valueOf(winInformation));
//        }


    }



}
