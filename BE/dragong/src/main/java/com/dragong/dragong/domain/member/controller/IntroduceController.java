package com.dragong.dragong.domain.member.controller;

import com.dragong.dragong.domain.member.dto.request.UpdateMyIntroduceRequestDto;
import com.dragong.dragong.domain.member.service.IntroduceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;

@RequestMapping("/resolve")
public class IntroduceController {

    @Autowired
    IntroduceService introduceService;

    @GetMapping
    public ResponseEntity<?> getMyIntroduce(@RequestHeader("Authorization") String accessToken) {
        try {
            return new ResponseEntity<>(introduceService.getMyIntroduce(accessToken), HttpStatus.OK);
        } catch (NullPointerException NPE) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PatchMapping
    public ResponseEntity<?> updateMyIntroduce(@RequestHeader("Authorization") String accessToken, UpdateMyIntroduceRequestDto updateMyIntroduceRequestDto) {
        try {
            introduceService.updateMyIntroduce(accessToken, updateMyIntroduceRequestDto);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (NullPointerException NPE) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
