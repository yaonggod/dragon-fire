package com.dragong.dragong.playResult.entity;

import com.dragong.dragong.member.entity.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import java.io.Serializable;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class PlayResultEmpId implements Serializable {
    @Column(name = "season")
    private int season;

    @OneToOne // 에러나면 이 부분 수정해주기 => many to one
    @JoinColumn(name = "uuid")
    private Member member;

}
