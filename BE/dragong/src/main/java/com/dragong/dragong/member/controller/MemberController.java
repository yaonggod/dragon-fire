package com.dragong.dragong.member.controller;


import com.dragong.dragong.member.dto.request.RegistRequestDto;
import com.dragong.dragong.member.dto.request.LoginRequestDto;
import com.dragong.dragong.member.dto.response.LoginResponseDto;
import com.dragong.dragong.member.entity.SocialType;
import com.dragong.dragong.member.service.MemberService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oauth")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @PostMapping("/login/{socialType}")
    public ResponseEntity<?> verify_token(@RequestBody LoginRequestDto memberRequestDto,
            @PathVariable("socialType") SocialType socialType,
            HttpServletResponse httpServletResponse) {
        try {
            LoginResponseDto loginResponseDto = memberService.checkMember(memberRequestDto,
                    socialType, httpServletResponse);
            return ResponseEntity.ok(loginResponseDto);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/regist/{socialType}")
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

    @PostMapping("/jwt/login")
    public ResponseEntity<?> jwtLogin(HttpServletResponse httpServletResponse) {
        try {
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
