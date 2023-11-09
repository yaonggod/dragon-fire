package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;

import java.util.Map;

public interface ResultUpdateService {
    void updateWinner(String accessToken); // 승자의 승 추가 + 최고 점수 갱신해야 한다면 점수 갱신
    void updateLoser(String accessToken); // 패자의 패 추가
    String getWinnerInfo(String accessToken);
    String getLoserInfo(String accessToken);
    Map<String, Object> gettingInfo(String accessToken1, String nickname1, String accessToken2, String nickname2);
}
