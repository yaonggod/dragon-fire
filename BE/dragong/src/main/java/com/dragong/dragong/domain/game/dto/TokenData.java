package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class TokenData {
    private String accessToken;
    private String nickname;

    public TokenData(String accessToken, String nickname) {
        this.accessToken = accessToken;
        this.nickname= nickname;
    }
}
