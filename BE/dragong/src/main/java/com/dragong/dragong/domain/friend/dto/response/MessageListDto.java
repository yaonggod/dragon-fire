package com.dragong.dragong.domain.friend.dto.response;

import com.dragong.dragong.domain.friend.entity.FriendStatus;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MessageListDto {
    private UUID toMember;
    private String toNickname;
    private FriendStatus friendStatus;
    private String fcmToken;
    private int score;
    private int win;
    private int lose;
}
