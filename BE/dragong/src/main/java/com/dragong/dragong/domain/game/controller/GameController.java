package com.dragong.dragong.domain.game.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedList;
import java.util.Queue;


@RequiredArgsConstructor
@RestController
@RequestMapping("/game")
public class GameController {

    private Queue<String> waitingPlayers = new LinkedList<>();

    @MessageMapping("play")
    @SendTo("/topic/results")
    public ResponseEntity<String> playGame(@Payload String choice) {
        // 게임 로직을 구현
        // choice: 가위, 바위, 보 중 하나의 선택

        // 큐에서 대기 중인 플레이어 꺼내기
        String player1 = waitingPlayers.poll();
        String player2 = waitingPlayers.poll();

        if (player1 != null && player2 != null) {
            // 게임 로직을 통해 결과 계산
            String result = calculateGameResult(player1, player2, choice);

            // 결과를 브로드캐스트
            return ResponseEntity.ok(result);
        } else {
            // 대기 중인 플레이어가 2명 미만일 경우, 대기 중인 플레이어로 추가
            waitingPlayers.offer(choice);
            return ResponseEntity.ok("Waiting for another player...");
        }
    }

    @RequestMapping(value = "/play", method = RequestMethod.GET)
    public ResponseEntity<String> playGameREST(String choice) {
        // 게임 로직을 구현
        // choice: 가위, 바위, 보 중 하나의 선택

        // 큐에 플레이어 추가
        waitingPlayers.offer(choice);

        // 대기 중인 플레이어 수 확인
        int waitingPlayersCount = waitingPlayers.size();

        if (waitingPlayersCount >= 2) {
            // 2명 이상이 모이면 게임 시작
            String player1 = waitingPlayers.poll();
            String player2 = waitingPlayers.poll();

            // 게임 로직을 통해 결과 계산
            String result = calculateGameResult(player1, player2, choice);

            // 결과 반환
            return ResponseEntity.ok(result);
        } else {
            // 아직 2명 미만이면 대기 중 메시지 반환
            return ResponseEntity.ok("Waiting for another player...");
        }
    }

    // 가위바위보 게임 로직
    private String calculateGameResult(String player1, String player2, String choice) {
        // 간단한 가위바위보 로직
        if ((player1.equals("가위") && player2.equals("보"))
                || (player1.equals("바위") && player2.equals("가위"))
                || (player1.equals("보") && player2.equals("바위"))) {
            return "Player 1 wins!";
        } else if ((player2.equals("가위") && player1.equals("보"))
                || (player2.equals("바위") && player1.equals("가위"))
                || (player2.equals("보") && player1.equals("바위"))) {
            return "Player 2 wins!";
        } else {
            return "It's a tie!";
        }
    }
}
