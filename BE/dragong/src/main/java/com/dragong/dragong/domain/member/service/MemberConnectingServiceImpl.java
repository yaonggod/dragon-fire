package com.dragong.dragong.domain.member.service;

import com.dragong.dragong.domain.member.dto.request.ChangeConditionRequest;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.global.util.JwtUtil;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MemberConnectingServiceImpl implements MemberConnectingService{

    @Autowired
    JwtUtil jwtUtil;

    @Autowired
    MemberInfoRepository memberInfoRepository;

    @Override
    public void changeCondition(ChangeConditionRequest changeConditionRequest) {
        String accessToken = changeConditionRequest.getAccessToken();
        UUID UUID = jwtUtil.extractMemberId(accessToken.substring(7));

        MemberInfo memberInfo = memberInfoRepository.findById(UUID).orElseThrow(() -> new NullPointerException());

        // 상태 변경
        memberInfo.updateIsConnecting(changeConditionRequest.isCondition());

        // 저장
        memberInfoRepository.save(memberInfo);
    }
}
