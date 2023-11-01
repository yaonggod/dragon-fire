package com.dragong.dragong.domain.game.service;

public interface ResultUpdateService {
    void updateWinner(String accessToken); // 승자의 승 추가 + 최고 점수 갱신해야 한다면 점수 갱신
    void updateLoser(String accessToken); // 패자의 패 추가

//    void testing();
}
