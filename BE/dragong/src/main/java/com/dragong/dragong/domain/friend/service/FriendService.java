package com.dragong.dragong.domain.friend.service;

import com.dragong.dragong.domain.friend.dto.request.FriendRequestDto;
import com.dragong.dragong.domain.friend.dto.response.FriendStatusResponseDto;
import java.util.UUID;

public interface FriendService {
    
    // 한 친구를 검색해서 친구 관계 상태 보여주기, 없거나 DISCONNECTED이면 에러
    public FriendStatusResponseDto getFriendStatus(UUID fromMember, UUID toMember);

    // 친구 신청하기
    public void requestFriend(FriendRequestDto friendRequestDto);
}
