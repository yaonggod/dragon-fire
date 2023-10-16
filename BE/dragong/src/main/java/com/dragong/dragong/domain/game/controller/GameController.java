package com.dragong.dragong.domain.game.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/game")
public class GameController {

    @MessageMapping("/play")
    @SendTo("/topic/results")
    public ResponseEntity<String> playGame(String choice) {
        // 게임 로직을 구현
        // choice: 가위, 바위, 보 중 하나의 선택

        // 게임 결과 반환
        String result = "You win!";
        return ResponseEntity.ok(result);
    }

    @RequestMapping(value = "/play", method = RequestMethod.GET)
    public ResponseEntity<String> playGameREST(String choice) {
        // 게임 로직을 구현
        // choice: 가위, 바위, 보 중 하나의 선택

        // 게임 결과 반환
        String result = "You win!";
        return ResponseEntity.ok(result);
    }
}
