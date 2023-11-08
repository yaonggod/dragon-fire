package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class WinData {
    private String nickname;
    private int win;

    public WinData(String nickname, int win) {
        this.nickname = nickname;
        this.win= win;
    }
}
