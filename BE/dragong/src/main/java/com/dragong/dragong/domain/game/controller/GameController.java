package com.dragong.dragong.domain.game.controller;

import com.dragong.dragong.domain.game.dto.PeopleCounter;
import com.dragong.dragong.domain.game.service.GameService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.Message;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.util.HashMap;
import java.util.Map;


@RestController
public class GameController {
    @Autowired
    private PeopleCounter peopleCounter;
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    @Autowired
    private GameService gameService;



    @MessageMapping("/{roomId}/pickwhat")
    public void handleChatMessage(@DestinationVariable String roomId, String message) {
        // 무엇을 선택했는지 저장하기 위해서
        System.out.println("선택한 값 저장을 위해 controller 입장");
        System.out.println(message);
        String[] parts = message.split(":");
        if (parts.length == 2) {
            String nickname = parts[0].trim();
            String picked = parts[1].trim();
            gameService.gameStack(roomId, nickname, picked);
        } else {
            System.out.println("올바른 메시지 형식이 아님");
        }
    }

    @GetMapping("/wait")
    public ResponseEntity<Map<String, Integer>> assignRoom() {
        peopleCounter.incrementPeopleCount();
        System.out.println("대기방 입장"); // start game을 누르는 순간 입장
        int nowNumber = peopleCounter.getPeopleCnt(); // 내가 몇 번째로 들어온 인간인지 확인
        // 내가 반환해야 하는 숫자는 nowNumber + 1 / 2를 반환해야합니다.
        int roomId = (nowNumber + 1) / 2;
        // roomId를 JSON 형식으로 반환
        Map<String, Integer> response = new HashMap<>();
        response.put("roomId", roomId);
        return ResponseEntity.ok(response);
    }

    @MessageMapping("/{roomId}/checkNum")
    @SendTo("/sub/{roomId}/numCheck")
    public String checkNum(@DestinationVariable String roomId, String message) {
        // 게임 시작 여부를 정하기 위해서
        System.out.println("현재 몇명인지 확인합니다");
        System.out.println(message);
        String nickname = message;

        int standard = gameService.giInit(roomId, nickname) % 2;

        // return 하는 값이 1 이라면 아직 방에 1명만 들어가 있다는 말
        // return 하는 값이 0 이라면 방에 2명이 들어간 상황이라는 말

        if (standard == 0) {
            // 0 일때 게임이 시작하니까
            // gi가 몇개인지 보내줘야겠지?
            String giMessage = gameService.giReturn(roomId);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi", String.valueOf(giMessage));
        }
        return String.valueOf(standard); // 처리된 메시지 다시 클라이언트로 전송
    }

    @MessageMapping("/{roomId}/Count")
    public void Count(@DestinationVariable String roomId,String nickname) {
        // 카운트 다운을 해준다.
        int errorCnt = 0;

        gameService.messageInsert(roomId,nickname);
        int localCnt = gameService.evenReturn(roomId);
        if (localCnt % 2 == 0) {
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
                    while(gameService.evenReturn(roomId)!=2){
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        System.out.println("아직 양쪽으로부터 값을 받지 못했습니다");
                    }
                    String answer = gameService.gameResult(roomId);
                    // 이건 이제 0초가 되는 순간을 생각하는건데. => 지금은 그냥 바로 재 경기를 실시하거나, 게임 결과가 나왔다.
                    // 하지만 이 사이에 gif를 추가해줄 계획이다. gif를 보여주는 시간은 일단 3초라고 생각하자.
                    System.out.println(answer);
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
                    errorCnt=0;
                    messagingTemplate.convertAndSend("/sub/" + roomId + "/countdown", String.valueOf(i));

                    while(gameService.evenReturn(roomId)!=2){
                        //양쪽에서 값을 받지 못한 경우 넘어갈 수 없다.
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        System.out.println("아직 양쪽으로부터 값을 받지 못했습니다");
                        errorCnt +=1;

                        if(errorCnt>=3){
                            //이 말은 결국 연결이 끊긴 상황이란 말이니까. 양쪽에 에러 메세지를 보내야한다.
                            if(gameService.evenReturn(roomId)==0){
                                // 둘 다 들어오지 않은 경우 => 이건 그냥 아무 일도 안 일어난다. 둘다 나갔는데 뭔 일이 일어나냐..

                                System.out.println("현재 이거 실행");
                                return;
                            }else{
                                // 한 명만 들어온 경우 => 남아 있는 한 명이 승리했다고 메시지를 보내줘야겠지?
                                System.out.println("현재 이거 실행1");
                                String remainName = gameService.returnName(roomId);
                                messagingTemplate.convertAndSend("/sub/" + roomId + "/error", "승자는"+" "+remainName);
                                gameService.cleanList(roomId); // 값을 정리해준다.
                                return;
                            }


                        }
                    }
                    gameService.cleanList(roomId); // 양쪽에서 값을 전달 받았으니 다시 0으로 정리를 해준다.

                }
                System.out.println(i);
            }

            String giMessage = gameService.giReturn(roomId);
            messagingTemplate.convertAndSend("/sub/" + roomId + "/countGi", String.valueOf(giMessage));
        }
    }

    @MessageMapping("/{roomId}/dispose")
    public void disposeHandle() {
        // 방을 폭파시켜야 한다.
        System.out.println("방 폭파 명령을 받음");
        int nowNumber = peopleCounter.getPeopleCnt(); // 내가 몇 번째로 들어온 인간인지 확인
        if (nowNumber % 2 == 1) {
            peopleCounter.incrementPeopleCount();
        }
    }

    @MessageMapping("/{roomId}/timereturn")
    public void gotTime(@DestinationVariable String roomId, String nickname) {
        // 이게 뭐냐? 5,4,3,2,1 이런식으로 카운트 다운을 할 때 제대로 시간을 각 클라이언트에서 받아오고 있는지 확인하기 위한 것.
        System.out.println("현재 카운트 다운을 받아오고 있습니다" + " " + nickname);
        gameService.messageInsert(roomId,nickname);
    }
}