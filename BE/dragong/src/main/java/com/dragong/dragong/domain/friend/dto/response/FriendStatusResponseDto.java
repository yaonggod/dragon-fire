package com.dragong.dragong.domain.friend.dto.response;

import com.dragong.dragong.domain.friend.entity.FriendStatus;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendStatusResponseDto {
    private UUID fromMember;
    private UUID toMember;
    private String toNickname;
    private FriendStatus friendStatus;
}
