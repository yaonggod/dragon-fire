package com.dragong.dragong.domain.member.service;


import com.dragong.dragong.domain.member.dto.request.LoginRequestDto;
import com.dragong.dragong.domain.member.dto.request.RegistRequestDto;
import com.dragong.dragong.domain.member.dto.request.UpdateRequestDto;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.entity.SocialType;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface MemberService {

    void regist(RegistRequestDto registRequestDto, SocialType socialType,
            HttpServletResponse httpServletResponse);

    void login(LoginRequestDto loginRequestDto, HttpServletResponse httpServletResponse);

    void update(UpdateRequestDto updateRequestDto, HttpServletRequest httpServletRequest,
            HttpServletResponse httpServletResponse);

    void nicknameCheck(String nickname, HttpServletRequest httpServletRequest,
            HttpServletResponse httpServletResponse);

    void logout(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse);

    void delete(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse);

    MemberInfo getMyMemberInfo(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse);

    Member getMyMember(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse);

}
