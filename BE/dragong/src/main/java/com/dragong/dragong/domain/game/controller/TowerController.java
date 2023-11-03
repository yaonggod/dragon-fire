package com.dragong.dragong.domain.game.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@Slf4j
public class TowerController {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;


    @PostMapping("/tower/{towerFloor}")
    public ResponseEntity<Map<String, Integer>> assignRoom(@RequestHeader("Authorization") String accessToken, @RequestBody Map<String, String> requestBody,@PathVariable String towerFloor) {
        String nickname = requestBody.get("nickname");
        log.info("받아온 nickname : " + nickname);
        log.info("받아온 accessToken : " + accessToken);
        log.info("받아온 탑의 층수는: "+towerFloor);
        log.info("타워에 입장합니다.");
        int floor = Integer.parseInt(towerFloor);
        Map<String, Integer> response = new HashMap<>();
        response.put("towerFloor", floor); // 층수를 담아서 넘긴다.
        return ResponseEntity.ok(response);
    }


}
