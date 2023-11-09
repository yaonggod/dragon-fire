package com.dragong.dragong.domain.playLog.controller;

import com.dragong.dragong.domain.playLog.dto.GetMyPlayListRequestDto;
import com.dragong.dragong.domain.playLog.service.PlayLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/play-log")
public class PlayLogController {

    @Autowired
    PlayLogService playLogService;

    @GetMapping
    public ResponseEntity<?> getMyPlayLogList(@RequestHeader("Authorization") String accessToken) {
        GetMyPlayListRequestDto getMyPlayListRequestDto = new GetMyPlayListRequestDto();
        getMyPlayListRequestDto.setAccessToken(accessToken);
        try {
            return new ResponseEntity<>(playLogService.getMyPlayList(getMyPlayListRequestDto),
                HttpStatus.OK);
        } catch (NullPointerException npe) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

}
