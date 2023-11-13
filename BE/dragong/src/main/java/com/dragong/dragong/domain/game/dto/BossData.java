package com.dragong.dragong.domain.game.dto;

import lombok.Data;

@Data
public class BossData {
    private String bossName; // 보스 이름
    private int evacuatePer; // 보스 회피 확률
    private int life; // 보스 생명통

    public BossData(String bossName,int evacuatePer, int life){
        this.bossName=bossName;
        this.evacuatePer = evacuatePer;
        this.life = life;
    }
}
