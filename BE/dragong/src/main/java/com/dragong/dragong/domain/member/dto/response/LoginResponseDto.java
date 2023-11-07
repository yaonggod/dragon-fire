package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class LoginResponseDto {

    private String nickname;

    @Builder
    public LoginResponseDto(String nickname){
        this.nickname = nickname;
    }
}
