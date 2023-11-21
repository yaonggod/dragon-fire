package com.dragong.dragong.domain.member.controller;

import com.dragong.dragong.domain.member.dto.request.ChangeConditionRequest;
import com.dragong.dragong.domain.member.service.MemberConnectingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/connecting")
public class MemberConnectingController {

    @Autowired
    MemberConnectingService memberConnectingService;

    @PatchMapping
    public ResponseEntity<?> changeConnecting(@RequestHeader("Authorization") String accessToken,
        @RequestBody ChangeConditionRequest changeConditionRequest) {
        changeConditionRequest.setAccessToken(accessToken);

        try {
            memberConnectingService.changeCondition(changeConditionRequest);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (NullPointerException NPE) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
