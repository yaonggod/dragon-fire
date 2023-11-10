package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class LogData {
    private String nickname;
    private String log;

    public LogData(String nickname, String log) {
        this.nickname = nickname;
        this.log = log;
    }
}
