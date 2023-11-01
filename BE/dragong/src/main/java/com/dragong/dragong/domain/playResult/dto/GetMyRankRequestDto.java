package com.dragong.dragong.domain.playResult.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GetMyRankRequestDto {
    String nickname;
    String score;
    String rank;
    String win;
    String lose;
    String seasonMaxScore;
}