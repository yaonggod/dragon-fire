package com.dragong.dragong.domain.friend.service;

import com.dragong.dragong.domain.friend.repository.FriendRepository;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.member.repository.FcmTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl implements FriendService {

    private final FriendRepository friendRepository;
    private final MemberRepository memberRepository;
    private final MemberInfoRepository memberInfoRepository;
    private final FcmTokenRepository fcmTokenRepository;


}
