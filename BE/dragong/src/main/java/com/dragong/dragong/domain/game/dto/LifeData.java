package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class LifeData {
    private String nickname;
    private int life;

    public LifeData(String nickname, int life) {
        this.nickname = nickname;
        this.life= life;
    }
}
