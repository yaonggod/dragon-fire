package com.dragong.dragong.member.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class LoginRequestDto {

    private String accessToken;
    private String refreshToken;
}
