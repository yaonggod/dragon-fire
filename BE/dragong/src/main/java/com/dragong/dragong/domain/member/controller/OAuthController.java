package com.dragong.dragong.domain.member.controller;


import com.dragong.dragong.domain.member.dto.request.LoginRequestDto;
import com.dragong.dragong.domain.member.dto.request.RegistRequestDto;
import com.dragong.dragong.domain.member.dto.response.LoginResponseDto;
import com.dragong.dragong.domain.member.entity.SocialType;
import com.dragong.dragong.domain.member.service.MemberService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oauth")
@RequiredArgsConstructor
public class OAuthController {

    private final MemberService memberService;

    @PostMapping("/login")
    public ResponseEntity<?> loginMember(@RequestBody LoginRequestDto loginRequestDto,
            HttpServletResponse httpServletResponse) {
        try {
            LoginResponseDto response = memberService.login(loginRequestDto, httpServletResponse);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/{socialType}")
    public ResponseEntity<?> registMember(
            @RequestBody RegistRequestDto registRequestDto,
            @PathVariable("socialType") SocialType socialType,
            HttpServletResponse httpServletResponse) {
        try {
            memberService.regist(registRequestDto, socialType, httpServletResponse);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logoutMember(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken,
            HttpServletResponse httpServletResponse) {
        try {
            memberService.logout(accessToken, refreshToken, httpServletResponse);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/out")
    public ResponseEntity<?> deleteMember(@RequestHeader("Authorization") String accessToken,
            @RequestHeader("refreshToken") String refreshToken,
            HttpServletResponse httpServletResponse) {
        try {
            memberService.delete(accessToken, refreshToken, httpServletResponse);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
