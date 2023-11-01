package com.dragong.dragong.domain.playResult.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class GetNicknameResponseDto {
    String nickname;
    int lose;
    int win;
    int score;
    int seasonMaxScore;
}
