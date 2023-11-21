package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class IntroductionUpdateResponseDto {

    String introduction;

    @Builder
    public IntroductionUpdateResponseDto(String introduction){
        this.introduction = introduction;
    }

}
