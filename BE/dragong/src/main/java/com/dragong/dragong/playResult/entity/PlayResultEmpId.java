package com.dragong.dragong.playResult.entity;

import com.dragong.dragong.member.entity.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
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

    @OneToMany
    @JoinColumn(name = "uuid")
    private List<Member> member;

}
