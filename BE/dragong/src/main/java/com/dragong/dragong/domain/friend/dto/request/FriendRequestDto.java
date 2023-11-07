package com.dragong.dragong.domain.friend.dto.request;

import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FriendRequestDto {
    // fromMember의 정보는 AT, RT로 얻어내기
    private UUID toMember;
}
