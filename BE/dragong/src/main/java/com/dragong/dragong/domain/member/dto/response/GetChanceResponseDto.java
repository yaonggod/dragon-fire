package com.dragong.dragong.domain.member.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetChanceResponseDto {
    private int chance;

    @Builder
    public GetChanceResponseDto(int chance) {
        this.chance = chance;
    }

}
