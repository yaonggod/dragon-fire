package com.dragong.dragong.domain.game.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class FriendConnectGameResponseDto {

    private String nickname1;
    private String nickname2;
    private int user1Win;
    private int user1Lose;
    private int user2Win;
    private int user2Lose;

    @Builder
    public FriendConnectGameResponseDto(String nickname1, String nickname2, int user1Win, int user1Lose, int user2Win, int user2Lose){
        this.nickname1 = nickname1;
        this.nickname2 = nickname2;
        this.user1Win = user1Win;
        this.user2Win = user2Win;
        this.user1Lose = user1Lose;
        this.user2Lose = user2Lose;
    }
}
