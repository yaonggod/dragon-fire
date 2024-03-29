package com.dragong.dragong.domain.friend.dto.response;

import com.dragong.dragong.domain.friend.entity.FriendStatus;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class MessageListDto {
    private UUID toMember;
    private String toNickname;
    private FriendStatus friendStatus;
    private String fcmToken;

    // 이 사람의 전적
    private int score;
    private int win;
    private int lose;
}
