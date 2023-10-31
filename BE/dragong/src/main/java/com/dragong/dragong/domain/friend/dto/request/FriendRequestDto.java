package com.dragong.dragong.domain.friend.dto.request;

import java.util.UUID;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendRequestDto {
    // fromMember의 정보는 AT, RT로 얻어내기
    private UUID toMember;
}
