package com.dragong.dragong.domain.friend.service;

import com.dragong.dragong.domain.friend.dto.request.FriendRequestDto;
import com.dragong.dragong.domain.friend.dto.response.FriendListDto;
import com.dragong.dragong.domain.friend.dto.response.FriendStatusResponseDto;
import com.dragong.dragong.domain.friend.dto.response.MessageListDto;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FriendService {
    
    // 한 친구를 검색해서 친구 관계 상태 보여주기
    // 상대 유저 닉네임 검색해서 닉네임이 존재하지 않거나 정지된 유저면 에러를 보이고
    // 상대 유저와의 친구 관계를 같이 보내는데, DB에 없을시 NONE으로...
    public FriendStatusResponseDto getFriendStatus(String accessToken, String refreshToken, String toNickname);

    // 친구 신청하기
    public void requestFriend(String accessToken, String refreshToken, FriendRequestDto friendRequestDto);

    // 친구 신청 수락하기
    public void acceptFriend(String accessToken, String refreshToken, FriendRequestDto friendRequestDto);

    // 친구 신청 거절하기
    public void rejectFriend(String accessToken, String refreshToken, FriendRequestDto friendRequestDto);

    // 친구 신청 수락 확인하기
    public void checkFriend(String accessToken, String refreshToken, FriendRequestDto friendRequestDto);

    // 절교하기
    public void disconnectFriend(String accessToken, String refreshToken, FriendRequestDto friendRequestDto);

    // 친구 리스트 불러오기(WAITING, FRIEND)
    public List<FriendListDto> getFriends(String accessToken, String refreshToken);

    // 메시지 리스트 불러오기(REQUESTCHECK, ACCEPTCHECK)
    public List<MessageListDto> getMessages(String accessToken, String refreshToken);

}
