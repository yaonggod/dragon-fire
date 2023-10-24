package com.dragong.dragong.playResult.entity;

import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "playResult")
public class PlayResult extends BaseTimeEntity {

    @EmbeddedId
    private PlayResultEmpId playResultEmpId;

    @Column(name = "win")
    private int win;

    @Column(name = "lose")
    private int lose;

    @Column(name = "score")
    private int score;

    @Column(name = "season_max_score")
    private int seasonMaxScore;
}
