package com.dragong.dragong.domain.member.dto.request;

import com.dragong.dragong.domain.member.entity.SocialType;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class LoginRequestDto {

    // 구글 리소스 서버의 액세스 토큰
    private String accessToken;
    private SocialType socialType;
}
