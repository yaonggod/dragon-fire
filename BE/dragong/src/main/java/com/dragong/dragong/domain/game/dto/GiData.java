package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class GiData {
    private String nickname;
    private int gi;

    public GiData(String nickname,int gi){
        this.nickname=nickname;
        this.gi = gi;
    }

}
