package com.dragong.dragong.domain.member.controller;

import com.dragong.dragong.domain.member.dto.request.AddMyChanceRequestDto;
import com.dragong.dragong.domain.member.service.TowerCntService;
import java.util.NoSuchElementException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/chance")
public class MemberChanceCtroller {

    @Autowired
    TowerCntService towerCntService;

    @GetMapping
    public ResponseEntity<?> getMyChance(@RequestHeader("Authorization") String accessToken) {
        try {
            return new ResponseEntity<>(towerCntService.getMyChance(accessToken), HttpStatus.OK);
        } catch (NoSuchElementException NSEE) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PatchMapping
    public ResponseEntity<?> addMyChance(@RequestHeader("Authorization") String accessToken,
        @RequestBody AddMyChanceRequestDto addMyChanceRequestDto) {
        try {
            towerCntService.updateMyChance(accessToken, addMyChanceRequestDto);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (NoSuchElementException NSEE) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

    }
}
