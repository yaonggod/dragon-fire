package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class GameRoomData {
    private String nickname;
    private String picked;


    public GameRoomData(String nickname, String picked) {
        this.nickname = nickname;
        this.picked = picked;
    }
}
