package com.dragong.dragong.domain.game.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class FriendAssignRoomResponseDto {

    private int roomId;

    @Builder
    public FriendAssignRoomResponseDto(int roomId) {
        this.roomId = roomId;
    }
}
