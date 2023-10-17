package com.dragong.dragong.domain.game.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessageType;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.user.SimpUserRegistry;
import org.springframework.stereotype.Controller;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.HtmlUtils;

import java.util.Collections;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

@RequiredArgsConstructor
@RestController
public class GameController {
    private Queue<String> waitingPlayers = new LinkedList<>();
    private final Lock lock = new ReentrantLock();
    @MessageMapping("/start-game")
    @SendTo("/topic/game-status")
    public String startGame(@Payload String playerName) {
        System.out.println("이거 실행됩니다");
        waitingPlayers.add(playerName);
        if (waitingPlayers.size() == 2) {
            // 두 명의 플레이어가 모였을 때만 게임 시작
            System.out.println("현재 이거 실행중");
            String player1 = waitingPlayers.poll();
            String player2 = waitingPlayers.poll();
            return "Game started with " + player1 + " and " + player2;
        }
        System.out.println("이게 실행되어버렸다");
        // 아직 두 명이 모이지 않았을 때 "아직 기다리는 중" 반환
        return "아직 기다리는 중";
    }
}
