package com.dragong.dragong.domain.friend.dto.request;

import java.util.UUID;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendRequestDto {
    private UUID fromMember;
    private UUID toMember;
}
