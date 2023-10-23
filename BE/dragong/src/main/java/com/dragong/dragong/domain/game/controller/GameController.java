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

    private int localCnt=0;

    @MessageMapping("/{roomId}/pickwhat")
    @SendTo("/sub/{roomId}/pickwhat")
    public String handleChatMessage(@DestinationVariable String roomId,String message) {
        // 무엇을 선택했는지 저장하기 위해서
        System.out.println("선택한 값 저장을 위해 controller 입장");
        System.out.println(message);
        String[] parts = message.split(":");
        if (parts.length == 2) {
            String nickname = parts[0].trim();
            String picked = parts[1].trim();
            gameService.gameStack(roomId,nickname,picked);
            return "success";
        } else {
            System.out.println("올바른 메시지 형식이 아님");
            return "error";
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
    @SendTo("/sub/{roomId}")
    public String checkNum(@DestinationVariable String roomId,String message) {
        // 게임 시작 여부를 정하기 위해서
        System.out.println("현재 몇명인지 확인합니다");
        System.out.println(message);
        String nickname = message;
        gameService.giInit(roomId,nickname);
        int standard = peopleCounter.getPeopleCnt() % 2;

        // return 하는 값이 1 이라면 아직 방에 1명만 들어가 있다는 말
        // return 하는 값이 0 이라면 방에 2명이 들어간 상황이라는 말

        if(standard==0){
            // 0 일때 게임이 시작하니까
            // gi가 몇개인지 보내줘야겠지?
            String giMessage = gameService.giReturn(roomId);
            messagingTemplate.convertAndSend("/sub/" + roomId+"/countGi", String.valueOf(giMessage));
        }
        return String.valueOf(standard); // 처리된 메시지 다시 클라이언트로 전송
    }

    @MessageMapping("/{roomId}/Count")
    public void Count(@DestinationVariable String roomId){
        // 카운트 다운을 해준다.
        localCnt+=1;
        if(localCnt%2==0){
            for(int i=5;i>=0;i--){
                try {
                    Thread.sleep(1000);
                }catch(InterruptedException e){
                    Thread.currentThread().interrupt();
                }

                if(i==0){
                    String answer= gameService.gameResult(roomId);
                    messagingTemplate.convertAndSend("/sub/" + roomId+"/result", answer);

                }else{
                    messagingTemplate.convertAndSend("/sub/" + roomId+"/countdown", String.valueOf(i));
                }
                System.out.println(i);
            }

            String giMessage = gameService.giReturn(roomId);
            messagingTemplate.convertAndSend("/sub/" + roomId+"/countGi", String.valueOf(giMessage));
        }
    }

    @MessageMapping("/{roomId}/dispose")
    public void disposeHandle() {
        // 방을 폭파시켜야 한다.
        System.out.println("방 폭파 명령을 받음");
        int nowNumber = peopleCounter.getPeopleCnt(); // 내가 몇 번째로 들어온 인간인지 확인
        if(nowNumber%2==1){
            peopleCounter.incrementPeopleCount();
        }
    }
}