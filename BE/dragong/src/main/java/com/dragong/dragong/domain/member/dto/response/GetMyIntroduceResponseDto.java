package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetMyIntroduceResponseDto {
    private String nickname;
    private String introduce;

    @Builder
    public GetMyIntroduceResponseDto(String nickname, String introduce) {
        this.nickname = nickname;
        this.introduce = introduce;
    }
}
