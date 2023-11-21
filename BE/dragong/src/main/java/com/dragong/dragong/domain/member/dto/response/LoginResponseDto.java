package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class LoginResponseDto {

    private String nickname;
    private String email;
    private String introduction;

    @Builder
    public LoginResponseDto(String nickname, String email, String introduction) {
        this.nickname = nickname;
        this.email = email;
        this.introduction = introduction;
    }
}
