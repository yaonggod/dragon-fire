package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class NicknameUpdateResponseDto {

    private String nickname;

    @Builder
    public NicknameUpdateResponseDto(String nickname){
        this.nickname = nickname;
    }
}
