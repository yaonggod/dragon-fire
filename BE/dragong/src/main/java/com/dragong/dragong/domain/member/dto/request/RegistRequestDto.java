package com.dragong.dragong.domain.member.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class RegistRequestDto {

    private String nickname;
    private String accessToken;

}
