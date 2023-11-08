package com.dragong.dragong.domain.friend.controller;

import com.dragong.dragong.domain.friend.dto.request.FriendRequestDto;
import com.dragong.dragong.domain.friend.service.FriendService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/friend")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @GetMapping("/search/{nickname}")
    public ResponseEntity<?> getFriendStatus(@PathVariable("nickname") String nickname,
            @RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {
        return new ResponseEntity<>(friendService.getFriendStatus(accessToken, refreshToken, nickname), HttpStatus.OK);
    }

    @PostMapping("/request")
    public ResponseEntity<?> requestFriend(@RequestBody FriendRequestDto friendRequestDto,
            @RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken,
            HttpServletResponse httpServletResponse) {
        friendService.requestFriend(accessToken, refreshToken, friendRequestDto, httpServletResponse);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/accept")
    public ResponseEntity<?> acceptFriend(@RequestBody FriendRequestDto friendRequestDto,
            @RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken, HttpServletResponse httpServletResponse) {
        friendService.acceptFriend(accessToken, refreshToken, friendRequestDto, httpServletResponse);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/reject")
    public ResponseEntity<?> rejectFriend(@RequestBody FriendRequestDto friendRequestDto,
            @RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {
        friendService.rejectFriend(accessToken, refreshToken, friendRequestDto);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/check")
    public ResponseEntity<?> checkFriend(@RequestBody FriendRequestDto friendRequestDto,
            @RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {
        friendService.checkFriend(accessToken, refreshToken, friendRequestDto);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/disconnect")
    public ResponseEntity<?> disconnectFriend(@RequestBody FriendRequestDto friendRequestDto,
            @RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {
        friendService.disconnectFriend(accessToken, refreshToken, friendRequestDto);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @GetMapping("/friends")
    public ResponseEntity<?> getFriends(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {
        return new ResponseEntity<>(friendService.getFriends(accessToken, refreshToken), HttpStatus.OK);
    }

    @GetMapping("/messages")
    public ResponseEntity<?> getMessages(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken) {
        return new ResponseEntity<>(friendService.getMessages(accessToken, refreshToken), HttpStatus.OK);
    }
}
