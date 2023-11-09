package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class LoginResponseDto {

    private String nickname;
    private String email;

    @Builder
    public LoginResponseDto(String nickname, String email) {
        this.nickname = nickname;
        this.email = email;
    }
}
