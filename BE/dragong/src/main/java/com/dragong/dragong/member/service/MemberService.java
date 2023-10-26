package com.dragong.dragong.member.service;


import com.dragong.dragong.member.dto.request.RegistRequestDto;
import com.dragong.dragong.member.dto.request.LoginRequestDto;
import com.dragong.dragong.member.entity.SocialType;
import jakarta.servlet.http.HttpServletResponse;

public interface MemberService {

    void regist(RegistRequestDto registRequestDto, SocialType socialType,
            HttpServletResponse httpServletResponse);

    void login(LoginRequestDto loginRequestDto, HttpServletResponse httpServletResponse);
}
