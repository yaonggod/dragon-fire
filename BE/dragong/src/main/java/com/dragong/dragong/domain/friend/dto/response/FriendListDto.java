package com.dragong.dragong.domain.friend.dto.response;

import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class FriendListDto {
    private UUID toMember;
    private String toNickname;
    private int score;
    private int win;
    private int lose;
}
