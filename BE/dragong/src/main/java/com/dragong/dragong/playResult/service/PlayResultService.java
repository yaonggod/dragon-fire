package com.dragong.dragong.playResult.service;

import com.dragong.dragong.playResult.dto.GetMyRankRequestDto;
import com.dragong.dragong.playResult.dto.GetRankRequestDto;
import java.util.UUID;

public interface PlayResultService {
    // 레디스 밸류에 들어갈 값 및 타입 알아보기
    // 동일한 키에 스트링을 순서대로 넣으면 리스트가 됨(LPUSH 해야함)


    void putRank();

    GetRankRequestDto getRank();

    GetMyRankRequestDto getMyRank(String accessToken);
}
