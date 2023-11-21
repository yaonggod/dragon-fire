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

        int maxFloor = resultUpdateService.getMaxFloor(accessToken);
        Map<String, Integer> response = new HashMap<>();
        response.put("maxFloor", maxFloor); // 내가 현재 들어갈 수 있는 타워의 층수
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
        int roomNumber = Integer.parseInt(requestBody.get("roomNumber"));
        towerService.chooseBoss(roomNumber, nowFloor); // 보스의 정보를 넣어준다.
        log.info("방 정보는 :" + roomNumber);

        towerService.giInit(roomNumber, nickname); // 나의 기 정보를 초기화해주고 // 즉 나의 기가 먼저 들어간다.
        String bossName = (String) towerService.getBoss(roomNumber).get("bossName");
        int bossLife = (int) towerService.getBoss(roomNumber).get("bossLife");
        log.info("받아온 보스 이름은?" + bossName);
        towerService.giInit(roomNumber, bossName); // 보스의 기 정보를 초기화해준다.
        towerService.initHpData(roomNumber, nickname, 3);
        towerService.initHpData(roomNumber, bossName, bossLife);
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
    public void Count(@DestinationVariable String nickname, String roomNumber) {
        // 카운트 다운을 해준다.
        int roomID = Integer.parseInt(roomNumber);
        int errorCnt = 0;
        log.info("시간을 보여줍니다");
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
                messagingTemplate.convertAndSend("/sub/" + nickname + "/countdown", String.valueOf(i)); // 0초도 한번 보내준다.
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                if (towerService.choosedSize(roomID) != 2) {
                    System.out.println("error 입장");
                    messagingTemplate.convertAndSend("/sub/" + nickname + "/error", "승자는" + " " + "없어도된다");
                    return;
                }
                String answer = towerService.showResult(roomID);
                // 여기서 만약에 answer의 가장 끝부분이 "안끝남"이 아니라면 gi 정보를 초기화 해주면 되지 않을까?
                // 이제 승 정보를 반환해야지
                String[] information = answer.split(" ");
                System.out.println(information[3]); // 이게
                if (information[3].equals("끝냅니다")) {
                    // 기 정보를 0, 0 으로 수정해줘야 한다.
                    towerService.giReset(roomID);
                    towerService.cleanBossChoose(roomID);
                }
                log.info("반환할 결과값은: " + answer);
                towerService.cleanMessageReceiver(roomID); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.
                for (int j = 3; j >= 0; j--) {
                    // 이건 뭘 뽑았는지 보여주는 시간이다.
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                    messagingTemplate.convertAndSend("/sub/" + nickname + "/selected", String.valueOf(j) + " " + answer);
                }
                // 이게 결과값을 반환하는 것이다. //
                if (information[3].equals("나갑니다")) {
                    messagingTemplate.convertAndSend("/sub/" + nickname + "/result", answer);
                    return;
                } else {
                    messagingTemplate.convertAndSend("/sub/" + nickname + "/result", answer);
                }

            } else {
                errorCnt = 0;
                messagingTemplate.convertAndSend("/sub/" + nickname + "/countdown", String.valueOf(i)); // 이게 시간을 보내주는 것이다.
                while (towerService.messageRecevierSize(roomID) != 2) {
                    try {
                        Thread.sleep(300);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                    log.info("보스 레이드 도중 아직 pingpong 값을 받지 못하였습니다.");
                    errorCnt += 1;
                    if (errorCnt >= 7) {

                        log.info("현재 연결이 끊긴 상황입니다.");
                        messagingTemplate.convertAndSend("/sub/" + nickname + "/error", "승자는" + " " + "???????");
                        return;

                    }
                }
                towerService.cleanMessageReceiver(roomID);

            }
        }
        String giMessage = towerService.returnGi(roomID);
        //이제 hp 정보를 반환해보자
        String HpInformation = towerService.returnHpData(roomID);
        messagingTemplate.convertAndSend("/sub/" + nickname + "/countGi", String.valueOf(giMessage));
        messagingTemplate.convertAndSend("/sub/" + nickname + "/HpInfo", String.valueOf(HpInformation));


    }


    @MessageMapping("/{nickname}/timecheck")
    public void gotTime(@DestinationVariable String nickname, String roomNumber) {
        log.info("타임 정보를 받아오고 있습니다");
        log.info("현재 보스 레이드 중인 사람은:" + nickname);
        log.info("현재 내가 차지하고 있는 방은?" + roomNumber);
        int roomID = Integer.parseInt(roomNumber);

        String bossName1 = (String) towerService.getBoss(roomID).get("bossName");
        Map<String, Object> bossInfo = towerService.getBoss(roomID); // 보스 정보 가져오기

        String bossName = (String) bossInfo.get("bossName");
        log.info("현재 카운트 다운 정보를 받아오고 있습니다.+ " + nickname);
        log.info("현재 전투 중인 보스의 이름은: " + bossName);
        towerService.messageInsert(roomID, nickname);
        towerService.messageInsert(roomID, bossName);


    }


    @MessageMapping("/{nickname}/chooseWhat")
    public void handleChatMessage(@DestinationVariable String nickname, String message) {
        // 무엇을 선택했는지 저장하기 위해서
        log.info("선택한 값 저장을 위해 controller 입장");
        String[] parts = message.split(":");
        if (parts.length == 3) {
            String picked = parts[1].trim();
            int roomID = Integer.parseInt(parts[2].trim());
            Map<String, Object> bossInfo = towerService.getBoss(roomID);
            String bossName = (String) bossInfo.get("bossName");

            towerService.pickStack(roomID, nickname, picked); // 내가 뭘 선택했는지 넣는다.
            String input = "";
            input = towerService.getBossTop(roomID);
            towerService.pickStack(roomID, bossName, input);

        } else {
            log.info("올바른 메시지 형식이 아닙니다");
        }


    }

    @MessageMapping("/{nickname}/updateMaxFloor")
    public void updateMaxFloor(@RequestBody Map<String, String> requestBody) {
        log.info("승리했으니 최종 층수를 업데이트 해줍니다");
        String accessToken = requestBody.get("Authorization");
        int nowFloor = Integer.parseInt(requestBody.get("nowFloor"));
        log.info(accessToken);
        log.info(requestBody.get("nowFloor"));
        resultUpdateService.updateMaxFloor(accessToken, nowFloor);

    }


}
