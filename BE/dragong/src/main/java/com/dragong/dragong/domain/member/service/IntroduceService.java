package com.dragong.dragong.domain.member.service;

import com.dragong.dragong.domain.member.dto.request.UpdateMyIntroduceRequestDto;
import com.dragong.dragong.domain.member.dto.response.GetMyIntroduceResponseDto;

public interface IntroduceService {

    GetMyIntroduceResponseDto getMyIntroduce(String accessToken);

    void updateMyIntroduce(String accessToken, UpdateMyIntroduceRequestDto updateMyIntroduceRequestDto);
}
