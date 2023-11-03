package com.dragong.dragong.domain.friend.dto.response;

import com.dragong.dragong.domain.friend.entity.FriendStatus;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.apache.tomcat.util.digester.FactoryCreateRule;

@Getter
@Setter
@Builder
public class FriendStatusResponseDto {
    private UUID toMember;
    private String toNickname;
    private FriendStatus friendStatus;
    private String fcmToken;

    // 이 사람의 전적
    private int score;
    private int win;
    private int lose;

    // 나랑 이 사람 간의 전적 - win : 내가 이김, lose : 쟤가 이김
    private int friendWin;
    private int friendLose;
}
