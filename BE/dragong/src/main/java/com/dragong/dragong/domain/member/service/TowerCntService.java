package com.dragong.dragong.domain.member.service;

import com.dragong.dragong.domain.member.dto.request.AddMyChanceRequestDto;
import com.dragong.dragong.domain.member.dto.response.GetChanceResponseDto;

public interface TowerCntService {

    GetChanceResponseDto getMyChance(String accessToken);

    void updateMyChance(String accessToken, AddMyChanceRequestDto addMyChanceRequestDto);

}
