package com.dragong.dragong.domain.game.dto;

import org.springframework.stereotype.Component;

@Component
public class PeopleCounter {
    private int cnt = 0;

    public int getPeopleCnt(){
        return cnt;
    }

    public void incrementPeopleCount(){
        cnt++;
    }

    public void decrementPeopleCount(){
        cnt--;
    }
}
