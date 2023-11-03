package com.dragong.dragong.domain.game.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class TowerController {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
}
