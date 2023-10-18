package com.dragong.dragong.domain.game.controller;

import com.dragong.dragong.domain.game.dto.PeopleCounter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.Message;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;


@RestController
public class GameController {
    @Autowired
    private PeopleCounter peopleCounter;
    @MessageMapping("/ws/{roomId}/chat")
    public void handleChat(@DestinationVariable String roomId, Message message) {
        // roomId를 이용하여 방 관련 처리 수행
        System.out.println("controller들어옴");
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
}