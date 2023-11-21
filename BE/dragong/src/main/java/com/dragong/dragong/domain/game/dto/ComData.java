package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class ComData {

    private String nickname;
    private String uuid;

    public ComData(String nickname,String uuid){
        this.nickname=nickname;
        this.uuid = uuid;
    }
}
