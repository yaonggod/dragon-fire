package com.dragong.dragong.domain.member.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ChangeConditionRequest {
    private String accessToken;
    private boolean condition;
}
