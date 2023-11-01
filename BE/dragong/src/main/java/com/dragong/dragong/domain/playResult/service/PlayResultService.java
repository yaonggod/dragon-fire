package com.dragong.dragong.domain.playResult.service;

import com.dragong.dragong.domain.playResult.dto.GetMyRankRequestDto;
import com.dragong.dragong.domain.playResult.dto.GetRankRequestDto;
import java.util.List;

public interface PlayResultService {

    void putRank();

    List<GetRankRequestDto> getRank();

    GetMyRankRequestDto getMyRank(String accessToken);

    int getSeason();
}
