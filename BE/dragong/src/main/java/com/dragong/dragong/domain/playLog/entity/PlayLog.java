package com.dragong.dragong.domain.playLog.entity;

import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class PlayLog extends BaseTimeEntity {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "play_result")
    private boolean playResult;

    @Column(name = "my_play")
    private String myPlay;

    @Column(name = "opponent_play")
    private String opponentPlay;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "my_uuid")
    private Member myUUID;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "opponent_uuid")
    private Member opponentUUID;
}
