package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.checkerframework.checker.units.qual.N;

@Getter
@NoArgsConstructor
public class GetMyInfoResponseDto {
    String nickname;
    String email;
    String introduction;

    @Builder
    public GetMyInfoResponseDto(String nickname, String email, String introduction){
        this.nickname = nickname;
        this.email = email;
        this.introduction = introduction;
    }
}
