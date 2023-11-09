package com.dragong.dragong.domain.playLog.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetMyPlayListResponseDto {

    private String myNickname;
    private String opponentNickname;
    private boolean playResult;
    private String myPlay;
    private String opponentPlay;


    @Builder
    GetMyPlayListResponseDto(String myNickname, String opponentNickname, boolean playResult,
        String myPlay, String opponentPlay) {
        this.myNickname = myNickname;
        this.opponentNickname = opponentNickname;
        this.playResult = playResult;
        this.myPlay = myPlay;
        this.opponentPlay = opponentPlay;
    }
}
