package com.dragong.dragong.domain.member.controller;


import com.dragong.dragong.domain.member.dto.request.UpdateRequestDto;
import com.dragong.dragong.domain.member.service.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @PutMapping("/nickname-modify")
    public ResponseEntity<?> updateMember(@RequestBody UpdateRequestDto updateRequestDto,
            HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) {
        try {
            memberService.update(updateRequestDto, httpServletRequest, httpServletResponse);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/nickname-duplicate/{nickname}")
    public ResponseEntity<?> nicknameCheck(@PathVariable("nickname") String nickname,
            HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) {
        try {
            memberService.nicknameCheck(nickname, httpServletRequest, httpServletResponse);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
