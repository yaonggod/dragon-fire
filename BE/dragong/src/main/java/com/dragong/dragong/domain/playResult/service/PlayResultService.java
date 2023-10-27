package com.dragong.dragong.domain.playResult.service;

import com.dragong.dragong.domain.playResult.dto.GetMyRankRequestDto;
import com.dragong.dragong.domain.playResult.dto.GetRankRequestDto;

public interface PlayResultService {

    void putRank();

    GetRankRequestDto getRank();

    GetMyRankRequestDto getMyRank(String accessToken);
}
