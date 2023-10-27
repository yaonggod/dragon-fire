package com.dragong.dragong.domain.playResult.entity;

import com.dragong.dragong.domain.member.entity.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import java.io.Serializable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class PlayResultEmpId implements Serializable {
    @Column(name = "season")
    private int season;

    @OneToOne(fetch = FetchType.LAZY) // 에러나면 이 부분 수정해주기 => many to one
    @JoinColumn(name = "uuid")
    private Member member;

}
