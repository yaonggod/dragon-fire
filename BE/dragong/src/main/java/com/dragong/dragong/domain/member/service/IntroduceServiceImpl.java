package com.dragong.dragong.domain.member.service;

import com.dragong.dragong.domain.member.dto.request.UpdateMyIntroduceRequestDto;
import com.dragong.dragong.domain.member.dto.response.GetMyIntroduceResponseDto;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.global.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class IntroduceServiceImpl implements IntroduceService {

    @Autowired
    JwtUtil jwtUtil;

    @Autowired
    MemberInfoRepository memberInfoRepository;

    @Override
    public GetMyIntroduceResponseDto getMyIntroduce(String accessToken) {
        UUID uuid = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo memberinfo = memberInfoRepository.findById(uuid).orElseThrow(() -> new NullPointerException());

        return GetMyIntroduceResponseDto.builder()
                .introduce(memberinfo.getIntroduction())
                .nickname(memberinfo.getNickname())
                .build();
    }

    @Override
    public void updateMyIntroduce(String accessToken, UpdateMyIntroduceRequestDto updateMyIntroduceRequestDto) {
        UUID uuid = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo memberinfo = memberInfoRepository.findById(uuid).orElseThrow(() -> new NullPointerException());
        memberinfo.updateIntroduction(updateMyIntroduceRequestDto.getIntroduce());
        memberInfoRepository.save(memberinfo);
    }
}
